# V3 API 계약

이 API 계약은 [OpenAPI 파일](openapi.yaml)에 정의된 경로·필드·상태 코드를 보완해 도메인 의미를 명시한다. API base path와 JSON response shape는 기존 `/api/v1` 계약을 유지한다. 신규 accepted mapping은 서버 내부 판정 데이터이며 API 요청으로 직접 수정하지 않는다.

## 재료 목록 및 보유함

기존 경로를 유지한다.

```text
GET    /api/v1/ingredients
GET    /api/v1/me/ingredients
POST   /api/v1/me/ingredients
DELETE /api/v1/me/ingredients/{userIngredientId}
```

`GET /ingredients`의 `groups[].name`은 접고 펼치는 그룹 제목이고 `groups[].items[]`만 선택 가능한 보유 항목이다. `items[]`는 그룹당 하나 이상이며 V3에는 base/default 항목 의미가 없다. 동명 group/item은 가능하지만 각각 title과 selectable row로 구분한다.

`POST /me/ingredients`는 selectable `variantId` 하나를 등록하고, 동일 사용자가 동일 variant를 이미 보유하면 기존 중복 오류를 유지한다. 같은 group의 다른 variant는 동시에 보유 가능하다. DELETE는 해당 보유 row 하나를 제거한다. `GET /me/ingredients`는 실제 등록된 selectable item만 반환한다.

로그인 응답은 `hasOwnedIngredients`와 별도로 계정의 `onboardingCompleted` 상태를 반환한다. `hasOwnedIngredients`는 현재 보유 row 존재 여부이며, `onboardingCompleted`는 초기 재료 등록을 마쳤는지 나타낸다. 초기 재료 등록을 통한 첫 성공 `POST /me/ingredients`는 이 상태를 `true`로 만든다. 재료를 모두 삭제해도 완료 상태는 유지된다. 완료되지 않은 신규 사용자는 온보딩의 초기 재료 등록으로 보내고, 완료된 사용자가 보유 재료를 모두 삭제한 경우에는 빈 홈을 표시한다. 기존 계정은 이 계약 도입 시 완료 상태로 간주한다.

## 추천과 상세

기존 경로와 외부 response shape를 유지한다.

```text
GET /api/v1/recipes/recommendations?mode=AVAILABLE
GET /api/v1/recipes/recommendations?mode=MISSING_INGREDIENTS
GET /api/v1/recipes/{recipeId}
```

- `DRAFT`는 추천과 recipe detail endpoint에서 제외한다.
- 필수 Requirement는 AND, 그 안의 Options는 OR다. Optional source는 requirement result와 missingCount에서 빠진다.
- `missingCount`는 현재 사용자의 selectable inventory로 충족되지 않은 필수 Requirement 개수다.
- Recommendation의 `MISSING` 결과에서 `MissingOption.requiredName`은 카드에 표시할 간결한 부족 재료명이다. 해당 Option의 원본 ingredient에 exact `variant`가 있으면 selectable item의 이름을 사용하고, exact item이 없는 포괄 요구에는 source ingredient의 `displayName`을 사용한다. 카드에서 accepted 후보를 열거하지 않는다. Recipe detail은 원본 요구 표현을 보존해 표시한다.
- Match의 `requiredName`은 recipe source에 저장된 표시 표현이고 `ownedName`은 사용자의 실제 selectable item명이다. 이 값은 서로 달라도 정상이다.
- 레시피 상세는 이 두 이름이 다를 때 요구명은 주 이름으로 유지하고 실제 보유 항목명을 보조 문구로 함께 보여준다. 예: `간장` 요구 행 아래 `보유한 진간장으로 만들 수 있어요`. 이름이 같으면 중복 보조 문구는 생략할 수 있다.
- Match type은 `DIRECT`, `PREPARATION`, `SUBSTITUTE`다. 각 Option의 우선순위는 [도메인 규칙](../domain/domain.md)에 정의한다.
- `MISSING` 결과의 구매 후보는 기존 Option/Substitute 선언만 반영한다. accepted mapping, Allowed Variant, global Relation은 구매 후보를 추가하지 않는다.
- 추천 mode/sort, pagination, status-specific response shape, error envelope는 OpenAPI와 V2 호환 계약을 유지한다.

## 서버와 클라이언트 책임

서버가 recipe-local accepted mapping, exact mapping, Allowed Variant, global preparation relation, Substitute를 이용해 match와 recommendation을 계산한다. Flutter는 API 결과를 표시하고 UI copy를 만들며 도메인 관계를 재계산하지 않는다. 응답에 없는 context 추론이나 AI 기반 runtime 매칭을 하지 않는다.

## 비호환 구현 점검

외부 API JSON 형식이 유지되어도 내부 구현은 V2와 달라져야 한다. 서버 로직이 RecipeIngredient의 nullable variant만 검사해선 안 되고, accepted mapping으로 인한 직접 일치와 준비 일치도 도메인 우선순위대로 평가해야 한다. `is_base`에 의존한 ingredient 응답/정렬이 없어야 한다. 정확한 기존 경로, DTO 필드, 오류 상태는 OpenAPI 및 기존 API 테스트와 대조한다.
