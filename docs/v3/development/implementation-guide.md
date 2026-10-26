# V3 구현 영향과 완료 기준

이 문서는 V3 명세를 코드 작업으로 옮길 때의 범위 및 확인 기준이다. 제품 의미는 [domain](../domain/domain.md), 논리 저장 구조는 [ERD](../domain/erd.md), fixture/data contract는 [Dataset](../data/dataset-schema.md), 외부 계약은 [API](../api/api-specification.md)를 따른다. 구현자는 이 문서와 링크된 V3 규격만으로 구현 의도를 파악할 수 있어야 한다. 현재 코드는 구현 위치와 기존 관례를 확인하는 자료이며 V3 결정을 덮어쓰지 않는다.

## 영향 범위

### Ingredient catalog와 inventory

- Ingredient group 응답 및 선택 화면은 그룹과 selectable item을 이미 구분하는 구조를 유지한다.
- inventory unique key는 user + selectable variant이며, 같은 group의 서로 다른 variant 보유를 계속 허용한다.
- catalog와 importer에서 `is_base`/기본 variant 전제를 제거한다. group 자체가 선택 가능한지는 카탈로그 item 목록으로만 표현한다.
- group 제목은 보유 수량/선택 상태를 가진 inventory row로 취급하지 않는다. UX 원칙은 [재료 등록 UX](../ux/ux.md)를 따른다.

### Recipe data와 matching

- RecipeIngredient의 source text/표시/양/단위와 optional 의미를 보존한다.
- nullable exact variant를 유지하면서 recipe-local accepted variant collection을 추가한다.
- Dataset importer, domain/entity mapping, recommendation match 계산을 모두 이 collection을 읽도록 변경한다.
- Match 우선순위와 Requirement/Option/Substitute graph 동작은 [domain 규칙](../domain/domain.md)을 따른다. 임의로 priority를 바꾸거나 Requirement를 평탄화하지 않는다.
- PUBLISHED completeness validation은 exact OR accepted 후보 존재를 검사한다. DRAFT는 미해결 required mapping을 허용하고 추천에서 제외한다.
- API DTO 외형은 유지하되 `requiredName`은 source display, `ownedName`은 실제 inventory item으로 반환한다.

## Migration 및 dataset 재구성

- V2 사업 데이터를 초기화할 예정이므로 V2 RecipeIngredient를 새 후보 집합으로 추론 backfill하지 않는다.
- 실행된 migration을 수정하지 않는다. 새 forward migration에서 base column/제약 제거와 accepted mapping relation 저장 구조를 추가한다.
- 현재 실제 DB명, ORM mapping, migration framework, importer transaction 전략을 확인하고 V3 논리 모델에 맞춘다. 논리 테이블명과 구현 명칭을 억지로 일치시키려 별도 architecture를 만들지 않는다.
- 새 catalog/dataset을 기준으로 importer validation과 API를 연결한다. importer는 잘못된 key/reference를 조용히 무시하거나 문자열 유사도로 추측하지 않는다.

### 로컬 개발 DB 초기화

V3 개발 전환은 기존 데이터를 변환하지 않고 로컬 Compose PostgreSQL 볼륨 전체를 제거해 새 DB와 V3 schema를 만든다. 계정, 인증 정보, 보유 재료, 레시피를 포함한 해당 Compose 프로젝트의 DB 데이터가 모두 사라진다. 다른 프로젝트의 볼륨과 저장소의 dataset 파일은 삭제하지 않는다.

저장소 루트에서 아래 명령을 실행하면 확인 절차를 통과한 경우에만 현재 저장소의 Compose 프로젝트를 내리고 그 프로젝트 볼륨을 제거한 뒤, backend와 PostgreSQL을 다시 빌드/시작한다. Flyway가 처음부터 migration을 적용한다.

```sh
ALLOW_WHIPUP_LOCAL_DB_RESET=YES ./scripts/reset-v3-local-db.sh
```

이 스크립트는 의도적으로 dataset import를 실행하지 않는다. V2 business dataset은 제거했으며 현재 `data/`에 V3 catalog와 recipe fixture가 아직 없다. V3 catalog와 recipe dataset을 준비하고 validator를 통과시킨 뒤 `make import-data`로 넣는다. 초기화 후 dataset을 넣기 전에는 앱이 사용자/재료/레시피 데이터 없이 실행된다.

### 외부 API 접근

