# API Specification v0.2

이 문서는 WhipUp MVP의 **1차 App ↔ Backend API 설계 초안**이다.

현재 목적은 구현 전에 Client와 Backend 사이의 책임과 데이터 흐름을 맞추는 것이다. Endpoint 이름, pagination 방식, 인증 토큰 형식 등은 실제 구현 과정에서 수정할 수 있다.

Business Rule은 `../domain/domain.md`, 저장 구조는 `../domain/erd.md`를 우선한다.

**운영 데이터 입력은 App API와 분리한다.** 초기 Ingredient/Recipe 데이터는 수백 건 단위로 준비될 수 있으므로 MVP에서는 관리자용 HTTP API를 만들지 않고 별도의 Bulk Import 방식으로 관리한다.

---

# Conventions

## Base Path

```plain text
/api/v1
```

## Content Type

```plain text
application/json
```

## Authentication

일반 User API는 Kakao Login 이후 발급되는 서비스 내부 인증 상태를 기준으로 현재 User를 식별한다.

```plain text
Authorization: Bearer <token>
```

서비스 인증은 JWT Access Token을 사용한다. MVP에서는 Refresh Token을 사용하지 않으며 Access Token 유효기간은 7일이다. 실제 secret은 environment variable로 주입하고 Git에 저장하지 않는다.

## IDs

API에서는 내부 식별자를 사용한다.

예:

```json
{
  "ingredientId": 12,
  "recipeId": 31
}
```

실제 DB PK 타입에 따라 OpenAPI 작성 시 타입을 최종 확정한다.

## Error Response

MVP에서는 Error Response를 단순하게 유지한다.

```json
{
  "code": "OWNED_INGREDIENT_ALREADY_EXISTS",
  "message": "이미 보유 중인 재료입니다."
}
```

기본 형태는 `code + message` 두 필드만 사용한다.

Validation 실패 역시 별도의 `fieldErrors` 구조를 만들지 않고 같은 형태로 응답한다.

```json
{
  "code": "INVALID_REQUEST",
  "message": "하나 이상의 재료를 선택해주세요."
}
```

여러 필드의 세밀한 Validation Error를 Client에서 개별 표시해야 하는 요구가 생기면 그때 확장한다.

Error Code 전체 목록도 미리 만들지 않고 실제 구현에 필요한 항목만 추가한다.

## Pagination

Ingredient Master와 Recommendation처럼 결과가 많아질 수 있는 API는 pagination을 지원한다.

MVP에서는 익숙하고 단순한 **page 기반 pagination**을 사용한다.

Request:

```plain text
page  optional  0부터 시작하는 페이지 번호
size  optional  조회 개수
```

Response:

```json
{
  "items": [],
  "page": 0,
  "size": 30,
  "hasNext": true
}
```

현재 App UX에서는 전체 페이지 수나 전체 데이터 개수를 표시할 필요가 없으므로 `totalPages`, `totalCount`는 기본 응답에 포함하지 않는다. `page`는 0-based, 기본 `size`는 30, 최대 `size`는 100이다. Backend는 전체 count가 필요 없는 Spring Data `Slice` 방식으로 구현한다.

---

# API Summary

| Method | Endpoint | Purpose |
| --- | --- | --- |
| POST | `/auth/kakao` | Kakao Login |
| GET | `/ingredients` | Ingredient Master 조회/검색 |
| GET | `/me/ingredients` | 내 보유 재료 조회 |
| POST | `/me/ingredients` | 보유 재료 일괄 등록 |
| DELETE | `/me/ingredients/{userIngredientId}` | 보유 재료 삭제 |
| GET | `/recommendations` | 부족 재료 개수별 추천 조회 |
| GET | `/recipes/{recipeId}` | Recipe Detail 조회 |

MVP App에서 사용하지 않는 관리자용 HTTP API는 만들지 않는다.

---

# Auth

## POST /auth/kakao

Kakao 인증 결과를 Backend에 전달하고 서비스 User 로그인 상태를 만든다.

