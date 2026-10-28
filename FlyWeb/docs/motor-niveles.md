# Motor: lo hecho en cada nivel (117–131)

Sacado tal cual de `motor.md` (OR.1, 21-10-2026, `docs/herramientas/separar-historial.py`): es historial; el método vigente sigue en el original.

## Nivel 117 — cumplido (04-10, FlyWeb 1.1)

- **CSS que la 116 ya tenía apagado** (paso 46): `LayoutNGSubgrid`, `CSSInitialPseudo` (`@starting-style`),
  `CSSTopLayerForTransitions` (`overlay`), `CSSTextWrapPretty`, `CSSContainIntrinsicSizeAutoNone`; y `light-dark()`
  (de la 123) abriendo el `-internal-light-dark()` de la 116.
- **`transition-behavior`** (paso 48): **no estaba en la 116** (LOCAL, 04-10); el flag `CSSTransitionDiscrete` de la 116
  era una versión previa sin la propiedad. Portados 3 commits; aplicaron tal cual.
- **Arreglos posteriores a la 116** de lo encendido (paso 49): 6 de subgrid (+1 previo necesario), 1 de
  `@starting-style`, 2 de `text-wrap: pretty`. Lista: `motor-117-cambios.txt`.
- **JavaScript:** `Object.groupBy` y `Map.groupBy` con parches de V8 (`patches/v8/`): el flag pasa a «shipping» sin
  `groupToMap`, con el arreglo de la 11.7 para objetos grandes y (paso 49, LOCAL) la implementación real de
  `Map.groupBy`, que en la 11.6 era un esqueleto. Los iterator helpers siguen apagados (Chrome los publicó en la 122).
- **Versión declarada: 117**, a todas las webs (sin la excepción de Google, apagada por defecto en el paso 47). Siguen con 116 la red
  del sistema (componentes, actualizador, Safe Browsing).
- **Coste real del nivel 117:** 5 flags + 1 porte pequeño (`light-dark()`) + 1 porte de V8 + 1 porte de 3 commits + 10
  arreglos. Todo aplicó sobre la 116 sin reescribir nada: buena señal para los niveles 118–120.
- **Comprobación:** `FlyWeb/tools/motor-117.html` y las web-platform-tests enlazadas en la página.
- **Subfunciones (FM.8, `nube/motor-117` bf7c3bcf):** `font-variant-position`, `URLSearchParams.has()`/`delete()` con valor
  y `<mtd columnspan/rowspan>` de MathML. **Excepción:** `Intl.PluralRules` con `roundingMode` es de V8 (c63522b, un
  refactor de `Intl.NumberFormat`): **descartada** en el 117 (HUMANO, 06-10); llega con la V8 11.8 del nivel 118.

## Nivel 118 (hecho en código, 05-10; pendiente de compilar y probar → FlyWeb 1.2)

Lo Baseline que Chrome 118 publicó (web-features): **unidades `cap` y `rcap`**, el elemento **`<search>`** y los valores
**`content-box`/`border-box`/`stroke-box` de `transform-box`**. La V8 11.8 no añade nada Baseline. Ninguna estaba en la
116 ni siquiera tras un flag.

- **`cap`/`rcap` y `<search>`** (brave-core `nube/motor-118` 8459f579, paso 53): 6 commits de Chromium que aplican tal cual (a
  mano solo la entrada del flag de `<search>`). La altura de mayúsculas sale de `FontMetrics::CapHeight()`, que ya está
  en la 116.
- **`transform-box`** (7a6ab191, paso 54): el commit (673794805ffa) se apoya en la serie de refactorización de transformaciones de
  SVG de las semanas siguientes a la rama de la 116, así que se porta la serie entera: **13 commits**, 70 ficheros, 2
  nuevos (`transform_utils`, `paint_order_array.h`). Cuatro trozos resueltos a mano, solo de contexto. Los ficheros de
  SVG quedan idénticos a Chromium. Es el **porte más grande hasta ahora** y el de más riesgo: toca el pintado de SVG.
- **Declarado 118 / FlyWeb 1.2** en 86a2c9da (paso 55; se revierte solo si no pasa).
- **Comprobación:** `FlyWeb/tools/motor-118.html` (15 comprobaciones; en Chromium 141 todas «ok» salvo la del UA) y
  `FlyWeb/tools/wpt-118-lista.txt` con las herramientas de LOCAL. **Además**, por el riesgo del SVG: `motor-117.html` sigue
  14/14 y un repaso de webs con mucho SVG (iconos, gráficos, mapas).
- **Subfunciones (FM.8, fb0feba6):** `float`/`clear` con `inline-start`/`inline-end` (`CSSLogical`), líneas base de
  `TextMetrics`, `hasUAVisualTransition` en `PopStateEvent`/`NavigateEvent` y `crossOrigin` en `<image>` de SVG.
  `Intl.PluralRules` con `roundingMode` viene en la V8 11.8.
- **Prueba de LOCAL (05-10):** 0 errores de compilación; WPT 71/73. Los 2 fallos (`cap`/`rcap` en
  `font-relative-units-dynamic.html`) salen porque falta la fuente Ahem instalada en el sistema: Chromium 141 de serie
  falla lo mismo sin ella y pasa con ella. Las WPT necesitan Ahem en `~/Library/Fonts` (`wpt-app.sh` lo comprueba).
  Confirmado por LOCAL (17:10): con Ahem, 73/73.
- **118 bueno (LOCAL, 05-10):** `ideographicBaseline` daba -39 (Chrome 118: 6.25): faltaban las líneas base de la tabla BASE
  de la fuente (b14d2ed1, para la 1.2.1). Los 2 fallos de compilación de FM.8 están arreglados en 9c0e99de/b14d2ed1.

## Nivel 119 (en código, 05-10; pendiente de compilar → FlyWeb 1.3)

Lo Baseline que Chrome 119 publicó (web-features): `:user-valid`/`:user-invalid`, las cajas de `clip-path`
(`<geometry-box>`), `rect()`/`xywh()`, `Promise.withResolvers`, la **Storage Access API** y, en WebAssembly, **Wasm GC**
y referencias tipadas a funciones.

- **`clip-path` con cajas y `rect()`/`xywh()`** (brave-core `nube/motor-119` 96f274f3): 12 commits de Philip Rogers y uno
  previo de Fredrik Söderquist. **Adaptado a mano:** entre la 116 y estos commits, Chromium pasó `ComputedStyle` y
  `ClipPathOperation` al recolector de basura (f126ce4d6c9, cientos de ficheros); se mantiene el modelo de la 116
  (recuento de referencias) en la operación nueva y en el conversor de estilos, y se adaptan dos nombres de la API de
  cajas. **El porte de más riesgo hasta ahora.**
- **`:user-valid`/`:user-invalid`** (f58ee342): 3 commits, limpios salvo la plantilla del *fuzzer* de CSS.
- **`Promise.withResolvers`** (978fbf70, V8): adaptado a la 11.6 sin tocar las raíces estáticas de V8 (que se generan al
  compilar): `"promise"` se crea al arrancar en vez de ser una raíz nueva; flag *harmony* encendido. Comprobado que no
  es un esqueleto. La rama lleva también el arreglo de `Map.groupBy` de LOCAL (paso 49), por tocar los mismos ficheros.
- **Fuera del nivel (decisión del HUMANO, 05-10):**
  - **Storage Access API:** deja que un tercero incrustado pida acceso a sus cookies; Brave la desactiva a propósito
    (`kPermissionStorageAccessAPI`) por chocar con el bloqueo de cookies de terceros de los Escudos. **Fuera por
    privacidad, definitivamente.**
  - **Wasm GC y referencias tipadas a funciones:** WebAssembly solo funciona en los sitios con JIT; portarlo de V8 11.9 a
    la 11.6 es enorme y encender el `--experimental-wasm-gc` de la 11.6 metería una especificación antigua.
    **Aparcado:** se revisa si una web importante lo exige o si en algún momento se actualiza V8 entero.
- **Comprobación:** `FlyWeb/tools/motor-119.html` (17 comprobaciones; en Chromium 141, 16 «ok» y la del UA) y
  `FlyWeb/tools/wpt-119-lista.txt`.
- **Declarado 119 / FlyWeb 1.3** en 625b048e (paso 59; se revierte solo si el nivel no pasa).
- **Subfunciones (FM.8):** ninguna propia; las de colores relativos van con el nivel 125 (principio 12).

## Nivel 120 (en código, 05-10; pendiente de compilar → FlyWeb 1.4)

Lo Baseline que Chrome 120 publicó (web-features): `:dir()`, las funciones exponenciales de CSS, las máscaras sin
prefijo, el nesting relajado, `@media (scripting)`, `URL.canParse`, `<details name>` y `ToggleEvent`. Rama brave-core
`nube/motor-120` (encima de `nube/motor-119`); pasos provisionales 61–66 de `integracion.md`.

- **`@media (scripting)`, `URL.canParse` y `pow()`/`sqrt()`/`hypot()`/`log()`/`exp()`** (aada2fed): las funciones
  ya estaban en la 116 tras un flag; las otras dos, portes pequeños.
- **`<details name>` y `ToggleEvent`** (25297478): 7 commits; arrastra `MutationEventSuppressionScope`. Se quita un
  DCHECK que depende del orden de clonado del DOM de la 117 (no portado).
- **Nesting relajado** (cfd746e3, `CSSNestingIdent`): 11 commits. Sin `@scope` anidado, que no es Baseline.
- **`:dir()`** (6aa53e03): la reescritura de la herencia de `dir=auto` de David Baron (17 commits, con dos previos
  que no salían al buscar por `:dir`: el cambio de nombre `*DirAttributeDirty` → `*HasDirAttribute` y la retirada de
  `ParserDidSetAttributes`). El código de direccionalidad queda **igual al de Chrome 120.0.6099.234**.
- **Máscaras sin prefijo** (b4894ccb, `CSSMaskingInterop`): 25 commits, de los alias `-webkit-mask-*` a `mask-mode`.
  **El porte de más riesgo del nivel:** `background-repeat` pasa de atajo de `-x`/`-y` a propiedad normal (como en
  Chrome 120) y cambia el pintado de fondos y máscaras. Adaptado a mano: `CSSImageValue` sin `CSSUrlData`, un
  `LayoutSVGResourceMasker::CreatePaintRecord()` sin contexto junto al de la 116, y la API de `StyleImage` de la 116.
  Fuera: ca90c03d6ffe (un fallo antiguo de `-webkit-mask-box-image` en varias líneas, que depende de
  `box-decoration-break`).
- **Sin cambios en V8:** `kFlyWebCacheEpoch` se queda en 3 (lo subió el nivel 119, ef097366).
- **Comprobación:** `FlyWeb/tools/motor-120.html` (24 comprobaciones; en Chromium 141, 23 «ok» y la del UA) y
  `FlyWeb/tools/wpt-120-lista.txt` (46 ficheros). Los `.any.js`/`.window.js` necesitan su `.html`:
  `wpt-envolver.py <raíz de wpt>` los crea como wptserve antes de `python3 -m http.server`.
- **Declarado 120 / FlyWeb 1.4** en 2b57270e (paso 66; se revierte solo si el nivel no pasa).
- **Subfunciones (FM.8, aa62a9d7):** `IntersectionObserver` con `scrollMargin` (adaptado a la geometría de la 116; sin
  el arreglo de scrollers anidados 569bff082e2b, que pide una `RootAndTarget` más nueva: con `scrollMargin` no se usan
  rectángulos en caché; sin él, nada cambia) y `document.fonts.check()` según la spec nueva. El atributo `mask` de SVG
  ya vino con las máscaras. Puede que `scroll-margin-nested.html` de WPT no salga igual que en Chrome 120.

## Nivel 121 (en código, 05-10; pendiente de compilar → FlyWeb 1.5)

Lo Baseline que Chrome 121 publicó (web-features): `Array.fromAsync`, `scrollbar-color`, `scrollbar-width`,
`::spelling-error`/`::grammar-error` con sus decoraciones de texto y `ClipboardItem.supports()`. Rama brave-core
`nube/motor-121` (encima de `nube/motor-120`).

- **V8 12.1.285.28** (V8 1fbb9881419d; el cambio de versión en brave-core es 9f5634b2; la V8 de Chrome 121): trae
  `Array.fromAsync` de serie. `patches/v8/` rehechos sin conflictos; `chromium_src/v8` de Brave 1.62.166.
  **Corrección (LOCAL de la 1.5, 06-10):** no era cierto que no quitara API pública: la 12.1 convierte 21
  `v8::Isolate::UseCounterFeature` en `kOBSOLETE_*` y elimina `v8::TypedArray::kMaxLength`, que Blink 116 usa
  (`use_counter_callback.cc`, `image_data.cc`, `shape.cc`, `gpu_buffer.cc`, `drawing_buffer.cc`). Arreglado por LOCAL
  (f1cd46f0), junto con dos fallos del porte de `scrollbar-color` (452d297d: no compilaba en la 116 y una
  desreferencia nula con `@keyframes { scrollbar-color: … }`). Integrado en `nube/motor-121` 4a8c006f y hacia arriba.
- **`::spelling-error`/`::grammar-error`** (4921ff33): el flag ya estaba en la 116; se portan 2 arreglos
  (e9b876697fb1, 477ebb6082da) y se enciende. Fuera la fusión de flags (3981da4f277e, limpieza).
- **`scrollbar-color`/`scrollbar-width`** (ead38049): 11 commits; el primero (4ef69ea532dc) es justo la
  implementación en Mac. Fuera lo que no se compila para Mac (temas Aura/Fluent/views, barras de Android). El pintado
  de Mac queda como en Chrome 121.
- **`ClipboardItem.supports()`** (001ac937): 2 commits.
- **Comprobación:** `FlyWeb/tools/motor-121.html` (11 comprobaciones; en Chromium 141 fallan, como deben, la del UA y
  la de *iterator helpers* apagados) y `FlyWeb/tools/wpt-121-lista.txt` (29 ficheros).
- **Declarado 121 / FlyWeb 1.5** en 509bd3a3.
- **Subfunciones (FM.8, 58086979):** opciones nuevas de `checkVisibility()` (`contentVisibilityAuto`, `opacityProperty`,
  `visibilityProperty`), números en `hsl()`/`hwb()` con la sintaxis moderna (escrito para el parser de colores de la
  116) y `@import … supports()` con `CSSImportRule.supportsText` (el análisis queda en *experimental*, como en Chrome
  121; lo enciende el 122).

## Nivel 122 (en código, 06-10; pendiente de compilar → FlyWeb 1.6)

Lo Baseline que Chrome 122 publicó (web-features): **métodos de iteradores** (*iterator helpers*: `Iterator.prototype.map`,
`filter`, `take`…) y **métodos de `Set`** (`union`, `intersection`, `difference`…), los dos de serie en la **V8 12.2**, y
las subfunciones de la lista de abajo. Rama brave-core `nube/motor-122` (encima de `nube/motor-121`).

- **V8 12.2.281.22** (8bbb2971; la de Chrome 122.0.6261.128, base también de Brave 1.63): `patches/v8/` rehechos desde la
  12.1 sin conflictos; `chromium_src/v8` de Brave 1.63 igual que el de la 1.62. La 12.2 quita
  `V8InspectorSession::CommandLineAPIScope`: `InspectorPageAgent::EvaluateScriptOnNewDocument()` evalúa con
  `V8InspectorSession::evaluate()`, como Chromium 122 (solo DevTools). Los parches de seguridad de V8 los rehace SEGURIDAD
  cuando se vaya a publicar (FS.4), Maglev apagado incluido.
- **Subfunciones (FM.8, cd251be0):** herencia de `::backdrop` desde su elemento (adaptada al `StyleResolver` de la 116),
  `URLPattern.hasRegExpGroups`, `rgb()` con números y porcentajes mezclados en la sintaxis moderna (escrito para el
  parser de la 116) y `@import … supports()` encendido.
- **Excepción del nivel (HUMANO, 06-10: se publica sin ella y se porta aparte, tarea FM.9):** `align-self`/`justify-self` en cajas con posición absoluta
  (d5e6d59db47c, `LayoutAlignForPositioned`). `ng_absolute_utils.cc` de la 116 y la base de ese commit difieren en unas
  640 líneas (refactors de por medio, anchor positioning entre ellos), y toca el posicionamiento absoluto, que usan casi
  todas las webs: es un porte grande y de riesgo, no de un día.
  **Portado aparte (FM.9, 06-10):** brave-core `nube/abspos-align` 0bb9d3bf (desde `nube/motor-122`), fusionado en
  `nube/motor-123` (3aa4f33e): **llega con la 1.7**; la 1.6 sale sin ella. Escrito de nuevo sobre la 116, sin el
  «inset-modified containing block» de Chromium: con los dos insets puestos, la alineación decide qué inset absorbe el
  espacio libre (`center` lo reparte; `safe` vuelve al inicio si no cabe); solo `normal`/`stretch` estiran un tamaño
  `auto`; las tablas se estiran con `stretch` explícito. Flag `LayoutAlignForPositioned` en `stable` (si da problemas,
  se apaga sin recompilar con `--disable-blink-features=LayoutAlignForPositioned`). Fuera: elementos reemplazados con
  `stretch` explícito. Riesgo: toca el posicionamiento absoluto; con alineación `normal` (casi todas las webs) el
  resultado es el de antes.
- **Fuera (no Baseline):** Storage Buckets y lectura de portapapeles sin sanear (solo Chrome). Los colores relativos en
  `rgb()`/`oklab()`/`oklch()` van al nivel 125.
- **Comprobación:** `FlyWeb/tools/motor-122.html` (10 comprobaciones; en Chromium 141 todas «ok» salvo la del UA) y
  `FlyWeb/tools/wpt-122-lista.txt` (8 ficheros; los 2 de `css-align/abspos` fallan en la 1.6 y pasan desde la 1.7, FM.9).
- **Declarado 122 / FlyWeb 1.6** en 667d367b (se revierte solo si el nivel no pasa).

## Nivel 123 (en código, 06-10; pendiente de compilar → FlyWeb 1.7)

Baseline de Chrome 123 (web-features 3.40.1 + flags que pasan a `stable` entre la 122 y la 123.0.6312.122). Rama brave-core
`nube/motor-123` (encima de `nube/motor-122`).

- **API pública de V8 contra Blink 116 (revisión de NUBE, 06-10, pedida por LOCAL):** comparando `include/` de V8
  12.1 → 12.2 → 12.3 con Blink, gin, content, extensions y pdf de la 116. Hay un fallo nuevo:
  `remote_window_proxy.cc` sigue llamando a `TracedReference::SetWrapperClassId()`, que la 12.3 quita. Se arregla
  en 9d7603cb, igual que Chromium 122. Lo demás ya estaba resuelto o no rompe nada:
  - `CommandLineAPIScope` (122), los *wrapper class ids* de `thread_state.cc`/`wrapper_type_info.h` y
    `SetWasmGCEnabledCallback` (123) ya estaban resueltos.
  - `SafeForTerminationScope`, `GetImportAssertions()` y `SetAccessor` con `AccessControl` siguen existiendo, marcados
    como obsoletos.
  - Los métodos de `v8::Platform` dejan de ser virtuales, pero gin de la 116 ya implementa los `*Impl`.
  - `Value::IsTrue/IsFalse` y `Local` solo cambian de sitio.
  - La 12.2 y la 12.3 no marcan más `UseCounterFeature` como obsoletos.

- **V8 12.3.219.16** (053fff59): `patches/v8/` rehechos desde la 12.2 sin conflictos; trae de serie los módulos JSON con
  `with` (import attributes; Blink 116 ya cargaba módulos JSON). La 12.3 quita dos API que usa Blink 116: los *wrapper
  class ids* de `TracedReference` (porte de Chromium 15fcb656b756 adaptado a `thread_state.cc`) e
  `Isolate::SetWasmGCEnabledCallback()` (se quita el *callback*; Wasm GC sigue los flags de V8, como en Chrome 123).
  `chromium_src/v8` de Brave 1.64 igual que el nuestro.
- **`CSSKeyframesRule.length`, `shadowRootDelegatesFocus` en `<template>` y `navigation.activation`** (207ebea0): el
  último toca `content/` (controlador de navegación) y el mojom de restauración de entradas.
- **`paint-order` en texto HTML** (7738bc04): el commit final de Chromium sobre el pintado de texto de la 116, sin los
  dos refactors de SVG previos.
- **`field-sizing`** (142ecbad): 10 commits; `DefaultIntrinsicContentBlockSize()` y `ApplyControlFixedSize()` escritos
  para la 116.
- **`align-content` en bloques** (9b582742): bloques, celdas de tabla, multicolumna y la excepción de `ruby-text`. La
  serie cruza el cambio de nombres de Chromium (`ng_`/`NG*`), así que la parte de tablas y multicolumna está escrita a
  mano. **El porte de más riesgo del nivel** (layout de bloques): si una web descuadra contenido vertical, mirar aquí.
- **`light-dark()`** ya entró en el nivel 117 (e50b83ff).
- **`zstd`: excepción del nivel (HUMANO, 06-10).** Un servidor solo manda zstd si el navegador lo anuncia en
  `Accept-Encoding`; FlyWeb no lo anuncia y recibe gzip o brotli. Portarlo metería una librería nueva en el checkout.
- **Alineación de cajas con posición absoluta** (excepción del 122, FM.9): fusionada aquí, 3aa4f33e.
- **Fuera (no Baseline):** CSS modules, Long Animation Frames, rutas estáticas de Service Worker, `text-spacing-trim`.
- **Comprobación:** `FlyWeb/tools/motor-123.html` (10 comprobaciones; en Chromium 141 todas «ok» salvo la del UA) y
  `FlyWeb/tools/wpt-123-lista.txt` (12 ficheros).
- **Declarado 123 / FlyWeb 1.7** en 372b2b1c (se revierte solo si el nivel no pasa).

## Nivel 124 (en código, 07-10; pendiente de compilar → FlyWeb 1.8)

Baseline de Chrome 124 (web-features y `@mdn/browser-compat-data`, funciones con `chrome: 124` que también tienen Safari
y Firefox). Rama brave-core `nube/motor-124` (encima de `nube/motor-123`). HUMANO (07-10): abrirlo ya, para ir dos
niveles por delante, y **seguir subiendo V8 nivel a nivel**.

- **V8 12.4.254.15 + ac8da461** (f75d5441). Antes de portar se comparó la API pública con Blink 116: la 12.4 parece
  quitar mucho, pero los interceptores siguen (obsoletos) y `TaskRunner::PostTask` sigue siendo virtual. Rompen solo
  tres cosas: `MeasurementComplete`, `CreateSyntheticModule` y los datos de continuación (del `Context` al `Isolate`).
