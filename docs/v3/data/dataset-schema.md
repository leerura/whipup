# V3 Dataset 스키마

Dataset은 DB numeric ID 대신 stable string key를 사용한다. 배열 순서는 표시 순서의 source of truth다. importer는 key를 DB row로 resolve한다. 식별자는 영문 kebab-case, 사용자 표시 콘텐츠는 한국어를 기본으로 한다. 실제 디렉터리 구조와 importer 동작은 구현 전에 확인하되 이 문서의 필드 의미와 검증 규칙을 바꾸지 않는다.

```text
data/
├── ingredients.json
└── recipes/
    └── {recipe-key}.json
```

## Ingredient catalog

```json
{
  "ingredients": [
    {
      "key": "garlic",
      "name": "마늘",
      "variants": [
        { "key": "whole-garlic", "name": "통마늘", "aliases": [] },
        { "key": "minced-garlic", "name": "다진 마늘", "aliases": [] }
      ],
      "relations": [
        { "source": "whole-garlic", "target": "minced-garlic" }
      ]
    }
  ]
}
```

Rules:

- Ingredient `key` is unique among Ingredients; Variant `key` is globally unique. These are separate namespaces.
- `variants` contains only selectable, concrete owned items. There is no `base` field and no required default item.
- Each group must contain at least one selectable item.
- Same-group multiple selectable items are valid and users may own any combination.
- Group and selectable item may have the same display name when that item is itself a concrete, user-recognizable owned unit.
- `aliases` are strict same-item expressions only. They do not create selectable items or recommendation compatibility.
- Relations are directional preparation relations; `source` and `target` must exist, differ, and belong to the same Ingredient group. Do not infer reverse relations.
- Do not classify new catalog cases by copying the examples. Apply product criteria; unresolved catalog policy is a product decision, not an importer guess.

## Recipe document

```json
{
  "key": "garlic-pork-stir-fry",
  "name": "마늘 삼겹살 볶음",
  "status": "PUBLISHED",
  "shortsReference": "https://youtube.com/shorts/example",
  "ingredients": [
    {
      "key": "soy-sauce",
      "variant": null,
      "acceptedOwnedVariants": ["dark-soy-sauce", "brewed-soy-sauce"],
      "displayName": "간장",
      "rawText": "간장 1큰술",
      "amount": "1",
      "unit": "큰술",
      "optional": false
    },
    {
      "key": "garlic",
      "variant": "minced-garlic",
      "acceptedOwnedVariants": [],
      "displayName": "다진 마늘",
      "rawText": "다진 마늘 한 큰술",
      "amount": "한",
      "unit": "큰술",
      "optional": false
    }
  ],
  "requirements": [
    {
      "options": [
        { "ingredient": "soy-sauce", "substitutes": [], "allowedVariants": [] }
      ]
    },
    {
      "options": [
        { "ingredient": "garlic", "substitutes": [], "allowedVariants": [] }
      ]
    }
  ],
  "steps": ["재료를 넣고 볶는다."]
}
```

### Recipe fields and state

- `status` is `DRAFT` or `PUBLISHED`.
- `ingredients` preserves source facts in display order. `key` is unique within the recipe and is referenced by requirements.
- `variant` is nullable. If present, it is the exact selectable item corresponding to the source expression.
- `acceptedOwnedVariants` is an optional array of selectable Variant keys accepted for this exact source ingredient in this recipe context. Omitted and empty both mean no additional candidates. It may cross Ingredient groups. Duplicate keys and a key equal to `variant` are invalid.
- `displayName` is the concise source-faithful label; `rawText` preserves the ingredient expression as extracted. `amount` and `unit` are nullable strings. `optional` is required boolean.
- `PUBLISHED` required ingredients need an exact `variant` or at least one accepted key. Both may be used together. A required unresolved ingredient is retained in `DRAFT` with no invented mapping.
- Optional ingredients may have source data without an inventory mapping and are excluded from requirements and missingCount.
- Requirements/options/substitutes keep the V2 graph shape. `ingredient` and substitute `ingredient` values are local keys in this recipe. `allowedVariants` contains global selectable Variant keys.
- A single Option is a single requirement; multiple Options in a Requirement are OR. Requirements themselves are AND.
- A published non-optional RecipeIngredient must participate in exactly one Option or Substitute role. Optional ingredients participate in neither.
- No explicit `displayOrder` is stored in JSON; array index is order.

### Allowed Variant and accepted mapping

`allowedVariants` is only for a Recipe Option whose source has an exact `variant`; every allowed key must belong to that same Ingredient group and differ from the exact key. It retains the existing “this recipe also allows another variant in this group” meaning.

`acceptedOwnedVariants` maps a source expression to the actual inventory items that this recipe regards as satisfying it. It is used for generic/contextual source expressions and can include items across groups. It is not an alias, global relation, or substitute. Do not silently move values between these fields.

## Catalog key resolution and validation

Importer prevalidation must fail with a useful path/key error before applying invalid data. It must validate uniqueness and references for all files, relation endpoints, local ingredient keys, requirement role counts, Allowed Variant group constraints, PUBLISHED completeness, and recipe-local accepted candidates. It must not silently create missing Ingredients/Variants or infer mappings from matching display text.

The importer must apply a dataset atomically. Follow existing transaction/sync behavior where compatible, preserve stable-key upsert semantics, and report deleted catalog items still referenced by user inventory. V3 resets business data, so no V2 record conversion or inferred backfill is required. Schema change still uses a new forward DB migration.

## Illustrative data only

Examples above only clarify field relationships; they are not an approved full catalog or a reusable mapping template. In particular, do not extrapolate accepted candidates to other recipes or ingredients. Every recipe-local mapping is independently decided from that recipe's context. If source context is unresolved, keep the recipe DRAFT and leave the mapping incomplete.
