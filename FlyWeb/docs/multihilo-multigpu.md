# FlyWeb — multihilo y varias GPU: estudio (FM.56)

ARQUITECTURA, 11-11-2026, por decisión de Titín (vía COORDINACIÓN-39, buzón 20261111-1333). **Solo estudio: sin código
y sin medidas nuevas.** Lo único que he ejecutado es un recuento sobre las tomas de `sample` que LOCAL-21 ya tenía
(§2.2). Propone; decide Titín.

**Revisado el mismo 11-11 con la respuesta de Titín y sus cinco capturas de la 6,1** (§2.4). Cambian las conclusiones
1, 3, 4, 5 y 6 y la recomendación (§6). Las capturas no van al repositorio: enseñan su barra de marcadores. Segunda
respuesta de Titín, también del 11-11: las capturas son de FlyWeb 3.1.0, usa además Basemark, y pregunta si hay algún
puente entre las dos tarjetas (§4.3; ahí sí he leído el registro de hardware de la 6,1, sin ejecutar nada más).

**Apartado añadido el 11-11 por encargo de COORDINACIÓN-39 (buzón 20261111-2118): §9, JavaScript y CPU de muchos
hilos.** Es independiente de §1–§8 y tiene su propia conclusión, sus puertas y sus fuentes.

**Apartado añadido el 13-11 por encargo de COORDINACIÓN-40 (buzón 20261113-1341): §10, los dos estados de Aquarium
con 15 000 peces.** Propone una comprobación sin compilar (M3) para antes de E1 y M1.

Marcas: **[V]** visto en el código, en las cabeceras del SDK o en medidas ya publicadas; **[R]** reanálisis mío de
datos existentes; **[I]** inferido; **[S]** suposición sin comprobar.

**Hipótesis de Titín:** en la 6,1 la GPU ya va al 100 % en las pruebas; el multihilo solo daría poco o nada porque el
cuello pasaría a la GPU; hace falta multihilo y varias GPU a la vez.

**Aclaración de Titín (11-11):** el multihilo de CPU es la base también de varias GPU: el hilo que envía a la tarjeta
se satura, así que hace falta **como mínimo un hilo de envío por tarjeta**. Ve la tarjeta al 100 % en el Historial de
la GPU del Monitor de Actividad: en las pruebas de GPU, en parte de MotionMark y en Aquarium. El reparto de calor ya es
para él una mejora por sí sola.

## 1. Conclusión

1. **Titín tiene razón en dos cosas que la primera versión negaba o dejaba en el aire.** La primera D500 llega al tope
   del medidor en MotionMark (Paths, Canvas Lines, Design, Suits) y pasa tramos largos arriba en Aquarium; la segunda
   no hace nada en ninguna captura (§2.4). Y un hilo de envío por tarjeta es condición para que dos tarjetas rindan
   cuando quien manda es ese hilo.
2. **Lo que mantengo:** en Aquarium con 15 000 peces y la 3.1, los fotogramas los fija un hilo de CPU, y hoy es el del
   JavaScript de la página, no el que envía a la tarjeta, que va al 57–65 % (§2.1, §2.2). Y el medidor arriba no
   significa por sí solo que la tarjeta no dé más (§2.4). Para clasificar hacen falta el medidor y los hilos a la vez.
3. **La prueba «con dos D500 da lo mismo» no vale como prueba** [V código]. Con la rama `flynk-b1d-dosgpu` solo van a
   la segunda tarjeta los lienzos WebGL que piden `powerPreference: "high-performance"`, y Aquarium no lo pide. Salvo
   que LOCAL-18 lo forzara al arrancar, que no consta, aquella medida corrió entera en la tarjeta de la pantalla
   (§4.2). FM.56 y `b1d/README.md:41` se apoyan en ella.
4. **Reparto de calor: decidido por Titín, se entrega.** Para que reparta de verdad, la rama tiene que mandar **toda**
   la WebGL a la segunda D500, no solo la que lo pide; el interruptor ya existe en Chromium (§4.2). Queda así: WebGL en
   la segunda; composición, páginas, lienzo 2D y vídeo en la primera. Condición: que no pierda fotogramas (§6, E1).
5. **El diseño que sale de la tesis de Titín es un hilo de envío por tarjeta** (§3, C′), y es bastante más abordable
   que «un hilo por contexto»: los contextos de la segunda tarjeta ya viven en otro `EGLDisplay`, solo hablan con el
   resto por IOSurface, y Chromium ya trae piezas de un segundo hilo de GPU. Límite: reparte entre **tipos de
   contenido** (la WebGL por un lado; la página y el lienzo 2D por otro), no dentro de un lienzo. Con Aquarium solo
   daría poco: sigue siendo un contexto en un hilo.
6. **MotionMark es el caso donde la tarjeta sí parece mandar, y donde la segunda no puede ayudar tal cual.** Todo su
   trabajo (lienzo 2D, SVG, CSS) va por el contexto de raster, que es uno y está en la tarjeta de la pantalla. Para
   repartirlo habría que pintar en una tarjeta y componer en la otra (§3, F): es lo más caro y depende de lo que
   cueste cruzar cada fotograma, que E1 mide de paso.
7. **Un solo lienzo no se reparte entre dos tarjetas** (§4.1). No cambia.
8. **No hay puente entre las dos D500** [V en la 6,1, §4.3]: cada una cuelga de su propio puerto PCIe del procesador
   y **todas las salidas de pantalla son de una sola**. La otra es, por diseño, un coprocesador con su propia
   memoria, como dice Titín. Lo que pasa de una a otra cruza por la memoria del sistema. De ahí la regla para
   repartir: compensa el trabajo cuyo resultado es pequeño frente a lo que cuesta calcularlo.
9. **Orden propuesto** (§6): E1 (calor, con medida) → M1 con números → puertas P2, P3 y P4. Abaratar el renderer sigue
   siendo lo que más fotogramas da en Aquarium y no depende de nada de esto.

## 2. Pregunta 1: ¿«GPU al 100 %» es la D500 o un hilo de CPU?

### 2.1 Lo ya medido [V]

| Dato | Valor | Fuente |
|---|---|---|
| 3.0.0, Aquarium 15 000 peces, 6,1 | 39,0 fps; `CrGpuMain` al 92,7 %; renderer al 61–62 % | `rendimiento-3x.md` §1, §2.1 |
| Coste por pez en el hilo de GPU | 1,6 µs de CPU | `rendimiento-3x.md` §2.1 |
| Candidata de la 3.1 (t4, cuatro parches de ANGLE) | 15 000 peces: de 39,8 a 41–49 fps (pasadas sueltas de 53,0 y 55,6); `CrGpuMain` baja al 57–65 %; **renderer al 100 %** | `rendimiento-3x.md` §3.1, §3.6 |
| 3.1.0 en la 6,1 | 15 000 peces, mediana 41,9 fps | encargo de COORDINACIÓN-39 |
| WebGL en la segunda D500 (`flynk-b1d-dosgpu`) | 60 / 54 / 37 fps, igual que con una. **No concluyente: no consta que Aquarium llegara a la segunda tarjeta (§4.2)** | `b1d/README.md:41`, LOCAL-18 |
| MotionMark 1.3.2, 6,1 | 1351 (3.0.0) · 1342 (3.0.1) · 1365 (t4): no se mueve con los parches de ANGLE | `rendimiento-3x.md` §3.1 |

Dos hechos bastan para Aquarium con 15 000 peces (el tercero de la primera versión queda retirado):

- **Los parches de la 3.1 solo quitan trabajo de CPU y los fotogramas suben.** Si la D500 hubiera sido el límite a
  39,8 fps, quitar CPU no habría subido nada. La tarjeta dio 53 y 55,6 fps en pasadas sueltas con 15 000 peces: su
  techo está **por encima de 55 fps**; cuánto más arriba, no se sabe.
- **Con la 3.1 el renderer está al 100 % de CPU.** Un hilo que espera a la tarjeta no está al 100 %.
- **Retirado el 11-11:** «mover la WebGL a la otra D500 no cambió nada». No consta que se moviera (§4.2).

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

