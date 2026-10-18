import argparse
import json
import os
import time
from datetime import datetime, timezone
from pathlib import Path

from dotenv import load_dotenv

from cache import metadata
from dataset import ingredient_master_hash, load_ingredient_master
from gemini_client import GeminiClient
from retry import resolve_retry_at, retry_decision
from state import STATE_DIR, load_video, save_video
from validator import validate_draft
from youtube import extract_video_id


ROOT = Path(__file__).resolve().parents[1]
INPUT_FILE = ROOT / "input" / "shorts-urls.txt"
DATA_DIR = ROOT.parents[1] / "data"
INGREDIENTS_FILE = DATA_DIR / "ingredients.json"
POLL_SECONDS = int(os.environ.get("PIPELINE_POLL_SECONDS", "20"))
STAGE_ONE_VERSION = 3
STAGE_TWO_VERSION = 4


def read_urls(path: Path = INPUT_FILE) -> list[tuple[str, str]]:
    if not path.exists():
        return []
    results: list[tuple[str, str]] = []
    seen: set[str] = set()
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        url = line.strip()
        if not url or url.startswith("#"):
            continue
        try:
            video_id = extract_video_id(url)
        except ValueError as exc:
            print(f"[input:{line_number}] ignored invalid URL: {exc}", flush=True)
            continue
        if video_id in seen:
            continue
        seen.add(video_id)
        results.append((video_id, url))
    return results


def _assign_source_ids(ingredients: list[dict]) -> list[dict]:
    result = []
    for index, ingredient in enumerate(ingredients, start=1):
        if not isinstance(ingredient, dict):
            raise ValueError(f"Stage 1 ingredients[{index - 1}] must be an object")
        result.append({"sourceId": f"ingredient-{index}", **ingredient})
    return result


def _stage(state: dict, name: str) -> dict:
    return state.setdefault("stages", {}).setdefault(name, {"status": "PENDING", "retryCount": 0})


def _set_pending_retry(state: dict, stage_name: str, error: Exception) -> None:
    stage = _stage(state, stage_name)
    decision = retry_decision(error, int(stage.get("retryCount", 0)))
    stage["error"] = str(error)
    stage["retryCount"] = decision.get("retryCount", stage.get("retryCount", 0))
    stage["retryReason"] = decision["reason"]
    if decision["reason"] == "failed":
        stage["status"] = "FAILED"
        stage.pop("retryAt", None)
        state["status"] = "FAILED"
        print(f"[{state['videoId']}] {stage_name} failed; restart the service to retry: {error}", flush=True)
        return
    stage["status"] = "WAITING_RETRY"
    stage["retryAt"] = resolve_retry_at(decision)
    state["status"] = "WAITING_RETRY"
    print(
        f"[{state['videoId']}] {stage_name} retry scheduled at {stage['retryAt']} ({decision['reason']})",
        flush=True,
    )


def _is_due(stage: dict) -> bool:
    retry_at = stage.get("retryAt")
    if not retry_at:
        return True
    try:
        return datetime.fromisoformat(retry_at).astimezone(timezone.utc) <= datetime.now(timezone.utc)
    except (TypeError, ValueError):
        return True


def _recover_failed_on_startup(state: dict) -> None:
    if state.get("status") != "FAILED":
        return
    for stage in state.get("stages", {}).values():
        if stage.get("status") == "FAILED":
            stage["status"] = "PENDING"
            stage["retryCount"] = 0
            stage.pop("retryAt", None)
            stage.pop("error", None)
    state["status"] = "PENDING"
    save_video(state)