- **`setHTMLUnsafe`/`parseHTMLUnsafe`** (449020f7).
- **Shadow DOM clonable** (d74c4b35): portado **a mano**, porque la serie de upstream (7 commits) se apoya en
  `NodeCloningData` y `serializable`, que la 116 no tiene. Se escribe el comportamiento ya publicado tras la flag
  `ShadowRootClonable` (apagada = comportamiento de la 116).
- **`RTCRtpReceiver.jitterBufferTarget`** (c50e033b).
- **Iteración asíncrona de `ReadableStream`, nativa** (2efbb747; HUMANO: nativo, no polyfill, para que funcione también
  en los workers). La 116 no sabía generar `async iterable`: se porta el soporte del generador de bindings de la 124 al
  diseño de la 116, en el que el iterador cuelga de su interfaz como `SyncIterator`. Probado en la nube ejecutando el
  generador de la 116 (`FlyWeb/tools/bindings/`): solo cambian los bindings de `ReadableStream`. Deja la base hecha
  para las próximas API con `async iterable`.
- **`fetch()` con `signal.reason`** (2440af93): MDN da `AbortSignal.timeout()` como parcial hasta Chrome 124, porque
  `fetch` rechazaba siempre con `AbortError`.
- **Controles de formulario verticales: excepción del nivel (HUMANO, 07-10)**, portados aparte en `nube/form-vertical`
  (FM.12) y fusionados en el nivel en que LOCAL los pruebe. En la 116 la parte de controles no textuales está tras una
  flag experimental y la de `input`/`textarea` no existe; toca el pintado nativo de todos los formularios, también los
  horizontales, y solo se puede comprobar a la vista en Mojave. **Portado en `nube/form-vertical` f553e5d7** (19 commits de
  upstream; se dejan fuera los avisos de `appearance`, los contadores de uso y el cursor en elementos vacíos, que
  necesita refactors de layout). Página: `FlyWeb/tools/formularios-verticales.html`.
- **Fuera (no Baseline):** `pageswap`, `writingSuggestions`, WebSocketStream, `inert` en la búsqueda.
- **Comprobación:** `FlyWeb/tools/motor-124.html` (10 comprobaciones; en Chromium 141 todas «ok» salvo la del UA) y
  `FlyWeb/tools/wpt-124-lista.txt` (13 ficheros, con variantes `.worker`).
- **Declarado 124 / FlyWeb 1.8** en 94b58ec2 (se revierte solo si el nivel no pasa).

## Nivel 125 (en código, 07-10; pendiente de compilar → FlyWeb 1.9)

Baseline de Chrome 125 (web-features 3.40.1 y `@mdn/browser-compat-data`, con las subfunciones) y flags que pasan a
`stable` entre la 124.0.6367.207 y la 125.0.6422.141. Rama brave-core `nube/motor-125` (encima de `nube/motor-124`;
sesión NUBE-motor). **Sin excepciones.**

- **V8 12.5.227.13** (e99930b4; fbcea6ee, la de Chrome 125.0.6422.141). Antes de portar se comparó `include/` 12.4 → 12.5
  con Blink, gin, content, extensions, pdf y `chrome/renderer` de la 116 y con brave-core: solo quita
  `Function::GetUnboundScript`, `ScriptCompiler::CompileFunctionInContext`, `CopyablePersistentTraits` y ayudas internas
  de cppgc, que nadie usa (`Script::GetUnboundScript` sigue), y añade `StateTag::LOGGING` (el único `switch` tiene
  `default`). Los `V8_DEPRECATED` nuevos solo avisan (`build.sh` apaga esos avisos). La 12.5 trae de serie los
  **modificadores de RegExp** y los **grupos con nombre repetido** (Baseline del 125). Los parches de CVE-2024-5274 sobran:
  la 12.5.227.13 ya lo lleva. **SEGURIDAD:** la rama 12.5 tiene después tres fusiones de Wasm (12.5.227.14–16, bugs
  343772336, 343917751 y 342522151) que no van en la 125.0.6422.141: valorar si se traen.
- **`WebSocket` con URL `http(s)` o relativas** (5614554f).
- **`:state()`** (404c029a), con `:--foo` funcionando aún, como en la 125.
- **`round()`, `mod()`, `rem()`** (4b5734f9): en la 116 estaban tras una flag experimental; se traen el análisis de la
  estrategia de redondeo y `calc(NaN)` = 0 en el nivel superior.
- **`getHTML()` y raíces *shadow* serializables** (70be0dec), **a mano**: la serie de upstream (9 commits) reescribe el
  serializador (`ShadowRootInclusion`, `ContainerNode::getHTML`). Se añaden dos modos al de la 116. Como en la 125, las
  plantillas serializadas usan `shadowrootmode` en lugar del viejo `shadowroot`.
- **Colores relativos** (00cee7a7), **a mano**: la 116 no tiene `ColorFunctionParser` (la serie de upstream son ~15
  commits, con el cambio de almacenamiento del sRGB «legacy» a [0,255]). Ruta aparte para `función(from <color> …)` con la
  lógica de la 125 convertida a las unidades de la `Color` de la 116; los colores absolutos siguen por el parser de la
  116. Orígenes: colores absolutos, con nombre, `transparent` y `color-mix()` de absolutos (`currentcolor` no, igual que
  la 125).
- **Tipos de View Transitions** (bd02e804), **a mano** (en la 116 `ViewTransition` aún es el objeto de JavaScript; no hay
  `DOMViewTransition`): `startViewTransition()` sin argumento, con *callback* o con `{update, types}`,
  `ViewTransition.types` (`ViewTransitionTypeSet`), `:active-view-transition` y `:active-view-transition-type()`.
  **Importante para la compatibilidad:** con la 116, `startViewTransition({update})` (la forma de Safari 18.2 y Firefox
  144) lanzaba `TypeError` y **no ejecutaba el `update`**: la página no se actualizaba. Necesitó portar un cambio pequeño del
  generador de bindings de la 125 (un *callback* se distingue de un diccionario).
- **`view-transition-class`** (dfd53448), a mano: propiedad, `::view-transition-*(nombre.clase)` y la lista de clases en
  el capturador de estilos.
- Las partes entre documentos de esas funciones no entran: la 116 no tiene transiciones entre documentos (Chrome 126, no
  Baseline).
- **Fuera (no Baseline):** anchor positioning, Compute Pressure, Storage Access más allá de cookies, motivos de bfcache.
- **Comprobación:** `FlyWeb/tools/motor-125.html` (14 comprobaciones y un botón de transición a ojo; en Chromium 141 todas
  «ok» salvo la del UA) y `FlyWeb/tools/wpt-125-lista.txt` (21 ficheros, con variantes `.worker`).
- **Declarado 125 / FlyWeb 1.9** en a928a32b (se revierte solo si el nivel no pasa). Todos los parches de la rama
  aplican sobre la 116 (`chk.sh`: 1014 parches, solo el aviso conocido de `menu_separator`). Bindings comprobados con
  `FlyWeb/tools/bindings/`. Sin compilar.

## Nivel 126 (en código, 07-10; pendiente de compilar → FlyWeb 1.10)

Baseline de Chrome 126 (web-features 3.40.1 + BCD) y flags que pasan a `stable` entre la 125.0.6422.141 y la
126.0.6478.182. Rama brave-core `nube/motor-126` (encima de `nube/motor-125`). **Sin excepciones.** Nivel pequeño: lo
Baseline son `URL.parse()` y `toJSON()` en la geolocalización; el resto de lo nuevo del 126 (transiciones de vista entre
documentos, `CloseWatcher`, `sizes="auto"`) no es Baseline.

- **V8 12.6.228.49** (d3c410c8): la cabeza de la rama 12.6, es decir la V8 de Chrome 126.0.6478.182 (12.6.228.28) más
  las ~20 fusiones de seguridad posteriores de su rama (M126-LTS: TurboFan, Maglev, Wasm, el intérprete y el *sandbox*).
  **API pública 12.5 → 12.6 contra la 116** (Blink, gin, content, extensions, pdf, `chrome/renderer`, brave-core y,
  por primera vez, **PDFium**): rompen dos cosas. (1) `v8::TaskRunner::Post*Task` deja de ser virtual: gin pasa a
  sobrescribir `Post*TaskImpl` (Chromium bcd7d6bc1f5). (2) `ObjectTemplate::SetAccessor` con nombre `String` desaparece:
  `chrome.app.isInstalled` (Chromium a3ac89ff609) y las propiedades de JavaScript de los PDF (PDFium 71bd32dce, que ya
  va en la PDFium de Chrome 126), como parches nuevos en `patches/third_party/pdfium/`. Lo demás (`TracedReferenceBase::Get`
  devuelve `Local<Data>`, sobrecargas nuevas de `ReturnValue::Set`, `Utf8Value` con opciones) no afecta a la 116.
  **Ojo (LOCAL/SEGURIDAD):** los niveles 120–125 no revisaron PDFium; la revisión de hoy no ve usos de las API que
  quitaron, pero conviene que la compilación lo confirme.
- **`URL.parse()`** (d36f294b, Chromium d1db8ebec85).
- **`GeolocationPosition.toJSON()` y `GeolocationCoordinates.toJSON()`** (d36f294b, Chromium 733c562491c), escritos
  sobre las clases de la 116 sin el refactor de upstream ni tocar `v8_object_builder.h` (lo incluye medio Blink).
- **Comprobación:** `FlyWeb/tools/motor-126.html` (5 comprobaciones y un botón de geolocalización real; en Chromium 141
  todas «ok» salvo la del UA) y `FlyWeb/tools/wpt-126-lista.txt` (5 ficheros).
- **Declarado 126 / FlyWeb 1.10** en 20ecf145. `chk.sh`: 1030 parches aplican sobre la 116 (más los 4 de PDFium, comprobados sobre su PDFium). Sin compilar.

## Nivel 127 (en código, 09-10; pendiente de compilar → FlyWeb 1.11)

Baseline de Chrome 127 (web-features 3.41.0 + BCD 8.1.5, con las subfunciones) y flags que pasan a `stable` entre la
126.0.6478.182 y la 127.0.6533.144. Rama brave-core `nube/motor-127` (encima de `nube/motor-126` ae77b3e5; sesión
MOTOR-2). **Sin excepciones.** Lo que se porta lo decidió el HUMANO sobre el inventario de FM.15, que incluye también
lo descartado.

- **V8 12.7.224.20** (9c7bd80e): la cabeza de la rama 12.7 = la V8 de Chrome 127.0.6533.144 (12.7.224.18) más dos
  arreglos de seguridad (356196918 TurboFan, 360700873 Wasm). **El 127 no tuvo LTS** (FS.9). **API pública 12.6 →
  12.7 contra la 116** (Blink, gin, content, extensions, `chrome/renderer`, components, pdf, brave-core y PDFium
  6c2c8ce8): todo mecánico, ~16 líneas en 10 ficheros. `ScriptOrigin` pierde el constructor con `Isolate` (6 sitios de
  Chromium y `safe_builtins_helpers.cc` de brave-core); desaparecen `Isolate::SafeForTerminationScope` (4 usos en
  `v8_script_runner.cc`) y `only_terminate_in_safe_scope` (gin), `ObjectTemplate::SetIndexedPropertyHandler` (gin pasa a
  `SetHandler`) y `kGCTypeMinorMarkCompact` (`thread_state.cc`). `MicrotasksScope(isolate, tipo)` solo lo usan
  *unittests*; el `->` de `TracedReference`, `PersistentValueVector` e `IdleNotificationDeadline` no tienen usos; PDFium no
  usa nada de lo quitado. `chromium_src/v8` de Brave 1.68 solo añade dos `#include` bajo la flag de PageGraph (apagada).
  `patches/v8` rehechos con `v8re.sh` sin conflictos; **`kFlyWebCacheEpoch` → 5** (adc17adc: la 1.10 ya sale con 4). Lleva también los dos arreglos de compilación de LOCAL en la 1.10 (7e222b20): parches de PDFium aplicados (`flywebRepos`) y V8 sin Perfetto fuera de Linux (`gni-v8.gni.patch`; la 12.7 tiene la misma condición). Muy por debajo del criterio de
  parada del principio 11.
- **`font-size-adjust`** (1de1fd7e): en la 116 estaba tras `CSSFontSizeAdjust` (*test*) sin `from-font` ni `ic-height`.
  Serie de upstream hasta la 127 (16 commits): `from-font` y su valor resuelto en `getComputedStyle`, fuentes de
  reserva del sistema, `ic-width`/`ic-height` independientes de la orientación (métricas perezosas en
  `SimpleFontData`, escritas a mano), grosor del subrayado con el tamaño calculado, `saturated_cast` en `FontCacheKey`.
  **Fuera:** 539a017f9ed (`calc()` con unidades relativas al animar): necesita el `InterpolableNumber` con expresiones
  que la 116 no tiene; el `calc()` numérico sigue funcionando.
- **`selectionchange` en `input`/`textarea`** (3c87a851, Chromium 23e6216332d + f11b25d06a8): el evento llega al
  control y burbujea, también cuando `setSelectionRange()` solo cambia la selección en caché.
- **`integrity` en mapas de importación** (48721436, 18f9d2c2c61 + a6ec68885e0): SRI para módulos sin atributo
  `integrity` (`<script type=module>`, `import` estático y dinámico, `modulepreload`). Sin el refactor de
  `ConsoleLogger` → `ExecutionContext` ni el contador de uso.
- **Interoperabilidad (decisión del HUMANO, 1095239f):** `showPicker()` consume la activación (solo `input`: la 116 no
  tiene `select.showPicker()`), `beforeinput` en los botones de `input type=number` y al deshacer/rehacer sobre el
  elemento del paso, texto alternativo de `content` con varios argumentos (sin `CSSParserSavePoint`: copia del rango) y
  `::selection` sin invertir el fondo cuando el autor pone sus colores (en la 116 la inversión está en
  `NGHighlightPainter`). Las dos que se apartaron al principio por no ser baratas, **portadas después a petición del
  HUMANO (09-10):** `SvgFilterUserSpaceViewportForNonSvg` (b878f587, Chromium 24decde21a6, a mano: un `filter: url(#f)`
  en HTML o `<canvas>` con `filterUnits="userSpaceOnUse"` y porcentajes ya no se queda con región vacía; el *viewport* es
  la caja del borde, como en Gecko, o el tamaño del lienzo) y `TextDiffSplitFix` (639a7a71, faa6b2f5d67 + 1fb194ccced:
  `splitText()` solo avisa a `LayoutText` del trozo borrado; no necesitaba el refactor `TextDiffRange`, porque
  `SetTextWithOffset(texto, offset, longitud)` de la 116 es lo mismo que `TextDiffRange::Delete`).
- **Descartado (HUMANO):** constructores de `RTCEncoded*Frame` (van con su función, nivel 141), `position-anchor: auto`,
  lo no Baseline (`ChapterInformation`, `VideoFrame.copyTo` RGB, Protected Audience, No-Vary-Search) y las flags de
  View Transitions por árbol y concurrentes, barras con `color-scheme`, copiar sin `text-transform`, `justify`/bidi y
  serialización corta de `transition`.
- **Comprobación:** `FlyWeb/tools/motor-127.html` (11 comprobaciones y dos a mano: `::selection` y `beforeinput`; en
  Chromium 141 todas «ok» salvo la del UA) y `FlyWeb/tools/wpt-127-lista.txt` (35 ficheros).
- **Declarado 127 / FlyWeb 1.11** en f8087001. `chk.sh`: 1088 parches aplican sobre la 116 (solo el aviso conocido de
  `menu_separator`); cada `#include` nuevo existe en la 116 (c776bbf5 añade el que faltaba en `content_data.h`). Sin
  compilar. Aparcado mientras se compilaba la 1.10; **desaparcado por el HUMANO el 09-10** con sus arreglos fusionados
  (cabeza `nube/motor-127` **639a7a71**, con los dos portes de arriba).

## Nivel 128 — cumplido (14-10, FlyWeb 1.12.1; la 1.12 sin `ruby-align`, publicada el 13-10)

Baseline de Chrome 128 y flags que pasan a `stable` entre la 127.0.6533.144 y la 128.0.6613.194 (inventario de MOTOR-2 en
FM.16). Por decisión del HUMANO, el 128 va **sobre la V8 12.8** de FM.17: rama brave-core **`nube/motor-128`**
(**64545ca4**), rebasada por MOTOR-6 (13-10) sobre **`nube/v1.11.2` 56ed9d93** = `seg/v8-12.8` f8cbd8c9 (FM.17 + ronda de
seguridad de V8 12.8) + la huella de red de la 1.11.1 (`local/huella-127`) + `flyweb_version` 1.11.2. Antes estaba
apilada sobre `nube/v8-12.8-fase4` 493c8998 (MOTOR-4). **Sin excepciones** salvo lo que se anota abajo.

**Decisión del HUMANO (12-10, por COORDINACIÓN-4):** la **1.12 = nivel 128 sin `ruby-align`** (lo de
`nube/motor-128`; 84735505 declara 128 / 1.12), sin esperar a RubyLB. **RubyLB va por etapas** (R1…R5, abajo) en la rama
brave-core **`nube/motor-128-ruby`**, apilada sobre `nube/motor-128`, **un commit y un push por paso** (tras el rebase
de MOTOR-6: R1 d1ed7eff, R2 763bcc3c, R3a 7a4bf532; luego R3b 83f81e6c, R3c 99887213, R3d c6d4a354, R4–R5 1f490905;
cabeza **38ad8ed0**, con los arreglos de compilación de V8 12.8 de LOCAL-2 fusionados desde `nube/motor-128` 724e4c27). **La 1.12.1 es
RubyLB completo (R1–R5), publicado de una vez cuando esté estable**; LOCAL hace compilaciones intermedias después de R2
y después de R3 (R1 sola no se compila ni se publica; COORDINACIÓN-4, 13-10). **El nivel 129 no empieza hasta terminar
RubyLB.** Sin freno por el límite semanal.

- **V8 12.8.374.38**: llega con FM.17 (`Promise.try` viene de serie, sin porte).
- **`document.caretPositionFromPoint()`** (2922bcaa; feecdfbca29, 1b5fb86a995, 7d0dfc27610, 6635e2d6e41, 85e3baa70a3,
  439b835b5c0, eae54e1bf13): interfaz `CaretPosition` (`offsetNode`, `offset`, `getClientRect()`), diccionario
  `CaretPositionFromPointOptions` con `shadowRoots`, y en controles de texto devuelve el propio control. A mano las
  listas (`idl_in_core.gni`, `document.h`, `document.idl`, contador 4970, flag). La 116 tiene `NGCaretPosition`, así
  que no hace falta el cambio de nombre de upstream (2ce426b3a16).
- **`Element.currentCSSZoom`** (9590abf1; 6413e659bde + 4c05a0c8ccd): upstream la pone tras `StandardizedBrowserZoom`,
  que no se porta (cambia el modelo de zoom de todo el motor), así que se expone sin flag y se divide por
  `StyleResolver::InitialZoom()` para quitar el zoom del navegador, igual que 4c05a0c8ccd.
- **`aria-colindextext` / `aria-rowindextext`** (e6614bc4; d1d8fd04816 + ec7a2121a01): reflejo en `ariaColIndexText`/
  `ariaRowIndexText` y al árbol de accesibilidad (`StringAttribute` 39/40, `[MinVersion=4]` porque la 116 está en la
  versión 4).
- **Interoperabilidad** (flags a `stable` en el 128, medidas al portar):
  - Portadas: `SelectTypeToSearchIgnoreAccents` (75b93522, 04dbfcbf633: la búsqueda al teclear en `<select>` ignora los
    acentos), `HTMLMenuElementIsListOwner`, `KeepCSSTargetAfterReattach` y `SvgGradientColorInterpolationLinearRgbSupport`
    (b96fee3e, un sitio cada una), `ModifyParagraphCrossEditingoundary` (c5642ecb, a95016b950e) e
    `InlineCursorMultiColFix` (bdc358f6, 46e80444197, a mano: caída en multicolumna).
  - **Fuera por coste** (dependen de código posterior a la 116; varios commits cada una):
    `PreserveFollowingBlockStylesDuringBlockMerge`, `DropUrlAsPlainTextInPlainTextOnlyEditablePosition`,
    `HandleDeletionWithNonEditableContentAtBlockBoundary`, `LabelAndDelegatesFocusNewHandling` (el foco de la 116 usa
    `IsMouseFocusable`/`DelegatesFocus`), `CssDecoratingBoxFirstLine` (otra estructura de `InlinePaintContext`) y
    `CompositedAnimationsCancelledAsynchronously`.
  - **Sin efecto o sin interés:** `SelectOptionAccessibilityTargetSize` (en Mac `<select>` usa el menú nativo),
    `BreakIteratorSetStartOffset` (solo rendimiento), `AutomaticFullscreenPermissionsQuery` (no es de la web).
