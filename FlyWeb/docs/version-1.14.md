# FlyWeb 1.14 — nivel de motor 130 (MOTOR-10, 15-10-2026)

**Cabeza final:** brave-core `nube/arreglos-1.14` **d12847a77f** (`git ls-remote`, 15-10, MOTOR-11) = 303e498fb5 (abajo) + los
arreglos de la prueba de LOCAL-4: el CHECK de `togglePopover()`, que tumbaba la pestaña (bloqueo), lo que faltaba frente a
las WPT de la 130 y WebSQL apagado de verdad (tabla de abajo). Antes: `nube/escapes-seg-1.14.1` **303e498fb5** =
`nube/motor-130` ccc74ea171 + las dos protecciones de seguridad que se escaparon en la 119–120 (decisión de
COORDINACIÓN-6, 15-10: van en la 1.14, sin esperar a `seg/oopsif`). **No hay 1.14.1** (Titín, 16-10): OOPSIF
(`seg/oopsif`) sale con la 1.15.

| Arreglo (`nube/arreglos-1.14`) | Qué |
|---|---|
| 685f820c68 | **`togglePopover(true)` sobre un popover ya abierto tumbaba la pestaña** (CHECK, también en la Release): el porte del 130 trajo la rama nueva sin la retirada del CHECK de 63e395a18a0 (M117). Y `white-space: <palabra clave>` dejaba 66 «Check failed» (solo ruido) |
| 47ecd3c46d | *Nesting* como Chrome 130: el `&` implícito se escribe al serializar (eaf72aae1cf) y `& {}` dentro de `@media` ya no se muestra como declaraciones sueltas (3bfc51bf4fa); índice opcional en `CSSGroupingRule.insertRule()` (e2ff44d09f5, M121, otro escape); fuera `HTMLTemplateElement.shadowRoot` (398d899d13b) y `DelegatedInkTrailPresenter.expectedImprovement` (1a9049fa8c4) |
| cc316c5c9 | `togglePopover({force})`: el diccionario se admite pero no se lee, como Chrome 130 (solo lo lee con `PopoverAnchorRelationships`, experimental) |
| d12847a77f | **WebSQL apagado de verdad**: `openDatabase` seguía expuesto porque `WebViewImpl` vuelve a encender `Database` desde la preferencia `databases_enabled`; como Chrome 130 en escritorio, FlyWeb la pone a `false` (`BraveContentBrowserClient::OverrideWebkitPrefs`). Lo encontró LOCAL-4 |

**Excepciones escritas frente a CfT 130 (decisiones de COORDINACIÓN-7, 15-10):** (a) `fetch/data-urls/processing.any`
(54/73 frente a 55/73, `data://test:test/,X`): es el análisis de URL de esquemas no especiales según el estándar
(`kStandardCompliantNonSpecialSchemeURLParsing`, encendido en la 130; más de 60 commits en `url/` y en todo Chrome), que
se valora en FM.23; (b) «Nested @scope rule» de `nested-declarations-cssom`: `@scope` está fuera por la decisión de
Baseline; (c) `::part()::details-content` y el estilo calculado de `::part()::placeholder`/`::file-selector-button` en
`pseudo-elements-after-part`: CfT los pasa porque el ejecutor de WPT de Chrome enciende lo experimental
(`DetailsStyling` lo es en la 130); el estilo calculado es el aplazado al 131. Además, `transfer-datachannel` pasa 4/4 en
la 1.14 y CfT 130 da ERROR: Chromium 130 la tiene como `[ Timeout ]` en su `TestExpectations`, así que no es un fallo de la 1.14.

**Estado:** en código en brave-core `nube/motor-130` **ccc74ea171**, con FS.14 fundida (`seg/v8-13.0` d6b66b7994 y
`seg/transfer-keys` 1df157fca7), ORB v0.2 encendido (FS.14) y FS.15 (`seg/popup-sandbox` 1825a087d0). Encima de la 1.13 (325686916c) y de `nube/ruby-003`
(0c95523439, monoespaciada japonesa), lleva la V8 de Chrome 130 (paso a7b5f3f4aa, también en `nube/motor-130-v8`), la
Baseline y las flags del 130, `KeyboardFocusableScrollers`, los apagados que se escaparon (§9–§10 de `motor.md`) y el
recorte de superficie frente a Chrome 129/130. Declara 130 / 1.14. Un solo nivel en una sola versión (regla 18).
**Pendiente:** Static, ASan y Release de LOCAL-4 (el Static del paso de V8 ya está hecho, fila de LOCAL; Static
incremental de 303e498fb5 con `seg-1.14.1.html`). Detalle
técnico: `motor.md`, «Nivel 130», §12; commits: `FlyWeb/tools/port/nivel130-commits.tsv`.

