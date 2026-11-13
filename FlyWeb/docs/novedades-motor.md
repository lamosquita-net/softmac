# Novedades de los motores: Chrome 157 y 158 (informe 1)

INVESTIGACIÓN-MOTOR-9, 09-11-2026. Encargo de Titín (09-11) vía COORDINACIÓN-35: vigilar las novedades de Blink, V8, CSS y
API web y **proponer**. Solo papel; nada compilado. Base de FlyWeb: 3.0.0 = Chromium 156.0.8078.90, V8 15.6.
MOTOR implementa solo lo que apruebe Titín, dentro de una 3.x.

Etiquetas de evidencia: **[P]** fuente primaria leída hoy (URL en §6) · **[S]** fuente secundaria · **[I]** inferencia mía
(razonada, no medida) · **[N]** no comprobado. Costes: **S** ≤ 1 día de MOTOR, **M** unos días, **L** semanas o toca
GPU/red/sandbox. Los costes son [I]: no pude leer los historiales de commits (gitiles pide inicio de sesión), así que se
basan en el estado de las banderas en la 156, 157 y 158 y en el tipo de componente.

## 1. Calendario [P]

| Versión | Estado | Fecha | V8 |
|---|---|---|---|
| 156 | nuestra base (Extended) | — | 15.6 |
| **157** | **estable** (157.0.8103.39 en Mac) | 03-11 | 15.7 |
| **158** | rama 8127; 158.0.8127.18 en el canal estable de Mac desde el 04-11 (despliegue escalonado); estable completa **17-11** | 17-11 | 15.8 |
| 159 | beta; estable 08-12 | 08-12 | — |

La 157 tiene 213 correcciones de seguridad según prensa [S] (Impress Watch); eso es de SEGURIDAD-PORTES (FS.42), no de aquí.
`developer.chrome.com/blog/chrome-157-beta` se pinta con JavaScript y no se puede leer con `curl`; uso la API de chromestatus,
que es de donde la entrada del blog saca la lista [P].

## 2. V8 (15.6 → 15.7 → 15.8) [P]

Comparado `src/flags/feature-flags.h` y `flag-definitions.h` de las ramas 15.6, 15.7 y 15.8:

- **15.7: ninguna función de JavaScript nueva.** Solo se recoloca `wasm compact_imports` (a «pre-staged»).
- **15.8:** `RegExp \A \z \Z` (límites de búfer) pasa a *staged* (aún apagado) y Wasm `custom_descriptors` sigue *staged*;
  `harmony_struct` sale de la lista de experimentales. Nada se enciende de serie.
- Internos: `forin_enumerator_holder` (optimiza `for-in`, encendido) y retoques de Maglev/Turbolev; **`turbolev` sigue apagado**
  en 15.6, 15.7 y 15.8. `maglev` sigue encendido.
- **Conclusión [I]:** por funciones, **no hay motivo para subir V8 de la 15.6**. Lo único que justifica tocar V8 son los
  arreglos de seguridad (SEGURIDAD-PORTES). AVX/Mojave: nada en estas banderas lo toca, pero **[N]** no audité los commits de
  15.6→15.8 (sí haría falta para una subida de V8).

## 3. Chrome 157: novedades [P] (chromestatus, milestone 157)

Columna «156»: estado de la bandera en el código de la rama 8078 (la nuestra). «Flip» = ya existe en la 156 tras bandera y el
porte es, sobre todo, encenderla y traer los arreglos [I].

| Novedad | ¿La usan webs reales? | Otros motores | 156 | Coste | Mojave / sin AVX | Propuesta |
|---|---|---|---|---|---|---|
| CORS en **Background Fetch** (seguridad: saltaba CORS/LNA) | No de forma apreciable [I] | sin señal | API estable en 156 | S (endurecimiento) | no | **Sí** (seguridad, regla 17) |
| CSS `position-visibility: anchor-valid / anchor-visible` (+ alias de los plurales) | Poco; es anclaje de la 1.15.2 [I] | Safari lo trae | no comprobado | S | no | Sí, junto al anchor ya portado |
| CSS `text-overflow: <string>` | Poco [I] | Firefox y Safari lo traen | `TextOverflowString` experimental → **flip** | S | no | Sí |
| CSS `text-decoration-inset` | Poco [I] | Firefox y Safari | la propiedad ya está definida en 156 | S | no | Sí |
| `ProgressEvent` en service workers | Raro | Firefox y Safari | ausente | S | no | Sí (trivial) |
| Long Animation Frames: `styleDuration` / `forcedStyleDuration` | Solo herramientas de medida | sin señal | experimental (en 158 estable) | S | no | Sí, si se quiere paridad; baja prioridad |
| **Métodos nuevos de insertar HTML** (`before/after/append…` con HTML y `streamAppendHTML` con `WritableStream`) | Aún nada [I]; lo usarán frameworks | Firefox «positivo» | ausente | M | no | Esperar (ver §5) |
| **HTML-in-canvas** (`CanvasDrawElement`: dibujar DOM en un canvas) | No: lo prueban demos | Safari «positivo», Firefox sin señal | experimental → estable en 157 | **L** | toca pintado y GPU; en Mojave pasa por nuestro ANGLE Metal 2.1 [I] | **No ahora** |
| Web Bluetooth: `BluetoothRemoteGATTServer` es `EventTarget` | No | Firefox y Safari en contra | — | S | — | **No** (Web Bluetooth cerrado por Brave; regla 20) |
| Capability elements: modo solo icono (`<camera>`…) | No | sin señal | — | S | UI de permisos | No |
| WebGPU `atomic-vec2u-min-max` | No | Safari «positivo» | — | S | **WebGPU apagado (CVE-2026-5281)** | No aplica |
| Desconexión de WebSockets al entrar en BFCache (despliegue escalonado) | Sí, en teoría: apps con WS | Safari ya lo hace | bandera estable en 156 | — | no | Ya está; sin acción |
| Origin trials: Connection Allowlists, Overscroll Areas; en flag: Decisions API, Popup Capability Delegation, `flow-start/end` | — | — | — | — | — | No (experimentos) |
| Language Detector en Android | — | Firefox en contra | — | — | solo Android | No aplica |

