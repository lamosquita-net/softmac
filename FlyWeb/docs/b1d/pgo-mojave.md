# PGO de Google en Mojave (INVESTIGACIÓN-MOTOR-9, 06-11-2026)

Problema: `oficial-8-pgo`, compilada con el perfil de Google, mejora mucho en la MacPro7,1 con Sequoia
(Speedometer 15,8 → 19,6, MotionMark 2585 → 3244). En la MacPro6,1 con Mojave va muy lenta, se cuelga en
React-stockcharts-SVG y da «error al cargar el manifest».

**Conclusión (revisada el 06-11 con datos de Titín y COORDINACIÓN-29):**
- **Rendimiento.** El perfil de Google no vio nunca ejecutarse la ruta de dibujo que usa Mojave (Skia Ganesh GL sobre
  ANGLE/Metal), así que esas funciones salen `cold`. Pero en la práctica **no se nota**: MotionMark en la 6,1 da 1494
  con PGO frente a 1381 de `oficial-6` sin PGO, un 8 % más. H2 y H3 quedan como «frío en el perfil, sin efecto medible»
  (sección 3).
- **El problema real es de carga, no de velocidad.** JetStream no termina de cargar con `oficial-8-pgo`, ni en la 7,1
  ni en la 6,1. Tampoco carga en Chrome 153/156/157.
- **La miscompilación por PGO (H7) es poco probable:**
  - Brave 1.96, en su versión de publicación, **también usa el PGO de Google** y sí carga JetStream (sección 6c).
  - El «~150» en el que se para no corresponde a ninguna prueba. Es el contador de **descargas terminadas** de unas
    460 peticiones simultáneas. Una sola petición que no termina bloquea la carga **sin dar error** (sección 6a).
- **Hipótesis principal: red y field trials (H5+H6).** Lo que comparten los navegadores que fallan es que aplican
  configuración de campo: Finch en Chrome y `fieldtrial_testing_config.json` en Chromium sin marca. Brave la apaga
  siempre. Entre esos estudios hay varios de red: `NetTaskScheduler` con el arreglo `SpdyDrain`, `HappyEyeballsV2`,
  `OptimisticDnsForTcp` y la caché de disco SQL.
- **Ojo con el contraste oficial-6/oficial-8-pgo:** no es un A/B limpio. Las dos compilaciones se diferencian en más
  cosas que el PGO (ANGLE en la punta, guardas de selectores, T10), y se midieron **en días distintos**, mientras
  browserbench.org daba ERR_HTTP2_PROTOCOL_ERROR. La decisión depende del control del mismo día (sección 6e).
- **La capa Mojave queda descartada como causa:** JetStream falla igual en Sequoia, donde la capa no hace nada.

## 1. Qué hace clang con el código que el perfil no vio

Las fuentes son de llvm-project, `main` salvo que se indique `release/21.x`. El perfil es de instrumentación IR (bit
`VARIANT_MASK_IR_PROF` en la cabecera).

- **Función con todos los contadores a 0:**
  - `PGOInstrumentation.cpp`: `F.setEntryCount(0)` y la función entra en `ColdFunctions`.
  - Después recibe **`F->addFnAttr(Attribute::Cold)`** (líneas 2144-2148 y 2224-2241).
  - Las funciones con perfil caliente reciben `InlineHint`.
- **Inlining** (`InlineCost.cpp`: 64-89 y 2063-2101):
  - El umbral normal es 225; con `-inlinehint-threshold=360` de Chromium en ThinLTO, 360 para las calientes.
  - Una llamada fría o un callee frío usa **45**, sin bonificaciones.
  - El código frío casi no se inlinea, ni hacia dentro ni hacia fuera.
