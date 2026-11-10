# Rendimiento de la 3.x: línea base (hito 0) y perfil del hilo de GPU

Datos medidos por LOCAL-21 el 09-11-2026 con la **FlyWeb 3.0.0 publicada** (198.63.41, Chrome/156.0.8078.90, PGO),
por orden de COORDINACIÓN-36. Cumple el hito 0 de [`plan-3x.md`](plan-3x.md) §3 en la 6,1 y el primer hito de la 3.1
(§4.1), con la receta de [`rendimiento-3.1.md`](rendimiento-3.1.md) §4. La parte de la 7,1 (3.0.0 frente a Chrome, §1.1)
se midió la noche del 09 al 10-11-2026, con la 7,1 libre de compilaciones. La candidata de la 3.1 (parches de ANGLE
0001–0004 y NTP privada) se midió en la 6,1 el 10-11-2026 (§3).

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

## 3. Candidata de la 3.1 en la 6,1 (10-11-2026)

Medida por LOCAL-21, por orden de COORDINACIÓN-36 y COORDINACIÓN-38 (que pide la t4 frente a la 3.0.1 publicada).
LOCAL-19 compiló cuatro tandas, todas desde brave-core b6c544471ec,
como 3.0.1 (198.63.42, Chrome/156.0.8078.98). Las cuatro llevan además los parches 0004 y 0005 de
`parches/3.0.2-sync-ajustes/` (NTP privada y de invitado). Cada tanda añade un parche de ANGLE de `3.1-angle`:

| Tanda | Parches de ANGLE | UUID del framework |
|---|---|---|
| t1 | 0001 | 4C4C444C-…-BB1019620F3A |
| t2 | 0001–0002 | 4C4C44AD-…-1ADE0E71321B |
| t3 | 0001–0003 | 4C4C44E2-…-65D2D41364AF |
| t4 | 0001–0004 | 4C4C4448-…-7D985778A276 |

Condiciones, las de §1 en la 6,1:
- Cada tanda se copió a `~/flyweb-pruebas/<tanda>` por la red local, con el sha256 del framework comprobado, nunca a
  `/Applications`.
- Perfil nuevo en `/tmp`. La 3.0.0 de control se midió el mismo día con el mismo guion.
- Cada binario nuevo sin firmar necesita la aprobación de LuLu antes de tener red, también hacia 127.0.0.1.

### 3.1 Rendimiento

Mediana de 3 pasadas; «serie» es una tanda aparte de 5 pasadas sin `sample`, sin la ruta de páginas antes. Controles
medidos el mismo día con el mismo guion: la 3.0.0 de `/Applications` y la **3.0.1 publicada** (la compilación 198.63.42
de `entregas/FlyWeb-3.0.1-release`, sha256 del framework `efbe530f…`, la misma que firmó PUBLICACIÓN), que es la base de
la candidata.

| Medida | 3.0.0 | 3.0.1 | t1 (0001) | t2 (0001–0002) | t3 (0001–0003) | t4 (0001–0004) |
|---|---|---|---|---|---|---|
| Aquarium 5 000 peces | 60,0 | – | 60,0 | 60,0 | – | – |
| Aquarium 10 000 peces | 57,1 | 57,7 (serie)¹ | **60,0** | **60,0** | **60,0** | 58,9; **60,0** (serie) |
| Aquarium 15 000 peces | 39,7 | 39,8 (serie) | 42,9 | 43,8 | 44,8 | 49,2; 41,2 (serie)² |
| MotionMark 1.3.2 | 1351 | 1342 | 1343³ | 1363 | 1352 | 1365 |
| Texturas WebGL 1 y 2 (69 pruebas) | 69 bien | 69 bien | 69 bien | 69 bien | 69 bien | 69 bien |

Pasadas sueltas:
- 3.0.0: 10 000 → 56,6 · 57,5 · 57,1; 15 000 → 39,7 · 40,2 · 39,6; MotionMark 1355 · 1350 · 1351.
- 3.0.1 (serie): 10 000 → 27,1 · 57,0 · 58,0 · 60,0 · 57,7; 15 000 → 39,7 · 39,9 · 39,8 · 40,0 · 39,5; MotionMark
  1360 · 1338 · 1342.
