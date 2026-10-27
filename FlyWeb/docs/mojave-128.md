# Mojave al 100 % en la base 128: inventario (FM.42)

MOTOR-21, 27-10-2026. Base: Chromium **128.0.6613.138** con los parches de brave-core `nube/base-128-motor-p21`
(3cc4ce116c, la 2.0.2). Directiva de Titín del 27-10 (`docs/DIRECTIVAS.md`): lo que la 128 hace con APIs de 10.15+
tiene en 10.14 otro camino (API de 10.14 o código de la 116), y **nada de Secure Enclave (SE) ni T2 en ninguna Mac**.
Solo inventario: no se porta nada hasta que COORDINACIÓN lo revise.

Método: se hizo un checkout parcial de la 116 y de la 128 (`*.mm`, `*_mac.*`, `*_apple.cc`, `*.gni`) y se le aplicaron
los 59 parches de la -p21 que caen en esos ficheros. Se buscaron las guardas de 10.14/10.15 de la 116 y unos 60
símbolos de 10.15, y se compararon las dos bases. Lo leyeron cuatro subagentes y las filas clave están comprobadas a mano.
Evidencia: [V] visto en el código, [I] inferido (sin probar en una Mac).
**Límites:** el registro real de avisos `-Wunguarded-availability` de la Release todavía no ha llegado de LOCAL. Los
`.cc` que quedan fuera del checkout (webrtc, ports de Skia, VideoToolbox) se miraron solo en parte. La GPU (FM.31) solo
se comprobó.

Coste: bajo < 1 h, medio 1–4 h, alto > 4 h. Prioridad: **P1** = el usuario lo nota en uso normal o es una decisión de
Titín; P2 = se nota en casos concretos; P3 = marginal.

## 0. `crypto/unexportable_key_mac.mm:263` (`kSecUseDataProtectionKeychain`): no se llega en Mojave [V]

Esa línea solo se ejecuta desde un `UnexportableKeyProviderMac`, y ese objeto solo lo crea
`GetUnexportableKeyProviderMac()`. Nuestro `patches/crypto-unexportable_key_mac.mm.patch` (LOCAL-8) hace que devuelva
`nullptr` con `@available(macOS 10.15)` antes que nada. Todos los que lo llaman comprueban el `nullptr`:
`GetUnexportableKeyProvider` (DBSC, enclave de GPM, métricas) y `user_verifying_key_mac.mm` (`DoGenerateKey`, `DoGetKey`,
`AreMacUnexportableKeysAvailable`). **No hay -p22**: la -p21 se compila tal cual. Lo que sí llega al SE está en (d).

## (d) Secure Enclave, llavero de protección de datos y LocalAuthentication

**Lo más importante [V]:**
- En una Mac con T2 y 10.15+, la Release oficial **ya toca el SE en cada arranque**: la métrica `TpmLatencyMetrics`
  (activada por defecto) crea una clave, firma y la borra.
- **Las passkeys del perfil** (autenticador de plataforma con Touch ID) se crean en el SE **en cualquier Mac con T2,
  también en 10.14** (MacBook Pro y Air 2018, Mac mini 2018, iMac Pro). La 116 hacía lo mismo.
- Las dos cosas dependen solo de los `keychain-access-groups` que `bc/app/entitlements.gni` añade en la Release oficial
  (`//chrome/app/app-entitlements-chrome.plist`: `.unexportable-keys`, `.webauthn`, `.webauthn-uvk`, `.devicetrust`,
  `folsom`). **Falta saber si la app firmada los lleva de verdad**: lo comprueba LOCAL con
  `codesign -d --entitlements :- FlyWeb.app`.
- No hay `kSecAttrNoLegacy` en el navegador. `chromium_src/` de Brave no toca nada del SE (solo añade ECDSA_SHA384).

