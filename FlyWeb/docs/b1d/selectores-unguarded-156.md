# Selectores y clases de Objective-C sin guarda en la 156 (objetivo macOS 10.14)

LOCAL-19, 05-11-2026. Es la condición (c) de COORDINACIÓN-28.

**Por qué esta lista.** La auditoría de símbolos débiles (`auditoria-debiles-156.md`) no ve los selectores de Objective-C, porque no son símbolos. Así se escapó el fallo de `+[GCController setShouldMonitorBackgroundEvents:]` (macOS 11.3), que tiraba el navegador con Babylon y Shadertoy. Esta lista sale del compilador.

**Cómo se ha hecho.**
- `-Wunguarded-availability` está activo de serie en Mac (`build/config/compiler/BUILD.gn`). Con `mac_deployment_target = "10.14"`, clang avisa de cada API más nueva que se usa fuera de `@available`.
- Base: la compilación oficial completa desde cero de `out/Oficial` (`ninja-oficial.log`, 57 076 pasos) dio 672 avisos únicos en 75 ficheros.
- Se recompilaron esos 66 ficheros fuente con el código actual (`flynk-b1d` `b14509d981`) y se recogieron otra vez los avisos.
- Resultado: **631 avisos, 345 parejas fichero-API, en 67 ficheros**. Por versión mínima: 10.14.x 3, 10.15 122, 11.0 160, 11.3 4, 12.x 49, 13.0 7.

**Cómo leerla.**
- Un aviso no es siempre un fallo. Chromium protege muchas llamadas con comprobaciones en tiempo de ejecución que clang no reconoce: `base::mac::MacOSMajorVersion()`, `respondsToSelector:`, `NSClassFromString`, o rutas a las que solo se llega desde una función moderna.
- Los ficheros marcados «tocado en flynk-b1d» (14) ya tienen arreglos de LOCAL-18. El aviso sigue saliendo porque la guarda no es `@available`.
- Lo que hay que revisar a mano es lo que no está tocado y se ejecuta en una ruta básica: arranque, ventana, menú, descargas, diálogos y vídeo.
- Dawn (11 ficheros) está apagado en 10.14 (WebGPU desactivado y Graphite cortado), así que no se ejecuta.

## Revisión a mano (LOCAL-19, 05-11, `oficial-7`)

**Criterio.**
- Una **clase** nueva (`UTType`, `SC*`, `AS*`, `AXCustomContent`…) se enlaza débil y en 10.14 vale `nil`. Mandarle mensajes devuelve `nil` y no tira nada, salvo que ese `nil` acabe en una colección (`addObject:`, `@[…]`), como clave de un diccionario o en `CFEqual`.
- Lo que tira el proceso es un **selector nuevo sobre una clase que ya existía** en 10.14 («unrecognized selector»), como pasó con `GCController`.
- Se han revisado los 38 ficheros sin ninguna guarda FlyWeb, y de los demás, los que se ejecutan en rutas básicas.

**Arreglado** (src `flynk-b1d` `d11d785b43`, «guard Objective-C APIs newer than 10.14 on basic paths»):