- **`ruby-align`: fuera de la 1.12; RubyLB en curso por etapas** (medición de MOTOR-4, 12-10). El HUMANO eligió el porte
  completo de la reescritura del ruby de upstream («RubyLB»). Entre la rama de la 116 (26-06-2023) y la de la 128
  (23-07-2024) hay **198 commits de ruby**, 125 con la etiqueta RubyLB. Sin pruebas y sin 4 actualizaciones de
  dependencias que se cuelan en la búsqueda: unos 175 commits con código, ~580 ficheros tocados, **+6800/−3400 líneas**.
  Los más antiguos son `display: ruby`/`ruby-text` (nivel 121), la «inlinificación» y los renombres. **Lo que encarece
  el porte no es el tamaño sino que casi todo cae en el núcleo del *layout* de línea** (`LineBreaker`, `InlineItem`,
  `LogicalLineBuilder`, justificación, `FragmentItem`, pintado y *hit-testing*). Entre la 116 y la 128 hay además **68
  commits que renombran ficheros y clases de `layout/ng/inline`** (`NGLineBreaker` → `LineBreaker`, `ng_line_breaker.cc`
  → `inline/line_breaker.cc`…), así que `portar.sh` no encuentra ningún fichero de la 116. Cada *hunk* hay que
  traducirlo de rutas y de nombres. **R0, decidido (MOTOR-4): no se portan los renombres** (serían 369 ficheros nuevos
  sin poder borrar los viejos y 209 más parcheados, 70 con parche nuestro); se usa el **traductor de diffs**
  (`FlyWeb/tools/port/ngmap.py`, `ngtraducir.py`, `portarng.sh`; README). Etapas, cada una compilable
  (LOCAL compila después de R2 y de R3; todo junto sale en la 1.12.1):
  - **R1** `display: ruby`/`ruby-text`: **en código** (MOTOR-5, 12-10), brave-core `nube/motor-128-ruby` **1e042ac6**,
    sin compilar. 16 commits de upstream: fff250bc61, 8e6792e47d, f47ea0a5a5, d1aceb95f2, e63c1d7cf2, bf262bd8d1,
    bdb9aad17f, 8b01cfed9a (`RubyContainer`), d4967df6da, f551901fad, 10fc889f33, 37da5ae3a9, e60ed2dd1a, 259c7e28f1
    (`display: block ruby` envuelve un `ruby` anónimo), b70e524a7f9 (*display lock*) y 58b8c97874 (fuera
    `BlockRubyConsoleMessage`). Flags `CssDisplayRuby`, `RubySimplePairing` y `BlockRubyWrappingInlineRuby` en `stable`.
    Adaptado a la 116: el analizador de `display` aún con `CSSDisplayMultipleValues`, sin alias
    `ConsoleMessage::Source`, `include` para `IsA<HTMLRTElement>` en `layout_object.h`, y `OriginalDisplay` (en la 116
    sigue siendo un campo `EDisplay`) con las mismas palabras clave que `Display` (`EDisplay` pasa a 6 bits; el tamaño
    de `ComputedStyle` no cambia). Comprobado con `chk.sh` y con los generadores de Blink (`gencss.sh`).
  - **R2** inlinificación: **en código** (MOTOR-5, 13-10), `nube/motor-128-ruby` **4f1ee98b**, sin compilar.
    62b922872d, 207a403ed2, d94ec8e798, 189fa20e6f, 988652b535 y 3748c5249f (los cuatro arreglos usan la
    inlinificación, por eso no van en R1), y la retirada de las flags `CssDisplayRuby`, `RubySimplePairing`,
    `RubyInlinify` y `BlockRubyWrappingInlineRuby` (f7690c6fbc, 7d0a83fd26, 88c8510c16d, 891de733b48): `<ruby>` y
    `<rt>` pasan a ser `HTMLElement` normales (estilo en `html.css`) y `display: block ruby` siempre envuelve un ruby
    anónimo. `html_rt_element.*`/`html_ruby_element.*` no se borran (los parches no borran ficheros): salen de
    `build.gni` y nadie los usa. Lo que upstream ya hacía depender de `RubyLineBreakable` (59564502ef3) queda para R3.
  - **R3** núcleo de RubyLB (5fa2b39df5 … 1786fbc146: tipos `kOpen/CloseRubyColumn`, `LineBreaker` anidados,
    `LogicalLineContainer`, líneas de anotación como `kLine` anidados, pintado, justificación): 1–2 semanas. **Riesgo
    alto: afecta a todo el texto.**
    **R3a en código** (MOTOR-5, 13-10, **e727339d**): flag `RubyLineBreakable` (apagada, como upstream hasta el R5),
    ítems `kOpen/CloseRubyColumn`, `SetInputRange()`, y `ComputeRubyEmHeightBox()` como envoltorio del
    `ScrollableOverflow(kEmHeight)` de la 116 en vez de portar cd1e15bd751/fe91db7955b/b40c24e2e02. Ensayo completo:
    104 commits, 251 hunks rechazados en 65 (lista y cifras en `FlyWeb/tools/port/rubylb-r3.tsv`).
    **R3 completo en código** (MOTOR-6, 13-10), sin compilar, en tres partes: **R3b 83f81e6c** (`LogicalLineBuilder`,
    columnas de ruby en `LineBreaker`, `LogicalLineContainer`, líneas de anotación como `kLine` anidados; más el
    requisito fb5131bcbd17, `NGLineInfo` `DISALLOW_NEW`, que no estaba en la lista), **R3c 99887213** (justificación,
    `ruby-align`, *overhang*, posición en bloque, `RubyPosition` over/under, `VttCueDisplayRuby` en `stable`) y
    **R3d c6d4a354** (columnas de ruby partibles entre líneas con `RubyBreakTokenData`, alineación en los bordes de
    línea, `RubyLineBreakable` y `RubyLineEdgeAlignment` en `experimental`). Saltados con motivo (en la lista y en los
    commits): f4181c2c74b y d6f2c593fcd (`InlineItemResult::ToString`, que la 116 no tiene), ae6d9d5db8f
    (`FasterMinContent`), 1094a4f126d (revertido en upstream por ebb948a6007: no portar el revert) y 99a722b4455 y
    5199d5afae9 (`text-box-trim`). Adaptaciones a la 116 más delicadas: `RareData` en `NGInlineBreakToken`
    (conserva el sub-token genérico de la 116), `BoxData` en `HeapVector` y la pila de cajas trazable sin `stack_`,
    `CommitPendingEndOverhang()` con la firma de la 116 (se llama después de `AddItem()`), y `absl::optional` donde
    la 116 lo usa. Comprobado con `chk.sh` (todos los parches aplican), `gencss.sh` (generadores sin fallos) e
    `idscan.py`. **Riesgo para R5:** las líneas de anotación son `kLine` sin `NGPhysicalLineBoxFragment`; revisar los
    usos de `LineBoxFragment()` de la 116 que upstream ya no tenía.
  - **R4** `ruby-align` (32f83cfafc, 4edb29252e, 24a2779462), alineación en los bordes de línea, heurística «short» y
    *overhang*: 2–3 días.
  - **R5** unos 60 arreglos de caídas y DCHECK de RubyLB: 2–3 días.
    **R4–R5 en código** (MOTOR-6, 13-10, **1f490905**), sin compilar: los 46 commits de ruby tras 1786fbc1466 (lista
    `FlyWeb/tools/port/rubylb-r45.tsv`; 24a2779462 ya entró en R3c), uno por paso: 38 portados y 8 saltados. Entran `ruby-align` (parseo,
    serialización y maquetación; flag `CssRubyAlign`; `CSSSampleId::kRubyAlign` = 795, como Chrome), `RubyShortHeuristics`
    (detección «corta» contando glifos), romper columnas de ruby desde `HandleOverflow()` con rebobinado, anotaciones con
    márgenes/bordes/relleno, `PaintLayer` de las anotaciones y arreglos de caídas. **Flags en `stable`:**
    `RubyLineBreakable`, `RubyShortHeuristics`, `RubyLineEdgeAlignment` y `CssRubyAlign` (como upstream en la 128).
    Saltados con motivo: la entrada de `about:flags` de 2bad9c8d19e (solo UI de Chrome; sí la flag de Blink),
    6f220af43ca (contadores de uso de `ruby-position: alternate | inter-character`), 81e6e9f8ee8 (icono de `alt`: la 116
    le pone `display`/`float` con estilo en línea antes de `StyleAdjuster`, que ya lo corrige con a91265e3868),
    8a35fc6c8e8 (anotaciones con `line-clamp` estándar, que la 116 no tiene) y el `NOINLINE` de Android de
    b1d0edbf7b9; además los revert/reland (ebb948a6007, c91684bd1bc, 092d9947202), 71b76b57de0 (solo pruebas) y
    edec8ed675e (*spanification*). Adaptaciones a la 116: el diff de estilo de `ruby-align` va en
    `computed_style_diff_functions.json5` (la 116 no tiene `invalidate:`), `CSSValueFromComputedStyleInternal` con 3
    argumentos, `ConsoleMessage` con los `mojom::blink::ConsoleMessage*` de la 116, el parámetro de plantilla
    `OffsetMappingBuilder` (upstream lo llama `MappingBuilder`) y `absl::optional`. Comprobado con `chk.sh`, `gencss.sh`
    e `idscan.py`. **Revisado el riesgo apuntado en R3** (líneas de anotación = `kLine` anidados con `LineBoxFragment()`
    nulo): los usos de la 116 o comprueban el nulo, o recorren solo el nivel superior (donde no hay anotaciones), o ya
    los adaptó R3 (pintado, *hit-testing*, contornos); el único resto era un `DCHECK_EQ(kBox)` en
    `AddScrollableOverflowForInlineChild()` (en *release* ya sumaba los hijos de la anotación), ajustado en 38ad8ed0.
    **Static de LOCAL-3 (13-10, sobre 21b44804): 20 errores en 7 objetos**, arreglados por MOTOR-7 en **f1b26d42** (dos
    `#include` que en la 128 llegan de rebote y `auto*` en iteradores, que en la 116 son punteros). **Static de f1b26d42: 0 errores, `motor-128` 9/9, WPT de
    `css-ruby` 110 iguales a Chrome 128, 1 mejor y 1 diferencia** (`line-spacing.html`), que arregla 1f0b377299b6. Con él,
    en **e420119c**, entran otros dos que la lista no tenía: ef8ddcab1d8e (caída; `Merged:` en la rama de la 128) y
    b877e3948a59 + 7e72ac335691 (`<rt>` sin `::first-letter`). **Lección para el 129+:** la lista de un porte grande se
    saca de `git log <tag N-1>..<tag N>` (incluye los `Merged:` de la rama del nivel) y por autor y fichero, no solo con
    `--grep` del nombre de la función.

  Las estimaciones son de antes de medir *hunks*. En R1, con el traductor corregido (MOTOR-5: no traduce los nombres
  que en la 116 son métodos, como `PhysicalFragment()`), se rechazaron 27 *hunks* de 16 commits, todos resueltos a
  mano uno a uno. Portar antes el renombre «ruby run» → «ruby column» (257af3736c2) no compensa: tiene 19 rechazos
  propios y solo quita 4. El resto del 128 no depende de RubyLB.
- **1.12:** Static de LOCAL-2 de `nube/motor-128` 710e7520 probado el 13-10 (0 errores, `motor-128` 9/9, webs 8/8 con
  YouTube, WPT iguales a Chrome 128 salvo dos de entorno); faltan el ASan, la Release y la entrega de LOCAL. «Para la
  web» en `version-1.12.md` (MOTOR-7, 13-10). Declarados 128 / 1.12 en `build/config.gni` (64545ca4), con
  `flyweb_engine_full_version` = **128.0.6613.138** (la última Stable normal de la 128 para Mac, 10-09-2024, como la
  .120 de la 127) y `flyweb_min_macos_version` 10.15.7. **Para cerrar el nivel 128:** RubyLB R1…R5 (1.12.1).
- **Cumplido (14-10):** la 1.12.1 (`nube/motor-128-ruby` **e6273d015** = 1.12 + RubyLB + e420119c + FS.11 + parte urgente
  de FS.12; 157.64.20) pasa `motor-128.html` 9/9 y las WPT del nivel: las 8 de `wpt-128-lista.txt` como Chrome 128 (con
  las dos diferencias de entorno de la 1.12) y las 113 de `css/css-ruby` con 112 iguales a Chrome 128 y 1 mejor, más las
  14 de `ruby-fs11/` de los arreglos de seguridad; ASan limpio (LOCAL-3). Entregada a PUBLICACIÓN.
- **Comprobación:** `FlyWeb/tools/motor-128.html` y `FlyWeb/tools/wpt-128-lista.txt` (8 ficheros; resultados en
  `version-1.12.md`). Para la 1.12.1, además, `FlyWeb/tools/wpt-128-ruby-lista.txt`: las WPT de `css/css-ruby` de la
  128 (97 *reftests* y 16 testharness) y `wpt-128-ruby-esperado.json` con lo que Chrome 128 falla (45 `[ Failure ]` de
  `TestExpectations` y los subtests de 4 `-expected.txt`). Se ejecutan con `FlyWeb/tools/wpt-ref.py` (MOTOR-7), que
  hace los dos tipos: captura a 800×600 con escala 1, como wptrunner, con `fuzzy`, y al final lista lo que difiere de
  Chrome 128. Probado en el contenedor con Chromium 141 en Linux: 106 de 113 iguales; las 7 diferencias son de Chrome
  141 (una revisada a ojo: un hueco real entre dos cajas). Las capturas dependen de las fuentes del sistema: para separar el entorno, pasar la lista también por la 1.12
  (sin RubyLB) y por el Chrome del mismo Mac.

## Nivel 129 (en código, 14-10, MOTOR-8; pendiente de compilar y de FS.13 → FlyWeb 1.13)

Inventario de FM.19, **para decidir COORDINACIÓN antes de portar**. Fuentes: web-features 3.42.0 + BCD 8.1.5
(`FlyWeb/tools/port/baseline-nivel.js`), flags de `runtime_enabled_features.json5` entre la **128.0.6613.194** y la
**129.0.6668.112** (cabeza de la rama 6668; `flags-nivel.py`) y la API pública de V8. Cada porte se midió aplicando
sus commits sobre la 116 + los parches de brave-core `nube/motor-128-ruby` **bb6c7146** (`medir.sh`; «hunks/rechazados»).
Las listas de commits salen de `git log 128.0.6613.194..129.0.6668.112` por fichero y por autor (con los `Merged:` de la
rama 6668) y, para lo anterior al 128, de `116.0.5845.188..129.0.6668.112`: `FlyWeb/tools/port/nivel129-commits.tsv`.

**Resumen: el 129 es un nivel pequeño.** Poco Baseline nuevo, ningún porte grande (el mayor, WebAuthn JSON, son 7
commits) y un salto de V8 barato. Estimación: **5–6 días de MOTOR**, una ronda de SEGURIDAD-PORTES para V8 12.9 y dos
compilaciones de LOCAL (tras V8 y al final).

### 1. V8 12.9 (`12.9.202.28`, f372edd3: la de Chrome 129, cabeza de la rama 12.9, 08-10-2024; sin LTS)

**Salto barato** (principio 11: el criterio de parada no se cumple). `include/` cambia +131/−86 líneas (la 12.8 eran
semanas). Lo que quita y la 116 usa:

- **`FastApiCallbackOptions::fallback`** (V8 be03ed2). La 116 lo pone en el generador de bindings
  (`bind_gen/interface.py`) y en `NoAllocDirectCallHost`, que usan los 158 métodos `[NoAllocDirectCall]` de WebGL,
  WebGPU y canvas 2D. La 12.8 aún lo respeta (TurboFan y Turboshaft leen el campo), así que la 1.12.x está bien; con la
  12.9 no compila. **(A, recomendada)** portar 8d78666bade + **d9bfd74484c** («Remove fallback for fast API users»: las
  llamadas rápidas lanzan la excepción ellas mismas, como hace Chrome desde la 126): 48 hunks, 19 rechazados (5 en
  `interface.py`, 2 en canvas), **~1 día**. **(B)** dejar de generar llamadas rápidas (`[NoAllocDirectCall]` pasa a
  llamada normal): horas y menos código, pero WebGL y canvas 2D van más lentos en llamadas cortas. B queda de reserva
  si A da problemas en LOCAL.
- **`v8::ZoneBackingAllocator`** y `Platform::GetZoneBackingAllocator()` (V8 7448e8c): gin lo sobrescribe → quitar la
  sobrescritura (parte de gin de abf6e5b63e6; el resto del commit es `base/`). Minutos.
- **cppgc prohíbe `new` en un `GarbageCollectedMixin`** (V8 4483ef3): no hay casos conocidos en la 116; lo dirá la
  compilación. Riesgo bajo.
- Sin uso en la 116, brave-core ni nuestros parches: `V8_ENABLE_DIRECT_LOCAL` → `V8_ENABLE_DIRECT_HANDLE`,
  `kFirst/LastStringMap`, `wasm_memory`, y los 3 flags de V8 que desaparecen (`direct_local`,
  `invocation_count_for_turbofan_if_profile_guided_non_turbofan`, `maglev_track_object_changes`).
- Lo nuevo es opcional (`Function::Call(isolate…)`, `Object::Clone(isolate)`, `GetCurrentHostDefinedOptions`,
  `SetExceptionContext`…). `experimental_report_exceptions_from_callbacks` pasa a `true`, pero sin
  `SetExceptionPropagationCallback` (la 116 no lo pone) no hace nada.

Compilación: el `BUILD.gn` de V8 importa ahora `//third_party/icu/config.gni` (comprobar en `gn gen`); ICU mínimo 73,
el de la 116; `gni-v8.gni.patch` (Perfetto) hay que rehacerlo; `chromium_src/v8` y `gin` de Brave no cambian entre la
1.69.168 (Chromium 128) y la 1.70.133 (Chromium 129); `enable_f16c` se decide en tiempo de ejecución (no rompe la 5,1).
**Seguridad:** de los 70 parches de `patches/v8`, 55 entran tal cual en la 12.9, 6 ya están dentro (`accessors.cc`,
`heap-refs.cc`, `isolate.cc`, `value-serializer.{cc,h}`, `graph-builder-interface.cc`) y 9 chocan (`object-gen.cc`,
`js-to-wasm.tq`, `access-builder.h`, `access-info.cc`, `js-native-context-specialization.cc`,
`snapshot-table-opindex.h`, `ic.cc`, `bytecode-generator.cc`, `js-objects.cc`) → ronda `seg/v8-12.9` de
SEGURIDAD-PORTES (como FS.10 con la 12.8) y `kFlyWebCacheEpoch` sube. Alternativa descartada: seguir en la 12.8 y
encender `harmony_intl_duration_format` (el código es el mismo); ahorra la ronda, pero el principio 11 manda subir
mientras el salto sea barato, y aplazarlo encarece el 130.

### 2. Baseline del 129

| Función | Baseline | Porte | Coste |
|---|---|---|---|
| `Intl.DurationFormat` | 2025-03-04 | de serie con V8 12.9 (pasa de *staged* a *shipping*; es lo único de JavaScript del 129) | — |
| WebAuthn: `PublicKeyCredential.parseCreationOptionsFromJSON()`, `parseRequestOptionsFromJSON()`, `toJSON()` | 2025-03-31 | flag `WebAuthenticationJSONSerialization` (en la 116, `test` y solo `toJSON`): 2f5a1248572, 95a8f00b45c, b56aa79d938, c4fff5a3d39, a9ec75b24ad (sin pruebas), 3e310890d6d, 4df593b6054; 68 hunks, 36 rechazados. `json.cc` a su forma final, a mano donde la 116 difiere (sin 8863aedceed ni la parte de navegador de ab91ac7b3a6) | 1,5–2 días |
| `RTCDataChannel.binaryType = "blob"` | 2024-09-19 | f1b59d2be7b + **f12d06e864d** (fusión M129: comprobar que el canal está abierto antes de enviar un Blob); 21 hunks, 8 rechazados | ~1 día |
| `container-type` sin contención de *layout* (BCD `weak_containment`; Firefox 133, Safari 18.4) | sí (BCD) | flag `ContainerTypeNoLayoutContainment`, e28cd00c20c: entra limpio. Cambia qué caja es el bloque contenedor de los `position: fixed` dentro de un contenedor de consultas | horas |

En los Mac del proyecto WebAuthn es con llaves USB (no hay Touch ID); las librerías de *passkeys* comprueban
`parse*FromJSON` y, si falta, usan su propio código, así que el porte es de compatibilidad, no de función nueva.
**Fuera:** las subfunciones de *anchor positioning* (`position-area`, palabras clave de `position-try(-fallbacks)`;
Baseline por clave, pero la función no lo es y no está portada), `prefers-color-scheme` heredado del embebedor (no
Baseline), `scheduler.yield()` (sin Safari; en la 116 está en `experimental`), *scroll snap events* y
`calc-size()`/`interpolate-size` (solo Chrome).

### 3. Flags a `stable` sin Baseline (12 que pasan y 21 que nacen en `stable`)

- **Portables, limpias** (0 rechazos; horas entre todas): `BaseElementUrlUseFallback` (f1ccaff48fb, `<base href>`
  con `data:`/`javascript:`), `HandleSelectionChangeOnDeletingEmptyElement` (c3113fb4a0a),
  `MoveToParagraphStartOrEndSkipsNonEditable` (ee343f49bbf), `NonNullInputEventDataForTextArea` (4268dcfcc60),
  `PreventUndoIfNotEditable` (f93ba2512ae) y `CallExitNodeWithoutLayoutObject` (2a25e3550de); además
  `ContainerTypeNoLayoutContainment` (arriba).
- **Portables, pocos rechazos** (~1 día entre las cuatro): `CoalesceSelectionchangeEvent` (827877b838b + c8e11ca620e,
  7/15; la parte previa, `DispatchSelectionchangeEventPerElement`, va desde el 127), `KeepActiveIfLabelActive`
  (bdb93badc1c, 2/10), `CssDisplaySerialziationFix` (f4d6f2ea661, 2/5; el analizador de `display` de la 116, adaptado
  en R1) y `VerticalInputRangeKeyOperationFix` (5610b4322aa, 2/3).
- **Fuera por coste** (dependen de código posterior a la 116): `ScrollIntoViewRootFrameViewportBugFix` (6916f1ac980,
  18/22), `DirAutoFixSlotExclusions` (73881d441c2, 4/4: el `dir=auto` de la 116 es la versión con plantillas y
  `is_deferred`) y `ShapeOutsideClippedImageFix` (c0d09ea0876, detrás de cinco refactors de `shape-outside`; 15/22
  incluso con 763b1682ab).
- **Sin efecto o sin interés:** rendimiento (`DynamicScrollCullRectExpansion`, `IntersectionOptimization`,
  `ExcludePopupMainThreadScrollingReason`, `SvgTransformOptimization`), no son de Mac (`AuraScrollbarUses*`,
  `UnblockTouchMoveEarlier`, `ViewportChangesUpdateTextAutosizing`), `UnrestrictedUsb` (solo apps aisladas),
  `WebGPUHDR`, *anchor positioning* (`CSSPositionArea*`, `CSSInsetAreaProperty`) y lo no Baseline
  (`CSSCalcSizeFunction`, `CSSScrollSnap*`, `SchedulerYield`). `KeyboardFocusableScrollers` llegó a `stable` y la propia
  rama M129 lo retiró (22718b9af37). Las `base::Feature` de Blink que cambian (p. ej. `IndexedDBCompressValuesWithSnappy`,
  formato en disco) no son de la web: fuera.

### 4. Fusiones de la rama M129 sobre lo que ya tenemos

- **75fdde77374** arregla el `aria-rowindextext`/`aria-colindextext` que portamos en el 128 (e6614bc4): entra
  limpio (6 hunks, Blink y `ui/accessibility`). Va en el 129.
- 9900d924764 (RubyLB) = ef8ddcab1d8, ya en e420119c.
- Para SEGURIDAD-PORTES (código de la 116; que valore si aplican): 8669b50ce1c (WebAudio, carrera en
  `automation_rate_`), 0712fcc39d2 (accesibilidad), ebe44c38be3 (nulo en `element.cc`), 7c883b00231 (304 en
  `ResourceLoader`), 1d8dc1d8291 y 29d14f1cd9c (analizador CSS).

### 5. Declaración y comprobación

