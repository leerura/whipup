# Tech Stack

현재 확정된 MVP 기술 선택을 기록한다. 세부 구조와 책임은 `architecture.md`를 따른다.

| Area | Technology |
| --- | --- |
| App | Dart + Flutter |
| State Management | Riverpod |
| Navigation | go_router |
| Backend | Java 21 + Spring Boot |
| Database | PostgreSQL |
| Local DB | Docker Compose |
| ORM | JPA / Hibernate |
| Migration | Flyway |
| API | REST |
| API Contract | OpenAPI |
| Flutter API Client | OpenAPI Generator generated client |
| External Auth | Kakao Login |
| Service Auth | JWT Access Token |
| Operational Data | CSV Ingredient Dataset + JSON Recipe Dataset + Bulk Import |
| Automated Test | MVP 초기 범위에서 제외 |

## Backend

Java 21 / Spring Boot를 사용한다. JPA/Hibernate를 활용하며 Schema는 Flyway가 관리한다. Hibernate Schema Auto Update는 사용하지 않고 `ddl-auto=validate`를 사용한다.

## Database

PostgreSQL을 사용한다. Local 개발 DB는 Docker Compose로 실행한다. PK는 BIGINT identity, DB naming은 snake_case, enum은 문자열, 시간은 TIMESTAMPTZ를 기본으로 한다.

## App

Dart/Flutter를 사용한다. 상태 관리는 Riverpod, navigation은 `go_router`를 사용한다. 단순한 feature-based 구조를 유지하고 불필요한 Clean Architecture 계층을 추가하지 않는다.

## API

REST API와 OpenAPI Contract를 사용한다. Flutter client는 OpenAPI Generator로 생성하고 생성 결과를 Repository에 commit한다. Generated code는 직접 수정하지 않는다.

## Authentication

Kakao Login의 Authorization Code를 Backend로 전달하고 Backend가 Kakao와 token 교환 및 사용자 검증을 수행한다. 서비스 내부 인증은 JWT Access Token을 사용하며 MVP에서는 Refresh Token을 사용하지 않는다. Access Token 유효기간은 7일이다.

## Operational Dataset

Ingredient Master는 CSV, Recipe Dataset은 JSON을 사용한다. 대량 운영 데이터는 Bulk Import command로 반영하며 Flyway 대량 INSERT나 관리자 HTTP CRUD API를 사용하지 않는다.

## Configuration / Secrets

Spring 설정은 environment variable을 참조한다. `.env.example`은 commit할 수 있지만 실제 `.env`, Kakao credential, JWT secret, DB password는 Git에 commit하지 않는다.

## Deferred

- YouTube Shorts 재생 SDK/구현 방식
- Refresh Token
- Cache / Redis
- Cloud / Deployment
- CI/CD
- Monitoring
