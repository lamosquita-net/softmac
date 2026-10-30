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

## Nivel 134

MOTOR-28, 28-10-2026: inventario con 3 subagentes Sonnet (Blink, V8 13.4, fuera de Blink) sobre 134.0.6998.166 (la última
Stable de Mac del 134 está sin confirmar sin red; el pin de V8 es el mismo desde la .129). Sus informes, abajo tal cual;
decisiones y orden, aquí.

**Resumen:** nivel pequeño en Blink (6–9 h: `<dialog closedby>`/`requestClose()` con su fusión de crashers ffe1a8806a,
`HighlightInheritance`, `CSSFontFeatureValuesRule`, `OffscreenCanvas.getContextAttributes`, correcciones de editing) y
sin cambios de huella de red. V8 **13.4.114.21** (4f282ae4, no LTS): faltan otra vez **11 de los 12 solo-LTS** (45d40ca20
ya viene) y ea2f03dfff; 69 de 79 `patches/v8` aplican; `maglev-graph-builder` a mano. Hay que traer
`third_party/simdutf` (V8 lo usa; la 128 no lo tiene) y subir `fast_float` a cb1d42aa. Nada exige AVX/F16C sin comprobar.

**Maglev (directiva: encendido en el 134):** el subagente cuenta **~40–50 arreglos reales** de 13.5–15.8 que tocan Maglev
y no están en la 13.4 (8–12 días, cifra suya sin contrastar; lista en `/tmp/claude-0/port/mg-groups.json`, no persiste).
SEGURIDAD-PORTES contó 16–20 cortando en 14.8. **Para COORDINACIÓN/SEGURIDAD-PORTES-11:** cruzar ambas cuentas antes de
fijar el coste; si la deuda real es la mayor, valorar con Titín si se enciende en el 134 o se aplaza (su directiva dice
«como tarde en el 134»).

**Fuera de Blink:** rebase de `user_agent_utils.cc.patch` y `client_hints.cc.patch` (~1 h), HSTS/pins y
`boringssl/BUILD.generated.gni`; `os_crypt_mac.mm` reescrito con `crypto::aes_cbc` (mismo formato `v10`: probar un perfil
existente, «FlyWeb Safe Storage»); `kDIPS` → `kBtm` (revisar parches de Brave); 6736b12fb2 quita el canvas acelerado en
Mac con NVIDIA (MacBook Pro 2012, GT 650M): portar como Chrome y avisar en las pruebas. Regla 20: siguen apagados los de
FLEDGE/Fenced Frames/Storage Access nuevos.

**Orden propuesto (después de la 2.2.1):** (1) V8 13.4 + 11 solo-LTS + ea2f03dfff + simdutf/fast_float + gin; (2) Blink
pequeño (HighlightInheritance, FontFeatureValuesRule, OffscreenCanvas); (3) `closedby` con ffe1a8806a; (4) editing;
(5) fuera de Blink; (6) Maglev según lo que se decida; (7) declaración 134 / 2.3.0, `motor-134.html`, WPT. FS de la regla
17 con la lista §4 de Blink.

### Informe Blink

### Inventario Blink del nivel 134 (134.0.6998.166)

**Resumen:** nivel pequeño en Blink. Solo 8 flags pasan a `stable` en el json5 (cr133→cr134) y de ellas solo 2 valen la pena (`closedby`/light dismiss de `<dialog>` y HighlightInheritance); 5 son Privacy Sandbox/WebGPU (fuera) y 1 es Document-Policy solo-Chrome. Otras 21 flags nuevas nacen `stable` pero son correcciones de editing/SVG/rendimiento sin cara web (llegan con su commit). Ninguna API de macOS 10.15+ sin guarda. Papel Blink: 6–9 h.
Método: script `flags-nivel.py` (cr133 vs cr134), json5 de FlyWeb = cr128 + parche de bc; commits con `git log` por ruta en 128.0.6613.138..134.0.6998.166. Ojo: el punto de rama es 72dd0b377c09 (06-01-2025).

#### 1. Flags que pasan a stable (cr133 → cr134)

| Flag | Qué es / Baseline | Commits (11 car. cuando se pidan; aquí 10) | Tamaño | Coste | Propuesta |
|---|---|---|---|---|---|
| `HTMLDialogLightDismiss` (era experimental) | `<dialog closedby=any/closerequest/none>`, `dialog.requestClose()`, cierre al pulsar fuera. Chrome 134; Firefox 141 y Safari 26.2 (a verificar) | 88af292eec, 1b130f3cee, 917c792b42, 046de1188f, 01e144886c, 7f4669f15e, 7aaf53e19b, 613b2ed621, 0aadd6e7f5, c8cc637fc4, d8a8f83689, 64f6b11d48, 8ee29d4a7e, 7d68067f2f, 15aaae4fd5, **ffe1a8806a** (fusión M134, 5 crashers), flip a42fbb916e | ~+1500/−400 con tests; ~10 ficheros (`html_dialog_element.cc/.idl`, `close_watcher.cc`, `document.cc`, pointer). Nuestro parche de `html_dialog_element.cc` (toggle events) choca | 3–5 h | **portar** (varios motores) con ffe1a8806a. No portar `bfe02c237c` (comando `request-close`: invoker commands, `HTMLInvokeActionsV2` = test) |
| `HighlightInheritance` (experimental en 128 y en FlyWeb) | herencia en `::highlight()`/`::selection`; Safari y Firefox (a verificar) | flip 921cea2e12 (1 línea); el código ya está en cr128 (`highlight_style_utils.cc`); + d6f74a7b14 (custom props en pseudos, +63/−38, 9 ficheros) | pequeño | 0,5–1 h | **portar** (flip + d6f74a7b14) |
| `DocumentPolicyExpectNoLinkedResources` | Document-Policy `expect-no-linked-resources`; solo Chrome | 4b5aee8dff, 19135e3a04 (impl.), flip 48358448dc | pequeño | 1 h | **aplazar** (sin otro motor; solo pista de rendimiento) |
| `WebGPUSubgroupsFeatures` | WebGPU subgroups | 57a0596f71 | 1 línea | — | **fuera**: WebGPU no existe en Mojave (Metal GPU process/Dawn); Brave lo deja tal cual |
| `FledgeSellerNonce`, `InterestGroupsInSharedStorageWorklet`, `SharedStorageWebLocks`, `PrivateAggregationApiMaxContributions` | Privacy Sandbox | 4636ac77e4, 32d6d4297a, bd5130d2b8, 31bf11c11c | — | — | **fuera** (regla 20; Brave los apaga) |
| `AuraScrollbarUsesNinePatchTrack` | solo Aura | 24c2190afc | — | — | irrelevante en Mac |

Sin pasar por stable pero relevantes, ya `stable` nacidas en 134 (flag nueva, correcciones; llegan con commit, coste ≈ 0,5–1 h el conjunto): `ExposeCSSFontFeatureValuesRule` (9d821a1e08, +52/−29; `CSSFontFeatureValuesRule` en `window`, Baseline: **portar**), `OffscreenCanvasGetContextAttributes` (147011978a +62/−35, flip 01423875ef: **portar**; ojo parche `offscreen_canvas_rendering_context_2d.idl`), `SvgViewportOptimization` (de0dd57803 +212/−84, 27 ficheros; rendimiento: **aplazar**, no es función), `DOMInsertionFaster` (c370a9394c, rendimiento, portar si cae limpio), 9 flags de editing (`AllowCopyingEmptyLastTableCell`, `AllowSkippingEditingBoundaryToMergeEnd`, `ComputeInsertionPositionBasedOnAnchorType`, `ConsiderFullChildNodeContentForListify`, `InsertLineBreakIfInlineListItem`, `RemovePlaceholderBRForDisplayInline`, `RemoveSelectionCanonicalizationInMoveParagraph`, `SplitTextNotCleanupDummySpans`, `FormValidationCustomElementsDelegatesFocusFix`): **portar** si encadenan con los de 133; `PaintLayerUpdateOptimizations`, `FastClearNeedsRepaint`, `ScrollableAreasWithScrollNodeOptimization`, `DragImageNoNodeId`, `DnDScaleHeightAndWidthToMaxDimension`, `TextCombineEmphasisNG`, `UsePositionForPointInFlexibleBoxWithSingleChildElement`: correcciones/rendimiento, opcionales.

**Quitadas del json5 (ya en código, enviadas ≤133):** 26. En FlyWeb ya estaban `stable` (DetailsStyling, FedCmIdpSigninStatus, MeterDevolveAppearance...). Sin flag en FlyWeb (`-`): `SkipTemporaryDocumentFragment`, `SvgTransformOptimization`, `CSSLineClampWebkitBoxBlockification`, `AuraScrollbarUsesSolidColorThumb` → llegan con el código.
**No suben y se revirtieron en 134:** dynamic-range-limit (8055a4e597), text-shadow layer bounds (62734e46ab), styles-in-serialization (f530ee9a3d). No portar.
**Nuevas en test/experimental (no entran):** animation-trigger*, `if()` inline (CSSInlineIfForStyleQueries), `safe-area-max-inset`, ScopedViewTransitions, Prompt API multimodal, SPC availability, StandardizedTimerClamping (a78ea6f24d), ResourceTimingContentEncoding (2841e06cd2), SignatureBasedInlineIntegrity. Finch: sin lista de Chrome for Testing a mano; lo único con `base_feature_status: enabled` que cambia es `PermissionElement` (PEPC, experimental): fuera.
**attr():** el 134 no añade nada a `CSSAdvancedAttrFunction` (sigue stable desde 133).

#### 2. Escapes (stable en ≤133, FlyWeb sin stable, flag presente)

| Flag (FlyWeb) | Propuesta |
|---|---|
| `TextSizeAdjustImprovements` (experimental) | portar (ya propuesta en 133, flip 5cec4efe5ec) |
| `AnimationProgressAPI` (test) | portar + encender (= `Animation.overallProgress`, 27df435a1f5, 726ab567b10 del 133; si no se flipó, queda escape) |
| `FileSystemObserver`, `FontVariantEmoji`, `HitTestOpaqueness`, `PageMarginBoxes`, `StaticAnimationOptimization`, `FontVariationSequences`, `ContinueEventTimingRecordingWhenBufferIsFull` | ya decididos en 133 (aplazar/fuera); sin cambios |
| `CSSScrollSnapChange/Changing/Events`, `CSSSnapContainerQueries`, `CSSStickyContainerQueries`, `AtomicMoveAPI` | aplazar (solo Chrome; scroll-state y `moveBefore`) |
| `DevicePosture`, `DirectSockets`, `UnrestrictedUsb`, `WebXRHandInput`, `DocumentPictureInPicturePreferInitialPlacement`, `ElementCapture`, `CredentialManagerReport`, `ReportEventTimingAtVisibilityChange` | fuera (hardware/solo Chrome/métricas) |
| `FedCmAuthz`, `FedCmButtonMode`, `FedCmWithStorageAccessAPI`, `FledgeRealTimeReporting`, `FledgeBiddingAndAuctionServerAPI`, `PrivateStateTokens` | fuera (regla 20) |
| `FontationsFontBackend`, `CSSAdvancedAttrFunction` | fuera / 2.2.x aparte (ya sabido) |

Los ~45 stable sin flag en FlyWeb (`MultipleImportMaps`, `CSSScrollInitialTarget`, etc.) son código sin flag: dependen de portar el commit (ver tabla 133).

#### 3. macOS 10.15+

Nada. Blink mac (`font_matcher_mac.mm:410` ya con `@available(macOS 13.0,*)`) sin cambios entre 133 y 134; el único `.mm` tocado es `locale_mac.mm` (base::ranges→std::ranges, 5b674970ad). Sin `API_AVAILABLE` nuevos.

#### 4. Candidatos regla 17 (fusionados en la rama 134, Blink)

| Commit | Qué | crbug |
|---|---|---|
| 53afd466dc | device change events encolados crashean el renderer | 403348706, 404042280 |
| ffe1a8806a | dialog `<dialog open>` crashers (con closedby) | 393420204, 393883102, 393879748, 393834331, 396679565 |
| 7a3dfd2c6a | fetchLater crashes | 398528191, 395869070, 395171134 |
| c5522665e0 | CSSStyleRule::setSelectorText: reatar wrappers (posible UAF) | 397904435 |
| 459940dd4f | cancellation traits en SingleThreadIdleTaskRunner (posible UAF) | 395826964 |
| 70a52b59e4 | detached anchor_position_scroll_data | 395057435 |
| 78bc85154c, ee09b0a7d9 | `<select>` anidados / OwnerSelectElement (customizable select) | 394924538, 393579139, 394861194 |
| 4b3f6cf5bf | shared storage `navigator.locks` en addModule | 396648513 |
| e6a88e7e60 | PEPC border exploitable | 383297655, 394246266, 394783066 |
| a6927fc264, bc09b6ac39 | invalidation sets nulos; DOM snapshot | 401260383, 395032416 |
| ea2f01f3c9, 9120eb438f, d06165f309, fbb3363dcf | a11y (aria-owns, árbol) crashes | 401394162, 401394502, 396048653, 366435136 |
| 715c0e93e6, f85d8c12a6, 5d836499ae, e98b235cc4 | denormal flush; XR; WebGL primitive restart a GPU; WindowProxy | 382005099, 396481096, 401059730, 394380126 |

Aplican a Blink de 128 solo los de código ya presente (dialog/select/PEPC dependen de portar esas funciones). Severidad por cruzar con CVE. Solo hay merges hasta el 19-03-2025 (.166).

#### Orden propuesto
(1) HighlightInheritance + CSSFontFeatureValuesRule + OffscreenCanvas getContextAttributes (≈2 h); (2) `closedby`/dialog + ffe1a8806a (3–5 h); (3) correcciones de editing 134 y candidatos regla 17; (4) fuera: Privacy Sandbox, WebGPU, ExpectNoLinkedResources.

### Informe V8 13.4

### Inventario V8 para el nivel 134 (MOTOR-28, solo lectura)

#### 1. Versión y solo-LTS
- **V8 13.4.114.21 = 4f282ae4** (DEPS de 134.0.6998.129, .165 y .166; `bh/13.4` apunta a él, sin merges posteriores). Los tags de la hist solo llegan a .166 (no hay .2xx); sin red no puedo confirmar cuál es la Stable de Mac: se usa .166 (el pin de V8 es el mismo desde .129).
- 13.4 **no es LTS** (la LTS es la M132 = 13.2.152.56 5eabe0e1). 13.3 y 13.4 divergen desde 3348638c0 (02-01-2025).
- Lo que tenía 13.3 y no 13.4: solo 3 merges (b75e527fb, 84a0e230d, 0242cac4b) y los **tres ya están en 13.4** (95520eaf4, 66f52356a, fd9d1daf4). Nada que recuperar de la 13.3.
- De los **12 solo-LTS** (13.2 sin 13.4): **11 siguen faltando** en 13.4 (origen no es ancestro ni hay cherry-pick): 3bdf541ae, 19301b95f, 725b6a21c, 385d92ca6, 42421010c, f39628536, 5a7e02c2e, 80600881c, 2b2a58c26, 20c1b8e9b, 5cf18d038. **45d40ca20 (Maglev ClearAllocationBlock) ya está en 13.4** como 2b4812d50. Los parches de esos 11 aplican igual salvo js-regexp (ver 2). Además 13.2 trae c39fa58fc (siso, irrelevante).
- ea2f03dfff (stack clash): ausente en 13.4 (es de 26-10-2026); `pipelines.{h,cc}` y su test aplican; `pipeline.cc` rechaza 2 de 7 hunks (solo declaraciones).

#### 2. patches/v8 sobre 13.4 (`git apply --check`, /tmp/claude-0/port/v8-134)
79 parches (+ FLYWEB-SECURITY.md): **69 aplican limpios**, 10 no:
- **Ya en 13.4 (se sueltan, 4):** `js-to-wasm.tq`, `wasm-to-js.tq` (se invierten limpios), `microtask-queue.cc` (idem) y `microtask-queue.h` (13.4 tiene el `std::optional` upstream; solo falta un `#include <optional>`, innecesario).
- **Contexto trivial (4, ~1 h):** `js-break-iterator.cc` y `js-duration-format.cc` (`DirectHandle` en 13.4), `js-regexp.cc` (13.4 usa `IsOneByteRepresentationUnderneath`; 4 hunks entran, falla el 5.º), `pipeline.cc` (2 declaraciones).
- **A mano (2, ~0,5–1 día):** `maglev-graph-builder.cc/.h` (arreglo define-const-data-field): 13.4 tiene visitantes `ReduceResult` (`VisitDefineNamedOwnProperty` devuelve ReduceResult, hunks 2–4 y .h rechazan); el hunk 5 (ClearCurrentAllocationBlock) ya es upstream (2b4812d50) y se quita.
- Época de caché: sube con `version.h` (aplica).

#### 3. API pública y flags
- include/ 13.3→13.4 (20 ficheros). **Quitados:** `BackingStore::Reallocate`, `ArrayBuffer::Allocator::Reallocate`, `FastApiTypedArray*`/`FastApiArrayBuffer*`, `CFunction::GetOverloadResolution`, `kGuardPageSize` (cppgc). **Nuevos:** `ContextDependants`, `Isolate::ContextDisposedNotification(ContextDependants)` (la antigua `(bool)` queda DEPRECATE_SOON), `SetMemorySaverMode`, `Freeze`, `Allocator::MaxAllocationSize`, `BackingStoreOnFailureMode`, `SharedArrayBuffer::MaybeNew`, `EstimateMemoryUsage`. `Utf8Length/Write*` pasan a V8_DEPRECATED (con `v8_deprecation_warnings:false` de build.sh no rompe). `SetAtomicsWaitCallback`, `AtomicsWaitWakeHandle`, `CppHeap::Terminate` deprecados.
- grep en cr133/cr134 (gin, bindings, platform, content/renderer, chrome/renderer, extensions, pdf): **ningún uso de lo quitado**. Blink 134 sigue llamando `ContextDisposedNotification(bool)`: compila. `kGarbageCollectionReasonMaxValue` sigue (27→28).
- gin 134: `IsolateHolder::Create(..., disallow_v8_feature_flag_overrides)` nuevo parámetro y orden nuevo (flags de Features antes que `--js-flags`): es cambio de Chromium, a portar con gin.
- Flags: desaparecen `scavenge_separate_stack_scanning`, `trap_on_abort`, `turboshaft_from_maglev`, `turboshaft_instruction_selection`, `turboshaft_wasm_instruction_selection_staged` (gin solo los pasa si el Feature se sobrescribe; ignorables). **`flush_liftoff_code` vuelve** en 13.4 (true): el cambio de gin de 133 («quitar kWebAssemblyLiftoffCodeFlushing») no debe repetirse en 134. Nuevos: `turbolev` (experimental, apagado), `memory_saver_mode`, `typed_array_length_loading`, `print_feature_flags_json`. `build.sh` no pasa flags de V8 (solo `v8_deprecation_warnings/imminent: false`): nada que quitar.
- **DEPS de V8:** `fast_float` sube 3e57d8dc→**cb1d42aa** (actualizar `FlyWeb/fast_float-revision` con su suma; la de hoy es para 13.0–13.3). V8 usa ahora `//third_party/simdutf` (base64): el árbol 116 no lo tiene (no está en el 128; el 133 sí): hay que traerlo (v6.0.2, `third_party/simdutf` del tag 134) o build.sh falla. simdutf despacha por CPU en ejecución (Haswell/Icelake con atributos de región): comprobar en la 5,1 que elige westmere/fallback.

#### 4. Encendido en 13.4
- **Shipping (JS):** `Error.isError` (nuevo; 13.3 lo tenía staged) además de lo de 133 (`Atomics.pause`, `Promise.try`, RegExp modifiers y nombres duplicados, iterator helpers, Set methods, import attributes). **Wasm:** sin cambios (legacy_eh, imported_strings, memory64). Sin cambios en los demás defaults.
- **Staged:** explicit resource management, Float16Array, `harmony_remove_intl_locale_info_getters`. **In progress:** decorators, source phase imports, `js_base_64` (nuevo), Temporal, ShadowRealm, structs. Wasm staged: type_reflection, stringref, imported_strings_utf8, exnref, jspi (todos apagados).

#### 5. Regla 19
- `maglev` = true y `maglev_untagged_phis` = true por defecto; ambos parches de flag-definitions.h aplican limpios (siguen apagándolos). Para encender Maglev: quitar la línea `maglev` del parche y mantener la de `untagged_phis` en false.
- **Deuda Maglev** (merges en 13.5…15.8 que no están en 13.4: 1370 commits de rama, 363 grupos únicos, **84 tocan Maglev**): 16 solo tocan ficheros que 13.4 no tiene (range analysis, HAMT, KNA split) y 7 son de turbolev (apagado); ~10 son de phis untagging (apagado) y 2 no son x64. Quedan **~40–50 reales** (frente a 16–20 del cálculo de 13.3, que cortaba en 14.8): en 13.4 `maglev-graph-builder` es más antiguo, así que casi todo va a mano. Estimación 8–12 días + medidas en 5,1/6,1. Nombres de los 84 en /tmp/claude-0/port/mg-groups.json.
- **AVX/F16C:** 13.4 añade `Cvtph2pd` (F16C+AVX sin guarda en el macroensamblador), pero solo lo emite `kSSEFloat16RawBitsToFloat64`, que el selector solo genera con `kFloat16RawBitsConversion` (exige F16C y AVX en ejecución; Float16Array está staged). Nada más: sin `-mavx` nuevo, sin cambios en base/cpu.cc; revectorizer igual. **Nada exige AVX/F16C sin comprobar.**

### Informe fuera de Blink

##### Nivel 134, §5 Fuera de Blink, privacidad y macOS (cr133 vs cr134 + historia 133.0.6943.141..134.0.6998.166)

**1. Huella de red: sin cambios en lo observable.**
- ClientHello: BoringSSL d777ea2a70 -> ea42fe2877 (67 commits). Solo SPAKE2+/PAKE en TLS 1.3 (2b19cd39, 21f54b27; extensión solo con credenciales PAKE configuradas, nunca en Chrome), cambio de licencia a Apache 2.0 (33d1049b), reorganización (modes -> aes), `chacha20_poly1305_*_sse41` (b0256708, SSE4.1, sin AVX), AES-GCM con prefetch (13840dd0; ruta AVX/VAES con detección en ejecución). Grupos (`X25519MLKEM768, X25519, P-256, P-384`), ALPS, ECH, sigalgs: `ssl_client_socket_impl.cc` y `net/ssl` sin cambios; `kUseMLKEM` ON igual. Nuevo: log de red `ech_enabled` en `ssl_connect_job.cc` (inocuo).
- BUILD.generated.gni: regenerar el parche `third_party-boringssl-BUILD.generated.gni.patch` (mlkem ya está upstream: el parche de Brave de MLKEM y `net-quic-quic_session_pool.cc.patch` (kUseMLKEM) ya los trae Chromium 133/134; comprobar que no choquen, probablemente se pueden soltar).
- HTTP/2: `spdy_session.cc`, `header_coalescer.cc`: solo `std::ranges`; SETTINGS iguales. QUIC: QUICHE e7d001c82 (5 rolls, ~34 commits, sin acceso a su log); en Chromium solo métricas (`QuicSessionKeyMismatchedFieldCombination`) y `http_stream_pool_*quic_task` renombrados. Ningún flag QUIC cambia de valor.
- Client Hints/UA: `user_agent_utils.cc` borra `enable_updated_grease_by_policy` y el algoritmo GREASE antiguo (el nuevo ya era el único activo en la 133: salida idéntica). Se borra `kAllExceptLegacyWindowsPlatform` (UA unificado en macOS ya era así). `client_hints.cc`: `mojom::PermissionsPolicyFeature` -> `network::mojom::...` (solo espacio de nombres). `content/common/user_agent.cc` sin cambio funcional. Rebase de `components-embedder_support-user_agent_utils.cc.patch` (BRAVE_GET_USER_AGENT_BRAND_LIST, firma cambia) y `third_party-blink-common-client_hints-client_hints.cc.patch` (namespace). Costo ~1 h.
- Lista HSTS/pins (`transport_security_state_static.*`) cambia: regenerar los 3 parches de Brave.

**2. BASE_FEATURE 133 -> 134 (valor/alta/baja)**
- Portar (comportamiento de Chrome): `EarlyEstablishGpuChannel` ON, `EstablishGpuChannelAsync` ON, `ThreadedScrollPreventRenderingStarvation` ON, `DeferRendererTasksAfterInput` ON, `IgnoreInputWhileHidden` ON, `LCPPLazyLoadImagePreload` ON, `BFCacheOpenBroadcastChannel` ON, `PageHideEventForPrerender2` ON, `Prerender2NewLimitAndScheduler` ON, `AccessibilityPageZoomEnhancements` ON, `VideoFrameAsyncCopyTo` ON, `SeamlessRenderFrameSwap` ON. Vienen con el código, sin trabajo extra.
- Apagar por regla 20 (privacidad): `DevToolsPrivacyUI` pasa a ON (solo interfaz de DevTools, inocuo; dejar). `kDIPS` se renombra `kBtm` (nombre de feature "DIPS" igual; ojo a parches Brave que citen `kDIPS`). Altas OFF que mantener OFF: `AdAuctionEventRegistration`, `FencedFramesCrossOriginAutomaticBeaconData`, `StorageAccessApiFollowsSameOriginPolicy`, `HttpCacheNoVarySearch`, `DisallowNonAsciiCookies`, `ServiceWorkerSyntheticResponse`, `DeleteStaleSessionCookiesOnStartup`. Altas ON con sabor Privacy Sandbox/telemetría: `FledgeQueryKAnonymity`, `FledgeMaxGroupLifetimeFeature` (FLEDGE ya apagado en FlyWeb: sin portar), `SafeBrowsingAsyncRealTimeCheck` (Safe Browsing va por proxy propio: sin portar), `ReportingApiCorsOriginHeader` (portar).
- Sin portar: `TrackingProtectionContentSettingUbControl` ON->OFF, `ReadingListEnableSyncTransportModeUponSignIn`, `UseCertTransparencyAwareApiForOsCertVerify` (solo Android). `StoreConnectionSubtype`, `LocalNetworkAccessAllowPotentiallyTrustworthySameOrigin`, `EnableLockCookieDatabaseByDefault`, `AttributionReportingCrossAppWeb`, `ServiceWorkerStorageSuppressPostTask`, `CrabbyAvif` (ya incondicional; libavif fuera de DEPS) dejan de ser flag: si FlyWeb los apaga, parche.
- `kStorageAccessHeaders` (decisión del 133, apagado) sin cambios.
- Cookie DB: `os_crypt_mac.mm` se reescribe con `crypto::aes_cbc`/`kdf` (CommonCrypto fuera), `OSCryptImpl::DeriveKey`. Mismo formato `v10`, sal `saltysalt`, 1003 iteraciones: conserva «FlyWeb Safe Storage». Probar leer perfil existente; `keychain_password_mac.mm` sin cambios (parche aplica).

**3. macOS: sin APIs nuevas de 10.15+.** Inventario del 134: 2 filas (`extensible_enterprise_sso_provider_mac.mm`, macOS 12, con guarda; empresa, no entra). Barrido de diffs en `.mm/_mac`: ningún `@available`/`API_AVAILABLE` nuevo. Cambios con efecto: sandbox Mac sin protobuf (526e35a6ec): `SandboxCompiler` -> `SandboxSerializer`, misma API privada (`sandbox_compile`/`sandbox_init_with_parameters`) y `csr_get_active_config` (10.11+, crash key SIP eda907474c) -> sin problema en Mojave; afecta al parche `sandbox-mac-system_services.cc.patch` (revisar contexto). `NativeWidgetNSWindowBridge::SetActivationIndependence` (`activateIgnoringOtherApps` condicionado), `Reanchor()` en immersive mode (solo pantalla completa, API existente), `accessibilityDocument` (existe en 10.14). Parche `render_widget_host_view_mac.mm` (unadjustedMovement en 10.14): sin conflicto. Capa de compatibilidad: nada nuevo.

**4. GPU/ANGLE/Skia/Dawn/sandbox.** Rolls: ANGLE 914c97c116, Skia aefbd9403c, Dawn 7056f50fdefc, SwiftShader 86cf34f5 (sin acceso a sus logs). Importante para Titín: **6736b12fb2** «Block accelerated canvas on NVidia macs» (software_rendering_list id 183, vendor 0x10de, macosx): en el MacBook Pro 2012 con GT 650M el canvas 2D pasa a software (Chrome 134 también); decisión: portar tal cual (huella/rendimiento iguales a Chrome), avisar en pruebas. Graphite en Mac ARM por defecto (9cf7a92e90): irrelevante (Intel). WebGL: primitive restart pasa a la GPU process (5d836499ae, a22941a979): probar WebGL en Mojave (GL core vía ANGLE). Nada más sobre el camino OpenGL de Mojave.

## Nivel 135

MOTOR-31, 29-10-2026: inventario con 3 subagentes Sonnet (Blink, V8 13.5, fuera de Blink) sobre **135.0.7049.117** (la
última Stable de Mac del 135, V por versionhistory.googleapis.com; chromiumdash da 403 por el proxy). Sus informes, abajo
tal cual; decisiones y estado, aquí. Rama brave-core **`nube/motor-135`**, sobre la 2.3.0 (479bcaf1e2).

**Resumen:** V8 **13.5.212.10** (e2591684, no LTS) es barata: 97 de 104 `patches/v8` aplican tras rebasar contexto, la 13.5
borra el `SpinningMutex` que tumbó la 2.3.0 en Mojave y no trae `CHECK` nuevos que Blink alcance ni APIs de 10.15+.
Fuera de Blink, dos cambios de huella (ALPS nuevo y `version_information` de QUIC con el código RFC). **Blink es el
grueso del nivel** (14–22 h reales sin carousel ni FetchLater; 33–45 h con todo): carousel CSS, select personalizable,
`shape()`, Observable, `command`/`commandfor`, `interactivity`, FetchLater y flips pequeños. Nada exige AVX.

**Hecho por MOTOR-31 (`nube/motor-135`, sin compilar):**
| Commit | Qué |
|---|---|
| 9db2c47e3 | port de WebGL `[PassAsSpan]` de M130 (89faaa39fb47; era `nube/motor-134-webgl-up` 8eeb795e9e): vuelven las llamadas rápidas de `uniform*`/`vertexAttrib*` |
| 619397a95 … 5a8fe0bb8 | **escapes WPT del 134** (`wpt-230-investigacion.md`): dirección `inherit` de OffscreenCanvas (ba17fa15de), `desynchronized` en `getContextAttributes` (06ed9ecbb6), pegar `<li>` como hermano (347bc308e2 + flag), `@font-feature-values` (efecto de 20d6d52ab7, mínimo), `calc()` en `font-weight` (738a7c5fd4 + 8c249d6e26), `font-variant-emoji`/variation sequences (12 commits de 129–132, emoji-segmenter 955936be como parche de su repo), highlights (3b9b9aaf29, 0112c990f8, 4d2736408d) |
| 37c5e8a5e | **V8 13.5.212.10**: rebase de `patches/v8` (103, todos aplican sobre e2591684); stack clash a mano (`AllocateRegisters` en `pipelines.cc`); Maglev a mano; d73530cfd9 (regla 19: `typed_array_length_loading` sale encendido en 13.5). Maglev **sigue apagado**. Época 23 |
| 33a7efd54 | ALPS 17613 (`UseNewAlpsCodepointHttp2/QUIC`) y QUIC `version_information` 0x11 (parche de QUICHE) |

**Hecho por MOTOR-32 (`nube/motor-135`, sin compilar; 29-10 ~16:13–17:10):**
| Commit | Qué |
|---|---|
| f9680180, 0bba4d30, 6eaf6c4d | faltas del cruce wpt.fyi (detalle y coste en `version-2.4.0.md`) |
| 5eaf0562 | flips: `AOMAriaRelationshipProperties` (con `…AriaOwns` aparte, experimental como en el 135), `CSSLogicalOverflow`, `NavigateEventSourceElement`, `NavigateEventPopstateLimitations` (cd6fd72eb9), `CSSSafeAreaMaxInset` (0px; sin el setter de Android) |
| 4f494d35 | `command`/`commandfor` (`HTMLCommandAttributes` estable): c121be19e, e38532a81, f4d84ff44, 33c0328e7, 8e63f280b, bfe02c237, bdfd9bd0e, 17926bb6e, 85364ff7e y la regla del 135 «sin `type` válido ⇒ botón» (sin su contador). Fuera: 1b6a541a2 (mapeos a11y) y 4be431c43 (referencetarget) |
| 7df1ac0a94 | arreglos de compilación de LOCAL-14 (Perfetto `NamedTrack`, licencias) |
| 56a99da5 | correcciones del 135 con su flag: `OptionLabelAttributeWhitespace`, `ResolveVarStylesOnCopy`, `SameValueTextContentFiresMutationObservers`, `SelectNoMouseUpForKeyboardSelection`, `StrongBolder`, `RadioInputNextButtonInScope`, `CorrectStylesForLists` |

**Hecho por MOTOR-33 (`nube/motor-135` ebd8c17f, sin compilar; 29-10 ~17:20–17:55; opción A de Titín):**
| Commit | Qué |
|---|---|
| 68585b1c | `AllowSameSiteNoneCookiesInSandbox` (b25e4d9b4 b2e2007e8 7fc76166e 41778368c 930296213, encendido). Regla 20: en `DecideAccess` el bloqueo de Shields (`IsAllowed(setting)`) y la macro 1PES de Brave van antes; solo abre cookies si la URL es del mismo sitio que la principal y todos los marcos antecesores son del mismo origen |
| 423cadcb | `UpdateRequestForCorsRedirect` (reland edcb05836) |
| 722d759c | `ServiceWorkerSrcdocSupport` (5b299cef9, 8d6a8c147) y `ServiceWorkerClientUrlIsCreationUrl` (ec3e438d8, 3a181153e); en la 128 la URL se recorta en `ServiceWorkerControlleeRequestHandler` |
| 747e8405 | **`shape()`** (17 commits + flip 5646d3a9a): parser reescrito sobre `CSSParserTokenRange`; solo `clip-path` (`offset-path` y `shape-outside` lo rechazan, como el 135); `CSSShapeFunctionCompositeAnimation` sigue `experimental` |
| 46fcecfd | **`interactivity`**: f88bfc0d5 + e47ead48d como un solo cambio, y 8b21209fb 3b8630b6c b73e018b7 4670338cc 66c0b303f 6f85e4ee1 ae21fa404; `CSSInert` estable; fuera la regla UA del select personalizable |
| 48134b44 | editing e inline: 528bccdc9 9c070c13a (`EnterInOpenShadowRoots` en `test`, como el 135) 16874a564 bc351d721 b71045ab2 c933c8576 |
| 3388c40a | HSTS, pins y `log_list.json` de la 135.0.7049.117 (los parches anteriores eran justo los de la 132) |
| ebd8c17f | declaración 135.0.7049.117 / 2.4.0 |

**Quedan fuera de la 2.4.0 (caros y menores, criterio de Titín):** `CSSAnchorRememberedScrollOffset` (cadena de anchor
132–135, >1 h); `text-box-trim` con spanners (80505a9e751, exige el refactor del 134 de `BoxFragmentBuilder`);
`preserveAspectRatio` en `feImage` (8692b015aaf: el diff es pequeño, pero en la 128 la imagen SVG se crea en
`SVGFEImageElement` sin tamaño de contenedor y el 135 la crea en `FEImage::GetImage()`; habría que portar ese refactor);
`text-emphasis-position: auto` (`experimental` en el 135); `CascadedAfterChangeStyle` (208c85057, solo rendimiento,
no aplica sobre el recalc de la 128); `NodeInUAShadowRootUnderAnonymousBlockFlow` y
`PartialCompletionNotAllowedInMoveParagraphs` (commit sin localizar con la historia ligera). Y lo que ya decidió Titín:
Observable, select personalizable, carousel y FetchLater. `motor-135.html` en `FlyWeb/tools/`.

**Lo que falta del Blink del 135, con lo medido (MOTOR-32):** las estimaciones del inventario eran optimistas en
cuatro filas, porque el código «del 129–134» no está en la 128:
- `CSSAnchorRememberedScrollOffset` (+88e081e06af): no es un flip; el flag no existe en FlyWeb y `out_of_flow_layout_part.cc`
  difiere en 366 líneas del 135 (cadena de anchor 132–135 sin portar). Más de 0,5 h.
- `shape()`: 17 commits (3284a9ba2 044cf3710 5f81b5c59 e54847d7c 8a6bafe00 c5c80dd0c 1cab9fbd2 4fe008824 8fa10d7fa ce85d539f a8af49cc4 6f97f790f 86533cc4b 9ad18e925 2a7c281d1 ae261b0d4 ead0ee8d0; flip 5646d3a9a). El
  parser de formas de la 128 usa `CSSParserTokenRange` y upstream ya `Stream`: hay que reescribir el parseo. 3–5 h reales.
- Observable: 17 commits (42d10ecd1 d80b708f1 b48238464 54935a98d 1ef99987d 911786c09 77a8e718d 4a2006a57 c322807af 4b00956a8 151cbac18 b6729c19a 3fcb998ed e24c9459e e35d6616b bf92734b2 10a2f47af; 123e89265 es de glic, fuera). Arrastra APIs de bindings del 129–133 que la 128 no tiene
  (`ThenCallable`, `TryRethrowScope`, `ScriptIterator` asíncrono): o se portan esas APIs o se reescribe con las de la
  128. Más de 4 h.
- `interactivity`: la cadena empieza en e47ead48d, revert de `visibility:inert` (que FlyWeb no tuvo) sobre ~100 ficheros:
  portar el estado neto del 135 (f88bfc0d5 + e47ead48d como un solo cambio) y luego 8b21209fb … ae21fa404d.
