# V4 성능 관측·병목 분석

## 목표

사용자가 느린 화면을 만났을 때 이를 막연한 “네트워크 문제”로 처리하지 않고, 아래 네 구간 중 어디가 느린지 구분한다.

```text
Flutter 앱 전체 시간
  ├─ 인터넷 / TLS / Caddy 전달 시간
  └─ Spring 요청 시간
       ├─ PostgreSQL 조회 시간
       ├─ recipe matcher·응답 변환 시간
       └─ 응답 직렬화 시간
```

V4의 관측은 무료 self-hosted Docker Compose 범위에서 끝낸다. 외부 SaaS, 로그 전문 저장소, 분산 tracing, 알림 자동화는 현재 범위가 아니다.

## 1차 구성

```text
Flutter release/debug 앱
  │  (end-to-end aggregate timing)
  ▼
Caddy HTTPS proxy ── JSON access log ──> docker compose logs
  │
  ▼
Spring Boot backend ── Micrometer metrics ──> Prometheus ──> Grafana
  │                         ▲
  └─ PostgreSQL / Redis ────┘
```

- **Spring Boot Actuator + Micrometer**: 서버 요청, JVM, Hikari connection pool과 Whippy 서비스 구간을 계측한다.
- **Prometheus**: backend의 내부 전용 `/actuator/prometheus`를 scrape하고 로컬 named volume에 시계열을 저장한다.
- **Grafana**: Prometheus를 datasource로 사용해 API 지연, 오류율, DB pool, JVM, 앱 체감 시간을 한 dashboard에서 표시한다.
- **Caddy JSON access log**: 프록시가 본 경로·상태·duration을 `docker compose logs https-proxy`에서 필요할 때 확인한다. 1차에서 Loki로 적재하지 않는다.
- **Flutter telemetry**: 앱이 실제로 측정한 전체 HTTP 시간을 집계값으로만 backend에 보낸다. 이 값은 Prometheus metric으로 누적되어 외부망까지 포함한 체감 지연을 비교하는 데 사용한다.

