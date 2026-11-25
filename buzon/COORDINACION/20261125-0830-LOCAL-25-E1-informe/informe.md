# LOCAL-25 → COORDINACIÓN (63): A/B de E1 contra la 3.2.2, M1 con E1, suplementos y control

Respuesta a `buzon/LOCAL/20261124-1805-COORDINACION-63-E1.md` y a los añadidos de COORDINACIÓN y ARQUITECTURA de la
noche del 24 al 25. Todo en la 6,1 (MacPro6,1, dos D500, Mojave 10.14.6). **E1 no es una versión y no se anuncia.**
Datos crudos en `software/entregas/local24/` (prefijos `e1ab`, `e1msaa`, `e1mmr`, `e1shd`, `e1shs`, `e1vid`, `e1via`,
`e1vib`). Tablas completas en `anexos/`.

## 0. Condiciones

- **Base = 3.2.2 publicada** (198.63.50), no la 3.2.1. E1 = el mismo árbol con el parche E1 (`Release-322-e1`).
- E1 escribe «FlyWeb: Metal device by id» en todas sus pasadas (2 entradas por pasada) y la base en ninguna. En el
  control, e1x lo escribe y e1d no.
- LuLu retuvo el binario E1 la primera vez. Lo aprobó el HUMANO; no fue que pasara solo.
- **Cortes:** ninguno en ninguna versión. Hubo un único fallo del método, `e1msaa-v-e1-esc2`: el conductor no
  encontró pestañas antes de empezar. Se repitió como `-r2` y salió bien.
- Pantalla sin cambios antes y después de cada tanda. Escala 1 y escala 2 por pasada, alternando base/E1 en espejo.
- **Validez** (regla de ARQUITECTURA): una pasada WebGL cuenta solo si hay contexto WebGL con tamaño y la captura no es
  negra, en las dos versiones. En MSAA, además, SAMPLES > 0. No se ha invalidado ninguna pasada del A/B ni de los
  suplementos.
- `threejs-buffergeometry` queda **no medido**: no arranca desde threejs.org. El suplemento de three.js se hizo con
  la copia local de la 0.170.

## 1. Veredicto §11.3 del A/B (5+5 por escala; MotionMark 3+3)

| Caso | Escala 1 | Escala 2 |
|---|---|---|
| Aquarium 5k / 10k / 15k, cruce4k, textura2d | pasa | pasa |
| shader-local | pasa | **falla**: 39 → 37,4 fps (+4,1 %, +1,1 ms/f) |
| Aquarium 20k | por estados: pasa (§1.1) | por estados: pasa en el estado rápido (§1.1) |
| Aquarium 30k | pasa | por estados: pasa (§1.1) |
| MotionMark (total) | pasa (−0,6 %) | pasa (−0,5 %) |
| Basemark (una pasada) | — | base 820, E1 827 |

### 1.1 Aquarium 20k/30k por estados, como 15k

A escala 2 **las pasadas lentas son pasadas enteras**: 15k, 20k y 30k caen juntos en la misma pasada. Son la pasada 09
de la base y las 02 y 03 de E1.

| Escala 2 | Base rápida | E1 rápida | Pérdida en estado rápido | Base lenta | E1 lenta |
|---|---|---|---|---|---|
| 20k | 47,9 47 47 47 → 47 | 48,3 49 49,1 → 49 | −4,3 % (gana E1) → **pasa** | 42 | 44 · 32,8 |
| 30k | 33 32,9 32,4 32,9 → 32,9 | 32,5 32,4 32,5 → 32,5 | +1,2 % → **pasa** | 28,1 | 29,5 · 28,6 |

- Estado lento: la base en 1 de 5 pasadas y E1 en 2 de 5. Con 5+5 no se puede separar.
- Escala 1, 20k: la base 04 cae a 33,4 solo en este caso (va de 32,4 a 49 dentro de la pasada). Sin ella, base 47,6 y
  E1 49 → **pasa**.

## 2. Suplemento MSAA / three.js (SAMPLES = 4 en todas)

- Carga calibrada con la base a escala 2. Se eligieron msaa 160k y 1M y three 160k y 500k.
- A escala 1 todo está a 60 fps y **pasa**.
- A escala 2:

| Caso | Base | E1 | Pérdida | Coste | Veredicto |
|---|---|---|---|---|---|
| msaa-1M | 47 | 45 | +4,3 % | +0,95 ms/f | **falla** |
| three-500k | 51 | 48 | +5,9 % | +1,23 ms/f | **falla** |
| msaa-160k, three-160k | 60 | 60 | — | — | pasa |

Es el mismo coste fijo de alrededor de 1 ms por fotograma que el del shader a escala 2.

## 3. Control con el mismo binario (e1x = E1 encendido; e1d = E1 apagado con `FLYWEB_METAL_DISPLAY_GPU=1`)

Las dos versiones se lanzan igual: ejecutable directo, mismo perfil nuevo y mismos argumentos. Comprobado antes de
medir:

- e1x escribe «Metal device by id» ×2 y la otra D500 trabaja al 100 % en Aquarium.
- e1d no escribe ninguna y la otra D500 se queda al 0 %.

| Caso | e1d (E1 apagado) | e1x (E1 encendido) | Pérdida | Veredicto |
|---|---|---|---|---|
| shader-local esc2 (3+3) | 39 39 39 | 37,4 37,4 37,4 | +4,1 % | **falla, igual que en el A/B** |
| MotionMark total esc1 (6+6) | 1600,2 | 1604,5 | −0,3 % | pasa |
| MM Multiply / Canvas Arcs / Leaves / Suits | | | −1,2 / −1,3 / −0,7 / +1,9 % | pasa |
| MM Paths | 15380 | 14923 | +3,0 % | dudoso |
| MM Canvas Lines / Images / Design | | | | no medible (ruido 10,4–13,6 %) |

**Lectura:**

- El −4,1 % del shader a escala 2 **es de E1**, no de una diferencia de compilación: sale idéntico con el mismo
  binario. Queda como **falla**; decide el HUMANO.
- Los fallos por prueba de MotionMark del A/B (Canvas Lines, Multiply y Paths) **no se repiten** con el mismo binario,
  salvo Paths, que queda «dudoso». La sospecha de ARQUITECTURA (diferencia de compilación o ruido) se confirma para
  esas pruebas.

## 4. Shader a escala 1 con más carga (`?n=4`, 5+5)

- Calibración con la base: n2 = 60, n3 = 54,6, n4 = 42,6, n5 = 35, n6 = 29,7 fps. Se elige n4.
- Resultado: base 41,3 (ruido 0,2 %), E1 43,0. **E1 gana el 4,1 %** (24,2 → 23,3 ms/f, −0,96 ms/f) → **pasa**.
- Comprobado con muestreador: el renderer está al 1 % y CrGpuMain al 5–6 % en las dos versiones, así que el límite es
  la tarjeta.
  - Base: D500 de pantalla al 100 % y la otra al 0 %.
  - E1: la otra D500 al 100 % y la de pantalla al 29 %.
- Con la misma carga por fotograma, a escala 1 E1 gana y a escala 2 pierde 1 ms/f. El coste aparece cuando hay que
  pasar a la tarjeta de pantalla un lienzo de 2× (más píxeles que copiar).

## 5. M1 con E1 y las puertas P3 / P4

Detalle en `anexos/m1-e1.md`. Con E1, la otra D500 trabaja al 94–100 % en Aquarium.

- **P3 no se abre.** Ningún caso tiene CrGpuMain ≥ 90 % por debajo de 60 fps con las dos tarjetas trabajando. El
  máximo es el 85 %, en Aquarium 20k.
- **P4.** El cruce cuesta menos del 10 % en todo lo medido; lo peor es el −5,9 % de three-500k a escala 2.
  - En MotionMark la tarjeta domina (los dos hilos por debajo del 85 %) en Design y Suits a escala 2, y en parte en
    Leaves.
  - No domina en Multiply, Images ni Canvas Lines.
  - La decisión es de ARQUITECTURA.

## 6. Vídeo + Aquarium a escala 2: **dudoso**

Lo que se reprodujo de verdad fue **1920x1080@60** (avc1 + opus) en todas las pasadas válidas, no 4K: YouTube no da
4K60 en esta ventana. Aquarium ocupa la ventana entera, no un lienzo de 1024.

### 6.1 A/B 3+3 en espejo