- **PGSO, optimizar para tamaño guiado por perfil** (`SizeOpts.cpp`: 18-35 y 51-89; `pgso=true` por defecto):
  - Con un perfil de *working set* grande, todo lo que no esté caliente al percentil 95 (`pgso-cutoff-instr-prof=950000`)
    se trata como `optsize`.
  - El perfil de Chrome **lo es**: el corte 990000 tiene 107.343 contadores, y el umbral está en 12.500
    (`ProfileSummaryBuilder.cpp`: 33-52).
  - Con `optsize` se desenrolla menos (`LoopUnrollPass.cpp`: 129-138, `OptSizeThreshold`).
  - Y se vectoriza peor (`LoopVectorize.cpp`: 7404-7413, sin comprobaciones en tiempo de ejecución, sin epílogo ni
    *tail folding*).
- **Función sin perfil** (hash distinto porque cambió su flujo de control, o función nueva):
  - `handleInstrProfError` avisa con «count discarded» y **no anota nada** (`PGOInstrumentation.cpp`: 1262-1312).
  - Chromium silencia ese aviso con `-Wno-profile-instr-out-of-date` y `-Wno-backend-plugin` (`build/config/compiler/pgo/BUILD.gn`: 158-173).
  - La función no recibe `cold`, porque `isFunctionColdInCallGraph` exige contadores (`ProfileSummaryInfo.h`: 163-185).
  - En cambio, PGSO con *working set* grande sí la trata como no caliente y la optimiza para tamaño. Esto se deduce
    del código de `ProfileSummaryInfo.h`: 298-323 y no está probado.
- **En Mac no hay separación de código frío:**
  - Mach-O ignora el prefijo `.text.unlikely` (`TargetLoweringObjectFileImpl.cpp`: 1473-1542).
  - `-fsplit-machine-functions` solo funciona con ELF (`release/21.x`, `clang/lib/Driver/ToolChains/Clang.cpp`: 6241-6246).
  - `hot-cold-split` viene apagado.
  - El efecto se queda en inlining y `optsize`; no hay saltos a una sección lejana.
- **Chromium 156 en Mac** (`build/config/compiler/pgo/*`, `compiler.gni`):
  - `chrome_pgo_phase=2` es el valor por defecto en las compilaciones oficiales, con ThinLTO.
  - Añade `-enable-ext-tsp-block-placement=1`.
  - `-pgo-cold-func-opt=minsize` va solo en Android y Fuchsia; en Mac los fríos usan las reglas de arriba, sin `minsize`.
- **Qué perfila Google** (`tools/pgo/generate_profile.py`: 1180-1281):
  - Speedometer 3, JetStream 3 y `system_health.common_desktop`.
  - En darwin, además, MotionMark normal y MotionMark con `SkiaGraphite`.
  - En Mac 156, `kSkiaGraphite` está activado por defecto (`gpu/config/gpu_finch_features.cc`: 383-389).
  - Ninguna pasada dibuja con Ganesh.
- **Documentación de clang** (UsersManual, sección PGO, `release/21.x` 3115-3124): «As you make changes to your
  code, clang may no longer be able to use the profile data. It will warn you when this happens.»

## 2. Datos del perfil

- **Perfil:** `chrome-mac-8078-1793642157-09366e2d…-4f610018….profdata` (321 MB). Es el de `chrome/build/mac.pgo.txt`,
  tanto en el tag 156.0.8078.90 como en la punta de `flynk-b1d`. Se bajó de
  `storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/`.
- **Formato:** índice v14. El `llvm-profdata` 18 de Ubuntu no lo lee, así que se leyó con un lector propio en Python
  (apéndice).
- **Validación del lector:** recorre el fichero entero sin errores y saca 1.177.903 registros, frente a los 1.178.927
  que declara el resumen.
- **Umbrales del resumen:**
  - Caliente (corte 990000): contador ≥ 25.481.
  - PGSO (corte 950000): ≥ 228.419.
  - Frío (corte 999999): ≤ 4.

Porcentaje de funciones con todos los contadores a 0. Los grupos se definen por el nombre *mangled*:

| Grupo | funciones | % a 0 |
|---|---|---|
| **Todo el perfil** | 1.177.903 | 77,6 % |
| **Skia Ganesh GL (`GrGL*`)** | 821 | **100 %** |
| Skia Ganesh (`Gr*`, `skgpu::ganesh`)¹ | 4.837 | 98,6 % |
| `GrTriangulator`, `ganesh::AtlasPathRenderer`, `TessellationPathRenderer`, `PathTessellator`, `GrGLSLProgramBuilder` | 162 | **100 %** |
| Skia Graphite (`skgpu::graphite`) | 2.389 | 40,9 % |
| Skia común (`Sk*`) | 15.765 | 70,6 % |
| ANGLE back-end Metal (`rx::mtl`, `*Mtl`)² | 1.479 | 55,2 % |
| ANGLE back-end GL (`rx::*GL`), sin uso en B1d | 691 | 90,6 % |
| ANGLE front-end (`gl::`) | 6.648 | 80,2 % |
| ANGLE traductor (`sh::`) | 2.285 | 65,0 % |
| V8 (`v8::internal`) | 74.158 | 60,3 % |
| Blink (`blink::`) | 270.406 | 76,9 % |
| Blink `LayoutSVG*` | 626 | 51,6 % |
| cc | 6.597 | 39,4 % |
| viz | 10.568 | 52,2 % |

¹ Las 69 funciones con cuenta del grupo Ganesh son tipos compartidos que usa Graphite (`GrBackendSemaphore`,
`GrPromiseImageTexture`…). No hay ninguna función de dibujo de Ganesh con cuenta.
² Solo tienen cuenta la inicialización y las tablas de formatos. El dibujo está frío: `rx::ContextMtl::drawElements`
da 0, `drawArrays` 1, `RenderCommandEncoder::draw` 2, y las entradas `GL_DrawElements*`, `GL_TexSubImage2D` dan 0.

Ejemplo de la ruta de SVG:

| Función | Contador de entrada |
|---|---|
| `blink::LayoutSVGShape::Paint` | 405.965 |
| `SkCanvas::drawPath` | 866.546 |
| `skgpu::graphite::Device::drawPath` | 840.774 |
| `skgpu::ganesh::Device::drawPath` | **0** |
| `skgpu::ganesh::SurfaceDrawContext::drawPath` | **0** |

En Mojave, Blink y el `SkCanvas` del renderer están calientes y bien optimizados. Las mismas llamadas, en el proceso
de GPU, entran en Ganesh y luego en ANGLE, que el perfil marca como frío.

**Funciones de flynk-b1d.**
- Método: 104 funciones sacadas de los *hunks* de `git diff 23b0e24a..flynk-b1d`, en los 92 `.cc`/`.mm` (sin contar
  los rolls de ANGLE y Dawn).
  - 49 tienen todos los contadores a 0 en la 156 de serie.
  - 32 no aparecen, porque se *inlinearon* o son nuevas.
  - 23 tienen cuenta, casi todas de arranque o configuración (< 2.000): `GetCPUType`, `IsSkiaGraphiteEnabled`,
    `ParseGpuPreferences`, `InitializeGpuModes`…
  - El emparejamiento es por nombre, así que es aproximado.
- Excepciones con cuenta alta:
  - **`SpinningMutex::LockSlow`** de PartitionAlloc: 19.035. Es la ruta lenta del cerrojo con contención.
  - **`IOSurfaceSetColorSpace`**: 9.507.
- Al cambiar su flujo de control, estas funciones **pierden su perfil**: se compilan sin datos y no como frías. Rinden
  más o menos como sin PGO; PGSO puede optimizarlas para tamaño, algo que no está probado.
- `LockSlow` en 10.14 no usa `OS_UNFAIR_LOCK_ADAPTIVE_SPIN`. Esa diferencia existe igual con PGO que sin él, así que
  no explica la diferencia entre `oficial-8` y `oficial-8-pgo`.

## 3. Hipótesis

