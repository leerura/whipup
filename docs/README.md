# Repo Docs Guide

이 영역은 WhipUp 구현에 필요한 문서를 Repository의 `docs/`로 옮기기 전에 정리하는 공간이다.

기존 Notion의 Product / PRD / User Flow / Design / Development 문서는 보존한다. 실제 구현 단계에서는 이곳에서 정리한 문서를 Markdown으로 옮겨 **Repository `docs/`를 개발 기준으로 사용한다.**

---

# Documents

## [product.md](product/product.md)

제품이 **무엇을 제공해야 하는지** 정의한다.

포함 내용:

- Product problem / target / value
- MVP 범위
- Login
- Ingredient Management
- Recommendation
- Recipe Detail
- 운영 데이터 요구사항
- Out of Scope

구현 중 기능 요구사항이 애매하면 가장 먼저 확인한다.

## [ux.md](ux/ux.md)

사용자가 **어떤 화면에서 어떻게 이동하고 어떤 상태를 보는지** 정의한다.

포함 내용:

- Main Journey
- IA
- S-01 ~ S-05
- Screen State
- Navigation Rules
- UX Boundaries

UI 구현과 화면 이동은 이 문서를 기준으로 한다. 시각 디자인의 최종 표현은 Figma를 따른다.

## [domain.md](domain/domain.md)

서비스의 **비즈니스 의미와 규칙**을 정의한다.

포함 내용:

- User / Ingredient / Ingredient Form
- Owned Ingredient
- Recipe / Recipe Ingredient / Recipe Step
- Draft / Published
- Recommendation
- Missing Ingredient 계산
- Recipe Publication Rule
- Ingredient Mapping Rule
- Domain Invariant

특히 Recommendation 로직을 구현할 때 이 문서를 기준으로 한다.

## [erd.md](domain/erd.md)

Domain을 **DB에 어떻게 저장하는지** 정의한다.

포함 내용:

- Table
- PK / FK / Unique Constraint
- 관계
- Nullable 정책
- Published Recipe 데이터 정합성
- Delete Policy
- Recommendation 비영속화
- Flyway Schema 관리 기준

DB 구조 변경 시 `domain.md`와 함께 확인한다.

## [architecture.md](development/architecture.md)

App과 Backend의 **코드 구조와 책임 경계**를 정의한다.

포함 내용:

- Monorepo 구조
- Backend Feature boundaries
- Controller / Service / Repository 책임
- JPA Entity 전략
- Flyway 전략
- Flutter Feature 구조
- App ↔ Backend 통신
- Authentication / OpenAPI 방향
- Source of Truth

새 패키지, 계층, 추상화를 추가하기 전에 이 문서를 확인한다.

## [tech-stack.md](development/tech-stack.md)

현재 확정된 **기술 선택만 빠르게 확인하는 문서**다.

세부 Architecture 결정은 `architecture.md`를 따른다.

## [api-specification.md](api/api-specification.md)

Backend가 App에 제공하는 **API의 의미와 동작**을 정의한다.

포함 예정:

- Endpoint
- Authentication requirement
- Request / Response
- Error
- Pagination
- Use Case별 API 규칙

## openapi.yaml

App ↔ Backend의 **machine-readable API Contract**다.

API 설계가 확정되면 작성한다.

---

# Reading Order

전체 구현을 시작할 때는 다음 순서로 읽는다.

```plain text
1. product.md
2. domain.md
3. erd.md
4. architecture.md
5. tech-stack.md
6. api-specification.md
7. openapi.yaml
```

화면이나 Flutter 작업을 할 때는 추가로 `ux.md`를 먼저 읽는다.

```plain text
product.md
   ↓
ux.md
   ↓
domain.md
   ↓
API Contract
```

DB 작업이라면 다음 순서를 우선한다.

```plain text
domain.md
   ↓
erd.md
   ↓
Flyway Migration
   ↓
JPA Entity
```

---

# Source of Truth

각 정보의 기준은 다음과 같다.

```plain text
제품 요구사항              → product.md
화면 / Navigation / State → ux.md
Business Rule             → domain.md
Persistent Data Structure → erd.md
Architecture / Packages   → architecture.md
Technology Choice         → tech-stack.md
API Behavior              → api-specification.md
API Contract              → openapi.yaml
DB Schema History         → Flyway Migration
Visual Design             → Figma
```

Notion의 기존 문서와 Repo Docs의 내용이 다르면, 구현 단계에서는 **Repo Docs에서 정리한 최신 결정**을 사용한다.

Repository로 이동한 이후에는 **Repository `docs/`가 Source of Truth**다. 같은 개발 문서를 Notion과 Repository 양쪽에서 동시에 수정하지 않는다.

---

# Conflict Rules

문서 간 내용이 충돌하면 먼저 서로 다른 책임의 문서인지 확인한다.

예:

```plain text
"추천은 canonical Ingredient만 비교한다"
→ domain.md

"Form을 DB에 저장한다"
→ erd.md
```

둘은 충돌하지 않는다. Form은 저장되지만 MVP Recommendation에는 사용하지 않는다.

같은 책임 영역에서 실제로 충돌한다면 임의로 구현하지 말고 최신 결정으로 문서를 먼저 수정한다.

---

# Implementation Rules

Coding Agent를 포함한 구현 작업에서는 다음 원칙을 지킨다.

1. 구현 전에 관련 `docs/`를 읽는다.
2. 문서에 없는 Business Rule을 임의로 추가하지 않는다.
3. DB 변경은 Flyway Migration으로만 수행한다.
4. 실행된 Migration 파일은 수정하지 않는다.
5. DB 구조가 바뀌면 `erd.md`도 함께 갱신한다.
6. Recommendation은 MVP에서 canonical Ingredient만 사용한다. Form은 추천 판단에 사용하지 않는다.
7. Generated OpenAPI Client가 생기면 직접 수정하지 않는다.
8. 필요하지 않은 계층, Interface, Adapter, 공통 추상화를 미리 만들지 않는다.
9. 새로운 기능 요구사항이 생기면 코드보다 문서를 먼저 갱신한다.

---

# Current Status

```plain text
product.md              ✅
ux.md                   ✅
domain.md               ✅
erd.md                  ✅
architecture.md         ✅
tech-stack.md           ✅
api-specification.md    ⏳
openapi.yaml            ⏳
```

다음 문서 작업은 `api-specification.md`다.