- t1: 15 000 → 42,9 · 44,1 · 41,0; MotionMark 1352 · 1333.
- t2: 15 000 → 49,1 · 43,8 · 43,1; MotionMark 1343 · 1363 · 1380.
- t3: 15 000 → 44,8 · 50,5 · 40,9; MotionMark 1331 · 1365 · 1352.
- t4: 10 000 → 60 · 58,9 · 58,9 y (serie) 60 · 60 · 60 · 60 · 58,9; 15 000 → 39,8 · 49,2 · 53,0 y (serie)
  46,3 · 55,6 · 41,0 · 40,0 · 41,2; MotionMark 1348 · 1365 · 1366.

¹ La primera pasada de la serie (27,1) es el arranque en frío: la serie no calienta antes con otras páginas.
² Bimodal: unas pasadas dan 40–41 (lo mismo que la 3.0.1) y otras 46–56. La mediana de las 8 pasadas es 43,8 (+10 %
  sobre la 3.0.1). Ver §3.6.
³ La primera pasada de la t1 detectó «Framerate 45fps» al cargar justo después de Aquarium (como en §1) y no cuenta.
  Desde la t2, el conductor recarga MotionMark hasta que detecta 60 fps.

- **t4 frente a 3.0.1:** con 10 000 peces, de 57,7 al tope de 60 fps. Con 15 000, entre +3 % (serie) y +10 % (8 pasadas),
  con mucha dispersión. MotionMark igual (+2 %, dentro del ruido). Texturas, 69 de 69. **Nada empeora.**
- **MotionMark:** igual en todas, dentro del ruido. Sus pruebas no cambian texturas por dibujo ni van limitadas por el
  hilo de GPU de WebGL.
- **Texturas:** página propia `correccion-texturas.html`, que lee píxeles con tolerancia 3 (12 en vídeo). Cubre:
  varias texturas y programas en un fotograma; `uniform1i` y `texParameteri` entre dibujos; render a textura;
  `generateMipmap`; samplers de WebGL2; textura desde vídeo; `getError` al final.
- **Páginas reales:** cuatro ejemplos de three.js (keyframes, envmaps, unreal bloom, texture2darray) cargan sin errores
  de consola en las seis. claude.ai y Maps, en §3.3 y §3.5.

### 3.2 `sample` del hilo de GPU con 15 000 peces

Porcentaje del tiempo activo de `CrGpuMain` en el que el símbolo está en la pila. Cada `sample` está simbolizado con el
dSYM de su tanda (UUID comprobado). Los parches de ANGLE de la 3.1 buscan bajar estos símbolos.

| Símbolo | 3.0.0 (control) | t1 | t2 | t3 | t4 |
|---|---|---|---|---|---|
| `CrGpuMain` activo (% del tiempo) | 92,2 | 90,4 | 87,5 | 76,7 | **66,5** |
| `updateTextures` | 21,9 | **0,0** | 0,0 | 0,0 | 0,0 |
| `bindToShader` | 18,2 | **0,1** | 0,1 | 0,0 | 0,1 |
| `setTexture` | 14,3 | **0,1** | 0,2 | 0,1 | 0,2 |
| `ProgramExecutableMtl` | 30,1 | **10,8** | 12,2 | 12,1 | 13,2 |
| `ContextMtl::drawElementsImpl` | 52,7 | 41,5 | 36,1 | 30,7 | **23,6** |
| `partition_alloc` | 5,2 | 7,3 | **1,6** | 1,2 | 1,0 |
| malloc/free bajo `resolveDrawElementsDraw` (fila 3) | 1,6 | 2,5 | **0,0** | 0,0 | 0,0 |
| `deviceOrFeatureProfileSupportsFeatureSet:` (fila 4) | 0,5 | 0,7 | 1,8 | **0,0** | 0,0 |
| `vector<unsigned char>::__insert_with_size` | 5,9 | 8,8 | 9,4 | 8,7 | **0,0** |
| Flujo intermedio entero (fila 2b) | 7,8 | 10,6 | 12,1 | 11,5 | **5,4** |
| `encodeMetalEncoder`/`endEncodingImpl` + driver AMD (fila 5) | 16,5 | 22,2 | 24,5 | 29,8 | 33,8 |

- **0001** quita la reasignación de texturas y samplers de cada dibujo. `updateTextures`, `bindToShader` y `setTexture`
  pasan de más del 50 % a casi nada.
