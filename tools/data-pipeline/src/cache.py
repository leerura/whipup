import json
from pathlib import Path
from typing import Any


def load_json(path: Path, default: Any) -> Any:
    if not path.exists():
        return default
    return json.loads(path.read_text(encoding="utf-8"))


def metadata(model: str, pipeline_type: str, pipeline_version: int, **extra: object) -> dict:
    return {"type": pipeline_type, "version": pipeline_version, "model": model, **extra}
