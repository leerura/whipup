import re
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo


RETRY_DELAYS = (60, 300, 900)
PACIFIC = ZoneInfo("America/Los_Angeles")


def _error_text(error: Exception) -> str:
    pieces = [str(error)]
    for name in ("message", "details", "status", "code"):
        value = getattr(error, name, None)
        if value is not None:
            pieces.append(str(value))
    return " ".join(pieces)


def _retry_info_seconds(error: Exception) -> float | None:
    # google-genai versions expose API details differently; inspect their
    # string representation as well as common structured attributes.
    values = [_error_text(error)]
    for name in ("details", "response_json", "body"):
        value = getattr(error, name, None)
        if value is not None:
            values.append(str(value))
    text = " ".join(values)
    matches = re.findall(r"retryDelay['\"]?\s*[:=]\s*['\"]?(\d+(?:\.\d+)?)s", text, re.I)
    matches.extend(re.findall(r"retry in\s+(\d+(?:\.\d+)?)s", text, re.I))
    if matches:
        return max(1.0, float(matches[-1]))

    # Common human-readable form: 1h2m3.5s, 2h30m, or 90s.
    match = re.search(r"retry in\s+((?:\d+(?:\.\d+)?\s*[hms]\s*)+)", text, re.I)
    if match:
        duration = match.group(1).lower().replace(" ", "")
        seconds = 0.0
        for amount, unit in re.findall(r"(\d+(?:\.\d+)?)([hms])", duration):
            seconds += float(amount) * {"h": 3600, "m": 60, "s": 1}[unit]
        return max(1.0, seconds)
    return None


def _is_429(error: Exception, text: str) -> bool:
    code = getattr(error, "code", None)
    return code == 429 or "429" in text or "RESOURCE_EXHAUSTED" in text.upper()


def _is_daily_quota(text: str) -> bool:
    lowered = text.lower()
    compact = re.sub(r"[\s_-]", "", lowered)
    indicators = ("per day", "per-day", "daily limit", "daily quota", "requests per day", "rpd")
    return any(indicator in lowered for indicator in indicators) or any(
        indicator in compact for indicator in ("perday", "dailyquota", "dailylimit", "requestperday")
    )


def next_pacific_midnight(now: datetime | None = None) -> datetime:
    current = now or datetime.now(timezone.utc)
    local = current.astimezone(PACIFIC)
    next_day = (local + timedelta(days=1)).date()
    return datetime.combine(next_day, datetime.min.time(), tzinfo=PACIFIC).astimezone(timezone.utc)


def retry_decision(error: Exception, retry_count: int, now: datetime | None = None) -> dict:
    """Return a persisted retry decision; retry_count counts scheduled retries."""
    text = _error_text(error)
    provided = _retry_info_seconds(error)
    if provided is not None:
        return {"waitSeconds": provided, "reason": "provider_retry_info", "retryCount": retry_count}
    if _is_429(error, text):
        if _is_daily_quota(text) or retry_count >= len(RETRY_DELAYS):
            until = next_pacific_midnight(now)
            return {
                "retryAt": until.isoformat(),
                "reason": "daily_quota_reset",
                "retryCount": 0,
            }
        return {
            "waitSeconds": RETRY_DELAYS[retry_count],
            "reason": "rate_limit_backoff",
            "retryCount": retry_count + 1,
        }

    code = getattr(error, "code", None)
    code_text = str(code).upper()
    try:
        numeric_code = int(code)
    except (TypeError, ValueError):
        numeric_code = None
    transient = (
        (numeric_code is not None and numeric_code >= 500)
        or code_text in {"INTERNAL", "UNAVAILABLE", "INTERNAL_SERVER_ERROR", "SERVICE_UNAVAILABLE"}
        or any(
            token in text.lower()
            for token in (
                "timeout", "timed out", "connection", "temporarily unavailable",
                "temporary failure in name resolution", "name or service not known",
                "could not resolve", "getaddrinfo failed", "dns resolution",
            )
        )
    )
    if transient and retry_count < len(RETRY_DELAYS):
        return {
            "waitSeconds": RETRY_DELAYS[retry_count],
            "reason": "transient_backoff",
            "retryCount": retry_count + 1,
        }
    return {"reason": "failed", "retryCount": retry_count}


def resolve_retry_at(decision: dict, now: datetime | None = None) -> str:
    if "retryAt" in decision:
        return decision["retryAt"]
    return ((now or datetime.now(timezone.utc)) + timedelta(seconds=decision["waitSeconds"])).isoformat()
