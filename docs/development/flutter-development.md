## 1. 목적

이 문서는 WhipUp MVP의 Flutter 구현 기준을 정의한다.

Flutter 구현 시 다음 Source of Truth를 사용한다.

```plain text
기능 / Business Rule → product.md / domain.md
화면 동작 → ux.md
Visual Design → Figma High-fi
API Contract → openapi.yaml
Flutter 구현 방식 → flutter-development.md
```

Figma는 layout, component, typography, color, spacing, visual state의 기준이다. 이 문서는 Figma에서 알 수 없는 API 호출, Client State, Navigation, Local Data, Asset Mapping, Loading / Error 처리, Generated API Client 사용 방식을 정의한다.

Flutter에서 Backend Business Rule을 다시 구현하지 않는다.

## 2. 기본 원칙

MVP에서는 구조를 단순하게 유지한다.

```plain text
Screen / Widget
      ↓
Riverpod
      ↓
Feature Data
      ↓
Generated API Client
```

단순한 API 호출 하나를 위해 Presentation → UseCase → Repository Interface → Repository Impl → DataSource → Mapper 같은 계층을 만들지 않는다.

기본 구조는 `presentation/`, `state/`, `data/` 정도면 충분하다. 작은 Feature라면 필요한 파일만 만들고 더 단순하게 구성해도 된다.

## 3. Figma

Visual Source of Truth는 Figma `냉장고 털이 🍚 > 03. High-fi`다.

최종 구현은 High-fi 화면을 기준으로 한다. Figma Component는 실제로 재사용되는 경우 Flutter Widget으로 구현한다.

예: `C-Ingredient Row → IngredientRow`, `C-Search Input → IngredientSearchField`, `C-Recipe Card → RecipeCard`, `C-Recommendation Selector → RecommendationSelector`, `C-Tab Bar → MainTabBar`.

Figma Component 하나당 반드시 Widget 파일 하나를 만드는 규칙은 두지 않는다.

## 4. Directory Structure

```plain text
app/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── theme.dart
│   ├── features/
│   │   ├── auth/
│   │   ├── ingredient/
│   │   ├── recommendation/
│   │   └── recipe/
│   └── core/
│       ├── network/
│       ├── auth/
│       └── config/
├── assets/
│   └── ingredients/
└── packages/
    └── api_client/        # Generated
```

Feature 내부는 필요할 때 `presentation/`, `state/`, `data/`를 사용한다. API 호출 하나를 위해 Repository/Service/UseCase 파일을 모두 만들지 않는다.

## 5. Generated API Client

API Request/Response Model을 Flutter에서 다시 작성하지 않는다.

```plain text
docs/api/openapi.yaml
        ↓
OpenAPI Generator
        ↓
app/packages/api_client/
```

Flutter는 generated `api_client`를 사용한다. Generated Code는 직접 수정하지 않는다. Contract 변경은 [openapi.yaml](../api/openapi.yaml) 수정 → `make generate-api` → Generated Client 갱신 순서로 처리한다.

## 6. Riverpod

Riverpod은 화면에서 필요한 비동기 서버 상태와 사용자 Action을 관리한다. Provider를 필요 이상으로 세분화하지 않는다.

하나의 화면에서만 필요한 검색 입력값, 일시적인 UI 선택/펼침 상태 등은 Widget local state로 처리할 수 있다. 서버 데이터나 여러 Widget에서 공유되는 상태는 Riverpod에서 관리한다.

## 7. Navigation

Navigation은 `go_router`를 사용한다.

```plain text
/login
/ingredients/setup
/ingredients
/recommendations
/recipes/:recipeId
```

실제 route 이름보다 Screen 역할을 명확하게 유지하는 것이 중요하다. Bottom Tab은 Figma의 `C-Tab Bar`를 기준으로 구현한다.

Navigation Rule은 [ux.md](../ux/ux.md)를 따른다.

```plain text
로그인
 ├─ 보유 재료 있음 → Recommendation
 └─ 보유 재료 없음 → Ingredient Setup

Recommendation 진입
 └─ 보유 재료 0개 → Ingredient Setup

Recipe 선택
 → Recipe Detail
```

## 8. Ingredient Data

Ingredient 화면의 서버 데이터는 다음 두 API에서 가져온다.

```plain text
GET /ingredients
→ 전체 Ingredient Master

GET /me/ingredients
→ 현재 User의 Owned Ingredients
```

`GET /ingredients`는 pagination 없이 전체 목록을 한 번에 조회한다. Flutter는 두 결과를 `ingredientId` 기준으로 조합한다. Backend에 검색 요청을 보내지 않는다.