**No había ninguna medida de utilización de las D500 con la 3.x hasta las capturas de Titín (§2.4), que son a ojo:
faltan los números y los hilos a la vez.** `relevo-local.md:256` anota que `ioreg` da cuatro
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

### 2.4 Capturas de Titín (11-11) [V: las capturas; no van al repositorio]

Cinco capturas de la 6,1 con el Historial de la GPU del Monitor de Actividad junto al navegador, que es
FlyWeb 3.1.0 (Titín, 11-11).

| Captura | Primera D500 | Segunda D500 |
|---|---|---|
| MotionMark 1.3.2, Paths | sube por escalones hasta el tope | plana en cero |
| MotionMark, Canvas Lines | igual; tope en los últimos tramos | cero |
| MotionMark, Design | tope en varios tramos | cero |
| MotionMark, Suits | tope casi continuo | cero |
| Aquarium, 5 000 peces, lienzo 1024×1024, **60 fps** | tramos largos en el tope, con caídas a media escala | cero |

- **La segunda D500 no trabaja nada.** Era de esperar (la 3.1.0 no lleva la rama de dos GPU) y es el dato de partida
  para el calor: hoy toda la carga gráfica cae en una tarjeta.
- **MotionMark lleva la primera tarjeta al tope.** MotionMark sube la complejidad hasta que deja de sostener los
  fotogramas, así que algo se satura por diseño; las capturas dicen que la tarjeta es candidata firme en esas cuatro
  pruebas. Encaja con que la nota no se mueva con los parches de CPU de ANGLE (1351 / 1342 / 1365), por donde también
  pinta Skia (`chrome://gpu`: GaneshGL) [I]. Corrige el «no se sabe qué lo limita» de la primera versión: solo falta
  descartar que un hilo llegue antes, midiendo los dos a la vez.
- **En Aquarium, el tope del medidor no es el tope de la tarjeta** [R]. La captura marca 60 fps con 5 000 peces y el
  medidor arriba. Si a 5 000 la tarjeta no diera más, con 15 000 (el triple de dibujos) rondaría los 20 fps: da 42 y
  sube con parches que solo quitan CPU. O el medidor cuenta tiempo ocupado y llega arriba antes que la tarjeta, o los
  tramos altos son de otro número de peces (el historial abarca más tiempo que la imagen). La captura no lo distingue.
- **«Si añades peces, el hilo que envía a la GPU también se satura»** (Titín): con la 3.0.0, sí (92,7 %). Con la 3.1
  quien llega antes al 100 % es el hilo de la página; el que envía se queda en el 57–65 % [V]. Cuando el renderer se
  abarate, el hilo que envía volverá a ir justo (§3): la tesis vale, con ese orden.
- **Qué mide** [S]: el Historial de la GPU lee, hasta donde sé, el mismo contador del controlador que `ioreg` («Device
  Utilization %»): fracción de tiempo con trabajo, no capacidad que queda.

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
| **C′. Un hilo de envío por tarjeta** (tesis de Titín) | todos los contextos de la segunda tarjeta (la WebGL) en un segundo hilo del proceso de GPU; composición, raster y lienzo 2D siguen en el principal | pequeño con Aquarium solo: sigue siendo un contexto en un hilo, y Viz gasta menos del 1 % [V] | cero: MotionMark no tiene WebGL | No existe en upstream, pero hay piezas [V]: colas del planificador por hilo (`scheduler.h:289-291,370`), gestor de imágenes compartidas con modo seguro entre hilos (`shared_image_manager.h:37-45`), y los contextos de la otra tarjeta ya solo comparten IOSurface (`iosurface_image_backing.mm:999`). Falta el diseño [I] |
| **D. Renderer** | nada: el JavaScript de una página corre en un hilo | — | — | Se abarata, no se reparte: `Math.sin`/`cos` de V8 es el 22–24 % y `IsFeatureEnabled` por dibujo el 3–4 % [V: `rendimiento-3x.md` §2.1]. Sin perfilar con la 3.1 (§5 de ese documento) |
| **E. Raster de páginas en varios hilos** | el dibujo de teselas | no aplica | podría mover MotionMark solo si lo limitara un hilo; las capturas de §2.4 apuntan a la tarjeta | Es el diseño de Graphite; mismo bloqueo que A |
| **F. Pintar en una tarjeta y componer en la otra** | el contexto de raster (páginas, lienzo 2D, SVG) en la segunda tarjeta con su hilo; composición y pantalla en la primera | no aplica | es lo único que llevaría MotionMark a la segunda tarjeta | No existe. Hoy raster y composición comparten un único estado de contexto (`gpu_channel_manager.h:212`, `raster_command_buffer_stub.cc:66` [V]). Cada lienzo y cada tesela que cambie cruzaría de tarjeta |

Lectura:

- **Aquarium con 15 000 peces tiene hoy el techo en el renderer, en torno a 42–50 fps.** Para llegar a 60 hace falta
  quitarle al renderer alrededor de un 30 % de CPU por fotograma [R: 24 ms → 16,7 ms]. Ningún reparto de hilos del
  proceso de GPU lo consigue. Solo después de eso el hilo de GPU volvería a ir justo (rondaría el 85–100 % a 60 fps
  [R]) y la opción B empezaría a rendir.
- **MotionMark no depende del hilo de WebGL.** Sus pruebas son DOM, CSS, SVG y lienzo 2D, y todo eso se pinta por el
  contexto de raster del proceso de GPU, en la tarjeta de la pantalla. Las capturas de Titín (§2.4) ponen esa tarjeta
  en el tope en cuatro pruebas: lo más probable es que mande la tarjeta [I]; falta ver los dos hilos a la vez. En la
  7,1 la diferencia con Chrome salió del renderer: las reglas de estilo del filtrado cosmético
  (`rendimiento-motionmark.md`). Ni B ni C′ lo mueven; solo F.
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
propio, sin donante. El caso (la tarjeta saturada con un solo lienzo) puede ser el de las pruebas de lienzo 2D de
MotionMark (§2.4), pero ahí el trabajo ni siquiera pasa por ANGLE como WebGL: lo que cabe estudiar es F (§3), que
mueve el lienzo entero a la otra tarjeta, no lo parte.

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
  WebGL **que pide alto rendimiento** en la otra. Solo actúa por debajo de 10.15. Trae `FLYWEB_METAL_DISPLAY_GPU=1` para
  comparar y escribe en el registro «FlyWeb: Metal device by id» cuando un contexto usa la otra tarjeta.
- **Qué WebGL va a la segunda tarjeta, exactamente** [V]: Blink solo pide la tarjeta potente si la página crea el
  contexto con `powerPreference: "high-performance"`; `"default"` y `"low-power"` van a la de por defecto
  (`webgl_context_attribute_helpers.cc:41-49`, `gles2_command_buffer_stub.cc:157-163`). Aquarium crea el suyo con
  `{antialias: false, xrCompatible: true}`, sin `powerPreference` (`aquarium.js:892`, leído hoy de webglsamples.org).
  Hay un interruptor de pruebas, apagado, que trata toda la WebGL como de alto rendimiento:
  `ForceHighPerformanceGPUForWebGL` (`blink/common/features.cc:736`, `webgl_rendering_context_base.cc:737-745`).
- **Consecuencia:** el «60 / 54 / 37, igual que con una» de LOCAL-18 solo prueba algo si arrancó con
  `--enable-features=ForceHighPerformanceGPUForWebGL`. Ni los commits ni `b1d/README.md` lo dicen. Hay que repetirla
  comprobando el registro y el Historial de la GPU. Y, tal cual está, la rama casi no repartiría calor: pocas páginas
  piden alto rendimiento [S].
