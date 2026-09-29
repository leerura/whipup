import argparse
import os
from pathlib import Path

from dotenv import load_dotenv

from cache import (
    INGREDIENT_STAGE_ONE_PIPELINE_TYPE,
    INGREDIENT_STAGE_ONE_PIPELINE_VERSION,
    is_current_result,
    load_json,
    metadata,
    write_json,
)
from gemini_client import GeminiClient
from youtube import extract_video_id

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT.parents[1] / "data"
INPUT_FILE = ROOT / "input" / "shorts-urls.txt"
RAW_DIR = ROOT / "ingredient" / "raw"
APPROVED_DIR = ROOT / "ingredient" / "approved"
MANIFEST_FILE = ROOT / "ingredient" / "manifest.json"


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
    entry = {
        **current,
        "status": status,
        **extra,
    }
    if status != "FAILED":
        entry.pop("error", None)
    manifest["videos"][video_id] = entry
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


def assign_source_ids(ingredients: list[dict]) -> list[dict]:
    return [
        {
            "sourceId": f"ingredient-{index}",
            **ingredient,
        }
        for index, ingredient in enumerate(ingredients, start=1)
    ]


def approve_stage_one_result(video_id: str) -> None:
    raw_path = RAW_DIR / f"{video_id}.json"
    result = load_json(raw_path, None)
    if result is None:
        raise RuntimeError(f"Stage 1 result not found for videoId: {video_id}")
    if not isinstance(result.get("ingredients"), list):
        raise RuntimeError(f"Stage 1 result has no ingredients list: {video_id}")

    write_json(APPROVED_DIR / f"{video_id}.json", result)
    update_manifest(
        video_id,
        "APPROVED",
        sourceUrl=result.get("sourceUrl"),
    )
    print(f"[approve] {video_id} APPROVED")


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
        if not force and existing and is_current_result(
            existing,
            model,
            pipeline_type=INGREDIENT_STAGE_ONE_PIPELINE_TYPE,
            pipeline_version=INGREDIENT_STAGE_ONE_PIPELINE_VERSION,
        ):
            print(f"{progress} SKIP cached result")
            update_manifest(video_id, "REVIEW_REQUIRED", sourceUrl=source_url, skipped=True)
            continue

        print(f"{progress} PROCESS {source_url}")
        update_manifest(video_id, "PROCESSING", sourceUrl=source_url)

        try:
            ingredients = assign_source_ids(
                client.extract_stage_one_ingredients(source_url)
            )
            result = {
                "videoId": video_id,
                "sourceUrl": source_url,
                "pipeline": metadata(
                    model,
                    pipeline_type=INGREDIENT_STAGE_ONE_PIPELINE_TYPE,
                    pipeline_version=INGREDIENT_STAGE_ONE_PIPELINE_VERSION,
                ),
                "ingredients": ingredients,
            }
            write_json(raw_path, result)
            update_manifest(video_id, "REVIEW_REQUIRED", sourceUrl=source_url)
            print(f"{progress} DONE extracted {len(ingredients)} ingredients")
        except Exception as exc:
            update_manifest(
                video_id,
                "FAILED",
                sourceUrl=source_url,
                error=str(exc),
            )
            print(f"{progress} FAILED {exc}")

def main() -> None:
    load_dotenv()

    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true")
    parser.add_argument(
        "--model",
        default=os.environ.get("GEMINI_MODEL", "models/gemini-2.5-flash"),
    )
    parser.add_argument(
        "--approve",
        metavar="VIDEO_ID",
        help="Copy a human-reviewed Stage 1 result into the approved input set.",
    )
    args = parser.parse_args()

    if args.approve:
        if args.force:
            parser.error("--approve cannot be used with --force")
        approve_stage_one_result(args.approve)
        return

    run_raw_extraction(model=args.model, force=args.force)


if __name__ == "__main__":
    main()
