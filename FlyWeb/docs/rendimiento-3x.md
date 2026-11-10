# Rendimiento de la 3.x: línea base (hito 0) y perfil del hilo de GPU

Datos medidos por LOCAL-21 el 09-11-2026 con la **FlyWeb 3.0.0 publicada** (198.63.41, Chrome/156.0.8078.90, PGO),
por orden de COORDINACIÓN-36. Cumple el hito 0 de [`plan-3x.md`](plan-3x.md) §3 en la 6,1 y el primer hito de la 3.1
(§4.1), con la receta de [`rendimiento-3.1.md`](rendimiento-3.1.md) §4. La parte de la 7,1 (3.0.0 frente a Chrome, §1.1)
se midió la noche del 09 al 10-11-2026, con la 7,1 libre de compilaciones.

## 1. Hito 0: tabla única

Condiciones en la 6,1:
- Mojave 10.14.6, 2× FirePro D500; compone la que lleva la pantalla, porque en el Mac Pro no se puede elegir.
- Pantalla a 60 Hz; ventana de 1920×1200, DPR 1. WebGL por ANGLE Metal.
- Perfil nuevo en `/tmp` y `--disable-brave-update`. Sparkle sin tocar (preferencias restauradas, caché sin cambios).
- Benchmarks servidos en 127.0.0.1, sin red. La máquina, en reposo.

| Medida | 6,1 (Mojave, D500), 3.0.0 | 5,1 (RX 580, sin AVX), 3.0.0 | 7,1 (Sequoia), 3.0.0 | Antes en la 6,1 (2.7.0, GL) |
|---|---|---|---|---|
| MotionMark 1.3.2 | 1381 (medido antes; no repetido por orden de COORDINACIÓN-36) | 864 ±2,8 % | **3183** ±0,8 % (sin ventana) | 566 |
| Speedometer 3.1 | **10,3 ±0,44** (1 pasada) | sin medir | **18,6** ±1,6 % (sin ventana) | 5,84 |
| JetStream 3 (76 pruebas, sin web-ssr) | **107,63** (1 pasada, 0 errores) | sin medir | **165,4** ±1,7 % (sin ventana, 0 errores) | 89,3 |
| Aquarium 5 000 / 10 000 / 15 000 peces | **60,0 / 55,9 / 39,0 fps** (mediana de 3; ≤1,1 %) | 60 / 40,9 / – | **60,0 / 60,0 / 56,8 fps** (sin ventana) | 60 / 44 / 30 |

Notas:
- **Aquarium:** lienzo de 1024×1024. Las pasadas a 10 000 peces dieron 55,9 · 55,3 · 56,5; a 15 000, 39,1 · 39,0 · 39,0.
  El fps es la media de `g_fpsTimer.averageFPS` durante 30 s, tras 10 s de calentamiento, y coincide con un contador
  de rAF de 5 s.
- **Speedometer y JetStream:** una pasada de cada uno, por orden de COORDINACIÓN-36 (tres solo si la primera salía rara).
  Frente a la 7,1, la 6,1 da el 55 % en Speedometer y el 65 % en JetStream.
- **7,1:** mediana de 3 pasadas; la dispersión es (máx. − mín.) / mediana. Detalle y condiciones en §1.1.
- **MotionMark:** la página detectó «Framerate 45fps» justo después de Aquarium, en una pasada que se cortó. Queda
  anotado por si explica cifras antiguas; no se ha investigado.

### 1.1 La 7,1: 3.0.0 frente a Chrome (sin ventana)

Condiciones:
- MacPro7,1, Sequoia, Radeon PRO W6600X. WebGL por ANGLE Metal en los dos navegadores; Skia Graphite.
- **Sin ventana** (`--headless=new`), porque en la 7,1 no se abre nada con ventana mientras Titín trabaja en ella.
  El refresco es el virtual del modo sin ventana (60 Hz; MotionMark detecta «60fps» y «medium screen»). Pantalla
  virtual de 800×600, ventana de 1920×1119–1200 y DPR 1.
- Perfil nuevo en `/tmp` y `--disable-brave-update` en FlyWeb. Benchmarks servidos en 127.0.0.1, sin red.
- La FlyWeb de Titín estaba abierta, en reposo, y no había ninguna compilación en marcha.
- **Chrome es la 157.0.8103.39**, no la 156: el Chrome instalado se había actualizado solo y no se ha descargado otro.
- **No es comparable con [`comparativa-71.md`](comparativa-71.md)**, que se midió con ventana en un monitor de 60 Hz
  (3.0.0 PGO 3576 y Chrome 156 3861 en MotionMark). Aquí solo vale la comparación entre los dos navegadores, en las
  mismas condiciones.