```plain text
POST /api/v1/auth/kakao
```

### Request

Client가 Kakao Login에서 획득한 Authorization Code를 Backend에 전달한다.

```json
{
  "authorizationCode": "kakao-authorization-code"
}
```

Backend가 Authorization Code를 Kakao token으로 교환하고 Kakao 사용자 정보를 직접 검증한다. Client가 전달한 사용자 프로필 정보는 인증 근거로 신뢰하지 않는다.

### Behavior

1. Kakao credential을 검증한다.
2. `(provider, providerUserId)`에 해당하는 Auth Account를 조회한다.
3. 최초 로그인이라면 User와 Auth Account를 생성한다.
4. 기존 사용자라면 연결된 User를 조회한다.
5. 서비스 내부 인증 정보를 발급한다.
6. 현재 User의 보유 재료 존재 여부를 함께 반환한다.

### Response `200 OK`

```json
{
  "accessToken": "service-access-token",
  "user": {
    "userId": 1
  },
  "hasOwnedIngredients": true
}
```

Client는 `hasOwnedIngredients`를 기준으로 로그인 직후 이동할 화면을 결정할 수 있다.

```plain text
false → 최초 재료 등록
true  → 추천
```

### Errors

```plain text
401 KAKAO_AUTH_FAILED
```

Kakao 인증 실패 시 User 로그인 상태를 생성하지 않는다.

---

# Ingredient Master

## GET /ingredients

사용자가 보유 재료로 선택할 수 있는 canonical Ingredient 및 Ingredient Form 옵션을 조회한다.

```plain text
GET /api/v1/ingredients
```

### Query Parameters

```plain text
query       optional  표시 재료 이름 검색
categoryId  optional  Ingredient Category 필터
page        optional  0-based, default 0
size        optional  default 30, max 100
```

예:

```plain text
GET /api/v1/ingredients?query=마늘
```

### Response `200 OK`

```json
{
  "items": [
    {
      "ingredientId": 12,
      "ingredientFormId": null,
      "displayName": "마늘",
      "categories": [
        { "categoryId": 2, "code": "VEGETABLE", "displayName": "채소" }
      ]
    },
    {
      "ingredientId": 20,
      "ingredientFormId": 101,
      "displayName": "대패삼겹살"
    }
  ],
  "page": 0,
  "size": 30,
  "hasNext": false
}
```

MVP User 화면에는 canonical Ingredient 자체와 등록된 Ingredient Form을 모두 선택 옵션으로 노출한다. 같은 canonical Ingredient의 서로 다른 Form은 별도 옵션이다. 검색은 표시 이름 contains 방식이며 query는 trim 후 빈 문자열이면 전체 조회로 처리한다. 기본 정렬은 `displayName ASC`다.

각 옵션은 canonical Ingredient의 Category 목록을 함께 반환한다. Ingredient Form은 별도 Category를 가지지 않고 canonical Ingredient의 Category를 그대로 사용한다. 하나의 Ingredient가 여러 Category에 속할 수 있으므로 `categories`는 배열이다.

`categoryId`가 주어지면 해당 Category에 매핑된 canonical Ingredient 및 그 Ingredient Form만 조회한다. 같은 Ingredient가 여러 Category에 속하는 것은 정상이며, Category는 Recommendation 계산에 사용하지 않는다.

### Rules

- 사용자가 직접 Ingredient를 생성할 수 없다.
- 검색은 canonical 및 Form의 표시 이름 기준이다.
- 하나의 canonical Ingredient는 여러 Category에 속할 수 있다.
- Ingredient Form은 canonical Ingredient의 Category를 따른다.
- Category는 탐색/표시용이며 Recommendation에는 사용하지 않는다.
- 자주 쓰는 재료/인기순은 MVP에서 관리하지 않는다.

---

# Owned Ingredients

## GET /me/ingredients

현재 User의 보유 재료를 조회한다.

```plain text
GET /api/v1/me/ingredients
```

