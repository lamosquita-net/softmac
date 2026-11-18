# FlyWeb 3.1.4: inventario (Altos y Críticos de Chrome 158 que no están en la 3.1.3)

SEGURIDAD-PORTES-24, 18-11-2026, por encargo de COORDINACIÓN-46. **Solo inventario: no hay nada portado todavía.**
Base de la 3.1.4: la 3.1.3 compilada, chromium `local/313` **`7ccbc27cf7`** (árbol `be76a94fbf`, `ls-remote` del 18-11),
ANGLE `bc2ebdd211` (= upstream `f10470c77e` + nuestro commit), V8 15.6.75.66 (`917584bd93`), Skia `27c31ca415`.

## Método

- Nota de la 158 estable (17-11, 11:12 PT, feed con `redirect=false`): 204 arreglos; **6 críticos y 62 altos**
  (82 medios y 54 bajos quedan fuera del encargo).
- Nota de la Extended Stable 156.0.8078.108/.109 (17-11, 09:01 PT): 79 arreglos. Cruce por número de bug.
- Para cada bug, su commit en la historia de `158.0.8127.65` (22 758 commits desde `156.0.8078.0`, espejo de GitHub,
  `--filter=tree:0`) y en la rama 8078 hasta la .109. V8, ANGLE, Dawn y Skia, en sus espejos de GitHub.
- Aplicabilidad: `git apply --cached --check` del commit original sobre el árbol de `local/313` (y de `f10470c77e` para
  ANGLE y de la .66 para V8), con y sin las pruebas, más la lectura del código y de las funciones que lo activan.
- **KEV:** `cve-watch.py --desde 2026-10-15`, catálogo **2026.11.17**: 2 de Chromium, ya triados, **0 nuevos**. La nota
  de la 158 no tiene ningún «exists in the wild». **No hay nada de KEV que adelantar.**

## Resumen

| | Nº |
|---|---|
| Críticos de la 158 | 6: **cerrados en la 3.1.3 parte 2** (0023 GPU y ffmpeg 0001 entran; GC ya estaba; ANGLE solo PowerVR; WebAudio no existe en la 156; WebView es Android) |
| Altos de la 158 | 62 |
| … ya en la .109 (nota de la Extended Stable) | 15 |
| … ya en la rama 8078 hasta la .109 aunque la nota no lo diga | 1 (573981230 Plugins, `4d744bf001` [M156]) |
| **Altos pendientes** | **46** |
| → **A. aplican y entran limpios** (el código; las pruebas, aparte) | **14 CVE en 12 arreglos** |
| → **B. aplican, a mano** (choca el código) | **9 CVE en 8 arreglos** (B8 con la duda de D) |
| → **C. no aplican a FlyWeb en Mac** | **21** |
| → **D. por confirmar al portar** | **2** (más B8) |

Además, la **rama 8078 sigue después de la .109** (tags .110 `04545e38be` y, en la rama, .111): 12 arreglos [M156] de
Chromium, 2 de ANGLE y un roll de Dawn que Google ya ha portado a nuestra rama y aún no han salido en ninguna nota (§E).

## A. Aplican y entran limpios

Orden de portado dentro del grupo: primero V8 (necesita la d8 de D8-LINUX, que tarda más), luego ANGLE (escritura fuera
de límites desde un shader de WebGL), luego el renderer.

