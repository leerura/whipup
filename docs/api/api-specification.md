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

Bearer Token을 사용한다는 방향만 현재 초안에 반영한다. Token 형식, 만료/재발급 방식, Spring Security 구성은 구현 전에 확정한다.

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

v0.2에서는 다음 형태를 기준으로 한다.

```json
{
  "items": [],
  "nextCursor": "..."
}
```

`nextCursor = null`이면 다음 페이지가 없다.

Cursor 생성 규칙과 기본 page size는 구현 단계에서 확정한다.

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

현재는 Kakao Access Token을 Backend에 전달하는 형태를 가정한다.

```json
{
  "kakaoAccessToken": "kakao-access-token"
}
```

Kakao SDK 연동 과정에서 Authorization Code 방식 등이 더 적합하면 변경할 수 있다.

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

서비스에 등록된 canonical Ingredient Master를 조회한다.

```plain text
GET /api/v1/ingredients
```

### Query Parameters

```plain text
query   optional  재료 이름 검색
cursor  optional  다음 페이지 cursor
size    optional  조회 개수
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
      "name": "마늘"
    },
    {
      "ingredientId": 18,
      "name": "다시마"
    }
  ],
  "nextCursor": null
}
```

MVP User 화면에는 canonical Ingredient만 노출한다.

Ingredient Form은 현재 추천/선택 UX에 직접 노출하지 않는다. 향후 Form 선택 UX가 생기면 API 확장을 검토한다.

### Rules

- 사용자가 직접 Ingredient를 생성할 수 없다.
- 검색은 canonical Ingredient 이름 기준이다.
- Category / 자주 쓰는 재료 정렬은 현재 확정하지 않는다.
- 재료 탐색 UX가 확정되면 Query Parameter나 Response field를 추가할 수 있다.

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

MVP App에서는 Form을 선택하지 않으므로 Response에도 Form 정보를 기본 노출하지 않는다.

---

## POST /me/ingredients

여러 Ingredient를 현재 User의 보유 재료로 한 번에 등록한다.

```plain text
POST /api/v1/me/ingredients
```

### Request

```json
{
  "ingredientIds": [3, 7, 12]
}
```

### Rules

- 최소 하나 이상의 Ingredient가 필요하다.
- 모든 `ingredientId`는 Ingredient Master에 존재해야 한다.
- 이미 보유 중인 canonical Ingredient를 다시 등록할 수 없다.
- Request 내부의 중복 Ingredient ID도 허용하지 않는다.
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

현재 User의 보유 canonical Ingredient와 Published Recipe의 필요 canonical Ingredient를 비교하여 추천을 계산한다.

```plain text
GET /api/v1/recommendations?missingCount=0
```

### Query Parameters

```plain text
missingCount  required  0 | 1 | 2
cursor        optional
size          optional
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
  "nextCursor": null
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
- 같은 Missing Count 내 추가 정렬 기준은 MVP에서 정의하지 않는다.

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
  "nextCursor": null
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
- Recipe Ingredient의 실제 조리 표현과 양을 반환한다.
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
- Cursor 생성 규칙 및 기본 page size
- Recommendation 추가 정렬 기준
- Recipe thumbnail / image 정책
- Ingredient Category / 자주 쓰는 재료 정책
- Ingredient Form을 User UX에 노출하는 방식
- Operational Dataset 실제 파일 Schema
- Bulk Importer의 실행 방식
- AI Recipe extraction script의 구현 방식
- OpenAPI Code Generation 전략

이 항목들은 관련 구현 단계에서 필요한 시점에 결정한다.
