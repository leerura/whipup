import json
import sys
import tempfile
import unittest
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from apply import PUBLISH, REVIEW, SKIP, WAIT_MASTER, build, check_video, evaluate_draft, fill_draft, recipe_key, unlock_ranking
from recipe_rules import (Catalog, check_rules, is_foreign_unit, is_group_name, load_rules, near_catalog_name, normalize_unit, plain_short_name, resolve,
                          split_alternatives, strip_english, validate_recipe)


def _write(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")


def _variant(key, name, aliases=()):
    return {"key": key, "name": name, "aliases": list(aliases)}


def _fixture(root: Path) -> tuple[Path, Path]:
    data, rules = root / "data", root / "rules"
    _write(data / "ingredients.json", {"ingredients": [
        {"key": "soy", "name": "간장", "variants": [_variant("dark-soy", "진간장"), _variant("brewed-soy", "양조간장")], "relations": []},
        {"key": "oil", "name": "들기름", "variants": [_variant("perilla-oil", "들기름")], "relations": []},
        {"key": "sesame", "name": "참기름", "variants": [_variant("sesame-oil", "참기름")], "relations": []},
        {"key": "chili", "name": "고추", "variants": [_variant("chili-item", "고추")], "relations": []},
        {"key": "egg", "name": "계란", "variants": [_variant("egg-item", "계란", ["달걀"])], "relations": []},
        {"key": "rice", "name": "밥", "variants": [_variant("rice-item", "밥")], "relations": []},
        {"key": "onion", "name": "양파", "variants": [_variant("onion-item", "양파")], "relations": []},
    ]})
    _write(data / "recipes" / "a.json", {"status": "PUBLISHED", "ingredients": [
        {"displayName": "간장", "variant": None, "acceptedOwnedVariants": ["dark-soy", "brewed-soy"]}]})
    _write(rules / "aliases.json", {"aliases": {"청양고추": "고추", "햇반": "밥"}})
    _write(rules / "policy.json", {"unitAliases": {"spoon": "스푼"}, "excludedIngredientWords": {"words": ["떡"]},
                                   "derivedIngredientWords": {"words": ["면수"]}, "minRequiredIngredients": 4,
                                   "maxNameLength": 9})
    _write(rules / "names.json", {"names": {"named000001": "간장계란밥"}})
    _write(rules / "recipe-mappings.json", {"recipes": {"decided0001": {"soy2": {
        "acceptedOwnedVariants": ["dark-soy", "brewed-soy"], "reason": "양념장 간장"}}}})
    _write(rules / "exclusions.json", {"videos": {"excluded0001": {"category": "USER_REMOVED"}}})
    return data, rules


def _ingredient(source_id, display, optional=False, raw=None):
    return {"sourceId": source_id, "rawText": raw or display, "displayName": display, "amount": None, "unit": None,
            "optional": optional, "evidences": [{"type": "AUDIO", "startSeconds": 1, "endSeconds": 2}]}


def _state(ingredients, title="간장계란밥", steps=("팬에 계란을 굽는다.",), checks=True, meta=True):
    state = {"status": "EXTRACTION_READY", "extraction": {"result": {
        "title": title, "ingredients": ingredients, "unresolved": [],
        "steps": [{"text": text, "evidences": [{"type": "AUDIO", "startSeconds": 1, "endSeconds": 2}]} for text in steps]}}}
    if checks:
        state["applyChecks"] = {"short": True, "embeddable": True}
    if meta:
        state["sourceMetadata"] = {"sourceChannelName": "채널", "sourceChannelThumbnailUrl": "https://yt3.example/a"}
    return state


FOUR = [_ingredient("egg", "계란"), _ingredient("rice", "햇반"), _ingredient("soy", "진간장"), _ingredient("onion", "양파")]


class Base(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        data, rules = _fixture(Path(self.tmp.name))
        self.rules = load_rules(rules)
        self.catalog = Catalog.load(data)

    def tearDown(self):
        self.tmp.cleanup()

    def build(self, state, video_id="new00000001", taken=None, names=None):
        return build(video_id, state, self.rules, self.catalog, taken or {}, names or Counter())


class ResolveTests(Base):
    def test_exact_catalog_name_and_catalog_alias(self):
        self.assertEqual(resolve("진간장", self.rules, self.catalog).variant, "dark-soy")
        self.assertEqual(resolve("달걀", self.rules, self.catalog).variant, "egg-item")

    def test_reviewed_alias_maps_to_catalog_name(self):
        mapping = resolve("청양고추", self.rules, self.catalog)
        self.assertEqual((mapping.variant, mapping.via), ("chili-item", "alias"))

    def test_group_name_is_unresolved_even_if_a_published_recipe_mapped_it(self):
        # data/recipes/a.json maps 간장 to two kinds; that per-recipe choice must not spread.
        self.assertIsNone(resolve("간장", self.rules, self.catalog))
        self.assertTrue(is_group_name("간장", self.catalog))

    def test_near_catalog_name_is_only_a_hint(self):
        self.assertEqual(near_catalog_name("노른자", self.catalog), None)
        self.assertEqual(near_catalog_name("굵은 양파", self.catalog), "양파")
        self.assertIsNone(resolve("굵은 양파", self.rules, self.catalog))

    def test_same_group_alternative_becomes_allowed_variant(self):
        mapping = resolve("양조간장 (또는 진간장)", self.rules, self.catalog)
        self.assertEqual((mapping.variant, mapping.allowed, mapping.accepted, mapping.via),
                         ("brewed-soy", ("dark-soy",), (), "alternative"))

    def test_other_group_alternative_becomes_accepted_variant(self):
        mapping = resolve("들기름 또는 참기름", self.rules, self.catalog)
        self.assertEqual((mapping.variant, mapping.accepted), ("perilla-oil", ("sesame-oil",)))

    def test_alternative_with_unknown_option_is_unresolved(self):
        self.assertIsNone(resolve("고추 또는 피망", self.rules, self.catalog))

    def test_alias_targets_must_exist(self):
        self.assertEqual(check_rules(self.rules, self.catalog), [])


class BuildTests(Base):
    def test_clear_case_is_published_and_valid(self):
        outcome = self.build(_state(FOUR))
        self.assertEqual(outcome.outcome, PUBLISH, outcome.reasons)
        self.assertEqual(outcome.recipe["status"], "PUBLISHED")
        self.assertEqual(validate_recipe(outcome.recipe, self.catalog), [])

    def test_unknown_required_ingredient_waits_for_master_as_draft(self):
        outcome = self.build(_state(FOUR + [_ingredient("truffle", "트러플오일")]))
        self.assertEqual(outcome.outcome, WAIT_MASTER, outcome.reasons)
        self.assertEqual(outcome.recipe["status"], "DRAFT")
        self.assertEqual(outcome.unresolved, ["트러플오일"])

    def test_excluded_video_and_policy_word_are_skipped(self):
        self.assertEqual(self.build(_state(FOUR), video_id="excluded0001").outcome, SKIP)
        self.assertEqual(self.build(_state(FOUR + [_ingredient("tteok", "떡볶이 떡")])).outcome, SKIP)

    def test_missing_checks_metadata_or_name_go_to_review(self):
        self.assertEqual(self.build(_state(FOUR, checks=False)).outcome, REVIEW)
        self.assertEqual(self.build(_state(FOUR, meta=False)).outcome, REVIEW)
        self.assertEqual(self.build(_state(FOUR, title="3분이면 끝나는 존맛 간장계란밥!")).outcome, REVIEW)
        approved = self.build(_state(FOUR, title="3분이면 끝나는 존맛 간장계란밥!"), video_id="named000001")
        self.assertEqual((approved.outcome, approved.recipe["name"]), (PUBLISH, "간장계란밥"))

    def test_quality_flags_go_to_review(self):
        self.assertEqual(self.build(_state(FOUR[:3])).outcome, REVIEW)
        self.assertEqual(self.build(_state(FOUR, steps=("그릇에 담아 섞는다.",))).outcome, REVIEW)
        self.assertEqual(self.build(_state(FOUR), names=Counter({"간장계란밥": 2})).outcome, REVIEW)

    def test_alternatives_and_group_names_go_to_review(self):
        alternative = FOUR + [_ingredient("oil", "들기름 또는 참기름")]
        self.assertEqual(self.build(_state(alternative)).outcome, REVIEW)
        raw_only = FOUR[:3] + [_ingredient("oil", "들기름", raw="들기름/참기름 약간")]
        self.assertEqual(self.build(_state(raw_only)).outcome, REVIEW)
        self.assertEqual(self.build(_state(FOUR + [_ingredient("soy2", "간장")])).outcome, REVIEW)

    def test_fraction_is_not_an_alternative(self):
        halves = FOUR[:3] + [_ingredient("onion", "양파", raw="양파 1/2개")]
        self.assertEqual(self.build(_state(halves)).outcome, PUBLISH)

    def test_unresolved_alternative_goes_to_review_and_policy_word_in_alternative_is_not_skipped(self):
        self.assertEqual(self.build(_state(FOUR + [_ingredient("chili2", "고추 또는 피망")])).outcome, REVIEW)
        self.assertEqual(self.build(_state(FOUR + [_ingredient("noodle", "떡 또는 소면")])).outcome, REVIEW)

    def test_gemini_uncertainty_near_match_and_english_unit_go_to_review(self):
        unsure = _state(FOUR)
        unsure["extraction"]["result"]["unresolved"] = ["기름 종류를 알 수 없음"]
        self.assertEqual(self.build(unsure).outcome, REVIEW)
        self.assertEqual(self.build(_state(FOUR + [_ingredient("onion2", "굵은 양파")])).outcome, REVIEW)
        cup = [dict(FOUR[0], unit="cup")] + FOUR[1:]
        self.assertEqual(self.build(_state(cup)).outcome, REVIEW)

    def test_quantity_only_gemini_note_does_not_block(self):
        unsure = _state(FOUR)
        unsure["extraction"]["result"]["unresolved"] = ["양파, 후추, 밥의 계량 수치는 명시되지 않음"]
        self.assertEqual(self.build(unsure).outcome, PUBLISH)
        for note in ("팬에 두르는 기름의 정확한 양과 종류는 언급되지 않음", "샤브용 고기의 부위 및 정확한 중량은 언급되지 않음",
                     "소스에 식초 대신 레몬즙을 사용할 수 있다고 언급됨", "통깨 사용 여부가 언급되지 않음"):
            unsure["extraction"]["result"]["unresolved"] = [note]
            self.assertEqual(self.build(unsure).outcome, REVIEW, note)

    def test_approved_decision_resolves_group_name_for_that_recipe_only(self):
        with_soy = _state(FOUR + [_ingredient("soy2", "간장")])
        decided_outcome = self.build(with_soy, video_id="decided0001")
        self.assertEqual(decided_outcome.outcome, PUBLISH, decided_outcome.reasons)
        self.assertEqual(decided_outcome.recipe["ingredients"][-1]["acceptedOwnedVariants"], ["dark-soy", "brewed-soy"])
        self.assertEqual(self.build(with_soy, video_id="other000001").outcome, REVIEW)

    def test_decision_needs_known_variants_and_reason(self):
        self.rules.decisions["bad"] = {"x": {"acceptedOwnedVariants": ["nope"]}}
        errors = check_rules(self.rules, self.catalog)
        self.assertTrue(any("unknown variant" in e for e in errors) and any("reason" in e for e in errors))

    def test_deleted_video_is_skipped(self):
        outcome = build("gone0000001", _state(FOUR), self.rules, self.catalog, {}, Counter(), {"gone0000001": "abc1234"})
        self.assertEqual(outcome.outcome, SKIP)

    def test_derived_item_becomes_optional(self):
        outcome = self.build(_state(FOUR + [_ingredient("water", "면수")]))
        self.assertEqual(outcome.outcome, PUBLISH, outcome.reasons)
        self.assertTrue(outcome.recipe["ingredients"][-1]["optional"])

    def test_key_collision_goes_to_review(self):
        taken = {recipe_key("Abc_defghij"): "abc-defghij"}
        self.assertEqual(self.build(_state(FOUR), video_id="Abc_defghij", taken=taken).outcome, REVIEW)


class DraftTests(Base):
    def test_fill_keeps_existing_mappings_and_publishes_when_complete(self):
        draft = {"key": "video-x", "name": "볶음밥", "status": "DRAFT", "shortsReference": "https://www.youtube.com/shorts/x",
                 "ingredients": [
                     {"key": "soy", "variant": None, "acceptedOwnedVariants": ["dark-soy", "brewed-soy"], "displayName": "간장",
                      "rawText": "간장", "amount": None, "unit": None, "optional": False},
                     {"key": "rice", "variant": None, "acceptedOwnedVariants": [], "displayName": "햇반", "rawText": "햇반",
                      "amount": None, "unit": None, "optional": False}],
                 "requirements": [{"options": [{"ingredient": "soy", "substitutes": [], "allowedVariants": []}]}],
                 "steps": ["볶는다."]}
        updated, filled, unresolved = fill_draft(draft, self.rules, self.catalog)
        self.assertEqual((filled, unresolved, updated["status"]), (["햇반→밥"], [], "PUBLISHED"))
        self.assertEqual(updated["ingredients"][1]["displayName"], "밥")
        self.assertEqual(updated["ingredients"][0]["acceptedOwnedVariants"], ["dark-soy", "brewed-soy"])
        self.assertEqual(validate_recipe(updated, self.catalog), [])
        self.assertEqual(draft["status"], "DRAFT")

    def test_promotion_needs_the_same_checks_as_new_recipes(self):
        draft = {"key": "video-x", "name": "볶음밥", "status": "DRAFT", "shortsReference": "https://www.youtube.com/shorts/x",
                 "sourceChannelName": "채널", "sourceChannelThumbnailUrl": "https://yt3.example/a",
                 "ingredients": [dict(key=i["sourceId"], variant=None, acceptedOwnedVariants=[], displayName=i["displayName"],
                                      rawText=i["rawText"], amount=None, unit=None, optional=False) for i in FOUR],
                 "requirements": [], "steps": ["팬에 볶는다."]}
        self.assertTrue(evaluate_draft("x", draft, _state(FOUR), self.rules, self.catalog).ready)
        self.assertFalse(evaluate_draft("x", draft, _state(FOUR, checks=False), self.rules, self.catalog).ready)
        self.assertFalse(evaluate_draft("x", draft, None, self.rules, self.catalog).ready)
        unsure = _state(FOUR)
        unsure["extraction"]["result"]["unresolved"] = ["기름 종류를 알 수 없음"]
        self.assertFalse(evaluate_draft("x", draft, unsure, self.rules, self.catalog).ready)

    def test_unlock_ranking_counts_sole_blockers(self):
        ranking = unlock_ranking([["두반장"], ["두반장", "청경채"], ["청경채"]])
        self.assertEqual(ranking, [("두반장", 1, 2), ("청경채", 1, 2)])


class FetchTests(unittest.TestCase):
    def test_unknown_answers_are_not_recorded(self):
        checks, meta = check_video("v", {}, {}, lambda _: None, lambda _: self.fail("no metadata without checks"))
        self.assertEqual((checks, meta), ({}, {}))

    def test_known_answers_are_kept_and_not_asked_again(self):
        checks, _ = check_video("v", {"short": False}, {}, lambda _: self.fail("asked again"), lambda _: {})
        self.assertEqual(checks, {"short": False})


class HelperTests(Base):
    def test_strip_english_and_split(self):
        self.assertEqual(strip_english("마늘 (Garlic)"), "마늘")
        self.assertEqual(split_alternatives("소면 (또는 메밀국수)"), ["소면", "메밀국수"])
        self.assertIsNone(split_alternatives("양념장"))

    def test_unit_alias_and_plain_name(self):
        self.assertEqual(normalize_unit("spoon", self.rules), "스푼")
        self.assertEqual(normalize_unit("g", self.rules), "g")
        self.assertIsNone(normalize_unit(None, self.rules))
        self.assertEqual(normalize_unit("스푼 (spoons)", self.rules), "스푼")
        self.assertTrue(is_foreign_unit("cup"))
        self.assertFalse(is_foreign_unit("g") or is_foreign_unit("스푼") or is_foreign_unit(None))
        self.assertEqual(plain_short_name("훈제오리 덮밥", self.rules), "훈제오리 덮밥")
        self.assertIsNone(plain_short_name("초간단 #shorts", self.rules))

    def test_validator_rejects_object_steps_and_published_gaps(self):
        recipe = {"key": "video-x", "name": "x", "status": "PUBLISHED", "shortsReference": "s", "requirements": [],
                  "ingredients": [{"key": "a", "variant": None, "acceptedOwnedVariants": [], "displayName": "a",
                                   "rawText": "a", "amount": None, "unit": None, "optional": False}],
                  "steps": [{"text": "볶는다"}]}
        errors = validate_recipe(recipe, self.catalog)
        self.assertTrue(any("steps" in e for e in errors))
        self.assertTrue(any("needs variant" in e for e in errors))


if __name__ == "__main__":
    unittest.main()