| # | CVE (bug) | Qué | Arreglo | Dónde | Nota |
|---|---|---|---|---|---|
| A1 | CVE-2026-131042 (573263262) | UAF en V8 (regexp: errores de `Trace::Flush` que se ignoraban) | V8 `659b8bf` | **V8** (no está en la 15.6) | Limpio sobre la .66. Regresión `mjsunit/regress/regress-573263262.js`. **d8/mjsunit en D8-LINUX** y la época de caché sube (regla de `SEGURIDAD.md`) |
| A2 | CVE-2026-130910 (576579698) | ANGLE: plegado de `switch` constante frente a `length()` | ANGLE `48e22c0` | ANGLE, traductor (todos los backends) | Limpio sobre `f10470c77e` |
| A3 | CVE-2026-130954 + CVE-2026-130996 (568896063, 568896486) | ANGLE: renombrar las variables que se sacan de un `switch` (OOB write) | ANGLE `a30dae4` | ANGLE, traductor (`PruneNoOps`, `msl/RewriteCaseDeclarations`) | El código entra limpio; solo choca `angle_end2end_tests_expectations.txt` |
| A4 | CVE-2026-131068 (574789298) | UAF en DOM: `AtomicString` colgantes en `WillModifyAttribute` | `7076eb7bd8` [M158] | `element.cc` | Limpio con pruebas |
| A5 | CVE-2026-130984 (572574561) | Canvas: sustitución reentrante del contexto en `getContext` | `15e314b14a` | canvas, offscreen canvas, WebGL | Limpio sin pruebas |
| A6 | CVE-2026-131082 + CVE-2026-130915 (575201060, 575201475) | UAF en CSS: `Persistent` únicos de `css/` por hilo | `dd9608809b` | 15 ficheros de `core/css` | Limpio sin pruebas |
| A7 | CVE-2026-130979 (566377256) | UAF en formularios: `WebPagePopupImpl::opener_web_view_` colgante | `bf220f8ce0` | PagePopup (selector de fecha, color…) | Limpio sin pruebas |
| A8 | CVE-2026-131090 (570703733) | UAF en geometría: IntersectionObserver con marco estrangulado | `bc7f159f95` | `intersection_observer/`, `local_frame_view.cc` | Limpio sin pruebas; añade un interruptor en `runtime_enabled_features.json5` (cruzar con el `.patch` de Brave) |
| A9 | CVE-2026-130980 (576203570) | UAF en Layout: estado de ciclo de vida obsoleto al calcular intersecciones | `2fc814f077` [M158] | `view_transition_supplement.cc`, `frame_view.cc` | Limpio sin pruebas |
| A10 | CVE-2026-130909 (560339053) | UAF en extensiones: no ejecutar *accessors* al buscar propiedades globales | `0339825273` | `extensions/renderer` | Limpio con pruebas |
| A11 | CVE-2026-130940 (568891853) | GPU: `glGenTextures` que devuelve 0 y estado de *reset* | `f182e1b65f` + `17d399e9af` [M158] | `ui/gl/gl_gl_api_implementation.*` | Limpios en ese orden. `ui/gl` es el camino de ANGLE en Mac |
| A12 | CVE-2026-130999 (583617538) | UAF en Views: proteger la actualización de botones de los diálogos | `b38c99803d` [M158] | `dialog_client_view.cc` | Limpio |

## B. Aplican, a mano

