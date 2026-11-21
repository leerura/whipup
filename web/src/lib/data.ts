import fs from 'node:fs';
import path from 'node:path';

export const SITE_NAME = 'Whippy';
export const APP_STORE_URL = 'https://apps.apple.com/kr/app/id6834718918';
export const CONTACT_EMAIL = 'sw09112@naver.com';
export const PER_PAGE = 12;
export const DEFINITION = '냉장고에 있는 재료로 지금 만들 수 있는 요리를 추천해 주는 자취생용 iPhone 앱';

export interface Ingredient {
  name: string;
  quantity: string;
  rawText: string;
  optional: boolean;
}

export interface Recipe {
  slug: string;
  name: string;
  videoId: string;
  videoUrl: string;
  embedUrl: string;
  thumbnail: string;
  channelName: string;
  channelAvatar: string | null;
  sourceTitle: string | null;
  ingredients: Ingredient[];
  steps: string[];
  requiredCount: number;
  summary: string;
}

// 저장소의 data/ 를 빌드 때 읽는다(web/ 에서 실행). 데이터를 복사해 두지 않는다.
const DATA_DIR = path.resolve(process.cwd(), '..', 'data');

function videoIdOf(reference: string): string | null {
  const m = reference.match(/(?:shorts\/|youtu\.be\/|[?&]v=)([A-Za-z0-9_-]{11})/);
  return m ? m[1] : null;
}

// 요약의 "주요 재료"에서는 어느 레시피에나 들어가는 양념·기본 재료를 뒤로 미룬다.
const PANTRY = new Set(['물', '소금', '맛소금', '설탕', '후추', '식용유', '올리브유', '참기름', '간장', '맛술', '굴소스', '고춧가루', '참깨', '물엿', '다진 마늘']);

function buildSummary(name: string, ingredients: Ingredient[], steps: number, channel: string): string {
  const required = ingredients.filter((i) => !i.optional);
  const names = required.map((i) => i.name);
  const main = [...names.filter((n) => !PANTRY.has(n)), ...names.filter((n) => PANTRY.has(n))].filter((n, idx, arr) => arr.indexOf(n) === idx).slice(0, 3);
  const mainText = main.length ? ` 주요 재료는 ${main.join(', ')}.` : '';
  return `${name}: 재료 ${required.length}개, ${steps}단계 레시피.${mainText} 영상 출처: ${channel}.`;
}

let cache: Recipe[] | null = null;

export function getRecipes(): Recipe[] {
  if (cache) return cache;
  const dir = path.join(DATA_DIR, 'recipes');
  const recipes: Recipe[] = [];
  for (const file of fs.readdirSync(dir).filter((f) => f.endsWith('.json'))) {
    const d = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf-8'));
    if (d.status !== 'PUBLISHED') continue;
    const videoId = videoIdOf(d.shortsReference ?? '');
    if (!videoId || !d.sourceChannelName) continue;
    const ingredients: Ingredient[] = (d.ingredients ?? []).map((i: any) => ({
      name: i.displayName,
      // 양·단위가 없으면 영상에서 읽은 원문 표현을 보여 준다(이름과 같으면 비운다).
      quantity: [i.amount, i.unit].filter(Boolean).join('') || (i.rawText && i.rawText.trim() !== i.displayName ? i.rawText.trim() : ''),
      rawText: i.rawText,
      optional: Boolean(i.optional),
    }));
    const steps: string[] = d.steps ?? [];
    recipes.push({
      slug: `${String(d.name).trim().replace(/\s+/g, '-')}-${videoId}`,
      name: d.name,
      videoId,
      videoUrl: `https://www.youtube.com/shorts/${videoId}`,
      embedUrl: `https://www.youtube.com/embed/${videoId}`,
      thumbnail: `https://i.ytimg.com/vi/${videoId}/hqdefault.jpg`,
      channelName: d.sourceChannelName,
      channelAvatar: d.sourceChannelThumbnailUrl ?? null,
      sourceTitle: d.sourceTitle ?? null,
      ingredients,
      steps,
      requiredCount: ingredients.filter((i) => !i.optional).length,
      summary: buildSummary(d.name, ingredients, steps.length, d.sourceChannelName),
    });
  }
  recipes.sort((a, b) => a.name.localeCompare(b.name, 'ko') || a.videoId.localeCompare(b.videoId));
  cache = recipes;
  return recipes;
}

export function getCatalogStats() {
  const cat = JSON.parse(fs.readFileSync(path.join(DATA_DIR, 'ingredients.json'), 'utf-8'));
  const variants = cat.ingredients.reduce((n: number, g: any) => n + g.variants.length, 0);
  return { ingredientCount: variants };
}

export function recipePath(r: Recipe): string {
  return `/recipes/${r.slug}/`;
}

export function pageCount(): number {
  return Math.ceil(getRecipes().length / PER_PAGE);
}

export function pageItems(page: number): Recipe[] {
  return getRecipes().slice((page - 1) * PER_PAGE, page * PER_PAGE);
}
