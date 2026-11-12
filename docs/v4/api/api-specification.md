# V4 API 계약

V3 API의 인증, ingredient catalog, 보유 재료 추가/삭제, recommendation, recipe detail 계약은 유지한다. V4는 아래 endpoint와 response field를 추가한다. 모든 경로는 Bearer 인증이 필요하며, 약관 동의 대기 사용자는 `POST /api/v1/me/terms-consent`, `GET /api/v1/me`, `DELETE /api/v1/me` 외 요청에서 `403 TERMS_CONSENT_REQUIRED`를 받는다.

## Apple 로그인

```text
POST /api/v1/auth/apple
```

```json
{
  "identityToken": "<JWT>",
  "authorizationCode": "<code>",
  "nonce": "<raw nonce>"
}
```

세 필드는 모두 필수다. 인증 없이 호출하며 응답은 `LoginResponse`다. iOS 전용이므로 `aud`는 앱 번들 ID다.

서버 처리 순서:

1. `identityToken`을 Apple 공개키(`https://appleid.apple.com/auth/keys`, `kid`로 선택, 캐시하되 모르는 `kid`면 갱신)로 서명 검증하고 `iss`(`https://appleid.apple.com`), `aud`(`APPLE_CLIENT_ID`), `exp`를 확인한다.
2. 토큰의 `nonce` claim이 요청 `nonce`의 SHA-256 hex와 같아야 한다. claim이 없거나 다르면 실패다.
3. `authorizationCode`를 Apple 토큰 endpoint에 교환한다(`client_secret`은 Team ID·Key ID·private key로 서버가 ES256 JWT로 생성). 응답의 `id_token`의 `sub`가 1번에서 검증한 `sub`와 같아야 한다.
4. `(APPLE, sub)`로 계정을 찾거나 새로 만들고, 응답의 refresh token을 암호화해 저장한다(기존 값은 덮어쓴다). 이후 WhipUp JWT 발급과 `LoginResponse`는 Kakao와 같다.

오류: 요청 필드 누락은 `400`, 토큰·nonce·code 검증 실패는 `401`, Apple 설정(`APPLE_CLIENT_ID`, `APPLE_TEAM_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY`, 토큰 암호화 키)이 없거나 Apple 호출 자체가 실패하면 `503 APPLE_LOGIN_UNAVAILABLE`이다. 이름·이메일은 받지도 저장하지도 않는다.

계정 삭제(`DELETE /api/v1/me`)에서 Apple 계정이면 삭제 트랜잭션이 커밋된 뒤 저장된 refresh token으로 Apple revoke를 호출한다. revoke 실패는 응답을 바꾸지 않고, 토큰·사용자 식별자 없이 로그만 남긴다.

## 로그인 응답

기존 `LoginResponse`에 아래 필드를 추가한다.

```json
{
  "termsConsentRequired": true,
  "onboardingCompleted": false
}
```

`termsConsentRequired=true`이면 Flutter는 약관 동의 화면으로 보낸다. `false`이고 `onboardingCompleted=false`이면 V4 재료 온보딩으로 보낸다. 둘 다 `false`/`true`면 홈으로 보낸다.

## 현재 계정 조회

```text
GET /api/v1/me
```

Bearer 인증 사용자의 현재 계정 상태를 반환한다. 앱이 저장해 둔 WhipUp access token으로 재진입할 때 토큰이 유효한지 확인하고 다음 화면을 정하는 데 쓴다. 약관 동의 대기 사용자도 호출할 수 있으며 `403 TERMS_CONSENT_REQUIRED`를 받지 않는다.

```json
{
  "user": { "userId": 1 },
  "hasOwnedIngredients": true,
  "onboardingCompleted": true,
  "termsConsentRequired": false
}
```

각 필드의 의미는 `LoginResponse`와 같다. `accessToken`은 포함하지 않고 새 토큰도 발급하지 않는다. 토큰이 없거나 만료·무효이거나 토큰의 사용자가 이미 삭제됐으면 `401`이다.

## 약관 동의

```text
POST /api/v1/me/terms-consent
```

```json
{
  "termsVersion": "v1",
  "privacyVersion": "v1",
  "age14OrOver": true
}
```

모든 필드는 필수다. `age14OrOver=false`이면 `400`을 반환하고 동의를 기록하지 않는다. 서버는 환경 설정으로 정한 현재 문서 버전만 받는다. 예시의 `v1`은 실제 고정값이 아니라 버전 식별자 형식이다. 성공 시 `204 No Content`다. 이미 동의한 기존 사용자가 호출해도 현재 버전과 동일한 값이면 idempotent하게 `204`를 반환한다.