## 4. Chrome 158: lo que se sabe [P]

La lista de «habilitado por defecto» está cerrada (rama 8127 cortada); lo que cambie hasta el 17-11 serán retoques.

| Novedad | ¿Webs reales? | Otros motores | 156 | Coste | Mojave / sin AVX | Propuesta |
|---|---|---|---|---|---|---|
| **Eliminar XSLT** (despliegue escalonado; la bandera `XSLT` deja de ser «stable» en 8127) | Muy poco: feeds RSS antiguos y sitios viejos [I] | Firefox y Safari «positivo» | estable | S (apagar) | no | **Sí, a debate** (superficie de ataque; ver §5) |
| `::highlight(*)` (selector universal de resaltado) | Poco | Safari a favor | experimental → **flip** | S | no | Sí |
| Seudoclases de medios `:playing :paused :seeking :buffering :stalled :muted :volume-locked` (foco de Interop 2026) | Algo: estilos de reproductores [I] | Firefox y Safari ya | no comprobado | S–M | no | **Sí** |
| SVG `textPath side` | Poco | Firefox ya | experimental → **flip** | S | no | Sí |
| `object-fit` / `object-position` en SVG de `<object>`/`<embed>` | Poco | Firefox ya | — | S | no | Sí |
| `OfflineAudioContext` renderizado incremental | Poco | sin señal | ausente | M | no | Baja prioridad |
| WebTransport: `draining`, `reliability`, flujos concurrentes anticipados | Poco (HTTP/3 aún minoritario) [I] | Safari ya | experimentales en 156 (`reliability` estable en 157) → **flip** | S–M | red: QUIC | Baja prioridad; revisar huella QUIC (FM.46) antes |
| Permissions Policy `focus-without-user-activation` | Raro | Safari a favor | experimental → **flip** | S | no | Sí (endurece embebidos) |
| `<install>` / **Web Install API** (`navigator.install()`) | No | **Safari en contra** | — | M | sin soporte en nuestra UI | **No** (superficie y regla 20) |
| **WebHID** en Android (la entrada es de Android: en escritorio ya es estable en el código de la 156) | No | Firefox y Safari **en contra** | escritorio: ya estable; Android: experimental | — | no aplica a Mac | **Sin acción de portado; comprobar que FlyWeb la tiene apagada en Mac** (huella; regla 20) |
| Direct Sockets: multicast con fuente (solo IWA) | No | sin señal | — | — | — | No aplica |

## 5. Lectura crítica

1. **Nada de esto se nota en claude.ai [I].** Ninguna de las ~35 entradas es una función que una app React con streaming de
   `fetch` necesite. No puedo comprobarlo desde aquí: chromestatus da contadores globales, no por sitio **[N]**. Si Titín
   quiere el dato, LOCAL puede abrir claude.ai en FlyWeb con DevTools y comprobar qué APIs de la lista llama (coste: una hora).
2. **La diferencia con Chrome es pequeña y mayormente «flip».** Varias novedades (7 con nombre de bandera confirmado) ya están en el código de la 156 tras bandera
   experimental (`TextOverflowString`, `CSSCustomHighlightUniversalSelector`, `SVGTextPathSideAttribute`,
   `WebTransportDraining`/`Reliability`/`AnticipatedConcurrentIncomingStreams`, `BlockingFocusWithoutUserActivation`). Encenderlas es
   barato, pero **cada bandera encendida cambia lo que declaramos ser**: FlyWeb se identifica como Chrome 156 (versión declarada
   = nivel completo). Anunciar funciones de la 157/158 con un UA de la 156 es detectable; las webs que sondean por
   *feature detection* no se quejan, las que cruzan UA y funciones, sí **[I]**. Conviene decidir si las 3.x suben el nivel
   declarado o se quedan en 156 con «extras».
