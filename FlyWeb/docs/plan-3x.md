# FlyWeb 3.x: plan de avance después de la 3.0.0

ARQUITECTURA. Estudio del 08-11-2026 (encargo de COORDINACIÓN-34), **rehecho el 09-11 con el plan que aprobó Titín**
(`docs/DIRECTIVAS.md:307-316`, «Plan de la 3.x aprobado», #883; detalle de COORDINACIÓN-35 en el buzón `20261109-1150`).
El orden ya está decidido; este documento es su detalle: hitos, criterios, riesgos y quién hace qué. **Solo papel.**
Sin horas. Las decisiones que quedan para Titín están en §7.

Marco: directiva «Versiones desde la 3.0.0» (Titín, 07-11): el **segundo dígito** (3.1, 3.2…) son nuestros avances; el
**tercero** (3.0.1, 3.0.2…), tandas de seguridad al ritmo de Chrome estable más arreglos. claude.ai es criterio de aceptación
de cada versión. Marcas: **[V]** verificado en el repo (fichero citado); **[I]** inferencia mía; **[N]** no comprobado. Rutas
relativas a `FlyWeb/docs/` salvo que se diga otra cosa.

## 1. El plan en una página

| Línea | Qué | Cuándo | Hito que la cierra |
|---|---|---|---|
| **3.0.x, seguridad** | Tandas cada 2–4 semanas al ritmo de Chrome estable; KEV y críticos al momento; medida mensual de «entran limpios» | **Siempre en marcha**, en paralelo con todo lo demás | Cada tanda publicada; la 3.0.1 = FS.42 + PDFium + parser de V8 (si mjsunit sale bien) + marca de MOTOR-42 + tests y depfile (§2.1) |
| **Hito 0, línea base** | Medir la 3.0.0 en la 7,1, la 6,1 y la 5,1 (MotionMark a 60 Hz, Speedometer, JetStream, Aquarium) y claude.ai; publicar el A/B de PGO con números | Ya; dentro del ciclo 3.0.x, no es versión | Tabla `rendimiento-3x.md` con la 3.0.0 en las tres Mac (§3) |
| **3.1, GPU e hilos (FM.56)** | Perfil del hilo del proceso de GPU; ANGLE Metal más barato por dibujo; sin parón de primera carga; A/B de PGO; Maglev si cumple B6. **Puerta con datos:** hilos y varias GPU solo si el perfil dice que ese hilo es el cuello | **Adelante ya**; primer hito = perfil (LOCAL) + lectura de ANGLE (MOTOR, ya hecha: `rendimiento-3.1.md`) | A 60 Hz: cerrar el hueco con Chrome en la 7,1 y subir en la 6,1 y la 5,1 sobre la línea base; claude.ai aprobado; sin caídas (§4.5) |
| **3.2, sync con cuenta (F7.7)** | Cuenta = email + contraseña + código; clave derivada en el cliente; aprobación entre aparatos; recuperación; RGPD | **Diseño en paralelo con la 3.1**; servidor y cliente después | Diseño aprobado por Titín → servidor → cliente → tres Mac sincronizando (§5) |
| **Transversal** | Sparkle 2.x; CFBundleVersion independiente de Brave; novedades de motores vigiladas por INVESTIGACIÓN-MOTOR; regla de base nueva (medida mensual + umbrales); techo de Xcode 27 como decisión aparte, sin prisa | Según §6 | — |

Reparto de máquinas que fija la directiva: **la compilación de la 3.0.1 va primero en la 7,1**; el perfilado de la 3.1 puede
ir en la 6,1 mientras tanto, así que las dos líneas no compiten [V: `DIRECTIVAS.md:309-310`].

Lo que el estudio del 08-11 señaló y **sigue en pie** dentro de este plan: no hay todavía un perfil del hilo de GPU ni un
donante para repartirlo entre hilos, por eso la 3.1 empieza por el perfil y la puerta con datos existe; PGO y Metal ya van
en la 3.0.0, así que la 3.1 los exprime; sin línea base no hay avance que se pueda aceptar ni rechazar.

## 2. Línea 3.0.x: seguridad siempre en marcha

### 2.1 La 3.0.1

Contenido fijado por COORDINACIÓN-35 (buzón `20261109-1150`) sobre lo que ya hay en el repo:

| Pieza | Estado | Fuente |
|---|---|---|
| FS.42: tanda de CVE posteriores a la 156.0.8078.90 (rama 8078 .91–.96 y estable 157) | Inventario y clasificación hechos; brave-core `seg/3.0.1` | `seguridad-3.0.1.md` §1–§5; `TAREAS.md:247` |
| PDFium: 121166, 121113, 121179 | Los tres A sobre `pdfium_revision` c97f02a3519c | `seguridad-3.0.1.md:101,176-178` |
| ffmpeg: 121047 (A), 121180 (X, con 2 líneas más), 568986882 (A) | Localizados el 08-11 | `seguridad-3.0.1.md:179-181` |
| Parser de V8 (CVE-2026-121082): serie de 21 commits en `seg/3.0.1-parser` | **Condición:** mjsunit de MOTOR-30 en verde con y sin la serie; si cae una prueba solo con ella, pasa a la 3.0.2 | `seguridad-3.0.1.md` §6 |
| Marca de MOTOR-42: `nube/b2-icono-restaurar` d3fae32d5b (barra de restaurar, logo, SVG de Sync y bienvenida, pedales) | Pendiente de fusionar; pruebas en la fila de MOTOR-42 | `coordinacion.md:32-35,47-48` |
| `nube/b2-tests` 148a5939c8 y `nube/b2-depfile` bbfb565048 | `b2-tests` toca producción (guarda de Sparkle en `sparkle_glue.mm`): **prueba de actualización real obligatoria** | `relevo-motor.md:16`; §6.4 |
| `flyweb_version` 3.0.1, `FLYWEB_BUILD_NUMBER` 42; época de caché 31 por `v8_embedder_string` | — | `coordinacion.md:47-48`; PR #790 |

Fuera de la 3.0.1 y con fecha: `nube/b2-redirect-cc` (3.0.1 o 3.0.2, con `check-overrides-156.sh` en verde), Shields,
`UpdateTargetURL` (3.0.2), 121112 (Permissions, sin localizar → 3.0.2) [V: `seguridad-3.0.1.md:184`; §6.4].

### 2.2 Ramas, cadencia y una sola versión mantenida

- **Punta de desarrollo** (hoy `flynk-b1d` en el fork de Chromium y `nube/b2-porte-t11` en brave-core): ahí entran los
  avances de la 3.1, cada uno en `avance/<tema>`, fusionado solo con su medida hecha.
- **Línea de seguridad** `seg/3.0.N`: se corta sobre el **tag de la última publicada**, lleva solo seguridad
  (`Flynk-Class: security`) y arreglos (`Flynk-Class: fix`). Cada tanda se fusiona también a la punta.
- **Una sola versión mantenida.** Publicada la 3.1.0, no hay más 3.0.x: la siguiente tanda es la 3.1.1 (regla de la 2.x
  «no sacar versión de seguridad que la siguiente vaya a sustituir», `DIRECTIVAS.md:99-101`).
- **Cadencia:** tanda ordinaria cada 2–4 semanas; **KEV o crítico explotado: ≤ 48 h** desde el aviso hasta la versión
  (`docs/SEGURIDAD.md:21`), con el interruptor de JIT como medida provisional si no llega a tiempo.
- **Prioridad en la 7,1:** la 3.0.1 se compila primero (directiva). Después, una tanda KEV desplaza a cualquier compilación
  de avance; las ordinarias van en hueco. Con dos directorios de salida (`out/Release` seguridad, `out/Avance` avances) no
  se pierde lo compilado: cuesta disco, lo valora LOCAL. D8-LINUX pasa mjsunit a todo lo que toque V8 antes de LOCAL.

### 2.3 Medida mensual de «cuántos entran limpios»

Definición (SEGURIDAD-PORTES puede corregirla): **unidad** = commit de upstream (Chromium, V8, ANGLE, Skia, Dawn, PDFium,
ffmpeg) que arregla un CVE alto o crítico que nos alcanza y que se ha localizado; los no localizados y los N van aparte.
**Clases** A (limpio), F (con fuzz), X (conflicto o a mano). **Medida = A / (A + F + X)**. **Dos grupos siempre
separados:** grupo 1, lo que Google fusiona a la rama de nuestra base mientras la 156 esté en Extended Stable; grupo 2, lo
que solo está en ramas posteriores. El grupo 1 desaparecerá solo; **el grupo 2 mide la deuda de base.** Se anota la
distancia (hitos de Chrome desde la base, meses desde la 3.0.0). Una tabla por tanda en `seguridad-3.0.N.md`, una fila por
mes en `docs/SEGURIDAD.md`.

Noviembre de 2026, con la tabla final de `seguridad-3.0.1.md` (08-11, con ffmpeg y PDFium): **85 %** en total (79/93: 79 A,
7 F, 7 X), **100 %** en el grupo 1 (51/51: 31 Chromium + 13 V8 + 7 Skia, corregido al portar) y **67 %** en el grupo 2 (28/42,
derivado del total: todo lo añadido el 08-11 es de la 157). La tabla del 07-11 (72/85, 49/49, 23/36) quedó superada
[V: `seguridad-3.0.1.md:129-133,183-191`]. Fuera del denominador: la serie del parser (aparte) y tres críticos no portados;
SEGURIDAD dice en cada tanda cuántos críticos quedan fuera y por qué.

### 2.4 Huecos que hay que tapar

- **Vigilancia de KEV entre tandas.** VIGÍA pausada desde el 23-10, SEGURIDAD-PORTES archivada entre encargos
  [V: `TAREAS.md:12,20`]. «Al momento» exige una rutina diaria barata (Haiku) sobre `cisagov/kev-data` y Chrome Releases que
  despierte a COORDINACIÓN. Decisión de COORDINACIÓN y Titín.
- **Reloj de LOCAL por tanda** en `CONSUMO.md`: no hay cifra de cuánto tarda una Release de la 156 con PGO (la 128: 2 h 40,
  `TAREAS.md:301`).
- **Overrides muertos:** `check-overrides-156.sh` en cada tanda, no solo en el porte [V: `RELEVO-SEGURIDAD.md:502-520`].

## 3. Hito 0: la línea base de la 3.0.0

Es la base de los hitos de la 3.1: sin ella no se puede aceptar ni rechazar nada.

| Medida | 6,1 (Mojave, D500) | 5,1 (RX 580, sin AVX) | 7,1 (Sequoia, Graphite) | Fuente |
|---|---|---|---|---|
| MotionMark 1.3.2 | 3.0.0 Metal **1381** (60 fps); 2.7.0 GL 566 | 3.0.0 **864** ±2,8 % | 3.0.0 PGO 3576; Chrome 156 3861 | `pruebas-gpu.md:42,143`; `coordinacion.md:262` |
| Speedometer 3.1 | 2.7.0 **5,84**; 3.0.0 sin medir | **ninguna** | 3.0.0 PGO 20,6; Chrome 156 20,7–21,0 | `coordinacion.md:485,262`; `comparativa-71.md:7-16` |
| JetStream 3 | 2.7.0 **89,3**; 3.0.0 sin medir | **ninguna** | 3.0.0 160,7 (sin PGO); Chrome no carga | ídem |
| Aquarium 5k/10k/15k | 60/54/37 (3.0.0) frente a 60/44/30 (2.7.0) | 60/40,9/– | — | `b1d/README.md:31`; `pruebas-gpu.md:142` |
| Crear 500 programas WebGL | **22 s** Metal frente a 1 s GL | sin medir | — | `b1d/README.md:74` |
| claude.ai | sí/no a mano (Titín) | ídem | ídem | `relevo-local.md:351` |

- **Qué:** los cuatro benchmarks servidos en local (sin red) con la 3.0.0 publicada, **en las tres Mac**, monitor a 60 Hz,
  tres pasadas, mediana y dispersión; el mismo guion para cada candidata después. Más dos medidas de claude.ai que no
  dependan de hCaptcha: tiempo hasta primer renderizado de una conversación guardada en local (HAR reproducido o copia
  estática) y p95 del intervalo entre fotogramas al desplazar 500 mensajes. Todo en `FlyWeb/docs/rendimiento-3x.md`
  (tabla única, pedida desde `investigacion-pendiente.md:12`).
- **Una fila previa: el A/B de PGO con números.** Hay dos relatos que no dicen lo mismo y hay que fijar cuál vale:
  `b1d/pgo-mojave.md:20-37` compara `oficial-6` sin PGO con `oficial-8-pgo` (MotionMark 1381 → 1494, +8 %) y avisa de que
  **no es un A/B limpio** (ANGLE, guardas de selectores y T10 cambian entre las dos, días distintos, red con fallos de
  HTTP/2); con ese dato COORDINACIÓN-30 anuló «PGO siempre» [V: `coordinacion.md:262-265`]. `coordinacion.md:181` recoge el
  A/B pedido limpio, `of9` frente a `of9pgo` **del mismo commit** [V: `coordinacion.md:244`]: Speedometer +42 %, JetStream
  +9 %, MotionMark +21 %, 0 fallos, y restablece «PGO siempre». **Vale el segundo**: mismo commit a los dos lados, posterior,
  y es el que decidió que la 3.0.0 saliera con PGO; el aviso de `pgo-mojave.md` habla del contraste anterior y no lo
  contradice. Lo que no vale aún es la cifra como ganancia planificable: solo porcentajes, sin absolutos, sin fichero y sin
  decir si los benchmarks iban en local; y +21 % frente a +8 % en MotionMark hay que explicarlo. LOCAL publica ese A/B con
  sus valores, fecha, red y fichero.
- **Hito:** la tabla existe para la 3.0.0 en las tres Mac y el guion corre desde la 7,1 por ssh en la 6,1 (banco de pruebas,
  `DIRECTIVAS.md:310`). La 5,1 se mide cuando Titín puede; no bloquea.
- **Quién:** LOCAL (guion y medidas). El criterio de claude.ai: la prueba manual de Titín sigue siendo la definitiva; las dos
  medidas sirven para detectar regresiones antes de molestarle.

La 7,1 mide con Graphite y no es la máquina objetivo [V: `comparativa-71.md:4-5`], pero es donde se mide el hueco con Chrome.

## 4. La 3.1: GPU e hilos (FM.56)

### 4.1 Primer hito: el perfil y la lectura

La directiva fija el primer hito: **perfil del hilo del proceso de GPU en la 6,1 y la 7,1 (LOCAL) y lectura de ANGLE Metal
(MOTOR)** [V: `DIRECTIVAS.md:316`]. La lectura ya está: `rendimiento-3.1.md` (MOTOR, 09-11; **todo lectura de código, nada
medido**). Lo que aporta, resumido:

- **El dato de partida:** Aquarium en la 6,1 da 60 / 54 / 37 fps con 5 000 / 10 000 / 15 000 peces, igual con una D500 que
  con dos; manda el hilo principal del proceso de GPU (`CrGpuMain`). De ahí salen **~1,8 µs de hilo por pez**, que cubren
  decodificador, ANGLE común, backend Metal y driver de AMD [V: `rendimiento-3.1.md` §1]. No hay un `sample` guardado que lo
  confirme, y lo que hace Aquarium por pez está sin capturar.
- **La ruta por dibujo**, con lo que no es trabajo útil: dos `malloc`/`free` por `drawElements` (vectores de
  `DrawCommandRange`); un mutex y una inserción en un `HashSet` por recurso en `setReadDependency`, aunque ya esté
  registrado; el flujo intermedio que graba cada `set`/`draw` y lo **reproduce entero** al cerrar el pase (todo se paga dos
  veces en el mismo hilo; los uniformes se copian dos veces); un mensaje ObjC al driver (`supportsFeatureSet:`) y un `xchg`
  atómico **por dibujo** en `isDrawNoOp` y `checkCommandBufferError`; la compilación síncrona de pipelines en el primer uso
  (el parón de la primera carga) [V: `rendimiento-3.1.md` §2].
- **Upstream no lo ha tocado:** entre la base de la 8078 y `main` del 09-11 ningún commit cambia esa ruta, salvo `adaa3da`
  (caché de índices para `flat`, solo si la web lo usa). Gerrit no se pudo consultar [V: `rendimiento-3.1.md` §3].

Los cambios que propone MOTOR, con lo que el perfil tiene que confirmar antes de escribirlos:

| # MOTOR | Cambio | Ganancia (estimada por lectura) | Riesgo | El perfil lo confirma si… |
|---|---|---|---|---|
| 3 | `FastVector` en vez de `std::vector` en `resolveDrawElementsDraw` | Dos `malloc` y dos `free` menos por `drawElements`; pocos % | Bajo; hay pruebas unitarias | Aparecen `malloc`/`free` bajo `resolveDrawElementsDraw` |
| 4 | Sacar del camino por dibujo lo que no cambia por dibujo (`isDrawNoOp`, `checkCommandBufferError`, bloques UBO por índice) | Un mensaje ObjC y un atómico menos por dibujo; poco cada uno | Nulo o bajo | Se ve `supportsFeatureSet:` bajo `isDrawNoOp` |
| 1 | Dependencias de recursos sin mutex ni `HashSet` cuando ya están registradas en el mismo serial | 1–3 lock/unlock y búsquedas por dibujo; algunos % | Medio-bajo | `setReadDependency` + `pthread_mutex_*` + `HashSet::insert` más de unos pocos % |
| 2 | Flujo intermedio sin un `insert` por campo; uniformes a un anillo de buffers en vez de `setBytes` (quita dos copias) | De unos % a > 10 % **si** se ve `memmove` bajo `setBytes` o en el driver | (a) bajo; (b) medio: depende del anillo y de que la memoria `Shared` en una D500 no cueste más | `commitUniforms` + `setBytes` por encima del ~5 % |
| 6 | PGO propio para ANGLE o quitar PGO a `third_party/angle` | Desconocida; el perfil de Google tiene frío el 55 % de `rx::mtl` | Bajo: compilación | `rx::`/`gl::` cambian entre el `sample` con PGO y sin PGO más que el ruido |
| 5 | **Reproducir el encoder en otro hilo** (puente con FM.56 fase 2: hilos) | Depende de cuánto pese el driver: el cambio con más techo **si** `encodeMetalEncoder` + driver se llevan una parte grande | **Alto:** orden con blit/compute, `present` e IOSurface, oclusión, `release` de objetos | `encodeMetalEncoder` + módulo del driver de AMD **> 25 % del hilo** |
| 7 | Decodificador de Chromium (TLS por comando, cerrojo de contexto en cada entrada) | Baja | Medio (seguridad: comandos sobre el contexto equivocado) | `DoCommandsImpl` + `GetCurrent` + `SharedContextMutex` por encima del ~5 % |

[V: `rendimiento-3.1.md` §3 y la tabla de símbolos de §4.] El cambio 8 de MOTOR (`adaa3da`, `memcmp` en `setUniformImpl`)
queda anotado, no planificado.

**Qué tiene que entregar LOCAL en este hito** (es la receta de `rendimiento-3.1.md` §4): build con símbolos
(`symbol_level=1` o el dSYM de la entrega); Aquarium a 10 000 y 15 000 peces, una D500, en la 6,1, y lo mismo en la 7,1 como
control de «lo que cuesta en Mojave y no en Sequoia»; un fotograma capturado con Spector.js (cuenta exacta de `uniform*`,
`drawElements` y cambios de estado por pez); `sample` del proceso de GPU, mejor Instruments con «Separate by Thread» e
«Invert Call Tree»; porcentajes de `CrGpuMain`, `VizCompositorThread` y del hilo principal del renderer, para descartar que
el límite esté en otro sitio; y los microbenchmarks de ANGLE (`DrawCallPerfBenchmark.Run/metal*`, `DrawElementsPerf*`,
`UniformsPerf*`) si `angle_perftests` compila. **Hito cumplido:** un perfil publicado en `rendimiento-3x.md` que diga, para
cada fila de la tabla, si su condición se cumple o no, y el porcentaje de `encodeMetalEncoder` más driver.

### 4.2 Contenido de la 3.1

Por orden, cada uno con su medida antes y después en la 6,1 (y la 5,1 cuando se pueda), compilado en la 7,1 en hueco de la
3.0.x:

| # | Avance | Qué se gana | Coste | Riesgo | Aceptación |
|---|---|---|---|---|---|
| **A** | **ANGLE Metal más barato por dibujo**: cambios 3 y 4 de MOTOR siempre (riesgo nulo o bajo, «conviene hacerlo aunque gane poco»); 1 y 2 según el perfil | Según el perfil; la suma de 1–4 es lo que la lectura sitúa entre «algunos %» y «> 10 %» del hilo | Medio: interior de ANGLE Metal sin donante upstream; parches en `b1d/angle/` | Bajo en 3 y 4; medio-bajo en 1; medio en 2b | Aquarium 10k/15k y `DrawCallPerf` suben sin regresión en la batería `pruebas-gpu.md`; MotionMark ≥ línea base |
| **B** | **Sin parón de primera carga**: compilar pipelines fuera del hilo o precalentar los comunes; recuperar la caché persistente de programas (`GpuPersistentCache` va desactivada, `TAREAS.md:317`) | Parón de 0,9–1,5 s y 22 s por 500 programas → objetivo ≤ 2 s [V: `b1d/README.md:64-81`]; Shadertoy Elevated 33–58 → 60 | Medio: `MTLBinaryArchive` es de macOS 11, hay que hacerlo a mano | Medio: la 5,1 tiene otra GPU; drivers de 2018 sin pruebas de Google (`metal-mojave.md:11`) | Parón ≤ 0,2 s; sin caídas; claude.ai |
| **C** | **A/B de PGO**: publicar el `of9`/`of9pgo` con números (§3) y, con el `sample` con y sin PGO del hito (fila 6), decidir si se quita PGO a `third_party/angle` o se genera perfil propio en la 6,1 | PGO ya gana (+42/+9/+21 %); aquí se mide si las rutas frías de Mojave (Ganesh GL 100 %, ANGLE Metal 55 % a 0) dejan algo [V: `b1d/pgo-mojave.md:103-108`]; `pgo-mojave.md:222` dice que hoy ningún remedio hace falta | A/B: una Release por variante. Perfil propio: build instrumentada + recogida + fusión, **rehecho en cada subida de base** (`pgo-mojave.md:188-223`) | Bajo el A/B; alto el perfil propio (mantenimiento) | ≥ 5 % en Aquarium o MotionMark sin perder en Speedometer; si no, se queda el perfil de Google |
| **D** | **Maglev** (B6): (1) mjsunit con Maglev en verde en d8 (D8-LINUX); (2) Speedometer y JetStream con y sin Maglev en 6,1 **y** 5,1 sin pérdida; (3) sin AVX sin despacho en la 5,1 (`otool`) [V: `DIRECTIVAS.md:288-292`] | Fuente publicada: mejoras de un dígito en JetStream y Speedometer en escritorio [N: cifra a confirmar]. Dato nuestro: 2.1.1 +3 % Speedometer y **JetStream colgado 5/5** [V: `coordinacion.md:781`]. La 3.0.0 salió sin esta medida | Bajo: es un interruptor; el coste es medir y, si cuelga, depurar | Medio: el cuelgue de la 2.1.1; la V8 de la 156 ya trae sus arreglos (`DIRECTIVAS.md:289`) | Las tres condiciones; si falla una, sigue apagado y se anota |
| **E** | **Hilos** (FM.56 fase 2: cambio 5 de MOTOR, reproducir el encoder en un hilo trabajador por contexto; después, decodificación y contextos) | Lo que pese el driver en el hilo; techo alto si pasa del 25 % | Alto: sin donante, ningún navegador lo hace así (`vision-motor.md:156-163`) | **Alto** (orden de encoders, `present`, IOSurface, oclusión) | **Solo tras la puerta de §4.3** |
| **F** | **Varias GPU** (FM.56 fase 3; `flynk-b1d-dosgpu`, src b8a4abda2f, ANGLE dc5ef06, que MOTOR no ha leído) | Desconocida; hoy la segunda D500 no cambia nada porque todo ocurre en un hilo | Muy alto | Muy alto | **Solo tras la puerta de §4.3**, y con E hecho |
| — | OpenGL de comparación (B1c) | Ya medida (2.7.0 GL frente a 3.0.0 Metal) | Una oficial si se reabre | — | **No se compila**; solo si la 5,1 falla con Metal (`DIRECTIVAS.md:297`) |

Fuera de la 3.1: WebGPU (Dawn sobre Metal 2.1 en 10.14, trabajo de base; apagado por CVE-2026-5281, `DIRECTIVAS.md:20`) y
Containers (decisión de producto, §6.4). Las novedades de Chrome 157+ que INVESTIGACIÓN-MOTOR proponga entran solo si Titín
las aprueba, para no distraer de la 3.1 [V: `DIRECTIVAS.md:313-315`].

### 4.3 La puerta con datos

Repartir entre hilos (E) y varias GPU (F) **solo si el perfil del hito 4.1 dice que el hilo de GPU es el cuello**; si no, a
la 3.3 [V: buzón `20261109-1150`; la directiva, `DIRECTIVAS.md:308`, dice «adelante ya» y la puerta la concreta COORDINACIÓN-35]. Criterio concreto, para que la puerta no sea una opinión:

1. `CrGpuMain` por encima del 90 % de un núcleo durante Aquarium 15k en la 6,1, con `VizCompositorThread` y el renderer por
   debajo (si manda el renderer, el problema es otro).
2. `encodeMetalEncoder` más el módulo del driver de AMD **por encima del 25 %** de ese hilo (umbral de MOTOR, fila 5). Por
   debajo, mover la reproducción a otro hilo no paga su riesgo.
3. Los cambios 1–4 de A ya aplicados y medidos: lo que quede del hilo después de abaratarlo es lo que E puede repartir.

Si se cumplen los tres, E se prototipa en `avance/gpu-hilos` sobre el cambio 5 y se mide con Aquarium y la batería antes de
decidir si entra en la 3.1 o en la 3.3. F solo después de E y con dato de E.

### 4.4 Riesgos propios de la 3.1

- **Todas las ganancias son estimaciones de lectura.** Ninguna está medida; el perfil puede tirar la mitad de la tabla. Por
  eso el orden empieza por el perfil y por los cambios de riesgo nulo.
- **Sin donante.** Upstream no ha tocado esta ruta; cada parche es nuestro y se arrastra en cada subida de ANGLE. Van como
  commits `Flynk-Class: perf` en `b1d/angle/`, con prueba unitaria donde la haya (3 la tiene).
- **El A/B exige mismo commit, mismo día y red local.** Lo que pasó con PGO (§3) no debe repetirse: ninguna medida de la 3.1
  vale si las dos compilaciones difieren en algo más que el cambio.
- **La 5,1 tiene otra GPU** (RX 580) y no está medida en Speedometer ni JetStream; la 3.1 se acepta con la 5,1 «igual o
  mejor», no con cifra de ganancia (memoria `feedback-5-1-no-bloquea`).
- **Una sola máquina compila** y la 3.0.1 va primero. Los avances se compilan en hueco; un KEV los para.

### 4.5 Hitos de la 3.1

A 60 Hz, con la línea base de §3 hecha:

1. **Perfil publicado** (§4.1) y puerta de §4.3 decidida por escrito.
2. **7,1: cerrar el hueco con Chrome.** COORDINACIÓN lo cifra en 8–15 %. Con los datos de hoy (`oficial-9-pgo` 20,6 frente a
   21,0 en Speedometer, 3576 frente a 3861 en MotionMark, `coordinacion.md:262`, `comparativa-71.md:9`) el hueco es del 2 % y
   del 7 %; sin PGO era del 21 % y el 27 %. La cifra exacta del hito la fija el hito 0 con el mismo guion para los dos.
3. **6,1 y 5,1: subir sobre la línea base** en Aquarium 10k/15k y MotionMark (base de la 5,1: 864), e igual o mejor en
   Speedometer y JetStream. Sin parón de primera carga (B).
4. **Sin caídas** en la batería `pruebas-gpu.md` en las tres Mac, y **claude.ai aprobado por Titín**.
5. Maglev decidido (encendido o apagado con motivo).

### 4.6 Quién hace qué en la 3.1

- **LOCAL:** hito 0; el perfil de §4.1 en la 6,1 y la 7,1; A/B de cada avance con la 6,1 como banco; prueba de actualización
  real en la 3.1.0.
- **MOTOR:** cambios 3 y 4, después 1 y 2 según el perfil (A); B; prototipo de E solo tras la puerta. Antes, cierre de la
  3.0.1 (§2.1).
- **D8-LINUX:** mjsunit con y sin Maglev (D, condición 1) y para cada tanda que toque V8; `v8_embedder_string` en sus gn args.
- **SEGURIDAD-PORTES:** revisa los parches de ANGLE que tocan cerrojos (cambio 1) y el hilo trabajador (E) si llega.
- **INVESTIGACIÓN-MOTOR:** informe periódico de qué trae cada Chrome (157+), qué se puede portar a la 156 y qué interesa;
  propone, no implementa.
- **ARQUITECTURA:** revisa el perfil contra la tabla de §4.1 y escribe la decisión de la puerta para Titín.

## 5. La 3.2: sync con cuenta (F7.7)

### 5.1 Diseño, en paralelo con la 3.1

El flujo ya lo eligió Titín (06-11) y está en `TAREAS.md:280`: cuenta = email + contraseña + código por email; «He olvidado
la contraseña» en Sincronización; aviso en todos los navegadores si cambia; un navegador nuevo **no recibe la clave hasta que
lo apruebe uno ya sincronizado** (petición en espera sin caducar; sin móvil no es inmediata); la clave de recuperación del
usuario aprueba sin otro navegador; sin navegadores y sin clave, los datos se pierden aunque se recupere la cuenta, y la
página lo dice; cuentas sin uso borradas con aviso 30 días antes. Condiciones de COORDINACIÓN-30: la contraseña deriva la
clave en el cliente (Argon2 o scrypt; el servidor solo ve un verificador), el código por email es solo segundo factor, el
email es dato personal en ns2 (hash para iniciar sesión, email cifrado con clave del servidor, sin IP).

El diseño tiene que dejar escrito, en `FlyWeb/docs/sync-cuenta.md`:

1. **Derivación de claves** sin que el servidor vea la contraseña: KDF, parámetros, qué se guarda en ns2 (verificador) y cómo
   se rota si cambia la contraseña sin perder los datos cifrados.
2. **Aprobación entre aparatos:** protocolo por el que un navegador sincronizado pasa la clave cifrada al nuevo; cómo se
   identifica la petición; qué ve el servidor (nada descifrable).
3. **Recuperación:** contraseña nueva por email → cuenta recuperada, datos solo con aprobación o clave de recuperación; qué
   dice la interfaz en cada caso.
4. **RGPD y privacidad:** qué guarda ns2, cuánto tiempo, texto de privacidad, borrado de inactivas
   (`FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS`, hoy 365 y desactivado).
5. **Compatibilidad** con la sincronización actual (24 palabras) durante la transición, y qué pasa con los 7 usuarios de hoy.

6. **Lecciones del 09-11 (Titín, 6,1 con el llavero desajustado tras 3.0.0 → 2.7.0 → 3.0.0)**, requisitos de la página nueva:
   - **Dos botones, dos alcances, sin confusión:** «salir de la sincronización **en este Mac**» frente a «borrar la cuenta
     y los datos del servidor **en todos**». El segundo, con confirmación que diga cuántos navegadores se desconectan.
   - **Nada se queda «en curso» para siempre:** «Eliminación de la cuenta en curso…» se quedó colgado sin error ni
     tiempo límite; con la lista de dispositivos vacía y sin que «Ver el código» ni «Añadir dispositivo» hicieran nada. Toda
     operación de sync tiene tiempo límite, mensaje de error claro y botón de reintentar.
   - **Claves locales ilegibles = estado propio:** si el navegador no puede descifrar (llavero cambiado), lo detecta y
     ofrece «volver a unir este Mac» en vez de mostrar una página rota.
   - **Volver a unir sin duplicar:** al reincorporar un aparato, opción «sustituir lo local por lo de la cuenta» (o fusión
     sin duplicados por URL/GUID), además de «combinar».
   - Literales: «Passwords» sin traducir en la lista de tipos de datos (también en la 3.0.x).
   - Volver de la 3.0 a la 2.7 abriendo la 2.7.0 sobre el perfil migrado rompe el llavero: la 2.7.x no debe abrir un
     perfil con la marca «FlyWeb 3 Profile» (o la salida documentada es solo restaurar la copia «antes de 3.0»).

### 5.2 Hitos y riesgo

- **Hito 1:** diseño aprobado por Titín (es suyo: él decide). Antes de eso, ni una línea de código.
- **Hito 2:** servidor (SERVIDOR-LOCAL / SERVIDOR): cuentas, verificador, códigos por correo, cola de aprobaciones, borrado
  de inactivas con aviso; probado desde el propio servidor.
- **Hito 3:** cliente (MOTOR / LOCAL): página de Sincronización nueva, KDF, aprobación, recuperación; prueba con tres
  navegadores: cuenta nueva, aparato nuevo aprobado en diferido, recuperación con y sin clave.
- **Aceptación de la 3.2:** los tres Mac sincronizan con cuenta; los datos siguen ilegibles para nosotros (comprobado en
  ns2); texto de privacidad publicado; la 3.1 no ha retrocedido (mismo guion de §3).
- **Riesgo:** medio-alto. Criptografía propia y un dato personal en nuestro servidor; **revisión obligatoria de SEGURIDAD**
  del diseño antes del hito 1 y del código antes del 3. Y compite con la 3.1 por la 7,1 para compilar: el cliente se compila
  cuando la 3.1 esté medida, no antes.
- **Quién diseña:** ARQUITECTURA con NUBE (criptografía y servidor), con las condiciones de COORDINACIÓN-30 como requisitos.

## 6. Transversal

### 6.1 Sparkle 2.x

- Hoy: binario precompilado del fork `brave/Sparkle` fijado en enero de 2023; Brave 1.98 sigue en 1.24.4 [V: `DEPS:14`,
  `relevo-motor.md:318-325`]. Las Release van firmadas con Developer ID y notarizadas [V: `docs/estado.md:16-17`]; **si el
  certificado cambia, todas las Mac se reinstalan a mano** [V: `servidor/actualizaciones/README.md:60`] y nadie vigila su
  caducidad. En la 3.0.0 el registro de Sparkle se perdió sin error de compilación [V: `relevo-motor.md:78-79`]: la prueba de
  actualización real es obligatoria en cada 3.N.0, en las tres Mac, con la FlyWeb de Titín cerrada.
- Sparkle 2.x: instalador en proceso aparte, XPC opcional, DSA eliminado (ya firmamos EdDSA), mínimo macOS 10.13 desde la 2.6
  **[N: a confirmar por SEGURIDAD-PORTES]**: Mojave entraría. Coste medio: reescribir `browser/mac/sparkle_glue.mm` y el
  empaquetado de `build/mac/BUILD.gn` sin donante. Riesgo medio: una actualización rota deja a los usuarios en la anterior; se
  prueba con canal aparte. **Propuesta:** valoración (mínimo real, XPC) durante la 3.1; migración en la 3.3 o en la primera 3.N
  que no lleve otro cambio del empaquetado.

### 6.2 CFBundleVersion 198.63.N, independiente de Brave

- `tweak_info_plist.py` compone `CFBundleVersion = (major·100+minor).build.N` a partir de la versión de Brave en
  `package.json` (1.98.63 → 198.63) y de `FLYWEB_BUILD_NUMBER` [V: `tweak_info_plist.py:46-61`]; la 3.0.0 lleva el 41, la
  3.0.1 el 42. Sparkle compara componente a componente y **nunca baja**; bak rechaza un número igual o menor, pero después de
  compilar y notarizar [V: `firmar-actualizacion.mjs:118`].
- **Riesgo:** si `package.json` desaparece o su `major` deja de ser ≥ 1 (cuando brave-core salga), el script cae en la rama
  de Chromium y queda un CFBundleVersion menor que 198.63: ninguna Mac volvería a actualizarse. `build.sh` no comprueba nada
  [V: `build.sh:272`].
- **Cierre, en la 3.0.1:** argumento de GN propio `flyweb_bundle_version_base = "198.63"`, congelado para siempre; `build.sh`
  lee `web/VERSION` y para si `FLYWEB_BUILD_NUMBER` no es mayor que el último publicado; regla escrita en
  `servidor/actualizaciones/README.md`. Cambio de build, sin riesgo de producto, **antes** de tocar brave-core.

### 6.3 Cuándo hace falta otra base

La referencia es la 128: medida tarde y de golpe, **15 %** de arreglos críticos limpios a 18–22 hitos de distancia, 750 CVE
altos o críticos acumulados, bloques de Blink aplazados creciendo por nivel [V: `b0-cve.md:91-101`, `cve-128-no-explotados.md:11`,
`base-siguiente.md:95-104`]. La 156 arranca con 67 % en el grupo 2 a 0–1 hito. La proporción **cae con la distancia**, así
que el umbral se lee con los meses desde la base, y la curva real la da la medida mensual de §2.3.

| Señal | Estudio (ARQUITECTURA prepara datos) | Propuesta de salto a Titín |
|---|---|---|
| S1 · % limpio del **grupo 2** (A, sin fuzz) | < 50 % dos meses seguidos | < 35 % dos meses seguidos (la 128 estaba en 15 %) |
| S2 · Críticos alcanzables **no portables** acumulados | ≥ 5 | ≥ 10, o 1 explotado (KEV) sin arreglo posible |
| P1 · Google retira de Mac algo de lo que dependemos (como GL en la 156, `base-siguiente.md:50`) | en cuanto se vea en `main` | cuando llegue a estable |
| P2 · Chromium sube el mínimo a macOS 14 (hacia mediados de 2027 [I], `base-siguiente.md:129-132`) | al anunciarse | según el tamaño de la capa Mojave que haría falta (la 156: 741 avisos, 48 ficheros, 13 rondas, `TAREAS.md:317`) |
| P3 · El SDK que exige la base deja de correr en nuestras Mac (Xcode 27+ es solo ARM; `mac_sdk.gni` de `main` se mira cada mes) | en cuanto `main` exija SDK 27 en Intel | antes de que esa exigencia llegue a la base que se quiera tomar |

Antes de proponer un salto, **el ensayo de rebase (B3/F5) es obligatorio**: nunca se ejecutó [V: `fork-propio.md` §6,
`base-siguiente.md:206`]. Su resultado (conflictos por `Flynk-Class` y por directorio) es la cifra real del coste.

**El techo de Xcode 27, decisión aparte y sin prisa (Titín).** Xcode 27 y posteriores son solo ARM; los anfitriones Intel
compilan `main` (159) con un Xcode 26 universal y SDK 26.5 [V: `base-siguiente.md:40-44`]. `macos11-niveles.md:19` sitúa el
SDK 27 en la 158, lo que no cuadra con el 26.5 de `main`: la fecha **no está clara** y se vigila, no se da por hecha. Cuando
llegue, sin una máquina ARM no habrá base nueva: un Mac con Apple Silicon solo para compilar (el producto sigue siendo Intel),
o compilación cruzada desde Linux, que Chromium no mantiene para Mac [N]. Mientras tanto la 156 es una rama de soporte largo
de hecho, y este plan está pensado para que aguante. ARQUITECTURA avisa cuando `mac_sdk.gni` cambie; la decisión queda para
entonces.

### 6.4 Lo pendiente de la 3.0.x en la fila de MOTOR

| Pendiente | Qué es | Dónde va | Dueño |
|---|---|---|---|
| `nube/b2-tests` (148a5939c8) | Enlace de `brave_unit_tests`/`brave_browser_tests` en la 156 **y** la guarda de `sparkle_glue.mm`, código de producción **no probado en Release** [V: `relevo-motor.md:16`] | 3.0.1, con prueba de actualización real | MOTOR; prueba LOCAL |
| `nube/b2-depfile` (bbfb565048) | `preprocess_if_expr.py` sin depfile con `--in-files` vacío | 3.0.1 | MOTOR |
| Marca (`nube/b2-icono-restaurar` d3fae32d5b) | Barra de restaurar, logo, SVG de Sync y bienvenida, pedales | 3.0.1 | MOTOR-42; prueba LOCAL |
| `nube/b2-redirect-cc` (58be92043) | Fuera `redirect_cc`/siso; envoltorios al esquema de 1.98. Cada `#define` puede dejar de aplicar **sin error** [V: `brave-propio.md:559`] | 3.0.1 o 3.0.2, con `check-overrides-156.sh` en verde y revisión de SEGURIDAD | MOTOR, SEGURIDAD-PORTES |
| Panel de Shields | Existe en t11; faltan cambios de 1.98 y **no está escrito qué le falta** [V: `relevo-motor.md:185`] | 3.0.2, tras una ficha que diga qué falta | MOTOR; diseño, Titín |
| `UpdateTargetURL`, restos de IPFS/Tor, `chrome_logo_dark.svg` | Menores | 3.0.2 | MOTOR |
| WebGPU | Apagado por CVE-2026-5281; Dawn sobre Metal 2.1 en 10.14 sin comprobar [V: `brave-propio.md:830-831`] | **No es pendiente de la 3.0.x**: trabajo de base. Sigue apagado | Titín, si algún día se abre |
| Containers | Perfiles-contenedor de Brave; nada en t11 | **Decisión de producto**; propongo **no** | Titín |

Cada uno debería tener ficha propia en `TAREAS.md` con la versión en la que entra.

### 6.5 Otros riesgos

- **Una sola máquina compila la 156.** Si la 7,1 falla no hay versión de seguridad hasta repararla; la 6,1 no puede ayudar.
  Junto al techo de Xcode 27, es el riesgo estructural.
- **El coste del salto 128 → 156 no está medido** (sin horas ni reloj). Para el próximo, ensayo de rebase y reloj de LOCAL
  desde el primer día.
- **`DIRECTIVAS.md:9` conserva «la 128 es la última base que tomamos de fuera»** pese a la puerta del 04-11; retirarla.

## 7. Lista corta de decisiones para Titín

Lo ya decidido (orden de las 3.N, 3.0.1 primero en la 7,1, seguridad continua, INVESTIGACIÓN-MOTOR vigila) no se vuelve a
preguntar. Queda:

1. **Criterio numérico de la 3.1 en la 7,1 (§4.5):** aceptar que la cifra del hueco con Chrome se fije con el hito 0 (mismo
   guion para los dos) en vez del 8–15 % a priori.
2. **Umbrales de la puerta (§4.3):** 90 % del hilo y 25 % de driver, o sus cifras.
3. **Umbrales de base nueva (§6.3):** S1 50/35 %, S2 5/10 críticos, o sus cifras.
4. **claude.ai:** la prueba manual sigue siendo la definitiva; el umbral de las dos medidas lo pone Titín cuando exista la
   línea base.
5. **`flyweb_bundle_version_base = "198.63"` en la 3.0.1** antes de tocar brave-core (propuesta: sí).
6. **Sparkle 2:** valorar durante la 3.1 y migrar en la 3.3 (propuesta), u otra versión.
7. **Containers: no. WebGPU: apagado y fuera de la 3.x** (propuestas).
8. **Vigilancia diaria de KEV** entre tandas (§2.4): rutina barata sí o no.

## 8. Fuentes y límites

- Directivas y reparto: `docs/DIRECTIVAS.md` (05-11, 07-11 y 09-11), `docs/TAREAS.md` (FS.42, F7.7, FM.55, FM.56, filas de
  agentes), `coordinacion.md` (09-11), buzón `20261109-1150-COORDINACION-35-plan3x-titin.md`.
- Rendimiento: `rendimiento-3.1.md` (MOTOR, 09-11), `pruebas-gpu.md`, `b1d/README.md`, `b1d/pgo-mojave.md`,
  `comparativa-71.md`, `relevo-local.md`, `metal-mojave.md`, `vision-motor.md`, `investigacion-pendiente.md`.
- Seguridad: `seguridad-3.0.1.md` (hasta §7, 08-11), `b0-cve.md`, `cve-128-no-explotados.md`, `seguridad-128.md`,
  `docs/SEGURIDAD.md`, `docs/RELEVO-SEGURIDAD.md`.
- Riesgos: brave-core `DEPS`, `build/mac/tweak_info_plist.py`, `browser/mac/sparkle_glue.mm`; `FlyWeb/scripts/build.sh`;
  `FlyWeb/servidor/actualizaciones/README.md`; `relevo-motor.md`; `brave-propio.md`.
- Base: `base-siguiente.md`, `fork-propio.md`, `macos11-niveles.md`.
- Límites: nada compilado ni medido en esta sesión; las ganancias de §4 son estimaciones de lectura de MOTOR, no medidas;
  Sparkle 2 y la cifra del blog de V8 sobre Maglev están sin comprobar [N]; los umbrales de §4.3 y §6.3 son propuestas.
