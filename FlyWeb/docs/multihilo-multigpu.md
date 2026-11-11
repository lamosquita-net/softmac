# FlyWeb — multihilo y varias GPU: estudio (FM.56)

ARQUITECTURA, 11-11-2026, por decisión de Titín (vía COORDINACIÓN-39, buzón 20261111-1333). **Solo estudio: sin código
y sin medidas nuevas.** Lo único que he ejecutado es un recuento sobre las tomas de `sample` que LOCAL-21 ya tenía
(§2.2). Propone; decide Titín.

Marcas: **[V]** visto en el código, en las cabeceras del SDK o en medidas ya publicadas; **[R]** reanálisis mío de
datos existentes; **[I]** inferido; **[S]** suposición sin comprobar.

**Hipótesis de Titín:** en la 6,1 la GPU ya va al 100 % en las pruebas; el multihilo solo daría poco o nada porque el
cuello pasaría a la GPU; hace falta multihilo y varias GPU a la vez.

## 1. Conclusión

1. **En Aquarium, lo que está al 100 % no es la D500: es un hilo de CPU.** Con la 3.0.0 era el hilo principal del
   proceso de GPU; con la 3.1 es el hilo principal del renderer (el JavaScript de la página y sus llamadas WebGL). Los
   datos que hay lo demuestran sin medir nada más (§2). Si Titín ve «GPU al 100 %» en un monitor del sistema, es otra
   magnitud, y **en la 3.x nadie ha medido la utilización de las tarjetas**: es la primera medida que falta (§2.3).
2. **El multihilo del proceso de GPU no daría nada hoy**, pero no por la razón de la hipótesis: no porque el cuello
   pase a la tarjeta, sino porque ya ha pasado al renderer, que es un hilo de JavaScript y no se puede repartir (§3).
3. **Un solo lienzo no se puede repartir entre dos GPU** de forma general: ni Metal ni Chromium lo hacen y el coste de
   CPU, que es el límite, no bajaría (§4.1). **Sí se pueden poner contextos distintos en tarjetas distintas**: lo trae
   Chromium de serie y nuestra rama `flynk-b1d-dosgpu` ya lo hace en la 6,1 con 51 líneas (§4.2). Midió lo mismo que
   con una tarjeta, como era de esperar con el límite en la CPU.
4. **«Multihilo y varias GPU a la vez» solo tiene sentido en una forma:** un hilo y una tarjeta por contexto WebGL.
   Ayuda cuando hay varios contextos pesados visibles a la vez, que en páginas reales es raro, y es el cambio más caro
   de mantener de todos (§5).
5. **Recomendación:** no invertir ahora en hilos ni en varias GPU. Antes, una medida barata en la 6,1 (§6, M1) que
   diga, página por página, si el límite es la tarjeta o un hilo. Con ese dato hay tres puertas con número (§6). Lo
   que sí rinde ya es el renderer, que es donde está el límite y que sigue sin perfilar (`rendimiento-3x.md` §5).
6. **El reparto de calor** que quiere Titín es un motivo distinto del rendimiento y la rama de dos GPU lo cumple en
   parte. Es decisión suya si se entrega aunque no dé un fotograma más (§7).

## 2. Pregunta 1: ¿«GPU al 100 %» es la D500 o un hilo de CPU?

### 2.1 Lo ya medido [V]

| Dato | Valor | Fuente |
|---|---|---|
| 3.0.0, Aquarium 15 000 peces, 6,1 | 39,0 fps; `CrGpuMain` al 92,7 %; renderer al 61–62 % | `rendimiento-3x.md` §1, §2.1 |
| Coste por pez en el hilo de GPU | 1,6 µs de CPU | `rendimiento-3x.md` §2.1 |
| Candidata de la 3.1 (t4, cuatro parches de ANGLE) | 15 000 peces: de 39,8 a 41–49 fps (pasadas sueltas de 53,0 y 55,6); `CrGpuMain` baja al 57–65 %; **renderer al 100 %** | `rendimiento-3x.md` §3.1, §3.6 |
| 3.1.0 en la 6,1 | 15 000 peces, mediana 41,9 fps | encargo de COORDINACIÓN-39 |
| WebGL en la segunda D500 (`flynk-b1d-dosgpu`) | 60 / 54 / 37 fps, igual que con una | `b1d/README.md:41`, LOCAL-18 |
| MotionMark 1.3.2, 6,1 | 1351 (3.0.0) · 1342 (3.0.1) · 1365 (t4): no se mueve con los parches de ANGLE | `rendimiento-3x.md` §3.1 |

