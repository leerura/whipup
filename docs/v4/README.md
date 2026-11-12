# V4 문서

V4는 V3의 재료 카탈로그, Recipe Requirement, recipe-local accepted mapping, 추천 매칭 규칙과 레시피 데이터 파이프라인을 유지하면서 탐색·보유 재료 관리·오늘 메뉴·신규 가입 온보딩을 개선하고 iOS Apple 로그인을 추가한다.

V3의 규칙을 바꾸지 않는 영역은 V3 문서를 계속 따른다. 특히 재료가 실제 보유 단위라는 원칙, 레시피 원문 재료 표현 보존, recipe-local mapping, `PUBLISHED` 검증과 Gemini 파이프라인은 V3가 기준이다. 이 디렉터리의 문서와 V3가 다르면 V4가 우선한다.

## 문서

- [제품 범위와 확정 결정](product/product.md)
- [V4 UX와 화면 상태](ux/ux.md)
- [도메인 규칙](domain/domain.md)
- [저장 모델](domain/erd.md)
- [API 계약](api/api-specification.md)
- [구현 영향과 완료 기준](development/implementation-guide.md)
- [성능 관측·병목 분석](development/observability.md)

## 범위 밖

- recipe pipeline, Gemini 추출 형식, catalog/recipe dataset 스키마의 변경
- 새로운 전역 재료 대체·호환 규칙
- 쿠팡 파트너스, 상품·가격·재고 데이터, 제휴 수익 추적
- 오늘 메뉴 외 일반 캐시 도입
- Apple 서버 간 알림(S2S) endpoint와 앱 시작 시 Apple credential state 확인
- Android·웹 Apple 로그인(Services ID 흐름)

위 항목을 V4 구현 중 임의로 추가하지 않는다.
