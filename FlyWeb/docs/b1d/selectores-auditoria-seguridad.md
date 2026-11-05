# Auditoría de selectores sin guarda de la 156 en 10.14: clasificación A/B/C

SEGURIDAD-PORTES-17, 05-11-2026, por encargo de COORDINACIÓN-29.

**Base:**
- Revisión: `lamosquita-net/chromium` `flynk-b1d` d11d785b.
- Lista: `selectores-unguarded-156.md` de LOCAL-19, rama `local/fm55-b1d` (#753).
- Ficheros: los 53 que LOCAL-18 no había tocado.
- Método: los 42 que no son de Dawn los leí junto con sus llamadores, repartidos en tres lecturas paralelas. Las cuatro A
  las verifiqué yo en el código.

**Criterio:**

| Clase | Qué significa |
|---|---|
| **A** | Se ejecuta en una ruta corriente en 10.14 sin guarda efectiva. Hay que arreglarlo. |
| **B** | Solo en rutas raras, o ya protegido por otra comprobación. |
| **C** | No se ejecuta en Mac de escritorio. |

Marcas: **[V]** verificado en código; **[I]** inferencia.

## Resumen

**Ninguna caída nueva del proceso en las rutas corrientes de 10.14.** Las guardas de LOCAL-19 (d11d785b) evitan todas las
excepciones que apuntaba la lista. Quedan **cuatro A sin caída: son fallos visibles que una web o un usuario corriente
provocan**, y dos B que conviene blindar.

| Clase | Ficheros |
|---|---|
| A | 4 (en 3 ficheros de la lista y 1 de fuera de ella: `media_switches.cc`) |
| B | 33 |
| C | 16 (11 de Dawn y 5 del inspector de accesibilidad) |

## A: arreglar en la próxima compilación (la de PGO)

### A1. Arrastrar una imagen **hacia** la página
- **Dónde:** `content/browser/web_contents/web_drag_dest_mac.mm` l.861–886, `PopulateDropDataFromPasteboard` [V].
- **Qué pasa:** d11d785b arregló el *origen* (`web_drag_source_mac.mm`), pero no este *destino*. En 10.14
  `[UTType typeWithIdentifier:]` da nil, así que una imagen que llega solo como datos (desde Fotos, Vista Previa u otra app)
  no se recoge, y el `drop` de la web la recibe vacía. No se cae, porque `utType &&` corta antes de leer `UTTypeImage`
  (puntero débil NULL), pero es frágil.
- **Arreglo:**
  - En el bucle: `if (@available(macOS 11.0, *)) { …como está… } else { is_image = UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeImage); }`.
  - Para la extensión: el `else` con `UTTypeCopyPreferredTagWithClass(…, kUTTagClassFilenameExtension)` (función Copy:
    `CFToNSOwnershipCast`).
  - **El límite `kMaxDragBinarySize` y la marca `file_contents_image_accessible` quedan fuera del `if`**: el `else` no se
    salta ninguna comprobación.

### A2. Arrastrar una imagen **desde** la página (la guarda de LOCAL-19 se queda corta)
- **Dónde:** `content/app_shim_remote_cocoa/web_drag_source_mac.mm` l.150–191, 275 y 283.
- **Qué pasa:** la guarda evita la `NSInvalidArgumentException`, pero en 10.14 `_fileType` siempre es nil, y eso tiene tres
  efectos:
  - No se ofrece el sabor con los bytes de la imagen.
  - `kPasteboardTypeFilePromiseContent` devuelve nil y el Finder puede rechazar la promesa [I].
  - `hasImageData` es falso: vuelve crbug 55879 (HTML con imagen en Mail o TextEdit).
- **Arreglo:** guardar un `NSString* _fileUTI`.
  - Con `@available(11)`: `_fileType.identifier`.
  - Si no: `UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mime, nullptr)`.
  - Usarlo en l.155, 275 y 283, y en l.190 `UTTypeConformsTo(_fileUTI, kUTTypeImage)`.
  - Se mantienen `GetSafeFilenameForImageFileContents` y las comprobaciones de `_host`.

### A3. `EyeDropper` (cualquier web, con gesto del usuario)
- **Dónde:** `chrome/browser/ui/views/eye_dropper/eye_dropper_view_mac.mm` l.54–60 [V].
- **Qué pasa:** `kEyeDropper` viene activado en Mac. En 10.14 `NSColorSampler` (10.15) es nil y el manejador no se llama
  nunca, así que la promesa de `new EyeDropper().open()` **se queda colgada para siempre**. Además, el tracker de la
  pestaña queda «activo» y rechaza las llamadas siguientes.
- **Arreglo:** en `ShowEyeDropper`, `if (@available(macOS 10.15, *)) { return std::make_unique<EyeDropperViewMac>(listener); } return nullptr;`.
  Con nullptr, `EyeDropperChooserImpl::Choose` llama a `ColorSelectionCanceled()`: la promesa se rechaza bien.

### A4. «Compartir audio del sistema» en `getDisplayMedia`
- **Dónde:** `media/base/media_switches.cc` l.2004–2009 [V] y `media/audio/mac/audio_loopback_input_mac_impl.mm` l.566.
- **Qué pasa:** `IsMacSckSystemLoopbackCaptureSupported()` solo exige `< 15`, así que **en 10.14 da true** y se ofrece la
  opción de audio del sistema. Al abrirla, `+[SCShareableContent getShareableContent…]` se manda a una clase nil y el
  manejador no llega nunca: el hilo de audio queda bloqueado 5 s (`TimedWait`) y la captura falla. No se cae.
- **Arreglo:**
  1. `return (base::mac::MacOSVersion() >= 13'00'00 && base::mac::MacOSVersion() < 15'00'00) || base::FeatureList::IsEnabled(kMacSckSystemAudioLoopbackOverride);`.
     Las APIs de audio de SCK son de 13.0, así que en 10.14 no se ofrece y `getDisplayMedia` sigue con vídeo y con el
     permiso de siempre.
  2. Como defensa, en `CreateSCKAudioInputStream`: `if (@available(macOS 13.0, *)) {…} return nullptr;`. Sus llamadores ya
     aceptan nullptr, y es lo que promete el comentario del `.h`.
  - Ojo: con (1) el *override* de pruebas aún puede pedirlo en 10.14. Por eso (2) también hace falta.

## B que conviene blindar (no bloquean)

| Fichero | Riesgo | Propuesta |
|---|---|---|
| `ui/accessibility/platform/ax_platform_node_cocoa.mm` `AXHelp` l.2416–2427 [V] | La guarda de LOCAL-19 en `accessibilityCustomContent` evita la caída, pero `AXHelp` sigue devolviendo nil si la descripción viene de ARIA. **VoiceOver en 10.14 pierde `aria-description`/`aria-describedby`.** Es accesibilidad: casi A para quien usa VoiceOver. | Dentro de `if ([self descriptionIsFromAriaDescription])`: `if (@available(macOS 11, *)) { …lógica actual… } else { return [self getStringAttribute:kDescription]; }` |
| `chrome/browser/enterprise/.../secure_enclave_client_impl.mm` l.81 | `kSecUseDataProtectionKeychain` (NULL) como clave de `@{}`: **caída** si un Mojave gestionado activa Device Trust Connector (DTC). Es el único uso de esa constante que quedó sin guarda. | Diccionario mutable, y añadir la clave solo con `@available(macOS 10.15, *)` |
| `device/gamepad/game_controller_data_fetcher_mac.mm` l.139, 245 y 281 | Protegido solo porque no se registra la factoría (8f4b6e97). Si alguien lo crea por otra vía, vuelve la caída de los mandos. | `@available(macOS 11.3, *)` en `Register/UnregisterOnMainThread` y `@available(10.15)` en l.139 |
| `media/capture/video/apple/video_capture_device_avfoundation.mm` l.481, 386 y 432 | KVO sobre `portraitEffectActive`, una clave que no existe en 10.14. Con `options:0` no debería lanzar [I]. | `@available(12.0)` a la vez en el `add` y en los dos `remove` |
| `ui/gfx/mac/io_surface.cc` l.452 | Guarda `10.15.4` para unas constantes de 11.0. Sin efecto en 10.14; en Catalina lo absorbe el `if (color_space_name)`. | Cambiar a `macOS 11` |
| Menú Servicios (`bridged_content_view.mm` y `render_widget_host_view_cocoa.mm`) | Degradación: en 10.14 el menú Servicios no ofrece texto. Las guardas de `readSelectionFromPasteboard:` sobran (no usa UTType). | Opcional: en el `else`, comparar con `NSPasteboardTypeString` |

Para la Catalina de control, sin efecto en 10.14:
- `mac_authentication_view.mm` (`LAAuthenticationView`, 12.0) podría caer en 10.15–11 con Touch ID [I].
- `extensible_enterprise_sso_entra.mm` (`setUserInterfaceEnabled:`, 12.0) podría caer en 10.15–11, solo con MDM y la
  extensión de Entra.

## Resto de B y C (comprobados)

- **Ya protegidos, con la protección verificada:**
  - `ellipsoidalAltitude` con `@available(12)`.
  - `CBManager authorization`: da `kAllowed` antes de 10.15, que no tiene permiso TCC.
  - `kSecUseDataProtectionKeychain` en `unexportable_key_apple.mm`: el proveedor es nullptr.
  - `supportedSymbologies`, `NSWindowCollectionBehaviorPrimary`, `setDefaultApplicationAtURL` y
    `LSCopyApplicationURLsForBundleIdentifier`.
  - El diálogo de ficheros, con `UTTypeCreatePreferredIdentifierForTag`.
  - `AVCapturePhotoOutput` (se llama a `OnPhotoError`) y `portraitEffect` con `@available(12)`.
  - `color_space_util.mm`, con la comprobación de símbolo débil.
- **Clase nil, sin colección ni diccionario, así que sin efecto:**
  - `SFUniversalLink`.
  - `ASWebAuthenticationSession*` (solo llega del sistema en 10.15+).
  - `ASAuthorization*` de SSO de empresa (`canPerformAuthorization` da NO).
  - `appkit_utils` (solo tras `@available(11)`).
- **Solo detrás de `@available(13.2/14.4)` o en Arm:**
  - ScreenCaptureKit (vídeo y miniaturas): en 10.14 se usa el capturador clásico.
  - WebNN CoreML: además viene apagado.
- **Solo con MDM y Okta:** `url_session_helper.mm` (`valueForHTTPHeaderField:`, 10.15). Es un selector nuevo y por tanto
  caída, pero en 10.14 no hay extensiones SSO [I].
- **C:**
  - Dawn, 11 ficheros: WebGPU forzado a apagado y Graphite cortado en 10.14 (c3865144, a336fb0b, 8ed42291).
  - Inspector de accesibilidad: `ax_transform_mac.*`, `ax_call_statement_invoker_mac.mm`, `ax_element_wrapper_mac.mm`.

## Comprobación pendiente para LOCAL [I]

`chrome/browser/BUILD.gn` (l.1584–1595), `content/browser/BUILD.gn` (l.2943) y `media/audio/BUILD.gn` (l.199 y 515)
enlazan AuthenticationServices (10.15), ScreenCaptureKit (12.3) y UniformTypeIdentifiers (11.0).
- Que la 156 arranque en 10.14 indica que el enlazador las marca como débiles.
- Conviene confirmarlo en los binarios del navegador **y de los procesos auxiliares** (sobre todo el de audio, que carga
  ScreenCaptureKit) con `otool -l … | grep -B1 -A3 LC_LOAD_WEAK_DYLIB`.
- Si alguna sale como `LC_LOAD_DYLIB`, pasarla a `weak_frameworks`.
