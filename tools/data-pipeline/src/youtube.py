import json
import os
from datetime import datetime, timezone
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlencode, urlparse
from urllib.request import Request, urlopen


def extract_video_id(url: str) -> str:
    parsed = urlparse(url.strip())

    if parsed.netloc in {"youtu.be", "www.youtu.be"}:
        return parsed.path.strip("/")

    if "youtube.com" in parsed.netloc:
        if parsed.path.startswith("/shorts/"):
            parts = parsed.path.split("/")
            if len(parts) > 2 and parts[2]:
                return parts[2]

        query = parse_qs(parsed.query)
        if "v" in query and query["v"]:
            return query["v"][0]

    raise ValueError(f"Unsupported YouTube URL: {url}")


def fetch_source_metadata(video_id: str) -> dict:
    """Fetch public YouTube attribution metadata without involving Gemini.

    oEmbed does not expose a stable channel ID. An optional YouTube Data API
    key upgrades the snapshot with the channel ID; missing metadata stays null.
    """
    fetched_at = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    api_key = os.environ.get("YOUTUBE_DATA_API_KEY")
    if api_key:
        query = urlencode({"part": "snippet", "id": video_id, "key": api_key})
        request = Request(f"https://www.googleapis.com/youtube/v3/videos?{query}")
        try:
            with urlopen(request, timeout=10) as response:
                payload = json.load(response)
            items = payload.get("items", []) if isinstance(payload, dict) else []
            if items:
                snippet = items[0].get("snippet", {}) if isinstance(items[0], dict) else {}
                return {
                    "sourceTitle": snippet.get("title"),
                    "sourceChannelName": snippet.get("channelTitle"),
                    "sourceChannelId": snippet.get("channelId"),
                    "sourceMetadataFetchedAt": fetched_at,
                }
        except (HTTPError, URLError, TimeoutError, ValueError, OSError):
            pass

    query = urlencode({"url": f"https://www.youtube.com/watch?v={video_id}", "format": "json"})
    request = Request(f"https://www.youtube.com/oembed?{query}", headers={"User-Agent": "WhippyRecipePipeline/1.0"})
    try:
        with urlopen(request, timeout=10) as response:
            payload = json.load(response)
        if not isinstance(payload, dict):
            raise ValueError("YouTube oEmbed response was not an object")
        return {
            "sourceTitle": payload.get("title"),
            "sourceChannelName": payload.get("author_name"),
            "sourceChannelId": None,
            "sourceMetadataFetchedAt": fetched_at,
        }
    except (HTTPError, URLError, TimeoutError, ValueError, OSError):
        return {
            "sourceTitle": None,
            "sourceChannelName": None,
            "sourceChannelId": None,
            "sourceMetadataFetchedAt": None,
        }
