# macOS 11+ en los niveles 129 y siguientes (FM.44, punto 1)

INVESTIGACIÓN-MOTOR-4 (borrador, 27-10-2026) e INVESTIGACIÓN-MOTOR-5 (continuación y cierre, 27-10-2026). Solo papel.
Marcas: [V] visto en el código o fuente; [I] inferencia; [N] no comprobado. Las líneas son de Chromium 128.0.6613.138 salvo
que se diga otra cosa.

## 1. Cuándo sube Chromium el mínimo [V]

`build/config/mac/mac_sdk.gni` en el primer tag de cada hito (espejo `github.com/chromium/chromium`):

| Cambio | Entre tags | Afecta desde | Commit |
|---|---|---|---|
| 10.15 → **11.0** | 129.0.6614.0 → 130.0.6669.0 | Chrome **129** | `165142f8` «Bump the Chrome macOS deployment target to 11.0» (25-07-2024) |
| 11.0 → **12.0** | 139.0.7205.0 → 140.0.7259.0 | Chrome **139** | `cb3ea77` «Change Chromium's deployment target to macOS 12» (28-05-2025; Avi Drissman; 25 ficheros, +75 −135) |
| 12.0 → **13.0** | 151.0.7872.0 → 152.0.7923.0 | Chrome **151** | (sin leer; fuera del alcance del punto 1, ver plan del fork) |

Contraste con el último tag de cada nivel (`mac_deployment_target` en `build/config/mac/mac_sdk.gni`) [V]: 128 = 10.15; 129–138 = 11.0; 139–150 = 12.0; 151–158 = 13.0.

SDK oficial (`mac_sdk_official_version`, último tag de cada nivel) [V]: 14.0 hasta la 130, 15.x de la 131 a la 141, 26.x de la 142 a la 156, 27.0 desde la 157.

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

## 3b. La serie de macOS 12 (nivel 139), leída [V]

Commits «Remove code supporting macOS 11 and earlier from X» entre el 28-05 y el 04-06-2025 (espejo de GitHub,
`git fetch --filter=tree:0 --shallow-exclude=139.0.7205.0 origin tag 140.0.7259.0`; 12 053 commits en el intervalo). Total ≈ 115
ficheros y ≈ 900 líneas cambiadas, **la mitad pruebas**. Lo que importa para Mojave (en negrita, lo que se rompe en 10.14 si se
copia tal cual):

