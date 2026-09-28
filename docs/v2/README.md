V2 구현을 위한 Repository 문서 Source of Truth다.

GitHub에서는 `docs/v2/` 아래에 동일한 구조로 관리한다. 기존 `docs/`의 V1 문서는 수정하지 않고 유지한다.

## 문서 구조

- `product/`: V2 제품 목표와 범위
- `domain/`: Ingredient Variant, Requirement, Matching, ERD
- `api/`: App ↔ Backend 계약과 OpenAPI
- `data/`: Dataset Schema
- `development/`: AI Pipeline, Importer, Flutter/Server 구현 원칙
- `ux/`: 재료 등록, 추천, 상세 UX

## 공통 결정

- API base path는 V2에서도 `/api/v1`을 유지한다.
- Recipe status는 기존 코드의 `PUBLISHED`를 유지한다.
- V1→V2 row migration은 하지 않는다. V2 데이터 전환 시 재료/레시피 관련 운영 데이터를 새 Dataset 기준으로 초기화·재적재한다.
- 사용자 보유 재료의 실제 저장 단위는 IngredientVariant다.
- Server가 추천/매칭 Domain 판정을 수행하고 Flutter는 결과를 표현한다.

