# FlyWeb 2.7.0 — nivel 138 del motor

Fila FM.53. Base: brave-core `local/261-arreglos` 480f73623798 (2.6.1 publicada), rama `nube/motor-138` (MOTOR-42).
Inventario del 138: `motor-niveles.md` § «Nivel 138» (pendiente).

## Decisiones

### Aplazado del 137

- **`CSSSampleId::kReadingOrder` en su sitio numérico** (839 antes de `kPrintColorAdjust` 848): hecho en 84bff67d. Detrás
  no hay contador implícito (`enumorden.py` sin avisos), así que es orden, no una caída evitada.
- **Particionado de Blob URL: propuesta de no portar los ~27 commits de `content/` del 137** (decide COORDINACIÓN).
  Motivo (V, lectura de código): FlyWeb ya lo tiene. La 128 guarda cada Blob URL con su `StorageKey`
  (`BlobUrlRegistry::IsUrlMapped`/`RemoveUrlMapping` comparan la clave) y la anulación de Brave
  `chromium_src/storage/browser/blob/blob_url_store_impl.cc` (2022) solo resuelve un Blob URL, para `fetch` y para
  navegación, desde la misma partición (o desde una extensión). **Brave 1.79 (Chrome 137) mantiene esa anulación** sobre
  el código de Chrome ya particionado, e ignora `is_top_level_navigation`: es más estricto que Chrome, que deja abrir en
  una pestaña nueva, con `noopener`, un Blob URL de otra partición del mismo origen. Regla 20: la referencia es Brave, y en
  esto ya estamos igual. Lo que trae el porte de Chrome es fontanería (estados `kNotMappedCrossPartition…`, avisos de
  DevTools, la política `PartitionedBlobUrlUsage`, claves de workers) sin cambio de privacidad para quien navega. S: no
  he comprobado línea a línea los workers dedicados y compartidos creados desde un Blob URL de otra partición; lo cubre
  la prueba de Brave `blob_url_browsertest.cc` solo para marcos.

- **`CaretWithTextAffinityUpstream`** (2a137720e54, crbug 40677155): c7fbf1e6. Bandera `stable` como en Chrome 137;
  include de `runtime_enabled_features.h` explícito en `insert_text_command.cc`. Sin arreglos posteriores en upstream.
- **`TextareaStableResizing`** (a687e1c3da8): 8a7edf40. Un hunk de `PointerEventManager::Clear()` a mano (contexto
  distinto en la 128). `PaintLayerScrollableArea::Resize` cambia de firma: los únicos llamadores en la 128 son
  `scroll_manager.cc` y `pointer_event_manager.cc` (S: no he barrido el árbol entero; si LOCAL ve otro, ese llamador
  tiene que guardar `InitializeResizeTransform()` al empezar el arrastre, como hacen los dos; un `{}` daría tamaños
  erróneos). Sin arreglos posteriores salvo quitar la bandera (026c1ff36ec).
- `fuera.py --ref 137.0.7151.122` sobre los 8 parches tocados: 0 avisos. `enumorden.py`: sin avisos.
- **Bit 0 de canvas-float16 (2.6.0: 1 canal de ~250 en un origen): sin causa encontrada, sin cambio de código.** Hipótesis
  descartada con simulación del algoritmo de `PerturbPixelsInternal` (200 claves, 64×64, float16 y float32): un canal
  elegido dos veces vuelve exacto a su valor, como el XOR de 8 bits; ninguna ejecución da un cambio fuera del bit 0.
  Queda como sospecha (S) un píxel que la GPU no rellena idéntico (1 ULP de diferencia en un relleno liso), que la página
  cuenta como «cambiado» sin serlo. `canvas-float16.html` ahora informa del píxel, canal, bits y valores de cada caso
  (hasta 4): LOCAL lo pasa con la 2.7.0 y, con ese dato, se decide. No bloquea (COORDINACIÓN-23, 31-10).

### Nivel 138, tanda del 02-11 (MOTOR-42; `nube/motor-138` 5a86f3aa, sin compilar)

