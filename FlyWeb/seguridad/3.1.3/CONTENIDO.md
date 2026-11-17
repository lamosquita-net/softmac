# FlyWeb 3.1.3: contenido (parte 1, delta de la rama 8078 hasta .109)

SEGURIDAD-PORTES-23, 17-11-2026, por la orden de las 21:15 UTC de COORDINACIÓN-44. Es una versión **solo de seguridad**
con una excepción: el arreglo de las fijadas compartidas (#1029; Titín, 17-11). **Nada compilado por mí.**

## Qué ha pasado hoy

- **Chrome 158 estable** (158.0.8127.36/.37, nota del 17-11 a las 11:12 PT, 204 arreglos).
- **Extended Stable 156.0.8078.108/.109** (nota del 17-11 a las 09:01 PT, 79 arreglos). Google ha portado a nuestra rama
  lo que considera de la 156, así que el grueso de la 3.1.3 es el delta **.105 → .109** de la rama 8078.
- **CVE-2026-125350** (UAF en XML/libxslt, explotado): **ya está** desde la 3.0.1 (parche 0034, «Fixed: 582442907,
  572578603»; `cve-triage.md`, pasada del 11-11). No hay que adelantar nada.
- **KEV:** `cve-watch.py --desde 2026-10-15` a las 21:45 UTC: el catálogo sigue en la 2026.11.13; 2 de Chromium, ya
  triados, **0 nuevos**.

## Base y resultado (comprobados)

| Repositorio | Base (3.1.2) | Resultado de la serie |
|---|---|---|
| chromium | commit `9439a7904c`, árbol `8abc877c10` (cierre de la 3.1.2) | 0001–0022 → árbol **`cd628ae8a2`** |
| brave-core | `local/3.1.2` **`ba428ad058`** (`ls-remote` del 17-11) | 0001–0003 → árbol **`adbf62d528`** |

`ls-remote` del 17-11 (21:20 UTC): rama 8078 hasta **156.0.8078.109**; V8 15.6.75 hasta **.66**
(`917584bd9326d5e6ae81008cddec50cdd7f1631e`); 157 hasta .81; 158 hasta 158.0.8127.65.

## chromium 0001–0022

`git log 156.0.8078.105..156.0.8078.109` (gitiles): 39 commits. Entran 18 tal cual, uno a medias (Skia sin V8), la V8
en un parche propio y `chrome/VERSION`. **Todos aplican limpios con `git am` sobre `9439a7904c`.**

**patch-id:** 16 de los 18 son iguales al original. 0002, 0003, 0008 y 0011 dan otro patch-id solo porque gitiles
alinea los hunks con otro algoritmo de diff: los blobs de antes y después de cada fichero son los mismos (comprobado con
las líneas `index`). En 0017, `element.cc` parte de otro blob porque nuestro árbol ya lo tenía cambiado, pero el cambio
es el mismo (mismo patch-id).

| Parche | Original | Qué | En Mac |
|---|---|---|---|
| 0001 | 6701a039c3 | Bluetooth: manejador del selector con WeakPtr (584996906) | sí |
| 0002 | 055812e1f6 | `~SVGImage()`: aplazar `IsolatedSVGDocumentHost::Shutdown()` (585406052) | sí |
| 0003 | b340258541 | remoting: errores y cierres de `StreamPacketSocket` (585801775) | inocuo (escritorio remoto) |
| 0004 | eb952d7235 | mDNS: acotar el análisis de la respuesta al tamaño del datagrama (586066716) | sí |
| 0005 | 0ec2fb306a | Sistema de ficheros: una base de directorios por bucket propio (584997810) | sí |
| 0006 | d301bae399 | [blink] Limpiar el streamer de scripts al revalidar (584997057) | sí |
| 0007 | ff40eac64d | ICU c670d12 → c66ba5d: fallos de memoria en DecNum y Scale (585406709) | sí |
| 0008 | 3ba6ecba77 | File System Access: lista blanca de escrituras en `*/.git` (583960618 y más) | sí |
| 0009 | 7fac162ee7 | Skia 4c5f57e4fa → bbb2664be6: recorte de subconjuntos con AA (584997751) | sí |
| 0010 | 39900c1a01 | Skia bbb2664be6 → 27c31ca415: hash de filtros de imagen (586067041). **Solo la parte de Skia** | sí |
| 0011 | 003dad2e3e | PointerEvents coalescidos y predichos a través de shadow DOM (586067048) | sí |
| 0012 | 86d3403b4e | Safe Browsing: proteger el extractor visual en `CapturePaintPreview()` (585802327) | sí |
| 0013 | 7678578801 | [FedCM] Salir pronto si cerrar el pop-up destruye la vista (584579228) | sí |
| 0014 | c630b66356 | [FedCM] Ídem al enfocar el pop-up (584579228) | sí |
| 0015 | 47d70531ed | gpu: flujo kVaapi en `CompoundImageBacking::ProduceVideo` (579236521) | inocuo (VA-API es Linux) |
| 0016 | 730482a940 | [FedCM] Salir pronto en `UpdateTaskId()` (584119715) | sí |
| 0017 | efc0bca6e3 | Prohibir `CSSAnimations::Cancel` durante el estilo animado (586066564) | sí |
| 0018 | 6b1e43fabf | Bloquear navegaciones reentrantes al abortar el documento en `CommitNavigation` (585800841) | sí |
| 0019 | 3455b06a0a | UAF en `MediaPermissionDispatcher` (584578630) | sí |
| 0020 | f8ec2e9b40 | [webauthn] Callbacks de error de `FidoHidDevice` en otra tarea (585800918) | sí |
| 0021 | — | **V8 15.6.75.58 → 15.6.75.66** (abajo) | sí |
| 0022 | — | `chrome/VERSION` 156.0.8078.105 → **.109** | — |

**V8 (0021).** Upstream .109 llega a la 15.6.75.63; la .64–.66 salieron hoy en la misma rama (M156) y entran ya:
- 95b829dd78 [ic] `Object.create(..)` entre contextos y comprobaciones de acceso al prototipo (582276825);
- fc84cf914b [parser] ámbito de `extends` al reanalizar inicializadores de clase (585801119);
- 7fd7b396c0 [objects] limpiar `ObjectCreateMap` en la migración de mapa de `JSGlobalProxy` (582276825);
- 3d65217807 [compiler] ciclos de movimientos FP de distinto ancho (585406612);
- b1b4519404 [runtime] TOCTOU en `FastKeyAccumulator::may_have_elements_` con GSAB (585407017);
- cc9a2672c3 [regalloc] límites en `LiveRange::SplitAt` (585801890).

La .59 (576333024) **no vuelve**: se revirtió en la .60 y no hay commit nuevo para ese bug. **La V8 cambia: hay encargo
de d8/mjsunit a D8-LINUX** (`buzon/D8-LINUX`), con los `patches/v8` de brave-core. Sin mjsunit en verde, 0021 no entra.

**Fuera:**
- **ANGLE** (e098dfff55: 2080bf27e5 → 44d1e22b80). Los dos commits de upstream después de nuestra base `f10470c77e`
  (2080bf27e5 y 44d1e22b80) son solo de Vulkan, que en Mac no se usa. Nuestro ANGLE es el fork `bc2ebdd211`.
- **Dawn** (d2c1eac2db6c: 68b5c1f3f2 → d2c1eac2db). dawn.googlesource.com sigue bloqueado desde aquí: **que LOCAL mire**
  si alguno de esos commits es de seguridad y aplica a nuestro fork, además de 68b5c1f3f y 8bc8ddaf2 (abajo).
- `chrome/VERSION` intermedios (.106–.108), pruebas (🌺 ×5), perfiles AFDO de ChromeOS (×3), XTB (traducciones, 82
  ficheros, sin seguridad), `testing/buildbot`, `internal` e `ios_internal`.

**Cruce con brave-core** (`local/3.1.2` más 0001–0003):
- `patches/third_party-blink-renderer-platform-runtime_enabled_features.json5.patch`: 0002 y 0011 añaden una entrada
  cada uno; el parche de Brave sigue aplicando (`git apply --check`, con desplazamientos de 16 líneas).
- `chromium_src/.../events/pointer_event.h` redefine `screen_x_` y `screen_y_` (farbling). 0011 solo añade accesores y
  una declaración en ese fichero, sin tocar esos campos: sin conflicto.
- Nada más de 0001–0022 tiene `patches/` ni `chromium_src/`.
- **Huella:** 0004 (mDNS) y 0018 (navegación) no tocan TLS, HTTP/2, cabeceras ni Client Hints: basta la prueba de
  huella de la 3.1.1.

## brave-core 0001–0003

| Parche | Qué |
|---|---|
| 0001 | `flyweb_version` 3.1.2 → **3.1.3** |
| 0002 | `package.json`: etiqueta del proyecto chrome 156.0.8078.105 → **.109** |
| 0003 | **Fijadas compartidas** (#1029, MOTOR-46): `FlyWeb/parches/3.2-fijadas-miniatura/0001` tal cual (suma `0bdb7a3c…`, mismo patch-id `e11cb4794b`). APTO en #1029. Excepción a «solo de seguridad» (Titín, 17-11) |

`flyweb_engine_full_version` se queda en 156.0.8078.82: la última estable de la 156 para Mac en versionhistory.

## Lo que hace LOCAL-19 (en este orden)

1. **Fijar lo que se compila de verdad** (antes de 0001, como parche suyo): gitlinks y `DEPS` de ANGLE `bc2ebdd211`,
   FFmpeg `a15fcf87d2` y Dawn (`31316d1c` + `cherry-pick -x` de 68b5c1f3f y 8bc8ddaf2, y lo que salga del roll de Dawn de
   la .109). **No lo genero yo:** esos commits no están en ningún remoto que yo pueda ver (`ls-remote` de
   `lamosquita-net/angle`, `/ffmpeg` y `/dawn` pide credenciales), y un hash solo va tras `ls-remote`. Para que
   `gclient sync` reproduzca lo publicado, tienen que estar en un remoto que pueda bajar; si hay que crear esos forks,
   decide Titín.
2. `git am` de chromium 0001–0022 sobre `9439a7904c` → árbol `cd628ae8a2`; `git am` de brave-core 0001–0003 sobre
   `ba428ad058` → árbol `adbf62d528`. Sumas en `SHA256SUMS` y `brave-core/SHA256SUMS`.
3. **0021 (V8) solo con el mjsunit de D8-LINUX en verde.** Si no llega o falla, se compila sin 0021 y se avisa.
4. Fijadas: reproducir en la 3.1.2 y comprobar con la 3.1.3 (pasos 4 y 5 del README de `3.2-fijadas-miniatura`);
   `SharedPinnedTabServiceBrowserTest.*` en verde; `BraveTabHoverTest.ThumbnailHelperIsAlwaysAttached` falla, como era de
   esperar: se anota como conocido, sin desactivarlo.
5. `FLYWEB_BUILD_NUMBER` = **46** (CFBundleVersion 198.63.46); `kFlyWebCacheEpoch` no cambia (no hay cambio de motor).

## Parte 2 (pendiente): lo de la 158 que Google no ha portado a la 156

La nota de la 158 trae 6 críticos que **no** están en la Extended Stable .109. Hay que ver si el código vulnerable está en
la 156. Commits en `main` (búsqueda en el espejo `chromium/chromium`):

| CVE | Bug | Qué | Commit en main |
|---|---|---|---|
| CVE-2026-131031 | 571153713 | OOB write en GPU | 0960c42b6c (13-10) |
| CVE-2026-131060 | 573128234 | Desbordamiento en Media (`mov_read_trun`, FFmpeg) | 60bb54f340 (solo la prueba; el arreglo está en FFmpeg) |
| CVE-2026-131008 | 574686297 | UAF en el GC (`CalculationValue`) | 218a524b0e (26-10, reaplicado) |
| CVE-2026-131054 | 576812570 | OOB write en ANGLE | b37ab74fc3 (roll de ANGLE 192af4dd12 → 48e22c0ca5) |
| CVE-2026-130975 | 577366760 | UAF en WebAudio | f4de8340fb (27-10) |
| CVE-2026-130963 | 562000561 | UAF en WebView | — (Android; no aplica) |

Después, los Altos de la 158 que tampoco están en la .109.
