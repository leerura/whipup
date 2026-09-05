# Architecture

WhipUp은 **Flutter App + Spring Boot Backend + PostgreSQL**로 구성한다.

```plain text
Flutter App
    ↓ REST API
Spring Boot Backend
    ↓
PostgreSQL
```

초기 MVP는 로컬 환경에서 개발한다. Backend는 하나의 Spring Boot Application으로 유지하고, 기능별 책임만 명확하게 나눈다.

---

# Principles

1. **단순한 구조를 우선한다.** 필요하지 않은 추상화나 계층은 미리 만들지 않는다.
2. **Feature 중심으로 코드를 묶는다.** 기술 종류별 전역 패키지보다 기능 단위 구조를 사용한다.
3. **현재 요구사항만 구현하고 미래 기능은 확장 지점만 남긴다.**
4. **저장 구조와 Business Rule을 구분한다.** Recommendation 같은 계산 결과를 불필요하게 DB에 저장하지 않는다.

MVP에서 도입하지 않는 구조:

- Microservices
- Event-driven Architecture
- CQRS
- Event Sourcing
- 엄격한 Clean / Hexagonal Architecture
- Domain Model과 JPA Entity의 완전 분리
- 모든 계층에 대한 Interface / Adapter 추상화

---

# Repository

Monorepo로 관리한다.

```plain text
project-root/
├── app/        # Flutter
├── backend/    # Spring Boot
├── docs/       # Product / UX / Domain / Development docs
├── AGENTS.md
├── README.md
└── .gitignore
```

App과 Backend는 코드를 직접 공유하지 않는다. 두 영역이 공유하는 것은 **Product/Domain 문서와 API Contract**다.

구현 단계에서는 Repository의 `docs/`를 개발 문서의 Source of Truth로 사용한다.

---

# Backend

## Style

Backend는 **Feature-based Modular Monolith**로 구성한다.

```plain text
com.<project>/
├── auth/
├── user/
├── ingredient/
├── recipe/
├── recommendation/
├── common/
└── Application.java
```

하나의 Application으로 실행되지만 각 Feature의 책임을 분리한다.

## Feature Boundaries

### auth

- Kakao Login
- 외부 인증 결과 검증
- User / Auth Account 연결
- 서비스 내부 인증 처리

Ingredient나 Recipe 비즈니스 로직을 처리하지 않는다.

### user

- 서비스 내부 User 관리
- 현재 로그인 User 식별

별도 프로필 기능은 MVP 범위가 아니다.

### ingredient

- Ingredient Master
- Form Type / Ingredient Form
- User Owned Ingredient 조회/추가/삭제

추천 계산은 담당하지 않는다.

### recipe

- Recipe
- Recipe Ingredient
- Recipe Step
- DRAFT / PUBLISHED lifecycle
- Recipe Detail 조회

User가 Recipe를 만들 수 있는지 판단하지 않는다.

### recommendation

- User의 현재 Owned Ingredients 조회
- Published Recipe의 Required Ingredients 조회
- Missing Ingredients 계산
- Missing Count / Classification 계산
- 추천 결과 조회

Recommendation은 DB Entity 없이도 독립적인 비즈니스 Feature로 취급한다.

계산 규칙은 `../domain/domain.md`를 따른다.

### common

여러 Feature에서 실제로 공유하는 기술 코드만 둔다.

예:

- Configuration
- Exception handling
- Security / Authentication context
- 공통 Error/Response 처리

특정 Feature의 비즈니스 로직을 `common`으로 옮기지 않는다.

---

# Backend Layers

Feature 내부에서 필요할 때 다음 책임으로 나눈다.

```plain text
Controller
    ↓
Service
    ↓
Repository
    ↓
PostgreSQL
```

모든 Feature가 반드시 모든 하위 패키지를 가져야 하는 것은 아니다. 코드가 적으면 flat하게 유지하고 필요할 때 분리한다.

## Controller

- HTTP Request/Response
- Request validation 진입점
- 인증 User 전달
- Service 호출

Business Logic을 작성하지 않는다.

## Service

- Use Case 실행
- Business Rule 검증
- Repository 조합
- Transaction boundary

`@Transactional`은 기본적으로 Service의 하나의 Use Case 단위에 둔다.

## Repository

- DB 조회/저장
- 필요한 Query 제공

Business Rule을 두지 않는다.

---

# JPA Strategy

MVP에서는 JPA Entity와 별도 Domain Object를 이중으로 만들지 않는다.

```java
@Entity
class Ingredient {
    ...
}
```

Entity는 해당 Feature의 `domain/`에 둔다.

예:

```plain text
ingredient/domain/
├── Ingredient.java
├── FormType.java
├── IngredientForm.java
└── UserIngredient.java

recipe/domain/
├── Recipe.java
├── RecipeIngredient.java
└── RecipeStep.java
```

다음과 같은 구조는 현재 만들지 않는다.

```plain text
Ingredient
IngredientEntity
IngredientMapper
IngredientRepository
JpaIngredientRepository
IngredientRepositoryAdapter
```

실제 문제가 생길 때만 Persistence Model 분리를 검토한다.

---

# Database

Schema 변경 권한은 **Flyway Migration**에 있다.

