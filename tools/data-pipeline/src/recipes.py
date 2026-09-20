import argparse
import csv
import hashlib
import os
from pathlib import Path

from dotenv import load_dotenv

from cache import RECIPE_PIPELINE_TYPE, is_current_result, load_json, metadata, write_json
from gemini_client import GeminiClient
from youtube import extract_video_id

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT.parents[1] / "data"
INPUT_FILE = ROOT / "input" / "shorts-urls.txt"
RAW_DIR = ROOT / "recipe" / "raw"
REVIEW_DIR = ROOT / "recipe" / "review"
MANIFEST_FILE = ROOT / "recipe" / "manifest.json"
INGREDIENTS_FILE = DATA_DIR / "ingredients.csv"
RECIPES_DIR = DATA_DIR / "recipes"


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


def read_csv_rows(path: Path) -> list[dict]:
    if not path.exists() or path.stat().st_size == 0:
        return []

    with path.open(encoding="utf-8", newline="") as file:
        return list(csv.DictReader(file))


def load_ingredient_master() -> list[str]:
    rows = read_csv_rows(INGREDIENTS_FILE)
    return sorted(
        {
            row["canonical_name"].strip()
            for row in rows
            if row.get("canonical_name") and row["canonical_name"].strip()
        }
    )


def ingredient_master_hash(ingredient_master: list[str]) -> str:
    payload = "\n".join(ingredient_master).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


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
        (REVIEW_DIR / f"{video_id}.json").unlink(missing_ok=True)
        videos.pop(video_id, None)
        print(f"[cleanup] removed stale recipe result {video_id}")

    manifest["videos"] = videos
    write_json(MANIFEST_FILE, manifest)


def has_unmapped_ingredients(recipe: dict) -> bool:
    for ingredient in recipe.get("ingredients", []):
        if ingredient.get("mappingStatus") == "UNMAPPED":
            return True
        if not ingredient.get("canonicalIngredient"):
            return True
    return False


def validation_errors(recipe: dict, ingredient_master: set[str]) -> list[str]:
    errors = []

    if not recipe.get("key"):
        errors.append("key is required")
    if not recipe.get("name"):
        errors.append("name is required")
    if not recipe.get("shortsReference"):
        errors.append("shortsReference is required")

    ingredients = recipe.get("ingredients", [])
    if not ingredients:
        errors.append("at least one ingredient is required")

    for index, ingredient in enumerate(ingredients, start=1):
        canonical = ingredient.get("canonicalIngredient")
        if not ingredient.get("displayName"):
            errors.append(f"ingredients[{index}].displayName is required")
        if not ingredient.get("rawText"):
            errors.append(f"ingredients[{index}].rawText is required")
        if canonical and canonical not in ingredient_master:
            errors.append(
                f"ingredients[{index}].canonicalIngredient is not in Ingredient Master: {canonical}"
            )

    if not recipe.get("steps"):
        errors.append("at least one step is required")

    return errors


def persist_recipe_result(
    video_id: str,
    source_url: str,
    model: str,
    master_hash: str,
    recipe: dict,
    ingredient_master: set[str],
) -> str:
    recipe["shortsReference"] = source_url

    raw_result = {
        "videoId": video_id,
        "sourceUrl": source_url,
        "pipeline": metadata(
            model,
            pipeline_type=RECIPE_PIPELINE_TYPE,
            ingredientMasterHash=master_hash,
        ),
        "recipe": recipe,
    }
    write_json(RAW_DIR / f"{video_id}.json", raw_result)

    errors = validation_errors(recipe, ingredient_master)
    if has_unmapped_ingredients(recipe):
        errors.append("recipe contains unmapped ingredients")

    if errors:
        review_result = {
            **raw_result,
            "validationErrors": errors,
        }
        write_json(REVIEW_DIR / f"{video_id}.json", review_result)
        return "REVIEW_REQUIRED"

    write_json(RECIPES_DIR / f"{recipe['key']}.json", recipe)
    return "COMPLETED"


def run_recipe_extraction(model: str, force: bool) -> None:
    ingredient_master = load_ingredient_master()
    if not ingredient_master:
        raise RuntimeError("data/ingredients.csv must contain at least one canonical_name")

    master_hash = ingredient_master_hash(ingredient_master)
    master_set = set(ingredient_master)
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
        if (
            not force
            and existing
            and is_current_result(
                existing,
                model,
                pipeline_type=RECIPE_PIPELINE_TYPE,
                ingredient_master_hash=master_hash,
            )
        ):
            print(f"{progress} SKIP cached recipe result")
            update_manifest(video_id, "COMPLETED", sourceUrl=source_url, skipped=True)
            continue

        print(f"{progress} PROCESS recipe {source_url}")
        update_manifest(video_id, "PROCESSING", sourceUrl=source_url)

        try:
            recipe = client.extract_recipe(
                source_url=source_url,
                video_id=video_id,
                ingredient_master=ingredient_master,
            )
            status = persist_recipe_result(
                video_id=video_id,
                source_url=source_url,
                model=model,
                master_hash=master_hash,
                recipe=recipe,
                ingredient_master=master_set,
            )
            update_manifest(video_id, status, sourceUrl=source_url)
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

    run_recipe_extraction(model=args.model, force=args.force)


if __name__ == "__main__":
    main()
