# FlyWeb — viabilidad de un navegador moderno para el G5 con Sorbet Leopard (INVESTIGACIÓN-MOTOR, 20-10-2026)

Estudio en papel (fila FM.27; desarrolla la ficha V11 de `vision-motor.md`). Sin código ni ramas. **Propone; decide Titín.**
Objetivo de Titín: **la mayor compatibilidad web posible en el G5** (PowerMac11,2: 970MP de doble núcleo a 2 GHz, 64 bits
big-endian, AltiVec, 12 GB). El criterio **no** es claude.ai. Solo G5; los G4 de 32 bits quedan fuera.

**Etiquetas:** **[V]** visto en una fuente citada; **[I]** inferido; **[H]** hipótesis. «(resultado)» = lo vi solo como
resultado de búsqueda (la sesión de nube no abre todas las páginas). Las horas son **estimación mía**. **No he podido
probar nada en un G5**: todo es de papel y por eso §9 propone una medición.

> **Actualización 20-10 (2): aportación de Titín sobre Rust (`mrustc`) y WebAssembly (`w2c2`).** **El veredicto no cambia**
> (no portar un motor), pero **el muro de Rust pasa de «imposible» a «camino indirecto posible y sin demostrar para algo del
> tamaño de Gecko»**. Detalle y límites en §5.1.

> **Actualización 20-10 (3): datos del G5 de Titín (Terminal). El veredicto no cambia** (no portar un motor), y todo lo de
> abajo es **[V]** salvo lo marcado. Lo que se concreta:
>
> - **GPU: NVIDIA GeForce 6600 LE, 128 MB, PCIe x16**, con Core Image y Quartz Extreme por hardware. OpenGL ≈ 2.1 [I] y
>   **sin decodificación H.264 por hardware** en Leopard [I]: el vídeo web va por CPU. La pantalla es de **2560×1440**.
> - **No hay compilador en este G5:** `gcc`, `g++` y `xcodebuild` dan «command not found» (en el PATH; falta comprobar
>   `/Developer`). Cualquier camino de compilación (§5.1) empieza por instalar Xcode 3.1.3 o un GCC de MacPorts: **+ 2–4 h**
>   [H], sin cambiar el veredicto.
> - **OpenSSL 0.9.7l y curl 7.16.4 son los de serie:** Sorbet **no** los actualiza. Las herramientas del sistema solo hablan
>   **TLS 1.0**, así que `curl`, `openssl`, `git` o `cargo` **no pueden bajar nada de la web actual** [I]: las fuentes hay
>   que llevarlas desde otro Mac. Falta saber si el Safari/WebKit de Sorbet usa un TLS más nuevo (prueba en §9, punto 6).
> - **`sw_vers` dice 10.5.9 (9L31b), Darwin 9.8.0;** CPU 970MP a **2,0 GHz**, **64 bits** (`hw.cpu64bit_capable = 1`) y
>   **12 GB**: confirma lo supuesto.
> - **Falta:** la salida de `file` sobre Aquafox (no llegó) y la versión de Aquafox.

## 1. Resumen

1. **Ningún motor moderno se puede llevar a Darwin PPC con un esfuerzo razonable.** Gecko reciente y Servo exigen Rust y
   no hay `rustc` oficial para Mac OS X PowerPC (el autor de TenFourFox lo declaró imposible desde Firefox 54 [V]); existe un
   camino indirecto por C con `mrustc` (§5.1), sin demostrar para algo del tamaño de Gecko;
   Blink/V8 y WebKit modernos exigen años de trabajo de sistema operativo, compilador y GPU; Ladybird pide C++23 y
   es todavía una alfa. Lo único que pasa de la tabla (§4) son los navegadores que **ya existen** para Leopard.
2. **La referencia, Aquafox, no es un Firefox 128/140.** Es un fork de TenFourFox (Gecko 45 con parches posteriores);
   lo que sigue las versiones ESR 128 y 140 son **listas de datos** (certificados, HSTS, zonas horarias), no el motor
   [V (notas de versión); I (lectura)]. Su compatibilidad real es de ~2016–2018.
3. **El candidato local con más recorrido es PowerFox** (Jazzzny, 2026, beta): motor UXP/Basilisk, **sin Rust**, con
   JavaScript hasta ES2020+ en la línea Pale Moon, TLS 1.3, WebGL y, desde una actualización de 2026, JIT y Skia
   [V (resultado)]. Puede **superar a Aquafox en JavaScript moderno**; está sin medir y sin versión estable.