- **0002** quita las asignaciones del dibujo: `partition_alloc` baja de 7,3 a 1,6 % y la fila 3 a cero.
- **0003** quita la consulta de capacidades por dibujo (fila 4) y, con ella, la actividad del hilo baja al 77 %.
- **0004** quita el `insert` por campo del flujo intermedio, que baja a la mitad.
- Con las cuatro, los seis símbolos de la lista del README de `3.1-angle` desaparecen. `drawElementsImpl` baja a menos de
  la mitad, y lo que queda es el encoder con el driver de AMD (un tercio del tiempo activo).
- El control de la 3.0.0 repite el perfil del 09-11 (§2.3) con diferencias de 1–2 puntos.

### 3.3 Google Maps tumba el proceso de GPU, también en la 3.0.0

Al pintar el mapa (tras rechazar el aviso de cookies), Maps no consigue compilar ni enlazar el programa «AtlasWrite» de
Filament, con el registro de información vacío. El proceso de GPU cae con `exit_code=6` (SIGABRT) dos veces seguidas.
Maps se rinde («The rendering context was not restored after 25 rendering frames») y todas las pestañas con WebGL pierden
el contexto.

- **No es de la candidata:** pasa igual con la 3.0.0 de `/Applications`, la t1, la t2 y la t3. Con la t4 y la 3.0.1 no
  se llegó a Maps porque antes se colgó claude.ai (§3.5).
- En la referencia del 09-11 no se vio porque Maps se quedó en el aviso de cookies.
- Las caídas no dejan informe en `DiagnosticReports`.
- Avisado a COORDINACIÓN y MOTOR para abrir fila. No se ha quitado el 0001, porque el fallo ya está en la 3.0.0.

### 3.4 NTP privada y de invitado (parches 0004 y 0005)

Probada con la t1 y repetida con la t4 (ventana privada: mismo resultado). Son los mismos parches en las cuatro tandas.

| Comprobación | Resultado |
|---|---|
| La mosca en la ventana privada (`--incognito`) | **Sí**, en el centro, sobre el fondo morado de la página privada |
| La mosca en la ventana de invitado (`--guest`) | **Sí**, con la misma página. La cabecera dice «Ventana Privada»: no hay texto propio de invitado |
| Sin león, sin «brave search» y sin Tor | **Sí**. Texto entero: «Ventana Privada · FlyWeb nunca guarda lo que haces…» (solo `headerText1`) |
| Sin errores de Trusted Types en DevTools | **Sí**. Solo un 404 del `favicon.ico` del servidor de pruebas y el aviso de siempre `crbug/1173575` |
| La NTP normal, igual que en la 3.0.0 | **Sí**: foto de la mosca, logo, «© fotografía @lamosquita» y los mismos avisos |
| La búsqueda va al buscador predeterminado del perfil | **No** |

Cómo se probó la búsqueda:
1. En un perfil nuevo, el predeterminado es DuckDuckGo, y la NTP privada abre `duckduckgo.com/?q=…`.
2. En ventana normal se eligió Google en Ajustes. Al relanzar, Ajustes sigue diciendo «Google».
3. Con el mismo perfil y `--incognito`, la NTP privada **sigue abriendo DuckDuckGo**.

Causa probable: `GoToSearch` usa `TemplateURLServiceFactory::GetForProfile(profile_)` y da por hecho que el perfil
privado se redirige al original. En la base Brave, la ventana privada tiene su propio buscador predeterminado
(DuckDuckGo), y FlyWeb no lo muestra en Ajustes. Avisado a MOTOR y COORDINACIÓN.

### 3.5 claude.ai: la pestaña se cae o deja de responder, también con la 3.0.1 publicada

Con la t4 y con la 3.0.1, al cargar `https://claude.ai/` (página de entrada, con hCaptcha invisible):
- La 3.0.1, en la carga 1, da «Target crashed» (se cae el renderer de la pestaña). Después, la pestaña no responde por
  CDP. Con la t4, no responde desde la primera carga. Se repite en todos los lanzamientos: 2 con la t4, 2 con la 3.0.1.
- En ese momento, el proceso de GPU llena el registro de `SharedImageManager::ProduceOverlay/ProduceSkia: Trying to
  Produce … from a non-existent mailbox` y `skia_output_device_buffer_queue.cc:258 Invalid mailbox`. Son 23–46 líneas con
  la t4 y la 3.0.1, y ninguna con la 3.0.0 ni con t1–t3.
