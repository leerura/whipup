## 원칙
Flutter는 Server의 Domain 판단을 재구현하지 않는다. Generated OpenAPI client를 사용하고 DTO를 임의 재정의하지 않는다.
## Ingredient Registration
사용자가 등록하는 실제 ID는 `variantId`다.
검색 API는 같은 canonical Ingredient의 등록 가능한 Variant를 group으로 반환한다.
Variant 1개:
```plain text
양파
[ 추가 ]
```
Variant 여러 개:
```plain text
마늘
[ 마늘 ] [ 다진 마늘 ]
```
같은 Ingredient의 여러 Variant를 동시에 가질 수 있으므로 multi-select다.
`다진 마늘` 검색 시 `마늘` group을 보여주되 직접 일치 Variant를 바로 식별할 수 있게 표시한다.
## Recommendation
Server는 mode에 맞는 전체 결과를 반환한다.
Flutter가 화면에서 필요한 개수만 우선 노출하거나 더 보기 UX를 처리한다. Server pagination은 없다.
Flutter는 Server 정렬을 보존한다.
카드에서는 Requirement 전체를 설명하지 않는다.
- AVAILABLE: DIRECT는 생략 가능, PREPARATION/SUBSTITUTE는 표시
- MISSING_INGREDIENTS: MISSING 우선, PREPARATION/SUBSTITUTE 보조
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

