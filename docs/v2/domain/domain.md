## Ingredient / Variant
`Ingredient`는 canonical identity다. 예: 마늘, 삼겹살, 양파.
사용자가 실제로 등록하고 보유하는 단위는 `IngredientVariant`다. Base도 Variant다.
예:
- Ingredient: 마늘
- Variants: 마늘(base), 다진 마늘
- Ingredient: 삼겹살
- Variants: 삼겹살(base), 대패삼겹살
형태가 다르다는 이유만으로 Variant를 만들지 않는다. 형태 차이를 무시했을 때 레시피 가능 여부에 의미 있는 오판이 생기고 사용자가 별도 보유 단위로 인식할 가치가 있을 때만 분리한다.
같은 Ingredient의 여러 Variant를 동시에 보유할 수 있다.
## Ingredient 표현 Alias
레시피 원문에서 쓰는 표현과 사용자가 관리하는 재료 이름이 항상 같을 필요는 없다.
Alias는 **동일한 재료를 가리키는 표현 차이**를 기존 Variant에 정규화하기 위한 mapping 정보다. Alias 자체는 사용자가 등록하는 별도 Variant가 아니며, 추천 Matching에도 독립적인 의미를 추가하지 않는다.
대표 예:
- 레시피 표현 `깨` → Variant `참깨`
- 레시피 표현 `참깨` → Variant `참깨`
사용자 보유 재료에는 `깨`와 `참깨`를 둘 다 노출하지 않고 `참깨`만 등록 가능한 항목으로 제공한다. `rawText` / source evidence에는 원래 표현인 `깨`를 그대로 보존할 수 있다.
Alias는 의미가 사실상 같은 표현에만 사용한다. 문맥에 따라 구체 종류가 달라질 수 있는 상위 표현을 특정 Variant의 Alias로 고정하지 않는다. 예를 들어 `간장 → 진간장`, `파 → 대파`를 기본 Alias로 취급하지 않는다.
## Variant Relation
방향성 있는 변환 가능 관계만 관리한다.
```plain text
마늘 -> 다진 마늘
```
역방향은 자동으로 성립하지 않는다. Relation에 Action/type/message를 저장하지 않는다. 같은 Ingredient라는 이유만으로 호환하지 않는다.
## Recipe Requirement
필수 재료 판정 단위는 Recipe Ingredient가 아니라 Requirement다.
지원:
- Single Requirement
- OR Requirement
- Recipe-declared Substitute
- Recipe-context Allowed Variant
- Optional Ingredient
Optional은 Requirement와 missingCount에서 제외한다.
## Option / Substitute
OR의 Option은 동등한 선택지다. Substitute는 특정 Option의 fallback이다.
예:
```plain text
Option A: 알룰로스
  Substitute: 설탕
OR
Option B: 올리고당
```
이를 `알룰로스 또는 설탕 또는 올리고당`으로 평탄화하지 않는다.
## Allowed Variant
Recipe가 Requirement의 원재료 대신 같은 Ingredient의 다른 Variant를 그대로 허용하는 경우 Option에 recipe-context Allowed Variant를 연결한다.
예:
- Requirement 원재료: 마늘
- 실제 조리 흐름상 다진 마늘도 그대로 사용 가능
- allowed variant: 다진 마늘
이는 global `다진 마늘 -> 마늘` Relation을 만들지 않는다.
## Matching
Requirement는 다음 방식으로 충족될 수 있다.
- DIRECT: exact Variant 또는 Allowed Variant
- PREPARATION: global Variant Relation을 통해 준비 가능
- SUBSTITUTE: Recipe-declared Substitute
- MISSING: 어떤 경로로도 충족되지 않음
OR에서 여러 Option을 동시에 충족하면 가능한 Match를 모두 보존한다.
한 Option에서 원재료와 Substitute를 모두 보유하면 원재료를 우선하고 Substitute Match는 생략한다.
## Recipe 판정
모든 Requirement가 만족하면 AVAILABLE이다.
하나라도 만족하지 않으면 MISSING_INGREDIENTS 대상이다.
`missingCount`는 만족하지 못한 Requirement 수다.
## Domain 원칙
- Runtime AI가 매칭 가능성을 판단하지 않는다.
- 불확실한 경우 자동으로 만족 처리하지 않는다.
- Server가 매칭을 계산하며 Flutter가 Domain graph를 재해석하지 않는다.
