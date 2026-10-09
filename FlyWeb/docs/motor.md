# FlyWeb — evolución del motor (fase M, decidida el 04-10-2026)

## Decisión (HUMANO, 04-10)

Hacer crecer el motor de la 116 **función a función**, en lugar de cambiarlo. No se pasa a Chromium Legacy: está
parado desde mayo de 2024 (última estable 124.0.6367.207, último canary 127.0.6494;
[releases](https://github.com/blueboxd/chromium-legacy/releases),
[discusión #274](https://github.com/blueboxd/chromium-legacy/discussions/274)), y cambiar de base obligaría a portar
brave-core y los 45 pasos de FlyWeb para ganar 8 versiones y volver a quedarse parados.

## Principios

1. **El CSS y casi todo Blink no dependen de macOS.** Son C++ sin Cocoa ni Metal; Chromium dejó Mojave por la GPU,
   el vídeo, la captura de pantalla y el SDK. Lo que separa la 116 de una función nueva es la antigüedad del código,
   no Mojave. Donde sí hay dependencia del sistema (barras de desplazamiento nativas, corrector, vídeo, GPU, fuentes),
   se estudia caso por caso.
2. **Objetivo: las funciones Baseline** (las que ya funcionan en Chrome, Safari y Firefox), porque son las que usan las
   webs. Las que solo tiene Chrome se dejan para cuando una web importante las exija.
3. **Niveles por versión de Chrome.** El nivel *N* está completo cuando FlyWeb tiene todo lo Baseline que Chrome
   publicó hasta la *N*: CSS portado o encendido, JavaScript con polyfills (componente firmado en bak) y las API que
   importen.
4. **Versión declarada = nivel real.** El User-Agent y los Client Hints dicen la versión del último nivel completo, no
   más: si una web cree que somos la 120, es porque lo somos en lo que usa. **Y a todas las webs igual** (HUMANO,
   04-10): sin excepciones por sitio; si una web nos rechaza, es un dato de qué nivel necesita. (FlyWeb 1.1: 117.)
5. **Flags, caso por caso, nunca en bloque.** Lo que está tras un flag en la 116 puede estar incompleto o ser una
   versión antigua de la especificación. Ejemplo: el `harmony_array_grouping` de la V8 11.6 ya instala
   `Object.groupBy`/`Map.groupBy`, pero también `Array.prototype.groupToMap`, que no publicó ningún navegador; por eso
   no se enciende el flag tal cual, sino que se parchea como lo dejó la V8 11.7 (la de Chrome 117).
   JavaScript: parche de V8 cuando el código está en la 11.6; si no, polyfill en un componente.
   **Antes de encender un flag *harmony*, comprobar que no son esqueletos** (`grep -n TODO src/builtins/<función>*.tq`
   y los `.cc`): en la 11.6, `Map.groupBy` devolvía `undefined` («TODO(v8:12499): Implement») y el paso 46 lo dejó
   expuesto; lo vio `motor-117.html` y LOCAL portó la implementación de la 11.7 (paso 49).
   **Y traer la serie entera de la función hasta que se publicó** (`git log --grep=<función> <11.6>..<versión que la
   publicó>` en V8; para `groupBy` eran 6 commits, no 1), **probando con tamaños grandes**: sin dos arreglos de la 11.7,
   un grupo de más de ~33 000 elementos cerraba la pestaña (LOCAL, paso 50).
6. **Inventario de cada nivel (método de LOCAL):** con la copia de Chromium, `git log -E --grep=<flag|propiedad>
   <N-1>..<N> -- third_party/blink` saca lo que se escribió después de la rama: la implementación que falte (lo que
   pasó con `transition-behavior`) y los arreglos de lo que se enciende. Se portan en orden de llegada; si uno no
   aplica, se busca el commit previo del que depende (como 43a6c81e7182 para 3a16f4331fe5).
7. **Validación:** una página de comprobación por nivel (`FlyWeb/tools/motor-N.html`, sin red) y las
   web-platform-tests de cada función en `wpt.live`, comparadas con el Chrome que la publicó (`wpt.fyi`).
8. **Seguridad:** cada función portada o encendida añade código al renderer; sus correcciones posteriores entran en la
   vigilancia de CVE (`cve-triage.md`).
9. **Coste por porte, una sola vez:** la base no se mueve, así que un porte no hay que rehacerlo con cada versión de
   Chromium.
10. **Caché de código de V8 (lección de la 1.1, LOCAL 05/10):** V8 acepta la caché del perfil si coinciden
   `Version::Hash()` (11.6.189.20, que nuestros parches no cambian) y los flags *no por defecto*; cambiar builtins o el
   valor por defecto de un flag no la invalida y las webs con JIT caen. Por eso **todo nivel o parche de seguridad que
   toque `patches/v8/` sube `kFlyWebCacheEpoch`** (`patches/v8/src-utils-version.h.patch`; 2 = 1.1.1, 3 = nivel 119).
   Y cada versión se prueba también **actualizando un perfil usado por la anterior** (Gmail, Drive, claude.ai,
   YouTube), no solo con perfil nuevo.
11. **V8 por niveles (decisión del HUMANO, 05-10; FM.5):** cada nivel N lleva la V8 de Chrome N en vez de portar
   funciones a la 11.6: brave-core `FlyWeb/v8-revision` la fija y `build.sh` la pone antes de los parches (sin el
   fichero, la de la 116). Por nivel: `patches/v8/` rehechos contra esa V8 (los de seguridad son de SEGURIDAD),
   `chromium_src/v8` de la versión de Brave de ese Chromium, y los parches de Blink para las APIs que esa V8 quita.
   Los avisos de APIs obsoletas de V8 van apagados en `build.sh`. 118 = 11.8.172.18, 119 = 11.9.169.7,
   120 = 12.0.267.17.
   **Solo se parchea (seguridad) la V8 del nivel que se publica**; las ramas intermedias son pasos de desarrollo.
   **Criterio de parada (HUMANO, 05-10):** se sube V8 mientras el salto cueste poco en Blink (unos pocos parches,
   como los tres de la 11.9). Si una V8 exige cambios grandes en Blink o en `gin`/bindings (p. ej. el paso de V8 a
   `Tagged<>` y handles directos en la API pública), o deja de funcionar en Mojave o en la 5,1, **se para en la última
   V8 que pasó** y desde ahí se vuelve a portar funciones sueltas de JavaScript, como antes. LOCAL anota en FM.5 cuántos
   errores de Blink dio cada salto para decidirlo con datos.
   **Parar no es automático (HUMANO, 05-10):** cuando un salto salga caro, antes de parar se comparan los dos dolores
   de cabeza: (a) **adaptar Blink** a esa V8 (cuántos ficheros y cuánto riesgo) frente a (b) **dejar V8 estacionada**
   y vivir de parches: portar a mano cada función nueva de JavaScript (lo de la 11.6 → 117 dio tres fallos en un día:
   `Map.groupBy` vacío, pestaña cerrada con grupos grandes, caché de código vieja) y rehacer cada parche de seguridad
   sobre un código que se aleja cada vez más del de V8 (CVE-2024-0519 ya no aplicaba en la 11.8). El coste de (b)
   crece con el tiempo; el de (a) se paga una vez por salto. Se decide con esas cifras (errores de Blink del salto,
   portes y parches pendientes en la V8 estacionada), no por costumbre.
   **Blink no se sustituye entero como V8:** V8 es un repositorio aparte con una API de incrustación estable; Blink
   está dentro de Chromium y depende de `content/`, `cc`/`viz`, `gpu`, Mojo y `base` de la misma versión. Cambiarlo
   entero es subir Chromium, que es justo lo que no funciona en Mojave (principio 1). En Blink se sigue portando
   función a función.
12. **Las subfunciones cuentan (decisión del HUMANO, 05-10; FM.8):** un nivel N no está completo con las funciones
   nuevas de web-features; también hacen falta las **subfunciones** Baseline que Chrome publicó en la N (`by_compat_key`
   de web-features: partes nuevas de funciones que ya existían, como `float: inline-start` o las opciones de
   `checkVisibility()`). Si la función completa es Baseline más tarde (colores relativos → 125, `@scope`), la
   subfunción va con el nivel de la función. El inventario de cada nivel se hace con las dos listas y con los flags que
   pasan a `stable` en `runtime_enabled_features.json5` entre la N−1 y la N (las versiones de BCD no siempre son exactas).
   Los niveles 117–121 se hicieron sin esto: se completan con un commit más por rama (opción A del HUMANO, aceptando una
   compilación más por nivel).

## Tipos de trabajo y coste estimado

| Tipo | Ejemplo | Coste |
|---|---|---|
| Encender un flag que ya está completo | subgrid, `@starting-style` (nivel 117) | Horas + pruebas |
| Porte pequeño (parser, estilos) | `light-dark()`, `:user-valid`, unidades `cap`, `mask` sin prefijo | Días |
| Porte mediano | colores relativos, nesting relajado, `field-sizing` | 1–2 semanas |
| Porte grande | view transitions, anchor positioning | Semanas o meses: solo si una web importante lo exige |
| JavaScript | `Object.groupBy` (parche de V8), `Promise.withResolvers`, métodos de `Set`… | Parche de V8 si ya está el código; si no, polyfill: horas |

## Versiones (HUMANO, 04-10)

El número menor de FlyWeb sigue al nivel de motor: **1.0 = Chromium 116, 1.1 = nivel 117**, 1.2 = nivel 118… Los
arreglos sobre un mismo nivel son 1.1.1, 1.1.2… Aparte, `FLYWEB_BUILD_NUMBER` (→ `CFBundleVersion` 157.64.N, lo que
compara Sparkle) sube en cada versión publicada: 1.0 = 0, 1.0.1 = 1, 1.1 = 2. Ambos números (`flyweb_version`,
`flyweb_engine_level`) están en brave-core `build/config.gni`; el nivel es también la versión declarada.

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

## Nivel 127 (en código, 09-10; aparcado hasta que compile la 1.10 → FlyWeb 1.11)

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
  `patches/v8` rehechos con `v8re.sh` sin conflictos; **`kFlyWebCacheEpoch` 3 → 4**. Muy por debajo del criterio de
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
  `NGHighlightPainter`). **Apartadas al portar** por no ser baratas: `TextDiffSplitFix` (depende del refactor
  `TextDiffRange`) y `SvgFilterUserSpaceViewportForNonSvg` (~110 líneas en 12 ficheros).
- **Descartado (HUMANO):** constructores de `RTCEncoded*Frame` (van con su función, nivel 141), `position-anchor: auto`,
  lo no Baseline (`ChapterInformation`, `VideoFrame.copyTo` RGB, Protected Audience, No-Vary-Search) y las flags de
  View Transitions por árbol y concurrentes, barras con `color-scheme`, copiar sin `text-transform`, `justify`/bidi y
  serialización corta de `transition`.
- **Comprobación:** `FlyWeb/tools/motor-127.html` (11 comprobaciones y dos a mano: `::selection` y `beforeinput`; en
  Chromium 141 todas «ok» salvo la del UA) y `FlyWeb/tools/wpt-127-lista.txt` (35 ficheros).
- **Declarado 127 / FlyWeb 1.11** en f8087001. `chk.sh`: 1088 parches aplican sobre la 116 (solo el aviso conocido de
  `menu_separator`); cada `#include` nuevo existe en la 116 (c776bbf5 añade el que faltaba en `content_data.h`). Sin
  compilar. **Aparcado (HUMANO, 09-10):** no se entrega a LOCAL ni a SEGURIDAD-PORTES (FS.9) hasta que compile la 1.10 y
  estén fusionados sus arreglos.

## Inventario: CSS Baseline publicado después de la 116

Datos de [web-features](https://www.npmjs.com/package/web-features) 3.40.1 (el catálogo de Baseline) y del fichero de
flags de la 116 (`runtime_enabled_features.json5`). De 102 funciones de CSS posteriores a la 116, estas 46 son
Baseline; el resto son solo de Chrome.

| Chrome | Función | Baseline | En la 116 |
|---|---|---|---|
| 117 | @starting-style | reciente | flag (`CSSInitialPseudo`) |
| 117 | Subgrid | amplia | flag (`LayoutNGSubgrid`) |
| 117 | transition-behavior | reciente | porte (3 commits; el flag de la 116 no tenía la propiedad) |
| 118 | cap unit | amplia | porte (nivel 118) |
| 118 | rcap unit | reciente | porte (nivel 118) |
| 118 | transform-box | reciente | porte (13 commits de SVG, nivel 118) |
| 119 | :user-valid and :user-invalid | amplia | porte (nivel 119) |
| 119 | Clip path boxes | amplia | porte adaptado a mano (nivel 119) |
| 119 | rect() and xywh() | amplia | porte (nivel 119) |
| 120 | :dir() | amplia | porte (17 commits, nivel 120) |
| 120 | Exponential functions (CSS) | amplia | flag encendido (nivel 120) |
| 120 | Masks | amplia | porte (25 commits, nivel 120) |
| 120 | Nesting | amplia | porte relajado (11 commits, nivel 120) |
| 120 | scripting media query | amplia | porte (nivel 120) |
| 121 | Spelling and grammar text decorations | reciente | flag + 2 arreglos (nivel 121) |
| 121 | scrollbar-color | reciente | porte (nivel 121) |
| 121 | scrollbar-width | reciente | porte (nivel 121) |
| 123 | align-content in block layouts | reciente | no está |
| 123 | field-sizing | reciente | no está |
| 123 | light-dark() | reciente | interno (`-internal-light-dark`) |
| 123 | paint-order | amplia | no está |
| 124 | Vertical form controls | reciente | flag (`FormControlsVerticalWritingModeSupport`) |
| 125 | :state() | reciente | porte (nivel 125) |
| 125 | Active view transition | reciente | porte a mano (nivel 125) |
| 125 | Relative colors | reciente | porte a mano (nivel 125) |
| 125 | round(), mod(), and rem() | reciente | flag + 2 arreglos (nivel 125) |
| 125 | view-transition-class | reciente | porte a mano (nivel 125) |
| 127 | font-size-adjust | reciente | flag + 15 arreglos (nivel 127) |
| 128 | ruby-align | reciente | no está |
| 130 | text-wrap | reciente | no está |
| 131 | ::details-content | reciente | no está |
| 133 | :open | reciente | no está |
| 135 | shape() | reciente | no está |
| 136 | print-color-adjust | reciente | no está |
| 138 | abs() and sign() | reciente | flag (`CSSSignRelatedFunctions`) |
| 138 | progress() | reciente | no está |
| 138 | sibling-count() and sibling-index() | reciente | no está |
| 143 | @scope | reciente | flag (`CSSScope`, versión antigua) |
| 146 | text-indent: each-line | reciente | no está |
| 146 | text-indent: hanging | reciente | no está |
| 147 | contrast-color() | reciente | no está |
| 148 | Name-only container queries | reciente | no está |
| 148 | crisp-edges | reciente | no está |
| 148 | text-decoration-skip-ink: all | reciente | no está |
| 150 | light-dark() image values | reciente | no está |
| 151 | alpha() | reciente | no está |

46 funciones.