| | Veredicto con los datos del perfil | Falta |
|---|---|---|
| **H1**: los caminos de 10.14 de flynk-b1d salen fríos | **Débil.** Sus funciones pierden el perfil (no reciben `cold`) y casi ninguna es caliente | `sample` de la 6,1: ¿aparece `LockSlow` arriba? |
| **H2**: Skia Ganesh frío | **Frío en el perfil (100 % a 0), sin efecto medible.** MotionMark en la 6,1 sube un 8 % con PGO (1494 frente a 1381). El coste de CPU de esas rutas pesa poco frente al de la GPU | Si sobra tiempo, `sample` de la GPU en React-stockcharts-SVG |
| **H3**: ANGLE | **Lo mismo que H2.** El dibujo de `ContextMtl` está frío, sin efecto medible | — |
| **H4**: runtime C++ de V8 y Blink | **Perfilado** (Speedometer y JetStream entran en el perfil; V8 tiene un 60 % a 0, por debajo de la media). PGO ahí debería ayudar. No explica que una carga no termine | `sample` del renderer durante el cuelgue |
| **H5**: red | **Principal, junto con H6.** JetStream se queda colgado esperando descargas (sección 6a), browserbench.org da ERR_HTTP2_PROTOCOL_ERROR y su cortafuegos ya filtró recursos en el lanzamiento | JetStream servido en local; `--disable-http2` |
| **H6**: field trials (configuración de campo) | **Principal.** Separa a los que fallan (Chrome con Finch, Chromium con `fieldtrial_testing_config`) de Brave, que los apaga. Hay estudios activos en Mac de red y de V8 (sección 6d) | `--disable-field-trial-config`, mismo día y misma red |
| **H7**: miscompilación por PGO | **Poco probable.** Brave 1.96 usa el mismo tipo de perfil y carga. Una miscompilación no se vería como «una descarga que no acaba», sino como una caída o un resultado erróneo | `oficial-8` sin PGO, el mismo día (sección 6e) |

**Sobre la hipótesis de Titín:** la capa Mojave queda descartada para JetStream, porque falla igual en Sequoia. Para el
rendimiento de dibujo, el código que solo corre en Mojave (Ganesh, que es de serie) sale frío en el perfil, pero
MotionMark no lo nota.

## 4. Pasos para LOCAL en la 6,1 (enviados a COORDINACIÓN-29 el 06-11)

0. Servir Speedometer 3 y JetStream en local (LOCAL-19).
   - Si en local `oficial-8-pgo` no se cuelga y no da el error de manifest, el cuelgue era H5.
1. Lanzar cada compilación con `--user-data-dir` limpio y `--enable-logging=stderr`, guardando la salida en un `.log`.
   Guardar `chrome://gpu` de cada una: las dos tienen que decir GaneshGL y el mismo ANGLE Metal.
2. Manifest: abrir DevTools (consola y red) antes de cargar la página. Apuntar el mensaje exacto, la URL y el código
   HTTP. Repetir con `--disable-http2`.
3. Durante el cuelgue en React-stockcharts-SVG, y en TodoMVC-React como control, en cada compilación:
   - `sample <pid> 10 -file …` del renderer, de la GPU y del navegador (5 s).
   - `top -l 3`.
   - Anotar qué proceso está al 100 %.
4. Speedometer en local: 3 pasadas por compilación, con el desglose por subprueba.
   - Si solo caen las de SVG/canvas → H2.
   - Si caen todas → otra causa.
5. MotionMark 1.3 en local, con el desglose por prueba.
6. La prueba de la 7,1 con `--disable-skia-graphite` de la sección 3.
7. Mandar los `sample`, los logs, `chrome://gpu` y las tablas. Con los `sample` se ve si el tiempo se va a
   `Gr*`/`skgpu::ganesh`, a `rx::`/`gl::`, a funciones de flynk-b1d o a V8.

## 5. Remedios, de menos a más trabajo

En cada caso, primero se confirma con los `sample` de la sección 4.

