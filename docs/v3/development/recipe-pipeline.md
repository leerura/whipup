# V3 레시피 데이터 파이프라인

이 문서는 Gemini 무료 API로 영상당 한 번 재료와 레시피 원본을 추출하고, 사용자가 별도로 요청한 Codex 에이전트가 그 결과를 V3 catalog 및 최종 recipe dataset에 반영하는 로컬 작업 흐름을 정의한다. Gemini 추출 결과는 영상 원본에 대한 사실 자료로 신뢰한다. 에이전트는 통상 작업에서 영상을 다시 검증하거나 원문을 재추출하지 않는다. 제품 판단은 [V3 제품 결정](../product/product.md), 최종 데이터 형식은 [Dataset schema](../data/dataset-schema.md)를 따른다.

## 확정된 운영 방식

- MacBook에서 필요할 때 Docker Compose pipeline 서비스만 수동 실행한다. macOS launchd, GitHub Actions, Windows 상시 실행은 사용하지 않는다.
- 서로 독립된 Gemini quota를 가진 계정은 하나 이상(`N >= 1`) 등록할 수 있다. 등록된 계정마다 worker 하나가 동작하며, worker 수는 계정 설정 수에서 자동으로 결정된다. 계정을 추가하거나 제거할 때 Compose 명령, 코드 또는 worker 수를 사람이 바꾸지 않는다.
- 계정의 API key 원문은 Git에 저장하지 않는다. 계정 설정은 로컬 전용이며, 상태·로그·대시보드에는 `account-a`처럼 key를 노출하지 않는 식별자만 남긴다.
- pipeline은 실행 중 `tools/data-pipeline/input/shorts-urls.txt`를 반복해서 확인해 새 URL을 처리한다. 빈 줄과 `#` 주석 줄은 건너뛴다. 제외할 URL은 목록에서 주석 처리할 수 있다.
- Compose 실행은 pipeline 서비스만 대상으로 한다. 일반적인 backend 및 PostgreSQL 서비스를 함께 시작하지 않는다.
- 사용자가 URL 목록, 진행 기록, Gemini 추출 결과와 최종 dataset을 Git 저장소에 남긴다. pipeline은 자동 commit/push하지 않는다.
- 컨테이너나 Mac이 종료되면 저장된 상태와 추출 결과를 기준으로 다음 Compose 실행에서 미완료 단계부터 계속한다. 중단된 worker의 선점은 lease 만료 후 자동 회수한다.
- pipeline은 Gemini 요청만 자동 처리한다. Codex 에이전트 호출, catalog/recipe 최종 반영, Git 작업은 사용자가 별도로 요청할 때 수행한다.

## 영상별 처리 흐름

1. URL 목록에서 주석이 아니며 아직 완료되지 않은 URL을 찾는다. 같은 YouTube video ID는 한 번만 처리한다.
2. 가용 worker가 공유 큐에서 처리 가능한 URL 하나를 원자적으로 선점한다. 한 video ID와 Gemini 추출 단계는 동시에 하나의 worker만 처리한다.
3. Gemini에 원본 영상 URL과 하나의 추출 요청을 보내 재료 원문, 수량·단위, 선택 여부, 조리 단계 등 recipe 내용에 필요한 정보를 한 번에 추출한다. 이 요청은 기존 catalog를 입력으로 요구하지 않는다. Gemini가 영상 내용에서 확인할 수 없는 YouTube 업로더 메타데이터를 추측하게 하지 않는다.
4. 원본 video ID로 YouTube의 source metadata를 별도 조회해 원본 영상 제목, 채널명, 채널 ID, 조회 시각을 가져온다. 이는 Gemini recipe extraction과 별도 단계이며, 원본 영상 페이지/API metadata에 없는 값은 추측하지 않고 `null`로 남긴다.
5. Gemini 응답, source metadata snapshot, 요청 상태를 video ID별 checkpoint에 저장하고 선점을 해제한다. 추출과 metadata 저장이 끝나면 해당 영상의 자동 작업을 멈춘다. pipeline은 catalog나 최종 recipe dataset을 수정하지 않는다.
6. 사용자가 Codex 에이전트에게 반영을 요청한다. 에이전트는 Gemini 추출 결과를 recipe 내용의 원본 사실로 사용하고, 저장된 source metadata를 출처 정보로 사용한다. 기존 catalog를 재사용하거나 필요한 Ingredient group/owned item을 추가하며, recipe-local mapping과 requirements를 구성한다.
7. 에이전트는 deterministic validator를 통과시킨 뒤 catalog와 recipe JSON을 최종 dataset에 반영한다. 필수 재료가 합리적으로 매핑되지 않거나 구조 검사가 실패하면 해당 recipe를 `DRAFT`로 유지하고 이유를 기록한다. 모든 필수 요구가 연결되고 구조 검사가 통과하면 `PUBLISHED`할 수 있다.

