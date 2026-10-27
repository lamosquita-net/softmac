# macOS 11+ en los niveles 129 y siguientes (FM.44, punto 1) — BORRADOR

INVESTIGACIÓN-MOTOR-4, 27-10-2026. **Borrador interrumpido** por cambio de modelo (COORDINACIÓN-16): lo sigue
INVESTIGACIÓN-MOTOR-5 desde aquí (ver §6, «Qué falta»). Marcas: [V] visto en el código o fuente; [I] inferencia; [N] no
comprobado.

## 1. Cuándo sube Chromium el mínimo [V]

`build/config/mac/mac_sdk.gni` en el primer tag de cada hito (espejo `github.com/chromium/chromium`):

| Cambio | Entre tags | Afecta desde | Commit |
|---|---|---|---|
| 10.15 → **11.0** | 129.0.6614.0 → 130.0.6669.0 | Chrome **129** | `165142f8` «Bump the Chrome macOS deployment target to 11.0» (25-07-2024) |
| 11.0 → **12.0** | 139.0.7205.0 → 140.0.7259.0 | Chrome **139** | (por localizar; ver §6) |
| 12.0 → **13.0** | 151.0.7872.0 → 152.0.7923.0 | Chrome **151** | (por localizar) |

SDK oficial: 14.0 hasta la 131, 15.x de la 132 a la 141, 26.x desde la 143, 27.0 en la 158.

## 2. Método (reproducible, `FlyWeb/tools/macos-api/`)

1. **Lista de API posteriores a 10.14** (`sdkapi.py`): símbolos de los `.tbd` del SDK 15.5 que no están en los del 10.14
   (funciones C, constantes, clases ObjC) y métodos/propiedades/enums con `API_AVAILABLE(macos(≥10.15))` en las
   cabeceras del 15.5. SDK sacados de `github.com/alexey-lysiuk/macos-sdk` (sparse: `.tbd` y cabeceras). Resultado:
   ≈118 000 símbolos, 15 500 clases, 7 800 métodos, 1 200 propiedades.
2. **Árboles por hito** (`fetch.sh` + `sparse.txt`): clon `--depth=1 --filter=blob:none` y checkout parcial solo de
   ficheros de Mac (`*.mm`, `*_mac.*`, `*_apple.*`, `*/mac/*`, `*/cocoa/*`; sin `ios/` ni `third_party/` salvo Blink),
   ≈2 000 ficheros por tag, segundos por tag. Tags: 128.0.6613.138 (nuestra base) y el primero de 130…141.
3. **Escáner** (`scan.py`): por par de tags, guardas de versión que desaparecen (`@available`, `__builtin_available`,
   `MacOSMajorVersion()`, `IsAtLeastOS`) y usos nuevos de la lista del paso 1, por componente.
4. **Mensajes de commit** del intervalo (`git fetch --filter=tree:0 --shallow-exclude=<tag anterior>`) filtrados por
   «Assume macOS 11+», «10.15», «deployment target».

**Ruido conocido:** propiedades de nombre corto (`process`, `platform`, `current`, `supported`, `bindings`) dan falsos
positivos; hay que filtrar nombres de una sola palabra en minúscula. Es un **cribado previo al porte**; la prueba real es
compilar con `mac_deployment_target=10.14` y `-Wunguarded-availability` (ya en `build.sh`), y comparar los avisos.

## 3. Resultado principal

**La subida a 11.0 (129) borra justo los «else» que son la traducción a 10.14, y esos «else» siguen en nuestra base
128 [V].** En casi todos los casos la rama «< 11» de la 128 usaba API de 10.14 (UTType C, `NSAppearance.currentAppearance`,
heurística de captura de pantalla…). Receta: **al portar un commit de 129+ que toque uno de estos ficheros, conservar la
rama de la 128** (o reponer la guarda con `@available(macOS 11, *)` y el «else» de la 128).

Serie «Assume macOS 11+» (julio–agosto de 2024) [V]:

| Commit | Área | Ficheros y API que quedan sin guarda | Traducción a 10.14 (está en la 128) |
|---|---|---|---|
| `16c56caa` /ui | ui (portapapeles, color, CA, permisos) | `clipboard_util_mac.mm`, `clipboard_format_type_mac.mm` (`UTType`, `NSURLContentTypeKey`, `UTTypeSVG`); `css_system_color_mixer_mac.mm`, `native_color_mixers_mac.mm` (`performAsCurrentDrawingAppearance:`); `permissions_utils.mm` (`CGPreflightScreenCaptureAccess`); `ca_renderer_layer_tree.mm` (HDR por `CVBufferSetAttachment`, `preventsCapture`); `io_surface.cc`; BUILD.gn enlaza UniformTypeIdentifiers | `UTTypeCreatePreferredIdentifierForTag`/`kUTType*`, `NSURLTypeIdentifierKey`; `NSAppearance.currentAppearance` guardar/restaurar; heurística `CGWindowListCopyWindowInfo` (ojo: en 10.14 ya se «permite» siempre, FM.42 c2) |
| `efc0f2c1` remote_cocoa | ui | `select_file_dialog_bridge.mm` (`UTType`), `immersive_mode_controller_cocoa.mm` (`titlebarSeparatorStyle`) | UTType C; sin separador (no existe en 10.14) |
| `d6204437` /content | content | `web_drag_source_mac.mm` (`UTType typeWithMIMEType:`), `theme_helper_mac.mm` (colores del sistema) | UTType C; `currentAppearance` |
| `b4c0a9f4` /chrome | chrome | `icon_loader_mac.mm` (`iconForContentType:`), notificaciones (`UTTypePNG`, `…PresentationOptionList/Banner`), `code_sign_clone_manager.mm` (`_dirhelper`) | `iconForFileType:`, `kUTTypePNG`, `…OptionAlert`, `NSTemporaryDirectory` |
| `a01fe8a7` /net | **red** | `platform_mime_util_apple.mm` (tipo MIME por extensión con `UTType`) | `UTTypeCopyPreferredTagWithClass` (rama de la 128) |
| `ee2ae23e` /media | media | `vt_video_encode_accelerator_mac.mm` (HEVC), `video_toolbox_video_decoder.cc`; borra `coreaudio_dispatch_override` | la guarda de la 128; **revisar** si el *override* de CoreAudio hacía falta en 10.14 [N] |
| `4142f42f` /gpu | **GPU** | `iosurface_image_backing_factory.mm` (NV12A/NV16/NV24 sin guarda), `feature_info.cc`, `gpu_finch_features.cc` | volver a `MacOSMajorVersion() < 11 → return` |
| `905606b2` /base | base | `launch_mac.cc` (`posix_spawnattr_set_csm_np`, 11.0), `sys_info_mac.mm` (`HW_PRODUCT`), `process_metrics_apple.cc` | guarda de 11; `HW_MODEL` |
| `53f9aaa3` | content/input | movimiento sin aceleración (Pointer Lock) | campos de CGEvent; funcionan en 10.14 según upstream (FM.42 b6) |
| `9e701c8c`, `d2cf8f0d` | accesibilidad | `AXCustomContent` (11.0) en `ax_platform_node_cocoa.mm` | descripción ARIA en `AXHelp` (rama de la 128) |
| `4a2bbbaf`, `8f3e134d` | **Blink** | solo pruebas (`harfbuzz_shaper_test.cc`, `font_*_mac_test.mm`) | nada en producción |

## 4. API 11+/12+ nuevas por nivel (cribado, sin falsos positivos evidentes) [V salvo marca]