| Ruta | API | Qué pasaba en 10.14 |
|---|---|---|
| Geolocalización (cualquier web que pide la ubicación) | `-[CLLocation ellipsoidalAltitude]` (12.0), con `kEllipsoidalAltitude` **activada de serie** | «unrecognized selector» en el servicio de dispositivos |
| Cámara (`getUserMedia` de vídeo) | `activeFormat.portraitEffectSupported` / `portraitEffectActive` (12.0) | «unrecognized selector» al configurar la captura |
| `ImageCapture.takePhoto()` | `AVCapturePhotoOutput` (10.15) nulo en `canAddOutput:` | Excepción. Ahora se devuelve el error de foto |
| Arrastrar una imagen fuera de una página | `UTType.identifier` (11.0) nulo en `addObject:` | `NSInvalidArgumentException` en el navegador |
| Diálogos de fichero con filtros de tipo | `UTType` (11.0) | Todas las extensiones se tomaban por inválidas. Ahora se usan las funciones UTI de 10.14 |
| Web Bluetooth | `+[CBManager authorization]` (10.15) | «unrecognized selector». Antes de 10.15 no hay permiso TCC: se da por permitido |
| Crear acceso directo / apps web | `-[NSWorkspace setDefaultApplicationAtURL:…]`, `URLsForApplicationsWithBundleIdentifier:` (12.0) | «unrecognized selector». Ahora se usa `LSCopyApplicationURLsForBundleIdentifier` |
| Claves no exportables | `kSecUseDataProtectionKeychain` (10.15) nulo como clave de diccionario | Excepción. Antes de 10.15 no hay proveedor (además, la 6,1 no tiene Secure Enclave) |
| `BarcodeDetector` | `-supportedSymbologiesAndReturnError:` (12.0) | «unrecognized selector». Ahora se usa `+supportedSymbologies` |
| Pantalla completa de ventanas auxiliares | `NSWindowCollectionBehaviorPrimary` (13.0) | Bit desconocido. Solo se pone en 13 o posterior |
| VoiceOver con `aria-description` | `AXCustomContent` (11.0) nulo en `@[…]` | Excepción. AppKit solo lo pide en 11 o posterior; protegido igualmente |

**Ya protegidos** (guardas FlyWeb de B1b/B1d o de serie; clang sigue avisando porque no reconoce el patrón de `return` anticipado ni las comprobaciones en tiempo de ejecución):
- Servicios y portapapeles: `render_widget_host_view_cocoa`, `bridged_content_view`, `clipboard_util_mac`, `appkit_utils`.
- Tipos MIME y LaunchServices: `platform_mime_util_apple`, `icon_loader_mac`, `shell_integration_mac`, `launch_application`.
- Vídeo y captura: `color_space_util_mac`, `video_frame_mac`, `video_capture_device_avfoundation_helpers`, `vt_video_encode_accelerator_mac`, `ca_renderer_layer_tree`.
- Otros: `midi_manager_mac`, `service_discovery_client_mac`, `hdr_copier_layer`, `game_controller_*` (el fetcher no se registra antes de 11.3) y ScreenCaptureKit (`@available(macOS 13.2)` en `CreateScreenCaptureKitDeviceMac`).

**Sin riesgo o fuera de las rutas básicas:**
- Empresa: SSO de Entra, `url_session_helper`, `secure_enclave_client_impl`.
- `ASWebAuthenticationSession`: solo lo pide macOS 10.15 o posterior.
- `SFUniversalLink`: clase nula, devuelve NO.
- EyeDropper (`NSColorSampler`, clase nula: no hace nada).
- `LAAuthenticationView`: clase nula.
- WebNN: apagado de serie.
- Dawn: WebGPU apagado.
- Inspectores de accesibilidad: herramientas de pruebas.

**Comprobado en la 6,1 con `oficial-7`:** batería completa y humo con 0 «unrecognized selector», 0 caídas y 0 `Check failed`. La geolocalización, la cámara y el arrastre no se pueden probar allí sin pedir permisos al sistema o sin cámara: se protegieron por lectura de código.

