import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

import discover


def page(items):
    data = {"items": [{"shortsLockupViewModel": {
        "onTap": {"innertubeCommand": {"reelWatchEndpoint": {"videoId": i}}},
        "overlayMetadata": {"primaryText": {"content": t}, "secondaryText": {"content": v}},
    }} for i, t, v in items]}
    return f"var ytInitialData = {json.dumps(data, ensure_ascii=False)};</script>"


class ParseTests(unittest.TestCase):
    def test_parse_views_units(self):
        self.assertEqual(discover.parse_views("조회수 3.7만회"), 37_000)
        self.assertEqual(discover.parse_views("조회수 1,234회"), 1_234)
        self.assertEqual(discover.parse_views("조회수 1.2억회"), 120_000_000)
        self.assertIsNone(discover.parse_views("조회수 없음"))
        self.assertIsNone(discover.parse_views(None))

    def test_parse_shorts_reads_id_title_views_without_duplicates(self):
        html = page([("aaaaaaaaaaa", "계란밥", "조회수 12만회"), ("aaaaaaaaaaa", "계란밥", "조회수 12만회")])
        self.assertEqual(discover.parse_shorts(html),
                         [{"id": "aaaaaaaaaaa", "title": "계란밥", "views": 120_000}])

    def test_parse_shorts_returns_empty_when_page_shape_changes(self):
        self.assertEqual(discover.parse_shorts("<html></html>"), [])


class SelectTests(unittest.TestCase):
    def test_filters_known_low_views_and_excluded_titles(self):
        items = [
            {"id": "known", "title": "계란밥", "views": 500_000},
            {"id": "low", "title": "계란밥", "views": 50_000},
            {"id": "ad", "title": "광고 포함 영상", "views": 500_000},
            {"id": "unknown_views", "title": "계란밥", "views": None},
            {"id": "ok", "title": "계란밥", "views": 500_000},
        ]
        chosen = discover.select(items, {"known"}, 100_000)
        self.assertEqual([i["id"] for i in chosen], ["ok"])

def search_page(rows):
    renders = []
    for video_id, title, views, channel, channel_id, length in rows:
        renders.append({"videoRenderer": {
            "videoId": video_id,
            "title": {"runs": [{"text": title}]},
            "viewCountText": {"simpleText": views},
            "ownerText": {"runs": [{"text": channel, "navigationEndpoint": {"browseEndpoint": {"browseId": channel_id}}}]},
            "lengthText": {"simpleText": length},
        }})
    return f"var ytInitialData = {json.dumps({'contents': renders}, ensure_ascii=False)};</script>"


class SearchTests(unittest.TestCase):
    def test_parse_duration(self):
        self.assertEqual(discover.parse_duration("0:45"), 45)
        self.assertEqual(discover.parse_duration("1:02"), 62)
        self.assertEqual(discover.parse_duration("1:02:03"), 3723)
        self.assertIsNone(discover.parse_duration("LIVE"))
        self.assertIsNone(discover.parse_duration(None))

    def test_parse_subscribers_units(self):
        self.assertEqual(discover.parse_subscribers("구독자 149만명"), 1_490_000)
        self.assertEqual(discover.parse_subscribers("구독자 1.2만명"), 12_000)
        self.assertEqual(discover.parse_subscribers("구독자 3,210명"), 3_210)
        self.assertIsNone(discover.parse_subscribers("구독자 없음"))
        self.assertIsNone(discover.parse_subscribers(None))

    def test_parse_search_reads_fields_without_duplicates(self):
        html = search_page([
            ("aaaaaaaaaaa", "토마토 파스타", "조회수 12만회", "채널A", "UCaaa", "0:45"),
            ("aaaaaaaaaaa", "토마토 파스타", "조회수 12만회", "채널A", "UCaaa", "0:45"),
        ])
        self.assertEqual(discover.parse_search(html), [{
            "id": "aaaaaaaaaaa", "title": "토마토 파스타", "views": 120_000,
            "channel": "채널A", "channel_id": "UCaaa", "duration": 45,
        }])

    def test_select_search_filters_known_long_and_excluded_titles(self):
        items = [
            {"id": "a", "title": "크림 파스타", "views": 5, "channel": "c", "channel_id": "UC1", "duration": 50},
            {"id": "b", "title": "알리오올리오", "views": 5, "channel": "c", "channel_id": "UC1", "duration": 600},
            {"id": "c", "title": "파스타 먹방", "views": 5, "channel": "c", "channel_id": "UC1", "duration": 50},
            {"id": "d", "title": "봉골레", "views": 5, "channel": "c", "channel_id": "UC1", "duration": 50},
            {"id": "e", "title": "오일 파스타", "views": 5, "channel": "c", "channel_id": None, "duration": 50},
        ]
        chosen = discover.select_search(items, known={"d"}, min_views=0)
        self.assertEqual([i["id"] for i in chosen], ["a", "e"])

    def test_select_search_keeps_shorts_shelf_items_without_duration(self):
        items = [{"id": "s", "title": "봉골레", "views": 5, "channel": "", "channel_id": None, "duration": None, "shelf": True}]
        self.assertEqual(len(discover.select_search(items, known=set(), min_views=0)), 1)

    def test_parse_search_reads_shorts_shelf(self):
        shelf = {"shortsLockupViewModel": {
            "onTap": {"innertubeCommand": {"reelWatchEndpoint": {"videoId": "bbbbbbbbbbb"}}},
            "overlayMetadata": {"primaryText": {"content": "크림 파스타"}, "secondaryText": {"content": "조회수 3.7만회"}}}}
        html = f"var ytInitialData = {json.dumps({'contents': [shelf]}, ensure_ascii=False)};</script>"
        self.assertEqual(discover.parse_search(html), [{
            "id": "bbbbbbbbbbb", "title": "크림 파스타", "views": 37_000,
            "channel": "", "channel_id": None, "duration": None, "shelf": True}])


if __name__ == "__main__":
    unittest.main()
