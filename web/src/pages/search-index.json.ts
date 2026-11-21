import { getRecipes, recipePath } from '../lib/data';

export function GET() {
  const index = getRecipes().map((r) => ({
    n: r.name,
    c: r.channelName,
    i: r.ingredients.map((i) => i.name).join(' '),
    u: recipePath(r),
    t: r.thumbnail,
    a: r.channelAvatar,
    k: r.requiredCount,
  }));
  return new Response(JSON.stringify(index), { headers: { 'Content-Type': 'application/json; charset=utf-8' } });
}
