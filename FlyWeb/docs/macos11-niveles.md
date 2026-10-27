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

- **13.0 (nivel 151):** leída en §8.4.
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

## 8. Traducción a 10.14 por API y nivel (132–156)

Encargo de Titín (27-10): no es decidir si nos quedamos en un nivel, sino **qué hay que traducir** en cada uno. Fuente: el escáner
(`FlyWeb/tools/macos-api/`) pasado sobre el último tag de cada nivel 128–156 con la lista de API de macOS 26.5 menos 10.14 (≈165 000
símbolos, métodos y clases): **`FlyWeb/tools/macos-api/inventario-129-156.tsv`** (506 filas: nivel, uso nuevo o cambio de guarda,
fichero, API, versión de macOS, framework). Sin `ios/`, pruebas ni los falsos positivos conocidos (`validate`, `CGDirectDisplayID`,
`MTLSharedEvent`, que existe desde 10.14). **Es un cribado, no el inventario real:** el compilador con destino 10.14 manda (§6).
Coste: **S** < 1 h, **M** 1–4 h, **L** > 4 h; sin medir [I], sobre el patrón de §3 y la tasa de Legacy (1–3 h por commit, `legacy-evolucion.md` §6).

**Mecanismo de traducción** (cinco, ver §9): **K** constante o macro local; **P** parche en tiempo de ejecución de un método o función que falta;
**G** guarda `@available` con el camino de 10.14 que ya está en la 128; **F** función apagada en 10.14 (framework débil, sin equivalente);
**R** reimplementación con API antigua.

### 8.1 Primero: 132 y 133 (MOTOR-25 está con el 132)

| Nivel | Qué sale del escáner [V] | Qué hace | Camino de 10.14 | Coste |
|---|---|---|---|---|
| **132** | `AXCustomContent` (clase, 11.0) en `ax_element_wrapper_mac.mm` | Contenido de accesibilidad en el volcado de árboles de pruebas | Es herramienta de volcado (`ui/accessibility/platform/inspect`), no producción: nada | — |
| 132 | `thumbnail_capturer_mac.mm`: guardas de 13.2 reducidas de 4 a 1 y una nueva de **14.4** (ScreenCaptureKit) | Miniaturas del selector de pantalla | **F**: ya guardada; en Mojave el selector usa el camino antiguo | S (comprobar) |
| **133** | `kVTCompressionPropertyKey_ReferenceBufferCount` + guarda **13.0** en `vt_video_encode_accelerator_mac.mm:1063` | Codificación de vídeo (WebCodecs/WebRTC) | **G**: llega guardada; no tocar | S |
| 133 | `kCVImageBufferAmbientViewingEnvironmentKey` + guarda **12** en `ca_renderer_layer_tree.mm:174` | HDR en la capa del compositor | **G**: llega guardada. **Ojo:** la serie del 139 la quita (§3b); en 10.14 se conserva | S |
| 133 | `AXPrefersNonBlinkingTextInsertionIndicator*` + 3 guardas **15.0** en `native_theme_mac.mm` | Preferencia de cursor no parpadeante | **G**: llega guardada | S |
| 133 | `service_discovery_client_mac.mm:270`: `MacOSMajorVersion() >= 15` | Descubrimiento local (Cast) | **G** | S |
| 133 | `tool_tip_base_view.mm`: se quita el `#if MIN_REQUIRED < 13.0` y el código **queda siempre activo** | Tooltips | Nada: lo que antes era condicional ahora vale para todos (incluido 10.14) [V: diff 132→133] | — |

**Conclusión para 132 y 133 [V con el cribado, I en cobertura]:** el escáner no encuentra ninguna API de 10.15+ sin guarda; el coste de
plataforma de los dos niveles es **comprobar** (compilar con destino 10.14 y `-Wunguarded-availability`) y **no perder las guardas** que
traen. Lo que hay que vigilar es el 139, que las borra.

### 8.2 134–141

