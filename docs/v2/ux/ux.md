## Ingredient Registration
Flat Variant list를 사용하지 않는다.
같은 Ingredient에 속한 등록 가능한 Variant를 하나의 group으로 보여준다.
```plain text
마늘
[ 마늘 ] [ 다진 마늘 ]

삼겹살
[ 삼겹살 ] [ 대패삼겹살 ]
```
Variant가 하나뿐이면 바로 추가할 수 있다.
여러 Variant가 있으면 inline multi-select로 보여준다.
목표는 사용자가 먼저 보인 base Variant를 실수로 등록하고 나중에 실제 보유 형태를 발견하는 문제를 줄이는 것이다.
## Recommendation
상위 탐색은 두 개다.
- 지금 있는 걸로
- 재료 추가해서
### 지금 있는 걸로
missingCount = 0.
카드:
- 추가 행동이 없으면 `지금 바로 만들 수 있어요`
- PREPARATION은 표시
- SUBSTITUTE는 표시
- DIRECT를 모두 나열하지 않음
### 재료 추가해서
missingCount \>= 1.
MISSING을 가장 먼저 보여준다.
PREPARATION/SUBSTITUTE는 보조 정보다.
예:
```plain text
대패삼겹살만 있으면 돼요
```
OR:
```plain text
설탕이나 올리고당 중 하나만 있으면 돼요
```
Substitute:
```plain text
알룰로스가 필요해요
설탕으로 대신해도 돼요
```
OR + Substitute:
```plain text
알룰로스나 올리고당 중 하나만 있으면 돼요
알룰로스는 설탕으로 대신해도 돼요
```
Substitute를 Option과 평탄화하지 않는다.
부족 Requirement가 많으면 카드에서는 요약하고 상세에서 전체를 보여준다.
## Recipe Detail
상단에 전체 가능 여부를 요약한다.
필수 재료는 Recipe Requirement 기준으로 보여준다.
예:
```plain text
필요한 재료

✓ 삼겹살 300g

✓ 다진 마늘 1큰술
  가지고 있는 마늘을 활용할 수 있어요

✓ 알룰로스 1큰술
  가지고 있는 설탕으로 대신할 수 있어요

✓ 간장 또는 굴소스 1큰술
  가지고 있는 간장을 사용할 수 있어요
```
Optional은 별도 선택 재료 영역에 둔다.
OR Requirement의 main display는 Option들만 사용한다.
Substitute는 해당 Option의 보조 설명으로만 표현한다.
## Domain fact와 Copy
Server는 상태/매칭 구조를 반환하고 Flutter가 최종 문구를 만든다.
Flutter는 API에 없는 action을 임의 추론하지 않는다. Relation에 Action을 저장하지 않으므로 PREPARATION을 보고 무조건 `다져서 사용` 같은 문구를 만들지 않는다.

