# FlyWeb 3.1.4: contenido (partes 1 y 2)

SEGURIDAD-PORTES-24, 18-11-2026. Versión **solo de seguridad**: los Altos de Chrome 158 que no están en la 3.1.3.
Inventario y criterios en [`INVENTARIO.md`](INVENTARIO.md). Decisión de COORDINACIÓN-46 (18-11): la 3.1.4 lleva
A + B + E (y D si se confirma); los 82 medios no entran (triaje aparte para la 3.1.5 cuando A + B estén entregados).
**Nada compilado por mí.** **Parte 1 = A completo + B1–B4, B7 y B8** (SEGURIDAD-PORTES-24). **Parte 2 = B5, B6, D y E**
(SEGURIDAD-PORTES-25, 18-11; abajo, desde «Parte 2»). Con las dos, A + B + E completos; D no aplica.

## Base y resultado (comprobados)

| Repositorio | Base (3.1.3, build 46) | Serie | Resultado |
|---|---|---|---|
| chromium | `local/313` **`7ccbc27cf7`** (árbol `be76a94fbf`; `ls-remote` del 18-11) | `chromium/` 0001–0017 (parte 1) | árbol **`6a2cac161c`** (comprobado: `git apply` de la serie sobre `local/313`) |
| chromium | árbol `6a2cac161c` (parte 1) | `chromium/` 0018–0026 (parte 2) | árbol **`4e87f2898a`** (comprobado por la -25: `git am` de 0001–0026 sobre `local/313`) |
| ANGLE | `bc2ebdd211` (árbol `099b621f10`, reproducido: `f10470c77e` + `3.0.1/angle` 0001–0012 + `parches/3.1-angle` 0001–0004) | `angle/` 0001–0003 | árbol **`db885a866b`** (comprobado con `git am`) |
| V8 | 15.6.75.66 (`917584bd93`), sin cambio de gitlink | `patches/v8` de brave-core (abajo) | — |
| brave-core | `local/3.1.3` `2d55dce9a96` | `brave-core/` 0001–0002 = rama **`seg/3.1.4`** **`d91632790084`** (`ls-remote`, 18-11) | árbol **`15f69f5850`** |
| brave-core | `seg/3.1.4` `d91632790084` | `brave-core/` 0003 (parte 2; **solo como `.patch`**: la -25 no tiene push a brave-core) | árbol **`71e60c4558`** |

Sin forks de ANGLE: LOCAL aplica `angle/` con `git am` sobre su `bc2ebdd211` y fija el gitlink y `angle_revision` en el
commit de fijación, como en la 3.1.3. Dawn, FFmpeg, Skia, PDFium e ICU no cambian en la parte 1.

## chromium 0001–0017

| Parche | Original | CVE (bug) | Qué | Cómo entra |
|---|---|---|---|---|
| 0001 | 7076eb7bd8 [M158] | CVE-2026-131068 (574789298) | `AtomicString` colgantes en `WillModifyAttribute` | limpio |
| 0002 | 15e314b14a | CVE-2026-130984 (572574561) | Canvas: reentrada en `getContext` | limpio (3 vías) |
| 0003 | dd9608809b | CVE-2026-131082, -130915 | `Persistent` únicos de `css/` por hilo | limpio |
| 0004 | bf220f8ce0 | CVE-2026-130979 (566377256) | PagePopup: `opener_web_view_` colgante | código limpio; la prueba nueva, fusionada a mano junto a nuestra `NarrowedPopupIsNotScrolled` (+339/−10, como upstream) |
| 0005 | bc7f159f95 | CVE-2026-131090 (570703733) | IntersectionObserver con marco estrangulado | código limpio; **`intersection_observer_test.cc` fuera** (choca con APIs de prueba de `main`) |
| 0006 | 2fc814f077 [M158] | CVE-2026-130980 (576203570) | Intersecciones con estado de ciclo de vida obsoleto | limpio |
| 0007 | 0339825273 | CVE-2026-130909 (560339053) | Extensiones: sin *accessors* al buscar globales | limpio |
| 0008–0009 | f182e1b65f, 17d399e9af [M158] | CVE-2026-130940 (568891853) | `glGenTextures` que devuelve 0 | limpios, en ese orden |
| 0010 | d9fcba36b9 | — (prerrequisito) | `views::ViewGuard` | **no existe en la 156**: lo usan 0011 y 0017. `BUILD.gn`: solo las líneas de `view_guard`; `AddMenuItemAt` conserva `AddChildViewAt(item, index)` |
| 0011 | b38c99803d [M158] | CVE-2026-130999 (583617538) | Views: botones de diálogos | limpio (con 0010) |
| 0012 | e8174b45ce | CVE-2026-131084 (569659189) | XML: fallos de `XMLDocumentParserRs` | **a mano** (detalle abajo) |
| 0013 | 01c2ce852f | CVE-2026-131065 (565839464) | Autofill: punteros a `RenderFrame` en *layout* síncrono | a mano: solo se quita nuestra `GetCaretBounds()` libre; +120/−51, como upstream |
| 0014 | propio, por 770ffddb7f | CVE-2026-131059 (573263397) | Autofill: `SynchronousFormCache` | **propio** (detalle abajo) |
| 0015 | 98e5b3bb0c | CVE-2026-131021 (572237022) | a11y: padres de hijos `aria-owns` | a mano: `RemoveIncludedSubtree` combina el arreglo con nuestro `GuardedCachedChildrenIncludingIgnored()` y `!object->IsDetached()`; **`ax_object_cache_test.cc` fuera** |
| 0016 | d0e07566a9 [M158] | CVE-2026-130970 (568937157) | GPU: `SubmitIfNecessary` antes de limpiar | a mano: sin el `DrainGLErrors()` de `main`; comprobado que `success` está declarado en los 7 sitios |
| 0017 | 3eedf7cece [M158] | CVE-2026-130968 (577401536) | Views: menús frente a *callbacks* de accesibilidad | limpio (con 0010). En Mac la mayoría de menús son nativos; entra igual, porque es barato |

