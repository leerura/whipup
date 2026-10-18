import json
import sys
import tempfile
import unittest
from datetime import datetime, timezone
from pathlib import Path
from unittest.mock import patch

SRC = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC))

import pipeline
import retry
import state
from validator import validate_draft


class RetryTests(unittest.TestCase):
    def test_ambiguous_429_uses_spaced_retries_then_pacific_midnight(self):
        error = RuntimeError("429 RESOURCE_EXHAUSTED")
        self.assertEqual(retry.retry_decision(error, 0)["waitSeconds"], 60)
        self.assertEqual(retry.retry_decision(error, 1)["waitSeconds"], 300)
        self.assertEqual(retry.retry_decision(error, 2)["waitSeconds"], 900)
        decision = retry.retry_decision(error, 3)
        self.assertEqual(decision["reason"], "daily_quota_reset")
        self.assertGreater(datetime.fromisoformat(decision["retryAt"]), datetime.now(timezone.utc))

    def test_provider_retry_info_is_used(self):
        error = RuntimeError('{"retryDelay":"37s"}')
        decision = retry.retry_decision(error, 0)
        self.assertEqual(decision["waitSeconds"], 37)
        self.assertEqual(decision["reason"], "provider_retry_info")

    def test_provider_human_retry_delay_with_hours_and_minutes_is_used(self):
        error = RuntimeError("429 RESOURCE_EXHAUSTED. Please retry in 2h30m.")
        self.assertEqual(retry.retry_decision(error, 0)["waitSeconds"], 9000)

    def test_daily_quota_waits_until_next_pacific_midnight(self):
        error = RuntimeError("429 daily quota exceeded")
        decision = retry.retry_decision(error, 0)
        self.assertEqual(decision["reason"], "daily_quota_reset")

    def test_provider_daily_quota_metric_without_spaces_is_recognized(self):
        error = RuntimeError("429 RESOURCE_EXHAUSTED quota metric GenerateRequestsPerDayPerProject")
        self.assertEqual(retry.retry_decision(error, 0)["reason"], "daily_quota_reset")

    def test_transient_failure_uses_backoff_and_then_stops(self):
        error = RuntimeError("connection timed out")
        self.assertEqual(retry.retry_decision(error, 0)["waitSeconds"], 60)
        self.assertEqual(retry.retry_decision(error, 1)["waitSeconds"], 300)
        self.assertEqual(retry.retry_decision(error, 2)["waitSeconds"], 900)
        self.assertEqual(retry.retry_decision(error, 3)["reason"], "failed")

    def test_string_status_codes_and_dns_errors_are_transient(self):
        class ApiFailure(Exception):
            code = "503"

        self.assertEqual(retry.retry_decision(ApiFailure("upstream failed"), 0)["reason"], "transient_backoff")
        self.assertEqual(
            retry.retry_decision(RuntimeError("Temporary failure in name resolution"), 0)["reason"],
            "transient_backoff",
        )


class PipelineTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.addCleanup(self.temp.cleanup)
        self.catalog = {
            "ingredients": [{
                "key": "garlic", "name": "마늘",
                "variants": [{"key": "minced-garlic", "name": "다진 마늘", "aliases": []}],
                "relations": [],
            }]
        }
        self.master_path = self.root / "ingredients.json"
        self.master_path.write_text(json.dumps(self.catalog, ensure_ascii=False), encoding="utf-8")
        self.state_dir_patch = patch.object(state, "STATE_DIR", self.root / "state")
        self.state_dir_patch.start()
        self.addCleanup(self.state_dir_patch.stop)
        self.master_path_patch = patch.object(pipeline, "INGREDIENTS_FILE", self.master_path)
        self.master_path_patch.start()
        self.addCleanup(self.master_path_patch.stop)

    def test_comment_and_duplicate_url_handling(self):
        urls = self.root / "urls.txt"
        urls.write_text(
            "# https://youtu.be/ignored\nhttps://youtu.be/abc123?x=1\nhttps://youtube.com/shorts/abc123\n",
            encoding="utf-8",
        )
        self.assertEqual(pipeline.read_urls(urls), [("abc123", "https://youtu.be/abc123?x=1")])

    def test_checkpoints_stage_outputs_and_holds_draft_for_agent_review(self):
        source = {
            "rawText": "다진 마늘 1큰술", "displayName": "다진 마늘",
            "amount": "1", "unit": "큰술", "evidences": [],
        }
        recipe = {
            "key": "garlic-recipe", "name": "마늘 요리", "status": "DRAFT",
            "shortsReference": "https://youtu.be/abc123",
            "ingredients": [{
                "key": "garlic", "variant": "minced-garlic", "acceptedOwnedVariants": [],
                "sourceId": "ingredient-1", **source, "optional": False,
            }],
            "requirements": [{"options": [{"ingredient": "garlic", "substitutes": [], "allowedVariants": []}]}],
            "steps": ["마늘을 넣는다."],
        }

        class FakeClient:
            calls = 0

            def extract_stage_one_ingredients(self, _url):
                self.calls += 1
                return [source]

            def structure_recipe(self, **_kwargs):
                self.calls += 1
                return {"recipe": recipe, "catalogAdditions": {"ingredients": []}, "mappingFailures": []}

        client = FakeClient()
        status = pipeline.process_video("abc123", "https://youtu.be/abc123", client, "test-model")
        self.assertEqual(status, "REVIEW_PENDING")
        saved = state.load_video("abc123")
        self.assertEqual(saved["stages"]["stage1"]["status"], "COMPLETED")
        self.assertEqual(saved["stages"]["stage2"]["status"], "COMPLETED")
        self.assertEqual(saved["review"]["status"], "PENDING")
        self.assertEqual(client.calls, 2)

        self.assertEqual(
            pipeline.process_video("abc123", "https://youtu.be/abc123", client, "test-model"),
            "REVIEW_PENDING",
        )
        self.assertEqual(client.calls, 2)

    def test_stage_two_waits_for_v3_catalog_without_calling_gemini(self):
        legacy_catalog = {
            "ingredients": [{"key": "garlic", "name": "마늘", "variants": [{"key": "garlic", "name": "마늘", "base": True}], "relations": []}]
        }
        self.master_path.write_text(json.dumps(legacy_catalog, ensure_ascii=False), encoding="utf-8")
        state.save_video({
            "videoId": "abc123", "status": "STAGE_1_COMPLETED", "sourceUrl": "https://youtu.be/abc123",
            "stages": {"stage1": {"status": "COMPLETED", "ingredients": []}, "stage2": {"status": "PENDING", "retryCount": 0}},
        })

        class FakeClient:
            def extract_stage_one_ingredients(self, _url):
                raise AssertionError("Stage 1 should already be checkpointed")

            def structure_recipe(self, **_kwargs):
                raise AssertionError("V2 catalog must block Stage 2")

        status = pipeline.process_video("abc123", "https://youtu.be/abc123", FakeClient(), "test-model")
        self.assertEqual(status, "WAITING_CATALOG")
        self.assertTrue(state.load_video("abc123")["catalogErrors"])

    def test_missing_and_empty_catalog_save_stage_one_and_block_stage_two(self):
        class FakeClient:
            stage_one_calls = 0
            stage_two_calls = 0

            def extract_stage_one_ingredients(self, _url):
                self.stage_one_calls += 1
                return [{
                    "rawText": "마늘", "displayName": "마늘", "amount": None,
                    "unit": None, "evidences": [],
                }]

            def structure_recipe(self, **_kwargs):
                self.stage_two_calls += 1
                raise AssertionError("Stage 2 must wait until a valid V3 catalog exists")

        for catalog_value in (None, {"ingredients": []}):
            with self.subTest(catalog=catalog_value):
                checkpoint = self.root / "state" / "abc123.json"
                checkpoint.unlink(missing_ok=True)
                if catalog_value is None:
                    self.master_path.unlink(missing_ok=True)
                else:
                    self.master_path.write_text(json.dumps(catalog_value), encoding="utf-8")
                client = FakeClient()
                status = pipeline.process_video("abc123", "https://youtu.be/abc123", client, "test-model")
                saved = state.load_video("abc123")
                self.assertEqual(status, "WAITING_CATALOG")
                self.assertEqual(saved["stages"]["stage1"]["status"], "COMPLETED")
                self.assertEqual(saved["stages"]["stage2"]["status"], "PENDING")
                self.assertEqual(client.stage_one_calls, 1)
                self.assertEqual(client.stage_two_calls, 0)

    def test_worker_sleeps_before_polling_again_for_waiting_catalog(self):
        legacy_catalog = {
            "ingredients": [{"key": "garlic", "name": "마늘", "variants": [{"key": "garlic", "name": "마늘", "base": True}], "relations": []}]
        }
        self.master_path.write_text(json.dumps(legacy_catalog, ensure_ascii=False), encoding="utf-8")

        class StopLoop(Exception):
            pass

        class FakeClient:
            def extract_stage_one_ingredients(self, _url):
                return []

            def structure_recipe(self, **_kwargs):
                raise AssertionError("V2 catalog must block Stage 2")

        with (
            patch.object(pipeline, "read_urls", return_value=[("abc123", "https://youtu.be/abc123")]),
            patch.object(pipeline, "GeminiClient", return_value=FakeClient()),
            patch.object(pipeline.time, "sleep", side_effect=StopLoop) as sleep,
        ):
            with self.assertRaises(StopLoop):
                pipeline.run("test-model")
        self.assertEqual(sleep.call_args.args[0], max(1, pipeline.POLL_SECONDS))
        self.assertEqual(state.load_video("abc123")["status"], "WAITING_CATALOG")

    def test_future_retry_checkpoint_skips_api_until_due(self):
        from datetime import timedelta

        retry_at = (datetime.now(timezone.utc) + timedelta(hours=1)).isoformat()
        state.save_video({
            "videoId": "abc123", "status": "WAITING_RETRY", "sourceUrl": "https://youtu.be/abc123",
            "stages": {"stage1": {"status": "WAITING_RETRY", "retryAt": retry_at, "retryCount": 1}},
        })

        class FakeClient:
            def extract_stage_one_ingredients(self, _url):
                raise AssertionError("A future retry checkpoint must not call Gemini")

        self.assertEqual(
            pipeline.process_video("abc123", "https://youtu.be/abc123", FakeClient(), "test-model"),
            "WAITING_RETRY",
        )

    def test_validator_keeps_unresolved_mapping_as_nonfatal_draft(self):
        stage_one = {"ingredients": [{"sourceId": "one", "displayName": "간장", "rawText": "간장", "amount": None, "unit": None}]}
        result = {
            "recipe": {
                "key": "sauce", "name": "소스", "status": "DRAFT", "shortsReference": "https://youtu.be/x",
                "ingredients": [{"key": "water", "variant": None, "acceptedOwnedVariants": [], "sourceId": "one", "displayName": "간장", "rawText": "간장", "amount": None, "unit": None, "optional": False}],
                "requirements": [{"options": [{"ingredient": "water", "substitutes": [], "allowedVariants": []}]}],
                "steps": ["섞는다."],
            },
            "mappingFailures": [{"sourceId": "one", "code": "VARIANT_MAPPING_FAILED"}],
        }
        errors = validate_draft(stage_one, result, {"ingredients": [{"key": "soy-sauce", "variants": [{"key": "dark-soy-sauce"}]}]})
        self.assertEqual(errors, [])


if __name__ == "__main__":
    unittest.main()