### Response `200 OK`

```json
{
  "items": [
    {
      "userIngredientId": 101,
      "ingredient": {
        "ingredientId": 3,
        "name": "계란"
      }
    },
    {
      "userIngredientId": 102,
      "ingredient": {
        "ingredientId": 7,
        "name": "김치"
      }
    }
  ]
}
```

MVP App에서도 Form을 보유 재료로 등록할 수 있으므로 Form이 있는 보유 재료는 `ingredientFormId`와 표시 이름을 반환한다. canonical 자체를 등록한 경우 `ingredientFormId`는 null이다.

---

## POST /me/ingredients

여러 Ingredient를 현재 User의 보유 재료로 한 번에 등록한다.

```plain text
POST /api/v1/me/ingredients
```

### Request

```json
{
  "items": [
    { "ingredientId": 3, "ingredientFormId": null },
    { "ingredientId": 10, "ingredientFormId": 101 }
  ]
}
```

### Rules

- 최소 하나 이상의 Ingredient가 필요하다.
- 모든 `ingredientId`는 Ingredient Master에 존재해야 한다.
- 같은 canonical Ingredient라도 서로 다른 Form은 각각 등록할 수 있다.
- 동일한 `Ingredient + Form` 조합 또는 Form 없는 동일 canonical 옵션은 중복 등록할 수 없다.
- `ingredientFormId`가 존재하면 반드시 요청의 `ingredientId`에 속한 Form이어야 한다.
- Request 내부의 동일 옵션 중복도 허용하지 않는다.
- 하나라도 유효하지 않으면 전체 등록을 실패시킨다.
- 부분 등록은 하지 않는다.
- 수량, 중량, 용량은 받지 않는다.

### Response `201 Created`

```json
{
  "items": [
    {
      "userIngredientId": 101,
      "ingredient": {
        "ingredientId": 3,
        "name": "계란"
      }
    },
    {
      "userIngredientId": 102,
      "ingredient": {
        "ingredientId": 7,
        "name": "김치"
      }
    }
  ]
}
```

### Errors

```plain text
400 INVALID_REQUEST
404 INGREDIENT_NOT_FOUND
409 OWNED_INGREDIENT_ALREADY_EXISTS
```

---

## DELETE /me/ingredients/{userIngredientId}

현재 User의 보유 재료 하나를 삭제한다.

```plain text
DELETE /api/v1/me/ingredients/{userIngredientId}
```

### Rules

- 현재 로그인 User 소유의 User Ingredient만 삭제할 수 있다.
- 별도 확인 단계는 Backend에 존재하지 않는다.
- 마지막 보유 재료도 삭제할 수 있다.
- 삭제는 즉시 반영한다.

### Response

```plain text
204 No Content
```

### Errors

```plain text
404 USER_INGREDIENT_NOT_FOUND
```

다른 User의 ID를 전달한 경우에도 리소스 존재 여부를 별도로 노출하지 않고 `404`로 처리한다.

---

# Recommendation

## GET /recommendations

현재 User의 보유 canonical Ingredient와 Published Recipe의 필요 canonical Ingredient를 비교하여 추천을 계산한다. User가 canonical 자체 또는 어떤 Ingredient Form을 보유하든 추천에서는 `ingredientId`만 DISTINCT 처리한다.

```plain text
GET /api/v1/recommendations?missingCount=0
```

### Query Parameters

```plain text
missingCount  required  0 | 1 | 2
page          optional  0-based, default 0
size          optional  default 30, max 100
```

```plain text
0 → 지금 바로 가능
1 → 재료 1개 부족
2 → 재료 2개 부족
```

3개 이상 부족한 Recipe는 결과에 포함하지 않는다.

### Response `200 OK`

```json
{
  "items": [
    {
      "recipeId": 31,
      "name": "김치볶음밥",
      "missingCount": 0,
      "missingIngredients": []
    }
  ],
  "page": 0,
  "size": 30,
  "hasNext": false
}
```

### Calculation

