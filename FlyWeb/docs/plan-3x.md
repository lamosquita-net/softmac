# FlyWeb 3.x: cómo avanzar después de la 3.0.0

ARQUITECTURA, 08-11-2026. Encargo de COORDINACIÓN-34 (buzón `20261107-2220`) por orden de Titín. **Solo papel.**
Marco: directiva «Versiones desde la 3.0.0» (Titín, 07-11; `docs/DIRECTIVAS.md`): el **segundo dígito** (3.1, 3.2…)
son nuestros avances, el primero rendimiento; el **tercero** (3.0.1, 3.0.2…), tandas de seguridad al ritmo de Chrome
estable más arreglos. claude.ai es el criterio de aceptación de cada versión. Sin horas: hitos y criterios. Decide Titín.

Marcas: **[V]** verificado en el repo (fichero citado); **[I]** inferencia mía; **[N]** no comprobado. Rutas relativas a
`FlyWeb/docs/` salvo que se diga otra cosa. Fuentes de detalle: cuatro lecturas de subagentes sobre `origin/main` 4708fe52
(rendimiento, seguridad, riesgos, base), citadas por fichero:línea.

## 1. Conclusión

1. **La 3.1 no «introduce» el rendimiento: lo exprime.** PGO y la GPU por Metal (B1d) ya van en la 3.0.0 [V:
   `TAREAS.md:246`, `pruebas-gpu.md:42,143`]. Lo que queda de la directiva son tres cosas medibles: quitar el parón de
   primera carga de Metal (compilación síncrona de pipelines, ×20 al crear programas), comprobar si el perfil de PGO de
   Google perjudica las rutas que solo usa Mojave (Ganesh GL y ANGLE Metal frías al 100 % y al 55 %), y decidir Maglev
   con las tres condiciones de B6, que la 3.0.0 **no** cumplió antes de salir. Hilos y varias GPU son investigación con
   expectativa baja y se abren después, con perfil antes que código.
2. **Antes de cualquier 3.1, una línea base de la 3.0.0** en la 6,1 y la 5,1 con los mismos cuatro números (Speedometer
   3.1, JetStream 3, MotionMark 1.3.2, Aquarium) y una medida repetible de claude.ai. Hoy la 5,1 no tiene Speedometer
   ni JetStream de ninguna versión, la 6,1 no los tiene de la 3.0.0, y claude.ai solo se prueba a mano [V:
   `investigacion-pendiente.md:12`, `relevo-local.md:351`]. Sin línea base no hay avance que se pueda aceptar ni rechazar.
3. **Seguridad y avances, en dos líneas de git y una sola versión mantenida.** Las 3.0.x se cortan sobre la última
   publicada y solo llevan seguridad y arreglos; la 3.1.0 nace de la punta de desarrollo e incluye todo lo anterior;
   publicada la 3.1.0, no hay más 3.0.x (como Chrome). La medida mensual de «entran limpios» se define en una sola unidad
   (commit de upstream localizado que nos afecta) y separando lo que Google aún fusiona a la rama 156 de lo que solo
   está en ramas posteriores: noviembre da **85 %** en total pero **64 %** en el segundo grupo, que es la cifra real de
   partida [V: `seguridad-3.0.1.md:129-135`].
4. **Otra base: no por calendario, y con un techo de hardware a la vista.** Xcode 27 y posteriores son solo ARM; los
   anfitriones Intel compilan `main` (159) con un Xcode 26 universal y SDK 26.5 [V: `base-siguiente.md:40-44`, del
   comentario de `mac_sdk.gni`]. El día que Chromium exija el SDK 27 (`macos11-niveles.md:19` lo sitúa en la 158;
   `base-siguiente.md` lo marca como inferencia), la 7,1 (Intel) deja de poder compilar la base nueva. Eso cambia la
   pregunta: no es solo «cuándo subimos», sino «cuánto aguanta la 156 y qué haría falta para compilar una base que pida
   Xcode 27». Propongo umbrales de seguridad (§4), vigilar `mac_sdk.gni` cada mes, y pido a Titín la decisión sobre la
   máquina de compilación antes de que haga falta.
5. **Dos riesgos que hay que cerrar en la 3.0.1, no en la 3.1:** el prefijo de `CFBundleVersion` (198.63) sale del
   `package.json` de Brave; cuando brave-core desaparezca (opción B), un error silencioso dejaría a todas las Mac instaladas
   sin actualizaciones para siempre [V: `tweak_info_plist.py:46-61`]. Y nadie vigila KEV entre tandas (VIGÍA pausada,
   SEGURIDAD-PORTES sin sesión entre encargos) pese a la directiva de «críticos y KEV en cuanto salgan» [V: `TAREAS.md:12,20`].
   Sparkle 2 es una migración planificable (admite Mojave), no una urgencia.