| Medida | FlyWeb 3.0.0 (Chrome/156.0.8078.90, PGO) | Chrome 157.0.8103.39 | FlyWeb frente a Chrome |
|---|---|---|---|
| MotionMark 1.3.2 | **3183** (3183 · 3200 · 3174; 0,8 %) | **3731** (3844 · 3725 · 3731; 3,2 %) | **−14,7 %** |
| Speedometer 3.1 | **18,6** (18,6 · 18,7 · 18,4; 1,6 %) | **21,4** (21,4 · 21,9 · 21,4; 2,3 %) | **−13,1 %** |
| JetStream 3 (76 pruebas, sin web-ssr) | **165,4** (165,3 · 168,1 · 165,4; 1,7 %; 0 errores) | **178,7** (175,7 · 181,4 · 178,7; 3,2 %; 0 errores) | **−7,4 %** |
| Aquarium 5 000 peces | 60,0 fps (60 · 60 · 60) | 60,0 fps (60 · 60 · 60) | = |
| Aquarium 10 000 peces | 60,0 fps (59,5 · 60 · 60) | 59,9 fps (59,9 · 59,9 · 60) | = |
| Aquarium 15 000 peces | **56,8 fps** (56,8 · 56,8 · 56,3) | **60,0 fps** (60 · 60 · 59,9) | **−5,3 %** (Chrome topa con los 60) |

MotionMark por pruebas (mediana de las 3 pasadas):

| Prueba | FlyWeb 3.0.0 | Chrome 157 | FlyWeb frente a Chrome |
|---|---|---|---|
| Multiply | 1448 | 2776 | **−48 %** |
| Canvas Arcs | 17690 | 17869 | −1 % |
| Leaves | 1505 | 1987 | **−24 %** |
| Paths | 40050 | 41032 | −2 % |
| Canvas Lines | 36970 | 37935 | −3 % |
| Images | 309 | 310 | = |
| Design | 320 | 370 | −13 % |
| Suits | 1835 | 2365 | **−22 %** |

Lectura:
- **El hueco con Chrome está en tres pruebas de MotionMark:** Multiply (casi la mitad), Leaves y Suits, y algo en
  Design. En Canvas Arcs, Paths, Canvas Lines e Images la 3.0.0 iguala a Chrome. Multiply y Leaves mueven muchos
  elementos con transformaciones CSS; Suits dibuja SVG con degradados y recortes. No se ha perfilado: es la primera
  pista fuera de la GPU de WebGL.
- **Aquarium:** en la 7,1 la 3.0.0 solo pierde a 15 000 peces (56,8 frente a 60). Es el mismo cuello de `CrGpuMain`
  que en la 6,1 (§2), con más margen; se verá con la candidata de la 3.1.
- **JavaScript y DOM:** Speedometer −13 % y JetStream −7 %, la misma base 156 frente a una 157. Parte puede ser de la
  versión; hace falta una Chrome 156 para separarlo.
- **Dispersión:** la de Chrome en MotionMark es mayor (los intervalos de la página llegan a ±13 %). La de FlyWeb, ±3–4 %.

#### 1.1 bis. Repetición con Chrome 156 y la 3.0.1 (LOCAL-19, 10-11-2026)

Por orden de COORDINACIÓN-38: lo mismo que arriba, pero con una **Chrome 156** en lugar de la 157 y la **3.0.1** en
lugar de la 3.0.0. Las condiciones son las mismas que en §1.1: sin ventana, perfil en `/tmp`, la FlyWeb de Titín
abierta y en reposo, ninguna compilación ni otra medida en marcha, y benchmarks servidos en 127.0.0.1. Se midió de
13:06 a 15:40 UTC.
- **FlyWeb 3.0.1:** 198.63.42, Chrome/156.0.8078.98, PGO, brave-core `77ae53e5f64`. Es la build `out/Release` de la
  entrega FS.42, con el mismo sha del framework que la publicada (`efbe530f…`), aunque esta copia está sin firmar.
- **Chrome for Testing 156.0.8078.80:** la que ya había en la 7,1 (`temp/cft156`); no se ha descargado otra. Es la 156
  más cercana a la .98 que había a mano, 18 revisiones de parche por detrás.