- Windows 개발 서버의 backend(`8080`) 앞에 Compose의 Caddy HTTPS reverse proxy를 둔다. 외부 클라이언트는 공유기의 공인 IPv4 주소를 HTTPS로 사용하고 Caddy가 내부 backend로 전달한다.
- Caddy는 Let’s Encrypt ACME의 `shortlived` 프로필로 공인 IP 인증서를 발급하고 자동 갱신한다. IP 인증서는 160시간만 유효하므로 Caddy의 `/data` 인증서 저장소를 Compose named volume에 영구 보존하고 Caddy 컨테이너를 상시 실행한다. TLS-ALPN 검증을 사용하고 HTTP challenge 및 HTTP redirect는 사용하지 않는다. IP로 접속하는 일부 TLS 클라이언트가 SNI를 보내지 않으므로 Caddy의 `default_sni`를 현재 공인 IP로 설정한다.
- 공유기에는 공인 TCP 443을 Windows 서버의 TCP 443으로 전달하고 Windows 방화벽에서도 TCP 443 인바운드를 허용해야 한다. 이 단계는 Whippy API를 인터넷에서 접근 가능하게 한다. Windows backend나 노트북이 꺼져 있으면 API도 사용할 수 없다.
- 현재 확인된 공인 IPv4는 `121.171.81.225`이며 회선은 유동 IP다. 주소가 바뀌면 `.env`의 `WHIPUP_PUBLIC_IP`, 공유기 전달 대상 설정(Windows 내부 IP가 바뀐 경우), 그리고 앱의 release 빌드 값을 갱신해야 한다. 고정 주소를 보장하지 않는다.
- iOS 실기기 debug 빌드는 기존 로컬 설정 주소를 사용한다. iOS 실기기 release 빌드는 `WHIPUP_API_BASE_URL` 빌드 값으로 받은 HTTPS 주소만 사용하며, 값이 없거나 HTTP이면 시작 오류로 드러낸다. 시뮬레이터의 로컬 개발 주소는 유지한다.
- 공개 API 주소는 앱 빌드에 전달한다. 서버 `.env`와 Caddy 인증서 private key는 저장소에 올리지 않는다.
- 완료 확인은 Caddy가 공인 IP용 신뢰 인증서를 획득했는지, 외부 HTTPS 요청이 backend 응답을 받는지, release 앱이 같은 주소로 API에 연결되는지로 한다.

Windows 서버 `.env`에 `WHIPUP_PUBLIC_IP=121.171.81.225`를 설정한다. iPhone release 실행과 App Store용 빌드에는 현재 공인 IP를 HTTPS URL로 전달한다.

```sh
cd app
flutter run --release -d <device-id> --dart-define=WHIPUP_API_BASE_URL=https://121.171.81.225
flutter build ipa --dart-define=WHIPUP_API_BASE_URL=https://121.171.81.225
```

## 검증 시나리오

구현 검증은 기존 test framework와 repository convention에 맞춰 아래 행동을 확인한다.

1. 한 group에 selectable item이 여러 개이고 base가 없어도 dataset validation 및 ingredient 목록 응답이 성공한다.
2. 한 사용자가 같은 group의 서로 다른 두 item을 보유할 수 있고, 정확히 같은 item의 중복 등록은 기존 중복 오류를 반환한다.
3. source 표현이 포괄적이고 accepted 후보에 서로 다른 group의 item 여러 개가 있는 경우 어느 후보든 보유하면 DIRECT SATISFIED가 된다. Match의 required/owned 이름이 각각 source/owned label을 보존한다.
4. 레시피 상세에서 요구명과 매치된 owned item명이 다르면 요구명은 그대로 두고 owned item명을 보조 문구로 노출한다. 두 이름이 같으면 중복 안내를 만들지 않는다.
5. accepted 후보 집합에 하나도 일치하지 않으면 미충족이다. 같은 이름 또는 group 소속만으로 자동 충족하지 않는다.
6. exact/accepted direct match가 preparation/substitute보다 우선하고, direct가 없을 때만 방향성 preparation을 판정한다. 역방향 관계는 매치되지 않는다.
7. accepted 후보를 준비해 얻는 target이 있으면 PREPARATION으로 판정한다. 한 단계보다 긴 전이 추론을 새로 추가하지 않는다.
8. 한 Option 안에서 original과 substitute가 함께 충족될 때 domain 우선순위가 적용되고, Substitute 자체에는 preparation relation이 적용되지 않는다. 서로 다른 OR Option이 충족되면 requirement는 satisfied다.
9. 필수 미매핑 source가 있는 PUBLISHED dataset은 거부되고, 동일 Recipe가 DRAFT이면 저장되지만 recommendations 및 detail API에서 노출되지 않는다.
10. optional ingredient는 missingCount/Requirement 결과에 추가되지 않는다. accepted 후보는 구매 후보 목록을 늘리지 않는다.
11. 기존 API JSON shape, 정렬, error contract, authentication이 회귀하지 않는다.

적절한 검증은 도메인 matcher, importer validator, API/integration 경계를 기존 코드 구조에 따라 선택한다. 테스트가 내부 구현 세부를 복제하는 데 그치지 않고 위의 관찰 가능한 결과를 확인해야 한다.

## 완료 전 리뷰

- V3 docs와 일치하는지, 특히 `base` 가정과 global compatibility 추측이 남지 않았는지 확인한다.
- 신규 migration 외에 과거 적용 migration이 수정되지 않았는지 확인한다.
- importer가 V3 fixture를 검증/적용하고, 잘못된 fixture는 진단 가능한 오류로 거부하는지 확인한다.
- 추천 및 detail endpoint에서 DRAFT 제외, count/sort, response shape가 유지되는지 확인한다.
- 관련 테스트 및 repository 필수 검증을 수행하고 최종 diff에서 unrelated change를 제거한다.

## 별도 작업 명세

Gemini 단일 추출, 저장된 결과의 Codex 반영, quota retry, Compose 실행과 checkpoint 요구사항은 [V3 recipe pipeline 명세](recipe-pipeline.md)를 따른다. 이 문서와 pipeline 명세에 없는 V2 절차를 구현 요구로 가져오지 않는다.
