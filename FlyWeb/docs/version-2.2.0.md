# FlyWeb 2.2.0 — motor 133 (FM.49)

MOTOR-27 y MOTOR-28, 28-10-2026. brave-core **`nube/motor-133`**, sobre la cabeza de la 2.1.1
(`nube/motor-211b` ef850e44; si MOTOR-26 la mueve, se funde). Declaración **133.0.6943.141**, V8 **13.3.415.23** (93c6f108)
con los 12 arreglos de la M132-LTS que la 13.3 no trae (época de caché 21). `flyweb_version` 2.2.0; `FLYWEB_BUILD_NUMBER`,
de LOCAL (34). Inventario y decisiones: `motor-niveles.md` § «Nivel 133». **Cabeza para compilar: 888963ca5**
(2f268ee217 + `attr()`; órdenes `buzon/LOCAL/20261028-0953-MOTOR-28.md`, `…-1016-MOTOR-28.md` y el aviso de
COORDINACIÓN-19; sin compilar).

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
| 2f268ee2 | restaura a `stable` `TextSizeAdjustImprovements`, `ScheduleSelectionChangeOnBackspace` y `AnimationProgressAPI` (38cd5fbd, 37088787 y 94c74346 los ponían, pero un commit posterior regeneró el json5 desde un área montada antes) | — |

Sin cambio: `Sec-Fetch-Storage-Access` ya está apagado en la red de la 128 (`kStorageAccessHeaders`); la decisión de Titín
solo importa si algún día se porta. `kUseBrowserCalculatedOrigin` no existe en la 128: no se porta.

## `attr()` avanzado (MOTOR-29, 28-10)

Primero iba en una 2.2.1. Titín decidió (DIRECTIVAS, PR #600) que solo sale una 2.N.x para una regresión o un fallo de
seguridad explotado, así que entra en la 2.2.0 (COORDINACIÓN-19). Commit **888963ca5**, encima de 2f268ee217 y de los dos
WIP de MOTOR-28 (5ce740bb, 59d488dd).


`CSSAdvancedAttrFunction` completo y en `stable` (como en Chrome 133): `attr(data-x type(<length>))`, unidades
(`attr(data-x px)`), `string` explícito, sustitución de `var()` dentro del valor del atributo, marca de *taint* del valor
entero (un `attr()` no puede acabar en una `url()`) y búsqueda del atributo por nombre local sin espacio de nombres.

Commits de upstream, en orden: 8026a18f3f … 58743c5967 (8, MOTOR-28), 1fc628b444, 0692e7d9b9, 8e710e2016 (MOTOR-28),
5189858a61, 0c00afffe9, **01b72da0c0**, 96a736734d, **774c4ce6b3**, c8d50d1a89, 162e74449d, 1bf714b913, 3d832173db,
8e507ecf45, 82d879b09e, 0c50bb37c1, ac008e348d. Los dos en negrita faltaban en la lista de MOTOR-28 (sin ellos no existe
`CSSAttrType` ni la sintaxis `type()`): salieron con `git log` de la 133 sobre `css_attr_type.*` y `style_cascade.cc`.

### Adaptaciones a la 128 (dónde puede fallar la compilación)

- `CSSVariableParser::ContainsValidVariableReferences()` toma el texto y valida con el `ConsumeUnparsedDeclaration()` de
  *streaming*; los validadores sobre `CSSParserTokenRange` se van, como en upstream. Llamadores: `style_value_factory.cc` y
  `AddCSSPaintArgument()` en `css_parsing_utils.cc` (este serializa los tokens, como ya hacía).
- `CSSParserTokenStream` gana un constructor `(CSSTokenizer&, rangos de taint)`: en la 128 el *stream* lee de un
  `CSSTokenizer`, no del texto. `css_attr_type.cc` y `ResolveAttrInto()` crean su `CSSTokenizer`.
- `ResolveAttrInto()` con la forma final de la 133. Sin `ElementResolveContext::GetUltimateOriginatingElementOrSelf()` en
  la 128: un ayudante local sube desde el pseudoelemento. `ResolveTokensInto()` de la 128 no tiene `stop_type`.
- `ConsumeUnparsedDeclaration()` de la 128 no tiene `comma_ends_declaration` (lo traía 5189858a61).
- `CSSVariableData::Create()` gana `is_attr_tainted` en tercera posición: todos los llamadores están revisados (el de
  `CSSTokenizedValue`, solo de la 128, pasa `false`). Si sale un «no matching function» en `Create`, es un llamador nuevo.
- `css_attr_value_tainting.{cc,h}` desaparecen, como en upstream (sus parches, borrados).

Los `_test.cc` no se portan (como siempre): si LOCAL compila tests de Blink, `css_variable_parser_test.cc` y
`style_cascade_test.cc` no compilarán.

### Pruebas

`FlyWeb/tools/motor-133.html`: seis líneas nuevas de `attr()` (en Chromium 153 salen ok). WPT:
las de `attr()`, `css-variables`, `css-properties-values-api`, typed OM, paint API y `css-content`, en `wpt-133-lista.txt`. Riesgo: toca el análisis de propiedades personalizadas y de toda
propiedad con `var()`, así que hay que mirar también `css/css-variables/` y `css/css-properties-values-api/` enteras y
una ronda de sitios (claude.ai, YouTube, GitHub).

## Fuera de la 2.2.0

- Escapes `flexbox-safe-overflow-position-002/005`: sin noticias de LOCAL de que sigan en rojo con la 2.1.1; van en la
  lista WPT (`css/css-flexbox/`) para comprobarlo con esta compilación.

Prueba: `FlyWeb/tools/motor-133.html` (comprobada en un Chromium 153: todo ok salvo la versión declarada y lo que el 153
ya trae, `Float16Array`/`using`; sin diferencias de `attr()`). WPT: `FlyWeb/tools/wpt-133-lista.txt`. **Cambios visibles en la interfaz:** ninguno.

## Para la web

FlyWeb 2.2.0 pone el motor al nivel de Chrome 133. Para quien hace webs: `text-box-trim` y `text-box-edge` (recortar el
espacio de interlineado sobre las mayúsculas y bajo la línea base, para alinear texto con precisión), `:open` para
desplegables y diálogos abiertos, popovers ligados a su botón y `popover="hint"`, `box-decoration-break: clone`,
`scheduler.yield()`, X25519 en Web Crypto, `Animation.overallProgress`, elementos del portapapeles creados con texto
directamente y la función `attr()` ampliada: los atributos de un elemento se usan como longitudes, colores, números con
unidad y cualquier otro tipo de valor en cualquier propiedad, no solo como texto en `content`. El motor JavaScript pasa a V8 13.3, con los arreglos de seguridad posteriores de la versión anterior que la
13.3 no traía, y WebAssembly admite memoria de 64 bits y las funciones de cadena de JavaScript. Las raíces de certificados
se ponen al día con la lista de confianza de Chrome. Sin cambios visibles en la interfaz.
