# FlyWeb 3.1.1: arranque y GPU en Catalina (10.15)

MOTOR-45, 12-11-2026, por encargo de COORDINACIÓN-40. **Nada compilado.** Lo que sí se ha ejecutado:
- el cruce de símbolos con los `.tbd` del SDK 10.15 (copia pública de los SDK de Apple) y las cabeceras del SDK 26.5;
- `git am` de los parches;
- la prueba del guion `comprobar-importes-1015.py` con `nm`/`otool` simulados.

**Base:** chromium, fork `lamosquita-net/chromium`, `seg/3.0.2` **502e3c5b85** (ls-remote; es el src de la 3.1.0). Los 4
parches entran limpios con `git am`; árbol `35d2c99d7b`. También entran limpios sobre `seg/3.0.1` c4b1caf806.
brave-core `local/3.1` (`fc9389773fe`) no necesita cambios (ver la auditoría).

## El fallo

```
dyld: lazy symbol binding failed: Symbol not found: _CGPreflightScreenCaptureAccess
  Referenced from: …/FlyWeb Framework.framework/Versions/156.1.98.63/FlyWeb Framework
  Expected in: /System/Library/Frameworks/CoreGraphics.framework/Versions/A/CoreGraphics
```

**Por qué.**
- Las cabeceras actuales declaran `CGPreflightScreenCaptureAccess()` y `CGRequestScreenCaptureAccess()` como
  `API_AVAILABLE(macos(10.15))`, pero CoreGraphics solo las exporta desde macOS 11:
  - no están en el `CoreGraphics.tbd` del SDK 10.15 (tampoco en su `CGWindow.h`);
  - sí están en el del SDK 11.0.
- Chromium 116, que aún soportaba Catalina, las llamaba con `@available(macOS 11.0, *)` y tenía una vía propia para 10.15.
  B1b (`95a97407`) las guardó con 10.15.

**Quién las llama al arrancar.** Las dos llamadas pasan por `ui::IsScreenCaptureAllowed()`:
- `ChromeBrowserMainPartsMac` → `ui::WarmScreenCapture()` (`chrome_browser_main_mac.mm:128`). En 10.15,
  `ShouldWarmScreenCapture()` devuelve true (es < 14), y una tarea del grupo de hilos llama a `IsScreenCaptureAllowed()`
  → `CGPreflightScreenCaptureAccess()`.
- La estadística de permisos (`base-128.md`, fila 8): `LogSystemMediaPermissionsStartupStats()` →
  `CheckSystemScreenCapturePermission()` → `IsScreenCaptureAllowed()`.

En Mojave no pasa porque las guardas cortan antes de llegar a la llamada; por eso la 6,1 y la 5,1 van bien.

### Perezoso, no débil

El mensaje dice que, en el binario de la 3.1.0, la referencia a ese símbolo es **fuerte**:
- Chromium enlaza en Mac con su `lld`. `lld` solo marca un símbolo como débil (también en el enlace perezoso,
  `LazyBindingSection::encode`) si **todas** las referencias a él son débiles (`refState = max(...)`).
- Con una referencia débil, dyld habría puesto NULL y el cuelgue habría sido un `EXC_BAD_ACCESS` en 0x0, no este mensaje.

Pero la auditoría B1d (`auditoria-debiles-156.md`) lo tenía en su lista de las 145 importaciones **débiles**. Esa lista
salió de un binario de medida, no de la Release oficial con PGO y ThinLTO. No puedo saber, sin el binario, dónde deja de
ser débil.

**Para el arreglo da igual:** si una función no existe en el sistema, llamarla cuelga igual con referencia débil (salto a
NULL) que con fuerte (aborto de dyld). Lo que falla es la guarda.

**Para saber cómo está cada símbolo,** `comprobar-importes-1015.py` (abajo) lo dice en un minuto con el binario de la 3.1.0.

## Los parches

| Parche | Qué | Efecto en Catalina sin él |
|---|---|---|
| `0001` `ui/base/cocoa/permissions_utils.mm` | `CGPreflight/CGRequestScreenCaptureAccess` con `@available(macOS 11.0, *)`; vuelven las vías de 10.15 de la 116 | **no arranca** |
| `0002` `media/base/mac/color_space_util_mac.mm` | `CVBufferCopyAttachment` con `@available(macOS 12.0, *)` (B1d puso 10.15; la cabecera dice 12.0 y no está en el CoreVideo de 10.15) | cuelga el primer fotograma de vídeo por hardware (YouTube) y el de la cámara (también en Big Sur) |
| `0003` `ui/gfx/mac/io_surface.cc` | `kCGColorSpaceITUR_2100_PQ/HLG` con macOS 11 (B1b puso 10.15.4; la cabecera dice 11.0, y la 116 usaba 11.0) | cuelga con contenido BT.2020 PQ/HLG por IOSurface (10.15.4–10.15.7) |
| `0004` `IsMacOSBelow10_15()` → `IsMacOSBelow11()` (7 ficheros de `gpu/`, `content/browser/gpu/`, `chrome/`) | Graphite, WebGPU, la enumeración de Dawn y la caché persistente de GPU, apagados también en 10.15 | el proceso de GPU cae en cuanto Dawn enumera adaptadores (selectores de macOS 11 sin guarda) |