1. **Quitar PGO a Skia Ganesh y ANGLE** (`configs -= [ "//build/config/compiler/pgo:default_pgo_flags" ]` en sus
   objetivos de GN; 1 hito).
   - Esos módulos se compilan como sin PGO: sin resumen de perfil, así que sin PGSO ni `cold` propios.
   - Conserva la ganancia en Blink y V8.
   - Dos dudas sin verificar:
     - Con ThinLTO, ¿PGSO trata como no calientes las funciones sin perfil al *inlinearlas* en módulos con perfil?
     - Graphite pierde PGO también en Monterey y versiones posteriores (efecto menor; Monterey no tiene garantía).
   - Hay que elegir bien los objetivos: Skia es un solo objetivo con Ganesh y Graphite dentro, así que quizá haga falta
     separar los `sources` de Ganesh.
2. **Variante global barata: `-mllvm -pgso=false`** (1 hito, un solo arg).
   - Quita `optsize` a todo lo no caliente, pero mantiene `cold` y el inline a 45 en Ganesh.
   - Arreglo parcial: sirve como experimento A/B para medir cuánto pesa cada mecanismo.
3. **PGO solo en V8 y Blink** (1-2 hitos).
   - Es lo contrario del remedio 1: más sencillo de razonar, pero pierde la ganancia de cc, viz y net en Sequoia.
4. **Perfil propio en Mojave** (3-4 hitos el primero, 1 por cada versión nueva de Chrome).
   - Compilar con `chrome_pgo_phase=1` en la 7,1.
   - En la 6,1, ejecutar `tools/pgo/generate_profile.py` (docs/pgo.md): Speedometer 3, JetStream 3 y MotionMark, más
     un recorrido SVG/canvas.
   - Fusionar con el de Google: `llvm-profdata merge --weighted-input=…` (lo admite `generate_profile.py`: 384-398 y
     1024-1044). Hay que usar el `llvm-profdata` de la propia toolchain de Chromium (formato v14).
   - Calienta Ganesh y ANGLE y conserva lo de Google.
   - Riesgos:
     - Un perfil hecho con poca carga calienta de más lo que se midió.
     - Hay que rehacerlo en cada subida de Chromium, porque los hashes cambian.
     - El binario instrumentado tiene que funcionar en Mojave.
5. **No usar PGO en las compilaciones para Mojave** (0 hitos).
   - Mojave es el objetivo garantizado, así que en la práctica sería quitar PGO a la 3.0.0 entera. Se pierde lo ganado
     en Sequoia, aunque deja de ser un riesgo.
   - Es la opción de reserva si 1 o 2 no recuperan el SVG.

**Recomendación (revisada):** con MotionMark +8 % en la 6,1, **ninguno de estos remedios hace falta ahora**. Se quedan
como reserva por si alguna medida concreta de dibujo en Mojave (SVG, canvas) empeora con PGO. Lo urgente es la sección 6.

## 6. JetStream no carga (H5, H6 y H7; encargo de COORDINACIÓN-29, puntos a–d)

**a) Qué es el «~150».** Sale del código de JetStream 3.0, publicado el 31-03-2026; rama `JetStream3.0` y `main` de
github.com/WebKit/JetStream, `JetStreamDriver.js`.
- Tiene 94 pruebas, de las que 77 están activas por defecto.
- Con `prefetchResources=true`, el valor por defecto (`utils/params.js:41`), descarga **todos** los recursos a la vez
  antes de empezar: `await Promise.all(promises)` en las líneas 530-534.
  - Cada recurso se pide con `fetch(…, {cache: "no-store"})`, se reintenta hasta 3 veces y se guarda en un `Blob`
    (216-241).
- El contador «Loading N of M» suma **descargas terminadas**: 694 elementos, unas 462 URL distintas y unos 199 MB.
  - Lo más pesado: un `.onnx` de 67 MB y varios `.wasm` de 8 a 11 MB.
  - **El 150 no identifica ninguna prueba.** Indica que unas 300 peticiones no han terminado.