- **Coste de cruzar para componer** [S, sin medir aislado]: un lienzo de 1024×1024 son 4 MB por fotograma (0,25 GB/s a
  60 fps); uno de 3840×2160, 33 MB (2 GB/s). El ancho de banda de PCIe da de sobra; lo que puede doler es la
  sincronización de cada fotograma entre las dos tarjetas. Con el lienzo de 1024 de Aquarium no consta que llegara a
  cruzar (punto anterior). A pantalla completa no se ha probado; las cifras con la pantalla de Titín, en §4.3. Indicio en contra: cuando **todo** se pintaba en la tarjeta sin pantalla,
  MotionMark dio 140 frente a los 1381 de después (`coordinacion.md:580`), aunque entre las dos medidas cambiaron
  más cosas y no se puede atribuir solo al cruce [V].
- **En la 7,1 (10.15 o posterior, hasta cuatro módulos):** la rama no actúa. Extenderla es la misma idea. La 7,1 de
  Titín lleva una W6600X (`rendimiento-3x.md` §5): con una tarjeta no hay nada que repartir.

### 4.3 ¿Hay algún puente entre las dos D500? (pregunta de Titín, 11-11)

Leído en la 6,1 con `ioreg` y `system_profiler`, sin ejecutar nada más [V]:

- **Cada D500 cuelga de su propio puerto raíz PCIe del procesador** (`GFXA@2` → `GFX1`, `GFXB@3` → `GFX2`), cada una
  con su enlace PCIe 3.0 de 16 carriles (estado de enlace 0x1103 en las dos). No comparten conmutador ni hay ningún
  dispositivo que las una.
- **Todas las salidas de pantalla son de una sola tarjeta:** `GFX2` tiene seis salidas (`ATY,KaniS@0` a `@5`) y `GFX1`
  una sola de relleno (`ATY,Kani@0`). La otra tarjeta no puede llevar un monitor: Apple la montó como coprocesador.
- **3 GB de memoria cada una**, sin compartir. Una textura vive en una tarjeta; para usarla en la otra hay que copiarla.

Qué significa:

- **No hay puente directo.** Lo que una tarjeta manda a la otra baja por su enlace PCIe a la memoria del sistema y
  sube por el de la otra. La CPU no copia byte a byte (lo hacen los controladores por DMA), pero sí lo ordena, y cada
  cruce exige sincronizar las dos tarjetas [I].
- **macOS no ofrece nada mejor en Mojave.** Los grupos de tarjetas de Metal son de 10.15 y de tarjetas que el sistema
  declara unidas (§4); en hardware eso es el puente Infinity Fabric Link de algunos módulos de la 7,1 [I]. El CrossFire
  de estas D500 bajo Windows va también por PCIe, sin puente físico [I].
- **El enlace no es el límite; la sincronización puede serlo.** Un enlace PCIe 3.0 ×16 mueve unos 15 GB/s teóricos. La
  pantalla de Titín está a 3008×1692 [V]: un lienzo a pantalla completa son 20 MB por fotograma, 1,2 GB/s a 60 fps.
  LOCAL-21 midió en esa pantalla `devicePixelRatio` = 1 (`entregas/local21/paso2/resultados-sp-js.json` [V]): no es
  un modo escalado y valen esos 20 MB. Cuánto cuesta de verdad el cruce solo lo dice la medida de E1.
- **Regla para decidir qué repartir:** compensa mandar a la segunda tarjeta el trabajo cuyo resultado es pequeño
  frente a lo que cuesta calcularlo. Una WebGL con sombreadores caros en un lienzo mediano compensa. Las teselas de
  una página o un lienzo 2D a pantalla completa, que se pintan rápido y pesan mucho, compensan mal: es el riesgo de F.

**Cuándo ayuda:** para el calor, siempre que haya WebGL en pantalla y toda vaya a la segunda tarjeta. Para los
fotogramas, cuando la tarjeta de la pantalla esté saturada y parte del trabajo sea WebGL. No ayuda a una página cuyo
trabajo es DOM, CSS o lienzo 2D (todo eso va en el contexto de raster, que es uno), ni a nada limitado por CPU
mientras las dos tarjetas las alimente el mismo hilo.

## 5. Pregunta 4: ganancia, riesgo, tamaño y mantenimiento

| Opción | Ganancia en páginas reales | Riesgo | Tamaño | Qué se rompe en cada actualización de Chromium |
|---|---|---|---|---|
| **Abaratar el renderer de WebGL** (no es de este estudio; es lo que manda hoy) | la mayor: todas las páginas con WebGL y Aquarium | bajo-medio | parches pequeños, como los de ANGLE de la 3.1 | poco: parches locales |
| **Toda la WebGL en la segunda tarjeta** (`flynk-b1d-dosgpu` + forzar alto rendimiento) | reparte el calor en cualquier página con WebGL; fotogramas: sin medir de verdad (§4.2), posible donde mande la tarjeta | medio: el cruce a pantalla completa sin medir; vídeo o lienzo 2D usados como textura WebGL cruzan de tarjeta [I]; memoria de texturas repartida en dos tarjetas | **51 líneas ya escritas** más forzar la preferencia (pocas líneas [I]); falta probar y medir | poco. Depende de que upstream conserve `kEGLDualGPURendering`, que tiene un «quitar tras probar» pendiente (`gles2_command_buffer_stub.cc:149` [V]) |
| **B. Codificador de Metal en otro hilo** | cero hoy; hasta ×1,5 del hilo de GPU en páginas con miles de dibujos, cuando el renderer deje de mandar | alto: orden con blits, `present`, consultas de oclusión, vida de los objetos (`rendimiento-3.1.md` §3, cambio 5) | medio: `mtl_command_buffer.mm` y `ContextMtl.mm` | bastante: es el fichero más movido de ANGLE Metal; parche propio que rebasar en cada salto |
| **C. Un hilo (y una tarjeta) por contexto WebGL** | solo con varios lienzos WebGL pesados visibles a la vez: raro | muy alto: imágenes compartidas entre hilos, contextos de ANGLE con hilo propio, pérdida de contexto | grande: `gpu/ipc/service`, planificador, imágenes compartidas, ANGLE | mucho: toca el corazón del proceso de GPU, que upstream está cambiando hacia Graphite. Iríamos contra la corriente |
| **C′. Un hilo de envío por tarjeta** | páginas con WebGL pesada y, a la vez, página o lienzo 2D pesados: cada mitad con su hilo y su tarjeta. Poco con un solo lienzo WebGL | alto: orden entre hilos de las imágenes compartidas, pérdida de contexto, `present` | medio-grande: `gpu/ipc/service` (canal y stub de WebGL), planificador; ANGLE casi no, porque el otro `EGLDisplay` ya está aislado [I] | bastante: zona que upstream mueve hacia Graphite, aunque las piezas que se reutilizan son las de DrDC y esas las mantiene upstream |
| **A/E. DrDC y raster en varios hilos (Graphite)** | fluidez de la interfaz con una WebGL pesada; quizá MotionMark | para Mojave, el de traducir Graphite (más de 20 h y regresiones de GPU, `DIRECTIVAS.md:71`) | cero en 10.15 o posterior (es de serie); enorme en Mojave | nada: lo mantiene upstream. Pero exige reabrir la directiva de Graphite |
| **F. Pintar en una tarjeta y componer en la otra** | MotionMark y páginas pesadas sin WebGL, si el cruce no se come la ganancia | muy alto: cada lienzo y tesela cruza de tarjeta; indicio en contra en `coordinacion.md:580` | grande: segundo estado de contexto, todas las imágenes compartidas de raster entre tarjetas | mucho |
| **Un lienzo entre dos tarjetas** | ninguna demostrable | muy alto | enorme, sin donante | todo |

## 6. Pregunta 5: recomendación y puertas

**Decidido por Titín el 11-11: el reparto de calor se entrega aunque no dé fotogramas.** La antigua puerta P1 pasa a
ser un encargo, E1, y la medida M1 se hace con él.

**E1 (propuesta para LOCAL; rama `flynk-b1d-dosgpu` sobre la 3.1; una compilación).**

1. Añadir a la rama que, con dos tarjetas iguales y por debajo de 10.15, toda la WebGL se trate como de alto
   rendimiento (lo que hace hoy el interruptor de pruebas de §4.2).