- **`MediaSourceNewAbortAndDuration`** (0cc875d9): encendido sin más; el código que gobierna es idéntico en la 128 y la 138.
- **Contenido mixto** (993b32bd; 3e980163 + aa485810): `ShouldAutoupgrade` decide con `IsMixedContentRestrictedInFrameContext`
  (esquema del marco superior y del actual) en vez del `HttpsState`. Afecta a la anulación de Brave
  `chromium_src/.../mixed_content_checker.{cc,h}` (firma nueva con `LocalFrame*`) y a `.onion`: el camino viejo dependía de
  que `https_state.cc` devolviera `kModern` para `.onion`; se añade el gancho
  `BRAVE_MIXED_CONTENT_CHECKER_IS_MIXED_CONTENT_RESTRICTED_IN_FRAME_CONTEXT` tal como lo tiene Brave 1.80. Sin portar
  `mixed_content_checker_test.cc` (si LOCAL compila `blink_unittests`, ese test no compilará con la firma vieja: pasarle
  `nullptr` como último argumento).
- **`QuotaExceededError`** (5a86f3aa; 3009dd8e, 1b6ec5ba, a7bea0c1, a162e5a3, 400a4608): interfaz nueva derivada de
  `DOMException` con `quota`/`requested`. Adaptado a la 128: `ExceptionState` guarda la excepción construida con
  `SetException` (la 128 la propaga después); sin isolate se lanza un `QuotaExceededError` normal en vez de no lanzar nada
  (upstream volvía sin excepción); fuera los trozos de `modules/ai`. `DOMExceptionCode::kQuotaExceededError` pasa a
  implícito = 37, igual que en la 138 (mismo orden), y `IDBException::kQuotaError` = 37 a juego (`idb_request.cc` hace un
  `static_cast` entre los dos). S: no he barrido la 128 entera buscando otros sitios que supongan el 22.
- **Aplazados a la tanda de mañana** (no son encendidos: piden código posterior a la 128):
  - `progress()`, `abs()`/`sign()`: sintaxis nueva de `progress()` (b9417dbcfe2), recorte del resultado (0f954c71f10) y la
    infraestructura de cálculo sin resolver que comparten con `sibling-index()` (se retiraron en marzo por caídas en flex).
    Van con `sibling-index()`.
  - `ViewportSegments`: `window.viewport` no existe en la 128 (ae78afaca30, ago. 2024). En Mac siempre es un segmento:
    solo aporta coherencia con el Chrome declarado. Coste ~1 h.
  - **Integrity-Policy**: función entera ausente en la 128 (~10 commits: análisis en `services/network`, mojom,
    `navigation_request.cc`, informes, Blink). Más que una tanda corta.
- `fuera.py --ref 138.0.7204.185`: 0 avisos en los 30 parches tocados; `enumorden.py`: sin avisos.

### Blink frente a la API de V8 13.8 (MOTOR-43, 02-11; brave-core 2c94d743, sin compilar)

- **API pública (`include/` 13.7.152.17 → 13.8.258.30): nada que la 128 use se ha quitado.** Barrido de Blink
  (`renderer/` y `public/`), gin, `content/renderer`, `extensions/renderer`, `chrome/renderer`, components, pdf,
  `proxy_resolver` y `v8_context_snapshot` de la 128 y de los parches de brave-core: ningún `Utf8Value` de 3 argumentos
  (pierde `WriteOptions`), ningún `ThreadIsolatedAllocator::SetDefaultPermissionsForSignalHandler` (borrado) ni
  `Member::GetRawAtomic` (ahora devuelve `const void*`). Lo demás son `DEPRECATE_SOON` (`GetIsolate()`,
  `ContinuationPreservedEmbedderData` sin V2), apagados en `build.sh`. `Write`/`WriteUtf8` viejos siguen (`DEPRECATED`).
- **`api.cc`: sin `ApiCheck`/`CHECK` nuevos** (el «Unaligned pointer» es el de siempre, reescrito). `read-only-promotion`
  y `weak`/`dlsym`/`__builtin_available` sin cambios (MOTOR-42).
- **Contadores de V8 168–174** (`kWasmMultiValue`… `kInvalidatedNoDateTimeConfigurationChangeProtector`): no se portan
  sus `WebFeature`; `use_counter_callback.cc` de la 128 los ignora con `default:` y FlyWeb no envía UMA.