### Detalle de 0001

En 10.15 vuelve el código de Chromium 116:
- `IsScreenCaptureAllowed()`: hay permiso si se ve el nombre de alguna ventana normal o del Dock de otro proceso.
- `TryPromptUserForScreenCapture()`: crea un `CGDisplayStream` de 1×1. Si la app no está en la lista de Preferencias,
  macOS saca el aviso; si se deniega, la creación falla.

`CGDisplayStreamCreate` lleva `SCREEN_CAPTURE_OBSOLETE(10.8,14.0,15.0)`, igual que `CGWindowListCreateImage`, que el
mismo fichero ya compila. Con objetivo 10.14 solo da un aviso de obsoleto, silenciado con `#pragma`. En 10.14 nada cambia.

### Detalle de 0004

**Por qué macOS 11.** El Dawn de esta base ya no guarda sus llamadas de macOS 11. Comprobado en upstream (etiqueta
`v20260921`, la más cercana a la rama 8078; la rama local `flynk-b1b`, `31316d1c`, no es pública):
- `PhysicalDeviceMTL.mm:637`: `-supportsBCTextureCompression`, sin guarda en macOS;
- `UtilsMetal.mm:977-987`: `-supportsCounterSampling:`;
- `CommandBufferMTL.mm`: `MTLComputePassDescriptor` y `MTLBlitPassDescriptor`.

Todos son `API_AVAILABLE(macos(11.0))` en el SDK 26.5.

**Qué cambia en Catalina.** Pasa a la configuración probada en Mojave:
- Ganesh sobre ANGLE Metal, con el modo GL por hardware;
- sin Graphite;
- sin WebGPU (ya fuera de la 3.x por decisión de Titín);
- sin Dawn;
- con la caché de shaders antigua.

En 10.14 nada cambia.

## Auditoría de 10.15

**Método.**
- Un símbolo que falta en 10.15 también falta en 10.14. Por eso, el código de upstream sin guarda ya está en la
  auditoría de 10.14 (sus filas **b** cuelgan igual en las dos).
- Lo propio de Catalina son los caminos que **nuestras** guardas abren en 10.15 y cierran en 10.14:
  `@available(macOS 10.15…)`, `MacOSVersion() >= 10'15'00`, `IsMacOSBelow10_15()`…
- He sacado todas las de B1b/B1d (diff `23b0e24a..502e3c5b85` del fork: 30 sitios) y de brave-core `local/3.1`
  (10 ficheros).
- Cada API que se usa dentro la he contrastado con los `.tbd` del SDK 10.15. Están incluidas las bibliotecas
  reexportadas: `libnetwork`, las subbibliotecas de CoreServices y ApplicationServices, y las de `libSystem`.

| Sitio | API | En 10.15 | Estado |
|---|---|---|---|
| `permissions_utils.mm` | `CGPreflight/CGRequestScreenCaptureAccess` | **no** (11.0) | **0001** |
| `color_space_util_mac.mm` | `CVBufferCopyAttachment` | **no** (12.0) | **0002** |
| `io_surface.cc` | `kCGColorSpaceITUR_2100_PQ/HLG` | **no** (11.0) | **0003** |
| `IsMacOSBelow10_15()` (Graphite, WebGPU, Dawn, caché) | selectores Metal 11 en Dawn | **no** | **0004** |
| `launch_application.mm`, `mac_util.mm`, `platform_util_mac.mm` | `NSWorkspaceOpenConfiguration` y `openURL(s):…configuration:` | sí | bien |
| `launch_mac.cc` | `posix_spawn_file_actions_addchdir_np` (`posix_spawnattr_set_csm_np` va con 11) | sí | bien |
| `service_discovery_client_mac.mm` | `nw_browse_*`, `nw_browser_*` (en `libnetwork`) | sí | bien |
| `eye_dropper_view_mac.mm` | `NSColorSampler` | sí | bien |
| `hdr_copier_layer.mm` | `CAEDRMetadata HDR10Metadata…`, `EDRMetadata`, `preferredDevice` | sí | bien |
| `screen_mac.mm` | `localizedName`, `maximumPotentialExtendedDynamicRangeColorComponentValue` | sí | bien |
| `gpu_info_collector_mac.mm` | `supportsFamily:`, `MTLGPUFamilyMac2` | sí | bien |
| `video_capture_device_avfoundation(_helpers).mm` | `AVCaptureDeviceDiscoverySession`, `AVCaptureDeviceType{BuiltInWideAngle,ExternalUnknown}`, `AVCapturePhotoOutput`, `photoSettingsWithFormat:`, `fileDataRepresentation` | sí | bien |
| `system_geolocation_source_apple.mm`, `bluetooth_adapter_mac_permission.mm` | `requestWhenInUseAuthorization`, `+[CBManager authorization]` | sí | bien |
| `secure_enclave_client_impl.mm` | `kSecUseDataProtectionKeychain` | sí | bien (además, el Secure Enclave no se usa) |
| `media_keys_listener_mac.mm` | `IOHIDCheckAccess` | sí | bien |
| brave-core: `game_controller_data_fetcher_mac` (`productCategory`), `mac_intent_picker_helpers` (`SFUniversalLink`), `menu_controller_cocoa_delegate_impl`, `gpu_mojo_media_client_mac` (xHE-AAC), `web_input_event_builders_mac`, `text_recognition.mm` (Vision 10.15; lo de 13 va guardado), `platform_thread_apple`, `file_utilities_host_impl`, `render_view_context_menu` | APIs de 10.15 o ninguna | sí | bien |

