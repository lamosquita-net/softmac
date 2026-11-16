const { chromium } = require('playwright');
const fs = require('fs');
const [selFile, injFile, bundleFile, force] = process.argv.slice(2);
const sels = fs.readFileSync(selFile, 'utf8').trim().split('\n');
const MARK = 'data-fw0123456789abcdef';
const inject = fs.readFileSync(injFile, 'utf8')
  .replace("'%s'", `'${MARK}'`).replace('const force = %s;', `const force = ${force};`).replace('of %s)', `of ${JSON.stringify(sels.concat(['div[style*="x"]:::nope']))})`);
const bundle = fs.readFileSync(bundleFile, 'utf8');
(async () => {
  const b = await chromium.launch(); const p = await b.newPage();
  p.on('pageerror', e => console.log('PAGEERROR', e.message));
  await p.setContent('<!doctype html><body><p>hola</p></body>');
  const r = await p.evaluate(async ({ inject, bundle, MARK, force }) => {
    window.cf_worker = { isFirstPartyUrl: () => false, hiddenClassIdSelectors: () => {}, onHandleMutationsBegin: () => 0, onHandleMutationsEnd: () => {} };
    window.content_cosmetic = { hide1pContent: force, generichide: false };
    // what InjectStylesheet(kUser) does, emulated with an adopted sheet
    const s = new CSSStyleSheet(); s.replaceSync(`[${MARK}]{display:none !important}`); document.adoptedStyleSheets = [s];
    const p1 = document.createElement('div'); p1.setAttribute('style', 'top: 0px; left: 0px; width: 1287px; height: 500px; position: fixed; z-index: 2147483647;'); p1.textContent = 'Este es un aviso propio de la web con bastante texto'; document.body.appendChild(p1);
    (0, eval)(inject);              // selectors arrive before the bundle
    (0, eval)(bundle);
    const sleep = ms => new Promise(r => setTimeout(r, ms));
    const out = { invalid_dropped: !window.content_cosmetic.styleAttrSelectors.has('div[style*="x"]:::nope') && !window.content_cosmetic.styleAttrForceSelectors.has('div[style*="x"]:::nope') };
    await sleep(3000);            // let the bundle start its observer (idle + delays)
    out.propio_1p_visible = getComputedStyle(p1).display !== 'none';
    const ov = document.createElement('div');
    ov.setAttribute('style', 'position: fixed; inset: 0px; z-index: 2147483647; pointer-events: auto;');
    document.body.appendChild(ov);
    await sleep(0);
    out.insertado_oculto = getComputedStyle(ov).display === 'none';
    const late = document.createElement('div'); document.body.appendChild(late); await sleep(0);
    late.setAttribute('style', 'position: fixed; inset: 0px; z-index: 2147483647; pointer-events: auto;');
    out.tarde_al_momento = getComputedStyle(late).display === 'none';
    await sleep(1300);
    out.tarde_tras_barrido = getComputedStyle(late).display === 'none';
    late.setAttribute('style', 'color: red');
    await sleep(1300);
    out.tarde_desmarcado = getComputedStyle(late).display !== 'none' && !late.hasAttribute(MARK);
    const normal = document.createElement('div'); normal.style.transform = 'translate(1px,1px)'; document.body.appendChild(normal); await sleep(1100);
    out.normal_visible = getComputedStyle(normal).display !== 'none';
    // cost: 2000 animated divs, same loop as medir.js
    const N = 2000, ITER = 150, divs = [];
    for (let i = 0; i < N; i++) { const d = document.createElement('div'); d.style.cssText = 'position:absolute;width:10px;height:10px;left:0;top:0'; document.body.appendChild(d); divs.push(d); }
    await sleep(50);
    const run = () => { const t0 = performance.now(); for (let k = 0; k < ITER; k++) { for (let i = 0; i < N; i++) divs[i].style.transform = `translate(${(i*7+k)%800}px,${(i*13+k)%600}px) rotate(${k}deg)`; document.body.offsetHeight; } return (performance.now() - t0) / ITER; };
    const a = [run(), run(), run(), run(), run()].sort((x, y) => x - y); out.ms_por_pasada = +a[2].toFixed(2);
    const t0 = performance.now(); document.querySelectorAll(Array.from(window.content_cosmetic.styleAttrSelectors).concat(Array.from(window.content_cosmetic.styleAttrForceSelectors)).join(',')); out.ms_un_barrido = +(performance.now() - t0).toFixed(2);
    return out;
  }, { inject, bundle, MARK, force: force === 'true' });
  console.log(force === 'true' ? 'agresivo/force' : 'estándar', JSON.stringify(r));
  await b.close();
})();