3. **XSLT:** la propuesta con más sentido para FlyWeb no es portar sino **apagar antes que Chrome** (libxslt tiene historial
   largo de CVE [N: no he contado cuántos en el triaje propio]). Riesgo: feeds RSS/Atom con hoja XSLT dejan de verse con estilo
   (el contenido sigue ahí). Antes de decidir, que SEGURIDAD-VIGÍA cuente los CVE de libxslt/`XSLTProcessor` de los últimos 24
   meses.
4. **HTML-in-canvas** es lo más llamativo y lo menos oportuno: L, solo Safari «positivo», especificación aún como borrador de
   trabajo, y en Mojave pasaría por la ruta Metal 2.1 que estamos terminando de estabilizar (B1d). Esperar a que otro motor lo
   envíe.
5. **WebHID, Web Install, Web Bluetooth, Direct Sockets:** aumentan superficie y huella, Firefox y Safari los rechazan. Brave ya
   cierra Web Bluetooth (`kBraveWebBluetoothAPI`). **No** portar los nuevos. WebHID ya está estable en escritorio en el código de la 156 (la entrada de la 158 es de Android): LOCAL
   debe comprobar si FlyWeb 3.0.0 la expone en Mac y, si sí, proponer apagarla.
6. **V8:** quedarse en 15.6 + arreglos de seguridad (§2).

## 6. Propuestas para Titín (por orden)

1. **Apagar XSLT** en la próxima 3.x (S), previa cuenta de CVE y de sitios afectados. *Seguridad, no funciones.*
2. **Tanda «CSS y medios de la 157/158» (S–M, un solo porte):** `text-overflow: <string>`, `text-decoration-inset`,
   `anchor-visible/valid`, `::highlight(*)`, seudoclases de medios, SVG `textPath side`, `object-fit` en SVG embebido,
   `ProgressEvent` en SW. Es paridad con Firefox/Safari, bajo riesgo, sin GPU ni AVX.
3. **Endurecimientos de seguridad:** CORS en Background Fetch y `focus-without-user-activation` (S). Se pueden meter en la tanda
   de SEGURIDAD-PORTES de la 3.0.x.
4. **Comprobar y, si hace falta, apagar WebHID (ya en escritorio desde antes), Web Install y Direct Sockets** en las políticas/args de la 3.x (S; la comprobación la hace LOCAL) y anotarlo en `rebranding`/
   `brave-propio` como decisión de privacidad.
5. **Dejar para otro informe:** HTML-in-canvas, métodos de inserción de HTML por *streaming*, WebTransport, `OfflineAudioContext`.
6. **No subir V8** por funciones.

**Pendiente de decisión previa:** la política de versión declarada (§5.2): si no se decide, MOTOR no debería encender ninguna
bandera de funciones. La tanda 2 solo es «gratis» si se acepta mostrar paridad parcial con la 157/158.

## 7. Fuentes [P]

- chromestatus: `https://chromestatus.com/api/v0/features?milestone=157` y `…=158`; `https://chromestatus.com/api/v0/channels`.
- Calendario y V8 por hito: `https://chromiumdash.appspot.com/fetch_milestones`, `…/fetch_releases?channel=Stable&platform=Mac`.
- Estado de banderas por rama (8078 = 156, 8103 = 157, 8127 = 158): `https://chromium.googlesource.com/chromium/src/+/refs/branch-heads/<rama>/third_party/blink/renderer/platform/runtime_enabled_features.json5`.
- V8: `https://chromium.googlesource.com/v8/v8/+/refs/branch-heads/15.{6,7,8}/src/flags/feature-flags.h` y `flag-definitions.h`.
- [S] Impress Watch (213 correcciones de seguridad de la 157): `https://forest.watch.impress.co.jp/docs/news/2153357.html`.

Límites: no leí `developer.chrome.com` (se pinta con JS), no audité commits de V8 ni de Blink, no medí uso en sitios reales, y
los costes son estimaciones por tipo de componente.

*Siguiente informe: cuando salga la 158 estable (17-11) o la 159 (08-12); sesión archivada entre informes.*

---

# Informe 2, parte A: tendencias de los estándares web (diseñador)

INVESTIGACIÓN-MOTOR-10, 13-11-2026. Encargo de Titín vía COORDINACIÓN-41. **Enfoque cambiado por Titín el 13-11:** se quitan los
navegadores para macOS viejos; el foco son las **últimas tendencias de los estándares** (HTML, CSS, TC39, WICG, APIs), aunque
ningún navegador las tenga o solo uno. Titín decide como diseñador web qué queremos en FlyWeb y la idea es poder traerlo
**antes que otros**. Gecko y WebKit entran como fuente de qué se está implementando. Solo papel; nada compilado. La parte B
(Chrome 158 estable) llega el 17-11. Base de FlyWeb: 3.1.x = Chromium 156.0.8078.90, V8 15.6; se declara 156 (decisión 8 del plan de la 3.x).

