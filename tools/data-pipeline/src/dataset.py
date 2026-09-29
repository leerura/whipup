import hashlib
import json
from pathlib import Path

from cache import load_json


def load_ingredient_master(path: Path) -> dict:
    master = load_json(path, None)
    if not isinstance(master, dict) or not isinstance(master.get("ingredients"), list):
        raise RuntimeError("data/ingredients.json must contain an ingredients array")
    if not master["ingredients"]:
        raise RuntimeError(
            "data/ingredients.json must contain at least one approved Ingredient"
        )
    return master


def ingredient_master_hash(master: dict) -> str:
    payload = json.dumps(master, ensure_ascii=False, sort_keys=True)
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()
