import json
import sys
import tempfile
import threading
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path
from unittest.mock import patch

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

import dashboard
import pipeline
import retry
import state


class ClassificationValidationTests(unittest.TestCase):
    def test_classification_is_required_only_for_new_extractions(self):
        from validator import validate_source_extraction
        base = {"title": "볶음밥", "ingredients": [{"sourceId": "ingredient-1", "rawText": "계란", "displayName": "계란",
                                                  "amount": None, "unit": None, "optional": False, "evidences": []}],
                "steps": [{"text": "볶는다", "evidences": []}], "unresolved": []}
        self.assertEqual(validate_source_extraction(base), [])
        self.assertEqual(len(validate_source_extraction(base, require_classification=True)), 4)
        full = {**base, "recipeName": "계란볶음밥", "dishType": "RICE", "mainIngredients": ["계란"], "requiresCooking": True}
        self.assertEqual(validate_source_extraction(full, require_classification=True), [])


class PipelineQueueTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.addCleanup(self.temp.cleanup)
        self.state_dir_patch = patch.object(state, "STATE_DIR", self.root / "state")
        self.state_dir_patch.start()
        self.addCleanup(self.state_dir_patch.stop)
        self.dashboard_state_dir_patch = patch.object(dashboard, "STATE_DIR", self.root / "state")
        self.dashboard_state_dir_patch.start()
        self.addCleanup(self.dashboard_state_dir_patch.stop)
        self.source_metadata_patch = patch("pipeline.fetch_source_metadata", return_value={
            "sourceTitle": None,
            "sourceChannelName": None,
            "sourceChannelId": None,
            "sourceMetadataFetchedAt": None,
        })
        self.source_metadata_patch.start()
        self.addCleanup(self.source_metadata_patch.stop)
        self.is_short_patch = patch("pipeline.is_short", return_value=True)
        self.is_short_mock = self.is_short_patch.start()
        self.addCleanup(self.is_short_patch.stop)

    def test_non_short_video_is_skipped_without_calling_gemini(self):
        class ExplodingClient:
            def extract_recipe_source(self, *_args):
                raise AssertionError("Gemini must not be called for a non-Short")
        self.is_short_mock.return_value = False
        state.claim_video("abc123", "https://youtu.be/abc123", "worker-a")
        result = pipeline.process_claimed_video("abc123", "https://youtu.be/abc123", ExplodingClient(), "test", "worker-a", "account-a")
        self.assertEqual(result, "SKIPPED_NOT_SHORT")
        saved = state.load_video("abc123")
        self.assertEqual(saved["status"], "SKIPPED_NOT_SHORT")
        self.assertNotIn("lease", saved)
        self.assertFalse(pipeline._eligible("abc123", "account-a", True))

    def test_unknown_short_status_still_extracts(self):
        self.is_short_mock.return_value = None
        self.assertTrue(pipeline._eligible("fresh123", "account-a", False))

    def test_duplicate_urls_are_video_id_deduplicated(self):
        urls = self.root / "queue.jsonl"
        urls.write_text('{"videoId": "abc123", "url": "https://youtu.be/abc123"}\n'
                        '{"videoId": "abc123", "url": "https://youtube.com/shorts/abc123"}\n', encoding="utf-8")
        self.assertEqual(pipeline.read_urls(urls, self.root / "none.json"), [("abc123", "https://youtu.be/abc123")])

    def test_concurrent_claims_only_have_one_winner(self):
        winners = []
        lock = threading.Lock()
        def claim(worker):
            if state.claim_video("abc123", "https://youtu.be/abc123", worker):
                with lock:
                    winners.append(worker)
        threads = [threading.Thread(target=claim, args=(f"worker-{number}",)) for number in range(8)]
        for thread in threads: thread.start()
        for thread in threads: thread.join()
        self.assertEqual(len(winners), 1)
        self.assertEqual(state.load_video("abc123")["lease"]["workerId"], winners[0])

    def test_stale_running_lease_is_recovered(self):
        old = (datetime.now(timezone.utc) - timedelta(minutes=16)).isoformat()
        state.save_video({"videoId": "abc123", "status": "EXTRACTION_RUNNING", "extraction": {"status": "RUNNING"}, "lease": {"workerId": "dead", "heartbeatAt": old}})
        self.assertEqual(state.recover_stale_claims(["abc123"]), 1)
        self.assertEqual(state.load_video("abc123")["status"], "PENDING")

    def test_pending_work_beats_quota_held_work_and_quota_is_account_specific(self):
        until = (datetime.now(timezone.utc) + timedelta(hours=2)).isoformat()
        state.save_video({"videoId": "held", "status": "WAITING_RETRY", "extraction": {"status": "WAITING_RETRY", "retryKind": "quota", "quotaAccounts": {"account-a": until}, "retryAt": until}})
        items = [("held", "https://youtu.be/held"), ("fresh", "https://youtu.be/fresh")]
        self.assertEqual(pipeline.claim_next(items, "worker-a", "account-a"), ("fresh", "https://youtu.be/fresh"))
        # When no PENDING URL remains, another independent account may take it.
        self.assertEqual(pipeline.claim_next(items, "worker-b", "account-b"), ("held", "https://youtu.be/held"))

    def test_transient_retries_are_short_and_then_retryable(self):
        error = RuntimeError("connection timed out")
        self.assertEqual(retry.retry_decision(error, 0)["waitSeconds"], 10)
        self.assertEqual(retry.retry_decision(error, 1)["waitSeconds"], 30)
        self.assertEqual(retry.retry_decision(error, 2)["waitSeconds"], 60)
        self.assertEqual(retry.retry_decision(error, 3)["reason"], "failed_retryable")

    def test_non_retryable_access_error_is_failed(self):
        decision = retry.retry_decision(RuntimeError("403 PERMISSION_DENIED"), 0)
        self.assertEqual(decision["reason"], "non_retryable_access")

    def test_failed_retryable_turns_review_pending_after_three_runs(self):
        state.save_video({"videoId": "abc123", "status": "FAILED_RETRYABLE", "extraction": {"status": "FAILED_RETRYABLE", "retryableRuns": 2}})
        pipeline._prepare_for_run([("abc123", "https://youtu.be/abc123")])
        self.assertEqual(state.load_video("abc123")["status"], "REVIEW_PENDING")

    def test_claimed_video_is_saved_once_as_extraction_ready(self):
        class FakeClient:
            def extract_recipe_source(self, _url, _video_id):
                result = {"title": "볶음밥", "description": None, "servings": None, "ingredients": [], "steps": [{"text": "볶는다", "evidences": []}], "unresolved": []}
                return result, json.dumps(result, ensure_ascii=False)
        self.assertTrue(state.claim_video("abc123", "https://youtu.be/abc123", "worker-a"))
        self.assertEqual(pipeline.process_claimed_video("abc123", "https://youtu.be/abc123", FakeClient(), "test", "worker-a", "account-a"), "EXTRACTION_READY")
        self.assertEqual(state.load_video("abc123")["extraction"]["status"], "COMPLETED")
        self.assertNotIn("lease", state.load_video("abc123"))

    def test_dashboard_snapshot_has_progress_and_worker_state(self):
        urls = self.root / "queue.jsonl"
        urls.write_text('{"videoId": "abc123", "url": "https://youtu.be/abc123"}\n', encoding="utf-8")
        state.save_video({"videoId": "abc123", "status": "EXTRACTION_READY", "extraction": {"status": "COMPLETED"}})
        state.save_workers({"account-a-run": {"accountId": "account-a", "status": "IDLE"}})
        snapshot = dashboard.queue_snapshot(urls)
        self.assertEqual(snapshot["total"], 1)
        self.assertEqual(snapshot["counts"], {"EXTRACTION_READY": 1})
        self.assertEqual(snapshot["workers"]["account-a-run"]["accountId"], "account-a")

    def test_dashboard_explains_missing_account_configuration(self):
        urls = self.root / "queue.jsonl"
        urls.write_text("", encoding="utf-8")
        state.save_runtime_status({"status": "NO_CONFIGURED_ACCOUNTS"})
        page = dashboard._page(dashboard.queue_snapshot(urls))
        self.assertIn("유효한 계정 설정이 없습니다", page)


if __name__ == "__main__":
    unittest.main()
