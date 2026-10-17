## 목표
V2는 사용자의 실제 보유 재료 형태를 더 정확하게 반영하고, 레시피가 요구하는 재료를 DIRECT / PREPARATION / SUBSTITUTE / MISSING으로 설명할 수 있게 한다.
V2에서 모든 식재료의 세부 종류와 문맥별 호환성을 완전히 모델링하려 하지 않는다. 실제 레시피를 충분히 축적하면서 명백한 사용자 혼란을 줄이는 범위까지만 다룬다.
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
DIRECT는 카드에서 굳이 모두 설명하지 않는다. PREPARATION처럼 보유 재료를 손질해 활용할 수 있다는 설명은 Recipe Detail에서 보여주고 카드에서는 생략할 수 있다. SUBSTITUTE처럼 선택 전에 알아야 할 정보는 카드에 보조 정보로 노출할 수 있다.
### 재료 추가해서
`missingCount >= 1`.
MISSING을 1차 정보로 보여준다. 카드의 부족 재료 문구는 `missingCount`에 따라 다음과 같이 요약한다.
- 1개: 부족한 재료명 1개를 직접 표시
- 2개: 부족한 재료명 2개를 모두 표시
- 3개 이상: 앞의 2개 재료명과 나머지 개수를 표시. 예: `양파와 대파 외 2개가 더 필요해요`
PREPARATION의 상세 활용 안내는 Recipe Detail에서 보여준다. 1개 부족/2개 부족 식의 top-level section이나 hard cutoff는 두지 않는다.
## 정렬
- AVAILABLE: `recipeId ASC`
- MISSING_INGREDIENTS: `missingCount ASC, recipeId ASC`
`recipeId ASC`는 추천 의미가 아니라 deterministic ordering 용도다.
## V2 재료 단순화
V2에서는 세부 종류를 구분하는 것이 오히려 추천 오판을 늘리는 재료는 하나의 관리 단위로 단순화할 수 있다.
- 간장은 V2에서 `간장` 하나로 관리하며 진간장/국간장/양조간장 등을 별도 보유 Variant로 나누지 않는다.
- 마늘은 Ingredient `마늘` 아래에 `통마늘`, `다진 마늘`처럼 사용자가 실제 보유 형태로 구분할 가치가 있는 Variant를 둔다.
이 단순화로 해결되지 않는 문맥별 호환성 문제는 V2에서 일반화하지 않는다.
## 범위 밖
V2에서는 취향/클릭/조리 이력 기반 개인화 추천 점수를 설계하지 않는다. 이런 신호가 생기면 정렬 정책을 교체한다.
또한 모든 식재료의 세부 종류, 조리 역할, 문맥별 대체 가능성을 일반화한 완전한 compatibility 모델은 V2 범위에 포함하지 않는다.
