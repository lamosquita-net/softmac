# FlyWeb — Brave 1.69.168 por encima de macOS 10.14 (INVESTIGACIÓN-MOTOR-2, 21-10-2026)

Encargo de COORDINACIÓN-11 (fila FM.31, #428): qué usa brave-core **1.69.168** (Chromium 128; tag `b44ebef655` →
commit `6918a99a`) que no esté en macOS 10.14 y no usara ya la **1.57.64** (`25c5f015`). Titín sospechaba que Brave
traería en sus propios componentes problemas de API de 10.15 como los de Chromium (Dawn en la GPU). Solo papel.
Etiquetas: **[V]** verificado en el código o en las cabeceras; **[H]** hipótesis o estimación.

## 1. Respuesta corta

1. **Brave no trae problemas propios de macOS 10.15 [V].** En sus ficheros de macOS nuevos o cambiados (63 ficheros,
   2 109 líneas añadidas) no hay **ninguna** llamada sin guarda a una API posterior a 10.14. Las tres de 10.15 o más
   (Vision 10.15/13, CoreLocation 11, NSMenuItem 12) llevan `@available`. Con eso, la clase E de `migracion-128.md` da
   **0 horas por macOS**, como decía, aunque §5 contaba mal las guardas nuevas: son **dos**, no una (§6).
2. **GPU y Dawn: Brave no los toca [V].** No hay `.patch` ni `chromium_src` en `gpu/`, `third_party/dawn`, ANGLE,
   Skia, Metal, IOSurface, VideoToolbox ni AVFoundation. Lo de `components/viz` es solo de Windows. En WebGPU solo
   está el *farbling* de Blink (WebGL), sin código de macOS. **Lo de Dawn es entero de Chromium** (clase I, apartado
   «No cubre», de `migracion-128.md`) y se mide en la compilación limpia de la 128 de LOCAL.
3. **Frameworks enlazados [V]:** solo uno nuevo, `CoreLocation.framework` (macOS 10.6). `NetworkExtension` (VPN, desde
   10.11) y `Vision` (desde 10.13) ya estaban en la 1.57.
4. **Rust [V]:** Brave no fija un objetivo mínimo propio. El enlace final lo hace clang con
   `-mmacos-version-min=$mac_deployment_target` (el de Chromium; nosotros, 10.14). Las crates que tocan API de Apple
   (`core-foundation-sys` 0.8.3, `iana-time-zone` 0.1.54 y `getrandom` 0.1.16/0.2.15) usan funciones de 10.12 o
   anteriores. `adblock` 0.8.11 es Rust puro.
5. **Sparkle y `keystone_glue` [V]:** Sparkle sigue en la **1.24.3** precompilada (mismo commit de `brave/Sparkle` que
   en la 1.57). El `keystone_glue` nuevo es una capa de Brave sobre Sparkle (`KeystoneEnabled()` →
   `SparkleEnabled()`) que solo usa Foundation antigua. **No hay API nueva**; lo que sí hay es **trabajo de fusión**
   contra nuestro Sparkle (§4), que va en la clase C o F, no en la de macOS.
6. **Horas por macOS en brave-core: 0–2 h [H]**, para un arreglo opcional de geolocalización y la revisión de avisos.

## 2. Método (reproducible) y límites

- Clonados de `github.com/brave/brave-core` los tags `v1.57.64` y `v1.69.168`. Diferencia recursiva fuera de `ios/`,
  `android/` y `third_party/`: los ficheros `.mm`, `.m`, `*_mac.*` y `/mac/`, y los `.patch` sobre ficheros de macOS de
  Chromium. De cada uno, solo las líneas añadidas.
- **Índice de disponibilidad [V]:** a partir de las cabeceras del **SDK macOS 14.5** (el que usa LOCAL), con las
  marcas `API_AVAILABLE(macos(…))`, `NS_AVAILABLE_MAC`, `CG_AVAILABLE_STARTING`, `__MAC_10_15`, etc., se reunieron
  22 693 nombres con versión ≥ 10.15. Se cruzó con todos los identificadores de esas líneas y se repasaron a mano los
  candidatos y todas las llamadas a `NS*`, `CF*`, `CL*`, `NE*`, `VN*`, `Sec*`… (350 líneas).
- **Límite 1:** el índice confunde nombres genéricos (`name`, `status`, `URLWithString:`), así que la decisión final es
  lectura a mano. **Límite 2:** no ve llamadas dinámicas (`NSClassFromString`, `performSelector`). La única nueva,
  `NSMenuBarDisplayManager` en `app_controller_mac.mm.patch`, devuelve `nil` en 10.14 y no hace nada [V].
  **Límite 3:** no compila. Pero Chromium 128 ya pone `-Wunguarded-availability` en Apple
  (`build/config/compiler/BUILD.gn`), con errores por aviso. **Cualquier uso sin guarda que se me haya escapado rompe la
  compilación de la Fase 1 con 10.14**: no puede pasar sin que se vea.
