## Flow
```plain text
Dataset Load
→ Schema Validation
→ Cross-reference / Domain Validation
→ Current DB
→ Sync Plan
→ Blocked Delete Check
→ BEGIN
→ Execute
→ Final Integrity Check
→ COMMIT
```
모든 validation 완료 전에는 DB write를 하지 않는다. Write는 단일 transaction이며 실패 시 rollback한다.
## Sync
Full Sync지만 delete-all/reinsert는 하지 않는다.
stable key 기준:
- 같은 key 존재: KEEP 또는 UPDATE, DB ID 유지
- 새 key: INSERT
- Dataset에서 사라짐: DELETE candidate
Dataset key는 외부 identity다. 표시명 변경은 key 변경이 아니다.
key 변경은 old delete + new create다.
## 사용자 데이터
V2 전환 자체는 V1 row migration을 하지 않고 재료/레시피 운영 데이터를 새 Dataset 기준으로 초기화·재적재한다.
일반적인 importer 실행에서는 `USER_INGREDIENT`를 자동 수정/삭제하지 않는다. Variant 삭제가 사용자 보유 데이터에 참조되면 import를 차단한다.
## Delete Blocking
Variant 삭제 시 확인:
- USER_INGREDIENT
- Recipe Ingredient
- Variant Relation
- Allowed Variant
Operational reference는 새 target Dataset 상태를 기준으로 판단한다.
User reference는 전체 import를 block한다.
Recipe가 Dataset에서 제거되면 Recipe와 child를 삭제할 수 있다. 현재 Recipe child ID를 참조하는 user data는 없다.
## Sync Plan
```plain text
CREATE
UPDATE
KEEP
DELETE
BLOCKED_DELETE
```
BLOCKED_DELETE가 하나라도 있으면 write 시작 전에 실패한다.
## Write Order
1. INGREDIENT
2. INGREDIENT_VARIANT
3. INGREDIENT_VARIANT_RELATION
4. RECIPE
5. RECIPE_INGREDIENT
6. RECIPE_STEP
7. RECIPE_REQUIREMENT
8. RECIPE_REQUIREMENT_OPTION
9. RECIPE_REQUIREMENT_SUBSTITUTE
10. RECIPE_REQUIREMENT_ALLOWED_VARIANT
Delete는 역순이다. USER_INGREDIENT는 importer write 대상이 아니다.
Ingredient/Variant/Recipe는 stable key upsert한다.
Recipe child는 delete/rebuild 가능하다.
## Error
가능한 validation error를 한 번에 수집한다.
필드:
- code
- file
- path
- key/value
- message
codes:
- INVALID_SCHEMA
- DUPLICATE_KEY
- UNKNOWN_REFERENCE
- INVALID_REFERENCE
- INVALID_REQUIREMENT
- INVALID_VARIANT_RELATION
- INVALID_ALLOWED_VARIANT
- INVALID_PUBLISHED_RECIPE
- MASTER_DELETE_BLOCKED
AI mapping failure code는 importer error code와 분리한다.
## Success Report
Ingredient/Variant: created / updated / kept / deleted
Recipe: created / synced / deleted
Child count는 성공 report에 포함하지 않는다.