Etiquetas: **[P]** fuente primaria leída hoy · **[S]** secundaria (buscador, MDN o WebKit vistos solo en el resumen del buscador) ·
**[I]** inferencia mía · **[N]** no comprobado. **Hito** = una tanda de MOTOR: **S** ≤ 1 día, **M** 2–5 días, **L** semanas o
GPU/red/sandbox (igual que el informe 1; los costes son [I]).

## 1. Lo que hay que saber primero

1. **Casi todo lo que hoy ilusiona a un diseñador ya está en nuestra 156.** Chrome lo lanzó hasta la 156 (§3).
   El hueco real frente a Chrome es pequeño: lo de la 157/158/159 (§4) y unas pocas piezas que Firefox o Safari tienen y Chrome no.
2. **Lo que Titín quiere adelantar** (masonry/grid lanes, `@mixin`/`@apply`, HTML en canvas…) **no son «cuatro
   cosas que se portan»**: unas ya viven en la 156 tras bandera de Blink y otras están en especificación inestable. El riesgo
   principal no es el coste de portar, sino **que la sintaxis cambie** después de que un diseñador la use (§4.1 y §7).
3. **Una palanca barata que no estaba en el informe 1:** un **«modo diseñador» opcional y apagado por defecto** que
   encienda las banderas experimentales de Blink. Permite probar masonry, mixins o HTML-en-canvas hoy, sin cambiar lo que
   FlyWeb declara a las webs de todos los usuarios (decisión 8). Hay que comprobar antes si FlyWeb ya expone esa página de
   banderas (§7, propuesta 2).
4. **Las tendencias se ven en Interop 2026** (§5): los tres motores se comprometen a igualar 20 áreas. Lo que está ahí es
   lo que llegará a todos.
5. **Las propuestas de IA para el navegador** (Prompt API, WebMCP) las rechazan Firefox y Safari (§4.7): encaja con
   nuestra regla 20 (privacidad); no se portan.

## 2. Método, fuentes y límites

- Lectura primaria (curl): paquete npm `web-features` 3.46.0 (publicado el 13-11; Baseline y versiones de Chrome/Firefox/Safari
  de MDN BCD); chromestatus (hitos 129–161, con la posición de Firefox y Safari); `runtime_enabled_features.json5` de las ramas
  8078 (nuestra 156), 8103 y 8127; `feature-flags.h` de V8 15.6 y 15.8; `tc39/proposals` (etapas 2–4 y terminadas);
  `web-platform-tests/interop` (2026); issues de `mozilla/` y `WebKit/standards-positions` (búsqueda de GitHub).
- **No pude leer** `webkit.org`, `developer.apple.com`, `developer.mozilla.org`, `mozilla.org`, `web.dev` ni los borradores del
  CSSWG/WHATWG: el entorno de la nube no los permite (probé; la petición de añadirlos quedó sin respuesta). Lo que cito de
  esas páginas viene del **resumen del buscador [S]**. Si Titín quiere notas de lanzamiento de Firefox y Safari leídas de
  primera mano, hay que añadir esos hosts al entorno.
- `web-features` va con retraso respecto a los lanzamientos y a veces discrepa de chromestatus o de MDN; lo señalo donde pasa.
- **Uso en webs reales:** chromestatus da contadores globales, no por sitio **[N]**. No puedo decir qué usa claude.ai. Como en
  el informe 1, lo comprobaría LOCAL con DevTools (una hora). En general, casi nada de esto se nota en claude.ai **[I]**.
- «Ya en la 156» significa: Chrome ≤ 156 lo trae habilitado por defecto **[P]**. Que **FlyWeb** lo exponga igual **[N]**:
  Brave u otro parche nuestro podría haberlo apagado. Propuesta 1 (§7): una página de comprobación.

## 3. Ya en la 156 (no cuesta nada portar; comprobar que sigue encendido)

Por temas. Versión de Chrome que lo estrenó; F = Firefox, S = Safari [P: web-features/chromestatus].

