# FlyWeb — Cuelgue navegador↔GPU de Chromium 128 al arrancar en Mojave (INVESTIGACIÓN-MOTOR-2, 21-10-2026)

Encargo de COORDINACIÓN-11 (FM.31 Fase 1). Solo papel, en paralelo a LOCAL-7.

**Síntoma (LOCAL-7):** en la 6,1, con los parches de Dawn y de `color_space_util`, el hilo principal del navegador se
queda en `cc::Scheduler` → `ClientResourceProvider::PrepareSendToParent` → `VerifySyncTokens` →
`GpuChannelHost::VerifyFlush`. El proceso GPU está en reposo: el `Flush` se contesta en su hilo de E/S, pero la
respuesta no llega. Pasa siempre con `open -j` y a veces con ventana. **No cambia** con ANGLE GL/Metal,
`CVDisplayLinkBeginFrameSource`, `UseGpuSchedulerDfs` ni `MojoIpcz`. **No pasa** con `--disable-gpu-compositing`.

**Método:** comparé los árboles de Chromium **116.0.5845.188**, **127.0.6494.0** y **128.0.6613.138** con
`blueboxd/chromium-legacy` (tag `1303823`, misma base que la 127.0.6494.0). Rutas: `ui/accelerated_widget_mac`,
`ui/display/mac`, `ui/gl`, `components/viz/{service,common}`, `gpu/ipc`, `gpu/command_buffer/service`,
`base/{message_loop,synchronization,process}` y `mojo/core`. Etiquetas: **[V]** visto en el código, **[H]** hipótesis.
No encontré incidencias públicas de Legacy sobre este cuelgue: GitHub las devuelve 403 desde la nube y la búsqueda web
no da nada.

## Hipótesis, de más a menos probable

### H1 — `CVDisplayLink` nuevo en el proceso GPU para las marcas de tiempo de presentación (probabilidad alta)

- **[V]** En la 116, `ImageTransportSurfaceOverlayMac` y `SkiaOutputSurfaceImplOnGpu` solo llamaban a
  `SetVSyncDisplayID` si `features::UseGpuVsync()`. En Apple, `kGpuVsync` está **desactivada por defecto**
  (`ui/gl/gl_features.cc`), así que el proceso GPU **nunca creaba un `CVDisplayLink`**.
- **[V]** En la 127 y la 128, `skia_output_surface_impl_on_gpu.cc` llama a `presenter_->SetVSyncDisplayID()` **sin
  condición** en Mac. `ImageTransportSurfaceOverlayMacEGL::SetVSyncDisplayID` crea entonces
  `ui::DisplayLinkMac::GetForDisplay(display_id)`, porque **`NewPresentationFeedbackTimeStamps` está activada por
  defecto**. En cada `Present()` registra un callback de vsync (`OnVSyncPresentation`), y las marcas de presentación
  pasan a depender de que el `CVDisplayLink` dé señal (en el hilo de la GPU).
- **[V] Chromium Legacy deshace justo eso:** en sus dos llamadas vuelve a poner `if (features::UseGpuVsync())`. Por
  defecto, Legacy 127 **no crea el `CVDisplayLink` en el GPU**, y es el Chromium 127 que funciona en la 6,1 (prueba de
  Titín del 20-10, con ventana).
- **[H] Mecanismo:** con la app oculta (`open -j`), o antes de que haya una ventana en pantalla, el `CVDisplayLink` del
  GPU en 10.14 no da señal o se queda parado. Las respuestas de presentación al navegador no llegan, y `cc` del
  navegador acaba esperando en la sincronización de recursos. Encaja con «siempre oculto, a veces con ventana» y con
  que `--disable-gpu-compositing` lo evite. `CVDisplayLinkBeginFrameSource` es otro `CVDisplayLink` (el de las
  BeginFrame de viz), y por eso apagarlo no cambió nada.
- **Prueba (10 min):** `--disable-features=NewPresentationFeedbackTimeStamps`. Con eso, `SetVSyncDisplayID` sale sin
  crear el display link: el mismo comportamiento que la 116 y Legacy. Diez arranques con `open -j` y diez con ventana.
  Si deja de colgarse: **arreglo** = el hunk de Legacy en `skia_output_surface_impl_on_gpu.cc` (2 condiciones, BSD-3),
  o apagar esa función por defecto en nuestra compilación. Esto es 0,5–1 h [H].
- **Prueba de refuerzo:** `--enable-features=VSyncAlignedPresent` debería empeorarlo, porque retrasa también el commit
  a CA hasta el vsync [H].

### H2 — La respuesta síncrona no se entrega en el navegador (diagnóstico; probabilidad media)

- **[V]** En la 128, `GpuChannelHost::VerifyFlush` hace la llamada síncrona `Flush()` con `context_lock_` cogido, y
  **siempre** cuando `ConditionallySkipGpuChannelFlush` y `SyncPointGraphValidation` están apagadas (por defecto).
  La 116 se la saltaba si el id ya estaba verificado (`verified_deferred_message_id_`). Hay más llamadas síncronas
  que en la 116.
