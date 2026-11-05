# B1d (FM.55): la 156 con ANGLE Metal en macOS 10.14, entrega de LOCAL-18

**Código.**
- src: rama `flynk-b1d` en `github.com/lamosquita-net/chromium`, hasta `a336fb0b2f`. Base: la 156.0.8078.90 de serie, padre de `95a974072b`.
- ANGLE (`2f34372aaf`) y Dawn (`31316d1c29`) no tienen fork público. Sus commits van como parches `git format-patch` **sobre la base de serie de la 156** (la del `DEPS`):
  - [`angle/`](angle/): 5 parches sobre `a66226b1d3` (`angle_revision`). `0001`–`0002` son de B1b; `0003`–`0005`, de B1d (Metal 2.1, GPU de la pantalla, cachés a 1024).
  - [`dawn/`](dawn/): 1 parche de B1b sobre `8ce9806ee5` (`dawn_revision`).
  - Comprobado: `git am` sobre la base reproduce exactamente el árbol de `2f34372aaf` y de `31316d1c29`.
  - Copia con `SHA256SUMS` en `entregas/b1-local16/parches-b1d/`.
- Lista de ficheros por subsistema: [`ficheros-156.md`](ficheros-156.md). Son 77 ficheros, todos modificados y añadidos sobre la 156. No hay ningún fichero revertido a la 150, ni nuevo, ni borrado.
- Auditoría de los 145 débiles: [`auditoria-debiles-156.md`](auditoria-debiles-156.md).

**Compilaciones.** Las dos son oficiales: `is_official_build`, sin DCHECK, ThinLTO, `mac_deployment_target` 10.14. Están en `entregas/b1-local16/`.

| zip | sha256 | contenido |
|---|---|---|
| `chromium-156-b1d-oficial-2.zip` | `ce921ec0cdf832f2a5f9b90fee3732ead242b50351ffc2224542db81002c1cfe` | **La de entrega**: todo hasta `cd334eec2a` |
| `chromium-156-b1d-oficial.zip` | `7a5a9729b3c4f37da30a142b995e0aa76b1cd71ab4e0f7dc5ec2964134a9dfa4` | La anterior, con src `87f4e8b263` más la caché persistente. Sin el aviso de obsoleto quitado y sin los débiles de prioridad 2 |

## Medidas en la 6,1 (FirePro D500, 10.14.6), frente a la 2.7.0

| prueba | 156 B1d oficial | 2.7.0 |
|---|---|---|
| MotionMark 1.3.2 **a 60 fps** | **1381,31** (1375,83 en una pasada anterior) | 566,38 |
| Multiply / Canvas Arcs / Leaves | 892 / 3440 / 995 | 336 / 1822 / 406 |
| Paths / Canvas Lines | 16508 / 19764 | 1024 / 7255 |
| Images / Design / Suits | 197 / 138 / 489 | 128 / 113 / 390 |
| Aquarium 5 000 / 10 000 / 15 000 peces | 60 / 54 / 37 | 60 / 44 / 30 |

- **El 45 fps de antes.**
  - rAF va a 60,0 fps de media (16,7 ms de mediana), tanto en reposo como animando.
  - MotionMark detecta 60 en cuanto la página está caliente. La cifra de la tabla es a 60.
  - El «45» sale **solo en la primera carga de cada sesión**. Hay un parón de 0,9 a 1,2 s y la media de 300 rAF baja a unos 48, que MotionMark redondea a 45. Pasa también con un perfil ya usado tras reiniciar.
  - La 2.7.0, con perfil nuevo, no tiene ese parón: su peor espera es de 67 ms.
  - **Causa**, según `sample` del proceso de GPU: `-[_MTLDevice newRenderPipelineStateWithDescriptor:error:]`. Es la compilación **síncrona** de pipelines Metal en ANGLE, que espera a `MTLCompilerService`.
  - **Pendiente:** compilar las pipelines en segundo plano o precalentarlas en ANGLE.
- **Una sola GPU.** Se verifica en el registro con «FlyWeb: Metal device of the main display … registryID 10000069e».
- **Dos D500** (WebGL en la segunda, con EGLDualGPURendering): Aquarium da lo mismo, 60 / 54 / 37. El límite es un hilo de CPU del proceso de GPU. Está en las ramas `flynk-b1d-dosgpu` (src `b8a4abda2f`, ANGLE `dc5ef06`) y queda **fuera de la entrega**. Titín lo quiere como optimización futura: reparto de calor y multihilo.

