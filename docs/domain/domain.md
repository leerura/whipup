# Domain

WhipUp의 핵심 도메인은 **사용자의 현재 보유 재료와 레시피의 필요 재료를 같은 canonical Ingredient 기준으로 비교하여 추천하는 것**이다.

MVP 추천은 단순하게 유지한다. Form 정보는 향후 형태/전처리 호환성 판단을 확장하기 위한 구조적 준비이며, **현재 추천 판단에는 canonical Ingredient만 사용한다.**

---

# Core Concepts

## User

서비스의 일반 사용자.

- 카카오 계정을 통해 식별한다.
- 자신의 보유 재료를 가진다.
- 사용자별 보유 재료는 서로 분리된다.
- 취향, 알레르기, 식단, 개인화 설정은 MVP에서 관리하지 않는다.

## Ingredient

추천 계산과 재료 연결에 사용하는 **canonical ingredient**다.

예:

```plain text
마늘
양파
삼겹살
치킨스톡
```

`다진 마늘`, `편마늘`, `통마늘`처럼 형태가 포함된 표현을 별도 Ingredient로 만들지 않는다.

```plain text
다진 마늘 ─┐
편마늘   ─┼─→ 마늘
통마늘   ─┘
```

같은 canonical Ingredient에 연결된다는 것은 추천 비교 기준이 같다는 의미다. 서로 다른 형태가 실제 조리에서 항상 호환된다는 의미는 아니다.

사용자는 서비스에서 관리하는 Ingredient만 보유 재료로 등록할 수 있으며 임의의 Ingredient를 생성할 수 없다.

## Ingredient Category

Ingredient Master를 사용자가 탐색하기 위한 분류 메타데이터다.

- 하나의 canonical Ingredient는 하나 이상의 Category에 속할 수 있다.
- 하나의 Category에는 여러 Ingredient가 속할 수 있으므로 Ingredient와 Category는 N:M 관계다.
- Category는 식품학적으로 하나의 정답을 강제하기 위한 분류가 아니라 재료 탐색과 표시를 위한 분류다.
- 같은 Ingredient가 여러 Category 화면에 나타나는 것을 허용한다.
- Ingredient Form은 별도의 Category를 가지지 않고 canonical Ingredient의 Category를 그대로 따른다.
- 대표 Category(primary category)는 MVP에서 두지 않는다.
- Category는 Recommendation 계산에 사용하지 않는다.
- `자주 쓰는 재료`, 인기순, 사용자별 사용 빈도는 Category와 별개의 개념이며 MVP 모델에 포함하지 않는다.

## Ingredient Form

canonical Ingredient의 구체적인 형태를 표현한다.

```plain text
Ingredient: 마늘
Form: MINCED
→ 다진 마늘

Ingredient: 마늘
Form: SLICE
→ 편마늘
```

Form은 `Form Type`과 `Ingredient Form`으로 구분한다.

- `Form Type` — `WHOLE`, `SLICE`, `MINCED`, `THIN_SLICE` 같은 공통 형태 vocabulary
- `Ingredient Form` — 특정 Ingredient와 Form Type의 조합. 예: `마늘 + MINCED = 다진 마늘`

Form 모델은 향후 형태/전처리 호환성 판단을 확장하기 위한 구조적 준비이면서, **MVP 재료 등록과 표시에도 사용한다.** 사용자는 canonical Ingredient 자체 또는 서비스에 등록된 Ingredient Form을 보유 재료로 등록할 수 있다. 다만 MVP에서는 Form 간 변환 가능 여부나 호환성을 판단하지 않는다.

## Owned Ingredient

특정 User가 현재 보유하고 있는 재료다.

- canonical Ingredient는 필수다.
- Ingredient Form은 선택적으로 가질 수 있다.
- 수량, 중량, 용량은 관리하지 않는다.
- 추가와 삭제만 가능하며 다른 재료로 수정하지 않는다.
- 마지막 보유 재료도 삭제할 수 있다.
- 조미료도 동일하게 취급한다.

같은 canonical Ingredient라도 서로 다른 Form이라면 별도의 보유 상태로 존재할 수 있다.

```plain text
User
├─ 삼겹살 + THIN_SLICE
└─ 삼겹살 + BLOCK
```

하지만 MVP 추천에서는 둘 다 canonical `삼겹살`을 보유한 것으로만 판단한다.

## Recipe

서비스에서 추천과 상세 조회에 사용하는 레시피다.

주요 정보:

- 레시피명
- YouTube Shorts reference
- Recipe Ingredients
- Recipe Steps
- 상태 (`DRAFT` / `PUBLISHED`)

사용자에게 제공되는 Recipe는 반드시 `PUBLISHED` 상태여야 한다.

조리 난이도, 조리 시간, 칼로리, 영양 정보, 즐겨찾기, 대체 재료, 선택 재료는 MVP Recipe 모델에 포함하지 않는다.

## Recipe Ingredient

Recipe를 조리하는 데 필요한 하나의 재료 항목이다.

추천을 위한 canonical 정보와 실제 조리를 위한 표현을 분리한다.

```plain text
canonical Ingredient: 마늘
Ingredient Form: MINCED
실제 표현: 다진 마늘
필요량: 1큰술
```

실제 조리 표현은 canonicalization 이후에도 보존한다.

같은 Recipe 안에서 여러 Recipe Ingredient가 같은 canonical Ingredient에 연결될 수 있다.

```plain text
다진 마늘 1큰술 → 마늘 + MINCED
편마늘 5알      → 마늘 + SLICE
```

이 경우 Recipe Ingredient는 두 개지만 MVP 추천에서 필요한 canonical Ingredient `마늘`은 한 번만 계산한다.

필요량은 사용자에게 조리 정보를 제공하기 위한 값이며 추천 판단에는 사용하지 않는다.

## Recipe Step

Recipe의 순서가 있는 조리 단계다.

- 조리 순서
- 조리 내용

Step별 시간, 온도, 조리 도구, Ingredient 연결, 타이머는 MVP에서 관리하지 않는다.

## Recipe Draft

MVP의 기본 운영 workflow에서는 AI가 생성한 Recipe Draft와 검수 중 데이터는 **Repository Dataset 파일**에서 관리한다. 불완전한 Draft를 DB에 넣지 않고, 사람이 검수하고 canonical mapping을 확정한 데이터만 Bulk Import한다.

DB의 Recipe lifecycle에는 향후 운영 확장을 위해 `DRAFT` / `PUBLISHED` 상태를 허용한다. 즉 DB가 DRAFT를 표현할 수는 있지만 MVP 기본 importer는 검증 실패/미완성 Draft를 저장하지 않는다.

```plain text
AI Draft File
  ↓ 운영자 검토 / 수정
  ↓ Ingredient mapping
  ↓ validation
Validated Dataset
  ↓ Bulk Import
PUBLISHED Recipe
```

AI 또는 시스템은 Ingredient mapping을 제안할 수 있지만 최종 판단은 운영자가 한다.

## Recommendation

User의 현재 Owned Ingredients와 Recipe의 Required Ingredients를 비교하여 **조회 시점에 계산되는 값**이다.

Recipe 자체에 `100% 가능`, `1개 부족` 같은 상태를 저장하지 않는다. 같은 Recipe라도 User 또는 보유 재료가 달라지면 추천 결과가 달라진다.

Recommendation 결과에는 다음 정보가 포함될 수 있다.

- Recipe
- Missing Ingredients
- Missing Count
- Classification

---

# Recommendation Rules

## Comparison

MVP에서는 Form, 수량, 전처리 상태를 무시하고 **고유 canonical Ingredient 집합만 비교한다.**

```plain text
Owned = DISTINCT User Owned canonical Ingredients
Required = DISTINCT Recipe Required canonical Ingredients

Missing = Required - Owned
Missing Count = COUNT(Missing)
```

예를 들어 Recipe에 다음 두 항목이 있어도:

```plain text
다진 마늘 1큰술 → 마늘
편마늘 5알      → 마늘
```

사용자가 `마늘`을 보유하지 않았다면 Missing Count는 `2`가 아니라 `1`이다.

동일 User가 `다진 마늘`과 `편마늘`을 모두 보유하더라도 추천에서는 `마늘`을 한 번 보유한 것으로 취급한다.

## Classification

```plain text
Missing Count = 0 → 100% 가능
Missing Count = 1 → 재료 1개 부족
Missing Count = 2 → 재료 2개 부족
Missing Count ≥ 3 → 추천 제외
```

User가 Recipe에 필요하지 않은 Ingredient를 추가로 가지고 있는 것은 결과에 영향을 주지 않는다.

조미료에도 같은 규칙을 적용한다. 필요한 조미료를 보유 재료로 등록하지 않았다면 Missing Ingredient로 계산한다.

## Ignored in MVP

추천 판단에 다음 정보는 사용하지 않는다.

