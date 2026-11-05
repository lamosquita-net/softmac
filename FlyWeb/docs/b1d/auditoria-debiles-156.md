# Auditoría de las 145 importaciones débiles de la 156 en macOS 10.14

Árbol: `~/proyectos/chromium-156/src` (rama `flynk-b1d`, HEAD `8e24951091`; dawn `flynk-b1b`, angle `flynk-b1d`).
Fuentes: `faltan-debiles-156.txt` (145 filas), `avisos-156-total.txt` (720 avisos únicos, 280 de ellos sobre los 145 símbolos), `git grep -w` sin tests/fakes/mocks/tools (más dawn, angle, skia y webrtc por separado).
Solo lectura: no se ha tocado ni compilado nada.

## Cómo leer la tabla

En 10.14, el efecto de que falte un símbolo débil depende de qué tipo de símbolo sea:

- **Constante** (`UTTypeHTML`, `kVT…`, `AVCaptureDeviceType…`) o **función C** (`CVBufferCopyAttachment`, `nw_browser_…`): leer o llamar a NULL hace que **se cuelgue seguro**.
- **Clase ObjC** (`_OBJC_CLASS_$_X`): la referencia vale nil y `[X algo]` devuelve nil, así que **no se cuelga por sí sola**. Se cuelga si ese nil acaba en un literal o en una colección (`@[nil]`, `addObject:nil`), o si después se envía a un objeto que sí existe un selector que aún no existía en 10.14 (por ejemplo `iconForContentType:` u `openURL:configuration:…`).

Estados:

- **a**: protegido. Puede ser por `@available`/`__builtin_available`, por una función o clase `API_AVAILABLE` cuyos llamadores están protegidos (el compilador no avisa) o por una comprobación de versión.
- **a\***: no tiene guarda explícita, pero en 10.14 es inofensivo. O la clase es nil y la salida es limpia, o el código es inalcanzable (el sistema no lo llama, hace falta un entitlement o B1d desactiva Dawn).
- **b**: sin proteger, **con cuelgue posible**.
- **b~**: sin proteger, sin cuelgue, pero la función queda rota o degradada.
- **c**: ya sustituido en B1b (`95a974072b`) o en B1d.

«Ruta básica» incluye arranque, navegación, menú contextual, portapapeles, arrastrar, descargas, notificaciones, diálogos de fichero, pantalla completa, accesibilidad básica, color/tema e impresión.

## Resumen

| estado | filas |
|---|---|
| a (protegido) | **69** (51 con guarda explícita y 18 a\*) |
| b (sin proteger) | **50** (40 con cuelgue posible y 10 b~ sin cuelgue) |
| c (sustituido en B1b/B1d) | **26** |
| total | 145 |

### Prioridad 1: b con cuelgue en ruta básica (arreglar primero)

1. **CVBufferCopyAttachment**, `media/base/mac/color_space_util_mac.mm:42,45,47,49`, dentro de `GetImageBufferColorSpace()`. Lo llama `media/gpu/mac/video_toolbox_frame_converter.cc:175` en **cada fotograma de vídeo con decodificación por hardware** (YouTube, etc.) y también la cámara (`video_capture_device_avfoundation.mm:1166,1207`). Es una función C de macOS 12, así que se cuelga en la primera reproducción.
2. **AVCaptureDeviceTypeBuiltInWideAngleCamera** y **AVCaptureDeviceTypeExternalUnknown** (constantes de 10.15), `media/base/mac/video_capture_device_avfoundation_helpers.mm:21` y `:38`. `GetVideoCaptureDevices()` se ejecuta en cuanto **cualquier web llama a `enumerateDevices()`/`getUserMedia()`** (`media/device_monitors/device_monitor_mac.mm:140`), y el cuelgue es en el proceso del navegador.
3. **NSWorkspaceOpenConfiguration**: la clase es nil y lo que se cuelga es el selector `openURL:configuration:completionHandler:`, que es de 10.15.
   - `chrome/browser/platform_util_mac.mm:63,85,105`: abrir una descarga, abrir su carpeta y los enlaces externos (mailto:, apps).
   - `base/mac/launch_application.mm:67,146,151`: relanzar tras actualizar o desde «Reiniciar» (`chrome/browser/mac/relauncher.mm:342`) y las PWA.
   - `base/mac/mac_util.mm:551-552`: `OpenSystemSettingsPane`, que se usa desde los permisos del sistema.
4. **UTTagClassMIMEType** (constante de 11.0), `net/base/platform_mime_util_apple.mm:63`. Se ejecuta en **los diálogos de fichero con `accept="image/*"`** y similares (`chrome/browser/file_select_helper.cc:551` → `net::GetExtensionsForMimeType`).
5. **UTType en `chrome/browser/icon_loader_mac.mm:79-80`** (`IconLoader::ReadIcon`). **El arreglo de B1d no lo cubre**: en 10.14 `[UTType typeWithIdentifier:]` da nil y `-[NSWorkspace iconForContentType:]` (11.0) es un selector que no existe. Afecta a **los iconos de las descargas**.