```plain text
ERD
 ↓
Flyway Migration
 ↓
PostgreSQL Schema
 ↑
JPA Entity
```

Hibernate가 Entity 기준으로 Schema를 자동 수정하게 하지 않는다.

```plain text
spring.jpa.hibernate.ddl-auto=validate
```

Migration 위치:

```plain text
backend/src/main/resources/db/migration/
├── V1__initial_schema.sql
├── V2__....sql
└── V3__....sql
```

실행된 Migration 파일은 수정하지 않는다. Schema 변경은 새 Migration으로 추가한다.

---

# Backend Structure

```plain text
backend/
├── build.gradle
├── settings.gradle
├── gradlew
├── gradlew.bat
├── gradle/
└── src/
    ├── main/
    │   ├── java/com/<project>/
    │   │   ├── auth/
    │   │   ├── user/
    │   │   ├── ingredient/
    │   │   ├── recipe/
    │   │   ├── recommendation/
    │   │   ├── common/
    │   │   └── Application.java
    │   └── resources/
    │       ├── application.yml
    │       └── db/migration/
    └── test/
```

Feature 내부는 필요에 따라 다음 구조를 사용할 수 있다.

```plain text
feature/
├── controller/
├── service/
├── domain/
├── repository/
└── dto/
```

DTO와 Repository도 해당 Feature 안에 둔다. 전역 `dto/`, `entity/`, `repository/` 패키지는 만들지 않는다.

Spring Data JPA Repository를 다시 감싸기 위한 별도 Adapter 계층은 만들지 않는다.

---

# Flutter App

Flutter 역시 Feature 중심으로 구성한다.

```plain text
app/
└── lib/
    ├── main.dart
    ├── app/
    ├── features/
    │   ├── auth/
    │   ├── ingredient/
    │   ├── recommendation/
    │   └── recipe/
    ├── core/
    └── api_generated/
```

## app/

Application 전체 설정.

```plain text
app/
├── app.dart
├── router/
└── theme/
```

개별 Feature의 UI나 Business Logic을 넣지 않는다.

## features/

각 Feature는 필요에 따라 다음 책임으로 나눈다.

```plain text
feature/
├── presentation/
├── state/
└── data/
```

State Management Library가 결정되면 `state/` 이름이나 세부 구조는 변경할 수 있다.

### presentation

- Screen
- Widget
- 사용자 Interaction
- Loading / Error 등 상태 표현

직접 HTTP 요청을 보내지 않는다.

### state / application

- 화면 상태
- User Action 처리
- Data Layer 호출

Backend의 Business Rule을 Client에서 다시 구현하지 않는다.

### data

- Backend API 호출
- Request / Response 처리
- API Model 변환

Backend가 서비스 데이터의 Source of Truth다. Offline-first 구조는 MVP에 도입하지 않는다.

## core/

여러 Feature에서 실제로 공유하는 기술 코드만 둔다.

```plain text
core/
├── network/
├── auth/
├── error/
└── config/
```

Feature Business Logic을 넣지 않는다.

## api_generated/

OpenAPI Code Generation을 사용하게 되면 생성 코드를 수동 코드와 분리한다.

Generated code는 직접 수정하지 않는다.

---

# App ↔ Backend

Flutter는 PostgreSQL에 직접 접근하지 않는다.

```plain text
Flutter
   ↓ REST API
Spring Boot
   ↓
PostgreSQL
```

Business Rule과 Recommendation 판단은 Backend가 책임진다.

---

# Authentication

Architecture 수준의 인증 흐름은 다음까지만 고정한다.

```plain text
Flutter
  ↓
Kakao Login
  ↓
Backend
  ↓
USER / USER_AUTH_ACCOUNT
  ↓
서비스 인증 상태
```

Spring Security 세부 구성과 내부 인증 방식은 구현 전 별도로 결정한다.

---

# OpenAPI

App과 Backend 사이의 API Contract는 OpenAPI로 관리한다.

원칙:

- Request / Response 구조를 명시한다.
- Backend와 App이 서로 다른 Contract를 임의로 정의하지 않는다.
- Generated code는 수동 수정하지 않는다.
- API 구현과 명세가 어긋나지 않도록 관리한다.

Code-first / contract-first와 구체적인 Code Generation 전략은 `../api/api-specification.md` 작성 단계에서 결정한다.

---

# Sources of Truth

```plain text
Product requirements        → product.md
UX behavior                 → ux.md
Domain / business rules     → domain.md
Persistent data structure   → erd.md
DB schema history           → Flyway migrations
Backend business decisions  → Backend code
API contract                → OpenAPI
Screen runtime state        → Flutter
```

Recommendation 결과는 저장된 Source of Truth가 아니다. 현재 DB 상태에서 계산되는 값이다.

---

# Deferred

필요성이 생기기 전까지 결정하거나 도입하지 않는다.

- Flutter state management library
- Flutter navigation library
- HTTP client
- Kakao SDK 세부 연동
- YouTube Shorts 재생 방식
- Spring Security 세부 구성
- 내부 인증 방식
- OpenAPI Code Generation 전략
- Cache / Redis
- Docker
- Cloud infrastructure
- CI/CD
- Monitoring
- Production logging infrastructure