- **Fuera del alcance:** binarios que Brave baja como componentes (cliente Tor y similares). No están en brave-core y
  dependen de nuestro servidor de componentes.

## 3. Por componente

| Componente (1.69) | API por encima de 10.14 | ¿Guarda? | En la 6,1 / 5,1 (Mojave) | Apagar o proteger | Horas [H] |
|---|---|---|---|---|---|
| `components/text_recognition` (copiar texto de imagen) | `VNRecognizeTextRequest` (10.15), `automaticallyDetectsLanguage` (13.0) | Sí, `@available` desde la 1.57 [V] | La función no aparece en 10.14, como ahora | Nada (o `enable_text_recognition:false` si se quiere quitar) | 0 |
| `browser/ui/geolocation/geolocation_utils_mac.mm` (**nuevo**) | `-[CLLocationManager authorizationStatus]` (11.0) | Sí, `@available(macOS 11.0)` [V] | En 10.14 siempre devuelve «servicios de localización desactivados» y no da el detalle del permiso. Solo afecta al aviso de la burbuja; la geolocalización sigue funcionando [V por código, H en uso] | Opcional: en 10.14, usar el método de clase `+authorizationStatus` (10.7, obsoleto en 11) | 0–1 |
| `browser/ui/views/commands/default_accelerators_mac.mm` | `allowsAutomaticKeyEquivalentLocalization` y `…Mirroring` de `NSMenuItem` (12.0) | Sí, `@available(macos 12.0)` (en minúsculas: por eso no lo vio el `grep` de §5) [V] | Sin efecto: en 10.14 no existe la localización automática de atajos | Nada | 0 |
| VPN IKEv2 (`components/brave_vpn/.../ikev2/mac`, antes `brave_vpn_ras_connection_api_mac`) | Ninguna: `NEVPNManager`, `NEVPNProtocolIKEv2` y `NEOnDemandRuleConnect`/`probeURL` (nuevos en la 1.69) son de 10.11 [V] | — | Apagada en FlyWeb | Ya apagada: `enable_brave_vpn:false` (`assert(enable_brave_vpn)` en su `BUILD.gn`) | 0 |
| VPN WireGuard Mac (nuevo) | Ninguna (`NOTIMPLEMENTED()`) [V] | — | Apagada | Igual que la anterior | 0 |
| Anuncios: `background_helper_mac`, `notification_helper_impl_mac`, `device_id_impl_mac` | Ninguna (`NSApplication`, `NSNotificationCenter`, IOKit). La guarda de 10.14 ya estaba [V] | — | Sin cambio | Las de siempre de Brave Ads | 0 |
| Menú y Tor en el Dock (`brave_app_controller_mac.mm`), marco de ventana, color del título (`native_widget_ns_window_bridge.mm`) | Ninguna pública. El color del título sobrescribe `-[NSThemeFrame _currentTitleColor]`, que es **privado** [V] | — | Un método privado puede no existir en 10.14: el override no fallaría, pero no se vería el color [H] | Probar en la 6,1 en la Fase 1 | 0–1 (prueba) |
| `keystone_glue`, `keystone_registration`, `install_from_dmg`, `scheduler_mac`, `get_installed_version_mac`, `google_brand_mac` (nuevos o movidos) | Ninguna (Foundation, CFRunLoop, `authorization_util`) [V] | — | Sin efecto: `KeystoneEnabled()` = `SparkleEnabled()` | Fusión con nuestro Sparkle (§4) | (clase C/F) |
| `components/l10n` (`countryCode`, `languageCode` de `NSLocale`) | Ninguna (10.12) [V] | — | Sin cambio | — | 0 |
| `.patch` nuevos sobre ficheros de macOS de Chromium: `permissions_utils.mm` (captura de pantalla en Sequoia), `render_widget_host_view_cocoa.mm` (padre de accesibilidad), `apps_folder_support.mm` (carpeta de apps) | Ninguna propia. `permissions_utils.mm` también lo toca Chromium Legacy (clase I) [V] | — | Lo de Legacy manda | Fusión a mano de ese fichero (ya en §5 de `migracion-128.md`) | (clase I) |
| Los 10 servicios de la clase E (`ai_rewriter`, `brave_player`, `psst`, `script_injector`, `brave_service_keys`, `challenge_bypass_ristretto`, `onboarding`, `day_zero_browser_ui_expt`, `tab_group`, `storage_access_api`) | **Ninguna**: 0 ficheros `.mm`/`_mac`, 0 `IS_MAC`/framework. Solo `ai_rewriter` nombra `is_mac`, en su buildflag [V] | — | Sin efecto | `ai_rewriter` cuelga de `enable_ai_chat` (en FlyWeb, `false`) | 0 |

## 4. Sparkle y `keystone_glue`: no es macOS, pero hay que saberlo