## 9. Ingredient Local Search

검색은 전체 Ingredient Master를 대상으로 Flutter에서 `displayName contains` 방식으로 처리한다. 검색 결과 개수는 filtered list의 길이를 사용한다.

검색할 때마다 Backend API를 호출하지 않는다. 검색 입력이 비어 있으면 기본 Ingredient 화면을 표시하고, 결과 있음/없음 상태는 Figma를 따른다.

## 10. Owned Ingredient State

Owned 여부는 `ingredientId`로 판단하며 이름 비교를 하지 않는다.

Figma의 `보유 중 N개`, `재료 더 담기 N개` 값은 Flutter가 현재 list 길이로 계산한다. Backend에 count API를 요청하지 않는다.

## 11. Ingredient Add / Delete

Figma interaction에 따라 체크하면 즉시 추가하고 체크를 풀면 즉시 삭제한다.

```plain text
체크
→ POST /me/ingredients

체크 해제
→ DELETE /me/ingredients/{userIngredientId}
```

성공하면 현재 Riverpod state를 갱신한다. 매번 전체 데이터를 다시 가져와야 하는 규칙은 두지 않는다. 요청이 실패하면 성공한 것처럼 상태를 확정하지 않는다.

## 12. Frequently Used Ingredients

Figma의 `자주 쓰는 재료`는 Backend 기능이 아니다. MVP에서는 Flutter static data로 관리한다.

실제 목록은 최종 Figma/확정 목록을 따른다. 가능하면 표시 이름 자체를 식별자로 사용하지 말고 Ingredient Master의 `ingredientId`와 연결하여 사용한다.

이 기능을 위한 API, DB Table, Backend Business Logic을 만들지 않는다.

## 13. Ingredient Icons

Ingredient 썸네일은 `app/assets/ingredients/` 아래 Flutter local asset으로 관리한다. Backend는 icon 정보를 반환하지 않는다.

Flutter가 Ingredient와 local asset을 매핑하며 Figma의 Ingredient Thumb Mapping을 구현 기준으로 사용한다. 전용 일러스트가 없는 Ingredient는 Figma에서 정의한 fallback 표현을 사용한다.

새 Ingredient 때문에 Backend Model/API Contract를 변경하지 않는다. 향후 필요 시 Storage 기반 asset으로 이전할 수 있다.

## 14. Recommendation

추천 결과 계산은 Backend 책임이다. Flutter에서 Recommendation Algorithm을 다시 구현하지 않는다.

```plain text
GET /recommendations?missingCount=0
GET /recommendations?missingCount=1
GET /recommendations?missingCount=2
```

Figma Recommendation Selector는 0=지금 바로 가능, 1=재료 1개 부족, 2=재료 2개 부족 상태를 표현한다. 선택된 missingCount가 변경되면 해당 결과를 표시한다.

## 15. Recommendation Pagination

Recommendation API pagination은 Backend Contract를 따른다. 최초 진입 시 첫 페이지를 조회하고 추가 결과가 필요하면 다음 page를 기존 list 뒤에 추가한다. `hasNext == false`면 추가 요청하지 않는다.

Ingredient 목록에는 pagination 로직을 사용하지 않는다.

## 16. Recipe Card Image

추천 카드 음식 이미지는 `RecommendationItem.thumbnailUrl`의 YouTube Shorts thumbnail을 사용한다.

Flutter local 요리 illustration을 Recipe thumbnail 대신 사용하지 않는다. Figma의 요리 illustration asset은 Recipe API 데이터의 Source of Truth가 아니다.

## 17. Recipe Detail

Recipe Card 선택 시 `/recipes/:recipeId`로 이동하고 `GET /recipes/{recipeId}`를 조회한다.

Backend 응답의 `name`, `thumbnailUrl`, `shortsReference`, `ingredients`, `steps`, `owned`, `missingCount`를 기준으로 화면을 표시한다.

Ingredient 보유/부족 여부는 Flutter에서 다시 계산하지 않고 `RecipeIngredient.owned`를 사용한다.

## 18. YouTube Shorts

Recipe Detail의 영상은 `shortsReference`를 사용한다. 화면 진입 시 자동 재생하지 않고 사용자가 재생 Action을 수행했을 때 재생한다.

영상 재생에 실패해도 Recipe 정보, Ingredient, 조리 단계는 계속 사용할 수 있어야 한다. YouTube 재생 SDK/Package 선택은 구현 시 결정한다.

## 19. Loading / Empty / Error

