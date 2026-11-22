import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

import video_queue
from video_queue import ExclusionsUnreadable, append_entries, read_queue, read_urls


class VideoQueueTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        self.queue, self.exclusions = root / "queue.jsonl", root / "exclusions.json"
        self.queue.write_text(
            '{"videoId": "aaaaaaaaaaa", "url": "https://www.youtube.com/shorts/aaaaaaaaaaa", "source": "manual"}\n'
            'not json\n'
            '{"videoId": "bbbbbbbbbbb", "url": "https://www.youtube.com/shorts/ccccccccccc"}\n'
            '{"videoId": "ddddddddddd", "url": "https://youtu.be/ddddddddddd?si=x"}\n', encoding="utf-8")
        self.exclusions.write_text(json.dumps({"videos": {"ddddddddddd": {"category": "NOT_SHORT"}}}), encoding="utf-8")

    def tearDown(self):
        self.tmp.cleanup()

    def test_invalid_or_mismatched_lines_are_skipped(self):
        self.assertEqual([e["videoId"] for e in read_queue(self.queue)], ["aaaaaaaaaaa", "ddddddddddd"])

    def test_excluded_videos_stay_queued_but_are_not_extracted(self):
        self.assertEqual(read_urls(self.queue, self.exclusions),
                         [("aaaaaaaaaaa", "https://www.youtube.com/shorts/aaaaaaaaaaa")])

    def test_append_skips_known_videos_and_drops_empty_fields(self):
        added = append_entries([
            {"videoId": "aaaaaaaaaaa", "url": "https://www.youtube.com/shorts/aaaaaaaaaaa"},
            {"videoId": "eeeeeeeeeee", "url": "https://www.youtube.com/shorts/eeeeeeeeeee", "views": None}], self.queue)
        self.assertEqual(added, 1)
        self.assertEqual(json.loads(self.queue.read_text(encoding="utf-8").splitlines()[-1]),
                         {"videoId": "eeeeeeeeeee", "url": "https://www.youtube.com/shorts/eeeeeeeeeee"})


    def test_append_after_a_line_without_newline_keeps_both(self):
        self.queue.write_text('{"videoId": "aaaaaaaaaaa", "url": "https://www.youtube.com/shorts/aaaaaaaaaaa"}', encoding="utf-8")
        append_entries([{"videoId": "eeeeeeeeeee", "url": "https://www.youtube.com/shorts/eeeeeeeeeee"}], self.queue)
        self.assertEqual([e["videoId"] for e in read_queue(self.queue)], ["aaaaaaaaaaa", "eeeeeeeeeee"])

    def test_broken_exclusions_never_mean_nothing_is_excluded(self):
        video_queue._last_good.pop(self.exclusions, None)
        self.exclusions.write_text('{"ddddddddddd": {}}', encoding="utf-8")
        with self.assertRaises(ExclusionsUnreadable):
            read_urls(self.queue, self.exclusions)
        self.exclusions.write_text(json.dumps({"videos": {"ddddddddddd": {}}}), encoding="utf-8")
        self.assertEqual(len(read_urls(self.queue, self.exclusions)), 1)
        self.exclusions.write_text('{"videos": {', encoding="utf-8")
        self.assertEqual(len(read_urls(self.queue, self.exclusions)), 1)  # last good list kept


if __name__ == "__main__":
    unittest.main()