| Commit | Área | Qué desaparece (el «else» es nuestra traducción) | Efecto de copiarlo en 10.14 |
|---|---|---|---|
| `cb3ea77` | 25 ficheros: `base/files/drive_info_mac.cc`, `base/mac/mac_util.mm`, `base/power_monitor/*`, `chrome/browser/shell_integration_mac.mm`, `device/bluetooth/bluetooth_adapter_mac.mm`, `device/gamepad/xbox_data_fetcher_mac.cc`, `media/base/mac/{color_space_util_mac,video_frame_mac}.mm`, `services/device/{hid,serial}/*`, `services/shape_detection/barcode_detection_impl_mac_vision_api.mm` | Deprecaciones que son error al subir el destino: `kIOMasterPortDefault` → **`kIOMainPortDefault` (12.0)** (verificado en `drive_info_mac.cc`); `media/base/mac/video_frame_mac.mm`: **`CVBufferHasAttachment` (12.0)** en lugar de `CVBufferGetAttachment`; guardas de Vision | **Símbolo inexistente en 10.14**: no portar el cambio de nombre; en 10.14 hay que mantener `kIOMasterPortDefault` (o `MACH_PORT_NULL`, equivalente documentado) |
| `9f9c74b` //ui | `ui/display/mac/screen_mac.mm`, `ca_display_link_mac.mm`, `accelerated_widget_mac/ca_renderer_layer_tree.mm` | Rama «CVDisplayLink» de `screen_mac.mm` (frecuencia de refresco) y guardas de 12 | **`NSScreen.minimumRefreshInterval` es de 12.0: en 10.14 es «unrecognized selector» y cae la app al primer `BuildDisplayForScreen`** (arranque). **La 128 ya usa solo `CVDisplayLink` (`screen_mac.mm:178-189`) [V]: no portar** |
| `d56bb5b` //media | `media/capture/video/apple/video_capture_device_avfoundation.mm`, `uvc_control_mac.mm` | Rama «< 12» de cámaras | Mantener la de la 128 |
| `8fb0bb8` //net | `net/cert/x509_util_apple.cc` (borra `CertificateChainFromSecTrust` con su rama `SecTrustGetCertificateCount`/`…AtIndex`), `client_cert_store_mac.cc` | `SecTrustCopyCertificateChain` (12.0) pasa a incondicional | **Certificados de cliente rotos en 10.14**; mantener la función de la 128 |
| `d1c6b42` //gpu | `gpu/command_buffer/service/feature_info.cc` | `if MacOSMajorVersion() >= 11` para `YUVA_420_TRIPLANAR` | Mantener la guarda (formato de IOSurface de 11.0) |
| `70d05a4` //base | `base/mac/launch_application.mm` | Chequeo `== 11 \|\| == 12`; `base/process/memory_unittest.cc` | Sin efecto en 10.14 (la ruta es la de ≤10.15 de la 128) |
| `1121fdd` Chromium | `chrome/browser/shell_integration_mac.mm` (28/75), `mac/install_from_dmg.mm` (42/89), `remote_cocoa/app_shim/{immersive_mode_*,native_widget_mac_nswindow}.mm`, `mac_notifications/*`, enterprise SSO | «navegador por defecto» (`URLForApplicationToOpenContentType:`, `setDefaultApplicationAtURL:`: 12.0), mover a Aplicaciones desde DMG, barra de herramientas inmersiva, notificaciones | Mantener lo de la 128 en los tres primeros; el resto, no se usa o cae en el else |
| `fe2b683` PWA | `web_applications/os_integration/mac/{app_shim_launch,web_app_shortcut_mac,bundle_info_plist}.mm`, `shortcuts/platform_util_mac.*` | Rama «< 12» de las apps instaladas (accesos directos) | Comprobar si FlyWeb conserva PWA (Brave sí) antes de tocar |
| `0857ae0` PartitionAlloc | `partition_alloc/*` (7 ficheros) | Quita el «macOS 11 malloc size hack» | **Sin efecto en 10.14:** el apaño está bajo `MacOSMajorVersion() == 11` (`partition_root.cc:1025`) [V]. Se puede portar |
| `ca17ee4`, `dfc1140`, `1dfb7a4`, `1e13ff5`, `9aea9cc` | WebAuthn (SE apagado en FlyWeb), `virtual_display_util_mac` (pruebas), UI de Chrome, WebNN, pruebas de accesibilidad | — | Nada en producción para Mojave |

Lo mismo vale para la serie de macOS 11 (§3): son los mismos ficheros; cada vez que sube el mínimo, los «else» desaparecen.

**Hallazgo nuevo: `coreaudio_dispatch_override` (borrado en `ee2ae23e`, nivel 129) hace falta en Mojave [V].**
`media/audio/mac/coreaudio_dispatch_override.cc` es un apaño de crbug 772410 (los callbacks de audio de un dispositivo dejan de
llegar cuando `HALC_IOContext_ResumeIO/PauseIO` se ejecutan desordenados). Su código dice «From Mac OSX 10.10 to 10.15 … Apple
reports this issue is fixed in 11+» (l. 106-111 y 154-156) y se llama desde `audio_manager_mac.cc:974`. Upstream lo borra con la
subida a 11.0 porque ya no sirve; **en 10.14 sí**. Receta: conservar los dos ficheros y la llamada de la 128. Riesgo si se
pierde: audio que se queda mudo en pestañas con WebAudio/WebRTC en ciertos dispositivos [I: síntoma por el comentario del código].

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
| 139 | media, chrome, ui… (≈25 ficheros) | serie de quitar guardas de 12 (`video_capture_device_avfoundation.mm`×5, `x509_util_apple.cc`, `color_space_util_mac.mm`, `native_widget_mac_nswindow.mm`, `shell_integration_mac.mm`×4…) | API de 12.0 | Leído en §3b: el «else» está en la 128; lo grave es `screen_mac.mm` (arranque) y los certificados de cliente |
| 140 | content | `render_widget_host_ns_view_bridge.mm` | `NSPreviewRepresentingActivityItem` (13.0) | Clase: guarda o débil |