`flyweb_engine_level` 129, `flyweb_version` 1.13, **`flyweb_engine_full_version` = 129.0.6668.101** (la última Stable
normal de la 129 para Mac al 100 %, 08-10-2024, según versionhistory de Google; como la .138 del 128) y
`flyweb_min_macos_version` **11.7.10** (Chrome 129 ya no admite 10.15; decisión del HUMANO del 12-10, principio 13).
Sin cambios conocidos de red en la 129: la receta de huella de LOCAL, como siempre. `motor-129.html` y
`wpt-129-lista.txt` al portar (WebAuthn JSON, `RTCDataChannel` con Blob, `container-type`, `Intl.DurationFormat` con
d8/test262).

### 6. Regla 17 y orden propuesto

Ningún porte llega a «decenas de commits», así que la regla 17 no obliga. La fila FS que sí hace falta es la ronda de
V8 12.9 (`seg/v8-12.9`, con la regla de no tener menos correcciones que la 12.8); propongo sumarle la revisión de lo
nuevo que una web puede alcanzar (envío de Blob por `RTCDataChannel`, parseo de JSON de WebAuthn, llamadas rápidas que
lanzan excepciones) con los `Merged:` de las ramas 130–132 (LTS). MOTOR la abre al empezar el porte de V8.
Orden: (1) `nube/motor-129` desde `nube/motor-128-ruby` bb6c7146; (2) V8 12.9 con d9bfd74484c y gin → Static de LOCAL
(en paralelo, la fila FS); (3) Baseline, flags y 75fdde77374, un commit cada uno; (4) declarar 129/1.13, `motor-129.html`
y WPT → Static, ASan y Release de LOCAL.

**Reparto entre 1.13 y 1.13.x (propuesta, lo pidió COORDINACIÓN-5):**

- **1.13 = nivel 129 completo, de una vez:** V8 12.9 (con d9bfd74484c y gin) + `seg/v8-12.9`, `Intl.DurationFormat`,
  `container-type`, Blob en `RTCDataChannel` (con f12d06e864d), WebAuthn JSON, las 10 flags y 75fdde77374. No compensa
  partirlo como el 128: aquí no hay un RubyLB. Lo que marca la fecha es la ronda de seguridad de V8, que va en paralelo
  y es requisito de la 1.13 (no publicar con menos correcciones que la 1.12.2). El porte más caro, WebAuthn JSON
  (1,5–2 días), cabe en ese tiempo. Si COORDINACIÓN quiere la V8 12.9 antes, WebAuthn JSON es lo que se puede pasar a
  la 1.13.1 sin romper nada: en los Mac del proyecto solo hay llaves USB y las librerías tienen su propio respaldo.
  Mientras tanto, la 1.13 declararía 129 con esa excepción anotada, como la 1.12 sin `ruby-align`.
- **1.13.x:** lo que salga en LOCAL; los arreglos posteriores a la 129 que encuentre la fila FS en el código nuevo
  (envío de Blob, parseo JSON, llamadas rápidas) si no llegan a tiempo; y los 6 arreglos de la rama M129 sobre código de
  la 116, cuando SEGURIDAD-PORTES los dé por buenos (no frenan la 1.13 salvo daño de memoria explotable).

### 7. Portado (MOTOR-8, 14-10): brave-core `nube/motor-129`

Decisiones de COORDINACIÓN-5 (FM.19): V8 12.9 sí, llamadas rápidas con la opción A, FS.13 abierta, y un Static de LOCAL
con YouTube y las webs con JIT en ASan **solo con el paso de V8** antes de seguir. Un commit por función, encima de la
1.12.2 (bb6c7146); cada uno comprobado con `chk.sh` (los parches aplican sobre la 116) y, donde toca, con los
generadores de Blink (`gencss.sh` para flags y el generador de *bindings*):

| Commit | Qué | Upstream y adaptación |
|---|---|---|
| **b589e86dc7** | Paso de V8: 12.9.202.28 | `v8re.sh`: 57 parches entran, 7 fuera por estar ya en la 12.9 (también `js-to-wasm.tq`, que `git apply` daba como choque), **6 fuera hasta FS.13**. d9bfd74484c a mano (19 de 48 hunks): el generador ya no emite `fallback` ni la ruta de pruebas, y los ficheros `NoAllocDirectCall*` quedan en el árbol pero fuera de `platform/BUILD.gn`; el generador sin compilar solo cambia las 10 interfaces con `[NoAllocDirectCall]`. gin sin `GetZoneBackingAllocator` |
| 170cc44a13 | `container-type` sin contención de *layout* | e28cd00c20c; dos hunks a mano |
| d2c01e612e | `aria-*indextext` en la capa de plataforma | 75fdde77374 (rama M129), limpio |
| 7919cb9d6c … 9f46f6419e | 6 flags limpias | f1ccaff48fb, c3113fb4a0a, ee343f49bbf, 4268dcfcc60, f93ba2512ae, 2a25e3550de; con el `#include` de `runtime_enabled_features.h` explícito donde la 116 no lo tenía |
| 4570871899 | `selectionchange` coalescido | estado final de **f59df98d713** (de la 128, faltaba en el porte del 127: los controles dentro de una sombra avisan al documento) + 827877b838b + c8e11ca620e, a mano |
| 54c6af04aa | `:active` con la etiqueta pulsada | bdb93badc1c |
| 78fd6b670e | serialización de `display` | f4d6f2ea661; el analizador de la 116 usa `CSSParserTokenRange` |
| 05821c83e3 | flechas en rangos verticales | 5610b4322aa adaptado: teclas como literales, `Over()/Under()` de la 116 y `!RemoveNonStandardAppearanceValueSliderVertical` |
| 4eb59aba99 | Blob en `RTCDataChannel` | f1b59d2be7b + f12d06e864d a mano sobre el `RTCDataChannel` de la 116 (*thread checker*, temporizador de eventos); como en Chrome 129, `send(String)` no espera a un Blob pendiente |
| e4e20f421b | WebAuthn JSON | estado final de 7 commits; sin `hints` ni `supplementalPubKeys` (la 116 no los tiene) y con la unión de la 116 como tipo de `toJSON()` en vez de `typedef object` (mismo objeto en JS) |
| **1a93159423** | declara 129 / 1.13 | 129.0.6668.101, `platformVersion` mínimo 11.7.10 |
| 9d83369504 | arreglos del Blob en `RTCDataChannel` (FS.13) | 6e4bc681b82 (crbug 374310077: `SelfKeepAlive` del `BlobReader`, uso tras liberar) y 1116bad3e0a (crbug 373898146); los únicos entre la 129 y la 132 LTS en ese código |
| 10173b669d | arreglos de WebAuthn JSON (FS.13) | 881db66b5c2 (`credBlob` leía el *getter* de `getCredBlob`: DCHECK al crear, valor falso en *release*) y 434f57a28bd (`prf.results` se construía y no se añadía); los dos fallos ya estaban en la 116, pero `toJSON()` solo es alcanzable desde la web ahora que la flag es *stable*. Pedidos por SEGURIDAD-PORTES |
| 91c501b266 | `TrustedHeapConstant` en la ISel de TurboFan | solo FlyWeb: con `turboshaft_instruction_selection` apagada, todo literal RegExp optimizado caía en `UNREACHABLE` en `ToConstant()` (3f714fa8 de la 12.9 no cubrió esa rama; la 13.0 tampoco). LOCAL-3 lo vio en claude.ai. Una línea, la misma constante que la rama Turboshaft. También en `nube/motor-129-v8` 138bf03174 (paso de V8 + arreglo). **Quitado al fundir FS.13** (547f27e798): con la ISel de Turboshaft encendida (regla 19) el JS ya no pasa por esa rama |
| **547f27e798** | FS.13: `seg/v8-12.9` 2ffa1017bc (SEGURIDAD-PORTES) | los 6 parches de V8 que el paso dejó fuera, época 13, `turboshaft_instruction_selection` y `wasm_to_js_generic_wrapper` otra vez en `true` (regla 19) con fc26d62d0, 153d4e84e, 94e495e1d y 34587b687, y a7c018806; sin la (a). `patches/v8` = `seg/v8-12.9` (71 parches, aplican sobre la 12.9.202.28 limpia). En `nube/motor-129-v8` **fdac7ed13b** (paso de V8 + FS.13, árbol = `seg/v8-12.9`) |
| **ea0bc5f33d** | FS.13: `seg/blink-129` 63ea2663a0 | 8669b50ce1c (WebAudio, `automation_rate_` atómico) |
| 43ef04cf64 | `RTCDataChannel.binaryType` como enum `BinaryType` | como en la 129: lo no válido se ignora en los *bindings* (aviso en consola) en vez de lanzar; lo vio LOCAL-3 con la WPT `RTCDataChannel-binaryType` (3/10 → Chrome 129 10/10) |
| **325686916c** | fuente monoespaciada por defecto en Mac: Menlo | `IDS_FIXED_FONT_FAMILY` de `chrome/app/resources/locale_settings_mac.grd` (Courier en la 117.0.5938.0, Menlo en la 118.0.5993.0): se escapó en el nivel 118 por estar fuera de Blink; lo destapó `block-ruby-003` (métricas de `monospace` distintas de Chrome for Testing 129). Sin la lista japonesa (`PrefsFontList`, posterior a la 116) |

Comprobación: `FlyWeb/tools/motor-129.html` (en Chromium 141 da ok todo lo que no es la versión declarada),
`fastapi-129.html` (11/11 en Chromium 141) y `wpt-129-lista.txt` (27). «Para la web» en `version-1.13.md`.

## Nivel 130 (en código, 15-10, MOTOR-10; cabeza ccc74ea171, LOCAL-4 compilando → FlyWeb 1.14)

Inventario de FM.20, **para decidir COORDINACIÓN antes de portar**. Fuentes: web-features 3.42.0 + BCD 8.1.5
(`baseline-nivel.js 130`), flags de `runtime_enabled_features.json5` entre la **129.0.6668.112** y la **130.0.6723.192**
(cabeza de la rama 6723; `flags-nivel.py`), `base::Feature` de red, content y Blink entre las mismas etiquetas, y la API
pública de V8 entre la **12.9.202.28** y la **13.0.245.25**. Lista de commits: `FlyWeb/tools/port/nivel130-commits.tsv`.
**Medidas sobre la 1.13:** primero se midió sobre la 116 sola (sin brave-core en la sesión); el 15-10, con brave-core
en lectura, se repitió todo sobre la 116 + los parches de `nube/motor-129` 325686916c (`medirng.sh`, con el traductor
de LayoutNG). Apenas cambia: *nested declarations* 99/31 (11 de sus 26 ficheros ya llevan parche nuestro), `text-wrap`
39/20 (13 de 20), `RTCDataChannel` transferible 44/8, `KeyboardFocusableScrollers` 75/67; el resto, igual. Las cifras
de abajo son las de la 1.13 donde difieren.

**Resumen: nivel mediano, sin porte grande y con un salto de V8 barato.** Tres portes de Baseline (*nested
declarations*, `text-wrap` y `RTCDataChannel` transferible), uno pequeño (`togglePopover({force})`), dos funciones que
llegan solas con la V8 13.0, ~12 flags pequeñas y los apagados que se escaparon (§9–§10). **Estimación en horas reales
(§11): 11–14 h desde el paso de V8 hasta la entrega de LOCAL, frente a ~9,5 h del 129.** (La primera cifra, «8–10
días», usaba la unidad del inventario del 129, que salió unas diez veces más pesimista que la realidad.) **Regla 18:
sale entero como 1.14, con la V8 13.0**; no hay nada del tamaño de RubyLB que justifique partirlo.

### 1. V8 13.0 (`13.0.245.25`, 3551594a: cabeza de la rama 13.0, 06-01-2025; sin LTS)

Chrome 130.0.6723.117 (la última Stable de Mac al 100 %) lleva la 13.0.245.18; propongo la cabeza de la rama, como en
el 129. `include/` cambia +409/−204, casi todo reordenación e iteradores; **lo que rompe la 116:**

- **`Platform::GetForegroundTaskRunner(Isolate*, TaskPriority)` pasa a virtual pura** y la de un argumento deja de ser
  virtual. gin (116) sobrescribe la de un argumento → no compila. **(B, recomendada)** cambiar la sobrescritura de gin
  a la de dos argumentos y devolver el mismo *task runner* para las tres prioridades (lo que hace hoy la 1.13): minutos.
  **Nunca `nullptr`:** la 13.0 pide `kUserVisible` en `incremental-marking-job.cc` y el adaptador de cppgc pasa la
  prioridad. **(A)** portar e97ba778462 + 8e42980ed5d (colas de V8 de prioridad baja en el planificador de Blink;
  74 hunks, 10 rechazados, 22 ficheros, ~1 día): solo rendimiento, no hace falta.
- **Dependencia nueva `//third_party/fast_float`** (la usa `v8_base`; la 116 no la tiene). Hace falta
  `third_party/fast_float/BUILD.gn` (el de Chromium 130, como parche de fichero nuevo en brave-core) y el código
  (`fastfloat/fast_float` 3e57d8dc, solo cabeceras; MIT/Apache-2.0/BSL). Propuesta: `build.sh` lo trae a
  `src/third_party/fast_float/src` como ya trae V8 (sin `gclient sync`); es un cambio en softmac que revisa LOCAL.
  ~2 h. Es lo único nuevo en las rutas GN de V8 frente a la 12.9 (comprobado contra el árbol de la 116).
- Sin efecto en la 116: `AllowCodeGenerationFromStringsCallback` (no se usa), `kWasmImportedStringsUtf8` (el
  contador de uso de Blink tiene `default:`), `Module::InstantiateModule` con un segundo argumento opcional,
  `PageAllocator::SealPages` (virtual con valor por defecto), `cppgc::Platform::GetForegroundTaskRunner(TaskPriority)`
  (ninguna subclase en la 116), `TracedReference` y `MemorySpan` (internos o compatibles; un solo uso en Blink).
- Riesgo de compilación bajo: las cabeceras usan C++20 (`Iterator::iterator_concept` sin `typename`, `<compare>`),
  que el clang de la 116 admite; ICU mínimo sigue en 73 y no hay cabeceras de ICU ni de abseil nuevas. Lo dirá LOCAL.
- **Seguridad (FS.14, SEGURIDAD-PORTES-2):** `patches/v8` (71) contra la 13.0.245.25 limpia (`git apply --check`):
  **55 entran, 8 parecen ya dentro** (`-R`: `wasm-compiler.cc`, `maglev-phi-representation-selector.cc`,
  `map-inl.h`, `map.h`, `runtime-wasm.cc`, los dos `liftoff-assembler-*-inl.h`, `wasm-js.cc`) **y 8 chocan**
  (`builtins-object-gen.cc`, `builtins-wasm-gen.cc`, `js-to-wasm.tq`, `wasm-to-js.tq`, `js-call-reducer.cc`, `ic.cc`,
  `js-break-iterator.cc`, `wasm/wrappers.cc`). Época de caché nueva (**15**: la 14 está reservada), fusiones 13.0/13.1/13.2-LTS, pasada de API del *embedder* y la tabla de la regla 19 (§6). Según
  `RELEVO-SEGURIDAD.md`, a7c018806, 153d4e84e y bc67262 ya están en la 13.0.245.25.
- JavaScript y Wasm que llegan solos: `Intl.Locale.prototype.getCalendars()`, `getCollations()`, `getHourCycles()`,
  `getNumberingSystems()`, `getTextInfo()`, `getTimeZones()`, `getWeekInfo()` (`harmony_intl_locale_info_func` pasa a
  *shipping*; los *getters* antiguos siguen) y **Wasm JS String Builtins** (`imported_strings` = true; sin
  `SetWasmImportedStringsEnabledCallback`, que la 116 no instala, manda la opción de V8). `Atomics.pause` queda en
  *staged* (no sale).

### 2. Baseline del 130

| Función | Baseline | Porte | Medida (116 sola) | Coste |
|---|---|---|---|---|
| `CSSNestedDeclarations` (*nesting*: las declaraciones tras una regla anidada van en su propia regla, en orden) | 2024-12-11 | 3ae71aa0358, 61067c8a5ba, 11e3a184408, a9b425e2212, 0a6d3ac600e, b4b329c0e7a, 63303296ddf; sobre el *nesting* relajado del 120 y el analizador por `CSSParserTokenRange` de la 116 (los rechazos, en `css_parser_impl.cc` y el inspector) | 99/31, 26 ficheros | **2–3 días** |
| `text-wrap` como abreviatura de `text-wrap-mode` + `text-wrap-style` (`stable`, `auto`) | 2024-10-17 | ee5d3f203d9 (sin flag en upstream; cambia `white-space` a `[white-space-collapse, text-wrap-mode]`); `pretty` sigue como en la 1.13 (no Baseline) | 39/20, 20 ficheros | **1,5–2 días** |
| `RTCDataChannel` transferible a un *worker* dedicado | 2025-10-14 | 6e640199859, e112b3ea554, 1f5f2853635; choca con el Blob del 129 en `rtc_data_channel.cc` | 44/8, 18 ficheros | **1–1,5 días** |
| `togglePopover({force})` (BCD `options_force_parameter`, Firefox 141, Safari 18.4) | sí (BCD) | la parte de 8010721fc51 que acepta `TogglePopoverOptions`; `source` queda tras `PopoverAnchorRelationships` (experimental), como en la 130 | 11/6 | **medio día** |
| `Intl.Locale` info como funciones | 2026-07-21 | de serie con V8 13.0 | — | — |
| Wasm JS String Builtins (`jsStringBuiltins`) | 2025-12-12 | de serie con V8 13.0; opcional el interruptor de Blink (1f2dd1392d2 + 37f9fd474bd: flag `WebAssemblyJSStringBuiltins` → `--no-experimental-wasm-imported-strings`) | 2/1 | minutos |

**Fuera (no Baseline):** `box-decoration-break` sin prefijo y en fragmentación de bloque (Safari solo con prefijo;
`-webkit-box-decoration-break` ya está en la 116), `justify-self` en bloques, *Compression Dictionary Transport*
(red, solo Chrome), `preferInitialWindowPlacement` de Document PiP, `text-wrap-style: pretty`, las opciones de
compilación de Wasm y lo de Web Serial.

### 3. Flags a `stable` sin Baseline (11 que pasan y 16 que nacen en `stable`)

- **Portables, limpias o casi** (horas entre todas): `PopoverDialogNewFocusBehavior` (e3092e4a179, 2/0),
  `RemoveCollapsedPlaceholder` (5017a8fc5de, 7/0), `ResetInputTypeToNoneBeforeCharacterInput` (2b7df017cf3, 6/0),
  `RootElementWithPlaceHolderAfterDeletingSelection` (95d6e97c5f7, 2/0), `StricterCellWidthContentSizeQuirk`
  (d192ad18b88, 2/1), `PseudoElementsCorrectInGetComputedStyle` (7e13e3080e9, 2/1) y `PaintHighlightsForFirstLetter`
  (f30d9fddc4b, 13/3).
- **Portables, pocos rechazos** (~1,5 días entre todas): `CSSFlatTreeContainer` (8410509e422 + 9425692817a, 22/2:
  *container queries* por el árbol plano), `MeterAppearanceNoneFallbackStyle` + `MeterDevolveAppearance` (5 commits,
  24/4), `MultiSmoothScrollIntoView` (4 commits, 22/4), `PointerEventTargetsInEventLists` (365b4154cbd +
  8f487908070, 5/4) y `CSSPartAllowsMoreSelectorsAfter` (4 commits, 15/10, `css_selector.cc`).
- **Fuera por coste:** `KeyboardFocusableScrollers` (da12836a721 + 199d1a77501 + 6f8b4173951: 55 ficheros, ~60
  rechazos; toca el foco en todo Blink), `ShapeOutsideWritingModeFix` (12/7; el `shape-outside` de la 116 va detrás de
  los mismos refactors que dejaron fuera `ShapeOutsideClippedImageFix` en el 129) y `TextInputNotAlwaysDirAuto` (4/3;
  el `dir=auto` de la 116, como `DirAutoFixSlotExclusions`).
- **Sin efecto o sin interés:** `CSSLineClampWebkitBoxBlockification` (necesita `line-clamp` sin prefijo, que la 116 no
  tiene), rendimiento (`SelectPopupLessUpdates`, `ReuseShapeResultsByFonts`,
  `MinimimalResourceRequestPrepBeforeCacheLookup`), WebGPU (`DeprecatedRequestAdapterInfo`, apagado), FLEDGE
  (`FledgePermitCrossOriginTrustedSignals`, apagado en Brave), no Baseline (`BoxDecorationBreak`,
  `LayoutJustifySelfForBlocks`, `DocumentPictureInPicturePreferInitialPlacement`) y no Mac
  (`AuraScrollbarUsesNinePatchTrack`). Las 55 flags que desaparecen quedan como estaban en la 129 (casi todas
  `stable`, ahora permanentes; las apagadas se quitan): no cambian nada.
- **`MutationEvents` pasa de `stable` a apagado (cc4fc38654c, «Land in M130») — decisión.** En Chrome 130 dejan de
  dispararse `DOMNodeInserted`, `DOMSubtreeModified` y compañía (salvo *deprecation trial* o la política
  `--mutation-events-enabled`). **Recomiendo hacer lo mismo:** es lo que espera una web que lee «Chrome 130», y los
  eventos de mutación han sido durante años fuente de fallos de uso tras liberar en el DOM, que en una base de 2023 no
  recibe arreglos. Coste: minutos. Riesgo: alguna web vieja que aún los use; Chrome 130 rompe igual.

### 4. Fuera de Blink (lección de Menlo)

Comparados `chrome/app/resources/locale_settings*.grd`, las preferencias web (`prefs_tab_helper.cc`, `settings.json5`),
`net/socket/ssl_client_socket_impl.cc` y las `base::Feature` de `net`, `services/network`, `content` y Blink:

- **Sin cambios de fuentes por defecto ni de TLS** (Kyber sigue; ML-KEM es de la 131). `PrefsFontList` solo pasa a
  permanente en la 130; la lista japonesa de fuente fija y `kPrefsFontList` los lleva MOTOR-8 en `nube/ruby-003`
  aa52bd0a60 (`block-ruby-003`), que entra en la base del 130 si LOCAL-4 lo confirma.