| Dato | Valor |
|---|---|
| Cabeza final | brave-core `nube/escapes-seg-1.14.1` **303e498fb5** (sobre `nube/motor-130` ccc74ea171; paso de V8 en `nube/motor-130-v8` a7b5f3f4aa) |
| Versión visible | 1.14 (`CFBundleVersion` la pone LOCAL en la entrega) |
| Nivel declarado | Chrome 130 (`flyweb_engine_full_version` 130.0.6723.117; `platformVersion` mínimo **11.7.10**) |
| Motor JavaScript | V8 13.0.245.25 (cabeza de la rama 13.0) con los arreglos de seguridad de FlyWeb (FS.14; época de caché **15**). gin con la opción B. `fast_float` 3e57d8dc traído por `build.sh` con suma fija |
| Portes del 130 | *nested declarations* (CSSOM incluido), `text-wrap` como abreviatura, `RTCDataChannel` transferible a un *worker*, `togglePopover({force})`, `KeyboardFocusableScrollers`, espacios en `data:` URL y 8 flags de interoperabilidad |
| Apagados, como Chrome | WebSQL, pantalla completa prefijada de `<video>`, `:--foo`, eventos de mutación, DSD antiguo (`<template shadowroot>`, `includeShadowRoots`), `getInnerHTML()` |
| Encendidos, como Chrome | agrupación por origen por defecto (`document.domain` ya no relaja el mismo origen), ORB v0.2 |
| Seguridad | FS.14 (V8 13.0, época 15; claves de `TransferList`) y FS.15: un iframe con `sandbox` sin `allow-popups` ya no abre pestañas sin *sandbox* con un clic sintético con Ctrl/Cmd (fd7c878da2, crbug 544197473). Más dos que se escaparon en niveles anteriores: `RemoveDanglingMarkupInTarget` (Chrome 119) y `RemoveDataUrlInSvgUse` (Chrome 120; la política `DataUrlInSvgUseEnabled` devuelve el comportamiento antiguo) |
| Interruptor de emergencia del JIT | **desde la V8 13.0, sin JIT no hay WebAssembly** (`jitless` apaga `expose_wasm`, como en Chrome 130). Quien apague el JIT por política (`DefaultJavaScriptJitSetting` = 2) pierde también Wasm en esas webs |
| Superficie, como Chrome 130 | fuera `Sanitizer`/`setHTML()` (los de 2022), `GPUCommandEncoder.writeTimestamp()`, `-webkit-highlight` y `:open`/`:closed`; fuera los polyfills de core-js; dentro las interfaces `SpeechSynthesis` y `SpeechSynthesisVoice` |
| Fuera, con motivo | `PseudoElementsCorrectInGetComputedStyle`, `PaintHighlightsForFirstLetter`, estilos de reserva de `<meter>` y `MultiSmoothScrollIntoView` (dependen de código posterior a la 116; van al 131, aprobado por COORDINACIÓN-6); `ShapeOutsideWritingModeFix` y `TextInputNotAlwaysDirAuto` (decisión v); lo no Baseline |
| `getInnerHTML()` | apagado (c5a094a9ab) y **se queda así**: LOCAL-4 lo comprobó en CfT 130.0.6723.116. Con la configuración de campo, `Element`/`ShadowRoot.getInnerHTML` es `undefined`; sin ella es `function`. En la 130 el código aún lo tiene y lo quita Finch, que es lo que recibe Chrome estable |
| Diferencia conocida con Chrome 130 | **sin Web Share** (`navigator.share`/`canShare`): Chrome lo encendió en Mac en la 129, pero no es Baseline y nunca se ha probado en Mojave (decisión de COORDINACIÓN-6, principio 2; se revisa cuando sea Baseline). Brave quita además, a propósito, `navigator.connection`, File System Access y Web Serial |
| Pendiente de datos | el código ALPS (F4.8, con los JA4 de LOCAL-4 frente a CfT 130) |
| Comprobación | `FlyWeb/tools/motor-130.html` y `fastapi-129.html` (con JIT y Wasm en un origen http(s), nunca en `about:blank`), `wpt-130-lista.txt` (38), `regexp-130.html` (FS.14, en la 5,1), `sandbox-popups.html` (FS.15) y `seg-1.14.1.html` (las dos protecciones) |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Motor al nivel de Chrome 130**, con el motor de JavaScript de Chrome 130. Las webs ven FlyWeb como Chrome 130, y lo
  es en lo que usan.