## Gemini 추출 결과와 Codex의 책임

Gemini는 영상 원본의 재료 및 조리 정보를 추출한다. 추출 결과의 내용은 신뢰하며, Codex는 이를 영상과 대조해 재검증하거나 다른 해석으로 교체하지 않는다. Codex는 결과에 없는 수량, 재료, 단계, 영상 근거를 만들어내지 않는다.

Gemini의 저장 응답은 아래 필드를 포함한다. `rawText`는 영상에서 확인한 원문 재료 표현이고 `displayName`은 그 표현의 읽기 쉬운 이름이다. `sourceId`는 pipeline이 응답 저장 시 순서대로 부여한다. evidence의 `type`은 `SPEECH`, `SUBTITLE`, `ON_SCREEN_TEXT`, `VISUAL_ACTION` 중 하나이며, 확인할 수 없는 수량·단위·설명·timestamp는 `null`로 둔다. 선택 여부를 판단할 수 없으면 `unresolved`에 이유를 기록한다.

```json
{
  "title": "string",
  "description": "string|null",
  "servings": "string|null",
  "ingredients": [
    {
      "sourceId": "ingredient-1",
      "rawText": "다진 마늘 1큰술",
      "displayName": "다진 마늘",
      "amount": "1",
      "unit": "큰술",
      "optional": false,
      "evidences": [
        { "type": "ON_SCREEN_TEXT", "text": "다진 마늘 1큰술", "timestamp": "00:05" }
      ]
    }
  ],
  "steps": [
    {
      "text": "팬에 마늘을 볶는다.",
      "evidences": [
        { "type": "VISUAL_ACTION", "text": "팬에 마늘을 넣고 볶음", "timestamp": "00:12" }
      ]
    }
  ],
  "unresolved": []
}
```

Codex는 V3 catalog 및 recipe 모델에 맞게 결과를 정리한다. 여기에는 기존 Ingredient/Variant 재사용, 새 catalog 항목 추가, source expression을 보유 단위에 연결, recipe별 `acceptedOwnedVariants` 및 requirements 작성, `DRAFT`/`PUBLISHED` 결정, deterministic validation이 포함된다. Gemini 결과에 명시된 불확실성 또는 필수 정보의 부재는 추측으로 메우지 말고 미해결 이유로 남긴다.

YouTube source metadata는 Gemini 추출과 별도로 URL의 video ID를 이용해 수집한다. 최종 recipe JSON은 `shortsReference`, `sourceTitle`, `sourceChannelName`, `sourceChannelId`, `sourceMetadataFetchedAt`를 보존한다. `sourceTitle`은 앱의 recipe `name`을 대체하지 않는다. Recipe read/API 요청에서는 저장된 metadata snapshot을 반환하며 YouTube에 매번 재조회하지 않는다. metadata가 누락된 경우 extraction 내용을 만들어 보완하지 않고 누락 상태를 유지한다.

## 검증 범위

결정적 validator는 의미상 영상 검증을 수행하지 않는다. 다음 데이터 무결성 조건을 검사하고 실패 시 dataset 반영을 막는다.

- Gemini 결과 JSON 및 필수 필드 파싱
- 최종 recipe 및 catalog JSON의 스키마와 필수 필드
- Ingredient/Variant key의 고유성 및 참조 유효성
- recipe-local ingredient, requirement, option, substitute 간 참조와 역할 수
- PUBLISHED recipe의 필수 재료 매핑 완결성

카탈로그 분류와 recipe-local mapping은 V3 제품·데이터 규칙에 따라 Codex가 판단한다. 매핑이 해결되지 않은 필수 요구는 `DRAFT`에 남긴다.

## 진행 상태와 저장