- **Barrido de fuentes y preferencias 117–130** (lo pidió COORDINACIÓN-6): en `locale_settings_mac.grd` solo cambian
  dos cosas, la monoespaciada general (Courier → Menlo, 47c2f9b983b, nivel 118; en la 1.13) y la japonesa (Osaka-Mono →
  «,Osaka,BIZ UDGothic,Menlo», niveles 127–128; `nube/ruby-003`); `locale_settings.grd` solo cambia en ChromeOS; los
  valores por defecto de `WebPreferences` en Mac son los mismos (77d1c7a4af3 solo los mueve a la cabecera). La cadena
  japonesa completa de upstream es c20e7d470d0, 4a7040197a4, 4fb67a95bdf, ce78dbafb47, **fff00651a17** (Blink:
  `GenericFontFamilySettings` pasa «Osaka» a «Osaka-Mono» en `monospace`; sin él, con Osaka instalada, la monoespaciada
  japonesa sería la proporcional), 663e2da6e4b y 6e966707997 (las dos cambian también
  `platform_locale_settings/locale_settings_mac_ja.xtb`, que manda con la interfaz en japonés) y 2888995d9c6. Hay que
  comprobar que `nube/ruby-003` lleve fff00651a17 y las `_ja.xtb`; no he podido mirarlo (sin brave-core).
- **`data:` URL: se conserva el espacio en blanco en las que no son base64** (`KeepWhitespaceForDataUrls`,
  34b6c2b36e8; como Firefox y Safari y la especificación de Fetch). Propongo portarlo: solo `net/base/data_url.cc` y la
  `base::Feature`, sin la política de empresa (16/3; horas).
- *Compression Dictionary Transport* encendido (`network::features`): `Available-Dictionary` y `dcb`/`dcz` solo se
  envían cuando la web ha registrado un diccionario, así que la huella por defecto no cambia. Fuera (no Baseline).
- Lo demás es interno o de producto (`BackgroundResourceFetch`, *parkable strings*, Shared Storage, organización de
  pestañas con IA, Esc mantenido para salir de pantalla completa).
- **Declaración:** `flyweb_engine_level` 130, `flyweb_version` 1.14, **`flyweb_engine_full_version` =
  130.0.6723.117** (la última Stable de Mac al 100 %, 05-11-2024, según versionhistory de Google; la .119 no pasó del
  50 %), `platformVersion` mínimo **11.7.10** (129–138, principio 13). Receta de huella de LOCAL como siempre.

### 5. Fusiones de la rama M130 (6723) sobre lo que ya tenemos

- 66a556bd168 (RubyLB, `text-align`) = 56be91796b, ya en la 1.12.1 (FS.11).
- Para SEGURIDAD-PORTES-2 (FS.14, punto 4; que valore si aplican a la 116 o a lo portado): e699ac35ac6 (Web Serial),
  ffedc45b73e (nulo en `platform` por debilidad), f3300abe2fc (`AcceptLanguagesWatcher`), 59d46b95c01 (caché y
  *service worker*), 6434353f319 (`AnimationFrameTimingMonitor`), 3d4d3dabe35 (`TextRenderingMode`), 4e10fc270e6 +
  55f45c2ad79 + 116873c4367 (`EncodedFormData`), a3304d219b0 (`calc()` mal analizado), 5333441795f (*container
  queries* y *subgrid*), f1e9e2c2e0b (colores relativos en canvas, nivel 125) y 7768072fa2d (`:visited` en iframes
  *credentialless*).

### 6. Lo apagado (regla 19) con la V8 13.0

| Qué | FlyWeb (1.13) | Upstream 13.0 | Recomendación |
|---|---|---|---|
| `maglev` | apagado | encendido | sigue apagado; se decide en el **132** (V8 13.2 LTS), como dice SEGURIDAD-PORTES |
| `maglev_untagged_phis` | apagado | encendido | con Maglev, en el 132 |
| `turboshaft_wasm` | apagado (= upstream) | apagado (encendido en la 13.2) | nada; el 132 |
| `turboshaft_instruction_selection`, `wasm_to_js_generic_wrapper` | encendidos | encendidos | nada |
| `regexp_simd` (nueva, encendida) | — | encendida | dejar la de upstream: en x64 exige SSSE3 (`CpuFeatures::IsSupported(SSSE3)`), que la 5,1 tiene; **no usa AVX** |
| `turboshaft_csa` | apagada (12.9) | **encendida** (los *builtins* CSA se generan con Turboshaft al compilar) | la de upstream; los parches de seguridad sobre CSA (`builtins-object-gen.cc`) pasan por ahí: mjsunit de FS.14 |
| Wasm JS String Builtins | — | encendido (de serie) | de serie; superficie nueva para FS.14 |
| WebGPU | apagado | encendido | sigue, ~140 |

Nada que encender en el 130 por la regla 19.

### 7. Regla 17 y orden propuesto

Ningún porte llega a «decenas de commits» (el mayor, *nested declarations*, son 7). La fila FS necesaria es **FS.14**
(ronda `seg/v8-13.0` como FS.13), más la revisión de lo nuevo que una web alcanza: *nested declarations* (analizador
CSS y CSSOM: `insertRule`, `ReplaceRuleIfExists`), `RTCDataChannel` transferible (paso del canal entre hilos: la parte
con más riesgo de uso tras liberar), `text-wrap`, Wasm JS String Builtins e `Intl.Locale`, con los `Merged:` de
131–132 (LTS), y los arreglos de la rama M130 del §5. MOTOR la abre al empezar el paso de V8.

Orden: (1) `nube/motor-130` desde `nube/motor-129` 325686916c (= `flyweb` 37197fe0, 1.13), más `nube/ruby-003` si LOCAL-4
lo confirma; (2) **paso de V8:**
`v8-revision` 13.0.245.25, `v8re.sh`, gin (B) y `fast_float` → Static y ASan aislados de LOCAL-4 con claude.ai, YouTube
y webs con JIT (FS.14 en paralelo); (3) Baseline, flags, `data:` y `MutationEvents` (si se aprueba), un commit cada uno;
(4) declarar 130/1.14, `motor-130.html` y `wpt-130-lista.txt` → Static, ASan y Release. Rehacer las medidas sobre
`nube/motor-129` en cuanto haya brave-core en la sesión.

**Decisiones que pido a COORDINACIÓN:** (i) V8 13.0.245.25 (cabeza) frente a la .18 de la Stable; (ii) gin con la
opción B; (iii) `fast_float` traído por `build.sh` (cambio en softmac) o empaquetado como parches de fichero nuevo en
brave-core; (iv) `MutationEvents` apagado como Chrome 130; (v) fuera por coste `KeyboardFocusableScrollers`,
`ShapeOutsideWritingModeFix` y `TextInputNotAlwaysDirAuto`; (vi) acceso de esta sesión a brave-core.

### 8. Decisiones de COORDINACIÓN-6 (15-10; valen como de Titín, regla 16)

- **(i)** V8 **13.0.245.25**. **(ii)** gin con la **opción B**, anotada como deuda: si una web nota que las tareas de
  baja prioridad de V8 compiten con las visibles, se vuelve a mirar la A (e97ba778462 + 8e42980ed5d). Preparado en
  `FlyWeb/tools/port/nivel130/gin-opcion-b.diff` (contra la 116; el parche final se rehace con el de gin que ya hay en
  brave-core). En la 12.9 todas las llamadas de V8 usan la versión de un argumento, así que la 1.13 no tiene ningún
  `nullptr` escondido.
- **(iii)** `fast_float` traído por `build.sh`, como V8, con commit y suma fijos (si no cuadran, se para), y su
  licencia en `about:credits`. Hecho en softmac: `build.sh` lee `src/brave/FlyWeb/fast_float-revision`
  («<commit> <suma>»; sin el fichero no hace nada) y lo trae de `chromium.googlesource.com/external/github.com/fastfloat/fast_float.git`.
  Probado con un espejo local: bien, segunda pasada sin traer, suma mala → para, fichero sin suma → para, sin fichero →
  nada. Para brave-core, en `FlyWeb/tools/port/nivel130/`: `fast_float-revision` (3e57d8dc, v6.1.4; suma 6344e292…),
  `fast_float/BUILD.gn` (el de Chromium 130 sin las pruebas) y `fast_float/README.chromium` (`License File:
  src/LICENSE-MIT`, que es lo que lee `licenses.py` para `about:credits`), como parches de fichero nuevo. **LOCAL-4:
  comprobar que `about:credits` lista fast_float.**
- **(iv)** `MutationEvents` apagado. **Corrección (15-10, tarde): sí se nos escapó en la 127.** En el código siguen
  en `stable` de la 127 a la 129 y se apagan en la 130 (cc4fc38654c), pero Chrome los apagó antes **por configuración
  de campo**: `fieldtrial_testing_config.json` los da por apagados en Mac desde la 124 y el despliegue a todos fue en
  la 127. LOCAL-4 lo vio en Chrome for Testing 129 (`typeof MutationEvent` `undefined`). Mi primera lectura solo
  miraba el código. Ver §10.
- **(v)** `KeyboardFocusableScrollers`, `ShapeOutsideWritingModeFix` y `TextInputNotAlwaysDirAuto`, fuera de la 1.14.
  Si alguna de sus WPT entra en `wpt-130-lista.txt`, se escribe como diferencia conocida en `version-1.14.md` y aquí.
  **Cambio (COORDINACIÓN-6, 15-10, tarde): `KeyboardFocusableScrollers` entra en la 1.14**, porque estimado en horas
  (2–3 h) ya no tiene sentido sacarlo por coste. Los otros dos siguen fuera.
  **Estimación de `KeyboardFocusableScrollers` (en horas reales, §11): 2–3 h de MOTOR** más una ronda de Static y ASan
  de LOCAL (~3 h) con pruebas de foco a mano.
  199d1a77501 rehace `SupportsFocus()`/`IsFocusable()` como un enum de tres estados en 55 ficheros (+485/−173), sobre
  da12836a721 (todos los *scrollers* admiten el foco). El riesgo está en el foco de formularios, `dialog` y *popover*.
  Propongo meterlo en un nivel ligero (131 o 132), no en uno cargado.
- **(vi)** brave-core: lo pide COORDINACIÓN a Titín. Para crear `nube/motor-130` hace falta poder escribir en el
  fork, no solo leerlo (regla 2).

### 9. Cambios «por defecto» que se escaparon (barrido 116–130, pedido en (iv))

Método: flags `stable` en la 116 que la 130 apaga, cambios de estado `stable` → otro entre 126→127→128→129, y
`BASE_FEATURE` de `net`, `services/network`, `content` y Blink entre esas etiquetas. De las 125 flags `stable` de la
116 que la 130 ya no tiene, 84 se quitaron en commits cuyo asunto dice que el cambio pasa a permanente. Las otras 41
se miraron una a una con `bisflag.py` (bisección sobre los commits de `runtime_enabled_features.json5` entre la 116 y
la 126; todas desaparecen ahí): **todas pasan a permanentes**, ninguna quita comportamiento. Son limpiezas de
funciones ya publicadas: MathML (4c179bccfbe), `offset-path` (1a9c63e62f4), FedCM (8c6c9ac464d), *style queries* con
la booleana (2a33a1e9e50), selectores no tolerantes en `:is`/`:has` (9739e872414), `::-webkit-scrollbar` (ddb1db50abe:
deja de depender de la preferencia, se sigue analizando), Resource Timing (b0b7955f811), ByobFetch, `linear()`,
formatos web del portapapeles, `HTMLScriptElement.supports`, LoAF, layout de la 115 y WebGPU+WebCodecs (apagado en
FlyWeb). Cuatro cambios visibles para las webs que ningún nivel recogió, todos de «apagar» y todos baratos (cambiar el
estado de la flag, y como mucho añadirla):

| Nivel | Qué apaga Chrome | Commit | En FlyWeb | Coste |
|---|---|---|---|---|
| 119 | **WebSQL** (`openDatabase`; flag `Database` → `experimental`) | 23d1b425018 | **sigue encendido** (la 116 lo trae `stable`; no consta en ningún nivel) | horas |
| 126 | API prefijadas de pantalla completa de `<video>` (`webkitEnterFullscreen`…; `PrefixedVideoFullscreen` → `test`) | c9fb12ce3ad | sigue encendido | minutos |
| 127 | sintaxis vieja de estados `:--foo` (`CSSCustomStateDeprecatedSyntax`) | 221eb242792 | sigue (el 125 la dejó «como en la 125») | horas |
| 128 | `DOMParser.parseFromString(…, {includeShadowRoots})` (`DOMParserIncludeShadowRoots`) | 20695562040 | sigue (la 116 lo trae sin flag) | horas |

**Decidido (COORDINACIÓN-6, 15-10): los cuatro se apagan en la 1.14, con `MutationEvents`,** después de que LOCAL-4 lo
compruebe en la 1.13; en `version-1.14.md`, «Para la web»: «WebSQL ya no existe, como en Chrome desde la 119».
`KeyboardFocusableScrollers` irá al 131 si es ligero, si no al 132 (se decide en su inventario); `IsolateSandboxedIframes`
lo valora SEGURIDAD-PORTES-2. Hay tres motivos:

- Es lo que hace el Chrome que declaramos.
- Cada uno es una prueba trivial de que no somos Chrome 129/130 (`typeof openDatabase`), en contra del principio 13.
- WebSQL mete SQLite en el renderer, con un historial largo de CVE (Magellan) sobre una base que no recibe arreglos.

Riesgo: una web que aún use WebSQL pierde el acceso a sus datos, lo mismo que en Chrome desde la 119. **Pido a LOCAL-4
que lo compruebe en la 1.13 antes, sin compilar:** `typeof openDatabase`,
`typeof HTMLVideoElement.prototype.webkitEnterFullscreen`, `CSS.supports('selector(:--x)')` y si
`parseFromString` con `includeShadowRoots: true` crea la sombra (Brave podría haber apagado alguno).

Sin efecto en la web o fuera por coste: `IsolateSandboxedIframes` (127: iframes con `sandbox` en otro proceso; es
modelo de procesos, grande; para que lo valoren SEGURIDAD-PORTES y ARQUITECTURA), FLEDGE y *fenced frames* (apagados
en Brave), métricas de Event Timing, `IndexedDBShardBackingStores`/`CompressValuesWithSnappy` (formato en disco),
`LocalCompileHints` (rendimiento), `ServiceWorkerClientIdAlignedWithSpec` (128, ajuste menor) y
`AncestorChainBitEnabledInPartitionedCookies` (128, cookies particionadas; se decide con la política de cookies de
Brave).

### 10. Configuración de campo (Finch), 116–130 (pedido de COORDINACIÓN-6 y Titín: «para ir a la par»)

**Por qué se nos escapan:** Brave compila con `disable_fieldtrial_testing_config: true` (brave-core
`build/commands/lib/config.js`), así que FlyWeb solo tiene los valores del código (y los que Brave cambia en
`chromium_src/*/features.cc`). Chrome real tiene además lo que manda el servidor de variaciones, que no vemos. Chrome for
Testing parece aplicar `testing/variations/fieldtrial_testing_config.json`: LOCAL-4 vio los eventos de mutación
apagados en CfT 129, con el código aún en `stable`. **La referencia empírica es CfT N en el mismo Mac**, como ya se
hace con las WPT.

**Método:** de cada etiqueta 116–130 (cabezas de rama), los estudios de `fieldtrial_testing_config.json` con «mac», con
su primer experimento, que es el que aplica Chromium. En la 130 hay 757 funciones; 182 tienen un valor por defecto que
sabemos leer (flags de Blink y `BASE_FEATURE` de `net`, `services/network`, `content` y Blink) y 112 de ellas difieren
del código. **La mayoría son experimentos, no despliegues:** rendimiento (LCPP, *prerender*, *parkable strings*,
planificador), Privacy Sandbox y FLEDGE (apagados en Brave), interfaz. La configuración de pruebas no dice a qué
porcentaje llegó cada experimento. Por eso solo cuento como «Chrome N lo hace» lo que tiene otra prueba: que el código
cambie poco después (131–133), o que LOCAL lo vea en CfT N.

| Qué | Código 130 | Campo 130 | Código 131–133 | Conclusión para la 1.14 |
|---|---|---|---|---|
| `MutationEvents` | on | **off** (desde la 124) | off | **apagar** (ya decidido; se escapó en la 127) |
| `ElementGetInnerHTML` (`getInnerHTML()`, el viejo de DSD; la 116 lo trae sin flag) | on | **off** (129–130) | **off desde la 131** | **apagar**, si LOCAL-4 confirma que CfT 130 no lo tiene |
| `UseNewAlpsCodepointHttp2`/`QUIC` (código nuevo de la extensión TLS ALPS) | off | on | off hasta la 133 | **no** sin datos: cambia la huella TLS (principio 13). LOCAL compara con ja4db de Chrome 130; si Chrome 130 ya usa el código nuevo, se enciende |
| `DeprecateUnload`, `ReduceAcceptLanguage`, `CacheControlNoStoreEnterBackForwardCache`, `CookieSameSiteConsidersRedirectChain`, `BlockAcceptClientHints`, `EscapeLtGtInAttributes`, `NonStandardAppearanceValueSliderVertical` (off), `TextSizeAdjustImprovements` | igual que FlyWeb | distinto | sin cambio hasta la 133 (`TextSizeAdjust`, en la 133) | no: experimentos parciales en la 130 |

**Barrido del código de la 116 a la 126 en `base::Feature`** (los niveles 117–125 solo miraron las flags de Blink). Uno
visible para las webs y sin tocar en Brave: **`OriginAgentClusterDefaultEnable`** (ead63e18b24, nivel 119). Chrome
agrupa por origen por defecto: `document.domain = …` ya no relaja el mismo origen salvo con `Origin-Agent-Cluster: ?0`.
FlyWeb sigue con el valor de la 116 (apagado). Es un endurecimiento de seguridad y cuesta minutos. **Propongo
encenderlo en la 1.14.** El resto del barrido son cosas que Brave ya decide en `chromium_src/net` (particiones,
`SupportPartitionedBlobUrl`), Privacy Sandbox (apagado), FedCM, rendimiento o red interna. ORB v0.2
(`OpaqueResponseBlockingV02`, encendido en el código en la 126) queda para que lo valore SEGURIDAD-PORTES-2.

**LOCAL-4 añadió otro** al probar los cuatro de §9: el atributo antiguo `<template shadowroot>` (DSD no *streaming*)
crea la sombra en la 1.13 con `Document.parseHTMLUnsafe` y no en CfT 129. Chrome lo apagó en la 121 (561042837d7) y
lo quitó en la 122 (5f4c1fc06a1). Va con los de §9.

**Decidido por COORDINACIÓN-6 (15-10, tarde):** fuera los cinco de §9 y el `<template shadowroot>` antiguo; fuera
`getInnerHTML()` si LOCAL-4 lo ve apagado en CfT 130 (la referencia es lo que expone CfT, no el código); dentro
`OriginAgentClusterDefaultEnable`, después de que LOCAL-4 compruebe en CfT 129 que asignar `document.domain` no relaja
el mismo origen; el código ALPS se decide con los JA4 de LOCAL-4 frente a CfT 129 y 130 (la huella TLS tiene que
cuadrar con la versión declarada, F4.8). La pasada de `superficie.html` va en la cola de LOCAL-4.

**Lista para la 1.14 (apagar o encender, todo barato):** WebSQL, pantalla completa prefijada de `<video>`, `:--foo`,
`includeShadowRoots`, `<template shadowroot>` antiguo, `MutationEvents`, `getInnerHTML()` (si CfT 130 lo confirma) y
`OriginAgentClusterDefaultEnable` encendido. Pendiente de datos: el código ALPS.

**Para que no vuelva a pasar:** `FlyWeb/tools/superficie.html` vuelca la superficie que ve una web: cada interfaz
global con sus miembros, las propiedades CSS, algunos selectores y comportamientos (`document.domain`, eventos de
mutación, DSD). LOCAL la abre en FlyWeb y en CfT N desde 127.0.0.1 y compara los dos ficheros con `diff`. Lo que
salga distinto y no esté en el inventario es un cambio «por defecto» que se escapó, venga del código o de Finch.
Propongo hacerlo en cada nivel, en la receta de LOCAL, junto a la huella de red. Primera pasada: 1.13 frente a CfT 129.

### 11. Estimación en horas reales, partida a partida con el 129

Tiempos del 129, sacados de FM.19 (14-10): inventario 12:55–13:20; paso de V8 en código 13:25–13:35; resto del nivel en
código 13:35–14:05; LOCAL compila y prueba el paso de V8, sale el cierre de claude.ai y se resuelve con FS.13 hacia
las 16:25; Static y WPT del nivel completo, con dos diferencias arregladas hacia las 20:45; ASan y Release; entrega a
las 23:07. Desde el paso de V8 hasta la entrega, **~9,5 h**. FS.13 fue en paralelo (~3 h).

| Partida | 129 (real) | 130 (estimado) | Por qué |
|---|---|---|---|
| Inventario | 25 min | hecho (~3 h, con los barridos de §9–§10) | — |
| Paso de V8 en código | 10 min | 30–45 min | `v8re.sh` + gin B (preparado) + ficheros de `fast_float` (preparados) |
| FS.14 (en paralelo) | ~3 h | 3–4 h | 8 parches chocan (6 a mano en el 129) + superficie nueva (Wasm JS String Builtins, `Intl.Locale`) |
| Baseline en código | ~30 min (44 rechazos) | 1–1,5 h (65 rechazos) | *nested declarations* toca el analizador CSS: más lógica que copia |
| Flags y apagados | dentro de esos 30 min (13 rechazos) | ~1 h | 12 flags (~21 rechazos), `data:` URL y 8 apagados o encendidos |
| Declarar + `motor-130.html` + `wpt-130-lista.txt` + `version-1.14.md` | dentro del bloque | ~45 min | — |
| Compilaciones y pruebas de LOCAL | ~7 h | 7–7,5 h | las mismas (Static y ASan del paso de V8, del nivel y Release), más la primera vez de `fast_float` |
| Arreglos tras las pruebas | ~2–3 h (claude.ai, `binaryType`, WPT) | 2–4 h | *nested declarations* y `text-wrap` cambian CSS de todas las páginas: más probable una ronda extra |
| **Total, del paso de V8 a la entrega** | **~9,5 h** | **11–14 h** | +20–45 %: más volumen de porte y más riesgo de regresión en CSS |

Lo que más pesa en la diferencia es *nested declarations* (analizador CSS y CSSOM). Si COORDINACIÓN quiere acortar,
es lo único que se podría pasar a una 1.14.1 sin romper nada, pero la regla 18 pide no partir sin un cambio muy amplio,
y esto no lo es. Recomiendo no partir.

**Estimación aceptada por COORDINACIÓN-6 (15-10).** Con `KeyboardFocusableScrollers` dentro: **+2–3 h de MOTOR**, sin
otra ronda de compilación si va en el mismo Static y ASan del nivel; más ~30 min de pruebas de foco a mano en LOCAL.
**Total: 13–17 h** del paso de V8 a la entrega.

**Lección de las unidades:** el inventario del 129 estimó «5–6 días de MOTOR» y el nivel salió en ~10 h de reloj. Copié
esa unidad para el 130 («8–10 días») sin compararla con lo que tardó de verdad, y la cifra no servía para decidir:
COORDINACIÓN sacó `KeyboardFocusableScrollers` por coste con un número inflado. **Desde el 130, las estimaciones van
en horas de reloj y se comparan, partida a partida, con el último nivel ya entregado** (tiempos de su fila FM).