**0012 (XML en Rust).** Se alcanza en la 156: `Document::CreateParser` usa `XMLDocumentParserRs` en documentos sin
marco (DOMParser, `responseXML`) **y en los SVG con marco** (`!GetFrame() || IsSVGDocument()`), donde corren scripts y
custom elements XHTML durante el análisis. Entra: `IsStopped()` tras `CreateElement` y atributos uno a uno si corrió un
constructor; `Append()`/`Finish()` reentrantes a `pending_src_` y a `EndInternal()` (el error de raíz desequilibrada
pasa de `Finish()` a `EndInternal()`, como upstream); posición de inicio de script; `saw_error_` en `WellFormed()`;
sin `panic` con entidades XHTML en documentos `standalone="yes"` (el crate `xml-v1` de la 156 exporta
`ImmutableEntitiesError::StandaloneDocument`). Fuera: lo de XSLT en Rust que la 156 no tiene (`saw_xsl_transform_`,
alertas CAP, `IsXSLTAllowed`), el cambio de estado de `XMLParsingRust` (ya apagado en la 156), `DOMPatchSupport`
(DevTools) y las expectativas de web tests. `ResumeParsing()` y `EndInternal()` quedan iguales que upstream salvo el
bloque de XSLT.

**0014 (SynchronousFormCache).** El arreglo de upstream rehace `SynchronousFormCache`, `FormCache`,
`FormSubmissionTracker` y `PasswordGenerationAgent` sobre APIs de `main`. Equivalente para la 156: la caché guarda copias
`std::optional<FormData>` en vez de `base::optional_ref` a los `FormData` de `FormCache`. Así el JavaScript que corre con
los eventos `input`/`change` que despachan Autofill y la generación de contraseñas ya no puede dejarla apuntando a
memoria liberada. Coste: copiar los formularios al crear la caché desde el mapa; dato quizá desactualizado en ese caso,
como acepta upstream.

## brave-core 0001–0002 (`seg/3.1.4`)

| Parche | Qué |
|---|---|
| 0001 | `flyweb_version` 3.1.3 → **3.1.4** |
| 0002 | `patches/v8`: **659b8bf** (CVE-2026-131042, regexp, limpio sobre la .66, con `regress-573263262.js`) y `kFlyWebCacheEpoch` 31 → **32**; nota en `patches/v8/FLYWEB-SECURITY.md` |

`package.json` (etiqueta del proyecto): .110 en 0003 (parte 2). **d8/mjsunit:** encargado a D8-LINUX
(`buzon/D8-LINUX/20261118-0950-SEGURIDAD-PORTES-24-v8-659b8bf.md`, avisado COORDINACIÓN-46); **sin él en verde, 0002 no
entra**.

## ANGLE 0001–0003

