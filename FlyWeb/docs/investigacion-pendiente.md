# Pendiente tras la 2.0.0: inventario y prioridades

INVESTIGACIÓN-MOTOR-3, 26-10-2026, encargo de Titín vía COORDINACIÓN-13. Solo papel: nada medido ni compilado.
Marcas: **[V]** verificado en el repo o en fuente citada; **[I]** inferencia mía; **[N]** no comprobado. Las horas son de
papel y, según `docs/DIRECTIVAS.md` («Medir antes de decidir»), salen pesimistas; las que no figuran en ningún documento
van como «n/d» y no las invento. Valor: lo que nota el usuario de FlyWeb (Macs obsoletos con Mojave), no lo que sería elegante.

## 1. Prioridades propuestas (las 5)

| # | Asunto | Por qué en este orden |
|---|---|---|
| 1 | **Línea base medida en Release** (Speedometer 3, JetStream 2, MotionMark 1.3, memoria, CPU de vídeo) en 5,1, 6,1, 7,1, Air 2013 y A1398 — **la de la 7,1 antes de cambiar la gráfica** | Todo lo demás se decide con estas cifras; hoy solo hay MotionMark en la 6,1 y un Speedometer 3 de desarrollo (3,99, sin máquina anotada). La de la 7,1 con la Radeon Pro 580X tiene fecha de caducidad |
| 2 | **Niveles 132+** con la regla 19 (Maglev, `turboshaft_wasm`) | Es la idea rectora (DIRECTIVAS) y la única que reduce la brecha de seguridad y de compatibilidad web que crece cada mes; Maglev/Turboshaft son el mayor salto de JS que queda sobre la mesa |
| 3 | **Ahorro de memoria adaptativo a la RAM** (descarte de pestañas) | Solo configuración; el beneficio está en los Macs de 4–8 GB, que son el público de FlyWeb |
| 4 | **Experimento `x86_64h`** (una sola compilación con `-march=haswell`, sin binario doble) | Barato de probar; solo se justifica el binario doble si gana ≥ 5 % (umbral mío, discutible) |
| 5 | **GPU: matriz Metal/OpenGL por máquina y F5.6 (códec por capacidad)**, incluida la prueba de la W6600X | Aporta en Monterey+; en Mojave no cambia nada |

Lo que **no** pondría entre las 5: FM.37 y la clase E (pocas ganancias de privacidad frente a su coste de fusión), el widget
de la NTP (ya hay buscador DuckDuckGo), WebGPU (bloqueado por CVE hasta ~140), EyeDropper/takePhoto (API marginal).

## 2. Inventario de lo parado