- **Ojo con Chrome for Testing:** aplica `fieldtrial_testing_config` de serie. Según `chrome://gpu`, eso le enciende
  EnableDrDc («Direct Rendering Display Compositor»), TreesInViz y WebGPU, que FlyWeb tiene apagadas. Por eso se ha
  medido también con `--disable-field-trial-config`, que deja las tres como en FlyWeb (columna «sin pruebas de campo»).
  Es la comparación limpia.

| Medida | FlyWeb 3.0.1 | Chrome 156 (CfT, de serie) | Chrome 156 sin pruebas de campo | 3.0.1 frente a Chrome 156 sin pruebas de campo |
|---|---|---|---|---|
| MotionMark 1.3.2 | **3202** (3236 · 3202 · 3196; 1,3 %) | 3373 (3373 · 3313 · 3474; 4,8 %) | **3786** (3786 · 3919 · 3712; 5,5 %) | **−15,4 %** |
| Speedometer 3.1 | **17,9** (17,9 · 18,5 · 17,8; 3,9 %) | 22,0 (21,5 · 22,0 · 22,1; 2,8 %) | **21,7** (21,5 · 21,9 · 21,7; 1,8 %) | **−17,5 %** |
| JetStream 3 (76 pruebas, sin web-ssr) | **161,1** (161,0 · 163,3 · 161,1; 1,4 %; 0 errores) | **176,1** (177,1 · 176,1 · 174,5; 1,5 %; 0 errores) | sin medir | **−8,5 %** (frente a la de serie) |
| Aquarium 15 000 peces | **56,4 fps** (56,6 · 55,3 · 56,4) | **56,6 fps** (55,3 · 56,9 · 56,6) | sin medir | **=** |

MotionMark por pruebas (mediana de 3):

| Prueba | FlyWeb 3.0.1 | Chrome 156 (de serie) | Chrome 156 sin pruebas de campo | 3.0.1 frente a Chrome 156 sin pruebas de campo |
|---|---|---|---|---|
| Multiply | 1374 | 2599 | 2870 | **−52 %** |
| Canvas Arcs | 18652 | 14588 | 19438 | −4 % |
| Leaves | 1442 | 1926 | 2088 | **−31 %** |
| Paths | 42306 | 32380 | 44796 | −6 % |
| Canvas Lines | 38562 | 39323 | 40242 | −4 % |
| Images | 309 | 317 | 322 | −4 % |
| Design | 323 | 319 | 346 | −7 % |
| Suits | 1899 | 1822 | 1959 | −3 % |

Lectura:
- **No es la versión (H3).** Con la misma base 156, el hueco en MotionMark sigue igual o mayor que con la 157:
  −15 % frente a la 156 sin pruebas de campo y −14,7 % frente a la 157 en §1.1. Multiply −52 % y Leaves −31 %.
- **Es el filtrado cosmético de Shields (H1 de [`rendimiento-motionmark.md`](rendimiento-motionmark.md)).** Con
  `--disable-features=BraveAdblockCosmeticFiltering`, la 3.0.1 da 3701 en MotionMark (+15,6 %) y Multiply pasa de
  1374 a 2723. Con el redondeo de tiempos también apagado da 3787, lo mismo que Chrome 156 sin pruebas de campo (3786).
  Tabla, `sample` y detalle en ese documento.
- **Speedometer sigue −12 % aun sin el filtro:** 19,1 frente a 21,7. **JetStream −8,5 %**, y ahí no entra el DOM. Lo
  que queda apunta a H4 (el PGO de Google sobre nuestro árbol) o a otra cosa de Brave en el renderer; no se ha separado.
- **Aquarium 15 000 peces:** empate (56,4 frente a 56,6). Esta Chrome 156 no topa con los 60 como la 157 de §1.1.
- **Pruebas de campo de Chrome for Testing:** sin ellas, Chrome sube en MotionMark de 3373 a 3786. Sobre todo suben
  Canvas Arcs (de 14588 a 19438) y Paths (de 32380 a 44796). Sin ventana, alguna de esas pruebas de campo le cuesta
  a Chrome en canvas. En FlyWeb, encender DrDc y TreesInViz no cambia nada: 3227 frente a 3202 (ver
  `rendimiento-motionmark.md`).
- La 3.0.1 frente a la 3.0.0 de §1.1, en las mismas condiciones: MotionMark 3202 frente a 3183, Speedometer 17,9 frente
  a 18,6, JetStream 161,1 frente a 165,4 y Aquarium 56,4 frente a 56,8. Las diferencias quedan dentro del ruido o muy
  cerca: los parches de seguridad no mueven el rendimiento.