- **`kUseContextSnapshot`** (ENABLED en la 138): se queda como en la 128.
- **Dependencias: tres bloqueos de compilación que no eran de API**, todos resueltos:
  - **dragonbox** (nuevo en V8 13.8; `numbers/conversions.cc`, solo cabecera): `BUILD.gn` y `README.chromium` de la 138
    por parche, el código en `FlyWeb/dragonbox-revision` (6c7c925b, 1.1.3, con suma) y `build.sh` lo trae como a
    fast_float (función común `traer_dep_v8`). Licencias Apache-2.0 con excepción LLVM y BSL-1.0 en `about:credits`. Sin
    intrínsecos AVX en clang (solo `addcarry`, x86-64 base).
  - **simdutf 6.4.0 → 7.0.0** (9d3e4d7c, el de la 138): V8 13.8 llama a `atomic_base64_to_binary_safe` y
    `to_well_formed_utf16`. Mismo `BUILD.gn` y `LICENSE`; solo lo usa V8. Mismo despacho en tiempo de ejecución
    (Westmere para la 5,1).
  - **Temporal**: V8 13.8 lo enciende por defecto en Mac y depende del crate Rust `temporal_capi`, que la 128 no tiene.
    `build.sh` pasa `v8_enable_temporal_support:false` (Chrome 138 no lo expone sin `--harmony-temporal`; upstream
    compila así en Windows). Se reabre en el nivel cuyo Chrome lo exponga.
  - ICU, abseil, highway, fp16 y cabeceras estándar: sin usos nuevos frente a la 13.7. `//build` de la 128 tiene todo
    lo que pide el `BUILD.gn` de V8 13.8.
- **S, para la primera prueba de LOCAL:** desde crrev.com/c/6458560, V8 saca el isolate del TLS
  (`GetCurrentIsolate[ForSandbox]`) en los `inline` de campos internos, datos de contexto y cadenas externas, en vez de
  la cabecera del objeto. Si Blink 128 toca un objeto de V8 en un hilo sin `Isolate::Scope`, falla ahí. Chrome 138 lo
  da por bueno, pero la 128 es más vieja: probar workers, worklets (audio, paint) y service workers.

### Tanda de MOTOR-43 (02-11; brave-core e80d8d6e y 17a21921, sin compilar)

- **`progress()` y `abs()`/`sign()` stable** (e80d8d6e): b9417dbcfe2 (sintaxis `progress(a, b, c)` en vez de `from`/`to`,
  adaptada a `CSSParserTokenRange` de la 128) y 0f954c71f10 [M138] (recorte a [0, 1]), más el flip de las dos banderas.
  **En la 128 `media-progress()` y `container-progress()` colgaban de la misma bandera que `progress()`**: encenderla sin
  más habría expuesto dos funciones que Chrome 138 no tiene. Se separan en `CSSMediaProgressNotation` y
  `CSSContainerProgressNotation` (experimentales), como en la 138.
- **`ViewportSegments`** (17a21921): ae78afaca30 (`segments` pasa de `visualViewport` a `window.viewport`), 9ea51ed248c
  (siempre devuelve los segmentos: uno en escritorio, sin entropía) y el flip de fc24d6c7278. La comprobación del
  origin trial `FoldableAPIs` de `origin_trial_context.cc` queda como en la 128, porque `DevicePosture` sigue usándolo
  aquí (Chrome 138 lo tiene stable; no está en el inventario: S, sin mirar).

### Integrity-Policy (MOTOR-44, 02-11; brave-core ca6014af, sin compilar)

- **`IntegrityPolicyScript`** (629b69e78b66, 93d38b50a171, 55bf0d1e8373, 4458c6764c68, 5ba6c5d0df66, f8e3fd713bce,
  227488522951, e9e51b382825, 7d991745c7df): cabeceras `Integrity-Policy` e `Integrity-Policy-Report-Only`; con
  `blocked-destinations=(script)`, un script sin `integrity` (o `no-cors`) se bloquea y se informa. Regla 20: Brave 1.80
  no lo toca (V, árbol de v1.80.125); los informes van por el mismo camino que los de CSP (`report-to` del propio sitio) y
  `ReportingObserver` sigue anulado por Brave. Sin huella nueva: no cambia ninguna petición.
- Adaptado a la 128 (V, contra `cr128`): el parser va en el componente `cpp` de red (ahí está `features.cc`; el
  componente `integrity_policy` no puede depender de él sin ciclo); `ContentSecurityPolicy::StripURLForUseInReport` pasa
  a miembro estático; `set_policy_container_host` → `SetPolicyContainerHost` (los llamadores de la 128 fuera de pruebas
  son los cuatro del commit); `kIntegrityPolicyInServiceWorkerResponse` = 5557 en su sitio numérico
  (`comprobar-enums.py` 0 errores). Pruebas, `fieldtrial_testing_config.json` y la lista del presubmit, fuera.
- **Dos arreglos posteriores a la serie, incluidos:** `integrity_policy.cc` de 138.0.7204.185 (vuelve sin bloquear si no
  hay policy container) y, de upstream `main`, el informe de integridad se envía **antes** del
  `static_cast<LocationReportBody*>` de `ReportingContext::SendToReportingAPI`: en la 138 ese cast leía
  `lineNumber()` fuera del objeto `IntegrityViolationReportBody` (regla 17: lo anoto para SEGURIDAD-PORTES).