- **[V] Descartado como causa de Mojave:**
  - `ChannelMac` (Mojo): sin cambio de fondo entre la 116 y la 128.
  - `MessagePumpKqueue`: igual; `TimerSlackMac` y `BatchNativeEventsInMessagePumpKqueue` vienen apagadas.
  - `WaitableEvent` de Apple: igual.

  Lo que Legacy cambia ahí (conjuntos de puertos, `dispatch`, temporizadores) es para 10.13 o anteriores. Que pase
  igual con y sin ipcz encaja: los dos van sobre `ChannelMac`.
- **Pruebas (10 min):**
  1. Durante el cuelgue, `sample <pid navegador> 5` y `sample <pid GPU> 5`: mirar **`Chrome_IOThread`** del navegador.
     Si está bloqueado en un cerrojo, es un interbloqueo de orden de cerrojos y no de API de macOS. También
     `lsmp -p <pid navegador>`: si hay mensajes encolados en el puerto de la respuesta, el hilo de E/S no lo vacía.
  2. `--enable-features=SyncPointGraphValidation`: `VerifyFlush` vuelve sin IPC síncrona. Si el cuelgue se va a otra
     llamada síncrona, el fallo es de entrega de respuestas en general. Si desaparece, encaja con H1 o con la propia
     verificación.
  3. `--enable-features=ConditionallySkipGpuChannelFlush`: el mismo diagnóstico, por memoria compartida.

### H3 — Papel y QoS de los procesos, nuevo por defecto (probabilidad media-baja)

- **[V]** `kMacSetDefaultTaskRole` pasa de **desactivada** (116) a **activada** (128). Cada proceso se pone
  `TASK_FOREGROUND_APPLICATION` y QoS de nivel 0. `Process::SetPriority` aplica además una `TASK_SUPPRESSION_POLICY`
  privada (una estructura del núcleo copiada a mano). **[H]** Encaja con el patrón «oculto sí, con ventana a veces»
  (App Nap y el papel de la app oculta en Mojave).
- **Prueba (10 min):** `--disable-features=MacSetDefaultTaskRole`. Aparte,
  `defaults write <bundle id> NSAppSleepDisabled -bool YES` y lanzar con `open -j`.

### H4 — Cerrojo de `SharedImageInterfaceProvider` (probabilidad baja)

- **[V]** Legacy quita el `context_lock_` que la 127/128 añadió a
  `components/viz/service/frame_sinks/shared_image_interface_provider.{h,cc}`, con la misma base. Puede ser una reversión
  a propósito o un fallo al fusionar. Esto bloquea hilos **del proceso GPU** (compositor ↔ principal), y LOCAL lo ve en
  reposo: poco probable.
- **Prueba:** solo si el `sample` de H2 enseña el hilo compositor del GPU esperando en `CreateSharedImageInterface`.

## Control de versión de macOS

La misma compilación en el **Mac mini 2012 o el MacBook Pro 2012 con Catalina** (control 10.15, `CLAUDE.md`):
- si allí no se cuelga, es de API de 10.15 (refuerza H1, por el `CVDisplayLink`);
- si también se cuelga, es de Chromium 128 y no de Mojave.

## Orden propuesto para LOCAL-7

1. H1, `--disable-features=NewPresentationFeedbackTimeStamps`: la más barata y la más probable.
2. H2.1, `sample` + `lsmp` del cuelgue tal cual.
3. H2.2 y H3: interruptores, uno cada vez.
4. Control en Catalina cuando haya máquina.

## Fuentes

- Chromium `116.0.5845.188`, `127.0.6494.0` y `128.0.6613.138` (espejo `github.com/chromium/chromium`):
  - `components/viz/service/display_embedder/skia_output_surface_impl_on_gpu.cc`;
  - `gpu/ipc/service/image_transport_surface_overlay_mac.mm` (`SetVSyncDisplayID`, `kNewPresentationFeedbackTimeStamps`);
  - `ui/gl/gl_features.cc` (`kGpuVsync`, apagada en Apple);
  - `components/viz/common/features.cc` (`kVSyncAlignedPresent`);
  - `gpu/ipc/client/gpu_channel_host.cc`, `gpu/config/gpu_finch_features.cc`;
  - `base/process/process_mac.cc`;
  - `base/message_loop/message_pump_kqueue.cc`, `base/synchronization/waitable_event_apple.cc`, `mojo/core/channel_mac.cc`.
- `blueboxd/chromium-legacy` tag `1303823` (commit `9938ec72`, 30-05-2024): los mismos ficheros y
  `components/viz/service/frame_sinks/shared_image_interface_provider.{h,cc}`.
- Proyecto: fila FM.31 de `docs/TAREAS.md` (síntoma, 21-10), `FlyWeb/docs/chromium-legacy.md`.