## 2. Perfil del hilo del proceso de GPU (6,1, Aquarium a 10 000 y 15 000 peces)

### 2.1 Qué hilo manda

| Hilo | 10 000 peces | 15 000 peces | Fuente |
|---|---|---|---|
| `CrGpuMain` (hilo principal del proceso de GPU) | **92,5 %** | **92,7 %** | `ps -M`, 3 lecturas; `sample` da 90,7 % y 91,9 % |
| `VizCompositorThread` | 0,7 % | 0,8 % | `sample` |
| `Chrome_ChildIOThread` (proceso de GPU) | 6,3 % | 6,6 % | `sample` |
| Hilo principal del renderer (Blink + V8) | 60–61 % | 61–62 % | `ps -M` |

- **El límite es `CrGpuMain`.** Con 10 000 y con 15 000 peces está igual de ocupado. El ~7,5 % que le falta para el 100 %
  es espera en `-[_MTLCommandBuffer waitUntilScheduled]` (`__psynch_cvwait`).
- **Coste:** unos **1,6 µs de hilo por pez** (15 000 × 39,5 fps ÷ 0,927 → 1,56 µs; 10 000 → 1,64 µs). Es algo menos
  que la estimación de 1,8 µs.
- **Renderer:** `sample` lo da al 99 % porque lo congela en cada toma; solo consigue unas 1 000 muestras en 10 s, frente
  a 7 400 del GPU. Por eso, para el renderer vale `ps -M`.
- **Dentro del renderer** (para más adelante): `Math.sin`/`cos` de V8 se lleva el 22–24 %. Además,
  `base::FeatureList::IsFeatureEnabled` se llama en cada dibujo desde `OnBeforeDrawCall` → `ClearIfComposited`
  (3–4 %).

### 2.2 Llamadas por pez (Spector.js 0.9.33 y contador propio)

| Por fotograma | 1 000 peces (Spector) | 2 000 peces (Spector) | 10 000 (contador) | 15 000 (contador) | **Por pez** |
|---|---|---|---|---|---|
| `drawElements` | 1 111 | 2 112 | 10 112 | 15 113 | **1** |
| `uniform*` | 4 760 | 8 770 | 40 806 | 60 816 | **4** (2 `uniform3fv` + 2 `uniform1f`) |
| Cambios de estado | 922 | 951 | 1 021 | 1 050 | **≈0** (≈950–1 050 fijos por fotograma) |

Aquarium no enlaza texturas ni cambia de programa por pez: `useProgram` se queda en 47–49 por fotograma y `bindTexture`
en 51–90, con 1 000 o con 15 000 peces. Spector, capturando 15 000 peces, superó los 120 s de CDP; por eso se capturó con 1 000 y 2 000.
El contador propio (envoltorio de `WebGLRenderingContext`) da exactamente lo mismo.

### 2.3 Tabla de `plan-3x.md` §4.1: ¿se cumple la condición?

Porcentajes inclusivos sobre todas las muestras de `CrGpuMain` en 15 000 peces (entre paréntesis, 10 000 peces).
`sample` de 10 s a 1 ms, simbolizado con el dSYM de la 3.0.0 (UUID 4C4C4466-5555-3144-A1AB-93F7DAB071D8).

