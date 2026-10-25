import argparse
import os
import threading
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path

try:
    from dotenv import load_dotenv
except ModuleNotFoundError:  # unit tests do not need local .env parsing
    def load_dotenv() -> bool:
        return False

from cache import metadata
from dashboard import start_dashboard
from gemini_client import GeminiClient
from retry import resolve_retry_at, retry_decision
from state import claim_video, heartbeat, load_video, recover_stale_claims, release_claim, save_runtime_status, save_video, update_worker
from validator import validate_source_extraction
from youtube import extract_video_id

ROOT = Path(__file__).resolve().parents[1]
INPUT_FILE = ROOT / "input" / "shorts-urls.txt"
ACCOUNTS_DIR = ROOT / "accounts"
POLL_SECONDS = int(os.environ.get("PIPELINE_POLL_SECONDS", "20"))
LEASE_SECONDS = 15 * 60
EXTRACTION_VERSION = 1


def read_urls(path: Path = INPUT_FILE) -> list[tuple[str, str]]:
    if not path.exists():
        return []
    results, seen = [], set()
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        url = line.strip()
        if not url or url.startswith("#"):
            continue
        try:
            video_id = extract_video_id(url)
        except ValueError as exc:
            print(f"[input:{line_number}] ignored invalid URL: {exc}", flush=True)
            continue
        if video_id not in seen:
            seen.add(video_id)
            results.append((video_id, url))
    return results


def load_accounts(directory: Path = ACCOUNTS_DIR) -> list[dict[str, str]]:
    """Load local files; filename is the safe account identifier used in state."""
    accounts = []
    if directory.exists():
        for path in sorted(directory.glob("*.env")):
            if path.name.endswith(".example.env"):
                continue
            values = {}
            for line in path.read_text(encoding="utf-8").splitlines():
                key, separator, value = line.partition("=")
                if separator and not key.strip().startswith("#"):
                    values[key.strip()] = value.strip()
            if values.get("GEMINI_API_KEY"):
                accounts.append({"id": path.stem, "apiKey": values["GEMINI_API_KEY"]})
    # Existing one-key setups keep working, but new setups use account files.
    if not accounts and os.environ.get("GEMINI_API_KEY"):
        accounts.append({"id": "default", "apiKey": os.environ["GEMINI_API_KEY"]})
    if not accounts:
        raise RuntimeError(f"No Gemini account files found in {directory}")
    return accounts


def _assign_source_ids(ingredients: list[dict]) -> list[dict]:
    result = []
    for index, ingredient in enumerate(ingredients, start=1):
        if not isinstance(ingredient, dict):
            raise ValueError(f"ingredients[{index - 1}] must be an object")
        result.append({**ingredient, "sourceId": f"ingredient-{index}"})
    return result


def _is_due(stage: dict) -> bool:
    value = stage.get("retryAt")
    if not value:
        return True
    try:
        return datetime.fromisoformat(value).astimezone(timezone.utc) <= datetime.now(timezone.utc)
    except (TypeError, ValueError):
        return True


def _account_quota_until(items: list[tuple[str, str]], account_id: str) -> datetime | None:
    deadlines = []
    for video_id, _ in items:
        value = load_video(video_id).get("extraction", {}).get("quotaAccounts", {}).get(account_id)
        if not isinstance(value, str):
            continue
        try:
            deadline = datetime.fromisoformat(value).astimezone(timezone.utc)
        except ValueError:
            continue
        if deadline > datetime.now(timezone.utc):
            deadlines.append(deadline)
    return max(deadlines) if deadlines else None


def _set_worker(worker_id: str, **values: object) -> None:
    update_worker(worker_id, {**values, "updatedAt": datetime.now(timezone.utc).isoformat()})


