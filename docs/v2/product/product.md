## 목표
V2는 사용자의 실제 보유 재료 형태를 더 정확하게 반영하고, 레시피가 요구하는 재료를 DIRECT / PREPARATION / SUBSTITUTE / MISSING으로 설명할 수 있게 한다.
추천의 역할은 사용자를 대신해 메뉴를 고르는 것이 아니라, 내 재료에서 가까운 레시피부터 보여주고 추가로 필요한 행동이나 재료를 명확하게 알려 사용자가 선택하게 하는 것이다.
## 핵심 사용자 질문
- 지금 내 재료로 뭐 해먹을 수 있지?
- 조금 장봐도 괜찮다면 뭐 해먹을 수 있지?
## V2 범위
- Ingredient Variant 기반 보유 재료
- 방향성 있는 Variant Relation
- Recipe Requirement / OR / Substitute / Optional
- Requirement-level matching
- Ingredient group 기반 등록 UX
- Recommendation mode: AVAILABLE / MISSING_INGREDIENTS
- Recipe Detail의 Requirement 중심 표시
- V2 Dataset / AI Pipeline / Importer / API 계약
## 추천 모드
### 지금 있는 걸로
`missingCount = 0`.
DIRECT는 카드에서 굳이 모두 설명하지 않는다. PREPARATION과 SUBSTITUTE처럼 사용자가 알아야 하는 추가 행동은 보여준다.
### 재료 추가해서
`missingCount >= 1`.
MISSING을 1차 정보로, PREPARATION/SUBSTITUTE를 2차 정보로 보여준다. 1개 부족/2개 부족 식의 top-level section이나 hard cutoff는 두지 않는다.
## 정렬
- AVAILABLE: `recipeId ASC`
- MISSING_INGREDIENTS: `missingCount ASC, recipeId ASC`
`recipeId ASC`는 추천 의미가 아니라 deterministic ordering 용도다.
## 범위 밖
V2에서는 취향/클릭/조리 이력 기반 개인화 추천 점수를 설계하지 않는다. 이런 신호가 생기면 정렬 정책을 교체한다.