- `sample` de todos los procesos durante el cuelgue con la t4: los nueve en reposo (navegador, GPU, utilidades, cinco
  renderers), sin ningún hilo principal bloqueado. Ficheros en `entregas/local21/c31/t4-claude` y `301-claude`.
- La 3.0.0 carga claude.ai bien (09-11 y 10-11), y la t2 y la t3 también. La t1 se colgó una vez, pero después de dos
  caídas de GPU por Maps.

**No es de los parches de ANGLE:** ya está en la 3.0.1 publicada. Falta mirar en una ventana a la vista si un usuario
lo nota (pestaña «¡Vaya!» o página congelada) y bisecar 3.0.0 → 3.0.1. Avisado a COORDINACIÓN-38 y MOTOR.

#### 3.5 bis Sospechosos y bisección (MOTOR-44, 10-11, por encargo de COORDINACIÓN-38)

Lectura de los parches de `FlyWeb/seguridad/3.0.1/` y `3.0.2/` y de brave-core `seg/3.0.2` (`6415661d`, `ef5de1bd`,
`0d6a771f`). Nada probado.

**Lo primero no cuadra.** t1–t3 son la **misma base que la 3.0.1** (b6c544471ec, .98) más parches de ANGLE, y cargaron
claude.ai. Entonces el diff de la 3.0.0 a la 3.0.1, por sí solo, no basta. Además, el orden de las pruebas cambió: con
t1–t3, Maps (que tumba la GPU) fue antes que claude.ai; con la 3.0.1 y la t4, claude.ai fue antes. Por eso el paso 0
va antes que cualquier bisección.

**Sospechosos de la caída del renderer** (más probable arriba):
1. **0045** (CVE-2026-121044): `CHECK(IsMainThread())` nuevo en `CSSPropertyParser::ParseValueStart`. Su propio
   comentario dice que el canvas usa el parser de CSS fuera del hilo principal. Los captchas pintan en `OffscreenCanvas`
   dentro de workers para sacar huella. He comprobado `ParseColor` (no llega ahí) y `ParseFont`, que reescribe el mismo
   parche. No he comprobado `filter`, `letterSpacing`, `FontFace` en workers ni Typed OM en worklets.
2. **0051 + 0052** (CVE-2026-121036): más `CHECK(IsMainThread())`, en `CSSUnparsedValue::ToCSSValue`,
   `CSSVariableParser::ConsumeUnparsedDeclaration` y la caché de `QualifiedName`. Son de la rama principal, no del
   `[M156]`: en la 156 puede quedar alguna llamada fuera del hilo principal que upstream ya había quitado.
3. **V8:** `b56fe9b` en `patches/v8` (CVE-2026-121228, cambia el generador de bytecode; brave-core `6415661d`), la subida a
   15.6.75.51 (3.0.2 0001) y la serie del parser `bee89ad8a6` (21 commits). JS ofuscado como el de hCaptcha es justo lo
   que las pone a prueba; el mjsunit en verde no lo descarta.
4. **Foco:** `kBlockingFocusWithoutUserActivation` encendido (brave-core `ef5de1bd`) con sus 3 arreglos (3.0.2 0008–0010).
   hCaptcha invisible va en un iframe.
5. Poco probables: 0044 (`CHECK` de desbordamiento de contador en animaciones), 0058/0059 (Long Animation Frames con
   workers), XSLT y WebHID apagados.

**Ruido de la GPU** («non-existent mailbox»): casi seguro es consecuencia de la caída. Al morir el renderer se pierden sus
SharedImages y el compositor aún las pide. Si sale sin caída del renderer, los sospechosos son:
- **0055** (CVE-2026-121140): pierde el contexto si, tras usar el contexto compartido, el del decodificador no vuelve a
  quedar activo. Con ANGLE Metal en 10.14 es plausible. Deja en el registro de la GPU `failed to restore context after
  using the shared context`.
- **0039** (CVE-2026-121074, texturas tras cada dibujo) y **0015** (CVE-2026-79235, consultas al cambiar de contexto
  virtual).
- 0032/0033 solo actúan en Mali (`gpu_driver_bug_list`).