- **Estilos anidados en el orden en que se escriben.** Las hojas de estilo que anidan reglas unas dentro de otras
  aplican cada declaración en el orden escrito, como Chrome, Safari y Firefox. Antes, algunas declaraciones escritas
  después de una regla anidada se aplicaban antes de tiempo.
- **Cortes de línea como en los demás navegadores.** La propiedad `text-wrap` funciona igual que en Chrome, Safari y
  Firefox (por ejemplo, `text-wrap: nowrap` para que un texto no se parta).
- **Conexiones directas en segundo plano.** Las webs de videollamada, juegos o envío de archivos entre usuarios pueden
  llevar una conexión directa a un hilo aparte, sin trabar la página.
- **Teclado:** las zonas de una página con desplazamiento propio se pueden alcanzar con el tabulador y recorrer con las
  flechas aunque no tengan nada enfocable dentro, como en Chrome 130. Ayuda a quien navega sin ratón.
- **Ventanas emergentes de las webs:** los avisos y menús que se abren y cierran con un botón se comportan como en
  Chrome 130, también los que son diálogos.
- **Más seguro:**
  - Cada web queda aislada de sus subdominios aunque intente juntarse con ellos (`document.domain`), como en Chrome
    desde la 119.
  - Las respuestas de otras webs que el navegador bloquea llegan como error y no como respuesta vacía, como en Chrome.
  - Un anuncio o contenido incrustado sin permiso para abrir ventanas ya no puede abrirlas con un clic simulado.
  - Dos protecciones que Chrome tiene desde la 119–120: una web ya no puede sacar datos de una página a través del
    nombre de una ventana mal cerrado (*dangling markup*), y los dibujos SVG ya no cargan piezas escondidas en
    direcciones `data:`. Las webs normales no notan nada.
  - Si se apaga el JIT de JavaScript por seguridad (el interruptor de emergencia), esas webs tampoco tienen
    WebAssembly, igual que en Chrome 130.
- **Lo que se va, como en Chrome:**
  - **WebSQL ya no existe, como en Chrome desde la 119.** Una web vieja que aún guarde datos con WebSQL deja de verlos,
    igual que en Chrome.
  - Los eventos antiguos de cambios en la página (eventos de mutación), la pantalla completa antigua de los vídeos y
    otras funciones retiradas que FlyWeb aún tenía de su base de 2023.
  - FlyWeb ya no añade a cada página su paquete de compatibilidad de JavaScript: todo lo que cubría lo trae ahora el
    propio motor, y así las webs no ven nada que Chrome 130 no tenga.
- **Pequeños arreglos de compatibilidad:**
  - Las direcciones `data:` con texto conservan los espacios, como en Firefox y Safari.
  - Pegar y borrar en los editores de las webs deja el texto como en Chrome 130.
  - Las tablas antiguas calculan el ancho de las celdas como Chrome 130.
  - Los estilos de los componentes de las webs (*shadow DOM*) se adaptan bien al tamaño de su contenedor.
- **Nada cambia** en los ajustes ni en los datos del usuario. La primera vez que se abra una web pesada puede tardar un
  poco más (el motor de JavaScript nuevo vuelve a preparar su caché).

## WPT del nivel 130

*(Pendiente de LOCAL-4: Static de `nube/motor-130` ccc74ea171 (las dos protecciones de 303e498fb5 no tocan ninguna de estas WPT), lista `FlyWeb/tools/wpt-130-lista.txt` (38, con `css/cssom/CSSGroupingRule-insertRule.html`; corregida el 15-10 por MOTOR-11: las de *container queries* están en `css/css-conditional/`), comparada con
Chrome for Testing 130 en el mismo Mac y con las `TestExpectations` de la 130.0.6723.117.)*