def _current_catalog() -> tuple[dict, str, list[str]]:
    errors: list[str] = []
    if not INGREDIENTS_FILE.exists():
        catalog = {"ingredients": []}
        errors.append("data/ingredients.json is missing; Stage 2 waits for a V3 catalog")
        return catalog, ingredient_master_hash(catalog), errors
    try:
        catalog = load_ingredient_master(INGREDIENTS_FILE)
    except (json.JSONDecodeError, RuntimeError) as exc:
        catalog = {"ingredients": []}
        errors.append(f"data/ingredients.json is not a valid catalog: {exc}")
        return catalog, ingredient_master_hash(catalog), errors

    ingredients = catalog["ingredients"]
    if not ingredients:
        errors.append("data/ingredients.json has no Ingredients; Stage 2 waits for a V3 catalog")
    ingredient_keys: set[str] = set()
    all_variant_keys: set[str] = set()
    for index, ingredient in enumerate(ingredients):
        if not isinstance(ingredient, dict):
            errors.append(f"ingredients[{index}] must be an object")
            continue
        group_key = ingredient.get("key")
        if not isinstance(group_key, str) or not group_key.strip():
            errors.append(f"ingredients[{index}].key is required")
        elif group_key in ingredient_keys:
            errors.append(f"duplicate Ingredient key: {group_key}")
        else:
            ingredient_keys.add(group_key)
        if not isinstance(ingredient.get("name"), str) or not ingredient["name"].strip():
            errors.append(f"ingredients[{index}].name is required")
        variants = ingredient.get("variants")
        if not isinstance(variants, list) or not variants:
            errors.append(f"ingredients[{index}].variants must contain selectable items")
            variants = []
        local_variant_keys: set[str] = set()
        for variant_index, variant in enumerate(variants):
            if not isinstance(variant, dict):
                errors.append(f"ingredients[{index}].variants[{variant_index}] must be an object")
                continue
            variant_key = variant.get("key")
            variant_name = variant.get("name")
            if not isinstance(variant_key, str) or not variant_key.strip():
                errors.append(f"ingredients[{index}].variants[{variant_index}].key is required")
                continue
            if variant_key in all_variant_keys:
                errors.append(f"duplicate Variant key: {variant_key}")
            all_variant_keys.add(variant_key)
            local_variant_keys.add(variant_key)
            if not isinstance(variant_name, str) or not variant_name.strip():
                errors.append(f"ingredients[{index}].variants[{variant_index}].name is required")
            aliases = variant.get("aliases")
            if not isinstance(aliases, list) or any(not isinstance(alias, str) for alias in aliases):
                errors.append(f"ingredients[{index}].variants[{variant_index}].aliases must be a string array")
            if "base" in variant:
                errors.append(
                    f"ingredients[{index}].variants[{variant_index}] uses legacy V2 base; rebuild the V3 catalog"
                )
        relations = ingredient.get("relations")
        if not isinstance(relations, list):
            errors.append(f"ingredients[{index}].relations must be an array")
            continue
        for relation_index, relation in enumerate(relations):
            if not isinstance(relation, dict):
                errors.append(f"ingredients[{index}].relations[{relation_index}] must be an object")
                continue
            source, target = relation.get("source"), relation.get("target")
            if (
                not isinstance(source, str)
                or not isinstance(target, str)
                or source not in local_variant_keys
                or target not in local_variant_keys
                or source == target
            ):
                errors.append(f"ingredients[{index}].relations[{relation_index}] has invalid Variant references")
    return catalog, ingredient_master_hash(catalog), errors


