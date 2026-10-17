## INGREDIENT
```plain text
id BIGINT PK
key VARCHAR NOT NULL UNIQUE
canonical_name VARCHAR NOT NULL UNIQUE
```
## INGREDIENT_VARIANT
```plain text
id BIGINT PK
key VARCHAR NOT NULL UNIQUE
ingredient_id BIGINT NOT NULL FK
name VARCHAR NOT NULL
is_base BOOLEAN NOT NULL
UNIQUE(ingredient_id, name)
```
Ingredient당 Base Variant는 정확히 하나다. Importer/Application validation으로 보장한다.
## USER_INGREDIENT
```plain text
id BIGINT PK
user_id BIGINT FK
ingredient_variant_id BIGINT FK
created_at TIMESTAMPTZ
UNIQUE(user_id, ingredient_variant_id)
```
## INGREDIENT_VARIANT_RELATION
```plain text
source_variant_id BIGINT FK
target_variant_id BIGINT FK
PRIMARY KEY(source_variant_id, target_variant_id)
CHECK(source_variant_id <> target_variant_id)
```
Importer가 source/target이 같은 Ingredient인지 검증한다.
## RECIPE_INGREDIENT
```plain text
id BIGINT PK
recipe_id BIGINT FK
ingredient_variant_id BIGINT NULL FK
display_name VARCHAR NOT NULL
raw_text VARCHAR NOT NULL
amount VARCHAR NULL
unit VARCHAR NULL
display_order INTEGER NOT NULL
is_optional BOOLEAN NOT NULL DEFAULT FALSE
```
DRAFT에서는 Variant가 null일 수 있다. PUBLISHED에서는 모든 Recipe Ingredient가 Variant에 매핑되어야 한다.
## RECIPE_REQUIREMENT
```plain text
id BIGINT PK
recipe_id BIGINT FK
display_order INTEGER NOT NULL
UNIQUE(recipe_id, display_order)
```
## RECIPE_REQUIREMENT_OPTION
```plain text
id BIGINT PK
requirement_id BIGINT FK
recipe_ingredient_id BIGINT FK
display_order INTEGER NOT NULL
UNIQUE(requirement_id, recipe_ingredient_id)
UNIQUE(requirement_id, display_order)
```
Option 1개면 Single, 2개 이상이면 OR다.
## RECIPE_REQUIREMENT_SUBSTITUTE
```plain text
id BIGINT PK
requirement_option_id BIGINT FK
recipe_ingredient_id BIGINT FK
display_order INTEGER NOT NULL
UNIQUE(requirement_option_id, recipe_ingredient_id)
UNIQUE(requirement_option_id, display_order)
```
## RECIPE_REQUIREMENT_ALLOWED_VARIANT
```plain text
requirement_option_id BIGINT FK
ingredient_variant_id BIGINT FK
PRIMARY KEY(requirement_option_id, ingredient_variant_id)
```
Allowed Variant는 원 Option과 같은 Ingredient의 다른 Variant여야 한다.
## DB / Application Validation 경계
DB:
- PK / FK
- explicit UNIQUE
- source != target
Importer/Application:
- Ingredient당 Base Variant 정확히 1개
- Variant Relation source/target 같은 Ingredient
- Requirement에 Option 최소 1개
- Recipe consistency
- Optional Ingredient는 Requirement/ Substitute에 참여하지 않음
- PUBLISHED Recipe의 모든 Recipe Ingredient 매핑 완료
- Allowed Variant는 같은 Ingredient이며 original과 다름