| Parche | Original | CVE | Qué |
|---|---|---|---|
| 0001 | a30dae4 | CVE-2026-130954, -130996 | Traductor: renombrar las variables sacadas de un `switch` (`PruneNoOps`, `msl/RewriteCaseDeclarations`). Solo choca `angle_end2end_tests_expectations.txt` (Pixel 4): se añade solo la línea de 573893628 |
| 0002 | 48e22c0 | CVE-2026-130910 | Traductor: plegado de `switch` constante frente a `length()` |
| 0003 | f4f8357 [M156] | (E: rama 8078 tras la .109) | GL: nivel base en la inicialización robusta de ASTC |

c1ef6d4 (E, «Wrap struct constructors after init») **ya estaba**: mismo `patch-id` que `3.0.1/angle` 0009.

## Cruce con brave-core

- `patches/`: `html_canvas_element.cc` (0002) y `runtime_enabled_features.json5` (0005) siguen aplicando
  (`git apply --check` sobre el árbol final).
- `chromium_src/`: `chrome_client_impl.cc` (0004) y `html_canvas_element.cc` (0002) solo incluyen el original y
  añaden funciones o la macro `BRAVE_TO_DATA_URL_INTERNAL`; ningún nombre que toque la serie.
- Los `#include` nuevos de la serie existen en el árbol, salvo los generados (`event_type_names.h`,
  `runtime_enabled_features.h`) y los de V8. **Huella:** nada toca red, TLS, cabeceras ni Client Hints.

## Veredicto (regla 17): **APTO**, parte 1

Revisado el código de cada parche contra la 156. Riesgos que LOCAL debe mirar al compilar:
- 0010/0011/0017: `ViewGuard` hace `NOTREACHED()` si la vista se destruye en su ámbito. Es la política de upstream:
  un cierre controlado en lugar de un UAF.
- 0012: el XML de Rust en SVG con marco.
- 0014: compila con copias; las pruebas `autofill_agent_browsertest` y `password_generation_agent_browsertest` deben
  seguir verdes.
- V8: el `CHECK` de `Compiler::Assemble`.

Pruebas que faltan por portar: las de 0005 y 0015.

## Parte 2 (SEGURIDAD-PORTES-25, 18-11)

### chromium 0018–0026

| Parche | Original | CVE (bug) | Qué | Cómo entra |
|---|---|---|---|---|
| 0018 | **propio**, por fb2af07952 + 61b6e5652b | CVE-2026-130961 (572308124) y CVE-2026-130936 (573262234, medio que arregla el mismo commit) | Media: validar el origen de los datos antes de tocar `UrlData` o redirigir | **porte propio** (detalle abajo) |
| 0019 | 9e54c5b962 | CVE-2026-130946, -131045 (572682755, 572882344) | Event Timing: marco del destino y ventana de origen en `CanExposeNode` | a mano solo `largest_contentful_paint.cc` y `performance.cc` (estilo de llaves); el resto, con pruebas e `histograms.xml`, como upstream |
| 0020 | 385ec45c60 [M156] | (583734992) | Prerender: borrar los subframes pendientes de borrado antes de activar | limpio, `patch-id` igual |
| 0021 | 777fb18c05 [M156] | (578657256) | Autofill: longitudes de `selected_option_text` y `selected_text` | limpio, `patch-id` igual |
| 0022 | 17c24f828f [M156] | (578676178) | Service Worker: vida de `NavigationPreloadRequest` en los *callbacks* | limpio, `patch-id` igual |
| 0023 | c676849a25 [M156] | (575053155) | `HTMLPlugInElement`: cargas de imagen fuera del recálculo de estilo (`HTMLPlugInDeferStyleRecalcImageLoad`, `stable`) | limpio, `patch-id` igual |
| 0024 | 062407e542 [M156] | (576742430) | Edición: mutaciones del DOM durante el reemplazo de texto | limpio, `patch-id` igual |
| 0025 | 2dc582d280 [M156] | (563000235 y 3 más) | MemoryCache: no reutilizar si `GetSkipServiceWorker()` no coincide | limpio, `patch-id` igual |
| 0026 | — | — | `chrome/VERSION` .109 → **.110** | propio |

