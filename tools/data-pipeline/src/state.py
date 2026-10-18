import json
import os
import tempfile
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
STATE_DIR = ROOT / "state"


def load_video(video_id: str) -> dict[str, Any]:
    path = STATE_DIR / f"{video_id}.json"
    if not path.exists():
        return {"videoId": video_id, "status": "PENDING", "stages": {}}
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"Invalid checkpoint: {path}")
    return value


def save_video(state: dict[str, Any]) -> None:
    path = STATE_DIR / f"{state['videoId']}.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            json.dump(state, stream, ensure_ascii=False, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
