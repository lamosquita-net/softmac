# FlyWeb 2.2.0 — motor 133 (FM.49)

MOTOR-27, 28-10-2026 (en curso; sigue MOTOR-28). brave-core **`nube/motor-133`**, sobre la cabeza de la 2.1.1
(`nube/motor-211b` ef850e44; si MOTOR-26 la mueve, se funde). Declaración **133.0.6943.141**, V8 **13.3.415.23** (93c6f108)
con los 12 arreglos de la M132-LTS que la 13.3 no trae (época de caché 21). `flyweb_version` 2.2.0; `FLYWEB_BUILD_NUMBER`,
de LOCAL (34). Inventario y decisiones: `motor-niveles.md` § «Nivel 133». Sin compilar.

## Qué lleva (hasta 426ed3c1)

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

Sin cambio: `Sec-Fetch-Storage-Access` ya está apagado en la red de la 128 (`kStorageAccessHeaders`); la decisión de Titín
solo importa si algún día se porta. `kUseBrowserCalculatedOrigin` no existe en la 128: no se porta.

## Falta (MOTOR-28)

`ClipboardItem` con `Promise<string>` (necesita adaptar a la 128 `ThenCallable`/`MemberScriptPromise`, que no existen: usar
`ScriptFunction::Callable`; tocar también `clipboard_writer`; conservar el `WritePlainText` de Brave en `chromium_src`),
`text-box-trim` (último, en su commit), `attr()` avanzado (detrás; si pasa de ~1 día, a una 2.2.x antes del 134),
escapes `flexbox-safe-overflow-position-002/005` si LOCAL los sigue viendo, `motor-133.html`, lista WPT y orden a LOCAL.

## Para la web

(Borrador; lo completa MOTOR-28.) FlyWeb 2.2.0 pone el motor al nivel de Chrome 133: `:open` para desplegables y diálogos,
popovers ligados a su botón, `box-decoration-break`, `scheduler.yield()`, X25519 en Web Crypto y el motor JavaScript V8 13.3,
con los arreglos de seguridad posteriores de la versión anterior. Sin cambios visibles en la interfaz.