**0018 (Media, B5).** El arreglo de upstream (fb2af07952) parte `UrlData::ValidateDataOrigin()` en `CanAcceptDataFrom()`
(solo lectura) y `SetDataOrigin()`, y valida el origen de la respuesta contra el `UrlData` viejo y el de destino **al
principio** de `DidReceiveResponse()`, antes de tocar longitud, caché, `UrlIndex` o redirección; `TryInsert()` devuelve
la entrada nueva si es inválida o si `MergeFrom()` la rechaza. Se le suma la parte de `url_index.cc` de **61b6e5652b**
(crbug 579225207): fb2af07952 metió `CHECK` que saltaban con URL de origen opaco idénticas (`blob:null/…` tras
`revokeObjectURL`) y tras un fallo de origen cruzado previo; en la 158 estable no está, y en FlyWeb sería un cierre de
pestaña con una web normal. La serie previa de `MultiBuffer` (61ef27611d, 79d7e8374c, ccb98073b6, 226a56e637,
718a8fc158) ya estaba en la 8078. **Fuera, con su motivo:**
- `media::kDisallowMixedOpaqueMediaResponses` (7628505b50, el C de CVE-2026-131081): no existe en la 156 y en la 158
  estable está apagada (8309773116). Sin ella, `CanAcceptDataFrom()` no compara la opacidad, como la 158 estable. Por eso
  la tercera prueba nueva de upstream (`MixedOpaqueResponseDoesNotMutateUrlData`) queda fuera; las otras dos entran.
- El bloque de `ERR_BLOCKED_BY_ORB` de `DidFail()` (b71ea276fd, 8132e3a4c4) y con él `CrossOriginFail()`, que en la 156
  no tendría llamador. 8132e3a4c4 es el medio CVE-2026-121223 de la 157 (propuesta de triaje).
- La clave de `UrlIndex` por `SecurityOrigin` del documento (7b99dd29ba, medio CVE-2026-121105 de la 157): sirve sobre
  todo a WebView sin aislamiento de sitios (propuesta de triaje).
- `TrySetLength()`/`HasCompatibleLength()` y no reintentar respuestas de Service Worker, que la 158 estable lleva encima
  de fb2af07952: es otro arreglo (probablemente el medio 573265164, CVE-2026-131026); no entra (los medios no entran).

`set_is_cors_cross_origin()` pasa a privado: los únicos llamadores de la 156 (`resource_multi_buffer_data_provider.cc`,
`url_index.cc` y `url_index_unittest.cc`) quedan cubiertos; se buscó en los 80 ficheros de `platform/media`.

**0019 (Event Timing, B6).** Todos los llamadores de `Performance::CanExposeNode` de la 156 (los de `core/timing`;
buscado también en `core/paint/timing`) están en el parche. `kEventTimingUseTargetFrame` es una función nueva
**encendida por defecto** (interruptor de Finch; nuestras *variations* son inertes, así que queda encendida). Los
histogramas nuevos (`…MaxEventDuration.MainFrame` y dos más) son UMA local, que FlyWeb no envía.

### D: no aplica

| CVE (bug) | Qué | Por qué no aplica |
|---|---|---|
| CVE-2026-131057 (569191970) | ANGLE `b82a564` + `e4a1c99` | El arreglo saca `EnsureLoopForwardProgress` del traductor de MSL al *frontend* y lo **enciende solo en PowerVR** (GL y, con e4a1c99, Vulkan): el compilador de PowerVR falla con bucles infinitos. En Metal ya estaba encendido en nuestro ANGLE (`f10470c77e`: `DisplayMtl.mm`, `ensureLoopForwardProgress` = `true`, con `tree_ops/msl/EnsureLoopForwardProgress.cpp`) y el arreglo lo deja igual. En el respaldo GL de la 3.1.2 (macOS < 11) seguiría apagado, porque ningún Mac de Intel tiene GPU PowerVR |
| CVE-2026-130944 (579037685) | Omnibox Everywhere `ec030d05ab` | `kOmniboxEverywhere` es **DISABLED** en la 156 (`omnibox_next_features.cc`) y brave-core no la toca (ni `kOmniboxEverywhere` ni *variations*); la WebUI (`OmniboxEverywhereUIConfig::IsWebUIEnabled`) y la página de depuración que arregla el parche exigen `IsOmniboxEverywhereEnabled()`, que además pide Google como buscador por defecto. Inalcanzable |
| CVE-2026-130968 (577401536) | Views, menús (B8) | Ya entró en la parte 1 (0017) |

### E: rama 8078 hasta la .110 (congelado)

**Congelado en el tag `156.0.8078.110` = `04545e38be40409060b193c691c54391a65ee1a1`** (`ls-remote` de chromium/chromium,
18-11 ~09:58 UTC: es el último tag de la 8078; la rama ya ha subido `VERSION` a .111 sin tag). Rango
`156.0.8078.109..156.0.8078.110`: 30 commits; 16 son de pruebas («🌺»), uno el AFDO de ChromeOS y uno `VERSION`.

