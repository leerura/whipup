import json
from pathlib import Path
from typing import Any

PIPELINE_TYPE = "INGREDIENT_RAW_EXTRACTION"
PIPELINE_VERSION = 1
RECIPE_PIPELINE_TYPE = "RECIPE_EXTRACTION"


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
    ingredient_master_hash: str | None = None,
) -> bool:
    pipeline = data.get("pipeline", {})
    is_current = (
        pipeline.get("type") == pipeline_type
        and pipeline.get("version") == PIPELINE_VERSION
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
    **extra: object,
) -> dict:
    return {
        "type": pipeline_type,
        "version": PIPELINE_VERSION,
        "model": model,
        **extra,
    }
