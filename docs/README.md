# Repo Docs Guide

`Repo Docs`는 WhipUp 구현 설계의 **현재 Source of Truth**다. 기존 Product / PRD / User Flow / Design / Development 페이지는 과거 설계 과정과 참고 자료로 보존하지만, 내용이 다를 경우 구현에서는 Repo Docs의 최신 결정을 따른다.

Repository로 옮긴 뒤에는 동일한 구조의 `docs/`가 Source of Truth가 된다. 이후 요구사항이나 설계가 바뀌면 **Repo Docs/Repository docs를 먼저 수정한 뒤 코드에 반영한다.** 과거 Notion 문서를 다시 동기화하지 않는다.

---

# Documents

## [product.md](product/product.md)

제품 문제, 대상, MVP 기능 범위와 운영 요구사항을 정의한다.

## [ux.md](ux/ux.md)

사용자 화면, 상태, 이동 규칙을 정의한다. 시각 디자인은 Figma를 따른다.

## [domain.md](domain/domain.md)

도메인 의미, canonical Ingredient / Form, Recipe, Recommendation 계산 규칙과 invariant를 정의한다.

## [erd.md](domain/erd.md)

테이블, 관계, 제약조건, nullable, 삭제 정책과 DB 구조를 정의한다.

## [architecture.md](development/architecture.md)

Monorepo, Backend/Flutter 구조, 인증, 데이터 import, 설정 및 책임 경계를 정의한다.

## [tech-stack.md](development/tech-stack.md)

확정된 기술과 라이브러리 선택을 요약한다.

## [ai-data-pipeline.md](development/ai-data-pipeline.md)

YouTube Shorts를 Gemini API로 분석하여 Ingredient / Recipe의 Validated Dataset을 생성하는 파이프라인, 캐시, 재처리, validation/review 규칙을 정의한다.

## [data-import.md](development/data-import.md)

AI Data Pipeline 등에서 생성된 최종 Validated Dataset을 PostgreSQL에 반영하는 형식, 검증, upsert, 실행 규칙을 정의한다.

## [api-specification.md](api/api-specification.md)

App ↔ Backend API의 의미, 동작, 오류, pagination, 정렬 규칙을 정의한다.

## [openapi.yaml](api/openapi.yaml)

App ↔ Backend의 machine-readable API Contract다. Request/Response 구조는 이 문서와 일치해야 한다.

---

# Reading Order

```plain text
1. product.md
2. ux.md (화면 작업 시)
3. domain.md
4. erd.md
5. architecture.md
6. tech-stack.md
7. ai-data-pipeline.md (AI Dataset 생성 작업 시)
8. data-import.md (운영 데이터 DB 반영 작업 시)
9. api-specification.md
10. openapi.yaml
```

DB 작업:

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

# Source of Truth by Area

```plain text
제품 요구사항              → product.md
화면 / Navigation / State → ux.md
Business Rule             → domain.md
Persistent Data Structure → erd.md
Architecture / Packages   → architecture.md
Technology Choice         → tech-stack.md
AI Dataset Generation     → ai-data-pipeline.md
Operational Dataset Import → data-import.md
API Behavior              → api-specification.md
API Contract              → openapi.yaml
DB Schema History         → Flyway Migration
Visual Design             → Figma
```

같은 책임 영역에서 문서와 코드가 충돌하면 코드를 기준으로 합리화하지 않는다. **문서를 먼저 확인하고, 필요한 새 결정이면 문서를 먼저 수정한다.**

---

# Implementation Rules

1. 구현 전에 관련 `docs/`를 읽는다.
2. 문서에 없는 Business Rule을 임의로 추가하지 않는다. 필요한 판단이 생기면 질문하거나 문서를 먼저 갱신한다.
3. DB 변경은 Flyway Migration으로만 수행한다.
4. 실행된 Migration 파일은 수정하지 않는다.
5. DB 구조가 바뀌면 `erd.md`도 함께 갱신한다.
6. Ingredient Form은 MVP 재료 등록/표시에 사용하지만 Recommendation 판단에는 사용하지 않는다. 추천은 DISTINCT canonical Ingredient만 비교한다.
7. Generated OpenAPI Client는 직접 수정하지 않는다.
8. 필요하지 않은 계층, Interface, Adapter, Mapper, UseCase 추상화를 미리 만들지 않는다.
9. Backend Business Rule을 Flutter에서 중복 구현하지 않는다.
10. 실제 secret은 Git에 커밋하지 않는다.
11. 자동 테스트와 API integration test는 MVP 초기 범위에서 작성하지 않는다.
12. 운영 Dataset은 Flyway에 대량 SQL로 넣지 않고 `data-import.md`의 Bulk Import 흐름을 따른다.

---

# Current Status

```plain text
product.md              ✅
ux.md                   ✅
domain.md               ✅
erd.md                  ✅
architecture.md         ✅
tech-stack.md           ✅
ai-data-pipeline.md     ✅
data-import.md          ✅
api-specification.md    ✅
openapi.yaml            ✅
```

이제 구현 설계의 기준은 Repo Docs다.