Spring Boot는 Actuator가 있을 때 Micrometer registry를 자동 구성하며, Prometheus endpoint에는 Prometheus registry 의존성이 추가로 필요하다. [Spring Boot Metrics](https://docs.spring.io/spring-boot/reference/actuator/metrics.html), [Actuator endpoint exposure](https://docs.spring.io/spring-boot/reference/actuator/endpoints.html)를 따른다.

## 접근 경계

`/actuator/prometheus`, Prometheus, Grafana는 **Windows 서버의 loopback 또는 Docker internal network에서만** 접근 가능하게 한다. Caddy의 public HTTPS route와 공인 포트 443으로 Actuator·Prometheus·Grafana를 노출하지 않는다.

개발 Mac에서 필요하면 SSH tunnel로 Grafana를 본다. 공유기 port forwarding이나 Flutter 앱을 위해 monitoring 포트를 추가로 열지 않는다.

## 측정 항목

### 서버 기본 지표

Actuator 기본 지표 중 아래를 Grafana에서 사용한다.

| Metric | 확인 목적 | 허용 tag |
| --- | --- | --- |
| `http.server.requests` | API route별 count, error rate, p50/p95/p99 | method, URI template, status, exception |
| Hikari connection pool | DB connection 고갈/대기 | pool name |
| JVM memory/GC/thread | Windows 노트북 리소스 압박 | 기본 tag만 |
| process CPU | backend CPU 포화 | 기본 tag만 |

Prometheus histogram은 `http.server.requests`와 아래 Whippy Timer에 한정해 활성화한다. 모든 route나 임의 tag에 percentile을 켜지 않는다.

### Whippy 서비스 Timer

`Timer`는 짧은 구간의 count와 duration을 기록하는 용도다. 각 timer는 아래 고정 이름과 low-cardinality tag만 쓴다.

| Metric | 측정 구간 | tag |
| --- | --- | --- |
| `whipup.recommendation.load` | PUBLISHED recipe graph와 owned inventory를 읽는 구간 | 없음 |
| `whipup.recommendation.match` | V3 matcher로 모든 후보를 판정하는 구간 | 없음 |
| `whipup.recommendation.project` | API DTO/thumbnail/missing item projection | 없음 |
| `whipup.recipe.detail` | 상세 조회·match·projection 전체 | 없음 |
| `whipup.recipe.search` | V4 검색의 filter·match·정렬·projection 전체 | scope (`AVAILABLE`, `ALL`) |
| `whipup.daily_menu` | Redis read/write와 published recipe projection | operation (`read`, `add`, `remove`), result (`success`, `unavailable`) |
| `whipup.client.http` | Flutter가 기록한 실제 HTTP 전체 시간 | route template, method, outcome |

`userId`, `recipeId`, request ID, 검색어, ingredient name, URL query, IP 주소, raw exception message는 metric tag에 넣지 않는다. 이렇게 하면 개인 정보와 무한히 늘어나는 time series를 모두 피할 수 있다.

### 요청 단위 구조화 로그

모든 API request에는 `X-Request-Id`를 사용한다. Flutter가 없으면 backend filter가 UUID를 생성하고, response header에도 같은 값을 넣는다. backend log MDC에는 `requestId`, `method`, template route, status, totalMs만 넣는다.

추천·상세·검색 요청의 완료 로그는 아래처럼 JSON 한 줄로 기록한다.

```json
{
  "event": "api.completed",
  "requestId": "uuid",
  "route": "/api/v1/recipes/recommendations",
  "status": 200,
  "totalMs": 184,
  "loadMs": 31,
  "matchMs": 142,
  "projectMs": 7
}
```

`loadMs` 등 구간 값은 해당 요청에서 실제 측정한 경우에만 넣는다. 로그에는 Authorization header, access token, Kakao token, 이름·이메일·사용자 ID, 검색어, recipe/ingredient ID를 기록하지 않는다.

## Flutter end-to-end 계측

Flutter의 Dio interceptor는 API 요청마다 다음을 측정한다.

- 앱이 request를 시작한 monotonic 시각부터 response body 수신/파싱 직전까지의 `totalMs`
- HTTP method, **정규화된 route template**, status/outcome
- backend response의 `X-Request-Id` (debug log correlation 전용)

Interceptor는 성공·실패 모두를 기록하되, telemetry 요청 자신은 다시 telemetry로 기록하지 않는다. 화면을 막지 않도록 보고는 fire-and-forget이며 실패·오프라인 상태는 조용히 버린다.

집계 보고 endpoint는 아래 한 개뿐이다.

```text
POST /api/v1/telemetry/http-timing
```

```json
{
  "route": "/api/v1/recipes/recommendations",
  "method": "GET",
  "outcome": "SUCCESS",
  "durationMs": 2880
}
```

- Bearer 인증된 사용자만 호출한다.
- `route`는 사전에 허용한 API template enum 중 하나여야 한다. raw path와 query string은 받지 않는다.
- `durationMs`는 0 이상 60,000 이하 정수만 받는다.
- backend는 raw event를 DB·Redis·파일에 저장하지 않고 `whipup.client.http` Timer에 누적한 뒤 `204`를 반환한다.
- telemetry endpoint 자체는 timer 보고 대상에서 제외한다.

이 값과 `http.server.requests`/Caddy duration을 함께 비교한다.

| 관찰 | 판단 |
| --- | --- |
| Flutter 전체 시간만 큼, backend/Caddy는 짧음 | 집↔인터넷 회선, TLS, Funnel/공인 HTTPS 전달, 응답 전송 구간을 우선 의심 |
| Caddy와 backend 시간이 모두 큼 | backend·DB·matcher 병목을 우선 확인 |
| backend 전체는 크고 `load`만 큼 | DB 쿼리/connection pool/N+1 가능성 확인 |
| backend 전체는 크고 `match`만 큼 | matcher 알고리즘·객체 그래프·후보 수 확인 |
| `project`만 큼 | response payload/직렬화와 불필요한 requirement payload 확인 |

## N+1 진단 규칙

추천 API가 느릴 때 바로 캐시를 추가하지 않는다. 먼저 개발 환경에서 Hibernate SQL statistics 또는 SQL logger를 일시적으로 켜 다음을 확인한다.

- 한 번의 recommendation/search 요청이 실행한 SQL statement 수
- recipe 수에 비례해 `requirements`, `options`, `substitutes`, accepted variant를 개별 조회하는지
- owned ingredient relation 조회가 request 안에서 반복되는지

N+1이 확인되면 repository의 `EntityGraph` 또는 필요한 범위의 fetch query로 recipe match graph를 한 번에 가져온다. 여러 collection fetch join으로 Cartesian product를 만들지 않으며, 변경 후 같은 fixture에서 statement 수와 `whipup.recommendation.load` p95를 비교한다. 이 진단용 SQL 상세 logging은 public 배포에 상시 활성화하지 않는다.

## Grafana dashboard

`Whippy API Performance` dashboard는 한 화면에 아래 panel을 둔다.

1. route별 request rate 및 4xx/5xx 비율
2. recommendation/search/detail route의 p50·p95·p99 서버 latency
3. Flutter `whipup.client.http` p50·p95와 같은 route의 server p95 비교
4. recommendation의 load/match/project p95 비교
5. Hikari active/pending connection과 PostgreSQL 연결 관련 지표
6. JVM heap, GC pause, process CPU
7. Redis daily-menu success/unavailable count

Prometheus는 수치 시계열을 HTTP pull 방식으로 수집·저장하는 도구이므로, backend와 Prometheus가 같은 Compose network 안에서 scrape하도록 설정한다. [Prometheus overview](https://prometheus.io/docs/introduction/overview/)

## 완료 기준

1. 외부 public HTTPS로 호출한 추천 API 한 건이 Flutter total, Caddy access duration, backend route duration 중 어디에서 느린지 비교 가능하다.
2. Grafana에서 recommendation/search/detail의 p50·p95와 error rate를 볼 수 있다.
3. `userId`, token, 검색어, ingredient/recipe ID, raw URL query가 metric·구조화 로그·telemetry request에 없다.
4. Actuator/Prometheus/Grafana는 public IP에서 접근할 수 없다.
5. Redis/Prometheus/Grafana 장애가 사용자 API 기능을 중단시키지 않는다. telemetry 실패도 앱 UX에 영향을 주지 않는다.
6. 추천이 느릴 때 SQL statement 수와 load/match/project 중 어느 단계가 원인인지 확인 가능하다.

## 이후 결정 대상

측정 결과를 본 뒤에만 아래를 논의한다.

- recipe match graph 조회 최적화
- Flutter in-memory response cache와 invalidation
- user inventory version 기반 서버 recommendation cache
- public HTTPS/Funnel 대체 또는 hosting 이전
- Prometheus retention, alerting, Loki/Tempo 도입
