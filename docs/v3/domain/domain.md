# V3 도메인 규칙

이 문서는 보유 재료, 레시피 원문 재료, 요구 충족 판단의 의미와 규칙을 정의한다. 직렬화 형식은 [Dataset 스키마](../data/dataset-schema.md), 저장 구조는 [데이터 모델](erd.md), 외부 동작은 [API 계약](../api/api-specification.md)을 따른다.

## 핵심 개념

### Ingredient group과 selectable owned item

`Ingredient`는 재료 탐색을 위한 그룹이고, `IngredientVariant`는 사용자가 실제 보유 단위로 선택하고 등록하는 항목이다. 이 도메인에서 “보유 재료”는 selectable item을 뜻한다. 그룹 제목은 자동으로 선택 항목이 되지 않으며, 그룹에는 선택 항목이 하나 이상 있을 수 있고 별도의 기본 항목은 없다.

그룹/항목의 이름이 같아도 항목이 그 이름으로 실제 보유할 수 있는 구체 단위라면 둘 다 존재할 수 있다. 반대로 그룹명이 포괄 개념이라면 같은 이름의 owned item을 만들지 않을 수 있다. 이는 각 재료의 사용자 인식과 보유 관리 필요에 따라 편집하는 카탈로그 결정이다. 모든 그룹에 동일한 분류 공식을 적용하지 않는다. 사례는 [제품 결정](../product/product.md)의 비일반화 원칙을 따른다.

사용자는 같은 그룹에서 서로 다른 selectable item을 동시에 보유할 수 있다. 같은 selectable item을 중복 등록하는 것은 허용하지 않는다.

### RecipeIngredient: source fact

`RecipeIngredient`는 레시피 원문에 있는 재료 표현 및 표시 근거를 보존한다. 이는 재료 카탈로그 항목과 동일 개념이 아니며, `variant`가 없어도 유효하다. `displayName`, `rawText`, 양, 단위, optional 여부는 원문에 근거해 저장한다. source 표현을 canonical owned item 이름으로 덮어쓰지 않는다.

### Accepted owned item: recipe-local 판정

각 필수 `RecipeIngredient`에는 해당 재료 요구를 충족할 수 있다고 그 레시피 맥락에서 판단한 owned item을 0개 이상 연결할 수 있다. 한 source ingredient가 여러 보유 item으로 충족될 수 있고, 한 owned item이 여러 레시피에서 서로 다른 source 표현을 충족할 수 있다. 연결은 레시피별이며 전역 Alias/Relation로 전파되지 않는다. 서로 다른 Ingredient group의 owned item도 연결할 수 있다.

이 연결은 정확한 source 정규화와 별개다. `variant`는 source가 특정 owned item과 정확히 대응한다고 판단된 경우에만 사용한다. `acceptedOwnedVariants`는 문맥에 따른 수용 가능 집합이며 exact identity를 주장하지 않는다. 둘 다 지정되면 exact 항목도 충족 후보에 포함되고, accepted 집합은 추가 후보를 나타낸다. 중복 항목은 허용하지 않는다.

맥락을 검토해도 필수 source ingredient에 충족 후보를 확정할 수 없으면 미해결 상태로 둔다. 미해결 필수 요구가 하나라도 있는 Recipe는 `DRAFT`이며 추천·상세 공개 대상이 아니다. 런타임은 미해결 후보를 추측하거나 AI로 보충하지 않는다.

## 기존 기능과의 경계

- **Alias**: 같은 owned item의 동의 표현을 정규화한다. 상위/포괄 표현이나 문맥 의존 호환성을 표현하지 않는다.
- **Global Variant Relation**: 한 보유 형태를 명시적인 손질·준비를 거쳐 다른 형태로 만드는 방향 관계다. 역방향·동일 그룹이라는 이유만으로 성립하지 않는다.
- **Accepted owned item mapping**: 특정 레시피 source ingredient를 충족하는 보유 항목의 recipe-local 판정이다. 전역 호환성을 만들지 않는다.
- **Allowed Variant**: 기존 Recipe Option의 정확한 owned item 대신 허용되는 동일 Ingredient group의 selectable item이다. accepted mapping과 별도 필드/의미로 유지한다.
- **Substitute**: 기존 Recipe Option에 선언된 fallback source ingredient다. OR option이나 accepted mapping으로 평탄화하지 않는다.