| Nivel | API que aparece (versión) | Qué hace | Camino de 10.14 | Mec. | Coste |
|---|---|---|---|---|---|
| 134 | `userInterfaceEnabled` (12.0, SSO de empresa) | Inicio de sesión de empresa (Entra) | No se usa en FlyWeb | F | S |
| **135** | **`UTTypeUTF8PlainText` (11.0, UniformTypeIdentifiers)** en `bridged_content_view.mm` y `render_widget_host_view_cocoa.mm` | **Pegar y arrastrar texto** | `kUTTypeUTF8PlainText` (CoreServices) o `NSPasteboardTypeString` — lo que usa la 128 [V, `macos11-niveles.md` §3] | R | **M** (se nota: portapapeles) |
| 135 | `providerName` (14.0, iCloud Keychain), `ASAuthorization*` (SSO) | Passkeys de iCloud y SSO | Fuera (FM.42 d10) | F | S |
| 135 | `kVTEncodeFrameOptionKey_BaseFrameQP` | Codificación de vídeo | Símbolo débil con guarda | G/K | S |
| 136 | `AVCaptureDeviceTypeContinuityCamera` (14) | Cámara del iPhone | Guardado por upstream | G | S |
| **137** | **`-[MTLDevice supportsFamily:]` (10.15)** en `metal_context_provider.mm`; `URLForApplicationToOpenContentType:` y `setDefaultApplicationAtURL:` (12.0) en `shell_integration_mac.mm` | GPU: familia Metal; **navegador por defecto** | `supportsFamily:` → `supportsFeatureSet:` (10.11+; tabla de equivalencias de `MTLGPUFamily`); `LSSetDefaultHandlerForURLScheme` (código de la 128) | P / R | **M** (GPU: probar en la 6,1) |
| 138 | `accessBehavior` (15.4, portapapeles), `CATapDescription`/`AudioHardwareCreateProcessTap` (14.2), 7 clases de CoreML | Aviso de acceso al portapapeles; captura de audio del sistema; WebNN | Guardadas; WebNN apagado | G/F | S |
| **139** | **`kIOMainPortDefault`** (12.0) en 15 ficheros (batería, Bluetooth, serie, HID, mandos…); **`SecTrustCopyCertificateChain`** (12.0) en `client_cert_store_mac.cc`; `largeBlob` y 4 clases `ASAuthorizationPlatformPublicKey*` (iCloud) | Puerto de IOKit; **certificados de cliente**; passkeys de iCloud | `kIOMasterPortDefault` (macro local); `SecTrustGetCertificateCount`/`…AtIndex` (código de la 128); iCloud fuera | K / P / F | K: **S** (una línea); cadena: **M**; **L en conjunto** con la serie del 12 (§3b) |
| 140 | `toolbarStyle` (11.0, `NSWindow`) en `immersive_mode_tabbed_controller_cocoa.mm`; `posix_spawnattr_set_csm_np` (11.0) en `launch_mac.cc`; `supportsFamily` otra vez | Barra de pestañas a pantalla completa; lanzar procesos | `toolbarStyle`: no existe en 10.14, es una propiedad estética → no-op (**P**); `csm_np`: guardar con `__builtin_available` | P/G | S |
| 141 | `NSPreviewRepresentingActivityItem` (clase, 13.0) | Compartir con vista previa | Guarda de clase (`NSClassFromString`) | G | S |

### 8.3 142–156 (resumen por nivel; el inventario completo, en el TSV)