Tres hechos bastan para Aquarium:

- **Los parches de la 3.1 solo quitan trabajo de CPU y los fotogramas suben.** Si la D500 hubiera sido el límite a
  39,8 fps, quitar CPU no habría subido nada. La tarjeta dio 53 y 55,6 fps en pasadas sueltas con 15 000 peces: su
  techo está **por encima de 55 fps**; cuánto más arriba, no se sabe.
- **Con la 3.1 el renderer está al 100 % de CPU.** Un hilo que espera a la tarjeta no está al 100 %.
- **Mover la WebGL a la otra D500 no cambió nada.** La tarjeta de la pantalla no iba justa por componer.

### 2.2 Dónde espera el hilo de GPU [R]

He clasificado las muestras del hilo principal del proceso de GPU en las tomas de 15 000 peces que LOCAL-21 dejó en
`entregas/local21` (guion `FlyWeb/tools/rendimiento/esperas.py`): tiempo activo, espera de trabajo en la bomba de mensajes y espera
dentro de Metal.

| Toma | Activo | Espera de mensajes (no tiene trabajo) | Espera en Metal (`waitUntilScheduled`) |
|---|---|---|---|
| 3.0.0 (`paso3`) | 91,6 % | 0,7 % | 7,5 % |
| 3.0.1, serie (`c31/301-perf`) | 92,4 % | 0,5 % | 6,9 % |
| t4, pasada 1 (`c31/t4`) | 66,3 % | **28,2 %** | 5,3 % |
| t4, serie (`c31/t4-aq`) | 79,9 % | **14,3 %** | 5,4 % |

Con la 3.1, el tiempo que el hilo de GPU no trabaja lo pasa **esperando órdenes del renderer**, no esperando a la
tarjeta. La espera en Metal es pequeña e igual antes y después (5–7 %); además `waitUntilScheduled` espera a que el
búfer de órdenes quede encolado, no a que la tarjeta termine. No aparece `waitUntilCompleted`.

Con estos números, el hilo de GPU de la 3.1 gasta entre 14 y 19 ms por fotograma con 15 000 peces: por sí solo
aguantaría entre 51 y 70 fps [R]. El renderer gasta unos 24 ms: es quien fija los 41,9.

### 2.3 Lo que no se ha medido y cómo medirlo en la 6,1

**No hay ninguna medida de utilización de las D500 con la 3.x.** `relevo-local.md:256` anota que `ioreg` da cuatro
valores de «Device Utilization %» en la 6,1 y que el fondo se ensucia si Titín está trabajando; FM.43 (27-10) recoge
«MotionMark … con la GPU al 100 %» con la 2.0.1, que pintaba por OpenGL: es otra versión y otra ruta. Los tiempos de
GPU por búfer de órdenes (`GPUStartTime`, `GPUEndTime`) existen desde macOS 10.15 [V: `MTLCommandBuffer.h`], así que en
Mojave no están. Queda esto, todo sin compilar nada:

1. **Contador del controlador, por tarjeta:** `ioreg -r -d 1 -w 0 -c IOAccelerator`, campo `PerformanceStatistics` →
   «Device Utilization %», una lectura por segundo, con la 6,1 en reposo y un control al 0 % antes de cada caso (el
   método de FM.43). Identificar cuál de las dos D500 lleva la pantalla por su `registryID` (el registro de FlyWeb lo
   escribe: «Metal device of the main display»). Qué mide exactamente el contador de AMD no está documentado [S]: por
   eso no basta solo.
2. **Los dos hilos a la vez:** `ps -M` del hilo principal del renderer y de `CrGpuMain` (no `sample`, que congela el
   renderer; `rendimiento-3x.md` §2.1).
3. **Barrido de píxeles con las mismas órdenes:** la misma escena con el lienzo a la mitad y al doble de lado. Si los
   fotogramas no cambian, no manda el relleno de píxeles de la tarjeta. Es la prueba que no depende de fiarse del
   contador.

**Regla para clasificar cada página:** manda **la tarjeta** si va por debajo de 60 fps, la utilización es ≥ 90 %, los
dos hilos están por debajo del 85 % y bajar el lienzo a la mitad sube los fotogramas un 15 % o más. Manda **un hilo**
si alguno está al 95 % o más.