```plain text
Owned = DISTINCT current user's canonical Ingredient IDs
Required = DISTINCT recipe's canonical Ingredient IDs
Missing = Required - Owned
Missing Count = COUNT(Missing)
```

### Rules

- `PUBLISHED` Recipe만 대상으로 한다.
- Ingredient Form은 추천 판단에서 무시한다.
- 같은 canonical Ingredient가 여러 Recipe Ingredient에 존재해도 한 번만 계산한다.
- User가 같은 canonical Ingredient를 여러 Form으로 보유해도 한 번만 보유한 것으로 계산한다.
- 수량 / 중량 / 용량 / Recipe 필요량은 판단에 사용하지 않는다.
- 보유 재료가 변경되면 다음 조회부터 새 상태로 계산한다.
- 같은 Missing Count 내 기본 정렬은 `recipeId ASC`로 고정하여 pagination 결과 순서를 안정적으로 유지한다.

### No Owned Ingredients

현재 User의 보유 재료가 0개라면 추천을 계산하지 않는다.

```plain text
409 NO_OWNED_INGREDIENTS
```

Client는 최초 재료 등록 화면으로 이동한다.

### Empty Result

해당 Missing Count에 Recipe가 없으면 정상 응답한다.

```json
{
  "items": [],
  "page": 0,
  "size": 30,
  "hasNext": false
}
```

---

# Recipe Detail

## GET /recipes/{recipeId}

Published Recipe의 상세 정보를 현재 User의 보유 상태와 함께 조회한다.

```plain text
GET /api/v1/recipes/{recipeId}
```

### Response `200 OK`

```json
{
  "recipeId": 45,
  "name": "두부조림",
  "shortsReference": "https://youtube.com/shorts/example",
  "thumbnailUrl": "YouTube Shorts thumbnail URL",
  "missingCount": 1,
  "ingredients": [
    {
      "recipeIngredientId": 501,
      "ingredientId": 21,
      "displayName": "두부",
      "amount": "1",
      "unit": "모",
      "owned": false
    },
    {
      "recipeIngredientId": 502,
      "ingredientId": 4,
      "displayName": "대파",
      "amount": "1/2",
      "unit": "대",
      "owned": true
    }
  ],
  "steps": [
    {
      "order": 1,
      "content": "두부를 먹기 좋은 크기로 썬다."
    },
    {
      "order": 2,
      "content": "양념을 넣고 졸인다."
    }
  ]
}
```

### Rules

- `PUBLISHED` Recipe만 조회할 수 있다.
- Recipe Ingredient의 실제 조리 표현과 양을 `displayOrder ASC` 순서로 반환한다.
- `amount`, `unit`은 nullable이다.
- Form이 매핑된 Recipe Ingredient는 `ingredientFormId`를 반환한다.
- `thumbnailUrl`은 별도 업로드 이미지가 아니라 YouTube Shorts reference를 기준으로 가져온 thumbnail이다.
- `owned`는 현재 User의 canonical Ingredient 보유 상태를 기준으로 계산한다.
- 동일 canonical Ingredient가 Recipe 안에서 여러 번 등장해도 각각의 Recipe Ingredient 표현은 모두 반환한다.
- `missingCount`는 고유 canonical Ingredient 기준이다.
- Shorts 재생 실패 여부와 무관하게 Recipe 데이터는 조회할 수 있다.

### Errors

```plain text
404 RECIPE_NOT_FOUND
```

Draft 또는 존재하지 않는 Recipe는 모두 `404`로 처리한다.

---

# Operational Data Import

Ingredient Master와 Recipe 데이터는 일반 User API와 성격이 다르다.

초기 서비스 데이터는 수십~수백 건 이상을 한 번에 준비할 가능성이 높기 때문에 **하나씩 호출하는 관리자 CRUD API를 MVP에 만들지 않는다.**

대신 Repository에서 관리되는 데이터 파일과 Importer를 사용한다.

## Direction

