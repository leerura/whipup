## Base Path
V2에서도 기존 API version을 유지한다.
```plain text
/api/v1
```
## Ingredient API
```javascript
GET    /api/v1/ingredients
GET    /api/v1/me/ingredients
POST   /api/v1/me/ingredients
DELETE /api/v1/me/ingredients/{userIngredientId}
```
사용자 API의 ingredient는 등록 가능한 보유 단위, 즉 IngredientVariant를 의미한다.
canonical Ingredient의 내부 ID/Domain 구조는 노출하지 않는다.
`GET /api/v1/ingredients`는 등록 가능한 전체 재료를 group 형태로 한 번에 반환한다. Server-side 검색 API는 두지 않는다. Flutter가 전체 응답을 대상으로 local filtering을 수행한다.
```json
{
  "groups": [
    {
      "name": "마늘",
      "items": [
        { "variantId": 17, "name": "마늘" },
        { "variantId": 18, "name": "다진 마늘" }
      ]
    }
  ]
}
```
등록:
```json
{ "variantId": 18 }
```
보유 조회:
```json
{
  "items": [
    {
      "userIngredientId": 101,
      "variantId": 18,
      "name": "다진 마늘"
    }
  ]
}
```
## Recommendation API
```javascript
GET /api/v1/recipes/recommendations?mode=AVAILABLE
GET /api/v1/recipes/recommendations?mode=MISSING_INGREDIENTS
```
- AVAILABLE: missingCount = 0
- MISSING_INGREDIENTS: missingCount \>= 1
- server pagination 없음
- AVAILABLE sort: recipeId ASC
- MISSING_INGREDIENTS sort: missingCount ASC, recipeId ASC
Recommendation Item:
```json
{
  "recipeId": 42,
  "name": "마늘 삼겹살 볶음",
  "thumbnailUrl": "...",
  "missingCount": 1,
  "requirementResults": []
}
```
RequirementResult는 status-specific shape을 사용한다.
SATISFIED:
```json
{
  "status": "SATISFIED",
  "matches": [
    {
      "type": "PREPARATION",
      "requiredName": "다진 마늘",
      "ownedName": "마늘"
    }
  ]
}
```
MISSING:
```json
{
  "status": "MISSING",
  "missingOptions": [
    {
      "requiredName": "알룰로스",
      "substitutes": [
        { "name": "설탕" }
      ]
    }
  ]
}
```
Match type:
- DIRECT
- PREPARATION
- SUBSTITUTE
Unsatisfied는 Match type이 아니다.
missingOptions는 Recipe가 선언한 Option/Substitute 구조만 반영한다. Allowed Variant와 Variant Relation은 구매 후보를 확장하지 않는다.
## Recipe Detail
```javascript
GET /api/v1/recipes/{recipeId}
```
V1에서 유지:
- recipeId
- name
- shortsReference
- thumbnailUrl
- missingCount
- steps
V1 `ingredients`는 V2에서 `requirements` + `optionalIngredients`로 대체한다.
```json
{
  "recipeId": 45,
  "name": "두부조림",
  "shortsReference": "...",
  "thumbnailUrl": "...",
  "missingCount": 1,
  "requirements": [],
  "optionalIngredients": [],
  "steps": [
    { "order": 1, "content": "두부를 먹기 좋은 크기로 썬다." }
  ]
}
```
Detail Option:
- displayName
- rawText
- amount
- unit
- substitutes
Substitute도 같은 display fields를 가진다. 원본에 amount/unit이 없으면 원재료에서 추론하지 않고 null이다.
Detail의 필수 재료 표시 단위는 Requirement다.
배열 순서가 표시 순서이며 displayOrder를 Flutter에 노출하지 않는다.
## Copy 책임
Server는 domain fact만 반환한다.
Flutter가 UX copy를 만든다.
Flutter는 API에 없는 의미나 preparation action을 추론하지 않는다.
## Unchanged
Auth, JWT, Health, error 기본 구조, YouTube Shorts thumbnail 방식은 기존 V1 계약을 유지한다.