| Nivel | Nº usos | Lo que pesa | Camino de 10.14 | Coste |
|---|---|---|---|---|
| **142** | 27 | **Constantes de accesibilidad** (`NSAccessibilityBlockQuoteLevelAttribute`, `…VisitedAttribute`, `…WebAreaRole`, `…ScrollToVisibleAction`, `…UIElementsForSearchPredicateParameterizedAttribute`, `…LanguageAttribute`…): Chromium deja de definirlas él y usa las públicas del SDK 26; **`safeAreaInsets` (12.0)**, `toolbarStyle`, `ASWebAuthenticationSessionCallback` | **K**: definir las cadenas a mano (los valores públicos son literales conocidos); `safeAreaInsets` → `NSEdgeInsetsZero` (**P**); inicio de sesión web por sesión: F | **M** (VoiceOver depende de las constantes) |
| 143 | 1 | `MTLSharedEvent` (falso positivo, existe en 10.14) | — | — |
| 144 | 7 | `SCContentFilter`, `SCShareableContent`… (ScreenCaptureKit, 12.3) | Selector de captura de pantalla: F (camino `CGDisplayStream` de la 128) | S |
| 145 | 10 | **`minimumRefreshInterval`, `maximumRefreshInterval`, `displayUpdateGranularity`, `maximumFramesPerSecond` (12.0)** en `screen_utils_mac.mm`/`screen_mac.mm`; `ellipsoidalAltitude` | **P**: emular con `CVDisplayLink` (como la 128) o ceros; altitud: guarda | **M** (arranque: ver §3b) |
| **146** | 17 | `CAMetalDisplayLink` (14.0) y `presentedTime`/`drawableID` (10.15) en `ca_metal_display_link_mac.*`; `GCXboxGamepad` | Solo existe con ANGLE-Metal+Graphite (`plan-fork.md` §2): en Mojave no se activa | F | S, **más el hito de Graphite (GPU)** |
| 147 | 30 | **CoreHaptics** (`CHHaptic*`, 10.15), `GCDualSenseGamepad`, `contextMenuKeyDown` (15.0) | Vibración de mandos: F; menú contextual: guarda | F | M |
| 148 | 4 | **`NSWorkspaceOpenConfiguration` (10.15)** en `mac_util.mm` y `platform_util_mac.mm` | Es lo que la 128 ya traduce en `launch_application.mm` (nuestro parche de 90 líneas): **mismo mecanismo** que el 128; ejemplo de lo que la capa A reutilizaría | R | **M** |
| 149 | 4 | `SCContentSharingPicker` (ScreenCaptureKit), `minimumRefreshInterval` otra vez | Igual que 144/145 | F/P | S |
| 150 | 18 | **`NSGlassEffectView` (26.0)**, `IOHIDCheckAccess` (10.15, teclas multimedia), más CoreHaptics | Vidrio líquido: clase ausente → vista normal (F); `IOHIDCheckAccess` → devolver «concedido» (P) | F/P | M |
| **151** | 8 | `kSecUseDataProtectionKeychain` (SE: fuera), `posix_spawn_file_actions_addchdir`, métricas de VideoToolbox. **Más la serie de macOS 13, ya leída (§8.4)** | §8.4: ≈ 65 ficheros (42 de producción), **más pequeña que la del 12** | G | **L** (6–10 h) |
| **152** | **90** | **Constantes de búsqueda de accesibilidad** (`NSAccessibility…SearchKey`, `…ListMarkerRole`, `…FontBoldAttribute`) | **K**: generar una cabecera de constantes a partir del SDK 26.5 | K | M (mecánico) |
| 153 | 16 | HDR `preferredDynamicRange`/`contentsHeadroom` (26.0), `imageWithSystemSymbolName` (11.0) en `main_menu_builder.mm`, `openApplicationAtURL` (10.15), `SCScreenshotManager` (14) | HDR: guarda; **iconos de menú SF Symbols**: sin imagen en 10.14; abrir app: igual que 148 | G/R | M |
| 154–156 | 6 / 3 / 2 | VideoToolbox HEVC 4:2:2, `includedDisplays`, `isDeviceConfiguredForPasskeys` | Guardadas o fuera | G/F | S |

**Resumen del coste (S=0,5 h, M=2,5 h, L=6 h) [I]:** 132–138: ≈ 5 h; 139: ≈ 10–12 h (la serie de 12 con lo del 139); 140–141: ≈ 1 h; 142–150: ≈ 15–18 h; 151: ≈ 6 h
sin leer la serie de 13 (más con ella); 152–156: ≈ 5 h. **Del 132 al 150, unas 35–40 h de papel** de traducción de plataforma, frente a las ≈ 9,5 h /
≈ 1,6 h / ≈ 30 h del motor de cada nivel (`migracion-128.md` §4). Según `DIRECTIVAS.md`, las horas de papel salen pesimistas.

### 8.4 Del 151 en adelante: traducir lo de macOS 13 y Graphite, o dejarlo fuera

Pedido por COORDINACIÓN-16 (decide Titín con estas cifras). **La serie de macOS 13** (espejo de GitHub, `--shallow-exclude=151.0.7872.0` hasta `152.0.7923.0`, 14 738 commits en el
intervalo) es de **junio de 2026**: `ab7e2c0` «Change Chromium's deployment target to macOS 13» (2-06), revertida y reaplicada (`1d98034`, `3a7cdb6` «Make Chromium require macOS 13», 8-06) y **16 commits**
«Remove code supporting macOS 12 from X» entre el 10 y el 16-06 [V]. En total **≈ 65 ficheros (42 de producción), +400 −870 líneas**: bastante menos que la del 12 (≈ 115 ficheros).

