import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from collection import Row, Taxonomy, Yield, distribution, makeable, over_target, plan


def _row(video_id, dish, stage="published", channel="채널A", channel_id="UCa"):
    return Row(video_id, channel, channel_id, "manual", None, None, dish, "name", stage, None)


class TaxonomyTests(unittest.TestCase):
    def setUp(self):
        self.taxonomy = Taxonomy.load()

    def test_rice_dishes_win_over_other_words(self):
        cases = {"김치볶음밥": "RICE", "계란카레밥": "RICE", "부타동": "RICE", "오므라이스": "RICE",
                 "알리오올리오": "NOODLE", "간장비빔국수": "NOODLE", "김치찌개": "STEW", "계란 만둣국": "SOUP",
                 "순살닭볶음탕": "GRILL_BRAISE_STEAM", "두부계란찜": "EGG", "간장우동": "NOODLE", "규동 #shorts": "RICE", "한국인의 감자전": "PANCAKE_FRIED", "고구마 맛탕": "OTHER", "삼겹살 제육 레시피": "STIR_FRY_SIDE", "밥 한공기 뚝딱 어묵볶음 #shorts": "STIR_FRY_SIDE", "제육볶음": "STIR_FRY_SIDE",
                 "치킨카레": "CURRY", "계란말이": "EGG", "감자전": "PANCAKE_FRIED", "에그토스트": "BREAD",
                 "오이무침": "SALAD", "참치맛나니": "STIR_FRY_SIDE", "바나나 요거트": "OTHER"}
        for name, code in cases.items():
            self.assertEqual(self.taxonomy.classify_name(name), code, name)

    def test_gemini_type_and_override_take_precedence(self):
        self.assertEqual(self.taxonomy.classify("v", "김치볶음밥", "STIR_FRY_SIDE"), ("STIR_FRY_SIDE", "gemini"))
        self.assertEqual(self.taxonomy.classify("v", "김치볶음밥", "NOT_A_TYPE"), ("RICE", "name"))

    def test_over_target_types_are_blocked(self):
        rows = [_row(str(i), "RICE") for i in range(6)] + [_row("s1", "SOUP"), _row("s2", "STEW")] + \
               [_row(f"n{i}", "NOODLE") for i in range(2)]
        self.assertIn("RICE", over_target(rows, self.taxonomy))
        self.assertNotIn("SOUP", over_target(rows, self.taxonomy))
        shares = {d["code"]: d["share"] for d in distribution(rows, self.taxonomy)}
        self.assertAlmostEqual(shares["RICE"], 60)


class PlanTests(unittest.TestCase):
    def setUp(self):
        self.taxonomy = Taxonomy.load()

    def rows(self):
        rows = []
        for i in range(20):  # proven channel, 50% yield on a type that is still collected
            dish = ("SOUP", "STEW", "GRILL_BRAISE_STEAM", "STIR_FRY_SIDE")[i % 4]
            rows.append(_row(f"a{i}", dish, "published" if i % 2 else "extracted"))
        for i in range(60):  # rice-only channel: its yield must not count once rice is over target
            rows.append(_row(f"r{i}", "RICE", "published", channel="채널R", channel_id="UCr"))
        for i in range(3):  # small sample, 100% yield: must not count as proven
            rows.append(_row(f"b{i}", "NOODLE", "published", channel="채널B", channel_id="UCb"))
        return rows

    def test_budget_is_fully_spent_and_split(self):
        result = plan(self.rows(), self.taxonomy, 40, {})
        spent = sum(e["calls"] for e in result["exploit"]) + sum(e["calls"] for e in result["exploreTypes"]) \
            + result["exploreNewChannels"]
        self.assertEqual(spent, 40)
        self.assertEqual([e["channelId"] for e in result["exploit"]], ["UCa"])

    def test_one_channel_cannot_take_the_whole_exploit_budget(self):
        result = plan(self.rows(), self.taxonomy, 40, {})
        self.assertLessEqual(result["exploit"][0]["calls"], 10)

    def test_small_samples_are_pulled_to_the_middle(self):
        self.assertLess(Yield("x", 2, 2).expected, Yield("y", 40, 30).expected)


class MakeableTests(unittest.TestCase):
    def test_accepted_allowed_and_substitutes_count(self):
        recipe = {"ingredients": [{"key": "soy", "variant": None, "acceptedOwnedVariants": ["dark", "brewed"]},
                                  {"key": "egg", "variant": "egg"}, {"key": "duck", "variant": "duck"}],
                  "requirements": [{"options": [{"ingredient": "soy"}]},
                                   {"options": [{"ingredient": "egg", "substitutes": ["duck"]}]}]}
        self.assertTrue(makeable(recipe, {"brewed", "duck"}))
        self.assertFalse(makeable(recipe, {"egg"}))


if __name__ == "__main__":
    unittest.main()
