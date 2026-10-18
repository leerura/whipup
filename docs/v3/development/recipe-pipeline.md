# V3 레시피 데이터 파이프라인

이 문서는 Gemini 무료 API로 재료와 레시피를 추출하고 결과를 저장하는 로컬 작업 흐름을 정의한다. 사용자가 별도로 에이전트에게 요청하면 에이전트가 브라우저로 원본 영상을 확인하고 초안을 검증·수정해 최종 dataset에 반영한다. 제품 판단은 [V3 제품 결정](../product/product.md), 데이터 형식은 [Dataset schema](../data/dataset-schema.md)를 따른다. 이 문서는 V2 pipeline을 이어 쓰라는 지시가 아니며, 아래 완료 조건에 필요한 기존 코드는 단순화하거나 교체할 수 있다.

## 확정된 운영 방식

- MacBook에서 필요할 때 Docker Compose pipeline 서비스만 수동 실행한다. macOS launchd, GitHub Actions, Windows 상시 실행은 사용하지 않는다.
- pipeline은 실행 중 `tools/data-pipeline/input/shorts-urls.txt`를 반복해서 확인해 새 URL을 처리한다. 빈 줄과 `#` 주석 줄은 건너뛴다. 제외할 URL은 목록에서 지우거나 다른 파일로 옮기는 대신 주석 처리할 수 있다.
- Compose 실행은 pipeline 서비스만 대상으로 한다. 일반적인 backend 및 PostgreSQL 서비스를 함께 시작하지 않는다.
- 사용자가 URL 목록, 진행 기록, Gemini 중간 결과와 최종 dataset을 Git 저장소에 남긴다. pipeline은 자동 commit/push하지 않는다.
- 컨테이너나 Mac이 종료되면 저장된 상태와 중간 결과를 기준으로 다음 Compose 실행에서 미완료 단계부터 계속한다.

## 영상별 처리 흐름

1. URL 목록에서 주석이 아니며 아직 완료되지 않은 URL을 찾는다. 같은 YouTube video ID는 한 번만 처리한다.
2. Gemini가 Stage 1 재료 추출을 실행하고 결과를 저장한다.
3. Stage 1 완료 뒤 별도 사람 승인 없이 Gemini Stage 2 레시피 구성을 실행한다. 레시피 단계는 Stage 1 재료 결과를 입력으로 사용한다. 단, V3 catalog가 아직 없거나 비어 있거나 유효하지 않으면 Stage 1 결과를 보존하고 `WAITING_CATALOG`로 대기한다. V3 catalog가 준비되면 Stage 1을 다시 호출하지 않고 Stage 2부터 이어간다.
4. 자동 추출은 영상별 상태에 `REVIEW_PENDING`으로 저장하고 멈춘다. pipeline은 에이전트를 호출하거나 dataset에 초안을 자동 반영하지 않는다.
5. 사용자가 에이전트에게 별도로 검토를 요청한다. 에이전트는 브라우저에서 원본 영상을 실제로 확인하고 초안의 재료, 근거, 레시피 내용을 검증·수정한다. 새 재료 item/group이 필요하면 [제품 기준](../product/product.md)에 따라 판단한다.
6. 검토 에이전트는 검증 결과와 수정된 catalog/recipe를 저장소의 최종 dataset에 반영한다. 영상에 접근할 수 없거나 의미가 불명확하면 추측하지 않고 recipe를 `DRAFT`로 남긴다. 최소 구조 검사는 dataset 반영 전 수행한다.

Stage 1과 Stage 2는 모두 Gemini 추출 단계다. Stage 1은 사람 승인 대기 단계가 아니다. 별도의 AI 재검증 단계를 추가하지 않는다.

## 검증 범위

사용자가 요청한 에이전트 검증은 영상과 Gemini 초안 사이의 의미상 근거, V3 recipe requirement와 owned-item 연결의 합리성, 새 catalog item/group 판단을 다룬다. 에이전트가 브라우저로 영상을 확인하며, 영상에서 합리적으로 결론을 낼 수 없으면 `DRAFT`로 남긴다. 에이전트 호출과 dataset 반영은 Gemini worker 바깥의 수동 단계다.

결정적 검사는 dataset 반영에 필요한 최소 오류만 차단한다.

- 결과 JSON 및 필수 필드의 파싱 여부
- Stage 1 source item과 Stage 2 Recipe Ingredient 간 누락·중복·잘못된 참조
- recipe와 catalog가 참조하는 key가 실제로 존재하는지
- PUBLISHED recipe에 unresolved required mapping이 남지 않았는지

결정적 검사는 별도의 의미 추론이나 recipe 재판정을 하지 않는다. 에이전트 영상 검증을 대신하지 않는다.

## 진행 상태와 저장

각 URL의 Stage 1 결과, Stage 2 결과, 검증 결과, 현재 단계, 오류 또는 다음 재시도 시각을 저장소 안에 보존한다. 저장 형식은 영상별 처리 상태와 중간 결과가 중복 manifest/raw/approved/review 파일 여러 묶음에 흩어지지 않도록 단일한 추적 구조로 단순화한다. 단계 결과를 저장한 뒤 다음 단계로 이동해 중단·재시작 후 완료된 Gemini 요청을 반복하지 않는다.

