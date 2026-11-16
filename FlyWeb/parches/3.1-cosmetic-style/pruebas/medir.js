const { chromium } = require('playwright');
const fs = require('fs');
const sels = fs.readFileSync(process.argv[2], 'utf8').trim().split('\n');
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage();
  console.log('Chromium', b.version());
  await p.setContent('<!doctype html><body></body>');
  const r = await p.evaluate(async (sels) => {
    const N = 2000, ITER = 150;
    const divs = [];
    for (let i = 0; i < N; i++) { const d = document.createElement('div'); d.style.cssText = 'position:absolute;width:10px;height:10px;background:red;left:0;top:0'; document.body.appendChild(d); divs.push(d); }
    const run = () => { const t0 = performance.now(); for (let k = 0; k < ITER; k++) { for (let i = 0; i < N; i++) divs[i].style.transform = `translate(${(i*7+k)%800}px,${(i*13+k)%600}px) rotate(${k}deg)`; document.body.offsetHeight; } return (performance.now() - t0) / ITER; };
    const sheet = new CSSStyleSheet();
    const res = {};
    const med = (f) => { const a = [f(), f(), f(), f(), f()].sort((x,y)=>x-y); return +a[2].toFixed(2); };
    res.sin_hoja = med(run);
    sheet.replaceSync('.no-existe{display:none}'); document.adoptedStyleSheets = [sheet];
    res.hoja_sin_style = med(run);
    sheet.replaceSync('[data-fw0123456789abcdef]{display:none !important}');
    res.hoja_marcador = med(run);
    sheet.replaceSync(sels.map(s => s + '{display:none !important}').join('\n'));
    res.hoja_24_style = med(run);
    sheet.replaceSync(sels[0] + '{display:none !important}');
    res.hoja_1_style = med(run);
    sheet.replaceSync('.ad-wrap div[style*="z-index: 2147483647"]{display:none}');
    res.hoja_1_style_clave_clase = med(run);
    sheet.replaceSync('div.x[style*="z-index"]{display:none}');
    res.hoja_style_compuesto_con_clase = med(run);
    document.adoptedStyleSheets = [];
    res.sin_hoja_otra_vez = med(run);
    return res;
  }, sels);
  console.log(JSON.stringify(r, null, 1));
  await b.close();
})();
