// Renders BackupDrive menu bar template PNGs (18pt @1x/@2x) and the app iconset.
// Uso: node render-icons.js BackupDrive/branding BackupDrive/app/Resources  (paquete npm "playwright"; CHROME=/ruta si hace falta)
const { chromium } = require('playwright');
const fs = require('fs');
const [branding, out] = process.argv.slice(2);
(async () => {
  const b = await chromium.launch(process.env.CHROME ? { executablePath: process.env.CHROME } : {});
  const p = await b.newPage();
  async function render(svgFile, size, dest, black) {
    const svg = 'data:image/svg+xml;base64,' + fs.readFileSync(svgFile).toString('base64');
    await p.setViewportSize({ width: size, height: size });
    await p.setContent(`<html><body style="margin:0;background:transparent"><img src="${svg}" style="display:block;width:${size}px;height:${size}px;${black ? 'filter:brightness(0)' : ''}"></body></html>`);
    await p.waitForTimeout(60);
    await p.screenshot({ path: dest, omitBackground: true });
  }
  for (const name of ['menubar_BackupDriveTemplate', 'menubar_BackupDrive-syncTemplate', 'menubar_BackupDrive-errorTemplate']) {
    const src = `${branding}/${name}.svg`;
    await render(src, 18, `${out}/${name}.png`, true);
    await render(src, 36, `${out}/${name}@2x.png`, true);
  }
  fs.mkdirSync(`${out}/AppIcon.iconset`, { recursive: true });
  for (const s of [16, 32, 128, 256, 512]) {
    await render(`${branding}/icon_BackupDrive.svg`, s, `${out}/AppIcon.iconset/icon_${s}x${s}.png`, false);
    await render(`${branding}/icon_BackupDrive.svg`, s * 2, `${out}/AppIcon.iconset/icon_${s}x${s}@2x.png`, false);
  }
  await b.close();
})();