| # | CVE (bug) | Qué | Arreglo | Por qué a mano |
|---|---|---|---|---|
| B1 | CVE-2026-131084 (569659189) | UAF en XML: errores de `XMLDocumentParserRs` | `e8174b45ce` | **Sí se alcanza en la 156:** `XMLRustForNonXslt` es `stable` (DOMParser y `responseXML` usan el parser de Rust), aunque `XMLParsingRust` esté apagado. Chocan `xml_document_parser_rs.{cc,h}` y el json5. Prioridad alta dentro de B |
| B2 | CVE-2026-131065 (565839464) | UAF en Autofill: punteros a `RenderFrame` durante un *layout* síncrono | `01c2ce852f` | Choca `autofill_agent.cc` |
| B3 | CVE-2026-131059 (573263397) | UAF en Autofill: `SynchronousFormCache` | `770ffddb7f` | Chocan `autofill_agent.cc` y `synchronous_form_cache.*` (los ficheros existen) |
| B4 | CVE-2026-131021 (572237022) | UAF en accesibilidad: restaurar padres de hijos `aria-owns` al quitar | `98e5b3bb0c` | Choca `ax_object_cache_impl.cc`. Solo con un lector de pantalla o el árbol de accesibilidad activo |
| B5 | CVE-2026-130961 (572308124) | Media: validar el origen de los datos antes de tocar `UrlData` o redirigir | `fb2af07952` | Depende de la serie previa de `MultiBuffer` (`61ef27611d`, `79d7e8374c`, `ccb98073b6`, `226a56e637`, `718a8fc158`); hay que ver cuáles hacen falta |
| B6 | CVE-2026-130946 + CVE-2026-131045 (572682755, 572882344) | Event Timing: atribución del marco y ventana de origen en `CanExposeNode` (fuga entre orígenes) | `9e54c5b962` | Chocan `largest_contentful_paint.cc` y `performance.cc` |
| B7 | CVE-2026-130970 (568937157) | GPU: `SubmitIfNecessary` antes de limpiar en RasterDecoder y CopySIHelper | `d0e07566a9` [M158] | Choca `copy_shared_image_helper.cc` |
| B8 | CVE-2026-130968 (577401536) | UAF en Views: actualizaciones de menú frente a *callbacks* de accesibilidad | `3eedf7cece` [M158] | Choca `menu_item_view.cc`. Ver en D si se usa en Mac |

## C. No aplican a FlyWeb en Mac

| CVE (bug) | Qué | Motivo |
|---|---|---|
| CVE-2026-130943 (512778726) | Chromecast, `CastBindings` | `chromecast/` no se compila en Mac |
| CVE-2026-130945 (569197056) | VR | `graphics_delegate_android.cc` |
| CVE-2026-130934 (573266324) | Autofill | `AndroidAutofillProvider` |
| CVE-2026-130907 (574795880) | Autofill (EVP) | Hoja inferior de Android (Java) |
| CVE-2026-130932 (579027312) | Core | *App zygote* de Android |
| CVE-2026-131089 (581367663) | CrashReporting | Breakpad de *remoting* en Windows |
| CVE-2026-130914 (574967987) | ANGLE (`f563ee4`) | D3D11 |
| CVE-2026-131025 (575712513) | ANGLE (`1ff8918`) | `EnsureLoopForwardProgress` no existe en nuestro ANGLE |
| CVE-2026-130977 (576131851) | Dawn (`fa6d854`) | Backend OpenGL de Dawn; WebGPU apagado y Graphite fuera |
| CVE-2026-131104 (576944087) | Tint (`11e2a24`) | Vulkan |
| CVE-2026-131103, -131076, -131083, -131002, -131007 (576954321, 577369844, 577369904, 577371168, 577403973) | GPU (`e655a1ae86`) | `graphite_shared_context.cc`: **Graphite apagado** (DIRECTIVAS, 27-10) |
| CVE-2026-130957 (577245772) | V8 (`84d5d70`) | Solo relaja un `DCHECK` del perfilador: sin efecto en Release |
| CVE-2026-131081 (572307225) | Media (`7628505b50`) | En la propia 158 la defensa queda **apagada por defecto** (`8309773116`, rompía webs); no hay nada efectivo que portar |
| CVE-2026-130982 (571284298) | Omnibox (AIM Drive, `895803ea34`) | Revertido en `main` (`ef588dd9ab`); la WebUI depende de `kComposeboxDriveContextMenuOption`, **DISABLED** en la 156, y nuestras *variations* son inertes |
| CVE-2026-131033 (575810899) | Extensiones (`experimentalAiData`) | La API solo existe con `--extension-ai-data-collection` |
| CVE-2026-131022 (572237023), CVE-2026-130941 (574640593) | HTML-in-canvas (`aa1365a4a2`, `7658e8cea3`) | `kCanvasDrawElement` apagada en brave-core desde la 3.0.1 (también su *origin trial*). Entran limpios sin pruebas: se pueden meter sin coste como defensa si se prefiere |

