// baseline-nivel.js <N> : Baseline de Chrome N (MOTOR-8, nivel 129). Ejecutar desde un directorio con
// `npm install web-features @mdn/browser-compat-data` (versiones anotadas en motor.md).
// (1) funciones de web-features con support.chrome = N; (2) subfunciones (by_compat_key) con chrome = N;
// (3) claves de BCD con chrome = N (sin flag, prefijo ni implementación parcial) y si Firefox y Safari las tienen.
// Baseline = las tres. Las claves de (3) que no estén en (2) también cuentan (principio 12).
const fs = require("fs");
const N = process.argv[2];
const wf = JSON.parse(fs.readFileSync("node_modules/web-features/data.json"));
const bcd = JSON.parse(fs.readFileSync("node_modules/@mdn/browser-compat-data/data.json"));
const isN = v => v && new RegExp("^" + N + "(\\.|$)").test(v);
console.log("## web-features " + JSON.parse(fs.readFileSync("node_modules/web-features/package.json")).version + ", BCD " + bcd.__meta.version);
console.log("## (1) funciones");
for (const [id, v] of Object.entries(wf.features)) {
  if (v.kind && v.kind !== "feature") continue;
  const s = v.status || {};
  if (isN((s.support || {}).chrome)) console.log([id, v.name, "baseline:" + s.baseline, s.baseline_low_date || ""].join(" | "));
}
console.log("## (2) subfunciones");
for (const [id, v] of Object.entries(wf.features)) {
  if (v.kind && v.kind !== "feature") continue;
  for (const [k, s] of Object.entries((v.status || {}).by_compat_key || {}))
    if (isN((s.support || {}).chrome)) console.log([id, k, "baseline:" + s.baseline, s.baseline_low_date || "", "función:" + (v.status || {}).baseline].join(" | "));
}
console.log("## (3) BCD");
function first(st) {
  for (const s of (Array.isArray(st) ? st : [st])) {
    if (!s || s.flags || s.prefix || s.alternative_name || s.partial_implementation || s.version_removed) continue;
    if (s.version_added && s.version_added !== "preview") return s.version_added;
  }
  return null;
}
function walk(o, path) {
  for (const [k, v] of Object.entries(o)) {
    if (k === "__compat") {
      const s = v.support || {};
      if (first(s.chrome) === N) {
        const ff = first(s.firefox), sf = first(s.safari);
        console.log([path.join("."), "ff:" + ff, "saf:" + sf, ff && sf ? "TODOS" : ""].join(" | "));
      }
    } else if (typeof v === "object" && !k.startsWith("__")) walk(v, path.concat(k));
  }
}
for (const top of ["api", "css", "html", "http", "javascript", "svg", "mathml", "webassembly"]) if (bcd[top]) walk(bcd[top], [top]);