2. Comprobar que actúa: registro «FlyWeb: Metal device by id» con la segunda tarjeta y las dos trabajando en el
   Historial de la GPU con Aquarium. Sin esto no se mide nada.
3. A/B contra la 3.1.0: Aquarium con 5 000, 10 000 y 15 000 peces; un lienzo WebGL a 4K (el coste del cruce);
   MotionMark entero (no debe cambiar); vídeo; una página que use vídeo o lienzo 2D como textura WebGL; pérdida de
   contexto; Basemark Web y la batería de `pruebas-gpu.md`. Cambiar el monitor de tarjeta no aplica: en la 6,1 todas
   las salidas son de la misma (§4.3).
4. **Se entrega si no pierde más del 2 % en ningún caso.** Ganar fotogramas no es condición.
5. Apagado de emergencia: `FLYWEB_METAL_DISPLAY_GPU=1`, que ya existe.

**M1 (LOCAL, 6,1; primero con la 3.1.0 publicada, sin compilar, y repetida con E1).** Para cada caso, a la vez:
utilización de cada D500 en números, CPU del hilo del renderer y de `CrGpuMain`, y fotogramas (§2.3), más el barrido
de lienzo donde se pueda. Casos:

1. Aquarium con 5 000 y 15 000 peces (aclara la captura de §2.4).
2. MotionMark, **prueba por prueba**: confirma o no que en Paths, Canvas Lines, Design y Suits manda la tarjeta.
3. La batería de Titín (`pruebas-gpu.md`, 12 webs: three.js, Babylon, Google Earth, Photopea, Shadertoy, YouTube 4K…)
   y **Basemark Web**, que Titín usa y que no está en esa lista. Maps, cuando deje de tumbar el proceso de GPU
   (`rendimiento-3x.md` §3.3).
4. Vídeo 4K a 60 con una página WebGL al lado, como caso de dos cargas a la vez.
5. En cada caso se anotan la resolución y `window.devicePixelRatio`: los píxeles que pinta la tarjeta dependen de eso.

Entregable: una tabla con la clasificación de §2.3 por caso, con una tarjeta y con dos.

| Puerta | Se abre si… | Entonces |
|---|---|---|
| **P2. Codificador de Metal en otro hilo (B)** | una página real, no solo Aquarium, con `CrGpuMain` ≥ 90 % por debajo de 60 fps y codificador + controlador ≥ 25 % del hilo | prototipo en una rama de avance; se sigue si da **≥ 20 % de fotogramas** |
| **P3. Un hilo de envío por tarjeta (C′)** | E1 entregado y, con E1, un caso con `CrGpuMain` ≥ 90 % por debajo de 60 fps y las dos tarjetas con trabajo (WebGL más página o lienzo 2D pesados) | estudio de diseño de ARQUITECTURA antes de tocar nada; prototipo en rama de avance; se sigue si da **≥ 20 %** |
| **P4. Pintar en una tarjeta y componer en la otra (F)** | M1 confirma que en MotionMark manda la tarjeta (los dos hilos por debajo del 85 %) y E1 mide que cruzar un lienzo 4K por fotograma cuesta menos del 10 % | estudio de diseño aparte |

Hoy, con lo medido: P2 no se abre (`CrGpuMain` al 57–65 % en Aquarium) y P3 y P4 esperan a E1 y M1.

**Añadido el 13-11:** con la 3.1.1, Aquarium con 15 000 peces va en dos estados, y en el rápido `CrGpuMain` está al
89–91 % a 55–57 fps (§10). Roza la condición de P2, pero es Aquarium: sigue faltando una página real. Antes de E1 y
M1 conviene M3 (§10.4), que no compila nada.

**Lo que no depende de nada de esto**, y sigue siendo lo que más da en Aquarium: perfilar el hilo principal del
renderer con la 3.1 (pendiente en `rendimiento-3x.md` §5) y abaratarlo. Cuando baje, `CrGpuMain` vuelve a ir justo y
P2 y P3 se abren solas.

**Sobre la tesis de Titín:** de acuerdo en el fondo. Dos tarjetas alimentadas por un hilo no rinden más que una
cuando manda ese hilo, y por eso el diseño de destino es un hilo de envío por tarjeta. Tres matices: (1) repartir por
tarjeta reparte entre tipos de contenido, no dentro de un lienzo; (2) en Aquarium con la 3.1 el hilo saturado es el
de la página, que no se puede repartir; (3) donde la tarjeta manda de verdad, que parece ser MotionMark, lo que hay
que mover es el raster, y eso es F, no la WebGL.

## 7. Para Titín

1. **Contestado (11-11):** ve el 100 % en el Historial de la GPU del Monitor de Actividad, en MotionMark y en
   Aquarium (§2.4). **Completado el mismo día:** las capturas son de FlyWeb 3.1.0 y usa además Basemark; la lista de
   webs es `pruebas-gpu.md`. No queda nada pendiente de este punto.
2. **Reparto de calor: decidido, sí** (11-11). Dos avisos. Tal cual está, la rama casi no repartiría, porque solo mueve
   la WebGL que pide alto rendimiento: E1 la cambia para mover toda. Y aun así, una página sin WebGL (y MotionMark)
   seguirá entera en la primera tarjeta; repartir eso es F, que es otro tamaño de trabajo.
3. **Graphite.** DrDC y el raster en varios hilos son el camino multihilo que mantiene upstream, y en Mac dependen de
   Graphite, hoy fuera por su directiva del 27-10. No propongo reabrirla; lo anoto porque es lo único de esta lista
   que no habría que mantener a mano, y solo valdría para 10.15 o posterior.
4. **E1 queda propuesto a COORDINACIÓN para LOCAL** como consecuencia del punto 2: una compilación y una mañana de
   medidas en la 6,1. No necesita otra respuesta de Titín salvo que quiera cambiar la condición del 2 %.

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
- **Revisión del 11-11:** capturas de Titín (no publicadas); `third_party/blink/renderer/modules/webgl/`
  `webgl_context_attribute_helpers.cc:41-49` y `webgl_rendering_context_base.cc:737-745`,
  `third_party/blink/common/features.cc:736`, `gpu/ipc/service/gles2_command_buffer_stub.cc:157-163`,
  `gpu/ipc/service/gpu_channel_manager.h:212`, `gpu/ipc/service/raster_command_buffer_stub.cc:66`,
  `gpu/command_buffer/service/shared_image/shared_image_manager.h:37-45`; mensajes de los commits `b8a4abda2f` y
  `dc5ef06`; `aquarium.js` y `tdl/webgl.js` de webglsamples.org.
- **Hardware de la 6,1** (11-11, solo lectura): `system_profiler SPDisplaysDataType` e `ioreg -p IODeviceTree`.
- **Límites:** no he leído la documentación web de Apple ni he medido rendimiento en ninguna máquina. Son inferencias mías,
  marcadas [I] o [S]: qué tarjetas forman grupo, cómo sincroniza el sistema un IOSurface entre dos tarjetas, el coste
  del cruce, el número de dibujos de una web real, qué mide el contador de AMD y que el Historial de la GPU lea ese
  mismo contador. De la utilización de las D500 con la 3.x solo hay las capturas de Titín, a ojo. Cómo arrancó
  LOCAL-18 la prueba de dos GPU no consta: que no llegara a la segunda tarjeta es lo que dice el código, no un
  registro de aquella sesión. C′ y F son esbozos: ninguno tiene diseño.

## 9. JavaScript y CPU de muchos hilos (añadido el 11-11)

Pregunta de Titín (vía COORDINACIÓN-39): las máquinas tienen muchos hilos (6,1: 24; 5,1: 16; portátiles: 4 o más).
¿Cuánto más se puede sacar de JavaScript y de la página usando varios, y qué repercute en lo demás? Solo estudio. He
ejecutado un recuento nuevo sobre tomas de `sample` que LOCAL-21 ya tenía (`FlyWeb/tools/rendimiento/reparto-renderer.py`)
y he leído el árbol 156. Mismas marcas que arriba.

### 9.1 Conclusión

