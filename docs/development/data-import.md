# Operational Data Import

초기 및 MVP 운영 단계의 Ingredient Master / Recipe 데이터를 Repository에서 관리하고 PostgreSQL에 Bulk Import하는 규칙을 정의한다.

관리자 HTTP CRUD API는 MVP에서 만들지 않는다. 대량 editorial data를 Flyway Migration에 넣지도 않는다.

---

# Dataset Location

```plain text
project-root/
└── data/
    ├── ingredients.csv
    └── recipes/
        ├── dubu-jorim-001.json
        ├── kimchi-bokkeumbap-001.json
        └── ...
```

Dataset은 Git으로 변경 이력을 관리한다.

---

# Ingredient Dataset

MVP Ingredient Master는 canonical Ingredient만 관리하므로 단일 `ingredients.csv`를 사용한다.

## Ingredient CSV Schema

`data/ingredients.csv`는 현재 서비스가 알고 있는 canonical Ingredient 목록만 저장한다.

```javascript
canonical_name
간장
계란
김치
깨
마늘
배추
삼겹살
소시지
양배추
양파
파스타면
```

컬럼은 MVP에서 다음 하나만 사용한다.

| Column | Required | Description |
| --- | --- | --- |
| `canonical_name` | Y | 서비스에서 사용하는 canonical Ingredient 이름 |

규칙:

- UTF-8 CSV를 사용한다.
- 첫 번째 row는 header다.
- `canonical_name`은 필수이며 빈 문자열을 허용하지 않는다.
- import 전에 앞뒤 공백을 trim한다.
- trim 이후 동일한 `canonical_name`의 중복을 허용하지 않는다.
- `canonical_name`은 DB의 `INGREDIENT.canonical_name`과 대응하며 DB에서도 UNIQUE다.
- canonical Ingredient의 식별을 위한 별도 dataset key는 MVP에서 만들지 않는다.
- CSV는 사람이 검토하기 쉽도록 `canonical_name` 가나다순 정렬을 기본 규칙으로 한다.
- Ingredient Category, Ingredient Form, Alias는 MVP Ingredient Dataset에서 관리하지 않는다.
- `다진 마늘`, `편마늘`, `참깨`, `대패삼겹살`, `진간장`, `비엔나소시지`, `알배추`, `스파게티면` 같은 실제 표현은 별도 canonical Ingredient로 저장하지 않고 가능한 경우 기존 canonical Ingredient에 매핑한다.
- canonical 기준은 단순한 이름의 상하위 관계가 아니라 추천에서 같은 재료를 보유했다고 간주해도 되는 수준인지로 판단한다. 예: `진간장 → 간장`, `비엔나소시지 → 소시지`, `알배추 → 배추`, `스파게티면 → 파스타면`.
- 서로 다른 실제 재료는 억지로 합치지 않는다. 예: `양배추`와 `배추`, `햄`과 `소시지`, `베이컨`과 `소시지`는 별도 canonical Ingredient로 관리한다.
- 실제 영상/레시피 표현은 Recipe Dataset의 `displayName`, `rawText`에 보존한다.
- 향후 필요성이 확인되면 canonical Ingredient를 기준으로 Form, Category, Alias 등의 별도 Dataset/테이블을 추가할 수 있다.

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

## Recipe Ingredient Master Reference

Recipe Dataset은 확정된 `data/ingredients.csv`의 Ingredient Master를 기준으로 작성한다.

- Recipe의 `canonicalIngredient`는 반드시 `data/ingredients.csv`에 존재하는 `canonical_name` 중 하나여야 한다.
- `canonicalIngredient`는 `canonical_name`과 정확히 일치해야 한다.
- Recipe 생성 또는 Import 과정에서 새로운 canonical Ingredient를 자동 생성하거나 Ingredient Master를 수정하지 않는다.
- 기존 Ingredient Master에 매핑할 canonical Ingredient가 없으면 해당 Recipe는 validation에 실패한다.
- 새로운 canonical Ingredient가 필요하면 먼저 `ingredients.csv`를 수정하여 Ingredient Master를 확정한 뒤 Recipe를 다시 작성하거나 검증한다.
- `canonical_name`은 현재 Ingredient Dataset의 natural key이므로 이름을 변경하면 이를 참조하는 Recipe JSON의 `canonicalIngredient`도 함께 변경해야 한다.