**Lo que solo pasa en Mojave** (dato de Titín: en la 7,1 la 3.0.1 carga claude.ai, aunque con sesión iniciada y no la
entrada con hCaptcha):
- En 10.14, Skia dibuja con **Ganesh GL sobre ANGLE Metal**, porque Graphite está apagado en código (`b1d/README.md`). En
  Sequoia dibuja con Graphite sobre Dawn. Así que en la 6,1 el contexto GL compartido de `SharedContextState` es de
  ANGLE Metal con nuestros parches de 10.14, y el decodificador *passthrough* lo usa para lecturas y copias de
  SharedImage.
- Por eso la **0055** sube al primer puesto de los sospechosos de Mojave. Antes, si `MakeCurrent` del contexto compartido
  fallaba o no restauraba el del decodificador, no pasaba nada. Ahora **se pierde el contexto**. Un contexto WebGL perdido
  a mitad de fotograma deja al compositor pidiendo SharedImages que ya no existen, que es justo el error del registro. La
  huella de hCaptcha (lecturas de WebGL y canvas) pasa por ese camino.
- Para comprobarlo, buscar en los registros que ya hay (`301-claude`, `t4-claude`):
  - `failed to restore context after using the shared context`;
  - `Failed to make SharedContextState context current`, que llega como error de WebGL `GL_INVALID_OPERATION`.

  Si sale alguna de las dos, es la 0055.
- **Repetirlo en la 7,1, más rápido de bisecar:** la 3.0.1 con `--disable-features=SkiaGraphite` dibuja con Ganesh, como
  Mojave. Cargar la entrada de claude.ai sin sesión y con perfil nuevo. Si cae, el fallo es del camino Ganesh/passthrough
  y no de 10.14, y se biseca en la 7,1.
- En la 6,1, `--use-angle=gl` (ANGLE sobre OpenGL en vez de Metal) separa ANGLE Metal del resto.

**Bisección para LOCAL (6,1), en este orden:**
0. **¿Se repite? Sin recompilar.** Perfil nuevo en cada lanzamiento y **solo claude.ai** (tres cargas), sin `perf` ni Maps
   antes. Alternando 3.0.0 → 3.0.1 → t3 → t4, dos vueltas, a la misma hora. Anotar caída sí o no y las líneas de
   «mailbox».
   - Si cae también la 3.0.0: el cambio es del lado de claude.ai o hCaptcha, no nuestro.
   - Si cae la t3: las pasadas buenas de ayer fueron por el orden de las pruebas, y se sigue con el 1.
   - Si solo caen la 3.0.1 y la t4: comparar `args.gn` y el PGO de las cuatro builds antes de seguir.
1. **Firma de la caída. Sin recompilar; decide entre CSS, V8 y GPU.**
   - Minivolcado en `<user-data-dir>/Crashpad/{pending,completed}/*.dmp`; si no está ahí, en el `Crashpad` del perfil por
     defecto.
   - Abrirlo con `lldb -c <dmp>` y la t4, que tiene `symbol_level=1`, y sacar `bt` del hilo que cae.
   - Arriba `ParseValueStart`, `ConsumeUnparsedDeclaration`, `CSSUnparsedValue::ToCSSValue` o `GetQualifiedNameCache` en
     un hilo de worker: sospechosos 1–2. Arriba `v8::internal::`: sospechoso 3.
   - Buscar también la frase de 0055 en el registro de la GPU.
2. **Flags, un lanzamiento cada uno con la 3.0.1, si el 1 no da firma:**
   `--disable-features=BlockingFocusWithoutUserActivation` (4) · `--disable-gpu` (si sigue cayendo, es del renderer) ·
   `--disable-accelerated-2d-canvas` · `--disable-webgl` · `--js-flags=--jitless` (si sigue cayendo, no es el JIT).
3. **Solo si 1–2 apuntan ahí, con recompilación:** quitar 0045 + 0051 + 0052 juntos (son dos CVE; si es esto, el arreglo es
   portar lo que los hizo seguros en la rama principal, no quitarlos). Después `b56fe9b`, después la serie del parser. En
   la GPU, 0055 primero.

### 3.6 Dónde está ahora el límite, y la puerta de §4.3

`ps -M` del hilo principal de cada proceso con 15 000 peces (% de CPU; tres lecturas iguales ±1):