- En la 1.69, Brave compila **siempre en Mac** `keystone_glue.mm` (739 líneas nuevas) y lo llama desde
  `BraveBrowserMainPartsMac::PostProfileInit`, `install_from_dmg`, `google_brand_mac`, el planificador del updater y
  `get_installed_version_mac` [V]. Todo acaba en `sparkle_glue` si `enable_sparkle` está activo. Si no, `KeystoneEnabled()`
  da `false` y esas rutas no hacen nada [V].
- **Para FlyWeb:** nuestro Sparkle propio (appcast, clave EdDSA, `FLYWEB_BUILD_NUMBER`) tendrá que encajar en esa capa.
  Es fusión de código (clases C/F de `migracion-128.md`), no compatibilidad con Mojave. En la comprobación tras cada
  fusión (fila FM.31) conviene añadir: **`strings` del binario sin `KSUpdateURL` ni hosts de Brave en el `Info.plist`** [H].
- Sparkle 1.24.3 admite 10.9 o superior [H: notas de versión de Sparkle 1.x]. Sin cambio respecto a la 1.57 [V].

## 5. Rust y las crates

- `build/config/rust.gni` (Chromium 128): `rust_abi_target = "x86_64-apple-darwin"`. rustc enlaza con
  `-Clinker=clang++` y las `ldflags` de Chromium, que llevan `-mmacos-version-min=$mac_deployment_target`
  (`build/config/mac/BUILD.gn`, `runtime_library`) [V]. Brave no lo cambia (0 coincidencias de
  `mac_deployment_target`/`LSMinimumSystemVersion` en brave-core) [V].
- El mínimo de Rust para `x86_64-apple-darwin` es **10.12** desde Rust 1.74 [V: Rust Blog, «Increasing the minimum
  supported Apple platform versions», 25-09-2023]. Mojave cumple.
- De las 327 crates de `chromium_crates_io/Cargo.lock` de Brave, las que tocan API de Apple:
  - `iana-time-zone` 0.1.54: `CFTimeZoneCopySystem` y `CFStringGetBytes`, de 10.0–10.5.
  - `getrandom` 0.1.16: `getentropy` débil (10.12), con `/dev/random` si no está.
  - `core-foundation-sys` 0.8.3: solo declaraciones.

  Ningún `#[link(kind = "framework")]` salvo `Security` en la ruta de iOS de `getrandom` [V].
- `cxx`/`cxxbridge` no tocan API del sistema [V por búsqueda; H en detalle].

## 6. Cruce con `migracion-128.md` y `chromium-legacy.md`

- **Corrección a §5 de `migracion-128.md` [V]:** había **dos** guardas nuevas en la 1.69, no una. La de geolocalización
  (11.0) y la de `default_accelerators_mac.mm` (12.0); esta se le escapó al `grep` porque escribe `@available(macos …)`
  en minúsculas. Las dos con guarda: la conclusión no cambia.
- **Clase E: comprobado de verdad** (no solo por marcas): 0 dependencias de macOS > 10.14, 0 h por macOS.
- **Chromium Legacy:** solo `permissions_utils.mm` coincide con un `.patch` nuevo de Brave. `app_controller_mac.mm` ya
  estaba en §5. Lo de GPU que Legacy no cubre (Dawn, ANGLE, Skia, listas de `gpu/config`) **sigue siendo solo de
  Chromium**. Brave no añade nada encima.

## 7. Qué falta y quién lo cierra

- **LOCAL (Fase 1, Brave 1.69.168 limpio con `mac_deployment_target = "10.14"`):** los avisos de
  `-Wunguarded-availability` en `brave/` deben ser **0**. Cualquiera que salga es un fallo de este estudio.
- **Prueba en la 6,1 y la 5,1:**
  - color del título de la ventana (override privado);
  - burbuja de geolocalización;
  - que las rutas de `keystone_glue` no hagan peticiones a hosts de Brave (`network-audit.py`).

## 8. Fuentes

- `brave/brave-core` tags `v1.57.64` (`25c5f015`) y `v1.69.168` (`b44ebef655` → `6918a99a`), en GitHub. Ficheros citados
  arriba.
- SDK `MacOSX14.5.sdk` (cabeceras de AppKit, CoreLocation, NetworkExtension, Vision y CoreGraphics), de la versión
  `14.5` de `joseluisq/macosx-sdks`.
- Chromium `128.0.6613.138`, espejo de GitHub: `build/config/rust.gni`, `build/config/mac/BUILD.gn`,
  `build/config/mac/mac_sdk.gni` (`mac_deployment_target = "10.15"`), `build/config/compiler/BUILD.gn`
  (`-Wunguarded-availability`), `build/config/c++/c++.gni` (`use_custom_libcxx` en Apple: la libc++ del sistema no
  entra en juego).
- Rust Blog, «Increasing the minimum supported Apple platform versions» (25-09-2023).
- Proyecto: `FlyWeb/docs/migracion-128.md` §3 (clase E), §5 y §6; `FlyWeb/docs/chromium-legacy.md`;
  `FlyWeb/scripts/build.sh` (args `enable_brave_vpn:false`, `enable_ai_chat:false`, `enable_sparkle`).