| | Fotogramas perdidos durante Aquarium |
|---|---|
| Base | 0, 0, 0 |
| E1 | 0, 0, 258 de 1812 (con Aquarium a 51,4 fps) |

Sumando las pasadas del A/B, E1 perdió fotogramas en 2 de 4 y la base en 0 de 4.

### 6.2 (b) Control e1x frente a e1d, 8+8 en espejo, sin muestreador

Detalle en `anexos/video-b.md`. Mide los fps de Aquarium por segundo desde la carga y los fotogramas de vídeo perdidos
en la carga, al segundo 15 y al final.

| | e1d (E1 apagado) | e1x (E1 encendido) |
|---|---|---|
| Pasadas que no se asientan en 45 s (nunca 3 s seguidos ≥ 58) | 3 de 8 | 5 de 8 (y una más tarda 16 s) |
| Segundos hasta asentarse (las que se asientan) | 4, 4, 5, 5, 9 | 4, 5, 7, 16 |
| Perdidos de la carga al segundo 15 (mediana) | 116 | 229 |
| Perdidos del segundo 15 al final | 0 0 0 42 358 444 473 488 | 80 148 233 468 486 497 507 517 |

**Lectura:**

- El estado lento **también aparece con E1 apagado y el mismo binario**: 3 de 8, frente a 1 de 3 en la base y ninguno
  en el A/B. Por tanto no lo crea E1.
- Con E1 aparece más a menudo: 5 o 6 de 8 frente a 3 de 8. Con 8+8 esa diferencia **no es concluyente** (Fisher
  bilateral: p = 0,62 con 5 de 8, y p = 0,31 si se cuenta la de 16 s).
- Tampoco lo es con Aquarium sin vídeo (§1.1: 2 de 5 frente a 1 de 5).
- Queda **dudoso**. Si hace falta decidirlo, harían falta unas 20+20 pasadas.

### 6.3 (a) Dos sample del proceso GPU, base, escala 2

Pasada `e1via-base-esc2-1`, en el primer intento. Aquarium tardó 14 s en asentarse.

- Sample del tramo lento: 07:07:07, 3,66 s. CrGpuMain va al 70–94 % en ps -M.
- Sample tras recuperarse: 07:07:23, 3,80 s. CrGpuMain va al 43–46 %.
- Simbolizados con el dSYM de `Release-322` (mismo UUID 4C4C44F4-…8BD5 que el FlyWeb Framework publicado).
- Cuentas en muestras de 1 ms; el recuperado está escalado a la misma duración.

**CrGpuMain.** En el tramo lento está activo 3245 de 3656 ms (89 %); recuperado, 2046 de 3796 (54 %). La diferencia,
unos 1270 ms, **no es trabajo de GPU** (detalle en `anexos/video-a-bajo-el-bucle.md`):

| Bajo… | Lento | Recuperado | Diferencia |
|---|---|---|---|
| `GpuChannel::ExecuteDeferredRequest` (los comandos WebGL/raster) | 1600 | 1539 | +61 |
| · de ello `CommandBufferService::Flush` (decodificar y ejecutar) | 1281 | 1523 | **−242** |
| · `GLES2DecoderPassthroughImpl::MakeCurrent` + `RasterDecoderImpl::MakeCurrent` | 83 | 7 | +76 |
| · `ProgramCache` / `GrShaderCache::ScopedCacheUse` (crear y destruir) + `CreateCacheUse` | 135 | 6 | +129 |
| `SkiaOutputSurfaceImplOnGpu::SwapBuffers` | 145 | 259 | −114 |
| `Scheduler::RunNextTask` propio + `PostDelayedTask` + `stable_sort` + `TaskGraph::BeginTask` | 199 | 11 | +188 |
| `DoWork` propio + `SelectNextTask` + `RemoveCancelledTasks` + `WorkQueueSets` | 200 | 16 | +184 |
| `__CFRunLoopRun` → `mach_port_insert_member` / `mach_port_extract_member` | 247 | 19 | **+228** |
| `__CFRunLoopRun` → `__CFRunLoopDoSources0` | 2580 | 1909 | +671 |
| `media::VideoToolboxFrameConverter::Convert` | 6 | 8 | −2 |

**Chrome_ChildIOThread.** En el tramo lento está activo 658 de 3656 ms (18 %); recuperado, 88 de 3796 (2 %): **7,5
veces más**.