| Hilo principal | 3.0.0 | 3.0.1 (serie) | t1 | t2 | t3 | t4 | t4 (serie) |
|---|---|---|---|---|---|---|---|
| Proceso de GPU (`CrGpuMain`) | 93,5 | 87,7 | 90,2 | 89,4 | 86,3 | 56,7 | 64,8 |
| Renderer de Aquarium (JS y llamadas WebGL) | 61,5 | 100 | 75,3 | 82,8 | 87,7 | 100 | 100 |

(Las columnas sin «serie» son la lectura de la pasada 1, justo antes del `sample`; las de la serie, al acabarla.)

- Con la t4, el hilo de GPU queda al 57–65 % y el renderer de la página al 100 %. **El límite pasa al renderer.** La
  dispersión de 15 000 peces desde la t2 viene de ahí: ya no hay un único hilo saturado, sino dos casi a la par.
- Puerta de §4.3 para hilos y varias GPU, con la t4: (1) `CrGpuMain` > 90 %: **ya no** (57–67 %); (2) encoder + driver
  > 25 %: **sí** (33,8 %); (3) cambios 1–4 aplicados: **sí**.
- **Repartir el proceso de GPU entre hilos o entre las dos D500 no subiría Aquarium ahora:** esperaría al renderer. El
  siguiente objetivo, para WebGL pesado, es el hilo principal del renderer: los enlaces WebGL de Blink, el cliente del
  command buffer y la validación en el cliente. Falta perfilarlo; el `sample` del renderer lo congela y engaña, así que
  hay que usar `ps -M` o trazas.

### 3.7 Maglev en la 6,1 (3.0.1 publicada; condición 2 de B6)

Orden de COORDINACIÓN-38, 10-11-2026. Es la condición 2 de B6 en [`DIRECTIVAS.md`](../../docs/DIRECTIVAS.md), «Maglev,
a prueba…».
- FlyWeb 3.0.1 publicada (`entregas/FlyWeb-3.0.1-release`, framework `efbe530f…`), Chrome/156.0.8078.98, V8 15.6.75.51.
- Dos lanzamientos seguidos con el mismo guion de §3: perfil nuevo en `/tmp`, ventana de 1920×1200 a la vista,
  benchmarks en 127.0.0.1. El primero sin opciones y el segundo con `--js-flags=--maglev`, que se comprobó en la línea
  de órdenes de `chrome://version`.
- Tres pasadas de cada prueba; se da la mediana, y la dispersión es (máx. − mín.) / mediana.

| Prueba | Sin Maglev | Con `--maglev` | Diferencia |
|---|---|---|---|
| Speedometer 3.1 | **10,48** (10,3 · 10,5 · 10,48; 1,9 %) | **11,19** (11,0 · 11,20 · 11,19; 1,8 %) | **+6,8 %** |
| JetStream 3 (76 pruebas, sin web-ssr) | **114,57** (111,09 · 114,92 · 114,57; 3,3 %; 0 errores) | **122,15** (121,32 · 122,41 · 122,15; 0,9 %; 0 errores) | **+6,6 %** |

- **Sin pérdida, y la ganancia queda fuera del ruido:** la peor pasada con Maglev supera a la mejor sin Maglev en las
  dos pruebas. En la 7,1 la ganancia fue del +8,2 % en ambas.
- **Ninguna caída, ningún `Check failed`:** en los dos lanzamientos no hay informes de caída, `Check failed` ni FATAL
  en el registro del navegador (`--enable-logging`).
- **Ninguna subprueba con error:** ninguna de JetStream (`.benchmark-error` vacío en las 6 pasadas) y ninguna de
  Speedometer. La consola solo muestra el aviso de JetStream por los parámetros de la URL.
- Los dos registros tienen las mismas tres líneas de ERROR, que no son de V8: el `.dat` de clean-urls y «Unable to get
  gpu adapter» (WebGPU en Mojave).
- La línea base sin Maglev (10,48 y 114,57) cuadra con el hito 0 de la 3.0.0 (10,3 y 107,63, una pasada).
- **Para B6 falta la 5,1**, cuando Titín pueda.

### 3.8 Maglev: AVX sin despacho (condición 3 de B6) y guion de la 5,1 (condición 2)

