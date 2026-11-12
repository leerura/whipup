# V4 구현 영향과 완료 기준

V4 구현자는 먼저 이 문서와 링크된 V4 계약을 읽고, 변경하지 않는 재료·레시피 매칭 규칙은 V3 문서를 따른다. V4 범위를 위해 recipe pipeline이나 data fixture를 바꾸지 않는다.

## Backend

- 기존 matcher를 재사용해 검색과 오늘 메뉴 response의 `missingCount`/Requirement 결과를 만든다. Flutter가 inventory 관계를 재계산하지 않는다.
- Redis client는 오늘 메뉴에만 사용한다. 연결 실패가 backend 전체 요청 실패로 번지지 않게 하고, 목록 read는 빈 목록 fallback, write는 명시적 `503`으로 처리한다.
- Redis는 AOF와 named volume을 Compose에 포함한다. key TTL은 서버 timezone이 아니라 KST 다음 자정을 명시적으로 계산한다.
- 검색은 DB/기존 repository 관례 안에서 `PUBLISHED`와 title/ingredient display name을 필터링한다. V4가 필요 없는 별도 검색 엔진·일반 캐시를 도입하지 않는다.
- 신규 약관 동의와 온보딩 저장은 각각 한 트랜잭션으로 처리한다. terms consent가 필요한 계정은 보호 endpoint에서 `403`으로 막는다.
- 기존 계정의 약관 동의·온보딩 backfill은 forward migration으로 처리한다. 이미 적용된 migration을 편집하지 않는다.
- detail projection에 `addableVariants`를 추가하고, 후보 계산은 V3 문서의 exact/accepted/option 후보를 따르며 새 전역 매칭을 만들지 않는다.

## Apple 로그인

- `AuthProvider`에 `APPLE`을 추가하고 `POST /api/v1/auth/apple`은 `loginWithApple`로 구현한다. Kakao 로그인 코드와 `LoginResponse`를 재사용한다.
- Apple 검증 클라이언트(공개키 조회·캐시, 토큰 교환, revoke)와 설정 값은 Apple 전용 패키지에 둔다. 설정이 비어 있으면 애플리케이션은 정상 기동하고 Apple 로그인만 `503 APPLE_LOGIN_UNAVAILABLE`을 반환한다.
- 설정 값은 environment variable로 주입하며 `.env.example`에는 이름만 둔다. 실제 key는 commit하지 않는다.
- 계정 삭제는 DB 삭제 커밋 뒤에 revoke를 호출하고, revoke 실패가 삭제 결과를 바꾸지 않는다.
- Flutter는 `sign_in_with_apple`로 nonce를 생성하고 SHA-256 hex를 Apple 요청에 넣는다. iOS Sign in with Apple capability/entitlements 설정이 필요하다.

## 자동 로그인

- `GET /api/v1/me`는 기존 `User`의 동의·온보딩 상태와 보유 재료 존재 여부를 읽는 조회 하나이며 새 도메인 개념이 아니다. 약관 동의 필터의 예외 경로에 포함한다.
- Flutter는 access token 하나를 iOS Keychain 등 보안 저장소에 저장하고 앱 시작 때 읽는다. 저장·삭제는 로그인 성공, 로그아웃, 계정 삭제, `401` 확인 실패에서만 한다.
- 시작 모션은 유지하고, 토큰 확인은 모션과 병렬로 수행한다.

## Flutter

- API base URL, auth token 저장, 기존 공통 header/탭/router/state-management 관례를 유지한다.
- 검색·오늘 메뉴·온보딩 화면은 Figma V4-S/T/E/G 시안의 레이아웃을 구현하되, 상태 판단은 API response로 한다. 검색 결과는 추천 목록 화면의 문맥을 유지한 채 교체한다.
- 재료 상세 조작 후 현재 detail을 재조회하거나 동일한 repository state를 갱신해 충족 상태를 즉시 반영한다.
- 외부 Notion·Coupang URL은 `url_launcher`의 외부 application mode를 사용한다. Coupang은 non-browser application(Universal Link)을 먼저 시도하고 지원되지 않으면 외부 브라우저로 fallback한다. 외부 이동 실패는 앱이 멈추지 않게 짧은 오류 안내를 보인다.
- Redis unavailable, 검색 empty, network error를 같은 빈 상태로 합치지 않는다.

## 검증 시나리오

1. 동일 검색어에서 `AVAILABLE`에는 바로 만들 수 있는 결과만, `ALL`에는 하나 이상 부족한 결과만 보이며 두 결과는 겹치지 않는다.
2. 제목 또는 source ingredient display name이 검색어와 일치할 때만 결과에 들어가며 `DRAFT`는 어느 검색에도 없다.
3. 오늘 메뉴는 동일 recipe 중복 없이 최신순이고, KST 자정 뒤 새 목록이다. `DRAFT`로 바뀐 recipe는 목록에서 숨는다.
4. Redis read 장애는 홈의 오늘 메뉴만 숨기며 추천/재료함은 동작한다. Redis write 장애는 담김 상태로 바꾸지 않는다.
5. detail에서 복수 후보 중 하나를 추가하면 해당 Requirement가 만족되고, 관계 없는 variant는 추가 후보에 없다.
6. detail에서 `다 먹었어요`를 확정하기 전에는 보유 재료가 삭제되지 않는다. 확정 후에는 상세 상태가 즉시 바뀐다.
7. 신규 계정은 약관 세 항목 동의 전 보호 API를 쓸 수 없고, 기존 계정은 약관 화면을 다시 보지 않는다.
8. 빠른 선택, 전체 목록 선택, 빈 선택 모두 온보딩을 한 번만 완료한다. 이후 재료를 모두 지워도 온보딩을 반복하지 않는다.
9. 쿠팡 이동은 일반 검색 URL을 외부로 열며 inventory를 변경하지 않는다.
10. Apple 로그인은 키가 없을 때 `503`으로 실패하고 다른 로그인·API에 영향이 없다. 유효한 키를 넣으면 로그인·계정 삭제 revoke가 코드 변경 없이 동작한다.
11. 로그인 후 앱을 완전히 종료했다가 다시 열면 모션 뒤에 로그인 없이 상태에 맞는 화면으로 이동한다. 만료·무효 토큰은 지워지고 로그인 화면이 보이며, 로그아웃과 계정 삭제 뒤에는 재진입해도 로그인 화면이다.
12. 기존 V3 ingredient matcher, recommendation, recipe detail, account deletion 관련 테스트가 회귀하지 않는다.
