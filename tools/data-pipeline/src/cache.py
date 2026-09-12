import json
from pathlib import Path
from typing import Any

PIPELINE_TYPE = "INGREDIENT_RAW_EXTRACTION"
PIPELINE_VERSION = 1


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


def is_current_result(data: dict, model: str) -> bool:
    pipeline = data.get("pipeline", {})
    return (
        pipeline.get("type") == PIPELINE_TYPE
        and pipeline.get("version") == PIPELINE_VERSION
        and pipeline.get("model") == model
    )


def metadata(model: str) -> dict:
    return {
        "type": PIPELINE_TYPE,
        "version": PIPELINE_VERSION,
        "model": model,
    }