Orden de COORDINACIÓN-38, 10-11-2026 (LOCAL-19, 7,1). En la 7,1, con el mismo guion de §1.1 bis, Maglev da +8,2 % en
Speedometer 3.1 y en JetStream 3, sin caídas (`rendimiento-motionmark.md`, «Medida de Maglev y del parche `[style…]`»).

**Condición 3: sin AVX sin despacho en V8 ni en Maglev. Se cumple.**
- **Binario:** framework de la 3.0.1 publicada (`efbe530f…`; el del DMG, firmado ad hoc, es `5cf631a3…`, con la misma
  sección `__TEXT,__text`, comprobado con `llvm-objcopy --dump-section`).
- **Método:**
  - `llvm-objdump -d` de todo `__TEXT,__text` (238 MB) y recuento de las instrucciones VEX: mnemónico `v…` salvo las de
    VMX, es decir, AVX, AVX2, FMA, F16C y AVX-512 en VEX/EVEX.
  - La 3.0.1 tiene `symbol_level=0`, así que, para saber de qué fichero fuente es cada instrucción, se repitió con la
    candidata t4 (`out/Release-31`, `symbol_level=1`, con dSYM). Tiene el mismo V8, el mismo Maglev y los mismos flags;
    solo cambia ANGLE. Las dos dan **el mismo total: 403 376 instrucciones VEX**. Cada dirección se pasó por
    `llvm-symbolizer` con el dSYM: fichero, línea y cadena de inline.
  - Flags de compilación: ningún objetivo de `obj/v8/` lleva `-mavx` ni `-march=`. Los únicos con `-mavx` son
    xnnpack (261), ruy (6), webrtc (3), libvpx, libaom y skia (2 cada uno), opus, libwebp y blink (1 cada uno), todos
    fuera de V8.
- **V8: 14 instrucciones, todas en `v8/src/objects/simd.cc`** (líneas 78, 300–333). Son `fast_search_avx`, marcada con
  `__attribute__((target("avx2")))` (`TARGET_AVX2`), para la búsqueda vectorizada de `Array.prototype.includes` e
  `indexOf`. **Despacho:** solo se llama si `get_vectorization_kind()` devuelve `kAVX2`, es decir, si
  `CpuFeatures::IsSupported(AVX2)`. Si no, va a `fast_search_noavx` (SSE).
- **Maglev: 0 instrucciones AVX en el binario.** `src/maglev/` no tiene código con `target(...)`, y su única mención a
  AVX es `CpuFeatures::IsSupported(SSE4_1) || CpuFeatures::IsSupported(AVX)` (`maglev-reducer.h:61`).
- **Código JIT (Maglev, TurboFan, Sparkplug, Liftoff):** emiten AVX solo si `CpuFeatures` lo marca.
  `CpuFeatures::ProbeImpl` (`codegen/x64/assembler-x64.cc:198`) solo pone AVX, AVX2 y FMA3 si CPUID dice AVX, OSXSAVE
  está activo y XCR0 confirma el estado YMM (`OSHasAVXSupport`, con `xgetbv`). Sin `-mavx` no se definen `__AVX__` ni
  `__AVX2__`, así que no se activan en compilación. En la 5,1 (Westmere, sin AVX) Maglev emite SSE.
- **Fuera de V8 (no lo pide B6; para el registro):** el resto de las 403 376 se reparte así:
  - crates de Rust (~100 000);
  - sin línea en el dSYM (~121 000; casi todo ensamblador: libaom, libvpx, BoringSSL, ffmpeg o dav1d);
  - libaom (68 000), xnnpack (36 000), skia (33 000), simdutf (12 700), libvpx (12 200), BoringSSL (9 700), ruy, libyuv,
    `pdf/paint_manager_simd.cc`, opus, libwebp, webrtc, `media/base` y blink (167).

  Todas son bibliotecas con despacho propio por CPUID (`target`/`-mavx` en ficheros aparte). **No lo he comprobado
  función a función.** La prueba real es la 5,1: un SIGILL saldría como caída.
- Ficheros: `temp/local19/avx/` (`avx.sh`, `avx-301.tsv`, `avx-t4.tsv`, `sym.jsonl`).

**Condición 2 en la 5,1: guion preparado para Titín.** Está en `entregas/prueba-51-301-maglev/`, con `LEEME.txt`.
- Se lanza con doble clic en `medir-maglev-51.command`.
- Copia la 3.0.1 del DMG publicado a `/tmp` y la abre dos veces, con ventana y perfil nuevo en `/tmp`: sin opciones y
  con `--js-flags=--maglev`.