4. **Para compatibilidad total, lo que hoy funciona es renderizar fuera del G5** (FlyWeb en la 7,1 o un servidor, visto
   por VNC/WebRTC): 8–24 h de puesta en marcha, compatibilidad = la del Chromium del servidor, a costa de latencia,
   vídeo y de depender de la red (§6).
5. **Seguridad:** un motor de 2016 en la web abierta arrastra diez años de fallos de memoria sin corregir; ningún
   fork de PowerPC los corrige en bloque [I]. No mezclarlo con cuentas importantes (§8).
6. **Recomendación (confianza media):** (a) Aquafox como navegador de uso diario; (b) probar **PowerFox** esta semana
   contra Aquafox con la batería de §9 (≈3 h en el G5); (c) montar un **renderizado remoto** como válvula para las webs
   que ninguno de los dos abra y para cuentas sensibles; (d) **no** invertir horas de ingeniería en portar un motor.
   **Linux en el G5** (Firefox ESR con Rust disponible, sin JIT) queda como estudio aparte, sin comprometer nada (§7).

## 2. Punto de partida: el G5 y Sorbet Leopard

- **Máquina** (PowerMac11,2, TAREAS): dos núcleos 970MP a 2 GHz, 1 MB de L2 por núcleo, 12 GB, SSD. **La GPU no consta**
  en los documentos del proyecto, pero **ya consta: GeForce 6600 LE, 128 MB** (actualización 20-10 (3)). OpenGL de Leopard en PPC: 2.1 [I]; sin Metal.
