// Renders FlyWeb branding PNGs/WebP into brave-core from the master SVG.
// Uso: node render-brand.js <icon.svg> <brave-core>   (necesita el paquete npm "playwright";
// CHROME=/ruta/al/chrome si no está el Chromium de Playwright)
const { chromium } = require('playwright');
const fs = require('fs');
const [svgPath, core] = process.argv.slice(2);
const svg = 'data:image/svg+xml;base64,' + fs.readFileSync(svgPath).toString('base64');
const TEXT_LIGHT = '#3b3e4f';

(async () => {
  const b = await chromium.launch(process.env.CHROME ? { executablePath: process.env.CHROME } : {});
  const p = await b.newPage();
  async function shot(w, h, html, out) {
    await p.setViewportSize({ width: w, height: h });
    await p.setContent(`<html><body style="margin:0;background:transparent;width:${w}px;height:${h}px;overflow:hidden">${html}</body></html>`);
    await p.evaluate(() => {
      const t = document.querySelector('span'); if (!t) return;
      let fs = parseFloat(getComputedStyle(t).fontSize);
      while (document.body.firstChild.scrollWidth > document.body.clientWidth && fs > 6)
        t.style.fontSize = (fs -= 0.5) + 'px';
    });
    await p.waitForTimeout(80);
    await p.screenshot({ path: out, omitBackground: true });
    console.log(out);
  }
  const icon = (s, white) =>
    `<img src="${svg}" style="display:block;width:${s}px;height:${s}px;${white ? 'filter:brightness(0) invert(1)' : ''}">`;
  const square = (s) => { const pad = Math.round(s * 0.04); return `<div style="padding:${pad}px">${icon(s - 2 * pad)}</div>`; };
  const wordmark = (w, h, white) =>
    `<div style="display:flex;align-items:center;height:${h}px;width:${w}px">${icon(h, white)}` +
    `<span style="font:bold ${Math.round(h * 0.62)}px 'DejaVu Sans',sans-serif;letter-spacing:-0.02em;margin-left:${Math.round(h * 0.12)}px;color:${white ? '#fff' : TEXT_LIGHT};white-space:nowrap">FlyWeb</span></div>`;

  const T = `${core}/app/theme`;
  const channels = ['', '_beta', '_dev', '_development', '_nightly'];
  // Tab / window icons (chrome://theme/current-channel-logo and friends).
  for (const c of channels) {
    for (const [dir, scale] of [['default_100_percent', 1], ['default_200_percent', 2]]) {
      for (const s of [16, 32]) {
        const f = `${T}/${dir}/brave/product_logo_${s}${c}.png`;
        if (fs.existsSync(f)) await shot(s * scale, s * scale, square(s * scale), f);
      }
    }
  }
  // Wordmarks: keep the original canvas sizes so layouts do not move.
  const marks = [
    ['default_100_percent/brave/product_logo_name_22.png', 77, 22, false],
    ['default_200_percent/brave/product_logo_name_22.png', 154, 44, false],
    ['default_100_percent/brave/product_logo_name_48.png', 164, 48, false],
    ['default_200_percent/brave/product_logo_name_48.png', 328, 96, false],
    ['default_100_percent/brave/product_logo_white.png', 214, 64, true],
    ['default_200_percent/brave/product_logo_white.png', 428, 128, true],
  ];
  for (const [rel, w, h, white] of marks) await shot(w, h, wordmark(w, h, white), `${T}/${rel}`);
  // brave://version logo (IDR_PRODUCT_LOGO / _WHITE).
  const R = `${core}/components/resources`;
  for (const [dir, k] of [['default_100_percent', 1], ['default_200_percent', 2]]) {
    await shot(164 * k, 48 * k, wordmark(164 * k, 48 * k, false), `${R}/${dir}/brave/product_logo.png`);
    await shot(164 * k, 48 * k, wordmark(164 * k, 48 * k, true), `${R}/${dir}/brave/product_logo_white.png`);
  }
  // Welcome page logo (WebP, 200x239).
  await p.setViewportSize({ width: 200, height: 239 });
  await p.setContent('<html><body></body></html>');
  const data = await p.evaluate(async (src) => {
    const img = new Image(); img.src = src; await img.decode();
    const c = document.createElement('canvas'); c.width = 200; c.height = 239;
    c.getContext('2d').drawImage(img, 10, 29, 180, 180);
    return c.toDataURL('image/webp', 1.0);
  }, svg);
  const out = `${core}/components/brave_welcome_ui/assets/brave_logo_3d@2x.webp`;
  fs.writeFileSync(out, Buffer.from(data.split(',')[1], 'base64'));
  console.log(out);
  await b.close();
})();