- 실제 보유 수량
- 중량 / 용량
- Recipe 필요량 충족 여부
- Ingredient Form
- preparation / processing state
- Form 간 호환성
- 재료 중요도
- 필수 / 선택 재료 구분
- 대체 가능한 재료 관계

따라서 사용자가 `통마늘`을 보유하고 Recipe가 `편마늘`을 요구하더라도 canonical Ingredient가 모두 `마늘`이면 MVP에서는 충족으로 판단한다. 실제 조리에 적합하지 않은 경우가 추천될 수 있으며 이는 현재 MVP에서 허용하는 단순화다.

---

# Recipe Publication Rules

`PUBLISHED` Recipe는 다음 조건을 모두 만족해야 한다.

- 레시피명이 존재한다.
- 원본 YouTube Shorts reference가 존재한다.
- 하나 이상의 Recipe Ingredient가 존재한다.
- 모든 Recipe Ingredient가 canonical Ingredient와 연결되어 있다.
- 각 Recipe Ingredient의 실제 조리 표현이 존재한다.
- `amount`, `unit`은 둘 다 nullable이며 레시피 원문에 값이 있을 때 저장한다.
- Recipe Ingredient의 표시 순서가 유효하다.
- 하나 이상의 Recipe Step이 존재하고 순서가 정의되어 있다.
- 운영자가 내용을 검토하고 최종 확정했다.

`DRAFT`에서는 위 조건이 일부 충족되지 않아도 된다.

AI 분석 실패나 불완전한 Draft는 기존 Published Recipe에 영향을 주지 않는다.

Published Recipe를 수정한 뒤에도 위 조건을 만족해야 한다. 삭제된 Recipe는 이후 추천과 상세 조회 대상에서 제외한다.

---

# Ingredient Mapping Rules

운영자가 Recipe의 실제 재료 표현을 canonical Ingredient와 연결한다.

```plain text
다진 마늘 → 마늘       O
편마늘 → 마늘          O

대체 가능한 A → B      X
```

- 표현이 달라도 동일한 실제 재료라면 같은 canonical Ingredient에 연결할 수 있다.
- 같은 canonical Ingredient라는 이유만으로 Form 간 조리 호환성을 보장하지 않는다.
- 단순히 서로 대체 가능하다는 이유로 서로 다른 재료를 하나의 Ingredient로 합치지 않는다.
- 적절한 Ingredient가 없으면 운영자가 Ingredient Master에 추가한다.
- 잘못된 Ingredient 정보는 운영자가 수정할 수 있다.

---

# Invariants

구현에서 항상 유지해야 하는 조건이다.

1. Owned Ingredient는 반드시 서비스의 canonical Ingredient와 연결된다.
2. `PUBLISHED` Recipe의 모든 Recipe Ingredient는 canonical Ingredient와 연결된다.
3. `PUBLISHED` Recipe는 레시피명, Shorts reference, 하나 이상의 Ingredient, 하나 이상의 Step을 가진다.
4. Recipe Ingredient의 사용자 표시 순서는 Dataset에서 검수된 배열 순서를 보존한다.
5. Recommendation은 현재 User의 보유 상태와 현재 Published Recipe를 기준으로 계산한다.
6. Missing Count는 부족한 **고유 canonical Ingredient 개수**다.
7. Form 정보는 MVP 재료 등록/표시에 사용하지만 Recommendation 결과에는 영향을 주지 않는다.
8. 하나의 Ingredient는 하나 이상의 Category에 속할 수 있으며 Category는 Recommendation 결과에 영향을 주지 않는다.
9. Ingredient Form은 canonical Ingredient의 Category를 상속하며 별도 Category mapping을 가지지 않는다.
10. 서로 다른 Ingredient의 대체 가능성을 canonicalization으로 표현하지 않는다.

---

# Domain Relationships

```plain text
User
└─ Owned Ingredient
   ├─ Ingredient
   └─ Ingredient Form (optional)

Ingredient
├─ Ingredient Category (N:M)
└─ Ingredient Form
   └─ Form Type

Recipe
├─ Recipe Ingredient
│  ├─ Ingredient
│  ├─ Ingredient Form (optional)
│  ├─ 실제 조리 표현
│  └─ 필요한 양
├─ Recipe Step
└─ YouTube Shorts reference

User Owned Ingredients
        +
Recipe Required Ingredients
        ↓
Recommendation (calculated)
```

DB의 실제 테이블, 컬럼, nullable/unique/delete 정책은 `erd.md`를 따른다.
