import argparse
import csv
import os
from pathlib import Path

from dotenv import load_dotenv

from cache import is_current_result, load_json, metadata, write_json
from gemini_client import GeminiClient
from youtube import extract_video_id

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT.parents[1] / "data"
INPUT_FILE = ROOT / "input" / "shorts-urls.txt"
RAW_DIR = ROOT / "ingredient" / "raw"
REVIEW_DIR = ROOT / "ingredient" / "review"
MANIFEST_FILE = ROOT / "ingredient" / "manifest.json"
INGREDIENTS_FILE = DATA_DIR / "ingredients.csv"


def read_urls(path: Path) -> list[str]:
    if not path.exists():
        return []

    urls = []
    seen_video_ids = set()

    for line in path.read_text(encoding="utf-8").splitlines():
        value = line.strip()
        if not value or value.startswith("#"):
            continue

        video_id = extract_video_id(value)
        if video_id in seen_video_ids:
            continue

        seen_video_ids.add(video_id)
        urls.append(value)

    return urls


def update_manifest(video_id: str, status: str, **extra: object) -> None:
    manifest = load_json(MANIFEST_FILE, {"videos": {}})
    current = manifest["videos"].get(video_id, {})
    manifest["videos"][video_id] = {
        **current,
        "status": status,
        **extra,
    }
    write_json(MANIFEST_FILE, manifest)


def cleanup_stale_results(active_video_ids: set[str]) -> None:
    manifest = load_json(MANIFEST_FILE, {"videos": {}})
    videos = manifest.get("videos", {})
    stale_video_ids = set(videos) - active_video_ids

    for video_id in sorted(stale_video_ids):
        (RAW_DIR / f"{video_id}.json").unlink(missing_ok=True)
        videos.pop(video_id, None)
        print(f"[cleanup] removed stale result {video_id}")

    manifest["videos"] = videos
    write_json(MANIFEST_FILE, manifest)


def read_csv_rows(path: Path) -> list[dict]:
    if not path.exists() or path.stat().st_size == 0:
        return []

    with path.open(encoding="utf-8", newline="") as file:
        return list(csv.DictReader(file))


def load_existing_master() -> set[str]:
    ingredient_rows = read_csv_rows(INGREDIENTS_FILE)
    return {
        row["canonical_name"].strip()
        for row in ingredient_rows
        if row.get("canonical_name")
    }


def raw_texts_for(items: list[dict]) -> list[str]:
    return sorted({item["rawText"] for item in items if item.get("rawText")})


def run_raw_extraction(model: str, force: bool) -> None:
    client = GeminiClient(model=model)
    urls = read_urls(INPUT_FILE)
    total = len(urls)
    active_video_ids = {extract_video_id(source_url) for source_url in urls}

    cleanup_stale_results(active_video_ids)

    for index, source_url in enumerate(urls, start=1):
        video_id = extract_video_id(source_url)
        raw_path = RAW_DIR / f"{video_id}.json"
        progress = f"[{index}/{total}] {video_id}"

        existing = load_json(raw_path, None)
        if not force and existing and is_current_result(existing, model):
            print(f"{progress} SKIP cached result")
            update_manifest(video_id, "COMPLETED", sourceUrl=source_url, skipped=True)
            continue

        print(f"{progress} PROCESS {source_url}")
        update_manifest(video_id, "PROCESSING", sourceUrl=source_url)

        try:
            ingredients = client.extract_ingredients(source_url)
            result = {
                "videoId": video_id,
                "sourceUrl": source_url,
                "pipeline": metadata(model),
                "ingredients": ingredients,
            }
            write_json(raw_path, result)
            update_manifest(video_id, "COMPLETED", sourceUrl=source_url)
            print(f"{progress} DONE extracted {len(ingredients)} ingredients")
        except Exception as exc:
            update_manifest(
                video_id,
                "FAILED",
                sourceUrl=source_url,
                error=str(exc),
            )
            print(f"{progress} FAILED {exc}")


def build_review_proposal() -> None:
    expressions = {}

    for path in sorted(RAW_DIR.glob("*.json")):
        data = load_json(path, {})
        for ingredient in data.get("ingredients", []):
            display_name = ingredient.get("displayName")
            if not display_name:
                continue

            expressions.setdefault(display_name, []).append(
                {
                    "videoId": data.get("videoId"),
                    "rawText": ingredient.get("rawText"),
                    "amount": ingredient.get("amount"),
                    "unit": ingredient.get("unit"),
                }
            )

    master = load_existing_master()
    existing_mappings = []
    new_ingredients = []

    for name in sorted(expressions):
        if name in master:
            existing_mappings.append(
                {
                    "raw": name,
                    "ingredient": name,
                }
            )
            continue

        new_ingredients.append(
            {
                "canonicalName": name,
                "sourceExpressions": raw_texts_for(expressions[name]),
            }
        )

    proposal = {
        "existingMappings": existing_mappings,
        "newIngredients": new_ingredients,
        "unresolved": [],
        "sourceExpressions": expressions,
    }

    write_json(REVIEW_DIR / "ingredient-master-proposal.json", proposal)


def main() -> None:
    load_dotenv()

    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true")
    parser.add_argument(
        "--model",
        default=os.environ.get("GEMINI_MODEL", "models/gemini-2.5-flash"),
    )
    parser.add_argument(
        "--skip-review",
        action="store_true",
        help="Only run raw extraction and do not create review proposal.",
    )
    args = parser.parse_args()

    run_raw_extraction(model=args.model, force=args.force)

    if not args.skip_review:
        build_review_proposal()


if __name__ == "__main__":
    main()