| Asunto | Qué es / de dónde sale | Valor real | Coste (papel) | Cómo se mide antes de decidir | Riesgo | Prioridad |
|---|---|---|---|---|---|---|
| **FM.37** privacidad de Brave > 1.69 | Estudio de cambios de privacidad/antihuella de Brave 1.70+ que no tengamos; fila FM.37, DIRECTIVAS «Brave no se sigue por número» (22-10). Fuera Leo, Rewards, Wallet, VPN, News, Talk | Medio-bajo: es lo que justifica elegir Brave, pero hasta la 1.69 casi todo estaba resuelto por nosotros | n/d; es un estudio en papel | Lista de cambios con `network-audit.py` sobre la 2.0.0 frente a la Brave 1.70+ | Bajo (solo papel); el coste real viene al portar | Media-baja; después de 2 |
| **Clase E** (servicios nuevos 1.58–1.69) | `brave-servicios-nuevos.md`; FM.35 | Bajo: «solo se incorpora lo que aporta funcionalidad real» (Titín, 22-10) | FM.32 estimaba 10–30 h; bajó a ≈6–14 h (`brave-servicios-nuevos.md`). Sin dependencias de macOS > 10.14 (`brave-169-macos.md`) | `network-audit.py`: ningún destino de Brave | Fugas de red si se activa algo sin auditar | Baja; solo lo que pida Titín |
| **F5.6** códec por capacidad | Fila F5.6 (Titín, 22-10, opción B): VP9/AV1 solo donde VideoToolbox decodifique por hardware. 2.0.0 sale con códec fijo | Real solo en Monterey+: >1080p en YouTube. En Mojave/Catalina, nada. Diferencia de CPU a 1080p: 12 % (1.15.2) frente a 15 % (Release -p15) de un núcleo [V: FM.39]; **3 puntos de un núcleo no justifican nada por sí solos** | n/d | A1398 con las dos GPU; `media-internals` (`kVideoDecoderName`), `MediaCapabilities.decodingInfo().powerEfficient`, CPU en 1080p/4K con H.264, HEVC, VP9, AV1 | Medio: VP9 por VideoToolbox colgó ffmpeg/IINA en Intel Macs [V: ffmpeg trac #9599]; hay que poder volver al software | Alta dentro de 5 |
| **Widget de búsqueda de la NTP** | `kBraveNtpSearchWidget`; apagado en 2.0.0; `identidad-128.md` (decisión d), DIRECTIVAS | Bajo: el buscador por defecto ya es DuckDuckGo (F7.2). Cambiar solo el icono escondería una fuga a Brave Search | n/d | `network-audit.py` al teclear en la caja: si toca `*.brave.com`, apagado | Fuga de privacidad | **Recomiendo dejarlo fuera** salvo que Titín quiera la caja; entonces, con el buscador por defecto, sin Brave Search |
| **Tabla de la regla 19** | `docs/RELEVO-SEGURIDAD.md` §2 | Alto para `maglev` y `turboshaft_wasm` (velocidad de JS/Wasm); el resto, hecho o a la espera de upstream | Se decide en el nivel 132 | Speedometer 3/JetStream 2 con y sin la opción, en las 5 máquinas, y comprobar que el arranque en la 5,1 sigue bien | `maglev_untagged_phis` apagado por CVE-2026-3910; `IsolateSandboxedIframes` +2 procesos y +27–39 MB (LOCAL-4) | **Alta (2)** |
| **WebGPU apagado** | CVE-2026-5281 (y CVE-2026-3909) «in the wild»; `nube/webgpu-off`; F5.5 (probar el Dawn de la 116 sobre Metal de Mojave, sin compilar) | Casi nulo hoy: pocas webs lo exigen; claude.ai no | n/d | `--enable-features=WebGPUService --enable-unsafe-webgpu` en 6,1 y 5,1 (F5.5) | Alto: es superficie de ataque nueva | Baja; revisar al llegar a ~140 |
| **EyeDropper y takePhoto en 10.14** | Pérdida aceptada en la 2.0.0 (`coordinacion.md`: la 128 quitó la alternativa de la 116). `NSColorSampler` exige 10.15 | Bajo: APIs marginales; solo afecta a Mojave | Cuentagotas: +16/−107 líneas, 2–6 h (`base-128.md`, fila 10); takePhoto: n/d [N] | Contar cuántas webs de la lista de compatibilidad las usan | Bajo | Baja |
| **`eglQueryDeviceAttribEXT: Bad attribute`** | Resuelto en `-p15` (0 líneas frente a 44 966 en 16 min con `-p14`, en la 6,1) [V: FM.39] | Hecho | — | **Pendiente repetir en el A1398 con la AMD**, donde se llenaba el registro | Bajo | Cerrar con una prueba |
| **FM.39 / `build.sh` sin adaptar a la 2.x** | 6 claves inertes nuevas (`service_key_aichat`, `brave_services_key_id`, `zebpay_*`) solo en el guion local; falta dependencia en `BUILD.gn` con `enable_ai_chat=false` (`-p16` en curso con MOTOR-18) | Interno, pero sin esto la Release no es reproducible desde el repo | Horas | Compilar `build.sh` limpio en un checkout vacío | Medio: una Release que solo sale con un guion local | **Alta antes de 2.0.1**; no es investigación |
| **Niveles 132+** | `migracion-128.md`, DIRECTIVAS (no empiezan hasta publicar la 2.0.0) | Alto (seguridad, compatibilidad web, Maglev) | Migración de la 128: ~330–710 h de papel (`base-128.md`) frente a un nivel suelto: n/d | Un nivel piloto (132) con la medida del punto 1 | Medio-alto: coste fuera de Blink/V8 (red, GPU, sandbox) | **Alta (2)** |

Otros aplazados del tablero (solo listados; no los he leído a fondo): F5.3 (artefacto de capas en la 6,1), F6.3 (portar 117–150),
F4.4 (medición frente a Baseline), F4.7 (login de Microsoft), F7.6 (varios perfiles), F7.7, FM.23 (regla 19: acabará entrando),
FM.30 (criba), SV.4 (copia cifrada de las claves de bak), B.2/B.3.

## 3. Optimizaciones nuevas

### 3.1 Binario doble `x86_64` + `x86_64h`

**Hechos.** [V] `FlyWeb/scripts/build.sh` compila solo `x64`; `check-no-avx.sh` falla si aparece `native` o si más del 5 % de
los comandos llevan flags AVX, porque Chromium contiene siempre rutinas AVX/AVX2 elegidas en ejecución. [V] `base-128.md`:
la base sigue en `-msse3` y TFLite/XNNPACK, libyuv, WebRTC, Dawn y Skia despachan en ejecución. [V] `vision-motor.md` V19 ya
dijo «No tocar» el juego de instrucciones, con el argumento de High Sierra/Penryn. Sobre el formato:
- `x86_64h` es una subarquitectura Mach-O distinta («Haswell»); el cargador toma la copia `x86_64h` en una CPU que la
  soporta y la `x86_64` en las demás; un binario solo `x86_64h` no carga en otras [V: documentación de rustc, `x86_64h-apple-darwin`; revisión LLVM D14772, que confirma que se puede mezclar con `x86_64`]. 
- Skia elige AVX2/otros por CPUID en ejecución (`SkOpts::Init`) y skcms añade una rutina AVX2 en ejecución con ~25–30 KB [V: Chromium Code Reviews/skia.googlesource.com].
- BoringSSL tiene sus palabras de capacidad (`OPENSSL_ia32cap_P`) y libvpx detección en ejecución activada por defecto [V, parcial]; dav1d: x86 no comprobado [N].
- Como la V8 genera su código en ejecución (JIT), el flag del compilador no cambia el código JIT; lo que mejoraría es el propio C++ de V8, Blink, la red y el compositor [I].

**Quién cargaría qué.** Haswell o posterior: Air 2013 (HD 5000, AVX2), A1398, 7,1 → copia AVX2. 5,1 (Westmere, sin AVX) y 6,1 (Ivy Bridge, AVX sin AVX2) → la normal. Esto es lo pedido; ninguna copia normal exigirá AVX.

**Mi lectura crítica.**
1. Las rutinas que más importan (píxeles, códecs, criptografía) **ya** usan AVX2 donde existe. Lo que ganaría el compilador con `-march=haswell` en el resto es autovectorización y BMI/FMA: en código de navegador, lleno de ramas y punteros, suele ser pequeño [I; no he encontrado una medida publicada en Chromium para macOS → **[N]**].
2. Coste cierto: **dos compilaciones completas** (el árbol ya es de 100–150 GB y se compila una a la vez), DMG y actualizaciones Sparkle más grandes, el doble de firmas por componente, y el doble de superficie de fallos que solo salen en una de las dos copias. GN no tiene soporte `x86_64h` directo para macOS [N]; habría que fabricar la copia con `lipo` de dos árboles.
3. Y la copia `x86_64h` **no se ejecutaría en la máquina de pruebas del peor caso**, así que lo que se publica ya no es lo que se prueba en la 5,1: contradice la lógica de la prueba de arranque.
4. **Subir el mínimo a SSE4.2/POPCNT**: la objeción de V19 (Penryn, High Sierra) ya no se aplica, porque la 2.0.0 exige Mojave y los Macs que Apple soporta en Mojave son Nehalem o posterior [I: de memoria de la lista de Apple, **[N]** hasta comprobar]. Pero ganaría poco por la misma razón del punto 1 y el único riesgo es perder Macs parcheados fuera de soporte. Si el experimento no justifica el binario doble, esta es la alternativa barata.

**Experimento propuesto (papel; 4–8 h de medición según V14/V19).**
- Compilar la Release de la 7,1 dos veces: `-msse3` como hoy, y `-march=haswell` en `x86_64h` (una sola copia, no binario doble).
- Medir en la 7,1 y en el Air 2013, 5 pasadas cada una, con **Speedometer 3, JetStream 2 y MotionMark 1.3** (herramienta ya preparada: `temp/local5/medir-51.sh`/`bench.py` [V: `relevo-local.md`]), además de tamaño del binario y arranque.
- Umbral: < 3 % de ganancia en JetStream y Speedometer → descartar; ≥ 5 % → plantear el binario doble; entre 3 y 5 %, no compensa el doble de pruebas. Los umbrales son míos.
- Antes de compilar nada: confirmar `chrome_pgo_phase` (V19). Si la Release no usa PGO, el PGO probablemente da más que el juego de instrucciones [I].

### 3.2 Ahorro de memoria (descarte de pestañas)

- [V] En FlyWeb **no hay nada hecho**: ni política ni configuración (`build.sh`, `flyweb-policies.mobileconfig`). `vision-motor.md` tiene V4 (activarlo, 4–8 h, solo configuración, sin quitar el aislamiento de sitios) y V18 (el contrario, para 48–96 GB), ambos «sin medir».
- [V] Chrome lo llama Memory Saver: descarta pestañas inactivas en segundo plano, conserva título y favicon y recarga al volver; el usuario puede excluir sitios; no se lanzan `beforeunload`/`pagehide`/`unload` en el descarte (developer.chrome.com, «Memory and Energy Saver modes»). Las fuentes discrepan en si llegó en la 108 o la 110 → no cito versión.
- **Crítica:** activarlo «por defecto» para todos es mala idea. En una 7,1 de 96 GB solo provoca recargas; el beneficio está en los Macs de 4–8 GB (Air 2013, mini). Propongo **decidir por RAM** (V4/V18 ya lo apuntan: «la elección puede ser automática por RAM») y excluir por defecto claude.ai y las pestañas con audio/formularios (Chrome ya protege las últimas [N]).
- Medida: memoria total (`memory-infra` o Monitor de Actividad) con 20 pestañas reales en el Air 2013 y el A1398, con y sin; contar recargas y tiempo de vuelta a la pestaña. La política de Brave sobre esto no la he encontrado [N].

### 3.3 Ruta de GPU por máquina

Hoy [V: TAREAS FM.39/MOTOR-17, `multimedia.md`, `base-128.md`]: la 116 usaba ANGLE sobre OpenGL 4.1 por defecto (Metal solo con `--use-angle=metal`); la 128 deja `DefaultANGLEMetal` como upstream y la propuesta aplicada en `-p11` es **Metal en ≥ 10.15, OpenGL en 10.14** (no he verificado el código). En el A1398 (Monterey; Radeon R9 M370X + Iris Pro) `--use-angle=metal` no arranca el proceso GPU y cae a SwiftShader (hipótesis: GCN1/Haswell no soportado por ANGLE-Metal) → «No forzar Metal». En la 7,1 Metal funciona.

Falta:
1. Una **matriz medida** (MotionMark 1.3 + desplazamiento real, no el shader de 1024²) Metal frente a OpenGL por GPU: 580X, D500, RX 580, HD 4000/5000, GT 650M, M370X (V16: «si Metal gana ≥ 20 %, fijarlo»; es el criterio ya escrito en `multimedia.md` §2). Esa matriz es la de F5.2, hoy condicionada a las mediciones.
2. Una **lista de rechazo por GPU** que lleve a OpenGL o a software sin colgar (hoy el A1398 solo se cubre por una caída a SwiftShader, que es lenta).
3. Dawn/Skia sobre Metal en Mojave («GPU y Metal sin cubrir», `migracion-128.md`).
4. Upstream va hacia Metal (Skia Graphite exige ANGLE-Metal [V: commit citado en V16]): el camino OpenGL queda sin mantenimiento; conviene saber qué GPU de Mojave se queda sin camino bueno antes del 132+.

## 4. MacPro7,1 con Radeon Pro W6600X

**Punto de partida** [V: `multimedia.md`, 03/10]: 7,1 con **Radeon Pro 580X** y Sequoia; Metal y OpenGL dan 42,4 y 43,0 FPS en el shader de WebGL (no distingue motores); vídeo: H.264 y HEVC por hardware, VP9 y AV1 por software.

**Qué es la W6600X.** [V: Apple y AMD] Módulo MPX de AMD basado en **RDNA2**, 8 GB GDDR6 a 256 GB/s, compatible con el Mac Pro (2019), exige **macOS 12.3 o superior** (Apple lo da como mínimo, no como garantía de Sequoia) y hasta 4 pantallas 4K o 2 de 5K. Silicio Navi 23 [I] (el mismo de la RX 6600 XT que cita la fila F5.6).

**Qué implica para FlyWeb.**
1. **ANGLE Metal.** Debería funcionar y ganar: es la GPU más moderna que se probaría; el fallo del A1398 apunta a GCN1/Haswell, no a RDNA [I; **[N]** hasta medirlo]. Cuidado con asumir lo contrario: no se ha probado nada de RDNA2 con FlyWeb. Soporte Metal 3 de la serie 6000: lo recuerdo de las tablas de Apple, sin fuente citable aquí → **[N]**.
2. **Vídeo por hardware.** VCN 3.0: H.264, HEVC y VP9 de decodificación, y AV1 en la decodificación según Wikipedia («Video Core Next») [V]; la tabla de AMD (AMF) marca a Navi 24 como «solo decodificación» y no a Navi 23, pero no lista AV1 por tarjeta [V: AMF wiki]. **Lo que importa es lo que macOS expone vía VideoToolbox**, no el silicio: AV1 por hardware en macOS Intel/AMD, y VP9 por hardware, **no los he podido comprobar [N]**; VP9 en Intel Macs dio cuelgues conocidos [V: ffmpeg trac #9599]. Es justamente el caso de uso de F5.6, así que **la W6600X es la mejor máquina disponible para validarlo**, mejor que el A1398 con la R9 M370X.
3. **Mojave no aplica**: la W6600X exige 12.3 y la 7,1 va con Sequoia. Nada de lo medido en esa máquina sirve como «peor caso».
4. **Registro y estabilidad:** repetir el control del `eglQueryDeviceAttribEXT` y de las caídas del proceso GPU de `cuelgue-gpu-128.md` (hoy la 128 se cuelga en la 6,1 con los parches de Dawn; la causa no la he leído).

**Qué medir (antes y después; la 580X no se podrá repetir una vez cambiada).**
- `chrome://gpu` (driver, ANGLE, vídeo decodificado por hardware) y proceso GPU estable 30 min.
- MotionMark 1.3 y Speedometer 3 con Metal y con OpenGL (`--use-angle=gl`) y sin forzar nada.
- `media-internals`: `kVideoDecoderName` y CPU (`ps`/Monitor) en H.264, HEVC, VP9 y AV1 a 1080p y 4K, con `FlyWebSoftwareVp9Av1` activado y desactivado; `MediaCapabilities` con `powerEfficient`.
- Registro de la GPU: errores EGL por minuto durante 10 min de MotionMark.
- Consumo en reposo y con vídeo, por si el cambio sube el ruido o el calor [I; sin método fijado].

## 5. Fuentes

- Repo: `docs/DIRECTIVAS.md`, `docs/TAREAS.md` (FM.37, FM.39, F5.5, F5.6, OR.1), `FlyWeb/docs/base-128.md`, `vision-motor.md` (V4, V14, V16, V18, V19), `multimedia.md`, `brave-servicios-nuevos.md`, `brave-169-macos.md`, `identidad-128.md`, `cuelgue-gpu-128.md`, `coordinacion.md`, `docs/RELEVO-SEGURIDAD.md`, `FlyWeb/scripts/check-no-avx.sh`.
- [Rust: x86_64h-apple-darwin](https://doc.rust-lang.org/rustc/platform-support/x86_64h-apple-darwin.html); [LLVM D14772](https://reviews.llvm.org/D14772).
- [Skia `SkOpts.cpp`](https://skia.googlesource.com/skia/+/b1b019985bee2bcbf35c2fbb4281904d0d3465bb/src/core/SkOpts.cpp); [skcms](https://skia.googlesource.com/skcms/+/f7d520f5e6f54ee3c256911e8b20619b286a3f63).
- [BoringSSL: detección de capacidades](https://boringssl.googlesource.com/boringssl/+/2d94b5e1ee99a22c2fd3bb3b3dd5b4e3be6b3cc6).
- [Chrome: Memory and Energy Saver](https://developer.chrome.com/blog/memory-and-energy-saver-mode).
- [Apple: Radeon Pro W6600X MPX Module](https://www.apple.com/sg/shop/product/MKGY3ZA/A/radeon-pro-w6600x-mpx-module); [AMD, nota de prensa](https://ir.amd.com/news-events/press-releases/detail/1052/amd-radeon-pro-w6600x-gpu-for-mac-pro-unleashes-new-creative-possibilities-for-design-and-content-creation-professionals).
- [Wikipedia: Video Core Next](https://en.wikipedia.org/wiki/Video_Core_Next); [AMF: soporte por GPU](https://github.com/GPUOpen-LibrariesAndSDKs/AMF/wiki/GPU-and-APU-HW-Features-and-Support).
- [FFmpeg trac #9599 (VP9 en VideoToolbox)](https://trac.ffmpeg.org/ticket/9599).
- Límite: este entorno no pudo abrir páginas (solo búsquedas); lo de las páginas de Apple y AMD viene de los resúmenes del buscador.