### Prioridad 2: b con cuelgue en rutas muy usadas pero no básicas

6. **nw_browser_set_queue / …_set_browse_results_changed_handler / nw_browse_result_get_changes / nw_browse_result_copy_endpoint / nw_browser_set_state_changed_handler / nw_browser_start**, `chrome/browser/local_discovery/service_discovery_client_mac.mm:89,91,95-97,138,183`. Se ejecuta la primera vez que se descubren dispositivos Cast o impresoras locales (menú «Enviar…», también en el menú contextual).
7. **UTTypeHTML**, `chrome/browser/shell_integration_mac.mm:90`, dentro de «Establecer como navegador predeterminado». Antes ya se cuelga en `:67,79,134` con `setDefaultApplicationAtURL:toOpenURLsWithScheme:`, que es de 12.0.
8. **kVTVideoEncoderSpecification_EnableLowLatencyRateControl**, `media/gpu/mac/vt_video_encode_accelerator_mac.mm:479`. Afecta a WebRTC con H.264 por hardware y retardo bajo, es decir, a las videollamadas.

### Fuera de los 145 símbolos, pero cuelgan en ruta básica (selectores de 10.15 a 12 sin guarda)

No están en la lista de importaciones porque son mensajes ObjC, pero en 10.14 producen `unrecognized selector`:

- **Pantalla completa.**
  - `components/remote_cocoa/app_shim/immersive_mode_controller_cocoa.mm:207,267` (`setTitlebarSeparatorStyle:`, 11.0) y `:634` (`NSScreen.safeAreaInsets`, 12.0).
  - `components/remote_cocoa/app_shim/immersive_mode_tabbed_controller_cocoa.mm:91,151` (`setToolbarStyle:`, 11.0).
- **Vídeo.** `ui/accelerated_widget_mac/ca_renderer_layer_tree.mm:1189` y `:1209` (`AVSampleBufferDisplayLayer.preventsCapture`, 10.15). La línea 1189 se ejecuta en **cada actualización de una capa AV de vídeo**, no solo con DRM.
- **«Buscar» / diccionario** (menú contextual y force-click). `third_party/blink/renderer/core/editing/substring_util.mm:124` (`-[NSFont fontWithSize:]`, 10.15).
- **Notificaciones (degradación, sin cuelgue).** `chrome/services/mac_notifications/mac_notification_service_un.mm:711-712` usa `UNNotificationPresentationOptionList|Banner` (11.0). En 10.14 no se muestra el aviso con FlyWeb en primer plano. Conviene usar `…OptionAlert` en `else`.
- **Geolocalización.** `services/device/public/cpp/geolocation/system_geolocation_source_apple.mm:212` (`requestWhenInUseAuthorization`, 10.15) y `location_manager_delegate.mm:64` (`ellipsoidalAltitude`, 12.0, si `kEllipsoidalAltitude` está activa).

### Arreglos de B1d: ¿cubren todos los usos?

| fichero | resultado |
|---|---|
| `ui/base/clipboard/clipboard_format_type_mac.mm` | sí (único uso, `:128`) |
| `ui/base/clipboard/clipboard_util_mac.mm` | sí (`:158-212` tras `@available(11)`) |
| `ui/base/dragdrop/os_exchange_data_provider_mac.mm` | sí (`:325-375`) |
| `chrome/services/mac_notifications/mac_notification_service_un.mm` | sí para UTTypePNG; quedan los enums de `:711-712` (degradación, arriba) |
| `chrome/browser/icon_loader_mac.mm` | **no**: `GroupForFilepath` está bien, pero `ReadIcon` (`:79-80`) sigue sin guarda (prioridad 1) |
| supportsFamily (gpu_info_collector_mac.mm) | sí; Dawn y Graphite están apagados en 10.14 |
| kIOMainPortDefault (B1b) | sí: **0 usos** sin el comentario FlyWeb en src, dawn, angle y crashpad |

### Los 6 frameworks que no cargan

| framework | ¿se usan sus símbolos sin guarda? |
|---|---|
| Accessibility | No. `AXPrefers…` va con `@available(15)`. `AXCustomContent` (`ax_platform_node_cocoa.mm:3930-3935`) haría `@[nil]` y se colgaría, pero en 10.14 VoiceOver no llama a `accessibilityCustomContent`. A cambio, `aria-description` deja de anunciarse: `:2416` lo quita de AXHelp. |
| AuthenticationServices | Sin cuelgue. Lo de passkeys va con `API_AVAILABLE(13.3)` y `IsSupported()` con `@available(13.5)`. `app_controller_mac.mm:1361` envía un mensaje a una clase nil al arrancar, lo que es inofensivo. El SSO de Entra sale en `canPerformAuthorization`. |
| CoreHaptics | **Sí** (b), en `device/gamepad/game_controller_gamepad.mm:46-59,105-110`. Se cuelga al conectar un mando con la Gamepad API, y antes ya falla `controller.haptics` (11.0) en `:148,188`. Es una función rara. |
| LocalAuthenticationEmbeddedUI | Sí, pero sin cuelgue (b~): `mac_authentication_view.mm:45` deja la vista de Touch ID vacía en WebAuthn. |
| ScreenCaptureKit | Vídeo protegido: `desktop_capture_util_mac.mm` exige `@available(13.2)` y el selector de miniaturas `@available(14.4)`. **El audio del sistema no lo está** (`media/audio/mac/audio_loopback_input_mac_impl.mm`, porque `IsMacSckSystemLoopbackCaptureSupported()` devuelve true en <15): solo clases nil, así que no se cuelga, pero no hay audio (b~). |
| UniformTypeIdentifiers | **Sí**: `platform_mime_util_apple.mm:63` (b), `shell_integration_mac.mm:90` (b) e `icon_loader_mac.mm:79-80` (b, por selector). Degradados (b~): `select_file_dialog_bridge.mm:36-44` (filtros de extensión vacíos) y `platform_mime_util_apple.mm:35,50` (sin MIME de plataforma). El resto está en c. |