| Qué | Resultado |
|---|---|
| 6 [M156] de chromium | 0020–0025, todos limpios y con el mismo `patch-id` que upstream |
| `chrome/VERSION` | 0026 (.110) |
| V8: `0c5649e53a` → `aab02c4400` → **`917584bd93`** | **nada que hacer:** la 3.1.3 ya compila la .66 (`917584bd93`) |
| ANGLE: `44d1e22b80` → **`f4f8357341`** | rango `f10470c77e..f4f8357341` = 4 commits: 2080bf27e5 y 44d1e22b80 son de Vulkan (no se compilan en Mac), c1ef6d4f97 ya estaba (`3.0.1/angle` 0009) y f4f8357341 es `angle/0003` de la parte 1. **Nada más** |
| Dawn: `d2c1eac2db` → `86d91e7812` → **`6d772bc9e5`** | 86d91e78 = LiteRT, sin efecto (LOCAL, 3.1.3). 86d91e78..6d772bc9 (leído por LOCAL-19, 18-11, vía COORDINACIÓN-47) = **un solo commit, 6d772bc9e5 «[M156] DEPS: Update DXC to patched branch»**. DXC solo se compila en Windows (`dawn_use_built_dxc = is_win`): **no entra**; Dawn se queda como en la 3.1.3 (`5ee7543174`) |
| `src_internal` | no se usa |

**Después de la .110 (fuera de la 3.1.4; a la 3.1.5):** 859c5bc938 FSA en incógnito, d83ec3c16e FSA UNC (Windows),
c404a3a5ff caché *sparse*, 7f43e52174 Streams, 39e958e23e `SyncLoadContext`, ba15fb1f7a WebCodecs y `VERSION` .111.

### brave-core 0003

| Parche | Qué |
|---|---|
| 0003 | `package.json`: etiqueta del proyecto `chrome` 156.0.8078.109 → **.110** |

Sin push a brave-core desde esta sesión (`add_repo` denegado por el clasificador): LOCAL aplica 0003 con `git am`
encima de `seg/3.1.4` `d91632790084`. Árbol resultante `71e60c4558`.

### Cruce con brave-core (parte 2)

- `patches/`: `third_party-blink-renderer-core-dom-document.cc.patch` (0025 no lo toca, pero `document.cc` está en la
  serie) y `…-runtime_enabled_features.json5.patch` (0023 añade una entrada) siguen aplicando: `git apply --check` sobre
  el árbol `4e87f2898a`.
- `chromium_src/`: `core/dom/document.cc` solo incluye el original; `platform/loader/fetch/resource_fetcher.cc` redefine
  `DefaultCacheIdentifier`, y 0025 no añade ninguna llamada nueva a ese nombre. Nada más de la serie tiene `chromium_src`.
- **Huella:** nada toca red, TLS, cabeceras ni Client Hints. 0025 cambia cuándo se reutiliza la caché de memoria
  (como Chrome 156 de serie).

### Veredicto (regla 17): **APTO**, parte 2

Revisado el código de cada parche contra la 156. Riesgos para LOCAL:
- **0018:** los `CHECK(destination_url_data->CanAcceptDataFrom(...))` tras `TryInsert()` y `RedirectTo()` son nuevos.
  Con 61b6e5652b y sin la comparación de opacidad no deberían saltar; si salta uno, es un cierre de pestaña y hay que
  avisarme. Pruebas: `blink_platform_unittests --gtest_filter='UrlIndexTest.*:ResourceMultiBufferDataProviderTest.*:MultiBufferDataSourceTest.*'`,
  y a mano: vídeo MP4 con saltos (YouTube 720p, Vimeo), `<video>` con `blob:` en un `iframe` con `sandbox` (sin `allow-same-origin`)
  tras `URL.revokeObjectURL`, y audio de otro origen (radio en línea, `crossorigin` y sin él).
- **0019:** `blink_unittests --gtest_filter='PerformanceTest.*:PointerEventManagerTest.*'`.
- **0022:** `content_unittests --gtest_filter='ServiceWorkerContextClient*'` y `blink_unittests --gtest_filter='WebEmbeddedWorkerImplTest.*'`.

### Pendiente

1. **D8-LINUX:** sin el verde de 659b8bf, brave-core 0002 no entra (parte 1).
2. ~~**Dawn** 86d91e78..6d772bc9~~: cerrado (solo DXC, Windows; arriba).
3. Propuesta de triaje corto de los medios para la 3.1.5, sin portar (aparte, a COORDINACIÓN).