## 3. Pregunta 2: qué se puede repartir entre hilos

Cómo está hoy [V]: todas las órdenes de todos los contextos (WebGL, raster de páginas, composición) se ejecutan en el
hilo principal del proceso de GPU. El planificador ya sabe llevar secuencias en más de un hilo
(`gpu/command_buffer/service/scheduler.h:289-291,370`), pero el canal crea todas en el principal
(`gpu/ipc/service/gpu_channel.cc:1038`). ANGLE Metal solo usa hilos de trabajo para compilar sombreadores y programas
(`ShaderMtl.mm`, `ProgramMtl.mm`).

| Opción | Qué reparte | Techo en Aquarium (6,1, 15 000 peces) | Techo en MotionMark | Estado |
|---|---|---|---|---|
| **A. Composición en su propio hilo** (DrDC de Chromium) | el compositor de pantalla fuera del hilo principal de GPU | ninguno: Viz gasta menos del 1 % [V] | desconocido | De serie en Android. En Mac, apagado y **solo funciona con Graphite** (`gpu_finch_features.cc:282-291` [V]), que en FlyWeb está fuera por directiva (`DIRECTIVAS.md:69-72`) |
| **B. Reproducir el codificador de Metal en otro hilo** (cambio 5 de `rendimiento-3.1.md`) | dentro de un contexto: decodificar en un hilo, hablar con el controlador de AMD en otro | el codificador y el controlador son el 33,8 % del tiempo activo con la t4 [V] → hasta ×1,5 en el hilo de GPU. **Hoy, cero:** ese hilo ya tiene holgura y manda el renderer | cero: no cambia con los parches de ANGLE [V] | No existe en upstream. Riesgo alto |
| **C. Un hilo por contexto WebGL** | contextos distintos en paralelo | cero: Aquarium es un solo contexto | cero | No existe en upstream. Muy caro (§5) |
| **D. Renderer** | nada: el JavaScript de una página corre en un hilo | — | — | Se abarata, no se reparte: `Math.sin`/`cos` de V8 es el 22–24 % y `IsFeatureEnabled` por dibujo el 3–4 % [V: `rendimiento-3x.md` §2.1]. Sin perfilar con la 3.1 (§5 de ese documento) |
| **E. Raster de páginas en varios hilos** | el dibujo de teselas | no aplica | es lo que podría mover MotionMark, pero **no se sabe qué lo limita en la 6,1** | Es el diseño de Graphite; mismo bloqueo que A |

Lectura:

- **Aquarium con 15 000 peces tiene hoy el techo en el renderer, en torno a 42–50 fps.** Para llegar a 60 hace falta
  quitarle al renderer alrededor de un 30 % de CPU por fotograma [R: 24 ms → 16,7 ms]. Ningún reparto de hilos del
  proceso de GPU lo consigue. Solo después de eso el hilo de GPU volvería a ir justo (rondaría el 85–100 % a 60 fps
  [R]) y la opción B empezaría a rendir.
- **MotionMark no depende del hilo de WebGL.** Sus pruebas son DOM, CSS, SVG y lienzo 2D. Qué lo limita en la 6,1
  (el hilo principal del renderer, el raster en el hilo de GPU o la tarjeta) **no está medido**; en la 7,1 el límite
  encontrado fue de estilo en el renderer (`rendimiento-motionmark.md`). Es una de las preguntas de M1.
- **Páginas reales:** una web con WebGL hace del orden de cientos o pocos miles de dibujos por fotograma, no 15 000
  [I]. El coste por dibujo del proceso de GPU pesa en ellas mucho menos que en Aquarium; pesan el JavaScript y, si el
  sombreador es caro o la pantalla grande, la tarjeta. No hay ninguna medida de esto en la 6,1.

## 4. Pregunta 3: varias GPU en macOS y Metal

Lo que da Metal [V: cabeceras del SDK]:

- Enumerar tarjetas (`MTLCopyAllDevices`, 10.11), saber cuál no lleva pantalla (`isHeadless`) y cuál lleva la pantalla
  principal (`CGDirectDisplayCopyCurrentMetalDevice`). **Cada recurso (textura, búfer, pipeline) pertenece a una
  tarjeta.**
