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

## 게스트 시작

- `POST /api/v1/auth/guest`는 `User`를 새로 만들고 WhipUp JWT를 발급해 `LoginResponse`로 반환한다. Kakao·Apple 클라이언트, 설정, 관련 DB 컬럼과 테스트는 제거한다. 이미 쓰는 `user_auth_account` 테이블 구조는 바꾸지 않는다.
- 약관 동의 필터의 예외 경로에는 `POST /api/v1/auth/guest`와 `GET /api/v1/me`, `DELETE /api/v1/me`, 약관 동의 endpoint를 둔다.
- 비활성 계정 정리는 매일 04:00(KST) 한 번 실행하는 Spring scheduled job으로 하고(검증용으로 `whipup.account-cleanup.cron` 설정으로 주기를 바꿀 수 있다), 삭제는 기존 계정 삭제 서비스를 계정마다 재사용한다. 한 계정의 삭제 실패가 나머지 정리를 멈추지 않는다.
- JWT 유효기간 설정은 3650일로 둔다. refresh token과 속도 제한은 만들지 않는다.
- Flutter는 access token 하나를 iOS Keychain 등 보안 저장소에 저장한다. 저장은 계정 생성 성공 때, 삭제는 계정 삭제와 `401` 확인 실패에서만 한다. Kakao SDK, Apple 로그인 의존성과 로그인 화면을 제거한다.
- 시작 모션은 유지하고, 토큰 확인이나 계정 생성은 모션과 병렬로 수행한다.

## 레시피 출처 채널

- recipe JSON에 선택 필드 `sourceChannelThumbnailUrl`을 추가한다. 값은 원본 채널의 프로필 사진 주소(88px)다. 수집하지 못하면 필드를 비워 두고 추측해서 채우지 않는다.
- recipe pipeline의 source metadata 수집(V3 pipeline 4단계)은 V4에서 `sourceTitle`, `sourceChannelName`, `sourceChannelId`, `sourceChannelThumbnailUrl`, `sourceMetadataFetchedAt` 다섯 값을 저장한다. Gemini 추출과는 계속 별도 단계다.
  - YouTube Data API 키가 있으면 videos API(제목·채널명·채널 ID)와 channels API(프로필 사진 `default` 크기)를 쓴다.
  - 키가 없거나 API 호출이 실패하면 공개 oEmbed(제목·채널명), 영상 공개 페이지(채널 ID), 채널 공개 페이지(프로필 사진)로 채운다.
  - 각 값은 따로 실패할 수 있으며, 실패한 값만 `null`로 남긴다.
- 에이전트가 저장된 source metadata를 recipe JSON에 반영할 때 `sourceChannelThumbnailUrl`도 그대로 옮긴다. 수집은 pipeline 실행 때 한 번 하고, 앱 요청 때 YouTube를 조회하지 않는다.
- 카드와 상세의 프로필 사진은 네트워크 이미지로 불러오고, 실패하면 첫 글자 원으로 대체한다. 이미지 실패가 화면 오류로 이어지지 않는다.

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
10. 처음 실행하면 로그인 없이 게스트 계정이 만들어지고 약관 화면으로 간다. 앱을 완전히 종료했다가 다시 열어도 같은 계정이 유지되고 새 계정이 만들어지지 않는다.
11. 저장된 토큰이 `401`이면 지우고 새 게스트 계정으로 시작한다. 서버에 연결할 수 없으면 다시 시도 안내를 보이고 토큰은 지우지 않는다.
12. 계정 삭제 뒤에는 새 게스트 계정으로 약관 화면부터 다시 시작한다. 설정에 로그아웃은 없다.
13. `last_active_at`이 365일보다 오래된 계정은 정리 작업 뒤 사라지고, 그 안의 계정은 남는다. 앱을 열면 해당 계정의 `last_active_at`이 갱신된다.
14. 기존 V3 ingredient matcher, recommendation, recipe detail, account deletion 관련 테스트가 회귀하지 않는다.