---

## Tablas por framework

Si no se indica otra cosa, los números de línea son los del árbol actual. «Ruta básica» indica si el uso sin proteger está en una ruta básica.

### AVFoundation

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| AVCaptureDeviceTypeBuiltInWideAngleCamera | media/base/mac/video_capture_device_avfoundation_helpers.mm:21; media/capture/video/apple/video_capture_device_factory_apple.mm:103,131,158 (API_AVAILABLE 14, solo registro) | **b** | **sí** (enumerateDevices/getUserMedia, device_monitor_mac.mm:140) | En `GetVideoCaptureDevices()`: `if (@available(macOS 10.15, *)) { …código actual… } else { return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]; } // FlyWeb B1d` |
| AVCaptureDeviceTypeContinuityCamera | helpers.mm:34; factory_apple.mm:104,132,159 | a | — | — |
| AVCaptureDeviceTypeExternal | helpers.mm:29; factory_apple.mm:104,132,159 | a | — | — |
| AVCaptureDeviceTypeExternalUnknown | helpers.mm:38 (rama `else` de `@available(14)`, se ejecuta en 10.14) | **b** | **sí** (igual) | Lo cubre el mismo arreglo |
| AVCaptureDeviceTypeMicrophone | factory_apple.mm:105 (API_AVAILABLE 14) | a | — | — |
| AVCaptureDeviceDiscoverySession | helpers.mm:43-44; factory_apple.mm:108,135,162 (API_AVAILABLE 14) | b~ (nil: no hay cámaras) | sí | Lo cubre el mismo arreglo |
| AVCapturePhotoOutput | media/capture/video/apple/video_capture_device_avfoundation.mm:266,644 | b~ (nil: takePhoto falla) | no (ImageCapture.takePhoto) | `if (@available(macOS 10.15, *))` alrededor de la creación (:636-660); en `else`, devolver un error en takePhoto |
| AVCapturePhotoSettings | video_capture_device_avfoundation.mm:693 | b~ | no | Lo cubre el mismo arreglo |

### Accessibility (no carga)

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| AXPrefersNonBlinkingTextInsertionIndicator | ui/native_theme/os_settings_provider_mac.mm:161 (`@available(15)`) | a | — | — |
| AXPrefersNonBlinkingTextInsertionIndicatorDidChangeNotification | os_settings_provider_mac.mm:70 (`@available(15)`) | a | — | — |
| AXCustomContent | ui/accessibility/platform/ax_platform_node_cocoa.mm:3930-3935; inspect/ax_call_statement_invoker_mac.mm:199,210; inspect/ax_element_wrapper_mac.mm:38,50 y 4 más (inspect/) | a\* (10.14 no llama a `accessibilityCustomContent`; `@[nil]` se colgaría si lo llamara) | accesibilidad: degradación | Opcional: en `-accessibilityCustomContent`, `if (@available(macOS 11, *)) {} else return nil;`. En `:2416`, devolver la descripción ARIA como AXHelp si es <11 (`// FlyWeb B1d`) para que VoiceOver la anuncie |

### AppKit

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| NSColorSampler | chrome/browser/ui/views/eye_dropper/eye_dropper_view_mac.mm:21,35,37; eye_dropper_view_mac.h | b~ (nil: el cuentagotas nunca responde) | no (EyeDropper API) | `if (@available(macOS 10.15, *)) {…} else { listener_->ColorSelectionCanceled(); return; }` |
| NSGlassEffectView (+ METACLASS) | chrome/browser/ui/views/frame/browser_native_widget_mac.mm:151 (subclase), :1028 (`@available(26)` en :1014); components/remote_cocoa/app_shim/native_widget_ns_window_bridge.mm:120 (`@available(26)`) | a | — | — |
| NSPreviewRepresentingActivityItem | content/app_shim_remote_cocoa/render_widget_host_ns_view_bridge.mm:334 | **b** (`addObject:nil` → excepción) | no (Web Share, navigator.share) | `if (@available(macOS 13, *)) { …actual… } else { [items addObject:ns_url]; }` |
| NSWorkspaceOpenConfiguration | chrome/browser/platform_util_mac.mm:64,86,106; base/mac/launch_application.mm:64-68,142; base/mac/mac_util.mm:552; chrome/installer/gcapi_mac/gcapi.mm (instalador) | **b** (cuelga el selector de 10.15) | **sí** (abrir descargas, carpetas y enlaces externos; relanzar) | platform_util: `if (@available(macOS 10.15, *)) {…} else { [NSWorkspace.sharedWorkspace openURL:url]; }`. launch_application: rama `else` con `launchApplicationAtURL:options:configuration:error:` y `openURLs:withApplicationAtURL:options:configuration:error:` (argumentos en `NSWorkspaceLaunchConfigurationArguments`; `NSWorkspaceLaunchAndHide` si está oculta). mac_util: `else [NSWorkspace.sharedWorkspace openURL:]` |

