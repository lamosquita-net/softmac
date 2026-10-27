# FlyWeb 2.0.2 — arreglos sobre la 2.0.1 (FM.41, FM.42 tanda 1 y FM.43)

**Estado (27-10-2026, MOTOR-23):** por decisión de COORDINACIÓN-15, la 2.0.2 junta tres entregas en una sola Release, una
prueba y un sí de Titín: la -p21 de MOTOR-20, la -p22 de MOTOR-22 (tanda 1 de FM.42, que iba a ser la 2.0.3) y el arreglo
de la mosca de la NTP (FM.43). brave-core `nube/base-128-motor-p23` **17e7858669** (sobre `-p22` 9b9fdbbd44, sobre `-p21`
3cc4ce116c, sobre `-p20` 8528639ead), entregada como bundle (rama de softmac `nube/motor23-p23`; la nube no escribe en
brave-core). **Sin compilar.** `flyweb_version` 2.0.2; LOCAL compila con `FLYWEB_BUILD_NUMBER=30`. **Cambia cosas
visibles** (versión en Información, mosca de la NTP, passkeys, menú de imagen): PUBLICACIÓN espera el sí de Titín.

| Commit | Qué |
|---|---|
| 98f869c5 | Pestañas fijadas compartidas: no se pierden al salir con 2+ ventanas; sin duplicadas al restaurar (punto 1) |
| b76b6b9a | Versión visible sin Brave ni Chromium (punto 2) |
| c2be18ce | xHE-AAC solo se anuncia en macOS 10.15+ (punto 4) |
| 3cc4ce116c | `flyweb_version` 2.0.2 (-p21) |
| 9b9fdbbd44 | Mojave, tanda 1 de FM.42 (punto 6; como -p22 decía 2.0.3) |
| 17e7858669 | Mosca de la NTP visible otra vez y en el compositor (punto 7); `flyweb_version` 2.0.2 |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12.)*

- **Pestañas fijadas:** con «Pestañas fijadas compartidas» y dos o más ventanas, la 2.0 perdía las fijadas al cerrar y, con
  «Continuar donde lo dejaste», una salía repetida. Arreglado.
- **Versión:** «Información de FlyWeb» muestra solo la versión de FlyWeb y su motor, «2.0.2 (motor 131)». Los proyectos en
  los que se basa siguen reconocidos en `flyweb://credits`.
- **Llaves de acceso (passkeys) y Touch ID:** FlyWeb ya no guarda llaves de acceso en el chip de seguridad del Mac (T2 /
  Secure Enclave) ni usa Touch ID, en ningún Mac. Es igual en todos los Mac compatibles y no depende de un chip que Mojave
  no aprovecha del todo.
  - **Si creaste una llave de acceso con FlyWeb 2.0.0 o 2.0.1 en un Mac con chip T2** (MacBook Pro y MacBook Air de 2018
    en adelante, Mac mini 2018, iMac Pro), tendrás que **volver a registrarla** en cada web, porque esa llave no se
    puede sacar del chip. Puedes borrar las antiguas en Ajustes › Autocompletar › Gestionar llaves de acceso.
  - Siguen funcionando: el **teléfono** (código QR), las **llaves de seguridad** USB/NFC y los **gestores de contraseñas**
    con llaves de acceso (por ejemplo, Bitwarden o KeePassXC).
  - Para ver las contraseñas guardadas, FlyWeb pide la **contraseña del Mac**, no la huella.
- **Audio en Mojave:** el audio en tiempo real (llamadas, Web Audio, reproducción) vuelve a usar en 10.14 el modo que
  usaba FlyWeb 1.x, para evitar cortes.
- **Compartir pantalla en Mojave:** las webs de videollamada pueden volver a compartir la pantalla en 10.14 sin pedir un
  permiso de «Grabación de pantalla» que Mojave no tiene.
- **«Copiar texto de la imagen»:** en Mojave ya no aparece, porque macOS 10.14 no sabe reconocer texto en imágenes (antes
  aparecía y no copiaba nada). En macOS 10.15 o posterior sigue igual.
- **Mosca de la nueva pestaña:** vuelve a verse volando por la página, como en FlyWeb 1.x (desde la 2.0.0 quedaba
  oculta detrás del fondo, aunque seguía gastando). Ahora la mueve la tarjeta gráfica sin ocupar el procesador, se para
  cuando la pestaña o la ventana no se ven y, si en Ajustes del Sistema › Accesibilidad está «Reducir movimiento», se
  queda quieta posada.

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

