# FlyWeb 1.14 — nivel de motor 130 (MOTOR-10, 15-10-2026)

**Cabeza final:** brave-core `nube/motor-130` **ccc74ea171** (8645de1731 + `seg/popup-sandbox` y los resultados de d8 de `seg/v8-13.0`).

**Estado:** en código en brave-core `nube/motor-130` **ccc74ea171**, con FS.14 fundida (`seg/v8-13.0` d6b66b7994 y
`seg/transfer-keys` 1df157fca7), ORB v0.2 encendido (FS.14) y FS.15 (`seg/popup-sandbox` 1825a087d0). Encima de la 1.13 (325686916c) y de `nube/ruby-003`
(0c95523439, monoespaciada japonesa), lleva la V8 de Chrome 130 (paso a7b5f3f4aa, también en `nube/motor-130-v8`), la
Baseline y las flags del 130, `KeyboardFocusableScrollers`, los apagados que se escaparon (§9–§10 de `motor.md`) y el
recorte de superficie frente a Chrome 129/130. Declara 130 / 1.14. Un solo nivel en una sola versión (regla 18).
**Pendiente:** Static, ASan y Release de LOCAL-4 (el Static del paso de V8 ya está hecho, fila de LOCAL). Detalle
técnico: `motor.md`, «Nivel 130», §12; commits: `FlyWeb/tools/port/nivel130-commits.tsv`.

| Dato | Valor |
|---|---|
| Cabeza final | brave-core `nube/motor-130` **ccc74ea171** (paso de V8 en `nube/motor-130-v8` a7b5f3f4aa) |
| Versión visible | 1.14 (`CFBundleVersion` la pone LOCAL en la entrega) |
| Nivel declarado | Chrome 130 (`flyweb_engine_full_version` 130.0.6723.117; `platformVersion` mínimo **11.7.10**) |
| Motor JavaScript | V8 13.0.245.25 (cabeza de la rama 13.0) con los arreglos de seguridad de FlyWeb (FS.14; época de caché **15**). gin con la opción B. `fast_float` 3e57d8dc traído por `build.sh` con suma fija |
| Portes del 130 | *nested declarations* (CSSOM incluido), `text-wrap` como abreviatura, `RTCDataChannel` transferible a un *worker*, `togglePopover({force})`, `KeyboardFocusableScrollers`, espacios en `data:` URL y 8 flags de interoperabilidad |
| Apagados, como Chrome | WebSQL, pantalla completa prefijada de `<video>`, `:--foo`, eventos de mutación, DSD antiguo (`<template shadowroot>`, `includeShadowRoots`), `getInnerHTML()` |
| Encendidos, como Chrome | agrupación por origen por defecto (`document.domain` ya no relaja el mismo origen), ORB v0.2 |
| Seguridad | FS.14 (V8 13.0, época 15; claves de `TransferList`) y FS.15: un iframe con `sandbox` sin `allow-popups` ya no abre pestañas sin *sandbox* con un clic sintético con Ctrl/Cmd (fd7c878da2, crbug 544197473) |
| Interruptor de emergencia del JIT | **desde la V8 13.0, sin JIT no hay WebAssembly** (`jitless` apaga `expose_wasm`, como en Chrome 130). Quien apague el JIT por política (`DefaultJavaScriptJitSetting` = 2) pierde también Wasm en esas webs |
| Superficie, como Chrome 130 | fuera `Sanitizer`/`setHTML()` (los de 2022), `GPUCommandEncoder.writeTimestamp()`, `-webkit-highlight` y `:open`/`:closed`; fuera los polyfills de core-js; dentro las interfaces `SpeechSynthesis` y `SpeechSynthesisVoice` |
| Fuera, con motivo | `PseudoElementsCorrectInGetComputedStyle`, `PaintHighlightsForFirstLetter`, estilos de reserva de `<meter>` y `MultiSmoothScrollIntoView` (dependen de código posterior a la 116; van al 131, aprobado por COORDINACIÓN-6); `ShapeOutsideWritingModeFix` y `TextInputNotAlwaysDirAuto` (decisión v); lo no Baseline |
| Condicional | `getInnerHTML()` apagado (c5a094a9ab) **se revierte si CfT 130 lo expone** (lo mira LOCAL-4) |
| Diferencia conocida con Chrome 130 | **sin Web Share** (`navigator.share`/`canShare`): Chrome lo encendió en Mac en la 129, pero no es Baseline y nunca se ha probado en Mojave (decisión de COORDINACIÓN-6, principio 2; se revisa cuando sea Baseline). Brave quita además, a propósito, `navigator.connection`, File System Access y Web Serial |
| Pendiente de datos | el código ALPS (F4.8, con los JA4 de LOCAL-4 frente a CfT 130) |
| Comprobación | `FlyWeb/tools/motor-130.html` y `fastapi-129.html` (con JIT y Wasm en un origen http(s), nunca en `about:blank`), `wpt-130-lista.txt` (35), `regexp-130.html` (FS.14, en la 5,1) y `sandbox-popups.html` (FS.15) |

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

*(Pendiente de LOCAL-4: Static de `nube/motor-130` ccc74ea171, lista `FlyWeb/tools/wpt-130-lista.txt` (35), comparada con
Chrome for Testing 130 en el mismo Mac y con las `TestExpectations` de la 130.0.6723.117.)*
