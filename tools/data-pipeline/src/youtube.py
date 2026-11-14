import html
import json
import os
import re
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


_PAGE_HEADERS = {"User-Agent": "Mozilla/5.0", "Accept-Language": "ko"}
_FETCH_ERRORS = (HTTPError, URLError, TimeoutError, ValueError, OSError)
_AVATAR_SIZE = "s88"


def _get_json(url: str, headers: dict | None = None) -> dict:
    with urlopen(Request(url, headers=headers or {}), timeout=10) as response:
        payload = json.load(response)
    if not isinstance(payload, dict):
        raise ValueError("expected a JSON object")
    return payload


def _get_text(url: str) -> str:
    with urlopen(Request(url, headers=_PAGE_HEADERS), timeout=10) as response:
        return response.read().decode("utf-8", "replace")


def _small_avatar(url: str | None) -> str | None:
    """Normalize a yt3 avatar URL to the 88px size the app shows."""
    if not url:
        return None
    return re.sub(r"=s\d+-", f"={_AVATAR_SIZE}-", url, count=1)


def _metadata_from_data_api(video_id: str, api_key: str) -> dict:
    video = _get_json("https://www.googleapis.com/youtube/v3/videos?"
                      + urlencode({"part": "snippet", "id": video_id, "key": api_key}))
    items = video.get("items") or []
    snippet = items[0].get("snippet", {}) if items and isinstance(items[0], dict) else {}
    result = {
        "sourceTitle": snippet.get("title"),
        "sourceChannelName": snippet.get("channelTitle"),
        "sourceChannelId": snippet.get("channelId"),
        "sourceChannelThumbnailUrl": None,
    }
    if result["sourceChannelId"]:
        try:
            channel = _get_json("https://www.googleapis.com/youtube/v3/channels?"
                                + urlencode({"part": "snippet", "id": result["sourceChannelId"], "key": api_key}))
            channels = channel.get("items") or []
            thumbs = channels[0].get("snippet", {}).get("thumbnails", {}) if channels else {}
            result["sourceChannelThumbnailUrl"] = (thumbs.get("default") or {}).get("url")
        except _FETCH_ERRORS:
            pass
    return result


def _metadata_from_public_pages(video_id: str) -> dict:
    result = {"sourceTitle": None, "sourceChannelName": None, "sourceChannelId": None,
              "sourceChannelThumbnailUrl": None}
    try:
        oembed = _get_json("https://www.youtube.com/oembed?"
                           + urlencode({"url": f"https://www.youtube.com/watch?v={video_id}", "format": "json"}),
                           {"User-Agent": "WhippyRecipePipeline/1.0"})
        result["sourceTitle"] = oembed.get("title")
        result["sourceChannelName"] = oembed.get("author_name")
    except _FETCH_ERRORS:
        pass
    try:
        page = _get_text(f"https://www.youtube.com/shorts/{video_id}")
        match = (re.search(r'"externalChannelId":"(UC[\w-]+)"', page)
                 or re.search(r'"channelId":"(UC[\w-]+)"', page))
        if match:
            result["sourceChannelId"] = match.group(1)
        if result["sourceTitle"] is None:
            title = re.search(r'<meta name="title" content="([^"]*)"', page)
            result["sourceTitle"] = html.unescape(title.group(1)) if title else None
        if result["sourceChannelName"] is None:
            owner = re.search(r'"ownerChannelName":"((?:[^"\\]|\\.)*)"', page)
            result["sourceChannelName"] = json.loads(f'"{owner.group(1)}"') if owner else None
    except _FETCH_ERRORS:
        pass
    return result


def _channel_avatar_from_page(channel_id: str) -> str | None:
    try:
        page = _get_text(f"https://www.youtube.com/channel/{channel_id}")
    except _FETCH_ERRORS:
        return None
    match = re.search(r'<meta property="og:image" content="(https://yt3\.[^"]+)"', page)
    return _small_avatar(match.group(1)) if match else None


def fetch_source_metadata(video_id: str) -> dict:
    """Fetch public YouTube attribution metadata without involving Gemini.

    Uses the YouTube Data API when a key is configured, otherwise (or when the
    API fails) the public oEmbed endpoint and the public video/channel pages.
    Each value is collected independently; anything not found stays null and
    is never guessed (docs/v4/development/implementation-guide.md).
    """
    fetched_at = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    result = None
    api_key = os.environ.get("YOUTUBE_DATA_API_KEY")
    if api_key:
        try:
            result = _metadata_from_data_api(video_id, api_key)
        except _FETCH_ERRORS:
            result = None
    if not result or not result.get("sourceChannelName"):
        result = _metadata_from_public_pages(video_id)
    if result.get("sourceChannelId") and not result.get("sourceChannelThumbnailUrl"):
        result["sourceChannelThumbnailUrl"] = _channel_avatar_from_page(result["sourceChannelId"])
    found_any = any(result.get(key) for key in ("sourceTitle", "sourceChannelName", "sourceChannelId"))
    result["sourceMetadataFetchedAt"] = fetched_at if found_any else None
    return result
