# FlyWeb 3.1.1: parches de seguridad (serie previa, antes de la nota de Chrome 158)

SEGURIDAD-PORTES-21, 12-11-2026, por orden de COORDINACIÓN-39. Inventario y criterios:
[`../../docs/seguridad-3.1.1.md`](../../docs/seguridad-3.1.1.md). El 17-11 se añade lo que traiga la nota de la 158 y
el KEV de ese día.

**Sin push al fork de chromium** en esta sesión: la serie va solo aquí, como `git format-patch`.

| Pieza | Base (ls-remote) | Resultado |
|---|---|---|
| chromium, [`chromium/`](chromium/) (34 parches; `SHA256SUMS`) | fork `lamosquita-net/chromium` `seg/3.0.2` **502e3c5b85** (= src de la 3.1.0) | `git am` → árbol **`3d9092e4e3`** (comprobación local; no hay rama remota) |
| brave-core | `local/3.1` **fc9389773fe** | **sin cambios** (ver «V8») |

## Qué lleva

- **V8 15.6.75.51 → .58** (`0002`, `0005`, `0008`, `0010`, `0018`, `0025`): los cinco rolls de V8 de la rama 8078 tal
  cual. El último deja `v8_revision` = `0064da7c8c` = tag 15.6.75.58, comprobado con `ls-remote`. Traen 7 `[M156]`:
  - Turboshaft: 9133115;
  - Maglev: 197b819 y dfe5a31;
  - compiler: 52dff94;
  - GC: 58707c0;
  - regalloc: fceab3a;
  - intérprete: 9ba5fcd.
- **Skia ea1e651d7a → 24e65cdd9b** (`0006`, `0015`, `0016`, `0021`, más el roll de `0008`): 5 `[M156]` de Ganesh y
  Graphite, rolls de la 8078 tal cual: 24e65cd, b9d4bd3, 160aff2, 93787ea y afd5fff.
- **21 `[M156]`** de la rama 8078 .98 → .103: los de clase A de §2 del inventario.
- **4 `[M157]` sin gemelo en la 156** (`0030`–`0033`).
  - `0033` (ImageCapture, 4dab8e40e2) es **el único resuelto a mano**. En la 156, `media_stream_manager` llega a las
    funciones del hilo de IO como parámetro; se conserva y se añade detrás el `GlobalRenderFrameHostId`.
  - **Riesgo:** los tests de ese commit (`image_capture_impl_unittest.cc`, `media_stream_manager_unittest.cc`) entraron
    por 3 vías sin conflicto, pero no se han compilado.
- **`0034`:** `chrome/VERSION` .98 → .103.

**Fuera, con motivo:**
- 939ad86d5 (`SVGImage`): ya está en la base (la fusión no cambia nada).
- ea36d0325 y f253859e6 (Background Fetch): ya entraron en la 3.0.1 (0041 y 0042).
- 973b2ff1b (snap sets): ya entró en la 3.0.2 (0004).
- 7b3fcb8ba y e5876d9c5: solo Windows.
- **29980f328:** apaga por defecto `kExtensionDebuggerStrictPolicyRestrictions`. Es una vuelta atrás que **relaja**
  una restricción de política de empresa (el propio commit dice «security implications»). Nos quedamos con la estricta.

**Comprobación:**
- Los 33 cherry-picks tienen el mismo `git patch-id --stable` que su commit de upstream, salvo `0033`.
- Se hicieron con `git merge-tree` (3 vías) sobre el árbol de 502e3c5b85.
- No se ha compilado nada.

## V8 y la época de caché

- Los `patches/v8` de `local/3.1` **aplican sobre la .58**. El único fichero que comparten con los cambios de la .58
  es `src/interpreter/bytecode-generator.cc`: aplica con `git apply --check`, solo con desplazamientos (1–7 líneas),
  sin «fuzz».
  - Los cambios de la .58 en ese fichero son la tabla de saltos de `resume_mode` (dfe5a31) y los `ScopeInfo` de `eval`
    (9ba5fcd).
  - El parche de la 3.0.1 añade salidas por código muerto (`RemainderOfBlockIsDead`) antes de esas tablas.
  - No se pisan.
- **`kFlyWebCacheEpoch` se queda en 31.** 9ba5fcd y dfe5a31 cambian el bytecode, pero el roll sube `V8_PATCH_LEVEL`
  de 51 a 58 (`include/v8-version.h`), y `Version::Hash()` ya incluye `patch_`, así que las cachés de la 3.1.0 dejan
  de valer solas. La época solo hace falta cuando cambian los parches propios dentro de la misma versión de V8.
- **d8 y mjsunit: pendientes, para D8-LINUX en el Ubuntu**, antes de LOCAL (DIRECTIVAS).
  - No se pudo en la nube: el `gn` de apt es demasiado viejo para el `.gn` de la 156, y googlesource y CIPD están
    bloqueados.
  - Receta: `FlyWeb/scripts/v8-d8.sh <carpeta> <brave-core local/3.1>` con `FlyWeb/v8-revision` = `15.6.75.58`;
    mjsunit completo, **con Maglev**, más `mjsunit/maglev/generator-*`, `regress/regress-577453560.js` y
    `compiler/regress-577461556.js`.
  - Después, el perfil PGO de V8 al día: `download_profiles.py --check-v8-revision`.

## Para LOCAL (cuando COORDINACIÓN dé la orden, tras el delta del 17-11)

1. Chromium: `git am chromium/*.patch` sobre 502e3c5b85, comprobando que el árbol da `3d9092e4e3`. Después,
   `gclient sync` para V8 .58 y la Skia nueva. ANGLE, ffmpeg, PDFium y Dawn, sin cambios.
2. brave-core: `local/3.1` tal cual.
3. Pruebas, además de las de siempre:
   - **Navegación (`0030`, `0031`):** el navegador ya no acepta ciertos commits de `about:blank` con origen distinto.
     Si algo en la 156 no cuadra, el síntoma sería un renderer cerrado («bad message»). Probar:
     - un popup abierto desde un documento con CSP `sandbox` y `allow-popups-to-escape-sandbox`;
     - iframes `about:blank` y `srcdoc`;
     - una página `file://` que abra `about:blank`;
     - claude.ai entero.
   - **FSA (`0003`):** `showDirectoryPicker()` sobre `~/Library` escrito con otras mayúsculas (p. ej. `~/LIBRARY`)
     tiene que dar la misma advertencia que con la ruta bien escrita.
   - **Prueba de huella** (DIRECTIVAS, 12-11): JA4, HTTP/2, orden de cabeceras y Client Hints iguales a los de un
     Chrome 156 real (`motor.md`, principio 13).
