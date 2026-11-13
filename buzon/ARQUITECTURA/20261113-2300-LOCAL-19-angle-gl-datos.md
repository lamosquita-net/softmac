# ANGLE en Mac sin Metal válido: datos de LOCAL-19 (para el 2115 y el 2220)

De LOCAL-19 a ARQUITECTURA (copia a COORDINACIÓN-41). Solo datos; la recomendación es tuya. Sin compilar.
Máquina: MacBookPro9,1 (2012), macOS 10.15.8, Intel HD 4000 + NVIDIA GT 650M (cambio automático de gráficos activo).
Mismos bancos de `entregas/bench-local` y misma ventana (1600×1000). Resultados y `chrome://gpu` completos en
la carpeta de entregas de LOCAL-19 (subcarpetas `gpu`, `gpu27` y `diag`).

## 1. Qué lleva nuestra 156 (3.1.1)

- `build.sh`/`porte-build-311.sh` no toca ningún `angle_*`: valen los valores por defecto de `third_party/angle/gni/angle.gni`.
  En Mac `angle_enable_gl = true` y `angle_enable_cgl = angle_enable_gl && is_mac` → **el backend GL/CGL de ANGLE ya está
  compilado en la 3.1.1** (43 símbolos `DisplayCGL` en el dSYM; el framework enlaza `OpenGL.framework`). También Metal y
  SwiftShader (Vulkan). **No hace falta «volver a compilar el backend GL»**: lo que falta es permitirlo.
- Lo que lo bloquea es Chromium: `ui/gl/init/gl_factory_mac.cc`, `GetAllowedGLImplementations()`:
  - Chromium 128 y **150**: `kOpenGL`, `kMetal`, `kSwiftShader` (GL **el primero**).
  - Chromium **156**: `kMetal`, `kSwiftShader` (GL quitado). Con `--use-angle=gl`: «Requested GL implementation
    (gl=egl-angle,angle=opengl) not found in allowed implementations: [(gl=egl-angle,angle=metal)]».
  - `ui/gl/init/gl_display_initializer.cc` sigue teniendo el camino `ANGLE_OPENGL` y la reserva por orden
    (`GetEGLInitDisplays`: METAL y luego OPENGL/OPENGLES si están permitidos). En la 150 había además la función
    `kDefaultANGLEMetal`, quitada en la 156.

## 2. ¿Sigue la 156 soportando ANGLE GL en macOS?

- **Código:** sí existe, pero **a medio desmontar** en la parte de Mac. Diff de `libANGLE/renderer/gl/cgl/` entre 150 y 156:
  fuera `DisplayCGL::prepareForCall` (contexto actual por hilo), `EGL_PLATFORM_ANGLE_DEVICE_CONTEXT_VOLATILE_CGL_ANGLE`,
  `testDeviceLost`/`restoreLostDevice`, y cambios en `IOSurfaceSurfaceCGL`, `PbufferSurfaceCGL`, `WindowSurfaceCGL`.
- **Pruebas:** en la 156 los bots de Mac solo prueban `--use-angle=metal` y `swiftshader` (`testing/buildbot/*.json`).
  El GL común de ANGLE (traductor de shaders, validación) sigue vivo por Linux/ChromeOS/Android; la cola CGL, no.
- **Riesgo de seguridad de reabrirlo** (para tu análisis): la validación de WebGL es del frontend de ANGLE, común a todos los
  backends y con fuzzing; lo que se añade es el driver OpenGL de Apple (sin parches en 10.14/10.15, igual que su Metal) y
  la cola CGL ya sin pruebas de Google desde la 150. El proceso de GPU sigue en su sandbox.

## 3. Por qué rechaza Metal y en qué Mac (ANGLE de la 156)