## 2. Contenido y orden de la 3.1, 3.2…

### 2.1 Lo que ya sabemos medir y lo que no

| Medida | 6,1 (Mojave, D500) | 5,1 (RX 580, sin AVX) | 7,1 (Sequoia, Graphite) | Fuente |
|---|---|---|---|---|
| MotionMark 1.3.2 | 3.0.0 Metal **1381** (60 fps); 2.7.0 GL 566 | 3.0.0 **864** ±2,8 % | 3.0.0 PGO 3576; Chrome 156 3861 | `pruebas-gpu.md:42,143`; `coordinacion.md:203` |
| Speedometer 3.1 | 2.7.0 **5,84**; 3.0.0 sin medir | **ninguna** | 3.0.0 PGO 20,6; Chrome 156 20,7–21,0 | `coordinacion.md:426,203`; `comparativa-71.md:7-16` |
| JetStream 3 | 2.7.0 **89,3**; 3.0.0 sin medir | **ninguna** | 3.0.0 160,7 (sin PGO) | ídem |
| Aquarium 5k/10k/15k | 60/54/37 (3.0.0) frente a 60/44/30 (2.7.0) | 60/40,9/– | — | `b1d/README.md:31`; `pruebas-gpu.md:142` |
| Crear 500 programas WebGL | **22 s** Metal frente a 1 s GL | sin medir | — | `b1d/README.md:74` |
| claude.ai | sí/no a mano (Titín) | ídem | ídem | `relevo-local.md:351` |

La 7,1 mide con Graphite y no sirve de objetivo [V: `comparativa-71.md:4-5`]. El A/B de PGO en la 6,1 (+42 % Speedometer,
+9 % JetStream, +21 % MotionMark) consta solo como porcentajes en `coordinacion.md:122`, sin valores absolutos ni fichero, y
`b1d/pgo-mojave.md` avisa de que no fue A/B limpio. **No se puede planificar rendimiento sobre esto.**

### 2.2 Hito 0: línea base (dentro del ciclo 3.0.x, no es una versión)

- **Qué:** los cuatro benchmarks servidos en local (sin red) en la 6,1 y la 5,1 con la 3.0.0 publicada, tres pasadas,
  mediana y dispersión; mismo guion para cada candidata después. Más dos medidas de claude.ai que no dependan de hCaptcha:
  tiempo hasta primer renderizado de una conversación guardada en local (HAR reproducido o copia estática) y p95 del
  intervalo entre fotogramas al desplazar 500 mensajes. Se guarda en `FlyWeb/docs/rendimiento-3x.md` (tabla única, pedida
  desde `investigacion-pendiente.md:12`).
- **Hito:** la tabla existe para la 3.0.0 en las dos Mac, y el guion corre desde la 7,1 por ssh en la 6,1 (banco de
  pruebas, `DIRECTIVAS.md:310`). La 5,1 se mide cuando Titín puede; no bloquea (memoria `feedback-5-1-no-bloquea`).
- **Quién:** LOCAL (guion y medidas), con el criterio de aceptación de Titín para claude.ai: la prueba manual sigue siendo
  la definitiva; las dos medidas son para detectar regresiones antes de molestarle.

### 2.3 Avances, por orden propuesto