| Commit | Área | Qué desaparece / cambia | Efecto en 10.14 | Qué hacer |
|---|---|---|---|---|
| `3a7cdb6` | `mac_sdk.gni`, `share_menu_controller.mm` (+9) | **Comprobación de «requiere macOS 13» al lanzar** (había una versión revertida, `8829a70`) | **Bloquearía el arranque** si se copiara | No portar; el `LSMinimumSystemVersion` de FlyWeb sale de `mac_min_system_version:10.14` (`build.sh`) |
| `28cfa0a` base | `base/mac/mac_util.mm` (40/150), `launch_application.mm` (3/47), `process_requirement.cc` (9/27) | Detección de versión y el rodeo de «lanzamiento con error» de macOS 12 | `launch_application.mm` ya es nuestro parche (90 líneas): mantenerlo | G |
| `4843d75` remote_cocoa | `immersive_mode_controller_cocoa.mm` (6/45), `native_widget_mac_nswindow.mm` (18/27), `browser_native_widget_window_mac.mm` | Barra de pestañas a pantalla completa, ventana nativa | Funcionalidad de 12: mantener la rama de la 128 | G/F |
| `c9b0782` media | `vt_video_encode_accelerator_mac.mm` (49/76), `video_toolbox_frame_converter.cc` (0/20), `screen_capture_kit_swizzler.mm`, `audio_loopback_input_mac_impl.mm` | Rutas de VideoToolbox y de captura de audio | Mantener las guardas | G |
| `461c392`, `2adb229` | ScreenCaptureKit (selector, miniaturas) | Quita las guardas de 12.3 | En 10.14 sigue apagado | F |
| `05445ba` sandbox | `sandbox/policy/mac/common.sb` | **`(if (>= os-version 1300) (allow … /System/Cryptexes …))` pasa a ser incondicional** | Las rutas `Cryptexes` no existen en 10.14; una regla `allow` sobre una ruta inexistente es inocua [I; probar con el perfil V2 en Mojave] | Probar |
| `5f58a1f` gpu | `webgpu_blocklist_impl.{cc,h}` | Quita la razón `DynamicArrayIndexInStruct` (AMD con Metal < 13) | WebGPU sigue apagada | Nada |
| `d5d4f94` webnn, `be311d8` installer, `37144d8` | CoreML, firmador, caché persistente | — | No se usa | — |

**Coste de traducir lo de macOS 13: L, ≈ 6–10 h de papel [I]** (lectura de la serie ≈ 2 h y 1–3 h por commit afectado en `base/`, `remote_cocoa` y `media/`); pesa más el 139 que el 151.

**Graphite (146–151):** es la decisión que cuesta de verdad y no se resuelve con una guarda.
- **Dejarlo fuera:** `kSkiaGraphite` apagada en nuestro parche (en Mojave ni siquiera se activaría: exige ANGLE-Metal, `plan-fork.md` §2) y seguir con Ganesh/OpenGL. **Coste ≈ 0 h** mientras el camino de OpenGL exista en la compositora: en el 158 siguen estando `skia_output_device_gl.{cc,h}` y `skia_output_device_buffer_queue.*` [V: `components/viz/service/display_embedder`]. Señal de alarma: que upstream los borre o que `kSkiaGraphite` deje de ser una función.
- **Traducirlo:** Dawn-Metal en 10.14 y en GPU sin la familia Mac2 (las de 2012–2015), más Graphite sobre ello. **No tengo cifra publicada ni propia**; es el ámbito del «GPU en Mojave» (FM.31/FM.43) con una superficie mayor (Dawn + Graphite + shaders). Orden de magnitud **XL (> 20 h) y con riesgo alto de regresión de GPU** [I, sin medir].
- **Recomendación a Titín:** **dejar Graphite fuera** y traducir solo lo de macOS 13 (L, 6–10 h); reabrir Graphite únicamente si aparece la señal de alarma. Con esto el 151 deja de ser una puerta y pasa a ser un nivel más, con su tanda de plataforma.

## 9. (A) Capa de compatibilidad propia: «FlyWeb Compat»

### 9.1 Qué hay hoy: parches sueltos [V]

En `brave-core` `nube/motor25-p25` hay **1 160 `.patch`**; los que existen **solo** para Mojave o para quitar el Secure Enclave son **26 ficheros (medidos) y ≈ 620
líneas cambiadas**, repartidos por 14 directorios:

| Parche (`patches/…`) | Líneas | Qué traduce | Pasaría a la capa |
|---|---|---|---|
| `base-mac-launch_application.mm` + `base-mac-launch_services_spi.h` + `base-process-launch_mac.cc` | 90 + 2 + 40 | `NSWorkspaceOpenConfiguration` (10.15) y `posix_spawn` con `chdir` → `LSOpenApplication` y camino de 10.14 | **Sí** (R): mismo problema reaparece en 148, 153 |
| `media-capture-video-apple-video_capture_device_avfoundation.mm` + `…helpers.mm` | 78 + 9 | `AVCapturePhotoOutput` → `AVCaptureStillImageOutput` | Parcial: es una función, no una API |
| `components-eye_dropper-…_mac.mm` + `chrome-browser-ui-views-eye_dropper-…` | 89 + 48 | `NSColorSampler` (10.15) → reimplementación (cuentagotas) | No: función completa; vive en su módulo |
| `services-device-public-cpp-geolocation-system_geolocation_source_apple.{h,mm}` | 31 | `requestWhenInUseAuthorization` | **Sí** (P) |
| `components-input-web_input_event_builders_mac.mm`, `content-browser-renderer_host-render_widget_host_view_mac.mm`, `content-app_shim_remote_cocoa-render_widget_host_view_cocoa.mm` | 25 + 12 | Eventos y entrada | Revisar |
| `device-bluetooth-…`, `device-gamepad-…`, `chrome-browser-platform_util_mac.mm`, `chrome-browser-app_controller_mac.mm`, `components-metal_util-hdr_copier_layer.mm`, `content-common-font_list_mac.mm`, `gpu-ipc-service-image_transport_surface_overlay_mac.mm`, `chrome-browser-apps-link_capturing-mac_intent_picker_helpers.mm` | 23, 20, 20, 19, 18, 12, 11, 10 | Guardas de APIs de 10.15 (Bluetooth, mandos, `platform_util`, ASWebAuthentication, HDR, fuentes, capas, intents) | **Sí** (G/P) |
| `crypto-unexportable_key_mac.mm`, `device-fido-mac-*`, `chrome-browser-device_reauth-…`, `…secure_enclave_client_impl.mm`, `crypto-features.cc` | 7, 10, 4, 9, 19 | Sin Secure Enclave ni T2 (FM.42 d1–d8) | No: decisión de producto; quedan como parches |
| `base-threading-platform_thread_apple.mm`, `media-mojo-services-gpu_mojo_media_client_mac.cc`, `components-os_crypt-sync-keychain_password_mac.mm` | 8, 6, 2 | Hilo de audio en tiempo real, xHE-AAC, nombre del llavero | Parcial |

(No incluye ANGLE, Dawn ni Skia, que viven en `third_party/` y tienen sus propios parches.)

### 9.2 Diseño propuesto

**Idea central: una capa de *polyfills*, no de wrappers.** Si el código de upstream llama a la API nueva con su nombre, la capa hace que **esa
llamada funcione también en 10.14**, sin que cada sitio se parchee. Los wrappers (`FlyWeb::IOMainPort()`) obligan a reescribir cada llamada y cada
commit futuro de upstream que use la API; los polyfills no. Cinco mecanismos, de menos a más delicado:

1. **K – constantes y macros** (cabecera de inclusión forzada con `-include`): `#define kIOMainPortDefault kIOMasterPortDefault`, las constantes de
   accesibilidad del 142 y el 152, `UTTypeUTF8PlainText`→cadena equivalente. Sin código en tiempo de ejecución. Cubre 139 (15 ficheros), 142 y 152.
2. **P – métodos que faltan, añadidos al arrancar** (`class_addMethod` solo si `![Cls instancesRespondToSelector:]`): `-[NSScreen minimumRefreshInterval]`,
   `-[NSWindow toolbarStyle]`, `-[MTLDevice supportsFamily:]`, `safeAreaInsets`. **Nunca como categoría** (sobrescribiría la implementación real en 12+).
3. **P – funciones C que faltan**: definición propia con el mismo nombre que cae en `dlsym` del real y, si no existe, en el camino de 10.14 (`SecTrustCopyCertificateChain`,
   `IOHIDCheckAccess`). El espacio de nombres de dos niveles de macOS enlaza con la definición del ejecutable, así que el código de upstream no cambia [I; comprobar en Mojave].