예를 들어 Ingredient Master에 `간장`만 존재하고 `진간장`은 존재하지 않는다면 Recipe는 원본 표현을 보존하면서 canonical 값은 `간장`을 참조한다.

```json
{
  "canonicalIngredient": "간장",
  "displayName": "진간장",
  "rawText": "진간장 2스푼",
  "amount": "2",
  "unit": "스푼"
}
```

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
Canonical Ingredient mapping
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

최신 상세 동작은 아래 `Dataset Import Contract`를 따른다.

- Ingredient Master는 `ingredients.csv` 기준 전체 동기화한다.
- Recipe는 `dataset_key` 기준으로 insert/update하며 child data는 현재 JSON 기준 Replace한다.
- Recipe Dataset에서 제거된 Recipe는 DB에서도 삭제한다.
- 전체 Dataset을 먼저 검증하며 하나라도 실패하면 DB를 변경하지 않는다.
- 전체 DB synchronization은 하나의 transaction으로 처리하며 오류 시 전체 rollback한다.

---

# Minimum Recipe Validation

Published로 import하려는 Recipe는 최소 다음을 만족해야 한다.

- dataset key 존재
- recipe name 존재
- YouTube Shorts reference 존재
- 하나 이상의 Recipe Ingredient 존재
- 모든 Recipe Ingredient가 canonical Ingredient에 mapping됨
- 모든 `canonicalIngredient`가 현재 `data/ingredients.csv`의 `canonical_name`에 존재하고 정확히 일치함
- display name 존재
- ingredient display order 유효
- 하나 이상의 Recipe Step 존재
- step order 유효

`amount`, `unit`은 nullable이다.

---

# Execution

Importer는 Spring Boot 애플리케이션 시작 시 자동 실행하지 않는다. 개발자/운영자가 의도적으로 `make import-data`를 실행할 때만 동작한다.

Makefile은 Docker Compose 기반 local PostgreSQL에 연결되는 backend Import Command의 진입점을 제공한다. 정확한 내부 Spring/Gradle 실행 방식은 코드 구조에 맞게 정할 수 있으며 HTTP Admin API로 노출하지 않는다.

---

# Schema vs Content

```plain text
Flyway
→ table / column / index / constraint / schema history

Dataset + Bulk Importer
→ canonical Ingredient / Recipe editorial content
```

대량 Recipe/Ingredient content를 Flyway SQL migration에 넣지 않는다.

---

# Dataset Import Contract

이 절은 MVP 개발 환경의 deterministic Dataset Import 구현 명세다.

## Source of Truth

MVP 개발 환경의 운영 데이터 Source of Truth는 Repository Dataset이다.

- Ingredient Master: `data/ingredients.csv`
- Recipe Dataset: `data/recipes/*.json`

PostgreSQL의 Ingredient / Recipe editorial data를 직접 관리하지 않는다. Dataset을 수정한 뒤 Import Command를 실행해 DB에 반영한다. 이 정책은 MVP 개발용이며 실서비스 배포 이후의 운영 데이터 관리 방식은 별도로 설계한다.

## Responsibility Boundary

AI / Gemini의 책임은 Validated Dataset 생성까지다. DB 반영은 AI를 호출하지 않는 deterministic Import Command가 수행한다.

Ingredient CSV / Recipe JSON → 전체 Validation → Import Command → PostgreSQL.

Importer는 PostgreSQL Docker Volume을 직접 조작하지 않는다. 일반적인 PostgreSQL connection을 통해 write하고, 실제 영속화는 PostgreSQL container와 `postgres_data` volume이 담당한다.

## Recipe Dataset → Database Mapping

