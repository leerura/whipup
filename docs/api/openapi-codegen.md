# OpenAPI Code Generation

WhipUp은 App과 Backend 사이의 API를 **Contract-First** 방식으로 개발한다.

API Contract의 Source of Truth는 [openapi.yaml](openapi.yaml)이다. Flutter와 Spring Boot에서 HTTP Contract를 수동으로 중복 작성하지 않는다.

```plain text
                   docs/api/openapi.yaml
                   API Contract
                         │
                  make generate-api
                         │
               OpenAPI Generator
                         │
            ┌────────────┴────────────┐
            ▼                         ▼
     Flutter Client             Spring Server
       Codegen                    Codegen
            │                         │
            ▼                         ▼
app/packages/api_client/    backend/generated/openapi/
```

Generated code는 Repository에 commit하고 직접 수정하지 않는다.

---

# Generator Runtime

OpenAPI Generator는 개발 머신에 직접 설치하지 않고 공식 Docker Image를 `docker run`으로 실행한다.

초기 고정 버전:

```plain text
openapitools/openapi-generator-cli:v7.19.0
```

`latest` tag는 사용하지 않는다. Generator는 상시 서비스가 아니므로 `compose.yaml`에 포함하지 않는다. 버전을 변경하면 Flutter와 Backend Generated Code를 모두 다시 생성하고 diff를 확인한다.

---

# Generation Entry Point

Repository Root의 `Makefile`을 공통 진입점으로 사용한다.

```bash
make generate-api
make generate-api-flutter
make generate-api-backend
```

```plain text
make generate-api
├── generate-api-flutter
└── generate-api-backend
```

개발자가 긴 `docker run` 명령을 직접 입력하지 않는다.

---

# Repository Structure

```plain text
project-root/
├── app/
│   ├── lib/
│   └── packages/
│       └── api_client/              # Generated
├── backend/
│   ├── generated/
│   │   └── openapi/                 # Generated
│   └── src/main/java/               # Handwritten
├── docs/api/
│   ├── api-specification.md
│   ├── openapi.yaml
│   ├── openapi-codegen.md
│   └── codegen/
│       ├── flutter.yaml
│       └── backend.yaml
└── Makefile
```

Generated 영역과 Handwritten 영역을 물리적으로 분리한다.

---

# Flutter Codegen

## Generator

Flutter API Client는 `dart-dio`를 사용한다. HTTP Client는 Dio 기반 Generated Client를 사용한다.

Serialization은 `built_value`를 사용한다.

Generated Client는 별도 Dart Package로 생성한다.

```plain text
app/packages/api_client/
```

Flutter App은 이 package를 local dependency로 사용한다.

```yaml
dependencies:
  api_client:
    path: packages/api_client
```

Flutter Feature 코드에서 REST endpoint나 Request/Response Model을 다시 수동 구현하지 않는다.

```plain text
Presentation
    ↓
Riverpod State
    ↓
Feature Data
    ↓
Generated api_client
    ↓
Dio
    ↓
Spring Boot
```

JWT Access Token 처리를 위해 Generated Code를 수정하지 않는다. Handwritten `core/network` 영역에서 Generated Client가 제공하는 설정 지점을 사용해 인증 정보를 주입한다. Token Storage 방식은 별도 결정 전까지 확정하지 않는다.

---

# Backend Codegen

Backend HTTP Contract는 `spring` generator를 사용한다.

기본 설정:

```plain text
delegatePattern=true
useSpringBoot3=true
useBeanValidation=true
interfaceOnly=false
```

`useSpringBoot3=true`를 사용하여 Spring Boot 3 / Jakarta namespace 기준으로 생성한다.

OpenAPI Generator의 책임은 HTTP Contract Layer까지다.

```plain text
Generated
├── API definitions
├── Controller / server wiring
├── Delegate interfaces
├── Request DTO
├── Response DTO
└── Bean Validation metadata
```

Handwritten Backend는 다음을 담당한다.

```plain text
Handwritten
├── Delegate implementation
├── Service
├── Repository
└── JPA Entity
```

전체 호출 흐름:

```plain text
HTTP Request
    ↓
Generated Spring HTTP Layer
    ↓
Generated Delegate Interface
    ↓
Handwritten Delegate Implementation
    ↓
Service
    ↓
Repository
    ↓
PostgreSQL
```

Delegate Implementation은 Generated HTTP Contract와 Service를 연결하는 얇은 Adapter다. Business Logic은 Service에 둔다. Service가 `ResponseEntity` 등 HTTP 타입에 직접 의존하지 않도록 한다.

---

# Backend Generated Source

Spring Generated Code는 다음 위치에 생성한다.

```plain text
backend/generated/openapi/
```

Handwritten Backend는 기존 `backend/src/main/java/`에 둔다. Generated 파일을 `src/main/java`로 복사하지 않는다.

Gradle에서 Generated Source를 compile 대상에 포함한다. 최초 Codegen 구현 시 generator가 만드는 supporting files를 확인하여 API/model/server contract에 필요한 산출물만 compile source로 연결한다.

---

# Docker Execution

Repository Root를 `/local`로 mount한다.

Flutter 개념 명령:

```bash
docker run --rm \
  -v "${PWD}:/local" \
  openapitools/openapi-generator-cli:v7.19.0 generate \
  -i /local/docs/api/openapi.yaml \
  -g dart-dio \
  -c /local/docs/api/codegen/flutter.yaml \
  -o /local/app/packages/api_client
```

Backend 개념 명령:

```bash
docker run --rm \
  -v "${PWD}:/local" \
  openapitools/openapi-generator-cli:v7.19.0 generate \
  -i /local/docs/api/openapi.yaml \
  -g spring \
  -c /local/docs/api/codegen/backend.yaml \
  -o /local/backend/generated/openapi
```

Makefile은 실행 방법을 담당하고, Generator별 세부 option은 `docs/api/codegen/flutter.yaml`, `docs/api/codegen/backend.yaml`에서 관리한다.

---

# Generated Code Policy

1. API 변경은 [api-specification.md](api-specification.md)의 의미/동작을 확인한 뒤 [openapi.yaml](openapi.yaml) Contract를 먼저 수정한다.
2. `make generate-api`를 실행한다.
3. Flutter와 Backend Generated Code를 함께 갱신한다.
4. Generated 결과를 Git에 commit한다.
5. Generated Code는 직접 수정하지 않는다.
6. 생성 결과에 문제가 있으면 Generated Code가 아니라 [openapi.yaml](openapi.yaml) 또는 Codegen Configuration을 수정한다.

```plain text
openapi.yaml / Codegen Config
        ↓
make generate-api
        ↓
Generated Code
```

---

# Source of Truth

```plain text
API 의미 / Business Behavior   → api-specification.md
API Request / Response Contract → openapi.yaml
Codegen Policy                  → openapi-codegen.md
Generator Options               → docs/api/codegen/*.yaml
Flutter Generated Client        → app/packages/api_client/
Spring Generated HTTP Layer     → backend/generated/openapi/
Backend Business Logic          → backend/src/main/java/
```

---

# MVP에서 생성하지 않는 것

- Service Business Logic
- Repository
- JPA Entity
- Database Schema
- Flyway Migration
- Flutter UI
- Riverpod State
- Test

Codegen의 책임은 API Contract와 직접 연결되는 Client/HTTP Layer까지다.
