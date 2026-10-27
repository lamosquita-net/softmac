# FlyWeb 2.0.2 — arreglos sobre la 2.0.1 (FM.41)

**Estado (27-10-2026, MOTOR-20):** código en brave-core `nube/base-128-motor-p21` **3cc4ce116c** (sobre `-p20` 8528639ead),
entregado como bundle (rama de softmac `nube/motor20-p21`; la nube no tiene escritura en brave-core). **Sin compilar.**
`flyweb_version` 2.0.2; LOCAL compila con `FLYWEB_BUILD_NUMBER=30`.

| Commit | Qué |
|---|---|
| 98f869c5 | Pestañas fijadas compartidas: no se pierden al salir con 2+ ventanas; sin duplicadas al restaurar (punto 1) |
| b76b6b9a | Versión visible sin Brave ni Chromium (punto 2) |
| c2be18ce | xHE-AAC solo se anuncia en macOS 10.15+ (punto 4) |
| 3cc4ce116c | `flyweb_version` 2.0.2 |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12.)*

- **Pestañas fijadas:** con «Pestañas fijadas compartidas» y dos o más ventanas, la 2.0 perdía las fijadas al cerrar y, con
  «Continuar donde lo dejaste», una salía repetida. Arreglado.
- **Versión:** «Información de FlyWeb» muestra solo la versión de FlyWeb y su motor, «2.0.2 (motor 131)». Los proyectos en
  los que se basa siguen reconocidos en `flyweb://credits`.

## 1. Pestañas fijadas compartidas (hecho, sin compilar)

**Causa** [comprobado en el código de brave-core -p20 y de Chromium 128.0.6613.138; falta confirmarlo en ejecución]:
- `PinnedTabService` de Chromium escribe `pinned_tabs` en `chrome::OnClosingAllBrowsers(true)` (con todas las ventanas abiertas)
  y desactiva la escritura (`need_to_write_pinned_tabs_ = false`) hasta que **se inserte una pestaña**. Cuando se quita la última
  ventana (`OnBrowserRemoved`), vuelve a escribir si hubo inserciones, y entonces ya no queda ninguna ventana en `BrowserList`.
- La 1.69 cambió `SharedPinnedTabService::OnBrowserClosing`: al cerrarse una ventana que no es la última, desengancha sus
  fijadas y guarda en caché el contenido compartido. Al cerrarse la última, lo **inserta** en ella
  (`MoveSharedWebContentsToBrowser`). Al salir con 2+ ventanas, esa inserción vuelve a activar la escritura, y al quitar la
  última ventana se guarda `pinned_tabs = []`. Es lo que midió LOCAL-11.
- La 1.15 no movía nada al salir: guardaba en caché al cerrar las pestañas y, para entonces, ya no había ventana destino.

**Arreglo:**
- (a) Con `browser_shutdown::IsTryingToQuit()` (en Mac se activa antes de cerrar las ventanas y se desactiva si se cancela la
  salida), la última ventana no recibe el contenido en caché. La sesión ya está guardada (`ShutdownSessionServices` antes de
  cerrar) y `pinned_tabs` también. El contenido en caché vive hasta que no queda ninguna ventana con sus pestañas de relleno
  (`OnBrowserRemoved`), así que ningún relleno apunta a un contenido destruido. El cierre ventana a ventana sin salir sigue
  como en la 1.69 (y en la 1.15).
- (b) Porte de `restored_browsers_` / `SynchronizeRestoredBrowser` de la 1.15 (MOTOR-11, FM.25), adaptado a la 128
  (`DiscardWebContentsAt` en lugar de `ReplaceWebContentsAt`). Una ventana creada durante la restauración de sesión o de pestañas
  no se sincroniza pestaña a pestaña: se une al acabar la restauración, o al activarla si ocurre antes. Primero recibe rellenos
  de las fijadas ya compartidas (sustituye por su relleno la copia de la misma URL) y después comparte las suyas. Así se evita
  la fijada duplicada con «Continuar donde lo dejaste».
- **Sin arreglar (igual en la 1.15):** si se cierran las ventanas una a una sin salir, `PinnedTabCodec` escribe las pestañas de
  relleno con URL vacía (`{url:""}`) en lugar de la fijada real. Lo cubre la sesión. No toca a «Al iniciar: Nueva pestaña» salvo
  en ese caso.

**Prueba (LOCAL, 6,1, perfiles temporales; nunca el de Titín):**
- (i) Los 5 pasos de `version-2.0.1.md` §3 con la -p21 en lugar de la 2.0.0.
- (ii) Control 2.0.2 → 2.0.2 con «Nueva pestaña», fijadas compartidas encendidas, 2 ventanas, 3 fijadas + 2 normales, Cmd+Q:
  `pinned_tabs` con las 3 URL (más rellenos vacíos, si los hay) y las 3 de vuelta al abrir.