| # | Avance | Qué se gana | Coste | Riesgo | Dónde se mide | Aceptación |
|---|---|---|---|---|---|---|
| **A** | **Metal sin parón de primera carga**: compilar pipelines fuera del hilo de render o precalentar los más comunes; recuperar la caché persistente de programas (`GpuPersistentCache` va desactivada, `TAREAS.md:317`) | Parón de 0,9–1,5 s en primera carga y 22 s/500 programas → objetivo ≤ 2 s [V: `b1d/README.md:64-81`]; Shadertoy Elevated 33–58 → 60 | Medio: interior de ANGLE Metal; `MTLBinaryArchive` es de macOS 11, hay que hacerlo a mano | Medio: la 5,1 tiene otra GPU; regresiones de estabilidad en drivers de 2018 sin pruebas de Google (`metal-mojave.md:11`) | 6,1 y 5,1; batería `pruebas-gpu.md` | Sin caídas en la batería; parón ≤ 0,2 s; MotionMark ≥ línea base; claude.ai |
| **B** | **PGO afinado para Mojave**: primero el A/B barato (quitar PGO a Ganesh/ANGLE, `-pgso=false`), después, solo si compensa, perfil propio recogido en la 6,1 | Desconocido en Mojave. En la 7,1 PGO dio +25 % Speedometer [V: `coordinacion.md:203`]; el perfil de Google tiene frías las rutas de Mojave [V: `b1d/pgo-mojave.md:103-108`] | A/B: una Release por variante. Perfil propio: build instrumentada + recogida + fusión, **y rehacerlo en cada subida de base** (`pgo-mojave.md:188-223`) | Bajo el A/B; alto el perfil propio (mantenimiento) | 6,1 (A/B limpio: mismo commit, mismo día, red local) | ≥ 5 % en Speedometer o MotionMark sin perder en el otro; si no, se queda el perfil de Google |
| **C** | **Maglev** (B6): (1) mjsunit con Maglev en verde en d8 (D8-LINUX); (2) Speedometer y JetStream con y sin Maglev en 6,1 **y** 5,1 sin pérdida; (3) sin AVX sin despacho en la 5,1 (`otool`) [V: `DIRECTIVAS.md:288-292`] | Fuente publicada: el blog de V8 anunció Maglev con mejoras de un dígito en JetStream y Speedometer en escritorio [N: cifra exacta a confirmar]. Único dato nuestro: 2.1.1 +3 % Speedometer y **JetStream colgado 5/5** [V: `coordinacion.md:722`] | Bajo: es un interruptor; el coste es medir y, si cuelga, depurar | Medio: cuelgue de la 2.1.1; la V8 de la 156 ya trae sus arreglos de seguridad (`DIRECTIVAS.md:289`), así que la deuda de FS.28 desaparece | d8 Ubuntu; 6,1; 5,1 | Las tres condiciones; si falla una, sigue apagado y se anota |
| **D** | **Hilo de CPU del proceso de GPU** (FM.56, fase 1): perfil con `sample` por fotograma, después repartir contextos/`DrawCommandRange` entre hilos | Desconocida. El límite medido en la 6,1 es ese hilo, no la GPU [V: `b1d/README.md:41`]; con WebGL en la segunda D500 Aquarium no cambia | Alto: código de Chromium y ANGLE sin donante | Alto: ningún navegador lo hace así (`vision-motor.md:156-163`, V20 «expectativa baja») | 6,1 (perfil), 7,1 | **Hito previo obligatorio:** perfil publicado que diga dónde se va el tiempo; sin él no se escribe código |
| **E** | **Varias GPU** (FM.56, fase 2) | Desconocida; V21 «descartar» antes de la directiva | Muy alto | Muy alto | 6,1 (dos D500), 7,1 (hasta cuatro) | Solo después de D y con dato de D |
| **F** | **Sparkle 2** (plataforma, no rendimiento) | Dejar un actualizador sin mantenimiento desde 2023 [V: `DEPS:14`]; instalador en proceso aparte; FlyWeb ya firma EdDSA | Medio: reescribir `browser/mac/sparkle_glue.mm` y el empaquetado de `build/mac/BUILD.gn` sin donante (Brave sigue en 1.24) | Medio: una actualización rota deja a los usuarios en la versión anterior; se prueba con canal aparte | 7,1, 6,1, 5,1 (actualización real con la FlyWeb de Titín cerrada) | Actualiza desde la 3.N−1 en las tres Mac y mantiene la exigencia de Developer ID |
| — | OpenGL de comparación (B1c) | Solo referencia: ya está medida (2.7.0 GL frente a 3.0.0 Metal) | Una oficial de ~3 h si se reabre | — | — | **No se compila**; se reabre solo si la 5,1 falla con Metal (`DIRECTIVAS.md:297`) |

**Orden propuesto y agrupación.** Cada 3.N lleva como mucho dos avances, para poder atribuir una regresión:

- **3.1 = A + B(A/B) + decisión de C.** Metal sin parón es lo que más nota el usuario y lo que más se aleja hoy de Chrome;
  el A/B de PGO es barato y responde la duda del perfil frío; Maglev se decide con las tres condiciones y entra encendido
  solo si pasa. Hito de la 3.1: línea base superada en los cuatro números en la 6,1, igual o mejor en la 5,1, claude.ai
  aprobado por Titín.
