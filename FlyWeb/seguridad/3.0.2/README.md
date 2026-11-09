# FlyWeb 3.0.2: parches de seguridad

SEGURIDAD-PORTES-20, 09-11-2026. Inventario, criterios y lo que queda fuera: [`../../docs/seguridad-3.0.2.md`](../../docs/seguridad-3.0.2.md).

| Pieza | Base | Punta (ls-remote) | Árbol |
|---|---|---|---|
| chromium, fork `lamosquita-net/chromium` **`seg/3.0.2`** (11 commits; copia en [`chromium/`](chromium/)) | `seg/3.0.1` c4b1caf806 | **502e3c5b85** | `9d40e011ed3` |
| brave-core **`seg/3.0.2`** (4 commits) | `seg/3.0.1` 6415661d24 | **0d6a771f23** | — |

Contenido de [`chromium/`](chromium/) (`git format-patch`; `SHA256SUMS` cubre los 11):
- `0001`: roll de V8 6500240d22 → 182f13107b (15.6.75.51), el de la 156.0.8078.98: trae 34ad010 (OOB en Turboshaft, crbug 579278668).
- `0002`–`0006`: `[M157]` de la rama 8103 sin gemelo en la 8078 (sin CVE publicado todavía).
- `0007`: e49055113b de main (null deref en el overlay de validación).
- `0008`–`0010`: arreglos de `focus-without-user-activation` de la 157/158, para encender la bandera con ellos.
- `0011`: `chrome/VERSION` .98.

Todos entran con 3 vías sin conflicto (`git merge-tree`); no se ha compilado nada.

## Para LOCAL

1. Chromium: `seg/3.0.2` del fork (o `git am chromium/*.patch` sobre `seg/3.0.1` c4b1caf806). ANGLE, ffmpeg y PDFium, los de la 3.0.1, sin cambios.
2. brave-core: `seg/3.0.2` 0d6a771f23. Si la 3.0.1 sale de `seg/3.0.1-parser`, rebasar `seg/3.0.2` encima (no tocan los mismos ficheros salvo `patches/v8/FLYWEB-SECURITY.md`, que solo crece por arriba).
3. V8: cambia el gitlink a 182f13107b; los `patches/v8` de brave-core aplican igual. Época de caché: sigue en 31.
4. Comprobar en ejecución (consola de DevTools, perfil nuevo):
   - `typeof XSLTProcessor` → `"undefined"`; un XML con `<?xml-stylesheet type="text/xsl"?>` se ve sin transformar, también con el espacio de nombres CAP (`urn:oasis:names:tc:emergency:cap:1.2`).
   - `typeof navigator.hid` → `"undefined"` (y nada de HID en `flyweb://settings/content`).
   - `document.featurePolicy.features().includes('focus-without-user-activation')` → `true`.
   - `CFBundleVersion` = `198.63.<FLYWEB_BUILD_NUMBER>`, igual que con el método anterior.
   - claude.ai: entrar, escribir, adjuntar, cambiar de conversación (foco en el cuadro de texto).