| # | Dónde | Qué hace | 10.14 hoy | 10.15+ con T2 hoy | Propuesta «sin SE» | Coste / prio |
|---|---|---|---|---|---|---|
| d1 | `crypto/unexportable_key_mac.mm` `GetUnexportableKeyProviderMac` | Claves EC no exportables en el SE | `nullptr` (parche LOCAL-8) | **Llega al SE**: `kEnableMacUnexportableKeys` activada por defecto (`crypto/features.cc:14`), token SE en `TKTokenWatcher` y entitlement | **Punto central:** devolver `nullptr` siempre (quitar el `@available` del parche) y desactivar la feature por defecto. No sustituirlo por el proveedor software en todo el navegador: guardaría la clave privada envuelta en el perfil | bajo / **P1** |
| d2 | `chrome_browser_main_extra_parts_metrics.cc` → `crypto::MaybeMeasureTpmOperations` | Mide la latencia: crea, firma y borra una clave | nada | **SE en cada arranque** (`TpmLatencyMetrics` activada) | Desaparece con d1; refuerzo: desactivar `TpmLatencyMetrics` | bajo / **P1** |
| d3 | `device/fido/mac/touch_id_context.mm` `TouchIdAvailableImpl` + `credential_store.mm` | Autenticador de plataforma: passkeys del perfil en el SE, verificación con `LAContext` | **true en Mac con T2** si la app lleva `.webauthn` [I] | true | `TouchIdAvailableImpl` → false siempre. **Conservar** la búsqueda, el borrado y la gestión (`local_credential_management_mac.cc`, borrado de datos) para limpiar las passkeys que ya existan | bajo / **P1** |
| d4 | `device/fido/mac/util.mm` `DeviceHasBiometricsAvailable`; `device_reauth/mac/authenticator_mac.mm` | Touch ID en WebAuthn y para reautenticarse en el gestor de contraseñas (`evaluateAccessControl` con `UserPresence`, sin clave en el SE) | Touch ID si la Mac lo tiene; si no, contraseña del sistema con Authorization Services (`password_manager_util_mac::AuthenticateUser`) | Touch ID (la huella se compara en el T2) | `CheckIfBiometricsAvailable` y `DeviceHasBiometricsAvailable` → false: siempre la contraseña del sistema, como en una Mac sin Touch ID (el camino clásico). `LAPolicyDeviceOwnerAuthentication` no vale porque también ofrece la huella [I] | bajo / P2 |
| d5 | `crypto/user_verifying_key_mac.mm` | Claves con verificación de usuario (SE + `UserPresence`) para GPM | no disponible (d1) | SE si GPM estuviera activo | Sale gratis con d1 | — / P3 |
| d6 | `chrome/browser/webauthn/enclave_manager.cc` (GPM) | Passkeys en el enclave de Google | inactivo | inactivo: `kWebAuthnEnclaveAuthenticator` desactivada y hace falta una cuenta de Google con sync | Dejarla desactivada. **No** usar `kWebAuthnUseInsecureSoftwareUnexportableKeys`: la clave UV seguiría yendo al SE | — / P3 |
| d7 | DBSC (`bound_session_credentials/unexportable_key_service_factory.cc`) | Cookies de sesión ligadas a una clave del dispositivo | sin soporte (d1) | solo con la feature o la política (desactivada por defecto) y solo cookies de Google | Sin soporte con d1; opcional `enable_bound_session_credentials=false` en `build.sh` | bajo / P2 |
| d8 | Device trust (`device_trust/.../mac/secure_enclave_client_impl.mm`) | Clave de empresa en el SE | parcheado (sin `kSecUseDataProtectionKeychain`); en Mac con T2 podría crearla [I] | **SE** con la política DeviceTrust | `IsSecureEnclaveSupported` → false. En Mac no hay proveedor software: device trust queda sin clave | bajo / P3 |
| d9 | `components/enterprise/client_certificates` | Certificado de cliente gestionado | clave software | SE si hay política | Pasa a clave software sola con d1 | — / P3 |
| d10 | `device/fido/mac/icloud_keychain.mm` | Passkeys de iCloud (las gestiona el sistema) | no (exige 13.5) | solo 13.5+ | Fuera del rango soportado (10.14–12). Por coherencia, desactivar las features o quitar el entitlement `web-browser.public-key-credential` | bajo / P3 |
| d11 | `bc/app/entitlements.gni` | Añade los grupos de llavero en la Release | habilitan d1–d3 y d8 | igual | Refuerzo: no incluir `app-entitlements-chrome.plist` (lo que ya recomendaba `rebranding.md` §5.3 b). Ojo: cambia la firma; hay que comprobar Sparkle y que se puedan seguir borrando las passkeys antiguas (necesita `.webauthn`) | bajo / P2 |

**Mínimo para «sin SE en todas las Mac»:** d1 + d3 + d4 (unas cuatro líneas, menos de 1 h). Con eso desaparecen d2, d5,
d7 y d9. Device trust (d8) necesita su propio false.
**Riesgo:** en una Mac con T2, las passkeys del perfil creadas por la 2.0.0–2.0.2 viven en el SE y no se pueden
exportar. Al apagar el autenticador, el usuario tiene que volver a registrar la passkey en cada web. Siguen valiendo
las llaves de seguridad, el teléfono por QR y los gestores de terceros. Hay que avisarlo en las notas de versión y no
quitar el entitlement `.webauthn` mientras haya que borrarlas.
**Equivalente por software de las passkeys del perfil** (clave en el llavero clásico con ACL `SecAccess` y verificación
con Authorization Services): es un autenticador nuevo, de coste alto y P3. Lo decide Titín.