복잡한 State Machine을 만들지 않고 기본적으로 `Loading / Data / Empty / Error` 정도만 구분한다.

Figma에 별도 Empty State가 있으면 해당 디자인을 사용한다. 예: Ingredient Search 결과 없음, Recommendation 결과 없음.

API Error를 그대로 사용자에게 출력하지 않는다. 필요한 경우 기술 Error를 사용자 메시지로 변환한다.

## 20. Authentication

Kakao Login 성공 후 `POST /auth/kakao`를 통해 서비스 JWT를 받는다.

JWT는 Generated Code 내부에 저장하지 않는다. `core/auth` 또는 `core/network`에서 관리하고 Generated API Client 요청에 주입한다.

로그인 응답의 `hasOwnedIngredients`가 false면 Ingredient Setup, true면 Recommendation으로 이동한다. 구체적인 secure storage package는 구현 시 결정한다.

## 21. Theme & Design

Figma High-fi를 Visual Source of Truth로 사용한다. 반복되는 color, typography 등 Design Token은 우선 `app/theme.dart`에 모은다.

규모가 실제로 커질 때만 theme 파일을 나눈다. 화면마다 반복되는 값을 복사하기보다 반복되는 값만 Theme/공통 상수로 관리한다.

## 22. Reusable Widgets

실제로 여러 화면에서 반복되는 UI만 공통 Widget으로 만든다.

예: `IngredientRow`, `RecipeCard`, `MainTabBar`, `IngredientSearchField`, `RecommendationSelector`.

한 번만 사용되는 작은 Widget까지 전부 별도 파일로 만들지 않는다. 거대한 전역 `common/widgets/` 폴더를 만들지 않으며 Feature 전용 Widget은 해당 Feature 안에 둔다.

## 23. Local UI Data

Backend와 무관한 UI 전용 데이터는 Flutter에 둘 수 있다.

현재 해당 데이터는 Frequently Used Ingredients와 Ingredient Icon Mapping이다. 이 데이터는 Domain Rule이 아니므로 Backend와 동기화하기 위한 API를 만들지 않는다.

## 24. Screen ↔ API

| Screen | API |
| --- | --- |
| Login | `POST /auth/kakao` |
| 최초 재료 등록 | `GET /ingredients`, `POST /me/ingredients` |
| 보유 재료 관리 | `GET /ingredients`, `GET /me/ingredients`, `POST /me/ingredients`, `DELETE /me/ingredients/{id}` |
| 추천 | `GET /recommendations` |
| 레시피 상세 | `GET /recipes/{recipeId}` |

재료 검색은 API 호출이 아니다.

## 25. 구현 시 하지 않는 것

MVP Flutter에서는 다음을 도입하지 않는다.

- Clean Architecture boilerplate
- UseCase class 남발
- Repository Interface + Impl 이중화
- API DTO 재정의
- Generated DTO용 Mapper 남발
- Offline Database
- Ingredient Search API / Count API / Icon API
- Frequently Used Ingredient API
- Recommendation Algorithm 재구현
- Global Event Bus
- 복잡한 State Machine

문제를 해결하기 위해 실제 필요해질 때만 구조를 추가한다.

## 26. AI Agent Rules

1. Visual 구현은 Figma High-fi를 기준으로 한다.
2. API Request/Response는 [openapi.yaml](../api/openapi.yaml)과 Generated `api_client`를 사용한다.
3. Generated Code를 직접 수정하지 않는다.
4. Backend에 존재하지 않는 API를 임의로 만들지 않는다.
5. Backend Business Rule을 Flutter에서 다시 구현하지 않는다.
6. Ingredient 검색은 local filtering으로 구현한다.
7. 자주 쓰는 재료와 Ingredient icon은 Flutter local data다.
8. Recipe image는 API의 YouTube Shorts thumbnail을 사용한다.
9. 새 Architecture Layer를 필요 없이 추가하지 않는다.
10. 구현 중 Figma와 API Contract가 충돌하면 임의로 추측하지 않고 Source of Truth 충돌로 취급한다.

## 27. 구현 시 결정해도 되는 사항

다음은 현재 문서에서 과도하게 고정하지 않는다.

- Notifier/Provider의 구체적인 이름
- Riverpod codegen 사용 여부
- Dio wrapper의 세부 구조
- secure storage package
- YouTube 재생 package
- 모든 Widget 파일명
- Theme 파일의 세부 분리 방식

구현 복잡도를 줄이는 방향을 우선하고, 실제 필요성이 생겼을 때만 구조를 확장한다.