1. **El JavaScript de una página corre en un solo hilo y el navegador no puede repartirlo.** Lo impone el lenguaje, no
   Chromium. Lo que el navegador sí reparte es lo de alrededor: recolector de basura, compilación, raster,
   decodificación, red, y cada sitio en su proceso.
2. **Los topes generales ya crecen con los núcleos** [V]: el grupo de hilos de cada renderer admite los hilos lógicos
   menos uno (23 en la 6,1, 15 en la 5,1, 3 en un portátil de 4), y V8 toma ese mismo número. Se quedan por debajo unos
   pocos topes fijos: marcado concurrente (7), recolector joven (8), Maglev (2), TurboFan (4) y raster (4) (§9.3).
3. **En Aquarium subirlos no da nada** [R]: el recolector y la compilación, que es lo que V8 sabe hacer en otros
   hilos, suman el 0,1 % del hilo principal. De los 22 hilos del renderer solo 4 tienen alguna actividad, y 3 de ellos
   por debajo del 3 %. El hilo está lleno de JavaScript de la propia página (56–65 %) y del coste de llamar a WebGL
   (32–40 %) (§9.2).
4. **De Speedometer no hay ningún perfil.** Es lo único que falta y lo único que pido medir (§9.6, M2). Lo más
   parecido que existe es el perfil de Multiply en la 7,1: ahí el 78 % del hilo es el ciclo de estilo, layout y
   pintado, y el estilo solo, el 51 %.
5. **Estilo en paralelo como Stylo: inabordable en Blink, y no hay nada parcial que aprovechar** [V] (§9.4). Lo que sí
   rinde en el estilo es abaratarlo: en Multiply ya apareció un 22 % del hilo en una sola causa.
6. **Recomendación:** no tocar hilos a ciegas. Una medida sin compilar (M2) y cuatro puertas con número (§9.6). Lo
   que más da por página sigue siendo abaratar el hilo principal; los 24 hilos de la 6,1 rinden con muchas pestañas,
   no con una.

### 9.2 Punto 1: en qué se va el hilo principal del renderer [R]

**Aquarium con 15 000 peces, 6,1.** Reparto de las muestras activas del hilo principal, con las tomas de
`entregas/local21` simbolizadas con el dSYM de cada compilación. `sample` congela el renderer en cada toma, así que
vale el reparto, no el porcentaje de ocupación (`rendimiento-3x.md` §2.1).

| En qué | 3.0.0 (`paso3`) | 3.1 candidata, pasada 1 (`c31/t4`) | 3.1 candidata, serie (`c31/t4-aq`) |
|---|---|---|---|
| Código JavaScript compilado (JIT) | 26,3 % | 33,9 % | 36,2 % |
| `Math.sin` / `Math.cos` (`ieee754`) | 22,4 % | 21,2 % | 23,1 % |
| V8: accesos a propiedades (IC megamórfico) y resto | 7,0 % | 5,8 % | 5,4 % |
| **JavaScript de la página, suma** | **55,7 %** | **60,9 %** | **64,7 %** |
| Enlaces WebGL de Blink, con el paso de V8 a Blink | 28,8 % | 25,7 % | 22,3 % |
| Cliente del búfer de órdenes (`GLES2Implementation`) | 6,2 % | 5,6 % | 4,5 % |
| `base::FeatureList` (consulta por dibujo) | 5,3 % | 4,7 % | 5,0 % |
| **Coste de llamar a WebGL, suma** | **40,3 %** | **36,0 %** | **31,8 %** |
| Estilo, layout y pintado | 3,4 % | 1,9 % | 2,1 % |
| Recolector de basura (V8 y Oilpan) | 0,1 % | 0,1 % | 0,0 % |
| Compilar JavaScript en el hilo principal | 0,0 % | 0,0 % | 0,0 % |
| Muestras activas | 1014 | 782 | 779 |

Los demás hilos del mismo proceso, en la toma de la serie: 22 hilos, de ellos 11 del grupo de trabajo; con alguna
muestra activa, 4: el principal, `Compositor` (1,9 %), `Chrome_ChildIOThread` (0,3 %) y un hilo de trabajo (0,3 %).

Lectura:

- **No hay nada que mandar a otro hilo.** Lo que V8 puede sacar del hilo principal (recolector, compilación) aquí no
  pesa. Más hilos, o topes más altos, darían cero.
- **Lo que se puede abaratar, y es trabajo de MOTOR, no de hilos:** la consulta de `FeatureList` en cada dibujo (5 %,
  basta guardarla una vez); la comprobación de tipos al pasar de V8 a Blink (`V8PerIsolateData::HasInstance` y
  parecidas pesan alrededor de un quinto de los enlaces); y `sin`/`cos`, que V8 calcula con su versión propia de
  `ieee754` y son un 21–23 % [V en la toma].
- **Una página sí puede usar otro núcleo si quiere:** un `Worker` con `OffscreenCanvas` saca su WebGL del hilo
  principal. Es decisión de quien escribe la página; el navegador no puede hacerlo por ella.

**Speedometer 3.1: no hay perfil.** LOCAL-21 midió la nota (10,3 en la 6,1 con la 3.0.0; con la 3.0.1, 10,48 sin Maglev y
11,19 con él; la 6,1 da el 55 % de la 7,1) pero no tomó `sample`. Lo que se sabe sin perfil: es una prueba de un solo hilo por diseño
(marcos de JavaScript que tocan el DOM y, tras cada paso, el estilo y el layout) [I], y que la 6,1 saque el 55 % de
la 7,1 encaja con lo que rinde un núcleo de cada una, no con sus hilos (24 y 32) [I].

**Lo más cercano que existe: Multiply de MotionMark en la 7,1** (`rendimiento-motionmark.md`, candidata 3.1): el 78 %
del hilo activo en `UpdateAllLifecyclePhases` y el **51 % en recalcular estilo**, con un 22 % en una sola causa (el
atributo `style` reescrito como texto por una regla `[style…]` del filtrado cosmético). En páginas de DOM el peso
está en el estilo, no en V8.

### 9.3 Punto 2: topes de hilos en Chromium 156 y V8 [V]

| Tope | En el código | 6,1 (24) | 5,1 (16) | Portátil (4) | ¿Por debajo de los núcleos? |
|---|---|---|---|---|---|
| Grupo de hilos del renderer | hilos lógicos − 1, mínimo 3 (`render_process_impl.cc:75-82`, `thread_pool_util.cc:13-17`) | 23 | 15 | 3 | no |
| Hilos de trabajo de V8 | los del grupo anterior (`gin/v8_platform.cc:271-277`) | 23 | 15 | 3 | no |
| Grupo de hilos del navegador | 0,6 × lógicos, entre 16 y 32 (`startup_helper.cc:59-63,74-81`) | 16 | 16 | 16 | sí en la 6,1, y no importa: es entrada y salida |
| Marcado concurrente del recolector | 7 (`flag-definitions.h:2579`; 0 = todos) | 7 | 7 | 3 | **sí** |
| Recolector joven en paralelo | mínimo de 8 y los núcleos (`scavenger.cc:1582-1594`) | 8 | 8 | 4 | **sí** |
| Actualización de punteros | 8 (`mark-compact.cc:5406`) | 8 | 8 | 4 | **sí** |
| Compactación en paralelo | todos los núcleos (`mark-compact.cc:247-262`) | 24 | 16 | 4 | no |
| Maglev concurrente | 2 (`flag-definitions.h:619`) | 2 | 2 | 2 | **sí** |
| TurboFan concurrente | 4 (`flag-definitions.h:1289`) | 4 | 4 | 3 | **sí** |
| Sparkplug concurrente | 1 (`flag-definitions.h:1220`) | 1 | 1 | 1 | **sí** |
| Compilación de WebAssembly | 128 o los hilos de trabajo (`flag-definitions.h:1984`) | 23 | 15 | 3 | no |
| Hilos de raster del renderer | lógicos ÷ 2, entre 1 y 4 (`compositor_util.cc:49-50,406-438`) | 4 | 4 | 2 | **sí** |

**Qué daría subirlos:**

