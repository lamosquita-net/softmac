# T10 → flynk-b1d (MOTOR-35, 06-11-2026)

Parches de Mojave de la capa propia de FlyWeb (§12.13.2 de `brave-propio.md`) que tocan ficheros que
`lamosquita-net/chromium` `flynk-b1d` ya modifica. Por decisión de COORDINACIÓN-29 (06-11), la capa de Mojave de
Chromium vive solo en `flynk-b1d`: se sacan de brave-core `patches/` (commit c2106b81 de `nube/b2-porte-t10`) y LOCAL
los mete como commits en `flynk-b1d`. Todos aplican con `git apply` sobre los ficheros de `flynk-b1d`; los tres
marcados con * solo aplican ahí (no sobre la 156 pelada).

| Parche | Qué deja (lo que `flynk-b1d` aún no hace) |
|---|---|
| `base-mac-launch_application.mm.patch` * | `prompt_user_if_needed` → `NSWorkspaceLaunchWithErrorPresentation` en 10.14 |
| `base-process-launch_mac.cc.patch` | cwd por hilo en 10.14, como en la 116 (sin `posix_spawn_file_actions_addchdir_np`) |
| `chrome-browser-device_reauth-mac-authenticator_mac.mm.patch` * | sin Touch ID en ningún Mac (decisión FlyWeb) |
| `crypto-apple-unexportable_key_apple.mm.patch` * | proveedor de claves no exportables nulo en Mac (sin Secure Enclave; sustituye a 3 parches de la 128) |
| `media-capture-video-apple-video_capture_device_avfoundation.mm.patch` | fotos con `AVCaptureStillImageOutput` en 10.14 |
| `services-device-public-cpp-geolocation-system_geolocation_source_apple.{h,mm}.patch` | FM.42 b4: arrancar actualizaciones para que 10.14 muestre su diálogo y pararlas al responder (el .h va con el .mm) |
| `ui-base-cocoa-permissions_utils.mm.patch` | no «calentar» permisos antes de 10.15 |
| `ui-display-mac-screen_mac.mm.patch` | FM.42 b3: nombres de pantalla por IOKit en 10.14 |

Al meterlos en `flynk-b1d`, marcar con «// FlyWeb B1d» como el resto de esa rama.
