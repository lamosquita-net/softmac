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
