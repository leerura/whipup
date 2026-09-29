import json
import os

from google import genai
from google.genai import types

# TODO: Move prompts into external files when prompt versioning becomes necessary.
INGREDIENT_STAGE_ONE_PROMPT = """
You are performing Stage 1 ingredient extraction from a Korean YouTube Shorts cooking video.

Rules:
- Extract only ingredients directly visible or explicitly mentioned in the video.
- Do not guess missing ingredients.
- Preserve the original cooking expression as much as possible.
- Do not canonicalize, map, add, or remove ingredients.
- If amount or unit is unclear, use null.
- Do not invent evidence or a timestamp that is not observable in the video.
- Return JSON only.

Schema:
{
  "ingredients": [
    {
      "rawText": string,
      "displayName": string,
      "amount": string | null,
      "unit": string | null,
      "evidences": [
        {
          "type": "SPEECH" | "SUBTITLE" | "ON_SCREEN_TEXT" | "VISUAL_ACTION",
          "text": string,
          "timestamp": string | null
        }
      ]
    }
  ]
}
"""

RECIPE_STAGE_TWO_PROMPT = """
You are structuring a Korean cooking video into a V2 Recipe Dataset draft.

Rules:
- Extract only information that is visible or explicitly mentioned in the video.
- Use every supplied approved Stage 1 ingredient exactly once. Do not add, remove,
  split, merge, or alter sourceId, displayName, rawText, amount, or unit.
- Map only to supplied IngredientVariant keys. Exact text equality is not required.
- Never use Ingredient Variant Relations as mapping permission.
- When no exact semantic mapping exists or confidence is insufficient, set variant
  to null and add a mappingFailures entry with INGREDIENT_MAPPING_FAILED or
  VARIANT_MAPPING_FAILED.
- Optional, OR, Substitute, and Allowed Variant declarations require explicit
  source evidence. A Substitute is directional and is not an OR option.
- Every non-optional Recipe Ingredient must participate exactly once in an
  Option or Substitute role. When no OR or Substitute evidence exists, create
  one Single Requirement with that Ingredient as its only Option.
- Use lowercase ASCII kebab-case for the Recipe key.
- Write recipe name, user-facing ingredient text, and recipe steps in Korean.
- Do not create Ingredients, Variants, or master changes.
- If a video does not reveal a value, leave it null or empty instead of guessing.
- Return JSON only.

Recipe key rule:
- Create a stable lowercase key from the recipe name and video id.
- Use kebab-case ASCII when possible.
- If Korean romanization is uncertain, use "recipe-{videoId}".

Schema:
{
  "recipe": {
    "key": string,
    "name": string,
    "status": "DRAFT",
    "ingredients": [
      {
        "sourceId": string,
        "key": string,
        "variant": string | null,
        "displayName": string,
        "rawText": string,
        "amount": string | null,
        "unit": string | null,
        "optional": boolean
      }
    ],
    "requirements": [
      {
        "options": [
          {
            "ingredient": string,
            "substitutes": [string],
            "allowedVariants": [string]
          }
        ]
      }
    ],
    "steps": [string]
  },
  "mappingFailures": [
    {
      "sourceId": string,
      "code": "INGREDIENT_MAPPING_FAILED" | "VARIANT_MAPPING_FAILED",
      "message": string
    }
  ]
}
"""


def _stage_two_recipe_prompt(
    video_id: str,
    approved_ingredients: list[dict],
    ingredient_master: dict,
) -> str:
    approved = json.dumps(approved_ingredients, ensure_ascii=False, indent=2)
    master = json.dumps(ingredient_master, ensure_ascii=False, indent=2)
    return f"""
{RECIPE_STAGE_TWO_PROMPT}

Video ID:
{video_id}

Approved Stage 1 ingredients:
{approved}

Immutable Ingredient/Variant master:
{master}
"""


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


def _parse_json_response(text: str) -> dict:
    return json.loads(_strip_json_fence(text))


class GeminiClient:
    def __init__(self, model: str) -> None:
        api_key = os.environ.get("GEMINI_API_KEY")
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY is required")

        self._client = genai.Client(api_key=api_key)
        self._model = model

    def extract_stage_one_ingredients(self, source_url: str) -> list[dict]:
        response = self._client.models.generate_content(
            model=self._model,
            contents=[
                INGREDIENT_STAGE_ONE_PROMPT,
                types.Part.from_uri(file_uri=source_url, mime_type="video/mp4"),
            ],
            config=types.GenerateContentConfig(response_mime_type="application/json"),
        )

        payload = _parse_json_response(response.text or "")
        return payload.get("ingredients", [])

    def structure_recipe(
        self,
        source_url: str,
        video_id: str,
        approved_ingredients: list[dict],
        ingredient_master: dict,
    ) -> dict:
        response = self._client.models.generate_content(
            model=self._model,
            contents=[
                _stage_two_recipe_prompt(
                    video_id,
                    approved_ingredients,
                    ingredient_master,
                ),
                types.Part.from_uri(file_uri=source_url, mime_type="video/mp4"),
            ],
            config=types.GenerateContentConfig(response_mime_type="application/json"),
        )

        return _parse_json_response(response.text or "")
