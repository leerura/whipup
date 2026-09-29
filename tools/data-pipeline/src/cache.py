import json
from pathlib import Path
from typing import Any

PIPELINE_TYPE = "INGREDIENT_RAW_EXTRACTION"
PIPELINE_VERSION = 1
RECIPE_PIPELINE_TYPE = "RECIPE_EXTRACTION"
RECIPE_STAGE_TWO_PIPELINE_TYPE = "RECIPE_STAGE_2_STRUCTURING"
RECIPE_STAGE_TWO_PIPELINE_VERSION = 3
INGREDIENT_STAGE_ONE_PIPELINE_TYPE = "INGREDIENT_STAGE_1_EXTRACTION"
INGREDIENT_STAGE_ONE_PIPELINE_VERSION = 2


def load_json(path: Path, default: Any) -> Any:
    if not path.exists():
        return default

    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def is_current_result(
    data: dict,
    model: str,
    pipeline_type: str = PIPELINE_TYPE,
    pipeline_version: int = PIPELINE_VERSION,
    ingredient_master_hash: str | None = None,
) -> bool:
    pipeline = data.get("pipeline", {})
    is_current = (
        pipeline.get("type") == pipeline_type
        and pipeline.get("version") == pipeline_version
        and pipeline.get("model") == model
    )

    if ingredient_master_hash is not None:
        is_current = (
            is_current
            and pipeline.get("ingredientMasterHash") == ingredient_master_hash
        )

    return is_current


def metadata(
    model: str,
    pipeline_type: str = PIPELINE_TYPE,
    pipeline_version: int = PIPELINE_VERSION,
    **extra: object,
) -> dict:
    return {
        "type": pipeline_type,
        "version": pipeline_version,
        "model": model,
        **extra,
    }
