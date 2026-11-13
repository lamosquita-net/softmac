# OpenGL de reserva en los Mac que ANGLE no admite en Metal: parche para una compilación preliminar

ARQUITECTURA, 14-11-2026. Para LOCAL-19, por orden directa de Titín a ARQUITECTURA (14-11): compilación **preliminar**
e incremental sobre la 3.1.1, para ver si pinta y medir, antes de decidir la definitiva con la tanda de seguridad.
El estudio completo está en el PR 982 (`FlyWeb/docs/gpu-mac-antiguos.md`).

**No es publicable:** falta la revisión de seguridad (regla 17) de los ficheros de texturas. No se firma, no se sube y
no cambia de versión ni de número de compilación.

## Qué hay aquí

| Parche | Qué | De dónde |
|---|---|---|
| `0001` | Admite ANGLE OpenGL detrás de Metal, **solo antes de macOS 11** (`ui/gl/init/gl_factory_mac.cc`, 8 líneas) | Escrito por ARQUITECTURA en papel, **sin compilar** |
| `0002` | `GetTextureTargetForIOSurfaces()` y el destino de textura en `SharedImageFactory` | `flynk-b1b` `24117207f8` (LOCAL-17) |
| `0003` | `SharedImageCapabilities.texture_target_for_io_surfaces` (mojom y traits) | `flynk-b1b` `d078e75aeb` |
| `0004` | Destino de textura en `ClientSharedImage` | `flynk-b1b` `8ebf3076c5` |
| `0005` | Formatos de Ganesh/GL en `viz` | `flynk-b1b` `978889beed` |

`SHA256SUMS` los sella. Los cinco aplican en cadena sobre `flynk-b1d` `33a1745949`, la base de la 3.0.0 (comprobado con
`git apply --cached --check` en un índice temporal, sin tocar el árbol). **Sobre el src de la 3.1.1 no lo he podido
comprobar:** el `0004` de Catalina toca `service_utils.cc` en otras líneas, así que espero como mucho un desplazamiento.

## Correcciones a tu parche (`temp/local19/gpu-macs-antiguos/`)

1. **De `src.patch` vale solo la vuelta de `kOpenGL`**, y con una condición más: solo antes de macOS 11. Usa el `0001`
   en su lugar. De macOS 11 en adelante no debe cambiar nada (allí compone Graphite y no hay modo GL por hardware).
2. **Fuera la apertura de Metal** (`angle.patch` y lo que quite la lista de modelos, `requireGpuFamily2` o
   `disableMetalOnNvidia`). Titín no la quiere, y las dos GPU del 9,1 son de familia 1.
3. **Falta lo que hace que pinte:** las texturas rectangulares de IOSurface, `0002` a `0005`. Con `kOpenGL` solo, la GPU
   arranca en hardware y la ventana no pinta: es lo que encontró LOCAL-16 el 04-11 («eglBindTexImage requires 2D»,
   miles de «uninitialized SharedImage», `BeginRasterCHROMIUM` fallido).

**Lo que no hace falta:**

- ningún argumento de GN: el backend GL/CGL de ANGLE ya va compilado en la 3.1.1, como tú mismo comprobaste;
- ningún cambio en ANGLE;
- de `flynk-b1b`, **no** tomes `9aab06cd1e` entero (su otra mitad deja Metal por defecto solo en macOS 11+ y contradice
  a B1d), ni `6a6e6ea38d` (la 3.1.1 ya tiene `supports_gpu_mode_hardware_gl_(IsMacOSBelow11())`), ni `e2285e9dbf`
  (B1d ya lo trae), ni el *roll* `d1bd098a89`.

## Compilación

- Sobre el src de la 3.1.1 (`seg/3.1.1` `9e0d83137f`) y su carpeta de salida: incremental.
- Toca un mojom (`gpu/ipc/common/shared_image_capabilities.mojom`), así que recompila lo que depende de él y vuelve a
  enlazar el framework. No toca Blink, V8 ni ANGLE.
- En una rama o un índice aparte: que no entre en `seg/3.1.1` ni se empuje a ningún fork.

## Antes de compilar, si quieres ahorrarte una sorpresa (5 minutos)

Se conserva `entregas/b1-local16/chromium-156-b1c.zip` (04-11). Si es la compilación de LOCAL-17 con las texturas (lo
supongo por la hora), ábrela en la 6,1 y mira si pinta y si WebGL crea contexto. En Mojave arranca con OpenGL por
defecto. Si ahí no pinta, a este parche le falta algo y conviene saberlo antes.

## Qué probar con la preliminar

| | Dónde | Qué tiene que salir |
|---|---|---|
| A | 6,1, sin indicadores | `chrome://gpu` con `angle=metal`, como hoy. Aquarium 10 000 como la 3.1.1. **Es la prueba de que los Mac Pro no cambian** |
| B | 6,1, `--use-angle=gl` | `(gl=egl-angle,angle=opengl)` y Ganesh GL; la ventana pinta (captura por CDP); WebGL 1 y 2 crean contexto; Aquarium; **YouTube H.264** con `VideoToolboxVideoDecoder` (el vídeo no lo ha probado nadie por este camino) |
| C | MacBookPro9,1 (Catalina), sin indicadores | `angle=opengl` con la HD 4000. La fila que falta en tu tabla: Aquarium 1 000 / 5 000 / 15 000 y MotionMark. WebGL, vídeo. Después, con el cambio automático desmarcado (GT 650M) |
| D | Si Titín puede: Air de 2013 (Mojave) y mini de 2012 | Lo mismo que C |

En la salida de error del proceso de GPU no debe aparecer «eglBindTexImage requires 2D», «uninitialized SharedImage»
ni `BeginRasterCHROMIUM` fallido. Cero caídas en DiagnosticReports y Crashpad.

**Dos datos que hacen falta para decidir:**

- **MotionMark con OpenGL frente a los 733 por software** en el 9,1. Si queda por debajo, dilo tal cual: en ese Mac la
  composición iba mejor por CPU que por la HD 4000.
- **Si se pierde el contexto o el dispositivo** (pantalla en negro tras dormir, al cambiar de GPU o al conectar un
  monitor). ANGLE quitó de su capa de Mac `prepareForCall` y `testDeviceLost` entre la 150 y la 156. No las devuelvas
  por tu cuenta: apúntalo y avisa.

## Después

Con A y B en verde y los datos de C, COORDINACIÓN y Titín deciden si entra en la compilación definitiva de la 3.1.2
con la tanda de seguridad. Antes de esa, SEGURIDAD tiene que revisar `0002` a `0005`.