- **Recolector (7 y 8).** Solo gana donde el recolector pese en el hilo principal. En Aquarium es el 0,1 %. V8 ya dice
  lo que consiguió al repartirlo: el marcado concurrente quitó el 60–70 % del marcado del hilo principal, y el
  recolector joven en paralelo, el 20–50 % de su tiempo (v8.dev). Con más hilos la pausa se divide entre los que
  participan, «más la sincronización»: de 8 a 16 se gana, como mucho, la mitad de algo ya pequeño. **Esperado: menos
  del 1 % en lo medido** [I].
- **Maglev (2) y TurboFan (4).** No aceleran el código: acortan lo que tarda en estar optimizado. Puede notarse en
  pruebas de arranque en frío y en Speedometer, donde cada caso dura poco [S]. Se prueba **sin compilar**, con
  `--js-flags`.
- **Raster (4).** Con el raster en la GPU, estos hilos decodifican imágenes y preparan órdenes de pintado. Solo ganaría
  una página con muchas imágenes grandes [S]. El interruptor `--num-raster-threads` existe pero el código lo recorta
  a 4: subirlo es cambiar una constante.

**Coste, y los portátiles de 4 hilos:**

- **Si se suben como techos, a un portátil de 4 hilos no le cambia nada:** su grupo es de 3 hilos y ya está por debajo
  de todos estos topes. El riesgo de memoria y calor en portátiles es nulo mientras no se fuerce un mínimo.
- **En la 6,1:** los hilos se crean cuando hay trabajo y se retiran al quedar ociosos; cada uno cuesta su pila y poco
  más [I]. El calor es el del trabajo, que es el mismo repartido en menos tiempo.
- **Riesgo real:** son valores que upstream prueba tal cual. Con otros, las carreras raras las encontramos nosotros.
  Por eso, si se tocan, con interruptores y solo en máquinas de muchos hilos, nunca cambiando constantes de V8.

### 9.4 Punto 3: estilo en paralelo

**Qué hace Stylo** (hacks.mozilla.org, 2017): reparte el cálculo de estilo entre núcleos. Los hijos de cada nodo se
agrupan en unidades de trabajo y los núcleos ociosos roban trabajo de las colas de los otros. Lo hace seguro Rust, que
comprueba al compilar que no hay carreras. Lo acompaña con un árbol de reglas y una caché de estilos compartidos. El
artículo afirma aceleraciones casi lineales con los núcleos, sin dar medidas.

**Por qué no se puede llevar a Blink** [V]:

- El estilo calculado es un objeto del recolector de Blink (`ComputedStyleBase : GarbageCollected`,
  `computed_style_base.h.tmpl:101`), igual que el DOM. El montón de Oilpan pertenece a un hilo (`cppgc/heap.h:88,107`).
  Otro hilo no puede crear ni leer esos objetos mientras el principal trabaja.
- Las cadenas internas (nombres de etiqueta, clases, atributos) viven en una tabla por hilo (`atomic_string_table.cc`).
- En `core/css`, `core/style`, `core/layout` y `core/paint` no hay ni un solo envío de trabajo a otro hilo fuera de
  las pruebas: no existe una base parcial que ampliar.
- Stylo salió de escribir de nuevo el motor de estilo en Rust, con años de trabajo de un equipo. En Blink sería
  rehacer el estilo, el DOM que lee y su gestión de memoria. **Inabordable para FlyWeb, y sin donante upstream** [I].

**Lo que Blink ya saca del hilo principal** [V, `blink/common/features.cc`]: composición, desplazamiento y animaciones
de `transform` y `opacity`; raster y decodificación de imágenes; compilación de scripts mientras se descargan
(`kScriptStreaming`, encendido); la caché de código (`kConsumeCodeCacheOffThread`, encendido); la descarga de recursos
(`kBackgroundResourceFetch`, encendido). **Apagados de serie:** el escáner de precarga en otro hilo
(`kThreadedPreloadScanner`), precompilar scripts en línea (`kPrecompileInlineScripts`) y cargar el cuerpo en otro hilo
(`kThreadedBodyLoader`). Son lo único «parcial» que hay, afectan a la carga de la página y no al estilo, y por qué
upstream los dejó apagados no lo sé [S].

**Lo que sí rinde en el estilo:** abaratarlo. El 22 % de Multiply en una regla `[style…]` es el ejemplo, y ya tiene
arreglo propuesto (`rendimiento-motionmark.md`, MOTOR-44).

### 9.5 Dónde rinden hoy muchos hilos, y qué repercute en lo demás

- **Muchas pestañas y sitios a la vez:** cada sitio va en su proceso, con su hilo principal. Es el reparto que de
  verdad usa los 24 hilos de la 6,1 [I].
- **Páginas que lo piden:** `Worker`, WebAssembly con hilos, `OffscreenCanvas`.
- **Alrededor de la página:** decodificación de vídeo e imágenes, red, raster, y el proceso de GPU (§3).
- **Repercusión con §1–§8:** cuando el hilo de la página se abarate, Aquarium volverá a depender del hilo que envía a
  la tarjeta (§3) y entonces abren las puertas P2 y P3. Nada de este apartado cambia E1 ni M1.

### 9.6 Punto 4: recomendación y puertas

**M2 (LOCAL, 6,1, 3.1.0 publicada y su dSYM; sin compilar; se hace con E1 y M1, después de la 3.2):**

1. `sample` del renderer durante Speedometer 3.1 y durante JetStream 3, pasado por `reparto-renderer.py`: la tabla de
   §9.2 para las dos pruebas, más `ps -M` de todos los hilos del renderer para ver cuántos trabajan.
2. A/B con `--js-flags="--concurrent-maglev-max-threads=6 --concurrent-turbofan-max-threads=8
   --concurrent-marking-max-worker-num=0"` frente a los valores de serie: Speedometer y JetStream, tres pasadas, y la
   memoria del renderer al acabar. El tope de Maglev solo cuenta si Maglev está encendido en la versión que se mida
   (directiva B6): anotarlo de `chrome://version`.
3. Opcional: A/B con `--enable-features=ThreadedPreloadScanner,PrecompileInlineScripts,ThreadedBodyLoader` en el
   tiempo de carga de cinco webs de `pruebas-gpu.md`.

| Puerta | Se abre si M2 da… | Entonces |
|---|---|---|
| **J1. Más hilos de compilación de V8** | el A/B del punto 2 gana **≥ 3 %** en Speedometer o en JetStream, no pierde más del 1 % en ninguno y la memoria del renderer no sube más del 5 % | esos valores pasan a ser los de serie **solo en máquinas de 12 hilos o más**; en las demás, los de upstream |
| **J2. Más hilos del recolector** | el recolector es **≥ 10 %** del hilo principal en Speedometer o JetStream | repetir el A/B solo con los topes del recolector |
| **J3. Estilo** | el estilo es **≥ 30 %** del hilo principal en Speedometer | no paralelizar: perfilar qué reglas pesan, como se hizo con Multiply (MOTOR) |
| **J4. Raster** | en M1, una página real con los 4 hilos de raster a ≥ 80 % cada uno | subir el tope a 8 en máquinas de 16 hilos o más (una constante) |

Hoy, con lo medido: ninguna abierta. **No hacer:** estilo en paralelo, ni nada que prometa repartir el JavaScript de
una página.

**Lo que no depende de M2**, y está en la tabla de §9.2: la consulta de `FeatureList` por dibujo, la comprobación de
tipos en los enlaces WebGL y `sin`/`cos`. Es la lista para abaratar el renderer de WebGL.

### 9.7 Para Titín

- **Respuesta corta:** de una sola página, con más hilos, casi nada. Su JavaScript va en un hilo y lo demás que
  Chromium reparte ya está repartido. Con muchas pestañas, la 6,1 sí usa sus 24 hilos.
- **Lo que queda por ganar por página** está en hacer más barato ese hilo, no en añadir otros.
- No hay ninguna decisión pendiente tuya en este apartado. M2 no compila nada y espera a la 3.2 con E1 y M1.

### 9.8 Fuentes y límites de este apartado