- En cada una pasa Speedometer 3.1 y JetStream 3 (76 pruebas, sin web-ssr) tres veces, servidos en 127.0.0.1 desde
  `bench/`.
- Comprueba el flag en `chrome://version` y cuenta los volcados de Crashpad y las líneas `Check failed`, `FATAL` y
  `SIGILL` del registro.
- Deja `resultado-51-<fecha>.txt` con las medianas y un `.json` por caso.
- El conductor (`mb51.py`) es un cliente CDP solo con la biblioteca estándar, válido para el Python 2.7 de Mojave y para
  Python 3. Mide como `l21.py`/`m71.py`.
- Probado en la 7,1 sin ventana, con una pasada y Python 3: sin Maglev, 18,9 y 165,6; con Maglev, 20,7 y 180,3; sin
  caídas. Con Python 2.7 no se ha podido probar (no hay ninguno en la 7,1).

## 4. Método y datos

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
- **Candidata (§3):** `s61-c31.sh` (6,1) y `c31.py` (conductor) por `corre.sh ETQ TANDA MODO [FLX]`. Modos: `corr`
  (texturas, capturas, NTP normal, páginas de fuera), `perf` (Aquarium y MotionMark con `sample` a 15 000), `ntp`
  (NTP de la ventana inicial y búsqueda desde su cuadro), `buscador` y `ajustes` (cambiar y leer el predeterminado),
  `aq` (serie de Aquarium sin `sample`; con `HILOS=1`, `ps -M` y `sample` al final) y `claude` (tres cargas; si una no
  responde, la orden `todos` del vigilante saca `sample` de cada proceso del perfil).
  Hay tres modos más:
  - `sp` y `js` (§3.7): tres pasadas de Speedometer 3.1 y de JetStream 3. Antes leen `chrome://version` para comprobar
    `--js-flags`.
  - `diseno`: capturas de la NTP privada y de las ventanas para el diseño de la 3.2, en `entregas/local21/diseno-32`.
    Cambia el tema con `setBraveThemeType`. Las órdenes `privada` y `ventanas` del vigilante abren la ventana privada
    en el mismo navegador y hacen `screencapture -l` de cada ventana.
  `corr` va en un lanzamiento aparte después de `perf`, porque Maps tumba el proceso de GPU. `SEGUIR`/`CONSERVAR`
  reutilizan el perfil de `/tmp` entre lanzamientos, y se borra al final.
  `comparar-sample.py` compara dos análisis; resultados en `entregas/local21/c31/<tanda>`.
- **Ficheros:** guiones, `sample`, `ps -M`, `spector.json` y análisis JSON están en la carpeta de entregas de LOCAL-21
  (`entregas/local21/paso2`, `paso3` y `hito0-71`), fuera del repo.

## 5. Pendiente

- **claude.ai (§3.5):** verlo en una ventana a la vista y bisecar 3.0.0 → 3.0.1. Maps con la t4 y la 3.0.1.
- **Renderer (§3.6):** perfilar el hilo principal del renderer de Aquarium con 15 000 peces con la t4.
- **7,1 con ventana:** COORDINACIÓN-37 pide repetir con ventana visible MotionMark y Aquarium de §1.1 (las cifras
  headless no son comparables con la 6,1). A la espera de que Titín autorice abrir ventanas en la 7,1.

- **7,1:** el mismo perfil del hilo de GPU como control (Sequoia, W6600X). La repetición con Chrome 156 y el perfil de
  Multiply ya están hechos: §1.1 bis y [`rendimiento-motionmark.md`](rendimiento-motionmark.md). Queda separar en
  Speedometer y JetStream lo que es del PGO de lo que es de Brave.
- **Fila 6:** `sample` de una 3.0.0 sin PGO del mismo commit.
- **`angle_perftests`** (`DrawCallPerfBenchmark.Run/metal*`, `DrawElementsPerf*`, `UniformsPerf*`): no intentado.
- **Del hito 0, sin hacer:** las dos medidas de claude.ai sin hCaptcha y la fila del A/B de PGO con valores absolutos.
  La 5,1, cuando Titín pueda: Maglev con `entregas/prueba-51-301-maglev/medir-maglev-51.command` (§3.8).