- (iii) Lo mismo con «Continuar»: 2 ventanas, 3 fijadas en cada una y sin duplicadas.
- (iv) Cierre por `Browser.close` (CDP) **y** por Cmd+Q real (AppleScript `quit`): son caminos distintos.
- (v) Cerrar una ventana con Cmd+Shift+W, activar la otra y volver a abrir una ventana nueva: las 3 fijadas siguen y no hay caída.

## 2. Versión visible (hecho, sin compilar)

- La misma constante `kBraveVersionNumberForDisplay` (`components/version_info/version_info_values.h.version`) alimenta
  «Información de FlyWeb» (`VersionUI::GetAnnotatedVersionStringForUi`), `flyweb://version` y `flyweb://crashes` (los
  `chromium_src` de `version_ui.cc` y `crashes_ui.cc`). Antes: «2.0.1 (motor 131) · Brave 1.69.168 · Chromium: 128.0.6613.138».
  Ahora: **«2.0.2 (motor 131)»**.
- La línea completa de «Información» queda como «Versión 2.0.2 (motor 131) (Compilación oficial) (x86_64)», con «FlyWeb» en el
  título. Para que la línea diga «FlyWeb 2.0.2 (motor 131)» habría que cambiar la cadena traducible
  `IDS_SETTINGS_ABOUT_PAGE_BROWSER_VERSION` (con `chromium-rebase-l10n.py`, no a mano); **no se toca sin el sí de Titín**.
- Brave y Chromium siguen en `about:credits` (MPL-2.0, BSD) y en el texto de licencia de «Información» («Mozilla Public License
  2.0», «software de código abierto»). Es una cadena nuestra que no dice Brave. La base real se documenta aquí y en `CLAUDE.md`.
- **Captura antes/después para Titín** (regla de diseño): LOCAL, «Información de FlyWeb» y `flyweb://version` con la 2.0.1 y con
  la -p21. Comprobar además las demás filas de `flyweb://version` («Revisión», JavaScript, agente de usuario) por si alguna
  dice Brave o 1.69.

## 3. `navigator.brave` (ya quitado; nada que hacer)

[comprobado] No se compila en escritorio desde la 2.0.0: `third_party/blink/renderer/includes.gni:53`, «FlyWeb: no
navigator.brave». `brave_blink_sub_modules` solo lleva `global_privacy_control` y no se genera `v8_brave`. Las marcas de UA y
Sec-CH-UA no llevan «Brave» (`chromium_src/components/embedder_support/user_agent_utils.cc:21`, con DCHECK en
`brave_content_browser_client.cc:1350`). `window.ethereum`/`solana` están apagados. `window.brave` de Brave Search solo existe
en los hosts de Brave. Lo único que delata algo «tipo Brave» es `Sec-GPC: 1` / `navigator.globalPrivacyControl`, que es
intencionado, y la aleatorización de Shields (inferencia). Nadie dentro de brave-core usa `navigator.brave`.

## 4. APIs de 10.15 sin guarda (inventario; un arreglo)

*(Subagente de lectura sobre Chromium 128 y 116 y brave-core -p20; sin el registro exacto de avisos de LOCAL.)*
- **~22 avisos de `ASWebAuthenticationSession`** (`chrome/browser/mac/auth_session_request.{h,mm}`, `app_controller_mac.mm`).
  Solo se ejecuta `app_controller_mac.mm:1199` al arrancar: la clase no existe en 10.14 (enlace débil), así que el mensaje a
  `nil` no hace nada. Que la 2.0 arranque en Mojave lo confirma. Lo demás solo lo llaman retrollamadas que no se registran.
  **SEGURO.**
- **~8 en código ya parcheado** por LOCAL-8 con `if (@available(10.15)) {} else { return; }`: clang no da por guardado lo que
  va detrás. Afectan a las cámaras (`AVCaptureDeviceDiscoverySession`, que vuelve a `[AVCaptureDevice devices]` como la 116),
  a `takePhoto` (error de foto en 10.14) y a `crypto/unexportable_key_mac.mm:263` (`kSecUseDataProtectionKeychain`; su fábrica
  devuelve nullptr en 10.14). **SEGURO.**
- **Sin aviso, pero mal en Mojave:** xHE-AAC (`mp4a.40.42`). `gpu_mojo_media_client_mac.cc:35` lo anunciaba siempre, pero
  AudioToolbox solo lo decodifica desde 10.15: `isTypeSupported` decía que sí y luego fallaba. La 116 lo comprobaba
  (`supported_types.cc`). **Arreglado** (c2be18ce, parche de Chromium con `__builtin_available(macOS 10.15, *)`).
