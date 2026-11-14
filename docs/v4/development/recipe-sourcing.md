# 레시피 영상 수집

pipeline이 처리할 영상 URL을 사람이 하나씩 찾지 않고, 정해 둔 채널의 Shorts에서 후보를 골라 `tools/data-pipeline/input/shorts-urls.txt`에 추가한다. 이후 Gemini 추출과 데이터 반영은 [V3 recipe pipeline](../../v3/development/recipe-pipeline.md)과 [레시피 데이터 반영 가이드](recipe-data-guidelines.md)를 따른다. 이 문서는 후보를 **고르는 기준**만 정한다.

## 채널

- 채널은 `tools/data-pipeline/input/discovery-channels.txt`에 채널 ID로 적는다. 이미 공개된 레시피가 나온 채널 중 구독자가 많은 채널부터 고른다.
- 현재 채널: 1분요리 뚝딱이형, 자취요리신, 유지만, 김진순 점심시간, 살림팝.

## 후보 기준

`python3 tools/data-pipeline/src/discover.py`는 YouTube Data API 키 없이 공개 채널 페이지만 읽는다. 기본은 목록만 출력하고, `--write`를 주면 URL 파일 끝에 주석과 함께 추가한다.

- 조회수 10만 이상(`--min-views`).
- 이미 URL 목록(주석 처리된 것 포함)이나 최종 dataset에 있는 영상은 제외한다.
- 제목에 먹방, 브이로그, 광고, 협찬 같은 단어가 있으면 제외한다.
- oEmbed로 외부 재생이 가능한 영상만 남긴다([제품 기준](../product/product.md)).
- 채널당 조회수 순으로 최대 12개(`--per-channel`).
- 채널 페이지 구조가 바뀌어 목록을 읽지 못하면 오류로 멈춘다.

재료 수, 특수 재료, 만드는 법 유무는 영상을 보기 전에는 알 수 없으므로 수집 단계에서 거르지 않는다. 이 판단은 데이터 반영 단계의 [공개하지 않는 레시피 기준](recipe-data-guidelines.md#5-공개하지-않는-레시피)을 따른다.