V3 catalog가 없거나 비어 있거나 스키마 검사를 통과하지 못해도 worker는 Stage 1 결과를 저장할 수 있다. Stage 2는 호출하지 않고 `WAITING_CATALOG` 상태로 보존하며, 실행 중에는 설정된 polling 간격으로 catalog를 다시 확인한다. polling 중 무한 busy loop를 만들지 않는다. 구 catalog의 V2 `base` 필드는 V3 catalog로 인정하지 않는다.

입력 URL을 주석 처리해도 이미 저장된 기록을 자동으로 지우지 않는다. pipeline은 기록을 정리하거나 URL을 목록에서 제거하지 않는다.

## 무료 Gemini quota와 재시도

- 무료 tier의 Gemini GenerateContent API를 사용한다. 유료 Batch API나 자동 유료 모델 fallback을 추가하지 않는다.
- 한 번에 하나의 영상 흐름을 처리해 분당 한도를 불필요하게 넘기지 않는다. 두 Gemini 단계를 순서대로 호출한다.
- 응답에 `RetryInfo.retryDelay`가 있으면 그 대기 시간을 사용한다.
- 오류 내용이 일일 quota 초과를 나타내면 다음 Pacific Time 자정까지 대기한다.
- 429지만 재시각과 quota 구분이 없으면 1분, 5분, 15분 간격으로 최대 3회 다시 시도한다. 계속 실패하면 실패 처리로 작업을 버리지 않고 다음 Pacific Time 자정까지 대기한다.
- 일시 네트워크 오류 또는 5xx도 즉시 반복하지 않고 최대 3회 간격을 두고 재시도한다. 재시도 후에도 실패하면 오류와 미완료 단계를 저장해 다음 실행에서 재개할 수 있게 한다.
- quota 대기는 Compose 프로세스가 살아 있는 동안 자동으로 이어진다. 대기 중 프로세스나 Mac이 종료된 경우에도 재시도 시각을 보존하고 다음 Compose 실행에서 너무 일찍 재호출하지 않는다.

Gemini quota는 모델·프로젝트별 RPM, TPM, RPD로 달라지고 RPD는 Pacific Time 자정에 초기화된다. API가 정확한 RetryInfo를 매번 제공한다고 가정하지 않는다. active limit은 AI Studio에서 확인하며 코드에 무료 quota 수치를 고정하지 않는다.

## 실행 인터페이스

Compose에 기존 `backend`/`postgres`와 독립적인 `recipe-pipeline` 서비스를 둔다. 작업자가 사용할 인터페이스는 다음처럼 간단해야 한다.

```sh
docker compose up -d recipe-pipeline
docker compose logs -f recipe-pipeline
docker compose stop recipe-pipeline
```

서비스 실행 중 URL 목록이 갱신되면 자동으로 새 항목을 처리한다. `docker compose up`에서 backend와 PostgreSQL까지 함께 켜야 하는 구조를 만들지 않는다.

## 완료 조건 및 선행 gate

- `shorts-urls.txt`에 URL을 추가하면 실행 중인 서비스가 자동 감지하고 Gemini Stage 1 → Stage 2를 수행한다.
- URL이 주석 처리되면 새 작업으로 실행하지 않는다. 중복 URL은 video ID 기준으로 한 번만 처리한다.
- 각 단계의 저장 이후 컨테이너를 종료하고 다시 실행해도 완료된 Gemini 단계를 다시 호출하지 않는다.
- Gemini worker는 두 단계를 완료한 뒤 `REVIEW_PENDING` 상태와 결과를 저장하며, 에이전트 검증이나 dataset 반영을 자동 실행하지 않는다.
- 사용자가 요청한 에이전트가 브라우저에서 영상을 확인하고 검증·수정한 결과만 최종 catalog 및 recipe dataset에 반영한다.
- 영상 접근 불가, 모호한 의미 판단, 미해결 필수 재료는 `DRAFT`로 남고 추천 가능한 published dataset에 들어가지 않는다.
- 구조 검사 실패는 원인을 기록하고 잘못된 dataset 반영을 막는다.
- 429 및 일시 오류 재시도 정책과 재개 동작을 테스트한다. 실제 Gemini 요청을 사용하지 않는 테스트로 quota 지연과 checkpoint 복구를 검증한다.
- 실제 영상 검토는 사용자가 요청한 에이전트가 브라우저를 사용해 수동으로 수행한다. 자동 agent invocation, 자동 게시, agent 접근 경로 확인 gate는 두지 않는다.

## 범위 밖

- GitHub Actions, 자동 Git commit/push, 별도 Windows worker
- macOS launchd 또는 자동 부팅 설정
- 사람이 매 URL마다 Stage 1을 승인하는 절차
- Gemini Batch API, 무료 quota를 넘는 유료 fallback
- 복수의 의미검증 AI 또는 복잡한 review queue UI