- **Grupos de tarjetas** (`peerGroupID`, `peerCount`, `newRemoteTextureViewForDevice:`): copia directa de tarjeta a
  tarjeta. Existen **desde macOS 10.15** y solo entre tarjetas que el sistema declara en el mismo grupo. En Mojave
  no existen. Las dos D500 de la 6,1 no forman grupo ni en Monterey [I]; en la 7,1 lo forman algunos módulos MPX
  enlazados, no cualquier pareja [I].
- Sin grupo, pasar una imagen de una tarjeta a otra es **bajarla a memoria del sistema y volver a subirla**. El
  camino práctico es un IOSurface, que las dos tarjetas pueden usar y que el sistema sincroniza [I].

### 4.1 Un solo lienzo repartido entre tarjetas: no

Las dos formas conocidas de repartir un fotograma (las de SLI y CrossFire) no encajan:

- **Partir la pantalla** (cada tarjeta, media imagen): todos los recursos duplicados en las dos y **todas las órdenes
  codificadas dos veces**. El límite es justo el coste de CPU por orden: se dobla.
- **Fotogramas alternos:** todos los recursos duplicados, y cualquier cosa que un fotograma herede del anterior
  (dibujar a textura, `preserveDrawingBuffer`, lienzos que acumulan) hay que copiarla entre tarjetas cada fotograma.
  El coste de CPU por fotograma no baja.
- En los dos casos, el resultado de la tarjeta sin pantalla cruza a la otra para componerse.

Metal no hace nada de esto por su cuenta, Chromium tampoco, y ningún navegador lo hace [I]. Sería un motor de reparto
propio dentro de ANGLE, sin donante, para un caso (la tarjeta saturada con un solo lienzo) que aún no se ha visto en
la 6,1.

### 4.2 Contextos distintos en tarjetas distintas: sí, ya existe

- **De serie en Chromium** [V]: `kEGLDualGPURendering` está encendida por defecto en Mac (`ui/gl/gl_switches.cc:286`).
  Un contexto WebGL que pide `powerPreference: "high-performance"` se crea en otro `EGLDisplay`, sobre la tarjeta
  potente, solo con ANGLE Metal (`gles2_command_buffer_stub.cc:150-163`); su imagen sale en un IOSurface marcado
  `SHARED_IMAGE_USAGE_HIGH_PERFORMANCE_GPU` (`drawing_buffer.cc:2084`, `iosurface_image_backing.mm:999`). Está pensado
  para portátiles con gráfica integrada y dedicada.
- **En un Mac Pro con dos tarjetas iguales no hace nada:** las dos son «de alto rendimiento» y todo acaba en la que
  IOKit llama activa, que en la 6,1 a veces es la que no lleva pantalla. Por eso la B1d fija la de la pantalla
  (`DisplayMtl.mm:235-256` [V]).
- **Nuestra rama `flynk-b1d-dosgpu`** [V] (src `b8a4abda2f`, 42 líneas en `gpu_info_collector_mac.mm`; ANGLE
  `dc5ef06`, 9 líneas): marca la tarjeta de la pantalla como la de por defecto, y así la composición va en ella y la
  WebGL de alto rendimiento en la otra. Solo actúa por debajo de 10.15. Trae `FLYWEB_METAL_DISPLAY_GPU=1` para
  comparar. Resultado de LOCAL-18: los mismos fotogramas.
- **Coste de cruzar para componer** [S, sin medir aislado]: un lienzo de 1024×1024 son 4 MB por fotograma (0,25 GB/s a
  60 fps); uno de 3840×2160, 33 MB (2 GB/s). El ancho de banda de PCIe da de sobra; lo que puede doler es la
  sincronización de cada fotograma entre las dos tarjetas. Con el lienzo de 1024 de Aquarium no se notó [V]. A
  pantalla completa en 4K no se ha probado. Indicio en contra: cuando **todo** se pintaba en la tarjeta sin pantalla,
  MotionMark dio 140 frente a los 1381 de después (`coordinacion.md:580`), aunque entre las dos medidas cambiaron
  más cosas y no se puede atribuir solo al cruce [V].
- **En la 7,1 (10.15 o posterior, hasta cuatro módulos):** la rama no actúa. Extenderla es la misma idea. La 7,1 de
  Titín lleva una W6600X (`rendimiento-3x.md` §5): con una tarjeta no hay nada que repartir.

