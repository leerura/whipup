import { APP_STORE_URL, DEFINITION, getRecipes, recipePath } from '../lib/data';

export function GET({ site }: { site: URL }) {
  const base = site.toString().replace(/\/$/, '');
  const recipes = getRecipes();
  const lines = [
    '# Whippy',
    '',
    `> ${DEFINITION}. iPhone용 무료 앱이고 회원가입이 필요 없습니다. 레시피는 유튜브 쇼츠 영상과 재료, 만드는 순서로 구성됩니다.`,
    '',
    '## 주요 페이지',
    `- [레시피 목록](${base}/): 요리 이름이나 재료로 검색`,
    `- [앱 소개](${base}/about/): 플랫폼, 가격, 사용법, 자주 묻는 질문`,
    `- [App Store](${APP_STORE_URL}): 앱 다운로드`,
    '',
    '## 레시피',
    ...recipes.map((r) => `- [${r.name} - ${r.channelName}](${base}${encodeURI(recipePath(r))})`),
    '',
  ];
  return new Response(lines.join('\n'), { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
}