def process_video(video_id: str, source_url: str, client: GeminiClient, model: str) -> str:
    state = load_video(video_id)
    state.update({"sourceUrl": source_url, "pipelineVersion": 1})
    if state.get("status") in {"REVIEW_PENDING", "COMPLETED", "DRAFT"}:
        return state["status"]

    stage_one = _stage(state, "stage1")
    stage_two = _stage(state, "stage2")
    if not _is_due(stage_one):
        return "WAITING_RETRY"
    if stage_one.get("status") != "COMPLETED":
        stage_one.update({"status": "RUNNING", "startedAt": datetime.now(timezone.utc).isoformat()})
        state["status"] = "STAGE_1_RUNNING"
        save_video(state)
        try:
            ingredients = _assign_source_ids(client.extract_stage_one_ingredients(source_url))
            state["stages"]["stage1"] = {
                "status": "COMPLETED",
                "pipeline": metadata(model, "V3_INGREDIENT_EXTRACTION", STAGE_ONE_VERSION),
                "completedAt": datetime.now(timezone.utc).isoformat(),
                "ingredients": ingredients,
                "retryCount": 0,
            }
            state["status"] = "STAGE_1_COMPLETED"
            save_video(state)
            print(f"[{video_id}] Stage 1 extracted {len(ingredients)} source items", flush=True)
        except Exception as exc:
            _set_pending_retry(state, "stage1", exc)
            save_video(state)
            return state["status"]

    stage_one = _stage(state, "stage1")
    if stage_one.get("status") != "COMPLETED":
        return state.get("status", "PENDING")

    catalog, catalog_hash, catalog_errors = _current_catalog()
    if catalog_errors:
        was_waiting = state.get("status") == "WAITING_CATALOG" and state.get("catalogErrors") == catalog_errors
        state["status"] = "WAITING_CATALOG"
        state["catalogErrors"] = catalog_errors
        save_video(state)
        if not was_waiting:
            print(f"[{video_id}] Stage 2 paused: {'; '.join(catalog_errors)}", flush=True)
        return "WAITING_CATALOG"
    state.pop("catalogErrors", None)
    stage_two = _stage(state, "stage2")
    previous_pipeline = stage_two.get("pipeline", {})
    if stage_two.get("status") == "COMPLETED" and (
        previous_pipeline.get("model") != model
        or previous_pipeline.get("ingredientCatalogHash") != catalog_hash
        or previous_pipeline.get("version") != STAGE_TWO_VERSION
    ):
        stage_two = {"status": "PENDING", "retryCount": 0}
        state["stages"]["stage2"] = stage_two

    if not _is_due(stage_two):
        state["status"] = "WAITING_RETRY"
        save_video(state)
        return "WAITING_RETRY"

    if stage_two.get("status") != "COMPLETED":
        stage_two.update({"status": "RUNNING", "startedAt": datetime.now(timezone.utc).isoformat()})
        state["status"] = "STAGE_2_RUNNING"
        save_video(state)
        try:
            result = client.structure_recipe(
                source_url=source_url,
                video_id=video_id,
                stage_one_ingredients=stage_one["ingredients"],
                ingredient_catalog=catalog,
            )
            recipe = result.get("recipe")
            if isinstance(recipe, dict):
                recipe["shortsReference"] = source_url
            errors = validate_draft(stage_one, result, catalog)
            state["stages"]["stage2"] = {
                "status": "COMPLETED",
                "pipeline": metadata(
                    model,
                    "V3_RECIPE_STRUCTURING",
                    STAGE_TWO_VERSION,
                    ingredientCatalogHash=catalog_hash,
                ),
                "completedAt": datetime.now(timezone.utc).isoformat(),
                "result": result,
                "structuralErrors": errors,
                "retryCount": 0,
            }
            # Agent source/video verification is a hard publish gate. This
            # worker has no supported reviewer integration, so it never writes
            # a Gemini draft into the published dataset.
            state["status"] = "REVIEW_PENDING"
            state["review"] = {
                "status": "PENDING",
                "required": "source_video_and_semantic_review",
                "structuralErrors": errors,
            }
            save_video(state)
            print(f"[{video_id}] Stage 2 saved; awaiting agent verification", flush=True)
            if errors:
                print(f"[{video_id}] structural issues: {'; '.join(errors)}", flush=True)
        except Exception as exc:
            _set_pending_retry(state, "stage2", exc)
            save_video(state)
            return state["status"]

    return state.get("status", "PENDING")


def run(model: str) -> None:
    load_dotenv()
    client = GeminiClient(model=model)
    for video_id, _ in read_urls():
        _recover_failed_on_startup(load_video(video_id))
    print(f"Watching {INPUT_FILE}; checkpoints: {STATE_DIR}", flush=True)
    while True:
        pending = False
        poll_again_later = False
        for video_id, source_url in read_urls():
            state = load_video(video_id)
            if state.get("status") in {"REVIEW_PENDING", "COMPLETED", "DRAFT"}:
                continue
            if state.get("status") == "FAILED":
                # Requeue on a fresh worker process only. In this process it
                # remains failed until the operator restarts the service.
                continue
            pending = True
            result = process_video(video_id, source_url, client, model)
            if result == "WAITING_CATALOG":
                poll_again_later = True
                continue
            if result == "WAITING_RETRY":
                # Keep one serial queue. A quota wait should pause the queue,
                # not spend more calls against the same project limit.
                retry_times = [
                    stage.get("retryAt")
                    for stage in load_video(video_id).get("stages", {}).values()
                    if stage.get("retryAt")
                ]
                if retry_times:
                    next_retry = min(datetime.fromisoformat(value) for value in retry_times)
                    seconds = max(1, (next_retry - datetime.now(next_retry.tzinfo)).total_seconds())
                    print(f"[{video_id}] waiting {int(seconds)} seconds before retry", flush=True)
                    time.sleep(seconds)
                else:
                    poll_again_later = True
                break
        if poll_again_later or not pending:
            time.sleep(max(1, POLL_SECONDS))


def main() -> None:
    parser = argparse.ArgumentParser(description="Run the V3 Gemini recipe extraction queue")
    parser.add_argument("--model", default=os.environ.get("GEMINI_MODEL", "models/gemini-2.5-flash"))
    args = parser.parse_args()
    run(args.model)


if __name__ == "__main__":
    main()
