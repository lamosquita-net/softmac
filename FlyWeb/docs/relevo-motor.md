# Relevo de MOTOR: de MOTOR-17 a MOTOR-18 (22-10-2026, ~17:45)

MOTOR-17 (`session_019jWvesenN4JUZRGdUQYNNz`, Opus 5.5, `xhigh`) hizo `blink_unittests` de la base 128, cerró las 2 WPT
(no eran del motor) y, por orden de COORDINACIÓN-12, ANGLE Metal en ≥ 10.15 y la integración con IDENTIDAD. **Desde
MOTOR-18, esfuerzo alto** (HUMANO, 22-10). Ramas fijas de brave-core (todas con `git ls-remote`):

| Rama | sha | Qué añade |
|---|---|---|
| `-p10` | 4799b94fc8 | `-p9` + 52 parches de tests: hunks de test de los 43 commits ya portados (fusión a tres bandas, `m3t.py`), los 5 tests de los `.gni`, `heap_test_platform.h` (V8 13.1) y 4 tests que rompe el `chromium_src` de Brave |
| `-p11` | cd9c85656b | ANGLE Metal de serie (bd08100342) salvo en macOS < 10.15 (OpenGL, lo probado en la 6,1); `flyweb_metal_bin_path` en vez de la ruta absoluta del Xcode 15.4 en `angle/.../metal/BUILD.gn` |
| `-p12` | ae5626ab1a | merge sin conflictos de `-p11` e identidad `-i5` dff94888fe (no comparten ningún fichero). **La que compila LOCAL** |

`nube/base-128-motor` sigue en `-p9` abb90752c3: **no se mueve hasta que LOCAL confirme `-p12`** (COORDINACIÓN).

**Lo que queda (tuyo):**

1. **Resultado de LOCAL-8** (rama de softmac `local/b128-blinktests-errores`, por mensaje o buzón): primero `blink_unittests` de `-p10`
   (estaba compilando), luego la Static de `-p12` (`-k 0`, sin PCH, `--gn flyweb_metal_bin_path:…/`), `blink_unittests` y
   la suite, y las pruebas de `identidad-128.md`. Si hay errores de tests: rama `-p13` desde `-p12`. Los tests nuevos
   (`css_color_function_parser_test`, `style_color_test`, `public_key_credential_unittest`…) se revisaron contra las
   cabeceras, sin compilar; los fallos de ejecución de un test cuyo código se adaptó a mano (observador de `@page`, colores
   relativos) se comparan con el comportamiento de la 131 antes de tocar el test.
2. **Las 2 WPT** (`hsla-clamp-negative-saturation`, `position-visibility-anchors-visible-change-anchor`): **no son del motor**.
   Con ANGLE OpenGL el raster por GPU redondea 1–2 niveles; con Metal, sin raster por GPU o sin GPU pasan (medida de
   LOCAL-8, ccb5d772e1). En 10.14 siguen difiriendo por eso (OpenGL a propósito). Trampa en `TRAMPAS.md`.
3. `launchQueue`: apagado (decidido por COORDINACIÓN). El códec fijo (H.264) no se toca (Titín; F5.6 para la 2.0.x).

**Trampas nuevas:**

- **git 2.43 de la nube no tiene `GIT_NO_LAZY_FETCH`**: un `git show <commit>` sin rutas sobre la historia sin blobs baja los
  blobs de fuera de lo que te interesa uno a uno (minutos por commit). Limitar a las rutas (`-- third_party/blink/renderer`)
  y bajar antes en bloque (`git ls-tree <rev> -- <rutas>` → `fetch --stdin`). Para saber si falta un blob sin bajarlo:
  `git rev-list --objects --no-walk --missing=print --stdin`. `git grep` sobre etiquetas tampoco: ampliar el sparse de `cr128`.
- **Un test que entra limpio puede usar API de un commit no portado**: `CSSParserTokenStream stream(String)` es de
  5144028324 (no portado); en la 128 va `CSSTokenizer` + `CSSParserTokenStream(tokenizer)`.
- **`pkill -f <patrón>` mata tu propio shell** si el patrón está en la línea de órdenes: usar `ps … | awk` + `kill`.
- **No anuncies un número de PR antes de crearlo** (MOTOR-17 dio dos mal a COORDINACIÓN).

Entorno (en `/tmp` y `/home/user`, se pierde): `cr128` con el sparse ampliado a `ui/gl`, `gpu/config`; historia
`/home/user/chromium/hist` desde 2024-05 con 128, 129, 130 y 131; `w-all` = 128 + parches de `-p9` + los tests de `-p10`.
Herramientas nuevas en `FlyWeb/tools/port/` (README, «Tests de los portes»): `mark.py`, `m3t.py`, `res.py`,
`gen128lista.sh`; `wpt-ref.py --detalle` en `FlyWeb/tools/`. ANGLE, por el espejo `raw.githubusercontent.com/google/angle`
(googlesource está bloqueado).

---

**Relevos anteriores** (MOTOR-2 a MOTOR-16): [`relevo-motor-historial.md`](relevo-motor-historial.md).