## Fallos encontrados y arreglados en esta tanda

1. **GpuPersistentCache tumbaba la 156 en 10.14** (`4147b70632`).
   - El fallo: el VFS de SQLite en la sandbox de GPU devuelve `SQLITE_IOERR_FSYNC` (2570). Eso se trata como `kPermanent`, `HandlePersistentCacheError()` llama a `ImmediateCrash`, el proceso de GPU se cae 6 veces y el navegador sale con «GPU process isn't usable».
   - Ahora: la caché persistente va apagada por defecto en macOS < 10.15, y se usa la caché de shaders antigua. `FLYWEB_GPU_PERSISTENT_CACHE=1` la vuelve a encender para diagnóstico.
   - Las medidas de LOCAL-16 y LOCAL-17 no lo veían porque arrancaban con `--disable-features=GpuPersistentCache`.
2. **Aviso de «macOS obsoleto»** (`IDS_MACOS_OBSOLETE`) quitado (`9e194ebb5b`).
3. **Débiles de prioridad 1**: 8 commits, de `5660e8931d` a `87f4e8b263`.
   - Vídeo: `CVBufferCopyAttachment`.
   - Cámaras: `AVCaptureDeviceType*`.
   - Abrir descargas, enlaces y relanzar: `NSWorkspaceOpenConfiguration`.
   - MIME en diálogos de fichero.
   - Iconos de descarga: `icon_loader ReadIcon`.
   - Pantalla completa: `titlebarSeparatorStyle`, `toolbarStyle` y `safeAreaInsets`.
   - `preventsCapture`, `fontWithSize:` y `requestWhenInUseAuthorization`.
4. **Débiles de prioridad 2**: 7 commits, de `fe1f0ab4ba` a `cd334eec2a`.
   - Cast e impresoras locales: `nw_browser_*` → `NSNetServiceBrowser`.
   - Navegador predeterminado: `setDefaultApplicationAtURL` → LaunchServices.
   - Web Share: `NSPreviewRepresentingActivityItem`.
   - VideoToolbox: baja latencia, SVC, QP, `ReferenceBufferCount`, HDR.
   - `CVBufferHasAttachment`.
   - Web MIDI: la ruta UMP solo en 11 o posterior.
   - Mandos: sin vibración antes de 11, por CoreHaptics y GCHaptics.
   - Copiador HDR: `CAEDRMetadata`, `setEDRMetadata:` y `preferredDevice`.
   - Notificaciones en primer plano: `…OptionAlert`.

   Quedan **b~** (degradados, sin cuelgue): `aria-description`, el audio del sistema por SCK, la vista de Touch ID en WebAuthn, `ImageCapture.takePhoto` y EyeDropper. Siguen el detalle de la auditoría.

## Humo en la 6,1 (entrega `ce921ec0…`, con la caché persistente de serie)

El navegador siguió vivo en todas las pruebas: 0 FATAL, 0 Check failed, 0 caídas del proceso de GPU. Resultado de cada una:

- **Navegación:** página segura y UA-CH «macOS 10.14.6» correctos.
- **Uso básico:** clic derecho, descarga, pantalla completa y diálogo de fichero correctos.
- **Dispositivos:** `enumerateDevices` funciona. `getUserMedia` da NotFoundError (no hay cámara) y Web MIDI da NotAllowedError (falta el permiso).
- **Web Share:** abre el selector de macOS sin colgarse. Mientras está abierto bloquea DevTools.
- **Vídeo VP9 720p:** se reproduce.
- **Sin probar:**
  - H.264 por hardware, porque la compilación de prueba no lleva códecs propietarios.
  - Cast y el navegador predeterminado, que necesitan interacción.

«Invalid mailbox» / «ProduceOverlay from a non-existent mailbox»: salen de 1 a 11 veces por sesión, al arrancar y al cerrar o navegar pestañas, y no tienen efecto visible. No bloquea.

## Regla 17 (SEGURIDAD-PORTES-17, `b1d-regla17.md`)