### AuthenticationServices (no carga)

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| ASAuthorizationErrorDomain | device/fido/mac/icloud_keychain.mm | a (API_AVAILABLE 13.3 / IsSupported 13.5) | — | — |
| ASAuthorizationPublicKeyCredentialAttestationKindNone | device/fido/mac/icloud_keychain_sys.mm | a | — | — |
| …UserVerificationPreferenceDiscouraged / Preferred / Required (3) | icloud_keychain_sys.mm | a | — | — |
| ASWebAuthenticationSessionErrorDomain | chrome/browser/app_controller_mac.mm:2585; chrome/browser/mac/auth_session_request.mm:167,383 | a\* (solo en callbacks de ASWebAuthenticationSession, que no ocurren en 10.14) | — | — |
| ASAuthorizationController (+ METACLASS) | chrome/browser/enterprise/platform_auth/extensible_enterprise_sso_entra.mm:124,175,177,258 y 3 más; device/fido/mac/icloud_keychain_sys.mm | a\* (Entra: sale antes porque el proveedor es nil) / a (fido) | — | — |
| ASAuthorizationPlatformPublicKeyCredentialAssertion / Descriptor / Provider / Registration (4) | icloud_keychain.mm, icloud_keychain_sys.mm | a | — | — |
| ASAuthorizationPublicKeyCredentialLargeBlobAssertionInput / RegistrationInput (2) | icloud_keychain_sys.mm | a | — | — |
| ASAuthorizationPublicKeyCredentialPRFAssertionInput / …Values / PRFRegistrationInput (3) | icloud_keychain_sys.mm | a | — | — |
| ASAuthorizationSingleSignOnProvider | extensible_enterprise_sso_provider_mac.mm:117-118; extensible_enterprise_sso_entra.mm:123,128 | a\* (nil → `canPerformAuthorization` NO → salida limpia; solo con política) | — | — |
| ASAuthorizationWebBrowserPublicKeyCredentialManager | icloud_keychain_sys.mm | a | — | — |
| ASWebAuthenticationSessionWebBrowserSessionManager | chrome/browser/app_controller_mac.mm:1361 (arranque) | a\* (mensaje a nil, inofensivo) | arranque, sin efecto | Opcional: `if (@available(macOS 10.15, *))` para que quede claro |

### CoreAudio

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| AudioHardwareCreateProcessTap | media/audio/mac/catap_api.mm:68; catap_audio_input_stream.mm:807 | a (`IsMacCatapSystemLoopbackCaptureSupported()` ≥14.2) | — | — |
| AudioHardwareDestroyProcessTap | catap_api.mm; catap_audio_input_stream.mm | a | — | — |
| CATapDescription | catap_api.*, catap_audio_input_stream.* (14 usos) | a | — | — |

### CoreFoundation

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| NSURLContentTypeKey | chrome/browser/icon_loader_mac.mm:49; ui/base/clipboard/clipboard_util_mac.mm:164,199,211 | c (B1d) | — | — |

### CoreGraphics

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| CGPreflightScreenCaptureAccess | ui/base/cocoa/permissions_utils.mm:107 | c (B1b) | — | — |
| CGRequestScreenCaptureAccess | permissions_utils.mm:114 | c (B1b) | — | — |
| kCGColorSpaceITUR_2100_HLG | ui/gfx/mac/io_surface.cc:456 | c (B1b) | — | — |
| kCGColorSpaceITUR_2100_PQ | io_surface.cc:454 | c (B1b) | — | — |

### CoreHaptics (no carga)

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| CHHapticEventParameter / …IDHapticIntensity / …IDHapticSharpness / CHHapticEvent / CHHapticEventTypeHapticContinuous / CHHapticPattern (6) | device/gamepad/game_controller_gamepad.mm:46-59 | **b** | no (Gamepad API con mando) | Toda la configuración háptica (constructor, `:148-212`) y `:380-394` bajo `if (@available(macOS 11, *))`; en `else`, sin vibración. Antes ya cuelga `controller.haptics` (11.0) |
| CHHapticDynamicParameter / …IDHapticIntensityControl / …IDHapticSharpnessControl (3) | game_controller_gamepad.mm:105-110 | **b** | no | Lo cubre el mismo arreglo |

