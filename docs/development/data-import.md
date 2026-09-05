# Operational Data Import

초기 및 MVP 운영 단계의 Ingredient Master / Recipe 데이터를 Repository에서 관리하고 PostgreSQL에 Bulk Import하는 규칙을 정의한다.

관리자 HTTP CRUD API는 MVP에서 만들지 않는다. 대량 editorial data를 Flyway Migration에 넣지도 않는다.

---

# Dataset Location

```plain text
project-root/
└── data/
    ├── ingredients.csv
    ├── ingredient-categories.csv
    ├── ingredient-category-mappings.csv
    ├── ingredient-forms.csv
    └── recipes/
        ├── dubu-jorim-001.json
        ├── kimchi-bokkeumbap-001.json
        └── ...
```

Dataset은 Git으로 변경 이력을 관리한다.

---

# Ingredient Dataset

Ingredient Master는 단순한 tabular data이므로 CSV를 사용한다.

canonical name은 import 전에 trim한다. canonical Ingredient의 식별은 별도 dataset key를 만들지 않고 `canonical_name` natural key를 사용하며 DB에서도 unique다.

Ingredient Category는 canonical Ingredient와 N:M 관계이므로 Ingredient row에 단일 `category_code`를 넣지 않고 별도 Dataset으로 관리한다.

```plain text
ingredients.csv
→ canonical Ingredient Master

ingredient-categories.csv
→ Category Master (`code`, `display_name`, `sort_order`)

ingredient-category-mappings.csv
→ canonical Ingredient ↔ Category N:M mapping

ingredient-forms.csv
→ canonical Ingredient ↔ Form Type ↔ display name
```

예를 들어 `ingredient-category-mappings.csv`에는 같은 Ingredient가 여러 번 등장할 수 있다.

```javascript
ingredient,category
김치,VEGETABLE
김치,PROCESSED
두부,TOFU_BEAN
두부,PROCESSED
삼겹살,MEAT
```

Ingredient Form은 별도 Category mapping을 가지지 않고 canonical Ingredient의 Category를 따른다. Primary Category는 두지 않는다. 실제 CSV column schema의 세부 사항은 importer 구현 직전에 이 문서에 최종 확정한다.

---

# Recipe Dataset

Recipe는 ingredients와 steps가 중첩되므로 JSON을 사용한다. Recipe 하나를 하나의 JSON 파일로 관리한다.

개념 예시:

```json
{
  "key": "dubu-jorim-001",
  "name": "두부조림",
  "shortsReference": "https://youtube.com/shorts/example",
  "ingredients": [
    {
      "canonicalIngredient": "두부",
      "form": null,
      "displayName": "두부",
      "rawText": "두부 1모",
      "amount": "1",
      "unit": "모"
    }
  ],
  "steps": [
    "두부를 먹기 좋은 크기로 썬다.",
    "양념을 넣고 졸인다."
  ]
}
```

`key`는 Recipe Dataset stable key다. DB의 `RECIPE.dataset_key`와 연결하며 UNIQUE다. Recipe name은 unique하지 않다.

Recipe Ingredient의 배열 순서는 사용자에게 표시할 순서이며 import 시 `display_order`로 저장한다. Recipe Step 배열 순서는 `step_order`로 저장한다.

`amount`, `unit`은 둘 다 nullable이다. `displayName`과 `rawText`는 보존한다.

Recipe thumbnail은 Dataset에서 별도 이미지 파일로 관리하지 않는다. YouTube Shorts reference를 기준으로 thumbnail을 가져온다.

---

# Draft Workflow

```plain text
YouTube Shorts URL
  ↓
AI extraction
  ↓
Draft JSON file
  ↓
Human review / correction
  ↓
Canonical Ingredient / Form mapping
  ↓
Validation
  ↓
Validated Dataset
  ↓
Bulk Import
  ↓
PUBLISHED Recipe
```

AI 결과를 자동으로 Published Recipe로 만들지 않는다. 검수 중 Draft는 기본적으로 파일에 존재하며 invalid/incomplete Draft는 DB에 저장하지 않는다.

DB의 `DRAFT` status는 향후 운영 확장을 위해 허용하지만 MVP 기본 importer workflow에서는 사용하지 않아도 된다.

---

# Import Behavior

## Recipe Upsert

`dataset_key` 기준으로 idempotent upsert한다.

- DB에 key가 없으면 insert
- DB에 같은 key가 있으면 update
- 같은 Dataset을 여러 번 실행해도 Recipe가 계속 중복 생성되지 않아야 한다.

## Deletion

Dataset 파일이 삭제되었다는 이유만으로 DB Recipe를 자동 삭제하지 않는다. Importer는 insert/update를 담당한다. Recipe 삭제가 필요하면 별도의 명시적인 작업으로 수행한다.

## Failure Unit

한 Recipe의 validation/import가 실패해도 다른 정상 Recipe의 import는 계속한다. 실패한 Recipe는 DB에 반영하지 않고 실행 결과에 실패 파일/key와 원인을 명확히 출력한다.

부분적으로 불완전한 하나의 Recipe를 저장하지 않는다.

---

# Minimum Recipe Validation

Published로 import하려는 Recipe는 최소 다음을 만족해야 한다.

- dataset key 존재
- recipe name 존재
- YouTube Shorts reference 존재
- 하나 이상의 Recipe Ingredient 존재
- 모든 Recipe Ingredient가 canonical Ingredient에 mapping됨
- Ingredient Form이 있으면 해당 canonical Ingredient 소속 Form임
- display name 존재
- ingredient display order 유효
- 하나 이상의 Recipe Step 존재
- step order 유효

`amount`, `unit`은 nullable이다.

---

# Execution

Importer는 Spring Boot 애플리케이션 시작 시 자동 실행하지 않는다. 개발자/운영자가 의도적으로 실행하는 **명시적 CLI/command** 형태로 제공한다.

정확한 Gradle task 또는 Spring command 구현 방식은 코드 구조에 맞게 정할 수 있지만, HTTP Admin API로 노출하지 않는다.

---

# Schema vs Content

```plain text
Flyway
→ table / column / index / constraint / schema history

Dataset + Bulk Importer
→ Ingredient / Ingredient Category / Category Mapping / Ingredient Form / Recipe editorial content
```

대량 Recipe/Ingredient content를 Flyway SQL migration에 넣지 않는다.
