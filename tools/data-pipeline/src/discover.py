"""채널의 Shorts 목록에서 레시피 후보 URL을 골라 대기열(input/queue.jsonl)에 추가한다.

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

from video_queue import QUEUE_FILE, append_entries, read_queue
from youtube import _get_text, extract_video_id, is_short

ROOT = Path(__file__).resolve().parents[1]
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


def parse_duration(text: str | None) -> int | None:
    """'1:02', '0:45', '1:02:03' 같은 길이를 초로 바꾼다. 알 수 없으면 None."""
    if not text:
        return None
    parts = text.strip().split(":")
    if not all(p.isdigit() for p in parts) or len(parts) > 3:
        return None
    seconds = 0
    for part in parts:
        seconds = seconds * 60 + int(part)
    return seconds


def parse_subscribers(text: str | None) -> int | None:
    """'구독자 149만명', '구독자 1.2만명', '구독자 3,210명' 같은 표기를 정수로 바꾼다."""
    if not text:
        return None
    m = re.search(r"구독자\s*([0-9][0-9.,]*)\s*([천만억]?)\s*명", text)
    if not m:
        return None
    try:
        return int(float(m.group(1).replace(",", "")) * _UNITS[m.group(2)])
    except ValueError:
        return None


def parse_search(html: str) -> list[dict]:
    """검색 결과 HTML에서 (id, title, views, channel, channel_id, duration)을 읽는다."""
    m = re.search(r"var ytInitialData = (\{.*?\});</script>", html, re.S)
    if not m:
        return []
    data = json.loads(m.group(1))
    found: list[dict] = []
    seen: set[str] = set()

    def walk(node):
        if isinstance(node, dict):
            shelf = node.get("shortsLockupViewModel")
            if shelf:
                endpoint = ((shelf.get("onTap") or {}).get("innertubeCommand") or {}).get("reelWatchEndpoint") or {}
                meta = shelf.get("overlayMetadata") or {}
                video_id = endpoint.get("videoId")
                if video_id and video_id not in seen:
                    seen.add(video_id)
                    found.append({
                        "id": video_id,
                        "title": (meta.get("primaryText") or {}).get("content") or "",
                        "views": parse_views((meta.get("secondaryText") or {}).get("content")),
                        "channel": "", "channel_id": None, "duration": None, "shelf": True,
                    })
            renderer = node.get("videoRenderer")
            if renderer and renderer.get("videoId") and renderer["videoId"] not in seen:
                seen.add(renderer["videoId"])
                owner = (renderer.get("ownerText") or {}).get("runs") or [{}]
                browse = (owner[0].get("navigationEndpoint") or {}).get("browseEndpoint") or {}
                found.append({
                    "id": renderer["videoId"],
                    "title": "".join(r.get("text", "") for r in (renderer.get("title") or {}).get("runs", [])),
                    "views": parse_views((renderer.get("viewCountText") or {}).get("simpleText")),
                    "channel": owner[0].get("text", ""),
                    "channel_id": browse.get("browseId"),
                    "duration": parse_duration((renderer.get("lengthText") or {}).get("simpleText")),
                })
            for value in node.values():
                walk(value)
        elif isinstance(node, list):
            for value in node:
                walk(value)

    walk(data)
    return found


def search_videos(query: str, attempts: int = 3) -> list[dict]:
    """유튜브 공개 검색 결과(쇼츠 선반 포함)에서 후보를 읽는다. 가끔 빈 페이지가 와서 몇 번 다시 시도한다."""
    url = f"https://www.youtube.com/results?search_query={quote(query)}&hl=ko"
    for attempt in range(attempts):
        items = parse_search(_get_text(url))
        if items:
            return items
        time.sleep(2 * (attempt + 1))
    return []


def subscribers_of(channel_url: str) -> int | None:
    """채널 페이지(/channel/ID 또는 /@핸들)에서 구독자 수를 읽는다. 읽지 못하면 None."""
    try:
        html = _get_text(f"{channel_url}{'&' if '?' in channel_url else '?'}hl=ko")
    except (HTTPError, URLError):
        return None
    m = re.search(r"구독자\s*[0-9][0-9.,]*\s*[천만억]?\s*명", html)
    return parse_subscribers(m.group(0)) if m else None


def oembed(video_id: str) -> dict | None:
    """oEmbed 응답(제목·채널명·채널 주소). 외부 재생이 안 되는 영상이면 None."""
    url = f"https://www.youtube.com/oembed?url={quote('https://www.youtube.com/shorts/' + video_id, safe='')}&format=json"
    try:
        return json.loads(_get_text(url))
    except (HTTPError, URLError, ValueError):
        return None


def select_search(items: list[dict], known: set[str], min_views: int, max_seconds: int = 180) -> list[dict]:
    """검색 결과 중 새 영상이고 제외 단어가 없고, 일반 영상은 길이 3분 이하인 것만 남긴다.

    쇼츠 선반에서 온 항목은 이미 쇼츠이므로 길이를 보지 않는다. 쇼츠 여부(일반 영상)·구독자·임베드는 따로 확인한다.
    """
    chosen = []
    for item in items:
        if item["id"] in known:
            continue
        if not item.get("shelf") and (item["duration"] is None or item["duration"] > max_seconds):
            continue
        if min_views and (item["views"] is None or item["views"] < min_views):
            continue
        title = item["title"].lower()
        if any(word in title for word in EXCLUDED_TITLE_WORDS):
            continue
        chosen.append(item)
    return chosen


def _entry(item: dict, source: str, batch: str, **extra) -> dict:
    return {"videoId": item["id"], "url": f"https://www.youtube.com/shorts/{item['id']}", "source": source,
            "addedAt": date.today().isoformat(), "batch": batch, "channel": item.get("channel"),
            "title": item.get("title"), "views": item.get("views"), **extra}


def known_video_ids() -> set[str]:
    """대기열(제외된 것 포함)과 최종 데이터에 이미 있는 영상 ID."""
    ids: set[str] = {entry["videoId"] for entry in read_queue()}
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


def blocked_dish_types(args) -> tuple:
    """(taxonomy, codes over target) unless --allow-over-target. Doc: 목표 비율을 넘으면 신규 수집을 멈춘다."""
    if getattr(args, "allow_over_target", False):
        return (None, set())
    try:
        from collection import Taxonomy, load_rows, over_target
        taxonomy = Taxonomy.load()
        blocked = over_target(load_rows(taxonomy), taxonomy)
    except (OSError, ValueError, KeyError) as exc:
        print(f"[경고] 요리 종류 비율을 계산하지 못해 종류로 거르지 않습니다: {exc}")
        return (None, set())
    if blocked:
        print("목표 비율을 넘어 거르는 종류: " + ", ".join(taxonomy.label(c) for c in sorted(blocked)))
    return (taxonomy, blocked)


def is_blocked(title: str, blocked: tuple) -> bool:
    """True when the title classifies into an over-target type. Printed so a person can audit what was dropped."""
    taxonomy, codes = blocked
    if not codes:
        return False
    main, others = taxonomy.other_types(title)
    if main in codes and others <= codes:  # "라면보다 쉬운 계란국" also names 국, so it is kept
        print(f"  [종류 초과로 제외: {taxonomy.label(main).split('(')[0]}] {title}")
        return True
    return False


def run_queries(args) -> int:
    known = known_video_ids()
    blocked = blocked_dish_types(args)
    subs_cache: dict[str, int | None] = {}
    picked: list[tuple[str, dict]] = []
    for query in args.query:
        items = search_videos(query)
        if not items:
            print(f"[오류] '{query}': 검색 결과를 읽지 못했습니다. 페이지 구조가 바뀌었을 수 있습니다.")
            return 1
        candidates = [i for i in select_search(items, known, args.min_views or 0) if not is_blocked(i["title"], blocked)]
        qualified = []
        for item in candidates[:30]:
            if not item.get("shelf") and is_short(item["id"]) is not True:
                continue
            info = oembed(item["id"])
            if not info or not info.get("author_url"):
                continue
            url = info["author_url"]
            if url not in subs_cache:
                subs_cache[url] = subscribers_of(url)
                time.sleep(0.5)
            subs = subs_cache[url]
            if subs is None or subs < args.min_subs:
                continue
            item.update({"subs": subs, "channel": info.get("author_name") or item["channel"]})
            qualified.append(item)
        chosen = sorted(qualified, key=lambda i: -i["subs"])[: args.per_query]
        print(f"'{query}': 읽음 {len(items)}, 길이·제외 통과 {len(candidates)}, 쇼츠·임베드·구독자 통과 {len(qualified)}, 선택 {len(chosen)}")
        for item in chosen:
            known.add(item["id"])
            picked.append((query, item))
        time.sleep(1)

    for query, item in picked:
        views = f"{item['views']:,}" if item["views"] is not None else "?"
        print(f"  구독자 {item['subs']:>9,}  조회 {views:>9}  [{query}] {item['channel']} · {item['title']}  https://www.youtube.com/shorts/{item['id']}")
    print(f"총 {len(picked)}개")
    if args.write and picked:
        batch = f"자동 수집 {date.today().isoformat()} (검색어, 구독자 {args.min_subs:,} 이상)"
        added = append_entries([_entry(item, "discover-search", batch, query=query, subscribers=item["subs"])
                                for query, item in picked])
        print(f"{QUEUE_FILE.name}에 {added}개를 추가했습니다.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--min-views", type=int, default=None, help="영상 조회수 하한(채널 방식 기본 100000, 검색 방식 기본 없음)")
    parser.add_argument("--query", action="append", default=[], help="검색어(여러 번 가능). 주면 채널 목록 대신 검색으로 찾는다")
    parser.add_argument("--min-subs", type=int, default=300_000, help="검색 방식에서 채널 구독자 수 하한")
    parser.add_argument("--per-query", type=int, default=10, help="검색어당 최대 후보 수(구독자 수 순)")
    parser.add_argument("--per-channel", type=int, default=12, help="채널당 최대 후보 수(조회수 순)")
    parser.add_argument("--write", action="store_true", help="대기열(input/queue.jsonl) 끝에 추가")
    parser.add_argument("--channel", action="append", default=[], help="이 채널 ID만 본다(여러 번 가능). 없으면 discovery-channels.txt")
    parser.add_argument("--allow-over-target", action="store_true",
                        help="목표 비율을 넘은 요리 종류(예: 밥류)도 고른다. 기본은 제목으로 분류해 걸러낸다")
    args = parser.parse_args()

    if args.query:
        return run_queries(args)
    min_views = 100_000 if args.min_views is None else args.min_views
    known = known_video_ids()
    picked: list[tuple[str, dict]] = []
    blocked = blocked_dish_types(args)
    channels = [(c, "") for c in args.channel] if args.channel else read_channels()
    for channel_id, note in channels:
        html = _get_text(f"https://www.youtube.com/channel/{channel_id}/shorts?hl=ko")
        items = parse_shorts(html)
        if not items:
            print(f"[오류] {note or channel_id}: Shorts 목록을 읽지 못했습니다. 페이지 구조가 바뀌었을 수 있습니다.")
            return 1
        candidates = [i for i in sorted(select(items, known, min_views), key=lambda i: -i["views"])
                      if not is_blocked(i["title"], blocked)]
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
        batch = f"자동 수집 {date.today().isoformat()} (조회수 {min_views:,} 이상)"
        added = append_entries([_entry(dict(item, channel=note.split("(")[0].strip()), "discover-channel", batch)
                                for note, item in picked])
        print(f"{QUEUE_FILE.name}에 {added}개를 추가했습니다.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