### CoreMIDI

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| MIDIInputPortCreateWithProtocol | media/midi/midi_manager_mac.cc:191 (`kMidiMacUmp` activo por defecto) | **b** | no (Web MIDI) | `bool ump = false; if (@available(macOS 11, *)) ump = base::FeatureList::IsEnabled(features::kMidiMacUmp);` y usar `ump` en `:190` y `:379` (`// FlyWeb B1d`) |
| MIDIEventListInit / MIDIEventListAdd / MIDISendEventList (3) | midi_manager_mac.cc:398,425,432 | **b** | no | Lo cubre el mismo arreglo |

### CoreML

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| MLComputePlan, MLCPUComputeDevice, MLGPUComputeDevice, MLNeuralEngineComputeDevice (4) | services/webnn/coreml/graph_impl_coreml.mm:626,672,693 y otros | a (sin avisos: código API_AVAILABLE de WebNN) | — | — |

### CoreMedia

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| kCMFormatDescriptionTransferFunction_sRGB | ui/gfx/mac/color_space_util.mm:161-165 | c (B1b) | — | — |

### CoreServices

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| _CSCheckFixDisable | sandbox/mac/system_services.cc:20,42-43 | c (B1b, weak + comprobación de NULL) | — | — |
| _kLSOpenOptionBackgroundLaunchKey | base/mac/launch_services_spi.h:22; base/mac/launch_application.mm:79-81 | c (B1b) | — | — |

### CoreText

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| CTFontCopyVariationAxesInternal | third_party/blink/renderer/platform/fonts/mac/font_matcher_mac.mm:423 (`@available(13)`, alternativa CTFontCopyVariationAxes) | a | — | — |

### CoreVideo

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| CVBufferCopyAttachment | media/base/mac/color_space_util_mac.mm:42,45,47,49 (← media/gpu/mac/video_toolbox_frame_converter.cc:175; video_capture_device_avfoundation.mm:1166,1207) | **b** | **sí** (vídeo con decodificación por hardware y cámara) | Helper local: `CFTypeRef CopyAttachment(CVBufferRef b, CFStringRef k) { if (@available(macOS 12, *)) return CVBufferCopyAttachment(b, k, nullptr); CFTypeRef v = CVBufferGetAttachment(b, k, nullptr); return v ? CFRetain(v) : nullptr; } // FlyWeb B1d` |
| CVBufferHasAttachment | media/base/mac/video_frame_mac.mm:191-194 (← WrapVideoFrameInCVPixelBuffer ← vt_video_encode_accelerator_mac.mm) | **b** | no (codificación: WebRTC, MediaRecorder) | `if (@available(macOS 12, *)) {…} else { return CVBufferGetAttachment(pb, kCVImageBufferColorPrimariesKey, nullptr) && …; }` |
| CVIsCompressedPixelFormatAvailable | media/gpu/mac/video_toolbox_decompression_session_manager.mm:297 | c (B1b) | — | — |
| kCVImageBufferAmbientViewingEnvironmentKey | ui/accelerated_widget_mac/ca_renderer_layer_tree.mm:255-259 | c (B1b) | — | — |

### GameController

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| GCHapticDurationInfinite | device/gamepad/game_controller_gamepad.mm:57 | **b** | no | El de CoreHaptics (`@available(macOS 11, *)`) |
| GCHapticsLocalityDefault / LeftHandle / RightHandle / LeftTrigger / RightTrigger (5) | game_controller_gamepad.mm:189-210, 382-384 | **b** | no | Lo cubre el mismo arreglo |
| GCDualSenseGamepad / GCDualShockGamepad / GCXboxGamepad (3) | game_controller_gamepad.mm:259-290, 397-398 | a\* (`ObjCCast`/`isKindOfClass` con clase nil → NO) | — | — |