## 6. Mojave, tanda 1 de FM.42 (hecho por MOTOR-22, sin compilar)

Orden de COORDINACIÓN-15: tanda 1 de [`mojave-128.md`](mojave-128.md) sobre la -p21, commit **9b9fdbbd44**. Los parches se
generaron con `git diff --full-index` contra Chromium 128.0.6613.138 y entran limpios con `git apply` en la 128 sin tocar.

### Qué cambia (ficheros)

| # | Fichero (parche de bc) | Cambio | Por qué así |
|---|---|---|---|
| d1 | `crypto/unexportable_key_mac.mm` | `GetUnexportableKeyProviderMac` devuelve `nullptr` siempre; el cuerpo de upstream queda en `#if 0` para las fusiones | Sustituye el `@available` de LOCAL-8. Un `return` sin más dejaría código inalcanzable, y Chromium compila con `-Wunreachable-code-aggressive` y `-Werror` (comprobado con clang 18) |
| d1 | `crypto/features.cc` (parche nuevo) | `EnableMacUnexportableKeys` desactivada por defecto | Lo pedía la orden; tras el `nullptr` ya no hace falta, pero queda coherente con `chrome://flags` |
| d2 | `crypto/unexportable_key_metrics.cc` | `TpmLatencyMetrics` desactivada (feature local estática; solo se puede cambiar con un parche) | Refuerzo: con d1 ya no llegaba al SE |
| d3 | `device/fido/mac/touch_id_context.mm` (nuevo) | El puntero `g_touch_id_available_` apunta a una función que devuelve false | Así `TouchIdAvailableImpl` y `CanCreateSecureEnclaveKeyPairBlocking` se siguen usando y no hay avisos de función sin usar. Los tests que ponen su propio puntero siguen igual. `TouchIdCredentialStore` (listar y borrar en `local_credential_management_mac.cc`, borrado de datos) **no** depende de esto [V]: las passkeys antiguas se pueden borrar mientras la app conserve `.webauthn` (d11, fuera de esta tanda) |
| d4 | `device/fido/mac/util.mm` (nuevo) | `DeviceHasBiometricsAvailable` → false (se respeta el override de los tests) | — |
| d4 | `chrome/browser/device_reauth/mac/authenticator_mac.mm` | `CheckIfBiometricsAvailable` → false | `DeviceAuthenticatorMac` va entonces siempre a `AuthenticateUserWithNonBiometrics` (contraseña del sistema) [V]. Sustituye el apaño de LOCAL-8 (`...BiometricsOrWatch`), que ya no se usa. `CheckIfBiometricsOrScreenLockAvailable` se queda igual: solo comprueba, no pide la huella |
| d8 | `.../device_trust/.../secure_enclave_client_impl.mm` | `VerifySecureEnclaveSupported` → false y `CreatePermanentKey` sale sin clave si no hay SE | **Matiz al inventario:** en la 128, `IsSecureEnclaveSupported` no se llama desde código de producción (solo desde tests), así que el false por sí solo no cambiaba nada. Lo que corta es la salida al principio de `CreatePermanentKey` [V]. Leer y borrar claves que ya existan sigue funcionando |
| c1 | `base/threading/platform_thread_apple.mm` (nuevo) | `IsOptimizedRealtimeThreadingMacEnabled` → false si `MacOSVersion() < 10'15'00` | Igual que la 116 (`mac::IsOS10_14()`, comprobado en `platform_thread_mac.mm` de la 116.0.5845.188) |
| c2 | `ui/base/cocoa/permissions_utils.mm` | Antes de 10.15, `IsScreenCaptureAllowed` y `TryPromptUserForScreenCapture` → true, y `ShouldWarmScreenCapture` → false | Igual que la 116. `CheckSystemScreenCapturePermission` de `system_media_capture_permissions_mac.mm` llama a `ui::IsScreenCaptureAllowed`, así que basta con el cambio central |
| b1 | bc `chromium_src/.../render_view_context_menu.cc` y `components/text_recognition/browser/text_recognition.mm` | El elemento del menú no se añade en 10.14, y `GetTextFromImage` devuelve `{false, {}}` en 10.14 | Antes devolvía `{true, vacío}` («soportado, sin texto») |

**Sin cambios:** d11 (entitlements, lo decide PUBLICACIÓN con el `codesign` de LOCAL). d5, d6, d7 y d9 quedan resueltos con
d1 (`nullptr`), como decía el inventario.

