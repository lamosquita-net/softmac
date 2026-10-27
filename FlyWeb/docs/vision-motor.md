# FlyWeb — visión del motor (documento vivo de INVESTIGACIÓN-MOTOR)

Segunda versión: 20-10-2026 (la primera, del 19-10, no llegó a `main`). Solo papel (fila FM.26): ni código ni ramas de
brave-core. **Propone; deciden ARQUITECTURA o el HUMANO.** Cada entrada lleva fecha; no se borran las descartadas (el
motivo evita volver a estudiarlas).

**Encargo (COORDINACIÓN-7, 20-10, con la voz de Titín):** WebKit primero (macOS y un posible iOS), después Gecko; para
cada idea, qué resuelve de lo que nos cuesta en Blink, lo que gana, lo que cuesta y cuánto nos aleja de upstream.
**Objetivo de Titín:** que FlyWeb rinda mejor en la **5,1 y la 6,1** (Intel, Mojave, GPU AMD), sin olvidar la 7,1, y
aprovechar el hardware existente al 100 %. PPC/Leopard y Linux, solo como contexto de muy largo plazo.

**Cómo leer las fichas.** *Gana* / *Cuesta* (horas como orden de magnitud, estimación mía) / *Distancia* = cuánto nos
aleja de los parches de upstream:

| Dist. | Significa |
|---|---|
| 0 | Configuración, flags o política: no toca ficheros de Chromium |
| 1 | Ficheros nuevos o `chromium_src/` aislados; los parches de upstream aplican igual |
| 2 | Parches pequeños en ficheros de Chromium (≈ <10 ficheros, cada nivel se rehace en horas) |
| 3 | Parches en zonas calientes: conflicto en cada nivel |
| 4 | Divergencia estructural: un fork duro, los parches de upstream dejan de aplicar |

Evidencia: **[V]** visto en el código, en un documento del proyecto o en una fuente citada; **[I]** inferido;
**[H]** hipótesis. **Nota:** varias fuentes de §7 las he visto solo como resultado de búsqueda (la sesión de nube no abre
todas las páginas); van marcadas «(resultado)».

## 1. Punto de partida: el hardware y lo que ya medimos

| Máquina | SO | RAM | GPU | Notas |
|---|---|---|---|---|
| MacPro5,1 | Mojave | 48 GB | RX 580 | **Sin AVX** (regla fija); sin mediciones todavía |
| MacPro6,1 | Mojave | 64 GB | 2 × FirePro D500 (macOS usa una) | H.264 por hardware; VP9 y AV1 por software; sin HEVC |
| MacPro7,1 | Sequoia | 96 GB | Radeon Pro 580X | 16 núcleos / 32 hilos; HEVC por hardware |

Fuente: `CLAUDE.md` y `multimedia.md` §3 [V]. **Lo medido (multimedia.md):** ANGLE elige **OpenGL 4.1 por defecto**
en la 116, tanto en Mojave como en Sequoia; Metal funciona con `--use-angle=metal` en la D500 (el *renderer* sale como
«ANGLE Metal Renderer: AMD Radeon HD - FirePro D500»); la prueba de WebGL **satura la pantalla a 60 Hz** y no
distingue motores. **Lo que no sabemos:** la 5,1 está en blanco; no hay Speedometer ni MotionMark; y las pruebas diarias
van con la compilación *Static*, que **no lleva ThinLTO** (`build.sh`, líneas 4–6), así que no representa lo publicado.

## 2. Qué nos cuesta hoy en Blink (de los documentos del proyecto)

| Id | Dolor | Dónde consta |
|---|---|---|
| D1 | **Cada función hay que portarla** de un Blink que cambia cada 4 semanas, sin capa estable | `motor.md` (216 commits solo en los niveles 129–131) |
| D2 | **El suelo de macOS sube** cada pocos hitos y arrastra la base (116 → 10.14; 128 → 10.15; 129 → 11) | `base-128.md` |
| D3 | **Superficie C++ sin portar:** net, media, GPU, Skia, códecs siguen en la 116 | `cve-triage.md`, `base-128.md` §6 |
| D4 | **Hardware viejo:** 5,1 sin AVX, GPU de Mojave con apaños que Chromium borró, G5 con 12 GB | `hoja-de-ruta.md`, `base-128.md` |
| D5 | **Huella y privacidad:** hay que declarar Chromium y aun así exponer menos que Brave | `motor.md` principio 4, regla 20 |
| D6 | **Compilar:** 100–150 GB y horas por compilación | `CLAUDE.md` |
| D7 | **Otras plataformas** (iOS, Linux, Leopard PPC) sin un motor que las cubra | encargo de INVESTIGACIÓN-MOTOR |
| D8 | **Rendimiento en la 5,1 y la 6,1:** JS sin JIT por defecto, OpenGL en lugar de Metal, VP9/AV1 por software, sin cifras | §1, `cve-triage.md`, `multimedia.md` |