## Claves y cifrado en reposo (petición de COORDINACIÓN-15: solo lo que hay, sin propuestas)

**OSCrypt de Mac** [V]:
- `components/os_crypt/sync/os_crypt_mac.mm`: prefijo `v10` (l. 44), AES-128-CBC (`crypto::Encryptor` CBC →
  `EVP_aes_128_cbc`, `crypto/encryptor.cc:28`) con un IV de 16 espacios (l. 168 y 208).
- La clave sale de PBKDF2-HMAC-SHA1 (`crypto/symmetric_key.cc:85`) con sal `saltysalt` (l. 33), **1003 iteraciones**
  (l. 39) y 128 bits (l. 36).
- La contraseña de PBKDF2 son 16 bytes aleatorios en Base64 (`keychain_password_mac.mm:45`). Se guarda en el **llavero
  clásico** (`SecKeychainFindGenericPassword`/`SecKeychainAddGenericPassword`, `crypto/apple_keychain_mac.cc:65` y 84),
  servicio «FlyWeb Safe Storage», cuenta «FlyWeb» (`bc/chromium_src/components/os_crypt/sync/keychain_password_mac.mm:14-15`).
- Ni SE ni APIs de 10.15. No se ha mirado si `os_crypt_async` está activo en Mac: lo estudia SEGURIDAD-PORTES-7 (FS.25).

**Claves no exportables y SE:** ver (d). Sin SE, se pierden:
- las passkeys del perfil (d3);
- Touch ID en el gestor de contraseñas (queda la contraseña del sistema, d4);
- DBSC (d7) y device trust (d8), sin uso real en FlyWeb;
- las claves UV y el enclave de GPM (d5–d6), que ya estaban inactivos.

**BoringSSL** (revisión `f01108e4`, `DEPS:337`) [V]:
- Se compila con ensamblador y `OPENSSL_SMALL`, sin `-mavx` ni `-march` (`third_party/boringssl/BUILD.gn:36-39` y
  104-131). Todo se elige en tiempo de ejecución por CPUID (`crypto/internal.h:1398-1505`).
- Si el sistema no guarda los registros YMM, `cpu_intel.c:219-237` borra AVX y AVX2.
- **Nada exige AVX.** En esta revisión no hay rutas AVX-512 ni VAES.

| Algoritmo | 5,1 Nehalem | 5,1 Westmere | 6,1 (Ivy Bridge-EP) | 7,1 (Cascade Lake) |
|---|---|---|---|---|
| AES-CBC (OSCrypt) | `vpaes_cbc_encrypt` (SSSE3) | `aes_hw_cbc_encrypt` (AES-NI) | `aes_hw_cbc_encrypt` | `aes_hw_cbc_encrypt` |
| AES-GCM (TLS) | `vpaes_ctr32` + `gcm_*_ssse3` | `aes_hw_ctr32` + `gcm_*_clmul` | igual que Westmere (sin MOVBE no hay `aesni_gcm`) | `aesni_gcm_*` + `gcm_*_avx` |
| ChaCha20-Poly1305 | SSE4.1 (`chacha20_poly1305_*`) | igual | igual | `*_avx2` |
| SHA-1 (PBKDF2) / SHA-256 | `_ssse3` / `_ssse3` | `_ssse3` / `_ssse3` | `_avx` / `_avx` | `_avx2` / `_avx` |
| X25519 / P-256 | fiat C (sin ensamblador por `OPENSSL_SMALL`) | igual | igual | igual |

La decisión está en `aes/aes.c:120-124`, `cipher/e_aes.c:159-207` y `290-331`, `modes/gcm.c:184-201` y 254,
`chacha/chacha.c:73-91` y `sha/sha1.c:387-419`; las rutas son de BoringSSL, bajo `crypto/fipsmodule/`.

**Para probar:** la 6,1 y la 7,1 no recorren las rutas de la 5,1 con Nehalem; hay que probar en la propia 5,1 o
enmascarar con `OPENSSL_ia32cap` (`cpu_intel.c:263-273`). Falta por saber si la 5,1 del estudio es Nehalem o Westmere:
`sysctl machdep.cpu.brand_string`.

## (a) Usos de APIs de 10.15+ sin guarda (los que avisa el compilador)

