import json
import os

from google import genai
from google.genai import types


INGREDIENT_STAGE_ONE_PROMPT = """
Extract the ingredients directly visible or explicitly mentioned in this Korean
YouTube cooking video. Preserve each source expression and its evidence. Do not
guess missing ingredients, canonicalize names, or invent quantities/timestamps.
Use null for unclear amount or unit. Return JSON only:
{"ingredients":[{"rawText":"string","displayName":"string","amount":"string|null","unit":"string|null","evidences":[{"type":"SPEECH|SUBTITLE|ON_SCREEN_TEXT|VISUAL_ACTION","text":"string","timestamp":"string|null"}]}]}
"""


RECIPE_STAGE_TWO_PROMPT = """
Structure a Korean cooking video into a V3 recipe dataset draft.

Use only the supplied Stage 1 ingredient sources, exactly once each. Preserve
sourceId, rawText, displayName, amount, unit, and evidence exactly. Use the full
video and recipe context when deciding whether owned items can satisfy each
source ingredient. Do not turn a recipe-local judgment into a global rule.

Map an ingredient to an existing catalog group key and, when the exact owned
item is clear, its selectable variant key. A broad source expression may have
variant null and recipe-local acceptedOwnedVariants. If it cannot be resolved,
leave variant null and acceptedOwnedVariants empty; do not guess. Keep optional
ingredients outside requirements. Preserve evidence-backed OR options and
directional substitutes only when the source supports them.

If a required selectable owned item or group is absent from the supplied
catalog, propose it in catalogAdditions using the V3 catalog schema. Do not
pretend a proposal is already approved. The reviewing agent must check the
source video and the V3 user-owned-unit criteria before adding it.

Use a stable lowercase ASCII kebab-case recipe key (fallback:
recipe-{videoId}). Write user-facing recipe data in Korean. Set status to DRAFT.
Return JSON only:
{
  "recipe": {
    "key":"string", "name":"string", "status":"DRAFT",
    "shortsReference":"string",
    "ingredients":[{
      "key":"string", "variant":"string|null",
      "acceptedOwnedVariants":["string"], "sourceId":"string",
      "displayName":"string", "rawText":"string",
      "amount":"string|null", "unit":"string|null", "optional":false
    }],
    "requirements":[{"options":[{"ingredient":"string","substitutes":[],"allowedVariants":[]}]}],
    "steps":["string"]
  },
  "catalogAdditions":{"ingredients":[]},
  "mappingFailures":[]
}
"""


def _stage_two_prompt(video_id: str, source_url: str, ingredients: list[dict], catalog: dict) -> str:
    return "\n".join(
        (
            RECIPE_STAGE_TWO_PROMPT,
            f"Video ID: {video_id}",
            f"Source URL: {source_url}",
            "Stage 1 ingredients and evidence:",
            json.dumps(ingredients, ensure_ascii=False, indent=2),
            "Current V3 ingredient catalog:",
            json.dumps(catalog, ensure_ascii=False, indent=2),
        )
    )


def _strip_json_fence(text: str) -> str:
    value = text.strip()
    if not value.startswith("```"):
        return value
    lines = value.splitlines()
    if lines and lines[0].startswith("```"):
        lines = lines[1:]
    if lines and lines[-1].strip() == "```":
        lines = lines[:-1]
    return "\n".join(lines).strip()


class GeminiClient:
    def __init__(self, model: str) -> None:
        api_key = os.environ.get("GEMINI_API_KEY")
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY is required")
        self._client = genai.Client(api_key=api_key)
        self._model = model

    def _generate(self, prompt: str, source_url: str) -> dict:
        response = self._client.models.generate_content(
            model=self._model,
            contents=[
                prompt,
                types.Part.from_uri(file_uri=source_url, mime_type="video/mp4"),
            ],
            config=types.GenerateContentConfig(response_mime_type="application/json"),
        )
        payload = json.loads(_strip_json_fence(response.text or ""))
        if not isinstance(payload, dict):
            raise ValueError("Gemini response must be a JSON object")
        return payload

    def extract_stage_one_ingredients(self, source_url: str) -> list[dict]:
        payload = self._generate(INGREDIENT_STAGE_ONE_PROMPT, source_url)
        ingredients = payload.get("ingredients")
        if not isinstance(ingredients, list):
            raise ValueError("Stage 1 response must contain an ingredients array")
        return ingredients

    def structure_recipe(
        self,
        source_url: str,
        video_id: str,
        stage_one_ingredients: list[dict],
        ingredient_catalog: dict,
    ) -> dict:
        return self._generate(
            _stage_two_prompt(video_id, source_url, stage_one_ingredients, ingredient_catalog),
            source_url,
        )
