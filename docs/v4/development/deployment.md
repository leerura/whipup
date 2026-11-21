# 배포: Oracle Cloud

운영 서버를 개인 노트북에서 Oracle Cloud의 Always Free Arm VM으로 옮기는 계획이다. Compose 구성(backend, postgres, redis, https-proxy, prometheus, grafana)은 그대로 쓰며 코드 변경은 없다. 모든 Compose 이미지는 `linux/arm64` 빌드를 제공한다.

## 결정

- 서버: Oracle Cloud **Always Free** Ampere(`VM.Standard.A1.Flex`) 1대, 무료 한도 안에서만 사용한다.
- 계정: **Pay As You Go로 업그레이드**한다. 한가한 Always Free 인스턴스가 회수될 수 있어서(7일간 사용률이 기준 이하이면 회수 대상이라고 알려져 있다. 기준 수치는 출처마다 달라 확인하지 못했다) 이를 피하기 위해서다. 업그레이드해도 Always Free 한도 안의 사용은 무료이고 한도를 넘는 사용량만 과금된다고 Oracle 문서에 있다. 유료 계정은 청구 상한이 없다.
- 청구 보호: 예산 알림을 먼저 건다. 예산은 알려 주기만 하고 자원을 멈추지 않는다.
- 노트북 서버는 전환이 끝나고 확인될 때까지 켜 둔다(롤백 수단).

## 서버 주소(도메인)

- 앱이 쓰는 서버 주소는 `https://api.seokwonlee.xyz`다. 가비아에서 `seokwonlee.xyz`를 1년 기간으로 샀고 가비아 네임서버를 쓴다. 자동 연장은 끄고, 만료 전에 앱을 내리거나 갱신한다(만료된 주소를 다른 사람이 사면 앱 요청이 그쪽으로 간다).
- DNS는 `api` A 레코드 하나이며 서버 공인 IP를 가리킨다(TTL 300초). 서버를 옮기면 이 값만 바꾼다. 앱은 다시 배포하지 않아도 된다.
- Caddy는 도메인 사이트와 기존 IP 사이트를 함께 서빙한다. 도메인은 기본 인증서 발급을 쓰고 443 포트만 필요하다. 이미 배포된 앱이 끊기지 않도록 IP 사이트는 당분간 남긴다.
- 릴리스 빌드는 `--dart-define=WHIPUP_API_BASE_URL=https://api.seokwonlee.xyz`로 만든다.

## 비용 안전장치

1. 업그레이드 직후 **예산(Budget)** 을 만든다: 월 예산을 1달러 안팎으로 두고, 예상이 아니라 **실제 지출**이 예산의 1% 정도(약 0.01달러)에 닿으면 이메일로 알리는 규칙을 둔다. 첫 과금이 바로 알림으로 오게 하려는 것이다. 콘솔 메뉴 위치(Billing & Cost Management → Budgets)는 바뀔 수 있다.
2. 첫 한 달은 Cost Analysis를 주 1회 확인한다.
3. 아래를 지킨다.
   - Arm VM은 1대, **2 OCPU · 12GB 이하**. 한도는 최근 줄었다는 보도가 있으므로 만들기 전에 공식 Always Free 문서를 다시 확인한다.
   - 부트 볼륨은 필요한 만큼만(50GB 안팎). 볼륨 총합이 무료 한도를 넘지 않게 한다. 한도 값은 공식 문서에서 확인한다.
   - 로드 밸런서, 관리형 DB 등 Always Free가 아닌 서비스는 만들지 않는다.
   - 공인 IP는 예약 IP를 쓴다. 앱은 도메인으로 접속하므로 IP가 바뀌면 DNS A 레코드만 고치면 된다. 예약 IP의 무료 여부는 확인한다.

## 서버 구성

- 이미지: Ubuntu(aarch64). 홈 리전은 가입 때 정하며 바꿀 수 없다(한국 리전 권장).
- 열 포트: Oracle Security List에서 `443`(전체)과 `22`(내 IP만). 서버 안 iptables에서도 `443`을 연다. Caddy가 80번 challenge를 쓰지 않으므로 80은 열지 않는다. Security List만 열고 서버 방화벽을 빼먹는 것이 흔한 실수다.
- 시작 서비스: `docker compose up -d backend https-proxy prometheus grafana`(postgres, redis는 의존성으로 같이 뜬다). `recipe-pipeline`은 서버에서 돌리지 않는다.
- Prometheus, Grafana, Actuator는 외부에 열지 않는다. Grafana는 SSH 터널(`ssh -L 3000:127.0.0.1:3000 ...`)로 본다.

## 옮기는 순서

1. (사람) Oracle 가입, Pay As You Go 업그레이드, 예산 알림 설정.
2. VM 생성 후 `Out of host capacity` 오류가 나면 다른 가용 도메인으로 시도하거나 시간을 두고 다시 만든다.
3. Docker와 compose 플러그인을 설치하고 저장소를 서버로 옮긴다. `.env`는 Git이 아니라 `scp`로 복사한다.
4. `.env`의 `WHIPUP_PUBLIC_IP`를 새 공인 IP로 바꾼다. **`JWT_SECRET`은 바꾸지 않는다**(바꾸면 모든 게스트 계정의 토큰이 무효가 되어 데이터를 잃는다).
5. 서버에서 `docker compose up -d --build ...`를 실행한다. 첫 빌드는 느릴 수 있다.
6. 재료·레시피 데이터는 서버에서 `make import-data`로 넣는다(`data/` 폴더 필요). 사용자 데이터를 옮기려면 `pg_dump`로 덤프해 복원하고 `JWT_SECRET`을 그대로 쓴다.
7. 밖에서 `https://새IP/health`가 열리는지 확인한다.
8. 앱의 `WHIPUP_API_BASE_URL`을 새 주소로 바꿔 빌드하고 동작을 확인한다.
9. 확인이 끝나면 노트북 서버를 끈다.

## 운영

- 백업: 매일 `pg_dump`를 서버에 저장하고 다른 곳(개인 컴퓨터 등)에도 복사한다. 서버가 회수되거나 삭제돼도 복구할 수 있어야 한다.
- 서버가 멈추면 알림을 받을 수 있게 외부 업타임 확인을 하나 둔다.
- 업데이트: 서버에서 `git pull` 후 `docker compose up -d --build backend`.
