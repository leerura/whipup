import html
import json
import threading
from datetime import datetime, timedelta, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from state import STATE_DIR, load_runtime_status, load_workers

KST = timezone(timedelta(hours=9))

# 워커 한 줄이 보여 줄 상태. 색은 CSS 클래스 이름과 같다.
WORKING, QUOTA, IDLE, RETRY, DONE, FAILED = "working", "quota", "idle", "retry", "done", "failed"


def queue_snapshot(input_file: Path) -> dict:
    """URL 목록과 checkpoint 파일에서 읽기 전용 현황을 만든다."""
    from pipeline import read_urls

    counts: dict[str, int] = {}
    total = 0
    for video_id, _url in read_urls(input_file):
        total += 1
        state_file = STATE_DIR / f"{video_id}.json"
        try:
            state = json.loads(state_file.read_text(encoding="utf-8")) if state_file.exists() else {"status": "PENDING"}
        except json.JSONDecodeError:
            state = {"status": "PENDING"}
        status = state.get("status", "PENDING")
        counts[status] = counts.get(status, 0) + 1
    return {"total": total, "counts": counts, "workers": load_workers(), "runtime": load_runtime_status()}


def _parse_time(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        parsed = datetime.fromisoformat(value)
    except ValueError:
        return None
    return parsed if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)


def _duration(seconds: float) -> str:
    seconds = max(0, int(seconds))
    hours, rest = divmod(seconds, 3600)
    minutes = rest // 60
    if hours:
        return f"{hours}시간 {minutes}분"
    if minutes:
        return f"{minutes}분"
    return f"{seconds}초"


def short_error(text: str | None) -> str:
    """긴 API 오류 원문을 한 줄 요약으로 줄인다."""
    if not text:
        return ""
    lowered = text.lower()
    if "per day" in lowered or "perday" in lowered.replace(" ", "") or "resource_exhausted" in lowered:
        return "일일 한도 초과"
    if "503" in text or "unavailable" in lowered or "high demand" in lowered:
        return "Gemini 일시 과부하"
    if "disconnected" in lowered or "timeout" in lowered or "timed out" in lowered:
        return "연결 끊김"
    return text.strip().splitlines()[0][:60]


def current_workers(workers: dict) -> list[dict]:
    """가장 최근 실행(run)의 워커만, 계정 이름 순으로 돌려준다. 지난 실행의 흔적은 숨긴다."""
    entries = [value for value in workers.values() if isinstance(value, dict) and value.get("accountId")]
    if not entries:
        return []
    newest = max(entries, key=lambda value: value.get("updatedAt") or "")
    run_id = newest.get("runId")
    if run_id:
        entries = [value for value in entries if value.get("runId") == run_id]
    return sorted(entries, key=lambda value: value["accountId"])


def describe_worker(entry: dict, now: datetime) -> dict:
    """워커 한 개를 화면에 보일 상태·설명으로 바꾼다."""
    status = entry.get("status") or "IDLE"
    video_id = entry.get("currentVideoId")
    updated = _parse_time(entry.get("updatedAt"))
    retry_at = _parse_time(entry.get("nextRetryAt"))
    error = short_error(entry.get("lastError"))

    if status == "EXTRACTING":
        since = f"{_duration((now - updated).total_seconds())} 전부터" if updated else ""
        return {"kind": WORKING, "label": "처리 중", "detail": since, "videoId": video_id}
    if status == "WAITING_QUOTA":
        if retry_at and retry_at > now:
            when = retry_at.astimezone(KST).strftime("%H:%M")
            detail = f"{when}(한국 시간)에 재개 · {_duration((retry_at - now).total_seconds())} 후"
        else:
            detail = "재개 확인 중"
        return {"kind": QUOTA, "label": "한도 소진", "detail": detail, "videoId": None}
    if status == "IDLE":
        return {"kind": IDLE, "label": "대기", "detail": "처리할 영상이 없어요", "videoId": None}
    if status == "EXTRACTION_READY":
        return {"kind": DONE, "label": "방금 완료", "detail": "다음 영상을 찾는 중", "videoId": None}
    if status == "WAITING_RETRY":
        wait = f" · {_duration((retry_at - now).total_seconds())} 후 재시도" if retry_at and retry_at > now else ""
        return {"kind": RETRY, "label": "재시도 대기", "detail": (error or "일시 오류") + wait, "videoId": None}
    return {"kind": FAILED, "label": "실패", "detail": error or status, "videoId": None}