## D. Por confirmar al portar

| CVE (bug) | Qué | Duda |
|---|---|---|
| CVE-2026-131057 (569191970) | ANGLE (`b82a564`, `e4a1c99`) | El arreglo pasa el *loop-forward-progress* de Metal al *frontend* y lo activa en PowerVR/Vulkan. Ver si el camino de Metal de Mac lo usaba y si el fallo nos alcanza |
| CVE-2026-130944 (579037685) | Omnibox Everywhere (`ec030d05ab`) | El código está en la 156 (`toolkit_views`); falta ver si la función está apagada por defecto. Choca |
| CVE-2026-130968 (577401536) | Views, menús (B8) | En Mac la mayoría de menús son nativos (Cocoa); ver si `MenuItemView` se alcanza |

## E. Rama 8078 después de la .109 (Google ya lo ha portado a nuestra rama)

`+log/156.0.8078.109..refs/branch-heads/8078` (gitiles, 18-11 ~09:00 UTC; la rama sigue moviéndose). Ninguno está
en la nota de la 158 por número, pero son arreglos [M156] de seguridad y entrarán en las próximas notas:

| Original | Qué |
|---|---|
| 859c5bc938 | FSA: sin resolución de rutas de la plataforma en incógnito (571250973) |
| d83ec3c16e | FSA: rutas UNC de escritorio remoto (Windows; inocuo en Mac) |
| c404a3a5ff | Caché: validar entradas *sparse* antes de servir peticiones que necesitan red (584997533) |
| 7f43e52174 | Streams: caché de las funciones de tamaño de las estrategias integradas (582927496) |
| 39e958e23e | `SyncLoadContext`: aplazar el final durante las redirecciones (579277904) |
| ba15fb1f7a | WebCodecs: *callbacks* por el *task runner* del contexto (576082223, 580866733, 578659916) |
| 2dc582d280 | MemoryCache: no reutilizar si `GetSkipServiceWorker()` no coincide (4 bugs) |
| 062407e542 | Edición: mutaciones del DOM durante el reemplazo de texto (576742430) |
| c676849a25 | `HTMLPlugInElement`: cargas de imagen fuera del recálculo de estilo (575053155) |
| 17c24f828f | Service Worker: vida de `NavigationPreloadRequest` en los *callbacks* (578676178) |
| 777fb18c05 | Autofill: longitudes de `selected_option_text` y `selected_text` (578657256) |
| 385ec45c60 | Prerender: borrar subframes pendientes antes de activar (583734992) |
| ANGLE c1ef6d4, f4f8357 | Traductor: envolver constructores de structs tras la inicialización (571383804); GL: nivel base en la inicialización robusta de ASTC (567812965) |
| Dawn `86d91e78` → `6d772bc9e5` | Roll de M156 (WebGPU y Graphite apagados: mirar, probablemente nada) |

## Propuesta

1. **La 3.1.4 = A + B + E** (y D si se confirma). C fuera, con el motivo anotado. Sin KEV ni críticos pendientes: se
   puede llevar al ritmo normal de tanda, no «en cuanto salga».
2. Orden: **A1 (V8) primero**, para que D8-LINUX empiece la d8/mjsunit cuanto antes → A2–A3 (ANGLE, como `.patch` en
   `3.1.4/angle/`) → A4–A12 → B1 (XML) → B2–B8 → E (congelado en el tag que exista al empezar a portar).
3. Entrega como en la 3.1.3: `format-patch` en `FlyWeb/seguridad/3.1.4/` (chromium sobre `local/313` `7ccbc27cf7`,
   ANGLE/Dawn como `.patch`, V8 aparte), cruce con `patches/` y `chromium_src/` de brave-core, y APTO propio por la
   regla 17. brave-core: `flyweb_version` 3.1.4 y la etiqueta de `package.json`.
4. Fuera del encargo, para decidir: los **82 medios** de la 158 no se han mirado.