**Riesgo del `BUILD.gn` de `fast_float` (lo señaló LOCAL-4): cubierto.** `gitPatcher.js` de brave-core
(`resetRepoFiles`, cambio de FlyWeb) ya borra los ficheros sin seguimiento cuando su parche deja de estar. Pasa con
muchos portes que crean ficheros (`async_iterable.cc`…). Al volver a una rama sin el parche, `BUILD.gn` y
`README.chromium` desaparecen. Solo se queda `src/third_party/fast_float/src`, que sin `BUILD.gn` nadie usa. LOCAL-4 lo
comprueba una vez al cambiar de rama en su primera compilación del 130.

### 12. Portado (MOTOR-10, 15-10): brave-core `nube/motor-130`

Sobre `nube/motor-129` 325686916c + `nube/ruby-003` 0c95523439. Un commit por función; cada uno con `chk.sh` (los parches
aplican sobre la 116: 127, más los de V8 contra la 13.0.245.25) y, donde toca, con `gencss.sh`, el generador de
*bindings*, `check_generated_file_list` y `validate_web_idl`. Herramientas nuevas en `FlyWeb/tools/port/README.md`.

| Commit | Qué | Upstream y adaptación |
|---|---|---|
| **a7b5f3f4aa** | Paso de V8: 13.0.245.25 (también `nube/motor-130-v8`) | `v8re.sh`: 62 parches; fuera por estar ya en la 13.0 los 8 del §1 más `builtins-object-gen.cc` y `wasm/wrappers.cc`; a mano `ic.cc` (comentarios), `js-to-wasm.tq` y `wasm-to-js.tq` (`check()` con el nombre `data` de upstream) y `builtins-wasm-gen.cc` (CVE-2026-87491 antes del nuevo `undef-code-stub-assembler-macros.inc`). gin opción B (`GetForegroundTaskRunner(isolate, priority)` devuelve el mismo *runner*). `fast_float-revision` + `BUILD.gn`/`README.chromium` como parches de fichero nuevo |
| 6e190602bf | *nested declarations* | estado final de la 130: los 7 del §2 más **9aaf19c456c, 4988a26f3a1 y 4b38c7c215f** (no estaban en el inventario: arreglos del CSSOM y del inspector posteriores a la serie). Sobre el analizador por `CSSParserTokenRange` de la 116; `Reparent` → `ReplaceSelectorList`; `frame_serializer.cc` recoge las propiedades en vez de leer `cssRules` nulo (fallo de upstream con la regla nueva) |
| 79dd7cef3c | `text-wrap` abreviatura | ee5d3f203d9. El generador de la 116 ordena los enums por id de palabra clave (`kNowrap` = 0), así que `white_space.h` lleva un bit explícito «sin corte» para que `EWhiteSpace::kNormal` siga en 0 (campo de 1 bit). `kTextWrapMode` = 805 y `kTextWrapStyle` = 806 en `css_property_id.mojom` |
| 6197cba436 | `RTCDataChannel` transferible | 6e640199859, e112b3ea554 y 1f5f2853635 a mano sobre el Blob del 129 (*thread checker* de la 116, `RegisterObserver` diferido, `CHECK(!was_transferred_)` al enviar); etiqueta de serialización `'p'`. Claves de `TransferList`/`Attachment` con dirección única en **e8c575a07f** (FS.14, crbug 511006880) |
| 60cbc4afdd | `togglePopover({force})` y `showPopover(options)` | parte de 8010721fc51: diccionarios nuevos; `source`/`invoker` se analiza y se ignora, como la 130 sin `PopoverAnchorRelationships` |
| cbf130398e … c53e604ee6 | 8 flags | `PopoverDialogNewFocusBehavior`, `RemoveCollapsedPlaceholder`, `ResetInputTypeToNoneBeforeCharacterInput`, `RootElementWithPlaceHolderAfterDeletingSelection`, `StricterCellWidthContentSizeQuirk`, `CSSFlatTreeContainer`, `PointerEventTargetsInEventLists` y `CSSPartAllowsMoreSelectorsAfter` (`IsAllowedAfterPart` de la 130 filtrado a los tipos de la 116) |
| d7518d129e | `KeyboardFocusableScrollers` | el comportamiento final de la 130 sin el enum de tres estados de 199d1a77501: `IsKeyboardFocusable()` acepta un *scroller* sin hijos enfocables (o ya enfocado), `IsFocusable()` también; el ratón sigue con `IsMouseFocusable()`. 3 ficheros (`element.cc`, `mouse_event_manager.cc` y la flag) en vez de 55. **LOCAL: pruebas de foco a mano** (formularios, `dialog`, *popover*) |
| 0b19c68a77 | espacios en `data:` URL | 34b6c2b36e8, sin la política |
| e35b106150 … c5a094a9ab | apagados del §9–§10 | WebSQL (`Database` → `test`, `kWebSQLAccess` apagado), `PrefixedVideoFullscreen` → `test`, `CSSCustomStateDeprecatedSyntax`, `MutationEvents`, `DeprecatedNonStreamingDeclarativeShadowDOM` y `DOMParserIncludeShadowRoots` (flags nuevas apagadas en `html_tree_builder.cc` y `dom_parser.cc`), `getInnerHTML()` (flag `ElementGetInnerHTML` apagada; **se revierte si CfT 130 lo expone**) |
| f2a06dcfc9 | `OriginAgentClusterDefaultEnable` encendido | `blink::features`, como ead63e18b24 |
| **bf596e40df** | declara 130 / 1.14 | 130.0.6723.117, `platformVersion` mínimo 11.7.10, `FLYWEB_BUILD_NUMBER` lo sube LOCAL |
| 59a9752614, 171b37e5e4 | FS.14: `seg/v8-13.0` 064323b537 y `seg/transfer-keys` 1df157fca7 | 91343bb4 y 924c1a79 (V8), época 15, `FLYWEB-SECURITY.md`; las 9 claves de la 116 con dirección única |
| 4caf11c4f6 | ORB v0.2 (FS.14) | fd38f4bbd62 (limpio) y el valor de fb43ec7b49a (122): bloqueo = error de red salvo en *fetch* de script |
| 37976248c3 | fuera los polyfills de core-js | decisión de COORDINACIÓN-6: con la V8 13.0 lo Baseline que cubrían es nativo y lo que quedaba (`RegExp.escape`, base64 de `Uint8Array`) no existe en Chrome 130. Fuera el observador, la `base::Feature`, el recurso de 50 KB y su entrada de `about:credits`; el generador de softmac `FlyWeb/polyfills/` queda como histórico |
| 4d6a8d5f60 | superficie que Chrome 130 no expone | `Sanitizer`/`setHTML()` tras `SanitizerAPI` (a24f025d3c3, 119), `writeTimestamp()` tras `WebGPUDeveloperFeatures` (feec40a09c3, 121; la 130 usa `WebGPUExperimentalFeatures`, que la 116 no tiene), `-webkit-highlight` quitada (d9ba00bd859, 117) y `:open`/`:closed` tras `HTMLSelectMenuElement` (0a36b431edd, 122; la 130 usa `CSSPseudoOpenClosed`). Los cuatro, restos de la 116 |
| 8645de1731 | interfaces `SpeechSynthesis` y `SpeechSynthesisVoice` | a918a37bec1 (121): la 116 las tenía como `LegacyNoInterfaceObject`. Sin función nueva; el *farbling* de voces de Brave sigue |
| 0fed65e758, **ccc74ea171** | FS.15 `seg/popup-sandbox` 1825a087d0 y `seg/v8-13.0` d6b66b7994 (SEGURIDAD-PORTES-3) | fd7c878da2 (crbug 544197473): un iframe con `sandbox` sin `allow-popups` ignora los modificadores de un clic sintético; los resultados de d8 en `FLYWEB-SECURITY.md` |
| 303e498fb5 | dos escapes de seguridad (119–120) | `nube/escapes-seg-1.14.1`, MOTOR-10 |
| 685f820c68 … **d12847a77f** | arreglos de la prueba de LOCAL-4 (`nube/arreglos-1.14`, MOTOR-11) | **`togglePopover(true)` sobre un popover abierto tumbaba la pestaña**: faltaba la retirada del CHECK de 63e395a18a0 (M117), que va con la rama `else` portada; abreviatura `-alternative-white-space` con su id; *nesting* como la 130 (eaf72aae1cf, 3bfc51bf4fa) e índice opcional de `CSSGroupingRule.insertRule()` (e2ff44d09f5); fuera `HTMLTemplateElement.shadowRoot` y `expectedImprovement`; diccionario de `togglePopover` sin leer, como la 130; WebSQL apagado de verdad (`databases_enabled` a `false`, como Chrome en escritorio). **Cabeza final de la 1.14.** Lección: al portar el estado final de una función, buscar también los cambios de upstream en las funciones a las que llama (aquí, `IsPopoverReady`) |

**Fuera de la 1.14, con motivo (al 131, aprobado por COORDINACIÓN-6).** Cuatro flags que el inventario daba por «limpias o casi» dependen de
código posterior a la 116, y la medida de hunks no lo ve (aplican, pero no compilan):
`PseudoElementsCorrectInGetComputedStyle` (necesita `kPseudoIdPlaceholder` y `kPseudoIdFileSelectorButton`),
`PaintHighlightsForFirstLetter` (`MarkerRangeMappingContext`), los estilos de reserva de `<meter>`
(`StyleUAShadowHostData`) y `MultiSmoothScrollIntoView` (`SetScrollOffset` con `bool` y los refactores del secuenciador
de *scroll*). El interruptor de Blink de Wasm JS String Builtins (opcional) tampoco entra, y el arreglo de
accesibilidad 8ddae9aa1fb tampoco.

**Superficie (pasada de LOCAL-4, 1.13 frente a CfT 129), clasificación pedida por COORDINACIÓN-6:**

| En CfT 129, no en la 1.13 | De dónde | En la 1.14 |
|---|---|---|
| `navigator.connection` | Brave: `kNavigatorConnectionAttribute` apagada (`idl_member_installer.cc`) | sigue fuera (privacidad) |
| File System Access (`show*Picker`, `getAsFileSystemHandle`…) | Brave: `kFileSystemAccessAPI` apagada | sigue fuera |
| Web Serial | Brave: `Serial` apagada en `brave_content_renderer_client.cc` | sigue fuera |
| Storage Access | Brave (`kPermissionStorageAccessAPI`) y decisión del nivel 119 | sigue fuera |
| interfaces `SpeechSynthesis`/`SpeechSynthesisVoice` | **nuestro**: la 116 no las expone (`speechSynthesis` sí estaba) | **dentro** (8645de1731) |
| `navigator.share`/`canShare` | **Chromium**: Chrome lo encendió en Mac en la **129** (52c8632e39b, `chrome/common`); entre la 116 y la 129 solo hay un arreglo funcional (06bbfc17caa, archivos en disco) | **fuera** (COORDINACIÓN-6, 15-10; principio 2): no es Baseline (Firefox de escritorio no lo tiene) y nunca se probó en Mojave. Diferencia conocida en `version-1.14.md`; se revisa cuando sea Baseline (son la flag y 06bbfc17caa, más una prueba de LOCAL en la 6,1) |

**Lección (otra de Menlo):** el barrido de `base::Feature` del §4 miró `net`, `services/network`, `content` y Blink, y
Web Share está en `chrome/common/chrome_features.cc`. Barrido ahora ese fichero entre la 116 y la 130: además de Web
Share solo cambian interfaz, actualizador, Privacy Sandbox (`KAnonymityService`, apagado en Brave) y `HttpsUpgrades`
(navegación, lo decide Brave). Desde el 131, el barrido incluye `chrome/common`.

Comprobación: `FlyWeb/tools/motor-130.html` (con las pruebas de superficie), `fastapi-129.html`, `wpt-130-lista.txt`
(37), `regexp-130.html` (FS.14) y `sandbox-popups.html` (FS.15). **JIT y Wasm se comprueban en un origen http(s)**
(`motor-130.html` y `fastapi-129.html`): la decisión de JIT es por sitio y en `about:blank` no se ve. El Static de
a7b5f3f4aa salió *jitless* en la 7,1 por una política vieja de la app de desarrollo (`DefaultJavaScriptJitSetting` = 2), y
las pruebas en `about:blank` no lo vieron. «Para la web» en `version-1.14.md`.

## Nivel 131 (inventario y decisiones, 15-10, MOTOR-10; se porta tras la entrega de la 1.14 → FlyWeb 1.15)

Inventario de FM.21, **para decidir COORDINACIÓN antes de portar**. Fuentes: web-features 3.42.0 + BCD 8.1.6
(`baseline-nivel.js 131`), flags de `runtime_enabled_features.json5` entre la **130.0.6723.192** y la **131.0.6778.268**
(cabeza de la rama 6778; `flags-nivel.py`), `base::Feature` de `net`, `services/network`, `content`, Blink, permisos **y
`chrome/common`**, configuración de campo de Mac (130 frente a 131), la API pública de V8 entre la **13.0.245.25** y la
**13.1.201.22**, y un barrido nuevo de las flags `stable` de **todos** los niveles 117–131 contra el json5 de la 1.14.
Medidas con `medirng.sh` sobre la 116 + los parches de `nube/motor-130` **ccc74ea171** (1.14). Lista de commits:
`FlyWeb/tools/port/nivel131-commits.tsv`.

**Resumen: nivel mediano con dos cosas grandes, una en Blink y otra fuera.** En Blink, los colores relativos sobre
`currentcolor` (149 hunks, 59 rechazos: más que *nested declarations*). Fuera de Blink, **ML-KEM**: Chrome 131 cambia
el intercambio poscuántico de TLS y QUIC de Kyber a ML-KEM, y el BoringSSL de la 116 no lo tiene (principio 13). La
V8 13.1 es el salto más barato hasta ahora. Más los cuatro aplazados del 130, ya aprobados, y unos escapes de niveles
anteriores que ha destapado el barrido nuevo (§6). **Estimación (§9): 13–17 h del paso de V8 a la entrega**, con
FS.17 (V8 13.1 y ML-KEM) en paralelo.

### 1. V8 13.1 (`13.1.201.22`, 9c09e787: cabeza de la rama 13.1 y la V8 de la 131.0.6778.265)

`include/` cambia +186/−41 en 18 ficheros, y casi nada rompe:

- **Lo que no compila en la 116:** `v8::Isolate::kImportAssertionDeprecatedSyntax` pasa a
  `kOBSOLETE_ImportAssertionDeprecatedSyntax` (`use_counter_callback.cc`, que ya tiene parche nuestro): una línea.
  **Y una segunda que el inventario no vio (MOTOR-11):** `ModuleRequest::GetImportAssertions()` pasa de
  `V8_DEPRECATE_SOON` a `V8_DEPRECATED`, y `module_record.cc` de la 116 lo llama. Chromium compila con
  `V8_DEPRECATION_WARNINGS` y `-Werror` (solo quita los avisos «imminent»), así que no compila: pasa a
  `GetImportAttributes()`, como en Chromium 131. Para cada salto de V8, buscar en la 116 lo que pasa a `V8_DEPRECATED`,
  no solo lo que se quita.
- Sin efecto: `EmbedderRootsHandler::IsRoot` y `V8InspectorClient::consoleTime*` dejan de ser virtuales puras y pasan
  a tener cuerpo por defecto, así que las sobrescrituras de la 116 y de nuestro parche siguen valiendo.
  `Object::GetCreationContext(PersistentBase)` sigue, con aviso. `v8-platform.h` no cambia: **gin no se toca**.
- **Sin dependencias nuevas** en `BUILD.gn` (al contrario que `fast_float` en la 13.0); `DEPS` solo cambia
  herramientas.
- JavaScript: **nada nuevo sale.** *Explicit resource management* (`using`) y `Float16Array` pasan de *in progress* a
  *staged*. `harmony_remove_intl_locale_info_getters` también se queda en *staged*, y los *getters* de `Intl.Locale`
  siguen. Wasm: `wasm_inlining` deja de ser opción experimental (sigue encendida); `wasm_deopt` sigue apagada.
- `patches/v8` contra la 13.1: el rebase lo hace SEGURIDAD-PORTES (FS.17), con época de caché nueva (16).
  `wasm_to_js_generic_wrapper` desaparece (la 13.1 lo da por fijo); el parche de `flag-definitions.h` que lo encendía
  (regla 19) se queda sin ese trozo.

### 2. Baseline del 131

| Función | Baseline | Porte | Medida | Coste |
|---|---|---|---|---|
| `::details-content` y `display` libre en `<details>` (`DetailsStyling`) | 2025-09-16 | 6223abaa9f0, 0837f59ce2e, 3e8f8fe3b1a, b5310fa7027, bfe80d0c3bd, ca1fb13815a (pseudoelementos «como `::part`»), 60972f7d007; con **951ace75914** (`CSSCascadeCorrectScope`: orden de la cascada para estilos de ámbitos de sombra superiores, que necesita el pseudoelemento) | 34/8 + 44/18 | **2–3 h** |
| Colores relativos sobre `currentcolor` (`rgb(from currentcolor …)`; subfunción de los colores relativos, nivel 125) | BCD: Firefox 133 y Safari 18, así que Baseline desde Firefox 133 (noviembre de 2024); web-features no le da fecha propia | 13 commits: 622fd7a782e … 9347d9baaa1, a7fccf6b808 y 175d1e860fb (`CSSRelativeColorPreserveNone`, que nace `stable`). Reorganiza cómo se calculan los colores (mapa de canales, palabras clave en `calc()`, resolución tardía): toca el CSS de color de todas las páginas | **149/59**, 28 ficheros (7 nuevos) | **3–4 h**, el mayor riesgo del nivel |

**Fuera:** `anchor-scope` (es de *anchor positioning*, que FlyWeb no tiene), `font-variant-emoji` (Safari no lo tiene),
márgenes de `@page` (`PageMarginBoxes`, ni Firefox ni Safari), `Request.duplex`, COOP `noopener-allow-popups` (solo
Safari), WebHID en *workers*, WebXR y lo de Privacy Sandbox o FedCM.

### 3. Flags a `stable` sin Baseline (16 que pasan y 18 que nacen en `stable`)

- **Interoperabilidad y arreglos, portables** (~1 h entre todos; 40/14 en 10 commits, casi todos los rechazos son del
  json5): `BreakIteratorHyphenMinus` (a74ffca5520), `CheckIfHighestRootContainsPositionAnchorNode` (cdd39e79efc),
  `FindDecomposedInShortText` (77147f8ac66) y `FindTextSkipCollapsedText` (91379783ec7) de la búsqueda en la página,
  `HTMLEmbedElementNotForceLayout` (9b8c2484180), `HTMLObjectElementFallbackDetachContentFrame` (d04e13c6871),
  `InitialLetterRaiseBySpecified` (3561ed8aa28), `LineBoxBelowLeadingFloats` (1fea2fe8c97), `UseSelectionFocusNodeForCaretNavigation`
  (1e4c5f5101d) y **`TextTransformAndSecurityFix`** (45cfc7335f9, fusionado a M131: cierre con `text-transform` y
  `-webkit-text-security`; para FS.17).
- `CSSAtPropertyStringSyntax` (8ef3ec8c032 + 11de2beffb6, 8/3): `@property` con `syntax: "<string>"`. No consta en BCD; es
  barato y de interoperabilidad con la especificación.
- `SvgExternalResources` (5e5a9e44286 + 1cdb2f557b7, 25/6): referencias a recursos SVG de otro documento
  (`fill: url(otro.svg#degradado)`), como Firefox y Safari. Recomiendo portarlo.
- **Sin efecto o fuera:** rendimiento (`HitTestOpaqueness` y `…OmitLineBox`, `SvgEagerPresAttrStyleUpdate`,
  `FastNonCompositedScrollHitTest`), métricas (`ContinueEventTimingRecordingWhenBufferIsFull`), no Baseline (`FontVariantEmoji`,
  `FontVariationSequences`, `SystemFallbackEmojiVSSupport`, `PageMarginBoxes`, `RTCRtpScaleResolutionDownTo`), apagado en
  FlyWeb (`WebGPUCanvasContextGetConfiguration`, `WebHIDOnDedicatedWorkers`, `FedCmWithStorageAccessAPI`,
  `FledgeRealTimeReporting`, `DirectSockets`, `WebXRHandInput`, `CSSAnchorScope`).
- `ElementGetInnerHTML` pasa a apagada en el código: ya está así en la 1.14 (c5a094a9ab).

### 4. Fuera de Blink

- **ML-KEM (`net::features::kUseMLKEM`, 4beeb73c814): decisión.** Chrome 131 manda `X25519MLKEM768` (0x11ec) en vez
  de `X25519Kyber768Draft00` (0x6399), en TLS (`ssl_client_socket_impl.cc`) y en QUIC (`quic_stream_factory.cc`). FlyWeb
  manda hoy Kyber (`chromium_src/net/base/features.cc`). El BoringSSL de la 116 (ae88f198) no tiene ML-KEM; el porte es
  `crypto/mlkem/mlkem.cc` (1097 líneas, autocontenido salvo Keccak, que la 116 ya trae en `crypto/kyber`),
  `include/openssl/mlkem.h`, la clase `X25519MLKEM768KeyShare` de `ssl_key_share.cc` (~90 líneas), el grupo
  `SSL_GROUP_X25519_MLKEM768` y el `NID`, las listas de fuentes de BoringSSL en Chromium y las dos líneas de `net/`. **Se
  puede probar en la nube** sin LOCAL: BoringSSL compila solo con CMake y trae los vectores oficiales
  (`mlkem768_*_tests.txt`, NIST incluidos). Sin esto, la huella TLS del 131 no es la de Chrome 131 (principio 13: el
  nivel no se da por cumplido). Es de SEGURIDAD-PORTES (principio 13: lo que toca BoringSSL). **3–5 h**, en paralelo.
- `services/network`: `CoopNoopenerAllowPopups` se enciende (no Baseline: fuera); el resto es rendimiento.
- `chrome/common`: `HttpsFirstBalancedMode` (navegación: lo decide la política HTTPS de Brave) y cambios de interfaz.
  Nada que vea una web.
- Fuentes y preferencias web por defecto: sin cambios en Mac.
- **Declaración:** `flyweb_engine_level` 131, `flyweb_version` 1.15, **`flyweb_engine_full_version` = 131.0.6778.265**
  (la última Stable de Mac al 100 %, 07–14-01-2025, según versionhistory; lleva justo la V8 13.1.201.22),
  `platformVersion` mínimo 11.7.10 (129–138).