### Riesgos y límites (sin Mac no se ha podido probar)
- **Tests de Chromium:** `crypto_unittests` de Mac (claves no exportables) y `device_unittests` de Touch ID que usan el
  autenticador real fallarán o se saltarán. No los ejecutamos y no bloquean nada.
- **Sitios que preguntan `isUserVerifyingPlatformAuthenticatorAvailable()`:** ahora reciben false en todas las Mac, así
  que no ofrecerán «crear una passkey en este dispositivo». Es lo que se busca.
- **c2 en 10.14:** el permiso vuelve a ser siempre «permitido», como en la 116. Si en 10.14 hubiera un caso real de
  denegación, no lo veríamos (en 10.14 no existía ese permiso).

### Pruebas para LOCAL

- **6,1 (Mojave), perfil temporal:**
  a. Arranque: en `chrome://histograms`, que no aparezca `Crypto.TPMSupport2` ni `Crypto.TPMOperation.*` (d2).
  b. WebAuthn: en https://webauthn.io, registrar con «Platform»: no se ofrece el autenticador del Mac; con «Cross-platform»
     se ofrecen el teléfono o la llave. En la consola, `PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable()`
     → `false`.
  c. Gestor de contraseñas: con la reautenticación activa, al ver una contraseña aparece el diálogo de la contraseña del
     sistema, no el de Touch ID.
  d. Audio (c1): un vídeo de YouTube y https://webaudiodemos.appspot.com (o una prueba WebRTC de 2 min): sin cortes. En
     `chrome://version` no hace falta nada; si se quiere comparar, `--disable-features=OptimizedRealtimeThreadingMac` en la -p21.
  e. `getDisplayMedia` (c2): en https://webrtc.github.io/samples/src/content/getusermedia/getdisplaymedia/ comparte la
     pantalla sin el mensaje de «Grabación de pantalla», **con y sin otras apps abiertas** (era lo que fallaba).
  f. Menú contextual de una imagen (b1): no aparece «Copiar texto de la imagen».
- **7,1 (Sequoia, T2), sin ventanas si Titín trabaja (`--headless=new` donde se pueda):**
  a. Con la -p21 (o la 2.0.1) y la -p23: `log stream --predicate 'subsystem == "com.apple.security"'` durante el arranque, o
     `chrome://histograms` → `Crypto.TPMSupport2`: con la -p23, nada (la -p21 sí lo crea).
  b. `isUserVerifyingPlatformAuthenticatorAvailable()` → `false` (en la -p21, `true` si la app lleva `.webauthn`).
  c. Si había passkeys de la 2.0.x en el perfil de pruebas: aparecen en Ajustes › Autocompletar › Gestionar llaves de
     acceso y se pueden borrar.
  d. Menú de una imagen: «Copiar texto de la imagen» sí aparece y copia texto (en 10.15+ no cambia).
- **`codesign -d --entitlements :- FlyWeb.app`** de la Release: resultado en FM.42 para PUBLICACIÓN (d11).

## 7. Mosca de la NTP (FM.43; hecho, sin compilar)

**Causa** [comprobado en el código de brave-core: 1.15.2 (`flyweb` 9401833a) frente a -p22; lo midió LOCAL-11 con
`elementsFromPoint`]: la 1.69 sacó del bloque `.page-stuck` el fondo propio de `StyledPage`
(`background: var(--default-bg-color)`, su `:before` fijo con la imagen, `opacity` y `filter: blur()`), que Brave necesita
para difuminar Brave News. Desde la 2.0.0, la página (z-index 6) es opaca sobre el fondo de `App`, y la mosca (z-index 3,
entre las dos) queda tapada. La mosca seguía viva: bucle `requestAnimationFrame` a 60 Hz que cambia `transform` y anima
la `opacity` de las alas (trazos SVG, que no pasan al compositor). Cada cuadro era estilo y pintado en el hilo principal y
rasterizado en el proceso GPU, además del fondo duplicado a pantalla completa y el `filter` de la página.

**Arreglo** (`17e7858669`, solo ficheros de bc, sin parches de Chromium):
- `components/default/page/index.tsx`: el fondo, la `opacity` y el `filter` de `StyledPage`, otra vez solo con `.page-stuck`,
  como en la 1.15. FlyWeb no tiene Brave News, así que la página nunca se queda pegada. La mosca vuelve a pasar **por debajo
  de los controles y por encima del fondo**, igual que en la 1.15. Los clics la atraviesan (`pointer-events: none`).
