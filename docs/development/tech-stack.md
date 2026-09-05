# Tech Stack

현재 확정된 기술만 기록한다. 구체적인 라이브러리는 실제 요구사항이 생길 때 선택한다.

| Area | Technology |
| --- | --- |
| App | Dart + Flutter |
| Backend | Java + Spring Boot |
| Database | PostgreSQL |
| ORM | JPA / Hibernate |
| Migration | Flyway |
| API | REST |
| API Contract | OpenAPI |
| External Auth | Kakao Login |
| Environment | Local Development |
| Automated Test | MVP 초기 범위에서 제외 |

## Backend

Java/Spring Boot를 사용한다.

이 프로젝트는 추천 알고리즘 자체보다 User Owned Ingredient, canonical Ingredient, Ingredient Form, Recipe Ingredient 등 **관계형 데이터의 구조와 정합성**을 안정적으로 관리하는 비중이 크다.

JPA/Hibernate를 활용해 관계형 데이터를 객체 모델과 연결하고, Spring의 DI / Validation / Transaction 지원을 활용한다. 동시에 기존 Java 경험을 바탕으로 Spring 생태계를 더 깊게 다루는 것도 기술 선택의 목적이다.

## Database

PostgreSQL을 사용한다.

Schema 변경은 Flyway Migration으로 관리하고 Hibernate Schema Auto Update는 사용하지 않는다. JPA Entity는 실제 Schema와 매핑하며 `ddl-auto=validate`를 기본 방향으로 한다.

## App

Dart/Flutter를 사용한다.

현재 앱은 로그인, 재료 관리, 추천 목록, 레시피 상세, 영상 재생과 Backend API 통신이 중심이며 복잡한 네이티브 기능을 요구하지 않는다.

## API

REST API를 사용하고 App ↔ Backend Contract는 OpenAPI로 관리한다.

구체적인 Code Generation 전략은 API 설계 단계에서 결정한다.

## Deferred

아직 선택하지 않는다.

- Flutter state management
- Navigation
- HTTP client
- Kakao SDK 연동 방식
- YouTube 재생 방식
- Spring Security 세부 구성
- 내부 인증 방식
- OpenAPI Code Generation 전략
- Cache / Redis
- Docker
- Cloud / Deployment
- CI/CD
- Monitoring
