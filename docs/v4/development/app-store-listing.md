# App Store 입력 문구 (초안)

App Store Connect에 붙여 넣는 문구다. 제품 결정이 아니라 제출용 초안이며, 앱 동작·약관과 맞는지만 확인한다. 길이는 Apple 한도 안이다.

## 검색에 걸리는 항목

App Store 검색은 **앱 이름, 부제, 키워드 필드**만 색인한다. 설명은 검색에 쓰이지 않는다. 같은 단어를 이 세 곳에 중복해서 쓰면 키워드 공간만 낭비되므로, 이름·부제에 쓴 단어(냉장고, 재료, 레시피, 자취, 요리, 뭐, 먹지)는 키워드에서 뺐다.

| 항목 | 한도 | 문구 |
|---|---|---|
| 앱 이름 | 30자 | `Whippy - 냉장고 재료 레시피` (19자) |
| 부제 | 30자 | `자취 요리, 오늘 뭐 먹지?` (15자) |
| 키워드 | 100자, 쉼표로 구분, 공백 없음 | `쇼츠,간단요리,자취생,집밥,한끼,계란,볶음밥,덮밥,찌개,오늘뭐먹지,냉털,냉장고털이,혼밥,야식,10분,유튜브,식단,밥` |
| 프로모션 텍스트 | 170자 | `냉장고에 있는 재료만 고르면, 지금 바로 만들 수 있는 요리를 찾아드려요. 영상 보고 따라 만드는 자취 요리 레시피.` |

앱 이름 `Whippy`가 이미 다른 앱에 쓰이고 있으면 App Store Connect에서 거절된다. 그때는 `Whippy 휘피` 등으로 바꾼다. 홈 화면 표시 이름은 `Whippy`로 그대로 둔다.

## 설명 (4000자 한도)

```
냉장고에 있는 재료만 골라 보세요. 지금 바로 만들 수 있는 요리를 찾아 드려요.

Whippy는 내가 가진 재료로 만들 수 있는 레시피를 추천하는 앱이에요. 장보기 전에 "오늘 뭐 먹지?" 고민될 때, 냉장고에 남은 재료를 털고 싶을 때 써 보세요.

■ 이런 점이 좋아요
• 재료만 고르면 끝: 계란, 대파, 김치, 고추장… 가지고 있는 재료를 체크해 두세요.
• 지금 바로 만들 수 있는 요리: 재료가 모두 있는 레시피부터 보여 드려요.
• 재료 한 가지만 더 있으면 되는 요리: 하나만 사면 만들 수 있는 요리도 알려 드려요.
• 영상으로 따라 하기: 레시피마다 원본 YouTube 영상을 앱 안에서 바로 볼 수 있어요.
• 오늘 먹을 메뉴 담기: 마음에 드는 레시피를 오늘 메뉴로 담아 두세요.

■ 이런 분께 추천해요
• 자취를 시작해서 뭘 해 먹을지 막막한 분
• 냉장고에 남은 재료를 알뜰하게 쓰고 싶은 분
• 쇼츠로 본 간단 요리를 집에서 따라 해 보고 싶은 분

■ 가입 없이 바로 시작
이름, 이메일, 전화번호 없이 바로 시작할 수 있어요. 계정은 앱을 처음 열 때 자동으로 만들어지고, 설정에서 언제든 삭제할 수 있어요.

레시피는 조리 참고용이에요. 알레르기와 식재료 상태는 직접 확인해 주세요. 문의: sw09112@naver.com
```

## 기타 입력값

- 기본 언어: 한국어
- 카테고리: 음식 및 음료 (보조: 라이프스타일)
- 가격: 무료
- 연령 등급: 설문에서 모든 항목 "없음"으로 답하면 4+가 나온다. 단, 사용자 생성 콘텐츠나 웹 접근에 관한 항목은 앱 안에서 외부 YouTube 영상을 재생하므로 설문 문구를 읽고 정직하게 답한다.
- 개인정보 처리방침 URL: https://cherry-target-075.notion.site/404e10b2db2881728abeed9f39726f0e
- 지원 URL: https://cherry-target-075.notion.site/404e10b2db2881bbb839d65b03cdc707
- 마케팅 URL: 비워 둔다.
- 저작권: `2026 이석원`

## 앱 개인정보 설문

- 추적: 아니요.
- 수집 데이터:
  - 사용자 ID(게스트 계정 번호): 앱 기능, 사용자와 연결됨, 추적 안 함
  - 기타 사용자 콘텐츠(보유 재료, 오늘 메뉴): 앱 기능, 사용자와 연결됨, 추적 안 함
- 이름, 이메일, 위치, 연락처, 사진 등은 수집하지 않는다.
- `PrivacyInfo.xcprivacy`의 수집 항목과 같아야 한다.

## 심사 메모 (App Review Information)

로그인 정보 필요 없음. 아래를 그대로 붙여 넣는다.

```
This app does not require sign-in.
- On first launch the app creates an anonymous guest account automatically (no name, email or phone number is collected). Accepting the Terms and Privacy Policy and selecting a few ingredients lets you use all features.
- Recipes are matched to the ingredients the user owns. Each recipe plays its original YouTube video inside the app.
- The app needs our server (https://api.seokwonlee.xyz) to be online. It is operated continuously during review.
- Account deletion: Settings > Account deletion. Support: Settings > Support (opens our support page).
- Accounts inactive for one year are deleted automatically.
Contact: sw09112@naver.com
```

## 제출 전 확인

- [ ] 6.9인치(1320×2868) 스크린샷 3~10장
- [ ] 개인정보 처리방침·지원 URL이 열린다(웹에서 공유 켜짐)
- [ ] 서버 `/health`가 UP이고 심사 기간 동안 노트북이 켜져 있다
- [ ] 빌드 번호가 이전 업로드보다 크다
