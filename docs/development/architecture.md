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
├── data/       # 최종 확정 운영 Dataset
│   ├── ingredients.csv
│   ├── ingredient-categories.csv
│   ├── ingredient-category-mappings.csv
│   ├── ingredient-forms.csv
│   └── recipes/
├── tools/      # 개발/운영 보조 도구
│   └── data-pipeline/
│       ├── input/
│       │   └── shorts-urls.txt
│       ├── ingredient/
│       │   ├── raw/
│       │   ├── review/
│       │   └── manifest.json
│       ├── recipe/
│       │   ├── raw/
│       │   ├── review/
│       │   └── manifest.json
│       ├── src/
│       │   ├── ingredients.py
│       │   ├── recipes.py
│       │   ├── gemini_client.py
│       │   ├── youtube.py
│       │   └── cache.py
│       ├── requirements.txt
│       └── README.md
├── docs/       # Source of Truth documents
├── AGENTS.md
├── README.md
├── .env.example
└── .gitignore
```

App과 Backend는 코드를 직접 공유하지 않는다. 두 영역이 공유하는 것은 **Product/Domain 문서와 API Contract**다.

`tools/`는 서비스 런타임 코드가 아닌 개발/운영 보조 도구 영역이다. YouTube Shorts → Ingredient/Recipe Dataset 생성 파이프라인은 `tools/data-pipeline/`에서 관리하며 Backend 패키지에 포함하지 않는다. 파이프라인의 상세 동작과 캐시/검증 규칙은 `ai-data-pipeline.md`를 따른다.

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
- YouTube Shorts reference 기반 thumbnail 제공

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

State Management는 Riverpod, Navigation은 `go_router`를 사용한다. 단순한 feature 구조를 유지하며 Riverpod 도입을 이유로 별도 UseCase/Repository Interface/Mapper 계층을 만들지 않는다.

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

OpenAPI Generator로 생성한 Flutter API client를 수동 코드와 분리한다. 생성 코드는 Repository에 commit하고 직접 수정하지 않는다. 인증 토큰 주입 등 필요한 최소 공통 처리만 수동 코드에 둔다.

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

MVP 인증 흐름은 다음과 같다.

```plain text
Flutter
  ↓ Kakao Login
Authorization Code
  ↓
Spring Boot Backend
  ↓ Authorization Code 교환
Kakao Token / Kakao User 검증
  ↓
USER / USER_AUTH_ACCOUNT 조회 또는 생성
  ↓
WhipUp JWT Access Token
  ↓
Flutter
```

Client가 전달한 사용자 프로필을 신뢰하지 않고 Backend가 Kakao를 통해 인증 결과를 검증한다. 서비스 인증은 JWT Access Token을 사용한다. MVP에서는 Refresh Token을 만들지 않고 Access Token 유효기간은 7일로 한다. 인증 실패는 User API에서 기본적으로 `401 UNAUTHORIZED`로 처리한다.

---

# OpenAPI

App과 Backend 사이의 API Contract는 OpenAPI로 관리한다.

원칙:

- Request / Response 구조를 명시한다.
- Backend와 App이 서로 다른 Contract를 임의로 정의하지 않는다.
- Generated code는 수동 수정하지 않는다.
- API 구현과 명세가 어긋나지 않도록 관리한다.

Flutter client generation은 OpenAPI Generator를 사용하고 생성 결과를 Repository에 commit한다. Generated client는 직접 수정하지 않는다.

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

# Operational Data Import

대량 Ingredient/Recipe 운영 데이터는 관리자 HTTP CRUD API나 Flyway 대량 INSERT로 관리하지 않는다.

```plain text
Repository data/
  ↓ validation / mapping
Bulk Import command
  ↓ Spring Service / Repository
PostgreSQL
```

Importer는 애플리케이션 부팅 시 자동 실행하지 않고 명시적인 CLI/command로 실행한다. 세부 Dataset schema와 upsert/failure 규칙은 `data-import.md`를 따른다.

# Local Environment & Secrets

Local PostgreSQL은 Docker Compose로 실행한다. Backend 설정은 Spring configuration + environment variable 방식으로 관리한다.

Repository에는 `.env.example`만 commit할 수 있고 실제 `.env`, Kakao credential, JWT secret, DB password 등 secret은 commit하지 않는다. `.gitignore`는 실제 `.env` 파일을 제외해야 한다.

# Testing

자동 테스트와 API integration test는 MVP 초기 범위에서 작성하지 않는다.

# Deferred

필요성이 생기기 전까지 결정하거나 도입하지 않는다.

- YouTube Shorts 재생 SDK/구현 방식
- Refresh Token
- Cache / Redis
- Cloud infrastructure
- CI/CD
- Monitoring
- Production logging infrastructure