- **Una petición que se queda colgada, sin llegar a fallar, bloquea la carga para siempre sin mostrar «Fetch
  failed».** Los reintentos solo empiezan cuando el primer `Promise.all` ha terminado (536-548).
  - Encaja con lo que se ve: más de 400 flujos HTTP/2 simultáneos y ERR_HTTP2_PROTOCOL_ERROR en browserbench.org.
- En el orden en que se declaran, alrededor del 150 están `sqlite3-wasm`, `richards-wasm`, `tsf-wasm` y Dart flute
  (WasmGC). No significa nada, porque las descargas no terminan en ese orden.
- Funciones que usa: WasmGC (Dart, Kotlin compose, j2cl), Wasm SIMD con un solo hilo, *workers* y `DecompressionStream`
  (`deflate`, 3 ficheros `.z`). No usa JSPI, COOP/COEP ni SharedArrayBuffer.

**b) Fallos conocidos.**
- No he encontrado ningún informe en crbug, issues.chromium.org ni en los issues de WebKit/JetStream de Chrome 15x que
  no cargue JetStream 3, ni de ERR_HTTP2_PROTOCOL_ERROR en browserbench.org.
- Sí consta que **el cortafuegos de browserbench.org bloqueaba recursos** en el lanzamiento: commit de K. Miller del
  31-03-2026, que renombró los `*.js.map` y `tsconfig.json`. Es un precedente de filtrado en el servidor.
- Desde la nube no se puede abrir browserbench.org, porque el proxy lo rechaza. No he visto qué sirve.

**c) ¿Usa Brave PGO?** **Sí, en las versiones que publica.**
- `build/commands/lib/config.ts:294` de brave-core v1.96.61: `'checkout_pgo_profiles': this.isBraveReleaseBuild()`.
- `buildArgs.ts:96-97`: `chrome_pgo_phase = 0` solo cuando **no** es una compilación de publicación.
- Brave 1.96.61 descargado es una de esas, así que lleva el perfil de Google de su rama (154).
- **Que Brave cargue JetStream debilita mucho H7:** el PGO de Google en sí no rompe JetStream.
  - Falta verificar: que la CI de Brave ponga `is_brave_release_build=1`, porque eso no está en el repo.
  - Matiz: es la 154, no la 156.

**d) Brave frente a Chrome y Chromium.**
- Brave pone siempre **`disable_fieldtrial_testing_config = true`** (`build/args/brave_defaults.gni:11`).
  - V8 de serie: solo `v8_enable_verify_heap` con ASan.
  - Solo pone `--wasm-jitless` cuando el usuario apaga el JIT.
- **En Chromium 156 sin marca, el `fieldtrial_testing_config.json` se aplica por defecto**, salvo con ese arg de GN,
  `--disable-field-trial-config` o `--variations-server-url`.
  - Fuentes: `variations_field_trial_creator.cc:133-155`, `components/variations/service/BUILD.gn:14-27` y
    `testing/variations/README.md:13-25` («Non-developer builds of Chromium … should disable the testing config»).
  - `is_official_build` no cuenta para esto.
  - Chrome con marca no usa el fichero, pero sí Finch, del servidor, con estudios parecidos.
- **¿Lo tienen puesto nuestras oficiales de flynk-b1d?** No consta en el repo. B1d es Chromium sin Brave, así que lo más
  probable es que **no**.
  - LOCAL tiene que mirarlo en `out/*/args.gn`.
  - También en `chrome://version`, en la línea «Variaciones» o «Variations».
- Estudios activos en Mac (el primer experimento de cada uno) que pueden explicar el fallo:
  - **Red:**
    - `NetTaskScheduler` (Enabled_SpdyDrainFix: `DrainSpdySessionSynchronouslyOnRemoteEndpointDisconnect`): toca el
      vaciado de la sesión HTTP/2, que es el más sospechoso.
    - `HappyEyeballsV2`.
    - `OptimisticDnsForTcp`.
    - `DiskCacheBackendExperiment` (caché de disco SQL; las peticiones llevan `no-store`).
    - `HttpCacheZstdCompression`.
  - **V8:**
    - `V8Turbolev` (`V8Flag_turbolev`: Maglev hacia Turboshaft).
    - `V8SparkplugPlus`.
    - `V8HomomorphicIC`.
    - `V8SideStepTransitions`.
    - Estos solo importarían si la carga termina y lo que falla es la ejecución.