- **3.2 = C (si quedó pendiente) + D fase de perfil + B perfil propio (si el A/B lo justificó).**
- **3.3 = F (Sparkle 2) + D código (si el perfil lo justifica).** E queda como investigación sin versión asignada.

Lo que **no** entra como avance: WebGPU (es Dawn sobre Metal 2.1 en 10.14, trabajo de base, no de versión; sigue apagado por
CVE-2026-5281, `DIRECTIVAS.md:20`) y Containers (decisión de producto, §5.3).

## 3. Cómo convive con la seguridad

### 3.1 Ramas y cadencia

- **Punta de desarrollo** (hoy `flynk-b1d` en el fork y `nube/b2-porte-t11` en brave-core; con la opción B, una sola rama
  `flynk`): ahí entran los avances, cada uno en `avance/<tema>` y fusionado solo con su A/B hecho.
- **Línea de seguridad** `seg/3.0.N`: se corta sobre el **tag de la última publicada**, lleva solo seguridad (`Flynk-Class:
  security`) y arreglos de fallos (`Flynk-Class: fix`), nada de avances. Cada tanda se fusiona también a la punta.
- **Una sola versión mantenida.** Publicada la 3.1.0, no se publican más 3.0.x; la siguiente tanda es la 3.1.1. Esto
  mantiene la regla de la 2.x «no sacar versión de seguridad que la siguiente vaya a sustituir» (`DIRECTIVAS.md:99-101`):
  si la 3.1.0 está lista para compilar, la tanda entra en ella.
- **Cadencia:** Chrome estable publica cada semana; nuestra tanda ordinaria agrupa 2–4 semanas (directiva). **KEV o crítico
  explotado:** ≤ 48 h desde el aviso hasta la versión (`docs/SEGURIDAD.md:21`), con el interruptor de JIT como medida
  provisional si no llega a tiempo.

### 3.2 Quién compila qué: la 7,1 es el cuello de botella

Solo la 7,1 compila la 156 (la 6,1 no puede, `DIRECTIVAS.md:311`) y solo una compilación a la vez (`DIRECTIVAS.md:186-188`).
La única regla de prioridad escrita es de la 2.x («la 7,1 compila primero el nivel de MOTOR», `DIRECTIVAS.md:154`). Propongo:

1. **Una tanda KEV/crítica desplaza a cualquier compilación de avance.** LOCAL para el ninja del avance, compila la Release
   de seguridad, publica, y reanuda el avance (ninja es incremental; con dos directorios de salida, `out/Release` para
   seguridad y `out/Avance` para avances, no se pierde lo compilado: cuesta disco, lo valora LOCAL).
2. **Una tanda ordinaria se compila en hueco**: cuando no haya A/B de avance en curso, o al cerrar el que haya.
3. **Los A/B de avances se compilan en la 7,1 y se miden en la 6,1 y la 5,1** por ssh desde la 7,1 mientras esta compila
   lo siguiente (uso de la 6,1 como banco, `DIRECTIVAS.md:310-313`).
