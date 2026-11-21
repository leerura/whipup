import sys
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

import dashboard

NOW = datetime(2026, 11, 14, 10, 0, tzinfo=timezone.utc)


class DescribeWorkerTests(unittest.TestCase):
    def test_extracting_shows_video_and_elapsed_time(self):
        info = dashboard.describe_worker(
            {"status": "EXTRACTING", "currentVideoId": "abc", "updatedAt": (NOW - timedelta(minutes=3)).isoformat()}, NOW)
        self.assertEqual((info["kind"], info["videoId"], info["detail"]), ("working", "abc", "3분 전부터"))

    def test_quota_shows_resume_time_in_kst_and_remaining(self):
        info = dashboard.describe_worker(
            {"status": "WAITING_QUOTA", "nextRetryAt": (NOW + timedelta(hours=5, minutes=40)).isoformat()}, NOW)
        self.assertEqual(info["kind"], "quota")
        self.assertIn("00:40", info["detail"])  # 15:40 UTC+... 10:00Z + 5h40 = 15:40Z = 00:40 KST
        self.assertIn("5시간 40분 후", info["detail"])

    def test_idle_and_failed(self):
        self.assertEqual(dashboard.describe_worker({"status": "IDLE"}, NOW)["kind"], "idle")
        failed = dashboard.describe_worker({"status": "FAILED_RETRYABLE", "lastError": "Server disconnected"}, NOW)
        self.assertEqual((failed["kind"], failed["detail"]), ("failed", "연결 끊김"))


class ShortErrorTests(unittest.TestCase):
    def test_summaries(self):
        self.assertEqual(dashboard.short_error("429 RESOURCE_EXHAUSTED ... requests per day limit"), "일일 한도 초과")
        self.assertEqual(dashboard.short_error("503 UNAVAILABLE high demand"), "Gemini 일시 과부하")
        self.assertEqual(dashboard.short_error(None), "")
        self.assertEqual(len(dashboard.short_error("x" * 300)), 60)


class CurrentWorkersTests(unittest.TestCase):
    def test_keeps_only_newest_run_sorted_by_account(self):
        workers = {
            "b-old": {"accountId": "account-b", "runId": "old", "updatedAt": "2026-10-25T00:00:00+00:00"},
            "b-new": {"accountId": "account-b", "runId": "new", "updatedAt": "2026-11-14T00:00:00+00:00"},
            "a-new": {"accountId": "account-a", "runId": "new", "updatedAt": "2026-11-14T00:00:01+00:00"},
        }
        rows = dashboard.current_workers(workers)
        self.assertEqual([r["accountId"] for r in rows], ["account-a", "account-b"])
        self.assertTrue(all(r["runId"] == "new" for r in rows))


if __name__ == "__main__":
    unittest.main()
