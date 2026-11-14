# Respaldo GL (`3.1.2-gl-reserva` 0001–0005): resultados de la preliminar

De LOCAL-19 a ARQUITECTURA (copia a COORDINACIÓN-42, para SEGURIDAD-PORTES). Solo datos.
Preliminar: 3.1.1 (198.63.44) + parches 0001–0005, sin firmar, sin publicar, versión sin cambiar. No se ha tocado el sandbox.
Datos completos (capturas, `chrome://gpu`, salida de error, registros) en la carpeta de entregas de LOCAL-19:
`gl/pre61` (MacPro6,1) y `julia/{glpre,glpre650,video650b,gc2c}` (MacBookPro9,1).

## A y B. MacPro6,1 (Mojave 10.14.6, FirePro D500, GPUFamily2)

| | A: sin indicadores | B: `--use-angle=gl` |
|---|---|---|
| implementación | (gl=egl-angle,angle=metal), igual que la 3.1.1 | (gl=egl-angle,angle=opengl), OpenGL 4.1 ATI-2.11.26 |
| WebGL 1 / 2, composición | sí / sí, GPU | sí / sí, GPU (GaneshGL, Sandboxed: true) |
| Aquarium 1000 / 10000 | 60,0 / 59,9 fps | 60,0 / 46,4 fps |
| YouTube H.264 (VideoToolbox) | 0 de 242 fotogramas perdidos | 0 de 523 |

Metal sigue siendo el camino por defecto en la 6,1 (la reserva GL no se activa).

## C. MacBookPro9,1 (Catalina 10.15.8, HD 4000 + GT 650M, GPUFamily1)

Sin indicadores la preliminar elige **angle=opengl sola** (Metal rechazado por ANGLE, como estaba previsto).

| | WebGL | Aquarium 1000 / 5000 / 15000 | MotionMark 1.3.2 |
|---|---|---|---|
| Safari de Catalina | sí | 59,7 / 43,0 / 16,1 | — |
| 2.7.0 (128, ANGLE GL, HD 4000) | 1 y 2 | 59,9 / 51,3 / 26,1 | 507 |
| 3.1.1 publicada (sin GPU) | no | — | 733 |
| **preliminar, HD 4000** (cambio automático activo) | **1 y 2** | **59,8 / 59,6 / 27,4** | **731** |
| **preliminar, GT 650M** (cambio automático desmarcado) | **1 y 2** | **60,0 / 60,0 / 36,6** | **698** |

- Con el cambio automático activo arranca en la Intel (`force_low_power_gpu` de la lista de controladores).
- MotionMark queda igual que la 3.1.1 por software (733): en este Mac la composición por GPU no gana a Skia por CPU,
  pero tampoco pierde; las pruebas de canvas suben (HD 4000: Canvas Arcs 1381, Canvas Lines 10141).
- Vídeo (GT 650M): YouTube eligió **H.264 con `VideoToolboxVideoDecoder`** (`kIsPlatformVideoDecoder true`),
  8 de 2152 fotogramas perdidos; MP4 H.264 1080p de prueba: 23 de 648 (al arrancar), CPU del renderer 3–11 %.

## G-C2 (pedidas por SEGURIDAD), con Titín delante, en el MacBookPro9,1

Aquarium 1000 (WebGL activo) y YouTube abiertos en ventanas propias; muestreo cada 5 s (fps, `webglcontextlost` /
`webglcontextrestored`, vídeo) y cada 30 s `chrome://gpu` (GPU activa, «GPU process crash count»).

| prueba | resultado |
|---|---|
| cambio de GPU en caliente (Intel → NVIDIA al desmarcar el cambio automático, 11:29) | sin pérdida de contexto, 60 fps sin cortes, vídeo sigue; FlyWeb conserva su contexto en la Intel (pantalla en la NVIDIA) |
| dormir y despertar (11:31, menos de un minuto) | sin pérdida de contexto, 60 fps al despertar, vídeo se reanuda, sigue en Intel por OpenGL |
| monitor externo | **NO PROBADO** (sin adaptador); queda pendiente |
| caídas | 0 en todas las tandas: «GPU process crash count: 0», 0 informes en DiagnosticReports, 0 minidumps |

Nota: con FlyWeb arrancada en la NVIDIA, volver a marcar el cambio automático no devuelve el sistema a la Intel
(macOS no quita la discreta a una app que la usa; igual que con la 2.7.0). No es un fallo.

## Salida de error (todas las tandas, 6,1 y MacBookPro9,1)

- **0** «eglBindTexImage requires 2D», **0** «uninitialized SharedImage», **0** BeginRasterCHROMIUM fallido.
- **0** pérdidas de contexto o de dispositivo (no hacían falta `prepareForCall` ni `testDeviceLost`).
- Registro del sandbox (`sender=="Sandbox"`, 6,1): 0 denegaciones con Metal y con GL.
- Solo avisos: `eglQueryDeviceAttribEXT: Bad attribute` (4–13 por sesión), `ProduceOverlay ... non-existent mailbox`
  e `Invalid mailbox` (2–4, al cerrar pestañas), `Unable to get gpu adapter` (WebGPU, desactivado por lista).
  Los mismos con Metal en la 6,1 salvo el de EGL.

## Pendiente

- Monitor externo en el MacBookPro9,1 (falta adaptador).
- Prueba D (Air de 2013, mini de 2012), si Titín puede.
- Vídeo con la HD 4000 por separado (solo se midió con la GT 650M; en la 6,1, VideoToolbox con GL y con Metal).