| Tema | Lo que ya tenemos | Chrome | F / S |
|---|---|---|---|
| Maquetación | anchor positioning (+ transformaciones, animaciones), `stretch`, gap decorations (`column-rule` en flex/grid), `reading-flow`, `scroll-snap-type: pair` y contenedores de un eje, `flex-wrap: balance`, columnas con salto en multicol, `text-wrap` balance/pretty, `scrollbar-gutter` | 94–156 | gap decorations y `stretch`: F/S a favor; `reading-flow`: sin señal |
| Contenedores | `@container` de estilo (`style()`), de nombre, de estado de scroll (`scroll-state`), de anclaje | 111–148 | F 151 / S 18 los de estilo; `scroll-state`: solo Chrome |
| Tipografía | `text-box-trim`/`text-box`, `text-fit`, `font-size-adjust`, `hyphenate-limit-chars`, `ruby-overhang`, `text-decoration-skip-ink: all`, `text-decoration-skip-spaces`, `margin-trim` | 109–155 | `text-box`: F 154 [S], S 18.2; `text-fit`: sin señal |
| Animación | scroll-driven animations, view transitions (mismo doc, entre documentos, tipos, grupos anidados, `match-element`, **ámbito de elemento**), `@starting-style`, `interpolate-size`/`calc-size()`, `sibling-index()`, scroll-triggered animations (`animation-trigger`) | 111–147 | scroll-driven: F 159, S 26; ámbito de elemento y triggers: solo Chrome |
| Color | `contrast-color()`, `light-dark()` con imágenes, `alpha()` relativo, `relative color`, `color-mix` (2 colores), `oklch`, `@property` | 120–152 | contrast-color: F 146, S 26 |
| Formas | `shape()`, `corner-shape`/`superellipse`, `border-shape`, `polygon()` con `round` | 135–150 | `shape()`: F 148, S 18.4; `corner-shape`: S a favor; `border-shape`: sin señal |
| Funciones CSS | `if()`, `@function`, `attr()` tipado, **`random()`**, aritmética tipada | 133–156 | `if()` y `@function`: S a favor, F sin señal; `random()`: S sí, F tras opción [S] |
| Formularios y componentes | `<select>` personalizable (+ listbox), `popover` (incl. `hint`), `<dialog closedby>`, `:open`, `command`/`commandfor`, `focusgroup`, `interestfor`, `field-sizing`, `<details name>`, `::details-content`, carruseles (`::scroll-button`, `::scroll-marker`, `scroll-target-group`) | 114–150 | `interestfor`: S **en contra**, F neutral; carruseles y `focusgroup`: sin señal (F positivo en focusgroup) |
| Plataforma | Navigation API (+ precommit), scoped custom element registries, `moveBefore()`, Sanitizer API (`setHTML`), `<template for>` (parches de HTML en streaming), Observable, speculation rules | 102–150 | Observable: F **en contra**, S a favor |
| JavaScript (V8 15.6) | Temporal, Iterator helpers + `join`/`sequencing`/`includes`/`zip`, `Set` methods, `Promise.try`, `RegExp.escape`, `Math.sumPrecise`, `Uint8Array` base64, `Float16Array`, `getOrInsert`, `using` (ERM), JSON/import attributes y `import text`, JSPI de Wasm | 117–154 | Temporal: F 139, S en desarrollo; ERM: S no |
| Imagen | **JPEG XL** (`image/jxl`) | 155 | F 158, S 17 |

Notas:
- **Interest invokers:** web-features dice Chrome 149, chromestatus lo lista en el 142: las fuentes discrepan. Safari está en contra **[P]**.
- **JPEG XL** (Chrome 155) y los *capability elements* (`<geolocation>` 144, `<camera>`/`<microphone>` 153) son **superficie nueva** en
  la 156 que el informe 1 no revisó. JPEG XL añade un decodificador de imágenes; los capability elements, interfaz de permisos.
  Propuestas 1 y 6 (§7).
- En V8 15.6 hay en *experimental/staged* **[P]**: decoradores, ShadowRealm, `import source` (fase de fuente), `\A \z \Z` de RegExp,
  ArrayBuffer inmutable, `import bytes` y `import defer`. Faltan **iterator chunking** (etapa 4, 2027) y `Math.clamp` (etapa 2) **[P por ausencia en las banderas]**.

## 4. La frontera: lo que no tenemos o aún nadie ha cerrado

### 4.1 Maquetación

| Novedad y ejemplo | Spec | Chrome / Firefox / Safari | Riesgo · polyfill | En 156 · coste | Propuesta |
|---|---|---|---|---|---|
| **Grid lanes** (masonry). `.galeria { display: grid-lanes; grid-template-columns: repeat(auto-fill, minmax(14rem,1fr)); }` Piezas que se colocan en el carril con más hueco | css-grid-3 (borrador) | Chrome **bandera** (`CSSGridLanesLayout`, experimental en 156/157/158) [P]. Safari lo lanzó (26.4 según Apple [S]; web-features marca 27.2 y 27.2 «renombró una propiedad» [S]). Firefox: no lo tiene [N] | **Alto**: la sintaxis cambió (masonry → grid-lanes → propiedad renombrada). Polyfill: librerías JS (masonry) o `columns` | bandera en 156 → **M** (encender, WPT, accesibilidad del orden) si el motor está completo; **L** si no [N] | **Esperar** a que Chrome la encienda; mientras, solo bajo «modo diseñador» |
| **`:heading` y `revert-rule`** | selectors/cascade (WD) | solo Safari 27 [S] | bajo · ninguno | ausentes · **S** cada una | No ahora |
| `position-visibility: anchor-valid/visible` + plurales | css-anchor-position | Chrome 157, F 147, S 26.2 [P] | bajo · no | **S** | **Sí** (ya en informe 1) |
| Propiedades abreviadas de esquina (`corner-*`) | css-borders-4 | Chrome 160 [P chromestatus]; F a favor, S en desarrollo | medio | no en 156 · **S** cuando salga | Esperar a la 160 |

### 4.2 Tipografía