**Cuándo ayudaría:** cuando la tarjeta de la pantalla esté saturada y una parte del trabajo sea un contexto WebGL que
se pueda llevar a la otra. No ayuda a una página cuyo trabajo es DOM, CSS o lienzo 2D (todo eso va en el contexto de
raster, que es uno), ni a nada limitado por CPU.

## 5. Pregunta 4: ganancia, riesgo, tamaño y mantenimiento

| Opción | Ganancia en páginas reales | Riesgo | Tamaño | Qué se rompe en cada actualización de Chromium |
|---|---|---|---|---|
| **Abaratar el renderer de WebGL** (no es de este estudio; es lo que manda hoy) | la mayor: todas las páginas con WebGL y Aquarium | bajo-medio | parches pequeños, como los de ANGLE de la 3.1 | poco: parches locales |
| **WebGL en la segunda tarjeta** (`flynk-b1d-dosgpu`) | cero donde manda la CPU; posible donde mande la tarjeta (sombreadores caros, pantalla grande); reparte el calor | medio: el cruce a 4K sin medir; cambio de pantalla en caliente sin probar | **51 líneas ya escritas**; falta probar y medir | poco. Depende de que upstream conserve `kEGLDualGPURendering`, que tiene un «quitar tras probar» pendiente (`gles2_command_buffer_stub.cc:149` [V]) |
| **B. Codificador de Metal en otro hilo** | cero hoy; hasta ×1,5 del hilo de GPU en páginas con miles de dibujos, cuando el renderer deje de mandar | alto: orden con blits, `present`, consultas de oclusión, vida de los objetos (`rendimiento-3.1.md` §3, cambio 5) | medio: `mtl_command_buffer.mm` y `ContextMtl.mm` | bastante: es el fichero más movido de ANGLE Metal; parche propio que rebasar en cada salto |
| **C. Un hilo (y una tarjeta) por contexto WebGL** | solo con varios lienzos WebGL pesados visibles a la vez: raro | muy alto: imágenes compartidas entre hilos, contextos de ANGLE con hilo propio, pérdida de contexto | grande: `gpu/ipc/service`, planificador, imágenes compartidas, ANGLE | mucho: toca el corazón del proceso de GPU, que upstream está cambiando hacia Graphite. Iríamos contra la corriente |
| **A/E. DrDC y raster en varios hilos (Graphite)** | fluidez de la interfaz con una WebGL pesada; quizá MotionMark | para Mojave, el de traducir Graphite (más de 20 h y regresiones de GPU, `DIRECTIVAS.md:71`) | cero en 10.15 o posterior (es de serie); enorme en Mojave | nada: lo mantiene upstream. Pero exige reabrir la directiva de Graphite |
| **Un lienzo entre dos tarjetas** | ninguna demostrable | muy alto | enorme, sin donante | todo |

## 6. Pregunta 5: recomendación y puertas

**No implementar nada de esto todavía.** Primero una medida, y después tres puertas con número.

**M1 (LOCAL, 6,1, 3.1.0 publicada; sin compilar; una mañana).** Para cada caso, a la vez: utilización de cada D500,
CPU del hilo del renderer y de `CrGpuMain`, y fotogramas (§2.3), más el barrido de lienzo donde se pueda. Casos:

1. Aquarium con 15 000 peces (control: debe salir «manda el renderer»).
2. MotionMark, **prueba por prueba**.
3. Tres páginas reales con WebGL: un ejemplo pesado de three.js, un sombreador caro a pantalla completa (Shadertoy) y
   Google Earth. Maps, cuando deje de tumbar el proceso de GPU (`rendimiento-3x.md` §3.3).
4. Vídeo 4K a 60 con una página WebGL al lado, como caso de dos cargas a la vez.

Entregable: una tabla con la clasificación de §2.3 por caso. Cuesta poco y contesta de una vez la pregunta de Titín
con datos de la tarjeta.

| Puerta | Se abre si M1 da… | Entonces |
|---|---|---|
| **P1. WebGL en la segunda tarjeta** | al menos una página real clasificada «manda la tarjeta» con la tarjeta de la pantalla ≥ 90 % | A/B de la rama `flynk-b1d-dosgpu` contra la 3.1.0 en esas páginas y en lienzo 4K. Se entrega si **gana ≥ 10 % en alguna y no pierde más del 2 % en ninguna** |
| **P2. Codificador de Metal en otro hilo (B)** | una página real, no solo Aquarium, con `CrGpuMain` ≥ 90 % por debajo de 60 fps y codificador + controlador ≥ 25 % del hilo | prototipo en una rama de avance; se sigue si da **≥ 20 % de fotogramas** |
| **P3. Un hilo y una tarjeta por contexto (C)** | P1 y P2 abiertas, y un caso de uso de Titín con dos o más lienzos WebGL pesados a la vez | estudio de diseño aparte antes de tocar nada |