Repaso de los grupos del anexo de `version-2.0.2.md` en el código parcheado:

| # | Dónde (cr128) | API | En 10.14 | Qué se pierde | Equivalente 10.14 | Coste / prio |
|---|---|---|---|---|---|---|
| a1 | `app_controller_mac.mm:1215`, `auth_session_request.mm` (~22 avisos) | `ASWebAuthenticationSession*` | solo un mensaje a nil (clase débil) | nada respecto a la 116 (la API no existe en 10.14) | ninguno; `@available` solo para quitar el aviso | bajo / P3 |
| a2 | `video_capture_device_avfoundation.mm:627` | `AVCapturePhotoOutput` | guarda → `OnPhotoError` | `ImageCapture.takePhoto()` | `AVCaptureStillImageOutput` (10.7): código de la 116 en ese mismo fichero, l. 490-680 | medio / P3 |
| a3 | `mac_intent_picker_helpers.mm:93` | `SFUniversalLink` | guardado | «abrir en la app» (igual que la 116) | no existe | — |
| a4 | `gpu_mojo_media_client_mac.cc:35` | xHE-AAC | arreglado en la -p21 (c2be18ce) | — | — | — |
| a5 | Paridad con la 116 (parches LOCAL-6/8) | lanzar apps y abrir ficheros, `posix_spawn` chdir, `platform_util`, `fontWithSize:`, Bluetooth, mandos, cámaras, `_CSCheckFixDisable`, `color_space_util`, HDR | camino de la 116 | nada | ya hecho | — |

Cuando llegue el registro de LOCAL, cualquier aviso que no esté en esta tabla es una caída en potencia
(`relevo-local.md`).

## (b) Ramas con guarda cuyo «si no» degrada en 10.14

Las ramas de upstream para macOS 11–14 (portapapeles, notificaciones, pantalla completa, ScreenCaptureKit…) no
cuentan: Mojave va por el mismo «si no» que Catalina, ya probado por Google, sin APIs de 10.15 [V].

| # | Dónde | Qué pierde Mojave | Equivalente 10.14 | Coste / prio |
|---|---|---|---|---|
| b1 | Brave `components/text_recognition/browser/text_recognition.mm:29` (`VNRecognizeTextRequest`, 10.15) | **«Copiar texto de la imagen» aparece y devuelve vacío**: el «no hay» silencioso que prohíbe la directiva | Vision de 10.14 no reconoce texto. Ocultar el elemento en 10.14 (bajo) o motor propio, p. ej. Tesseract (alto) | bajo / P2 |
| b2 | `eye_dropper_view_mac.mm:44-54` (`NSColorSampler`, parche LOCAL-8 → nullptr) | API `EyeDropper` rechazada; `<input type=color>` conserva la lupa de NSColorPanel [I] | Compilar `components/eye_dropper/eye_dropper_view.cc` en Mac y reponer la parte Mac de la 116 (`eye_dropper_view_mac.mm:40-125`) | alto / P3 |
| b3 | `screen_mac.mm:208` (`NSScreen.localizedName`) | `screen.label` vacío (Window Management) | Código de la 116 (`screen_mac.mm:82-150`, `IODisplayCreateInfoDictionary`) | medio / P3 |
| b4 | `system_geolocation_source_apple.mm:120` (`requestWhenInUseAuthorization`) + `system_permission_settings_mac.cc:153-160` | El flujo normal va bien; el elemento `<permission>` y los ajustes pueden quedarse esperando [I] | En 10.14, `startUpdatingLocation` y `stop` para que salga el diálogo | bajo / P2 (probar antes) |
| b5 | Brave `geolocation_utils_mac.mm:24,42` (`-authorizationStatus`, 11) | Sin el aviso de «localización desactivada en el sistema» (10.14 y 10.15) | `+[CLLocationManager authorizationStatus]` (10.7) | bajo / P3 |
| b6 | `render_widget_host_view_mac.mm:1383` (Pointer Lock `unadjustedMovement`, 10.15.1) | `NotSupported` en juegos (igual que la 116) | El propio comentario de upstream dice que los campos de CGEvent sin aceleración funcionan desde 10.14: bajar la guarda y probar | bajo / P3 |

## (c) Caminos de 10.13/10.14 que la 116 tenía y la 128 borró