4. **F – frameworks y clases que no existen** (UniformTypeIdentifiers, ScreenCaptureKit, CoreHaptics, CoreML, `NSGlassEffectView`): enlace débil (`weak_frameworks` en el
   `BUILD.gn`) y un `FlyWebCompat::HasClass()`; el sitio de upstream ya está guardado o se guarda una vez.
5. **R – reimplementaciones** (lanzar aplicaciones, cuentagotas, foto, `UTType`): módulos propios con su prueba; **no** son polyfills y se quedan fuera de la capa.

**Organización:** una cabecera por **familia de API** (`io_port`, `display_refresh`, `accessibility_constants`, `metal_family`, `sec_trust`, `workspace_launch`…)
y un único registro (`flyweb_compat.mm`) que instala los polyfills de tipo P al arrancar, **por mecanismo y no por subsistema**: el mismo mecanismo se
revisa de una vez (seguridad: hay *swizzling*), y la lista de familias es el inventario vivo. Una prueba por familia que corre en 10.14 y en 12+ y compara el
polyfill con la API real donde existe (`compat_unittest.mm`).

### 9.3 Qué ahorra y qué no (crítica)

- **Ahorra [I]:** las llamadas nuevas de upstream (§8) dejan de necesitar parche si su API está en la capa. Del 139: la macro del puerto de IOKit evita
  **15 ficheros**; las constantes de accesibilidad del 142 y 152, **otros ≈ 100 sitios** del TSV; `minimumRefreshInterval` y `supportsFamily` aparecen en 4 niveles
  distintos. Cada commit de upstream que vuelva a usar esas API ya no cuesta 1–3 h (Legacy) sino **0**.
- **Frente a Chromium Legacy:** Legacy tiene un parche de guarda por sitio y **69 commits de guarda o evitación de API en 24 meses** (≈ 3 al mes, en rachas de hasta
  24 en tres días) y series de **20–30 *reverts*** cada vez que sube el mínimo (`legacy-evolucion.md` §4–5). Una capa convierte «muchos sitios, un parche cada uno» en
  «una familia, un polyfill»: es la diferencia entre una deuda que crece con cada nivel y una que crece con cada API nueva.
- **No ahorra:** (a) las funciones sin equivalente (ScreenCaptureKit, haptics: se apagan igual), (b) las reimplementaciones (R), (c) el trabajo de **detectar** qué API entra en
  cada nivel (el escáner y el compilador siguen haciendo falta), y (d) la revisión: un polyfill mal hecho es peor que un parche visible porque oculta el problema.
- **Riesgos:** *swizzling*/`class_addMethod` es frágil si Apple cambia la clase (pero solo actúa cuando el selector **falta**, o sea, nunca en 12+); un `-include` global
  puede chocar con cabeceras (mitigación: nombres con prefijo `FLYWEB_` y `#ifndef`); el comportamiento emulado puede divergir (p. ej. `minimumRefreshInterval` desde `CVDisplayLink`).
  Mitigación: cada familia declara su comportamiento y su prueba; **nada que toque seguridad** (Secure Enclave, T2) entra: sigue siendo decisión de producto.
- **Orden recomendado [I]:** empezar por K (sin riesgo, ahorra más: 139, 142, 152), luego P para las familias que se repiten (`display_refresh`, `metal_family`),
  y dejar R donde están. Primer paso útil: mover el `kIOMainPortDefault` y las constantes de accesibilidad **antes** de portar el 139 y el 142.

## 10. (B) Firefox 115 ESR como referencia

**Qué es:** la última versión de Firefox para **macOS 10.12–10.14** (y Windows 7/8/8.1). Firefox 116 pasó a exigir macOS 10.15; los usuarios de 10.12–10.14 se mueven
automáticamente a la rama ESR 115 [F: Mozilla, «Firefox users on macOS 10.12, 10.13 and 10.14 moving to Extended Support Release»,
`support.mozilla.org`, abierta desde el buscador; mis herramientas no podían abrir `mozilla.org`].

**Fechas [F, con la fuente; las he cruzado entre varias, no abierto la original]:**