- Ninguna de las ~30 llamadas se ejecuta en 10.14 de forma que pueda caer. **No se añade más `@available`** (la orden: solo las
  alcanzables). Lo cosmético (que la Release compile sin `treat_warnings_as_errors=false`) se puede hacer en una 2.0.x sin
  prisa. Tabla completa: anexo al final.
- **LOCAL:** cuando compile, sacar del registro las líneas `warning: … is only available on macOS 10.15` (fichero:línea y API)
  y dejarlas en FM.41, para contrastarlas con este inventario.

## 5. JetStream 3.0 web-ssr y Speedometer 3.1 «?» (solo diagnóstico)

**web-ssr** [comprobado en JetStream3.0 06785cf]:
- `utils/StartupBenchmark.js:29` usa **`RegExp.escape`** al cargar. Llegó a Chrome con la 136 (V8 13.6). FlyWeb quitó su
  polyfill de core-js en la 1.14 (`motor-niveles.md`). Sin él, la clase base lanza TypeError y la fila sale en rojo.
- El resto de web-ssr es casi ES5, no hace peticiones y Shields no influye.
- **Pega:** el mismo fichero lo cargan mobx-startup, jsdom-d3-startup, prismjs-startup-es6 y babylonjs-startup-es6. Si esas
  terminan bien, la causa es otra (web-ssr compara un hash del HTML y la cuenta de comentarios: un fallo de V8 con regexp o
  cadenas bajo JIT).
- Comprobación de 2 min:
  1. `typeof RegExp.escape` en la consola.
  2. `browserbench.org/JetStream3.0/?test=web-ssr` y, al ponerse en rojo, `JetStream.errors` en la consola.
- Si es `RegExp.escape`: es del nivel 136 y no se porta fuera de nivel (motor.md). Se anota como dato.

**Speedometer 3.1 «?»** [comprobado en release/3.1]:
- Los números usan fuentes del sistema (`"Futura-CondensedMedium", Futura, "Helvetica Neue"…`, `main.css:408`), sin web font,
  y se formatean con `toPrecision`. Un NaN saldría como «NaN», no como «?»: es un fallo de **glifos** en CoreText con Sequoia
  [inferencia]. Probablemente la búsqueda por nombre PostScript en una colección `.ttc` (`font_matcher_mac.mm`, donde hay un
  parche de LOCAL con `CTFontCopyVariationAxesInternal`) da una cara distinta a la que pinta Skia.
- Comprobación de 2 min en la 7,1:
  1. DevTools › `#result-number` › Computed › «Rendered Fonts».
  2. `textContent`: si da dígitos, el texto está bien.
  3. Cambiar `font-family: Helvetica` en vivo.
  4. `data:text/html,<p style="font:100px Futura-CondensedMedium">0123</p>` frente a `font:100px Futura`.
- Solo afecta a Sequoia (fuera del objetivo garantizado), pero puede tocar a cualquier web que pida Futura por nombre
  PostScript.

## Anexo: inventario de APIs 10.15 (subagente)

| Dónde | API | ¿Se ejecuta en 10.14? | Riesgo |
|---|---|---|---|
| `app_controller_mac.mm:1199` | `ASWebAuthenticationSessionWebBrowserSessionManager` | sí, al arrancar; clase débil = nil | seguro |
| `auth_session_request.{h,mm}` | `ASWebAuthenticationSessionRequest` y protocolo | no (sin manejador registrado) | seguro |
| cámaras (`video_capture_device_*_mac`) | `AVCaptureDeviceDiscoverySession`, tipos de dispositivo | no: vuelve a `[AVCaptureDevice devices]` | seguro |
| `takePhoto` | `AVCapturePhotoOutput` | no: error de foto | seguro |
| `crypto/unexportable_key_mac.mm:263` | `kSecUseDataProtectionKeychain` | no: fábrica nullptr, además flag y entitlement | seguro |
| Bluetooth, `LAContext`, `launch_application`, `platform_util`, `SFUniversalLink`, cuentagotas, geolocalización, mandos, `fontWithSize:`, `posix_spawn`, `_CSCheckFixDisable`, pantalla/HDR/Dawn, `secure_enclave_client_impl` | varias | guardadas por parches (`patches/`) | seguro |
| `gpu_mojo_media_client_mac.cc:35` | xHE-AAC en AudioToolbox | sí (sin aviso del compilador) | **mal → arreglado** |