### 5. Configuración de campo (Finch), 130 → 131 en Mac

De lo que cambia, casi todo es interfaz, *autofill* o rendimiento. Dos cosas confirman escapes del §6, porque estaban
encendidas por campo en la 130 y en la 131 pasan a código: `BeforeunloadEventCancelByPreventDefault` y
`MouseDragOnCancelledMouseMove`. `WebAudioBypassOutputBuffering` entra como experimento con política de empresa: fuera
(experimento, no despliegue). ALPS sigue pendiente de los JA4 de LOCAL-4 (F4.8).

### 6. Escapes de niveles anteriores (barrido nuevo: flags `stable` de 117–131 contra la 1.14)

Para cada nivel 117–131 se leyó el json5 de su cabeza de rama y se comparó con el de la 1.14. Hay **354 flags** que
Chrome tuvo en `stable` en algún nivel y FlyWeb no tiene en `stable`; **287 no salen por nombre en ningún documento**.
Muchas son falsos positivos: niveles que portaron el estado final sin la flag (`@starting-style`, `light-dark()`,
`<details name>`). Lo fiable son las que **la 1.14 sí tiene en su json5, pero apagadas**, más la pasada de
`superficie.html`. De ahí salen, quitando Privacy Sandbox, lo que Brave quita, lo que no es Baseline y lo interno:

| Qué | Chrome | En FlyWeb | Coste |
|---|---|---|---|
| `customElements.getName()` (`CustomElementsGetName`) | 117; **Baseline 2023** | flag `experimental`; `superficie.html` lo ve faltar | minutos (encender; comprobar que la 116 lo trae completo) |
| `event.preventDefault()` en `beforeunload` pide confirmación (`BeforeunloadEventCancelByPreventDefault`) | 119 (campo en la 130, código en la 131) | `experimental` | minutos (8188517aca3) |
| No resolver `data:` en `<use>` de SVG (`RemoveDataUrlInSvgUse`) | 120, **seguridad** | `experimental` | minutos |
| Quitar el *dangling markup* de `target` (`RemoveDanglingMarkupInTarget`) | 119, **seguridad** | `experimental` | minutos |
| Selección de texto con `mousemove` cancelado (`MouseDragOnCancelledMouseMove`) | 125 (campo en la 130) | sin la flag | 1583e508e68 + 165b28d3f3e |
| `<input type=date>` como `inline-block` (`DateInputInlineBlock`) | 122 | `test` | 5ff04491da5 |
| Copiar texto sin `text-transform` (`IgnoresCSSTextTransformsForPlainTextCopy`), `insertLink` en `inputType`, `lostpointercapture` al quitar el nodo | 127, 125, 122 | sin la flag | horas entre los tres |
| `content-visibility: auto` implica `contain-intrinsic-size: auto` | 117 (`content-visibility`, Baseline 2024) | sin la flag | por medir |
| Atributos de importación desconocidos dan error (`ImportAttributesDisallowUnknownKeys`) | 118 (Baseline 2025) | sin la flag | por medir |
| `SVGClipPathElement.transform` | (`superficie.html`) | falta | minutos |

Lo demás de la pasada de superficie ya estaba clasificado: Brave (`ReportingObserver`, `navigator.connection`, Web
Serial, File System Access), Privacy Sandbox o FedCM, no Baseline (CloseWatcher, EditContext, `@scope`, *anchor
positioning*, *scroll snap events*, LoAF, `scheduler.yield()`, `interpolate-size`, `text-spacing-trim`,
`select.showPicker()`) o apagado por decisión (WebGPU). **Propuesta:** portar la tabla en el 131 (1–2 h), y una
auditoría completa de las 287 en una fila aparte. El método: para cada flag, el commit que la quita (`bisflag.py`) y
mirar si su código está en la 1.14. Son unas 3–4 h de MOTOR, sin compilar.

### 7. Los cuatro aplazados del 130 (aprobados para el 131), con sus dependencias

| Flag | Dependencia que faltaba | Medida (cadena entera) | Coste |
|---|---|---|---|
| `PseudoElementsCorrectInGetComputedStyle` | a97d3e46b05 (`CSSComputedStyleFullPseudoElementParser`, 124: otro escape) + 471ed5d216b (`kPseudoIdPlaceholder`/`kPseudoIdFileSelectorButton`) | 45/10, 15 ficheros | 1–1,5 h |
| `PaintHighlightsForFirstLetter` | 1660cb958aa (`MarkerRangeMappingContext`: optimización del mapeo de desplazamientos del pintado de resaltados) | 49/17, 11 ficheros | 1,5–2 h; toca el pintado de selección y resaltados |
| reserva de `<meter>` (`MeterAppearanceNoneFallbackStyle` + `MeterDevolveAppearance`) | 02492b88a85 (`StyleUAShadowHostData`) | 45/12, 24 ficheros | 1–1,5 h |
| `MultiSmoothScrollIntoView` | `SetScrollOffset` que devuelve `bool`: viene de 621af243570 (eventos de *scroll snap*, no Baseline); se porta solo el cambio de firma | 23/5 + la firma | 1 h |

### 8. Lo apagado (regla 19) con la V8 13.1, y la rama M131

Sin cambios en lo que decide la regla 19: Maglev y `maglev_untagged_phis` siguen encendidos upstream y apagados en
FlyWeb hasta la decisión del **132** (V8 13.2 LTS). `turboshaft_wasm` sigue apagada upstream, y
`turboshaft_instruction_selection`, `turboshaft_csa` y `regexp_simd` siguen como en la 1.14.

Fusiones de la rama M131 (72 en Blink) para FS.17, además de `TextTransformAndSecurityFix`: `EncodedFormData`
(d8f78a1c886, 0b1d6d2efc0), `XMLDocumentParser` con *isolate* nulo (bef5f3efe54), `AcceptLanguagesWatcher` (5973dd14151),
`WorkerNavigator::NotifyUpdate` (968edf7d9de), `DocumentLoader::CalculateOrigin` (8ecb19166b6), las de accesibilidad y
la de Web Serial (apagado). **4888675b6c9** arregla `ObserveNestedDeclarations` del inspector, que porté en el 130 (solo
DevTools; lógica, no memoria): propongo que vaya en la 1.14.1 con `seg/oopsif` o en el 131. ff0d92a5dd6 ya está (es
1116bad3e0a, FS.13).

### 9. Estimación en horas reales, con el 130

El 130 en código, del paso de V8 a la cabeza final: **~1 h 35 min de MOTOR** (15:50–17:25) para unos 215 hunks y 90
rechazos, más el recorte de superficie. La estimación del §11 del 130 decía 5–7 h: **cuatro veces pesimista para MOTOR**.
LOCAL (7–8 h) es lo que manda en el total.

| Partida | 130 (real) | 131 (estimado) | Por qué |
|---|---|---|---|
| Paso de V8 | ~10 min (más `fast_float`) | 10–15 min | una línea en Blink; sin dependencias nuevas |
| FS.17 en paralelo | FS.14 ~3 h | 4–7 h | rebase de `patches/v8` + **ML-KEM** (3–5 h, probado en la nube) |
| Baseline | ~45 min (~190/65) | 1,5–2,5 h (~227/85) | colores relativos sobre `currentcolor` y `::details-content` con la cascada |
| Flags del 131 | ~20 min | 30–45 min (~73/23, con `@property`) | casi todo json5 |
| Los cuatro aplazados | — | 1,5–2,5 h (~162/44) | dependencias incluidas |
| Escapes del §6 | — | 1–1,5 h | encendidos y commits pequeños |
| Declarar + `motor-131.html` + `wpt-131-lista.txt` + `version-1.15.md` | ~20 min | 30 min | — |
| **MOTOR en total** | **~1,6 h** | **5–7,5 h** | unas 2,3 veces el volumen del 130 |
| LOCAL (Static, ASan, Release y pruebas) | 7–8 h (en curso) | 7–8 h | igual |
| Arreglos tras las pruebas | por ver | 2–4 h | color y cascada tocan el CSS de todas las páginas |
| **Total, del paso de V8 a la entrega** | — | **13–17 h** | con FS.17 en paralelo y sin esperar a ML-KEM para el Static de Blink |

**Regla 18:** sale entero como 1.15 con la V8 13.1. Nada es «muy amplio»: el porte mayor (colores relativos) es del
tamaño de *nested declarations*.

**Decisiones que pido a COORDINACIÓN:** (i) V8 13.1.201.22; (ii) **ML-KEM** en la 1.15, portado por SEGURIDAD-PORTES
(FS.17) y probado con los vectores de BoringSSL antes de LOCAL; sin él, el 131 no cumple el principio 13; (iii) la
Baseline del §2, incluidos los colores relativos sobre `currentcolor` (el porte de más riesgo); (iv) flags del §3 con
`SvgExternalResources`; (v) **escapes del §6 en el 131** y la auditoría completa como fila aparte; (vi) 4888675b6c9 en la
1.14.1 o en el 131.

### 10. Decisiones de COORDINACIÓN-6 (15-10; valen como de Titín, regla 16)

- **(i)** V8 13.1.201.22 y declarar 131.0.6778.265 con `platformVersion` 11.7.10: sí.
- **(ii)** ML-KEM en la 1.15: sí. Lo lleva SEGURIDAD-PORTES-3 en **FS.17** (encargo de COORDINACIÓN); MOTOR no lo toca.
- **(iii)** `::details-content` y los colores relativos sobre `currentcolor`: sí. Los colores, con **las WPT de color
  del 131 completas** comparadas con CfT 131, por ser el porte de más riesgo.
- **(iv)** Flags del §3: como se propone.
- **(v)** Escapes del §6: **los dos de seguridad se adelantan a la 1.14** (primero se dijo 1.14.1 con `seg/oopsif`;
  COORDINACIÓN-6 lo cambió el 15-10, ~18:10: la 1.14 = ccc74ea171 + los escapes, y la 1.14.1 = la 1.14 + `seg/oopsif`). Están hechos en brave-core
  `nube/escapes-seg-1.14.1` **303e498fb5**, sobre `ccc74ea171`, y se funden sin conflictos con `seg/oopsif`
  57c1b3fa2a. Prueba: `FlyWeb/tools/seg-1.14.1.html`. Los revisa SEGURIDAD-PORTES-3. El resto de escapes van en el 131.
  La auditoría completa va en **FM.22, después de entregar el 131**.
- **(vi)** 4888675b6c9 en el 131 (solo DevTools).
- **Orden:** el 131 empieza cuando LOCAL-4 entregue la 1.14.

### 11. Portado (MOTOR-11, 15-10): brave-core `nube/motor-131`

Sobre la 1.14 (`nube/escapes-seg-1.14.1` 303e498fb5) + `seg/ml-kem` fc0f45c433 (FS.17). Un commit por función; cada uno
con `chk.sh` (los parches aplican sobre la 116; los de V8, sobre una 13.1.201.22 limpia) y, donde toca, `gencss.sh`.
Lista de commits con su estado: `FlyWeb/tools/port/nivel131-commits.tsv`.

| Commit | Qué | Upstream y adaptación |
|---|---|---|
| 2331bba696 | FS.17: `seg/ml-kem` fc0f45c433 | ML-KEM en TLS y QUIC (SEGURIDAD-PORTES-3), sin conflictos |
| **9b19e7dafc** | Paso de V8: 13.1.201.22 (también `nube/motor-131-v8`) | §1; `module_record.cc` con `GetImportAttributes()` (el inventario no lo vio: `V8_DEPRECATED` + `-Werror`) |
| 8ac23ca71a, 83308d0028 | FS.18: `seg/v8-13.1` 7b3c3e6cf5 y 364a9d554f | revisión del paso (época 16) y arreglo de compilación: fuera el parche de `wasm-objects.cc`, que usaba `wasm_to_js_generic_wrapper`, que ya no existe en la 13.1 (aplicaba limpio y no compilaba: **fallo mío del paso**, lo vio SEGURIDAD-PORTES-3); quedan 62 |
| 57dda2531f | `::details-content`, cascada y `getComputedStyle()` con pseudoelementos | 18 commits; la cascada (9065c891224, 8a5bc8d0550, 951ace75914) en su forma final de la 131, a mano; `MatchResult` con el orden del árbol = índice del ámbito (idea de f4c890d7e6f, M118) |
| 66a8436ed4 | colores relativos sobre `currentcolor` | **comportamiento de la 131 sobre el analizador de FlyWeb del 125**, no la serie de upstream (que rehace un `ColorFunctionParser` que FlyWeb no tiene): origen absoluto resuelto al analizar; si no, `CSSRelativeColorValue`, resuelto al calcular el estilo o, si el origen es `currentcolor`, al usarse. La puerta es la WPT de color completa frente a CfT 131 (decisión de COORDINACIÓN-6) |
| f871534a91 | flags del §3, `@property <string>` y `SvgExternalResources` | 8 de las 10 flags de interoperabilidad; `BreakIteratorHyphenMinus` y `TextTransformAndSecurityFix` no aplican a la 116 (la 116 ya se comporta como el arreglo o no tiene el código); confirmado por SEGURIDAD-PORTES-3 (FS.18) |
| 1481da3472 | reserva de `<meter>` | `StyleUAShadowHostData` de 02492b88a85 sin su parte de `<img>`; reglas de `html.css` sin `@supports blink-feature()` |
| f18bc09f0c | `MultiSmoothScrollIntoView` | 5 commits; de 621af243570 solo la firma de `ProgrammaticScrollHelper()` |
| e2ed217536 | escapes del §6 y 4888675b6c9 | `CustomElementsGetName` y `DateInputInlineBlock` encendidas (el código de la 116 es el que publicó Chrome); 885747b4b60 (`style_adjuster.cc` a mano), 2623d401a2e, a451e490628, 1583e508e68 + 165b28d3f3e (`WebFeature` 4754), fb41d7f417e, aa36610ec66 (sin el enum de `ui/accessibility`: `insertLink` cuenta como `insertText` para la accesibilidad), 2ff15031068 y 4888675b6c9 sobre nuestro observador de `inspector_style_sheet.cc` |
| **2f04e8614a** | declara 131 / 1.15 | 131.0.6778.265, `platformVersion` mínimo 11.7.10, `FLYWEB_BUILD_NUMBER` lo sube LOCAL |
| **01b123af05** | FS.18 cerrada: `seg/v8-13.1` 634cedc130 | resultados de d8 en `FLYWEB-SECURITY.md` (pruebas de FlyWeb 8/8, mjsunit 7279/7280, Wasm con `--stress-wasm-code-gc` 394/394) |
| 391db5f63d | arreglos de la 1.14 (`nube/arreglos-1.14` d12847a77f) | `togglePopover`, *nesting*, `insertRule`, superficie y WebSQL (ver «Nivel 130» §12); `PopoverAnchorRelationships` sigue experimental en la 131, así que el diccionario se ignora igual. `css_selector.cc`: fusión a tres bandas del contenido, limpia |
| **1419974606** | FS.19: modo de petición de los recursos SVG externos, como la 131 | f871534a91 llamaba a `SVGResource::Load(document, kCrossOriginAttributeAnonymous)`, que la 116 no tiene: **no compilaba** (lo vio SEGURIDAD-PORTES-3; fallo mío del porte). Ahora `Load(Document&, CrossOriginAttributeValue)`: sin valor, mismo origen; con él, CORS (`fill`, `stroke`, `clip-path` y `marker-*` usan anónimo); filtros, `<use>` y `LoadWithoutCSP`, mismo origen; `SVGResourceDocumentContent::Fetch` hace `CHECK(AllowedRequestMode)` en vez de forzar el modo. En la 116 ya era todo de mismo origen (`Fetch` lo forzaba): lo nuevo es CORS anónimo para esas propiedades, como la 131. Visto bueno de SEGURIDAD-PORTES-3 (~20:44) |
| **55b9b4d9d2** | OOPSIF: `seg/oopsif` 57c1b3fa2a (FS.15) | la 1.14.1 es la 1.14 + OOPSIF (`local/1.14.1` 13138902af de LOCAL-4); sin pasos atrás, va también en la 1.15. Fusión limpia: los 7 parches no los toca el 131. **Cabeza para LOCAL** |

**Fuera de la 1.15: `PaintHighlightsForFirstLetter` (decisión de COORDINACIÓN-7, 15-10, ~19:36).** Su dependencia
1660cb958aa (`MarkerRangeMappingContext`) da 25 *hunks* rechazados en `ng_highlight_painter.cc`/`.h`,
`ng_highlight_overlay.cc` y `ng_ink_overflow.cc` sobre una base que ya tocó RubyLB: mucho riesgo en el pintado de la
selección, que se ve en todas las páginas, para algo marginal (las marcas de buscar en la página, ortografía, gramática
y resaltados no se pintan en la parte de `::first-letter`). Pasa a **FM.22** como porte propio, con su Static y su ASan.
**WPT que por eso no coinciden con CfT 131: ninguna.** La única prueba de f30d9fddc4b es la interna de Blink
`paint/markers/first-letter.html` (no WPT). Comprobado en la 131.0.6778.265: ninguna WPT de `css/css-highlight-api/` ni
de `css/css-pseudo/` con resaltados, `target-text`, ortografía o selección usa `::first-letter` salvo
`active-selection-025.html` y `-027.html`, que son de `::selection` (no son marcas) y tienen la misma expectativa en
`TestExpectations` en la 116 y en la 131.

Comprobación: `FlyWeb/tools/motor-131.html` (en un origen http(s); en Chromium 141 sale todo ok salvo la versión y la
prueba de que `Float16Array` y `using` aún no existen, que salen en la 134–135) y `wpt-131-lista.txt` (43 entradas,
con `css/css-color/`, `html/rendering/the-details-element/` y `html/semantics/forms/the-meter-element/` enteros).
«Para la web» en `version-1.15.md`.

### 12. Anchor positioning (FM.28, MOTOR-13, 20-10): FlyWeb 1.15.2

Porte grande dentro del nivel 131 (regla 18). Era lo que «Fuera» de los §2–§3 dejaba aparte (`anchor-scope`,
`CSSPositionArea*`, `CSSInsetAreaProperty`). brave-core `nube/motor-131-anchor` sobre la 1.15.1: la cadena entera de
upstream de 2023 a la rama de la 131, unos 230 commits en cuatro fases (`FlyWeb/tools/port/anchor-fases.tsv`), con los
arreglos posteriores a la 131 que pidió SEGURIDAD-PORTES (FS.21). Va igual que en la 131: `anchor()`/`anchor-size()`
(no en insets ni márgenes), `position-area`, `position-try-fallbacks`/`-order`, `@position-try`,
`position-visibility`, `anchor-scope` y el `anchor-center` nuevo. **No va:** el atributo `anchor` y el ancla implícita
de quien abre un popover (flags experimentales en la 131), `<select>` personalizable y la relación de accesibilidad
`aria-details` entre ancla y anclado (74a5382ac8b, por la infraestructura de accesibilidad de la 116). Adaptaciones a la
116, controles y trampas en `FlyWeb/tools/port/README.md` («Porte grande con fusión a tres bandas»). Comprobación:
sección «Anchor positioning (1.15.2)» de `motor-131.html` y `wpt-fm28-lista.txt`. Detalle y estado en
`version-1.15.2.md`. En la misma versión, `KeyboardFocusableScrollers` (encendido en el 130, d7518d129e) vuelve a
`experimental`, como en Brave 1.73 (regla 20; decisión de COORDINACIÓN-8, 20-10; `brave-vs-parches-motor.md`, punto 2), y
`motor-130.html` lo espera apagado. FS.22 (4 CVE críticos de 117–128) entra en la 1.15.2 por fusión.

## Nivel 132 (inventario para decidir, 27-10, MOTOR-25; FM.45, sobre la 2.0.3)