| # | 116 → 128 | Qué hacía la 116 en 10.14 | Estado en la -p21 | Qué pierde Mojave | Coste / prio |
|---|---|---|---|---|---|
| c1 | `base/threading/platform_thread_mac.mm:104-108` → `platform_thread_apple.mm:98` | `IsOptimizedRealtimeThreadingMacEnabled()` → false en 10.14 («some platform bug on 10.14») [V] | **borrado**; la feature está activada por defecto en Mac (l. 87-94) [V] | Los hilos de audio en tiempo real usan la política que la 116 evitaba en Mojave: posibles cortes en WebAudio, WebRTC y la reproducción [I] | bajo (una línea con `MacOSVersion() < 10'15'00`) / **P1** |
| c2 | `ui/base/cocoa/permissions_utils.mm:114,151,170`, `system_media_capture_permissions_mac.mm` | Captura de pantalla «permitida» antes de 10.15, sin calentar la captura | **borrado** (Brave solo añade Sequoia) | `getDisplayMedia` puede salir denegado y remitir a un «Grabación de pantalla» que no existe en 10.14 [I: depende de las ventanas abiertas]; además hace una captura inútil en cada arranque | bajo / P2 |
| c3 | `file_system_access_regular_file_delegate.cc` + `file_utilities.mojom` `SetLength` | En 10.14 el sandbox no deja al renderer hacer `ftruncate`; la 116 lo pedía al proceso del navegador | **borrado** (el mojom de la 128 no tiene `SetLength`) [V] | `FileSystemSyncAccessHandle.truncate()` falla en OPFS (SQLite-WASM y editores web) | medio-alto (5–10 h; mojom de Blink → **regla 17**) / P2 |
| c4 | `menu_controller_cocoa_delegate_impl.mm` | `NSTextAttachmentCell` para la insignia «Nuevo» (10.13–10.14 ignoran `flipped`) | borrado | Insignia «Nuevo» y punto IPH de los menús, quizá invertidos [I] | bajo / P3 |
| c5 | `content/common/font_list_mac.mm` `IsHiddenFontFamily` | Quitaba las familias que empiezan por «.» | borrado | Familias «.SF…» en Ajustes › Fuentes [I] | bajo / P3 |
| c6 | `base/apple/foundation_util.mm` (puente CTFont↔NSFont, `_CFIsObjC`) | `CFCast` tolerante antes de 10.15 | borrado | Nada en Release; aborta con DCHECK (ASan) | bajo / P3 |
| c7 | `barcode_detection_impl_mac` | CIDetector en 10.14.0–10.14.2 | borrado | Solo en 10.14.0–10.14.2 | — (no aplica en 10.14.6) |

Lo que en la 116 protegía solo a 10.13 (notificaciones, tema oscuro, colores, diálogos de ficheros…) no aplica: Mojave
ya tiene esas APIs [V].

## GPU (FM.31): comprobación

- Los parches de la -p21 están [V]: Dawn `PhysicalDeviceMTL.mm` y `AlignedAlloc.cpp`, ANGLE Metal (BUILD.gn,
  `TextureMtl.mm`), `color_space_util.mm`, `hdr_copier_layer.mm`, `image_transport_surface_overlay_mac.mm`,
  `gl_display_initializer.cc` y `gl_switches.cc`.
- **Listas de GPU** (fila 14 de `base-128.md`): sin parche. Se compararon las de la 116 y la 128 [V]:
  - `gpu_driver_bug_list.json` pierde 39 entradas de Mac y `software_rendering_list.json` 9.
  - Las que tienen versión son de ≤10.13; ninguna limita su versión a Mojave.
  - Las que no tienen versión valen para todas las macOS y son del decodificador GL validante, que la 128 ya no tiene [I].
  - Conclusión: nada propio de Mojave que reponer. Los apaños del backend GL de ANGLE están en sus propias listas.

## Orden propuesto (2.0.3 y siguientes; lo decide COORDINACIÓN)

1. **2.0.3, tanda 1 (bajo coste, se nota o lo ha decidido Titín):**
   - d1 + d2 + d3 + d4: sin SE en todas las Mac; aviso de las passkeys en las notas de versión;
   - c1: hilos de audio;
   - c2: captura de pantalla;
   - b1: ocultar «Copiar texto de la imagen» en 10.14.
   - Antes de nada, LOCAL comprueba los entitlements reales de la app.
2. **Tanda 2:** b4 (después de probarlo en Mojave), d11, b5, b6, c4, c5.
3. **Tanda 3 (coste medio-alto):** c3 (OPFS truncate, con su fila FS por la regla 17), a2 (fotos), b3 (nombre de
   pantalla), b2 (cuentagotas).
4. **Para Titín:** ¿passkeys del perfil por software (alto) o solo las llaves externas, el teléfono y los gestores?
