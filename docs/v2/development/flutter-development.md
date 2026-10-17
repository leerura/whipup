## 원칙
Flutter는 Server의 Domain 판단을 재구현하지 않는다. Generated OpenAPI client를 사용하고 DTO를 임의 재정의하지 않는다.
## Ingredient Registration
사용자가 등록하는 실제 ID는 `variantId`다.
`GET /api/v1/ingredients`로 등록 가능한 전체 Ingredient group을 한 번에 조회한다. 별도 검색 API는 두지 않는다. Flutter가 받은 전체 group을 대상으로 local filtering을 수행한다.
Variant 1개:
```plain text
양파
[ 추가 ]
```
Variant 여러 개:
```plain text
마늘
[ 통마늘 ] [ 다진 마늘 ]
```
같은 Ingredient의 여러 Variant를 동시에 가질 수 있으므로 multi-select다.
검색은 Flutter local state로 처리한다. group name 또는 item name이 검색어와 일치하면 해당 group을 유지한다. `다진 마늘` 검색 시 `마늘` group을 보여주되 직접 일치 Variant를 바로 식별할 수 있게 표시한다.
## Recommendation
Server는 mode에 맞는 전체 결과를 반환한다.
Flutter가 화면에서 필요한 개수만 우선 노출하거나 더 보기 UX를 처리한다. Server pagination은 없다.
Flutter는 Server 정렬을 보존한다.
카드에서는 Requirement 전체를 설명하지 않는다.
- AVAILABLE: DIRECT는 생략 가능. PREPARATION의 활용 안내는 상세에서만 표시하고, SUBSTITUTE처럼 선택 전에 알아야 하는 정보만 필요 시 보조 노출
- MISSING_INGREDIENTS: MISSING을 우선 표시. PREPARATION의 상세 활용 안내는 상세에서만 표시
부족 재료 copy는 `missingCount`에 따라 만든다.
- 1개: 부족 재료명 1개 표시
- 2개: 부족 재료명 2개 모두 표시
- 3개 이상: 앞의 2개 재료명 + 나머지 개수. 예: `양파와 대파 외 2개가 더 필요해요`
## Detail
필수 재료 UI 단위는 Requirement다. Recipe Ingredient row와 matching result를 Flutter가 직접 join하지 않는다.
Server detail projection:
- requirements
- optionalIngredients
- missingCount
- 기존 recipe metadata / steps
Option을 메인으로 표시하고 Substitute를 fallback 정보로 표현한다.
## Copy 책임
Server는 구조화된 fact만 내려준다.
Flutter가 최종 UX 문구를 만든다.
단 Flutter는 API에 없는 Domain 의미를 추론하지 않는다.
PREPARATION에 Action 데이터가 없으므로 `다져서`, `썰어서` 같은 action을 재료명에서 임의 생성하지 않는다.
## 기존 V1 유지
- Base path: `/api/v1`
- Recipe thumbnail: 기존 YouTube Shorts thumbnail 방식
- Recipe steps shape: `order + content`
- Auth와 기본 network/codegen 구조는 기존 구현을 유지한다.

## Development API Configuration

개발 환경의 Backend 연결과 iOS Local Network / ATS 규칙은 [local-development.md](local-development.md)를 따른다.

Flutter는 App startup에서 iOS Simulator와 Physical iPhone을 한 번 판별하고 API Base URL을 결정한다.

```plain text
iOS Simulator
→ http://localhost:8080

Physical iPhone
→ LocalConfig.deviceApiBaseUrl
```

실행 환경 판별은 `device_info_plus`의 `isPhysicalDevice`를 사용한다.

Physical Device용 Windows LAN 주소는 `core/config/local_config.dart`에서 관리하며 Git에 commit하지 않는다. Repository에는 `local_config.example.dart`만 포함한다.

Feature 코드와 Generated API Client 내부에 API 주소를 직접 작성하지 않는다. `core/config`에서 결정된 Base URL 하나를 API Client 생성 시 주입한다.

Physical iPhone의 Device API URL이 설정되지 않은 경우 `localhost`로 fallback하지 않는다.
