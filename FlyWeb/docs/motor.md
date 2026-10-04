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
   más: si una web cree que somos la 120, es porque lo somos en lo que usa. (FlyWeb 1.1: 117.)
5. **Flags, caso por caso, nunca en bloque.** Lo que está tras un flag en la 116 puede estar incompleto o ser una
   versión antigua de la especificación. Ejemplo: el `harmony_array_grouping` de la V8 11.6 ya instala
   `Object.groupBy`/`Map.groupBy`, pero también `Array.prototype.groupToMap`, que no publicó ningún navegador; por eso
   no se enciende el flag tal cual, sino que se parchea como lo dejó la V8 11.7 (la de Chrome 117).
   JavaScript: parche de V8 cuando el código está en la 11.6; si no, polyfill en un componente.
6. **Validación:** una página de comprobación por nivel (`FlyWeb/tools/motor-N.html`, sin red) y las
   web-platform-tests de cada función en `wpt.live`, comparadas con el Chrome que la publicó (`wpt.fyi`).
7. **Seguridad:** cada función portada o encendida añade código al renderer; sus correcciones posteriores entran en la
   vigilancia de CVE (`cve-triage.md`).
8. **Coste por porte, una sola vez:** la base no se mueve, así que un porte no hay que rehacerlo con cada versión de
   Chromium.

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

## Nivel 117 (hecho en código, 04-10; pendiente de compilar y probar → FlyWeb 1.1)

- **CSS:** brave-core `nube/motor-117` = paso 46. En la 116 todo el CSS de la 117 estaba hecho y apagado. Se encienden
  6 flags: `LayoutNGSubgrid` (subgrid), `CSSInitialPseudo` (`@starting-style`; en la 117 se llama
  `CSSStartingStyle`), `CSSTransitionDiscrete` (`transition-behavior`), `CSSTopLayerForTransitions` (`overlay`),
  `CSSTextWrapPretty` y `CSSContainIntrinsicSizeAutoNone`. Además se adelanta **`light-dark()`** (de la 123): la 116 ya
  la tenía como `-internal-light-dark()` para sus hojas internas; ahora es pública.
- **JavaScript de la 117:** `Object.groupBy` y `Map.groupBy` con parches de V8 (`patches/v8/`): el flag pasa a
  «shipping» sin `groupToMap` y con el arreglo de la 11.7 para objetos grandes. Los iterator helpers, que estaban en la
  11.7 como «staged», siguen apagados (Chrome los publicó en la 122).
- **Versión declarada: 117** (User-Agent y client hints; `browser/flyweb/declared_version.*`). Siguen con 116 la red
  del sistema (componentes, actualizador, Safe Browsing) y las extensiones que lean la versión real.
- **Comprobación:** `FlyWeb/tools/motor-117.html` (20 comprobaciones; las 14 de CSS dan «ok» en Chromium 141; las de JS y versión, según el navegador) y las
  web-platform-tests enlazadas en la página.

## Inventario: CSS Baseline publicado después de la 116

Datos de [web-features](https://www.npmjs.com/package/web-features) 3.40.1 (el catálogo de Baseline) y del fichero de
flags de la 116 (`runtime_enabled_features.json5`). De 102 funciones de CSS posteriores a la 116, estas 46 son
Baseline; el resto son solo de Chrome.

| Chrome | Función | Baseline | En la 116 |
|---|---|---|---|
| 117 | @starting-style | reciente | flag (`CSSInitialPseudo`) |
| 117 | Subgrid | amplia | flag (`LayoutNGSubgrid`) |
| 117 | transition-behavior | reciente | flag (`CSSTransitionDiscrete`) |
| 118 | cap unit | amplia | no está |
| 118 | rcap unit | reciente | no está |
| 118 | transform-box | reciente | no está |
| 119 | :user-valid and :user-invalid | amplia | no está |
| 119 | Clip path boxes | amplia | no está |
| 119 | rect() and xywh() | amplia | no está |
| 120 | :dir() | amplia | flag (`CSSPseudoDir`) |
| 120 | Exponential functions (CSS) | amplia | flag (`CSSExponentialFunctions`) |
| 120 | Masks | amplia | no está |
| 120 | Nesting | amplia | no está |
| 120 | scripting media query | amplia | no está |
| 121 | Spelling and grammar text decorations | reciente | no está |
| 121 | scrollbar-color | reciente | flag (`ScrollbarColor`, test) |
| 121 | scrollbar-width | reciente | flag (`ScrollbarWidth`) |
| 123 | align-content in block layouts | reciente | no está |
| 123 | field-sizing | reciente | no está |
| 123 | light-dark() | reciente | interno (`-internal-light-dark`) |
| 123 | paint-order | amplia | no está |
| 124 | Vertical form controls | reciente | flag (`FormControlsVerticalWritingModeSupport`) |
| 125 | :state() | reciente | no está |
| 125 | Active view transition | reciente | no está |
| 125 | Relative colors | reciente | no está |
| 125 | round(), mod(), and rem() | reciente | flag (`CSSSteppedValueFunctions`) |
| 125 | view-transition-class | reciente | no está |
| 127 | font-size-adjust | reciente | flag (`CSSFontSizeAdjust`, test) |
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
