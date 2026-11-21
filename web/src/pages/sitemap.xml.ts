import { getRecipes, pageCount, recipePath } from '../lib/data';

export function GET({ site }: { site: URL }) {
  const base = site.toString().replace(/\/$/, '');
  const urls = ['/', '/about/'];
  for (let n = 2; n <= pageCount(); n++) urls.push(`/page/${n}/`);
  for (const r of getRecipes()) urls.push(recipePath(r));
  const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls
    .map((u) => `  <url><loc>${base}${encodeURI(u)}</loc></url>`)
    .join('\n')}\n</urlset>\n`;
  return new Response(xml, { headers: { 'Content-Type': 'application/xml; charset=utf-8' } });
}