## 요구 구조와 충족 판정

필수 단위는 `Requirement`다. Requirement의 Option은 OR이며, 여러 Requirement는 모두 충족되어야 한다. 각 Option은 원본 RecipeIngredient와 0개 이상의 Substitute를 가진다. Optional RecipeIngredient는 Requirement/Option/Substitute 역할에 참여하지 않고 추천의 missingCount에도 포함되지 않는다.

각 Option의 inventory 후보는 아래 순서로 계산한다. 같은 owned item이 여러 경로에 해당하면 더 높은 우선순위 유형 한 번만 반환한다.

1. **DIRECT**: 원본 RecipeIngredient의 exact `variant`, `acceptedOwnedVariants`, 그리고 Option의 `allowedVariants`에 속하는 owned item과 일치한다.
2. **PREPARATION**: 직접 일치가 없을 때, 보유 item에서 허용 후보 방향으로 이어지는 global Relation이 한 단계 존재한다.
3. **SUBSTITUTE**: 직접/준비 일치가 없을 때, 해당 Option의 선언된 Substitute RecipeIngredient의 exact/accepted owned item과 직접 일치한다. 기존처럼 Substitute 자체에는 preparation relation을 적용하지 않는다.
4. **MISSING**: 위 경로에 해당하지 않는다.

위의 우선순위는 Option 단위이며 V2 코드의 동작을 유지한다. OR Requirement에서 하나 이상의 Option이 충족되면 Requirement는 SATISFIED이며, 충족한 모든 Option의 유효 match를 보존한다. 한 Option 안에서 원본과 Substitute가 함께 충족되면 원본/직접 및 준비 경로를 우선하여 Substitute 경로를 추가하지 않는다. 이 규칙은 recipe-local 후보 집합을 기존 직접/준비 판정에 포함한다.

보유 항목이 accepted 집합 중 여러 개에 해당하면 각각을 유효 match로 보존한다. 서버는 실제 보유 항목의 이름과 source 표현의 이름을 각각 응답한다. 클라이언트는 재료 관계를 다시 해석하지 않는다.

Recommendation의 `missingCount`는 충족하지 못한 필수 Requirement 수다. `AVAILABLE`은 0, `MISSING_INGREDIENTS`는 1 이상이다. `DRAFT`는 두 모드 모두 제외한다.

## Publish 불변조건

`PUBLISHED` Recipe는 모든 필수 source ingredient의 충족 판정을 완료해야 한다. 각 필수 ingredient는 아래 둘 중 하나 이상을 가져야 한다.

- 정확한 `variant` 연결
- 한 개 이상의 `acceptedOwnedVariants`

동시에 exact와 accepted 연결을 가질 수 있다. 중복된 동일 variant는 금지한다. Optional ingredient에는 exact/accepted 연결을 둘 수 있지만, Requirement 참가가 없으므로 추천 충족에 사용되지 않는다. DRAFT는 불완전하거나 검토 중인 source 및 판정을 보존할 수 있다.

PUBLISHED의 비선택 optional=false RecipeIngredient는 정확히 하나의 Requirement Option 또는 Substitute 역할에 참가한다. Option과 Substitute는 같은 Recipe 안의 ingredient만 참조한다. Requirement에는 한 개 이상 Option이 있어야 한다.

## 판정 예시의 범위

제품 문서의 재료 예시는 각 상황에서의 판단 원리를 보여준다. 목록 전체나 다른 재료 분류의 선례가 아니다. 새로운 group, item, source-to-owned 연결은 위 개념과 제품 문서의 사용자 관리 기준으로 개별 판단한다. 기준으로 결론을 낼 수 없으면 파이프라인 운영 또는 제품 결정으로 되돌리고 임의 분류하지 않는다.
