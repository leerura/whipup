from urllib.parse import parse_qs, urlparse


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
