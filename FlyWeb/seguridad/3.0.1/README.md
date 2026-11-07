# FlyWeb 3.0.1: parches de seguridad (FS.42)

SEGURIDAD-PORTES-19, 07-11-2026. La tanda la aprobó COORDINACIÓN-34 (T1 + T2). Inventario y criterios en
[`../../docs/seguridad-3.0.1.md`](../../docs/seguridad-3.0.1.md).

Los commits de Chromium van aquí como `git format-patch`, porque esta sesión no tiene acceso al fork
`lamosquita-net/chromium`. Si Titín lo autoriza, se suben como rama `seg/3.0.1` del fork y estos ficheros pasan a ser copia.

| Pieza | Base | Contenido | Árbol resultante (`git am`, comprobado) |
|---|---|---|---|
| [`chromium/`](chromium/) (61) | `flynk-b1d` 33a1745949 | ver la lista de abajo | `2723e1b371c` |
| [`angle/`](angle/) (12) | ANGLE `f10470c77e` (`angle_revision` de la .96) | `0001`–`0008` = nuestros 8 parches de B1d rebasados, sin conflictos; `0009`–`0012` = Translator: CVE-2026-121229 (crítico), -121197, -121140, -121037 | `d094abc` |
| brave-core `seg/3.0.1` | `nube/b2-porte-t11` bf4262a094 | V8 b56fe9b (CVE-2026-121228) en `patches/v8`, `kFlyWebCacheEpoch` 31, `kCanvasDrawElement` apagada | **6415661d24** (ls-remote) |

Contenido de [`chromium/`](chromium/):
- `0001`–`0034`: los 34 `[M156]` de la rama 8078 (.91–.96), con `cherry-pick -x`.
- `0035`: DEPS y gitlinks: V8 6500240d22 y Skia ea1e651d7a; `angle_revision` f10470c77e.
- `0036`–`0038`: críticos de main.
- `0039`–`0060`: altos de main.
- `0061`: `chrome/VERSION` .96.

En el asunto de cada parche va su CVE, o «sin CVE publicado». `SHA256SUMS` cubre los 73 parches.

## Para LOCAL

1. `git am chromium/*.patch` sobre `flynk-b1d` 33a1745949. Avisos de espacios en blanco: vienen de upstream (libxslt), no fallan.
2. ANGLE, como en B1d: `git am angle/*.patch` sobre f10470c77e y poner el gitlink `third_party/angle` en ese commit. Dawn no cambia.
3. brave-core en `seg/3.0.1` (6415661d24). Para la versión de la 3.0.1 (`flyweb_version` 3.0.1; FLYWEB_BUILD_NUMBER 42 solo al final), COORDINACIÓN decide la rama.
4. Antes de compilar, D8-LINUX pasa mjsunit de la V8 15.6.75.50 con `patches/v8`, incluido `regress-568794851.js`.
5. Comprobaciones en ejecución:
   - `drawElementImage` no existe en `HTMLCanvasElement.prototype`, tampoco con `--enable-experimental-web-platform-features`;
   - `navigator.userAgent` y `/json/version` dan 156.0.8078.96.

## Hecho a mano (revisar al compilar)

| Parche | CVE | Qué se hizo |
|---|---|---|
| `0038` 8fde5a8071 | CVE-2026-121126 | Conflicto en `navigation_request.cc`: upstream adelanta la comprobación `!this_ptr`. Se origina en Android; se porta por paridad. El `.patch` y el override de Brave siguen aplicando |
| `0055` 776099dc87 | CVE-2026-121140 | Conflicto de includes en el unittest: se quedan los dos lados |
| `0057` 7d7ffedf61 | requisito de CVE-2026-121188 | Cherry-pick limpio (7 líneas): `Client` pasa a GarbageCollectedMixin |
| `0060` 31e05381bd | CVE-2026-121214 | La 156 no tiene el argumento `is_manually_triggered`; se mantiene la rama del lector de pantalla. `Show()` pasa a `bool Show(GenerationUIState)`, con todas las comprobaciones de vida de upstream |
| `0056` 4c4bf6a5eb | CVE-2026-121034 | En la 156, `AddMenuItemAt` añade un `MenuItemView*` crudo en `index`; el `AutoReset` envuelve esa llamada |

## Sin portar en esta tanda

- **CVE-2026-121082** (V8 parser, 3 commits): 1aae39c necesita refactorizaciones de main en `parser-base.h`. Queda para análisis aparte (3.0.2).
- **HiC**: CVE-2026-121038, -121052 y -121123. La feature está apagada (ver arriba).
- **T3** (sin localizar): PDFium ×3, ffmpeg ×2, CrabbyAvif, libxml y CVE-2026-121112. Si en ~1 día no aparecen, pasan a la 3.0.2.
