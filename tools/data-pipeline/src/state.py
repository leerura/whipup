import json
import os
import tempfile
from contextlib import contextmanager
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

import fcntl


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


@contextmanager
def locked_video(video_id: str):
    """Lock one checkpoint while reading and replacing it.

    ``os.replace`` prevents partial JSON files, but it cannot prevent two
    workers from both reading PENDING before either writes.  The lock is kept
    next to the checkpoint so independent Docker worker processes can share it.
    """
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    lock_path = STATE_DIR / f".{video_id}.lock"
    with lock_path.open("a+", encoding="utf-8") as lock_file:
        fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX)
        try:
            yield load_video(video_id)
        finally:
            fcntl.flock(lock_file.fileno(), fcntl.LOCK_UN)


def _parse_time(value: object) -> datetime | None:
    if not isinstance(value, str):
        return None
    try:
        return datetime.fromisoformat(value).astimezone(timezone.utc)
    except ValueError:
        return None


def claim_video(
    video_id: str,
    source_url: str,
    worker_id: str,
    *,
    now: datetime | None = None,
    lease_seconds: int = 15 * 60,
) -> dict[str, Any] | None:
    """Atomically claim a PENDING checkpoint; return it only to the winner."""
    current = now or datetime.now(timezone.utc)
    with locked_video(video_id) as state:
        state.update({"videoId": video_id, "sourceUrl": source_url, "pipelineVersion": 3})
        status = state.get("status", "PENDING")
        extraction = state.setdefault("extraction", {"status": "PENDING", "retryCount": 0})
        if status in {"CLAIMED", "EXTRACTION_RUNNING"}:
            heartbeat = _parse_time(state.get("lease", {}).get("heartbeatAt"))
            if heartbeat and heartbeat + timedelta(seconds=lease_seconds) > current:
                return None
            state["status"] = "PENDING"
            extraction["status"] = "PENDING"
            state.pop("lease", None)
        if state.get("status") != "PENDING":
            return None
        stamp = current.isoformat()
        state["status"] = "CLAIMED"
        extraction["status"] = "CLAIMED"
        state["lease"] = {"workerId": worker_id, "claimedAt": stamp, "heartbeatAt": stamp}
        save_video(state)
        return state


def heartbeat(video_id: str, worker_id: str, *, now: datetime | None = None) -> bool:
    with locked_video(video_id) as state:
        lease = state.get("lease")
        if not isinstance(lease, dict) or lease.get("workerId") != worker_id:
            return False
        lease["heartbeatAt"] = (now or datetime.now(timezone.utc)).isoformat()
        save_video(state)
        return True


def release_claim(state: dict[str, Any], worker_id: str) -> bool:
    video_id = state["videoId"]
    with locked_video(video_id) as current:
        lease = current.get("lease")
        if isinstance(lease, dict) and lease.get("workerId") not in {None, worker_id}:
            return False
        current.update(state)
        current.pop("lease", None)
        save_video(current)
        return True


def recover_stale_claims(video_ids: list[str], *, now: datetime | None = None, lease_seconds: int = 15 * 60) -> int:
    current = now or datetime.now(timezone.utc)
    recovered = 0
    for video_id in video_ids:
        with locked_video(video_id) as state:
            if state.get("status") not in {"CLAIMED", "EXTRACTION_RUNNING"}:
                continue
            heartbeat_at = _parse_time(state.get("lease", {}).get("heartbeatAt"))
            if heartbeat_at and heartbeat_at + timedelta(seconds=lease_seconds) > current:
                continue
            state["status"] = "PENDING"
            state.setdefault("extraction", {})["status"] = "PENDING"
            state.pop("lease", None)
            save_video(state)
            recovered += 1
    return recovered


WORKERS_FILE = "workers.json"
RUNTIME_FILE = "runtime.json"


@contextmanager
def _workers_lock():
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    with (STATE_DIR / ".workers.lock").open("a+", encoding="utf-8") as lock_file:
        fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX)
        try:
            yield
        finally:
            fcntl.flock(lock_file.fileno(), fcntl.LOCK_UN)


def load_workers() -> dict[str, Any]:
    path = STATE_DIR / WORKERS_FILE
    if not path.exists():
        return {}
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
        return value if isinstance(value, dict) else {}
    except json.JSONDecodeError:
        return {}


def save_workers(workers: dict[str, Any]) -> None:
    path = STATE_DIR / WORKERS_FILE
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=".workers.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            json.dump(workers, stream, ensure_ascii=False, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def update_worker(worker_id: str, values: dict[str, Any]) -> None:
    with _workers_lock():
        workers = load_workers()
        workers[worker_id] = {**workers.get(worker_id, {}), **values}
        save_workers(workers)


def load_runtime_status() -> dict[str, Any]:
    path = STATE_DIR / RUNTIME_FILE
    if not path.exists():
        return {}
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
        return value if isinstance(value, dict) else {}
    except json.JSONDecodeError:
        return {}


def save_runtime_status(values: dict[str, Any]) -> None:
    path = STATE_DIR / RUNTIME_FILE
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=".runtime.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            json.dump(values, stream, ensure_ascii=False, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