def _prepare_for_run(items: list[tuple[str, str]]) -> None:
    recover_stale_claims([video_id for video_id, _ in items], lease_seconds=LEASE_SECONDS)
    for video_id, _ in items:
        state = load_video(video_id)
        # Old two-stage checkpoints never get to block the one-call V3 queue.
        # Preserve their saved data but give the new extraction a normal queue
        # status; legacy retry deadlines are carried forward when present.
        if state.get("status") == "WAITING_CATALOG":
            state["status"] = "PENDING"
            state.setdefault("extraction", {}).setdefault("status", "PENDING")
            save_video(state)
            continue
        if state.get("status") == "WAITING_RETRY" and not state.get("extraction", {}).get("retryAt"):
            waits = [stage for stage in state.get("stages", {}).values() if isinstance(stage, dict) and stage.get("status") == "WAITING_RETRY"]
            if waits:
                legacy = waits[0]
                state["extraction"] = {"status": "WAITING_RETRY", "retryCount": int(legacy.get("retryCount", 0)), "retryAt": legacy.get("retryAt"), "retryKind": "quota" if legacy.get("retryAt") else "transient"}
                save_video(state)
        if state.get("status") != "FAILED_RETRYABLE":
            continue
        extraction = state.setdefault("extraction", {})
        retries = int(extraction.get("retryableRuns", 0)) + 1
        extraction["retryableRuns"] = retries
        if retries >= 3:
            state["status"] = extraction["status"] = "REVIEW_PENDING"
        else:
            extraction.update({"status": "PENDING", "retryCount": 0})
            extraction.pop("retryAt", None)
            state["status"] = "PENDING"
        save_video(state)


def _eligible(video_id: str, account_id: str, allow_held: bool) -> bool:
    state = load_video(video_id)
    if state.get("status", "PENDING") == "PENDING":
        return True
    if state.get("status") != "WAITING_RETRY" or not allow_held:
        return False
    extraction = state.get("extraction", {})
    if extraction.get("retryKind") == "quota":
        return account_id not in extraction.get("quotaAccounts", {})
    return extraction.get("retryAccountId") in {None, account_id} and _is_due(extraction)


def claim_next(items: list[tuple[str, str]], worker_id: str, account_id: str) -> tuple[str, str] | None:
    # New work comes before retry/quota-held work.
    for allow_held in (False, True):
        for video_id, source_url in items:
            if not _eligible(video_id, account_id, allow_held):
                continue
            if allow_held:
                from state import locked_video
                with locked_video(video_id) as held:
                    # Recheck while locked: another worker may have claimed it
                    # after _eligible read the checkpoint.
                    if held.get("status") == "WAITING_RETRY":
                        extraction = held.get("extraction", {})
                        permitted = (extraction.get("retryKind") == "quota" and account_id not in extraction.get("quotaAccounts", {})) or (extraction.get("retryKind") != "quota" and extraction.get("retryAccountId") in {None, account_id} and _is_due(extraction))
                        if permitted:
                            held["status"] = "PENDING"
                            extraction["status"] = "PENDING"
                            save_video(held)
            if claim_video(video_id, source_url, worker_id, lease_seconds=LEASE_SECONDS):
                return video_id, source_url
    return None


def _handle_error(state: dict, error: Exception, account_id: str) -> None:
    stage = state.setdefault("extraction", {"retryCount": 0})
    decision = retry_decision(error, int(stage.get("retryCount", 0)))
    stage.update({"error": str(error), "retryReason": decision["reason"], "retryCount": decision.get("retryCount", 0)})
    if decision["reason"] == "non_retryable_access":
        stage["status"] = state["status"] = "FAILED"
    elif decision["reason"] == "failed_retryable":
        stage["status"] = state["status"] = "FAILED_RETRYABLE"
    else:
        stage.update({"status": "WAITING_RETRY", "retryKind": decision.get("kind", "transient"), "retryAt": resolve_retry_at(decision)})
        if decision.get("kind") == "quota":
            stage.setdefault("quotaAccounts", {})[account_id] = stage["retryAt"]
        else:
            stage["retryAccountId"] = account_id
        state["status"] = "WAITING_RETRY"


