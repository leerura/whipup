# Local Development

## 1. 목적

WhipUp Backend의 로컬 개발환경 구성과 실행 방법을 정의한다.

로컬 Backend 환경은 **Docker Compose를 기준으로 통일**한다. 개발자는 로컬 머신에 PostgreSQL이나 별도의 Backend Runtime 환경을 직접 구성하지 않고, Docker를 통해 Spring Boot Backend와 PostgreSQL을 함께 실행한다.

```plain text
Flutter App
     │
     │ HTTP
     ▼
Docker Compose
├── Spring Boot Backend :8080
│        │
│        │ JDBC
│        ▼
└── PostgreSQL :5432
```

MVP 단계에서는 로컬 개발환경의 빌드 시간 최적화, Hot Reload, Docker Build Cache 최적화 등은 별도로 고려하지 않는다.

## 2. 기본 원칙

### Docker Compose

로컬 Backend 실행 환경은 Docker Compose로 관리한다.

```plain text
Docker Compose
├── backend
│   └── Spring Boot
└── postgres
    └── PostgreSQL
```

Flutter App은 Docker Compose에 포함하지 않는다. Flutter는 개발 머신에서 직접 실행하며 Docker의 Backend API에 접근한다.

### Backend

Spring Boot Backend는 Docker Container에서 실행한다. Backend Container는 Repository의 `backend/Dockerfile`을 사용해 생성한다. 기본 API Port는 `8080`이다.

### Database

PostgreSQL 역시 Docker Container에서 실행한다. 기본 Port는 `5432`이다. PostgreSQL 데이터는 Docker Volume을 사용하여 Container 재시작 또는 재생성 이후에도 유지한다.

## 3. Repository Structure

```plain text
project-root/
├── app/
├── backend/
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       └── resources/
│   │           ├── db/
│   │           │   └── migration/
│   │           └── application.yml
│   ├── Dockerfile
│   ├── build.gradle
│   └── settings.gradle
├── data/
├── tools/
├── docs/
├── compose.yaml
├── .env.example
├── .gitignore
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `compose.yaml` | 로컬 Backend + PostgreSQL 실행 환경 |
| `backend/Dockerfile` | Spring Boot Container Image 정의 |
| `.env` | 실제 로컬 환경변수 |
| `.env.example` | 필요한 환경변수 예시 |

## 4. Docker Compose

`compose.yaml`은 최소 `backend`, `postgres` 두 서비스를 정의한다.

```yaml
services:
  backend:
    build:
      context: ./backend
    ports:
      - "8080:8080"
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      SPRING_PROFILES_ACTIVE: local
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: ${DB_NAME}
      DB_USERNAME: ${DB_USERNAME}
      DB_PASSWORD: ${DB_PASSWORD}

  postgres:
    image: postgres:<FIXED_VERSION>
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      # PostgreSQL connection readiness check

volumes:
  postgres_data:
```

현재 Tech Stack에는 PostgreSQL의 구체적인 버전이 확정되어 있지 않으므로 `<FIXED_VERSION>`으로 남긴다. 구현 전에 사용할 버전을 확정하고 `latest` tag는 사용하지 않는다.

## 5. Container Dependency

Backend는 PostgreSQL이 정상적으로 Connection을 받을 수 있는 상태가 된 이후 시작한다. 이를 위해 PostgreSQL Container에 Health Check를 설정한다.

```plain text
docker compose up
        │
        ▼
PostgreSQL Container Start
        │
        ▼
PostgreSQL Health Check
        │
        ▼
healthy
        │
        ▼
Spring Boot Start
        │
        ▼
Flyway Migration
        │
        ▼
JPA Schema Validation
        │
        ▼