### RECIPE

- `key → dataset_key`
- `name → name`
- `shortsReference → shorts_reference`
- import된 Recipe의 `status = PUBLISHED`
- `recipe_id`는 DB에서 생성한다.

### RECIPE_INGREDIENT

- `canonicalIngredient → INGREDIENT.canonical_name` 조회 후 `ingredient_id`
- `displayName → display_name`
- `rawText → raw_text`
- `amount → amount`
- `unit → unit`
- ingredients 배열의 index + 1 → `display_order`
- `mappingStatus`는 Pipeline/Dataset validation metadata이며 DB에 저장하지 않는다.

### RECIPE_STEP

- steps 배열의 index + 1 → `step_order`
- step String → `content`

## Full Dataset Validation

DB 변경 전에 **전체 Dataset을 먼저 검증**한다. 하나라도 실패하면 Import 전체를 중단하고 DB를 변경하지 않는다.

Ingredient Dataset은 CSV header `canonical_name`, blank/trim 후 빈 값 금지, canonical_name 중복 금지를 검증한다.

Recipe Dataset은 key 존재 및 전체 중복 금지, name/shortsReference 존재, ingredients/steps 비어 있지 않음, 모든 `mappingStatus = MAPPED`, canonicalIngredient 존재 및 현재 Ingredient Dataset에 존재, 동일 Recipe 내 canonicalIngredient 중복 금지, displayName/rawText 존재를 검증한다. amount와 unit은 nullable이다.

## Transaction Policy

모든 Validation이 성공한 이후 DB synchronization을 시작한다. **전체 Dataset Import를 하나의 transaction으로 처리**한다. DB constraint violation 또는 예상하지 못한 오류가 발생하면 전체 transaction을 rollback하며 부분 Import 상태를 허용하지 않는다.

## Ingredient Full Synchronization

`data/ingredients.csv`는 Ingredient Master 전체의 Source of Truth다. Import 완료 후 DB의 INGREDIENT는 CSV와 동기화되어야 한다.

- CSV에 있고 DB에 없으면 INSERT
- CSV와 DB 모두에 있으면 유지
- DB에 있지만 CSV에 없으면 DELETE

Importer는 Ingredient 삭제 때문에 참조 데이터를 자동 수정하거나 삭제하지 않는다. 삭제 대상 Ingredient를 USER_INGREDIENT 또는 기타 데이터가 참조하지 않도록 Dataset 관리자가 직접 보장한다. FK constraint 때문에 삭제할 수 없으면 Import 전체를 실패시키고 rollback한다.

## Recipe Synchronization

Recipe는 `dataset_key`를 식별자로 사용한다. DB에 동일한 dataset_key가 없으면 RECIPE와 현재 Dataset의 RECIPE_INGREDIENT / RECIPE_STEP을 INSERT한다.

DB에 동일한 dataset_key가 있으면 RECIPE 기본 정보를 UPDATE하고, 기존 RECIPE_INGREDIENT와 RECIPE_STEP을 각각 DELETE한 뒤 현재 Dataset 기준으로 다시 INSERT한다. Recipe child data는 현재 JSON을 기준으로 Replace한다.

**Repository의 `data/recipes/*.json`에 존재하지 않는 기존 DB Recipe는 DELETE한다.** 따라서 Recipe Dataset 역시 현재 DB에 존재해야 하는 Recipe 전체의 Source of Truth다. Recipe 삭제 시 기존 child row는 ERD의 delete policy에 따라 함께 제거된다.

## Execution Interface

전체 Dataset Import의 개발자 진입점은 다음으로 통일한다.

```bash
make import-data
```

단건 Recipe import는 MVP에서 제공하지 않는다. `make import-data`는 Docker Compose 기반 local PostgreSQL에 연결되는 backend Import Command를 실행한다. Makefile은 실행 진입점만 제공하며, 내부 Spring/Gradle 실행 방식은 구현 구조에 맞게 결정할 수 있다. HTTP Admin API로 노출하지 않는다.
