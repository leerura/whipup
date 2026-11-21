import { defineConfig } from 'astro/config';

// 배포 주소는 PUBLIC_SITE_URL로 준다. 기본값은 로컬 주소다.
const site = process.env.PUBLIC_SITE_URL || 'http://localhost:4321';

export default defineConfig({
  site,
  output: 'static',
  trailingSlash: 'always',
  build: { format: 'directory' },
});
