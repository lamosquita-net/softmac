// Genera en brave-core todos los recursos de marca desde los maestros elegidos del HUMANO
// (FlyWeb/branding/imagenes.md, entregas 1 y 2). Cada PNG se dibuja a su tamaño exacto desde el SVG.
// Uso: node generar-entrega.js <brave-core>   (paquete npm "playwright"; CHROME=/ruta si hace falta)
// Después: icns (icns.py) y .icon (svg2icon.py), ver README.md.
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const core = process.argv[2];
const B = path.resolve(__dirname, '..');
const svg = (f) => 'data:image/svg+xml;base64,' + fs.readFileSync(path.join(B, f)).toString('base64');

// Maestros elegidos
const M1 = svg('M1-01.svg');        // icono de la app (disco naranja)
const O1 = svg('O1-01.svg');        // variante de canal (morado): development
const M2 = svg('M2.svg');           // símbolo de color para pestañas (16×16)
const M3 = svg('M3_1.svg');         // monocromo (16×16)
const M4C = svg('M4-fondo-claro.svg'), M4O = svg('M4-fondo-oscuro.svg');
const M4Cp = svg('M4-fondo-claro-pequeño.svg');
const O2 = svg('O2-02.svg');        // documento

(async () => {
  const b = await chromium.launch(process.env.CHROME ? { executablePath: process.env.CHROME } : {});
  const p = await b.newPage();
  // Dibuja la imagen centrada y entera (sin deformar) en un lienzo w×h transparente.
  async function draw(src, w, h, out) {
    await p.setViewportSize({ width: w, height: h });
    await p.setContent(`<html><body style="margin:0;background:transparent;width:${w}px;height:${h}px;overflow:hidden">` +
      `<img src="${src}" style="display:block;width:${w}px;height:${h}px;object-fit:contain"></body></html>`);
    await p.evaluate(() => document.images[0].decode());
    fs.mkdirSync(path.dirname(out), { recursive: true });
    await p.screenshot({ path: out, omitBackground: true });
    console.log(path.relative(core, out), `${w}x${h}`);
  }
  const T = `${core}/app/theme`;
  const channels = ['', '_beta', '_dev', '_development', '_nightly'];

  // Pestañas y ventanas (product_logo_16/32): M2, en todos los canales.
  for (const c of channels)
    for (const [dir, k] of [['default_100_percent', 1], ['default_200_percent', 2]])
      for (const s of [16, 32]) {
        const f = `${T}/${dir}/brave/product_logo_${s}${c}.png`;
        if (fs.existsSync(f)) await draw(M2, s * k, s * k, f);
      }
  // Logotipos con nombre (M4), mismos lienzos que antes: no se mueve ningún diseño.
  const marks = [
    ['default_100_percent/brave/product_logo_name_22.png', 77, 22, M4Cp],
    ['default_200_percent/brave/product_logo_name_22.png', 154, 44, M4Cp],
    ['default_100_percent/brave/product_logo_name_48.png', 164, 48, M4C],
    ['default_200_percent/brave/product_logo_name_48.png', 328, 96, M4C],
    ['default_100_percent/brave/product_logo_white.png', 214, 64, M4O],
    ['default_200_percent/brave/product_logo_white.png', 428, 128, M4O],
  ];
  for (const [rel, w, h, src] of marks) await draw(src, w, h, `${T}/${rel}`);
  // brave://version (180 pt de ancho): claro y oscuro.
  const R = `${core}/components/resources`;
  for (const [dir, w, h] of [['default_100_percent', 180, 53], ['default_200_percent', 360, 106]]) {
    await draw(M4C, w, h, `${R}/${dir}/brave/product_logo.png`);
    await draw(M4O, w, h, `${R}/${dir}/brave/product_logo_white.png`);
  }
  // Iconos sueltos de la app (Linux, instaladores, about): M1; el canal development, O1.
  for (const s of [22, 24, 48, 64, 128, 256]) {
    const f = `${T}/brave/product_logo_${s}.png`;
    if (fs.existsSync(f)) await draw(M1, s, s, f);
  }
  for (const c of ['_beta', '_dev', '_nightly']) await draw(M1, 128, 128, `${T}/brave/product_logo_128${c}.png`);
  await draw(O1, 128, 128, `${T}/brave/product_logo_128_development.png`);
  await draw(M3, 22, 22, `${T}/brave/product_logo_22_mono.png`);
  // Iconos de la extensión interna de Brave: M2 a 16 y 32 (dibujado a píxel), M1 a partir de 48.
  const X = `${core}/components/brave_extension/extension/brave_extension/assets/img`;
  for (const s of [16, 32]) await draw(M2, s, s, `${X}/icon-${s}.png`);
  for (const s of [48, 64, 128, 256]) await draw(M1, s, s, `${X}/icon-${s}.png`);
  // PNG para los .icns (a icns.py): M1, O1 y O2.
  const tmp = process.env.ICNS_TMP || '/tmp/flyweb-icns';
  for (const [name, src] of [['M1', M1], ['O1', O1], ['O2', O2]])
    for (const s of [16, 32, 64, 128, 256, 512, 1024]) await draw(src, s, s, `${tmp}/${name}-${s}.png`);
  await b.close();
})();