- La configuración es la misma en `oficial-6` y en `oficial-8`, salvo que haya cambiado entre esas dos entregas, así
  que H6 sola no explica por qué `oficial-6` sí cargó. Por eso es clave la medición del mismo día (e).

**e) Pasos para LOCAL**, en este orden y **todo el mismo día y desde la misma red**:
1. **`oficial-6`, `oficial-8` sin PGO y `oficial-8-pgo`** contra browserbench.org/JetStream.
   - Si fallan las tres, el PGO y la 8 quedan descartados: es la red o el servidor.
2. En la que falle:
   - `--disable-field-trial-config`.
   - Después, `--disable-http2`.
   - Después, `--disable-features=NetTaskScheduler,HappyEyeballsV2,OptimisticDnsForTcp,DiskCacheBackendExperiment`.
3. JetStream **servido en local** (lo que monta LOCAL-19), dos veces: con `prefetchResources` por defecto y con
   `?prefetchResources=false`. Antes hay que descomprimir los `.z` (`npm run decompress`).
   - Si en local carga todo → H5/H6 de red. JetStream entonces mide igual.
4. Si **solo** falla `oficial-8-pgo`, también en local y sin field trials, entonces sí H7.
   - Ahí van `--js-flags=--no-maglev`, `--no-turbofan`, `--no-liftoff` y `--no-wasm-tier-up`, como prevé COORDINACIÓN.
5. Mientras está parado: `chrome://net-export` (NetLog) desde antes de cargar, y DevTools → Red, filtrando «Pending».
   - Con eso se ve qué peticiones no acaban y con qué error de HTTP/2 (RST_STREAM, GOAWAY o PROTOCOL_ERROR).
   - El NetLog no se sube al repo, porque lleva cookies y URL. Se pasa resumido.
6. Mirar si `chrome://version` muestra las variaciones activas.
   - Si las muestra, **`disable_fieldtrial_testing_config = true`** en las oficiales (como Brave y la 2.x) debería
     entrar en los args de la 3.0.0, por coherencia con el README de Chromium. Es una recomendación independiente de
     este fallo.

## Apéndice: lector del perfil (v14, IR)

```python
# python3 -I dump.py perfil.profdata salida.tsv  → nombre, nº contadores, entrada, máx, suma
import sys, struct, mmap
m = mmap.mmap(open(sys.argv[1], 'rb').fileno(), 0, access=mmap.ACCESS_READ)
u = lambda o: struct.unpack_from('<Q', m, o)[0]
out = open(sys.argv[2], 'w'); hashoff = u(32)            # cabecera: 9 × u64
o = 72; nf, nc = u(o), u(o + 8); o += 16 + nf * 8 + nc * 24  # resumen
while o < hashoff:                                         # cadenas del OnDiskChainedHashTable
    cnt = struct.unpack_from('<H', m, o)[0]; o += 2
    for _ in range(cnt):
        kl, dl = u(o + 8), u(o + 16); o += 24              # hash, long. clave, long. datos
        name = m[o:o + kl].decode('utf-8', 'replace'); o += kl
        d, end = o, o + dl; o = end
        while d < end:                                     # un registro por hash de CFG
            k = u(d + 8); d += 16
            cs = struct.unpack_from('<%dQ' % k, m, d); d += 8 * k
            nb = u(d); d += 8 + 8 * nb                     # bitmap (MC/DC)
            ex = u(d); d += 8 + 8 * ex                     # campo añadido en v13/v14
            d += struct.unpack_from('<I', m, d)[0]         # ValueProfData (TotalSize)
            out.write('%s\t%d\t%d\t%d\t%d\n' % (name, k, cs[0] if k else 0, max(cs, default=0), sum(cs)))
```