def process_claimed_video(video_id: str, source_url: str, client: GeminiClient, model: str, worker_id: str, account_id: str) -> str:
    # claim_video has already set the durable lease. Keep it until result/error
    # state is saved; no other account can duplicate this Gemini request.
    from state import locked_video
    with locked_video(video_id) as persisted:
        if persisted.get("lease", {}).get("workerId") != worker_id:
            return "PENDING"
        persisted.update({"sourceUrl": source_url, "pipelineVersion": 3, "status": "EXTRACTION_RUNNING"})
        persisted.setdefault("extraction", {}).update({"status": "RUNNING", "startedAt": datetime.now(timezone.utc).isoformat(), "accountId": account_id})
        save_video(persisted)
    heartbeat_stop = threading.Event()
    def keep_lease_alive() -> None:
        while not heartbeat_stop.wait(60):
            heartbeat(video_id, worker_id)
    heartbeat(video_id, worker_id)
    heartbeat_thread = threading.Thread(target=keep_lease_alive, daemon=True)
    heartbeat_thread.start()
    try:
        result, raw_response = client.extract_recipe_source(source_url, video_id)
        if not isinstance(result, dict):
            raise ValueError("Gemini extraction must be a JSON object")
        result = dict(result)
        if isinstance(result.get("ingredients"), list):
            result["ingredients"] = _assign_source_ids(result["ingredients"])
        errors = validate_source_extraction(result)
        current = load_video(video_id)
        current["extraction"] = {"status": "COMPLETED", "pipeline": metadata(model, "V3_RECIPE_SOURCE_EXTRACTION", EXTRACTION_VERSION), "completedAt": datetime.now(timezone.utc).isoformat(), "rawResponse": raw_response, "result": result, "structuralErrors": errors, "retryCount": 0, "accountId": account_id}
        current["status"] = "EXTRACTION_READY"
        release_claim(current, worker_id)
        print(f"[{video_id}] extracted; saved for agent application", flush=True)
        return "EXTRACTION_READY"
    except Exception as exc:
        current = load_video(video_id)
        _handle_error(current, exc, account_id)
        release_claim(current, worker_id)
        print(f"[{video_id}] {current['status']}: {exc}", flush=True)
        return current["status"]
    finally:
        heartbeat_stop.set()
        heartbeat_thread.join(timeout=1)


def worker(account: dict[str, str], model: str, run_id: str, stop: threading.Event) -> None:
    account_id, worker_id = account["id"], f"{account['id']}-{run_id[:8]}"
    client = GeminiClient(model=model, api_key=account["apiKey"])
    _set_worker(worker_id, accountId=account_id, status="IDLE", runId=run_id)
    while not stop.is_set():
        items = read_urls()
        recover_stale_claims([video_id for video_id, _ in items], lease_seconds=LEASE_SECONDS)
        quota_until = _account_quota_until(items, account_id)
        if quota_until:
            _set_worker(worker_id, accountId=account_id, status="WAITING_QUOTA", currentVideoId=None, nextRetryAt=quota_until.isoformat())
            stop.wait(min(POLL_SECONDS, max(1, (quota_until - datetime.now(timezone.utc)).total_seconds())))
            continue
        claimed = claim_next(items, worker_id, account_id)
        if not claimed:
            _set_worker(worker_id, accountId=account_id, status="IDLE", currentVideoId=None)
            stop.wait(POLL_SECONDS)
            continue
        video_id, source_url = claimed
        _set_worker(worker_id, accountId=account_id, status="EXTRACTING", currentVideoId=video_id)
        status = process_claimed_video(video_id, source_url, client, model, worker_id, account_id)
        extraction = load_video(video_id).get("extraction", {})
        _set_worker(worker_id, accountId=account_id, status=status, currentVideoId=None, lastError=extraction.get("error"), nextRetryAt=extraction.get("retryAt"))


def run(model: str) -> None:
    load_dotenv()
    start_dashboard(host="0.0.0.0", port=int(os.environ.get("PIPELINE_DASHBOARD_PORT", "8081")))
    accounts = []
    while not accounts:
        try:
            accounts = load_accounts()
        except RuntimeError as exc:
            save_runtime_status({"status": "NO_CONFIGURED_ACCOUNTS", "message": str(exc), "updatedAt": datetime.now(timezone.utc).isoformat()})
            print(f"{exc}; dashboard remains available while waiting for account files", flush=True)
            time.sleep(POLL_SECONDS)
    save_runtime_status({"status": "RUNNING", "accountCount": len(accounts), "updatedAt": datetime.now(timezone.utc).isoformat()})
    run_id = str(uuid.uuid4())
    _prepare_for_run(read_urls())
    print(f"Watching {INPUT_FILE}; {len(accounts)} account worker(s); dashboard http://localhost:8081", flush=True)
    stop = threading.Event()
    threads = [threading.Thread(target=worker, args=(account, model, run_id, stop), daemon=True) for account in accounts]
    for thread in threads:
        thread.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        stop.set()
        for thread in threads:
            thread.join(timeout=5)


def main() -> None:
    parser = argparse.ArgumentParser(description="Run the V3 Gemini recipe extraction queue")
    parser.add_argument("--model", default=os.environ.get("GEMINI_MODEL", "gemini-3.8-flash"))
    args = parser.parse_args()
    run(args.model)


if __name__ == "__main__":
    main()