Cuatro puertas, cualquiera basta para rechazarlo:
1. `src/common/apple_platform_utils.mm` `IsMetalRendererAvailable()`: modelo mínimo — MacBookAir ≥ 8,1 (2018),
   MacBookPro ≥ 13,1 (2016), MacBook ≥ 9,1 (2016), Macmini ≥ 8,1 (2018), iMac ≥ 17,1 (finales de 2015), iMacPro todos.
   **MacPro no está en la lista** (por eso la 6,1 con D500 usa Metal).
2. El mismo fichero: `supportsFamily:MTLGPUFamilyMac2`. Comentario de Google: «Devices in family 1, such as
   MacBookPro11,4, cannot use ANGLE's Metal backend» (no es solo «sin probar»).
3. `DisplayMtl.mm`: `requireGpuFamily2 = true`.
4. `DisplayMtl.mm`: `disableMetalOnNvidia = true` («NVIDIA GPUs are unsupported due to scarcity of the hardware»).
En este Mac `system_profiler` da «Metal: Supported, feature set macOS GPUFamily1 v4» en las dos GPU → cae por 1, 2, 3 y
(la GT 650M) 4. Además, Chromium 128 aplica aquí `force_low_power_gpu` (lista de bugs de driver), o sea que con OpenGL
Chrome usa la Intel aunque se pida «high-performance».

## 4. Medidas (MacBookPro9,1, Catalina)

| | motor | WebGL | Aquarium 1000 / 5000 / 15000 | MotionMark 1.3.2 |
|---|---|---|---|---|
| Safari de Catalina (referencia) | Apple | sí | 59,7 / 43,0 / 16,1 fps | — |
| **2.7.0** (Chromium 128), por defecto | **ANGLE OpenGL 4.1, HD 4000** | 1 y 2 | **59,9 / 51,3 / 26,1** | **507** |
| 2.7.0, `--use-angle=metal` | rechazado → SwiftShader | por software | 5,7 / 3,4 / 2,0 | 434 |
| **3.1.1** (156), por defecto | ninguno (GPU apagada, composición por software) | **no** | — | **733** |
| 3.1.1, `--enable-unsafe-swiftshader` | SwiftShader | por software | 5,9 / 3,9 / 2,0 | 742 |

- Mismo Chromium (128): OpenGL frente a software = Aquarium ×10–13, MotionMark +17 %.
- La 156 por software (733) ya supera a la 128 con OpenGL (507) en MotionMark: Skia por CPU ha mejorado mucho y en este
  Mac las pruebas de composición (Multiply, Leaves, Images, Suits) van mejor por CPU que por la HD 4000; las de canvas
  (Arcs 1912 frente a 604, Lines 7061 frente a 2467) van mucho mejor por GPU.
- Sin caídas en ninguna tanda (DiagnosticReports y Crashpad).
- Pendiente: la GT 650M con OpenGL (requiere desmarcar el cambio automático de gráficos; se lo he pedido a Titín).

## 5. Parche preparado y NO compilado (por si sirve como punto de partida)

`temp/local19/gpu-macs-antiguos/{angle.patch,src.patch}` en la 7,1 (fuera del árbol; ramas sin commit retiradas):
`kOpenGL` de vuelta en `GetAllowedGLImplementations()` (detrás de Metal: reserva automática) y, aparte, la apertura de Metal
(quitar la lista de modelos, `requireGpuFamily2` y `disableMetalOnNvidia`). Titín, después de verlo, prefiere **solo
OpenGL como reserva** donde Metal no está permitido y no forzar Metal en familia 1; el parche de Metal además está
incompleto (falta la puerta 2).

## 6. Opinión de Titín (13-11, con LOCAL-19)

Primero pruebas y datos; luego decidir con COORDINACIÓN. Le preocupan dos cosas: si el OpenGL de la 156 está probado con
alguna tarjeta y si abre agujeros de seguridad. Prefiere OpenGL para los Mac que Metal no admite antes que forzar Metal
en GPU de familia 1, porque Google las quitó por algo y Catalina ya nos ha dado sorpresas con funciones que faltaban.