각 URL의 Gemini 요청 상태, 단일 응답 원문, 오류 또는 다음 재시도 시각을 저장소 안에 보존한다. 완료된 Gemini 요청을 재실행하지 않도록 저장 후 다음 작업으로 이동한다. 데이터 반영 요청이 들어오면 에이전트는 저장된 추출 결과를 사용하며 Gemini를 다시 호출하지 않는다.

공유 큐 상태는 다음을 사용한다.

| 상태 | 의미 |
| --- | --- |
| `PENDING` | 아직 처리되지 않아 가용 worker가 선점할 수 있음 |
| `CLAIMED` / `EXTRACTION_RUNNING` | 한 worker가 선점했거나 Gemini 요청을 실행 중임 |
| `EXTRACTION_READY` | Gemini 원본 추출이 저장되어 Codex 반영을 기다림 |
| `WAITING_RETRY` | 재시도 시각까지 보류됨 |
| `FAILED_RETRYABLE` | 이번 실행의 짧은 재시도를 모두 소진해 다음 실행에서 다시 시도 가능함 |
| `FAILED` | 영상 접근 불가 등 재시도로 해결할 수 없는 실패임 |
| `REVIEW_PENDING` | 추출은 끝났고 사람이 요청한 Codex 반영 또는 검토를 기다림 |

선점에는 `workerId`, `claimedAt`, heartbeat를 기록한다. heartbeat가 15분 동안 갱신되지 않으면 worker가 중단된 것으로 보고 선점을 해제해 `PENDING`으로 돌린다. 완료된 결과를 가진 URL은 lease 회수나 새 worker 시작으로 다시 Gemini에 요청하지 않는다.

quota 또는 일시 오류로 보류된 URL은 아직 처리되지 않은 `PENDING` URL보다 먼저 선택하지 않는다. 큐에 새 URL이 남아 있지 않을 때만 다른 가용 계정이 보류 URL을 가져갈 수 있다.

기존 `WAITING_CATALOG` 상태는 사용하지 않는다. Gemini 추출은 catalog 입력에 의존하지 않으며, catalog가 준비되지 않았다는 이유로 영상 추출이나 저장을 대기시키지 않는다. 입력 URL을 주석 처리해도 이미 저장된 기록을 자동으로 지우지 않는다.

## 무료 Gemini quota와 재시도

- 무료 tier의 Gemini GenerateContent API를 사용한다. 유료 Batch API나 자동 유료 모델 fallback을 추가하지 않는다.
- 기본 모델은 `gemini-3.8-flash`이며 `GEMINI_MODEL` 환경 변수로 변경할 수 있다. 모델 접근 및 무료 tier 제공 여부는 계정·프로젝트에 따라 달라질 수 있으므로 현재 Google AI Studio 설정과 공식 모델 문서를 확인한다.
- 영상당 Gemini 요청은 하나다. 각 계정 worker는 동시에 하나의 영상만 처리해 해당 계정의 분당 한도를 불필요하게 넘기지 않는다. 서로 독립된 계정 worker는 병렬로 동작할 수 있다.
- 오류 내용이 일일 quota 초과를 나타내면 응답의 `RetryInfo.retryDelay`가 있을 때 그 시각을 사용하고, 없으면 다음 Pacific Time 자정까지 해당 계정만 대기한다. 다른 계정 worker와 아직 처리되지 않은 URL은 계속 처리한다.
- quota가 아닌 429, 일시 네트워크 오류 또는 5xx는 `10초`, `30초`, `60초` 간격으로 최대 3회 재시도한다. 재시도 대기 URL은 worker를 점유하지 않는다.
- 세 번의 짧은 재시도에도 실패하면 `FAILED_RETRYABLE`로 남긴다. 다음 pipeline 실행에서 다시 시도할 수 있으며, 세 번의 별도 실행에서도 계속 실패하면 `REVIEW_PENDING`으로 전환한다.
- 비공개·삭제·권한 오류처럼 재시도로 해결되지 않는 오류는 `FAILED`로 남기며, 다른 계정으로 반복하지 않는다.
- quota 대기와 다음 재시도 시각은 계정과 URL별로 보존한다. 프로세스나 Mac이 종료된 경우에도 너무 일찍 재호출하지 않는다.