## 온보딩 재료 저장

```text
POST /api/v1/me/onboarding
```

```json
{
  "variantIds": [12, 31, 42]
}
```

`variantIds`는 중복 없는 selectable owned item ID 배열이며 빈 배열도 허용한다. 서버는 한 트랜잭션에서 각 item을 보유 재료로 추가하고 `onboardingCompleted=true`를 기록한다. 동일 ID가 이미 있으면 중복 오류 대신 결과 inventory 하나로 취급한다. 약관 동의가 끝나지 않은 사용자는 호출할 수 없다. 성공은 `204 No Content`다.

기존 `POST /api/v1/me/ingredients`는 온보딩 상태를 바꾸지 않는다.

## 레시피 검색

```text
GET /api/v1/recipes/search?scope=AVAILABLE|ALL&query={query}
```

- `scope`와 `query`는 필수다.
- 빈 문자열 또는 공백뿐인 `query`는 `400`이다.
- response는 `RecommendationListResponse`와 동일한 `items` 배열이다. 각 item의 match/missingCount는 현재 inventory 기준이다.
- `AVAILABLE`은 `missingCount=0`인 `PUBLISHED`만, `ALL`은 `missingCount>=1`인 `PUBLISHED`만 반환한다. 두 결과 집합은 겹치지 않는다.
- 제목 또는 RecipeIngredient의 `displayName`이 정규화된 query를 포함하는 경우만 반환한다.
- 정렬 규칙은 [제품 문서](../product/product.md#검색)를 따른다.

## 오늘 메뉴

```text
GET    /api/v1/me/daily-menu
POST   /api/v1/me/daily-menu
DELETE /api/v1/me/daily-menu/{recipeId}
```

`GET` response는 `RecommendationListResponse`와 같은 `{ "items": [...] }`이며 최신으로 담은 순서다. 현재 `PUBLISHED`가 아닌 recipe는 포함하지 않는다. Redis가 사용할 수 없으면 서버는 `{ "items": [] }`를 반환하고, Flutter는 오늘 메뉴 섹션 자체를 표시하지 않는다.

`POST` request:

```json
{ "recipeId": 123 }
```

현재 `PUBLISHED` Recipe만 담을 수 있다. 이미 같은 날 담긴 recipe를 다시 요청해도 성공으로 취급하고 위치를 바꾸지 않는다. 성공은 `204 No Content`다. Redis 장애는 `503 DAILY_MENU_UNAVAILABLE`다.

`DELETE`는 해당 날짜의 recipe ID를 제거한다. 항목이 이미 없거나 만료된 경우도 idempotent하게 `204`를 반환한다. Redis 장애는 `503 DAILY_MENU_UNAVAILABLE`다.

## 상세의 재료 추가 후보

기존 `RecipeDetailResponse`의 각 `MissingDetailRequirement`에 다음 필드를 추가한다.

```json
{
  "addableVariants": [
    { "variantId": 12, "name": "진간장" },
    { "variantId": 13, "name": "양조간장" }
  ]
}
```

`addableVariants`는 해당 부족 Requirement를 충족하는 V3 recipe-local 후보만 포함한다. 비어 있을 수 있으며, 이 경우 상세에서 재료함 추가 동작을 제공하지 않는다. Flutter는 사용자가 고른 `variantId`를 기존 `POST /api/v1/me/ingredients`에 보낸다. DELETE는 기존 `userIngredientId` endpoint를 사용한다.

## HTTP 체감 시간 집계

```text
POST /api/v1/telemetry/http-timing
```

```json
{
  "route": "/api/v1/recipes/recommendations",
  "method": "GET",
  "outcome": "SUCCESS",
  "durationMs": 2880
}
```

인증된 앱만 호출한다. `route`는 서버가 허용한 정규화된 API template, `method`는 `GET`·`POST`·`DELETE`, `outcome`은 `SUCCESS`·`CLIENT_ERROR`·`SERVER_ERROR`·`NETWORK_ERROR`만 허용한다. `durationMs`는 0 이상 60,000 이하 정수다. 서버는 raw event를 저장하지 않고 Prometheus용 `whipup.client.http` Timer에만 누적한 뒤 `204 No Content`를 반환한다.

## 오류 형식

기존 `ErrorResponse`를 유지한다. V4가 추가하는 code는 `TERMS_CONSENT_REQUIRED`, `DAILY_MENU_UNAVAILABLE`, `APPLE_LOGIN_UNAVAILABLE`이다.