- **Qué es Sorbet Leopard** [V (resultado): [MacRumors](https://forums.macrumors.com/threads/sorbet-leopard-10-5-reinvigorated-updated.2300924/),
  [Macintosh Repository](https://www.macintoshrepository.org/39027-sorbet-leopard)]: Mac OS X 10.5.8 modernizado, con
  componentes de 10.6.8, retoques propios de rendimiento y de sistema. **Lo que enumera su autor:** Safari 11,
  QuickTime 7.7 Pro, Bash 4.3.30, ntpd 4.2.8 y **certificados raíz iguales a los de macOS 10.13.6**.
- **Qué abre eso, y qué no:**
  - *Abre* la validación de HTTPS con raíces de 2018 en las apps que usan el llavero del sistema, y un Safari 11
    (WebKit 604, ≈ el Leopard WebKit de §4) [I].
  - **Datos del G5 de Titín [V]:** `sw_vers` = 10.5.9 (9L31b); **OpenSSL 0.9.7l y curl 7.16.4 de serie** (Sorbet no los
    toca); **sin `gcc`, `g++` ni `xcodebuild` en el PATH**. No consta la versión de libc++ ni de las bibliotecas de
    desarrollo. MacPorts avisa de que Sorbet es una versión **no estándar** y que no la soporta ni la probó [V (resultado):
    lista de MacPorts].
  - La cadena de compilación **no depende de Sorbet**: GCC admite `powerpc-darwin9` hasta GCC 14 (Iain Sandoe) y se
    llega a él desde Xcode 3.1.x (GCC 4.2) pasando por GCC 10 como puente [V (resultado): [gcc-help, abr. 2023](https://lists.nongnu.org/archive/html/gm2/2023-04/msg00087.html)];
    Brian Callahan compiló GCC 14.2 para Tiger con parches al ensamblador de `cctools` [V (resultado): [blog](https://briancallahan.net/blog/20250329.html)].
    Es decir: **hay C++17/20 en Darwin PPC; no hay Rust** (§5).
- **32 contra 64 bits:** Leopard corre aplicaciones de 64 bits en el G5 [I]; TenFourFox y sus derivados son de **32 bits**
  [I], así que cada proceso ve ≤ 4 GB y los 12 GB solo sirven para tener varios procesos o cachés del sistema.

## 3. La referencia: Aquafox

| Pregunta | Respuesta | Evidencia |
|---|---|---|
| ¿En qué está basado? | Fork independiente de **TenFourFox** (que es Firefox 45 + parches posteriores); nació como continuación de InterWebPPC; solo Tiger y Leopard; compilaciones para G3, G4, **G5** y Yonah; 920 commits | [V: [repo](https://github.com/BlackBirdLC/Aquafox)] |
| ¿Qué son «ESR 128» y «ESR 140»? | En las notas de la 2.0 «pasó a ESR 128 y **importó** sus certificados raíz, listas HSTS/HPKP y zonas horarias»; la 3.x dice «actualización de seguridad a ESR 140.13 (HSTS, HPKP, TLD)» y «listas de bloqueo de 140.10.2» y actualiza los *user agents* a Chrome/Firefox/Safari actuales | [V: [versiones](https://github.com/BlackBirdLC/Aquafox/releases)]; que el motor sigue siendo el de TenFourFox: [I] (también porque la 3.0 dice «TenFourFox February patchset») |
| ¿Está activo? | Sí: 3.3 el 1 de agosto (año no impreso; ESR 140.13 es de 2026) | [V]/[I] |
| ¿JIT? | Hereda **IonPower** de TenFourFox (IonMonkey adaptado a PPC, «hasta 40 veces más rápido que el intérprete»; ajuste específico para el 970 en el G5); **sin WebAssembly**; asm.js sin aceleración propia | [V: [FAQ de TenFourFox](https://github.com/classilla/tenfourfox/wiki/AAATheFAQ)]; que Aquafox lo conserva: [I] |
| ¿TLS? | TLS 1.2 y **1.3** (desde la FPR20 de TenFourFox) | [V: FAQ] |
| ¿AltiVec? | Sí, para VP8/VP9, JPEG y WebM | [V: FAQ] |
| ¿Hasta qué versión web llega? | Motor ≈ Firefox 45 (marzo de 2016) con retoques; **sin WebAssembly**. En JavaScript/CSS, lo mejor de los casos es ≈ 2017–2018 | [V] para 45 y Wasm; **[H]** para el resto: sin batería de pruebas |
| ¿Se parchea la seguridad del motor? | Las notas hablan de **listas**, no de arreglos de código de ESR 128/140 | [I]; confirmar con el autor |

**Lectura crítica:** el *user agent* de Chrome/Firefox actual hace que las webs sirvan su versión moderna a un motor de
2016. Es una decisión razonable para evitar el «navegador no soportado», pero cuando la web usa una sintaxis o una API
que el motor no tiene, falla en lugar de degradarse [I].

## 4. Candidatos

Dos tablas: capacidades y esfuerzo. «Horas» = estimación mía [H].

**4.1 Capacidades**

| Opción | Versión web alcanzable | JIT | Big-endian | Cadena de compilación (Darwin PPC) | Gráficos | TLS y seguridad |
|---|---|---|---|---|---|---|
| **Aquafox** (Gecko 45/TenFourFox) | ≈ 2016–2018 [H]; sin Wasm | IonPower [V] | Sí (PPC) [V] | GCC; kit de TenFourFox; **sin Rust** (no lo necesita) | Compositor propio; WebGL parcial [H] | TLS 1.3, raíces de ESR 140 [V]; motor sin parchear [I] |
| **PowerFox** (UXP/Basilisk) | **ES2016–2020+** en la línea Pale Moon 32 (sin BigInt en la 32.0; clases públicas y asignación lógica en la 32.2) [V (resultado)]; **sin Wasm** (línea Pale Moon) [V (resultado)] | IonPower + Skia desde 2026 [V (resultado)] | PPC [I]; G5 sin confirmar | GCC; UXP **no usa Rust** [V (resultado)] | WebGL anunciado [V (resultado)] | TLS 1.3 [V (resultado)]; motor Goanna, con mantenimiento propio |
| **Leopard WebKit** (WebKit 604.5.6 ≈ Safari 11) | ≈ 2017 | **No** (JSC no tiene JIT para PPC; LLInt/C Loop) [I] | Sí | Xcode 3.x | Core Graphics/CA del sistema | **Sin TLS 1.3**; más lento que InterWebPPC [V (resultado): foros]; proyecto parado |
| **TenFourFox oficial** | = Aquafox sin la capa nueva | IonPower | Sí | — | — | Sin versiones nuevas desde la FPR32.5 (oct. 2021) [V (resultado)] |
| **Arctic Fox PPC** (wicknix) | ≈ Pale Moon antiguo | — | — | — | — | **Archivado** en jul. 2023, «prueba de concepto, miles de commits por detrás» [V] |
| **Gecko ESR reciente** (140/153) en Darwin PPC | = Firefox actual | Sin JIT para PPC (el de TenFourFox no sube a ESR) | SpiderMonkey tiene fallos de endianidad conocidos [V (resultado): [jitpower](https://github.com/classilla/jitpower)] | **Exige Rust**: no hay destino `powerpc-apple-darwin` oficial (camino indirecto: `mrustc`, §5.1); los destinos Apple de 32 bits son *tier 3* desde Rust 1.42 [V (resultado): [RFC 2837](https://www.ncameron.org/rfcs/2837.html)] | WebRender: OpenGL 3.x [H] | — |
| **Blink/V8** en Darwin PPC | = Chrome actual | V8 tiene port ppc64 de IBM (AIX big-endian, Linux little-endian) [V (resultado): [Red Hat](https://developers.redhat.com/articles/2021/12/09/how-nodejs-uses-v8-javascript-engine-run-your-code)] | V8 ppc64 sí; Chromium no [I] | Chromium exige clang reciente y SO de 64 bits LE con APIs de 2018+ | ANGLE/Skia: GL ES 3 [H] | — |
| **WebKit moderno** (WebKitGTK/WPE) | = Safari 17+ | **No** en ppc64: LLInt/C Loop; JSC con supuestos little-endian [V (resultado): [bug 128743](https://bugs.webkit.org/show_bug.cgi?id=128743), [webkit-dev 2017](https://lists.webkit.org/pipermail/webkit-dev/2017-February/028754.html)] | Soporte frágil (sí en C Loop de 64 bits [V (resultado): [bug 103128](https://bugs.webkit.org/show_bug.cgi?id=103128)]) | C++20; en Linux ppc64 BE existe; en Darwin PPC no | OpenGL | — |
| **Servo** | Parcial (embebible, inmaduro) | SpiderMonkey sin JIT PPC | — | **Rust**: solo por `mrustc` (§5.1) | wgpu: no | — |
| **Ladybird** | Alfa; LibJS propio | Sin JIT útil [H] | Supuestos little-endian [H] | **C++23**, Skia, bibliotecas de 2024+; GCC 14 en Darwin PPC lo haría *en teoría* [I] | Metal/OpenGL moderno: no | — |
| **NetSurf** | HTML 4/CSS 2.1 + flexbox (3.11); JS con Duktape, limitado y apagado de serie | Sin JIT | Portable | GCC; sin frontal Cocoa propio [H] | Propios | Depende de OpenSSL/GnuTLS del sistema |
| **Renderizado remoto** (FlyWeb en la 7,1, Neko, Kasm, VNC) | = el Chromium del servidor (FlyWeb: nivel 131) | El del servidor | Irrelevante | Solo cliente en el G5: VNC (p. ej. Chicken) o WebRTC en Aquafox (TFF trae WebRTC y AltiVec para VP8) [H] | El servidor | Cifrado en el túnel; cuentas y cookies **en el servidor** |

**4.2 Esfuerzo y riesgo** (estimación mía; «puesta» = hasta tener algo usable; «mant.» = al mes)

| Opción | Puesta en marcha | Mantenimiento | Riesgo | Veredicto |
|---|---|---|---|---|
| Aquafox | 0–2 h | 0 (lo lleva su autor) | Un solo mantenedor; techo de compatibilidad bajo; seguridad (§8) | **Usar (referencia)** |
| PowerFox | 1–4 h (instalar y medir) | 0 | Beta de 2026; 32 bits; G5 sin confirmar; Wasm ausente | **Medir ya** |
| Leopard WebKit | 0–1 h | 0 | Parado; sin TLS 1.3 | Solo como segundo motor de prueba |
| TenFourFox oficial / Arctic Fox | — | — | Sin soporte | Descartar |
| Gecko ESR en Darwin PPC | **1 500–4 000 h** (Rust + SpiderMonkey sin JIT + WebRender) [H] | Alto | Inabordable; Kaiser lo dio por imposible [V] | **Descartar** |
| Blink/V8 en Darwin PPC | **>3 000 h** [H] (SO, clang, GPU, V8 en Darwin) | Muy alto | Inabordable | **Descartar** |
| WebKit moderno en Darwin PPC | **800–2 000 h** [H] | Alto | Sin JIT: lento en un 970 de 2 GHz | **Descartar** |
| Servo | Rust solo por `mrustc` (§5.1); además GL 3 y SpiderMonkey | — | Inmaduro | Descartar |
| Ladybird | >1 000 h [H] | Alto | Alfa; C++23 | Descartar ahora; revisar en 1–2 años |
| NetSurf | 20–40 h [H] | Bajo | Compatibilidad baja | Opcional, para páginas de texto |
| **Renderizado remoto** | **8–24 h** [H] | 1–2 h/mes | Latencia, vídeo, red; datos en el servidor | **Hacer como válvula** |
| Linux en el G5 + Firefox ESR / WebKitGTK | 4–12 h de SO + paquetes [H] | Bajo (distribución) | Sin JIT; GPU GeForce 6600 (NV43: *nouveau*, sin probar en PPC [I]); abandona Sorbet | **Estudio aparte (§7)** |

## 5. Por qué los motores nuevos no entran: cinco muros

1. **Rust.** Gecko (desde la 54) y Servo lo exigen. No existe `powerpc-apple-darwin` oficial; los destinos Apple de 32 bits son
   *tier 3* [V (resultado)] y «Rust nunca ha estado soportado en PowerPC OS X» [V: FAQ de TenFourFox]. `rustc` genera código con
   LLVM y el *backend* PPC de Darwin no está en uso [I]. **Camino indirecto:** `mrustc` (Rust → C → GCC), §5.1: **abre la puerta,
   no la cruza todavía** para algo del tamaño de Gecko.
2. **Sistema.** Los motores de 2024+ asumen APIs de macOS 10.12–10.15 y *toolchains* de la misma época. Sorbet añade
   piezas de 10.6.8, no de 10.12.
3. **JIT en PPC big-endian.** SpiderMonkey tiene el de TenFourFox (32 bits, antiguo) y uno de Kaiser en preparación para
   **POWER9 little-endian**; el big-endian «podría añadirse más tarde» [V (resultado): jitpower, [OSNews](https://www.osnews.com/story/144144/firefox-on-power9-the-jit-of-it/)].
   JSC corre en PPC solo como intérprete [V (resultado)]. V8 sí tiene port ppc64 mantenido por IBM, pero para AIX y Linux.
4. **GPU.** OpenGL 2.1; WebRender y ANGLE piden GL 3.x/ES 3 o Metal [H].
5. **Mano de obra.** El proyecto ya mantiene Blink/V8 sobre una 116 en Intel; sumar un segundo motor en otra
   arquitectura duplicaría el problema D1 de `vision-motor.md`.

### 5.1 Rust por la vía C (`mrustc`) y WebAssembly a C (`w2c2`) — aportación de Titín (20-10)

**`mrustc`** (compilador de Rust alternativo, en C++, que emite C y deja el binario a GCC):
- **Qué dice su README [V: [repositorio](https://github.com/thepowersgang/mrustc)]:** arranca `rustc` (probado hasta 1.90.0, que
  produce una 1.91.1 idéntica; también 1.19, 1.29, 1.39, 1.54 y 1.74); plataforma probada: **x86-64 Linux**; secundarias: macOS x86-64 y
  arm64; **no menciona PowerPC ni big-endian**; **sin comprobador de préstamos** (asume código válido); macros procedurales: **solo
  `derive` personalizado**; «mensajes de error terribles»; C generado «muy feo»; `cargo` a través de `minicargo`.
- **PowerPC [V (resultado)]:** en la lista de MacPorts (dic. 2022) alguien dice que `mrustc` compila en ppc32 y propone la cadena
  `mrustc` → Rust 1.54 → 1.55 → 1.56; hay tickets de MacPorts de un *Portfile* sin fusionar para Leopard
  ([#65942](https://trac.macports.org/ticket/65942), [#64639](https://trac.macports.org/ticket/64639)). Titín cita hilos de MacRumors
  («Rust on macOS PowerPC: Hello World» y «I have fixed Rust for PowerPC via mrustc… works with real apps now»); **no pude abrirlos**
  (el dominio no resuelve desde la nube), así que **lo que afirman no está comprobado por mí**.
- **Lo que permite:** compilar **código Rust propio y crates de tamaño moderado** en el G5 con GCC [I]; y, con ello, bibliotecas en
  Rust (analizadores, codificación de texto, TLS) para proyectos propios.
- **Lo que no garantiza (límites):**
  1. Una cadena de `rustc` construida con `mrustc` **sigue necesitando LLVM** para generar código PPC; en la práctica el compilador
     «de verdad» para PPC sería `mrustc` y no `rustc` [I].
  2. Gecko lleva **cientos de crates**, macros procedurales más allá de `derive`, banderas de `rustc` propias y enlazado con C++; que
     `mrustc` aguante eso **no está demostrado** [H].
  3. Aunque se compilase, **los demás muros no caen** (§5, puntos 2–5): sin JIT para PPC big-endian, OpenGL 2.1 frente a WebRender,
     APIs de 10.12+, C++20 y 32 bits.
- **Veredicto:** **el muro de Rust baja de «imposible» a «posible y sin probar»**; **la recomendación no cambia** (Gecko/Servo siguen
  descartados). Como **línea de largo plazo** (sin horas ni propuesta de trabajo): un motor mínimo escrito en Rust, con crates de análisis
  de HTML/CSS y un intérprete de JS en C, compilado con `mrustc`, sería concebible en el G5 [H]; es un proyecto de años.

**`w2c2`** (WebAssembly → C89):
- **Qué dice su README [V: [repositorio](https://github.com/turbolent/w2c2)]:** traduce módulos Wasm (especificación 1.0, hilos y
  atómicos, memoria en bloque, extensión de signo, conversiones sin trampa; **sin SIMD ni GC** en lo que consta) a C casi C89; lista Mac OS
  X, PowerPC y **big-endian**; acepta GCC viejo; ~7 % más lento que el nativo en Coremark.
- **Para qué sirve:** compilar Rust (o C) a `wasm32` en una máquina moderna y llevar el **C resultante** al G5 [I]. Sirve para **programas y
  bibliotecas de cálculo** (sin red, ventanas ni sistema, salvo las capas que se escriban encima).
- **Para qué no sirve:** **no da WebAssembly a Aquafox**: `w2c2` traduce **por adelantado** un módulo conocido; un navegador recibe módulos
  desconocidos de las webs y necesitaría un intérprete o un compilador en ejecución [I]. Tampoco sustituye al JIT de un motor.
- **Veredicto:** herramienta útil para **llevar código Rust ya escrito a PPC sin tocar el compilador**; **no cambia** el estado del
  navegador. Útil, en su caso, para aislar un componente en una caja de Wasm.

## 6. Renderizado remoto

- **Idea:** el navegador real corre en una máquina potente y el G5 solo muestra la imagen y envía teclas y ratón.
  Compatibilidad = la del navegador del servidor; para FlyWeb, **nivel 131** (o cualquier Chromium/Firefox actual).
- **Opciones:** (a) **FlyWeb en la 7,1** (o en un servidor) con VNC/noVNC; (b) **Neko** (navegador virtual en Docker,
  audio y vídeo por WebRTC, Firefox o Chromium) [V (resultado): [LinuxLinks](https://www.linuxlinks.com/neko-self-hosted-virtual-browser-remote-desktop/)];
  (c) Kasm Workspaces [H]. Un cliente VNC antiguo corre en Leopard [H]; WebRTC en Aquafox no probado.
- **Gana:** compatibilidad total desde el día 1; **cero** mantenimiento de motor en PPC; seguridad (el motor viejo no
  toca las cuentas: cookies y contraseñas quedan en el servidor); aprovecha lo que ya hace FlyWeb.
- **Cuesta:** 8–24 h [H]. Latencia de la LAN (≈ ms) y **decodificar el flujo en el G5**: VNC ZRLE a 1280×800 es
  asumible para dos núcleos de 2 GHz; H.264 a 1080p no [H]. **La pantalla del G5 es de 2560×1440 y la GeForce 6600 LE
  no decodifica vídeo:** hay que pedir al servidor una salida **escalada** (1280×720 o 1600×900) y no el 1440p nativo,
  que cuadruplica los píxeles a decodificar [I]. Sin red no hay navegador. Sonido y portapapeles requieren
  ajustes. Privacidad: **tú** guardas el historial de navegación en el servidor (decisión del proyecto: datos propios).
- **No es** «un navegador moderno para el G5»; es el modo de que el G5 vea la web moderna. Por eso lo propongo como
  **complemento**, no como sustituto.

## 7. Linux en el G5 (variante, fuera del encargo)

El G5 corre Linux ppc64 big-endian (Debian ppc64 no oficial, Void, Adélie, Gentoo) [H]. Allí **sí hay Rust**
(`powerpc64-unknown-linux-gnu`, nivel 2 [V (resultado): rustup-components-history]), así que Firefox ESR 140+ se compila;
sin JIT para PPC (§5, punto 3) iría con el intérprete y el *Baseline Interpreter*, lento en un 970 pero con la
compatibilidad de un Firefox actual. WebKitGTK/WPE iría con C Loop [V (resultado)]. GPU: *nouveau*
para la GeForce 6600 (NV43), con OpenGL 2.1 [H, sin probar en PPC]. **Coste:** instalar Linux (arranque doble) y probar. Enlaza con la idea de «Linux como
nexo» (V10 de `vision-motor.md`). **No lo recomiendo hoy**: abandona Sorbet y el rendimiento sin JIT es incierto;
conviene medirlo antes con un *live* (§9).

## 8. Seguridad (crítica)

- Un motor de 2016 en la web abierta carece de ~10 años de correcciones. En Chromium, ~70 % de los fallos graves son
  de memoria [V (resultado): [chromium.org](https://chromium.org/Home/chromium-security/memory-safety)]; Firefox 45 no
  tiene ninguna de esas correcciones ni los endurecimientos de ESR posteriores [I].
- **El *user agent* moderno** de Aquafox invita a las webs a servir contenido moderno, no a un navegador parcheado.
- El proyecto ya asume este tipo de riesgo con la 116 (`motor.md`: «riesgo asumido»), pero **aquí es mayor** y sin
  vigilancia de CVE.
- **Mitigación sencilla:** en el G5, nada de bancos, correo principal ni cuentas con claves importantes en Aquafox;
  para eso, el renderizado remoto (§6). Dejar JavaScript desactivado por sitio (donde el navegador lo permita) en webs
  desconocidas.

## 9. Recomendación y medición en el G5

**Recomendación:** (1) Aquafox sigue como navegador de uso diario. (2) **Medir PowerFox** con la batería de abajo y
quedarse con el mejor para cada tipo de web. (3) **Montar el renderizado remoto** (FlyWeb en la 7,1 o Neko) para lo que
los dos locales no abran y para cuentas sensibles. (4) No portar ningún motor (§5). (5) Estudiar Linux en el G5 solo si
(2) y (3) no bastan.

**Batería de medición (≈ 3 h en el G5, Titín o LOCAL con acceso):**
1. **Datos de la máquina: hechos (20-10, Titín)**: GPU, `openssl version`, `sw_vers`; **faltan** `gcc` (comprobar
   `ls /Developer/usr/bin /opt/local/bin | grep gcc`) y la versión y arquitectura de Aquafox.
2. **Qué motor es:** `about:support` (o equivalente) en Aquafox y PowerFox: versión de Gecko/Goanna, JIT activo
   (`javascript.options.ion`), WebGL.
3. **Compatibilidad de JavaScript:** tabla de [compat-table de Kangax](https://compat-table.github.io/compat-table/) (ES6,
   2016+, 2017, 2018–2020) en los tres motores (Aquafox, PowerFox, Leopard WebKit); anotar «sí/no» por apartado.
4. **HTML/CSS:** html5test.com y una página propia de CSS (flexbox, grid, variables, `:is()`, `clamp()`).
5. **Veinte webs reales** con resultado «abre / abre mal / no abre»: Wikipedia, GitHub, un periódico, YouTube (en 360p
   y 480p; ¿H.264 o VP9?), un servicio con inicio de sesión moderno, un sitio con Cloudflare, una SPA (React/Vue),
   mapas, foros, comercio.
6. **TLS:** badssl.com (TLS 1.2/1.3, cadenas modernas) y una web con certificado Let's Encrypt reciente. **Además, en el Safari de Sorbet:** abrir `https://www.howsmyssl.com/` y anotar la versión de TLS que
   negocia (decide si el WebKit del sistema abre HTTPS moderno; ver actualización 20-10 (3)).
7. **Rendimiento:** Speedometer 2.1 o JetStream 2 si el motor lo termina (anotar el tiempo); CPU y RAM con el Monitor de
   Actividad.
8. **Remoto:** VNC a 1280×800 (**no a los 2560×1440 de la pantalla**) desde el G5 contra FlyWeb en la 7,1: latencia al escribir y al desplazar, CPU del G5,
   vídeo a 480p.

**Criterio para decidir:** si PowerFox pasa más pruebas de la batería 3–5 que Aquafox, se queda como principal y Aquafox
de respaldo; si no, la ventaja de PowerFox no compensa un proyecto beta.

## 10. Fuentes

- Aquafox: [repositorio](https://github.com/BlackBirdLC/Aquafox), [versiones](https://github.com/BlackBirdLC/Aquafox/releases) [V]; [Arctic Fox PPC (wicknix), archivado](https://github.com/wicknix/AF-OSX-PPC/blob/main/README.md) [V].
- TenFourFox: [FAQ](https://github.com/classilla/tenfourfox/wiki/AAATheFAQ) [V]; [The Register, fin del proyecto](https://www.theregister.com/2021/03/31/tenfourfox_dev_quits/) (resultado).
- PowerFox: [foro de Pale Moon](https://forum.palemoon.org/viewtopic.php?p=273167), [Low End Mac, 2026](https://lowendmac.com/2026/finally-a-properly-modern-browser-for-powerpc-macs/), [MacRumors](https://forums.macrumors.com/threads/powerfox-web-browser-for-mac-os-x-10-6-snow-leopard-10-5-leopard-and-10-4-tiger.2475545/) (resultados).
- UXP/Pale Moon: [roadmap](https://www.palemoon.org/roadmap.shtml), [Neowin 32.2.0](https://www.neowin.net/amp/pale-moon-3220/), [foro sobre WASM](https://forum.palemoon.org/viewtopic.php?p=169524) (resultados).
- Sorbet Leopard: [MacRumors](https://forums.macrumors.com/threads/sorbet-leopard-10-5-reinvigorated-updated.2300924/), [Macintosh Repository](https://www.macintoshrepository.org/39027-sorbet-leopard), [MacPorts-users, jul. 2022](https://lists.macports.org/pipermail/macports-users/2022-July/051291.html) (resultados).
- Leopard WebKit: [SourceForge](https://www.sourceforge.net/p/leopard-webkit/), [MacRumors, encuesta de navegadores PPC](https://forums.macrumors.com/threads/powerpc-web-browser-options-poll.2042792/) (resultados).
- Toolchain: [gcc-help, abr. 2023](https://lists.nongnu.org/archive/html/gm2/2023-04/msg00087.html); [Callahan, GCC 14.2 en Tiger](https://briancallahan.net/blog/20250329.html); [MacPorts #59268](https://trac.macports.org/ticket/59268); [RFC 2837 de Rust](https://www.ncameron.org/rfcs/2837.html) (resultados).
- JIT en Power: [jitpower](https://github.com/classilla/jitpower); [OSNews](https://www.osnews.com/story/144144/firefox-on-power9-the-jit-of-it/); [Red Hat, V8 en Power](https://developers.redhat.com/articles/2021/12/09/how-nodejs-uses-v8-javascript-engine-run-your-code); WebKit: [bug 103128](https://bugs.webkit.org/show_bug.cgi?id=103128), [bug 128743](https://bugs.webkit.org/show_bug.cgi?id=128743), [webkit-dev, feb. 2017](https://lists.webkit.org/pipermail/webkit-dev/2017-February/028754.html) (resultados).
- Rust en PPC (aportación de Titín): [mrustc](https://github.com/thepowersgang/mrustc), [w2c2](https://github.com/turbolent/w2c2); MacPorts: [lista de desarrollo, dic. 2022](https://lists.macosforge.org/pipermail/macports-dev/2022-December/044860.html), [#65942](https://trac.macports.org/ticket/65942), [#64639](https://trac.macports.org/ticket/64639) (resultados); hilos de MacRumors citados por Titín (no abiertos).
- NetSurf: [Wikipedia](https://en.wikipedia.org/wiki/NetSurf), [OSNews, 3.11](https://www.osnews.com/story/138159/netsurf-3-11-released/) (resultados). Neko: [LinuxLinks](https://www.linuxlinks.com/neko-self-hosted-virtual-browser-remote-desktop/) (resultado).
- Proyecto: `vision-motor.md` (V10, V11, D1), `motor.md` («riesgo asumido»), `docs/TAREAS.md` (FM.27, fila de INVESTIGACIÓN-MOTOR).

## 11. Pendiente

- Abrir las fuentes «(resultado)» con red completa; **confirmar con el autor de Aquafox** si el motor recibe parches de
  seguridad de ESR más allá de las listas.
- ~~Datos que solo Titín tiene~~: llegados el 20-10 (GPU, OpenSSL, `sw_vers`). **Faltan:** `gcc` (¿hay Xcode en `/Developer`?),
  versión y `file` de Aquafox, y **qué TLS usa el Safari de Sorbet** (§9 punto 6).
- ¿PowerFox admite el 970 en 64 bits o solo 32? ¿Hay compilación específica para G5?
- Verificar Linux ppc64 BE: qué distribución trae hoy Firefox ESR y con qué JIT (§7).
- **Rust por `mrustc`:** comprobar con los hilos de MacRumors qué versión de Rust, qué *target* y qué aplicaciones reales compilan; si aguanta crates grandes con macros procedurales; y si hay una cadena que llegue a una versión de `rustc` reciente.
- Si se sigue adelante con §6: probar Neko y VNC contra FlyWeb 1.15 en la 7,1 (desde el G5).