| Nivel | Componente | Dónde | API (mínimo) | ¿Nos toca? / traducción |
|---|---|---|---|---|
| 129 | chrome | `extensible_enterprise_sso_provider_mac.mm` | `ASAuthorizationSingleSignOn*` (10.15) | No (empresa); no portar |
| 129 | chrome | `local_discovery/service_discovery_client_mac.mm` | `nw_browser_*` (Network, 10.15) | Solo si se porta el descubrimiento local; en 10.14, el `NSNetServiceBrowser` de la 128 |
| 129 | content | `native_screen_capture_picker_mac.mm`, `screen_capture_kit_device_mac.mm` | ScreenCaptureKit (12.3/14) | Guardado por upstream; en Mojave sigue el camino de `CGDisplayStream` [I] |
| 129 | ui | `screen_mac.mm` | `minimumRefreshInterval` (12.0) | Comprobar guarda [N] |
| 131 | ui | `cursor_utils.mm` | cursores de 15.0 | Guardado [I] |
| 131 | device | `fido/mac/icloud_keychain*.mm` | PRF/LargeBlob de AuthenticationServices | No (passkeys de iCloud fuera, FM.42 d10) |
| 133 | media / GPU | `vt_video_encode_accelerator_mac.mm`, `ca_renderer_layer_tree.mm` | `kVTCompressionPropertyKey_ReferenceBufferCount`, `kCVImageBufferAmbientViewingEnvironmentKey` | Constantes: en 10.14 el símbolo no existe → **dyld falla si no es débil**; poner guarda [I] |
| 135 | ui / content | `bridged_content_view.mm`, `render_widget_host_view_cocoa.mm` | **`UTTypeUTF8PlainText` (11.0, UniformTypeIdentifiers)** | **Sí** (texto, entrada); `kUTTypeUTF8PlainText` / `NSPasteboardTypeString` |
| 136 | media | `video_capture_device_avfoundation_helpers.mm` | `AVCaptureDeviceTypeContinuityCamera` (14) | Guardado [I] |
| 137–140 | **GPU** | `viz/common/gpu/metal_context_provider.mm`, `gpu_info_collector_mac.mm`, `gpu/.../metal_context_provider.mm` | `-[MTLDevice supportsFamily:]` (10.15) | **Sí** al portar GPU/Graphite; en 10.14, `supportsFeatureSet:` |
| 137, 139 | chrome | `shell_integration_mac.mm`, `shortcut_creator_mac.mm` | `URLForApplicationToOpenContentType:`, `setDefaultApplicationAtURL:` (12.0) | **Sí** si se porta «navegador por defecto»; en 10.14, `LSSetDefaultHandlerForURLScheme` (código de la 128) |
| 138 | media | `audio/mac/catap_*` | CoreAudio process tap (14.2) | No (captura de audio del sistema) |
| 138–140 | services | `webnn/coreml/*` | CoreML 12.3+ | No (WebNN apagado) [I] |
| 138 | Blink | `fonts/mac/character_fallback_cache.*` | solo falso positivo (`platform`) | Revisar a mano [N] |
| 139 | base, device, chrome… (15 ficheros) | `drive_info_mac.cc`, `mac_util.mm`, `battery_level_provider_mac.mm`, `bluetooth_adapter_mac.mm`, `hid_service_mac.cc`, `serial_device_enumerator_mac.cc`, `xbox_data_fetcher_mac.cc`, `uvc_control_mac.mm`… | **`kIOMainPortDefault` (12.0)** | **Sí** (muy repartido): `kIOMasterPortDefault` o `MACH_PORT_NULL` (equivalente documentado). Una macro en `base/mac` resuelve todos |
| 139 | **red** | `net/ssl/client_cert_store_mac.cc` | `SecTrustCopyCertificateChain` (12.0) | **Sí** (certificados de cliente): `SecTrustGetCertificateCount` + `…AtIndex` (código de la 128) |
| 139 | media, chrome, ui… (≈25 ficheros) | serie de quitar guardas de 12 (`video_capture_device_avfoundation.mm`×5, `x509_util_apple.cc`, `color_space_util_mac.mm`, `native_widget_mac_nswindow.mm`, `shell_integration_mac.mm`×4…) | API de 12.0 | Igual que §3: el «else» está en la 128. **Falta leer el diff** (§6) |
| 140 | content | `render_widget_host_ns_view_bridge.mm` | `NSPreviewRepresentingActivityItem` (13.0) | Clase: guarda o débil |

**V8** y la mayor parte de **Blink**: sin API de macOS 11+ en producción en 129–140 según este cribado (Blink: solo
pruebas; V8 no está en el espejo y **no se ha mirado**, §6). Coincide con `legacy-evolucion.md` §6: los niveles de motor
casi no pagan plataforma; lo que paga es portar código de `ui/`, `content/`, `media/`, `gpu/`, `net/`, `base/mac`.

## 5. Receta por nivel (propuesta)

1. Antes de portar el nivel N: `fetch.sh` de los tags N y N+1, `scan.py` y lista de ficheros tocados por el porte; el
   cruce da los puntos de riesgo.
2. En cada fichero de la lista: si el commit borra una guarda, **no borrarla** (mantener el «else» de la 128).
3. Constantes y clases nuevas: guarda `@available` o, en C, comprobar `&kSimbolo != nullptr` (enlace débil).
4. Frameworks que no existen en 10.14 (UniformTypeIdentifiers, ScreenCaptureKit…): enlace débil en el BUILD.gn
   (`weak_frameworks`), o dyld no arranca la app.
5. Compilar con `mac_deployment_target=10.14`: cada aviso nuevo de `-Wunguarded-availability` que no esté en la lista
   del paso 1 es un hueco del cribado.

## 6. Qué falta (para INVESTIGACIÓN-MOTOR-5)

- Leer el diff de la serie de 12.0 (139.0.7205.0 → 140.0.7259.0): commits «Assume macOS 12+» (el `git fetch` de ese
  intervalo no llegó a hacerse bien; repetir con `--shallow-exclude=139.0.7205.0 origin tag 140.0.7259.0`).
- V8 (`github.com/v8/v8`, `src/base/platform/platform-darwin.cc`, `platform-macos.cc`, `src/heap`, `MAP_JIT`): mismo
  método, versiones 12.9–14.0.
- Filtrar el ruido de propiedades genéricas en `scan.py` y ampliar el sparse a `.cc` de Blink (`fonts/`, `editing/`).
- Comprobar si `coreaudio_dispatch_override` (borrado en `ee2ae23e`) protegía algo de 10.14.
- Niveles 141+ (13.0 desde la 151) si el plan del fork llega ahí.
- Chromium Legacy no aporta aquí: su último código es la 127 y nunca trató la subida a 11 (`chromium-legacy.md`).

Fuentes: espejo `github.com/chromium/chromium` (tags citados), `github.com/alexey-lysiuk/macos-sdk` (SDK 10.14 y 15.5),
`legacy-evolucion.md`, `mojave-128.md`, `chromium-legacy.md`.
