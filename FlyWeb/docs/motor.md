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
13. **Huella de red coherente con el Chrome N (ARQUITECTURA por encargo del HUMANO, 12-10; F4.8):** un nivel N no se
   da por cumplido si la huella TLS/HTTP/2 de FlyWeb no es una que el Chrome N real pueda tener. La red sigue siendo la
   de la 116 y no se migra (principio 1); lo que cambia con los niveles son los valores por defecto que una web puede
   ver: GREASE ECH (Chrome 117), `zstd` (123, excepción del HUMANO), intercambio poscuántico Kyber (124), ML-KEM
   (131). **Receta de LOCAL en cada nivel**, junto a `motor-N.html`: desde la app, `https://tls.peet.ws/api/all`
   (JA4, huella HTTP/2 «akamai», orden de cabeceras, `Accept-Encoding`) comparada con la publicada para Chrome N
   (ja4db.io), no con el Chrome de la 7,1. No se busca una JA3 idéntica (Chrome baraja el orden de las extensiones
   desde la 110): se busca que la huella sea plausible para la versión declarada. Lo que la 116 trae apagado se
   enciende (Fase 6.2, con `base::Feature` en brave-core, no con args de GN); lo que exija tocar BoringSSL lo porta
   SEGURIDAD-PORTES.
   **Confirmado con la 1.11 (F4.8, 12-10):** adidas.es (Akamai) bloqueaba y claude.ai (Cloudflare) retaba porque
   faltaban `sec-ch-ua`, `-mobile` y `-platform`. Con esas *client hints* pasan los dos. La regla vale también para
   ellas: cabeceras, `navigator.userAgentData` y User-Agent declaran lo mismo (versión completa real del Chrome N,
   `flyweb_engine_full_version` en `config.gni`; GREASE con la semilla N; marcas GREASE + `Chromium`, sin `Brave` ni
   `Google Chrome`). La medición de F4.8 (`tls.peet.ws` y la lista de sitios de la fila) entra en la receta de cada
   nivel. **`platformVersion` (decisión del HUMANO, 12-10, a propuesta de ARQUITECTURA):** la versión real de macOS si el
   Chrome N la admite; si no, la mínima que admite el Chrome N (127–128: 10.15.7; 129–138: 11.7.10; 139+: 12.7.6), en
   `config.gni` y revisada en cada nivel contra los requisitos publicados de Chrome. Excepción al principio 4 por dos
   motivos: Chrome 127 en 10.14 es una combinación que no existe (un antibot la lee como suplantación), y **privacidad**:
   10.14.6 identifica a muy pocos usuarios, mientras que 10.15.7 es lo que ya dice el User-Agent congelado de todos los
   Mac. Hecho en brave-core `local/huella-127` (1608096de2c).

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

## Nivel 130 (inventario, 15-10, MOTOR-9; nada portado → FlyWeb 1.14)

Inventario de FM.20, **para decidir COORDINACIÓN antes de portar**. Fuentes: web-features 3.42.0 + BCD 8.1.5
(`baseline-nivel.js 130`), flags de `runtime_enabled_features.json5` entre la **129.0.6668.112** y la **130.0.6723.192**
(cabeza de la rama 6723; `flags-nivel.py`), `base::Feature` de red, content y Blink entre las mismas etiquetas, y la API
pública de V8 entre la **12.9.202.28** y la **13.0.245.25**. Lista de commits: `FlyWeb/tools/port/nivel130-commits.tsv`.
**Medidas sobre la 1.13:** primero se midió sobre la 116 sola (sin brave-core en la sesión); el 15-10, con brave-core
en lectura, se repitió todo sobre la 116 + los parches de `nube/motor-129` 325686916c (`medirng.sh`, con el traductor
de LayoutNG). Apenas cambia: *nested declarations* 99/31 (11 de sus 26 ficheros ya llevan parche nuestro), `text-wrap`
39/20 (13 de 20), `RTCDataChannel` transferible 44/8, `KeyboardFocusableScrollers` 75/67; el resto, igual. Las cifras
de abajo son las de la 1.13 donde difieren.

**Resumen: nivel mediano, sin porte grande y con un salto de V8 barato.** Tres portes de Baseline de 1–3 días
(*nested declarations*, `text-wrap` y `RTCDataChannel` transferible), uno pequeño (`togglePopover({force})`), dos
funciones que llegan solas con la V8 13.0 y ~12 flags pequeñas. Estimación: **8–10 días de MOTOR** (la misma unidad
que el 129), una ronda de SEGURIDAD-PORTES-2 (FS.14) y dos compilaciones de LOCAL. **Regla 18: sale entero como 1.14,
con la V8 13.0**; no hay nada del tamaño de RubyLB que justifique partirlo.

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
- **(iv)** `MutationEvents` apagado. **Chrome no los apagó en la 127:** `MutationEvents` sigue en `stable` en la
  127.0.6533.144, la 128.0.6613.194 y la 129.0.6668.112, y `content/child/runtime_features.cc` solo los enciende con
  `--mutation-events-enabled`. Se apagan en la 130 (cc4fc38654c, «Land in M130»). No se nos escapó. Sí se escaparon
  otros cambios «por defecto» (§9).
- **(v)** `KeyboardFocusableScrollers`, `ShapeOutsideWritingModeFix` y `TextInputNotAlwaysDirAuto`, fuera de la 1.14.
  Si alguna de sus WPT entra en `wpt-130-lista.txt`, se escribe como diferencia conocida en `version-1.14.md` y aquí.
  **Estimación de `KeyboardFocusableScrollers`: 3–4 días de MOTOR** más una ronda de pruebas de foco de LOCAL.
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

## Apuntado para niveles futuros

- **143 — `onselectionchange` como atributo de elemento** (`<div onselectionchange=…>`, `setAttribute`): Chromium
  añade `kOnselectionchangeAttr` a la tabla `AttributeTriggers` de `html_element.cc` en la 143. De la 120 a la 142,
  `selection/textcontrols/onselectionchange-content-attribute.html` y `selectionchange-bubble.html` están en
  `TestExpectations` como `[ Timeout ]`, así que en el nivel 127 cuentan como «igual que Chrome 127» (MOTOR-3,
  COORDINACIÓN-4, 12-10).

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
