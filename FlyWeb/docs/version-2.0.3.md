# FlyWeb 2.0.3 — Mojave, tanda 1 (FM.42)

MOTOR-22, 27-10-2026. Orden de COORDINACIÓN-15: tanda 1 de [`mojave-128.md`](mojave-128.md) sobre la -p21 3cc4ce116c
(2.0.2). brave-core `nube/base-128-motor-p22` **9b9fdbbd44**, un commit; `flyweb_version` 2.0.3 y LOCAL compila con
`FLYWEB_BUILD_NUMBER=31`. Va como `p22.bundle` en la rama de softmac `nube/motor22-p22`. **Sin compilar**: en la nube no
hay SDK de macOS. Los parches se generaron con `git diff --full-index` contra Chromium 128.0.6613.138 y se comprobó con
`git apply` que entran limpios en la 128 sin tocar.

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12.)*

- **Llaves de acceso (passkeys) y Touch ID:** FlyWeb ya no guarda llaves de acceso en el chip de seguridad del Mac (T2 /
  Secure Enclave) ni usa Touch ID, en ningún Mac. Es igual en todos los Mac compatibles y no depende de un chip que Mojave
  no aprovecha del todo.
  - **Si creaste una llave de acceso con FlyWeb 2.0.0–2.0.2 en un Mac con chip T2** (MacBook Pro y MacBook Air de 2018
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

## Qué cambia (ficheros)

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

**Riesgos y límites (sin Mac no se ha podido probar):**
- **Tests de Chromium:** `crypto_unittests` de Mac (claves no exportables) y `device_unittests` de Touch ID que usan el
  autenticador real fallarán o se saltarán. No los ejecutamos y no bloquean nada.
- **Sitios que preguntan `isUserVerifyingPlatformAuthenticatorAvailable()`:** ahora reciben false en todas las Mac, así
  que no ofrecerán «crear una passkey en este dispositivo». Es lo que se busca.
- **c2 en 10.14:** el permiso vuelve a ser siempre «permitido», como en la 116. Si en 10.14 hubiera un caso real de
  denegación, no lo veríamos (en 10.14 no existía ese permiso).

## Pruebas para LOCAL

- **6,1 (Mojave), perfil temporal:**
  a. Arranque: en `chrome://histograms`, que no aparezca `Crypto.TPMSupport2` ni `Crypto.TPMOperation.*` (d2).
  b. WebAuthn: en https://webauthn.io, registrar con «Platform»: no se ofrece el autenticador del Mac; con «Cross-platform»
     se ofrecen el teléfono o la llave. En la consola, `PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable()`
     → `false`.
  c. Gestor de contraseñas: con la reautenticación activa, al ver una contraseña aparece el diálogo de la contraseña del
     sistema, no el de Touch ID.
  d. Audio (c1): un vídeo de YouTube y https://webaudiodemos.appspot.com (o una prueba WebRTC de 2 min): sin cortes. En
     `chrome://version` no hace falta nada; si se quiere comparar, `--disable-features=OptimizedRealtimeThreadingMac` en la 2.0.2.
  e. `getDisplayMedia` (c2): en https://webrtc.github.io/samples/src/content/getusermedia/getdisplaymedia/ comparte la
     pantalla sin el mensaje de «Grabación de pantalla», **con y sin otras apps abiertas** (era lo que fallaba).
  f. Menú contextual de una imagen (b1): no aparece «Copiar texto de la imagen».
- **7,1 (Sequoia, T2), sin ventanas si Titín trabaja (`--headless=new` donde se pueda):**
  a. Con la 2.0.2 y la -p22: `log stream --predicate 'subsystem == "com.apple.security"'` durante el arranque, o
     `chrome://histograms` → `Crypto.TPMSupport2`: con la -p22, nada (la 2.0.2 sí lo crea).
  b. `isUserVerifyingPlatformAuthenticatorAvailable()` → `false` (en la 2.0.2, `true` si la app lleva `.webauthn`).
  c. Si había passkeys de la 2.0.x en el perfil de pruebas: aparecen en Ajustes › Autocompletar › Gestionar llaves de
     acceso y se pueden borrar.
  d. Menú de una imagen: «Copiar texto de la imagen» sí aparece y copia texto (en 10.15+ no cambia).
- **`codesign -d --entitlements :- FlyWeb.app`** de la Release: resultado en FM.42 para PUBLICACIÓN (d11).