- **Tomas** (LOCAL-21, `entregas/local21`): `paso3/sample-aquarium15k-renderer.txt`, `c31/t4/…-renderer.txt`,
  `c31/t4-aq/…-serie-renderer.txt`; dSYM en `temp/local21/dsym` y `dsym-t4`; `paso2/resultados-sp-js.json`.
  Guion: `FlyWeb/tools/rendimiento/reparto-renderer.py`.
- **Documentos:** `rendimiento-3x.md` §1, §2.1, §3.6, §3.7 y §4; `rendimiento-motionmark.md` (perfil de Multiply).
- **Código** (árbol `flynk-b1d`, Chromium 156, V8 15.6): los ficheros citados en §9.3 y §9.4;
  `base/task/thread_pool/initialization_util.cc:15-23`.
- **Web:** v8.dev/blog/concurrent-marking (2018), v8.dev/blog/trash-talk (2019) y el artículo de Stylo en
  hacks.mozilla.org (2017). Ninguno da el número de hilos que usa ni el coste en máquinas pequeñas.
- **Límites:** las tomas son de Aquarium; de Speedometer y JetStream no hay ninguna. El reparto por categorías sale de
  patrones sobre los nombres de las funciones: una función mal clasificada mueve algún punto, no la conclusión. No he
  medido nada nuevo. Son suposiciones [S] la ganancia de Maglev y TurboFan con más hilos, la de raster y el motivo de
  los tres interruptores apagados; e inferencias [I] el coste por hilo y que Speedometer sea de un solo hilo.

## 10. Aquarium con 15 000 peces va en dos estados (añadido el 13-11)

Encargo de COORDINACIÓN-40 (buzón 20261113-1341). LOCAL-19 midió la 3.1.1 en la 6,1 (`TAREAS.md`, FS.44): cada
pasada se queda en **~41 fps** o en **55–57 fps**, sin intermedios. COORDINACIÓN propone que lo decide dónde coloca
macOS los dos hilos (hermanos SMT o no) y pide una comprobación sin compilar. Solo papel: he recontado medidas ya
publicadas y he leído, sin lanzar nada, qué herramientas hay en la 6,1. Mismas marcas que arriba.

### 10.1 Conclusión

1. **Lo que cambia entre los dos estados es el renderer, no el hilo de GPU** [R]. El hilo de la página gasta unos
   24 ms de CPU por fotograma en el estado lento y unos 15,5 ms en el rápido. `CrGpuMain` gasta 16 ms en los dos.
2. **El estado lento no es nuevo ni viene de la 3.1** [R]. La 3.0.1 ya tenía el renderer al 100 % con 25 ms por
   fotograma. No se veía en los fotogramas porque el hilo de GPU de entonces topaba casi en el mismo sitio (unos 42
   fps). Los parches de ANGLE subieron ese tope a unos 62 y dejaron el otro a la vista. Maglev no parece la causa: en
   la 3.0.1 estaba apagado (es una sola lectura, §10.6).
3. **La hipótesis de los hermanos SMT, tal como está formulada, no encaja con los datos** [R]. Si el renderer y
   `CrGpuMain` compartieran núcleo en el estado lento, se frenarían los dos, y `CrGpuMain` cuesta lo mismo en ambos
   estados. Queda viva una variante: que el otro hilo lógico del núcleo del renderer lo ocupe otra cosa.
4. **Hay otras dos explicaciones que encajan igual o mejor** y se comprueban más barato: la prioridad que macOS da
   al proceso del renderer, y el estado del código JavaScript compilado (§10.3).
5. **Comprobación propuesta, M3** (§10.4): cuatro pasos sin compilar. Los dos primeros no necesitan nada que LOCAL
   no tenga ya. Mirar en qué CPU corre cada hilo exige contraseña de administrador en la 6,1, y apagar el SMT exige
   que Titín reinicie: por eso van al final y solo si lo anterior apunta ahí.
6. **Merece hacerse antes de E1 y M1.** El estado lento cuesta un 27 % de fotogramas (41 frente a 56). Quitarlo da
   más que cualquier parche suelto del renderer, y mientras exista, las medianas de Aquarium mezclan los dos estados
   y no sirven para comparar versiones (§10.5).

### 10.2 Recuento: CPU por fotograma en cada hilo [R]

Coste por fotograma = % de CPU del hilo × 10 / fps, en milisegundos. Lecturas de `ps -M` ya publicadas.

| Compilación y lectura | fps | Renderer: % → ms | `CrGpuMain`: % → ms | Fuente |
|---|---|---|---|---|
| 3.0.0, hito 0 | 39,0 | 61,5 → **15,8** | 92,7 → 23,8 | `rendimiento-3x.md` §1, §2.1 |
| 3.0.0, control | 39,7 | 61,5 → **15,5** | 93,5 → 23,6 | ídem §3.1, §3.6 |
| 3.0.1, serie | 39,5 | 100 → **25,3** | 87,7 → 22,2 | ídem |
| t1 (un parche de ANGLE) | 42,9 | 75,3 → 17,6 | 90,2 → 21,0 | ídem |
| t2 | 49,1 | 82,8 → 16,9 | 89,4 → 18,2 | ídem |
| t3 | 44,8 | 87,7 → 19,6 | 86,3 → 19,3 | ídem |
| t4 (candidata 3.1), pasada 1 | 39,8 | 100 → **25,1** | 56,7 → 14,2 | ídem |
| t4, serie | 41,2 | 100 → **24,3** | 64,8 → 15,7 | ídem |
| 3.1.1, pasadas lentas | ~41 | 99–100 → **24,3** | 66 → **16,1** | `TAREAS.md` FS.44 |
| 3.1.1, pasadas rápidas | 55–57 | 80–93 → **14–17** | 89–91 → **15,6–16,5** | ídem |

Emparejar cada lectura con los fotogramas de su pasada es cosa mía [I]: las lecturas sin «serie» son de la pasada 1
y las de la serie, del final (uso la última pasada).

Lectura:

- **Dos costes del renderer:** 15,5–17 ms y 24–25 ms por el mismo fotograma. Los valores de en medio (t3) aparecen
  cuando además limitaba el hilo de GPU.
- **El hilo de GPU no cambia con el estado:** 16,1 ms en las pasadas lentas y 15,6–16,5 en las rápidas de la 3.1.1.
- **En el estado rápido van los dos hilos casi llenos** (renderer 80–93 %, `CrGpuMain` 89–91 %): por eso se queda en
  55–57 y no llega a 60.
- **Pasadas intermedias sí las hubo en la t4:** 49,2 y 46,3 (`rendimiento-3x.md` §3.1). Están a mitad de camino entre
  41 y 56, y encajan con un cambio de estado a media pasada [I]. Si es así, el estado no queda fijado al empezar.
- **Qué partes del renderer se encarecen.** Pasando a milisegundos el reparto de §9.2: de la toma de la 3.0.0
  (estado rápido) a las dos de la t4 (estado lento), el código JavaScript compilado pasa de 4,2 a 8,5–8,8 ms (×2,1);
  `sin`/`cos`, que es C++, de 3,5 a 5,3–5,6 (×1,5); y el coste de llamar a WebGL, de 6,4 a 7,7–9,0 (×1,2–1,4). Se
  encarece todo, y el JavaScript más. Vale como indicio y no como prueba: son compilaciones distintas y `sample`
  congela el renderer.

### 10.3 Qué puede ser

