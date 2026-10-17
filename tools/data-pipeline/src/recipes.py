import argparse
import os
from pathlib import Path

from dotenv import load_dotenv

from cache import (
    RECIPE_STAGE_TWO_PIPELINE_TYPE,
    RECIPE_STAGE_TWO_PIPELINE_VERSION,
    is_current_result,
    load_json,
    metadata,
    write_json,
)
from dataset import ingredient_master_hash, load_ingredient_master
from gemini_client import GeminiClient
from youtube import extract_video_id
from validator import validate_and_publish

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT.parents[1] / "data"
INPUT_FILE = ROOT / "input" / "shorts-urls.txt"
APPROVED_DIR = ROOT / "ingredient" / "approved"
RAW_DIR = ROOT / "recipe" / "raw"
REVIEW_DIR = ROOT / "recipe" / "review"
MANIFEST_FILE = ROOT / "recipe" / "manifest.json"
INGREDIENTS_FILE = DATA_DIR / "ingredients.json"


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


def dataset_key_for(video_id: str) -> str:
    return f"recipe-{video_id.encode('ascii').hex()}"


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
    if status != "REVIEW_REQUIRED":
        entry.pop("reviewReason", None)
    manifest["videos"][video_id] = entry
    write_json(MANIFEST_FILE, manifest)


def cleanup_stale_results(active_video_ids: set[str]) -> None:
    manifest = load_json(MANIFEST_FILE, {"videos": {}})
    videos = manifest.get("videos", {})
    stale_video_ids = set(videos) - active_video_ids

    for video_id in sorted(stale_video_ids):
        (RAW_DIR / f"{video_id}.json").unlink(missing_ok=True)
        (REVIEW_DIR / f"{video_id}.json").unlink(missing_ok=True)
        videos.pop(video_id, None)
        print(f"[cleanup] removed stale recipe result {video_id}")

    manifest["videos"] = videos
    write_json(MANIFEST_FILE, manifest)


def load_approved_stage_one_result(video_id: str) -> dict | None:
    result = load_json(APPROVED_DIR / f"{video_id}.json", None)
    if result is None or not isinstance(result.get("ingredients"), list):
        return None
    return result


def persist_stage_two_result(
    video_id: str,
    source_url: str,
    model: str,
    master_hash: str,
    result: dict,
) -> dict:
    recipe = result.get("recipe")
    if not isinstance(recipe, dict):
        raise RuntimeError("Stage 2 response must contain a recipe object")

    recipe["key"] = dataset_key_for(video_id)
    recipe["shortsReference"] = source_url

    raw_result = {
        "videoId": video_id,
        "sourceUrl": source_url,
        "pipeline": metadata(
            model,
            pipeline_type=RECIPE_STAGE_TWO_PIPELINE_TYPE,
            pipeline_version=RECIPE_STAGE_TWO_PIPELINE_VERSION,
            ingredientMasterHash=master_hash,
        ),
        "result": result,
    }
    write_json(
        RAW_DIR / f"{video_id}.json",
        raw_result,
    )
    return raw_result


def validate_stage_two_result(
    video_id: str,
    source_url: str,
    approved_stage_one: dict,
    ingredient_master: dict,
    raw_result: dict,
) -> str:
    recipe = raw_result["result"].get("recipe")
    if isinstance(recipe, dict):
        recipe["key"] = dataset_key_for(video_id)
        write_json(RAW_DIR / f"{video_id}.json", raw_result)

    errors = validate_and_publish(
        approved_stage_one=approved_stage_one,
        ingredient_master=ingredient_master,
        stage_two_result=raw_result["result"],
        recipes_directory=DATA_DIR / "recipes",
    )
    if errors:
        write_json(
            REVIEW_DIR / f"{video_id}.json",
            {
                **raw_result,
                "validationErrors": errors,
            },
        )
        update_manifest(video_id, "REVIEW_REQUIRED", sourceUrl=source_url)
        return "REVIEW_REQUIRED"

    (REVIEW_DIR / f"{video_id}.json").unlink(missing_ok=True)
    update_manifest(video_id, "COMPLETED", sourceUrl=source_url)
    return "COMPLETED"


def run_recipe_structuring(model: str, force: bool) -> None:
    ingredient_master = load_ingredient_master(INGREDIENTS_FILE)
    master_hash = ingredient_master_hash(ingredient_master)
    client = GeminiClient(model=model)
    urls = read_urls(INPUT_FILE)
    total = len(urls)
    active_video_ids = {extract_video_id(source_url) for source_url in urls}

    cleanup_stale_results(active_video_ids)

    for index, source_url in enumerate(urls, start=1):
        video_id = extract_video_id(source_url)
        raw_path = RAW_DIR / f"{video_id}.json"
        progress = f"[{index}/{total}] {video_id}"
        approved = load_approved_stage_one_result(video_id)
        if approved is None:
            update_manifest(
                video_id,
                "REVIEW_REQUIRED",
                sourceUrl=source_url,
                reviewReason="approved Stage 1 result is required",
            )
            print(f"{progress} REVIEW_REQUIRED approved Stage 1 result is required")
            continue

        existing = load_json(raw_path, None)
        if (
            not force
            and existing
            and is_current_result(
                existing,
                model,
                pipeline_type=RECIPE_STAGE_TWO_PIPELINE_TYPE,
                pipeline_version=RECIPE_STAGE_TWO_PIPELINE_VERSION,
                ingredient_master_hash=master_hash,
            )
        ):
            print(f"{progress} SKIP cached Stage 2 result")
            status = validate_stage_two_result(
                video_id=video_id,
                source_url=source_url,
                approved_stage_one=approved,
                ingredient_master=ingredient_master,
                raw_result=existing,
            )
            print(f"{progress} {status}")
            continue

        print(f"{progress} PROCESS Stage 2 {source_url}")
        update_manifest(video_id, "PROCESSING", sourceUrl=source_url)

        try:
            result = client.structure_recipe(
                source_url=source_url,
                video_id=video_id,
                approved_ingredients=approved["ingredients"],
                ingredient_master=ingredient_master,
            )
            raw_result = persist_stage_two_result(
                video_id=video_id,
                source_url=source_url,
                model=model,
                master_hash=master_hash,
                result=result,
            )
            status = validate_stage_two_result(
                video_id=video_id,
                source_url=source_url,
                approved_stage_one=approved,
                ingredient_master=ingredient_master,
                raw_result=raw_result,
            )
            print(f"{progress} {status}")
        except Exception as exc:
            update_manifest(video_id, "FAILED", sourceUrl=source_url, error=str(exc))
            print(f"{progress} FAILED {exc}")


def main() -> None:
    load_dotenv()

    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true")
    parser.add_argument(
        "--model",
        default=os.environ.get("GEMINI_MODEL", "models/gemini-2.5-flash"),
    )
    args = parser.parse_args()

    run_recipe_structuring(model=args.model, force=args.force)


if __name__ == "__main__":
    main()
