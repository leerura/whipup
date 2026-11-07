# V3 데이터 모델

이 모델은 [도메인 규칙](domain.md)의 의미를 관계형 저장소에 반영한다. 표기는 논리 모델이며 실제 SQL 타입/명명은 기존 migration convention을 따른다.

## Ingredient catalog와 user inventory

```text
INGREDIENT
  id PK
  key UNIQUE NOT NULL
  canonical_name UNIQUE NOT NULL

INGREDIENT_VARIANT
  id PK
  key UNIQUE NOT NULL
  ingredient_id FK -> INGREDIENT.id NOT NULL
  name NOT NULL
  UNIQUE(ingredient_id, name)

USER_INGREDIENT
  id PK
  user_id FK NOT NULL
  ingredient_variant_id FK -> INGREDIENT_VARIANT.id NOT NULL
  created_at NOT NULL
  UNIQUE(user_id, ingredient_variant_id)

INGREDIENT_VARIANT_ALIAS
  ingredient_variant_id FK -> INGREDIENT_VARIANT.id NOT NULL
  alias NOT NULL
  PRIMARY KEY(ingredient_variant_id, alias)

INGREDIENT_VARIANT_RELATION
  source_variant_id FK -> INGREDIENT_VARIANT.id NOT NULL
  target_variant_id FK -> INGREDIENT_VARIANT.id NOT NULL
  PRIMARY KEY(source_variant_id, target_variant_id)
  CHECK(source_variant_id <> target_variant_id)
```

V3에서 `INGREDIENT_VARIANT.is_base`와 Ingredient당 base 1개 제약을 제거한다. Group에 유일한 기본 selectable item은 없다. Alias와 Relation은 기존 의미를 유지한다. Relation의 양 끝은 같은 Ingredient group이어야 하며 importer/application validator가 보장한다.

## Recipe source와 inventory 후보

```text
RECIPE
  id PK
  key UNIQUE NOT NULL
  status NOT NULL  -- DRAFT | PUBLISHED
  ...existing recipe fields

RECIPE_INGREDIENT
  id PK
  recipe_id FK -> RECIPE.id NOT NULL
  key NOT NULL    -- recipe-local stable key
  ingredient_variant_id FK -> INGREDIENT_VARIANT.id NULL
  display_name NOT NULL
  raw_text NOT NULL
  amount NULL
  unit NULL
  display_order NOT NULL
  is_optional NOT NULL
  UNIQUE(recipe_id, key)

RECIPE_INGREDIENT_ACCEPTED_VARIANT
  recipe_ingredient_id FK -> RECIPE_INGREDIENT.id NOT NULL
  ingredient_variant_id FK -> INGREDIENT_VARIANT.id NOT NULL
  PRIMARY KEY(recipe_ingredient_id, ingredient_variant_id)
```

`RECIPE_INGREDIENT.ingredient_variant_id`는 exact match다. 새 join table은 source ingredient별 recipe-local accepted owned item을 저장한다. Accepted variant는 어떤 Ingredient group에서든 올 수 있다. `variant`와 accepted variant가 같으면 중복이므로 금지한다. `DRAFT`에서는 둘 다 비어 있을 수 있고, `PUBLISHED`의 필수 source에는 exact 또는 accepted mapping이 최소 하나 있어야 한다.

## Requirement graph

```text
RECIPE_REQUIREMENT
  id PK
  recipe_id FK -> RECIPE.id NOT NULL
  display_order NOT NULL
  UNIQUE(recipe_id, display_order)

RECIPE_REQUIREMENT_OPTION
  id PK
  requirement_id FK -> RECIPE_REQUIREMENT.id NOT NULL
  recipe_ingredient_id FK -> RECIPE_INGREDIENT.id NOT NULL
  display_order NOT NULL
  UNIQUE(requirement_id, recipe_ingredient_id)
  UNIQUE(requirement_id, display_order)

RECIPE_REQUIREMENT_SUBSTITUTE
  id PK
  requirement_option_id FK -> RECIPE_REQUIREMENT_OPTION.id NOT NULL
  recipe_ingredient_id FK -> RECIPE_INGREDIENT.id NOT NULL
  display_order NOT NULL
  UNIQUE(requirement_option_id, recipe_ingredient_id)
  UNIQUE(requirement_option_id, display_order)

RECIPE_REQUIREMENT_ALLOWED_VARIANT
  requirement_option_id FK -> RECIPE_REQUIREMENT_OPTION.id NOT NULL
  ingredient_variant_id FK -> INGREDIENT_VARIANT.id NOT NULL
  PRIMARY KEY(requirement_option_id, ingredient_variant_id)
```

Allowed Variant는 Option 원본의 exact `ingredient_variant_id`와 같은 Ingredient의 다른 Variant여야 한다. Exact variant가 없는 generic source ingredient에는 Allowed Variant를 둘 수 없다. 이 상황은 accepted mapping으로 표현한다.

## 무결성 검증 책임

DB는 PK/FK/UNIQUE 및 source != target을 강제한다. Dataset importer/application validator는 다음을 검증한다.

- 각 Relation source와 target이 같은 Ingredient group인지.
- published 필수 RecipeIngredient의 exact/accepted 후보가 최소 하나인지, exact-accepted 중복이 없는지.
- accepted/Allowed Variant/Relation이 실제 selectable variant key인지.
- Allowed Variant가 원본 exact variant와 같은 group의 다른 variant인지.
- 각 Requirement에 Option이 하나 이상이고, 모든 관계가 같은 Recipe 안의 ingredient인지.
- Optional ingredient가 Requirement 또는 Substitute 역할에 참여하지 않는지.
- published non-optional RecipeIngredient가 정확히 하나의 Option 또는 Substitute 역할에 참여하는지.
- DRAFT가 미완성 매핑을 포함할 수 있고 추천 대상 쿼리가 PUBLISHED만 반환하는지.

## V2에서의 DB 변경 범위

V2 user inventory의 고유성 제약은 동일 selectable variant 중복만 막으며, 같은 그룹의 서로 다른 variant 보유는 이미 가능하다. V3 migration은 base 의미 제거, recipe-local accepted variant 관계 추가, 관련 인덱스/FK 추가가 핵심이다. V2 업무 데이터는 재구성 대상이므로 데이터 행 backfill은 하지 않는다. 이미 적용된 migration 파일을 편집하지 말고 신규 forward migration을 추가한다. 실제 테이블/컬럼명은 코드 확인 후 이 논리 모델에 맞춰 migration을 작성한다.