4. **D8-LINUX pasa mjsunit a todo lo que toque V8**, sea seguridad o avance (Maglev), antes de LOCAL.
5. Todo cambio de V8 sube la época de caché; en la 156 va en `v8_embedder_string`, no en un parche (ARQUITECTURA, 07-11,
   comentario en el PR #790).

### 3.3 La medida mensual de «cuántos entran limpios»

Las cifras de hoy no son comparables entre sí: B0 cuenta CVE, la 3.0.1 commits, la clase D de la 128 ficheros, y la tasa de
rechazo de V8 mide lo contrario (nuestros parches sobre la V8 nueva) [V: `b0-cve.md:91-99`, `seguridad-3.0.1.md:129`,
`seguridad-128.md:396-452`, `fork-propio.md:61-73`]. Definición propuesta, que SEGURIDAD-PORTES puede corregir:

- **Unidad:** commit de upstream (Chromium, V8, ANGLE, Skia, Dawn, PDFium, ffmpeg) que arregla un CVE alto o crítico que nos
  alcanza y que se ha localizado. Los no localizados y los N (no nos afectan) se cuentan aparte, no en el denominador.
- **Clases:** A (aplica limpio: `cherry-pick` sin conflicto y compila a la primera), F (aplica con fuzz), X (conflicto o a
  mano). **Medida = A / (A + F + X)**, y también (A + F) / (A + F + X).
- **Dos grupos siempre separados:** grupo 1, commits que Google fusiona a la rama de nuestra base (mientras la 156 esté
  en Extended Stable); grupo 2, los que solo están en ramas posteriores. El grupo 1 desaparecerá solo; el grupo 2 es el
  que mide la deuda de base.
- **Anotar la distancia:** hitos de Chrome publicados desde la base y meses desde la publicación de la 3.0.0.
- **Dónde:** una tabla por tanda en `seguridad-3.0.N.md` y una fila por mes en `docs/SEGURIDAD.md`.

Noviembre de 2026, con esa definición: **85 %** en total (79/93), **100 %** en el grupo 1 (49/49), **64 %** en el grupo 2
(23/36; 83 % con fuzz) [V: `seguridad-3.0.1.md:129-130,189-191`]. Fuera del denominador: 121082 (parser de V8, 21 commits aparte)
y tres críticos no portados; conviene que SEGURIDAD diga en cada tanda cuántos críticos quedan fuera y por qué.

### 3.4 Huecos que esta convivencia no tapa

- **Vigilancia de KEV entre tandas.** VIGÍA está pausada desde el 23-10 y SEGURIDAD-PORTES se archiva entre encargos
  [V: `TAREAS.md:12,20`]. La directiva pide «críticos y KEV en cuanto salgan». Hace falta una rutina diaria barata (Haiku) que
  lea `cisagov/kev-data` y Chrome Releases y despierte a COORDINACIÓN. Es decisión de COORDINACIÓN y Titín; lo anoto como riesgo.
- **Reloj de LOCAL por tanda.** No hay cifra de cuánto tarda una tanda completa de la 156 en la 7,1 (la 128 tardaba 2 h 40 por
  Release, `TAREAS.md:301`; la 156 con PGO, sin cifra). Pido que cada tanda anote su reloj en `CONSUMO.md`.
- **Overrides muertos.** Tras el salto de base, overrides de `chromium_src` que ya no aplican compilan sin error
  [V: `RELEVO-SEGURIDAD.md:502-520`]; `check-overrides-156.sh` debe correr en cada tanda, no solo en el porte.

## 4. Cuándo hace falta otra base

### 4.1 La referencia: qué pasó con la 128

| Dato | 128 (medido 18–22 hitos después) | 156 (medido a 0–1 hito) | Fuente |
|---|---|---|---|
| Arreglos críticos que aplican limpios | **15 %** (3 de 20; intervalo 5–36 %); 50 % con conflicto | 64 % grupo 2; 85 % total | `b0-cve.md:91-101`; `seguridad-3.0.1.md:129` |
| CVE altos/críticos acumulados sin portar | 750 (611 alcanzables, 99 críticos) | 3 críticos fuera | `cve-128-no-explotados.md:11`; `seguridad-3.0.1.md:191` |
| Nuestros parches de V8 rechazados al subir nivel | 9,8 % (137) → 17,5 % (138) | no aplica (sin niveles) | `fork-propio.md:69-73` |
| Bloques de Blink aplazados por refactor ausente | 1 → 2 → 4 → 5 por nivel | 0 | `base-siguiente.md:95-104` |
| Distancia a `main` | 31 hitos | 3 hitos | `base-siguiente.md:91,136` |

La 128 nunca tuvo medida mensual: el 15 % se midió de golpe y tarde. La proporción **cae con la distancia**, así que el
umbral debe leerse junto a los meses desde la base, y la curva real solo la dará la medida mensual de §3.3.

### 4.2 Umbrales propuestos (para que Titín los fije o los cambie)

Se mide cada mes. Dos señales de seguridad y tres de plataforma:

| Señal | Estudio (ARQUITECTURA prepara datos) | Propuesta de salto a Titín |
|---|---|---|
| S1 · % limpio del **grupo 2** (A, sin fuzz) | < 50 % dos meses seguidos | < 35 % dos meses seguidos (la 128 estaba en 15 %) |
| S2 · Críticos alcanzables **no portables** acumulados (X que no se consigue adaptar, o N por falta de código) | ≥ 5 | ≥ 10, o 1 explotado en la práctica (KEV) sin arreglo posible |
| P1 · Google retira de Mac algo de lo que dependemos (como pasó con GL en la 156 sin que saltara la señal escrita, `base-siguiente.md:50`) | en cuanto se vea en `main` | cuando llegue a estable |
| P2 · Chromium sube el mínimo a macOS 14 (previsto hacia mediados de 2027 [I], `base-siguiente.md:129-132`) | al anunciarse | según el tamaño de la capa Mojave que haría falta (la 156 necesitó 741 avisos, 48 ficheros, 13 rondas, `TAREAS.md:317`) |
| P3 · El compilador o el SDK que exige la base dejan de correr en nuestras Mac (Xcode 27+ es solo ARM; `mac_sdk.gni` de `main` se mira cada mes) | en cuanto `main` exija SDK 27 en Intel | antes de que esa exigencia llegue a la base que se quiera tomar (§4.3) |

Antes de proponer un salto, **el ensayo de rebase (B3/F5) es obligatorio**: nunca se ejecutó y la puerta 128 → 156 se
decidió sin esa medida [V: `fork-propio.md` §6, `base-siguiente.md:206`]. Su resultado (conflictos por `Flynk-Class` y por
directorio) es la cifra real del coste.

### 4.3 El techo de hardware

Xcode 27 y posteriores son solo ARM; los anfitriones Intel usan un Xcode 26 universal [V: `base-siguiente.md:43-44`, citando
`mac_sdk.gni` de `main`]. La 7,1 compiló la 156 con Xcode 26.3 y SDK 26.2 [V: `TAREAS.md:317`]; `main` (159) aún se compila
en Intel con Xcode 26.6 y SDK 26.5. `macos11-niveles.md:19` sitúa el SDK 27 en la 158, lo que no cuadra con el 26.5 de `main`
(159): la fecha exacta en que Chromium exigirá SDK 27 en Intel **no está clara** y hay que vigilarla, no darla por hecha. Lo que
sí es seguro:

- **Cuando llegue, sin una máquina ARM no habrá base nueva.** Ese salto no sería de código, sino de taller: un Mac con Apple
  Silicon solo para compilar (el producto sigue siendo Intel; Titín excluyó Apple Silicon como destino, no como herramienta),
  o estudiar la compilación cruzada desde Linux, que Chromium no mantiene para Mac [N]. La ventana de bases compilables en
  Intel puede cerrarse en 2027, y una base se tarda semanas en traer: conviene decidir con margen.
- Mientras tanto, la 156 es una **rama de soporte largo de hecho**, y el plan de este documento está pensado para que
  aguante: seguridad por backports, avances propios, y los umbrales de §4.2 como aviso, no como automatismo.

Esto es lo primero que debería decidir Titín (§6), porque condiciona el sentido de medir «cuándo otra base».

## 5. Riesgos conocidos

### 5.1 Sparkle 1.24.3

- Binario precompilado del fork `brave/Sparkle` fijado en enero de 2023; Brave 1.98 sigue en 1.24.4 y tampoco ha pasado a
  Sparkle 2 [V: `DEPS:14`, `relevo-motor.md:318-325`]. Las Release **sí** van firmadas con Developer ID y notarizadas
  [V: `docs/estado.md:16-17`]; sin firmar van solo las de prueba. Sparkle exige que el Developer ID de la actualización sea el
  instalado: **si el certificado cambia, todas las Mac se reinstalan a mano** [V: `servidor/actualizaciones/README.md:60`].
  Nadie vigila la caducidad del certificado.
- En la 3.0.0 el registro de Sparkle se perdió sin error de compilación y hubo que reponer `BraveBrowserMainPartsMac`
  [V: `relevo-motor.md:78-79`]: cada cambio de base puede volver a soltarlo. La prueba de actualización real debe ser
  obligatoria en cada 3.N.0 (en las tres Mac, con la FlyWeb de Titín cerrada).
- Sparkle 2.x: instalador en proceso aparte, XPC opcional sin sandbox, DSA eliminado (ya firmamos EdDSA), mínimo macOS 10.13
  desde la 2.6 **[N: a confirmar]**: Mojave entraría. Coste: reescribir `sparkle_glue.mm` y el empaquetado sin donante.
  Va como avance F (§2.3), no como seguridad.

### 5.2 CFBundleVersion 198.63.N

- `tweak_info_plist.py` compone `CFBundleVersion = (major·100+minor).build.N` a partir de la versión de Brave en
  `package.json` (1.98.63 → 198.63) y de `FLYWEB_BUILD_NUMBER` [V: `tweak_info_plist.py:46-61`]. La 3.0.0 lleva el 41
  [V: `TAREAS.md:15`]. Sparkle compara componente a componente y **nunca baja**; el firmador de bak rechaza un número igual o
  menor, pero después de compilar y notarizar [V: `firmar-actualizacion.mjs:118`].
- **Riesgo real:** con brave-core fuera (opción B), si `package.json` desaparece o su `major` deja de ser ≥ 1, el script no
  entra en la rama de Brave y queda el CFBundleVersion de Chromium (estilo `8078.90`), menor que 198.63: ninguna Mac instalada
  volvería a actualizarse. `build.sh` no comprueba nada y su mensaje sigue diciendo «157.64 / 169.168» [V: `build.sh:272`].
- **Cierre, en la 3.0.1:** argumento de GN propio `flyweb_bundle_version_base = "198.63"`, congelado para siempre y usado
  por `tweak_info_plist.py` en vez de la versión de Brave; `build.sh` lee `web/VERSION` y para si `FLYWEB_BUILD_NUMBER` no es
  mayor que el último publicado; la regla, escrita en `servidor/actualizaciones/README.md`. Es un cambio de build, sin riesgo
  de producto, y hay que hacerlo **antes** de tocar brave-core.

### 5.3 Lo pendiente de la 3.0.x en la fila de MOTOR

| Pendiente | Qué es | Dónde debe ir | Dueño |
|---|---|---|---|
| `nube/b2-tests` (148a5939c8) | Enlace de `brave_unit_tests`/`brave_browser_tests` en la 156 **y** la guarda de `sparkle_glue.mm` (`--test-type` o sin CFBundleVersion → `SUNoVersionException`), que es código de producción en una rama de tests y **no está probada en Release** [V: `relevo-motor.md:16`] | 3.0.1, con prueba de actualización real | MOTOR; prueba LOCAL |
| `nube/b2-depfile` (bbfb565048) | `preprocess_if_expr.py` no escribía el depfile con `--in-files` vacío | 3.0.1 | MOTOR |
| `nube/b2-redirect-cc` (58be92043) | Fuera `redirect_cc`/siso; envoltorios `.cc` al esquema de 1.98. Cada `#define` puede dejar de aplicar **sin error** [V: `brave-propio.md:559`] | 3.0.1, con `check-overrides-156.sh` en verde y revisión de SEGURIDAD de los envoltorios que apagan cosas | MOTOR, SEGURIDAD-PORTES |
| Panel de Shields | Existe en t11; faltan los cambios de 1.98 y **no está escrito qué le falta** ni si la 3.0.0 lo muestra bien [V: `relevo-motor.md:185`] | 3.0.2, tras una ficha que diga qué falta | MOTOR; diseño, Titín |
| `UpdateTargetURL`, restos de IPFS/Tor, `chrome_logo_dark.svg` | Menores | 3.0.2 | MOTOR |
| WebGPU | Permiso/farbling de Brave pendiente; WebGPU apagado por CVE-2026-5281; Dawn sobre Metal 2.1 en 10.14 sin comprobar [V: `brave-propio.md:830-831`] | **No es un pendiente de la 3.0.x**: es trabajo de base. Sigue apagado | Decisión de Titín si algún día se abre |
| Containers | Perfiles-contenedor de Brave con farbling por contenedor; no hay nada en t11 | **Decisión de producto**; propongo **no**: no es privacidad base de Shields y es superficie nueva | Titín |

Crítica: la fila mezcla deuda de build, código de producción sin probar y decisiones de producto sin dueño ni orden. Cada
uno debería tener ficha propia en `TAREAS.md` con la versión en la que entra.

### 5.4 Otros riesgos que conviene tener delante

- **Una sola máquina compila la 156.** Si la 7,1 falla, no hay versión de seguridad posible hasta repararla o sustituirla.
  La 6,1 no puede ayudar. Esto, junto al techo de Xcode 27 (§4.3), es el riesgo estructural del plan.
- **El coste del salto 128 → 156 no está medido** (sin horas ni reloj; en `CONSUMO.md` solo MOTOR-32 anota dólares) [V:
  informe de base]. Para el próximo salto, el ensayo de rebase y el reloj de LOCAL son obligatorios desde el primer día.
- **`DIRECTIVAS.md:9` conserva «la 128 es la última base que tomamos de fuera»** pese a la puerta del 04-11; conviene
  retirarla para que nadie la cite.

## 6. Qué cambia para cada agente y qué decide Titín

### 6.1 Agentes

- **LOCAL:** hito 0 (guion de línea base servido en local, medidas de la 3.0.0 en la 6,1 y la 5,1, dos medidas de claude.ai);
  A/B de avances con la 6,1 como banco; prueba de actualización real en cada 3.N.0; reloj por tanda en `CONSUMO.md`; dos
  directorios de salida si lo ve viable (§3.2).
- **MOTOR:** cierre de la 3.0.1 (§5.3: tests con la guarda de Sparkle probada, depfile, redirect-cc con `check-overrides`);
  `flyweb_bundle_version_base` (§5.2); avance A (Metal sin parón) con hito previo de perfil del parón; avance D solo después
  de su perfil.
- **SEGURIDAD-PORTES:** la medida mensual con la definición de §3.3 (o su corrección), por tanda y por mes; lista de críticos
  fuera del denominador con motivo; `check-overrides-156.sh` en cada tanda; valoración de Sparkle 2 (mínimo real, XPC) antes
  del avance F.
- **D8-LINUX:** mjsunit con y sin Maglev para la V8 de la 156 (condición 1 de C) y para cada tanda que toque V8;
  `v8_embedder_string` en sus gn args, por coherencia.
- **COORDINACIÓN:** una ficha por pendiente de §5.3 en `TAREAS.md`; la regla de prioridad de compilación (§3.2) en
  `DIRECTIVAS.md` si Titín la acepta; decidir cómo se vigilan KEV entre tandas (§3.4); retirar la frase de `DIRECTIVAS.md:9`.
- **ARQUITECTURA:** revisar cada mes la tabla de §3.3 contra los umbrales de §4.2 y avisar cuando toque estudio; preparar el
  ensayo de rebase (B3) cuando se acerque una señal.

### 6.2 Decisiones de Titín

1. **El techo de hardware (§4.3):** aceptar que la 156 es la rama de soporte largo y decidir, con margen, qué se hace el día
   que la base siguiente exija Xcode 27: máquina ARM para compilar, compilación cruzada por estudiar, o quedarse en la 156.
   Es la decisión que da sentido a las demás.
2. **Orden de las 3.N (§2.3):** 3.1 = Metal sin parón + A/B de PGO + decisión de Maglev; 3.2 = Maglev/perfil del hilo de
   GPU/perfil propio de PGO; 3.3 = Sparkle 2 + hilos. O cambiar el orden.
3. **Criterio de aceptación de claude.ai:** la prueba manual de Titín sigue siendo la definitiva; las dos medidas de §2.2 se
   usan para detectar regresiones. Umbral de las dos medidas: lo pone Titín cuando exista la línea base.
4. **Umbrales de §4.2** (S1 50/35 %, S2 5/10 críticos) o sus cifras.
5. **Prioridad de compilación (§3.2):** una tanda KEV desplaza a cualquier avance; las ordinarias, en hueco.
6. **Containers: no** (propuesta). **WebGPU:** sigue apagado y fuera de la 3.x.
7. **`flyweb_bundle_version_base = "198.63"` en la 3.0.1** antes de tocar brave-core (propuesta: sí, sin esperar).

## 7. Fuentes y límites

- Directivas: `docs/DIRECTIVAS.md` (05-11 noche y 07-11), `docs/TAREAS.md` (filas MOTOR, LOCAL, SEGURIDAD-PORTES, D8-LINUX).
- Rendimiento: `pruebas-gpu.md`, `b1d/README.md`, `b1d/pgo-mojave.md`, `comparativa-71.md`, `coordinacion.md`, `relevo-local.md`,
  `metal-mojave.md`, `vision-motor.md`, `hardware.md`, `investigacion-pendiente.md`.
- Seguridad: `seguridad-3.0.1.md`, `b0-cve.md`, `cve-triage.md`, `cve-128-no-explotados.md`, `seguridad-128.md`,
  `docs/SEGURIDAD.md`, `docs/RELEVO-SEGURIDAD.md`, `docs/CONSUMO.md`, `gl-150-156-seg.md`.
- Riesgos: brave-core `DEPS`, `build/config.gni`, `build/mac/tweak_info_plist.py`, `browser/mac/sparkle_glue.mm`;
  `FlyWeb/scripts/build.sh`; `FlyWeb/servidor/actualizaciones/README.md`; `relevo-motor.md`; `brave-propio.md`.
- Base: `base-siguiente.md`, `fork-propio.md`, `plan-fork.md`, `brave-propio.md`, `b2-poda.md`, `macos11-niveles.md`,
  `legacy-evolucion.md`, `chromium-legacy.md`, `g5-viabilidad.md`.
- Límites: nada compilado ni medido en esta sesión; las cifras de Sparkle 2 y la del blog de V8 sobre Maglev están sin
  comprobar [N]; los umbrales de §4.2 son propuestas para que Titín los fije, no medidas.