Hoy, con lo medido: P2 no se abre (`CrGpuMain` al 57–65 %) y P1 y P3 no se pueden evaluar porque falta M1.

**Lo que sí recomiendo hacer ya**, y que no depende de M1: perfilar el hilo principal del renderer con la 3.1 en
Aquarium (pendiente en `rendimiento-3x.md` §5) y atacar ahí. Es donde está el límite demostrado.

**Sobre la hipótesis de Titín:** la segunda mitad es razonable como orden de las cosas (si algún día la tarjeta manda,
repartir hilos sin repartir tarjetas no serviría), pero la primera no se cumple en Aquarium, y en lo demás no está
medida. El orden que sale de los datos es: renderer → medir tarjetas (M1) → lo que M1 diga.

## 7. Para Titín

1. **¿Dónde ve «GPU al 100 %»?** (Monitor de Actividad, iStat, otra cosa) y con qué página. Con eso M1 reproduce
   exactamente su observación.
2. **Reparto de calor.** La rama de dos GPU manda la WebGL de alto rendimiento a la segunda D500 y deja la
   composición en la primera. No reparte por igual: solo trabaja la segunda cuando hay una página WebGL que lo pide.
   ¿Se entrega por ese motivo aunque P1 no dé fotogramas, siempre que no pierda? Mi recomendación: sí, pero **después
   de M1 y del A/B a 4K**, no a ciegas.
3. **Graphite.** DrDC y el raster en varios hilos son el camino multihilo que mantiene upstream, y en Mac dependen de
   Graphite, hoy fuera por su directiva del 27-10. No propongo reabrirla; lo anoto porque es lo único de esta lista
   que no habría que mantener a mano, y solo valdría para 10.15 o posterior.

## 8. Fuentes y límites

- **Medidas:** `rendimiento-3x.md` §1–§3 y §5 (LOCAL-21), `rendimiento-3.1.md` (MOTOR), `b1d/README.md:27-41,157-169`,
  `rendimiento-motionmark.md`, `relevo-local.md:256`, `TAREAS.md` FM.43 y FM.56, `coordinacion.md:576-583`. Tomas de
  `sample` reanalizadas: `entregas/local21/paso3/sample-aquarium15k-gpu.txt` y `c31/{301-perf,t4,t4-aq}/…-gpu.txt`.
- **Código** (árbol `flynk-b1d`, 33a1745949, Chromium 156): `ui/gl/gl_switches.cc:283-290,470-474`,
  `ui/gl/gl_display_manager.h:82-97`, `gpu/ipc/service/gles2_command_buffer_stub.cc:126-190`,
  `gpu/ipc/service/gpu_channel.cc`, `gpu/command_buffer/service/scheduler.h`,
  `gpu/config/gpu_finch_features.cc:282-291,683-741`, `third_party/blink/.../gpu/drawing_buffer.cc:2084`,
  `gpu/command_buffer/service/shared_image/iosurface_image_backing.mm:999`, ANGLE
  `src/libANGLE/renderer/metal/DisplayMtl.mm:235-300`; rama `flynk-b1d-dosgpu` (b8a4abda2f, ANGLE dc5ef06).
- **Metal** (cabeceras del SDK de Xcode de la 7,1): `MTLDevice.h` (`MTLCopyAllDevices`, `isHeadless`, `isLowPower`,
  `isRemovable`, `peerGroupID`/`peerIndex`/`peerCount` desde 10.15), `MTLTexture.h` (`newRemoteTextureViewForDevice:`
  desde 10.15), `MTLCommandBuffer.h` (`GPUStartTime`/`GPUEndTime` desde 10.15).
- **Límites:** no he leído la documentación web de Apple ni he medido nada en ninguna máquina. Son inferencias mías,
  marcadas [I] o [S]: qué tarjetas forman grupo, cómo sincroniza el sistema un IOSurface entre dos tarjetas, el coste
  del cruce, el número de dibujos de una web real y qué mide el contador de AMD. La utilización de las D500 con la 3.x
  no la ha medido nadie.