**Lo que no he podido auditar,** porque no es público:
- las ramas locales de ANGLE (`flynk-b1d`) y de Dawn (`flynk-b1b`);
- los selectores ObjC: no son importes, y el guion no los ve.

Con 0004, Dawn no se ejecuta antes de 11. Para ANGLE, en la 7,1 (`chromium/8078` es la referencia de upstream sobre la
que se rebasó `flynk-b1d`, commit `9da2d916` del fork; si en el clon local se llama de otra forma, usad esa):

```
git -C ~/proyectos/flyweb-build/src/third_party/angle log -p chromium/8078..flynk-b1d | \
  grep -nE "available\(macOS 10\.15|10\.15\)|__MAC_10_15"
```

Cada API dentro de esas guardas tiene que existir en 10.15. Si sale algo, me lo pasáis.

**Guion para el binario:** `comprobar-importes-1015.py <FlyWeb Framework> [<MacOSX10.15.sdk>]`.
- Necesita `python3`, `nm` y `otool`. El SDK 10.15 está en la 6,1 (Xcode 11.3.1).
- Lista los importes del sistema que no existen en 10.15 y dice si son débiles o FUERTES.
- Con la 3.1.0 debería salir `_CGPreflightScreenCaptureAccess` como FUERTE. Con eso se cierra la pregunta del enlace
  perezoso.
- Con la 3.1.1, cualquier FUERTE de la lista es un fallo de enlace seguro si se llama: hay que mirar su guarda.

## ¿La 3.0.x también?

**Sí.** Las cuatro guardas vienen de B1b (`95a97407`) y B1d (`5660e893`, `c3865144`, `a336fb0b`). Todos esos commits están
en `seg/3.0.1` (c4b1caf806, ls-remote), así que la 3.0.0, la 3.0.1 y la 3.1.0 tienen el mismo fallo en Catalina.

La 2.x (base 128) probablemente no [I]: Chromium 128 aún soportaba 10.15 y llevaba el código de la 116. No lo he
comprobado.

## Cómo probarlo en las Mac de Catalina

**Máquinas:**
- Mac mini 2012 (Intel HD 4000);
- MacBook Pro 15" 2012 (GeForce GT 650M + Intel HD 4000). Probar con las dos GPU:
  - «Cambio automático de gráficos» activado, para la Intel en reposo;
  - y desactivado, para la NVIDIA siempre.

Con la 3.1.1 instalada y un perfil nuevo:

1. **Arranque:** lanzarla desde Terminal (`/Applications/FlyWeb.app/Contents/MacOS/FlyWeb`). Sin `dyld: …` ni
   cuelgue, y la ventana abre.
2. **`flyweb://gpu`:** «Skia Backend» Ganesh (no Graphite), WebGPU apagado y aceleración por hardware activa. En el
   MacBook Pro, la GPU activa tiene que corresponder al modo elegido.
3. **Vídeo por hardware (0002):** YouTube H.264 1080p, 2–3 min; en `flyweb://media-internals`, decodificador
   `VideoToolboxVideoDecoder`. Sin cuelgue ni pantalla negra.
4. **Cámara (0002):** solo en el MacBook Pro (el mini no tiene). Una página con `getUserMedia({video:true})` mostrando
   el vídeo 30 s.
5. **Captura de pantalla (0001):** una página con `navigator.mediaDevices.getDisplayMedia()`.
   - La primera vez sale el aviso de «Grabación de pantalla» del sistema.
   - Tras permitirlo en Preferencias y reiniciar FlyWeb, la captura funciona.
   - Si se deniega, la página recibe el error, sin cuelgue.
6. **HDR (0003), si se puede:** un vídeo BT.2020 PQ (las pruebas HDR de YouTube). En estas Mac se ve como SDR; basta
   con que no cuelgue.
7. **WebGL y Aquarium:** con las dos GPU del MacBook Pro y en el mini, y claude.ai (criterio de aceptación).
8. **Binario:** `comprobar-importes-1015.py` sobre el framework de la 3.1.1.
9. **Mojave (6,1):** la batería de siempre (`funcional.js`, texturas, Aquarium). Ningún parche cambia lo que hace 10.14.

Lo que no funciona en 10.15 por diseño (igual que en 10.14): Graphite, WebGPU y la caché persistente de GPU.
