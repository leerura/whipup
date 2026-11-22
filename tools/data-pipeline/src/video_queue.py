"""The video queue: input/queue.jsonl, one JSON object per line, in the order videos were added.

Each entry: {"videoId", "url", "source": "manual|discover-channel|discover-search", "addedAt"?, "batch"?,
"note"?}. Entries are never removed, so the queue doubles as the record of every video ever submitted;
videos that must not be extracted are listed in rules/exclusions.json instead of being commented out.
"""

from __future__ import annotations

import json
from pathlib import Path

from youtube import extract_video_id

ROOT = Path(__file__).resolve().parents[1]
QUEUE_FILE = ROOT / "input" / "queue.jsonl"
EXCLUSIONS_FILE = ROOT / "rules" / "exclusions.json"


def read_queue(path: Path = QUEUE_FILE) -> list[dict]:
    """All entries, first occurrence of each video only. Malformed lines are reported and skipped."""
    if not path.exists():
        return []
    entries, seen = [], set()
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if not line.strip():
            continue
        try:
            entry = json.loads(line)
            video_id = entry["videoId"]
            if extract_video_id(entry["url"]) != video_id:
                raise ValueError("videoId does not match url")
        except (ValueError, KeyError, TypeError) as exc:
            print(f"[queue:{line_number}] ignored invalid entry: {exc}", flush=True)
            continue
        if video_id not in seen:
            seen.add(video_id)
            entries.append(entry)
    return entries


class ExclusionsUnreadable(Exception):
    """rules/exclusions.json could not be read and no earlier copy is known."""


_last_good: dict[Path, set[str]] = {}


def excluded_ids(path: Path = EXCLUSIONS_FILE) -> set[str]:
    """IDs in rules/exclusions.json. A broken or wrongly shaped file never means "nothing is excluded":
    the last good copy is used, and before any good copy exists ExclusionsUnreadable is raised."""
    if not path.exists():
        return set()
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(data, dict) or not isinstance(data.get("videos"), dict):
            raise ValueError("expected an object with a 'videos' object")
        _last_good[path] = set(data["videos"])
    except (OSError, ValueError) as exc:
        if path not in _last_good:
            raise ExclusionsUnreadable(f"{path}: {exc}") from exc
        print(f"[queue] cannot read {path} ({exc}); using the last good exclusion list", flush=True)
    return _last_good[path]


def read_urls(path: Path = QUEUE_FILE, exclusions: Path = EXCLUSIONS_FILE) -> list[tuple[str, str]]:
    """(videoId, url) to extract: queue entries not in the exclusion list."""
    excluded = excluded_ids(exclusions)
    return [(e["videoId"], e["url"]) for e in read_queue(path) if e["videoId"] not in excluded]


def append_entries(entries: list[dict], path: Path = QUEUE_FILE) -> int:
    """Append new videos; ones already queued are skipped. Returns how many were added."""
    known = {e["videoId"] for e in read_queue(path)}
    new = [e for e in entries if e["videoId"] not in known]
    if new:
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists() and path.stat().st_size and not path.read_bytes().endswith(b"\n"):
            with path.open("a", encoding="utf-8") as stream:
                stream.write("\n")
        with path.open("a", encoding="utf-8") as stream:
            for entry in new:
                stream.write(json.dumps({k: v for k, v in entry.items() if v is not None}, ensure_ascii=False) + "\n")
    return len(new)


def main(argv: list[str] | None = None) -> int:
    """`python3 src/video_queue.py add URL [URL ...] [--note TEXT]`: add videos by hand."""
    import argparse
    from datetime import date
    parser = argparse.ArgumentParser(description="Add videos to input/queue.jsonl")
    sub = parser.add_subparsers(dest="command", required=True)
    add = sub.add_parser("add")
    add.add_argument("urls", nargs="+")
    add.add_argument("--note")
    args = parser.parse_args(argv)
    entries = [{"videoId": extract_video_id(url), "url": url.strip(), "source": "manual",
                "addedAt": date.today().isoformat(), "note": args.note} for url in args.urls]
    print(f"{append_entries(entries)}개 추가 (이미 있던 영상은 건너뜀)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