### IOKit

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| IOHIDCheckAccess | ui/base/accelerators/media_keys_listener_mac.mm:30-33 | c (B1b) | — | — |
| kIOMainPortDefault | 26 sitios: base/files/drive_info_mac.cc:214,220; base/mac/mac_util.mm:437; base/power_monitor/*.cc y 22 más (incl. dawn, angle y crashpad) | c (B1b, `MACH_PORT_NULL`); 0 restos | — | — |

### LocalAuthenticationEmbeddedUI (no carga)

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| LAAuthenticationView | chrome/browser/ui/views/webauthn/mac_authentication_view.mm:35,45 | b~ (nil: vista vacía; `initWithContext:` es de 12.0 pero se envía a nil) | no (WebAuthn/Touch ID) | `if (@available(macOS 12, *)) {…}`; en `else`, no ofrecer UV en la vista (callback false) |

### Metal (todo en Dawn salvo la captura)

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| MTLCommonCounterSetTimestamp / MTLCommonCounterTimestamp (2) | third_party/dawn/src/dawn/native/metal/PhysicalDeviceMTL.mm:683-684; QuerySetMTL.mm:114,185 | a\* (B1d: Dawn no se inicializa en 10.14: WebGPU y Graphite apagados, `CollectDawnInfo` sale) | — | — |
| MTLBlitPassDescriptor | dawn CommandBufferMTL.mm:436-437; CommandRecordingContext.h:63, .mm:90 | a\* | — | — |
| MTLComputePassDescriptor | dawn CommandBufferMTL.mm:130-175,1588; CommandRecordingContext.* | a\* | — | — |
| MTLCounterSampleBufferDescriptor | dawn QuerySetMTL.mm:43-45 | a\* | — | — |
| MTLLogStateDescriptor | dawn QueueMTL.mm:96 (`@available(15)`) | a | — | — |
| MTLCaptureDescriptor | angle libANGLE/renderer/metal/mtl_utils.mm:191 (solo captura de fotogramas de depuración); dawn DeviceMTL.mm:440; skia ganesh/mtl/GrMtlGpu.mm:1753 (`GPU_TEST_UTILS`); skia graphite/mtl/MtlQueueManager.mm:72 | a\* (solo depuración/pruebas o Dawn) | — | — |

### Network

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| nw_browser_set_queue | chrome/browser/local_discovery/service_discovery_client_mac.mm:89 | **b** | casi (menú «Enviar…»/Cast, impresoras locales) | En `ServiceWatcherImplMac::Start()` (`:308-321`): `if (@available(macOS 10.15, *)) { …nw_browser… } else { force_enable_legacy_discovery_ = true; }`, y proteger igual `StartServiceBrowser`/`StopServiceBrowser` (`nw_browser_` nulo). Así se usa el NetServiceBrowser que ya existe |
| nw_browser_set_browse_results_changed_handler | :91 | **b** | igual | Lo cubre el mismo arreglo |
| nw_browse_result_get_changes | :95 | **b** | igual | Lo cubre el mismo arreglo |
| nw_browse_result_copy_endpoint | :96,97 | **b** | igual | Lo cubre el mismo arreglo |
| nw_browser_set_state_changed_handler | :138 | **b** | igual | Lo cubre el mismo arreglo |
| nw_browser_start | :183 | **b** | igual | Lo cubre el mismo arreglo |

### QuartzCore

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| CADynamicRangeHigh / CADynamicRangeStandard (2) | ui/accelerated_widget_mac/ca_renderer_layer_tree.mm:1294,1297 (`@available(26)`) | a | — | — |
| CAEDRMetadata | components/metal_util/hdr_copier_layer.mm:354,360 | b~ (nil). Ojo: `setEDRMetadata:` (`:367`) y `preferredDevice` (`:378`) son selectores de 10.15 y sí cuelgan | no (vídeo HDR PQ con HDR copier) | `if (@available(macOS 10.15, *))` alrededor de `:352-380`, o que `ShouldUseHDRCopier()` devuelva false si es <10.15 |
| CAMetalDisplayLink | ui/display/mac/ca_metal_display_link_mac.mm/.h (10 usos) | a (API_AVAILABLE 14) | — | — |

### SafariServices

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| SFUniversalLink | chrome/browser/apps/link_capturing/mac_intent_picker_helpers.mm:106 | a\* (nil → `std::nullopt`) | — | — |

### ScreenCaptureKit (no carga)

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| SCShareableContent | content/browser/media/capture/screen_capture_kit_device_mac.mm:134,302,576,635 y 30 más; media/audio/mac/audio_loopback_input_mac_impl.mm:110,111,170 | a (vídeo: `desktop_capture_util_mac.mm` `@available(13.2)`, miniaturas `@available(14.4)`) / **b~** (audio del sistema) | no | En `AudioManagerMac::MakeLowLatencyInputStream` (`audio_manager_mac.cc:930`): `if (@available(macOS 13, *)) {…SCK…} else { return nullptr; } // FlyWeb B1d` |
| SCContentFilter | screen_capture_kit_device_mac.mm:265,313,324,335 y 49 más; audio_loopback_input_mac_impl.mm:106,158,196,324 | a / b~ (audio) | no | Lo cubre el mismo arreglo |
| SCStream | screen_capture_kit_device_mac.mm:178,222,260,382 y 47 más; audio_loopback_input_mac_impl.mm:226-249,349 | a / b~ (audio) | no | Lo cubre el mismo arreglo |
| SCStreamConfiguration | screen_capture_kit_device_mac.mm:226,230,378,503; audio_loopback_input_mac_impl.mm:339 y 9 más | a / b~ (audio) | no | Lo cubre el mismo arreglo |
| SCContentSharingPicker | content/browser/media/capture/native_screen_capture_picker_mac.mm (API_AVAILABLE 14); third_party/webrtc/modules/desktop_capture/mac/sck_picker_handle.mm:36,94; screen_capturer_sck.mm:348 (`@available(14)`) | a | — | — |
| SCScreenshotManager | chrome/browser/media/webrtc/thumbnail_capturer_mac.mm:409; ui/base/cocoa/permissions_utils.mm:88 (`@available(14)`); ui/snapshot/snapshot_mac.mm:85 (API_AVAILABLE 14.4) | a | — | — |
| SCStreamFrameInfoBoundingRect / DirtyRects / PresenterOverlayContentRect / Status / ContentRect / ContentScale / ScaleFactor (7) | screen_capture_kit_device_mac.mm:46,49,52 (solo desde el dispositivo protegido); webrtc screen_capturer_sck.mm:604-644 | a | — | — |

### Security

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| SecTrustCopyCertificateChain | net/ssl/client_cert_store_mac.cc:85 (los demás son iOS) | c (B1b) | — | — |
| kSecUseDataProtectionKeychain | crypto/apple/unexportable_key_apple.mm:186,462; chrome/browser/enterprise/connectors/device_trust/key_management/core/mac/secure_enclave_client_impl.mm:81 | a\* (`GetUnexportableKeyProviderApple` exige Secure Enclave **y** el entitlement `keychain-access-groups`, que FlyWeb no tiene; device trust solo con política) | no | Opcional: `if (@available(macOS 10.15, *)) {} else return nullptr;` al principio de `GetUnexportableKeyProviderApple` |

### SkyLight

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| SLSGetDisplayLink | ui/display/mac/ca_display_link_mac.mm:176-178 | c (B1b) | — | — |

### UniformTypeIdentifiers (no carga)

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| UTType | **chrome/browser/icon_loader_mac.mm:79-80** (`ReadIcon`: nil + `iconForContentType:` de 11.0); components/remote_cocoa/app_shim/select_file_dialog_bridge.mm:36-44; net/base/platform_mime_util_apple.mm:35,50,61-67; chrome/browser/shell_integration_mac.mm:44,149; content/app_shim_remote_cocoa/web_drag_source_mac.mm:150; content/browser/web_contents/web_drag_dest_mac.mm:863,881. El resto (clipboard, os_exchange, servicios, icon_loader:46-63) está en c | **b** | **sí** (descargas: icon_loader). b~: diálogo de fichero (filtros) y MIME de plataforma | icon_loader:79: `NSImage* icon; if (@available(macOS 11, *)) { …actual… } else { icon = [NSWorkspace.sharedWorkspace iconForFileType:base::SysUTF8ToNSString(group_)]; } // FlyWeb B1d`. select_file_dialog: `else` con `UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, …)` y `UTTypeCopyDescription`. platform_mime_util:35,50: `else` con `UTTypeCreatePreferredIdentifierForTag` / `UTTypeCopyPreferredTagWithClass(kUTTagClassMIMEType / kUTTagClassFilenameExtension)`. Los drag (`_fileType &&`, `utType &&`) no se cuelgan |
| UTTagClassMIMEType | net/base/platform_mime_util_apple.mm:63 | **b** | **sí** (diálogos de fichero con `accept=`, file_select_helper.cc:551) | `GetPlatformExtensionsForMimeType`: `if (@available(macOS 11, *)) {…actual…} else { CFArrayRef utis = UTTypeCreateAllIdentifiersForTag(kUTTagClassMIMEType, mime, nullptr); por cada uti: UTTypeCopyAllTagsWithClass(uti, kUTTagClassFilenameExtension) → extensions; } // FlyWeb B1d` |
| UTTagClassFilenameExtension | platform_mime_util_apple.mm:73 | a\* (hoy inalcanzable: bucle sobre `types` nil, después de :63) | — | Lo cubre el arreglo de :63 |
| UTTypeHTML | chrome/browser/shell_integration_mac.mm:90 (los otros 2 son iOS) | **b** | no (ajustes / barra de aviso «predeterminado») | `SetAsDefaultBrowser`: `if (@available(macOS 12, *)) {…actual…} else { LSSetDefaultHandlerForURLScheme(CFSTR("http"), bundle_id); …"https"…; LSSetDefaultRoleHandlerForContentType(CFSTR("public.html"), kLSRolesViewer, bundle_id); }`. Igual en `SetAsDefaultClientForScheme` (`:133`) y `SetAsDefaultHandlerForUTType` (`:156`) |
| UTTypeContent | icon_loader_mac.mm:67 | c (B1d) | — | — |
| UTTypeImage | os_exchange_data_provider_mac.mm:329,368 (c); web_drag_source_mac.mm:189 y web_drag_dest_mac.mm:864 (a\*: cortocircuito `x && …` con nil) | c | — | — |
| UTTypeInternetLocation | ui/base/clipboard/clipboard_util_mac.mm:168 | c (B1d) | — | — |
| UTTypeInternetShortcut | clipboard_util_mac.mm:212 | c (B1d) | — | — |
| UTTypePNG | mac_notification_service_un.mm:216 (sustituido; los demás son iOS) | c (B1d) | — | — |
| UTTypeSVG | clipboard_format_type_mac.mm:128 (sustituido; los demás son iOS) | c (B1d) | — | — |
| UTTypeUTF8PlainText | bridged_content_view.mm:1458,1462,1484; render_widget_host_view_cocoa.mm:3004,3006,3120 | c (B1b, `@available(11)` al principio de los métodos de Servicios) | — | — |

### VideoToolbox

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| VTRegisterSupplementalVideoDecoderIfAvailable | media/gpu/mac/video_toolbox_video_decoder.cc:50 | c (B1b) | — | — |
| kVTVideoEncoderSpecification_EnableLowLatencyRateControl | media/gpu/mac/vt_video_encode_accelerator_mac.mm:479 | **b** | no (videollamadas WebRTC H.264 por hardware) | `bool svc_ok = false; if (@available(macOS 11.3, *)) svc_ok = true;` y añadir `svc_ok &&` a la condición de `:476`. Mejor aún: que `IsSVCSupported()` devuelva false en <11.3 (`// FlyWeb B1d`), lo que también cubre BaseFrameQP, BaseLayerFrameRateFraction y ReferenceBufferCount |
| kVTEncodeFrameOptionKey_BaseFrameQP | vt_video_encode_accelerator_mac.mm:1285 | **b** | no (WebCodecs con QP manual) | Cubierto por `IsSVCSupported()` ≥11.3 (`IsManualQpSupported` lo usa) |
| kVTCompressionPropertyKey_BaseLayerFrameRateFraction | vt_video_encode_accelerator_mac.mm:1811,1817 | **b** | no (SVC L1T2) | Cubierto por `IsSVCSupported()` ≥11.3 |
| kVTCompressionPropertyKey_ReferenceBufferCount | vt_video_encode_accelerator_mac.mm:1837,1839 | **b** | no (SVC) | Cubierto por `IsSVCSupported()` ≥11.3 |
| kVTCompressionPropertyKey_HDRMetadataInsertionMode | vt_video_encode_accelerator_mac.mm:132,134 | **b** | no (codificar HDR PQ) | `if (@available(macOS 11, *)) { …:131-137… }` |
| kVTHDRMetadataInsertionMode_Auto | vt_video_encode_accelerator_mac.mm:135 | **b** | no | Lo cubre el mismo arreglo |
| kVTCompressionPropertyKey_CalculateMeanSquaredError | vt_video_encode_accelerator_mac.mm:1785,1788 (`@available(14.4)`) | a | — | — |
| kVTSampleAttachmentQualityMetricsKey_LumaMSE / ChromaBlueMSE / ChromaRedMSE (3) | vt_video_encode_accelerator_mac.mm:1626,1630,1634 (`@available(14.4)`) | a | — | — |

### libSystem

| símbolo | usos | estado | ruta básica | arreglo propuesto |
|---|---|---|---|---|
| __darwin_check_fd_set_overflow | sin uso en código propio: lo emite `FD_SET`/`FD_ISSET` del SDK (`sys/_types/_fd_def.h:64`), que comprueba el puntero débil | a | — | — |
| _availability_version_check | sin uso en código propio: lo emite `@available` (compiler-rt; si es NULL, lee SystemVersion.plist) | a | — | — |
| aligned_alloc | third_party/dawn/src/dawn/common/AlignedAlloc.cpp:57 (Apple pasa a `posix_memalign`, B1b); el shim de PartitionAlloc solo lo usa con `forward_through_malloc=true` (por defecto false) | c (B1b). Si sigue apareciendo en el binario, viene de otra dependencia: comprobar con `nm -m` | — | — |
| posix_spawn_file_actions_addchdir | base/process/launch_mac.cc:164 (`__builtin_available(26)`) | a | — | — |
| posix_spawn_file_actions_addchdir_np | launch_mac.cc:166 | c (B1b) | — | — |
| posix_spawnattr_set_csm_np | launch_mac.cc:354 | c (B1b) | — | — |
| task_create_identity_token | third_party/crashpad/crashpad/util/mach/exc_client_variants.cc:146,179 (`__builtin_available(11.3)` original; B1b lo hace weak) | a | — | — |
| task_identity_token_get_task_port | crashpad/util/mach/exc_server_variants.cc:511,610 | c (B1b, comprobación de NULL) | — | — |

---

## Notas

- Que no haya aviso del compilador para un símbolo con `API_AVAILABLE` en el SDK significa que todos sus usos están protegidos o dentro de código `API_AVAILABLE` con llamadores protegidos. Esos símbolos los he marcado «a» tras mirar el punto de entrada. Los símbolos declarados a mano sin atributo (`CTFontCopyVariationAxesInternal`, `_CSCheckFixDisable`, `SLSGetDisplayLink`, `task_*`, `_kLSOpenOption…`) no avisan nunca; esos los he revisado uno a uno.
- `nw_browser_create`, `nw_browse_descriptor_create_bonjour_service` y `nw_browser_cancel` dan aviso de 10.15 pero no están en la lista de importaciones que faltan; el arreglo de Network las cubre igual.
- Rutas de los avisos: el fichero de avisos es de la compilación **sin** B1b/B1d. En los ficheros que B1b/B1d modificaron, las líneas de esta tabla son las del árbol actual.
