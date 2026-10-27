// Genera flyweb_polyfills.js: los polyfills de core-js que necesita Chromium 116 para las funciones de
// JavaScript que la web moderna da por supuestas. Uso:
//   npm ci && node build.mjs <ruta de brave-core>
// Escribe <brave-core>/components/flyweb_polyfills/resources/flyweb_polyfills.js. Ver README.md.
import builder from 'core-js-builder';
import { minify } from 'terser';
import fs from 'node:fs';
import path from 'node:path';

// Cada módulo solo se añade si el navegador no lo trae (core-js comprueba en tiempo de ejecución), así que
// la lista se puede ampliar sin romper nada. Criterio: Baseline (web-features) y uso real en la web.
// Fuera, a propósito: lo que sustituye funciones nativas que Chromium 116 ya tiene (es.array.push,
// web.structured-clone, web.dom-exception.stack), lo no estándar (web.immediate) y lo pesado y raro
// (gestión explícita de recursos, Float16, Math.sumPrecise, getOrInsert).
export const MODULES = [
  // Baseline "ampliamente disponible" que Chromium 116 no tiene
  'es.object.group-by', 'es.map.group-by', 'es.promise.with-resolvers', 'es.array.from-async',
  'web.url.can-parse',
  // Baseline "recién disponible", habitual en código moderno
  /^es\.set\..*\.v2$/,
  'es.iterator.constructor', 'es.iterator.drop', 'es.iterator.every', 'es.iterator.filter',
  'es.iterator.find', 'es.iterator.flat-map', 'es.iterator.for-each', 'es.iterator.from',
  'es.iterator.map', 'es.iterator.reduce', 'es.iterator.some', 'es.iterator.take',
  'es.iterator.to-array',
  'es.promise.try', 'es.regexp.escape',
  'web.url.parse', 'web.url-search-params.delete', 'web.url-search-params.has',
  /^es\.uint8-array\./,
];

const out = process.argv[2]
  ? path.join(process.argv[2], 'components/flyweb_polyfills/resources/flyweb_polyfills.js')
  : 'flyweb_polyfills.js';

const bundle = await builder({
  modules: MODULES,
  targets: { chrome: '116' },
  format: 'bundle',
  summary: { comment: { size: false, modules: true } },
});
const header = bundle.slice(0, bundle.indexOf('*/', bundle.indexOf('modules:')) + 2);
const { code } = await minify(bundle, { compress: true, mangle: true, format: { comments: false } });
const banner = `/* FlyWeb: generado con FlyWeb/polyfills/build.mjs (softmac). No editar a mano. */\n`;
fs.mkdirSync(path.dirname(out), { recursive: true });
fs.writeFileSync(out, banner + header + '\n' + code + '\n');
console.log(`${out}: ${fs.statSync(out).size} bytes`);
