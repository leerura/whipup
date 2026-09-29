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

RECIPE_PROMPT = """
You are extracting a recipe from a Korean YouTube Shorts cooking video.

Rules:
- Extract only recipe information that is visible or explicitly mentioned in the video.
- Do not invent missing ingredients or cooking steps.
- Use only the provided canonical ingredient master for canonicalIngredient.
- The only valid canonicalIngredient values are the names listed under Canonical ingredient master.
- canonicalIngredient must exactly match one of the provided canonical ingredient names.
- If a video ingredient cannot be mapped to the provided master, set canonicalIngredient to null and mappingStatus to "UNMAPPED".
- Do not create new canonical ingredients.
- Preserve the original expression in displayName and rawText.
- If amount or unit is unclear, use null.
- Keep ingredient and step order as shown in the video.
- Return JSON only.

Recipe key rule:
- Create a stable lowercase key from the recipe name and video id.
- Use kebab-case ASCII when possible.
- If Korean romanization is uncertain, use "recipe-{videoId}".

Schema:
{
  "key": string,
  "name": string,
  "ingredients": [
    {
      "canonicalIngredient": string | null,
      "displayName": string,
      "rawText": string,
      "amount": string | null,
      "unit": string | null,
      "mappingStatus": "MAPPED" | "UNMAPPED"
    }
  ],
  "steps": [string]
}
"""


def _recipe_prompt(video_id: str, ingredient_master: list[str]) -> str:
    master = "\n".join(f"- {name}" for name in ingredient_master)
    return f"""
{RECIPE_PROMPT}

Video ID:
{video_id}

Canonical ingredient master:
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

    def extract_recipe(
        self,
        source_url: str,
        video_id: str,
        ingredient_master: list[str],
    ) -> dict:
        response = self._client.models.generate_content(
            model=self._model,
            contents=[
                _recipe_prompt(video_id, ingredient_master),
                types.Part.from_uri(file_uri=source_url, mime_type="video/mp4"),
            ],
            config=types.GenerateContentConfig(response_mime_type="application/json"),
        )

        return _parse_json_response(response.text or "")