STYLE = """
body{font-family:system-ui,-apple-system,sans-serif;background:#f7f7f5;color:#1f1f1d;margin:28px;max-width:860px}
h1{font-size:20px;margin:0 0 4px}.sub{color:#77746d;font-size:13px;margin:0 0 20px}
.notice{background:#fff4d8;border:1px solid #edcc7b;border-radius:10px;padding:12px;font-size:13px}
.worker{display:flex;align-items:center;gap:14px;background:#fff;border:1px solid #e6e4df;border-radius:12px;padding:14px 16px;margin-bottom:8px}
.name{width:84px;font-weight:600;font-size:14px}
.badge{min-width:84px;text-align:center;border-radius:999px;padding:4px 10px;font-size:12px;font-weight:600}
.working{background:#e1f3e6;color:#1c6b36}.quota{background:#ffe4dc;color:#a8401f}.idle{background:#ececea;color:#66645e}
.retry{background:#fff1cc;color:#8a6410}.done{background:#e1ecf8;color:#1f5a94}.failed{background:#f9d9d9;color:#9a2121}
.info{flex:1;font-size:13px;color:#4b4a46}.info a{color:#8b4b22;font-weight:600;text-decoration:none}
.queue{display:flex;gap:18px;flex-wrap:wrap;margin-top:18px;font-size:13px;color:#4b4a46}.queue b{font-size:16px;color:#1f1f1d;margin-left:4px}
"""


def _page(snapshot: dict, now: datetime | None = None) -> str:
    now = now or datetime.now(timezone.utc)
    runtime = snapshot["runtime"]
    notice = ""
    if runtime.get("status") == "NO_CONFIGURED_ACCOUNTS":
        notice = "<p class='notice'>유효한 계정 설정이 없습니다. tools/data-pipeline/accounts/account-a.env에 GEMINI_API_KEY를 입력하면 자동으로 worker가 시작됩니다.</p>"

    rows = []
    for entry in current_workers(snapshot["workers"]):
        info = describe_worker(entry, now)
        if info["videoId"]:
            video_id = html.escape(info["videoId"])
            target = f"<a href='https://www.youtube.com/shorts/{video_id}' target='_blank'>{video_id}</a> · {html.escape(info['detail'])}"
        else:
            target = html.escape(info["detail"])
        rows.append(
            f"<div class='worker'><span class='name'>{html.escape(entry['accountId'])}</span>"
            f"<span class='badge {info['kind']}'>{info['label']}</span><span class='info'>{target}</span></div>"
        )
    workers_html = "".join(rows) or "<p class='sub'>워커가 시작되길 기다리는 중이에요.</p>"

    counts = snapshot["counts"]
    waiting = counts.get("PENDING", 0)
    running = counts.get("EXTRACTION_RUNNING", 0) + counts.get("CLAIMED", 0)
    retrying = counts.get("WAITING_RETRY", 0)
    done = counts.get("EXTRACTION_READY", 0)
    failed = sum(count for status, count in counts.items() if status.startswith("FAILED"))
    queue = (
        f"<span>대기<b>{waiting}</b></span><span>처리 중<b>{running}</b></span>"
        f"<span>재시도 대기<b>{retrying}</b></span><span>추출 완료<b>{done}</b></span><span>실패<b>{failed}</b></span>"
    )
    return (
        "<!doctype html><html lang='ko'><head><meta charset='utf-8'><meta http-equiv='refresh' content='5'>"
        f"<title>Recipe pipeline</title><style>{STYLE}</style></head><body>"
        f"<h1>Recipe pipeline</h1><p class='sub'>URL {snapshot['total']}개 · 5초마다 갱신</p>{notice}"
        f"{workers_html}<div class='queue'>{queue}</div></body></html>"
    )


def start_dashboard(host: str, port: int, input_file: Path | None = None) -> ThreadingHTTPServer:
    source = input_file or Path(__file__).resolve().parents[1] / "input" / "shorts-urls.txt"

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path not in {"/", "/index.html"}:
                self.send_error(404)
                return
            body = _page(queue_snapshot(source)).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def log_message(self, _format, *_args):
            return

    server = ThreadingHTTPServer((host, port), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server