```plain text
Dataset Files
    ↓
Validation / Mapping
    ↓
Bulk Importer
    ↓
Spring Service / Repository
    ↓
PostgreSQL
```

예상 구조:

```plain text
data/
├── ingredients.csv
└── recipes/
    ├── recipe-001.json
    ├── recipe-002.json
    └── ...
```

형식은 구현 시 변경할 수 있다. Ingredient처럼 단순한 Master Data는 CSV가 편하고, Ingredients와 Steps가 중첩되는 Recipe는 JSON 또는 YAML 형태가 적합하다.

## Ingredient Dataset

예:

```javascript
canonical_name
계란
김치
대파
마늘
양파
두부
```

향후 Category 같은 Master Data가 확정되면 컬럼을 추가할 수 있다.

## Recipe Dataset

개념 예시:

```json
{
  "key": "dubujolim-001",
  "name": "두부조림",
  "shortsReference": "https://youtube.com/shorts/example",
  "ingredients": [
    {
      "displayName": "두부",
      "canonicalIngredient": "두부",
      "amount": "1",
      "unit": "모"
    },
    {
      "displayName": "다진 마늘",
      "canonicalIngredient": "마늘",
      "amount": "1",
      "unit": "큰술"
    }
  ],
  "steps": [
    "두부를 먹기 좋은 크기로 썬다.",
    "양념을 넣고 졸인다."
  ]
}
```

실제 Import Dataset Schema는 구현 전에 별도로 확정한다.

## Import Rules

Importer는 최소한 다음을 검증한다.

- Recipe name 존재
- Shorts reference 존재
- 하나 이상의 Recipe Ingredient 존재
- 모든 Recipe Ingredient가 canonical Ingredient와 매핑 가능
- 조리 표현과 양 존재
- 하나 이상의 Recipe Step 존재
- Step 순서 유효

검증에 실패한 Recipe는 Published 데이터로 넣지 않는다.

가능하면 Import는 **idempotent**하게 만든다. 같은 Dataset을 다시 실행해도 데이터가 무한히 중복되지 않아야 한다.

이를 위해 DB PK와 별도로 Dataset에서 사용할 stable key를 두는 방식을 구현 단계에서 검토한다.

```plain text
recipe key: dubujolim-001
```

이 key는 사용자 API에 노출할 필요가 없다.

## AI Draft Workflow

YouTube Shorts → AI Draft 생성 역시 일반 User HTTP API와 분리한다.

초기 데이터 구축 단계에서는 다음 흐름을 사용할 수 있다.

```plain text
YouTube Shorts URL 목록
    ↓
AI extraction script / tool
    ↓
Recipe Draft files
    ↓
사람이 검토 및 Ingredient mapping 수정
    ↓
Validated Dataset
    ↓
Bulk Import
```

즉 AI가 DB에 직접 Published Recipe를 생성하지 않는다.

이 방식이면 수백 개 Recipe를 HTTP API로 하나씩 등록하는 대신 파일 단위로 생성·검토·일괄 반영할 수 있고, Dataset 변경 이력도 Git에서 관리할 수 있다.

## Later

서비스 운영 중 비개발자가 Recipe를 자주 추가/수정해야 하는 시점이 오면 그때 Admin UI와 Admin API를 별도 설계한다.

MVP에서는 필요하지 않은 관리용 HTTP API를 미리 만들지 않는다.

---

# Deferred Decisions

현재 문서에서 의도적으로 확정하지 않은 항목:

- 서비스 Access Token 상세 형식 / Refresh Token
- Pagination 기본 page size
- Recommendation 추가 정렬 기준
- Recipe thumbnail / image 정책
- Ingredient Category / 자주 쓰는 재료 정책
- Ingredient Form을 User UX에 노출하는 방식
- Operational Dataset 실제 파일 Schema
- Bulk Importer의 실행 방식
- AI Recipe extraction script의 구현 방식
- OpenAPI Code Generation 전략

이 항목들은 관련 구현 단계에서 필요한 시점에 결정한다.