- `fuera.py --ref 138.0.7204.185`: 0 avisos en 41 parches; `chk128.sh`: 55/55 aplican.
- **S para LOCAL:** `PolicyContainerPolicies` cambia de constructor (dos argumentos nuevos tras
  `document_isolation_policy`); si `content_unittests` o `blink_unittests` se compilan, sus pruebas con la firma vieja
  fallan (no portadas).

### Lote B2/B3 y letter-spacing (MOTOR-44, 02-11; brave-core a77a0737 y 9714bc81, sin compilar)

Arreglos que nacen `stable` en la 138, cada uno con su bandera (V: ninguna estaba en FlyWeb ni en el 137):
- a82b813fa801 `Selection.deleteFromDocument()` no borra dentro de INPUT/TEXTAREA (`SelectionDeleteFromDocumentUaShadowFix`).
- db062d2fc3c6 copiar no incluye contenido `user-select: none` (`SkipUnselectableContentInSerialization`).
- 5ee3b4ac2a1f la instantánea del portapapeles se reinicia al escribir (`ClipboardSnapshotResetOnWrite`).
- 132862ba859e CDATA se serializa como texto en documentos HTML (`SerializeCdataAsTextInHTMLDocuments`).
- 2cd928936852 ajuste de anchor positioning con overscroll (`AnchorPositionAdjustmentWithoutOverflow`); se queda dentro
  de la comprobación `ScrollNodeForOverflowHidden` de la 128 (stable aquí).
- **9b7d041aae94 unidad `ch` sin glifo «0»: 0,5em** (`CSSChUnitSpecCompliantFallback`). V: FlyWeb arrastraba el fallo de
  crrev.com/c/6333369 (136): devolvía `size / 0.5f` = 2em.
- f746f478c914 invalidación de filtros de referencia en trozos vacíos (`EmptyReferenceFilterInvalidation`); añade
  `EffectPaintPropertyNode::HasReferenceFilter()` sobre el `state_.filter` de la 128.
- 51d0892240f1 elementos dentro de contenedores SVG ocultos no reciben foco (`RestrictTabFocusForHiddenSVGElements`);
  `SupportsFocus()` es `bool` en la 128.
- ba96d51e → 77ab8bb83726 + 97e135f47abc `letter-spacing` no se aplica en escrituras cursivas (árabe, siríaco, N'Ko,
  mongol…; `IgnoreLetterSpacingInCursiveScripts`), con el espaciado `float` de la 128.
- **No portados:** 1f5acb16b48e (herencia de prioridad de `scheduler.yield` entre marcos): FlyWeb no tiene
  `SchedulerTaskContext`, es decir, **no tiene la herencia de `scheduler.yield`** (S: escape de un nivel anterior; mirar
  en el 139 qué nivel la trajo). 9b98a818d86d (popover): su autor dice que no es observable. 1c066c83 y 3a7a9069
  (rendimiento) y 0bc24ff1 (`LayoutIsAnonymousBlockFix`, refactor de layout, 9 rechazos): fuera de esta tanda.
- **Textarea (`TextareaLineEndingsAsBr`, `TextareaMultipleIfcs`): no son encendidos**, son la reescritura interna del
  textarea (~15 commits, 8cd6ad61d → 47cec2cbb). Propuesta a COORDINACIÓN-24 (02-11): «Aplazado del 138».
- `fuera.py --ref 138.0.7204.185`: 0 avisos (22 parches); `chk128.sh` 15/15 y 9/9; `api128.sh 17a21921`: 0 avisos.

### Aplazado del 138 (COORDINACIÓN-24, 02-11; sin 2.7.1)

Van al principio del 139 (2.8.0), como lo aplazado del 137 en esta. Sin 2.7.1, porque las 2.N.x solo salen por una
regresión o un KEV. La 2.7.0 declara 138 de todos modos: es CSS nuevo con alternativa y no cambia la huella de red
(precedente: RubyLB en el 128). `motor-138.html` no prueba estas tres.
- **`sibling-index()`/`sibling-count()`** (`CSSSiblingFunctions`, `CSSSiblingFunctionsInContainerQueries`): 64 commits
  (8b1026ab8, 18-11-24 … d51435dc8 y el reland 15ce3aa27, 26-05-25), ~2 000 líneas sin pruebas. Incluye refactors de
  `CSSPrimitiveValue` (fuera `GetFloatValue`, `GetIntValue`, `ComputeDotsPerPixel`; `DoubleValue` solo con calc
  resolubles). Solo el commit base da 12 rechazos en 10 ficheros sobre la 128. Lista con tamaños:
  `FlyWeb/tools/port/nivel138-sibling.tsv`. Estimación: 8–12 h. Regla 17: invalidación de estilo.
