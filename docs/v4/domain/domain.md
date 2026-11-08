# V4 도메인 규칙

V4는 V3의 Ingredient group, selectable owned item, RecipeIngredient, Requirement/Option, recipe-local accepted owned item, preparation relation, substitute 의미를 변경하지 않는다. 이 문서는 V4가 추가하는 상태만 정의한다.

## 오늘 메뉴

`DailyMenu`는 영구적인 Recipe relation이 아니라 Redis에만 존재하는 사용자별 임시 recipe ID 집합이다.

- 식별: 사용자 ID + KST 날짜
- 값: recipe ID, 담은 시각
- 중복: 같은 키에서 recipe ID 하나만 허용한다.
- 표시 순서: 담은 시각 내림차순
- 유효 기간: 해당 KST 날짜의 다음 자정까지
- 대상: 담는 시점에 `PUBLISHED`인 Recipe만 허용한다.

오늘 메뉴를 읽을 때도 Recipe의 현 상태가 `PUBLISHED`인지 확인한다. 그렇지 않은 항목은 응답에 포함하지 않는다. 이 상태 검사는 recipe publish 상태의 변경을 Redis에 전파해야 한다는 뜻이 아니다.

## 검색 범위

검색의 `AVAILABLE` 범위는 V3 recommendation matcher 결과 `missingCount == 0`인 `PUBLISHED` Recipe다. `ALL` 범위는 `missingCount >= 1`인 `PUBLISHED` Recipe다. 각각의 `missingCount`와 Requirement 결과는 현재 사용자의 inventory를 기준으로 계속 계산하며, 두 범위는 겹치지 않는다. 검색은 Recipe status나 inventory 판정을 별도 캐시로 복제하지 않는다.

## 동의와 온보딩 상태

약관 동의는 계정 단위의 사실이다. 다음을 함께 저장한다.

- 서비스 이용약관 버전과 동의 시각
- 개인정보 수집·이용 버전과 동의 시각
- 만 14세 이상 확인 시각

세 시각이 모두 있으면 `termsConsentRequired=false`다. V4 도입 전 생성된 기존 계정은 세 동의를 완료한 것으로 migration/backfill한다. 새 계정은 동의가 끝날 때까지 재료·검색·추천·오늘 메뉴 API를 사용하지 못하며, 약관 동의 endpoint만 사용할 수 있다.

`onboardingCompleted`는 약관 동의와 별도다. V4 온보딩 제출(빈 선택 포함)이 성공하면 `true`가 되고, 이후 보유 재료를 모두 지워도 `false`로 되돌리지 않는다.

## 재료 빠른 조작 후보

레시피 상세에서 부족한 Requirement에 표시할 추가 후보는 서버 matcher가 이미 확정한 recipe-local 후보여야 한다. 후보 ID·표시명은 API가 보내며 Flutter가 재료 관계를 새로 계산하지 않는다. 후보가 여러 개면 사용자가 하나를 선택한다. 선택한 후보가 해당 Requirement의 어떤 Option도 충족하지 않는다면 서버가 요청을 거부한다.
