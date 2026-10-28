# FlyWeb 2.2.0 — motor 133 (FM.49)

MOTOR-27 y MOTOR-28, 28-10-2026. brave-core **`nube/motor-133`**, sobre la cabeza de la 2.1.1
(`nube/motor-211b` ef850e44; si MOTOR-26 la mueve, se funde). Declaración **133.0.6943.141**, V8 **13.3.415.23** (93c6f108)
con los 12 arreglos de la M132-LTS que la 13.3 no trae (época de caché 21). `flyweb_version` 2.2.0; `FLYWEB_BUILD_NUMBER`,
de LOCAL (34). Inventario y decisiones: `motor-niveles.md` § «Nivel 133». **Cabeza para compilar: 88732b96c4**
(orden `buzon/LOCAL/20261028-0953-MOTOR-28.md`; sin compilar).

## Qué lleva

| Commit | Qué | Origen |
|---|---|---|
| a833b085 | V8 13.3.415.23 + 12 solo-LTS (20c1b8e9b y 5cf18d038 a mano); `patches/v8` rebasado, 76 parches; detalle en `patches/v8/FLYWEB-SECURITY.md` | FM.49 / FS.33 |
| a54afae1 | Wasm JS String Builtins encendidas (escape del 130: estaban apagadas) | 1f2dd1392d2, 37f9fd474bd |
| 38cd5fbd | `TextSizeAdjustImprovements` | 5cec4efe5ec |
| 55273752 | X25519 en WebCrypto (Ed25519 sigue con su flag experimental, como en el 133) | 3136845f1fb, fa2e69a1abf |
| 2fe02e59 | `scheduler.yield()` | ea2bd51cd50, 3a35087087d |
| 3fb8a6bd | `box-decoration-break` (adaptado a la fragmentación de la 128) | 904f3504be1 … c9ce28826ba |
| ec788fb7 | `finalResponseHeadersStart` | 006487e3ae3, 1249cc6be6b |
| b7bfdb41 | `renderTime` engrosado (4 ms) entre orígenes en LCP y Element Timing | d6a8de54aeb … 31a0c0a83bb |
| 37088787 | `selectionchange` al borrar en cuadros de texto | ddf020ca49b |
| 94c74346 | `Animation.overallProgress` | 27df435a1f5, 726ab567b10 |
| 4260778c | selección en shadow DOM con `delegatesFocus` | 15d4924b212, c8a1a5f70f4 |
| 9ea5f04b | `:open` (sin `:closed`; `input:open`); fuera los commits de `<select>` personalizable y el UseCounter | ad3094520f8, 833248d9d46, 7d2b2076d87 |
| 89978029 | `ReportEcn` y `MacImeLiveConversionFix` encendidos (mismo código en 128 y 133) | 8b7ac0ea2bd, fa3bf858457e |
| 318ea64a | `popover=hint`, ancla implícita del invocador (`showPopover({source})`), popover dentro de su botón | 8010721fc51 … d7258369ec3 |
| 426ed3c1 | declaración 133.0.6943.141 / 2.2.0 | — |
| 25367508 | merge `seg/fs33-roots153` 7416f3bd: cortes del Root Store con la constante 153.0.8010.0 | FS.33 (Titín) |
| c1ff7342 | `ClipboardItem` con `Promise<DOMString>`: en la 128 no hay `ThenCallable` ni promesas tipadas, así que la cadena se convierte en `Blob` de su tipo al resolverse (escritura) y en `getType()`; el escritor sigue solo con `Blob` y el `WritePlainText` de Brave no se toca. Lectura: fuera los formatos que no se pudieron leer | d72d71316f2, 586423e8031, 887df9720c3 |
| 8da9f5f3 | `text-box`, `text-box-trim` y `text-box-edge` (22 commits). `ba1e0b7556` (relayout genérico) adaptado: la 128 conserva el modelo anterior de `line-clamp`, así que el estado con el que arranca un relayout de line-clamp se guarda aparte (`line_clamp_relayout_data_`) y pasa a los siguientes. Sin los de `line-clamp: auto` (7f48814f67, 5c55151b22, adbca44169). Contador `kTextBox` = 801, como Chrome 133 | 8cc53df378 … 336cc860af |
| 77caf973 | merge `seg/v8-stackclash-133` ef6d96de: marcos optimizados de TurboFan acotados a 4 KB (stack clash, crbug 574660146) | v8 ea2f03dfff, FS.33 |
| 88732b96 | merge `seg/fs33-blink133` 4dff2dfc: DevTools `DevToolsAgent::Client` (posible UAF), caret, anchors de a11y | 9044bcbe4e16, 5e0a7a16b019, 2a251e725fe0, FS.33 |

Sin cambio: `Sec-Fetch-Storage-Access` ya está apagado en la red de la 128 (`kStorageAccessHeaders`); la decisión de Titín
solo importa si algún día se porta. `kUseBrowserCalculatedOrigin` no existe en la 128: no se porta.

## Fuera de la 2.2.0

- **`attr()` avanzado** (`CSSAdvancedAttrFunction`): 8 de 20 commits aplicaban, pero 0c00afffe9 necesita
  `CSSSyntaxDefinition::Consume` y, debajo, la migración del analizador CSS a *streaming* (~40 commits de 2024:
  7910c0201d «Remove the non-streaming parser», 5144028324, media queries, `@import`, keyframes, calc…). Toca el análisis
  de CSS de todas las webs: >1 día y riesgo alto. Propuesta a COORDINACIÓN-18: 2.2.x propia antes del 134 (migración +
  `attr()` encima). Es la única diferencia esperada con CfT 133 en `motor-133.html`.
- Escapes `flexbox-safe-overflow-position-002/005`: sin noticias de LOCAL de que sigan en rojo con la 2.1.1; van en la
  lista WPT (`css/css-flexbox/`) para comprobarlo con esta compilación.

Prueba: `FlyWeb/tools/motor-133.html` (comprobada en un Chromium 153: todo ok salvo la versión declarada y lo que el 153
ya trae, `Float16Array`/`using`). WPT: `FlyWeb/tools/wpt-133-lista.txt`. **Cambios visibles en la interfaz:** ninguno.

## Para la web

FlyWeb 2.2.0 pone el motor al nivel de Chrome 133. Para quien hace webs: `text-box-trim` y `text-box-edge` (recortar el
espacio de interlineado sobre las mayúsculas y bajo la línea base, para alinear texto con precisión), `:open` para
desplegables y diálogos abiertos, popovers ligados a su botón y `popover="hint"`, `box-decoration-break: clone`,
`scheduler.yield()`, X25519 en Web Crypto, `Animation.overallProgress` y elementos del portapapeles creados con texto
directamente. El motor JavaScript pasa a V8 13.3, con los arreglos de seguridad posteriores de la versión anterior que la
13.3 no traía, y WebAssembly admite memoria de 64 bits y las funciones de cadena de JavaScript. Las raíces de certificados
se ponen al día con la lista de confianza de Chrome. Sin cambios visibles en la interfaz.