- Sin tocar: select personalizable, FetchLater (+8a947848b8), carousel, editing (`AdjustStartOfParagraphToMoveDuringIndent`…).
- Fuera de Blink, ninguna de las 4 está en la 128: `UpdateRequestForCorsRedirect` (17d4c9271 → revert → reland
  edcb05836), `ServiceWorkerClientUrlIsCreationUrl` (ec3e438d8, 3a181153e), `ServiceWorkerSrcdocSupport` (f0232ec8d →
  revert → reland 5b299cef9, 8d6a8c147), `AllowSameSiteNoneCookiesInSandbox` (b25e4d9b4, b2e2007e8, 7fc76166e,
  41778368c, 930296213; toca cookies: regla 20).

**Decisiones:**
- **Lecciones de la 2.3.0 aplicadas:** `api.cc` 13.4→13.5 sin `CHECK` nuevos alcanzables (el `CHECK_NE` de aridad de
  `NewWithCFunctionOverloads` sigue: el arreglo de IDL de la 2.3.0 vale); `FunctionCallbackInfo::Holder()` desaparece
  y ni gin ni Blink 128 lo usan; `src/base`, `src/libplatform` y `src/heap/base` sin APIs de 10.15+; barrido de IDL de
  FW sin sobrecargas `[NoAllocDirectCall]` de misma aridad; el 135 solo añade `[NoAllocDirectCall]` a `webgl_multi_draw*`
  (32f7cb889c, firma única). `getContext('webgl')` y `webgl2` con `ANGLE_multi_draw` en la prueba de humo.
- **No se portan:** `progress()`, `abs()`, `sign()` (Chrome los desenvió en el 135), `MediaStreamTrackWebSpeech`,
  `MediaRecorderUseMediaVideoEncoder`, WebGPU, métricas (`BackForwardCacheUpdateNotRestoredReasonsName`,
  `EventTimingSelectionAutoScrollNoInteractionId`, `RTCEncodedFrameTimestamps`), el borrado de
  `GL_PRIMITIVE_RESTART_FIXED_INDEX` (depende de un ANGLE más nuevo). Regla 20: ningún flag nuevo de Privacy Sandbox
  sube a `stable`; los de red (`IpProtection`, `DeviceBoundSessions`, `Delete*LocalStorageOnStartup`…) siguen fuera.
- **macOS:** nada nuevo para la capa de compatibilidad. `UTType` (11.0) solo en el menú Servicios: se queda la rama de la
  128; **corregir la fila de §8.2 de `macos11-niveles.md`** (decía portapapeles/arrastrar, «M»).
- `highlight-paired-cascade-004` sigue sin causa: que LOCAL lo pruebe con la receta de `wpt-230-investigacion.md`.
- Fijadas perdidas en la 7,1 (2.1.1 → 2.3.0): el arreglo de la 2.0.3 (98f869c5b, `shared_pinned_tab_service.cc`) sigue
  intacto en 479bcaf1e2 y ningún commit del 133/134 toca sesiones ni tab strip: **reproducir en la 7,1 con la 2.4.0**.

**Pendiente para MOTOR-32 (orden del informe Blink):** (1) flips pequeños (AOM, `CSSLogicalOverflow`,
`CSSSafeAreaMaxInset`, `sourceElement`/popstate, `CSSAnchorRememberedScrollOffset`) 2–3 h; (2) `command`/`commandfor`;
(3) `shape()`; (4) Observable; (5) correcciones pequeñas y de edición; (6) select personalizable; (7) `interactivity`;
(8) FetchLater con 8a947848b8; (9) carousel (8–12 h; solo Chrome: proponer a COORDINACIÓN si va en una 2.4.x); las faltas
del cruce con wpt.fyi (paso 3, `version-2.4.0.md`); fuera de Blink, `AllowSameSiteNoneCookiesInSandbox`,
`ServiceWorkerSrcdocSupport`, `ServiceWorkerClientUrlIsCreationUrl`, `UpdateRequestForCorsRedirect` y regenerar
HSTS/CT; declaración 135.0.7049.117 / 2.4.0 en `build/config.gni`; `motor-135.html`.

### Informe Blink

### Inventario Blink del nivel 135 (135.0.7049.117)

MOTOR-31, 29-10-2026, solo lectura. V = verificado, S = supuesto. Datos en `/tmp/claude-0/port/i135/` (diff.tsv, esc.tsv, flmap.txt, l135.json, b135.json).

**Tags (V, versionhistory.googleapis.com; chromiumdash está bloqueado por el proxy):** última Stable de Mac del 135 = **135.0.7049.117** (sha 37b1cea674dc; servida 06–08-05-2025, .115 y .116 fueron las anteriores). La del 134 que usamos, **134.0.6998.166** (0b26d3a1ee1e), correcta (Stable Mac 25-03 a 07-04-2025).
Rango del nivel (V, Gitiles): 134.0.6998.0..135.0.7049.0 = 11 926 commits de main, **4-02-2025 a 4-03-2025** (el punto de rama del 134 es el 4-02, no el 06-01 que dice el informe del 134; S: el 06-01 es el del 133). Ramas del 135 tras la rama: 2177 commits, 426 no triviales, 40 tocan Blink (§4).

**Resumen:** nivel **medio-grande en Blink**, dominado por el *carousel* CSS (`::scroll-marker`, `::scroll-button`, `::column`) y el select personalizable. 22 flags pasan a `stable` (json5 134→135, V) y 21 nacen `stable`; solo ~11 tienen cara web. FW tiene ya el flag en `experimental` de 8 de ellas (código base de la 128 presente), así que el coste es el delta 128→135. Papel Blink ~45–60 h; **estimación real 14–22 h** (÷4 sobre papel, pero el carousel es reescritura: ahí no divido). Ningún cambio en red/huella. Ver §5: **un solo cambio de IDL afecta a bindings (multi-draw WebGL), de bajo riesgo**.

#### 1. Flags que pasan a `stable` (134 → 135) y nuevas `stable`

Estado en FW = json5 de FW (cr128 + parche de bc) (V). Tamaño = líneas cambiadas FW(128+parches)→135 en ficheros de código sin tests (V, `area.sh`; es el techo, incluye lo del 129–134 no portado). Coste = horas reales (S). Baseline/otros motores = de memoria (S).

| Flag (FW) | Qué es / otros motores | Commits (flip y clave) | Tamaño | Coste | Propuesta |
|---|---|---|---|---|---|
| `CSSPseudoScrollMarkers`, `CSSPseudoScrollButtons`, `CSSPseudoColumn`, `PseudoElementsFocusable` (exp / ausentes) | *CSS carousel*: `::scroll-marker(-group)`, `::scroll-button()`, `::column`, `scroll-marker-group`, `scroll-target-group`. Solo Chrome (S) | flip 27a528fe68 (V); 4a90433754, 81d4fd37ec, eef593cc87 (`scroll-marker-contain`, experimental), fe39f54ab8, e118d70791, 65270f9c4e, 98a9b8203d, c16dd65f4d, 27fde48102, cv/carousel 74e940f3a4 7aa0764dfd da08391469 | Ficheros NUEVOS `scroll_marker_pseudo_element.*`, `scroll_marker_group_pseudo_element.*`, `scroll_marker_group_data.h` (~680 líneas); `pseudo_element.cc` 318, `pseudo_element_data.h` 138; + layout/paint/focus/animations. ~+2500/−500 | **8–12 h** (reescritura; el mayor del nivel) | **portar al final** (Chrome-only, riesgo alto en `pseudo_element.cc`/focus); si el tiempo aprieta, 1.N.x aparte. Decide COORDINACIÓN |
| `CSSNestedPseudoElements`, `CSSMarkerNestedPseudoElement` (ausente / exp) | pseudo-elementos anidados (`::marker::before`…) y `::marker` en `::scroll-marker`. Chrome | flip 20c4cc86a4 | con el carousel (`css_selector_parser.cc` 655, `selector_checker.cc` 932 incluyen más) | 1–2 h | con el carousel |
| `CustomizableSelect`, `SelectParserRelaxation`, `InputClosesSelect` (exp/exp/ausente) | `<select>` con `appearance: base-select`, `::picker(select)`, `<selectedcontent>`, parser relajado. Solo Chrome; Safari/Firefox en estandarización (S) | flip 425a3d1c5f (SPR+CS), e53a28a42a (InputCloses); 6030783edb, 60804161fb, c120b20791, 0fa0d8c028, 51193abdb9, 50311f85e2 (crash a11y) | `html_select_element.cc` 913, `select_type.cc` 751, `html_option_element.cc` 458, `option_list.cc` 132, `html.css`, a11y | 5–8 h | **portar** (visible en formularios; Chrome 135 la enciende a todos). Unir las 3 y los arreglos de §4 |
| `HTMLCommandAttributes` (nueva; antes `HTMLInvokeTargetAttribute`/`HTMLInvokeActionsV2`, ya renombradas) | `command`/`commandfor` en `<button>`, `CommandEvent`, `oncommand`. Firefox 144, Safari 26.2 (S) | flip 85364ff7e3; 33c0328e77 (renombre), 17926bb6ea, 1b6a541a24, bdfd9bd0e1 | `html_element.cc` 504, `html_button_element.cc` 300, `html_input_element.cc` 203, `command_event.*` | 2–3 h | **portar** (varios motores). En el 134 se dejó `request-close` fuera: ahora cabe |
| `CSSShapeFunction` (ausente) | `shape()` en `clip-path`, `offset-path`, `shape-outside`. Safari 18.4, Firefox 142 (S) | flip 5646d3a9a1 (1 línea); código en 129–134 | NUEVOS `css_shape_value.cc/.h` (~350), `shape_functions.h`, `basic_shape_functions.cc` 296, parser + interpolación | 3–5 h | **portar** |
| `ObservableAPI` (exp) | `Observable`, `Subscriber`, `EventTarget.when()`. Solo Chrome (S) | flip **10a2f47aff** (merge M135 del 11-03; el original no está en main), bf92734b27, e35d6616b7, e24c9459e6 | `observable.cc` 1068, `subscriber.cc` 143 | 3–4 h | **portar** |
| `FetchLaterAPI` (exp) | `fetchLater()`. Solo Chrome | flip d1338cefdd; 81858676da | NUEVOS `fetch_later_util.cc/.h` (~540) | 2–3 h | **portar** con el arreglo de crash 8a947848b8 (§4). Si cuesta, aplazar |
| `NavigateEventSourceElement` (exp), `NavigateEventPopstateLimitations` (nueva) | `NavigateEvent.sourceElement`; popstate según spec | 61a28abed5; cd6fd72eb9 | `navigate_event.cc` 179 | 0,5–1 h | **portar** |
| `AOMAriaRelationshipProperties` (exp) | reflexión de elementos ARIA (`ariaActiveDescendantElement`…). Safari/Firefox 119 (S) | flip 163f516c9a | `element_internals.cc` 58 | 0,5–1 h | **portar** (flip) |
| `CSSLogicalOverflow` (test) | `overflow-block/inline`. Firefox/Safari (S) | flip 2d63b38fdf | `html.css` + props | 0,5 h | **portar** |
| `CSSSafeAreaMaxInset` (ausente) | `env(safe-area-max-inset-*)` | 9c7a5d10e5, flip 64a7f3b746 | `style_environment_variables.cc` 33 | 0,3 h | portar (barato) |
| `CSSInert` (ausente) | propiedad `interactivity: auto|inert`; `inert` pasa a ser UA style. Solo Chrome | flip 66c0b303f4; después **ae21fa404d** (fuera del shorthand `all`) | `css_properties.json5`, `ax_object.cc`, `html.css` | 2–3 h | portar con ae21fa404d (cambia cómo funciona `[inert]`: probar `<dialog>`/popover) |
| `CSSAnchorRememberedScrollOffset` (nueva) | anchor positioning: recuerda el desplazamiento | 3b7bcf05af, b8a2fd50e3 | pequeño | 0,5 h | portar (FW lleva anchor) |
| `StrongBolder`, `CorrectStylesForLists`, `OptionLabelAttributeWhitespace`, `ResolveVarStylesOnCopy`, `SameValueTextContentFiresMutationObservers`, `RadioInputNextButtonInScope`, `SelectNoMouseUpForKeyboardSelection`, `SchedulerYieldCrossOriginFix` (nuevas) | cambios de comportamiento pequeños: `<b>/<strong>` `font-weight: bolder` (0f34660cbc), UA de listas (923e985590), etiqueta de `<option>` en blanco (06f3c0350d), `var()` al copiar (49ca6f6089), `textContent` igual dispara MO (9be8c38c3b), radios fuera de form (1130886598), teclado no dispara mouseup (b63bfbf34b) | los indicados (S para los flips) | 1 línea a decenas | 2–3 h el conjunto | **portar** (`html.css` y editing; probar con `motor-135.html`) |
| Editing/layout/paint: `AdjustStartOfParagraphToMoveDuringIndent` (528bccdc9f S), `PartialCompletionNotAllowedInMoveParagraphs` (9c070c13a5 S), `PrevOrNextCandidateIsEditingRootChild`, `FindFirstMisspellingEndWhenNonEditable` (16874a5647), `CollapseZeroWidthSpaceWhenReuseItem` (b71045ab25), `CssDecoratingBoxPseudoFix` (c933c85763 S), `NodeInUAShadowRootUnderAnonymousBlockFlow`, `ScrollCullRectFromContainerRect` (7acc815c4b), `ForceDelayedIntersectionUpdate` (92c1ca1b0a, 7df9c8ab21), `IsolatedSVGDocumentOptimization`, `SvgInlineRootPixelSnappingScaleAdjustment` (7a30176149), `CascadedAfterChangeStyle` (208c850572 S) | correcciones/rendimiento sin cara web | — | pequeño | 1–2 h el conjunto | portar los de editing y layout si caen limpios; **aplazar** SVG/IO/cull rect (rendimiento) |
| `BackForwardCacheUpdateNotRestoredReasonsName`, `EventTimingSelectionAutoScrollNoInteractionId`, `RTCEncodedFrameTimestamps` | métricas / `NotRestoredReasons.name` / WebRTC encoded transform | af269bab5f, 21c80f9a63, 7624f1cb18 | — | — | **aplazar** (sin demanda) |
| `MediaStreamTrackWebSpeech`, `MediaRecorderUseMediaVideoEncoder` (Mac: stable) | Web Speech sobre pista; MediaRecorder con `media::VideoEncoder` (VideoToolbox) | 0cf7b0a506, ab66fe87c0 | — | — | **fuera** (voz = servicio de Google; encoder: riesgo API Mojave, 0 demanda) |
| `AriaNotifyV2`, `CSSContainerProgressNotation`, `CSSMediaProgressNotation`, `CSSInlineIf*`, `CSSCornerShape`, `CSSReadingOrder`, `CSSPreferredTextScale`, `ContainerTiming`, `WebAuthenticationImmediateGet`, `DeviceBoundSessionCredentials`, `TranslationAPIV1`, `AnimationTrigger`, `SpeculationRulesTargetHint`… | nuevas en `experimental`/`test` | — | — | — | no entran. Ojo: Chrome **desenvió** en el 135 `progress()`, `abs()`, `sign()` (7f0beaff89, a790d9f93b, 03943066cd; ya `experimental` en FW): no encender |

**Privacy Sandbox/Fenced/Storage Access/huella/WebGPU (regla 20):** en este paso no sube a `stable` ninguno nuevo (V: no aparece en el diff 134→135). Cambian de estado solo `DirectSockets*InWorkers` (test), `FledgeClickiness` (test), `CapturedSurfaceResolution` (Win), `DeprecateMaxInterStageShaderComponents` (WebGPU): fuera. Quitadas de json5 (ya en código, V): `FedCmAuthz/ButtonMode/Disconnect/DomainHint/Error/AutoSelectedFlag`, `FledgeReportingTimeout`, `HTMLPopoverHint`, `PopoverAnchorRelationships`, `PopoverButtonNestingBehavior`, `NavigationActivation`, `SchedulerYield`, `SidewaysWritingModes`, `MultiSmoothScrollIntoView`, `ConcurrentViewTransitionsSPA`, `AtomicMoveAPI`, `HitTestOpaqueness*`, `TextSizeAdjustImprovements`, etc. Las que FW ya tenía `stable` no hacen nada; **ojo** `AtomicMoveAPI` (FW `test`), `HitTestOpaqueness` (FW `experimental`) y `TextSizeAdjustImprovements` (FW la tiene `stable`, V) siguen el criterio del 134: aplazar / aplazar / ya.

**Orden propuesto:** (1) flips pequeños y baratos (AOM, LogicalOverflow, SafeAreaMaxInset, sourceElement/popstate, anchor offset) 2–3 h; (2) `command/commandfor` 2–3 h; (3) `shape()` 3–5 h; (4) Observable 3–4 h; (5) fixes pequeños de comportamiento + editing 3–5 h; (6) select personalizable 5–8 h; (7) `interactivity` 2–3 h; (8) FetchLater 2–3 h; (9) carousel 8–12 h; (10) fusiones de §4. Total real 33–45 h si se portan todos; **14–22 h** si el carousel y FetchLater van a una 1.N.x aparte (S, contando el factor ÷4 solo en lo que no es reescritura; revisar tras el primer paso).

#### 2. Escapes (stable en ≤135, FW sin stable, flag presente) (V, flags-escapes.py sobre 117..135)

58 filas (`esc.tsv`); 41 ya documentadas y decididas en 129–134 (hardware/solo-Chrome/Privacy Sandbox/rendimiento: `DevicePosture`, `DirectSockets`, `UnrestrictedUsb`, `WebXRHandInput`, `ElementCapture`, `CredentialManagerReport`, `ReportEventTimingAtVisibilityChange`, `DocumentPictureInPicturePreferInitialPlacement`, `FedCm*`, `Fledge*`, `PrivateStateTokens`, `FileSystemObserver`, `PageMarginBoxes`, `FontVariantEmoji`, `FontVariationSequences`, `FontationsFontBackend`, `StaticAnimationOptimization`, `ContinueEventTimingRecordingWhenBufferIsFull`, `CSSScrollSnapChange/Changing/Events`, `CSSSnapContainerQueries`, `CSSStickyContainerQueries`, `WebGPUSubgroupsFeatures`, `WebGPUHDR`, `AtomicMoveAPI`, `DynamicScrollCullRectExpansion`, `IntersectionOptimization`, `UnblockTouchMoveEarlier`) → **sin cambios**. Apagados a propósito (decididos 126–130: `Database`, `PrefixedVideoFullscreen`, `MutationEvents`, `CSSCustomStateDeprecatedSyntax`, `DOMParserIncludeShadowRoots`, `ElementGetInnerHTML`, `DeprecatedRequestAdapterInfo`) → sin cambios.
Nuevos o no nombrados en los docs:

| Flag (FW) | Propuesta |
|---|---|
| `AOMAriaRelationshipProperties` (exp), `CSSLogicalOverflow` (test), `CSSMarkerNestedPseudoElement` (exp), `CSSPseudoScrollMarkers` (exp), `FetchLaterAPI` (exp), `NavigateEventSourceElement` (exp), `ObservableAPI` (exp), `SelectParserRelaxation` (exp) | son los del §1 (stable en 135): portar según §1 |
| `MediaRecorderUseMediaVideoEncoder`, `MediaStreamTrackWebSpeech` ('') | fuera (§1) |
| `ExcludeTransparentTextsFromBeingLcpEligible` (exp; quitada en 133) | aplazar (solo métrica LCP) |
| `LongTaskFromLongAnimationFrame` (test), `MultiSelectDeselectWhenOnlyOption` (test), `LayoutIgnoreMarginsForSticky` (ninguna) | restos de 117–125 sin demanda: aplazar. `MultiSelectDeselectWhenOnlyOption` es de `<select multiple>`: mirar con el select personalizable (0,2 h) |
| `CSSInsetAreaProperty`, `CSSCalcSizeFunction` (quitadas en 133, FW vacío / exp) | decididas con anchor positioning (131): sin cambios; recomprobar al portar `CSSAnchorRememberedScrollOffset` |

#### 3. macOS 10.15+ (S)
No revisado a fondo (fuera del alcance de Blink): los `.mm` de Blink no aparecen entre los 40 commits de rama; el diff 128→135 de `platform/` (`font_matcher_mac.mm`, `locale_mac.mm`) queda para el subagente de «fuera de Blink».

#### 4. Candidatos regla 17 (V la lista; la gravedad hay que cruzarla con CVE)

**Áreas/ficheros que se portan en el 135** (para que SEGURIDAD-PORTES busque arreglos posteriores):
- Select: `core/html/forms/{html_select_element,select_type,html_option_element,option_list}.{cc,h}`, `core/html/resources/html.css`, `core/css/{selector_checker,parser/css_selector_parser}.cc`, `modules/accessibility/ax_object_cache_impl.cc`.
- Carousel: `core/dom/{pseudo_element,scroll_marker_pseudo_element,scroll_marker_group_pseudo_element}.cc`, `scroll_marker_group_data.h`, `pseudo_element_data.h`, layout/focus/animations.
- Invoker: `core/html/{html_element,forms/html_button_element,forms/html_input_element}.cc`, `core/events/command_event.cc`.
- `core/dom/{observable,subscriber}.cc`, `bindings/core/v8/observable_array_exotic_object_handler.h`; `core/fetch/fetch_later_util.cc`; `core/navigation_api/navigate_event.cc`; `core/css/{basic_shape_functions,css_shape_value}.cc`; `core/css/css_properties.json5` (`interactivity`); `core/css/style_environment_variables.cc`.

**Arreglos ya fusionados en la rama 135 (hasta .117) que tocan Blink** (40 en total; los que importan a lo que portamos o ya tenemos). Cruzar con `crbug`:

| Commit | Qué | crbug |
|---|---|---|
| 8a947848b8 | FetchLater: crash en `GetReservedDeferredFetchQuota()` | 407556082, 408106277, 409378979 |
| dd1398d69d | eventos de cambio de dispositivo en cola crashean el renderer (= 53afd466dc del 134) | 403348706, 404042495 |
| de2eb485a1 | no extraer bucketing tras pseudo-elementos respaldados por elemento (RuleSet) | 409981769 |
| ae21fa404d | `interactivity` fuera del shorthand `all` | 408241037, 409052825 |
| b93ddf3764 | `attr()` fallback con cadena vacía (FW lleva attr()) | 396334721, 401489004 |
| 51138e8e66 | `StyleResolver::ComputedValue` sin estilo padre | 404734313 |
| 9fac8640c3 | color de `::picker(select)` en `appearance: auto` | 404464591, 405189626 |
| 409faf5574, 83832f6662, 367f76b6ac | a11y: select imperativo, árbol tras `aria-owns`, atributos cacheados | 402438863, 377975067, 400836342 |
| 69af44067c | `html_dialog_element.cc`: CHECK innecesario (dialog del 134) | 405085122, 405444738 |
| 11ae9f743f | contadores de popover en UA ShadowRoot | 404262626 |
| 5ba87566df | carrera en animaciones pendientes | 409086867, 409633595 |
| a3be1aa6f9, 746b0a2d7c | canvas 2D `context_lost`; WebGL tex con SVG | 371939829/407062187; 41357911/409203678/410027185 |
| a629cc4312, 2efdf2a6f8, ce7a5f6b60, 0fda79e536 | redondeo de paint offset, sticky, `DrawScrollingContentsOp` | 401693546, 404066170, 404958325/407051809 |
| 1fb3496b32 | PEPC: renombra `onresolve`/`ondismiss` (PEPC sigue fuera) | — |

(Lista completa de los 40 en `/tmp/claude-0/port/i135/td/` + `b135.json`.)

#### 5. IDL y bindings (V: comparados 134.0.6998.166 y 135 con `[NoAllocDirectCall]`/`[PassAsSpan]`, y FW = 128 + parches)
- **Único cambio 134→135:** commit **32f7cb889c** («Allow larger buffers in multi-draw extensions», crbug 395670641): `webgl_multi_draw.idl` (4 métodos) y `webgl_multi_draw_instanced_base_vertex_base_instance.idl` (2) pasan de `(Int32Array or sequence<long>)` a **`Int32List`/`Uint32List` con `[NoAllocDirectCall]`**. Son los mismos typedef (`[PassAsSpan]` + `BufferSourceTypeNoSizeLimit`) que ya aplicamos a `uniform*fv` en FW (parche de `webgl_rendering_context_base.idl`), y son **una sola firma por método** (sin sobrecarga): el CHECK de V8 13.4 de «misma aridad» no salta. Toca además `webgl_multi_draw*.cc/.h` y `generated_in_core.gni`. Comprobar con `getContext('webgl')` + `ANGLE_multi_draw`.
- **Sobrecargas con `[NoAllocDirectCall]` en la 135 (V)**: `putImageData` (3 y 7 args), `setTransform` (6 args / `optional` 1), `stroke()` / `stroke(Path2D)`, `setBindGroup` (3 y 5 args, WebGPU): **todas con aridad distinta** y solo una de cada par lleva el atributo; son idénticas en el 134. Aviso: el 134 ya movió la parte de canvas a `canvas_recording_context_2d.idl` (22 atributos) y `base_rendering_context_2d.idl`; **FW sigue con `canvas_rendering_context_2d.idl` y `offscreen_canvas_rendering_context_2d.idl` de la 128 (8 + 8)**. Si se porta ese refactor, repasar los parches de FW de esos dos IDL (V: existen) y buscar pares de misma aridad.
- Nuevos `[PassAsSpan]` en la 135 respecto de FW (V): `bluetooth_remote_gatt_{characteristic,descriptor}.idl`, `hid_device.idl`, `usb_device.idl`, `file_system_sync_access_handle.idl`: todos ya estaban en el 134, sin sobrecargas rápidas; Bluetooth/HID/USB están fuera de FW.
- Generador: solo `35fdbc236c` (NRVO en `generated_code_helper.h`), inocuo.
- Barrido hecho con `/tmp/claude-0/port/i135/nadc.py` (agrupa operaciones por nombre y aridad): FW 128+parches = 0 pares con `[NoAllocDirectCall]` repetidos salvo `setBindGroup`; 135 = 4 (arriba).

### Informe V8 13.5

### Inventario V8 para el nivel 135 (MOTOR-31, solo lectura)

Marcas: V = verificado (git/diff/grep sobre el código), S = supuesto. Trabajo en `/tmp/claude-0/port/v8inv/` (v8 = 13.4.114.21 y 13.5.212.10 a profundidad 1; hist = historia filtrada desde 2024-10; `v8rev.sh`/`v8rev.txt` = resultado por parche).