| Explicación | A favor | En contra | Cómo se comprueba |
|---|---|---|---|
| **A. El renderer y `CrGpuMain` en el mismo núcleo físico** (la del encargo) | un hilo que comparte núcleo con otro ocupado rinde bastante menos, y la diferencia es de ×1,5 | **`CrGpuMain` cuesta lo mismo en los dos estados** [R]: si compartieran núcleo se frenaría también, y en el rápido, ya solo, costaría 10–12,5 ms, que a 56 fps es un 58–69 % y no el 89–91 % medido | M3, paso 3 |
| **A′. El otro hilo lógico del núcleo del renderer, ocupado por otra cosa** | explicaría que se encarezca también el C++ | no se ve qué lo ocuparía: en el renderer ningún otro hilo pasa del 3 % (§9.2). macOS no fija hilos a una CPU y suele llenar antes los núcleos libres [S, de memoria], así que cuesta que dure una pasada entera en una máquina de 12 núcleos | M3, paso 3 |
| **B. Prioridad del proceso del renderer** | Chromium baja el renderer a segundo plano cuando cree que su pestaña no se ve (`base/process/process_mac.cc:152-195` [V]); se decide al cargar o al cambiar de ventana y dura; frenaría todo el hilo, C++ incluido | no sé cuánto frena macOS a un proceso en segundo plano con la máquina libre [S] | M3, paso 1: la columna `PRI` de `ps -M` |
| **C. Estado del código compilado de V8** (una función caliente que no llega al nivel más alto, o que se desoptimiza según cómo arranque la página) | el JavaScript compilado es lo que más se encarece (×2,1); depende del arranque y puede cambiar a media pasada | no explica que `sin`/`cos` y las llamadas a WebGL también suban | M3, pasos 2 y 4 |

No sé cuál es. Con lo que hay, A queda descartada, y B y C me parecen más probables que A′.

### 10.4 M3: comprobación sin compilar

LOCAL, 6,1, con la 3.1.1 publicada. Va después de la 3.2, como E1 y M1, y antes que ellas. De lo más barato a lo
más caro; **se para en el primer paso que dé una respuesta clara.**

**Paso 1. Lo que ya se sabe medir, anotando más** (sin permisos nuevos). Doce pasadas con 15 000 peces, para tener al
menos tres de cada estado. En cada una:

- fotogramas **cada segundo**, no solo la media: se ve si el estado cambia a media pasada y en qué momento;
- `ps -M` del renderer y del proceso de GPU cada 5 s, **guardando la línea entera**: `%CPU`, `PRI`, `STIME` y `UTIME`.
  En la 6,1 `ps -M` da esas columnas [V] y no dice en qué CPU corre el hilo;
- el PID del renderer (si cada pasada estrena proceso o lo reutiliza) y si la ventana estaba delante y a la vista.

Con eso, por pasada: estado, milisegundos por fotograma de cada hilo, prioridad del hilo principal del renderer y
reparto de su tiempo entre usuario y sistema.

- Si `PRI` es distinta en las pasadas lentas → es **B**. Se mira entonces por qué el navegador da la pestaña por
  oculta (ventana tapada, sin foco, lanzada por SSH), y si a un usuario le pasa lo mismo.
- Si el tiempo de sistema sube en las lentas → el coste está en el núcleo del sistema, no en la página; se sigue
  con el paso 2.
- Si el estado va con el PID (el mismo proceso lo conserva de una pasada a otra) → apunta a B o C, no a A′.

**Paso 2. Qué se encarece, con una sola compilación** (sin permisos nuevos; necesita el dSYM de la versión que se
mida). Un `sample` del renderer al final de una pasada lenta y otro al final de una rápida, pasados por
`reparto-renderer.py` y convertidos a milisegundos por fotograma con la lectura de `ps -M` anterior a la toma.

- Si todas las categorías suben por igual (±15 %) → la causa está fuera del código: A′ o B.
- Si solo sube el JavaScript compilado → **C**, y se va al paso 4.

**Paso 3. En qué CPU corre cada hilo** (pide contraseña de administrador en la 6,1 [V]: lo lanza Titín o está
delante). Diez segundos a media pasada, en una lenta y en una rápida:

```bash
sudo dtrace -q -n 'profile-997 /pid == $1 || pid == $2/ { @hilos[pid, tid, cpu] = count(); } profile-997 /pid != 0/ { @ocupacion[cpu] = count(); } tick-10s { exit(0); }' PID_RENDERER PID_GPU
```

Da, por hilo, cuántas muestras cayeron en cada CPU lógica, y cuánto estuvo ocupada cada una. El hilo principal de
cada proceso es el que más muestras tiene. La 6,1 tiene 12 núcleos y 24 hilos lógicos [V]; supongo que las CPU 2k y
2k+1 son el mismo núcleo [S]. No lo he ejecutado: que funcione con la protección del sistema activa, como está en
la 6,1, es suposición [S].

- A′ confirmada si, en la pasada lenta, el hilo del renderer pasa al menos el 70 % de sus muestras en CPU cuya
  pareja está ocupada un 30 % o más, y en la rápida menos del 20 %.
- Descartada si el reparto es igual en los dos estados.

Solo si se confirma: **repetir con el SMT apagado.** Es un cambio de ajuste del sistema en la máquina de Titín y lo
decide y lo hace él. Apple lo documenta para Mojave: arrancar en Recuperación, `nvram boot-args="cwae=2"` y
`nvram SMTDisable=%01`, reiniciar; se deshace restableciendo la NVRAM [V, artículo 101870 de Apple]. Hoy la 6,1 no
tiene ninguna de las dos variables [V]. Doce pasadas: si todas salen rápidas, queda probado.

**Paso 4. Estado de V8** (sin permisos nuevos; solo si el paso 2 apunta a C). Lanzar con
`--js-flags="--trace-opt --trace-deopt"` y la salida a un fichero, y comparar una pasada lenta con una rápida:
cuántas desoptimizaciones hay en los últimos 20 s y si las mismas funciones acaban optimizadas. Que la salida del
renderer llegue al fichero con la caja de arena activa es suposición [S].

### 10.5 Qué abre cada resultado, y qué hacer mientras tanto

| Resultado | Entonces |
|---|---|
| **B**, prioridad | puede ser un artefacto de cómo se lanza la prueba, y entonces basta corregir el guion; si le pasa también a un usuario con la ventana a la vista, es un fallo nuestro y va a MOTOR |
| **C**, estado de V8 | a MOTOR, con el nombre de la función: es de la misma familia que los parches del renderer (#949) |
| **A′**, colocación | estudio aparte de ARQUITECTURA. macOS no deja fijar un hilo a una CPU; lo que hay son etiquetas de afinidad, y no sé si en esta máquina separan hilos por núcleo [S] |
| Ninguna | queda el dato del paso 1: el instante en que cambia el estado y qué cambió con él |

**Mientras tanto:** toda medida de Aquarium con 15 000 peces se da **por pasada, con su estado y los milisegundos
por fotograma de cada hilo**, no con la mediana de fotogramas. La mediana depende de cuántas pasadas caen en cada
estado: 41,0 en la 3.1.1 frente a 41,9 en la 3.1.0 no dice nada de ninguna de las dos. Vale también para medir los
parches del renderer.

### 10.6 Fuentes y límites de este apartado

- **Medidas:** `TAREAS.md` FS.44 (LOCAL-19, 13-11; #972); `rendimiento-3x.md` §1, §2.1, §3.1 y §3.6 (LOCAL-21); la
  tabla de §9.2 de este documento.
- **La 6,1, leída el 13-11 sin lanzar nada:** macOS 10.14.6, Xeon E5-2696 v2, 12 núcleos y 24 hilos lógicos; están
  `dtrace`, `ktrace`, `powermetrics` y Xcode; protección del sistema activa; `sudo` pide contraseña;
  `SMTDisable` y `boot-args` sin definir.
- **Código** (árbol 156): `base/process/process_mac.cc:152-195`.
- **Apple:** «How to enable full mitigation for Microarchitectural Data Sampling (MDS) vulnerabilities»,
  support.apple.com/en-us/101870, leído el 13-11-2026.
- **Límites:** no he medido nada. Cada fila de §10.2 sale de una o pocas lecturas, y la 3.0.1 en estado lento es
  una sola. El emparejamiento de lecturas y pasadas es mío. Son suposiciones [S]: cómo numera macOS los hilos
  lógicos, que prefiera núcleos libres, cuánto frena a un proceso en segundo plano, que `dtrace` funcione así en
  Mojave con la protección activa y que la traza de V8 salga con la caja de arena. Los umbrales del paso 3 son
  míos. No he leído el código de V8 para la explicación C.
