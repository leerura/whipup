import html
import json
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from state import STATE_DIR, load_runtime_status, load_workers


def queue_snapshot(input_file: Path) -> dict:
    """Read-only dashboard data derived entirely from URL/checkpoint files."""
    from pipeline import read_urls

    items = []
    counts: dict[str, int] = {}
    for video_id, url in read_urls(input_file):
        state_file = STATE_DIR / f"{video_id}.json"
        try:
            state = json.loads(state_file.read_text(encoding="utf-8")) if state_file.exists() else {"status": "PENDING"}
        except json.JSONDecodeError:
            state = {"status": "PENDING", "error": "checkpoint parse error"}
        status = state.get("status", "PENDING")
        counts[status] = counts.get(status, 0) + 1
        extraction = state.get("extraction", {})
        items.append({"videoId": video_id, "url": url, "status": status, "worker": state.get("lease", {}).get("workerId"), "error": extraction.get("error"), "retryAt": extraction.get("retryAt"), "accountId": extraction.get("accountId")})
    return {"total": len(items), "counts": counts, "items": items, "workers": load_workers(), "runtime": load_runtime_status()}


def _page(snapshot: dict) -> str:
    cards = "".join(f"<div class='card'><b>{html.escape(status)}</b><span>{count}</span></div>" for status, count in sorted(snapshot["counts"].items())) or "<div class='card'><b>PENDING</b><span>0</span></div>"
    rows = "".join(
        "<tr><td>{}</td><td><a href='{}' target='_blank'>video</a></td><td>{}</td><td>{}</td><td>{}</td><td>{}</td></tr>".format(
            html.escape(item["videoId"]), html.escape(item["url"]), html.escape(item["status"]), html.escape(str(item.get("accountId") or item.get("worker") or "-")), html.escape(str(item.get("retryAt") or "-")), html.escape(str(item.get("error") or "-")))
        for item in snapshot["items"]
    ) or "<tr><td colspan='6'>활성 URL이 없습니다.</td></tr>"
    worker_rows = "".join("<tr><td>{}</td><td>{}</td><td>{}</td><td>{}</td><td>{}</td><td>{}</td></tr>".format(html.escape(data.get("accountId", worker)), html.escape(data.get("status", "-")), html.escape(str(data.get("currentVideoId") or "-")), html.escape(str(data.get("nextRetryAt") or "-")), html.escape(str(data.get("lastError") or "-")), html.escape(str(data.get("updatedAt") or "-"))) for worker, data in snapshot["workers"].items()) or "<tr><td colspan='6'>worker 시작 대기</td></tr>"
    runtime = snapshot["runtime"]
    notice = ""
    if runtime.get("status") == "NO_CONFIGURED_ACCOUNTS":
        notice = "<p class='notice'>유효한 계정 설정이 없습니다. tools/data-pipeline/accounts/account-a.env에 GEMINI_API_KEY를 입력하면 자동으로 worker가 시작됩니다.</p>"
    return f"""<!doctype html><html lang='ko'><head><meta charset='utf-8'><meta http-equiv='refresh' content='5'><title>Whipup pipeline</title><style>body{{font-family:system-ui,sans-serif;background:#f7f7f5;color:#1f1f1d;margin:28px;max-width:1200px}}.summary{{display:flex;gap:10px;flex-wrap:wrap}}.card{{background:white;border:1px solid #e6e4df;border-radius:12px;padding:14px;min-width:105px;display:flex;justify-content:space-between}}.card span{{font-size:22px;font-weight:700}}.notice{{background:#fff4d8;border:1px solid #edcc7b;border-radius:10px;padding:12px}}table{{border-collapse:collapse;width:100%;background:white;margin:12px 0 28px}}th,td{{padding:10px;border-bottom:1px solid #eceae5;text-align:left;font-size:13px;vertical-align:top}}th{{background:#f0eee9}}a{{color:#8b4b22}}</style></head><body><h1>Recipe pipeline</h1><p>활성 URL {snapshot['total']}개 · 5초마다 갱신 · 읽기 전용</p>{notice}<div class='summary'>{cards}</div><h2>계정 worker</h2><table><thead><tr><th>계정</th><th>상태</th><th>현재 URL</th><th>다음 시도</th><th>마지막 오류</th><th>갱신</th></tr></thead><tbody>{worker_rows}</tbody></table><h2>URL 진행</h2><table><thead><tr><th>Video ID</th><th>원본</th><th>단계</th><th>계정/worker</th><th>다음 시도</th><th>마지막 오류</th></tr></thead><tbody>{rows}</tbody></table></body></html>"""


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
