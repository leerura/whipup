import json
import os

from google import genai
from google.genai import types


PROMPT = """
You are extracting ingredient expressions from a Korean YouTube Shorts cooking video.

Rules:
- Extract only ingredients directly visible or explicitly mentioned in the video.
- Do not guess missing ingredients.
- Preserve the original cooking expression as much as possible.
- Do not canonicalize ingredients.
- If amount or unit is unclear, use null.
- Return JSON only.

Schema:
{
  "ingredients": [
    {
      "rawText": string,
      "displayName": string,
      "amount": string | null,
      "unit": string | null
    }
  ]
}
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

    def extract_ingredients(self, source_url: str) -> list[dict]:
        response = self._client.models.generate_content(
            model=self._model,
            contents=[
                PROMPT,
                types.Part.from_uri(file_uri=source_url, mime_type="video/mp4"),
            ],
            config=types.GenerateContentConfig(response_mime_type="application/json"),
        )

        payload = _parse_json_response(response.text or "")
        return payload.get("ingredients", [])
