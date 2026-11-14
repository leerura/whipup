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


if __name__ == "__main__":
    unittest.main()
