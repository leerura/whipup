import sys
import unittest
from pathlib import Path
from unittest.mock import patch
from urllib.error import HTTPError

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

import youtube

VIDEO_PAGE = '<meta name="title" content="간장계란밥 &amp; 계란"> "externalChannelId":"UCabc123" "ownerChannelName":"자취생존"'
CHANNEL_PAGE = '<meta property="og:image" content="https://yt3.googleusercontent.com/xyz=s900-c-k-c0x00ffffff-no-rj">'


class IsShortTests(unittest.TestCase):
    def _opener(self, outcome):
        class Opener:
            def open(self, *_args, **_kwargs):
                if isinstance(outcome, Exception):
                    raise outcome
                return outcome
        return Opener()

    def test_ok_response_is_a_short(self):
        class Response:
            status = 200
            def __enter__(self): return self
            def __exit__(self, *_args): return False
        with patch.object(youtube, "build_opener", return_value=self._opener(Response())):
            self.assertIs(youtube.is_short("abc"), True)

    def test_redirect_to_watch_is_not_a_short(self):
        error = HTTPError("u", 303, "See Other", {"Location": "https://www.youtube.com/watch?v=abc"}, None)
        with patch.object(youtube, "build_opener", return_value=self._opener(error)):
            self.assertIs(youtube.is_short("abc"), False)

    def test_other_failures_are_unknown(self):
        with patch.object(youtube, "build_opener", return_value=self._opener(HTTPError("u", 500, "x", {}, None))):
            self.assertIsNone(youtube.is_short("abc"))
        with patch.object(youtube, "build_opener", return_value=self._opener(TimeoutError())):
            self.assertIsNone(youtube.is_short("abc"))


class FetchSourceMetadataTests(unittest.TestCase):
    def test_public_pages_fill_every_field_without_api_key(self):
        def get_text(url):
            return CHANNEL_PAGE if "/channel/" in url else VIDEO_PAGE
        with patch.dict("os.environ", {}, clear=True), \
             patch.object(youtube, "_get_json", return_value={"title": "간장계란밥", "author_name": "자취생존"}), \
             patch.object(youtube, "_get_text", side_effect=get_text):
            meta = youtube.fetch_source_metadata("vid")
        self.assertEqual(meta["sourceTitle"], "간장계란밥")
        self.assertEqual(meta["sourceChannelName"], "자취생존")
        self.assertEqual(meta["sourceChannelId"], "UCabc123")
        self.assertEqual(meta["sourceChannelThumbnailUrl"],
                         "https://yt3.googleusercontent.com/xyz=s88-c-k-c0x00ffffff-no-rj")
        self.assertIsNotNone(meta["sourceMetadataFetchedAt"])

    def test_page_fallbacks_cover_blocked_oembed(self):
        def get_json(url, headers=None):
            raise HTTPError(url, 401, "Unauthorized", None, None)
        def get_text(url):
            return CHANNEL_PAGE if "/channel/" in url else VIDEO_PAGE
        with patch.dict("os.environ", {}, clear=True), \
             patch.object(youtube, "_get_json", side_effect=get_json), \
             patch.object(youtube, "_get_text", side_effect=get_text):
            meta = youtube.fetch_source_metadata("vid")
        self.assertEqual(meta["sourceTitle"], "간장계란밥 & 계란")
        self.assertEqual(meta["sourceChannelName"], "자취생존")
        self.assertEqual(meta["sourceChannelId"], "UCabc123")

    def test_data_api_uses_channel_default_thumbnail(self):
        def get_json(url, headers=None):
            if "/videos?" in url:
                return {"items": [{"snippet": {"title": "T", "channelTitle": "C", "channelId": "UCx"}}]}
            return {"items": [{"snippet": {"thumbnails": {"default": {"url": "https://yt3.ggpht.com/a=s88-c"}}}}]}
        with patch.dict("os.environ", {"YOUTUBE_DATA_API_KEY": "k"}), \
             patch.object(youtube, "_get_json", side_effect=get_json), \
             patch.object(youtube, "_get_text", side_effect=AssertionError("pages not needed")):
            meta = youtube.fetch_source_metadata("vid")
        self.assertEqual(meta["sourceChannelId"], "UCx")
        self.assertEqual(meta["sourceChannelThumbnailUrl"], "https://yt3.ggpht.com/a=s88-c")

    def test_everything_failing_leaves_nulls(self):
        with patch.dict("os.environ", {}, clear=True), \
             patch.object(youtube, "_get_json", side_effect=OSError("offline")), \
             patch.object(youtube, "_get_text", side_effect=OSError("offline")):
            meta = youtube.fetch_source_metadata("vid")
        self.assertEqual(set(meta.values()), {None})


if __name__ == "__main__":
    unittest.main()
