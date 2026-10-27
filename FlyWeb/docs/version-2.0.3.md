# FlyWeb 2.0.3 — Mojave, tandas 2 y 3 de FM.42

**Estado (27-10-2026, MOTOR-24):** brave-core `nube/base-128-motor-p24` **23f2d547d9** (sobre `-p23` 17e7858669, la 2.0.2),
subida a brave-core y también como bundle (rama de softmac `nube/motor24-p24`). **Sin compilar.** `flyweb_version` 2.0.3;
LOCAL compila con `FLYWEB_BUILD_NUMBER=31`, **cuando acabe la 2.0.2, nunca en paralelo**. Inventario y motivos:
[`mojave-128.md`](mojave-128.md) (b, c, a). La tanda 1 de FM.42 ya va en la 2.0.2 (`version-2.0.2.md` §6). Sin d11 (lo
decide PUBLICACIÓN con el `codesign` de LOCAL). **c3 depende de FS.26** (regla 17, SEGURIDAD-PORTES-8): si sale «no apto»,
se revierte solo su commit. **Cambios visibles:** pocos y solo en Mojave (cuentagotas, insignia «Nuevo» de los menús,
lista de fuentes, aviso de ubicación); PUBLICACIÓN espera el sí de Titín con las capturas de LOCAL.

Un commit por punto, para revertir uno solo:

| Commit | Punto | Qué |
|---|---|---|
| ecb561f3 | — | `flyweb_version` 2.0.3 |
| 17360926 | b5 | Aviso de «ubicación del sistema» en el permiso de ubicación (Brave solo lo daba en macOS 11+) |
| 87ca88bc | b6 | Pointer Lock con `unadjustedMovement` desde 10.14 |
| 16747438 | c4 | Insignia «Nuevo» de los menús derecha en 10.14 |
| 4b97373d | c5 | Sin familias «.SF…» en las listas de fuentes |
| **4e84e03b** | **b4** | Permiso de ubicación del sistema en 10.14 (**aparte**: se quita si la prueba previa dice que no hace falta) |
| 36cdeb20 | b3 | `screen.label` con el nombre del monitor en 10.14 (camino de la 116) |
| a0770af4 | a2 | `ImageCapture.takePhoto()` en 10.14 (`AVCaptureStillImageOutput`, camino de la 116) |
| f9c785ad | b2 | API `EyeDropper` en 10.14 (cuentagotas genérico de la 116) |
| **23f2d547** | **c3** | OPFS `FileSystemSyncAccessHandle.truncate()` en 10.14 (mojom de la 116; **FS.26**) |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12.)* Todo esto es para **macOS 10.14 Mojave**: lo que la base nueva solo
hacía en 10.15 o posterior vuelve a funcionar en Mojave, con lo que Mojave tiene.

- **Cuentagotas de las webs:** las páginas que usan el cuentagotas del navegador (editores de imagen y de diseño) vuelven a
  abrir la lupa para elegir un color de la pantalla.
- **Fotos con la cámara:** las webs que hacen fotos fijas con la cámara (no vídeo) vuelven a poder hacerlas.
- **Webs con base de datos local y editores web:** las que guardan ficheros en el almacenamiento privado del navegador y
  necesitan acortarlos o alargarlos (por ejemplo, las que usan SQLite en la web) dejan de fallar.
- **Juegos en el navegador:** los que capturan el ratón pueden pedir el movimiento sin aceleración, como en macOS 10.15.
- **Varias pantallas:** las webs que colocan ventanas en varios monitores ven el nombre de cada uno.
- **Ubicación:** el aviso de permiso dice si la ubicación del Mac está activada, y el diálogo de macOS para dar permiso a
  FlyWeb sale cuando una web la pide por primera vez.
- **Detalles:** la insignia «Nuevo» de los menús ya no sale del revés, y las listas de fuentes de Ajustes no muestran
  fuentes internas del sistema (las que empiezan por un punto).

## Qué cambia (ficheros de Chromium; regla 2, anotados en FM.42)

| Punto | Ficheros (parche de bc) |
|---|---|
| b5 | solo de bc: `browser/ui/geolocation/geolocation_utils_mac.mm` |
| b6 | `content/browser/renderer_host/render_widget_host_view_mac.mm`, `components/input/web_input_event_builders_mac.mm` |
| c4 | `components/remote_cocoa/app_shim/menu_controller_cocoa_delegate_impl.mm` |
| c5 | `content/common/font_list_mac.mm` |
| b4 | `services/device/public/cpp/geolocation/system_geolocation_source_apple.{h,mm}` (el `.mm` ya tenía parche de LOCAL-8) |
| b3 | `ui/display/mac/screen_mac.mm` (ya tenía parche de LOCAL-6) |
| a2 | `media/capture/video/apple/video_capture_device_avfoundation.mm` (sustituye el corte de LOCAL-8) |
| b2 | `chrome/browser/ui/views/eye_dropper/eye_dropper_view_mac.mm`, `chrome/browser/ui/BUILD.gn` (ya tenían parche), `components/eye_dropper/BUILD.gn`, `components/eye_dropper/eye_dropper_view.h`, **nuevo** `components/eye_dropper/eye_dropper_view_mac.mm` |
| c3 | `third_party/blink/public/mojom/file/file_utilities.mojom`, `content/browser/renderer_host/file_utilities_host_impl.{h,cc}`, `third_party/blink/renderer/modules/file_system_access/file_system_access_regular_file_delegate.{h,cc}` |