| Fichero | Tocado en flynk-b1d | APIs sin guarda (versión mínima) |
|---|---|---|
| `base/mac/launch_application.mm` | sí | `GetOpenConfiguration` (10.15); `NSWorkspaceOpenConfiguration` (10.15); `openApplicationAtURL:configuration:completionHandler:` (10.15); `openURLs:withApplicationAtURL:configuration:completionHandler:` (10.15) |
| `chrome/browser/app_controller_mac.mm` |  | `ASWebAuthenticationSessionErrorCodeCanceledLogin` (10.15); `ASWebAuthenticationSessionErrorDomain` (10.15); `ASWebAuthenticationSessionRequest` (10.15); `ASWebAuthenticationSessionWebBrowserSessionManager` (10.15) |
| `chrome/browser/apps/link_capturing/mac_intent_picker_helpers.mm` |  | `SFUniversalLink` (10.15) |
| `chrome/browser/enterprise/connectors/device_trust/key_management/core/mac/secure_enclave_client_impl.mm` |  | `kSecUseDataProtectionKeychain` (10.15) |
| `chrome/browser/enterprise/platform_auth/extensible_enterprise_sso_entra.h` |  | `ASAuthorizationController` (10.15); `ASAuthorizationSingleSignOnProvider` (10.15); `ASAuthorizationSingleSignOnRequest` (10.15) |
| `chrome/browser/enterprise/platform_auth/extensible_enterprise_sso_entra.mm` |  | `ASAuthorization` (10.15); `ASAuthorizationController` (10.15); `ASAuthorizationSingleSignOnCredential` (10.15); `ASAuthorizationSingleSignOnProvider` (10.15); `ASAuthorizationSingleSignOnRequest` (10.15); `setUserInterfaceEnabled:` (12.0) |
| `chrome/browser/enterprise/platform_auth/extensible_enterprise_sso_provider_mac.mm` |  | `ASAuthorizationSingleSignOnProvider` (10.15) |
| `chrome/browser/icon_loader_mac.mm` | sí | `NSURLContentTypeKey` (11.0); `UTType` (11.0); `identifier` (11.0); `typeWithFilenameExtension:` (11.0) |
| `chrome/browser/local_discovery/service_discovery_client_mac.mm` | sí | `nw_browse_result_copy_endpoint` (10.15); `nw_browse_result_get_changes` (10.15); `nw_browser_cancel` (10.15); `nw_browser_set_browse_results_changed_handler` (10.15); `nw_browser_set_queue` (10.15); `nw_browser_set_state_changed_handler` (10.15); `nw_browser_start` (10.15) |
| `chrome/browser/mac/auth_session_request.h` |  | `ASWebAuthenticationSessionRequest` (10.15) |
| `chrome/browser/mac/auth_session_request.mm` |  | `ASWebAuthenticationSessionErrorCodeCanceledLogin` (10.15); `ASWebAuthenticationSessionErrorCodePresentationContextInvalid` (10.15); `ASWebAuthenticationSessionErrorDomain` (10.15); `ASWebAuthenticationSessionRequest` (10.15); `callbackURLScheme` (10.15) |
| `chrome/browser/media/webrtc/thumbnail_capturer_mac.mm` |  | `SCContentFilter` (12.3); `SCDisplay` (12.3); `SCShareableContent` (12.3); `SCWindow` (12.3) |
| `chrome/browser/shell_integration_mac.mm` | sí | `UTType` (11.0); `UTTypeHTML` (11.0); `typeWithIdentifier:` (11.0); `URLForApplicationToOpenContentType:` (12.0); `setDefaultApplicationAtURL:toOpenContentType:completionHandler:` (12.0); `setDefaultApplicationAtURL:toOpenURLsWithScheme:completionHandler:` (12.0) |
| `chrome/browser/shortcuts/shortcut_creator_mac.mm` |  | `setDefaultApplicationAtURL:toOpenFileAtURL:completionHandler:` (12.0) |
| `chrome/browser/ui/views/eye_dropper/eye_dropper_view_mac.mm` |  | `NSColorSampler` (10.15) |
| `chrome/browser/ui/views/webauthn/mac_authentication_view.mm` |  | `LAAuthenticationView` (12.0); `initWithContext:` (12.0) |
| `chrome/browser/web_applications/os_integration/mac/bundle_info_plist.mm` |  | `URLsForApplicationsWithBundleIdentifier:` (12.0) |
| `components/enterprise/platform_auth/url_session_helper.mm` |  | `valueForHTTPHeaderField:` (10.15) |
| `components/metal_util/hdr_copier_layer.mm` | sí | `kCGColorSpaceExtendedLinearITUR_2020` (10.14.3); `CAEDRMetadata` (10.15); `preferredDevice` (10.15); `setEDRMetadata:` (10.15) |
| `components/remote_cocoa/app_shim/bridged_content_view.mm` |  | `UTType` (11.0); `UTTypeUTF8PlainText` (11.0) |
| `components/remote_cocoa/app_shim/native_widget_ns_window_bridge.mm` |  | `NSWindowCollectionBehaviorPrimary` (13.0) |
| `components/remote_cocoa/app_shim/select_file_dialog_bridge.mm` |  | `UTType` (11.0); `localizedDescription` (11.0); `typeWithFilenameExtension:` (11.0) |
| `content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm` |  | `UTType` (11.0); `UTTypeUTF8PlainText` (11.0) |
| `content/app_shim_remote_cocoa/web_drag_source_mac.mm` |  | `UTType` (11.0); `UTTypeImage` (11.0); `conformsToType:` (11.0); `identifier` (11.0); `typeWithMIMEType:` (11.0) |
| `content/browser/media/capture/screen_capture_kit_device_mac.mm` |  | `SCContentFilter` (12.3); `SCDisplay` (12.3); `SCShareableContent` (12.3); `SCStream` (12.3); `SCStreamConfiguration` (12.3); `SCStreamFrameInfoContentRect` (12.3); `SCStreamFrameInfoContentScale` (12.3); `SCStreamFrameInfoScaleFactor` (12.3); `SCStreamOutputType` (12.3); `SCStreamOutputTypeScreen` (12.3); `SCWindow` (12.3) |
| `content/browser/media/capture/screen_capture_kit_fullscreen_module.h` |  | `SCShareableContent` (12.3); `SCWindow` (12.3) |
| `content/browser/media/capture/screen_capture_kit_fullscreen_module.mm` |  | `SCDisplay` (12.3); `SCShareableContent` (12.3); `SCWindow` (12.3) |
| `content/browser/web_contents/web_drag_dest_mac.mm` |  | `UTType` (11.0); `UTTypeImage` (11.0); `conformsToType:` (11.0); `preferredFilenameExtension` (11.0); `typeWithIdentifier:` (11.0) |
| `crypto/apple/unexportable_key_apple.mm` |  | `kSecUseDataProtectionKeychain` (10.15) |
| `device/bluetooth/bluetooth_adapter_mac_permission.mm` |  | `authorization` (10.15) |
| `device/gamepad/game_controller_data_fetcher_mac.mm` |  | `productCategory` (10.15); `setShouldMonitorBackgroundEvents:` (11.3) |
| `device/gamepad/game_controller_gamepad.h` |  | `CHHapticEngine` (10.15); `CHHapticPatternPlayer` (10.15) |
| `device/gamepad/game_controller_gamepad.mm` | sí | `leftThumbstickButton` (10.14.1); `rightThumbstickButton` (10.14.1); `CHHapticDynamicParameter` (10.15); `CHHapticDynamicParameterIDHapticIntensityControl` (10.15); `CHHapticDynamicParameterIDHapticSharpnessControl` (10.15); `CHHapticEngine` (10.15); `CHHapticEvent` (10.15); `CHHapticEventParameter` (10.15); `CHHapticEventParameterIDHapticIntensity` (10.15); `CHHapticEventParameterIDHapticSharpness` (10.15); `CHHapticEventTypeHapticContinuous` (10.15); `CHHapticPattern` (10.15); `CHHapticPatternPlayer` (10.15); `buttonMenu` (10.15); `buttonOptions` (10.15); `GCDeviceHaptics` (11.0); `GCDualShockGamepad` (11.0); `GCHapticDurationInfinite` (11.0); `GCHapticsLocality` (11.0); `GCHapticsLocalityDefault` (11.0); `GCHapticsLocalityLeftHandle` (11.0); `GCHapticsLocalityLeftTrigger` (11.0); `GCHapticsLocalityRightHandle` (11.0); `GCHapticsLocalityRightTrigger` (11.0); `GCXboxGamepad` (11.0); `buttonHome` (11.0); `haptics` (11.0); `GCDualSenseGamepad` (11.3); `buttonShare` (12.0) |
| `media/audio/mac/audio_loopback_input_mac_impl.mm` |  | `SCContentFilter` (12.3); `SCDisplay` (12.3); `SCShareableContent` (12.3); `SCStream` (12.3); `SCStreamConfiguration` (12.3); `SCStreamErrorUserDeclined` (12.3); `SCStreamOutputType` (12.3); `SCStreamOutputTypeAudio` (13.0); `setCapturesAudio:` (13.0); `setChannelCount:` (13.0); `setExcludesCurrentProcessAudio:` (13.0); `setSampleRate:` (13.0) |
| `media/base/mac/color_space_util_mac.mm` | sí | `CVBufferCopyAttachment` (12.0) |
| `media/base/mac/video_capture_device_avfoundation_helpers.mm` | sí | `AVCaptureDeviceDiscoverySession` (10.15); `AVCaptureDeviceTypeBuiltInWideAngleCamera` (10.15); `AVCaptureDeviceTypeExternalUnknown` (10.15) |
| `media/base/mac/video_frame_mac.mm` | sí | `CVBufferHasAttachment` (12.0) |
| `media/capture/video/apple/video_capture_device_avfoundation.mm` |  | `AVCapturePhoto` (10.15); `AVCapturePhotoOutput` (10.15); `AVCapturePhotoSettings` (10.15); `isPortraitEffectActive` (12.0); `isPortraitEffectSupported` (12.0) |
| `media/gpu/mac/vt_video_encode_accelerator_mac.mm` | sí | `kVTCompressionPropertyKey_BaseLayerFrameRateFraction` (11.3); `kVTVideoEncoderSpecification_EnableLowLatencyRateControl` (11.3); `kVTEncodeFrameOptionKey_BaseFrameQP` (12.0); `kVTCompressionPropertyKey_ReferenceBufferCount` (13.0) |
| `media/midi/midi_manager_mac.cc` | sí | `MIDIEventListAdd` (11.0); `MIDIEventListInit` (11.0); `MIDIInputPortCreateWithProtocol` (11.0); `MIDISendEventList` (11.0) |
| `net/base/platform_mime_util_apple.mm` | sí | `UTTagClassFilenameExtension` (11.0); `UTTagClassMIMEType` (11.0); `UTType` (11.0); `isDynamic` (11.0); `preferredFilenameExtension` (11.0); `preferredMIMEType` (11.0); `tags` (11.0); `typeWithFilenameExtension:` (11.0); `typeWithMIMEType:` (11.0); `typesWithTag:tagClass:conformingToType:` (11.0) |
| `services/device/public/cpp/geolocation/location_manager_delegate.mm` |  | `ellipsoidalAltitude` (12) |
| `services/shape_detection/barcode_detection_impl_mac_vision_api.mm` |  | `supportedSymbologiesAndReturnError:` (12.0) |
| `services/webnn/coreml/tensor_impl_coreml.mm` |  | `MLMultiArrayDataTypeFloat16` (12.0); `initWithPixelBuffer:shape:` (12.0); `getMutableBytesWithHandler:` (12.3) |
| `services/webnn/coreml/utils_coreml.mm` |  | `getBytesWithHandler:` (12.3); `getMutableBytesWithHandler:` (12.3) |
| `third_party/dawn/src/dawn/native/metal/CommandBufferMTL.mm` |  | `MTLCounterSampleBuffer` (10.15); `resolveCounters:inRange:destinationBuffer:destinationOffset:` (10.15); `sampleCountersInBuffer:atSampleIndex:withBarrier:` (10.15); `MTLBlitPassDescriptor` (11.0); `MTLComputePassDescriptor` (11.0); `MTLStorageModeMemoryless` (11.0); `sampleBufferAttachments` (11.0); `setEndOfFragmentSampleIndex:` (11.0); `setSampleBuffer:` (11.0); `setStartOfVertexSampleIndex:` (11.0) |
| `third_party/dawn/src/dawn/native/metal/CommandRecordingContext.h` |  | `MTLBlitPassDescriptor` (11.0); `MTLComputePassDescriptor` (11.0) |
| `third_party/dawn/src/dawn/native/metal/CommandRecordingContext.mm` |  | `MTLBlitPassDescriptor` (11.0); `MTLComputePassDescriptor` (11.0); `blitCommandEncoderWithDescriptor:` (11.0); `computeCommandEncoderWithDescriptor:` (11.0) |
| `third_party/dawn/src/dawn/native/metal/DeviceMTL.mm` |  | `MTLCaptureDescriptor` (10.15); `MTLCaptureDestinationGPUTraceDocument` (10.15); `sampleTimestamps:gpuTimestamp:` (10.15); `startCaptureWithDescriptor:error:` (10.15); `supportsDestination:` (10.15) |
| `third_party/dawn/src/dawn/native/metal/PhysicalDeviceMTL.mm` |  | `MTLCommonCounter` (10.15); `MTLCommonCounterSet` (10.15); `MTLCommonCounterSetTimestamp` (10.15); `MTLCommonCounterTimestamp` (10.15); `MTLGPUFamily` (10.15); `MTLGPUFamilyApple1` (10.15); `MTLGPUFamilyApple2` (10.15); `MTLGPUFamilyApple3` (10.15); `MTLGPUFamilyApple4` (10.15); `MTLGPUFamilyApple5` (10.15); `MTLGPUFamilyApple6` (10.15); `MTLGPUFamilyApple7` (10.15); `MTLGPUFamilyApple8` (10.15); `MTLGPUFamilyApple9` (10.15); `MTLGPUFamilyCommon1` (10.15); `MTLGPUFamilyCommon2` (10.15); `MTLGPUFamilyCommon3` (10.15); `MTLGPUFamilyMac2` (10.15); `counterSets` (10.15); `counters` (10.15); `hasUnifiedMemory` (10.15); `name` (10.15); `supportsFamily:` (10.15); `supportsBCTextureCompression` (11.0) |
| `third_party/dawn/src/dawn/native/metal/QuerySetMTL.h` |  | `MTLCounterSampleBuffer` (10.15) |
| `third_party/dawn/src/dawn/native/metal/QuerySetMTL.mm` |  | `MTLCommonCounterSet` (10.15); `MTLCommonCounterSetTimestamp` (10.15); `MTLCounterSampleBuffer` (10.15); `MTLCounterSampleBufferDescriptor` (10.15); `counterSet` (10.15); `counterSets` (10.15); `name` (10.15); `newCounterSampleBufferWithDescriptor:error:` (10.15); `setCounterSet:` (10.15); `setLabel:` (10.15); `setSampleCount:` (10.15); `setStorageMode:` (10.15) |
| `third_party/dawn/src/dawn/native/metal/ShaderModuleMTL.mm` |  | `setPreserveInvariance:` (11.0) |
| `third_party/dawn/src/dawn/native/metal/TextureMTL.h` |  | `MTLTextureSwizzleChannels` (10.15) |
| `third_party/dawn/src/dawn/native/metal/TextureMTL.mm` |  | `MTLGPUFamilyApple2` (10.15); `MTLTextureSwizzle` (10.15); `MTLTextureSwizzleAlpha` (10.15); `MTLTextureSwizzleBlue` (10.15); `MTLTextureSwizzleChannels` (10.15); `MTLTextureSwizzleGreen` (10.15); `MTLTextureSwizzleOne` (10.15); `MTLTextureSwizzleRed` (10.15); `MTLTextureSwizzleZero` (10.15); `newTextureViewWithPixelFormat:textureType:levels:slices:swizzle:` (10.15); `supportsFamily:` (10.15); `MTLPixelFormatASTC_10x10_LDR` (11.0); `MTLPixelFormatASTC_10x10_sRGB` (11.0); `MTLPixelFormatASTC_10x5_LDR` (11.0); `MTLPixelFormatASTC_10x5_sRGB` (11.0); `MTLPixelFormatASTC_10x6_LDR` (11.0); `MTLPixelFormatASTC_10x6_sRGB` (11.0); `MTLPixelFormatASTC_10x8_LDR` (11.0); `MTLPixelFormatASTC_10x8_sRGB` (11.0); `MTLPixelFormatASTC_12x10_LDR` (11.0); `MTLPixelFormatASTC_12x10_sRGB` (11.0); `MTLPixelFormatASTC_12x12_LDR` (11.0); `MTLPixelFormatASTC_12x12_sRGB` (11.0); `MTLPixelFormatASTC_4x4_LDR` (11.0); `MTLPixelFormatASTC_4x4_sRGB` (11.0); `MTLPixelFormatASTC_5x4_LDR` (11.0); `MTLPixelFormatASTC_5x4_sRGB` (11.0); `MTLPixelFormatASTC_5x5_LDR` (11.0); `MTLPixelFormatASTC_5x5_sRGB` (11.0); `MTLPixelFormatASTC_6x5_LDR` (11.0); `MTLPixelFormatASTC_6x5_sRGB` (11.0); `MTLPixelFormatASTC_6x6_LDR` (11.0); `MTLPixelFormatASTC_6x6_sRGB` (11.0); `MTLPixelFormatASTC_8x5_LDR` (11.0); `MTLPixelFormatASTC_8x5_sRGB` (11.0); `MTLPixelFormatASTC_8x6_LDR` (11.0); `MTLPixelFormatASTC_8x6_sRGB` (11.0); `MTLPixelFormatASTC_8x8_LDR` (11.0); `MTLPixelFormatASTC_8x8_sRGB` (11.0); `MTLPixelFormatEAC_RGBA8` (11.0); `MTLPixelFormatEAC_RGBA8_sRGB` (11.0); `MTLPixelFormatETC2_RGB8` (11.0); `MTLPixelFormatETC2_RGB8A1` (11.0); `MTLPixelFormatETC2_RGB8A1_sRGB` (11.0); `MTLPixelFormatETC2_RGB8_sRGB` (11.0); `MTLStorageModeMemoryless` (11.0) |
| `third_party/dawn/src/dawn/native/metal/UtilsMetal.mm` |  | `MTLGPUFamilyApple2` (10.15); `MTLGPUFamilyMac2` (10.15); `supportsFamily:` (10.15); `useResource:usage:stages:` (10.15); `MTLCounterSamplingPointAtBlitBoundary` (11.0); `MTLCounterSamplingPointAtDispatchBoundary` (11.0); `MTLCounterSamplingPointAtDrawBoundary` (11.0); `MTLCounterSamplingPointAtStageBoundary` (11.0); `MTLPixelFormatASTC_10x10_LDR` (11.0); `MTLPixelFormatASTC_10x10_sRGB` (11.0); `MTLPixelFormatASTC_10x5_LDR` (11.0); `MTLPixelFormatASTC_10x5_sRGB` (11.0); `MTLPixelFormatASTC_10x6_LDR` (11.0); `MTLPixelFormatASTC_10x6_sRGB` (11.0); `MTLPixelFormatASTC_10x8_LDR` (11.0); `MTLPixelFormatASTC_10x8_sRGB` (11.0); `MTLPixelFormatASTC_12x10_LDR` (11.0); `MTLPixelFormatASTC_12x10_sRGB` (11.0); `MTLPixelFormatASTC_12x12_LDR` (11.0); `MTLPixelFormatASTC_12x12_sRGB` (11.0); `MTLPixelFormatASTC_4x4_LDR` (11.0); `MTLPixelFormatASTC_4x4_sRGB` (11.0); `MTLPixelFormatASTC_5x4_LDR` (11.0); `MTLPixelFormatASTC_5x4_sRGB` (11.0); `MTLPixelFormatASTC_5x5_LDR` (11.0); `MTLPixelFormatASTC_5x5_sRGB` (11.0); `MTLPixelFormatASTC_6x5_LDR` (11.0); `MTLPixelFormatASTC_6x5_sRGB` (11.0); `MTLPixelFormatASTC_6x6_LDR` (11.0); `MTLPixelFormatASTC_6x6_sRGB` (11.0); `MTLPixelFormatASTC_8x5_LDR` (11.0); `MTLPixelFormatASTC_8x5_sRGB` (11.0); `MTLPixelFormatASTC_8x6_LDR` (11.0); `MTLPixelFormatASTC_8x6_sRGB` (11.0); `MTLPixelFormatASTC_8x8_LDR` (11.0); `MTLPixelFormatASTC_8x8_sRGB` (11.0); `MTLPixelFormatEAC_R11Snorm` (11.0); `MTLPixelFormatEAC_R11Unorm` (11.0); `MTLPixelFormatEAC_RG11Snorm` (11.0); `MTLPixelFormatEAC_RG11Unorm` (11.0); `MTLPixelFormatEAC_RGBA8` (11.0); `MTLPixelFormatEAC_RGBA8_sRGB` (11.0); `MTLPixelFormatETC2_RGB8` (11.0); `MTLPixelFormatETC2_RGB8A1` (11.0); `MTLPixelFormatETC2_RGB8A1_sRGB` (11.0); `MTLPixelFormatETC2_RGB8_sRGB` (11.0); `supportsCounterSampling:` (11.0) |
| `ui/accelerated_widget_mac/ca_renderer_layer_tree.mm` | sí | `kCVImageBufferAmbientViewingEnvironmentKey` (12.0) |
| `ui/accessibility/platform/ax_platform_node_cocoa.mm` |  | `AXCustomContent` (11.0); `AXCustomContentImportanceHigh` (11.0) |
| `ui/accessibility/platform/inspect/ax_call_statement_invoker_mac.mm` |  | `AXCustomContent` (11.0) |
| `ui/accessibility/platform/inspect/ax_element_wrapper_mac.mm` |  | `AXCustomContent` (11.0) |
| `ui/accessibility/platform/inspect/ax_transform_mac.h` |  | `AXCustomContent` (11.0) |
| `ui/accessibility/platform/inspect/ax_transform_mac.mm` |  | `AXCustomContent` (11.0) |
| `ui/base/clipboard/clipboard_util_mac.mm` | sí | `NSURLContentTypeKey` (11.0); `UTType` (11.0); `UTTypeInternetLocation` (11.0); `UTTypeInternetShortcut` (11.0); `conformsToType:` (11.0) |
| `ui/base/cocoa/appkit_utils.h` |  | `UTType` (11.0) |
| `ui/base/cocoa/appkit_utils.mm` |  | `UTType` (11.0); `typeWithIdentifier:` (11.0); `typeWithTag:tagClass:conformingToType:` (11.0) |
| `ui/gfx/mac/color_space_util.mm` |  | `kCMFormatDescriptionTransferFunction_sRGB` (10.15) |
| `ui/gfx/mac/io_surface.cc` |  | `kCGColorSpaceITUR_2100_HLG` (11.0); `kCGColorSpaceITUR_2100_PQ` (11.0) |
