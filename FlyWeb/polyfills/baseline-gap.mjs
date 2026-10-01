// Lista las funciones web con estado Baseline que Chromium 116 no tiene, según web-features, y si el
// paquete de polyfills de FlyWeb las cubre. Uso: npm ci && node baseline-gap.mjs > ../docs/baseline-gap.md
import { features } from 'web-features';
import fs from 'node:fs';

const CHROMIUM = 116;
// Funciones de web-features que cubre build.mjs (mantener a la par de MODULES).
const COVERED = new Set([
  'array-group', 'promise-withresolvers', 'array-fromasync', 'url-canparse', 'set-methods',
  'iterator-methods', 'promise-try', 'regexp-escape', 'uint8array-base64-hex',
]);
const version = JSON.parse(fs.readFileSync(new URL('./node_modules/web-features/package.json', import.meta.url))).version;

const rows = [];
for (const [id, f] of Object.entries(features)) {
  if (f.kind && f.kind !== 'feature') continue;
  const s = f.status ?? {};
  const chrome = parseFloat(s.support?.chrome);
  if (!s.baseline || !(chrome > CHROMIUM)) continue;
  rows.push({ id, name: f.name, chrome, baseline: s.baseline, low: s.baseline_low_date ?? '',
              groups: [].concat(f.group ?? []).join(', ') });
}
rows.sort((a, b) => (a.baseline === b.baseline ? a.low.localeCompare(b.low) : a.baseline === 'high' ? -1 : 1));

const label = { high: 'amplia', low: 'reciente' };
console.log(`# Funciones Baseline que faltan en Chromium ${CHROMIUM}\n`);
console.log(`Generado con \`FlyWeb/polyfills/baseline-gap.mjs\` (web-features ${version}). No editar a mano.\n`);
console.log(`- **amplia**: Baseline "ampliamente disponible" (30 meses en todos los navegadores principales): la web la da por supuesta.`);
console.log(`- **reciente**: Baseline "recién disponible": se empieza a usar, normalmente con alternativa.`);
console.log(`- **Polyfill**: sí = la cubre \`flyweb_polyfills.js\`; vacío = no (CSS, HTML o APIs del navegador no se pueden suplir con JS razonable).\n`);
console.log(`Total: ${rows.length} (${rows.filter(r => r.baseline === 'high').length} amplias, ${rows.filter(r => COVERED.has(r.id)).length} con polyfill).\n`);
console.log('| Baseline | Desde | Chrome | Función | id | Grupo | Polyfill |');
console.log('|---|---|---|---|---|---|---|');
for (const r of rows) {
  console.log(`| ${label[r.baseline]} | ${r.low} | ${r.chrome} | ${r.name.replaceAll('|', '\\|')} | \`${r.id}\` | ${r.groups} | ${COVERED.has(r.id) ? 'sí' : ''} |`);
}