| Novedad y ejemplo | Spec | Quién | Riesgo · polyfill | En 156 · coste | Propuesta |
|---|---|---|---|---|---|
| **`text-autospace`** (espacio entre CJK y latín). `text-autospace: normal;` | css-text-4 | F 145, S 27; Chrome **no** [P] | bajo · JS que inserta espacios | no (sin bandera por nombre) · **M–L** (maquetado) | No: afecta sobre todo a CJK |
| `hanging-punctuation` | css-text-4 | solo Safari 26.5 | bajo · ninguno | **M** | No |
| `font-width` / `font-variant-position` | css-fonts | S 18.4 / F 34 | bajo | **S** | No |
| `text-overflow: <string>`, `text-decoration-inset` | css-overflow/text-decor | Chrome 157, F y S | bajo | **S** (flip) | **Sí** (informe 1) |
| `generic()` (familias genéricas) | css-fonts-5 | propuesta; Mozilla a favor [P] | medio | no · — | Vigilar |
| `text-size-adjust` sin prefijo | css-size-adjust | propuesta en WebKit (#720) [P] | bajo | **S** | Vigilar |

### 4.3 Animación y transiciones

| Novedad y ejemplo | Spec | Quién | Riesgo · polyfill | En 156 · coste | Propuesta |
|---|---|---|---|---|---|
| **Pseudoclases de medios** `video:paused::after{…}` (`:playing :muted :buffering :seeking :stalled :volume-locked`) | selectors-4 (Interop 2026) | Chrome 158, F 150, S 15.4 [P] | bajo · clases con JS | no · **S–M** | **Sí** (informe 1) |
| **Triggers de animación** (`animation-trigger`, `trigger-scope`) | animation-triggers-1 (borrador) | Chrome 146; F y S sin señal [P] | **alto** (spec joven, un solo motor) | ya · — | Ya lo tenemos; avisar a diseñadores |
| **Vista transiciones: ámbito de elemento** `el.startViewTransition(…)` | css-view-transitions-2 | Chrome 147; resto sin señal | alto | ya | idem |
| `::highlight(*)` y extensiones de la Custom Highlight API | css-highlight-api | Chrome 158, S a favor; F a favor; extensiones: propuestas nuevas (#1480) | bajo | bandera en 156 · **S** | **Sí** (informe 1) |
| `object-fit` en SVG de `<object>/<embed>` | svg | F ya | bajo | **S** | Sí (informe 1) |

### 4.4 Color

| Novedad y ejemplo | Spec | Quién | Riesgo · polyfill | En 156 · coste | Propuesta |
|---|---|---|---|---|---|
| **`color-mix()` con 3+ colores**. `color-mix(in oklch, red 20%, blue 30%, green)` | css-color-5 (borrador) | F 150, S 27; Chrome **no** [P] | bajo (ampliación simple) · Sass/JS | no (sin bandera por nombre) · **S–M** (parser, serialización, WPT) | **Sí** |
| **`<input type=color alpha colorspace="display-p3">`** | HTML | S 18.4; resto no [P] | bajo | no · **M** (panel de color de macOS) | No ahora |
| HDR: `dynamic-range-limit`, tone mapping de Canvas2D (Chrome 160) | CSS/WHATWG | Chrome 136 y 160; F/S sin señal | medio | `dynamic-range-limit` ya | Vigilar |

### 4.5 Formularios y componentes

| Novedad y ejemplo | Spec | Quién | Riesgo · polyfill | En 156 · coste | Propuesta |
|---|---|---|---|---|---|
| **HTML en canvas** `<canvas content="drawable">` (texto y DOM en un canvas, accesible) | WICG | Chrome 157; S a favor; F sin señal | alto · no | bandera en 156 (`HTMLInCanvas`) · **L** (pintado/GPU, ANGLE Metal) | **No ahora** (informe 1) |
| **Métodos nuevos de insertar HTML** `el.setHTML(html)`, `beforeHTML`, `afterHTML`… (+ `streamAppendHTML`, solo especificación) | WHATWG HTML | Chrome 157; resto sin señal; en streaming, nadie | bajo (ya en el estándar) · polyfill sencillo | ausentes, pero el Sanitizer ya está · **M** | **Sí** los de una vez (seguridad: sustituyen `innerHTML`); streaming: no |
| `<model>` (3D en HTML) | WebKit | solo Safari 27 [S] | alto | **L** | No |
| `<geolocation>`, `<camera>`, `<microphone>` | WICG/W3C | Chrome 144/153; `<geolocation>`: F a favor, S sin señal; `<camera>`: Mozilla a favor (#1461) | medio | **ya** | **Comprobar que están apagados o bajo política** (§7, propuesta 6) |
| `<agecheck>`, `<sealedinput>`, WebMCP declarativo | propuestas nuevas | solo propuestas / experimental | — | WebMCP: bandera experimental en 156 [P] | **No** (regla 20) |

### 4.6 JavaScript (TC39)

| Novedad y ejemplo | Etapa | Quién | Riesgo · polyfill | En 156 · coste | Propuesta |
|---|---|---|---|---|---|
| **RegExp `\A \z \Z`** | 3 | F ya; Chrome 159 [P chromestatus]; S sin señal | bajo | V8 15.6 experimental · **S** (encender + mjsunit) | **Sí**, junto al 159 |
| **`import defer`** (evaluación diferida de módulos) | 3 | F 158 solo Nightly [S]; V8 15.6 *staged*; Chrome: sin señal | medio | staged · **S** | Esperar a que Chrome lo encienda |
| **Iterator chunking / `windows`** | 4 (2027) | F sin señal [N]; no en V8 15.6 | bajo · polyfill | ausente · **M** (código de V8) | Esperar (V8 lo traerá) |
| **`import bytes`, ArrayBuffer inmutable** | 2.7 | staged en V8 15.6 | medio | staged · **S** | No (etapa 2.7) |
| **Decoradores, `import source`, ShadowRealm** | 2.7 / 3 | V8 *experimental*; F y S sin señal | alto | experimental | No |
| `Await Dictionary`, `Error.stack` accessor, límites de *thenables* | 3 (nuevas) | ninguno | medio | ausentes | Vigilar |
| `Math.clamp`, `Iterator.range`, pipeline, `SeededPRNG`, `String.dedent` | 2 | ninguno | alto | ausentes | No |

Etapa 4 o anterior ya está en V8 15.6: **Temporal**, Iterator helpers y `join`/`includes`/`sequencing`/`zip`, `Set`, `RegExp.escape`, `Promise.try`,
`Math.sumPrecise`, base64, `getOrInsert`, ERM (`using`) **[P]**. No hace falta portar nada de JavaScript para
estar a la par de Chrome ahora mismo. Wasm: JSPI (Chrome 137, Interop 2026), GC, memory64 y *tail calls* ya están en Chrome ≤ 137 **[P web-features]**.

### 4.7 Plataforma, IA y privacidad

- **Prompt API** (`LanguageModel`): Chrome 160 le añade un modo de muestreo; **Firefox negativo y Safari en contra** [P chromestatus M160]. WebMCP
  y sus atributos de formulario (`toolname`, `tooldescription`): experimentales, sin Firefox ni Safari [P]. **No portar; comprobar
  apagadas** (los nombres de bandera no aparecen en 8078 con el patrón `AIPromptAPI`: **[N]**, verificar).
- **Seguridad que sí conviene mirar** (Mozilla y WebKit a favor): Web Crypto con *streaming* de hash e *híbridos KEM*, WebAssembly Component Model.
  Estados `[P]` en `standards-positions`; coste no estimado [N].
- **Contra:** radio que se desmarca, *customized built-ins* (S en contra), `interestfor` (S), Observable (F). Chrome los lleva, otros no;
  riesgo de cambio o de retirada. Ya los tenemos (§3): no apagarlos por eso, pero avisar a los diseñadores.

## 5. Interop 2026: la lista de lo que llegará a todos [P: `web-platform-tests/interop`]

20 áreas de enfoque (representantes de Apple, Google, Microsoft, Mozilla, Igalia y Bocoup; los tres motores): **container style queries, anchor positioning,
`attr()`, `contrast-color()`, `zoom`, custom highlights, diálogos y popovers (`closedby`, `:open`, `popover=hint`), fetch con *streaming*
de subida y *Range*, IndexedDB `getAllRecords()`, JSPI de Wasm, seudoclases de medios, Navigation API (`precommitHandler`), scoped custom
element registries, scroll-driven animations, scroll snap, `shape()`, view transitions (`blocking=render`, `link rel=expect`,
`:active-view-transition-type()`, entre documentos), web compat (módulos ESM, orden de scroll/animación, `-webkit-user-select`), WebRTC y WebTransport**.
Cuatro investigaciones: accesibilidad, **JPEG XL**, pruebas móviles, WebVTT.
- **Lectura [I]:** casi todo tiene ya Chrome ≤ 156. Lo que falta en nuestra 156: las **seudoclases de medios** (Chrome 158); y quedan por comprobar `:active-view-transition-type()`
  y `rel=expect` **[N]**. Si Titín quiere «la puntuación de Interop como criterio», LOCAL puede correr las WPT de
  `interop-2026-*` en FlyWeb y compararlas con el Chrome 156 de referencia (el método de `motor-N`).

## 6. Gecko y WebKit: qué implementan ahora

- **Firefox 147–158** [S: MDN vía buscador]: módulos CSS (147), `color-mix` multicolor y `light-dark()` con imágenes (150), `@container style()`
  (151), `text-box-trim` y `progress()` (154), `attr()` en cualquier propiedad (155), `named-feature()` (156), `overscroll-behavior: chain` (157),
  aritmética tipada, **JPEG XL por defecto** y `fetch` con ReadableStream (158); tras opción: `random()` y `corner-shape` (158). Firefox 159: scroll-driven
  animations y scoped registries (por web-features [P]); Nightly: `import defer`.
- **Safari 26.4 → 27.3** [S: WebKit/Apple vía buscador]: grid lanes (26.4, propiedad renombrada en 27.2), `hanging-punctuation` (26.5), 58 funciones nuevas en
  Safari 27 (WWDC26): `<select>` personalizable (`appearance: base-select`), `stretch`, `:heading`, `revert-rule`, anclaje con transformaciones,
  `<model>`, `color-mix` multicolor, `text-autospace`. STP 256 (05-11).
- **Lectura [I]:** Firefox y Safari van **detrás de Chrome en componentes de interfaz** (carruseles, `interestfor`, scroll-state) y
  **por delante en maquetación (grid lanes) y tipografía (autospace, hanging-punctuation)**. La tendencia de diseño:
  componentes nativos personalizables, CSS programable (`if()`, `@function`, mixins), formas y esquinas, y transiciones sin JS.

## 7. Propuestas para Titín (marcar sí/no)

Por prioridad. **Ninguna toca V8 ni la versión declarada** (decisión 8: lo nuevo se enciende solo si una web real lo necesita; las marcadas «S» son ajustes pequeños).

1. **[ ] Página de comprobación `diseno-156.html` (LOCAL, S, 1 h):** sondea las ~60 funciones de §3 en FlyWeb 3.1.x y las compara con un
   Chrome 156. Confirma que nada de lo que Chrome lanzó en 105–156 está apagado en FlyWeb por Brave o por parches nuestros, y
   que **JPEG XL, los capability elements, `focusgroup` y `interestfor`** se comportan como se quiere.
2. **[ ] Modo diseñador (opcional, apagado, S–M):** exponer en FlyWeb la página de banderas experimentales de Blink con un aviso («cambia
   lo que las webs ven de tu navegador»), no un cambio en lo declarado. Da a Titín grid lanes, mixins (`@mixin/@apply`),
   HTML-en-canvas y lo que salga **hoy**, sin riesgo para los demás usuarios. Comprobar si ya existe [N].
3. **[ ] Tanda «CSS y medios de la 157/158/159» (M, un solo porte):** informe 1 §6.2 + `color-mix()` multicolor + `::highlight(*)`. Son paridad
   con Firefox/Safari, bajo riesgo.
4. **[ ] Métodos de insertar HTML (`setHTML`, `beforeHTML`…), M:** solo los no *streaming*; refuerzan seguridad.
5. **[ ] RegExp `\A \z \Z`, S:** al salir en Chrome 159 (08-12), junto a la tanda de seguridad.
6. **[ ] Revisar superficie nueva de la 156 (SEGURIDAD-VIGÍA/LOCAL):** decodificador JPEG XL, `<geolocation>`/`<camera>`/`<microphone>`,
   Prompt API y WebMCP: dejar apagado lo que no sirva y anotarlo en `rebranding`/`brave-propio` como decisión de privacidad (regla 20).
7. **[ ] Dejar para más adelante (vigilar):** grid lanes, mixins, `text-autospace`, `:heading`, `revert-rule`, `<model>`, HTML-en-canvas, *streaming* de HTML,
   `import defer`, iterator chunking. Reabrir cuando Chrome o dos motores las enciendan.
8. **[ ] No:** Prompt API, WebMCP, `<agecheck>`, `<sealedinput>`, Web Install, decoradores/ShadowRealm/`import bytes` (etapa 2.7 o inestables).

## 8. Fuentes [P salvo indicación]

- web-features 3.46.0 (npm, 13-11-2026): `https://www.npmjs.com/package/web-features` (datos de MDN BCD).
- chromestatus, hitos 129–161: `https://chromestatus.com/api/v0/features?milestone=<N>`.
- Blink, rama 8078/8103/8127: `https://chromium.googlesource.com/chromium/src/+/refs/branch-heads/<rama>/third_party/blink/renderer/platform/runtime_enabled_features.json5`.
- V8 15.6/15.8: `https://chromium.googlesource.com/v8/v8/+/refs/branch-heads/15.{6,8}/src/flags/feature-flags.h`.
- TC39: `https://github.com/tc39/proposals` (README y `finished-proposals.md`, 13-11-2026).
- Interop 2026: `https://github.com/web-platform-tests/interop/blob/main/2026/README.md`.
- Posiciones: `https://github.com/mozilla/standards-positions/issues`, `https://github.com/WebKit/standards-positions/issues` (búsqueda de GitHub, 13-11-2026).
- [S] Notas de Firefox 147–158: `https://developer.mozilla.org/en-US/Firefox/Releases/158` (y anteriores); Safari 26.4–27.3: `https://webkit.org/blog/17967/news-from-wwdc26-webkit-in-safari-27-beta/`
  y `https://developer.apple.com/documentation/safari-release-notes/safari-27_3-release-notes`; CSS Mixins: hilos de `lists.w3.org/Archives/Public/public-css-archive/` (mar–abr 2026) y *Intent to Prototype: CSS mixins* (blink-dev, 07-2026).
  Vistas solo en el resumen del buscador.

Límites: no medí uso real; no probé nada en un FlyWeb compilado; no leí los borradores del CSSWG ni WHATWG; costes por tipo de componente.

*Siguiente: parte B (Chrome 158 estable) el 17-11, cuando COORDINACIÓN avise.*
