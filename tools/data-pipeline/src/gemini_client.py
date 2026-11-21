import json
import os



RECIPE_SOURCE_PROMPT = """
Watch the supplied Korean cooking video and extract its recipe source facts in
one response. The response will be used later by a separate data agent to map
ingredients into an app catalog, so do not use or assume any ingredient catalog.

Extract the recipe title, every ingredient used or explicitly mentioned,
quantities and units when stated, whether an ingredient is optional, the
cooking steps in order, and source evidence for ingredients and steps. Preserve
the wording and specificity from the video. Do not normalize an ingredient to
an owned-item category, infer unstated quantities, or invent facts. If something
cannot be determined, use null or record it in unresolved. Include timestamps
when available; do not fabricate them. The user trusts this extraction as the
source of truth, so be comprehensive and precise.

Return JSON only, with this shape:
{
  "title": "string",
  "description": "string|null",
  "servings": "string|null",
  "ingredients": [{
    "rawText": "string",
    "displayName": "string",
    "amount": "string|null",
    "unit": "string|null",
    "optional": false,
    "evidences": [{
      "type": "SPEECH|SUBTITLE|ON_SCREEN_TEXT|VISUAL_ACTION",
      "text": "string",
      "timestamp": "string|null"
    }]
  }],
  "steps": [{
    "text": "string",
    "evidences": [{
      "type": "SPEECH|SUBTITLE|ON_SCREEN_TEXT|VISUAL_ACTION",
      "text": "string",
      "timestamp": "string|null"
    }]
  }],
  "unresolved": ["string"]
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


class GeminiClient:
    def __init__(self, model: str, api_key: str | None = None) -> None:
        from google import genai
        from google.genai import types

        api_key = api_key or os.environ.get("GEMINI_API_KEY")
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY is required")
        # 응답이 끊긴 요청이 계정 하나를 무한정 붙잡지 않도록 시간 제한을 둔다. 초과하면 일시 오류로 재시도한다.
        timeout_seconds = float(os.environ.get("GEMINI_REQUEST_TIMEOUT_SECONDS", "180"))
        self._client = genai.Client(
            api_key=api_key,
            http_options=types.HttpOptions(timeout=int(timeout_seconds * 1000)),
        )
        self._model = model

    def extract_recipe_source(self, source_url: str, video_id: str) -> tuple[dict, str]:
        from google.genai import types

        prompt = "\n".join((RECIPE_SOURCE_PROMPT, f"Video ID: {video_id}", f"Source URL: {source_url}"))
        response = self._client.models.generate_content(
            model=self._model,
            contents=[
                prompt,
                types.Part.from_uri(file_uri=source_url, mime_type="video/mp4"),
            ],
            config=types.GenerateContentConfig(response_mime_type="application/json"),
        )
        raw_response = response.text or ""
        payload = json.loads(_strip_json_fence(raw_response))
        if not isinstance(payload, dict):
            raise ValueError("Gemini response must be a JSON object")
        return payload, raw_response