**V8** [V para `src/base`, `src/libplatform` y `src/snapshot/embedded`, y para los ficheros de plataforma Mac de 12.8 a 14.9 en `v8/v8`]:
no hay ninguna comprobación de versión de macOS ni API de 11+ (`__builtin_available`, `@available`, `MAC_OS_X_VERSION`,
`os_unfair_lock`…): la única guarda es `pthread_jit_write_protect_np`, solo arm64 (`platform-darwin.cc:228-233`). Lo que cambia en
`platform-darwin.cc` entre 12.8 y 14.9 es de API interna de V8 (`SharedMemoryHandle`, 14.5) y en `platform-posix.cc` la
etiqueta `VM_MAKE_TAG` de `mmap` (14.3), sin relación con la versión del SO. **V8 no paga plataforma en estos niveles.** Se miró
con `git grep` en un clon parcial de los tags `12.8.98`…`14.9.98`; el resto de `src/` no se barrió entero [N].

**Blink:** solo cambian pruebas (`harfbuzz_shaper_test.cc`, `font_*_mac_test.mm`) según el cribado del borrador; de nuevo, lo
que paga es `ui/`, `content/`, `media/`, `gpu/`, `net/`, `base/mac`. Coincide con `legacy-evolucion.md` §6.

## 5. Receta por nivel (propuesta)

1. Antes de portar el nivel N: `fetch.sh` de los tags N y N+1, `scan.py` y lista de ficheros tocados por el porte; el
   cruce da los puntos de riesgo.
2. En cada fichero de la lista: si el commit borra una guarda, **no borrarla** (mantener el «else» de la 128).
3. Constantes y clases nuevas: guarda `@available` o, en C, comprobar `&kSimbolo != nullptr` (enlace débil).
4. Frameworks que no existen en 10.14 (UniformTypeIdentifiers, ScreenCaptureKit…): enlace débil en el BUILD.gn
   (`weak_frameworks`), o dyld no arranca la app.
5. Compilar con `mac_deployment_target=10.14`: cada aviso nuevo de `-Wunguarded-availability` que no esté en la lista
   del paso 1 es un hueco del cribado.

## 6. Qué queda abierto

- **13.0 (nivel 151)** sin leer: la serie «Remove code supporting macOS 12 and earlier» no se ha abierto (es de `plan-fork.md`,
  punto 4 de FM.44).
- El **inventario real** lo da la compilación con `mac_deployment_target=10.14` y `-Wunguarded-availability`; este documento es el
  cribado de antes del porte, no sustituye al registro de avisos (LOCAL).
- `scan.py` queda con el filtro de ruido de una sola palabra en minúscula (`process`, `platform`…); falta ampliar `sparse.txt` a
  `third_party/blink/renderer/platform/fonts` y `editing` si se quiere cubrir Blink con la lista de API [N].
- **Chromium Legacy no aporta aquí:** su último código es la 127 y nunca trató la subida a 11 (`chromium-legacy.md`).
- Hipótesis no probadas en Mojave (todas [I]): el síntoma de audio sin `coreaudio_dispatch_override`; que `screen_mac.mm` sin el
  `CVDisplayLink` caiga en el arranque (el selector no existe antes de 12; la caída es por «unrecognized selector»).

## 7. Resumen para MOTOR

1. **No se porta la serie de macOS 11 ni la de 12 (niveles 129 y 139).** Quitan justo los «else» que son la traducción a 10.14 y
   que ya están en la 128.
2. Al portar cualquier otro commit que toque esos ficheros, **gana la rama de la 128**. La lista de ficheros está en §3 y §3b.
3. **Conservar** `coreaudio_dispatch_override` (§3b): único caso en que lo que upstream borra aún hace falta en Mojave, además
   de las 11 filas de §3 y `screen_mac.mm`.
4. Los niveles de motor (Blink y V8) casi no pagan plataforma (§4): el trabajo está en `ui/`, `content/`, `media/`, `gpu/`,
   `net/`, `base/mac`.
5. Coste del método: preparar el escáner por nivel (`fetch.sh`, `scan.py`) ≈ 1 h; leer la serie de cada subida de mínimo ≈ 2–3 h
   [I, sin medir].

Fuentes: espejo `github.com/chromium/chromium` (tags y commits citados), `github.com/v8/v8` (tags 12.8.98 a 14.9.98),
`github.com/alexey-lysiuk/macos-sdk` (SDK 10.14 y 15.5), `legacy-evolucion.md`, `mojave-128.md`, `chromium-legacy.md`.