- **`stretch`** (`LayoutStretch`, `LayoutFlexNewStretch`): unos 15 commits de layout (79360f335 separa Stretch de
  FillAvailable, 5269fcdb7, 8e4d4b2a8, 1df0736d5/38883a97b abspos, 56092706c, el flip); empieza antes de nov-24
  (9ae24680f, 4287aedae). Encontrarlos: `git log --grep=stretch` y quitar el ruido de vistas/GPU.
- **`CSSAlignBlockAndInlineOutOfFlows`** con `LayoutJustifySelfForBlocks` (babd2b646 lo quita del 137; 25bf90a44,
  4ada5a818, db5b93af2). Estimación de los dos bloques: 6–10 h.

## Para LOCAL: dependencias y args nuevos del 138

V8 13.8.258.30 no compila con solo los parches de brave-core: hacen falta estos tres pasos en el árbol de la 128 (en
tu guion de Release; `FlyWeb/scripts/build.sh` los hace igual, pero no es el que usas para la 2.x).

1. **dragonbox** (nuevo; lo incluye `v8/src/numbers/conversions.cc`). El `BUILD.gn` y el `README.chromium` los pone
   brave-core (`patches/third_party-dragonbox-*.patch`); el código hay que traerlo a `src/third_party/dragonbox/src`:
   ```
   mkdir -p src/third_party/dragonbox/src && cd src/third_party/dragonbox/src && git init -q
   git fetch --depth 1 https://chromium.googlesource.com/external/github.com/jk-jeon/dragonbox.git 6c7c925b571d54486b9ffae8d9d18a822801cbda
   git checkout -q --detach FETCH_HEAD
   git ls-files -z include LICENSE-Apache2-LLVM LICENSE-Boost | LC_ALL=C sort -z | xargs -0 shasum -a 256 | shasum -a 256
   ```
   Suma esperada: `2a863ef8d1e6fedaab2fce779ff93c59a22b19d88d4bbf9fd41c740536453dec` (también en brave-core
   `FlyWeb/dragonbox-revision`). Si no cuadra, parar.
2. **simdutf 7.0.0**: nada que traer; los `patches/third_party-simdutf-*.patch` de brave-core ya llevan la 7.0.0
   (Chromium `third_party/simdutf` 9d3e4d7c). Si tu árbol tiene un `src/third_party/simdutf` de la 6.4.0 con cambios
   locales, `apply_patches` lo pisa; comprobar después `grep SIMDUTF_VERSION src/third_party/simdutf/simdutf.h` = 7.0.0.
3. **Arg de gn nuevo:** `v8_enable_temporal_support=false`. Sin él, gn pide `//third_party/rust/temporal_capi`, que la
   128 no tiene, y `gn gen` falla. Chrome 138 no expone Temporal.

Los demás args, como en la 2.6.1. Primera prueba: además de lo de siempre, una página con worker, un audio worklet y
un service worker (S del apartado «Blink frente a la API de V8 13.8»).

## Para la web

- Al escribir un espacio al principio de una línea partida en un cuadro de texto, el espacio aparece donde está el
  cursor y no al final de la línea anterior.
- Redimensionar un cuadro de texto con el tirador sigue al ratón aunque la página esté ampliada, girada o en
  escritura de derecha a izquierda.
- Las funciones de CSS `progress()`, `abs()` y `sign()`, como en Chrome 138.
- `window.viewport.segments` (pantallas plegables; en el ordenador, un solo segmento).
- `QuotaExceededError` es ahora un tipo de error propio, que indica cuánto espacio había y cuánto se pidió.
- Las webs pueden exigir que todos sus scripts lleven comprobación de integridad (`Integrity-Policy`): FlyWeb bloquea
  los que no la lleven, como Chrome 138.
- Al copiar, ya no se copia el texto que la página marca como no seleccionable.
- La unidad CSS `ch` vuelve a medir media letra cuando la fuente no tiene «0» (antes salía cuatro veces mayor).
- En árabe y otras escrituras cursivas, el espaciado entre letras ya no rompe las uniones.
- La subida automática a HTTPS del contenido mixto (imágenes, audio y vídeo) usa el mismo criterio que el bloqueo.