## 3. Cómo lo resuelven WebKit y Gecko

| Dolor | WebKit (prioridad) | Gecko | Lectura crítica |
|---|---|---|---|
| D1 portar | Los *ports* (Mac, GTK, WPE, Win…) comparten `WebCore` y separan lo de plataforma en `platform/`; API estable para quien incrusta (WKWebView) | Gecko se embebe peor (GeckoView, Android); sin API estable en escritorio | WebKit es **el único** de los tres con una frontera de plataforma pensada para ser portada. Blink la tiene a medias (`content/`, `ui/`) y Chromium la usa con `#if IS_MAC` repartido |
| D2 suelo de macOS | Apple controla el sistema: el WebKit del sistema envejece con la máquina (Mojave se queda en Safari 14); WebKit *trunk* fija su suelo por política interna (≈ macOS ≥ 11 en 2023, no he visto cifra oficial actual) [V (resultado): bugs.webkit.org 252783 y 327019] | Mozilla mantiene un canal ESR con SO viejos: **Firefox ESR 115** da soporte a macOS 10.12–10.14; fin previsto sept. 2024, ampliado a 2025 y luego a una fecha de 2026 que las fuentes no concuerdan (marzo o agosto) [V (resultado): [Mozilla](https://blog.mozilla.org/futurereleases/2023/07/06/firefox-support-for-macos-10-12-10-13-and-10-14/), [TidBITS](https://talk.tidbits.com/t/firefox-for-macos-10-12-through-10-14/22593?page=2)] | Ninguno resuelve D2 para nosotros: **WebKit trunk no sirve para Mojave** y el ESR de Gecko caduca. Gecko enseña una **política**: una rama de soporte largo para el SO viejo |
| D3 memoria | Reglas de punteros inteligentes (`Ref`, `RefPtr`, `CheckedPtr`) **impuestas por el analizador estático de clang**, no por revisión [V (resultado): [Niwa, webkit-dev 2023](https://lists.webkit.org/pipermail/webkit-dev/2023-August/032554.html); Garen, CppNow 2025: «el análisis define un C++ más seguro, no busca fallos»]; asignador propio (bmalloc/libpas) con montones aislados por tipo y *Gigacage* [V (resultado): [WithSecure](https://labs.withsecure.com/archive/some-brief-notes-on-webkit-heap-hardening/)] | **Rust** para componentes enteros (Stylo, WebRender). En Stylo, **51 de 69 fallos de seguridad (73,9 %) no habrían sido posibles** en Rust [V: [Mozilla Hacks, 2019](https://hacks.mozilla.org/2019/02/rewriting-a-browser-component-in-rust/)] | Chromium mide lo mismo: ~**70 %** de los fallos graves son de memoria (912 de 2015 en adelante, la mitad *use-after-free*) [V: [chromium.org](https://chromium.org/Home/chromium-security/memory-safety)] y responde con `raw_ptr`/PartitionAlloc y Rust en piezas sueltas. Las tres vías son válidas; **la de WebKit (reglas + analizador) es la única que se puede aplicar a código ya escrito sin reescribirlo** |
| D4 hardware viejo | Núcleo en C++ de bajo coste y compositor de Core Animation del sistema; intérprete (LLInt) rápido en JSC [I] | **WebRender** con respaldo por software para GPU sin soporte (exige hardware tipo D3D10 en escritorio) [V (resultado): wiki.mozilla.org/Platform/GFX/WebRender2020]; **TenFourFox** llevó Gecko a PowerPC con JIT y AltiVec hasta 2021 [V (resultado): [The Register](https://www.theregister.com/2021/03/31/tenfourfox_dev_quits/)] | Gecko es la referencia de **portar a hardware viejo**; Blink/V8 ni lo intentan (sin PPC ni Mac sin AVX en Chrome 117+) |
| D5 privacidad | *Intelligent Tracking Prevention* y, desde Safari 17, **ruido** en lecturas de canvas 2D, WebGL y WebAudio (por defecto en todo el tráfico desde iOS/macOS 26) | `resistFingerprinting` (RFP: zona UTC, tamaño de pantalla redondeado, temporizadores gruesos) | **No son equivalentes.** El ruido de Safari tiene fallos publicados (el de audio se saltó [V (resultado): [FingerprintJS](https://fingerprint.com/blog/bypassing-safari-17-audio-fingerprinting-protection/)]) y el RFP rompe sitios y **choca con declarar Chromium** (regla 20). Brave ya hace *farbling* (ruido, como Safari) |
| D6 compilar | WebKit compila en menos espacio y tiempo que Chromium [H] | Gecko, intermedio [H] | Sin medición propia; no es motivo para cambiar de motor |
| D7 plataformas | iOS (WKWebView), macOS, Linux (GTK/WPE), consolas | Windows, macOS, Linux, Android; PPC solo vía TenFourFox (cerrado, Gecko 45) | WebKit es el único con **iOS**. Para PPC el autor de TenFourFox recomendó *Leopard WebKit* en 10.5 y Firefox Legacy en 10.6 [V (resultado): The Register] |
| D8 rendimiento | **Todo el camino de dibujo es del sistema:** Core Animation (capas y composición), Metal y, para el vídeo, AVFoundation/VideoToolbox, que elige solo el camino por hardware [I]. Safari apaga el JIT solo en el Modo Aislamiento (*Lockdown*) [I] | Gecko saca estilo y dibujo del hilo principal (**Stylo**, **WebRender**), con respaldo por software; el JIT va siempre encendido | **WebKit no es más rápido por magia**: es más barato en una máquina Mac porque delega en el sistema lo que Chromium reimplementa (ANGLE, Skia, su compositor). Lo que sí podemos copiar es **la elección del camino por hardware** (ideas V14–V20) |

## 4. iOS: condiciones de Apple para motores propios (anotadas, sin decidir nada)

- **UE (España incluida):** desde iOS 17.4 / iPadOS 18, *Web Browser Engine Entitlement* (navegadores) y *Embedded
  Browser Engine Entitlement* (navegación dentro de apps). Requisitos vistos: app distribuida **solo** en iOS/iPadOS en
  la UE; tener ya el *default web browser entitlement*; cumplir un anexo de requisitos funcionales (una base de
  funcionalidad web); pedir un *Entitlement Profile* en el portal del Programa de Desarrolladores; y **obligaciones
  continuas de privacidad y seguridad, con actualizaciones de seguridad puntuales**. A cambio, Apple da JIT, multiproceso
  y otras capacidades [V (resultado): [Apple, UE](https://developer.apple.com/support/alternative-browser-engines)]. **No
  visto:** la lista completa del anexo y los plazos de parcheo (están en el PDF del anexo).
- **Japón:** desde iOS 26.2 (dic. 2025), lo mismo para navegadores y apps de «guardianes» de motor, con criterios y
  autorización previa; distribución solo en Japón salvo autorización expresa para otra jurisdicción [V (resultado):
  [Apple, Japón](https://developer.apple.com/support/alternative-browser-engines-jp)].
- **Resto del mundo:** WebKit obligatorio para las apps de navegación.
- **Lecturas, sin decidir:** (1) no existe un puerto oficial de Blink/V8 a iOS [I]: llevarlo (sandbox, JIT, interfaz,
  Chromium sobre iOS) es un trabajo de años y de riesgo ajeno; (2) «distribución solo en la UE» acota el mercado y
  obliga a mantener otra edición para el resto; (3) **la objeción dura es el parcheo puntual**: un FlyWeb-Blink en iOS
  exigiría estar al día de seguridad, justo lo que hoy no hacemos (base 116 con portes selectivos, `base-128.md`);
  (4) un FlyWeb sobre WebKit (V9) no tiene ninguna de esas condiciones y vale en todo el mundo. Decide ARQUITECTURA o
  el HUMANO.

## 5. Ideas (fichas)

Veredicto: **Hacer** (barato, claro), **Medir** (falta un dato), **Descartar** (con motivo). La V8 JIT-off por sitio
(*jitless* con sitios de confianza) **ya está hecha** (`cve-triage.md`); no se repite.

### 5.1 Rendimiento en la 5,1 y la 6,1 (V14–V21)

**V14 · Medir con benchmarks de motor, en Release y no en Static** — **Hacer primero**
- *Resuelve:* D8. Hoy no sabemos dónde se va el tiempo; la prueba de GPU de `multimedia.md` satura a 60 Hz [V] y la 5,1
  está en blanco. Sin cifras, las ideas V15–V20 son opiniones.
- *Cómo:* **Speedometer 3**, **MotionMark 1.3** (el benchmark gráfico de WebKit) y **JetStream 2.2**, publicados en
  browserbench.org [I]; en la compilación **Release** (ThinLTO), con tres configuraciones (por defecto, JIT en todo, Metal
  frente a OpenGL) y en las tres máquinas. Como referencia, **Firefox ESR 115** en Mojave (soportado en macOS 10.12–10.14
  [V (resultado): [Mozilla](https://blog.mozilla.org/futurereleases/2023/07/06/firefox-support-for-macos-10-12-10-13-and-10-14/)]):
  otro motor en el **mismo** hardware dice qué parte del coste es de Blink y cuál del Mac.
- *Gana:* convierte lo demás en cifras y decide el orden. *Cuesta:* 10–16 h de LOCAL/HUMANO delante de las máquinas,
  0 de código. *Distancia:* 0.

**V15 · Cuánto cuesta *jitless* en estas máquinas** — **Medir** (con V14)
- *Resuelve:* D8. FlyWeb corre sin JIT por defecto, con lista de sitios de confianza que sí lo usan, y **sin Wasm en los
  demás** en la 116 (`integracion.md`, paso 3) [V]. Es probablemente el mayor factor de lentitud en una CPU vieja y es
  una decisión de seguridad (`cve-triage.md`, filas 13–14: la mayoría de CVE de JIT son de Maglev/TurboFan/Wasm).
- *Lo que enseña WebKit:* JSC tiene intérprete y JIT sin optimizar, pero Safari solo apaga el JIT en el Modo
  Aislamiento [I]. **No hay término medio barato:** el escalón sin optimizar de V8 (Sparkplug) dio solo un 5–15 % sobre
  el intérprete en pruebas reales [V (resultado): [InfoQ](https://www.infoq.com/news/2021/06/v8-sparkplug-compiler/)];
  lo que pierde *jitless* son TurboFan y Maglev. Un nivel «solo Sparkplug» **no** compensa.
- *Idea:* cifrar la pérdida (Speedometer/JetStream, jitless frente a JIT) y, si es grande, **ampliar la lista de
  confianza con datos** (los sitios que usa Titín), no inventar un nivel intermedio. Cada sitio añadido asume los CVE de
  JIT.
- *Cuesta:* 0 de código; 2–4 h de decisión. *Distancia:* 0. Comprobar también si con la V8 13.1 sigue sin Wasm en los
  sitios sin JIT [H].

**V16 · Metal frente a OpenGL, por GPU** — **Medir** (con V14)
- *Resuelve:* D4/D8. ANGLE usa **OpenGL 4.1** por defecto en la 116 en Mojave y Sequoia [V]; Apple declaró OpenGL
  obsoleto en 10.14 y lo dejó en 4.1 (`hoja-de-ruta.md`). WebKit va solo por Metal y Core Animation [I]. En Chromium, el
  despliegue de ANGLE-Metal por defecto iba «parcial» en la 118 y Skia Graphite exige ANGLE-Metal [V (resultado):
  [commit de Chromium](https://chromium.googlesource.com/chromium/src/+/aba318bb00c92df222ff922b4476c60e2e51d982)]: el
  futuro de upstream es Metal y el camino OpenGL queda sin mantenimiento.
- *Idea:* decidir con MotionMark y con desplazamiento real, no con el *shader* de 1024×1024. Criterio ya escrito
  (`multimedia.md` §2): si Metal gana ≥ 20 % en una GPU, fijarlo para esa GPU (D500, RX 580).
- *Cuesta:* 4–8 h de medición tras V14 y 2–6 h para la regla por GPU. *Riesgo:* fallos de Metal con drivers AMD de
  Mojave; Legacy documenta colores mal con 117–119 y aceleración por GPU en Intel [V: [issue 191](https://github.com/blueboxd/chromium-legacy/issues/191)]
  → probar color, vídeo y WebGL. *Distancia:* 0 (`--use-angle`) o 1 (regla por GPU).

**V17 · Preferir lo que el hardware decodifica: H.264 por HW antes que VP9/AV1 por software** — **Medir y, si procede, hacer**
- *Resuelve:* D8. La D500 decodifica H.264 por hardware; VP9 y AV1 salen «fluidos» pero por software; no hay HEVC; la RX 580
  de la 5,1 está sin medir [V]. YouTube es la carga pesada más común.
- *Lo que enseña WebKit:* el vídeo va por AVFoundation/VideoToolbox y se presenta con capas del sistema, así que el
  camino por hardware se elige solo [I]. `multimedia.md` §2 ya propone una extensión que fuerce H.264; la versión nativa
  sería anunciar VP9/AV1 como no soportados donde no haya decodificador por hardware.
- *Cuesta:* 4–10 h (un parche en `media/`, el mismo sitio que toca la fila 9 de `base-128.md`: coordinar). *Riesgo:*
  cambia lo que `canPlayType`/`MediaCapabilities` dicen (superficie de huella frente a un Chrome real: un compromiso
  con la regla 20) y pierde el 4K de YouTube, que estas GPU tampoco mueven. *Distancia:* 1–2.
- *Veredicto:* medir antes la CPU con VP9 frente a H.264 en la 5,1 y la 6,1 (`multimedia.md` §1c, pendiente); si es más
  del doble, hacerlo.

**V18 · Perfil de RAM alta (48–96 GB)** — **Medir, prioridad baja**
- *Resuelve:* D8. Sobra memoria: más páginas vivas (caché de página atrás/adelante), sin descarte de pestañas y con cachés
  de imagen y de disco mayores. Es el contrario de V4 (RAM baja); la elección puede ser automática por RAM.
- *Cuesta:* 4–8 h de pruebas. *Distancia:* 0 (flags y parámetros de `base::Feature`).

**V19 · Compilación: ThinLTO, PGO y juego de instrucciones** — **Medir**
- *Resuelve:* D8. La Release ya es `is_official_build` con ThinLTO [V: `build.sh`]; **no consta si usa PGO**
  (`chrome_pgo_phase`) [H]. Chromium publica perfiles por plataforma y las compilaciones oficiales los usan.
- *Juego de instrucciones:* la 5,1 no tiene AVX (regla fija) pero sí SSE4.2; la 6,1 y la 7,1 tienen AVX. Las bibliotecas
  críticas (códecs, Skia, BoringSSL) despachan en ejecución [I], así que subir la base a SSE4.2 ganaría poco y
  arriesgaría Macs de 2009 de High Sierra (Penryn, sin SSE4.2) [I]. **No tocar.**
- *Cuesta:* 2–6 h para confirmar PGO y medir con V14. *Distancia:* 0 (argumentos de GN).

**V20 · Hilos para muchos núcleos** — **Medir, expectativa baja**
- *Resuelve:* D8. Estilo y *layout* van en el hilo principal en Blink y en WebKit [I]; Gecko los paraleliza con Stylo
  (V6, descartada). Sí se pueden ajustar los hilos de rasterización (`--num-raster-threads`) y los de V8 [I].
- *Gana* poco en carga normal; algo en páginas con mucho dibujo. *Cuesta:* 2–4 h. *Distancia:* 0.

**V21 · Repartir trabajo en la segunda D500 de la 6,1** — **Descartar**
- Un proceso de GPU usa una tarjeta; repartir dibujo o decodificación entre dos obliga a copiar entre tarjetas y ningún
  navegador lo hace [I]. Distancia 4 y ganancia pequeña. «Aprovechar el hardware al 100 %» no pasa por ahí.

### 5.2 Arquitectura, seguridad y portabilidad (V1–V13)

**V1 · Capa de compatibilidad Mojave aislada** (idea de los *ports* de WebKit) — **Hacer**
- *Gana:* los ~15 bloques de `base-128.md` (guardas 10.15, GPU, captura) viven agrupados y etiquetados por directorio; un
  salto de base o un nivel nuevo los rehace sin buscarlos. Reduce D1 y D2.
- *Cuesta:* 10–30 h para ordenar lo que ya existe en `patches/` y `chromium_src/` con una convención («un `.patch` por
  directorio, prefijo `mojave-`») y una página con la lista. Sin código nuevo.
- *Distancia:* 1. No cambia lo que se parchea, solo cómo se organiza.

**V2 · Comprobar y mantener las mitigaciones de memoria de Chromium** (`raw_ptr`/BackupRefPtr, PartitionAlloc) — **Medir**
- *Gana:* los *use-after-free* (la mitad de los fallos graves [V]) dejan de ser explotables de forma directa. D3.
- *Cuesta:* 4–10 h: confirmar en `args.gn` de la 116 y de Brave qué está encendido en x86-64 de macOS y medir el coste
  en RAM y velocidad en la 5,1 (puede notarse en una máquina vieja). **No sé** si están encendidos en nuestra
  compilación [H].
- *Distancia:* 0 (argumentos de GN).

**V3 · Regla de «C++ más seguro» para nuestro código, impuesta por el compilador** (idea de WebKit) — **Hacer**
- *Gana:* cada función que portamos añade código al renderer (`motor.md`, principio 8). Una regla mecánica (lo que ya
  comprueba el plugin de estilo de Chromium en campos `raw_ptr` y en el uso de punteros crudos) frena que **nuestros**
  portes metan *use-after-free* nuevos; WebKit demuestra que funciona por analizador, no por revisión [V (resultado)].
- *Cuesta:* 6–12 h: confirmar que el plugin va encendido en nuestras compilaciones y añadir a SEGURIDAD-PORTES una
  línea en la lista de revisión de la regla 17.
- *Distancia:* 0–1.

**V4 · Memoria en máquinas con poca RAM: descarte de pestañas y límite de procesos de renderer, SIN tocar el aislamiento
por sitio** — **Medir**
- *Gana:* D4. El aislamiento de sitios cuesta ~9–13 % de memoria total [V: [Reis et al., USENIX Security 2019](https://research.google/pubs/pub48285/)];
  es un precio bajo por una barrera de seguridad grande: **no recomiendo quitarlo**. Sí el descarte de pestañas en
  segundo plano (función ya existente en Chromium/Brave).
- *Cuesta:* 4–8 h de pruebas en el G5 de 12 GB o en un Mac de 8 GB; solo configuración.
- *Distancia:* 0. La contraparte con RAM de sobra es V18.

**V5 · Perfil de GPU por máquina con respaldo por software** (idea de WebRender) — **Hacer, ya apuntado; se mide con V16**
- *Gana:* D4. Con 117–119 en Mojave, Chromium Legacy documenta colores mal con la aceleración encendida; el apaño fue apagar
  la rasterización por GPU [V: [issue 191](https://github.com/blueboxd/chromium-legacy/issues/191)]. Gecko resolvió lo mismo
  con un renderizador por software como camino normal para GPU no admitidas.
- *Cuesta:* parte de la Fase 5 de `hoja-de-ruta.md` y de `multimedia.md` (tabla por máquina y backend); 8–16 h. Reponer
  las listas de GPU está en `base-128.md`, fila 14.
- *Distancia:* 0 (`--use-angle`, `--disable-gpu-rasterization`) o 1 (listas de GPU).

**V6 · Estilos en paralelo (Stylo)** — **Descartar**
- *Gana:* velocidad de recálculo de estilo en equipos de muchos núcleos (la 7,1 tiene 16); nada en el G5 de 2 núcleos.
- *Cuesta:* un motor de estilos nuevo (Mozilla lo escribió en Rust tras años de trabajo); Blink calcula estilos en el hilo
  principal. Meses o años.
- *Distancia:* 4. Los parches de Blink dejarían de aplicar en `core/css`. **Motivo del descarte:** el beneficio no
  compensa y toca exactamente el código que más portamos (niveles de CSS).

**V7 · Rust para código nuevo y propio, como Gecko (y ya Chromium en piezas)** — **Hacer como regla, no como reescritura**
- *Gana:* D3 en lo que escribimos nosotros: el 73,9 % de los fallos de seguridad de Stylo habrían sido imposibles [V].
  Si FlyWeb añade analizadores (componentes firmados, listas de Shields, formatos nuevos), que sean crates en Rust.
- *Cuesta:* 0 h si se aplica solo a lo nuevo; el toolchain de Rust ya lo trae la compilación de Chromium. Comprobar que
  el binario resultante carga en Mojave (la biblioteca estándar de Rust admite 10.12+ [H]).
- *Distancia:* 1 (ficheros nuevos). **No** proponer reescribir Blink: no está al alcance y no aporta nada a upstream.

**V8 · Montones aislados por tipo (isoheaps/libpas)** — **Descartar en Blink**
- *Gana:* convierte un *use-after-free* en un fallo de tipo en lugar de una confusión de tipos [V (resultado): WithSecure].
- *Cuesta:* es el asignador de WebKit; Blink ya reparte PartitionAlloc en particiones (búferes, diseño, memoria rápida)
  y Oilpan gestiona el DOM [I]. Replicar el aislamiento por tipo es un fork del asignador.
- *Distancia:* 4. **Motivo:** el beneficio queda cubierto por V2 a coste cero.

**V9 · FlyWeb para iOS sobre el iOS de Brave (WKWebView)** — **Estudio aparte antes de decidir**
- *Gana:* D7. Reutiliza servidor (`FlyWeb/servidor/`), listas de Shields (convertibles a *content rules* de WebKit
  [I]), sincronización y la marca; el motor lo da Apple.
- *Cuesta:* alto y con riesgo ajeno (cuenta de desarrollador, revisión de App Store, reglas de privacidad); el motor
  propio de FlyWeb **no** viaja a iOS: lo hecho en Blink/V8 no aprovecha. Sin estimación fiable todavía.
- *Distancia:* 2 para el código de iOS de brave-core (que ya existe) más la marca; 0 para el servidor. Apple permite
  motores propios en la UE (España incluida) y en Japón, con condiciones (§4).
- *Pendiente:* qué parte de `brave-core/ios` sigue viva y cuánto pesa el rebase de marca (§7).

**V10 · Linux como nexo** — **Medir, sin prisa**
- *Gana:* D7: variedad de hardware y de pruebas (incluido x86 sin AVX y, con límites, PowerPC 64).
- *Cuesta:* recompilar el mismo árbol con GN de Linux y repasar `chromium_src` de Mac; **no sé** cuántos parches de
  FlyWeb son solo de macOS. Chromium en Linux soporta ppc64 little-endian, no el del G5 (big-endian) [H].
- *Distancia:* 0–1.

**V11 · Leopard PPC y el G5 como lienzo** — **Abierto; propongo un estudio propio**
- Lo que hay: TenFourFox (Gecko 45, JIT y AltiVec) cerrado en 2021 con parches «de afición» [V (resultado)], y *Leopard
  WebKit* recomendado por su autor para 10.5. Ni Blink ni V8 modernos son viables en PPC de 32 bits ni en Leopard.
- El G5 (970MP, 64 bits, AltiVec, 12 GB) **no** corre claude.ai y no es el objetivo; sí sirve como banco para un motor
  mínimo que aproveche la CPU. Opciones: (a) mantener o compilar TenFourFox/Leopard WebKit sin tocarlos; (b) Linux ppc64
  big-endian con un Firefox de la distribución; (c) un motor propio pequeño (NetSurf-like) — coste de años.
- Siguiente paso concreto: ficha propia con medición de qué compila hoy en Leopard (herramientas de Xcode 3.1 y GCC) y qué
  se pierde del G5 si se usa Linux. **No** cambiar el plan de FlyWeb por esto.

**V12 · Privacidad: ruido al estilo Safari/Brave, sin el RFP de Firefox** — **Hacer lo que ya hace Brave; no añadir RFP**
- *Gana:* D5 sin romper la identidad declarada (regla 20). El *farbling* de Brave equivale al ruido de Safari y no
  exige parches nuevos.
- *Cuesta:* 4–8 h de medición con privacytests.org y las páginas de huella; subir la lista de lo que exponemos solo si
  la medición lo pide.
- *Distancia:* 0. **Descartado el RFP:** zona horaria UTC, pantalla redondeada y temporizadores gruesos son rasgos
  que no tiene ningún Chromium; un antibot nos leería como suplantación (el mismo argumento de `platformVersion`).

**V13 · Rama de soporte largo para el SO viejo (política de Gecko)** — **Hacer como decisión, no como código**
- *Gana:* D2. Mozilla mantiene un ESR con SO viejos para quien no puede actualizar; FlyWeb ya lo hace de hecho con
  Mojave. Escribirlo como política (qué SO, hasta cuándo, qué se promete) evita que el siguiente suelo de macOS decida
  por nosotros. Gecko enseña también su límite: el ESR 115 se amplió dos veces y las fuentes no concuerdan en la fecha.
- *Cuesta:* 2–4 h de redacción; decide ARQUITECTURA.
- *Distancia:* 0.


## 6. Orden propuesto y qué NO hacer

1. **Primero V14** (medir en Release, con Firefox ESR 115 como referencia): sin esas cifras, V15–V20 no se pueden ordenar.
2. **Hacer ya (<30 h en total):** V1 (ordenar), V3 (regla del plugin), V13 (política) y V7 como regla para código nuevo.
3. **Medir con V14:** V15 (coste de *jitless*), V16 (Metal frente a OpenGL), V17 (códecs), V19 (PGO), V18 y V20.
   Mi apuesta, sin datos todavía: **lo que más rendimiento da en la 5,1 y la 6,1 es V15 (ampliar la confianza) y V16
   (Metal)**; V17 si YouTube sube mucho la CPU. Las demás dan poco.
4. **Estudios propios:** V9 (iOS), V10 (Linux), V11 (PPC).
5. **No hacer:** Stylo (V6), asignador por tipo (V8), RFP (V12), quitar el aislamiento por sitio (V4) y la segunda D500
   (V21): empujan a una divergencia (distancia 3–4) o a perder seguridad sin una ganancia que lo pague.
6. **Lo que no cambia:** el camino principal sigue siendo niveles de Blink/V8 sobre la 116. Estas ideas reducen el coste
   de mantenerlo o lo hacen rendir más; ninguna lo sustituye. WebKit es la referencia de **arquitectura** (frontera de
   plataforma, reglas de memoria con analizador, delegar en el sistema) y de **iOS**, no un motor que podamos adoptar en
   macOS 10.14 (el *trunk* de WebKit fija su suelo en macOS ≥ 11 [V (resultado): bugs.webkit.org 252783]).

## 7. Fuentes

- Proyecto: `multimedia.md` (§3, mediciones de la 6,1 y la 7,1), `hoja-de-ruta.md` (Fase 5), `integracion.md` (paso 3,
  *jitless*), `cve-triage.md` (filas 13–14), `scripts/build.sh` (Release con ThinLTO), `base-128.md`.
- Reis, Moshchuk, Oskov, [«Site Isolation: Process Separation for Web Sites within the Browser»](https://www.usenix.org/conference/usenixsecurity19/presentation/reis), USENIX Security 2019 (sobrecarga de memoria 9–13 %) (resultado).
- Mozilla Hacks, [«Implications of Rewriting a Browser Component in Rust»](https://hacks.mozilla.org/2019/02/rewriting-a-browser-component-in-rust/), 2019 (51 de 69 fallos de Stylo) (resultado).
- Chromium, [«Memory safety»](https://chromium.org/Home/chromium-security/memory-safety) (912 fallos graves desde 2015, ~70 % de memoria) (resultado).
- WebKit: [Smart Pointers Usage Guidelines (webkit-dev, 2023)](https://lists.webkit.org/pipermail/webkit-dev/2023-August/032554.html);
  [«Memory safety in WebKit», CppNow 2025](https://schedule.cppnow.org/session/2025/memory-safety-in-webkit/);
  [WithSecure, «Some brief notes on WebKit heap hardening»](https://labs.withsecure.com/archive/some-brief-notes-on-webkit-heap-hardening/) (resultados).
- Apple: [motores alternativos en la UE](https://developer.apple.com/support/alternative-browser-engines),
  [en Japón](https://developer.apple.com/support/alternative-browser-engines-jp),
  [M. J. Tsai, iOS 26.2](https://mjtsai.com/blog/2026/01/06/ios-26-2-alternative-browser-engines-in-japan/) (resultados).
- Mozilla, [Firefox y macOS 10.12–10.14](https://blog.mozilla.org/futurereleases/2023/07/06/firefox-support-for-macos-10-12-10-13-and-10-14/);
  [TidBITS](https://talk.tidbits.com/t/firefox-for-macos-10-12-through-10-14/22593?page=2) (fechas de ESR 115, discordantes).
- V8, [Sparkplug](https://v8.dev/blog/sparkplug) y [InfoQ](https://www.infoq.com/news/2021/06/v8-sparkplug-compiler/) (5–15 % sobre el intérprete) (resultado).
- Chromium, [commit sobre Graphite y ANGLE-Metal](https://chromium.googlesource.com/chromium/src/+/aba318bb00c92df222ff922b4476c60e2e51d982) (resultado).
- [The Register, fin de TenFourFox](https://www.theregister.com/2021/03/31/tenfourfox_dev_quits/);
  [WebRender 2020](https://wiki.mozilla.org/Platform/GFX/WebRender2020) (resultados).
- Safari 17 y huella: [FingerprintJS](https://fingerprint.com/blog/bypassing-safari-17-audio-fingerprinting-protection/) (resultado).
- Chromium Legacy [issue 191](https://github.com/blueboxd/chromium-legacy/issues/191).

## 8. Pendiente (próximas entradas)

- Abrir las fuentes marcadas «(resultado)» cuando haya red y confirmar las cifras con el texto completo (sobre todo
  el anexo de requisitos de Apple para la UE).
- V14: tabla de resultados (5,1 vacía) y primer Speedometer 3 / MotionMark / JetStream en Release.
- V19: ¿la Release usa PGO? Leer `chrome_pgo_phase` en el `args.gn` real de LOCAL.
- V2: leer `args.gn` de Brave 1.57 (¿`enable_backup_ref_ptr_support`?).
- V15: ¿sigue la V8 13.1 sin Wasm en los sitios sin JIT?
- V9: qué queda de `brave-core/ios` y qué regla de App Store afecta a una marca nueva.
- V10 y V11: fichas propias, solo como contexto de largo plazo (Titín tiene además un G5 anterior con dos procesadores
  separados, PowerMac7,2 o 7,3, y Xcode 3.1.3 en la máquina con Leopard; encargo de COORDINACIÓN-7, 19-10).