| # | Cambio | Condición | Medido | ¿Se cumple? |
|---|---|---|---|---|
| 3 | `FastVector` en `resolveDrawElementsDraw` | Aparecen `malloc`/`free` bajo `resolveDrawElementsDraw` | Asignaciones bajo `resolveDrawElementsDraw`: 1,8 % (1,8 %). Por la ruta del dibujo, todas van a `partition_alloc`. Contando el `vector<DrawCommandRange>` de `ContextMtl::drawElementsImpl`: 5,0 % de asignación y 6,7 % en total | **Sí**, y pesa más de lo estimado (5–7 %) |
| 4 | Sacar del dibujo lo que no cambia (`isDrawNoOp`…) | Se ve `supportsFeatureSet:` bajo `isDrawNoOp` | `isDrawNoOp` va inline. `rx::mtl::GetMaxNumberOfRenderTargetsForDevice` se llama en cada dibujo desde `setupDrawImpl`: 3,6 % (3,2 %), con `-[_MTLDevice deviceOrFeatureProfileSupportsFeatureSet:]` 0,9 % y su `objc_release`. `checkCommandBufferError`: 0 % | **Sí** (3–4 %) |
| 1 | Dependencias sin mutex ni `HashSet` | `setReadDependency` + `pthread_mutex_*` + `HashSet::insert` > unos pocos % | `set(Read\|Write)Dependency` 3,8 % (3,7 %), de ello mutex 2,6 %. `HashSet` no aparece como función propia (inline). Mutex en total (propio): 6,6 %, también bajo `setTexture` (4,2 %) y `CommandBufferService::Flush` | **Sí, en el límite** (≈4 %). Con los mutex de `setTexture`, más |
| 2 | Flujo intermedio sin `insert` por campo; uniformes a un anillo | `commitUniforms` + `setBytes` > ~5 % | `commitUniforms` + `setBytes` 4,9 % (4,0 %). Flujo intermedio (`vector<unsigned char>::insert` + `memmove`): 8,3 % (7,2 %); el `memmove` bajo `setBytes` es el 2,5 % | **En el límite** para (b), uniformes. **Sí** para (a), flujo intermedio |
| 6 | PGO propio para ANGLE o quitarlo | `rx::`/`gl::` cambia con PGO y sin PGO más que el ruido | `rx::`/`gl::`/`egl::` en la pila: 80,6 % (75,6 %), solo con PGO | **Sin decidir:** falta el `sample` de una 3.0.0 sin PGO del mismo commit |
| 5 | Reproducir el encoder en otro hilo | `encodeMetalEncoder` + driver AMD > 25 % del hilo | **15,1 % (13,7 %)**: `endEncodingImpl` 14,6 % (`encodeMetalEncoder` va inline en él), driver `AMDMTLBronzeDriver` 6,3 % (5,9 % de ello bajo `endEncodingImpl`) | **No** |
| 7 | Decodificador de Chromium | `DoCommandsImpl` + `GetCurrent` + `SharedContextMutex` > ~5 % | Tiempo propio: `DoCommandsImpl` 2,3 % + `GL_DrawElements` 2,3 % + `gl::Validate*` 3,4 %; `GetCurrent` y `SharedContextMutex`: 0 %. El decodificador entero (`Handle*`/`Do*`, `GLApiBase::`, validación) suma 13,7 % | **Sí** (≈8 % en las funciones nombradas), pero el coste está en validar y despachar, no en TLS ni en el cerrojo |
| — | Fallos de caché de pipelines | `newRenderPipelineStateWithDescriptor` en estado estable | 0 % | No hay fallos de caché |

**`encodeMetalEncoder` + driver de AMD: 15,1 % del hilo con 15 000 peces (13,7 % con 10 000).**

### 2.4 Lo que el perfil enseña fuera de la tabla

1. **Texturas re-enlazadas en cada dibujo.** Es lo más caro que se puede atacar. `ProgramExecutableMtl::updateTextures`
   pesa el 18,6 % (18,0 %) inclusivo: `TextureMtl::bindToShader` 15,1 %, `RenderCommandEncoder::setTexture` 11,4 %
   (4,2 % de mutex) y `setSamplerState`. Aquarium no cambia texturas entre peces (§2.2), así que es trabajo repetido.
   Candidato a cambio nuevo de MOTOR: no reenlazar texturas y samplers si no cambian desde el último dibujo del mismo
   encoder.
2. **`objc_release` dentro de `endEncodingImpl`: 8,1 % (7,2 %).** Liberar los objetos retenidos por el flujo intermedio
   al cerrar cada encoder. Contando `objc_msgSend` y `objc_retain`, el `objc_*` propio llega al 11,7 %.
3. **Asignación por dibujo:** `partition_alloc` propio 5,0 %, casi todo desde `ContextMtl::drawElementsImpl`. Es el
   vector de la fila 3.
4. **Puerta de §4.3 para hilos y varias GPU.**
   - (1) `CrGpuMain` > 90 % con Viz y el renderer por debajo: **sí** (92,7 %; Viz < 1 %; renderer 62 %).
   - (2) `encodeMetalEncoder` + driver > 25 %: **no** (15 %).
   - (3) cambios 1–4 aplicados: no.
   - **La puerta no se abre.** Lo que da el perfil va en el propio hilo: texturas (≈19 %), flujo intermedio (≈8 %),
     `objc_release` (≈8 %), vector por dibujo (≈5–7 %), decodificador y validación (≈8–14 %), consulta de capacidades
     por dibujo (≈4 %) y mutex (≈4–7 %). Hay solapes entre ellos.

Funciones más caras de `CrGpuMain` con 15 000 peces (tiempo propio, % del tiempo activo):