Gemini quota는 모델·프로젝트별 RPM, TPM, RPD로 달라지고 RPD는 Pacific Time 자정에 초기화된다. API가 정확한 RetryInfo를 매번 제공한다고 가정하지 않는다. active limit은 AI Studio에서 확인하며 코드에 무료 quota 수치를 고정하지 않는다.

## 실행 인터페이스

Compose에 기존 `backend`/`postgres`와 독립적인 `recipe-pipeline` 서비스를 둔다. 작업자가 사용할 인터페이스는 다음처럼 간단해야 한다.

각 독립 Gemini 계정은 `tools/data-pipeline/accounts/account-a.env`처럼 로컬 전용 파일 하나로 등록한다. 파일 이름은 대시보드에 표시되는 계정 식별자이고 파일 내용은 `GEMINI_API_KEY=...` 한 줄이다. 저장소의 `account.example.env`를 복사해 사용하며, 이 실제 `.env` 파일은 Git에서 제외한다. 파일 수가 worker 수다.

```sh
docker compose up -d recipe-pipeline
docker compose logs -f recipe-pipeline
docker compose stop recipe-pipeline
```

서비스 실행 중 URL 목록이 갱신되면 자동으로 새 항목을 처리한다. `docker compose up`에서 backend와 PostgreSQL까지 함께 켜야 하는 구조를 만들지 않는다. 대시보드는 `http://localhost:8081`에서 열리며 Docker는 이 포트를 loopback에만 bind한다.

pipeline은 loopback에서만 접근 가능한 읽기 전용 운영 대시보드를 제공한다. 이 화면은 별도 상태를 저장하지 않고 checkpoint와 공유 큐만 읽어 자동 갱신한다. 대시보드는 최소한 전체 URL 진행률, 단계별 URL 수와 목록, 현재 처리 중인 URL, 계정별 worker 상태, 마지막 오류, quota 또는 재시도 예정 시각을 보여준다. 최종 데이터 반영·검토를 위한 별도 웹 UI나 복잡한 review queue는 만들지 않는다.

## 완료 조건

- `shorts-urls.txt`의 활성 URL마다 Gemini를 한 번 호출해 재료와 레시피 원본 추출을 함께 수행한다.
- URL이 주석 처리되면 새 작업으로 실행하지 않는다. 중복 URL은 video ID 기준으로 한 번만 처리한다.
- 추출 결과와 상태가 저장된 뒤 컨테이너를 종료하고 다시 실행해도 완료된 Gemini 요청을 다시 호출하지 않는다.
- catalog가 없거나 유효하지 않아도 Gemini 추출 및 결과 저장은 가능하다. `WAITING_CATALOG`에 들어가지 않는다.
- pipeline은 자동으로 Codex 에이전트를 부르거나 최종 dataset을 수정하지 않는다. 사용자 요청을 받은 에이전트가 저장된 응답을 catalog 및 recipe dataset으로 반영한다.
- 에이전트는 Gemini 추출 사실을 재검증 목적으로 변경하지 않는다. 새 catalog 항목 및 레시피별 매핑을 V3 규칙에 따라 처리한다.
- 필수 mapping이 미해결이거나 deterministic validation이 실패한 recipe는 `DRAFT`로 유지한다. 검증을 통과한 완결 recipe는 `PUBLISHED`할 수 있다.
- 복수 계정 worker가 같은 video ID를 중복 요청하지 않으며, 중단된 선점을 회수할 수 있다.
- 계정 하나의 quota 대기 또는 일시 오류가 다른 계정 worker의 `PENDING` URL 처리를 막지 않는다.
- 429, 일시 오류 재시도, checkpoint 복구, queue 선점과 lease 회수를 실제 Gemini 호출 없이 검증한다.

## 범위 밖

- GitHub Actions, 자동 Git commit/push, 별도 Windows worker
- macOS launchd 또는 자동 부팅 설정
- Gemini Stage 1/Stage 2의 두 번 호출 구조
- catalog 준비를 기다리는 `WAITING_CATALOG` 처리
- pipeline에서 Codex 에이전트를 자동 호출하는 기능
- Gemini 추출 결과를 에이전트가 영상과 다시 대조하는 절차
- Gemini Batch API, 무료 quota를 넘는 유료 fallback
- 복수의 의미검증 AI 또는 복잡한 review queue UI