- **Cachés de 128 a 1024**: el parche `0003` solo cambia las dos constantes, `kMaxCachedLibraries` y `kMaxPipelines`, con un comentario. No toca `TrimCache` ni el `shared_ptr`. Después del cambio no aparece ningún «Overflowed» en MotionMark ni en Aquarium. **Pendiente:** una prueba que llene la caché por encima de 1024 y medir la memoria en la 6,1.
- **MTLDevice** (parche `0002`):
  - En macOS < 10.15 todos los EGLDisplay usan `CGDirectDisplayCopyCurrentMetalDevice(CGMainDisplayID())`. Una web no puede influir, ni siquiera con `powerPreference`. Desde 10.15 se mantiene el comportamiento de serie.
  - El dispositivo es único, así que es el mismo que el de los IOSurface.
  - El cambio de GPU en caliente (MBP con dos GPU) no está probado. El dispositivo se fija al iniciar el display y, si la pantalla cambia de GPU, se pinta con una copia entre tarjetas. Hay que probarlo en las MBP.
  - `FLYWEB_METAL_ACTIVE_GPU=1` vuelve a la elección de serie, para medidas A/B.
- **Guardas de débiles**:
  - Cada `else` llama a la API anterior equivalente: `CVBufferGetAttachment` más `CFRetain`, `devicesWithMediaType:`, `openURLs:withApplicationAtURL:…`, LaunchServices, `NSNetServiceBrowser` o la ruta MIDIPacketList.
  - O bien devuelve «no soportado»: `IsSVCSupported` falso, `ShouldUseHDRCopier` falso, sin motor háptico.
  - Ninguno se salta una validación ni deja memoria sin inicializar.
  - Los punteros que antes venían de `Copy*` se retienen igual (`FlyWebCopyAttachment`).
- **Graphite, WebGPU y Dawn**: apagados **en código** en macOS < 10.15, no con un flag.
  - `a336fb0b2f`: Graphite sigue apagado **aunque llegue `--enable-skia-graphite`**. `IsSkiaGraphiteEnabled` devuelve false antes de mirar el flag, con un aviso en el registro, y el navegador no ofrece el modo `HARDWARE_GRAPHITE` ni con `kLateGraphiteFeatureCheck`.
  - Probado en la 6,1 con `--enable-skia-graphite` (entrega `da00740d…`): `chrome://gpu` da «Skia Backend: GaneshGL» y «WebGPU: Disabled», sin caídas.
  - `gpu_finch_features.cc:591`: `IsSkiaGraphiteSupportedByDevice` devuelve false.
  - `service_utils.cc:273,336`: sin WebGPU ni Dawn.
  - `gpu_info_collector.cc:837`: sin Dawn al recoger la información.
  - `compositor_util.cc:206` y `gpu_data_manager_impl_private.cc:442`.

## Contraseñas guardadas (prueba en la 6,1, entrega `da00740d…`)

Se guarda una contraseña de prueba con `chrome.passwordsPrivate.addPassword` en `chrome://password-manager` y se pide verla (`requestPlaintextPassword(id, 'VIEW')`).

- **Lanzada desde la sesión gráfica** (`open`): se abre SecurityAgent, el diálogo de autorización de macOS, en cuanto se pide. El navegador queda esperándolo, como en Chrome. Al cerrar el navegador sin autenticar, el diálogo desaparece y la contraseña no se ha entregado.
- **Lanzada por SSH** (sin sesión gráfica): macOS responde `errAuthorizationInteractionNotAllowed` (-60007) y la petición se **rechaza**. Falla cerrada: nunca da el texto sin autenticar.
- El código es el de serie: `password_manager_util_mac::AuthenticateUser` con `AuthorizationCopyRights`. Lo único que toca B1b es la comprobación de biometría (`LAPolicy…WithBiometrics` en 10.14 en lugar de la política 4).
- Falta, si se quiere: ver el diálogo en la pantalla. `screencapture` por SSH sale en blanco en Mojave.

## Pendiente

- Parón de compilación de pipelines Metal en la primera carga (ver arriba).
- Prueba de llenado de cachés y memoria.
- Batería `pruebas-gpu.md`.
- Widevine en la 2.7.0 y la 156 (orden de COORDINACIÓN-27, 05-11 11:28).
- La causa de fondo del `fsync` del VFS en la sandbox de 10.14.