Notas de cada uno:
- **b6:** upstream lo limitaba a 10.15.1 aunque su propio comentario dice que los campos de CGEvent sin aceleración funcionan
  desde 10.14. Se leen por su valor (170/171) para no usar los nombres de 10.15.1, y en 10.14, si llegan a 0 con el ratón
  moviéndose, se usa el movimiento normal (no se queda el puntero quieto).
- **c4:** en 10.13–10.14 los menús de Carbon ignoran el `flipped` de la imagen; la 116 usaba un `NSTextAttachmentCell`.
- **b4:** sin `requestWhenInUseAuthorization` (10.15) nada pedía el permiso y `SystemPermissionSettings::Request` podía
  esperar para siempre. En 10.14 se arrancan las actualizaciones de ubicación (eso saca el diálogo) y se paran al responder,
  salvo que una web esté vigilando la posición.
- **b3:** se arregla de paso un fallo de la 116: el emparejamiento de idioma nunca actualizaba el mejor resultado.
- **a2:** sustituye el `OnPhotoError` de LOCAL-8; si la salida no tiene conexión, error en vez de `DCHECK`.
- **b2:** el cuentagotas genérico (`components/eye_dropper`) solo se compilaba con Aura; ahora también en Mac, con la parte
  Mac de la 116 (monitor local de eventos, menú, nivel de ventana emergente, `NSCursor`). La pantalla se lee con el
  capturador CGDisplayStream que `content` usa antes de macOS 14 (en 10.14 no pide permiso de grabación).
- **c3:** revierte la retirada de upstream (crbug 1084565): método `SetLength` solo en Mac, `[Sync]`, con `ReportBadMessage`
  en 10.15+; en el renderer, `OnFileContentsModified` (nombre de la 128) y error limpio si la tubería se rompe. Riesgo que
  revisa FS.26: el renderer pasa un handle y el navegador hace `ftruncate` sobre él (la 116 lo aceptaba porque en 10.15+ y
  en el resto de sistemas el renderer ya puede hacerlo por sí mismo).

## Riesgos y límites (sin Mac no se ha podido probar)

- **Sin compilar**: revisado contra las cabeceras de la 128 (`base::apple::*`, `ScopedIOObject`, `ExtractBaseAddressAndLength`,
  `HeapMojoRemote`, `GetBrowserInterfaceBroker`) y los parches aplicados sobre la 128.0.6613.138 limpia, sin fallos. Pido
  `-k 0` y un punto de compilación con `enable_precompiled_headers=false` (TRAMPAS, «La Static tapa includes»).
- **b2** es el de más riesgo de compilación: activa en Mac un `static_library` que upstream solo compilaba con Aura. Si no
  compila o falla en uso, se revierte solo f9c785ad (queda como en la 2.0.2: API rechazada).
- **b6:** que los campos 170/171 den valores en 10.14.6 lo dice upstream, no está probado aquí.
- **a2** en Mac con varias cámaras o cámaras USB: la 116 tenía el mismo código.

## Pruebas para LOCAL

**Antes de compilar, con la 2.0.2 (-p23) en Mojave — b4:** en un Mac donde FlyWeb **nunca** haya pedido la ubicación
(Servicios de localización sin FlyWeb en la lista; la 6,1 sirve si no aparece; si no, el MacBook Air de Mojave), abrir
`FlyWeb/tools/mojave-203.html` y pulsar «Pedir ubicación» tras dar el permiso del sitio:
- sale el diálogo de macOS y luego llega la posición → **b4 no hace falta**: revertir 4e84e03b antes de compilar;
- se queda esperando sin diálogo (30 s) → b4 se queda.

**Con la 2.0.3, en la 6,1** (perfil temporal; `mojave-203.html` por https o `file://`; cada bloque dice qué esperar):
1. b6 Pointer Lock, b3 nombre de pantalla, a2 foto, b2 cuentagotas (clic y Esc), c3 OPFS `truncate`, b4/b5 ubicación.
2. c5: Ajustes › Aspecto › Personalizar fuentes, sin familias con «.» delante.
3. c4: si algún menú muestra la insignia «Nuevo», captura (derecha). Si no aparece ninguna, se anota y no se busca más.
4. Control en la 7,1 (macOS 15): los mismos bloques, para ver que el camino de 10.15+ no ha cambiado.
5. Capturas para Titín: cuentagotas, aviso de ubicación, lista de fuentes y, si sale, la insignia.