| Fecha | Hecho | Fuente |
|---|---|---|
| 04-07-2023 | Salida de Firefox 115 ESR | endoflife.date, «115 (ESR)» |
| 2024 (septiembre) | Fin previsto ampliado hasta **marzo de 2025** | AlternativeTo, 2024 |
| 04-09-2025 | Ampliado hasta **marzo de 2026** (Windows 7/8/8.1 y macOS 10.12–10.14) | blog «Future Releases» de Mozilla; gHacks |
| 2026 (marzo) | Ampliado hasta **agosto de 2026** | abit.ee |
| 21-10-2026 | La página de soporte de macOS 10.12–10.14 dice **marzo de 2027** y que se reevaluará | support.mozilla.org; endoflife.date (actualizado 21-10-2026: «31 mar 2027») |

Es decir: **unos 44 meses de actualizaciones de seguridad para un sistema que la rama principal dejó en agosto de 2023**, ampliados cuatro veces en tramos de 6–12 meses.

**Lo que se ve en el código [V, `mozilla/gecko-dev`]:**

- La rama `esr115` tiene la versión **115.26.0** y compila Intel con **destino 10.12** (`build/moz.configure/toolchain.configure:56-62`: «We continue to target 10.12 on Intel, but can target 11.0
  for aarch64»).
- Las ramas `esr128` y `esr140` compilan Intel con **destino 10.15** (l. 59-65 y 183-189): **Gecko ha mantenido 10.15 como mínimo en Intel durante tres ESR** (115→140), mientras que
  Chromium subió el mínimo tres veces en el mismo tiempo (11.0, 12.0 y 13.0 en 129, 139 y 151). Gecko paga menos plataforma por nivel.
- El destino de Intel y el de Apple Silicon son **independientes** («…since the earliest hardware was released alongside 11.0»): Mozilla separa por CPU lo que Chromium separa por versión.

**Qué nos sirve:**

1. **Modelo de mantenimiento:** una rama larga con **solo parches de seguridad** y el mínimo de SO congelado, sin portar funciones. Es lo que FlyWeb hace con la 128 en el eje de seguridad
   (FS.24); la diferencia es que Mozilla lo sostiene con un equipo y una base de código mucho más pequeña, y aun así lo ha ampliado a tramos y **con una reevaluación cada seis meses** (decidida con el
   uso real). Propongo que FlyWeb adopte la misma cadencia: reevaluar el nivel soportado cada seis meses con datos de uso, no una fecha única.
2. **Plazo realista:** 44 meses, sin garantía de más. Si Titín quiere una promesa pública a los usuarios de Mojave, la referencia es «ampliaciones de 6–12 meses», no «para siempre».
3. **El contraste del mínimo (115→140 en 10.15) es el argumento de `vision-motor.md` sobre Gecko:** un motor que no sube el mínimo de SO al ritmo de Chromium reduce el coste de plataforma de la capa A.
   No cambia la decisión (Blink por la compatibilidad de claude.ai), pero cuantifica lo que se paga.
4. **Lo que no nos sirve:** no es un motor al que portar (la base de código no es la nuestra) ni una fuente de parches de Blink.

**Qué no pude comprobar:** el cuerpo de las páginas de Mozilla (el entorno no llega a `mozilla.org`): las fechas vienen de resúmenes del buscador y de `endoflife.date`; cómo
selecciona Mozilla los parches que retroporta a la ESR 115 y cuántos CVE quedan sin corregir [N]; el número exacto de versiones 115.x publicadas.

Fuentes: espejo `github.com/chromium/chromium` (tags y commits citados), `github.com/v8/v8` (tags 12.8.98 a 14.9.98),
`github.com/alexey-lysiuk/macos-sdk` (SDK 10.14 y 26.5), `github.com/mozilla/gecko-dev` (ramas `esr115`, `esr128`, `esr140`), `brave-core` `nube/motor25-p25`,
`legacy-evolucion.md`, `mojave-128.md`, `chromium-legacy.md`, `plan-fork.md`; Mozilla (vía buscador): [Extended Firefox ESR 115 Support…](https://blog.mozilla.org/futurereleases/2025/09/04/firefox-esr-115-support-for-windows-7-8-and-8-1-and-old-mac-os-versions-extended-until-march-2026/),
[Firefox users on macOS 10.12–10.14 moving to ESR](https://support.mozilla.org/en-US/kb/firefox-users-macos-1012-1013-1014-moving-to-extended-support), [endoflife.date/firefox](https://endoflife.date/firefox).
