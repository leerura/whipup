"""채널의 Shorts 목록에서 레시피 후보 URL을 골라 shorts-urls.txt에 추가한다.

YouTube Data API 키 없이 공개 채널 페이지만 읽는다. 기본은 목록만 출력하고, --write를 주면 파일 끝에 추가한다.
"""
import argparse
import json
import re
import time
from datetime import date
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import quote

from youtube import _get_text, extract_video_id

ROOT = Path(__file__).resolve().parents[1]
URL_FILE = ROOT / "input" / "shorts-urls.txt"
CHANNEL_FILE = ROOT / "input" / "discovery-channels.txt"
DATASET_RECIPES = ROOT.parents[1] / "data" / "recipes"

# 레시피가 아닐 가능성이 큰 제목
EXCLUDED_TITLE_WORDS = ("먹방", "브이로그", "vlog", "광고", "협찬", "유료광고", "이벤트", "구독", "공동구매", "공구", "쿠폰", "할인")
_UNITS = {"": 1, "천": 1_000, "만": 10_000, "억": 100_000_000}


def parse_views(text: str | None) -> int | None:
    """'조회수 3.7만회', '조회수 1,234회' 같은 표기를 정수로 바꾼다. 알 수 없으면 None."""
    if not text:
        return None
    m = re.search(r"([0-9][0-9.,]*)\s*([천만억]?)\s*회", text)
    if not m:
        return None
    try:
        return int(float(m.group(1).replace(",", "")) * _UNITS[m.group(2)])
    except ValueError:
        return None


def parse_shorts(html: str) -> list[dict]:
    """채널 Shorts 탭 HTML에서 (id, title, views)를 읽는다."""
    m = re.search(r"var ytInitialData = (\{.*?\});</script>", html, re.S)
    if not m:
        return []
    data = json.loads(m.group(1))
    found: list[dict] = []

    def walk(node):
        if isinstance(node, dict):
            vm = node.get("shortsLockupViewModel")
            if vm:
                endpoint = ((vm.get("onTap") or {}).get("innertubeCommand") or {}).get("reelWatchEndpoint") or {}
                meta = vm.get("overlayMetadata") or {}
                video_id = endpoint.get("videoId")
                if video_id:
                    found.append({
                        "id": video_id,
                        "title": (meta.get("primaryText") or {}).get("content") or "",
                        "views": parse_views((meta.get("secondaryText") or {}).get("content")),
                    })
            reel = node.get("reelItemRenderer")
            if reel and reel.get("videoId"):
                found.append({
                    "id": reel["videoId"],
                    "title": (reel.get("headline") or {}).get("simpleText") or "",
                    "views": parse_views((reel.get("viewCountText") or {}).get("simpleText")),
                })
            for value in node.values():
                walk(value)
        elif isinstance(node, list):
            for value in node:
                walk(value)

    walk(data)
    seen, unique = set(), []
    for item in found:
        if item["id"] not in seen:
            seen.add(item["id"])
            unique.append(item)
    return unique


def known_video_ids() -> set[str]:
    """목록(주석 처리된 것 포함)과 최종 데이터에 이미 있는 영상 ID."""
    ids: set[str] = set()
    for line in URL_FILE.read_text(encoding="utf-8").splitlines():
        text = line.strip().lstrip("#").strip()
        m = re.search(r"(?:shorts/|v=|youtu\.be/)([A-Za-z0-9_-]{11})", text)
        if m:
            ids.add(m.group(1))
    for path in DATASET_RECIPES.glob("*.json"):
        reference = json.loads(path.read_text(encoding="utf-8")).get("shortsReference", "")
        m = re.search(r"(?:shorts/|v=|youtu\.be/)([A-Za-z0-9_-]{11})", reference)
        if m:
            ids.add(m.group(1))
    return ids


def read_channels() -> list[tuple[str, str]]:
    channels = []
    for line in CHANNEL_FILE.read_text(encoding="utf-8").splitlines():
        text = line.strip()
        if not text or text.startswith("#"):
            continue
        channel_id, _, note = text.partition("#")
        channels.append((channel_id.strip(), note.strip()))
    return channels


def is_embeddable(video_id: str) -> bool:
    """oEmbed가 응답하면 외부에서 재생 가능한 영상으로 본다."""
    url = f"https://www.youtube.com/oembed?url={quote('https://www.youtube.com/shorts/' + video_id, safe='')}&format=json"
    try:
        _get_text(url)
        return True
    except (HTTPError, URLError):
        return False


def select(items: list[dict], known: set[str], min_views: int) -> list[dict]:
    chosen = []
    for item in items:
        if item["id"] in known:
            continue
        if item["views"] is None or item["views"] < min_views:
            continue
        title = item["title"].lower()
        if any(word in title for word in EXCLUDED_TITLE_WORDS):
            continue
        chosen.append(item)
    return chosen


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--min-views", type=int, default=100_000)
    parser.add_argument("--per-channel", type=int, default=12, help="채널당 최대 후보 수(조회수 순)")
    parser.add_argument("--write", action="store_true", help="shorts-urls.txt 끝에 추가")
    args = parser.parse_args()

    known = known_video_ids()
    picked: list[tuple[str, dict]] = []
    for channel_id, note in read_channels():
        html = _get_text(f"https://www.youtube.com/channel/{channel_id}/shorts?hl=ko")
        items = parse_shorts(html)
        if not items:
            print(f"[오류] {note or channel_id}: Shorts 목록을 읽지 못했습니다. 페이지 구조가 바뀌었을 수 있습니다.")
            return 1
        candidates = sorted(select(items, known, args.min_views), key=lambda i: -i["views"])
        chosen = []
        for item in candidates:
            if len(chosen) >= args.per_channel:
                break
            if is_embeddable(item["id"]):
                chosen.append(item)
        print(f"{note or channel_id}: 읽음 {len(items)}, 조건 통과 {len(candidates)}, 선택 {len(chosen)}")
        for item in chosen:
            known.add(item["id"])
            picked.append((note or channel_id, item))
        time.sleep(1)

    for note, item in picked:
        print(f"  {item['views']:>9,}  {note.split('(')[0].strip()}  {item['title']}  https://www.youtube.com/shorts/{item['id']}")
    print(f"총 {len(picked)}개")
    if args.write and picked:
        lines = [f"# 자동 수집 {date.today().isoformat()} (조회수 {args.min_views:,} 이상)"]
        for note, item in picked:
            lines.append(f"# {note.split('(')[0].strip()} · {item['title']} · 조회수 {item['views']:,}")
            lines.append(f"https://www.youtube.com/shorts/{item['id']}")
        with URL_FILE.open("a", encoding="utf-8") as f:
            f.write("\n" + "\n".join(lines) + "\n")
        print(f"{URL_FILE.name}에 {len(picked)}개를 추가했습니다.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