| Función | % |
|---|---|
| `objc_release` | 8,7 |
| `rx::mtl::RenderCommandEncoder::setTexture` | 5,0 |
| `_platform_memmove` (Nehalem + Ivybridge) | 5,6 |
| `rx::ProgramExecutableMtl::updateTextures` | 3,9 |
| `gl::ValidateUniform` | 3,5 |
| `partition_alloc::PartitionRoot::FreeInline` | 3,5 |
| `std::vector<unsigned char>::__insert_with_size` (flujo intermedio) | 3,4 |
| `pthread_mutex_unlock` / `pthread_mutex_lock` | 3,3 / 2,9 |
| `rx::TextureMtl::bindToShader` | 2,9 |
| `objc_msgSend` | 2,7 |
| `GL_DrawElements` / `GLES2DecoderPassthroughImpl::DoCommandsImpl<false>` | 2,5 / 2,5 |
| `gl::GLApiBase::glUniform3fvFn` / `HandleUniform1f` | 2,4 / 2,3 |
| `rx::VertexArrayMtl::resolveDrawElementsDraw` | 2,3 |
| `amdMtlBronzeResourceMgrValidateConstantState` (driver) | 2,0 |

## 3. Método y datos

- **Guion:** `s61-l21.sh` corre en la 6,1 por una sola sesión SSH con túnel CDP. `l21.py` conduce desde la 7,1.
  - El guion aborta si hay otra FlyWeb, Chromium, compilación o semáforo `/tmp/*61-en-uso`.
  - Sirve los benchmarks en local y guarda y restaura las preferencias de Sparkle.
  - Los `sample` se piden al vigilante por fichero de órdenes. Primero se lee `ps -M` (3 lecturas); después
    `sample` del proceso de GPU (`--type=gpu-process`, que en FlyWeb es «FlyWeb Helper», no «Helper (GPU)») y luego
    del renderer, uno tras otro para no perturbar.
- **Simbolización:** `sample` en 10.14 atribuye todo a `ChromeMain + desplazamiento`. `analizar-sample.py` vuelve a
  simbolizar las direcciones absolutas con `atos` y el dSYM, usando la base de carga de «Binary Images».
  - El dSYM no estaba en la entrega. Es el de `out/Release-300tests` de la misma compilación (el UUID coincide).
  - El % «activo» descuenta las hojas de espera (`mach_msg_trap`, `__psynch_cvwait`, `kevent*`…).
- **Spector.js:** si se inyecta al crear el documento, se cae porque busca `document.head`. Se carga al pasar a
  `interactive`, que es antes de que Aquarium cree el contexto en `DOMContentLoaded`.
- **7,1 (§1.1):** `m71/lanzar.sh` arranca el navegador siempre con `--headless=new` y perfil en `/tmp`; `m71/m71.py` es
  `l21.py` (`PASO=2`) sobre el puerto 9445; `m71/todo.sh` mide FlyWeb y después Chrome, y aborta si hay una compilación.
- **7,1, §1.1 bis (LOCAL-19):** `temp/local19/m71/` con copias de `lanzar.sh` y `m71.py` en el puerto 9446 y el servidor en 8127. `caso.sh` mide un navegador con sus flags y `todo3.sh` lo pasa todo en serie. Los resultados y `chrome://gpu` (texto y PNG) de cada caso están en `c*/`. Una primera pasada de Chrome se pisó con otro guion lanzado a la vez y se descartó entera (`descartado-1438/`).
- **Ficheros:** guiones, `sample`, `ps -M`, `spector.json` y análisis JSON están en la carpeta de entregas de LOCAL-21
  (`entregas/local21/paso2`, `paso3` y `hito0-71`), fuera del repo.

## 4. Pendiente

- **7,1:** el mismo perfil del hilo de GPU como control (Sequoia, W6600X). La repetición con Chrome 156 y el perfil de
  Multiply ya están hechos: §1.1 bis y [`rendimiento-motionmark.md`](rendimiento-motionmark.md). Queda separar en
  Speedometer y JetStream lo que es del PGO de lo que es de Brave.
- **Fila 6:** `sample` de una 3.0.0 sin PGO del mismo commit.
- **`angle_perftests`** (`DrawCallPerfBenchmark.Run/metal*`, `DrawElementsPerf*`, `UniformsPerf*`): no intentado.
- **Del hito 0, sin hacer:** las dos medidas de claude.ai sin hCaptcha y la fila del A/B de PGO con valores absolutos.
  La 5,1, cuando Titín pueda.
