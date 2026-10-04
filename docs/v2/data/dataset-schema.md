## 구조
```plain text
data/
├─ ingredients.json
└─ recipes/
   └─ {recipe-key}.json
```
Dataset은 DB numeric ID를 사용하지 않고 stable string key를 사용한다. Importer가 key를 DB row로 resolve한다.
식별자는 영문 kebab-case, 사용자 표시 콘텐츠는 한국어를 사용한다.
## ingredients.json
```json
{
  "ingredients": [
    {
      "key": "garlic",
      "name": "마늘",
      "variants": [
        { "key": "garlic", "name": "마늘", "base": true, "aliases": [] },
        { "key": "minced-garlic", "name": "다진 마늘", "base": false, "aliases": [] }
      ],
      "relations": [
        { "source": "garlic", "target": "minced-garlic" }
      ]
    }
  ]
}
```
규칙:
- Ingredient key는 Ingredient namespace에서 unique
- Variant key는 전체 Variant에서 unique
- Ingredient key와 Variant key는 별도 namespace이므로 같은 문자열 사용 가능
- Ingredient당 base Variant 정확히 1개
- Relation source/target 존재
- source != target
- source/target 같은 Ingredient
- Relation은 방향성
- Variant의 `aliases`는 recipe source 표현을 기존 Variant로 정규화하기 위한 문자열 배열
- Alias는 사용자 등록 항목을 추가하지 않으며 추천 Matching 관계로 사용하지 않음
- Alias는 의미가 사실상 같은 표현에만 등록하며 context-dependent 상위 표현은 특정 Variant Alias로 고정하지 않음
- category/form/action은 두지 않음
Alias 예:
```json
{
  "key": "sesame-seed",
  "name": "참깨",
  "base": true,
  "aliases": ["깨"]
}
```
이 경우 Recipe source의 `깨`는 `참깨` Variant에 mapping할 수 있지만 사용자가 등록하는 재료 항목에는 `참깨`만 노출한다.
## Recipe JSON
```json
{
  "key": "garlic-pork-stir-fry",
  "name": "마늘 삼겹살 볶음",
  "status": "PUBLISHED",
  "shortsReference": "https://youtube.com/shorts/example",
  "ingredients": [],
  "requirements": [],
  "steps": []
}
```
status는 기존 코드와 맞춰 `DRAFT | PUBLISHED`를 사용한다.
## Recipe Ingredient
```json
{
  "key": "sauce-garlic",
  "variant": "garlic",
  "displayName": "마늘",
  "rawText": "마늘 3알",
  "amount": "3",
  "unit": "알",
  "optional": false
}
```
- Recipe-local key
- 같은 Variant를 여러 번 사용할 수 있음
- DRAFT에서는 variant nullable
- PUBLISHED에서는 variant 필수
- amount/unit은 nullable string
- optional은 필수 boolean
## Requirement
```json
{
  "options": [
    {
      "ingredient": "garlic",
      "substitutes": [],
      "allowedVariants": ["minced-garlic"]
    }
  ]
}
```
- Requirement key/type은 두지 않음
- options 최소 1개
- ingredient/substitutes는 Recipe Ingredient local key
- allowedVariants는 global Variant key
- optional Recipe Ingredient는 참여 금지
- substitute != original
- allowed variant는 original과 같은 Ingredient의 다른 Variant
PUBLISHED에서 optional=false Recipe Ingredient는 정확히 하나의 Option 또는 Substitute role에 참여해야 한다.
## Steps
```json
[
  "팬을 달군다.",
  "재료를 넣고 볶는다."
]
```
배열 순서가 step_order다.
## Ordering
Dataset의 ordered array가 유일한 순서 Source of Truth다. JSON에 displayOrder를 중복 저장하지 않는다. Importer가 배열 index를 DB display_order/step_order로 변환한다.