- `flyweb/mosca.tsx`: la trayectoria, el aleteo, el tamaño y los tiempos son los de la 1.15 (mismas fórmulas y ajustes).
  Cambia cómo se dibuja:
  - Cada tramo (un vuelo entre posaderos o una parada) se calcula una vez, muestreado a 60 Hz como el bucle antiguo, y se
    reproduce como Web Animation de `transform`, en el compositor. El ángulo se desenrolla para que la interpolación no dé
    una vuelta entera.
  - El dibujo va en tres capas, en su orden: lo de debajo, las alas y el cuerpo. Las alas laten con una animación de
    `opacity` de su capa, `steps(2, jump-none)` cada 90 ms, entre 1 y 0,3 (0,4 → 0,12 de sus trazos). Al posarse vuelven a
    0,4 en 0,25 s, como la transición de la 1.15.
  - El hilo principal solo despierta al acabar cada tramo, cada pocos segundos.
  - Con `document.hidden` (pestaña o ventana tapada) se pausan las animaciones y siguen donde estaban.
  - Si se cambia el tamaño de la ventana, se recalcula el tramo en curso.
- **Medida en la nube** (Chromium de Playwright sin GPU, 1280×800, 10 s, métricas de CDP; no vale como cifra de la 6,1):
  la versión de la 1.15 hace 596 recálculos de estilo y 0,508 s de tareas del hilo principal (~5 %); la nueva, 0 y 0,012 s.
  Comprobado también: 3 capas, la pausa con `hidden`, el cambio de tamaño, «reducir movimiento» y ningún error en consola.

**Lo que cambia a la vista (para Titín):**
- (a) La mosca **vuelve a verse** (como en la 1.15).
- (b) **Con «Reducir movimiento» la mosca se queda quieta** en un posadero al azar (lo pedían `disenos.md` §3 y la orden de
  COORDINACIÓN). En la 1.15 volaba más despacio y con menos temblor. Si Titín prefiere lo de la 1.15, se vuelve a ello con
  unas líneas.
- (c) Posible matiz: al rotar una capa ya rasterizada, el compositor filtra la imagen, y el borde puede verse un poco más
  suave que el SVG repintado de la 1.15. Lo dirán las capturas.

**Riesgo F5.3:** la mosca animada en el compositor tiene capa propia, como con `will-change`. En la 1.x, en la 6,1 con la
pantalla 4K en modo escalado, eso dibujaba una línea intermitente en toda la pantalla (F5.3). La 2.0 tiene otra GPU (ANGLE
sobre Metal), así que puede no pasar, pero hay que mirarlo. Si vuelve, la salida es revertir solo el `mosca.tsx` de este
commit (vuelve el bucle de la 1.15, ya visible gracias al arreglo de `page`). Se perdería el ahorro de CPU, pero no la
mosca.

### Pruebas para LOCAL (6,1, Mojave; fondo en reposo comprobado antes de cada medida)

1. **Fondo:** sin FlyWeb, 2 min de `ioreg -r -d 1 -c IOAccelerator | grep -i utilization` y `top -l` en 0–1 %. Si Titín
   está usando la 6,1, díselo en su ventana y espera.
2. **NTP, 2 min, una ventana, perfil limpio, sin extensiones:** GPU % y CPU del proceso GPU (y del renderer de la NTP) con
   la **1.15.2**, la **-p21** y la **-p23**. Objetivo: la -p23 ≤ 1.15.2 (~5 % del proceso GPU).
3. **Pausa:** con la NTP de la -p23 en otra pestaña (o la ventana tapada o minimizada), el proceso GPU vuelve a su nivel de
   `about:blank`.
4. **Reducir movimiento** (Accesibilidad › Pantalla): la mosca, quieta. Al quitarlo, vuelve a volar sin recargar.
5. **F5.3:** pantalla 4K de la 6,1 en modo escalado («parece 3008×1692»), 1 min con la NTP: ¿línea intermitente? Si sale,
   repetir con la -p21 para ver si es de la mosca y avisar a MOTOR (no se publica así).
6. `flyweb://tracing` de 10 s (categorías cc, viz, gpu) con la NTP de la -p23: los cuadros salen del compositor sin
   `BeginMainFrame` cada cuadro. Opcional si 2 y 3 salen bien.
7. **Para Titín:** vídeo corto (10–15 s) o 3 capturas de la mosca en la 1.15.2 y en la -p23, con el mismo fondo y tamaño de
   ventana, también con «Reducir movimiento» en la -p23. DMG de prueba.

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
