# FlyWeb 3.1.4: contenido (parte 1)

SEGURIDAD-PORTES-24, 18-11-2026. Versión **solo de seguridad**: los Altos de Chrome 158 que no están en la 3.1.3.
Inventario y criterios en [`INVENTARIO.md`](INVENTARIO.md). Decisión de COORDINACIÓN-46 (18-11): la 3.1.4 lleva
A + B + E (y D si se confirma); los 82 medios no entran (triaje aparte para la 3.1.5 cuando A + B estén entregados).
**Nada compilado por mí.** **Parte 1 = A completo + B1–B4, B7 y B8.** Faltan B5, B6, D y E (abajo, «Pendiente»).

## Base y resultado (comprobados)

| Repositorio | Base (3.1.3, build 46) | Serie | Resultado |
|---|---|---|---|
| chromium | `local/313` **`7ccbc27cf7`** (árbol `be76a94fbf`; `ls-remote` del 18-11) | `chromium/` 0001–0017 | árbol **`6a2cac161c`** (comprobado: `git apply` de la serie sobre `local/313`) |
| ANGLE | `bc2ebdd211` (árbol `099b621f10`, reproducido: `f10470c77e` + `3.0.1/angle` 0001–0012 + `parches/3.1-angle` 0001–0004) | `angle/` 0001–0003 | árbol **`db885a866b`** (comprobado con `git am`) |
| V8 | 15.6.75.66 (`917584bd93`), sin cambio de gitlink | `patches/v8` de brave-core (abajo) | — |
| brave-core | `local/3.1.3` `2d55dce9a96` | `brave-core/` 0001–0002 = rama **`seg/3.1.4`** **`d91632790084`** (`ls-remote`, 18-11) | árbol **`15f69f5850`** |

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

`package.json` (etiqueta del proyecto) se queda en .109 hasta E. **d8/mjsunit:** encargado a D8-LINUX
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

## Pendiente (relevo)

1. **B5** (fb2af07952, Media, CVE-2026-130961): choca en `resource_multi_buffer_data_provider.cc` y `url_index.cc`;
   depende de `CrossOriginFail()`, `CanAcceptDataFrom()` y del bloque de `ERR_BLOCKED_BY_ORB` de `main`. Los cinco
   previos de `MultiBuffer` ya están en la 8078. Hace falta un porte propio.
2. **B6** (9e54c5b962, Event Timing, CVE-2026-130946/-131045): sin empezar.
3. **D:** ANGLE 569191970 (`b82a564`, `e4a1c99`) y Omnibox Everywhere (`ec030d05ab`).
4. **E:** 12 commits [M156] de la rama 8078 tras la .109 (lista en `INVENTARIO.md` §E), congelados en el tag que
   exista al llegar (anotarlo). Con ellos, `chrome/VERSION`, la etiqueta de `package.json` y el roll de Dawn
   `86d91e78` → `6d772bc9e5` (mirar si hay algo de Mac; WebGPU y Graphite están apagados).
5. Resultado de D8-LINUX para brave-core 0002.
