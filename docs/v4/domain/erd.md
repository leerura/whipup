# V4 저장 모델

V3의 관계형 ingredient/recipe 모델은 그대로 유지한다. V4는 계정 동의 데이터와 Redis today-menu만 추가한다. 실제 테이블/컬럼명은 기존 migration convention을 따른다.

## 계정 동의

```text
USER
  ...existing fields
  terms_version NULL
  terms_accepted_at NULL
  privacy_version NULL
  privacy_accepted_at NULL
  age_14_confirmed_at NULL
  onboarding_completed NOT NULL
```

V4 새 계정은 약관 동의 전 세 동의 시각이 `NULL`이다. V4 도입 전 existing user는 현재 배포한 약관 버전과 migration 시각으로 backfill한다. 기존 계정에 동의 화면을 다시 보여 주지 않는다.

## 온보딩 추천 재료

```text
INGREDIENT_VARIANT
  ...existing fields
  onboarding_suggested NOT NULL DEFAULT false
  onboarding_order NULL
```

`onboarding_suggested=true`인 selectable item만 빠른 선택 화면에 보인다. `onboarding_order` 오름차순으로 표시하며, 동률은 기존 catalog 순서를 쓴다. 이 속성은 group 자체에는 두지 않는다.

## Redis 오늘 메뉴

```text
daily-menu:{userId}:{YYYY-MM-DD}  -- Redis sorted set, KST 날짜
  member: recipeId
  score: addedAt epoch milliseconds
  expiry: 다음 KST 00:00:00
```

`ZADD NX`로 중복을 막고 `ZREVRANGE`로 최신순을 읽는다. `EXPIREAT`은 최초 추가와 이후 모든 추가 때 그 날짜의 다음 KST 자정으로 설정한다. Redis AOF와 Docker volume을 활성화해 컨테이너 재시작 동안에는 키가 유지되도록 한다. Redis 영속화는 자정 이후 이력 보관을 의미하지 않는다.
