## 흐름
```plain text
Source
→ Stage 1 Ingredient Extraction
→ Human Review / Approve
→ Stage 2 Recipe Structuring
   + approved ingredients
   + ingredients.json
   + source
→ Deterministic Validator
→ Final Recipe JSON
```
## Stage 1
목표는 소스에 실제로 등장한 재료를 추출하는 것이다.
```json
{
  "ingredients": [
    {
      "sourceId": "ingredient-1",
      "displayName": "마늘",
      "rawText": "마늘 3알",
      "amount": "3",
      "unit": "알",
      "evidences": [
        {
          "type": "SPEECH",
          "text": "마늘 세 알 넣어줄게요",
          "timestamp": "00:23"
        }
      ]
    }
  ]
}
```
Evidence type: SPEECH / SUBTITLE / ON_SCREEN_TEXT / VISUAL_ACTION.
실제로 없는 timestamp를 만들지 않는다.
## Stage 2
Stage 1에서 승인된 재료의 의미와 관계를 구조화한다.
Stage 2는 Stage 1 재료를 추가/삭제/변경할 수 없다.
불변 필드:
- sourceId
- displayName
- rawText
- amount
- unit
AI는 `ingredients.json`을 수정하지 않는다.
Mapping:
- 가장 의미적으로 정확한 기존 Variant에 매핑
- 문자열 exact match는 필수 아님
- 형태 차이를 canonical base로 뭉개지 않음
- Variant Relation은 mapping 용도로 사용하지 않음
- Ingredient 없음 → INGREDIENT_MAPPING_FAILED
- 필요한 Variant 없음 → VARIANT_MAPPING_FAILED
- 불확실 → 실패
Semantic evidence:
- Optional: source가 명시한 경우만
- OR: 동등 대안이 source에 명시된 경우만
- Substitute: 방향성 있는 fallback이 source에 명시된 경우만
- Allowed Variant: 실제 조리 과정이 original을 기존 Variant 의미로 명확히 변환하며 해당 Variant를 그대로 사용할 수 있을 때만
Stage 2가 master 부족으로 실패하면 사람이 master update를 결정한 뒤 다시 실행한다.
## Validator
AI output 이후 deterministic validator가 Dataset schema, key/ref, sourceId bijection, immutable fields, optional/requirement 규칙, PUBLISHED mapping completeness, allowed variant 규칙 등을 검증한다.
sourceId는 검증 후 final Recipe JSON에서 제거한다.