| Bajo… | Lento | Recuperado | Diferencia |
|---|---|---|---|
| `mojo::core::Channel::TryDispatchMessage` → ipcz `OnAcceptParcel` → `MojoTrap::TrapEventHandler` | 394 | 59 | +335 |
| · `MessageDispatcher::Accept` → `InterfaceEndpointClient::HandleIncomingMessage` | 162 | 19 | +143 |
| · `MojoDestroyMessageIpcz` → `~ParcelWrapper` → `Envelope::Close` → `mach_port_deallocate` | 145 | 20 | +125 |
| `gpu::mojom::GpuChannelStubDispatch::Accept` | 90 | 13 | +77 |
| `GpuChannelMessageFilter::FlushDeferredRequests` → `Scheduler::ScheduleTasks` (con su `LockImpl`) | 73 | 10 | +63 |
| `GpuChannel_WaitForGetOffsetInRange_ProxyToResponder::Run` | 55 | 0 | **+55** |
| `GpuChannelMessageFilter::WaitForGetOffsetInRange` | 9 | 0 | +9 |

**Lectura (datos, no conclusión).** En el tramo lento CrGpuMain hace **el mismo trabajo de comandos o menos**: Flush
−242 ms, SwapBuffers −114 ms. Lo que suma son unos 700 ms de **coste por tarea**:

- cambio de contexto (`MakeCurrent`) y caché de programas por cada petición diferida;
- planificador (`RunNextTask`, `PostDelayedTask`, ordenación);
- bucle de tareas;
- el CFRunLoop metiendo y sacando puertos de su conjunto (`mach_port_insert/extract_member`, unas 12 veces más).

Al mismo tiempo, el hilo de E/S recibe unas 7 veces más mensajes mojo de `GpuChannel`. Aparece
`WaitForGetOffsetInRange`, que **solo existe en el tramo lento**: un cliente espera de forma síncrona a que el GPU
alcance un offset.

Todo apunta a **muchas peticiones diferidas pequeñas**, con un cliente que hace flush y espera. Lo que esto no dice es
de quién son esas peticiones (el renderer de Aquarium o el del vídeo).

**Hilo 9.** En el ps -M de esta pasada, el hilo que pasa del 3,6 % al 29–31 % en el tramo lento es el **índice 11**,
no el 9. Por su comportamiento es Chrome_ChildIOThread: es el único hilo cuyo activo se multiplica, del 2 % al 18 % en
`sample`. El orden de ps -M **no es estable entre pasadas** (en esta hay 12 hilos en ps y 22 en `sample`), así que no
conviene identificar hilos por índice. Lo confirmo por comportamiento, no por número.

## 7. Resumen para decidir

- **Pasan:** Aquarium (5k a 30k por estados), cruce4k, textura2d, MotionMark total, Basemark, shader a escala 1 (E1
  gana un 4 %) y todo a escala 1.
- **Fallan a escala 2, siempre por el mismo coste fijo de unos 1 ms/f:**
  - shader-local −4,1 %, confirmado con el mismo binario;
  - msaa-1M −4,3 %;
  - three-500k −5,9 %.
  - Decide el HUMANO.
- **Dudosos:**
  - vídeo + Aquarium: el estado lento existe sin E1 y con E1 es más frecuente, pero no de forma concluyente;
  - MotionMark Paths.
- **P3 no se abre.** P4 queda para ARQUITECTURA con la tabla de M1.

## 8. Anexos

- `veredicto-ab.md`, `veredicto-msaa.md`, `veredicto-e1mmr.md` y `veredicto-e1shd.md` (control),
  `veredicto-e1shs.md` (shader a escala 1).
- `m1-e1.md` y `m1-shader-esc1.md`.
- `video-b.md`, `video-a-dif-funciones.md` y `video-a-bajo-el-bucle.md`.
- Guiones: `analisis-ab.py`, `m1-e1.py`, `video-b.py`, `tareas.py`, `dif.py` y `hijos.py`. Los tres últimos usan
  `analizar-sample.py` de LOCAL-21.

Después de esto paso a la orden F1 del guion único (`20261124-2140-COORDINACION-63-F1-guion-unico.md`). Primero
devuelvo los checkouts de chromium y ANGLE de `local/322-e1` a `local/322-final`.