Application Ready
```

단순히 PostgreSQL Container Process가 실행되었다는 것만으로 Backend가 준비되었다고 판단하지 않는다.

## 6. Database Schema Management

Database Schema의 Source of Truth는 **Flyway Migration**이다. Docker 또는 Hibernate가 Database Schema를 임의로 생성하지 않는다.

Migration 파일은 다음 위치에서 관리한다.

```plain text
backend/src/main/resources/db/migration/
├── V1__initial_schema.sql
├── V2__example.sql
└── ...
```

사용하지 않는다:

- Docker `init.sql`을 통한 Application Schema 관리
- Hibernate `ddl-auto=create`
- Hibernate `ddl-auto=create-drop`
- Hibernate `ddl-auto=update`

사용한다:

- Flyway Migration
- Hibernate `ddl-auto=validate`

Spring Boot 실행 시 Flyway가 아직 적용되지 않은 Migration을 실행한다. 그 이후 Hibernate는 Entity와 Database Schema가 호환되는지 검증한다.

## 7. PostgreSQL Data Persistence

PostgreSQL 데이터는 Docker Named Volume `postgres_data`에 저장한다.

일반적인 종료:

```bash
docker compose down
```

Container를 종료해도 Database 데이터는 유지한다.

Database를 완전히 초기화해야 할 경우에만 Volume까지 제거한다.

```bash
docker compose down -v
```

이 명령은 **로컬 Database 데이터를 모두 삭제하므로 명시적인 DB Reset 목적으로만 사용한다.** 이후 다시 실행하면 빈 PostgreSQL Database가 생성되고 Flyway Migration이 처음부터 적용된다.

## 8. Environment Variables

Secret 또는 환경별 설정값은 Repository에 직접 작성하지 않는다. 로컬 환경에서는 Root의 `.env`를 사용한다.

```plain text
DB_NAME=whipup
DB_USERNAME=whipup
DB_PASSWORD=local-password

KAKAO_CLIENT_ID=...
KAKAO_CLIENT_SECRET=...

JWT_SECRET=...
```

`.env`는 Git에 Commit하지 않는다. 대신 필요한 환경변수를 확인할 수 있도록 `.env.example`을 Commit하며 실제 Secret을 포함하지 않는다.

## 9. Spring Profile

로컬 Docker 환경에서는 `local` Spring Profile을 사용한다. Docker Compose가 `SPRING_PROFILES_ACTIVE=local`을 Backend에 전달한다.

Spring의 Database Connection은 Container 내부에서 `postgres` Host를 사용한다.

```plain text
jdbc:postgresql://postgres:5432/${DB_NAME}
```

Container 내부에서 Database 접근 시 `localhost`를 사용하지 않는다. `localhost`는 해당 Container 자기 자신을 의미한다.

## 10. Local Execution

최초 실행 전에 `.env.example`을 참고하여 `.env`를 생성한다.

Repository Root에서:

```bash
docker compose up --build
```

정상 실행 시:

```plain text
Backend
http://localhost:8080

PostgreSQL
localhost:5432
```

Backend readiness는 public health endpoint로 확인한다.

```bash
curl http://localhost:8080/health
```

정상 응답:

```json
{
  "status": "UP"
}
```

종료:

```bash
docker compose down
```

Database까지 완전히 초기화:

```bash
docker compose down -v
```

이후 다시 `docker compose up --build`하면 Flyway Migration이 처음부터 적용된다.

## 11. Flutter와 Backend 연결

Flutter App은 Docker Container에 포함하지 않는다.

```plain text
Flutter
Local Machine
      │
      │ HTTP
      ▼
Spring Boot
Docker :8080
      │
      ▼
PostgreSQL
Docker :5432
```

Flutter에서 사용하는 Backend Host는 실행 환경에 따라 달라질 수 있다. Web, iOS Simulator, Android Emulator, Physical Device는 각각 Host Machine에 접근하는 방법이 다를 수 있으므로 Flutter의 API Base URL은 환경 설정으로 분리한다. 구체적인 Platform별 주소는 Flutter 개발환경 구성 시 결정한다.

## 12. Dataset과 Database Schema의 분리

Docker/Flyway와 운영 Dataset Import의 책임을 구분한다.

```plain text
Flyway
→ Database Schema 생성 및 변경

Dataset Import
→ Ingredient / Recipe 데이터 적재
```

따라서 Flyway Migration에 Ingredient/Recipe 운영 Dataset을 직접 작성하지 않는다.

```plain text
Schema
backend/src/main/resources/db/migration/

Operational Data
data/
├── ingredients.csv
└── recipes/
```

Dataset Import 방법은 [data-import.md](data-import.md)를 따른다.

## 13. MVP에서 하지 않는 것

현재 단계에서는 다음을 구성하지 않는다.

- Production Docker Compose
- Cloud Deployment
- Kubernetes
- CI/CD
- Container Registry
- AWS RDS
- AWS ECS
- Monitoring
- Logging Infrastructure
- Docker Build Time Optimization
- Hot Reload Optimization
- Development Container Optimization

이 문서는 **Local Backend Development Environment**만 다룬다. Production Infrastructure는 배포 단계에서 별도로 설계한다.