Inventario de FM.45 con el método de los niveles 129–131, **para decidir COORDINACIÓN antes de portar**. La base es ahora la
128 con Blink y V8 en el 131, así que se mide sobre la 128.0.6613.138 + los parches de la -p24 (23f2d547d9). Fuentes:
web-features 3.44.0 y BCD 8.1.7 (`baseline-nivel.js 132`); `runtime_enabled_features.json5` de la 131.0.6778.268 y la
132.0.6834.245 (cabeza de M132-LTS; `flags-nivel.py`); commits del tramo de main 128→132 (f88bd091e24..9eb617a342f);
`base::Feature` de net, network, content, chrome/common y permisos; Finch de Mac 131 → 132; `include/` de V8 13.1.201.22 →
13.2.152.56; Brave 1.73.105 → 1.74.51 (que llevan justo la 131.0.6778.265 y la 132.0.6834.160); y la receta de macOS 11+ de
INVESTIGACIÓN-MOTOR-5 (`macos11-niveles.md`, #545). Hecho con subagentes de lectura; sin portar ni compilar nada.

**Resumen: nivel pequeño, con una pieza grande (`writing-mode: sideways-*`) y una decisión de la regla 19 (Maglev).**
Fuera de Blink no cambia nada que vea una web ni un servidor (TLS, HTTP/2, QUIC y Client Hints como en el 131), Brave 1.74 no
apaga nada nuevo y **el 132 no trae ninguna API de macOS 11+** en código de producción. Estimación (horas de papel, que con
el ritmo real de 129–131 suelen ser la mitad): **Blink 9–14 h + escapes 2,5–3,5 h + V8 2,5–3,5 h (4,5–7 h con Maglev)**.

### 1. Versión declarada y V8

- **Declarar 132.0.6834.160**: la última Stable de Mac al 100 % (28-01 → 04-02-2025) y la de Brave 1.74.51.
  `platformVersion` sigue en el mínimo que admite el 132. Comprobación de huella: `Sec-CH-UA` con
  `"Not A(Brand";v="8", "Chromium";v="132"` (semilla 132).
- **V8 13.2.152.56** (5eabe0e1, cabeza de `branch-heads/13.2`, M132-LTS): la .36 de la .160 más las fusiones de
  seguridad de la LTS. Como en el 131, se toma la cabeza de la rama; la V8 no sale en el UA. El json5 de Blink, el de la
  cabeza de la rama: ya trae apagados `CSSRelativeColorLateResolveAlways` y `SvgInlineRootPixelSnappingScaleAdjustment`.
- **Lo que no compila con la 13.2** (dos ficheros de Blink, 30–45 min): `EmbedderRootsHandler::IsRoot` desaparece
  (`thread_state.cc:39`, sobrescrito con `final`: se borra); `SetRAILMode()` y `UpdateLoadStartTime()` pasan a
  `V8_DEPRECATED` (`main_thread_scheduler_impl.cc:1513` y `:1930`, que ya lleva parche nuestro): `SetIsLoading()`, como
  en la 132, y fuera `RAILModeToV8RAILMode()`, que queda sin uso (`-Wunused-function`). `FastApiTypedArray` pasa a
  `V8_DEPRECATED` pero nadie lo usa (comprobado en la 128, PDFium, Brave 1.69 y la -p24). gin y DevTools no se tocan; sin
  dependencias nuevas.
- **JS y Wasm: nada nuevo sale.** Desaparece `--expose-wasm` (Wasm se oculta con `--jitless`, que ya usa
  `proxy_resolver_v8`; solo sale un aviso en stderr).
- **`patches/v8`** (SEGURIDAD-PORTES): de 61, 26 ya están dentro, 11 tienen su arreglo en upstream, 1 se rehace (gancho de
  Brave en `compiler.cc`) y 23 aplican; quedan ~24, época de caché 18. Que apliquen no quiere decir que compilen (en el
  131, `wasm-objects.cc`).
- **CPU:** nada exige AVX (lo nuevo con AVX/AVX2/VNNI comprueba la CPU o es experimental).

### 2. Lo apagado (regla 19) con la V8 13.2

| Opción | FlyWeb | 13.2 | Propuesta |
|---|---|---|---|
| `turboshaft_wasm` (y la ISel de Turboshaft para Wasm en x64) | sin parche | **pasa a `true`** | encendido, como upstream; sus arreglos de rama ya vienen; prueba con mjsunit/wasm |
| Maglev | apagado | encendido | **decidir**: encenderlo exige portar la parte de Maglev de CVE-2025-13223 (4cf93118, ~10 líneas) y medir Speedometer 3 y JetStream 2 en la 5,1 y la 6,1 (+2–4 h) |
| `maglev_untagged_phis` | apagado | apagado upstream desde el 10-03-2026 (7076ba13) | se cierra la fila: «igual que upstream» |

Cambian también `flush_liftoff_code` y dos de GC en segundo plano (a `true`): memoria, sin efecto visible.

### 3. Baseline del 132

| Función | Baseline | Porte | Tamaño | Coste |
|---|---|---|---|---|
| `writing-mode: sideways-rl` / `sideways-lr` (`SidewaysWritingModes`) | 2025-03 | 41 commits `sideways:` desde la 128; se enciende en 5a1ba09c9cd. Toca flex, fragmentación, SVG `<text>`, formularios y `position-try`. **Antes, la serie de `shape-outside` del 129 (§5)** | 214 ficheros, +4370/−688 | **4–6 h**, el riesgo del nivel; regla 17 |
| `toggle`/`beforetoggle` en `<dialog>` (`DialogElementToggleEvents`) | 2025-09 | bec792eeaac, a076abdd30d, 84daae16519, ef1155930aa | 11 ficheros | 0,5–1 h |
| `Request.bytes()`, `Response.bytes()`, `PushMessageData.bytes()` | 2025-01 | d741eabf4a5, 5c7532a8972, 812475a1cb0 (`Blob.bytes()` es del 144) | 42 ficheros | 0,5–1 h |
| `anchor-size()` en insets y márgenes (`CSSAnchorSizeInsetsMargins`) | subfunción, 2026-01 | dc6dd8db71a, d4e557d30af, eb63933a4cb: lo que la 1.15.2 dejó fuera | — | 0,5–1 h |
| IndexedDB: `NotReadableError` | — | 3fa6ab8b214 | — | minutos |

**Fuera:** Device Posture, Element Capture, la *signal API* de WebAuthn (superficie nueva para huella), FedCM, Protected
Audience, WebGPU y WebXR.

### 4. Flags a `stable` sin Baseline (~2,5–3,5 h)

Portables, de interoperabilidad y arreglos: `SelectionIsCollapsedShadowDOMSupport` (bea8eb7a19a),
`TopLayerInactiveDocumentExceptions` (ac7cfddd363; estabilidad, a SEGURIDAD-PORTES), `TextSegmentBoundaryForElementWithFloatStyle`
(0801480790e), `ListItemWithCounterSetNotSetExplicitValue` (f04300ab682, 24353eb454f), `SkipTemporaryDocumentFragment`
(398837e6773), `ScheduleSelectionChangeOnBackspace` (340e132d8e3), `CalendarPickerMonthPopupButtonDisabledColor`
(f1bae6ee920) y `ViewTransitionOverflowRectFromSurface` (6d0d43dfc2d). **Aplazado:** `FindRubyInPage` (23 commits, solo
Cmd-F). El resto: métricas, rendimiento, Android, FedCM o Privacy Sandbox.

**`KeyboardFocusableScrollers` vuelve a `stable`** (regla 20): la 1.15.2 lo bajó a `experimental` como Brave 1.73, y
Brave 1.74 quita ese parche («Revert when cr132 is merged»). Con 199d1a77501, 6f8b4173951 y 5800d804208 si la 2.0 no los
trae ya: 1–2 h. `motor-132.html` lo espera encendido.

### 5. Escapes de niveles anteriores

La 2.0.3 no tiene en `stable` 47 flags que la 131 sí; casi todas ya clasificadas en 129–131. Lo nuevo: cinco que sobre la
116 quedaron «fuera por coste» dependen de código del 129 que ahora aplica sobre la 128, y se portan **antes** de abrir el
132 (regla 18): la serie de `shape-outside` del 129 (763b1682aba … 1e0aa4d1b7a: `ShapeOutsideClippedImageFix` y
`ShapeOutsideWritingModeFix`; la necesita `sideways`), `DirAutoFixSlotExclusions` (73881d441c2), `TextInputNotAlwaysDirAuto`
y `ScrollIntoViewRootFrameViewportBugFix` (6916f1ac980).

### 6. Fuera de Blink, privacidad y macOS

- **Huella de red, sin cambios:** los 55 commits de BoringSSL son de DTLS 1.3 o pruebas (JA4 como el 131); HTTP/2 solo
  histogramas; QUIC, nada en los parámetros del cliente. `Sec-Fetch-Storage-Access` no se envía sin `StorageAccessHeaders`.
- **Para valorar (no son del nivel):** `NoReferrerForPreloadFromSubresource` (mejora de privacidad, pequeño: **propongo
  portarlo**); `EnableStaticCTAPIEnforcement` (~1 día) e `IgnoreHSTSForLocalhost` (horas), a SEGURIDAD-PORTES;
  `CrabbyAvif` (decodificador AVIF en Rust, grande) y `KeepAliveInBrowserMigration`, aplazados.
- **Regla 20:** Brave 1.74 solo mueve sus ajustes de features de sitio y adapta sus ganchos a Blink 132 (farbling,
  `cached_permission_status.cc`, navigator, plugins, media_devices): conservarlos al portar. `PartitionVisitedLinkDatabase`
  (partición de `:visited`) sigue en experimento en Chrome: estudio aparte como privacidad por encima de Brave.
- **macOS 11+:** ninguna serie «Assume macOS 11+» ni de 10.15 en el tramo (solo el paso al SDK 15.1). `AXCustomContent`
  (611aefda, inspector de accesibilidad) es de 11.0 y no es de Blink: **no se porta**. ScreenCaptureKit (12.3+) nunca se
  crea en Mojave. Se respeta `macos11-niveles.md` §7: no portar las series de 11+ (129) ni de 12 (139).

### 7. Regla 17, orden y decisiones

- **Filas FS (regla 17):** una para `sideways` (41 commits, 214 ficheros) más la serie de `shape-outside`, y otra para la
  V8 13.2 (rebase de `patches/v8`, la tabla del §2 y, si se enciende Maglev, 4cf93118).
- **Orden:** (1) escapes del §5; (2) V8 13.2 y los dos ficheros de Blink; (3) Baseline pequeño y flags del §3–§4;
  (4) `sideways` en su propio commit, el último, para poder quitarlo si la regla 17 o LOCAL lo tumban; (5) `motor-132.html` y
  la lista WPT.
- **Para COORDINACIÓN:** (a) declarar 132.0.6834.160 con la V8 13.2.152.56; (b) `turboshaft_wasm` encendido sin parche;
  (c) Maglev: encender en el 132 (4cf93118 + medición) o aplazarlo con su motivo; (d) `maglev_untagged_phis` cerrado;
  (e) `KeyboardFocusableScrollers` a `stable`; (f) `sideways` en la misma versión del nivel o en una versión aparte (regla 18: grande, pero
  no tanto como RubyLB); (g) `NoReferrerForPreloadFromSubresource` dentro.

### 8. Portado (MOTOR-25, 27-10): brave-core `nube/motor-132`

Decisiones de COORDINACIÓN-16 (27-10, fila FM.45): (a), (b) y (d) como se proponen; (c) **Maglev apagado** (rectificado: ~15 arreglos de Maglev posteriores a la LTS 13.2, 4–6 días; FS.28); (e) `KeyboardFocusableScrollers` como lo expone CfT 132 (`stable`); (f) `sideways` en la misma versión, último commit;
(g) `NoReferrerForPreloadFromSubresource` dentro (resultó ser CVE-2025-4664, ya portado en la 2.0.0). 12 commits sobre
`nube/motor25-p25` fbe2394fed, cabeza **fbe98109** (con FS.27 fundida antes de `sideways`; un force push de la rama propia, sin el sí de Titín: avisado); tabla en [`version-2.1.0.md`](version-2.1.0.md). Medidas reales: casi
todo aplicó sin rechazos sobre la 128 (escapes 0–2 por commit tras añadir 291f585e77 y 940fa8c2098/96483a7f06b a sus series;
`sideways`, 7 rechazos en 4 ficheros). Adaptados a mano: IDB (`OnLoadComplete` con `bool` en la 128), `isCollapsed`,
`style_engine.cc`, y en `sideways` el sentido de los deslizadores (la 128 voltea al revés que el upstream posterior), el
caret de bloque vacío y `SerializedAnchor`. `anchor-size()` en insets ya estaba (código del 131): solo el flag. Fuera:
`SkipTemporaryDocumentFragment` (refactors de 129–131 en `node.cc`), `ViewTransitionOverflowRectFromSurface` (sin flag en la
2.0) y el refactor 199d1a77501. `patches/v8`, en FS.28; `IgnoreHSTSForLocalhost` (a5e738f2321) entra antes de `sideways` (SEGURIDAD-PORTES-9); regla 17 de `sideways` y
`shape-outside`, FS.27. Comprobación de parches: `FlyWeb/tools/port/chk128.sh <base>` (el `chk.sh` antiguo compara con la
116). Trampa: dos áreas que tocan el json5 no se generan seguidas sin commit en medio (la segunda pisa a la primera).

## Nivel 133 (inventario para decidir, 28-10, MOTOR-27; FM.49, sobre la 2.1.1)

Base: 128.0.6613.138 + brave-core `nube/motor-211b` ef850e44 (2.1.1). Fuentes: web-features 3.44.0 y BCD 8.1.7
(`baseline-nivel.js 133`); json5 de la 132.0.6834.160, la 133.0.6943.141 y el parcheado de bc (`flags-nivel.py`); tramo de main
47a3549fac1..72dd0b377c0 (21 207 commits) y rama 72dd0b377c0..133.0.6943.141 (1912); V8 13.2.152.56 → 13.3.415.23; `base::Feature`
de net, network, content y chrome/common. Tres subagentes de lectura (Blink, V8, fuera de Blink); sin portar ni compilar.

**Resumen:** nivel mediano. Lo grande es `text-box-trim` (Baseline de todos los motores) y una sorpresa en V8: **la 13.3 tiene
menos arreglos de seguridad que la 13.2 LTS que llevamos**. Fuera de Blink la huella de red no cambia; ninguna API de macOS 10.15+
sin guarda. Papel: Blink 20–28 h (lo propuesto), V8 4–6 h, fuera de Blink ~4 h.

### 1. Versión declarada y V8

- **Declarar 133.0.6943.141** (última Stable de Mac del 133; su DEPS fija V8 93c6f108 = `branch-heads/13.3` = 13.3.415.23).
  Pendiente comprobar con la Brave 1.75 qué .x lleva (sin acceso a brave/brave-core desde la nube).
- **La 13.3 se congeló el 22-01-2025; la 13.2.152.56 es M132-LTS con fusiones hasta el 01-10-2025.** `git rev-list
  93c6f108..5eabe0e1` deja **12 arreglos solo-LTS** que hay que portar encima de la 13.3 (~190 líneas): 3bdf541ae, 19301b95f,
  725b6a21c, 385d92ca6, 42421010c, f39628536, 5a7e02c2e, 80600881c, 2b2a58c26, 45d40ca20 (Maglev) aplican; **20c1b8e9b**
  (`js-regexp.cc`) y **5cf18d038** (LLE) con conflicto. 3–4 h. Sin ellos la 2.2.0 retrocedería en seguridad: no es opcional.
- **API pública:** nada deja de compilar (lo retirado —`SetRAILMode`, `FastApiTypedArray`, `CPPGC_2GB_CAGE`— ya no se usa tras
  el 132; `Utf8Length`/`Write*` y `AdjustAmountOfExternalAllocatedMemory` solo se deprecan y `build.sh` no las trata como error).
  gin: quitar `kWebAssemblyLiftoffCodeFlushing`/`--flush-liftoff-code` (el flag desaparece de V8).
- **`patches/v8`** (48): 43 aplican; `js-to-wasm.tq` (un hunk ya dentro), `store-store-elimination-reducer-inl.h` (tras
  80600881c), `messages.cc` y `js-objects.cc` (`DirectHandle`, contexto) y **`late-load-elimination-reducer.cc` a mano** (~1 h,
  junto a 5cf18d038). Época de caché nueva. → fila de SEGURIDAD-PORTES con los 12 solo-LTS.
- **JS/Wasm que sale encendido:** `Atomics.pause` y **Wasm Memory64** (`memory64` shipped). Además `use_std_math_pow`,
  `scavenger_max_new_space_capacity_mb` 8→32 y `script_context_mutable_heap_number` encendido (como Chrome 133: se dejan).
  Staged/apagado: Float16Array (135), `Error.isError`, explicit resource management.
- **CPU:** nada exige AVX sin comprobación (VAES/AVX2, revec y `Cvtpd2ph` se deciden en ejecución; la 5,1 no tiene F16C).

### 2. Lo apagado (regla 19) con la 13.3

| Opción | FlyWeb | 13.3 | Propuesta |
|---|---|---|---|
| Maglev | apagado (parche) | encendido | **134** (directiva): deuda contada por `Merged:` en 13.5–14.8 = 32 cherry-picks, **16–20 reales** (7 son de phis sin etiquetar), 4–6 días + medida en 5,1/6,1. Los de 13.3 ya vienen; 45d40ca20 va con los solo-LTS. Empezar a portarla ya en `seg/` para no atascar el 134 |
| `maglev_untagged_phis` | apagado | encendido | seguir apagado al encender Maglev (quita 7 de la deuda) |
| `turboshaft_wasm` | sin parche | **flag eliminado** | se cierra la fila |
| `flush_liftoff_code` | sin parche | eliminado | gin, arriba |

### 3. Escapes (regla 18, antes del nivel)

| Flag | Commits | Coste | Propuesta |
|---|---|---|---|
| **`WebAssemblyJSStringBuiltins`** (Baseline 2025-12) | 1f2dd1392d2, 37f9fd474bd | minutos | **portar**: hoy FlyWeb las tiene apagadas (json5 en `experimental`); el 130 lo dejó «opcional» y no se hizo |
| `BoxDecorationBreak` (FF; Safari con prefijo) | 904f3504be1, 26f726f450b, f7afd40fcbb, b34a6d5a6f6, c9ce28826ba | 2–3 h | portar (dos motores) |
| `SchedulerYield` (FF142) | ea2bd51cd50, 3a35087087d | 1–1,5 h | portar (dos motores) |
| `WebCryptoCurve25519` (X25519, Baseline 2025-02) | 3136845f1fb, fa2e69a1abf | 1 h | portar |
| `TextSizeAdjustImprovements` | 5cec4efe5ec (flip) | minutos | portar |
| Eventos de snap | 5458f67d491, c442049a8c8, 8694375dd34 | 1–2 h (no 25–50: el código ya está en la 128) | siguen fuera (solo Chrome) |
| `FontVariantEmoji` | 7 commits | 4–6 h | aplazar (en Mac necesita el fallback de emoji entero) |
| `PageMarginBoxes`, `HitTestOpaqueness`, `StaticAnimationOptimization`, Event Timing, FedCM, Fledge, PST, DevicePosture, DirectSockets, WebXR, USB | — | — | fuera (impresión, rendimiento, métricas o regla 20) |
| Escapes de la 2.1.1 | `flexbox-safe-overflow-position-002/005` | — | si LOCAL los sigue viendo en rojo |

### 4. Baseline y flags del 133

| Función | Commits | Tamaño (rech. sobre 128+bc) | Coste | Propuesta |
|---|---|---|---|---|
| `text-box` / `-trim` / `-edge` (`CSSTextBoxTrim`; FF154, Safari 18.2) | 30 commits 8cc53df3787 … 336cc860afc (ba1e0b75565, 2d18c3e5a7d) | +941/−597 (43 rech., block/inline layout) | 8–12 h | **portar, último y en su commit** (como `sideways`); sin los de `line-clamp` si sigue apagado |
| `:open` (Baseline 2026-05) | 6dfa7c8fc14, e0d51c14a17, ad3094520f8, 66d504d869c, 833248d9d46, 7d2b2076d87 | 39 ficheros (17 rech.) | 1,5–2,5 h | portar |
| Ancla implícita de popover (`PopoverAnchorRelationships`, Baseline 2026-01) + `popover=hint` | 8010721fc51 … 92bc6e98708 + flips 2dfb69e116d, 7bca6f1675e, d7258369ec3 | 26 ficheros (38 rech.; choca con nuestro `TogglePopoverOptions`) | 4–6 h | portar ambas |
| `ClipboardItem` con `Promise<string>` (Baseline 2025-02) | d72d71316f2, 586423e8031, 887df9720c3 | 12 ficheros (15 rech.) | 3–4 h | portar **conservando** el `WritePlainText` de Brave (`chromium_src`, regla 20) |
| `Animation.overallProgress` | 27df435a1f5, 726ab567b10 | 7 (1 rech.) | 0,5 h | portar |
| `finalResponseHeadersStart` | 006487e3ae3, 1249cc6be6b | 0 rech. | 0,5 h | portar |
| `renderTime` de LCP/ET entre orígenes (`ExposeCoarsenedRenderTime`, 4 ms) | d6a8de54aeb, b6afc5e5047, 59c59f02d18, 31a0c0a83bb | 0 rech. | 1 h | portar; comprobar que manda el `time_clamper` de Brave |
| `SelectionOnShadowDOMWithDelegatesFocus`; selectionchange del retroceso | 15d4924b212, c8a1a5f70f4; ddf020ca49b | pequeño | 1,3 h | portar |
| attr() avanzado (`CSSAdvancedAttrFunction`; Baseline parcial 2025-03) | 27 commits (9edcb63ea87 …) | +1456/−1041 (56 rech.; cascada) | 14–22 h | **aplazar** (riesgo alto en variables CSS de todas las webs): 134 o fila propia |
| `moveBefore`, scroll-state, varios import maps, `scroll-initial-target` | — | — | 4–6, 6–9, 3–5, 2–3 h | aplazar (no Baseline; import maps toca el `script_loader` de Brave) |
| `FontationsFontBackend`, `CSSCaretAnimation`, `FileSystemObserver` | — | — | — | fuera (Mac sigue en CoreText; experimental; Brave apaga File System Access) |

### 5. Fuera de Blink, privacidad y macOS

- **Huella de red, sin cambios** 132→133: ClientHello (BoringSSL: DTLS 1.3, PQ dentro de FIPS; grupos iguales), HTTP/2, QUIC y
  Client Hints. ALPS nuevo sigue apagado (135).
- **Portar (≈ 4 h):** `kReportEcn` a ON (8b7ac0ea2bd, 1 línea), `kMacImeLiveConversionFix` (fa3bf858457e), `kUseBrowserCalculatedOrigin`,
  lista HSTS; comprobar `user_agent_utils.cc.patch` (cambian firmas de GREASE). **Riesgo:** `kZstdContentEncoding` y `kPriorityHeader`
  desaparecen como flag en la 133; si FlyWeb los apaga por feature (`compatibilidad.md`), hará falta parche (~1 h).
- **Regla 20, propuesta:** `kStorageAccessHeaders` (`Sec-Fetch-Storage-Access`, ON en la 133, af95d9956afc) **apagado**: expone el
  estado de cookies de terceros. Prefetch del navegador, `kPermissionPredictionsV3` y OHTTP de Safe Browsing, sin portar. Brave 1.75
  sin revisar (sin red a brave/*): lo hace INVESTIGACIÓN o quien tenga acceso.
- **macOS:** 4 guardas y 4 usos del inventario, todos con guarda (HEVC L1T2 de 13, 4:4:4 de 13, HDR de 12). **No portar 0bd13a6ea21**
  (cursor sin parpadeo de macOS 15: enlaza `Accessibility.framework` fuerte y pide SDK 15). Nada nuevo para la capa de compatibilidad.
- GPU/ANGLE/Skia/Dawn: nada para el camino OpenGL de Mojave; Graphite no se enciende en Mac. Sandbox: sin cambios.

### 6. Regla 17, orden y decisiones

- **FS.33 (regla 17 del 133):** (a) los 12 solo-LTS de V8 sobre la 13.3 y el rebase de `patches/v8`; (b) arreglos posteriores
  de `text-box-trim` y popover/`:open`; (c) candidatos de Blink fusionados en la rama 133 (`/tmp` no persiste: lista en la fila):
  5e0a7a16b019 (caret), 2466b6a78d62 (view transitions), 9a80935019b0 (cull rect), ad4d3e7eff4c y 2a251e725fe0 (anchor),
  5c2bacf7420c (a11y), 9044bcbe4e16 (DevTools, posible UAF), 9f671e81d968 y 276c4ca4be4e (IDB `BlobReader`). Los de `moveBefore`,
  scroll-state y attr() van con esas funciones cuando se porten. Severidad por cruzar con los CVE.
- **Orden:** (1) V8 13.3 + 12 solo-LTS + gin; (2) escapes del §3; (3) Baseline pequeño del §4 y fuera de Blink del §5; (4) popover y
  ClipboardItem; (5) `text-box-trim` el último; (6) declaración 133.0.6943.141 / 2.2.0, `motor-133.html` y lista WPT.
- **Para COORDINACIÓN:** (a) declarar 133.0.6943.141 con V8 13.3.415.23 + 12 solo-LTS; (b) attr() aplazado; (c) BoxDecorationBreak y
  SchedulerYield entran; (d) Storage Access Headers apagado (regla 20; si duda, a Titín); (e) Maglev en el 134 con su deuda empezada ya
  por SEGURIDAD-PORTES.
