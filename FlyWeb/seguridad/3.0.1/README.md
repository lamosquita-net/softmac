# FlyWeb 3.0.1: parches de seguridad (FS.42)


**Fork (09-11, aprobado por Titín):** la serie de Chromium está también como rama **`seg/3.0.1`** de `lamosquita-net/chromium`, con punta **c4b1caf806e2** (ls-remote) sobre `flynk-b1d` 33a1745949 y árbol `2723e1b371c` (comprobado). `flynk-b1d` no se ha tocado. ANGLE, ffmpeg y PDFium no tienen fork accesible: siguen como `.patch` en esta carpeta.
SEGURIDAD-PORTES-19, 07-11-2026. La tanda la aprobó COORDINACIÓN-34 (T1 + T2). Inventario y criterios en
[`../../docs/seguridad-3.0.1.md`](../../docs/seguridad-3.0.1.md).

Los commits de Chromium van aquí como `git format-patch`, porque esta sesión no tiene acceso al fork
`lamosquita-net/chromium`. Si Titín lo autoriza, se suben como rama `seg/3.0.1` del fork y estos ficheros pasan a ser copia.

| Pieza | Base | Contenido | Árbol resultante (`git am`, comprobado) |
|---|---|---|---|
| [`chromium/`](chromium/) (61) | `flynk-b1d` 33a1745949 | ver la lista de abajo | `2723e1b371c` |
| [`angle/`](angle/) (12) | ANGLE `f10470c77e` (`angle_revision` de la .96) | `0001`–`0008` = nuestros 8 parches de B1d rebasados, sin conflictos; `0009`–`0012` = Translator: CVE-2026-121229 (crítico), -121197, -121140, -121037 | `d094abc` |
| [`ffmpeg/`](ffmpeg/) (3) | ffmpeg `9db86ce5b5` (`ffmpeg_revision`, igual en .90 y .96) | T3, del uprev de la M157: f4bee18 (mov tts_data, crbug 568986882, sin CVE publicado), 5eed87f (h264 next_output_pic, CVE-2026-121180; con las 2 líneas de ER de FFmpeg que le sirven de contexto) y fb424c4 (mov frag_index, CVE-2026-121047) | `fd96f28` |
| [`pdfium/`](pdfium/) (3) | pdfium `c97f02a3519c` (`pdfium_revision` de la .90) | T3, de pdfium main con `cherry-pick -x`, los tres limpios (LOCAL-19, 08-11): cce5c5ed80 (**CVE-2026-121166**, type confusion: `CJS_Global::EnumProperties`), 4150fb564e (**CVE-2026-121113**, buffer overflow: reparación de JPEG mal formados sin `const_cast`) y 0a21f66dd0 (**CVE-2026-121179**, UAF: reentrada en el foco de campos de formulario). Revisados por SEGURIDAD-PORTES-19 (08-11): correctos; el `ObservedPtr<CFFL_FormField>` de 0a21f66dd0 compila porque `CPWL_Wnd::ProviderIface` ya es `Observable`; en el asunto de cada parche va su CVE (el árbol no cambia) | `98a993d8181` |
| brave-core `seg/3.0.1` | `nube/b2-porte-t11` bf4262a094 | V8 b56fe9b (CVE-2026-121228) en `patches/v8`, `kFlyWebCacheEpoch` 31, `kCanvasDrawElement` apagada | **6415661d24** (ls-remote) |

Contenido de [`chromium/`](chromium/):
- `0001`–`0034`: los 34 `[M156]` de la rama 8078 (.91–.96), con `cherry-pick -x`.
- `0035`: DEPS y gitlinks: V8 6500240d22 y Skia ea1e651d7a; `angle_revision` f10470c77e.
- `0036`–`0038`: críticos de main.
- `0039`–`0060`: altos de main.
- `0061`: `chrome/VERSION` .96.

En el asunto de cada parche va su CVE, o «sin CVE publicado». `SHA256SUMS` cubre los 76 parches.

## Para LOCAL

1. `git am chromium/*.patch` sobre `flynk-b1d` 33a1745949. Avisos de espacios en blanco: vienen de upstream (libxslt), no fallan.
2. ffmpeg, igual que ANGLE: `git am ffmpeg/*.patch` sobre 9db86ce5b5 y poner el gitlink `third_party/ffmpeg` en ese commit (ffmpeg no tiene fork público).
3. pdfium, igual: `git am pdfium/*.patch` sobre c97f02a3519c y poner el gitlink `third_party/pdfium` en ese commit.
4. ANGLE, como en B1d: `git am angle/*.patch` sobre f10470c77e y poner el gitlink `third_party/angle` en ese commit. Dawn no cambia.
5. brave-core en `seg/3.0.1` (6415661d24). Para la versión de la 3.0.1 (`flyweb_version` 3.0.1; FLYWEB_BUILD_NUMBER 42 solo al final), COORDINACIÓN decide la rama.
6. Antes de compilar, D8-LINUX pasa mjsunit de la V8 15.6.75.50 con `patches/v8`, incluido `regress-568794851.js`.
7. Comprobaciones en ejecución:
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
- **T3**, resultado (07-11):
  - ffmpeg ×2: portados (arriba).
  - CVE-2026-121080 (CrabbyAvif): **ya en la 156**. Nuestra `crabbyavif_revision` d250697 es el mismo arreglo, con `poc_b_568818122.avif`.
  - CVE-2026-121124 (XML): **no es código**. Es el `CPEPrefix` del README de libxml (5d610f72d2); nuestra libxml es la misma revisión, 81c05baf.
  - **PDFium ×3: portados** (arriba, `pdfium/`). LOCAL-19 lo comprobó en la 7,1 (08-11): la `pdfium_revision` c97f02a3519c no tenía ninguno de los tres (log de gitiles, 2000 commits, hasta 10-2024); cherry-pick limpio desde main sobre esa revisión.
  - CVE-2026-121112 (Permissions, crbug 40063728): ningún commit de main lo cita; queda sin localizar → 3.0.2.