#### 1. Versión y rama
- V: Stable de Mac más reciente de la 135 = **135.0.7049.117** (6-05-2025; `versionhistory.googleapis.com`, chromiumdash da 403 por el proxy). Todas las 135.0.7049.84..117 fijan el mismo V8 en su DEPS.
- V: **V8 13.5.212.10 = e2591684c45463aa1e46ebefc3fd35deee63f37c** (`Version 13.5.212.10`). `branch-heads/13.5` = 6e278d6 (13.5.212.11 = solo un cambio de espacio en blanco, 740f6f6): usar .10, o .11 da igual.
- V: **no es LTS** (la LTS vigente en la rama es la M132 = 13.2.152.56; la siguiente LTS es otra, no la 135). 13.4 y 13.5 divergen desde 27af2e93 (main#98459); 13.5 tiene 581 commits de main + 9 merges propios (212.1 a .10) sobre ese punto.
- V: DEPS de terceros de V8 13.4 -> 13.5: **simdutf 5a9a2134 igual, fast_float cb1d42aa igual, highway 00fe003d igual, fp16 0a92994d igual**. Cambian solo abseil (aaed376e -> 2705c665) e icu, zlib, protobuf (los pone Chromium; V8 13.5 no añade ningún `#include "absl/..."` nuevo). Chromium 135 trae simdutf 6.0.2 como la 134 (S: sin comparar los ficheros uno a uno). Nuevo en DEPS: `third_party/partition_alloc` (solo d8 independiente; `assert(!build_with_chromium || !v8_enable_partition_alloc)`): no entra.

#### 2. Solo-LTS y merges de 13.4
- V: **los 11 + ea2f03dfff siguen faltando en 13.5** (hay que volver a ponerlos todos): 13.5 es de febrero de 2025 y los arreglos son de mayo a septiembre de 2025; ni los orígenes en main (a5f18bb86, ec6c18478, eba18128, c58fda1f, 9a884b1b, 22e9d962, 1d82eec6, 7bc0a67e, 45eb42cd, 62ee3244, 37d6fa3f) son ancestros de 13.5.212.10 ni hay merge ni cherry-pick con ese sha ni con el asunto. ea2f03dfff (26-10-2026) tampoco.
- V: los 104 parches de `patches/v8` ya los llevan; todos esos aplican limpios sobre 13.5 (ver 3), salvo la parte de ea2f03dfff (a mano, 3).
- V: **merges de la rama 13.4 posteriores a 13.4.114.21: ninguno** (4f282ae4 es la cabeza). Merges de 13.4 que 13.5 no tenga: de los 14 relevantes, 12 están por sha; los otros 2 (`[context] Call correct load for lex var in LoadGlobalIC`, `[turbofan] Fix TransitionElementsKindOrCheckMap`) están en 13.5 como `fe19441`/`30a1208` (misma corrección, otro sha); lo demás es loong64/mips64/ppc. **Nada que recuperar de 13.4.**
- V: la 13.5 trae 3 merges propios útiles: `a0f977f1` (Maglev, elisión de write barrier), `beff10e3` (Maglev, flag `maglev_allocation_folding`), `0aaafa85` (typed array length + `super`, Maglev). No hay merges de seguridad de TurboFan en 13.5.212.1..10.

#### 3. patches/v8 sobre 13.5.212.10 (`git apply --check`, `v8rev.sh`; 104 parches)
**93 aplican limpios** (comprobado también contra 13.4: AA). 1 ya está upstream. 10 no aplican:
- **Ya en 13.5 (se suelta, 1):** `test-mjsunit-maglev-regress-402646504.js` (origen dd4c05ce, mergeado como 0aaafa85); y en `maglev-graph-builder.cc` el hunk «typed array + super» de ese mismo arreglo.
- **Obsoletos (se sueltan, 2):** `src-base-platform-mutex.cc` (V8 13.5 **borró `SpinningMutex`**: ya no hay `os_unfair_lock_lock_with_options` en V8, solo `absl::Mutex`; ver 4b) y `src-compiler-pipeline.cc` salvo su hunk 2 (el turboshaft `turboshaft_pipeline.AllocateRegisters(...)` pasa a `if (!...) return false;`): las definiciones `PipelineImpl::AllocateRegisters` de TurboFan ya no existen en 13.5 (solo sus declaraciones).
- **Contexto trivial (5, ~1 h):** `BUILD.gn` (`v8_headers` gana `":v8_tracing"` en deps), `builtins-collections-gen.h` (`TNode<JSAny> NormalizeNumberKey`), `maglev-ir.h` (SBXCHECK_LT en `get_by_index`, 13.5 lo tiene en otra posición), `maglev-regalloc.cc` (el final de `AllocateRegisters` ahora acaba en `ApplyPatches(block);`), `flag-definitions.h` (hunk 3 = `maglev_allocation_folding`: **ya upstream**, se quita; los otros 3 entran).
- **A mano (3 ficheros + 1 nuevo, ~4 h):**
  - **Stack clash (ea2f03dfff, FlyWeb `pipelines.{h,cc}`):** en 13.5 `Pipeline::AllocateRegisters(config, cd, run_verifier)` es `void` y su cuerpo está en `turboshaft/pipelines.cc:22` (en 13.4 estaba en `pipelines.h`). Hay que volverla `bool` (declaración en `.h:406`, `return true/false`, guarda de 4 KB como en upstream, y el llamador `.h:358` propaga). `pipelines.cc.patch` **aplica pero ya no es completo** (solo cambia los llamadores): regenerarlo. Cuidado: «AA» no garantiza semántica.
  - **`maglev-graph-builder.cc/.h` (15 + 2 hunks):** 6 de 15 rechazan. De esos, 4 ya son upstream en 13.5 (write barrier `current_allocation_block_ == allocation`, typed array `super`, `maglev_allocation_folding` nivel 1/2 con `BuildInlinedAllocation` y `ClearCurrentAllocationBlock`; el hunk 2 del .h `BuildInlinedAllocationImpl` también): se quitan. Quedan 2 a mano: (a) `TryBuildStoreField`: la condición `access_mode == kStore` pasa a `!= kStoreInLiteral` (13.5 ya tiene el camino de `TryFoldLoadConstantDataField` + `CheckValueEquals*`, el cambio es de una línea, FS.29 define-const-data-field); (b) `ShouldInlineCall` -> `CanInlineCall` en 13.5: añadir la guarda `MaxInliningId` (y probablemente en `MaglevInliner::Run`, `maglev-inlining.h`, que es nuevo en 13.5; S).
  - **Nuevo, d73530cf** (`[typed array length loading] Fix a correctness issue in Turbofan`, bugs 402646504/403345130, main 17-03-2025, **no mergeado a 13.5**): ver 6. Port de ~1,5–2 h. d73530cf añade `TypedArrayLength_string` a `heap-symbols.h` (cambia `static-roots.h`, 204 líneas): evitarlo (S: bastaría no optimizar cuando `receiver != lookup_start_object`, como hace Maglev con un deopt).
- Época de caché: `version.h` aplica (subir).

#### 4. Lecciones de la 2.3.0
**(a) API (V: diff `api.cc` + `include/` 13.4.114.21 -> 13.5.212.10, 522 líneas de api.cc)**
- **Ningún `CHECK`/`ApiCheck` nuevo que Blink pueda disparar.** El único CHECK promovido en `api.cc` es `ValidateFunctionCallbackInfo`: `CHECK(info.This()->IsObject())` (antes `IsValue`), pero solo lo llaman `DCHECK(i::ValidateCallbackInfo(info))` de **d8** y de builtins internos, no el código de Blink/gin (V: git grep). Nuevos CHECK no-API: `CHECK_NULL(default_isolate_group_)` (inicialización por proceso de `IsolateGroup`; gin la llama una vez; S) y CHECKs de cppgc-js (`in_atomic_pause_`, `marking_done_`; internos).
- **El CHECK de la 13.4 sigue igual en 13.5:** `FunctionTemplate::NewWithCFunctionOverloads` `CHECK_NE(ArgumentCount)` (misma aridad) idéntico: el arreglo de Blink de la 2.3.0 sigue siendo necesario; no hay nada más de ese estilo en `api.cc`.
- **Quitado: `FunctionCallbackInfo::Holder()` y `HolderSoonToBeDeprecated()`.** Blink 128 no lo usa (V: sus `Holder()` son de `PropertyCallbackInfo`, que sigue; cr128), **pero gin sí: `gin/arguments.h` `GetHolder` y `gin/arguments.cc` `GetHolderCreationContext` usan `info_for_function_->Holder()` en 116 y en 128 (V, raw github): error de compilación; cambiarlo a `This()` (Chromium 135 hace lo mismo), 30 min.**
- Cambios compatibles: `Local`/`Global`/`Persistent` upcast pasan a `requires(is_base_of)` (no rompe), `ExternalStringResourceBase::EstimateMemoryUsage` -> `size_t` (Blink 128 no lo sobreescribe; V grep), `kGarbageCollectionReasonMaxValue` 28 -> 29 (Blink solo lo pasa a `UMA_HISTOGRAM_ENUMERATION`), `EmbedderRootsHandler::TryResetRoot` por defecto `return false` (Blink 128 lo sobreescribe), nuevos `UseCounterFeature` kRegExpEscape/kFloat16Array (S: sin switch exhaustivo), `ArrayBuffer::Allocator::GetPageAllocator()` virtual (default nullptr) y `NewDefaultAllocator(const IsolateGroup&)`, `Value::IsPrimitive/GetHash`, `Function::GetScriptLocation`, `Isolate::GetHashSeed`, `String::WriteUtf8V2` +parámetro por defecto. `AttachCppHeap`/`CppHeap::Terminate` pasan a `V8_DEPRECATED` (Blink 128 los llama; `build.sh` apaga `v8_deprecation_warnings`).
- Flags: desaparecen `enable_sealed_frozen_elements_kind`, `incremental_marking_bailout_when_ahead_of_schedule`; **vuelve `trap_on_abort`**. gin 116/128 no pasa ninguno (los flags `--reclaim-unmodified-wrappers` y `--wasm-to-js-generic-wrapper` que gin pasa ya no existen en 13.4 tampoco: igual que hoy).
- Gate de 128: `parallel_reclaim_unmodified_wrappers` pasa a **true**; Blink 128 ya implementa `TryResetRoot` (la ruta paralela), S: sin carrera (misma situación que ya probó la 134).

**(b) macOS 10.15+ en src/base, libplatform, heap/base (V: grep de `__builtin_available`, `@available`, `API_AVAILABLE`, `dlsym`, `weak`, `os_unfair_*`, `OS_UNFAIR_*`, `pthread_*_np`, `os_sync_*`, `kern_`, `mach_`, `MAP_JIT`, `sysctl` sobre ambos tags + diff completo de `src/ third_party/ include/` 13.4->13.5)**
- **Prioridad 1 resuelta por upstream:** V8 13.5 **elimina `SpinningMutex`** (`mutex.cc/.h`): el `OS_UNFAIR_LOCK_ADAPTIVE_SPIN` que abortaba en Mojave desaparece y nuestro parche `src-base-platform-mutex.cc.patch` se suelta. Los usuarios (`api.cc`, `bounded-page-allocator`, etc.) pasan a `base::Mutex` = `absl::Mutex` (la 13.4 ya usaba `absl::Mutex` para `Mutex`); `RecursiveMutex` ahora es `Mutex` + `thread_id_` + `OS::GetCurrentThreadId()` cacheado con `thread_local` (S: C++ thread_local OK en Mojave, igual que en Chromium).
- **Ninguna API de 10.15+ nueva.** El resto de usos de macOS son idénticos a 13.4 (`platform-darwin.cc`, `platform-posix.cc`: `pthread_set_qos_class_self_np`, `pthread_setname_np` por `dlsym`, `memfd_create` por `dlsym`, `MAP_JIT`, `pthread_jit_write_protect_np` solo arm64; `time.cc`: `thread_info`/`mach_timebase_info` desde 10.x).
- **Aviso fuera de V8 (S, para una futura base nueva):** `base/allocator/partition_allocator/.../spinning_mutex.cc` de **Chromium 133/134/135** lleva el mismo patrón `os_unfair_lock_lock_with_options` + `OS_UNFAIR_LOCK_ADAPTIVE_SPIN` con `__attribute__((weak))` que abortó la 13.4 (en 128 no estaba, 0 coincidencias). No afecta a nuestra base 116/128; sí si algún día se sube `base`/PartitionAlloc.

#### 5. CPU
- V: **nada nuevo que exija AVX/AVX2/F16C/BMI sin detección.** No cambian `cpu.cc`, ni flags de `BUILD.gn`/`gni` (`-m...`). Lo nuevo en x64: `LoadCodePointerTableBase`, Maglev con constantes inmediatas (`addl/subl reg, imm`), selector de instrucciones x64 sin la ruta TurboFan (Adapter), `AndInt32/OrInt32`; las ramas AVX del selector siguen tras `IsSupported(AVX)`.
- V: `src/objects/simd.cc` gana `Uint8ArrayToHexFastWithSSE` (SSE2 con `_mm_*`; `#ifdef __SSE3__`, detección `get_vectorization_kind()`; solo con `js_base_64`, que es «in progress»). `third_party/simdutf`/`fast_float`/`highway`/`fp16`: misma revisión que 13.4. Wasm: nuevos `wasm-shuffle-reducer`/`wasm-simd-phase` (flag solo arm64).
- S: simdutf elige por CPU en ejecución (como en la 134): comprobar en la 5,1 que no usa la ruta Haswell/Icelake.

#### 6. Maglev, Turboshaft, regla 19
- **Defectos que cambian en 13.5 (V, diff de `flag-definitions.h`, 86 líneas):** **`typed_array_length_loading`: experimental -> `true`** (upstream lo enciende en la 13.5, regla 19: se queda encendido); `separate_gc_phases` false -> true; `parallel_reclaim_unmodified_wrappers` true (nuevo); `update_allocation_limits_after_loading` -> true; `verify_simplified_lowering` -> false (release); `turboshaft_csa` implica `load_elimination` en débil. Nuevos apagados: `maglev_cons_string_elision`, `maglev_pretenure_store_values`, `maglev_non_eager_inlining`, `additive_safe_int_feedback`, `incremental_marking_unified_schedule` (false). **Sin cambios: `maglev` (true), `maglev_untagged_phis` (true), `turbolev` (experimental, off), `turboshaft_*`.** JS shipping igual que 13.4 (Error.isError, Atomics.pause, Promise.try, RegExp modifiers y nombres duplicados); staged: explicit resource management, Float16Array, **RegExp.escape (nuevo)**.
- **Typed array length (riesgo de seguridad, S):** al activarse el flag, el arreglo de TurboFan d73530cf (bug 403345130, «Fixed») **no está en 13.5.212.10** (solo el de Maglev). Opciones: portar d73530cf (~2 h) o `--no-typed-array-length-loading` (contra la regla 19). Recomendado: portar.
- **Maglev (V):** los parches de Maglev siguen apagados por nuestro parche de flags; en 13.5 la deuda baja: ya traen 54 commits de Maglev de ene-mar 2025 (p. ej. cc8d1c54 const field, 28ee00b `vector-based basic blocks`, c5e86be `Buffer nodes`, `maglev-inlining.h` nuevo) y 3 merges de 13.5.212.x. De los 16 arreglos de Maglev de FS.34 que llevamos: **3 ya upstream** (write barrier, `maglev_allocation_folding` f7bf2ff1fa-equivalente, typed array super) y el resto (413419840, 447658917, 495751197, 523884658, 536945254, 547819997, 559932543, 550360762, af7d1483a5…) **siguen sin estar en 13.5** (todos de abril 2025 a septiembre 2026). Deuda restante de merges 13.5..15.8: 84 grupos que tocan Maglev - 3 = 81 (S; revisar los que dependen de `maglev-graph-builder` de 13.5 que ya es más cercano a main: menos «a mano» que en 13.4).
- Mjsunit: se esperaba `maglev/extras-cped` como único fallo conocido (S).

#### 7. Coste estimado (horas reales)
- Fijar rev 13.5.212.10 + `FlyWeb/v8-revision`/FLYWEB-SECURITY.md/época de caché: 0,5 h. `fast_float`/`simdutf`: 0.
- Parches: 5 de contexto trivial 1 h; stack clash a mano (`pipelines.{h,cc}`, `pipeline.cc` hunk 2) 1,5 h; `maglev-graph-builder.cc` 2 hunks 1 h; soltar mutex/pipeline/test 0,2 h; d73530cf 2 h (+ test mjsunit); regenerar los 104 con `v8regen.sh` y repasar: 1 h. **Total parches ~7 h.**
- gin `Arguments` Holder -> This y revisión del resto de `FunctionCallbackInfo::Holder()` en 116/128 fuera de Blink: 1 h.
- `d8` en la nube (13.5 + parches, mjsunit completo, tests de FlyWeb 9/9): 3 h de reloj (~1 h atendidas). Sin compilar en Mojave/Chromium: eso es de LOCAL.
- **Total: ~12 h reales (1,5 días) para V8; Blink 135 aparte.** Riesgo no medido: Maglev sobre el nuevo `MaglevInliner` y Turboshaft sobre `typed_array_length_loading` (S).

### Informe fuera de Blink

# Nivel 135, inventario «fuera de Blink» (cr134 -> cr135), solo lectura

MOTOR-31 (subagente de lectura), 29-10-2026. Marcas: **V** verificado en código o historial; **S** supuesto.
Base: la 128 NO se rebasa. Aquí «portar» = traer a la 128 el cambio de comportamiento observable de Chrome 135.

## 0. Tag y fuentes

- **Última Stable de Mac de 135: `135.0.7049.115`** (V; versionhistory de Google, plataforma mac, canal stable, fracción 1,
  servida 22-04 -> 29-04-2025; antes .96, .85, .42). Chromiumdash estaba bloqueado por el proxy; versionhistory
  (`versionhistory.googleapis.com/v1/chrome/platforms/mac/channels/stable/versions/all/releases`) sirve igual.
  Comparado contra `134.0.6998.166` (última Stable Mac de 134, la que usó el informe del 134).
- **Brave de nivel 135: 1.77.x** (V; `package.json` de brave-core): v1.77.95 = 135.0.7049.52, v1.77.97 = .84,
  v1.77.100 = .100, **v1.77.101 = 135.0.7049.115** (misma que la nuestra). v1.78.94 ya es 136.0.7103.60.
- Intervalo: 14 101 commits no-merge; revisiones de DEPS 134 -> 135 (V):
  BoringSSL `ea42fe28` -> `673e61fc` (35 rolls, 48 commits), QUICHE `e7d001c8` -> `25a56e31` (49 commits),
  ANGLE `914c97c1` -> `079266db` (169 commits), Skia `aefbd940` -> `5a44cdd7` (232 commits), Dawn `7056f50f` -> `53dfda5e`,
  SwiftShader `86cf34f5` -> `c12c1383`, V8 `4f282aea` -> `e2591684`.
- Método: diffs de directorio con Gitiles `+diff/134.0.6998.166..135.0.7049.115/<dir>` (net 2,7 MB, services/network, content/*, chrome, components,
  gpu, ui/*, media, base, cc: guardados en `/tmp/claude-0/port/fuera135/dif/`), ficheros sueltos con raw.githubusercontent, historia local
  `/home/user/chromium/hist` (mensajes y `git show --stat`), BoringSSL/QUICHE/ANGLE en clones blobless (`bssl.git`, `quiche.git`, `angle.git`).
  `+log` de Gitiles da 401/403: no sirve. Scripts: `feat.py` (BASE_FEATURE old/new), `mac.py` (API de macOS).

## 1. Huella de red 134 -> 135: dos cambios observables, ambos pequeños

**1.1 TLS (ClientHello). Un cambio: ALPS con el código nuevo (V).**
- `UseNewAlpsCodepointHttp2` y `UseNewAlpsCodepointQUIC` pasan de OFF a **ON** en `net/base/features.cc` (commit `90243a7416f`, 10-02-2025,
  «Enable Alps new codepoint as default», dentro de la 135). Efecto: la extensión ALPS del ClientHello pasa de 17513 (0x4469, antiguo) a
  **17613 (0x44CD, nuevo)**; cambia JA3/JA4 (hash de extensiones) y el campo de extensiones de JA4. Ya lo anunciaba `gpu-red-129-132.md` §3.1.
- Cableado ya en la 128 (V): `SSL_set_alps_use_new_codepoint` (`ssl_client_socket_impl.cc:765`), `crypto_config->set_alps_use_new_codepoint`
  (`quic_session_pool.cc:1969`), `ShouldQuicUseNewAlpsCodepoint` (`network_session_configurator.cc:311`). **Portar = invertir dos valores por
  defecto** (si Brave 1.77 no los toca: `chromium_src/net/base/features.cc` de v1.77.101 no los menciona; V).
  En QUIC el valor sale de `use_new_alps_codepoint` de los parámetros de prueba de Finch o, si no hay, del flag (V); el cambio de default del
  parámetro (`220d59101b2`) es de junio de 2025 (136+), no de la 135.
- BoringSSL (48 commits): **nada en ClientHello** (V, revisados uno a uno). Solo: `SSL_parse_client_hello`, `SSL_CREDENTIAL_set_must_match_issuer`/
  certificate_authorities (API de servidor/credenciales; Chrome no llama), quitar `SSL_VERIFY_PEER_IF_NO_OBC`, DTLS 1.3 HRR, PBES2 en PKCS12,
  ed25519 SPKI, «Revert Speed up sha512 on x86» y «Restore `__SHA__` compile-time check» (extensiones SHA de Intel con detección en ejecución o
  solo en tiempo de compilación; sin AVX obligatorio). Grupos (`X25519MLKEM768, X25519, P-256, P-384`), sigalgs, ECH, GREASE, permutación:
  `ssl_client_socket_impl.cc` **sin diff** (V, 0 líneas), `net/ssl/*` sin diff. No hace falta subir BoringSSL.
- Datos: HSTS preload (`transport_security_state_static.json` +1301/-1837 líneas, `.pins` y `_pins.json` 1 línea, **V**), lista de logs CT
  (`log_list.json` +8/-8). **Chrome Root Store: sin cambios** (V; ningún fichero de `net/data/ssl/chrome_root_store` en el diff). No altera el ClientHello.

**1.2 HTTP/2: sin cambios (V).** `spdy_session.cc`, `spdy_http_utils.cc`, `http_network_session.cc`, `http_util.cc` sin diff; `spdy_session_pool.cc` solo
`enable_ip_based_pooling` en `HasAvailableSession` (HttpStreamPool, que sigue apagada). SETTINGS, ventanas, orden de pseudocabeceras: iguales.
`http_request_headers.cc` solo renombra `SourceStream::SourceType` -> `SourceStreamType` (Accept-Encoding idéntico: `gzip, deflate, br, zstd`; la excepción
de FlyWeb sin zstd sigue en pie).

**1.3 QUIC: un cambio observable, en QUICHE, no en Chromium (V código, S captura).**
- QUICHE `f4690dbf` (20-12-2024, «Switch QUIC version negotiation to RFC codepoint») y su flag `quic_version_negotiation_rfc`: en la 134 el flag estaba
  a `false` (se enviaba el parámetro de transporte *draft* `0xFF73DB`); **QUICHE `475ee6de` («Enabling rolled out flags», 18-02-2025) lo pone a `true`
  y la 135 lo lleva**. Resultado: el Initial de QUIC envía `version_information` con el id **0x11 (RFC 9368)** en vez de `0xFF73DB`. Cambia la huella
  de los parámetros de transporte (JA4Q y similares). El flag se deprecó el 18-03-2025 (`064ae1b7`).
- La 128 **no** tiene el código nuevo (V: `transport_parameters.cc` de `aecfea15` solo tiene `kVersionInformation = 0xFF73DB`): hay que **portar `f4690dbf`
  (+72 líneas en `transport_parameters.cc`, +1 en la lista de flags; tests +203) y poner el flag a `true`**. Parche acotado, sin dependencias de Chromium.
- Resto de QUICHE 49 commits: MoQT, WebTransport, CONNECT-UDP-Bind, oghttp2 sin Huffman (opción, no por defecto), `QuicTimeWaitList`, borrado de flags
  de servidor (`quic_parse_transport_parameters_from_chlo`). Nada que toque los parámetros de transporte del cliente ni el orden de tramas. Chromium:
  `quic_chromium_packet_writer.cc` (`QuicIpAddress` -> `QuicheIpAddress`), `quic_session_attempt.h`: solo nombres.
- `kReportEcn` ON sin cambio; ningún flag QUIC de `net/base/features.cc` cambia de valor salvo ALPS.

**1.4 Client Hints / UA / cabeceras: sin cambio de salida (V).**
- `user_agent_utils.cc`: solo refactor (`GetFormFactorsClientHint` cambia de sitio; se borra `SetDesktopUserAgentOverride` de Android; `kUseMobileUserAgent`
  para iOS). `content/common/user_agent.cc` movió `GetOSVersion` pero conserva Mac = `10_15_7` si major > 10. Algoritmo GREASE idéntico al de la 134.
- Con semilla 135 el algoritmo da (calculado, V): `Sec-CH-UA: "Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"` (GREASE: `Not` +
  `greasey_chars[135%11]`=`-` + `A` + `[136%11]`=`.` + `Brand`, versión `greased_versions[135%3]`=`8`, permutación 3 elementos `orders[135%6]`={1,2,0}).
  Depende solo de `flyweb_engine_level`; el parche de Brave `BRAVE_GET_USER_AGENT_BRAND_LIST` no cambia de firma entre 134 y 135 (S: el diff de
  `user_agent_utils.cc` no toca `GenerateBrandVersionList`).
- Accept/Accept-Language/Sec-Fetch-*: `kFrameAcceptHeaderValue` y compañía sin diff. Nueva `Sec-Fetch-Frame-Top` detrás de `FrameAncestorHeaders` **OFF**
  (V; no sale en la 135). `ReduceAcceptLanguageHTTP` nuevo, **OFF**. Mapa permissions-policy <-> client hints se mueve de `blink::` a `network::`
  (refactor): los 94 features de `permissions_policy_features.json5` y sus defaults son idénticos (V, comparado programáticamente), así que
  `document.featurePolicy.features()` no cambia.
- Ojo, `client_hints.cc`: el parámetro `is_javascript_enabled` desaparece de `AddPrefetchNavigationRequestClientHintsToRequest` (solo prefetch; sin efecto).

**Qué portar de la red para coincidir con Chrome 135 (resumen):** (a) 2 defaults ALPS; (b) parche QUICHE `f4690dbf` + flag `true`; (c) regenerar HSTS/pins y
`log_list.json`. Todo lo demás de `net/` es refactor, `DeviceBoundSessions` (apagado), HttpStreamPool (apagado) y métricas.

## 2. BASE_FEATURE 134 -> 135 (V: lectura de diffs; ojo, «NUEVO/BORRADO» incluye traslados y variantes `#if`; solo los CAMBIO son seguros)

Cambios de valor reales (52 detectados; solo los que importan a la web/huella):
- **Portar (comportamiento web/red de Chrome):**
  `AllowSameSiteNoneCookiesInSandbox` OFF -> ON (cookies SameSite=None en iframes sandbox; `net/base/features.cc`, código ya en 128, V),
  `ServiceWorkerSrcdocSupport` OFF -> ON y `ServiceWorkerClientUrlIsCreationUrl` nuevo ON (`content/common/features.cc`; visibles en `Client.url` de SW),
  `UpdateRequestForCorsRedirect` nuevo ON (reland `edcb05836fc`; cabeceras/cuerpo/referrer en redirecciones CORS; `cors_url_loader.cc` 128 necesita el código),
  `SharedDictionaryRegisterNavigationRequests` nuevo ON (diccionarios de compresión desde respuestas de navegación; `5bf2f92000e`; baja prioridad, S),
  `PartitionProxyChains` OFF -> ON (solo con proxies; baja), `ReduceTransferSizeUpdatedIPC` OFF -> ON (rendimiento), `SubframeProcessReuseThresholds` ON.
- **Limpiezas que fijan el valor** (el flag desaparece; el comportamiento queda como estaba): `TreatHTTPExpiresHeaderValueZeroAsExpired` (ON, V `e9f7f9175ec`),
  `SplitCacheByMainFrameNavigationInitiator`/`SplitCacheByNavigationInitiator`/`HttpCacheKeyingExperimentControlGroup2024` (OFF; queda
  `SplitCacheByCrossSiteMainFrameNavigationBoolean`, que ya es el de Chrome), `CanvasOopRasterization` (ON; el tipo de feature GPU se borra: la lista de
  bloqueo `accelerated_2d_canvas` del NVIDIA/Mac, id 183, **no cambia**), `WindowCaptureMacV2`/`ScreenCaptureKitMacWindow`/`ThumbnailCapturerMac`
  (captura de pantalla Mac, ya guardada para SCK >= 12.3), `AccessibilityPageZoomEnhancements`, `FontDataService` (se sustituye por `FontDataServiceAllWebContents` OFF),
  `WebAssemblyMemory64` (V8, de MOTOR). Ya consta la parte de la 134.
- **Privacy Sandbox / telemetría: mantener APAGADO o ausente (regla 20).** Suben a ON en 135 y **no se portan**:
  `EnableBandAPrivateAggregation`, `EnableBandASampleDebugReports`, `PrivateAggregationApiProtectedAudienceAdditionalExtensions`,
  `SharedStorageWorkletSharedBackingThreadImplementation`, `PrivacySandboxPrivacyPolicy`, `HappinessTrackingSystem` (HaTS, encuestas), `AddReferringAppInfoToProtegoPings`,
  `AddReferringWebApkToProtegoPings`, `SavePasswordHashFromProfilePicker`, `OnDeviceNotificationContentDetectionModel`, `BrowserSignalsReportingEnabled`/`ProfileSignalsReportingEnabled`
  (OFF), `kEnableIpProtectionProxy` (parámetros nuevos `IpPrivacyProbabilisticRevealToken*`; sigue OFF), `GlicWarming`, `AiSettingsPageRefresh`,
  `AutofillAi*`, `AutofillIncludeUrlInCrowdsourcing` (crowdsourcing de Autofill: OFF en FlyWeb), `LocalNetworkAccessChecks` (OFF), `DeviceBoundSessions*` (OFF; `DeviceBoundSessionsRefreshQuota` ON es inerte).
- Lo que Brave 1.77.101 ya apaga (V, `chromium_src` de brave-core): `BrowsingTopics`, `InterestGroupStorage`, `SharedStorageAPI` (ahora en `network::features`, no en Blink:
  **revisar nuestro parche si apunta a `blink::features::kBrowsingTopics`**), `WaitForFirstPartySetsInit`, `DevToolsPrivacyUI`, `FedCm`, `WebOTP`, `HttpsFirstBalancedMode`.
- Sin cambio útil: `UseRustJsonParser` ON en desktop (`base/json`, no es JSON.parse; S: exige el crate de Rust ya presente en 128, no portar), `HttpsFirstModeV2ForEngagedSites` ON
  (UI de seguridad de Chrome; FlyWeb ya decide HTTPS por política), `FluentScrollbar`, `WaylandTextInputV3` (no Mac), el resto de Autofill/Sync/IPH/Supervised.
- Borrado de datos de usuario: `DeleteOrphanLocalStorageOnStartup`/`DeleteStaleLocalStorageOnStartup` pasan a ON: **no portar** (S: no afecta a la huella; riesgo de borrar datos sin beneficio).

## 3. macOS: nada obligatorio; sin APIs 10.15+ nuevas sin guarda (V)

Barrido de diffs de `.mm`/`_mac`/`_apple` (mac.py + lectura): 19 ficheros con coincidencias, 0 usos nuevos de API 10.15+ sin guarda que lleguen a producción de Mojave.
| Fichero / commit | API (versión) | Qué hace | Camino de Mojave | Coste |
|---|---|---|---|---|
| `bridged_content_view.mm`, `render_widget_host_view_cocoa.mm`, `ui/base/cocoa/appkit_utils.{h,mm}` (nuevas `UTTypeForServicesType`, `UTTypesForServicesTypeArray`) | `UTType`, `UTTypeUTF8PlainText` (11.0, UniformTypeIdentifiers) | Solo el menú Servicios de macOS (`validRequestorForSendType`/`writeSelectionToPasteboard`): sustituye el truco del `NSStringPboardType` | **No portar: el código de la 128 (`NSPasteboardTypeString`) funciona igual** | **0 h** (el cribado de `macos11-niveles.md` §8.2 lo marcaba «M, pegar y arrastrar texto»; no es portapapeles ni arrastrar: es el menú Servicios; **corregir esa fila**) |
| `vt_video_encode_accelerator_mac.mm` | `kVTEncodeFrameOptionKey_BaseFrameQP`, `kVTCompressionPropertyKey_SupportsBaseFrameQP` (símbolo de SDK nuevo, guarda `LOW_LATENCY_AND_SVC_AVAILABLE_VER`) | QP externo por fotograma (WebCodecs `bitrateMode: quantizer`) | Llega guardado; **pero** nuestro SDK es 13.3 y estos símbolos son de SDK >= 14/15: si algún día se porta, necesita constante local (K) | 0 h ahora; 1 h si se porta (S) |
| `native_screen_capture_picker_mac.mm` | `SCContentSharingPicker` (`API_AVAILABLE(macos(14.0))`) | Selector de pantalla | Guardado | 0 |
| `browser_native_widget_window_mac.mm`, `immersive_mode_controller_cocoa.mm`, mensaje `b8e13a05bfa` «permanent thin controller macOS 13+» | `MacOSMajorVersion() >= 13` | Pantalla completa inmersiva | Guardado por versión; Brave ya apaga `kImmersiveFullscreen` | 0 |
| `extensible_enterprise_sso_*.mm` | `@available(macOS 12)` | SSO de empresa | Guardado; fuera de FlyWeb | 0 |
| `1117cc4641b`, `dffa0e82f45` (`providerName` 13.x/14) | FIDO/passkeys iCloud | | Fuera (FM.42 d10) | 0 |
| `process_metrics_apple.cc` | `NSProcessInfo.physicalMemory` en vez de `host_info` | Memoria total | API de siempre | 0 |
| `base/threading/platform_thread_apple.mm` | quita un `#if USE_BLINK` | Hilos en tiempo real | **Revisar el contexto de nuestro parche `base-threading-platform_thread_apple.mm`** (8 líneas) | 0,5 h |
| `de0697268ce` «dragend después de drop en Mac» (`web_drag_dest_mac.mm`) | AppKit antiguo | Orden de eventos DnD | Sin API nueva | 1 h, opcional, web-visible |
| `9be6be66bec` `pthread_threadid_np` para `PlatformThreadId` | 10.6+ | ID de hilo | Sin problema | 0 |
`SDK`: 135 sigue con `mac_deployment_target = 11.0` (V, `macos11-niveles.md` §1); nada que añada a «FlyWeb Compat» (§9): no aparece ninguna de las familias K/P/F nuevas.
Lo único que el 135 añade sin guarda y exige 11.0 es el UTType del menú Servicios (primera fila): se resuelve «conservando la rama de la 128» (receta de `macos11-niveles.md` §3).

## 4. GPU / ANGLE / Skia / Dawn

- **Camino OpenGL de Mojave: sin cambios necesarios (V/S).** `gpu/config/software_rendering_list.json` **sin diff** (el id 183 «Block accelerated canvas on NVidia macs», de la 134,
  sigue igual; sigue valiendo el aviso para el MacBook Pro 2012 GT 650M). `gpu_driver_bug_list.json`: una línea (`msaa_is_slow`, Android).
- **Decoder / primitive restart:** en la 135 el decodificador *passthrough* **deja de activar `GL_PRIMITIVE_RESTART_FIXED_INDEX`** (la activación temporal de la 134,
  `5d836499ae`/`a22941a979`, se borra; comentario original: «hasta que ANGLE lo bloquee para WebGL»), y se añade `CHECK(GetGLImplementation()==kGLImplementationEGLANGLE)`
  (`gles2_cmd_decoder_passthrough.cc`). Esto **depende de que ANGLE de la 135 ya lo gestione**: como nuestra base no sube ANGLE, **conservar el comportamiento de la 134**
  (activar en el decoder) y **no portar el borrado** (V el cambio en el decoder; S la dependencia de ANGLE). Probar WebGL2 con índices 0xFFFF/0xFFFFFFFF en Mojave.
  También `90abe620855`: quita `glGetBooleani_v` (ES 3.1) del decodificador passthrough: es un cambio compatible con GL 4.1 (no lo necesitamos).
- **ANGLE (169 commits, 914c97c1 -> 079266db):** nada que cambie los strings de renderer/vendor ni la lista de extensiones en GL/macOS: D3D11/Metal/Vulkan/WebGPU, traza,
  validación EGL, `EGL_LARGEST_PBUFFER`, traductor de shaders (`textureGather`, atomic ops, `relaxed precision`), `GL_BGRA_EXT` renderable (añadido, revertido,
  relanzado y **revertido otra vez** en `4bfb9da6`: neto 0). «Metal: Remove divMatrixScalar polyfills» solo Metal. **No se sube ANGLE** (ver `gpu-red-129-132.md` §1.4, quita guardas < 11).
- **Skia (232 commits):** sin cambios de rasterizado visibles en el camino Ganesh-GL/CoreText de Mac Intel: Fontations/FreeType AA sobre geometría desconocida (no se usa en Mac),
  PDF, PNG/JPEG, blur: «Attempt specialized blurred rrect draw for arcs» (`jamesgk`, 26-02, sombras de rrect con arcos; S: posible diferencia de píxel en `shadowBlur`/`box-shadow`
  con esquinas de arco, sin repercusión en la huella real) y «[skif] build flag to avoid slow small sigma CPU blurs» (flag de compilación). Graphite en Mac ARM (`08e2bdc788a`): irrelevante (Intel).
  Canvas 2D por GPU out-of-process: sin variación; la lista de bloqueo es la de siempre.
- **Dawn / SwiftShader:** WebGPU apagada; SwiftShader solo es el respaldo de software. Sin impacto.
- **IOSurface:** histograma nuevo `GPU.IOSurface.CreationTimeUs` (inocuo); `1d5fa743dc1` BGRA en `image_to_buffer_copier.cc` (Blink, solo Mac con Graphite/ARM).
- Cambios de Mac en `gpu/`: `image_transport_surface_overlay_mac.mm` (métrica con `ShouldRecordSubsampledMetric(0.001)` en vez de `cpu_reduction_experiment`; **pide la función nueva
  de `base/rand_util.h`**; si se porta ese fichero hay que traer `ShouldRecordSubsampledMetric` o dejar la lógica de la 128). `external_begin_frame_source_mac.cc` igual.

## 5. Estimación en horas reales (nuestras de papel salen ~4x pesimistas; ya divididas)

| Tarea | Horas |
|---|---|
| ALPS: invertir 2 defaults y comprobar con JA4 (captura frente a Chrome 135) | 0,5–1 |
| QUICHE `f4690dbf` (versión RFC de `version_information`) + flag a true + captura QUIC (Initial) | 1,5–2,5 |
| HSTS preload + pins + `log_list.json` (regenerar los 3 parches de Brave) | 0,5–1 |
| `AllowSameSiteNoneCookiesInSandbox`, 2 flags de SW | 0,5–1 |
| `UpdateRequestForCorsRedirect` (código de `cors_url_loader.cc`; V: tiene reland y revert en el intervalo, hay que tomar el último) | 1–1,5 |
| Verificar que ningún parche de Brave apunta a `blink::features::kBrowsingTopics/kSharedStorageAPI/...` (ahora `network::features`) | 0,5 |
| macOS: nada obligatorio; revisar parche de `platform_thread_apple.mm` | 0,5 |
| WebGL2 en Mojave (primitive restart) en 5,1/6,1 y comparación con 134 | 1 |
| **Total obligatorio / útil** | **≈ 6–9 h** |
| Opcional: DnD dragend (1 h), `SharedDictionaryRegisterNavigationRequests` (1 h), `PartitionProxyChains` (0,5 h) | +2,5 |

Riesgo principal: la **captura** (JA4/JA4Q frente a un Chrome 135 real) es lo que falta para pasar S a V en 1.1 y 1.3; lo demás es mecánico.

## 6. Lo no encontrado (para no buscarlo otra vez)

- Sin cambios en: `ssl_client_socket_impl.cc`, `net/ssl`, `spdy_*`, `quic_session_pool.cc`, `quic_chromium_client_session.cc`, `quic_context.*`, `ssl_config.h`, Accept-Encoding,
  Accept de navegación, orden de cabeceras, `http_util.cc`, `software_rendering_list.json`, `chrome_root_store`.
- La cadena `ech_enabled`/ECH: sin diff. ML-KEM: sin diff (`kUseMLKEM` ON, ya portado).

## Nivel 136

MOTOR-35, 30-10-2026: inventario con 4 subagentes Sonnet (Blink, V8 13.6, fuera de Blink y cruce wpt.fyi) sobre
**136.0.7103.116** (última Stable de Mac del 136, V por versionhistory.googleapis.com; V8 **13.6.233.10** = 5297e56d).
Sus informes, abajo tal cual; cruce en [`wpt-136-cruce.md`](wpt-136-cruce.md); listas en `FlyWeb/tools/port/nivel136-*.tsv`.
Rama brave-core **`nube/motor-136`**, sobre `fw1` (841029d2, que compila LOCAL).

**Resumen:** nivel pequeño-medio. V8 13.6 barata (235 de 239 `patches/v8` siguen; lo único que rompe es que desaparecen
`Isolate::AttachCppHeap/DetachCppHeap`, resuelto con e0ae83721). Blink sin bloques grandes nuevos: 11 flags a `stable`,
39 nacen (casi todo arreglos), Baseline solo `print-color-adjust` (y `RegExp.escape` en V8); ~21–27 h de papel, menos
en real. Fuera de Blink: huella TLS/HTTP2/QUIC/Client Hints sin cambio observable (por código; falta captura de un Chrome
136), HSTS y `log_list.json` nuevos, Root Store sin cambio de confianza. Nada exige AVX ni APIs de 10.15+.

**Hecho por MOTOR-35 (`nube/motor-136`, sin compilar):**
| Commit | Qué |
|---|---|
| d3951086 | **`moveBefore()`** (29 escapes de `wpt-240.md`): cadena 128→136 sobre el prototipo `AtomicMoveAPI` de la 128 (35 commits, detalle en el mensaje). A mano: `RemovedFrom` del dialog con el `isConnected` de la 128, fuera el `CHECK` de `WillRemoveChildren`, `kMoveBeforeAPI = 229` |
| 365bbb4c | faltas (c) del cruce, 1.ª tanda: `ch` con writing-mode, gradientes (missing components, sRGB por defecto; requisito 6dc105ef2), unidades de contenedor en `radial-gradient`, sin 1:1 en imagen rota, filtros de referencia con caja vacía, `safe` en OOF estáticos, `flex` con `ConsumeNumber` |
| 670f8fa1 | **V8 13.6.233.10** (rebase de `patches/v8`; quitados 3 que ya trae; a mano 7, ver mensaje) + **CppHeap al crear el isolate** (e0ae83721: `ThreadState::ReleaseCppHeap`, `gin::IsolateHolder` con `cpp_heap`, `SnapshotCreator(isolate, params)`). Época de caché 25. Maglev **sigue apagado** |
| ada7223e | `--js-float16array`, `--js-explicit-resource-management` y `--js-regexp-escape` desde gin, como Chromium 135/136 (**escape del 135**: la 2.4.0 declaraba 135 sin `Float16Array` ni `using`) |
| 6a78dd41 | faltas (c), 2.ª tanda: 16 commits (lista en el mensaje); 7 saltados por infraestructura del 13x (1–2 pruebas cada uno) |

**Hecho por MOTOR-36 (`nube/motor-136`, sin compilar; 66 + 79 parches comprobados con `chk128.sh`):**
| Commit | Qué |
|---|---|
| 8bc16792 | 11 escapes sueltos de `wpt-240`: f5074d96d (cuelgue de gradientes en espacios amplios: aviso y rechazo), `dir=auto` (8183c1f69 482ca309f cd28cb10c), `innerText` con `::first-line` (ae3880348 6f3ca1eaf), `TextEmphasisNoPunctuation` (dba2b53e9), highlights (7a6ed3a2c c0159ab76), dirección del OffscreenCanvas en workers (bf1511e11; ba17fa15d ya estaba), `CSSLineClampWebkitBoxBlockification` (4cc57d9a2) |
| dff03148 | **anchor con scroll** (15 escapes): 33 commits 132–136 en orden de historia, `CSSAnchorRememberedScrollOffset` stable; 2b756df0e y b75a8aa4b por fusión a tres bandas (`ap3.sh`). Saltados: 9a3fe1090 (ya), a80abbd9a/bbcda52cd (par revertido), d63e50b22 (compositor) |
| 2ca5a279 | F01 `print-color-adjust`, F02 `var()` sin tipo, F03 `attr()` raw-string, F04 `dynamic-range-limit` (palabras nuevas; mezcla binaria de FlyWeb), F13 click capturado, F22 `request-close` tras `HTMLCommandRequestClose` (experimental) |
| ab14c905 | F07 `SVGAElement.rel/relList`; F10 `StandardizedTimerClamping` + 03fa95f4e (`TimeClamper`) |
| 6f8abd3c | F06 `ctx.lang` (IDL a mano en los dos contextos de la 128) |
| d287a07a | F05 colores relativos resueltos tarde |
| 597b30b0 | F14 `LayoutFlexNewRowAlgorithm`; F16 `TableIsAutoFixedLayout`, `RestrictGetBoundingClientRectForHiddenSVGElements`, `TextAutoSizingDisabledOnFlexbox` |
| e28633a3 | F18/F19: fallback de `ch`/`ic` sin «0»/«水», `src:local("")`, rangos de variables (f9458ac19), edición en shadow host, `<br>`, listify |
| 28622769 | F20: `pow()` complejo, arreglo de choque de `ConsumeNumberRaw`, longitudes en `text-size-adjust`/porcentajes, formas básicas, `SVGLength` |
| d84e5b8b | regla 17 (§9): 0758480be a31e9e490 3d52f68a6 d6b334758 a507cda33 0d519d0aa d26593a94 |
| 4e259ef8 | HSTS, pins y `log_list.json` de la 136; `CacheControlNoStoreEnterBackForwardCache` con el nivel del 136 |
| 1747f79f | declaración 136.0.7103.116 / 2.5.0 (`FLYWEB_BUILD_NUMBER` 37 en la orden de LOCAL) |

**No entran (motivo en cada commit y en `version-2.5.0.md`):** F12, F15, F17, `SplitCacheByCrossSite…`, d63e50b22, y
los commits de F16/F18/F20/§9 que piden infraestructura del 13x (`GetValueIfKnown`, quirks de `-webkit-box`, `HashTrie`,
`InitTypes`…). 511088344 (`SetSinkIdResolver`) queda para SEGURIDAD-PORTES: la 128 es anterior al refactor.

**Pendiente del 136 (para MOTOR-37):**
1. Errores de compilación de LOCAL (orden `buzon/LOCAL/20261030-*-MOTOR-36.md`, sha 1747f79f). Los probables, en
   `version-2.5.0.md` § «Dónde puede fallar».
2. d8 13.6 de D8-LINUX (si mjsunit baja: `rewriter.cc`, `shared-function-info`, Maglev).
3. Resultados de `motor-136.html` y WPT frente a CfT 136; lo que escape, a una 2.5.x o al 137 (regla 18).
4. Regla 17: COORDINACIÓN pide a SEGURIDAD-PORTES la FS del 136 (`nivel136-regla17.tsv`, sha 1747f79f).
5. **`PartitionVisitedLinkDatabaseWithSelfLinks`** (Titín: sí, 30-10): 65e131047, 2760e043, 4f7177ca
   (`components/history`, `visitedlink`) y 9252d771 (Blink); antes, ver qué de la cadena de `:visited` particionado
   del 129–135 falta en la 128. Resto de decisiones del 30-10: STTF apagado (3 escapes aceptados), HEVC sin exponer,
   gradientes solo sin cuelgue (Skia aplazado). Detalle en `version-2.5.0.md`.

**Coste del cruce wpt.fyi (directiva fija):** ~6 min de reloj, 5 consultas HTTP, un subagente Sonnet (137 000 tokens,
~1–2 $). Dio 84 pruebas (c) en ~45 causas con commit; portadas 26 en ~1 h de sesión, 7 saltadas.


### Inventario Blink del nivel 136 (136.0.7103.116)

MOTOR-35, 30-10-2026, solo lectura. V = verificado, S = supuesto. Datos en `/tmp/claude-0/port/i136/` (flags.tsv, flags-fw.tsv, flip-commits.tsv, blink-commits.tsv, commits-136.tsv, regla17.tsv, idl-diff.txt, baseline136.txt, log.txt, fw/). Copias junto a este informe: `inv-blink-136-commits.tsv` (filas, rol, fecha, sha de 10, asunto), `inv-blink-136-blink-todos.tsv` (los 1177 commits con código de Blink del rango), `inv-blink-136-regla17.tsv`, `inv-blink-136-flags.tsv` (diff json5 135→136 con el estado en FW).

## 0. Tags y rango

- **V:** la etiqueta `136.0.7103.116` existe (sha 5e3a5617c213, «Incrementing VERSION to 136.0.7103.116», 13-05-2025). Es la última 136.0.7103.x del repo (tras ella solo hay .113 a .115). Que sea la última Stable de Mac no lo he podido comprobar (versionhistory no consultado): **S**.
- **V (historia ligera, `git log 135.0.7049.117..136.0.7103.116`):** 15 310 commits (main del 03-03 al 03-31 + rama 136 hasta el 05-13). Con árboles (`blob:none --shallow-since=2025-03-01`, 44 MB, `git log -- third_party/blink` en 0,4 s): **1625 commits tocan `third_party/blink`, 1177 con código (no solo tests), 38 son de la rama tras el punto de corte** (01-04 a 13-05).
- Punto de rama del 136: 31-03-2025 (V por fechas; el 135 se cortó el 03-03/04).
- **Trampa de método:** `/tmp/claude-0/port/cr135|cr136|h|DEPS13x|log135-136.txt` los crea también otro subagente en paralelo (V8); no borrar nada ahí.

## 1. Resumen

Nivel **pequeño-medio en Blink**: ningún bloque grande nuevo enviado a `stable` (el carousel, el select personalizable, Observable, FetchLater y compañía ya eran `stable` en el 135 y siguen igual). Las novedades web del 136 son sobre todo **funciones pequeñas** (11 flags pasan a `stable` entre json5 135→136, V) y **correcciones de layout/paint** (22 flags nuevos nacen `stable`, casi todos arreglos). Baseline (web-features 3.44.0 / BCD 8.1.7, V): solo `print-color-adjust` y `RegExp.escape` (V8) llegan a Baseline «low» con el 136; el resto son subfunciones sin Baseline.
**Estimación real (÷4 sobre papel; layout/paint sin dividir): 21–27 h** para el delta propio del 136 (filas F01–F22), +2 h WebAudio (opcional), +3–5 h `moveBefore` (nivel 133, nunca portado). Las filas aplazadas del 135 (carousel, select, Observable, FetchLater) **cuestan lo mismo que entonces**: el delta 135→136 es mínimo (§4).

Cifras del json5 135→136 (`flags-nivel.py`, V): 11 `A_STABLE`, 17 `CHANGE`, 39 `NEW`, 34 `REMOVED`.

## 2. Funciones y flags que pasan a stable (135 → 136)

Estado FW = json5 de cr128 + `platform-runtime_enabled_features.json5.patch` de la rama `nube/motor-136` (V). «¿En 128?» = el código de la función ya está en la 128 (V por `grep` en cr128) o ausente. Horas = reales (S). Flip = commit que cambia el flag; impl = commit(s) de la implementación (a veces anteriores al 135: el flip solo toca el json5, por eso se listan aparte; todos en `commits-136.tsv`).

| Fila | Flag (FW) | Commits | ¿En 128? | Horas | Propuesta / privacidad |
|---|---|---|---|---|---|
| F01 `print-color-adjust` sin prefijo (Baseline low 05-2025) | — (`-webkit-print-color-adjust` pasa a alias) | e81066c28 | prefijado sí | 0,3 | portar |
| F02 `var()` fallback sin tipo (CSSTypeAgnosticVarFallback, ausente) | stable | 7b65a6f1e (1 fichero `style_cascade.cc` + flag) | no | 0,3 | portar |
| F03 `attr(x raw-string)` (CSSAttrRawString, ausente) + arreglos de `attr()` | stable | dcc590f01 (impl), 924560fbc (flip), 1abd013ba, bc5b2bcf9 | FW lleva `CSSAdvancedAttrFunction` (V) | 0,6 | portar (bc5b2bcf9 = arreglo del `attr()` vacío ya anotado en el 135) |
| F04 `dynamic-range-limit` (CSSDynamicRangeLimit, FW exp) | stable | flip 7bb8923dd; keywords nuevas b728122aa (`high`→`no-limit`, `constrained-high`→`constrained`); impl ≤135: 8c9599d7c, eea7d1daf (revert), aaf67e7be | sí (FW exp) | 0,3 | portar; las keywords del 135 de FW cambian. En Mojave sin HDR: sin efecto visible |
| F05 colores relativos con resolución tardía (CSSRelativeColorLateResolveAlways, ausente) | stable | 354a5392a, cafe22137 (flip), 23e73b3fb (inf); impl ≤135 9347d9baa | `CSSRelativeColor` sí; late-resolve no | 1,0 | portar (8 ficheros de animación, mecánico) |
| F06 canvas `ctx.lang` (CanvasTextLang, ausente) | stable | fe51f0bbd (flip); impl ab92db212 | no | 0,8 | portar. **Ojo:** el 136 mueve el IDL a `canvas_2d_recorder_context.idl`; FW sigue con `canvas_rendering_context_2d.idl` + `offscreen_canvas_rendering_context_2d.idl` de la 128: poner `lang` en esos dos |
| F07 `SVGAElement.rel/relList` (SvgAnchorElementRelAttributes, ausente) | stable | 5cbc8cc71 (flip); impl 4848d6cf8 (≤135) | no | 0,5 | portar (Baseline low) |
| F08 `isPointInFill/isPointInStroke/getCharNumAtPosition(DOMPointInit)` | — | 1c8516ad0 (6 ficheros SVG) | no | 0,3 | portar (Baseline low). Es cambio de IDL: `SVGPoint`→`optional DOMPointInit`, una sola firma |
| F09 `ProgressEvent.loaded/total` como `double` | — | 5ad24b5ad (progress_event*, resource_progress_event) | no | 0,3 | portar; `unsigned long long`→`double` en IDL |
| F10 `StandardizedTimerClamping` (ausente) + `TimeClamper` | stable | 427f9ba4e (flip), a78ea6f24 (impl ≤135), 03fa95f4e (desbordamiento int64 en `TimeClamper`, bug 399818722) | no | 0,4 | portar los dos; 03fa95f4e afecta a la resolución de `performance.now` (huella): **sí portar** |
| F11 informes de Permissions Policy para iframes (PotentialPermissionsPolicyReporting, ausente) | stable | 868cb645c (flip); 2c433a7f5 (≤135) | Reporting API sí | 0,7 | **aplazar** (S): solo genera informes locales/`Reporting-Endpoints`; Brave apaga Reporting a red (S). Sin demanda |
| F12 `AudioContext` estado `interrupted` (AudioContextInterruptedState, ausente) | stable | 49ce323ac (flip); impl 9d9ac4bd6 | no | 0,8 | portar (Safari lo tiene). Baseline false |
| F13 `click` tras captura de puntero (ClickToCapturedPointer, FW exp) | stable | 76aefeea1; impl 49bfab42e, af98e568b | sí (exp) | 0,2 | portar (flip). Interop: dispara el `click` en el elemento capturador |
| F14 flex: algoritmo nuevo de tamaño intrínseco de fila (LayoutFlexNewRowAlgorithm; en FW `LayoutFlexNewRowAlgorithmV3` = test) | stable | a309eab0e (renombra V3, 33 líneas en `flex_layout_algorithm.cc`) | V3 sí (test) | 0,5 | portar (flip + renombre). Cambia tamaños de contenedores flex en fila: probar con `motor-136.html` |
| F22 `command="request-close"` pasa a experimental (HTMLCommandRequestClose, nueva) | exp | 0ea22962d | FW lo tiene encendido desde el 135 (V: parche `element.h` con `kRequestClose`) | 0,2 | **apagar**: en el 136 el valor `request-close` NO se acepta (V: `html_button_element.cc` lo guarda tras el flag). Para ser fiel a Chrome 136, gatear con flag `experimental` |

Cambian de estado pero **no se portan** (V la lista; decisión S):

| Flag | Cambio | Decisión |
|---|---|---|
| `CapturedSurfaceControl` (stable en escritorio), `CapturedSurfaceResolution` (Mac/Win stable) | commits X1 en el TSV (952cc74c ship; renombres de `CaptureController`: captureWheel→forwardWheel, getZoomLevel→atributo `zoomLevel`, setZoomLevel→increase/decrease/resetZoomLevel; 03e674667 quita el zoom de página de `screenPixelRatio`) | **fuera**: API de captura de pantalla (requiere permiso y navegador), solo Chrome. Sin demanda |
| `FedCmMultipleIdentityProviders`, `FledgeTrustedSignalsKVv2Support`, `PrivateAggregationApiErrorReporting`, `FledgeTrustedSignalsKVv2ContextualData` | FedCM / Privacy Sandbox | **fuera** (regla 20; decididos en 129–135) |
| `SpeculationRulesTag` (stable por merge 82ca828bd) | campo `tag` y cabecera `Sec-Speculation-Tags` (10 commits) | **fuera**: depende de `content/browser` (prefetch/prerender) y Brave apaga el precargado (S) |
| `WebGPUAdapterInfoIsFallbackAdapter` | `GPUAdapterInfo.isFallbackAdapter` | **fuera** (WebGPU; además dato de GPU = huella) |
| `MediaRecorderUseMediaVideoEncoder` | solo Android | fuera |
| `RasterInducingScroll` (Linux/Win), `Serial` (Android) | otras plataformas | fuera |
| `AIPageContentPaidContentAnnotation` | IA de Chrome | fuera |
| `PartitionVisitedLinkDatabaseWithSelfLinks` (stable por defecto) | ver §6 | **valorar** (privacidad a favor) |

## 3. Flags nuevos que nacen `stable` (correcciones; FW ausente) y limpiezas

| Fila | Flags | Commits (flip/impl) | Horas | Propuesta |
|---|---|---|---|---|
| F15 Tamaños con porcentajes (LayoutMinSizeIndefinite) y replaced | `LayoutMinSizeIndefinite`, `LayoutImageForceAspectRatioOfOneOnError` (quitado) | fcd3f5f53, a8ad9ea3a, e8db6a7a4, 6f6398aef, b2dd60714, 5269fcdb7, 652700872, 165310213 | 2,5 | portar (cambia el layout de imágenes/replaced con %; probar a mano) |
| F16 Layout/SVG/tabla | `TableIsAutoFixedLayout` 52a95f9bf, `ScrollbarGutterFixedPosBugfix` a218ae496, `LayoutWebkitBoxTreeFix`+`LayoutDisableWebkitBoxQuirks` (560fb6d62, cc8a6bef3), `RestrictGetBoundingClientRectForHiddenSVGElements` 8e0b5b604, `TextAutoSizingDisabledOnFlexbox` aa4e42273, `TextOffsetMapCrashFix` 16f576f0d, `RubyFieldsetCrashFix` 634a7e2ac (+cb45acdae, a914a6196) | ver TSV | 2 | portar (varios arreglan fallos; RubyLB ya es nuestro) |
| F17 Redondeo de scroll y de paint offset | `RoundScrollOffsets` | fe3040617, 81436c404, 6ec45eab, 23aefe3c1, 9500dda9a, 704bef8a6, 2797fa283, c06eeb89e | 2,5 | portar con prueba visual (afecta a rasterizado y sticky); si cuesta, aplazar a 1.N.x |
| F18 Selección/edición | `DelegatesFocusTextControlFix` d33187362, `SelectionVisibilityAfterPaint` 79db7b3e4, `SelectionUpdateToInitialSelectionInListify` c1fa6e7f0, `UseShadowHostStyleCheckEditable` 39caae030 (+0bca2ab2f, 7cc78c603 quita flags de selección en shadow DOM) | ver TSV | 1,5 | portar (SelectionVisibilityAfterPaint solo tiene sentido en móvil: aplazar) |
| F19 Fuentes/texto | fallback de `ch`/`ex`/`ic` sin glifo 水/0 (05ebb1bcd, 24dd09a83), `src:local("")` b080fc583, `ch` según writing-mode 79495045a, rangos de variables inválidos f9458ac19 | | 1,0 | portar f9458ac19 (seguridad) y los dos de fallback; el resto, opcional |
| F20 Bloque CSS math/`calc()` | sin flag: `calc()` sin resolver en `steps()`, `linear()`, cubic-bezier, cursor, `-webkit-perspective`, `flex`, formas básicas, `anchor()` (4914a98ba, 26f9fcb21, 22d5ce93c…), trigonometría no simplificable 61f96086e, `pow()` ae47ae4e0, gradientes (dd20dbfcd, 2d96077a6) | 23 commits en el TSV | 2,5 | portar como bloque único (`ConsumeNumberRaw`→`ConsumeNumber` es mecánico pero toca 15 ficheros del parser) |
| F21 Anchor positioning (deltas) | `CSSAnchorRememberedScrollOffset` (stable desde el 135) | bab3300ad (opciones que no caben en el offset recordado), 628b74a88 (position-area expande el CB), 9a3fe1090, f812ab02e, 8e10adeb7, 83058c058, d63e50b22, a80abbd9a/bbcda52cd (static position seguro, con revert), 7e14bcd97, 49682a9c5, db5b93af2 | 3,0 | portar con la fila del 135 que ya lleva anchor (`anchor_evaluator_impl.cc` 135→136: 179 líneas) |
| F23 WebAudio | `WebAudioBypassOutputBuffering` (Mac stable), `WebAudioRemoveAudioDestinationResampler` (base::Feature, **Finch/`features.cc`, no está en el json5**) | 6a48b34b2, c0ec0bb0e, dd2943e8, 511088344 (SetSinkId tras cerrar), bc3b8736c, 0d519d0aa, e26c8a91e | 2,0 | **opcional/aplazar**: toca el pipeline de audio de salida; riesgo en Mojave sin Mac real (S). Portar solo los arreglos 511088344 y 0d519d0aa |

Sin cara web, **aplazar** (rendimiento): `HarfBuzzBufferPool` 328bd7e28, `FewerSubsequences` ef94cbcf7/590bd0dd8, `ReferenceFilterOutputBounds` 991185d49, `SelectionVisibilityAfterPaint`.
Nuevos `experimental/test`, **no entran**: `HTMLCommandRequestClose` (ver F22), `HeadingOffset` (ca7f55d77), `MulticolColumnWrapping`+`column-wrap`/`column-height` (2544ae515), `CSSGapDecoration` (`row-rule-color`), `CSSReadingOrder` (`reading-flow: source-order` e278a7b65), `CanvasTextNg`/`PlainTextPainter` (25 commits CanvasTextNG), `SearchTextHighlightPseudo`, `AnimationTrigger`, `ScopedViewTransitions`, `CSSCornerShape` (`corner-shape`, ~10 commits), `ContainerTiming`, `PreferredAudioOutputDevices`, `ClipboardChangeEvent`, `TrustedTypesHTML` (document.write con TrustedHTML), `NoFontAntialiasing`, `AriaNotifyV2`.

**Limpiezas de flag que fuerzan el estado de FW (S: revisar al fusionar):** al quitar el flag, el código queda siempre encendido. FW tiene estos en `experimental` o no-stable: `PageMarginBoxes` (26b6bf8af «enable forever»; FW lo dejó exp en 129–134), `StaticAnimationOptimization` (cc69f09c6), `JavaScriptCompileHintsMagicRuntime` (ce6806ab5, V8), `FindTextInReadonlyTextInput`, `SiteInitiatedMirroring` (8ddc27302), `OnDeviceChange` (61e8db21a). **Regla:** al portar esas limpiezas, dejar el flag en el parche de FW (o saltar el commit); no tomar la parte que borra el `status`. `UpdateSelectionOnNodeInsertion`: Chrome la apaga (0e69cebf); FW no tiene el flag: nada. `Database`, `WebAnimationsSVG`: pasan a `none`; FW exp → dejar.

## 4. Filas aplazadas del 135: ¿qué cambia en el 136?

Delta = líneas cambiadas cr135→cr136 en los ficheros clave (V, `diff`); «128→136» = techo de trabajo total.

| Fila 135 | Estado json5 136 (FW) | Cambios en el 136 (commits) | 135→136 | Horas |
|---|---|---|---|---|
| `CSSAnchorRememberedScrollOffset` | stable (FW ausente) | F21: bab3300ad y los demás de anchor | 22 líneas en `anchor_position_scroll_data.cc`, 179 en `anchor_evaluator_impl.cc` | 0,5 (sola) / 3 con F21 |
| `text-box-trim` con spanners | `CSSTextBoxTrim` stable en 135, 136 y FW (V) | **ninguno** (V: solo `HasRareData()`→`rare_data_` en `constraint_space.h` por «Make %-size non-rare»; sin commits por asunto) | 0 funcional | 0 |
| `preserveAspectRatio` en `feImage` | sin flag | **ninguno** (V: `svg_fe_image_element.cc/.h/.idl` iguales; `svg_fe_image.cc` 6 líneas de `Member`) | 0 | 0 |
| `text-emphasis-position: auto` | `TextEmphasisPositionAuto` **experimental** en 135 y 136 (FW ausente) | ninguno | 0 | no entra |
| Observable (`ObservableAPI`) | stable (FW exp) | solo el flip en main 957fb6341 (03-10; en el 135 fue el merge 10a2f47aff) | `observable.cc` 2 líneas, `subscriber.cc` 0 | 3–4 (como en el 135) |
| FetchLater | stable (FW exp) | solo 3486865e1 (= 8a947848b8 del 135, mismo bug 407556082) | `fetch_later_util.cc` 0 | 2–3 |
| Select personalizable | `CustomizableSelect`, `SelectParserRelaxation`, `InputClosesSelect` stable (FW exp/exp/ausente) | 53987479a (estilos de disabled), c7405edb6 y d38bd78bc (quitan `option_slot_`), c6f0a7262 (quita `!important` de colores UA) **y su desactivación en M136: 693a5e108 (`SelectColorsRemoveImportant` = none): no tomar**, 1f8d9579d (`<button>`/`<legend>` hijos directos; bug 402438864), c7510df47 (color de `::picker`), 5fc3d3c78 y ce26744e7 (a11y), 1024e1694 (espacios en `label`), f7cbcc22f (ReferenceTarget: `.form` pasa a `HTMLElement?` con `formForBinding` en 10 IDL; **experimental, no portar**) | `html_select_element.cc` 23, `select_type.cc` 21, `html_option_element.cc` 7, `html.css` 36 | 5–8 + 1 |
| Carousel CSS (`::scroll-marker`, `::column`, `::scroll-button`) | `CSSPseudoScrollMarkers/Buttons/Column`, `PseudoElementsFocusable`, `CSSNestedPseudoElements` stable (FW exp/ausente); `CSSScrollMarkerContain` y `CSSReadingOrder` siguen exp | 3e785ee6c (algoritmo de marcador activo), a7623c31b/438da0020/2277213a4 (foco en `::column`), 907a55c62 (elemento raíz), debeece9d→f8979e389→c221e0d41 (snap areas), 752792ccc, 60e7d5a42 y otros 8 (lista en TSV); `scroll-marker-contain` (0c9f84c18, 6b8e47152) **revertido** (9ec585168) y exp: no entra | `scroll_marker_group_pseudo_element.cc` 23, `scroll_marker_pseudo_element.cc` 28, `scroll_marker_group_data.h` 24, `pseudo_element.cc` 3 | 8–12 + 1 |

Estado de los demás flags del 135 que FW ya lleva (`CSSShapeFunction`, `HTMLCommandAttributes`, `CSSInert`, `AOMAriaRelationshipProperties`, `NavigateEventSourceElement`, `CSSLogicalOverflow`, `CSSSafeAreaMaxInset`, `CSSTextBoxTrim`): sin cambio de estado en el 136 (V). Fuera del flag: `NavigateEvent.commit()/redirect()` desaparecen y aparece `precommitHandler` (71ee6c15d, `NavigateEventCommitBehavior`, exp): no entra. `CloseWatcher`: 3d52f68a6 y 082bc8d97 (grupo estable ante Esc, merge M136; bug no listado): portar si FW lleva CloseWatcher (V: sí, parche `close_watcher.cc`).

## 5. `Node.prototype.moveBefore` (Chrome 133): ¿cambios en 134–136? (V, historia ligera)

- **Sí hay cambios, y FW no lo tiene encendido** (`AtomicMoveAPI` = `test` en FW; en cr128 el IDL existe tras ese flag; Chrome lo envió en el 133: 133f1cb4b «Ship the moveBefore API», 27-12-2024, y quitó el flag).
- **133→134** (3 arreglos de choque, 17-01-2025): 96e62c0d6 (padre nulo), ea2ba3fc1 (CHECK con iframe desconectado), f0dc0d21e (estilo de `CharacterData`).
- **134→135:** 7f0b7aa30 (choque con custom element sin `disconnectedMoveCallback`, 11-02) y 7dc739393 (solo test).
- **135→136:** caf55a633 («Reapply style after a moveBefore», `link_style.cc`, 14 líneas), 5619643c2 (choque con `<object>` subframe, `html_frame_owner_element.cc`, bug 40150299), fcad0ee2d (WPT no-tentative).
- Total 128→135: **35 commits** de moveBefore (lista en el TSV, F24/F24b), más 2 del 136. Node.cc/container_node.cc cambian 510 y 512 líneas 128→136 (techo, incluye otras cosas).
- **Horas reales: 3–5** (S), moveBefore + los 5 arreglos. Es una función Baseline-por-llegar (Firefox y Safari en curso, S); sin demanda conocida. Propuesta: portar en una 1.N.x o junto a la fusión de `node.cc`/`container_node.cc` de otra fila; no bloquea el 136.

## 6. Privacidad y huella (regla: por encima de Brave; referencia Brave 1.78 = Chrome 136)

- **A favor, valorar:** `PartitionVisitedLinkDatabaseWithSelfLinks` (65e131047 «Enable partitioned :visited links»; 2760e043 y 4f7177ca en `components/history`/`visitedlink`; 9252d771 en Blink). Particiona los enlaces `:visited` por (enlace, sitio superior, origen del marco) = cierra la fuga de historial por CSS. **Casi todo es de navegador (historial, `visitedlink`), no de Blink**: queda para el subagente «fuera de Blink». Si Brave 1.78 lo trae (S), la regla de privacidad pide portarlo; estimación aparte (S: 6–10 h con la migración de la base de historial).
- **No portar:** FPF-CI = *Fingerprinting Protection / Canvas Interventions* de Chrome (ruido en lecturas de canvas, c12563dd/e6c6753b + 11 commits `core/canvas_interventions`, flags `CanvasInterventions*`): Brave ya tiene su propio *farbling*; dos sistemas se pisarían. `IsCapturedSurfaceResolutionActive`/`screenPixelRatio` (X1). `GPUAdapterInfo.isFallbackAdapter` (huella de GPU). Cabecera `Sec-Speculation-Tags`.
- **Portar (robustez de timers = huella):** 03fa95f4e `TimeClamper` (F10).
- **Pegado a navegador:** LNA (`local-network-access` en `PermissionDescriptor`, a9d4580fc; 2930c2764 y 221c26561 saltan comprobaciones de contenido mixto solo para LNA): permisos de red local, **fuera** (la parte útil está en el navegador).
- Señalar: 76fa3c178 (rama 136, bug 415810136) pone `referrerpolicy: "no-referrer"` en las cabeceras `Link:` de subrecursos = fuga de Referer corregida. **Portar** (regla 17).

## 7. Finch / `base::Feature` que Chrome enciende y no están en el json5

(S, por asunto de commit): `WebAudioRemoveAudioDestinationResampler` (c0ec0bb0e), `RendererSideContentDecoding` (1c47ad0d reland en M136; descodifica `Content-Encoding` en el renderer; red/navegación), `SkipUnnecessaryRemoteFrameGeometryPropagation` (4514d724b, rendimiento), `ThrottleMainFrameTo60Hz` y variantes de frame rate (86571ee34, 51c7edd9b, 9373ec74f, rendimiento), `StaleSessionCookieCleanup` (navegador), `IsPaintableChecksResourceProviderInsteadOfBridge` y killswitches de `Canvas2DLayerBridge` (fcb352f82, 9cd92ae38, 8273759b1: canvas 2D, interno), compile hints de V8 (`ce6806ab5`, V8 13.6). Ninguno cambia la API web visible salvo RendererSideContentDecoding (invisible).

## 8. IDL y bindings (V: 73 IDL cambiados, `idl-diff.txt`)

- **Cambios que sí afectan a FW si se portan filas:** `progress_event*.idl` (double), `svg_geometry_element.idl` y `svg_text_content_element.idl` (`DOMPointInit`), `canvas_2d_recorder_context.idl` (nuevo `lang`; el refactor `base_rendering_context_2d`→`Canvas2DRecorderContext` **no se porta**: FW mantiene sus dos IDL de la 128 con sus parches, 22 atributos; hay que meter `lang` a mano), `html_dialog_element.idl` (`closedBy`, `requestClose()` sin flag; FW ya `stable`).
- **`[NoAllocDirectCall]` y sobrecargas (V8 13.4 CHECK de «misma aridad»):** el único IDL nuevo con dos sobrecargas rápidas es `gpu_command_encoder.idl`: `copyBufferToBuffer(source, destination, optional size)` y `(source, sourceOffset, destination, destinationOffset, optional size)`; aridades 2–3 y 4–5, **no solapan**, y es WebGPU (fuera de FW). Sin cambios en `webgl_multi_draw*` ni en canvas respecto del 135.
- Solo experimentales o fuera: `document.write(TrustedHTML)` (`TrustedTypesHTML`), `Element.headingOffset/headingReset`, `AnimationTrigger`, `navigation_intercept_options` (`precommitHandler`), Sanitizer `replaceWithChildrenElement`→`replaceElementWithChildren`, `TextCluster.begin`→`start`, `ImageData` `storageFormat`→`pixelFormat` y `Float16Array` (bindings 0ec014129, 11ddbcdbe, 72f7508df: ver X5; **aplazar**, `ImageDataPixelFormat` es exp), `AuctionAdConfig.sellerTKVSignals`, `PrivateAggregation.contributeToHistogramOnEvent`, `SpeechRecognition.availableOnDevice` → `AvailabilityStatus`, renombre del bloque AI (`AI*`→`LanguageModel/Summarizer/Writer/Rewriter/Translator/LanguageDetector`, 50 commits), WebNN `Exposed=(Window, Worker)`, constantes de `WEBGL_shader_pixel_local_storage` renumeradas, `MediaTrackSettings` (`screenPixelRatio`), `PermissionDescriptor` `local-network-access`.
- Generador: sin cambios de bindings con riesgo; `0ec014129` («Float16Array: Add IDL bindings») toca `bind_gen` solo si algún IDL usa `Float16Array`.

## 9. Candidatos regla 17 (V la lista; la gravedad hay que cruzarla con CVE)

`regla17.tsv` (94 commits por asunto: crash/CHECK/overflow/race…). Los de áreas que portamos (los más importantes, todos con bug):

| Commit | Qué | Bug |
|---|---|---|
| 76fa3c178 (rama) | `Link:` en subrecursos sin Referer | 415810136 |
| b249bc61d (rama) | choque con *text fragment* en ShadowDOM desordenado | 411457974, 410033683 |
| b636c5225 (rama) | quita `PlzDedicatedWorker` (choques) | 407563096, 408413160 |
| d6b334758 (rama) | carrera en animaciones pendientes (= 5ba87566df del 135) | 409086867, 409632308 |
| d26593a94 (rama) | rectángulo visual recortado con offsets de scroll grandes | 414412511, 413078309 |
| 3486865e1 (rama) | FetchLater: choque en `GetReservedDeferredFetchQuota()` (= 8a947848b8) | 407556082, 408106277 |
| a507cda33 (rama) | tamaño por defecto de SVG en `tex*Image*` de WebGL | 41357911, 409203678 |
| 03fa95f4e | desbordamiento int64 en `TimeClamper` | 399818722 |
| e4007690b | desbordamiento en escala de scrollbar | 397734696 |
| f9458ac19 | rangos de variables de fuente inválidos | 40062214 |
| 0758480be | `WTF::String::Format` reforzado | 395789217 |
| 511088344, 0d519d0aa, bc3b8736c | WebAudio: `SetSinkId` tras cerrar, contexto cerrado, errores de render | 381126158, 408018835, 410818045 |
| 3b9a6ad28, 91e66f04b | View Transitions: choques | 406828705, 406317718 |
| 5619643c2, caf55a633 | moveBefore (§5) | 40150299 |
| 1f8d9579d, ce26744e7, 5fc3d3c78 | select: hijos directos, a11y | 402438864, 405946933 |
| 16f576f0d, 634a7e2ac, cb45acdae, a914a6196, daac4aa11 | text-transform/Ruby | 396666438, 402200344, 406999114, 401056618, 401444931 |
| 5abd591b6 | `interactivity` fuera del shorthand `all` (= ae21fa404d) | 408241037 |
| 6ee9995db, a31e9e490, 5cf8af29d, b3ea66ce0 | parser/estilo: choques con `calc`, `revert-layer`, contadores, HashTrie | 404174133, 400052780, 400087471, 406054649 |
| 082bc8d97 (rama) | CloseWatcher: grupo estable ante Esc | — |

Áreas a vigilar tras el 136 (para SEGURIDAD-PORTES): `core/html/forms/*`, `core/dom/{pseudo_element,scroll_marker*}.cc`, `core/animation/*` (carrera 409086867), `core/layout/{flex,length_utils,out_of_flow_layout_part}.cc`, `core/css/parser/*` (calc), `modules/webaudio/*`, `core/timing/time_clamper.cc`, `core/view_transition/*`.

## 10. Orden propuesto y horas (reales, S)

1. **F01, F02, F03, F04, F13, F22** (flips y CSS pequeños): 2 h.
2. **F08, F09, F07, F06, F10** (IDL pequeños + timers): 2,3 h.
3. **F05, F12** (colores relativos, `interrupted`): 1,8 h.
4. **F14, F16, F15** (layout: flex, tabla/scrollbar/webkit-box, %-size): 5 h.
5. **F20** (bloque `calc()` del parser): 2,5 h.
6. **F18, F19** (selección, fuentes): 2,5 h.
7. **F21** (anchor) junto con la fila `CSSAnchorRememberedScrollOffset` del 135: 3 h.
8. **F17** (redondeo de scroll/paint): 2,5 h, con prueba visual; si hay duda, a 1.N.x.
9. Arreglos regla 17 de §9 (los que no vengan en filas anteriores): 1 h.
10. Opcionales: F23 WebAudio (2 h), moveBefore (3–5 h), PartitionVisited (§6, aparte).
11. Filas aplazadas del 135, sin cambio de coste: Observable 3–4, FetchLater 2–3, select 5–9, carousel 9–13.

**Total delta propio del 136: 21–27 h** (filas 1–9; ≈ 90–110 h de papel). Con las filas del 135 aplazadas y las opcionales: ~45–65 h.

Declarar **Chrome 136.0.7103.116** exige solo el nivel; no cambia nada de lo anterior. `motor-136.html` debería probar: `attr(raw-string)`, `var()` con fallback sin tipo, `print-color-adjust`, `ctx.lang`, `SVGAElement.relList`, `isPointInFill({x,y})`, `ProgressEvent` con `loaded` fraccionario, `AudioContext.state === 'interrupted'` (enumeración), `click` con captura, y `command="request-close"` (debe fallar).

### Inventario V8 para el nivel 136 (MOTOR-35, solo lectura)

Marcas: V = verificado (git/diff/grep), S = supuesto. Trabajo: clon `/home/user/v8` (historia filtrada tree:0 desde 2025-02), worktrees `/home/user/v8-135` (e2591684) y `/home/user/v8-136` (5297e56d; queda limpio), scripts y listas en el scratchpad (`chk.sh`, `r135.txt`, `r136.txt`, `src135-136.diff`, `deps.py`). Referencias de Chromium: `/tmp/claude-0/port/cr128`, `cr135`, `cr136` (grep), raw github para simdutf.

#### 1. Versión
- V: **V8 13.6.233.10 = 5297e56d91816747d539abca52b578e5832135f0** (`Version 13.6.233.10`, 6-05-2025; la fija `DEPS` de Chromium 136.0.7103.116 en cr136). No es LTS. 571 commits de main desde el punto común con 13.5 (af3cadca9b, 2-03-2025) + 9 merges propios 233.1..10: `Add function's source code to the minidump` (x2), `Properly compare ScopeInfo.context_local_names_hashtable`, `Fix handling of mutable heap numbers in debugger ^2`, `Revert Reland maglev add->stringconcat`, `Revert regexp common prefix backwards`, `wasm: imports array filled with holes` (ya en `patches/v8`: ver 2), y dos de pruebas en Mac. Ninguno es de seguridad de TurboFan.
- V: **`patches/v8` tiene 239 `.patch`, no 104** (240 ficheros con FLYWEB-SECURITY.md; son los de FS.36: 70 arreglos portados). Todo lo de abajo es sobre los 239.

#### 2. patches/v8 sobre 13.6.233.10
Comprobado con `git apply --check` (y `-R --check`, y `--3way` aplicando de verdad): **222 aplican limpios** (los 239 aplican limpios sobre 13.5: control AA), **6 aplican solo con 3-way sin conflicto** (contexto movido: `accessor-assembler.cc`, `json-parser.cc`, `maglev-basic-block.h`, `maglev-code-generator.cc` hunk 3, `elements.cc` hunks 8-9, `wasm/value-type.h`), **2 ya están dentro**, **1 falla por fichero movido**, **8 con conflicto real**. Lo que se suelta o rehace:
- **Ya en 13.6 (se sueltan):** `src-wasm-wasm-module.cc` (merge 233.8 «imports array filled with holes» = nuestro arreglo, `-R --check` OK), `test-mjsunit-compiler-regress-402646504.js` (el test ya existe), `src-runtime-runtime-collections.cc` (los 4 hunks `clear_exception` ya son upstream, 92aba703; solo cambia el comentario), `js-native-context-specialization.cc` hunk 3 (**d73530cf ya está en 13.6**: existe `TypedArrayLength_string`; nuestro port con `length_string` sobra), `maglev-post-hoc-optimizations-processors.h` (upstream ya hace `if (!v8_flags.maglev_untagged_phis) return kRemove` en `Process(Dead*)`; se suelta el parche entero salvo que se quiera quitar el `UNREACHABLE` con untagged_phis encendido: Maglev está apagado).
- **Fichero movido (1):** `include-cppgc-ephemeron-pair.h` -> `cppgc/ephemeron-pair.h` **ya no existe**; `EphemeronPair` se mudó a `cppgc/visitor.h`. `include-cppgc-visitor.h.patch` aplica, pero `ClearKeyAndValueIfKeyIsDead` hay que añadirla a mano en el `EphemeronPair` de `visitor.h` (0,3 h). Blink 128 no usa `EphemeronPair` (V grep cr128).
- **Conflicto de contexto (se rehacen a mano):** `shared-function-info{.h,-inl.h,.tq}` (13.6 añade el bit `live_edited` en `relaxed_flags`; V: con él + nuestro `class_initializer_allows_await` son **justo 32 bits**, cabe; hay que conservar los dos), `maglev-graph-builder.cc` (2 hunks: `TryBuildStoreField` en 13.6 sigue siendo `access_mode == kStore`, nuestro cambio a `!= kStoreInLiteral` entra con una línea; el resto auto-fusiona), `parsing/rewriter.cc` (13.6 cambia `Rewriter::Rewrite/RewriteBody` a `bool* out_has_stack_overflow`; nuestro chequeo anticipado de `HasStackOverflow` hay que dejarlo con `*out_has_stack_overflow = true`, 0,3 h).
- **Los 11 solo-LTS (a5f18bb86, ec6c18478, eba18128, c58fda1f, 9a884b1b, 22e9d962, 1d82eec6, 7bc0a67e, 45eb42cd, 62ee3244, 37d6fa3f) y ea2f03dfff: NO los trae la 13.6** (V: fechas 19-05 a 16-09-2025 y 26-10-2026; ninguno es ancestro de 5297e56d ni hay cherry-pick por asunto). Sus parches aplican todos limpios sobre 13.6. Stack clash: `turboshaft/pipelines.{h,cc}` son **idénticos** en 13.5 y 13.6 (V diff vacío en `.cc`; `.h` solo cambia el include de turbolev y quita loop peeling) y `pipeline.cc` solo cambia en partes wasm, así que el port de la 135 vale tal cual. S: `turbo_elide_frames` (nuevo, true) no interfiere con la guarda de 4 KB.
- Época de caché: `version.h` aplica; subir (25, S).
- Mjsunit: `stack-traces-overflow.js` borrado por nuestro parche sigue aplicando.

#### 3. include/ 13.5 -> 13.6 y Blink/gin 128 (V: diff completo de include/, grep sobre cr128 y comparación con cr136)
- **ROMPE: `Isolate::AttachCppHeap()` y `DetachCppHeap()` desaparecen** (v8-isolate.h/api.cc). Blink 128 los llama en `third_party/blink/renderer/platform/heap/thread_state.cc:119,128`. Ahora el `CppHeap` se pasa en `CreateParams::cpp_heap` y lo posee el isolate (`CHECK(!owning_cpp_heap_)`; si no hay, V8 crea uno por defecto). Chromium 136 lo resuelve con: `ThreadState::{owning_cpp_heap_, cpp_heap_, ReleaseCppHeap(), SetCppHeap(), RecoverCppHeapAfterIsolateTearDown()}`, `gin::IsolateHolder` con parámetro `std::unique_ptr<v8::CppHeap> cpp_heap` (-> `params->cpp_heap = cpp_heap.release()`) y los dos llamadores de Blink `v8_initializer.cc` y `worker_backing_thread.cc` (`ThreadState::Current()->ReleaseCppHeap()`), más `SnapshotCreator(isolate_, *params)`. `CreateParams::cpp_heap` ya existe en 13.5, así que se puede portar antes de subir V8. Ficheros: `thread_state.{h,cc}`, `v8_initializer.cc`, `worker_backing_thread.cc`, `gin/isolate_holder.{h,cc}` (FlyWeb ya parchea estos dos por las colas de tareas), `heap_test_utilities.cc`; otros creadores de isolate (pdf, services/accessibility, proxy_resolver) pasan `nullptr` por defecto. **~3 h**, y es lo único que impide compilar.
- Quitado sin uso en 128 (V grep): `Isolate::AtomicsWaitCallback/SetAtomicsWaitCallback/AtomicsWaitWakeHandle`. `cppgc/ephemeron-pair.h` movido (128 no lo incluye). `kHolderIndex` privado -> `kUnusedIndex`. `kWasmContinuationJmpbufTag` interno. El orden de los offsets `kIsolateFastCCallCallerPc/Fp` cambia (Blink lo compila en línea: recompilar todo, nada que tocar). `#include <fstream>` fuera de `libplatform/v8-tracing.h` (S: nadie lo usa de rebote).
- **gin/Holder: nada que hacer** (V: gin 128 ya usa `This()` para `FunctionCallbackInfo`; `Holder()` queda en `PropertyCallbackInfo`; ya lo estaba en la 135).
- Compatibles: `MaybeLocal` con ctor implícito desde `Local` y upcast `requires`, `Maybe`/`WeakCallbackInfo` heredan `ConditionalStackAllocatedBase` (+ `cppgc/internal/conditional-stack-allocated.h`; Blink define su propio `WTF::IsStackAllocatedType`, otro espacio de nombres), `IsolateGroup` copiable, `Message::PrintCurrentStackTrace(..., filter = nullptr)` (Blink 128 lo llama con 2 args: vale), `FunctionTemplate::SealAndPrepareForPromotionToReadOnly`, `PrintCurrentStackTraceFilterCallback`, nuevos `UseCounterFeature` 166 `kExplicitResourceManagement` y 167 `kWasmBranchHinting` (S: sin `switch` exhaustivo; en cr136 `use_counter_callback.cc` lo trata), `V8Inspector::isolateId()` puro y `consoleTimeStampWithArgs` (solo los implementa V8; 128 no hereda de `V8Inspector`), `cppgc::IsInitialized()` (V8 llama `cppgc::InitializeProcess` si falta; gin lo hace antes: compatible, S).
- CHECK nuevos alcanzables por el *embedder*: **ninguno en `api.cc`** (V: diff de 190 líneas; el único DCHECK nuevo es de `RequestGarbageCollectionForTesting`). No-API: `CHECK(!owning_cpp_heap_)` en heap.cc (relacionado con lo anterior), CHECK de `IsolateGroup`, `read-only-promotion` (plantillas selladas), `backing-store`.
- Flags que pasa gin: `harmony_iterator_helpers` y `harmony_set_methods` **desaparecen** (ya no hay flag; SetFlagsFromString ignora/avisa como hoy con otros). `experimental_wasm_*` que gin/Blink 128 pasa siguen existiendo salvo los ya inexistentes en 13.4/13.5.

#### 4. Regla 19 (V: diff de `flag-definitions.h`, 264 líneas)
| Opción | FlyWeb | 13.6 | Nota |
|---|---|---|---|
| `maglev` | apagado (parche) | true | igual que 13.5; el parche aplica |
| `maglev_untagged_phis` | apagado (parche) | true | igual |
| `typed_array_length_loading` | encendido | true | ahora con d73530cf dentro (en 13.5 faltaba) |
| `turbolev` | — | `DEFINE_BOOL false` (ya no experimental) + `turbolev_future` experimental | sigue apagado upstream |
| `minor_gc_task_with_lower_priority` | — | **false -> true** | usa prioridad kUserVisible: FlyWeb ya tiene `user_visible_task_runner` en gin/PerIsolateData (V: `gin-isolate_holder.cc.patch`) |
| `turbo_elide_frames` | — | nuevo, true | S: sin efecto en x64 de interés; revisar con mjsunit |
| `wasm_opt` | — | `DEFINE_DEBUG_BOOL` (siempre true en release) | |
| `conservative_stack_scanning` implica `scavenger_conservative_object_pinning` (antes `minor_ms`) | — | experimental, apagado | sin efecto |
| `better_code_range_allocation` | — | quita exclusión de ChromeOS | sin efecto en Mac |
| `js_regexp_escape` | — | **staged -> shipping** | RegExp.escape sale solo |
Maglev (13.6): ~52 commits de Maglev (asunto) desde 13.5, `maglev_non_eager_inlining` y `maglev_inlining_following_eager_order` nuevos (false). De los 16 arreglos de Maglev de FS.34/36, siguen sin estar upstream los tests `mjsunit/maglev/regress-*` (13 ficheros nuevos aplican); ya upstream: write barrier, `maglev_allocation_folding`, typed array `super`, `Dead` en post-hoc. Deuda de Maglev ≈ la de la 135 menos 2; sigue apagado.

#### 5. DEPS de terceros de V8 13.5 -> 13.6 (V)
- **simdutf 5a9a2134 -> 40d1fa26** (Chromium 135: 6.0.2; **Chromium 136: 6.4.0**, `simdutf.cpp` 2,40 -> 2,72 MB, `simdutf.h` 224 -> 240 KB; BUILD.gn solo añade `SIMDUTF_DLLIMPORTEXPORT` en Windows). V: los usos `simdutf::` en `src/` son **idénticos** en 13.5 y 13.6, así que se puede **quedar con la 6.0.2 que ya está vendida en `patches/third_party-simdutf-*`** (S: compila; 0 h) o subir a 6.4.0 (regenerar `simdutf.cpp.patch` de 2,4 MB: ~1 h; S: arreglos de simdutf no relevantes).
- fast_float cb1d42aa, highway 00fe003d, fp16 0a92994d: **iguales**. abseil 2705c665 -> 3fbb10e8 (V: lo pone Chromium; V: 13.6 no añade ningún `#include "absl/..."` respecto a 13.5), icu/protobuf/perfetto/libunwind/llvm-libc/googletest/catapult cambian (no entran: los trae Chromium o son de pruebas). `third_party/partition_alloc` no está en DEPS 13.6 (solo d8). Nuevo `rust-toolchain` en DEPS de V8 (no se usa).

#### 6. JS/Wasm nuevo en 13.6
- V: shipping nuevo: **RegExp.escape** (`js_regexp_escape` pasa a shipping). Iterator helpers y Set methods: flags eliminados (ya iban de serie). Sigue staged: `js_explicit_resource_management`, `js_float16array`, `harmony_remove_intl_locale_info_getters`; in progress: `js_base_64` (+ ruta SSE de hex nueva).
- V: **Chromium (cr135/cr136 `gin/v8_initializer.cc`) enciende `--js-float16array` y `--js-explicit-resource-management`; gin 128 no, y FlyWeb no tiene parche de gin para ello.** Si el nivel 135/136 debe declarar `Float16Array` y `using`, hay que añadir esas dos líneas `SetV8Flags` (cr136 también `--js-regexp-escape`, innecesaria al ser shipping). Float16Array en x64 usa F16C solo con detección en ejecución (ver 7). S: decisión de producto, no de V8.
- V: Wasm sin nada shipping nuevo: `type_reflection` desestagea, `branch_hinting` pasa a staged, nuevos experimentales (`custom_descriptors`, `rab_integration`, `ref_cast_nop`...); JSPI sigue experimental (`jspi` false).

#### 7. Riesgos (V salvo S)
- **AVX/CPU:** V: sin cambios en `base/cpu.cc` ni en flags `-m...` de `BUILD.gn`. Nuevo `Uint8ArrayFromHexWithSSE` (SSE2, `#ifdef __SSE3__` y `get_vectorization_kind()`; solo con `js_base_64`, apagado). x64: Maglev `CheckFloat64SameValue`, selector Turboshaft sin cambios de ISA. V: **la caché de código ya no incluye `CpuFeatures::SupportedFeatures()` en `ScriptCompiler::CachedDataVersionTag`** (solo versión + hash de flags): la caché de bytecode se comparte entre CPU (S: sin riesgo, el bytecode no depende de AVX). S: simdutf despacha por CPU en ejecución (Haswell/Icelake con atributos de región); comprobar en la 5,1 (igual que en 13.4/13.5).
- **macOS 10.15+:** V: grep de `__builtin_available`, `dlsym`, `os_unfair`, `pthread_*_np`, `mach_`, `MAP_JIT`, `sysctl` sobre el diff completo `src/`: **nada nuevo**; `platform-darwin.cc`/`platform-posix.cc` no cambian. Único cambio: `IsRemapPageSupported` pasa de `V8_OS_DARWIN` a `V8_OS_MACOS` (sigue true en Mac). El `SpinningMutex` ya salió en 13.5. El `weak os_unfair_lock_lock_with_options` sigue estando solo en el `partition_alloc` de Chromium 133+, no en nuestra base 128.
- **Época de caché:** cambia (versión y hash de flags): subir la época de FlyWeb a 25 (S) y regenerar el parche de `version.h`.
- **Isolate/CppHeap:** primer arranque del isolate de Blink con el heap poseído por V8: probar cierre de workers y snapshot (S).
- **Maglev:** apagado; riesgo bajo mientras siga así. `turbo_elide_frames` y `minor_gc_task_with_lower_priority` son los únicos defaults de producción que cambian en TurboFan/GC (S).

#### 8. Estimación (horas reales)
- Fijar 13.6.233.10 + `v8-revision` + FLYWEB-SECURITY.md + época: 0,5 h.
- Parches: 6 de contexto (3-way limpio) 0,3 h; SFI x4 + maglev builder + rewriter + EphemeronPair/visitor 1,3 h; soltar 5 (wasm-module, test 402646504, runtime-collections, post-hoc, js-native-context hunk 3) 0,3 h; regenerar los 239 con `v8regen.sh` y repasar: 1 h. **~3 h.**
- Blink/gin CppHeap (sección 3): **~3 h** (+ compilar, de LOCAL).
- simdutf: 0 (o +1 h si se sube a 6.4.0). Gin flags de Float16Array/using: 0,2 h si se decide.
- `d8` nube 13.6 + parches, mjsunit completo y FlyWeb 9/9: 3 h de reloj (~1 h atendidas).
- **Total ≈ 7–8 h reales para V8 + pegamento (≈1 día)**, menos que la 135 (12 h): sin mutex, sin `Holder`, sin d73530cf. Riesgo no medido: CppHeap poseído por el isolate en workers/snapshot.

# Nivel 136, inventario «fuera de Blink» (cr135 -> cr136), solo lectura

MOTOR-35 (subagente de lectura), 30-10-2026. Marcas: **V** verificado en código o historial; **S** supuesto.
Base: la 128 NO se rebasa. «Portar» = traer a la 128 el cambio de comportamiento observable de Chrome 136.
Blink y V8 los hacen otros subagentes y no se repiten aquí.

## 0. Tag y fuentes

- **Tag de 136: `136.0.7103.116`** (V; versionhistory de Google, mac/stable: .114 al 100 % del 15-05 al 21-05-2025;
  .116 servida con .114 del 27-05 al 02-06-2025, fracciones 0,099 -> 0,2475; .115 solo 0,5 %; luego 137). Es la última de la rama 136
  para Mac. Origen: `.117` de 135 (la que declara FlyWeb). Chromiumdash no se usó.
- Intervalo `135.0.7049.117..136.0.7103.116`: 15 310 commits (rev-list con merges). Incluye los merges de seguridad de la rama
  (p. ej. `76fa3c17` «[M136 Minibranch] referrerpolicy no-referrer en Link de subrecursos», bug 415810136, flag
  `NoReferrerForPreloadFromSubresource` ON en `third_party/blink/common/features.cc`: es de Blink, lo anoto para el otro subagente).
- DEPS 135 -> 136 (V, `git show <tag>:DEPS`):
  BoringSSL `673e61fc` -> `a9993612` (79 commits), QUICHE `25a56e31` -> `5077431b` (69), ANGLE `079266db` -> `fa40b7c5` (193),
  Skia `5a44cdd7` -> `bcce46ca` (254), Dawn `53dfda5e` -> `1cffe7ec`, SwiftShader `c12c1383` -> `4982425f`, V8 `e2591684` -> `5297e56d`.
- Método: `mkcr.sh` de cr135 y cr136 (en `/tmp/claude-0/port/cr135`, `cr136`; `diff -ruN` por directorio, guardados en
  `/tmp/claude-0/port/f136/`), historia ligera `--filter=tree:0` en `/tmp/claude-0/port/h` (con `git diff --name-only` y `git show <tag>:<ruta>`:
  rápido, 1 s), clones blobless de BoringSSL, QUICHE (`github.com/google/boringssl`, `github.com/google/quiche`), ANGLE y Skia (mirrors de github).
  `feat136.py` / `featgit.py` (`/tmp/claude-0/port/s/`): BASE_FEATURE old/new. Listas de commits: `log135-136.txt`, `bssl-log.txt`,
  `quiche-log.txt`, `angle-log.txt`, `skia-log.txt`. Googlesource no se usó.

## 1. Huella de red 135 -> 136: ningún cambio observable en TLS, HTTP/2, QUIC ni Client Hints (V código, S captura)

**1.1 TLS (ClientHello): igual que 135 (V).**
- `net/ssl/*` **sin diff** (0 ficheros; incluye `ssl_config`, `cert_compression.cc`); `net/socket/ssl_client_socket_impl.cc` **sin diff**.
  Grupos (`X25519MLKEM768, X25519, P-256, P-384`), sigalgs, ECH, GREASE, permutación, ALPS: iguales. `UseNewAlpsCodepointHttp2/QUIC` siguen ON
  (ya cambiados en 135; `net/base/features.cc` líneas 553-559), y `ShouldQuicUseNewAlpsCodepoint` (`network_session_configurator.cc:312`) sin cambio.
  `kEncryptedClientHello`, `kUseMLKEM`, `kReportEcn` (ON): sin cambio de valor.
- BoringSSL (79 commits), revisados los que tocan `ssl/`: `02f0d877` «draft-kwiatkowski-tls-ecdhe-mlkem-01 es ahora draft-ietf-tls-ecdhe-mlkem-00»
  (solo nombre/comentario en `ssl_key_share.cc`, 2 líneas; mismo codepoint 0x11EC); `7e529d2b` Trust Anchors (extensión `trust_anchors`: el cliente solo la
  envía si `requested_trust_anchors` tiene valor; Chrome no lo llama, V `extensions.cc:2656`); `1f8dc079` «Compress the CA extension» (solo si hay CA names; Chrome no las pone);
  `899b557b` cross-SNI-resumption / `tls_flags` (solo servidor y la API `resumption_across_names_enabled`, desactivada por defecto);
  `f6bf5e2c` API de DTLS. **Nada nuevo en el ClientHello por defecto.** No hace falta subir BoringSSL (si se subiera, regenerar el parche de `BUILD.generated.gni`).
- x86 (sin AVX obligatorio): `920bad63` quita la comprobación de FXSR (suponen SSE2), `a57d1b88` CLMUL AES-GCM exige además SSSE3, `b1ef5eee`/`d8beaa34`/`c2f05fa2`
  añaden `vzeroupper`/movdqa en rutas AVX2 ya con detección en ejecución; `c7bec85f`/`11337e42` renombran avx10 -> avx512. Nada exige AVX (V: `crypto/cpu_intel.cc` -6 líneas, sin cambios de detección).
  Mojave: SSE2/SSSE3/CLMUL de las MacPro 5,1 (Westmere) cubiertos.
- Datos de CA: **Chrome Root Store pasa de v17 a v18** (`root_store.textproto` +664 líneas, `root_store.md`, `root_store.proto` +7), pero `root_store.certs` **idéntico** (V) y
  los anclajes iguales: solo añade `eutl: true` y `additional_certs` (certificados de la UE para QWAC), detrás de `kVerifyQWACs` **OFF** (nueva, `net/base/features.cc`). No cambia la
  confianza de ninguna web. Opcional: tomar solo la versión (S: cosmético, `chrome://net-internals`).

**1.2 HTTP/2: sin cambios en lo que sale al cable (V).**
- `spdy_session.cc` (+46/-29): solo «spanify» (copia de `kHttp2ConnectionHeaderPrefix` + SETTINGS + WINDOW_UPDATE con `SpanWriter`; mismo contenido y orden), `availability_state` en NetLog.
  `http2_priority_dependencies.cc` (+7/-5): spanify. `spdy_session_pool.cc` -8: limpieza. `http_network_session.cc`: crea siempre `HttpStreamPool`, pero **se usa solo si**
  `HostResolverManager::IsHappyEyeballsV3Enabled()`, que sale de `kHappyEyeballsV3` = **OFF** (V; mismo valor que 135; nueva política `HappyEyeballsV3Enabled`, irrelevante).
- `http_request_headers.cc`, `http_util.cc`, `services/network/public/cpp/constants.cc` (`kDefaultAcceptHeaderValue "*/*"`), `source_stream_type.h`: **0 diff**. Accept-Encoding `gzip, deflate, br, zstd` sin cambio
  (la excepción de FlyWeb sin zstd sigue). `RendererSideContentDecoding` nuevo, **OFF** (la descompresión en renderer no cambia la cabecera).

**1.3 QUIC / HTTP/3: sin cambio en los parámetros de transporte ni en las tramas del cliente (V código, S captura).**
- QUICHE 69 commits: MoQT, MASQUE/OHTTP (herramientas), `QuicTimeWaitList`, `QuicHeadersStream`/stream-closing, bzlmod, limpiezas de flags.
  `transport_parameters.cc` **-71 líneas**: borra el camino antiguo (`0xFF73DB`) tras deprecar `quic_version_negotiation_rfc` (`064ae1b7`); el flag ya era `true` en el QUICHE de 135.
  **El parche de 135 (`f4690dbf` + flag true) sigue valiendo tal cual**; no hay que añadir nada para 136 (opcional: borrar el camino antiguo, 0 h útiles).
  `quic_config.cc`, `tls_client_handshaker.cc`, `quic_crypto_client_config.cc`: sin diff; `quic_spdy_session.cc`: solo parámetro `priority_type` (herramientas).
- Flags de `quiche_feature_flags_list.h` que cambian de valor en 136 (V): `quic_use_alarm_multiplexer` false -> true (gestión interna de alarmas, sin efecto en el cable),
  `quic_notify_ack_listener_earlier` y `quic_notify_stream_soon_to_destroy` -> true (interno), `quic_use_one_map_in_time_wait_list` -> true (servidor); se borran `quic_ack_ce_immediately`,
  `quic_gfe_allow_alps_new_codepoint`, `quic_support_flow_label2`, `quic_no_vn_in_response_to_vn`, `quic_dispatcher_only_serialize...` (todos servidor). Nuevo `quic_record_tos_byte` false.
- Chromium: `3eb1f7fe` envío de ECN en `QuicChromiumPacketWriter` (V `quic_chromium_packet_writer.cc`): `SupportsEcn()` pasa de `false` a **`true`** y el escritor hace `socket_->SetTos(DSCP_NO_CHANGE, ecn)` según
  `params.ecn_codepoint`. **S**: solo marcaría ECT(0)/ECT(1) si `QuicSentPacketManager::EnableECT0/1()` (algoritmo de congestión) lo pide; por defecto no consta. Si lo hiciera, sería un cambio observable a nivel IP (bits ECN), no en JA4Q.
  Es parte del propio Chrome 136 (V: está en el tag); portar el escritor son ~60 líneas (1 h), con captura de QUIC para confirmar.
- `quic_session_pool_job.cc`/`quic_session_pool.h`: `AddedToJob/RemovedFromJob` (CHECK de depuración).

**1.4 Client Hints / UA / cabeceras.**
- **Refactor grande (V): `content/common/user_agent.cc` y `content/public/common/user_agent.h` DESAPARECEN** (`b742ad8b`, 04-03-2025, «Merge //content/common/user_agent.cc into //components/embedder_support:user_agent»);
  sus funciones (`GetUserAgentPlatform`, `GetUnifiedPlatform` = `Macintosh; Intel Mac OS X 10_15_7`, `BuildCpuInfo`, `GetOSVersion` con el tope 10_15_7, `BuildUserAgentFromProduct`, `GetCpuArchitecture/Bitness`...)
  pasan a `components/embedder_support/user_agent_utils.cc` (+~230 líneas) y `784ba703` borra `GetReducedUserAgent`. **Salida idéntica** (V: mismo cuerpo, mismo `10_15_7`).
  Impacto en el porte: el parche `patches/content-common-user_agent.cc.patch` (solo `BRAVE_GET_ANDROID_OS_INFO`, Android) y `components-embedder_support-user_agent_utils.cc.patch` (BRAVE_GET_USER_AGENT_BRAND_LIST,
  BRAVE_BRAND_VERSION_OVERRIDE...) chocan con el movimiento. Si se queda la estructura de la 128: **no portar el movimiento** (0 h); si se porta: 1,5–2 h (17 hunks en `user_agent_utils.cc`).
- `GenerateBrandVersionList`/GREASE (`GetGreasedUserAgentBrandVersion`, `GetRandomOrder`): **sin cambio de algoritmo** (V). Con semilla 136 sale (calculado, V):
  `Sec-CH-UA: "Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"` (grease `Not` + `chars[136%11]`=`.` + `A` + `chars[137%11]`=`/` + `Brand`; versión `[136%3]`=`99`; permutación `orders[136%6]`={2,0,1}).
  `Sec-CH-UA-Full-Version-List: "Chromium";v="136.0.7103.116", "Google Chrome";v="136.0.7103.116", "Not.A/Brand";v="99.0.0.0"`. Solo depende de `flyweb_engine_level` y de la versión completa.
  (El de 135 era `"Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"`: el orden cambia.)
- `third_party/blink/common/client_hints/*` y `services/network/public/cpp/client_hints.h` (solo `COMPONENT_EXPORT(NETWORK_CPP_WEB_PLATFORM)`): lista de hints igual. `permissions_policy_features.json5`: cambios en `services/network/public/cpp/permissions_policy/` (revisar: mapa client hints <-> políticas; es del otro subagente de Blink si toca `document.featurePolicy`).
- Cabeceras nuevas o con cambio: `Sec-Speculation-Tags` (`d60f9ff8`, `c33034fb`; `content/browser/preloading/prerender/prerender_host.cc:1651`, `prefetch_container.cc`; solo si la regla de especulación lleva `tag`, shippeado en 136; S: baja).
  `Accept-Signature` con orden nuevo (`d5222f4c`, SRI por firma; Blink/`sri_message_signatures.cc`, OFF). `Referer` ausente en preload de `Link:` de subrecursos (`NoReferrerForPreloadFromSubresource`, Blink).
  `Sec-Fetch-Storage-Access`: `StorageAccessHeaders` ON desde 135; en 136 se borra `StorageAccessHeadersTrial` y la lógica queda `return IsEnabled(kStorageAccessHeaders)` (V `cookie_settings.cc`): sin cambio de comportamiento.
  `Sec-Fetch-Frame-Top`/`FrameAncestorHeaders`, `ReduceAcceptLanguage`: sin cambio de valor.
- `HttpCacheNoVarySearch` **OFF** en ambas (V), aunque `no_vary_search_cache.cc` crece (+487): no se ve.

**Qué portar de la red para coincidir con Chrome 136 (resumen):** (a) la fórmula del Sec-CH-UA ya sale sola con `flyweb_engine_level=136`; (b) `SplitCacheByCrossSiteMainFrameNavigationBoolean` OFF -> ON (8bea9cb2); (c) regenerar HSTS/`.pins`/`log_list.json`;
(d) (opcional, con captura) ECN del escritor QUIC. No hay que tocar TLS, ALPS, H2 ni QUICHE.

## 2. BASE_FEATURE 135 -> 136 (V: lectura del código de ambos tags; «NUEVO/BORRADO» incluye traslados; solo los CAMBIO son seguros)

Listados completos: `/tmp/claude-0/port/f136/feat.txt` (net/, services/network, content/{common,public/common,browser}, components/{embedder_support,network_session_configurator,variations}, blink/common) y
`feat_git.txt` (99 ficheros `*features*.cc` cambiados en todo el árbol).

**CAMBIO de valor que importan a la web/huella (portar):**
| Feature | Fichero | Cambio | Nota |
|---|---|---|---|
| `SplitCacheByCrossSiteMainFrameNavigationBoolean` | `net/base/features.cc` | OFF -> **ON** | `8bea9cb2` (13-03-2025). Clave de caché HTTP con el bit «navegación principal cross-site»; no sale al cable pero cambia aciertos de caché/tiempos. Depende de `SplitCacheByNetworkIsolationKey` (ON). 0,25 h |
| `CacheControlNoStoreEnterBackForwardCache` | `content/public/common/content_features.cc` | OFF -> **ON** | Páginas `Cache-Control: no-store` entran en bfcache (eventos `pageshow persisted`). Código en 128 (S). 0,5–1 h con prueba |
| `WebRtcAllowH265Receive` / `WebRtcAllowH265Send`, `MediaRecorderHEVCSupport` | `media/webrtc/webrtc_features.cc`, `media/base/media_switches.cc` | OFF -> **ON** | `RTCRtpReceiver.getCapabilities('video')` y `MediaRecorder.isTypeSupported` listan H265 si hay HEVC por hardware (VideoToolbox). Huella observable; en Mojave depende del HW (S). Evaluar 0,5 h; no portar si FlyWeb no expone HEVC |
| `DeleteStaleSessionCookiesOnStartup` | `content_features.cc` | OFF -> ON | Borra cookies de sesión viejas al arrancar. **No portar** (borra datos; S sin efecto de huella) |
| `SiteInstanceGroupsForDataUrls` | `content_features.cc` | OFF -> ON | Modelo de procesos para `data:`. Interno; no portar (S) |
| `EarlyEstablishGpuChannel` | `content_features.cc` | ON -> OFF | Rendimiento. No portar |
| `EstablishGpuChannelAsync` | `blink/common/features.cc` | ON -> `#if Android ON else OFF` | Rendimiento en escritorio. Es de Blink-common; aviso |
| `WebAuthenticationHybridLinking` | `device/fido/features.cc` | ON -> OFF | Fuera de FlyWeb (FM.42) |
| `PdfCr23` | `pdf/pdf_features.cc` | OFF -> ON | Visor PDF con nueva UI (Blink/PDF); S, ver con el otro subagente |
| `FileDialogsBlockPictureInPicture` | `media/base/media_switches.cc` | ON -> OFF | Interno |
| `cc`: `NewContentForCheckerboardedScrolls`, `UseMapRectForPixelMovement`, `ViewTransitionCaptureAndDisplay`, `InitImageDecodeLastUseTime` | `cc/base/features.cc` | OFF -> ON | Rendimiento/compositor; `ViewTransitionCaptureAndDisplay` va con View Transitions (Blink). Ver con el otro subagente |
| `UseFrameIntervalDecider`, `WebViewEnableADPFGpuMain`, `DevToolsWellKnown`, `Autofill*`, `Signin*`, `Sync*`, `Commerce*`, `Payments*`... | varios | OFF -> ON | UI/Android/servicios Google: **no portar** (fuera de FlyWeb) |

**Nuevos ON que cambian el comportamiento de red/carga (valorar):**
`PrefetchBumpNetworkPriorityAfterBeingServed`, `PrefetchNetworkPriorityForEmbedders` (prioridad de red de los prefetch de especulación; solo `Priority:`/prioridad HTTP/2 de esas peticiones, S baja),
`Prerender2NoVarySearch` (con NVS OFF, inerte), `NoReferrerForPreloadFromSubresource` (Blink, seguridad: **portar**, 0,5 h, es del otro subagente), `RenderThrottleFrameRate` (cc, S),
`CombineNewWindowIPCs`, `IsPaintableChecksResourceProviderInsteadOfBridge`, `AdjustCanCreateCanvas2dResourceProvider` (rendimiento/canvas), `PrefetchBrowsingDataRemoval`.

**Nuevos OFF o inertes (no portar):** `RendererSideContentDecoding` (OFF), `GetCookiesOnSet` (OFF), `PopulatePermissionsPolicyOnRequest` (OFF), `NoThrowForCSPBlockedWorker` (OFF),
`LocalNetworkAccessChecks` (+`...Warn`, OFF; en 135 ya constaba), `VerifyQWACs` (OFF), `SharedStorageTransactionalBatchUpdate` (OFF), `BackForwardCachePrioritizedEntry` (OFF),
`EnableProbabilisticRevealTokens` (OFF; sustituye a los parámetros `IpPrivacyProbabilisticRevealToken*` de `kEnableIpProtectionProxy`, que se borran: **no portar, regla 20**).

**Privacy Sandbox / telemetría (mantener APAGADO o ausente):** `FledgeUseKVv2SignalsCache` (OFF -> ON), `FledgeOriginScopedKeys` (nuevo ON), `ProtectedAudienceCorsSafelistKVv2Signals` (nuevo ON),
`FledgePrepareSellerContextsInAdvance` (ON), `AttributionReportingRateLimitCheckSourceTime` (ON), `PrivacySandboxEqualizedPromptButtons` (ON), avisos `*NoticeModal` (ON, UI de Chrome), `BeaconLeakageLogging`.
Brave ya apaga la parte de ads (`InterestGroupStorage`, `BrowsingTopics`, `SharedStorageAPI`), pero **revisar que los nuevos `Fledge*` no reabren nada**: 0,5 h.

**BORRADOS (el flag desaparece; queda el valor):** `AncestorChainBitEnabledInPartitionedCookies` (ON; cookies particionadas con bit de cadena de ancestros, ya el valor de Chrome),
`OptimizeParsingDataUrls` (ON; **choca con el parche `net-base-data_url.cc.patch`**, 7 hunks), `PervasivePayloadsList`, `PlzDedicatedWorker` (ON), `PrefetchNewWaitLoop` (ON),
`StorageAccessHeadersTrial`, `SqlWALModeOnDipsDatabase` (ON; BTM/DIPS), `ThreadedScrollPreventRenderingStarvation`, `WebSQLWebViewAccess`, `UtilityWithUiPumpInitializesCom` (Win).
Para la 128: si el flag existe allí, dejarlo en el valor ON (receta «dejar la flag en stable»).

## 3. macOS: nada obligatorio; deployment target sigue en 11.0 (V)

- `build/config/mac/mac_sdk.gni`: `mac_deployment_target = "11.0"` en ambos tags (V); `mac_sdk_official_version` 15.1 -> 15.2 (Xcode 16.2; FlyWeb sigue con SDK 13.3).
  `obsolete_system_mac.cc`: «Chromium 138 será el último con macOS 11» (solo avisos de UI). Sin subida de mínimos.
- Barrido de los 231 ficheros `.mm`/`_mac`/`_apple`/cocoa/metal cambiados (`/tmp/claude-0/port/f136/names_mac.txt`; diff en `mac.diff`): **0 APIs 10.15+ nuevas sin guarda** que lleguen a producción de Mojave.
| Fichero / commit | API | Qué hace | Mojave | Coste |
|---|---|---|---|---|
| `media/base/mac/video_capture_device_avfoundation_helpers.mm` (`kUseAVCaptureDeviceTypeContinuity` ON) | `AVCaptureDeviceTypeContinuityCamera` (13+) | Cámaras de continuidad | **Dentro de `@available(macOS 14.0, *)`** (V, líneas 28-47); Mojave toma el `else` | 0 |
| `media/audio/mac/screen_capture_kit_swizzler.mm` | `@available(macOS 15.0, *)` | Evita el swizzle en 15+ | Guardado | 0 |
| `content/app_shim_remote_cocoa/web_menu_runner_mac.mm`, `ui/menus/cocoa/menu_controller.mm`, `ui/gfx/image/image_skia_util_mac.mm`, `ui/views/widget/native_widget_mac.mm`, `native_widget_ns_window_bridge.mm` | refactors AppKit (propiedades, `menuModelForNSMenuItem:`, `useWithPopUpButtonCell` fuera) | Selectores y limpieza | Sin API nueva (el comentario de macOS 14 para cabeceras de sección es un TODO) | 0 |
| `gpu/ipc/service/image_transport_surface_overlay_mac.mm`, `shared_image/iosurface_image_backing*.mm`, `shared_image_format_service_utils_mac.mm` | `kIOSurfaceMultiThreading` (nuevo, **OFF**), `MTLPixelFormatRGBA16Float` (10.11) | IOSurface multihilo, formato HDR | OFF / API vieja | 0 (si se porta `image_transport_surface_overlay_mac.mm` ver 135 §4: `ShouldRecordSubsampledMetric`) |
| `components/device_signals/core/{common,browser}/mac/*` | `MacOSMajorVersion() < 15` | Señales empresariales | Fuera de FlyWeb | 0 |
| `components/metrics/drive_metrics_provider_mac.mm` | borrado (-79) | IOKit/DiskArbitration | n/a | 0 |
| `device/fido/enclave/icloud_recovery_key_mac.mm`, `icloud_keychain.mm`, `extensible_enterprise_sso_entra.mm`, `immersive_mode_controller_cocoa.mm` | iCloud Keychain, SSO, inmersivo | Fuera / guardados por versión | 0 |
| `base/mac/launch_application.{h,mm}`, `base/mac/code_signature.cc` | `absl::variant` -> `std::variant` | Cambio de tipo en `CommandLineArgs` | **Choca con tus parches `base-mac-launch_application.mm.patch`/`.h`**; no es API de macOS | 0,5 h |
- Trampa transversal: `absl::variant/optional` -> `std::variant/optional` por todo `net/`, `base/`, `content/` (host resolver, connect jobs, `launch_application`): al portar una función de 136 a la 128 hay que usar el tipo de la 128.
  Y `SHA256HashValue::data` pasa de miembro `data[32]` a `std::array` (`sha256.data()`; `net/base/hash_value.h`, `x509_util_apple.cc`, `trust_store_mac.cc`): afecta a cualquier parche que lea `.data` (HSTS/pins, trust store de Chrome). 0,5–1 h al portar `net/cert`.
- `base/threading/platform_thread_apple.mm`: **sin diff** en 136 (V; el parche de 8 líneas de FlyWeb no se toca).

## 4. GPU / ANGLE / Skia / Dawn

- **Listas de bloqueo (V): `gpu/config/software_rendering_list.json` NO cambia** (id 183 «Block accelerated canvas on NVidia macs» intacto; sigue el aviso del MacBook Pro 2012 GT 650M).
  `gpu_driver_bug_list.json`: solo Windows (ids 403 borrado, 442 nuevo, `disable_direct_composition` -> `..._video_overlays`); `gpu_workaround_list.txt`: `force_rgb10a2_overlay_support` Win. Mac sin entradas nuevas.
  `gpu_util.cc`: renombra `swiftshader` -> `software_gl` y añade WARP de D3D11 (Windows). `feature_info.cc`: `is_swiftshader_for_webgl` -> `is_software_webgl`.
- **Primitive restart (V):** la 136 **vuelve a activar** `GL_PRIMITIVE_RESTART_FIXED_INDEX` para WebGL2 en el decodificador (validating: `DoEnable` en `Initialize`; passthrough: bloque «TEMPORARY» + `IsIgnoredCap` para `GL_PRIMITIVE_RESTART_FIXED_INDEX`
  en contextos WebGL). Es decir, **lo contrario de lo que borró la 135**: el comportamiento de la 134 que el informe 135 mandaba conservar queda **igual que Chrome 136**. Con nuestro ANGLE de la 128, probar WebGL2 con índices 0xFFFF/0xFFFFFFFF en Mojave (5,1/6,1 + MBP 2012 con GT 650M): 1 h.
  También: `attrib_helper.enable_oop_rasterization` -> `enable_gpu_rasterization` (renombre) en passthrough.
- **Nuevo `AllowANGLEPassthroughShaders` (ON, killswitch en `ui/gl/gl_features.cc`):** pasa un feature de ANGLE «shaders sin traducir al driver». Como no subimos ANGLE, es inerte (S: comprobar que `GetANGLEFeaturesFromCommandLineAndFinch` no peta con un nombre de feature que la ANGLE de la 128 desconoce; 0,25 h).
- **ANGLE (193 commits, `079266db` -> `fa40b7c5`):** lo que toca el backend GL/CGL (S: no aplicable sin subir ANGLE, que seguimos sin subir): `db48967f50` «Reland: GL_BGRA_EXT como formato sized renderable» (`formatutilsgl.cpp` +79, `Caps.cpp`, `renderergl_utils.cpp`; esta vez **no** se revierte en el rango) —
  cambia qué formatos reporta `getInternalformatParameter`/renderbuffers en GL (WebGL2 en Mac GL) y es un cambio de huella menor; `forceMaxCombinedShaderOutputResources` para NVIDIA (GLES 3.1 solamente, no afecta a WebGL);
  `supportsShaderFramebufferFetchEXT` exige `drawBuffersIndexedAny()`. `IOSurfaceSurfaceCGL`/`PbufferSurfaceCGL`/`WindowSurfaceCGL`: solo renombres. El resto: Vulkan, Metal (líneas en bucle, `divMatrixScalar`), traductor (`textureGather`, swizzle), WebGPU.
  Si algún día se quiere el reporte de `GL_BGRA_EXT`, es un parche de ~80 líneas (1–2 h, S).
- **Skia (254 commits):** nada de Ganesh-GL/CoreText salvo `20e7a6c88fa` «Fix CoreText data font weight calculation» (peso de fuentes cargadas desde datos por CoreText; puede mover el `font-weight` efectivo de webfonts en Mac; **S**, 0,5 h para comprobar con una webfont variable) y
  `0063b824168` (AAA, `updateQuadratic`: píxel). Fontations/Skrifa 0.29 y Graphite: no se usan en Mac Intel. Sin impacto en `software_rendering_list`.
- **Dawn / SwiftShader:** WebGPU apagada en FlyWeb; sin impacto. `webnn/coreml/tensor_impl_coreml.mm` (WebNN, fuera).
- Compositor/otros: `cc/paint/paint_shader.cc`, `cc/trees/property_tree.cc` (parches de FlyWeb) cambian en 136 (`property_tree.cc` 18 hunks): ver el otro subagente/CC; coste de rebase 1 h.

## 5. HSTS preload, pins y log_list.json (CT) de la 136

| Fichero (ruta) | 135 -> 136 | Notas |
|---|---|---|
| `net/http/transport_security_state_static.json` | **cambia**: 164 770 -> 165 699 entradas (+1285 nuevas, -356 quitadas, 0 modificadas; 18,27 -> 18,37 MB; ~349 hunks) | Todas `bulk-1-year force-https include_subdomains`, sin pins. `pinsets` vacío en ambas (V, comparado programáticamente). Parche de FlyWeb/Brave `net-http-transport_security_state_static.json.patch`: regenerar (V el parche existe) |
| `net/http/transport_security_state_static.pins` | **2 líneas** (comentario «Last updated: 2025-04-21 12:54 UTC» -> 2025-05-10 12:55 UTC y el timestamp 1745240079 -> 1746881712) | Sin pins nuevos |
| `net/http/transport_security_state_static_pins.json` | **1 línea** (mismo comentario) | idem |
| `components/certificate_transparency/data/log_list.json` | **versión 53.19 -> 53.41**, `log_list_timestamp` 2025-04-21 -> 2025-05-11; **2 líneas**, sin logs nuevos ni quitados (V `diff` de 4 líneas) | Parche de Brave sobre este fichero y `ct_known_logs`: ver que sigue aplicando |
| `net/data/ssl/chrome_root_store/root_store.{textproto,md,certs}` | textproto +664 (v17 -> v18, `eutl`/`additional_certs`), md 1 línea, **certs idéntico** | Ver §1.1: confianza igual |
| `net/http/transport_security_state_static_unittest*.json` | sin cambio | n/a |
Coste: regenerar los 3 parches HSTS/pins + CT = 0,5–1 h (mecánico, como en 135). El código de pins (`transport_security_state.cc`) no cambia salvo `SHA256HashValue`.

## 6. Estimación en horas reales (las de papel ~4x pesimistas, ya divididas)

| Tarea | Horas |
|---|---|
| `SplitCacheByCrossSiteMainFrameNavigationBoolean` + comprobar `CacheControlNoStoreEnterBackForwardCache` (ON) + decidir H265 (WebRTC/MediaRecorder) | 1–2 |
| HSTS preload + `.pins` + `log_list.json` (regenerar los 3-4 parches de Brave) | 0,5–1 |
| Captura TLS/HTTP2 (JA4/JA3, SETTINGS) y QUIC (Initial, ECN) frente a Chrome 136.0.7103.116 real: pasar S a V | 1–1,5 |
| Sec-CH-UA con semilla 136 (verificar la cadena calculada en 1.4 con `flyweb_engine_level=136`) | 0,25 |
| Comprobar que ningún parche se rompe por: movimiento de `user_agent.cc`, `absl::variant -> std::variant`, `SHA256HashValue.data`, `OptimizeParsingDataUrls` borrada (`data_url.cc`), `trust_store_chrome` refactor | 1–1,5 |
| WebGL2 en Mojave (primitive restart vuelto a ON) en 5,1/6,1 + MBP 2012 | 1 |
| Revisar que ningún `Fledge*`/`PrivacySandbox*` nuevo reabre algo (regla 20) | 0,5 |
| **Total obligatorio / útil** | **≈ 5–7,5 h (red, macOS, GPU y datos; sin Blink ni V8)** |
| Opcional: ECN del escritor QUIC (1 h), `GL_BGRA_EXT` renderable (1–2 h), CoreText data font weight (0,5 h), `PrefetchBump/NetworkPriority` (0,5 h) | +3–4 |

Riesgo principal: la **captura** (JA4/JA4Q, ECN) sigue siendo lo que pasa S a V; y el **rebase de los 101 ficheros no-Blink parcheados** que también cambian en 136 (lista en `f136/colision.txt`; 1385 hunks de diff 135->136 sobre esos
ficheros, de los que 349 son el JSON de HSTS y 111 `about_flags.cc`; el resto, ~50 con >5 hunks: `render_frame_host_impl.cc` 42, `web_contents_impl.cc` 37, `navigation_request.cc` 26, `network_handler.cc` 21, `canonical_cookie.cc` 20, `user_agent_utils.cc` 17...).
Eso solo cuenta si se porta ese cambio; no hay que rebasar los ficheros.

## 7. Lo no encontrado (para no buscarlo otra vez)

- Sin cambios (0 líneas, V) en: `net/ssl/*`, `ssl_client_socket_impl.cc`, `net/http/http_util.cc`, `http_request_headers.cc`, `net/filter/source_stream_type.h`, `services/network/public/cpp/constants.cc`,
  `quic_session_pool.cc`/`quic_chromium_client_session.cc`/`quic_context.*` (salvo `AddedToJob`), `third_party/blink/common/client_hints/*`, `gpu/config/software_rendering_list.json`,
  `chrome_root_store/root_store.certs`, `base/threading/platform_thread_apple.mm`, `UseNewAlpsCodepoint*` (ya en ON).
- No hay en 136 ningún cambio de BoringSSL en grupos, sigalgs, ECH, GREASE o permutación de extensiones; ni cambios de SETTINGS HTTP/2; ni de parámetros de transporte QUIC del cliente.
- No comprobado (S): capturas reales de Chrome 136 (JA4, JA4Q, ECN); si `EnableECT1()` es true por defecto con el algoritmo de congestión de Chrome; el resultado exacto de `getCapabilities` para H265 en Mojave;
  `AllowANGLEPassthroughShaders` con la ANGLE de la 128; el contenido de `content/browser` aparte de los features (838 ficheros cambiados, no leídos uno a uno: `diff` en `f136/content_browser.diff`);
  `base/features.cc` y `ui/`/`media/` fuera de los `.mm` y los `*features*.cc`; Android/iOS/ChromeOS/Windows (fuera de alcance).
- Pendiente de otros subagentes: Blink (incl. `NoReferrerForPreloadFromSubresource`, `ViewTransitionCaptureAndDisplay`, `EstablishGpuChannelAsync`, `PdfCr23`) y V8.

## Nivel 137

MOTOR-37, 30-10-2026: inventario con 4 subagentes Sonnet (Blink, V8 13.7, fuera de Blink y cruce wpt.fyi) sobre
**137.0.7151.122** (última Stable de Mac del 137, V por versionhistory.googleapis.com; V8 **13.7.152.17** = 075234cf3d).
Informes, abajo tal cual; cruce en [`wpt-137-cruce.md`](wpt-137-cruce.md). Rama brave-core **`nube/motor-137`**, sobre
`local/250-arreglos` 3e8c8e219a (= `nube/motor-136` 1747f79f + FS.37), **sin compilar**.

**Resumen:** nivel medio. V8 13.7 barata (231 de 256 `patches/v8` limpios; simdutf a 6.4.0 obligatoria). Huella de red sin
cambio observable (por código). Blink: los dos bloques grandes (`if()` y `reading-flow`) piden infraestructura del 13x
que la 128 no tiene (ver «Pendiente del 137»). Nada exige AVX ni APIs de 10.15+ (salvo `UTType` en
`shell_integration_mac.mm`, solo si se porta esa función).

**Hecho por MOTOR-37 (`nube/motor-137`, sin compilar; `chk128.sh` y `v8chk.sh` en verde en cada commit):**
| Commit | Qué |
|---|---|
| b832524c | **`:visited` particionado con self-links** (decisión de Titín del 136): 15 commits 128→137 sobre la infraestructura de la 128 (`PartitionedVisitedLinkWriter`, `VisitedLinkDatabase`); `PartitionVisitedLinkDatabaseWithSelfLinks` stable (su `base::Feature` la genera el json5, como en la 137); `kPartitionVisitedLinkDatabase` sigue apagada. A mano: `HTMLAnchorElement` (no `…Base`), sitio superior cacheado en el constructor de `Document` de la 128, `frame_url` al final de `HistoryAddPageArgs` (sin romper llamadas posicionales). Sin entradas de `chrome://flags` |
| 2afdbe36 | faltas (c) del cruce, 1.ª tanda: 5a687a31d, 69b4d66dc, 69e2e4a30, 8963d3274 (AudioWorklet `process()` por instancia). Saltadas: 5f8643cf1, 6f2b75e22, 58e06f599, 10da5d634, c832b551d/fb4a7683f/9983d9c9f (nodos suma/producto de `calc()` del 13x) |
| 1aefb25a | HSTS, pins y `log_list.json` de la 137 (55.7, sin Sectigo Sabre) |
| cc6ec885 | **V8 13.7.152.17** + simdutf 6.4.0: `v8re.sh`, 16 parches soltados (ya upstream), 4 a mano (`wasm.tq`, `compiler.cc`, `turboshaft/pipelines.cc` con la guarda de 4 KB, `store-store-elimination-reducer-inl.h`); .18/.19 ya estaban; época de caché 27. Maglev **sigue apagado** (pregunta a COORDINACIÓN) |
| d20bb0ed | Ed25519 (e1b1cfbcc, 92a9ca085), `offset-path: shape()` (0c33b6e13, 96d9ccc8d, 779bc1cbe; `BasicShape` con `scoped_refptr` de la 128), `LayoutNGShapeCache`, noopener en navegaciones a blob: de otro sitio (12a036755, d38e87a3f; ENABLED como en 137), **`TableIsAutoFixedLayout` vuelve a `test`** (775fc95e0: deshace la del 136) |
| e14354b1 | arreglos que nacen stable: 0ed040ec0, 9c525476b + c2186af2a (`<use>` a raíz externa), 7ffa5b3a3, 768a189b0, 09c66878c, 0985ff647, a83881e2d, e423ccef7. Saltados: 430520313 (solo el flip de `SvgTransformOnNestedSvgElement`), 4c7536927 y d7020222f (ya estaban), 88a83e3a4 (camino de la 128 distinto), 0207b9d2a (line-clamp del 13x) |
| dea5f3eb | `HandleScope` en `ScriptState::DisposePerContextData` (como Chromium 137) |

**Hecho por MOTOR-38 (`nube/motor-137`, sin compilar; `chk128.sh` en verde en cada commit):**
| Commit | Qué |
|---|---|
| ce442bec | **CSS `if()`** con `style()`, `media()` y `supports()` (cadena de 19 commits, a mano): ficheros nuevos de la 137 (`if_condition.*`, `css_if_eval.h`, `kleene_value.h`, `media_eval_utils.h`, `parser/css_if_parser.*`); los bloques de `media()`/`style()` se pasan **por rango** a los parsers de la 128 (`MediaQueryParser::ConsumeIfMediaTest`, `ContainerQueryParser::ConsumeIfStyleQuery`); media funcional de 1ddf33edab (`StyleEngine::EvaluateFunctionalMediaQuery`, invalidación, `AffectedByFunctionalMedia`, fuera de la MPC); `EvalIfInitial/Inherit` seguros con nulos (la 137 desreferencia los dos lados). Flags `CSSInlineIfFor{Media,Style,Supports}Queries` stable |
| f4b4d1ec | **`reading-flow`/`reading-order`** (11 commits; f9acfd178d, contador WebDX, fuera): `Element::ReadingFlowChildren`, nodos en vez de elementos, tabindex, `display: contents`, `reading-order` y `source-order`. A mano: flex queda como la 128 (= 137 tras e278a7b657), grid y AX como la 137 sobre estructuras de la 128. Flags `CSSReadingFlow`/`CSSReadingOrder` stable. Regla 17: foco |
| 5abcd0cc | **Selección a través de Shadow DOM**: `getComposedRanges`, `direction`, `UpdateSelectionBehavior`/`CollapseIfNeeded` (91084df601, bdeda3f178, 5c67432271, 293ab78a94, 74bc8664c7, 518f88cf9a, 4b1cbba41a, a485c783d8); foco y selección con ratón por el árbol plano en su forma final (b82f00e345, 0ecd2fcf04, d331873629, 7cc78c603a); `SelectionAcrossShadowDOM` stable. Ya estaban: bea8eb7a19, e16c86f61d, 15d4924b21, c8a1a5f70f |

**Hecho por MOTOR-39 (`nube/motor-137`, sin compilar; parches regenerados en fuente desde 128.0.6613.138 y comprobados con `git apply`):**

| Commit | Qué |
|---|---|
| 331b25b6 | merge de `local/250-arreglos` 44d92a8611 (arreglos de LOCAL-14 de la 1.ª pasada de la 2.5.0); `style_builder_converter.cc`, `element.h` y `out_of_flow_layout_part.cc` resueltos con merge a 3 vías sobre la fuente |
| 92748597 | `EnterInOpenShadowRoots` stable + su uso en `ApplyStyleCommand::ApplyBlockStyle` (el único que faltaba; en la 137 la flag sale en 4 ficheros: los otros 3 ya estaban) |
| 18dc7d4a | **Root Store v19** compilado (118 anclas, −17 raíces): `root_store.{certs,md}` de la 137; el `textproto` sin `additional_certs`/`eutl` (solo alimentan QWAC, apagado; el proto de la 128 no los tiene). El componente del espejo sigue mandando si su `version_major` es mayor (`cert_verifier_service_factory.cc:310`) |
| c1e082f4 | **VT `view-transition-name: match-element`** a mano: keyword guardada como `ScopedCSSName` con nombre reservado (`view_transition_match_element.h`), el tracker la cambia por `-ua-auto-<token>-<DOMNodeId>` como la 137. `CSSViewTransitionMatchElement` stable; `auto` sigue fuera (experimental en la 137) |

**Resueltos sin código (MOTOR-39):**
- `maglev/extras-cped`: fallo esperado (Maglev apagado por parche); detalle en `version-2.6.0.md`.
- **`DocumentIsolationPolicy`: Brave 1.79 (v1.79.126) no la apaga** (0 referencias en `chromium_src`, `app`, `browser`,
  `components`). Pero en Chrome 137 la de Blink es `experimental` con `origin_trial_feature_name` (solo por origin trial);
  la `base::Feature` de red está activa en Mac. Ninguna web la ve → **no se porta, tampoco en la 2.6.x** (COORDINACIÓN-22,
  30-10; directiva del 22-10); se reabre cuando Chrome la saque en stable. En la 2.6.x va solo el Blob URL.
- **`SvgTransformOnNestedSvgElement`: saltada** (1 WPT). En la 137 la usan `layout_svg_viewport_container.cc` y
  `layout_svg_container.cc` sobre la dependencia del viewport de los 13x (`SVGLayoutResult::has_viewport_dependence`,
  `HasViewportDependence()`), que la 128 lleva como bit de `LayoutObject`; portarla exige ese refactor de SVG.

**Pendiente del 137 (para MOTOR-39), por orden** (los puntos 2 a 4 de MOTOR-37 están hechos arriba):
1. **Hecho (MOTOR-39): fallo esperado, por el parche que apaga Maglev; explicación en `version-2.6.0.md`.** **d8 13.7 (D8-LINUX, cc6ec885): en verde salvo `mjsunit/maglev/extras-cped`** (assertTrue en `extras-cped.js` 39:1;
   pasa en la base 13.7.152.17 y falla con nuestros parches, igual que en la 13.6). Cifras: base 7756/7756; parcheada
   7799/7800 (también `--always-osr`); maglev+compiler con `--maglev --stress-maglev` 1319/1319; jspi, `wasm/deopt*`,
   `compiler/regress-*` sin fallos; Intl sin cubrir (d8 sin ICU). Hipótesis de COORDINACIÓN: el parche que apaga Maglev.
   Confirmarlo leyendo la prueba y `patches/v8`; si es eso, anotarlo como esperado (`FLYWEB-SECURITY.md` o
   `version-2.6.0.md`); si no, es un error nuestro y va antes que todo lo demás.
0. **`EnterInOpenShadowRoots`** (FW: `test`; la 137.0.7151.122 la lleva **stable** aunque main la bajó a `test` el 14-04,
   3efb9e44bb: se volvió a subir en la rama). Falta en FlyWeb su uso en `apply_style_command.cc` (9c070c13a5 u otro;
   buscarlo) antes de subirla a stable. ~30 min.

**Pendiente del 137 que dejó MOTOR-37 (historial):**
1. Errores de la compilación de la 2.5.0 (si llegan) y el informe de la d8 13.7 (D8-LINUX, sha cc6ec885b7 o posterior).
2. **CSS `if()`** (A01, 3 WPT): la cadena (19 commits, `if.lst` abajo) choca con el parser de media/container queries por
   **rangos** de la 128 (la 137 los parsea por *stream*). Intento a medias en el área `w-if` (descartado): sirvió para
   ver que `StyleCascade::ResolveTokensInto` necesita `stop_type` (hecho como sobrecarga en el intento) y que `CSSIfParser`
   llama a `MediaQueryParser`/`ContainerQueryParser` por stream. Plan: tomar los ficheros nuevos de la 137
   (`css_if_parser.*`, `if_condition.*`, `css_if_eval.h`) y adaptar en ellos la llamada a los parsers de la 128 copiando
   los tokens del bloque a un `Vector<CSSParserToken>` + `CSSParserTokenOffsets` (rango); evaluación en `style_cascade`
   como la de la 137 con la `FunctionContext&` de FlyWeb. ~3–4 h.
   Lista: 15b0dd79a f60813b56 1100c6a3b 5a9b20760 2a9f96e9d d493c46e1 b88b05d57 a0afe67d7 95e14742d 2b59535ef 77da4c5d2
   24399cf35 3675994aa 828bd154d 6e7570095 841f10dd1 53002c0e2 0b6b1760f a10210e9b.
3. **`reading-flow`/`reading-order`** (A02, 7 WPT, 14 commits; toca el foco: regla 17). Sin probar; mirar antes si choca
   con la infraestructura de foco de la 128.
4. `SelectionAcrossShadowDOM` + `getComposedRanges` (A07, 11 WPT, 8–12 commits) y `EnterInOpenShadowRoots` (FW: `test`).
5. VT `match-element` (A03): aff847fb6 necesita `StyleViewTransitionName` (13x) y el tracker de VT de la 128 difiere.
6. `SvgTransformOnNestedSvgElement`: falta la cadena de implementación (430520313 es solo el flip).
7. Canvas float16 (con prueba de farbling), y comprobar en Brave 1.79 `DocumentIsolationPolicy` (60e02302b) antes de
   portarla; Blob URL (9aae7ac7f, ~30 commits de `content/`) va en una 2.6.x propia (decisiones abajo).
8. Regla 17: pedir a SEGURIDAD-PORTES la FS del 137 (candidatos en §8 del inventario Blink y FS de V8 13.7).
9. Declaración 137.0.7151.122 / 2.6.0 en `build/config.gni` y `version-2.6.0.md` § «Para la web», al final.
10. Root Store v19 (−17 raíces): comprobar si la compilación de Mac usa `root_store.certs` o solo el del espejo de ns2.

**Decisiones del 30-10 (COORDINACIÓN-22, 16:37 y 16:49 UTC; Titín da por buenas JSPI y Maglev):**
- **JSPI y las banderas de Wasm que pasan a true en 13.7** (`wasm_deopt`, `wasm_inlining_call_indirect`, `branch_hinting`,
  `exnref`): **sí, como Chrome 137** (regla 19 y huella). Ya están así en V8 13.7 sin tocar nada. Condición: la FS del 137
  (regla 17) revisa expresamente JSPI y `wasm_deopt` con los merges posteriores hasta la LTS; si aparece algo explotado
  sin portar, se apaga desde gin (`--no-experimental-wasm-jspi`, etc.) hasta portarlo.
- **Maglev: sigue apagado en el 137** (falta la medición de JetStream de LOCAL en la 6,1 y la 5,1 y el umbral de Titín).
  Seguir portando su deuda de seguridad (`patches/v8/FLYWEB-SECURITY.md`) para que encenderlo sea solo la bandera.
- **V8 13.7.152.18/.19:** como arreglos del 137 (484172fda y 4278d6d37 ya estaban en `patches/v8`, comprobado con `apply -R`).
- **`ReduceScreenSize`: no** (Chrome 137 no la lleva); se reabre cuando Chrome la envíe.
- **Canvas float16 + `ImageData.pixelFormat`: sí, solo si `getImageData` en float pasa por el mismo farbling**, con una
  prueba que lo demuestre (dos lecturas en orígenes distintos, valores distintos); si no se puede garantizar, fuera y
  anotado. SEGURIDAD-PORTES lo revisa en la FS del 137.
- **Particionado de Blob URL: sí, en una 2.6.x propia** después de publicar la 2.6.0.
- **`DocumentIsolationPolicy`: sí**, en la 2.6.0 si cabe sin riesgo o en la misma 2.6.x que Blob URL; **antes comprobar
  que Brave 1.79 no la apaga** (si la apaga, no se porta: regla 20).
- **CSS `if()` y `reading-flow`:** a MOTOR-38 con el plan y la estimación de «Pendiente del 137».
- **FS del 137:** COORDINACIÓN la abre a SEGURIDAD-PORTES cuando MOTOR dé el inventario por cerrado.

**Coste del cruce wpt.fyi:** ~12 min, 4 consultas HTTP, un subagente Sonnet (~107 000 tokens). Dio 35 pruebas (c) en
14 causas; portadas 4 causas, 7 saltadas por infraestructura del 13x.

### Inventario Blink del nivel 137 (137.0.7151.122)

### Inventario Blink del nivel 137 (137.0.7151.122)

MOTOR (subagente de solo lectura), 30-10-2026. V = verificado (git/grep/diff), S = supuesto. Datos en `/tmp/claude-0/port/i137/`
(flags.tsv, flags-fw.tsv, blink-diff.txt, idl-diff.txt, feat.py, sample*.txt). Estado FW = json5 de cr128 + `platform-runtime_enabled_features.json5.patch`
de brave-core (rama checkout `nube/motor-137`, que ya lleva b832524c :visited y 2afdbe36 wpt-137 lote 1).

## 0. Tags y rango

- V: `136.0.7103.116` = 5e3a5617c213; `137.0.7151.122` = 4c03e725fa2c («Incrementing VERSION to 137.0.7151.122», 16-06-2025).
- V: `git rev-list --count 136.0.7103.116..137.0.7151.122` = **14 720** commits (31-03 a 16-06-2025: main hasta el corte ~28-04 y rama 7151).
- Commits que tocan `third_party/blink`: sin árboles no se puede contar. Muestra al azar de 128 commits (S): 9 con Blink (~7 %) = **~1 000–1 500**
  (en el 136 fueron 1 625). `diff -rq cr136 cr137` sobre `third_party/blink`: 2 163 entradas (con tests), 65 solo en 136, 63 solo en 137.
- S: la 137.0.7151.122 es la última Stable de Mac del 137 (no consultado versionhistory).

## 1. Resumen

Nivel **medio-pequeño en Blink**. Bloques con peso: (1) CSS `if()` (3 flags a stable, ~19 commits, casi todo código nuevo);
(2) `reading-flow`/`reading-order` (14 commits, foco/layout); (3) un lote de arreglos de edición/layout/SVG nacidos `stable`;
(4) refactor interno de flex (1 139 líneas en `flex_layout_algorithm.cc`) y grid (1 381; masonry, flag `test`): sin cara web, solo cambia el coste de fusionar.
Fuera de FlyWeb por tamaño o por regla 20: WebRTC (88 ficheros de `modules/peerconnection`), WebGPU (57), WebNN, APIs de IA (34), `v8_compile_hints_producer` (2 053 líneas, Chrome-only).
Cifras del json5 136→137 (V, `flags-nivel.py`): **18 A_STABLE**, 19 CHANGE, 49 NEW, 21 REMOVED.
**Estimación real: ~20 h** para el delta propio (filas A01–A09, B1–B5, C) + ~1,5 h regla 17; ~5 h más si Titín quiere el opcional (canvas float, ReduceScreenSize).
Nada exige AVX ni APIs 10.15+ (V en lo mirado; S en lo no leído línea a línea). FW no enciende `experimental-web-platform-features` (V: sin coincidencias en patches/build), así que lo que pasa de `test` a `experimental` (IA, Translation) sigue apagado.

## 2. Flags que pasan a `stable` (136 → 137)

Estado FW: «ausente» = ni en cr128 ni en el parche. Horas = reales (S). Privacidad según regla 20 (referencia Brave 1.79).

| Fila | Flag | Commit del flip / impl (log136-137 y log128-137) | ¿En 128 / FW? | Horas | Propuesta / privacidad |
|---|---|---|---|---|---|
| A01 CSS `if()` | `CSSInlineIfForMediaQueries`, `…StyleQueries`, `…SupportsQueries` (exp→stable; el flag base `CSSInlineIf` ya no existe) | flip a10210e9b (10-04); impl 15b0dd79a (parse), 2a9f96e9d, 5a9b20760, 24399cf35, 828bd154d, 841f10dd1, 6e7570095, 0b6e95e4e… = **~19** commits 128→137, V por asunto | ausente en 128 (`css_if_parser.cc` 163 líneas + 43 `.h` nuevos; `StyleCascade::ResolveIfInto`). FW tiene `FunctionContext` (128) y `CSSAdvancedAttrFunction` (stable en parche) | 3–4 | **portar**. Sin huella. Tras el flip, 136→137 solo cambia 15 líneas en `style_cascade.cc` |
| A02 `reading-flow` / `reading-order` | `CSSReadingFlow` (exp→stable), `CSSReadingOrder` (exp→stable, dep. del anterior) | flip c67d9fab7 (02-04); impl 14 commits (6daa0a6f5, 573065ab8, eacf422a9, 9729576fe, ffd900af8, 119f3959d, bfc8359c8, e278a7b65 `source-order`, 2e5c63af0, f9acfd178, 905712a79…) | `CSSReadingFlow` exp en 128 (parte de la impl ya está); `CSSReadingOrder` ausente. FW: sin override → exp | 4–5 | **portar** (Baseline: solo Chrome, S). `focus_controller.cc` 72 líneas de delta 136→137. Sin huella. Toca foco/tabulación: pasarlo por regla 17 |
| A03 View Transitions | `CSSViewTransitionMatchElement` (exp→stable) + `ViewTransitionUpdateLifecycleBeforeReady` (nace stable) | flip 26f116090 (14-04); impl aff847fb6 (19-12-24); fix 97dda72f8 (`[VT] Fix name capture scoping`) | flag ausente en 128; VT existe | 1,5 | **portar**. Sin huella |
| A04 `offset-path: shape()` | `CSSShapeFunctionOffsetPath` (nace stable), `CSSShapeFunctionCompositeAnimation` (exp→stable) | 0c33b6e13 (impl), 96d9ccc8d (ship), 779bc1cbe (flip) | FW lleva `CSSShapeFunction` stable y `…CompositeAnimation` exp (V parche: líneas 484–486) | 1 | **portar** (+ flip). Sin huella |
| A05 WebCrypto Ed25519 | `WebCryptoEd25519` (exp→stable) | e1b1cfbcc (ship 11-04), 92a9ca085 (`alg` del JWK) | FW: flag añadido en el parche como exp (V) → el código ya está | 0,3 | **portar** (flip + 92a9ca085). Sin huella (Mojave: BoringSSL puro) |
| A06 Canvas `float16` + `ImageData` Float16Array | `CanvasFloatingPoint` (exp→stable), `ImageDataPixelFormat` (exp→stable, ausente) | flip 0d364e3a8 (17-04); impl 11ddbcdbe (`ImageData: Use Float16Array`), 5177673d2, b188c95c0/ba1f99c0b (separar flags), d0f5f58ca, 1d0aa0d08 + renombrado `pixelFormat`→`colorType` y `uint8`→`unorm8` del contexto 2D (V: IDL cr128 usa `pixelFormat="uint8"`, cr137 `colorType="unorm8"`) | `CanvasFloatingPoint` exp en 128 (con nombres viejos); FW exp | 2–3 | **DUDOSO → Titín**. Float16 permite leer píxeles con más precisión por `getImageData`: el *farbling* de Brave actúa sobre el camino Uint8ClampedArray (S) y podría no cubrir el nuevo. Propuesta: dejar apagado en FW hasta confirmar que el farbling lo cubre |
| A07 Selección a través de Shadow DOM | `SelectionAcrossShadowDOM` (exp→stable) | flip 7cc3f757b (02-04); `getComposedRanges`: 91084df60, 5c6743227, 293ab78a9, 0698a196e (tests); isCollapsed/delegatesFocus: bea8eb7a1, e16c86f61, c8a1a5f70, 15d4924b2, c2cfc2057 (8–12 commits 128→137) | flag exp en 128 con **0 usos**; `getComposedRanges` ausente en 128 y en el parche (V `selection.idl` 137:62). FW lleva ya `SelectionIsCollapsedShadowDOMSupport` (V parche 136) | 2 | **portar**. Sin huella (API de selección) |
| A08 Dos flips sin código | `LayoutNGShapeCache` (test→stable, `base_feature`), `EnterInOpenShadowRoots` (test→stable) | 236bc250c (19-04); `EnterInOpenShadowRoots`: 3efb9e44b (14-04) lo pone en `test`, pero cr137 trae `stable` (V json5): hubo un flip posterior que no sale por asunto (S) | ambos ya en 128/FW (el 2º añadido como `test` en el parche) | 0,4 | portar el flip de `LayoutNGShapeCache` (rendimiento, caché de shaping: con prueba visual); `EnterInOpenShadowRoots` (tecla Enter en shadow roots abiertos) **solo tras ver el commit de flip** |
| A09 `PlainTextPainter` | `PlainTextPainter` (exp→stable) | flip 097f22ae1 (01-04, «para todo menos `<canvas>`»); impl ~20 commits `CanvasTextNG: …` (3a041207d, 0734e16da, 29712bd5b, eca2cc3a8…) | ausente en 128. Usos no-canvas en 137: `web_font.cc`, `string_truncator.cc`, `drag_image.cc`, `text_utils.cc`, `text_combine_painter.cc`, `graphics_context.cc`, `embedded_object_painter.cc` | (8–10) | **NO portar** (refactor de rendimiento/estructura, sin cara web; riesgo en anchuras de texto). Si un test visual lo pide, nivel aparte |
| — | `DocumentPolicyIncludeJSCallStacksInCrashReports` (exp→stable) | 0c93dbbdb | 128 lo tiene (exp, `base_feature_status: enabled`) | 0 | **apagar/dejar fuera**: solo alimenta informes de caída a Google; FW sin crash upload (S) |
| — | `CustomizableSelectElementAccessibilityIssues` | 64702bc5d | ausente; depende del select personalizable (aplazado en el 135) | 0 | fuera (DevTools + select aplazado) |
| — | `FledgeBiddingAndAuctionServerAPIMultiSeller`, `WebAuthenticationAlignErrorTypeForPaymentCredentialCreate`, `WebGPUCopyBufferToBufferOverload` (nace stable) | acc9c29ce, 1547403e1, cddaa6ecd | — | 0 | **fuera** (Privacy Sandbox / pagos / WebGPU: regla 20) |
| — | solo ChromeOS/Android: `CapturedSurfaceResolution`(ChromeOS), `GetAllScreensMedia`(ChromeOS), `DynamicSafeAreaInsets*`, `WebAppLaunchQueue` | 59112962e etc. | — | 0 | fuera |

Eliminados del json5 por haber salido ya `stable` (V; el código queda siempre encendido): `EditableBoundaryAdjustment`, `ButtonNoAlignItems`, `IncludeListElementTagInExtendedSelection`, `UnifiedScrollableAreas`, `ScrollableAreasWithScrollNodeOptimization`, `NoCollapseSpaceBeforeRuby`, `RubyOverhangOverlapFix`, `TextCombineEmphasisNG`, `AuraScrollbarUsesNinePatchTrack`, `WebAuthenticationClientCapabilities`, `WebGPUSubgroupsFeatures`, `IsSecurePaymentConfirmationAvailableAPI` (renombrado). Ninguno está en el parche de FW ni en cr128 (V): **FW no tiene esos arreglos de 129–136** salvo los que el 136 ya portó (RubyLB). A revisar por si algún test de edición falla (S): `EditableBoundaryAdjustment` (53d673eda) e `IncludeListElementTagInExtendedSelection` (d1efed814).

## 3. Flags que nacen `stable` (correcciones) y limpiezas

| Fila | Flags | Commits (por asunto, S) | Horas | Propuesta |
|---|---|---|---|---|
| B1 SVG | `AllowSvgUseToReferenceExternalDocumentRoot`, `SvgTransformOnNestedSvgElement` | 9c525476b + c2186af2a; 430520313 | 1 | portar (web-compat de `<use>`; `svg_*`) |
| B2 Edición | `CaretWithTextAffinityUpstream`, `CheckForCanonicalPositionInIdleSpellCheck` (09c66878c), `HandleDeletionAtStartAndEndBoundaryContainingHiddenElement`, `TreatSymbolsAsWordBoundary` (7ffa5b3a3), `AdjustDOMOffsetToLayoutOffsetForSecureText` (768a189b0), + 0985ff647, 0ed040ec0, e423ccef7 (nullptr en Range) | ~10 | 2 | portar los que tocan crash (09c66878c, e423ccef7) y los visibles; `element.cc` 766 líneas de delta 136→137 es sobre todo registry escopado (exp, fuera) |
| B3 Layout/texto | `LineBreakEarlyReturn`, `SkipLineBreakItemWhenIsCollapsed`, `ListOwnerMustHaveCSSBox`, `PlaceholderVisibility`, `PreLogicalMargin` (UA: `margin-block`), `TextareaStableResizing`, `RubyJustificationFix` (4c7536927), + d7020222f (bucle infinito `InlineLayoutAlgorithm`), 88a83e3a4 (caída de la caché de intrínsecos), a83881e2d (caída de sticky con container queries), 0207b9d2a (`text-overflow` en `line-clamp`) | ~14 | 3 | portar; `line_breaker.cc` 139 y `inline_layout_algorithm.cc` 108 líneas de delta: fusión a mano |
| B4 Rendimiento/diagnóstico | `ScrollableAreaOptimization` (fusiona dos flags que FW no tiene), `UseStyleRuleMapForSelectorStats`, `ValidationBubbleNoForcedLayout`, `SpatNavUsesCursorInheritance`, `FindNested/OrphanAnnotationFix` (fragmentos de texto: apagados en FW, decisión 30-10) | — | 0 | **aplazar/no portar** (sin cara web, o fuera por decisión) |
| B5 Reversiones que afectan al 136 ya portado | `TableIsAutoFixedLayout` stable→**test** (775fc95e0, 16-05: «probablemente no es web-compatible»; FW lo puso stable en 597b30b0); `SvgInlineRootPixelSnappingScaleAdjustment` stable→test (6d37c99ac; FW no lo tiene); `XMLSerializerConsistentDefaultNsDeclMatching` test (16397892b; FW no); 2314193e6 «Revert Use Original DOM text…» y 94a35984f «Revert ShapeResultRun» (comprobar si FW los llevó); d36d9a59a desactiva `DelayStopForMediaElementSourceNode` | — | 0,3 | **hacer ya**: pasar `TableIsAutoFixedLayout` a test en el parche de FW |
| B6 CSS math/anchor | `css_math_expression_node.cc` 530 líneas: 75afc91d4, fb4a7683f, 10da5d634, 36c6ec211 (`log()`), 69e2e4a30; anchor/OOF 71+69 líneas | — | — | ya cubierto por el cruce wpt-137 (2afdbe36 portó 69e2e4a30, 69b4d66dc; saltó 10da5d634/fb4a7683f por falta de infraestructura de nodos suma/producto) |
| — | Nuevos `experimental/test`, **no entran**: `CSSSiblingFunctions` (`sibling-index()` sigue exp; sale en el 138), `CSSGapDecoration` (`rule-*`, test), `CSSMasonryLayout` (`item-tolerance`, test), `CSSAlignBlockAndInlineOutOfFlows` (400916929), `CustomizableSelectInPage`, `CanvasElementDrawImage`/`CanvasPlaceElement`, `IgnoreLetterSpacingInCursiveScripts`, `SvgScriptElementAsyncAttribute`, `ScopedCustomElementRegistry` (exp, `customElementRegistry`, `importNode(…, options)`), `NavigateEventCommitBehavior`, `HTMLInterestTargetAttribute`, `HeadingOffset`, `AnimationTrigger`, `ScrollTimelineNamedRangeScroll`, `PreloadLinkRelDataUrls`, `MulticolColumnWrapping` | — | 0 | no entran |

Limpiezas que fuerzan estado en FW (S): `WebAnimationsSVG` (128: exp) desaparece con 4 commits de limpieza (ca0155841…): FW queda con el camino nuevo siempre encendido; `FastPathSingleSelectorExactMatch`, `QuickIntensiveWakeUpThrottlingAfterLoading`, `XMLParserMergeAdjacentCDataSections`, `FluentScrollbarUsesNinePatchTrack` (stable en 128) pasan a código fijo, sin cambio de comportamiento.

## 4. Filas aplazadas del 136: ¿qué cambia en el 137?

| Fila | Estado 137 | Cambio 136→137 (V diff) | Horas | Nota |
|---|---|---|---|---|
| `PartitionVisitedLinkDatabaseWithSelfLinks` y cadena :visited | stable (iOS off) en 136 y 137 | 137 añade 9892a3924 (`initiator_origin` en vez de `referrer`, bug 411157351) y a4000d4d3 (IDs bajos de `-internal-forced-visited`); `visitedlink_writer.cc` solo `std::to_array` | 0 | **YA PORTADO** en b832524c (V `git log nube/motor-137`): cadena 128→137 de 14 commits, incluidos esos dos. Queda: `kPartitionVisitedLinkDatabase` sigue `DISABLED_BY_DEFAULT` también en Chrome 137 (V `features.cc:2036`); todos los usos son `kPartitionVisitedLinkDatabase \|\| …WithSelfLinks` (V), por lo que el flag stable basta. `chrome://flags` no se porta |
| F12 `AudioContext` `interrupted` | stable (136 y 137) | `audio_context.cc` 85 líneas (SetSinkId/cierre) | 0,8 | sigue aplazado: en macOS el sistema nunca lo dispara (S) |
| F15 `LayoutMinSizeIndefinite` + imagen rota 1:1 | stable | `length_utils.cc` 16 líneas, `layout_replaced.cc` 20; 4dee7a268 (min-size de select personalizable en flex/grid) | 2,5 | coste igual al del 136 |
| F17 `RoundScrollOffsets` | stable | `paint_layer_scrollable_area.cc` 113 líneas, `scrollable_area.cc` 25 (V); sin commit con el nombre del flag en el log | 3 | peor que en el 136 (+0,5 h por el delta); prueba visual |
| `SplitCacheByCrossSiteMainFrameNavigationBoolean` | sin flag en json5 | es de `net/` (fuera de Blink) | — | para el inventario de net |
| d63e50b22 (nodos de compositor de anchor) | — | `anchor_evaluator_impl.cc` 71 líneas, `out_of_flow_layout_part.cc` 69 | — | caso raro, igual |
| Observable | stable | `observable.cc` +2 líneas, `subscriber.cc` 0 | 3–4 | igual que antes |
| FetchLater | sin flag | `fetch_later_util.cc` 0 | 2–3 | igual |
| Select personalizable | `CustomizableSelect`, `SelectParserRelaxation`, `InputClosesSelect` stable | `html_select_element.cc` 86 líneas, `select_type.cc` 52, `html_option_element.cc` 147, `html.css` +268 (V); `SelectColorsRemoveImportant` desactivado en M137 (96c6fbc8e) | 5–9 (+1) | un poco más |
| Carousel (`::scroll-marker/-button`, `::column`) | stable | `scroll_button_pseudo_element.cc` 102 líneas, `scroll_marker_group_data.cc` 5; 5a1e287f4 (a11y: des-anidar group/botón) | 9–13 | igual |
| `moveBefore` | `AtomicMoveAPI` desaparece (shipped) | solo `MeasureAs=kMoveBefore` en el IDL (V) | 0 | ya portado en el 136 |

## 5. Privacidad y huella (regla 20; referencia Brave 1.79)

**Proponer apagar / dejar fuera:**
1. APIs de IA de Google: `AIPromptAPI*`, `AIRewriterAPI*`, `AISummarizationAPI*`, `AIWriterAPI*`, `TranslationAPI*`, `LanguageDetectionAPIForWorkers`, `BuiltInAIAPI` (todas pasan `test`→`experimental`; IDL `ai.idl`, `language_model*.idl`, `summarizer.idl`, `translator.idl`…). FW no enciende experimental (V), así que quedan apagadas; **no portar nada** y mantener los flags fuera del parche. Renombres 137: `AIAvailability`→`Availability`, `AICreateMonitor`→`CreateMonitor`.
2. `DocumentPolicyIncludeJSCallStacksInCrashReports` (stable): pilas JS en informes de caída; dejar apagado.
3. Privacy Sandbox: `FledgeBiddingAndAuctionServerAPIMultiSeller`, `RelatedWebsitePartitionAPI`, `SharedWorkerExtendedLifetime`, `BrowserInitiatedAutomaticPictureInPicture`, `LocalNetworkAccessPermissionPolicy`, `DeviceAttributesPermissionPolicy`, `SecurePaymentConfirmationAvailabilityAPI`, `WebXRDepthPerformance`: fuera.
4. WebGPU: `GPUAdapterInfo.subgroupMinSize/MaxSize` pasan a incondicionales y `powerPreference` (exp) añade más datos de adaptador = huella; WebGPU fuera.
5. `PublicKeyCredential.getClientCapabilities()` pasa a incondicional (`WebAuthenticationClientCapabilities` eliminado): expone qué autenticadores soporta el navegador (huella leve). **Dudoso**: proponer dejarlo tras flag apagado si FW lleva WebAuthn.
6. Canvas `float16` / `ImageData.pixelFormat` (A06): dudoso (ver §2).
7. `PlainTextPainter`/CanvasTextNG: no portar (rendimiento).
8. Reporting de `Permissions Policy` (136, F11): sigue aplazado.

**Candidatos a portar por privacidad (a favor):**
- `kEnforceNoopenerOnBlobURLNavigation` (DISABLED→**ENABLED** en 137): impone `noopener` a navegaciones a blob: de otro sitio. 12a036755 (+11 líneas en `local_dom_window.cc`, flag) y d38e87a3f (`html_anchor_element.cc`, 6 líneas). Ausente en 128. **0,5 h, portar**.
- Particionado de Blob URL (9aae7ac7f «Launch Blob URL partitioning», 30-04, cherry-pick a M137): 27 commits 128→137 que casan con «Blob URL … partition»; el código está en `content/browser` (`render_frame_host_impl.cc`, workers) y `switches` de Blink; **fuera de Blink, pasar al inventario de content**. Privacidad: a favor.
- `ReduceScreenSize` (NUEVO, sin estado, `base_feature`; ahora con `screenX/Y`=0 en `local_dom_window.cc`, `Screen.isExtended`, `colorDepth`, `device-*` media queries; 8e459a3df, 7c1e2b5be, 790793200 + el núcleo del flag que no sale por asunto): limita `screen.*` al tamaño del viewport salvo permiso de Window Management. Es **más privado que Brave** (S: Brave lo farblea en modo estricto, no lo limita). Coste ~2 h; riesgo de compatibilidad (sitios que leen `screen.width`). **Decisión de Titín**.
- `ReduceUserAgentDataLinuxPlatformVersion`: solo Linux, no aplica.

**Revisadas y sin huella nueva:** `if()`, `reading-flow`, `match-element`, Ed25519, `getComposedRanges`, SVG, edición.
**Retrocesos de Chrome por huella (no tocar):** `bac0aa199` «Expose screenPixelRatio by default» revertido por bea577c91; `20e7aebf3` WebCodecs orientation revertido por 49d5e7b21.

## 6. Finch (`base::Feature` de `third_party/blink`, cambios de valor 136→137, V con `feat.py`)

Solo hay **1 cambio de valor**: `kEnforceNoopenerOnBlobURLNavigation` DISABLED→ENABLED (ver §5).
Nuevas: `kWorkerThreadSequentialShutdown` ENABLED (cierre secuencial de hilos de worker; estabilidad; S: relacionado con carreras al cerrar, mirar en regla 17), `kIdbDecompressValuesInPlace` ENABLED (rendimiento IDB); DISABLED: `kClearSiteDataPrefetchPrerenderCache`, `kCrashReportingAPIMoreContextData`, `kForceOffTextAutosizing`, `kOptimizeHTMLElementUrls`, `kSecPurposePrefetchHeaderRelPrefetch`, `kWebAppEnableScopeExtensionsBySite`, `kDomStorageAblation`, `kCacheStorageAblation`, `kDelayStopForMediaElementSourceNode` (d36d9a59a), `kPropagateEnabledEventForWebRtcAudioTrack`, `kNoSamePageFragmentPreloadingAnchorTracking`; `kDisplayAudioCaptureKillSwitch` ENABLED (0730fdc14).
Eliminadas (código fijo, ya ENABLED en 128 salvo la primera): `kOptimizeLoadingDataUrls` (en 128 DISABLED → ahora siempre on, rendimiento; 1 h si se quiere), `kServiceWorkerClientIdAlignedWithSpec` (128 ENABLED), `kSimplifyLoadingTransparentPlaceholderImage`, `kUnpremultiplyAndDitherLowBitDepthTiles`, `kIgnoreInputWhileHidden` (0cafb3a6f lo deshabilita), `kAdjustCanCreateCanvas2dResourceProvider`.
Flags del json5 con `base_feature` cuyo estado cambió: ninguno relevante para Mojave. Cambios de `origin_trial_feature_name` (`MediaPlaybackWhileNotVisiblePermissionPolicy`, `RenderBlockingFullFrameRate`): irrelevantes.

## 7. IDL (V: `idl-diff.txt`)

**55 `.idl` cambiados** (50 modificados, 3 nuevos —`import_node_options.idl`, `availability.idl`, `create_monitor.idl`—, 2 retirados por renombre). Con cara web en stable o que pasan a stable/incondicional:
- `ImageData.pixelFormat`, `ImageDataSettings.pixelFormat` (`rgba-unorm8`/`rgba-float16`), `ImageData(Float16Array, …)`, `getContextAttributes().colorType` (A06).
- `Selection.getComposedRanges` ya estaba (flag stable ahora).
- `PublicKeyCredential.getClientCapabilities` incondicional; `GPUAdapterInfo.subgroupMinSize/MaxSize`; `GPUCommandEncoder.copyBufferToBuffer` 2 sobrecargas (WebGPU, fuera).
- `ImageCapture` pasa a `[SecureContext]` (restringe: bien).
- Nombres/atributos de medida: `moveBefore` `MeasureAs=kMoveBefore`; `requestAnimationFrame` en worker con `MeasureAs`; `InputEvent`/`MediaStream` sin `CallWith=Isolate` (V8 interno; **ojo con el generador de bindings**: `CallWith=Isolate` retirado en 3 IDL).
- Detrás de flags no stable (no entran): `Element.customElementRegistry`, `Document.importNode(node, options)`, `CustomElementRegistry.initialize()`, `HTMLTemplateElement.shadowRootCustomElementRegistry`, `NavigationTransition.committed`, `SharedWorker.extendedLifetime`, `HTMLPermissionElement.isTypeSupported`, `SVGScriptElement.async`, `SpeechRecognition.phrases`/`SpeechRecognitionPhraseList`, `PaymentRequest.securePaymentConfirmationAvailability`, `XRDepthStateInit`, interfaces de IA.
- Sobrecargas/V8: no hay nuevos IDL con dos sobrecargas rápidas fuera de WebGPU.

## 8. Candidatos regla 17 (V la existencia del commit; gravedad por cruzar con CVE; solo por asunto)

Rama 137 (cherry-picks): 17f1fd9c7 (IDs generados de nodos XML) + d74c2cfea/e58d93d2a/7d9a3e738/c1b5f4537 (libxml/libxslt: structs y UBSAN, **seguridad probable**), b46d98d81 (carrera del singleton de fábrica IDB), 21a3db719 (caída en `GpuCanvasContext::PaintRenderingResultsToCanvas`), ead43ea4d (optimizaciones de procesado de URL del documento), 79b5a317b (`ComputeScrollIntoBehavior` con device-scale-factor), b94900304 (curva de scroll programático).
Main: e423ccef7 (nullptr en Range), 01c7c1b09 (caída en `AddToTopLayer`), 33d2ddbb9 (DCHECK de `HTMLCanvasElement::Paint` con OffscreenCanvas), a83881e2d (sticky + container queries), 88a83e3a4 (caché de intrínsecos), d7020222f (bucle infinito en `InlineLayoutAlgorithm::Layout`), 8552f4419 (invalidación de reglas anidadas insertadas), 08bd445f4 (CHECK de invalidation tracing), 4646a17d3 (CHECK de IME en Mac), 5fdce0873 y 79799243b (CDM clear key), acb2f3568 (bloqueo de puertos de localhost, net).
Áreas a vigilar para SEGURIDAD-PORTES tras el 137: `core/css/parser` (if()), `core/page/focus_controller.cc` (reading-flow), `core/editing/*`, `core/layout/inline/*`, `modules/canvas/*`, libxml/libxslt (`third_party/libxml`, `libxslt`).

## 9. Orden propuesto y horas (reales, S; papel ≈ 4×)

1. **Flips y reversiones** (A05 Ed25519, A08, B5 `TableIsAutoFixedLayout`→test, C blob noopener, A04 shape(), A03 VT): ~3,5 h.
2. **A01 `if()`**: 3,5 h (aislado, sin dependencias nuevas).
3. **B1 SVG + B2 edición + B3 layout/texto + A07 getComposedRanges**: 8 h (los de layout, con prueba visual; fusiones a mano en `line_breaker`/`inline_layout_algorithm`).
4. **A02 reading-flow**: 4,5 h (con regla 17: FS de foco).
5. Regla 17 (§8) fuera de las filas anteriores: 1,5 h.
**Total delta propio ≈ 21 h** (papel ≈ 85 h). `motor-137.html` debería probar: `if(media()…)`, `if(style()…)`, `if(supports()…)`, `reading-flow`/`reading-order`, `view-transition-name: match-element`, `offset-path: shape()`, `crypto.subtle` Ed25519 (generateKey/sign/verify/JWK), `getSelection().getComposedRanges()`, caret en línea ajustada, `<use>` a documento externo.
Opcionales (Titín): A06 canvas float (2,5 h), `ReduceScreenSize` (2 h).
Aplazadas del 136 (coste sin cambio salvo lo indicado): F15 2,5, F17 3, F12 0,8, Observable 3–4, FetchLater 2–3, select 6–10, carousel 9–13.
Con todo lo aplazado y opcional: ~55–70 h.

### Inventario V8 para el nivel 137 (MOTOR-37, solo lectura)

### Inventario V8 para el nivel 137 (solo lectura; V = verificado, S = supuesto)

Trabajo: clon `/home/user/v8` (tree:0), worktrees `/home/user/v8-136` (5297e56d) y `/home/user/v8-137` (075234cf), ambos **limpios**. Scripts y listas en `/home/user/scr/` (`chk.sh`, `r136.txt`, `r137.txt`, `api.diff`, `src.diff`, `flags.diff`). Chromium: `/tmp/claude-0/port/cr128`, `cr136`, `cr137` (cr137 = 137.0.7151.122, su DEPS fija v8_revision 075234cf).

#### 1. Versión
- V: **V8 13.7.152.17 = 075234cf3d7622d9d588a6f748fc4501aa23080c** (12-06-2025). No es LTS. 13.6.233.10 y 13.7.152 salen del mismo punto de main (f6be4827a, 31-03-2025); 13.7.152 se corta de main el 27-04.
- V: **390 commits** de 13.6.233.10 a 13.7.152.17 (`git log`); = 356 de main (31-03 a 27-04) + 18 commits `Version` (152 a .17) + **16 propios de la rama**: 13 `Merged:` y 3 de infra. Los 13: wasm CanonicalEquality::EqualValueType, wasm Liftoff zero-extension i32, regexp EscapeRegExpSource uint32_t, wasm JSPI SBXCHECK, **turbofan** Smi->Word64 zero-extension, **turbofan** store-store alias analysis, **turboshaft** late-load-elim alias, turbofan simplified lowering boolean, maglev CheckMaps tipo imposible, serializer ObjectTemplateInfo a RO, wasm deopts desactivados en plataformas no soportadas, 2 de bots Mac.
- V: **hay más puntos**: `13.7.152.18` (intl: fatal a excepción) y **`13.7.152.19`** (26-06-2025, `4278d6d37` «interpreter: no elidir hole checks en optional chain»; arreglo de seguridad probable). Chromium 137.0.7151.122 solo lleva hasta .17. Recomiendo fijar en .17 (nivel = Chromium 137) y portar .18/.19 como arreglos (2 parches pequeños, 0,3 h; S).
- Por área (asunto, 390): wasm 74, maglev 22, turbofan 17, turboshaft 3, sandbox 8, Revert 13.

#### 2. patches/v8 (256 `.patch`) sobre 13.7.152.17 (`git apply --check`, `-R --check`, `--3way` en worktree temporal ya borrado)
Control: los 256 aplican limpios sobre 13.6.233.10. Sobre 13.7: **231 limpios, 14 ya dentro, 11 no aplican**.

- **Ya dentro (se sueltan, 14; `-R --check` OK):** `src-compiler-representation-change.cc`, `src-compiler-simplified-lowering.cc` (merges de turbofan), `src-compiler-turboshaft-snapshot-table-opindex.h`, `src-compiler-turboshaft-store-store-elimination-phase.cc` (572dfe2ea), `src-objects-js-regexp.cc` (59579e020), `src-wasm-baseline-liftoff-assembler.cc` (3efc4f0f8), `src-wasm-canonical-types.h`, `src-wasm-value-type.h` (018d184a7), y los tests `test-mjsunit-maglev-regress-413419840.js`, `test-mjsunit-regress-413800519.js`, `test-mjsunit-turboshaft-regress-417169470-{1,2,3,4}.js`.
- **3-way sin conflicto (5):** `compilation-dependencies.cc`, `frame-states.h`, `ic.cc` (contexto movido); `late-load-elimination-reducer.cc` (**su hunk 1 «Wiping all maps» ya es upstream** en 13.7: el 3-way lo absorbe, queda el resto: `InvalidateAllNonAliasingInputs`, `WipeAllMaps()`, `InvalidateAllMaps()`; revisar que no quede duplicado); `flag-definitions.h` (Maglev off, untagged_phis off, quitar `compact_code_space_with_stack`; el `turboshaft_trace_load_elimination` READONLY ya es upstream, no se duplica; V: un solo `DEFINE` por rama de `#ifdef DEBUG`).
- **Conflicto real (6 ficheros, 5 de ellos pequeños), a mano:**
  1. `src-builtins-wasm.tq`: upstream cambió `tail GetPropertyWithReceiver` por `return GetPropertyWithReceiver`; nuestro parche borra todo el builtin `WasmGetOwnProperty` (pasa a CSA). Basta regenerar contra el bloque nuevo (0,1 h). V: `WasmGetOwnProperty` sigue usado en liftoff-compiler.cc y turboshaft-graph-interface.cc.
  2. `src-codegen-compiler.cc`: hunk de `BackgroundMergeTask::BeginMergeInBackground`. 13.7 ya hace `Tagged<ScopeInfo> info = old_sfi->scope_info(); if (!info->IsEmpty()) new_sfi->SetScopeInfo(info); else if (old_sfi->HasOuterScopeInfo()) ...set_outer_scope_info(old_sfi->GetOuterScopeInfo())`. Hay que dejar la rama `else` con nuestra lectura única `TryGetOuterScopeInfo()` (que añade nuestro parche de `shared-function-info{.h,-inl.h}`; V: no existe en upstream). El hunk 1 (`ConstantPoolPointerForwarder`, `scope_info(kAcquireLoad)`) y el de `GetFunctionFromEval` aplican. 0,3 h.
  3. **`src-compiler-turboshaft-pipelines.{h,cc}` y `src-compiler-pipeline.cc` (guarda de 4 KB, port de ea2f03dfff): upstream rehízo el pipeline** (13.7 añade cancelación: macros `RUN_MAYBE_ABORT`, `Run<>` devuelve `bool`, `AllocateRegisters(...)` ya es `bool` con `V8_WARN_UNUSED_RESULT` y todos los llamadores comprueban). `pipeline.cc` **se suelta** (V: línea 494 ya hace `if (!...AllocateRegisters(...)) return false;`). De `pipelines.{h,cc}` solo hay que conservar el bloque nuevo tras `RUN_MAYBE_ABORT(AssignSpillSlotsPhase)`: `constexpr int kMaxStackSlots = 4*KB/kSystemPointerSize; if (data_->info()->IsOptimizing() && data_->frame()->GetTotalFrameSlotCount() > kMaxStackSlots) { AbortOptimization(kFunctionTooBig); ClearRegisterComponent(); return false; }`, pero **antes de `CommitAssignmentPhase`** y con el mismo tipo `bool` (ya no hace falta cambiar firmas). ~0,5 h. S: `info()->AbortOptimization` coexiste con `was_cancelled()` (comprobar en mjsunit `regress-574660146`).
  4. `src-compiler-turboshaft-store-store-elimination-reducer-inl.h`: aplican `InvalidateBasesInRange` y el cambio de bucle (V: `InvalidateBasesInRange` no está en upstream; sí está el `MarkAllStoresAsObservable` para loads con índice y el renombrado `is_fixed_offset_store`). Falta solo la línea `eliminable_stores_->erase(index);` dentro de `if (is_on_heap_store && is_fixed_offset_store)`. 0,1 h.
- V: ningún fichero movido o borrado. V (comm de identificadores): **todo identificador que añaden nuestras líneas `+` sigue existiendo en 13.7** (0 desaparecidos). Los parches de Maglev (16) aplican limpios; Maglev sigue apagado (ver 4). El de cppgc (`include-cppgc-visitor.h`) aplica.
- S: 231 «limpios» no garantizan que no haya hunks medio-duplicados con las 13 fusiones de la rama (p. ej. `Dead` post-hoc); revisar con mjsunit en la `d8`.
- Época de caché: V: `src-utils-version.h.patch` hoy `kFlyWebCacheEpoch = 26` -> **27**.
- Nuevos fusionados que cubren cosas nuestras: V: ver los 14 «ya dentro». Nada de seguridad Wasm/JSPI nuevo que no tengamos, salvo .18/.19 de arriba.

#### 3. include/ 13.6 -> 13.7 y Blink/gin 128 (V: `diff -ru include` completo, 476 líneas; grep sobre cr128; comparación cr136 vs cr137)
- **No rompe nada de gin/Blink 128** (V). El CppHeap del 136 queda como está; `CreateParams` sin cambios.
- Quitado: `JavaScriptCompileHintsMagicEnabledCallback` y `Isolate::SetJavaScriptCompileHintsMagicEnabledCallback` (V: cr128 no los llama; solo `gin` pasa `--compile-hints-magic` si la feature está sobreescrita, y ese flag ya falta desde 13.6). Chromium 137 migró `v8_code_cache.cc`/`v8_compile_hints_common.h` a `kFollowCompileHintsPerFunctionMagicComment` (V: la opción ya existe en 13.6); es cambio de Blink, no obligatorio.
- `V8Inspector::connect` pasa de virtual con cuerpo a **puro** y se añade `connectShared` puro: solo lo implementa V8 (V: Blink 128 `devtools_session.cc:186` y `os_devtools_agent.cc:48` solo llaman a `connect`; vale).
- Añadido sin romper: `Isolate::Deinitialize()` / `Isolate::Free()` (`Dispose()` sigue igual), `Isolate::ValidateAndCanonicalizeUnicodeLocaleId` (lo usa Blink 137 `ai_utils.cc`, no 128), `Symbol::GetDispose/GetAsyncDispose`, `Data::IsCppHeapExternal` + nuevo `v8-cpp-heap-external.h`, `cppgc/tagged-member.h` (Blink 137 `member.h` lo incluye: solo si se porta ese cambio de Blink), `PageAllocator::ResizeAllocationAt` (virtual con `return false`: gin no lo reimplementa; V8 usa `resize_large_object` solo si lo soporta), `ObjectTemplate::SealAndPrepareForPromotionToReadOnly`, `kGarbageCollectionReasonMaxValue` 29->30.
- Deprecaciones «pronto»: los typedef `Generic*PropertyXxxCallback` e `IndexedProperty*Callback` (sin V2) pasan a `V8_DEPRECATE_SOON`; `v8_imminent_deprecation_warnings = true` en el BUILD de V8. V: gin 128 (`object_template_builder.cc`) y los bindings (`v8::Intercepted`, V2) **ya usan los tipos nuevos**; sin avisos que rompan.
- Tags de `ExternalPointerTag` reordenados (`kFirstInterceptorInfoExternalPointerTag`...) y offsets: recompilar todo Blink (nada que tocar).
- **CHECK nuevos de `api.cc` alcanzables por el embedder (lección a):** V: diff de 421 líneas; solo `ApiCheck` en `CppHeapExternal::Cast` (API nueva que 128 no usa) y en `Isolate::Deinitialize` (isolate no entrado) + un DCHECK interno. **Ninguno que provoquen los IDL de la 128.**
- **Qué hizo Chromium 137 (V: cr136 vs cr137 diff):** `gin/v8_initializer.cc` y `gin_features.*` **idénticos**; `thread_state.*`, `worker_backing_thread.cc`, `v8_initializer.cc` de Blink **idénticos**. Solo cambios de higiene de handles: `gin::ContextHolder::~ContextHolder` = default (el destructor necesita un `HandleScope` del llamador) y `PerContextData::~PerContextData` ya no crea el suyo; `gin/shell_runner.cc` abre `HandleScope`; **`ScriptState::DisposePerContextData()` añade `v8::HandleScope scope(GetIsolate());`**. S: en gin 128 el `HandleScope` propio sigue ahí, así que no hace falta; conviene copiar la línea de `script_state.cc` (0,1 h).
- Flags que pasa la 128 (90 cadenas `--...` de gin/content/Blink): V: comparado con `flag-definitions.h` + `wasm-feature-flags.h` de 13.6 y 13.7; **solo se pierde `--update-allocation-limits-after-loading`** (la pasa gin 128 si `V8UpdateLimitAfterLoading` está sobreescrita; FlyWeb no tiene field trials: sin efecto; quitar la línea de gin 0,1 h si se quiere). Gin 137 ya no la tiene.

#### 4. Flags JS/Wasm y Regla 19
- V: **no hay funciones JS nuevas en 13.7.** Las listas `JAVASCRIPT_*_FEATURES` son idénticas a las de 13.6: shipping = duplicate_named_groups, modifiers, `Promise.try`, `Atomics.pause`, **`Error.isError`** (ya shipping en 13.6, así que FlyWeb lo tiene desde el 136; en 137 Blink solo cambia el contador `kDRAFT_ErrorIsError` -> `kIsError`), `RegExp.escape`; staged = `js_explicit_resource_management`, `js_float16array`, `remove_intl_locale_info_getters`. V: gin 137 enciende `--js-float16array`, `--js-explicit-resource-management`, `--js-regexp-escape` y FlyWeb ya las tiene (`patches/gin-v8_initializer.cc.patch`). Nada que añadir.
- **Wasm: tres características pasan a «shipping» (flag a true)**: `branch_hinting` (Wasm), `exnref` (excepciones nuevas) y **`jspi`** (V: `wasm-feature-flags.h`). V8 consulta `Isolate::IsWasmJSPIRequested`: callback de Blink **o** `v8_flags.experimental_wasm_jspi`, y ahora el flag es `true` por defecto, así que **JSPI queda encendido en todas las páginas** (en Blink 128/137 el callback devuelve false pero el flag lo activa). Decisión de producto/seguridad para SEGURIDAD-PORTES: aceptar (Chrome 137 lo lleva y es el criterio de la regla 19) o añadir `SetV8Flags("--no-experimental-wasm-jspi")` en gin (1 línea). FLYWEB-SECURITY ya cubre los arreglos JSPI de 13.5. Mojave: JSPI usa pilas propias con `mmap` (S: sin APIs de macOS nuevas; probar `wasm/jspi` en la 5,1/Mojave).
- Otros cambios de defaults de producción (V: diff `flag-definitions.h`, 304 líneas): **`wasm_deopt` false -> true** (excepto plataformas exóticas), `wasm_deopts_per_function_limit` 50 -> 10, **`wasm_inlining_call_indirect` false -> true** (inlining especulativo de call_indirect: superficie de JIT nueva), `script_context_cells` (reemplaza `const_tracking_let` + `script_context_mutable_heap_*`, true), `resize_large_object` (true), `scavenger_conservative_object_pinning` pasa a `DEFINE_BOOL` false, desaparecen `separate_gc_phases`, `force_marking_deque_overflows`, `update_allocation_limits_after_loading`, `const_tracking_let`. Nuevos con false: `cache_property_key_string_adds`, `managed_zone_memory`, `discard_memory_pool_before_memory_pressure_gcs`, `wasm_allow_mixed_eh_for_testing`; `wasm_explicit_prototypes`/`wasm_implicit_prototypes` true pero exigen `experimental_wasm_custom_descriptors` (apagado). `conservative_stack_scanning` pasa a depender de `V8_ENABLE_DIRECT_HANDLE` (apagado: `v8_enable_direct_handle = false`; nadie en FlyWeb ni en build.sh usa `v8_enable_conservative_stack_scanning`, que desaparece del GN; V: grep sin resultados).

Tabla de lo apagado por FlyWeb (regla 19):
| Opción | FlyWeb | 13.7 upstream | Nota |
|---|---|---|---|
| `maglev` | **false** (parche) | true | Chrome lo usa; ~22 commits de Maglev en 13.7 (6 son arreglos: tipos, constant-folding de typed array, write barriers en código muerto); sigue la deuda; Maglev, tope el nivel 134 (decisión Titín 27-10, ya vencida: COORDINACIÓN debe decidir) |
| `maglev_untagged_phis` | **false** (parche) | true | CVE-2026-3910; igual que en 13.6 |
| `maglev_inline_api_calls` | — | false | sin cambio (el parche borra su implicación con `compact_code_space_with_stack`) |
| `turbolev` | — | false (`turbolev_future` experimental) | sin cambio |
| `typed_array_length_loading` | encendido | true | sin cambio |
| `turbo_elide_frames` | — | true | desde 13.6 |
| `minor_gc_task_with_lower_priority` | — | true | desde 13.6 (gin ya tiene `user_visible_task_runner`) |
| `wasm_deopt` / `wasm_inlining_call_indirect` | — | **true / true** (nuevos en 13.7) | recomendado: aceptar (regla 19); S: mjsunit/wasm y FlyWeb 9/9 |
| `jspi` | — | **true** (nuevo) | ver arriba |
| `compact_code_space_with_stack` | quitado del flag | true | el parche sigue aplicando |

#### 5. Riesgos Mojave/AVX
- (b) V: `platform-darwin.cc`, `platform-posix.cc`, `mutex.cc` **idénticos**; `src/base` solo cambia `cpu.{h,cc}` (campos ARM64 sha3/hbc/cssc, un `sysctlbyname("hw.optional.arm.FEAT_SHA3")` solo en `V8_HOST_ARCH_ARM64`), `time.h` (`<=>` C++20; compilador de la 128 lo admite), numerics (`safe_conversions*.h` movidos a `src/base/numerics/`, en BUILD.gn; ningún parche nuestro los toca), `region-allocator`, `bounded-page-allocator`. Sin `os_unfair_lock*`, `__builtin_available`, `weak`, `MAP_JIT` nuevos; los `dlsym` (memfd_create, pthread_setname_np) son anteriores. `libplatform`: solo `NonNestableDelayedTasksEnabled()` en la cola por defecto (gin usa la suya). `perf-jit.cc` ahora vale en Darwin (flag `perf_basic_prof` apagado). `trap-handler`: añade ARM64, x64 igual.
- (c) V: ningún `-mavx`/`-mavx2` ni nuevo uso fuera de `IsSupported(AVX)` / `CpuFeatures::IsSupported(AVX2)` (x64 instruction-selector: 6 usos nuevos, todos con la guarda; `objects/simd.cc` despacha en ejecución). `simdutf` despacha por CPU en ejecución; **`json-stringifier.cc` usa highway** (como en 13.6; sin cambios en la parte de ISA; S: probar en la 5,1 `JSON.stringify` rápido, igual que 13.5/13.6).
- **simdutf: SÍ hay que subir (a diferencia del 136).** V: 13.7 añade en `builtins-typed-array.cc` el uso `simdutf::atomic_binary_to_base64` y `OUTPUT_BUFFER_TOO_SMALL` en `toBase64/fromBase64` (se compila aunque `js_base_64` esté apagado). V: la simdutf vendida en `patches/third_party-simdutf-*` es **6.0.2 y no tiene `atomic_binary_to_base64`** (0 coincidencias); la de Chromium 136/137 y el DEPS de V8 13.7 (62d1cfb6) es **6.4.0** (`simdutf.h` idéntico en 40d1fa26 y 62d1cfb6: 240.473 bytes; `simdutf.cpp` 2,72 MB). Hay que regenerar `third_party-simdutf-simdutf.{h,cpp}.patch` (+README/BUILD.gn) a 6.4.0 (1 h). Sin esto no compila.
- Lección (a)/(CppHeap): sin nuevos CHECK.
- Otras DEPS de V8 (V: `diff DEPS`): simdutf (arriba), partition_alloc_version, icu, abseil, test262 cambian (los trae Chromium o son de pruebas); fast_float y highway: iguales; sin dependencia nueva.

#### 6. Época de caché de código
V: 13.7 cambia versión y el hash de flags (flags nuevos, desaparecen otros, `jspi/branch_hinting/exnref` encendidos) (S: también habrá cambios de bytecode; p. ej. 4278d6d37 en .19): **subir `kFlyWebCacheEpoch` de 26 a 27** (S: si se porta además .18/.19, la misma 27).

#### 7. Horas reales (de papel ÷4) y trabajo
- Fijar 13.7.152.17 + `FlyWeb/v8-revision` + FLYWEB-SECURITY.md + época 27: 0,5 h.
- Parches: 5 de 3-way limpio 0,3 h; a mano (wasm.tq 0,1, compiler.cc 0,3, pipelines ×3 0,5, store-store 0,1) 1,0 h; soltar 14: 0,2 h; regenerar los ~242 restantes con `v8regen.sh` y repasar: 1 h. **~2,5 h.**
- simdutf 6.0.2 -> 6.4.0 (regenerar parches de 2,4 MB): 1 h.
- Blink/gin: `HandleScope` en `ScriptState::DisposePerContextData` 0,1 h; quitar `--update-allocation-limits-after-loading` 0,1 h; decisión JSPI (flag en gin) 0,1–0,3 h. **~0,5 h.**
- .18/.19 (opcional, 2 parches): 0,3 h.
- `d8` nube 13.7 + parches + mjsunit completo y FlyWeb 9/9: 3 h de reloj (~1 h atendidas); atención extra a `mjsunit/wasm/jspi*`, `wasm/deopt*`, `regress-574660146`.
- **Total ≈ 5–6 h reales para V8 + pegamento** (menos que el 136: sin cambio de API de CppHeap), riesgo medio solo en JSPI/wasm_deopt activados.

Identificadores que el porte mete o necesita (para `grep -w` contra v8-137):
`TryGetOuterScopeInfo` (0 en upstream: lo añade nuestro parche SFI), `SetScopeInfo` (4), `HasOuterScopeInfo` (18), `scope_info(kAcquireLoad)`, `kFunctionTooBig` (2), `AbortOptimization`, `GetTotalFrameSlotCount`, `ClearRegisterComponent`, `kMaxStackSlots`, `RUN_MAYBE_ABORT`, `InvalidateBasesInRange` (0), `MarkAllStoresAsObservable` (1), `eliminable_stores_`, `is_fixed_offset_store`, `WipeAllMaps` (0), `InvalidateAllMaps` (0), `InvalidateAllNonAliasingInputs` (3), `TypedArrayLength_string` (2), `live_edited` (4), `out_has_stack_overflow` (2), `ClearKeyAndValueIfKeyIsDead` (0; lo añade el parche cppgc), `kReturnUndefined` (7), `AllocateInSharedHeap` (2), `kFlyWebCacheEpoch`, `atomic_binary_to_base64`, `OUTPUT_BUFFER_TOO_SMALL`, `experimental_wasm_jspi`, `wasm_deopt`, `wasm_inlining_call_indirect`, `script_context_cells`, `connectShared`, `Isolate::Deinitialize`, `kIsError`.

# Nivel 137, inventario «fuera de Blink» (cr136 -> cr137), solo lectura

MOTOR (subagente de lectura), 30-10-2026. Marcas: **V** verificado en código o historial; **S** supuesto.
«Portar» = traer a la 128 el cambio de comportamiento observable de Chrome 137. Blink y V8 los hacen otros subagentes.

## 0. Tags y fuentes

- Intervalo `136.0.7103.116 .. 137.0.7151.122` (V). `.122` es el tag que declara el nivel.
- DEPS 136 -> 137 (V, `DEPS` de `cr136`/`cr137`): BoringSSL `a9993612` -> `918cf66e` (62 commits), QUICHE `5077431b` -> `faec2063` (23),
  ANGLE `fa40b7c5` -> `df9c59dc` (185), Skia `bcce46ca` -> `0dfd95a4` (223), Dawn `1cffe7ec` -> `fbe707f8`, SwiftShader `4982425f` -> `7905fa19`, V8 `5297e56d` -> `075234cf`.
- Método: `diff -ruN` de `cr136`/`cr137` por directorio (guardado en `/tmp/claude-0/port/f137/{net,services,content,components,cc}.diff`),
  `git diff` sobre `/home/user/chromium/hist` para el resto del árbol (`f137/allnames.txt`: 39 872 ficheros; `f137/mac.diff`: ficheros mac/apple/cocoa),
  clones `--filter=tree:0` de BoringSSL, QUICHE, ANGLE y Skia (`/tmp/claude-0/port/{boringssl,quiche,angle,skia}.git`; listas en `f137/*-log.txt`).
  Flags: `f137/feat.py` -> `f137/feat.txt` (BASE_FEATURE old/new, `*features*.cc` + `media_switches.cc`).
  Choques con parches de Brave: `f137/colision.txt` (100 ficheros no-Blink de `net/ services/ content/ components/ cc/`, 782 hunks de diff 136->137 sobre ellos).

## 1. Huella de red 136 -> 137: ningún cambio observable en TLS, HTTP/2, QUIC, Client Hints ni cabeceras por defecto (V código, S captura)

**1.1 TLS (ClientHello): igual que 136 (V).**
- `net/ssl/*`: solo `ssl_config.h` (+`proxy_chain`, `proxy_chain_index`, `session_usage`), `ssl_client_session_cache.{h,cc}` (la clave de la caché de sesiones ahora incluye esos 3 campos: solo afecta a
  conexiones a/vía proxy; directo = igual), `openssl_ssl_util.{h,cc}` (`SetSSLChainAndKey` nuevo), `client_cert_store_mac.cc` (ver 3). Ni grupos, ni sigalgs, ni ECH, ni ALPS, ni GREASE.
  `ssl_client_socket_impl.cc`: la comprobación de CT sale de `SSLClientSocketImpl` (`CheckCTRequirements` borrada; ahora en el servicio de verificación de certificados, `services/cert_verifier/*`)
  y el `SSLClientSessionCache::Key` se rellena con proxy/uso. Sin efecto en el cable.
- BoringSSL (62 commits; V `git diff` de `ssl/` y `crypto/`): `c86127e6` «Change to use ALPS new codepoint as default» (`ssl_lib.cc`: `alps_use_new_codepoint(true)`); Chrome ya lo fija
  explícitamente con `UseNewAlpsCodepointHttp2/QUIC` = ON (sigue ON, `net/base/features.cc`), así que **no cambia nada**; `23018360` «Tidy TLS 1.2 cipher selection» y `cccf8525` `max_cert_list` (lado servidor/sesión);
  `ssl/extensions.cc`: `qsort` -> `std::sort` (mismo orden). El resto: CMS/PKCS7, BIO, scopers, X509_NAME, DSA, refactor de `ssl/internal.h`. **Nada nuevo en el ClientHello por defecto.**
- x86 sin AVX: `d5440dd2` (H^2 de AES-GCM) toca solo `aes-gcm-avx2-x86_64.pl` y `-avx512-`, rutas que se eligen con detección en ejecución; `cpu_intel.cc` solo cambia `sscanf` por `strtoull` en el parser de `OPENSSL_ia32cap`.
  Nada exige AVX (V). No hace falta subir BoringSSL; si se subiera, regenerar el parche de `BUILD.generated.gni`.
- Entradas de red de la `HttpNetworkSession`: `UseDnsHttpsSvcbAlpn` **borrada** (`107159157`, estaba ON): la ALPN de los registros HTTPS DNS se usa siempre, como en 136. `kEncryptedClientHello`, `kUseMLKEM`: sin cambio.

**1.2 HTTP/2: sin cambios en lo que sale al cable (V).**
- `spdy_session.cc` (12 hunks): solo `force_send_go_away` (parámetro nuevo de `CloseSessionOnError`/`DoDrainSession`, solo lo usan rutas nuevas de cierre),
  campos de depuración (`GetInfoAsValue`: `drain_error`, `go_away_error`), CT con `ct::CTRequirementsStatus`, `SpdySessionInitiator`. SETTINGS, WINDOW_UPDATE, prioridades y pseudo-headers: **0 diff**.
- `http_util.cc`: refactor de `StringViewTokenizer`/`TrimLWS` (V: mismo resultado). `http_request_headers.cc`, `services/network/public/cpp/constants.cc` (Accept), `source_stream_type.h`: **0 diff**.
  `Accept-Encoding gzip, deflate, br, zstd` sin cambio (la excepción de FlyWeb sin zstd sigue).
- `HappyEyeballsV3` sigue OFF (el `DnsTaskResultsManager` se crea ahora en `StartDnsTask` en vez del constructor del Job; solo si HEv3). `http_stream_pool*` (18 ficheros): solo con HEv3, inerte.

**1.3 QUIC / HTTP/3: sin cambio en parámetros de transporte ni tramas del cliente (V código, S captura).**
- QUICHE (23 commits): WebTransport subprotocol, MoQT, MASQUE, `QuicAlarmMultiplexer` ya sin flag, `QuicConnectionId`, README. Cliente: **`value_splitting_header_list.cc` solo añade `QUIC_CODE_COUNT`** (contador de crumbling de cookies;
  mismo resultado). `transport_parameters.cc`, `quic_config.cc`, `tls_client_handshaker.cc`, `quic_crypto_client_config.cc`: solo quitan `#if BORINGSSL_API_VERSION >= 27` y `CRYPTO_library_init()`.
  Flags de `quiche_feature_flags_list.h`: nuevo `quic_heapless_static_parser` (false), borrado `quic_use_alarm_multiplexer`. **Los parches de QUICHE de 135/136 siguen valiendo; no hay que añadir nada.**
- **ECN: `kReportEcn` se BORRA (`d062e0ec`, «always sending ACK-ECN»); era ON en 136, así que el comportamiento no cambia.** `QuicParams::report_ecn` desaparece (`net/quic/quic_context.h`); `QuicChromiumPacketReader` y `quic_session_pool.cc` (39 hunks; parcheado por Brave) pierden el parámetro.
  Si se porta algo de QUIC, usar la firma de 137 (sin `report_ecn`). `QuicChromiumPacketWriter`: solo `RegisterQuicConnectionClosePayload` (Android).
- `SearchEnginePreconnect2` nueva, OFF (preconexión QUIC con PING periódico al buscador; es de Chrome/omnibox, no hay equivalente en FlyWeb).

**1.4 Client Hints / UA / cabeceras.**
- `components/embedder_support/user_agent_utils.cc`: un único hunk, `#if BUILDFLAG(IS_LINUX)` que vacía `platform_version` con `ReduceUserAgentDataLinuxPlatformVersion`. **Mac sin cambio** (V).
  `third_party/blink/common/client_hints/*`, `services/network/public/cpp/client_hints.*`, `content/browser/client_hints/*`: **0 diff** (V `git diff`). La lista de hints y `Accept-CH` no cambian.
  `accept_ch_frame_interceptor.{cc,h}` es fichero nuevo en `services/network/` (movimiento/refactor de ACCEPT_CH en HTTP/2; solo si el servidor manda el frame ACCEPT_CH; lo calcula con la misma lista).
- Algoritmo de GREASE/`GenerateBrandVersionList`: sin cambio (V, líneas 268-320, 573-590). Con semilla 137 sale (calculado a mano, V; `shuffled[order[i]] = list[i]`, `orders[137%6=5] = {2,1,0}`;
  `greasey_chars[137%11=5]` = `/`, `[138%11=6]` = `)`, versión `greased_versions[137%3=2]` = `24`):
  `Sec-CH-UA: "Google Chrome";v="137", "Chromium";v="137", "Not/A)Brand";v="24"`
  `Sec-CH-UA-Full-Version-List: "Google Chrome";v="137.0.7151.122", "Chromium";v="137.0.7151.122", "Not/A)Brand";v="24.0.0.0"`
  (coincide con el que manda Chrome 137 real, S de memoria; comprobar con captura). El de 136 era `"Chromium", "Google Chrome", "Not.A/Brand";v="99"`: **el orden y el grease cambian**, y salen solos con `flyweb_engine_level=137`.
  User-Agent reducido: `Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36` (misma plantilla).
- Cabeceras nuevas o con cambio (V):
  - `Sec-Probabilistic-Reveal-Token` (`http_network_transaction.cc`): solo con `EnableProbabilisticRevealTokens` (OFF) + `ProbabilisticRevealTokensAddHeaderToProxiedRequests` y petición por proxy IP Protection (OFF). **Mantener apagado (regla 20).**
    `IP-Protection: 1`: igual, solo en proxy.
  - `Sec-Fetch-Storage-Access`: `kStorageAccessHeaders` BORRADA (`af311238`, queda ON) y nueva `StorageAccessHeadersRespectPermissionsPolicy` ON (la cabecera respeta la política de permisos; sin cambio en peticiones sin política).
  - `Sec-Purpose` en `rel=prefetch`: `SecPurposePrefetchHeaderRelPrefetch` OFF. `Integrity-Policy` para scripts: `IntegrityPolicyScript` OFF (sustituye a `CSPRequireSRIFor`, que se borra).
  - `Priority:`/prefetch: sin cambio de valor de flags de prioridad.
- `UrlRequestHttpJob`: `Sec-Session-Registration`/`Sec-Session-Challenge` (Device Bound Sessions) sin cambio de defecto (OFF fuera de pruebas).

**Qué portar de la red para coincidir con Chrome 137 (resumen):** (a) Sec-CH-UA sale solo con `flyweb_engine_level=137` (sale con orden y grease distintos de 136); (b) regenerar HSTS/`.pins`/`log_list.json`/**Chrome Root Store v19** (§5);
(c) el resto de TLS/H2/QUIC/CH: nada; (d) comprobar por captura (JA4, JA4Q, SETTINGS) que sigue igual que 136.

## 2. BASE_FEATURE 136 -> 137 (V: lectura del código de ambos tags; solo los CAMBIO son seguros; lista completa en `f137/feat.txt`)

**CAMBIO de valor relevantes (los de Android/iOS/ChromeOS/Autofill/Signin/IPH/Commerce se ignoran):**
| Feature | Fichero | Cambio | Nota |
|---|---|---|---|
| `DocumentIsolationPolicy` | `services/network/public/cpp/features.cc` | OFF -> **ON** en Mac/Win/ChromeOS/Linux | `60e02302` «Enable DocumentIsolationPolicy on desktop». Cabecera `Document-Isolation-Policy` -> `crossOriginIsolated` sin COOP/COEP. Visible por web. Requiere el soporte de Blink y de `content/browser` (navegación/proceso: `navigation_request.cc` 42 hunks). Coordinar con el subagente de Blink. 2–3 h |
| `WebAssemblyExperimentalJSPI` | `content/public/common/content_features.cc` | OFF -> ON | JSPI en V8 (se envía con la V8 137). Va con el subagente de V8 |
| `IgnoreInputWhileHidden` | `third_party/blink/common/features.cc` | ON -> OFF | Blink; aviso |
| `EnforceNoopenerOnBlobURLNavigation` | `third_party/blink/common/features.cc` | OFF -> ON | Blink; aviso |
| `FedCmUseOtherAccountAndLabelsNewSyntax` | `content/common/features.cc` | OFF -> ON | FedCM (Brave lo tiene; web) |
| `ServiceWorkerAvoidMainThreadForInitialization` | `content/common/features.cc` | OFF (no Android) -> ON | Rendimiento; sin huella directa |
| `RemoveRendererProcessLimit` | `content/common/features.cc` | OFF -> ON | `9ff4fd4b`; quita el límite blando de procesos de renderer. **No portar en equipos de 48 GB / MacPro5,1**: más procesos = más RAM (S) |
| `UseFrameIntervalDecider` | `components/viz/common/features.cc` | Android ON/resto OFF -> **ON salvo ChromeOS** | `0cb66d08`. Reduce el intervalo de frame para vídeo fijo; en Mac escritorio pasa a ON. No portar de entrada (S, riesgo de tirones en GPUs viejas) |
| `AckOnSurfaceActivationWhenInteractive`, `DrawImmediatelyWhenInteractive` | `components/viz/common/features.cc` | (no ChromeOS) ON -> ON siempre | Sin cambio en Mac |
| `PdfSearchify` | `pdf/pdf_features.cc` | OFF -> **ON** | OCR de PDF escaneados con el componente ScreenAI (descarga de Google). **Apagar/no portar** (§6) |
| `SerialPortConnected` | `services/device/public/cpp/device_features.cc` | ON -> ON solo no-Android | Sin cambio en Mac |
| `OmniboxDefaultTypedNavigationsToHttps`, `IpadZeroSuggestMatches` | omnibox | -> `enable_if(IS_IOS)` | Fuera |
| `AddReferringWebApkToProtegoPings`, `ClientSideDetectionSendLlamaForcedTriggerInfo` | `components/safe_browsing/core/common/features.cc` | OFF -> ON | Safe Browsing; ver §6 |
| `EncryptAllPasswordsWithOSCryptAsync`, `UseNewEncryptionMethod` | password_manager | OFF -> ON | Cifrado de contraseñas con OSCrypt async (afecta a `FlyWeb Safe Storage` del llavero: **revisar con cuidado antes de portar**, migración de datos; S) |
| `PrivacySandboxMigratePrefsToSchemaV2`, `ProfileSignalsReportingEnabled`, `MostVisitedTilesNewScoring`, `NtpMostRelevantTabResumptionModule`, `Autofill*`, `FullscreenBubble*`, `EnableUrlRestriction`, `EnableLocalWebApprovalErrorDialog` | varios | OFF -> ON | UI/servicios de Google: **no portar** |
| `gpu`: `SkiaGraphite` | `gpu/config/gpu_finch_features.cc` | Mac ARM64 ON -> Mac ARM64 **o iOS** ON | Intel Mac sigue OFF (V) |

**BORRADOS (el flag desaparece; queda el valor que tenía en 136; para la 128: dejar el flag fijo en ese valor):**
`ReportEcn` (ON), `UseDnsHttpsSvcbAlpn` (ON), `StorageAccessHeaders` (ON), `DeleteStaleSessionCookiesOnStartup` (ON: **pasa a ser permanente en 137**: borra cookies de sesión viejas al arrancar; es lo que hace Chrome 137, privacidad neutra/positiva),
`MacSyscallSandbox` (OFF; `770eff88`; borra todo el bloque `filter-syscalls` de los `.sb`: ver 3), `DocumentIsolationPolicyOriginTrial` (ON), `BackForwardCacheMediaSessionService` (ON), `UseBrowserCalculatedOrigin` (ON),
`OneTimePermission` (ON), `OcclusionCullingForTextureQuads`/`RenderPassDrawnRect` (ON), `OnBeginFrameAcks` (OFF), `OptimizeLoadingDataUrls`/`ServiceWorkerClientIdAlignedWithSpec`/`SimplifyLoadingTransparentPlaceholderImage`/`AdjustCanCreateCanvas2dResourceProvider` (ON, Blink),
`CSPRequireSRIFor` (OFF, sustituido por `IntegrityPolicyScript`), `PdfCr23` (ON), `Serial` (ON), `PrivacySandboxEqualizedPromptButtons`/`PrivacySandboxPrivacyPolicy` (ON), `StarterPackPage`, `PushSubscriptionChangeEvent` (se parte en dos, OFF).

**Nuevos ON (valorar):** `StorageAccessHeadersRespectPermissionsPolicy`, `PrefetchQueueingPartialFixWithoutScheduler` (prefetch, sin huella), `AlwaysUpdateKAnon`, `FledgeOnlyUseIpAddressSpaceInClientSecurityState`, `AttributionReportExpiry` (privacy sandbox: **mantener apagado el conjunto**, §6),
`ComplexOccluderForQuadsWithRoundedCorners`, `ZeroCopyRBPPartialRasterWithGpuCompositor`, `WorkerThreadSequentialShutdown` (rendimiento/Blink), `ClickInputTracker`, `EnableSavePackageForOffTheRecord`, `WebAuthenticationDisabledOnAuto`, `LensSearchProtectedPage`.

**Nuevos OFF o inertes (no portar):** `RestrictAbusePorts`/`RestrictAbusePortsOnLocalhost` (OFF; lista de puertos por Finch, sin lista no hace nada; opcional portar solo `port_util.cc` si se quiere la defensa; 0,5 h), `IncludeDeprecatedClientCertLookup` (OFF, ver 3),
`SearchEnginePreconnect2` (OFF), `RelatedWebsitePartitionAPI` (OFF), `IncreaseCookieAccessCacheSize` (OFF), `IntegrityPolicyScript` (OFF), `ScriptSrcV2` (OFF), `DeviceBoundSessionAccessObserverSharedRemote` (OFF), `PermissionsAIv3` (OFF),
`FedCmAutofill` (OFF), `Prerender2DisallowNonTrustworthyHttp` (OFF), `PrefetchPrerenderIntegration` (OFF), `ClearSiteDataPrefetchPrerenderCache`, `ForceOffTextAutosizing`, `OptimizeHTMLElementUrls`, `CrashReportingAPIMoreContextData`, `SecPurposePrefetchHeaderRelPrefetch` (OFF, Blink),
`GraphiteContextIsThreadSafe` (OFF «DO NOT ENABLE»), `UseFrameIntervalDeciderAdaptiveFrameRate` (OFF), `BuiltInHlsMP4` (media, OFF -> ON; reproductor HLS integrado, Android; en escritorio sin efecto, S).

## 3. macOS: nada obligatorio; deployment target sigue en 11.0 (V)

- `build/config/mac/mac_sdk.gni`: `mac_deployment_target = "11.0"` en ambos tags; `mac_sdk_official_version` 15.2 -> 15.4 (Xcode 16.3; FlyWeb sigue con SDK 13.3). `mac_sdk_overrides.gni`: `mac_sdk_min = "10.15"` fijo, ya no se lee `FORCE_MAC_SDK_MIN`
  (afecta solo a la comprobación del SDK; FlyWeb pasa su `mac_sdk_path`). Sin subida de mínimos. Frameworks nuevos: **ninguno en Mac** (`BrowserEngineCore` es iOS; `DiskArbitration` se retira con el refactor de `drive_info_mac.cc`; `LocalAuthentication`/`IOBluetooth` solo se reorganizan).
- Barrido de los ~330 ficheros mac/apple/cocoa/`.mm` cambiados (`f137/macnames.txt`, `f137/mac.diff`): **0 APIs 10.15+/11+ nuevas sin guarda que lleguen a producción de FlyWeb**, salvo:
| Fichero / commit | API | Qué hace | Mojave | Coste |
|---|---|---|---|---|
| `chrome/browser/shell_integration_mac.mm` (+108) | `UTType` (UniformTypeIdentifiers, macOS 11) en `GetBundleIdForDefaultAppForUTType`, `SetAsDefaultHandlerForUTType`, `IsDefaultHandlerForUTType`; `@available(macOS 12, *)` solo envuelve `NSWorkspace URLForApplicationToOpenContentType:`/`setDefaultApplication...` | «Hacer predeterminado» para tipos (p. ej. PDF); la rama `else` ya usa `LSCopyDefaultApplicationURLForContentType`/`LSSetDefaultRoleHandlerForContentType` | **`UTType` no existe en Mojave**: sin guarda, falla al cargar/enlazar. Solo si se porta la función (es `chrome/browser`, Brave la parchea/ignora). Traducir a `UTTypeCreatePreferredIdentifierForTag`/strings (`CFStringRef`), 1 h; si no se porta, 0 |
| `crypto/apple_keychain_mac.cc`, `components/os_crypt/sync/keychain_password_mac.mm`, `mock_apple_keychain*` | misma API `SecKeychain*` (deprecada pero presente en Mojave); cambia la firma a `base::expected<std::vector<uint8_t>,OSStatus> FindGenericPassword(std::string_view, std::string_view)` y `AddGenericPassword(service, account, span)`; `ItemDelete`/`ItemFreeContent` desaparecen | Llavero de `FlyWeb Safe Storage` | Misma API del SO. **Choca con cualquier parche de `keychain_password_mac.mm`/`apple_keychain.h` de FlyWeb** (cambio de firma); no es API de SO. 0,5 h si se toca |
| `net/ssl/client_cert_store_mac.cc` (`d5718944`) | `SecIdentitySearchCreate` (deprecada desde 10.7) queda detrás de `IncludeDeprecatedClientCertLookup` (OFF) | Certificados de cliente del llavero (smartcards/identidades) | En Mojave `SecItemCopyMatching` ya existe; se pierde la ruta antigua. Sin guarda de SO. Opcional: dejar el flag ON en FlyWeb para no regresar con identidades de smartcard en Mojave (S); 0,25 h |
| `third_party/crashpad/.../crashpad_client_mac.cc`, `exception_types.cc` | `MacOSVersionNumber() < 13'00'00` | Máscara de excepciones: añade `EXC_MASK_GUARD` **solo antes de macOS 13** | Mojave (<13) mantiene el comportamiento actual: correcto | 0 |
| `base/apple/mach_port_rendezvous*.{cc,h}` | Parte `mach_port_rendezvous.cc` en `_mac`/`_ios` | Refactor | Mismo API mach; **choca con parches** de `base/apple/mach_port_rendezvous.cc` si los hay | 0,5 h al portar |
| `base/files/drive_info_apple.mm` -> `drive_info_mac.cc` (-263/+228) | IOKit/DiskArbitration -> API de bajo nivel | Info de disco para métricas | Sin API nueva; sin efecto de huella | 0 |
| `media/audio/apple/audio_low_latency_input.cc` (+43), `core_audio_util_mac.cc` | `kAUVoiceIOProperty_VoiceProcessingEnableAGC` (10.7+), terminales de salida en `IsInputDevice` | AGC del sistema para `getUserMedia` con `autoGainControl`; arregla dispositivos de salida clasificados como entrada | API vieja; guardado por `use_voice_processing_` | 0 |
| `components/remote_cocoa/app_shim/native_widget_ns_window_bridge.mm` | `NSWorkspaceActiveSpaceDidChangeNotification`, `NSWindow onActiveSpace` (10.6+) | Nueva `OnSpaceActivationChanged` (ocultar/mostrar ventana por espacio) | Disponibles en Mojave | 0 |
| `ui/accessibility/platform/*_mac.mm` (~20 ficheros) | `gfx::NativeViewAccessible` pasa a ser un wrapper `.Get()` (id) | Accesibilidad de VoiceOver | Solo refactor de tipos; **choca con cualquier parche de `render_widget_host_view_mac.mm`** (7 hunks, parcheado) | 0,5 h al portar |
| `gpu/ipc/service/image_transport_surface_overlay_mac.mm`, `ui/accelerated_widget_mac/ca_*`, `components/viz/common/gpu/metal_context_provider.*` | Pasa un `id<MTLDevice>` (nil con ANGLE-GL) a `CARendererLayerTree`; `GetGraphiteSharedContext`; quita `PresentationDelayForInteractiveFrames` y métricas | Mojave con ANGLE-GL: `GetMTLDevice` devuelve nil (rama `GrContextIsGL` + `EGL_METAL_DEVICE_ANGLE`, si el display no es Metal devuelve nil) | Hay que comprobar que la capa acepta `nil` (V: parámetro opcional `= nil`) | 0,25 h con prueba en Mojave |
- `sandbox/policy/mac/{common,renderer,audio,cdm,gpu,utility,print_compositor}.sb`: se borra todo el bloque `(if (param-true? filter-syscalls) ... (syscall-number SYS_...))` y `content/browser/sandbox_parameters_mac.mm` ya no pasa `FILTER_SYSCALLS`.
  El bloque era solo para 10.15+ y estaba OFF: **en Mojave nunca se ejecutó**. Si FlyWeb parcheó los `.sb` o `sandbox_parameters_mac.mm`, chocan (0,25 h); si no, nada.
- Trampa transversal heredada de 136 sigue (`absl::variant/optional` -> `std::*`, `SHA256HashValue`). Nueva en 137: `base::span`/`std::to_array` en `net/http/http_util.cc` y `gpu/command_buffer/service/{gl_utils,texture_manager}.cc` (spanify, sin cambio de comportamiento).
- `IOSurfaceLock` devuelve `kern_return_t` (antes `IOReturn`): `software_output_device_mac.cc`, `iosurface_image_backing.mm`; mismo tipo subyacente (int), sin efecto.

## 4. GPU / ANGLE / Skia / Dawn

- **Listas de bloqueo (V):** `gpu/config/software_rendering_list.json` +1 entrada (id 184, **Windows**/Intel «Disable Graphite on very old Intel drivers»); Mac sin entradas nuevas; id 183 (NVIDIA Mac, canvas acelerado) intacto: sigue el aviso del MacBook Pro 2012 GT 650M.
  `gpu_driver_bug_list.json`: solo Windows/Intel (AV1) y se borra el id 439 (Windows AMD). `gpu_workaround_list.txt` -1 línea (Win). `gpu_util.cc`: `D3D11Warp` -> `D3D11WarpForWebGL` (Windows).
- **Decodificador:** `gpu_init.cc` (`926b1bf99`): si el validating decoder no está compilado, fuerza el passthrough también con SwiftShader/GL desactivado. En Mac el passthrough ya era el único; **sin efecto** (V).
  `gles2_cmd_decoder.cc`/`gl_utils.cc`/`texture_manager.cc`: `std::to_array` (spanify) y `flip_y` -> `is_dst_origin_top_left` (renombre en el CopyTextureCHROMIUM, mismo resultado); no tocan WebGL en GL/Mac.
- **ui/gl:** borra `kWriteMetalShaderCacheToDisk`/`kUseBuiltInMetalShaderCache` (Metal, FlyWeb usa GL), `ui/gl/gl_features.cc` y `gl_switches.cc` solo Windows/Android. `gpu_switches.cc` quita `--shader-cache-path` (era solo de Metal). Sin efecto en Mojave.
- **Graphite (apagado en FlyWeb):** `SkiaGraphite` sigue OFF en Intel Mac (solo Mac ARM64 e iOS ON). Nuevo `GraphiteSharedContext` (`gpu/command_buffer/service/graphite_shared_context.{cc,h}`, +389 líneas) con `GraphiteContextIsThreadSafe` OFF «DO NOT ENABLE». No tocar.
  Si el parche de FlyWeb toca `metal_context_provider.mm` o `shared_context_state.cc` (+118), chocan; no se portan.
- **ANGLE (185 commits `fa40b7c5` -> `df9c59dc`, solo mensajes revisados):** `5dd05578` **revierte** «GL: Allow untranslated shaders to pass through on GLES» (`4e77552b`); como `AllowANGLEPassthroughShaders` seguía en 136, queda inerte en 137 (el flag sigue en `ui/gl/gl_features.cc`, V sin cambio). Resto: Vulkan (workarounds Qualcomm), Metal (`0f9feb49` PBO, `07eeca12`, `f6a350de`), traductor (`02ae054c` init de variables de salida inactivas, `0d1478f3` dFdx/dFdy en WGSL),
  `9a3c3718` «Stop Mac Intel experiment» (Metal en Mac Intel, que FlyWeb no usa), tests y builders. **Nada del backend GL/CGL** (no hay commits `GL:`/`CGL` salvo el revert). No subir ANGLE; sin cambios que portar a la 128 (V mensajes; S contenido).
- **Skia (223 commits `bcce46ca` -> `0dfd95a4`):** `668e700e8` «Support GL texture for BGRA8 format» (Ganesh GL; relacionado con el cambio de `GL_BGRA_EXT` de ANGLE de 136, huella menor de WebGL2/GL; opcional, S), Fontations (flat pixel geometry), infra. **Nada de CoreText.** Sin impacto en Mojave.
- **Dawn/SwiftShader:** WebGPU apagada en FlyWeb (toggles nuevos `DisabledToggles`/`EnabledToggles` en `gpu_finch_features.cc`, sin efecto). `webnn/coreml/*` (WebNN, fuera).
- `ca_renderer_layer_tree.mm`, `cc/` (5059 líneas de diff en `f137/cc.diff`, mayormente rendimiento): ver subagente de CC/compositor.

## 5. HSTS preload, pins, CT y raíces de la 137

| Fichero (ruta) | 136 -> 137 | Notas |
|---|---|---|
| `net/http/transport_security_state_static.json` | **cambia**: 165 699 -> 166 958 entradas (+1267 nuevas, -8 quitadas, 0 modificadas; 18,37 -> 18,51 MB) | Todas las nuevas `bulk-1-year force-https include_subdomains`, sin pins (V comparado programáticamente). `pinsets` y `domain_ids` vacíos e iguales. Parche `net-http-transport_security_state_static.json.patch`: regenerar (9 hunks de diff) |
| `net/http/transport_security_state_static.pins` | 2 líneas (comentario «Last updated: 2025-05-10» -> **2025-06-15 13:01 UTC** y timestamp 1746881712 -> 1749992496) | Sin pins nuevos |
| `net/http/transport_security_state_static_pins.json` | 1 línea (mismo comentario) | idem |
| `components/certificate_transparency/data/log_list.json` | versión **53.41 -> 55.7**, `log_list_timestamp` 2025-05-11 -> 2025-06-16 (`2025-06-16T12:53:26Z`); **se quita el log «Sectigo 'Sabre'»** (retirado, `readonly` desde 2024-05-06) (V; no se comparó el resto del diff línea a línea) | Parche de Brave sobre este fichero y `ct_known_logs`: ver que sigue aplicando |
| `net/data/ssl/chrome_root_store/root_store.{textproto,md,certs}` | **v18 -> v19; `root_store.certs` CAMBIA (134 -> 118 certificados)** | **Cambia la confianza** (a diferencia de 136): quita de «Trusted Roots» 17 raíces (V `root_store.md`) (emSign Root CA - C1 y ECC C3, Starfield Class 2, Baltimore CyberTrust, QuoVadis Root CA 3 y 1 G3, IdenTrust Public Sector Root CA 1, Secure Global CA, Hellenic Academic RootCA y ECC 2015, Entrust.net Certification Authority (2048), SecureSign RootCA11, TWCA Root Certification Authority, Go Daddy Class 2, XRamp, AAA Certificate Services, GlobalSign Root CA R1), añade TWCA CYBER Root CA (neto -16: 134 -> 118 PEM; ePKI Chunghwa sigue, solo cambia de posición en el fichero); `textproto` cambia las restricciones `sct_not_after_sec: 1754006399`/`min_version: "135"` (antes 1731369599/131). Es lo que confía Chrome 137; **portar** (regenerar `root_store.certs`, `.textproto`, `.md`, `BUILD.gn`/`test_*`; el parche de Brave sobre `root_store.certs` hay que rehacerlo). Con FlyWeb en Mojave: el almacén de Chrome (no el llavero) decide si `CHROME_ROOT_STORE_SUPPORTED` está activo en Mac; comprobar (S) |
| `net/cert/internal/trust_store_chrome.{h,cc}` (9 + 8 hunks), `net/cert/cert_verify_proc_builtin.cc` (33 hunks), `qwac.{h,cc}` | Refactor de `ChromeRootStore` y constraints; `VerifyQWACs` sigue OFF | Si se regenera el almacén sin tocar el código, depende del formato del `textproto` (campos nuevos `eutl`/`additional_certs` ya desde 136); 0,5 h de comprobación |
Coste: regenerar HSTS/pins/CT = 0,5 h (mecánico, como en 136); root store v19 = 0,5–1 h. El código de pins (`transport_security_state.cc`, 7 hunks) cambia por mover CT a `ct::CTRequirementsStatus`; los parches que toquen CT hay que rehacerlos.

## 6. Privacidad: lo nuevo que expone datos (proponer apagar o no portar)

| Qué | Estado en 137 | Propuesta |
|---|---|---|
| **IP Protection / PRT** (`Sec-Probabilistic-Reveal-Token`, `IP-Protection: 1`, nuevos parámetros `ProbabilisticRevealTokens*` y `Bypass...Registry`) | `EnableIpPrivacyProxy` y `EnableProbabilisticRevealTokens` OFF (V `net/base/features.cc:352,404`) | **Dejar OFF y no portar** `components/ip_protection/*` (regla 20). Los parámetros nuevos `...ForNonProxiedRequests`, `...OnlyInIncognito` no deben llegar al cable. |
| **PDF Searchify** (OCR con ScreenAI, componente de Google) | `PdfSearchify` **OFF -> ON** (`02f2335c`) | **Apagar / no portar**; FlyWeb no sirve el componente ScreenAI (sería petición a Google) |
| **APIs de IA en el navegador** (Prompt API, Summarizer, Writer, Rewriter, Translator, LanguageDetector) | En 137 siguen `status: "experimental"` (V `runtime_enabled_features.json5`: `51cb0fb1`); necesitan el modelo on-device de Chrome (`optimization_guide`, `is_chrome_branded`, `dc339326`) y Origin Trials | No portar `chrome/browser/ai`, `content/browser/ai` (`echo_ai_*` es de test). **Mantener experimentales y sin componente de modelo**; no añadir los servicios `optimization_guide` al servidor de componentes. Políticas de empresa nuevas para IA (`1a743ab5`, `703bbeea`): ignorar |
| **AutofillAI / FormsAI** (formularios con IA, modelo de servidor) | `autofill_ai/*`, `AutofillAiUploadModelRequestAndResponse` OFF | No portar (Autofill de Chrome/Google) |
| **Privacy Sandbox / Protected Audience** | Nuevos ON: `AlwaysUpdateKAnon`, `FledgeOnlyUseIpAddressSpaceInClientSecurityState`, `AttributionReportExpiry`; `EnabledBandAClickiness` OFF; `PrivacySandboxMigratePrefsToSchemaV2` ON | Ya apagados en Brave (`InterestGroupStorage`, `BrowsingTopics`, `SharedStorageAPI`); **comprobar que los 3 ON nuevos no reabren nada** (0,25 h). `RelatedWebsitePartitionAPI` OFF: dejar OFF |
| **Local Network Access** | `LocalNetworkAccessChecks` OFF (modo solo aviso `Warn=true` si se activara); permisos-policy `local-network-access` nueva (`c5f8f3d9`); `PrivateNetworkAccessForNavigations` OFF | Sin exposición. Es protección; no se despliega en 137: no portar |
| **Safe Browsing / Client Side Detection con LLM** | `ClientSideDetectionSendLlamaForcedTriggerInfo` OFF -> ON (`safe_browsing/core/common/features.cc`); `NotificationTelemetry`, `ReportNotificationContentDetectionData`, `BundledSecuritySettings` OFF | FlyWeb usa Safe Browsing estándar vía `proxy.flyweb.lamosquita.net`; **dejar este flag OFF** (envía información de disparo forzado; S) |
| **Device Bound Sessions** (`Sec-Session-Registration`) | `DeviceBoundSessions*` OFF salvo `ForceEnableForTesting` | Mantener OFF |
| **Geolocalización de red** (`services/device/geolocation/network_location_request.cc`) | Solo cambio de tipo `std::optional` | Sin cambio de destino; FlyWeb debe seguir usando su endpoint (o ninguno) |
| **Cookies de sesión** | `DeleteStaleSessionCookiesOnStartup` queda permanente (ON) | Aceptable (menos rastro); no hace falta apagarlo |

## 7. Horas reales (las de papel ~4x pesimistas, ya divididas)

| Tarea | Horas |
|---|---|
| `DocumentIsolationPolicy` ON (lado red/contenido; el resto lo hace el subagente de Blink) + decidir `RemoveRendererProcessLimit`/`UseFrameIntervalDecider` (no portar) | 2–3 |
| HSTS preload + `.pins` + `log_list.json` (regenerar los 3-4 parches de Brave) | 0,5 |
| **Chrome Root Store v19** (`root_store.certs`/`.textproto`/`.md`, rehacer el parche; comprobar `trust_store_chrome`) | 0,5–1 |
| Captura TLS/HTTP2 (JA4/JA3, SETTINGS) y QUIC (Initial/ECN) frente a Chrome 137.0.7151.122 real: pasar S a V; verificar la cadena `Sec-CH-UA` de §1.4 con `flyweb_engine_level=137` | 1–1,5 |
| Comprobar que ningún parche de los 100 ficheros del cruce (`f137/colision.txt`) se rompe en lo que SE porta: `quic_session_pool.cc` (39 hunks), `trust_store_chrome`, `keychain`/`render_widget_host_view_mac.mm`, `ssl_client_socket_impl.cc` (5), `url_request_http_job.cc` (6) | 1–1,5 |
| macOS: `IncludeDeprecatedClientCertLookup` (decidir ON), `.sb`/`sandbox_parameters_mac.mm`, `metal_device` nil con ANGLE-GL en Mojave | 0,5 |
| GPU: prueba WebGL2 en Mojave 5,1/6,1 y MBP 2012 (nada cambia; solo regresión) | 0,5 |
| Privacidad: confirmar que `Fledge*`/`AlwaysUpdateKAnon`/`AttributionReportExpiry`/`PdfSearchify`/`ClientSideDetection*` quedan OFF | 0,5 |
| **Total obligatorio / útil** | **≈ 6–9 h (red, macOS, GPU y datos; sin Blink ni V8)** |
| Opcional: `RestrictAbusePorts` (`port_util.cc`, 0,5 h), `UTType` en `shell_integration_mac.mm` (1 h), `GL_BGRA8` de Skia/ANGLE (1 h) | +1,5–2,5 |

Riesgo principal: la **captura** (JA4, JA4Q) sigue siendo lo que pasa S a V; y el **cambio de confianza del Root Store v19** (a diferencia de 136), que sí altera qué certificados valida el navegador.

## 8. Lo no encontrado (para no buscarlo otra vez)

- Sin cambios (0 líneas, V) en: `net/ssl/ssl_config_service*`, `net/ssl/ssl_cipher_suite_names.cc`, `net/http/http_request_headers.cc`, `net/filter/source_stream_type.h`, `services/network/public/cpp/constants.cc`,
  `net/socket/ssl_client_socket.cc`, `net/quic/quic_chromium_client_session.cc`(salvo el parámetro de ECN), `components/network_session_configurator/*` (0 ficheros), `third_party/blink/common/client_hints/*`,
  `base/threading/platform_thread_apple.mm` (el parche de 8 líneas de FlyWeb no se toca), `UseNewAlpsCodepoint*`.
- No hay en 137 ningún cambio de BoringSSL en grupos, sigalgs, ECH, GREASE ni orden de extensiones; ni cambios de SETTINGS HTTP/2; ni de parámetros de transporte QUIC del cliente; ni cabeceras `Accept*`/`Sec-CH-*` nuevas por defecto.
- No comprobado (S): capturas reales de Chrome 137 (JA4, JA4Q, ECN); el contenido de ANGLE/Skia más allá de los mensajes de commit (no se leyeron los diffs de ANGLE; clones sin blobs); el contenido de `content/browser` aparte de flags, geolocalización, permisos y mac
  (`f137/content.diff`, 96 731 líneas, no leído fichero a fichero); `media/`, `ui/` y `gpu/` fuera de los `.mm`, `*features*.cc` y `gpu/config`; si `CHROME_ROOT_STORE_SUPPORTED` está activo en Mac en la compilación de FlyWeb (afecta al peso del cambio de v19);
  si `PdfSearchify` necesita componente (sí: ScreenAI) o corre sin él; Android/iOS/ChromeOS/Windows (fuera de alcance).
- Pendiente de otros subagentes: Blink (incl. `DocumentIsolationPolicy` en Blink, `IgnoreInputWhileHidden`, `EnforceNoopenerOnBlobURLNavigation`, `OptimizeHTMLElementUrls`) y V8 (`WebAssemblyExperimentalJSPI`).
