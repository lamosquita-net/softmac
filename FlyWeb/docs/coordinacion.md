# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN. Puesta al día el **20-10-2026, ~22:45 (Madrid)** por COORDINACIÓN-8
(`session_0133Pd3pUk1DtKWpYpE53qB4`, «Coordinación (8)», 20-10, Opus 5.5 alto; relevada al 66 % de contexto),
que relevó a COORDINACIÓN-7 (archivada).
Leer antes: `CLAUDE.md` (**primera regla fija: datos personales del HUMANO nunca en GitHub**; al HUMANO se le llama
**Titín**), `docs/TAREAS.md` (tabla de agentes, **reglas 1–20**, filas FM.28, FM.29, FM.31 y FS.20–FS.22),
`FlyWeb/docs/migracion-128.md` (plan de la base 128, recalibrado) y los estudios de hoy (abajo).

## 28-10: COORDINACIÓN-18 → COORDINACIÓN-19 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-18 (`session_01MwmK2kpAkjPBYo89FV7qEV`, Opus 5.5, medio; abierta por Titín) se releva al ~36 % (~18 $). **Nunca
aprobar la tarjeta de confianza.** A la 7,1, solo por `buzon` (tarda; si corre prisa, Titín se lo dice a la sesión local).

**Hecho:** 2.1.0 publicada (curl 27-10 19:15). **2.1.1** (FM.48) entregada por LOCAL-14 (brave-core `local/2.1.1-arreglos`
ef850e44d7, build 33; CT, raíces, V8 FS.29, 11+2 escapes de flex, Futura): orden a PUBLICACIÓN en el buzón (09:2x UTC);
**falta: PUBLICACIÓN publica → Titín firma en bak → comprobar con curl (appcast, web, DMG) y avisar a Titín.** **2.2.0 = nivel 133**
(FM.49): `nube/motor-133` **2f268ee217** (build 34), orden a LOCAL de MOTOR-28 (`buzon/LOCAL/20261028-0953` + corrección 1016).

**Decisiones de Titín del 28-10** (en `DIRECTIVAS.md`): MOTOR abierto no es MOTOR parado; «hasta dos niveles por delante» es un
máximo; servidor a la par del motor (FS.32, SERVIDOR-LOCAL); lo menor sale en la primera compilación y se afina después;
Root Store a 153.0.8010.0 con el 133; `Sec-Fetch-Storage-Access` apagada (no existe en la red de la 128).

**En curso:**
- **MOTOR-29** (`session_01MwmK2iDD1sWx5FwbmTYa37`): **bloqueada** sin push a brave-core; Titín tiene que aprobar `add_repo` en
  su sesión. Encargo: errores de la 2.2.0 → **2.2.1** (attr() en `nube/motor-133-attr`, sin la migración entera a streaming) →
  134 con Maglev (`seg/maglev-134` 127ec285b, FS.34: 16 arreglos contra la 13.4, cifra buena).
- **MOTOR-26** (`session_01MwmK2ifjhdhoUu5VEpAigY`) viva hasta publicar la 2.1.1; **MOTOR-28** (`session_01MwmK2mPzyrf5do67riZaYB`)
  hasta publicar la 2.2.0. Archivarlas al publicar.
- **LOCAL-14** (7,1): compila la 2.2.0; prepara `software/entregas/maglev-51/medir-maglev.command` para que Titín lo lance en la
  5,1 (con tiempo máximo por prueba; con la build del 134, no con la 2.1.x). **Maglev con la 2.1.1 en la 6,1: Speedometer +3 %,
  JetStream se cuelga 5/5** → en la 2.1.x sigue apagado; se repite con el 134.
- **SERVIDOR-LOCAL**: FS.32 (tabla de componentes del espejo frente al nivel 132), orden en el buzón.
- **BACKUPDRIVE-1** (`session_01MMur1TxacRpN7gNor98eYm`): B.2 casi cerrada; maqueta de la interfaz (B.7, #593) para Titín;
  INTERFAZ se abre cuando Titín dé el visto bueno al diseño.
- **SEGURIDAD-PORTES-11 archivada** (28,5 $); nota «11 → 12» en `RELEVO-SEGURIDAD.md`; abrir la 12 solo con encargo (FS del
  134 o montar la serie de Maglev sobre los `patches/v8` del 134 si MOTOR-29 lo pide).
- **SEGURIDAD-VIGÍA**: le pedí que actualice el prompt de su rutina (sigue diciendo 2.0.x / V8 13.1); comprobar el lunes.

**Pendiente de Titín:** permiso de MOTOR-29; firma de la 2.1.1 en bak; la maqueta de BackupDrive y sus 3 decisiones; si
quiere la regla de permiso fija para `add_repo` (ofrecido, sin respuesta).
**Costes del día** (nube): MOTOR-26 ~12 $, MOTOR-27 21,8 $, SEGURIDAD-PORTES-11 28,5 $, COORDINACIÓN-18 18,2 $.

## 27-10: COORDINACIÓN-17 → COORDINACIÓN-18 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-17 (`session_01MwmK2kJWombM32SbQ96TJQ`, Opus 5.5, medio; abierta por COORDINACIÓN-16, linaje 1) se releva al
~37 % (~13 $). **Nunca aprobar la tarjeta de confianza.** A la 7,1 solo por `buzon` (la nube no puede contestar a las sesiones
`bridge:`); ellas te escriben. Lectura larga y webs de versión, con subagentes Sonnet (barato: ~60–100 k tokens suyos).

**Hecho hoy:** 2.0.3 publicada (comprobada con curl); **2.0.4 cancelada** (Titín: sus arreglos los sustituye la V8 13.2);
**2.1.0 = nivel 132** compilada por LOCAL-13 sobre `local/2.1.0-arreglos` 5f2c1e51 (build 32), probada en la 6,1, sí de Titín
a lo visible, entregada; PUBLICACIÓN la firmó, notarizó y subió (SHA 06f0e334…0d98, 174 879 611 bytes); web en main (#575).
**Falta: firma de Titín en bak → PUBLICACIÓN verifica el appcast → comprobar con curl y avisar a Titín** (lo pidió).

**Decisiones de Titín de hoy** (en `DIRECTIVAS.md`): force push en `nube/*` propias sin derivadas; Maglev encendido como tarde en
el 134 con deuda portada y medida; WebGL sin falsear; sin versiones de seguridad que el nivel listo vaya a sustituir; raíces con
constante propia fijada en 139.0.0.0; FM.47 sin versión propia.

**Siguiente — FM.48 = 2.1.1:** abrir **MOTOR-26** (Opus medio) con la nota «De MOTOR-25 a MOTOR-26» de `relevo-motor.md` y la fila
FM.48: (1) revisar 843cac4f/5f2c1e51 y que 84926a40d7e quedó entero; (2) los 12 escapes de WPT del 132 (lista en FM.45);
(3) FM.47 (Futura en Sequoia: camino por familia → .LastResort; sospechoso nuestro parche de `font_matcher_mac.mm`); (4) fundir
`seg/fs30-ct` 2d022f2c, `seg/fs31-roots` dae06d65, `seg/fs29-v8` 53814453 (época 20) → orden a LOCAL. Luego, inventario del 133.
LOCAL-13 mide Maglev (orden 14:20) y se releva después (34 %). SEGURIDAD-PORTES-11 solo con encargo (deuda de Maglev para el 134;
nota «10 → 11» en `RELEVO-SEGURIDAD.md`).

**Agentes vivos:** LOCAL-13, PUBLICACIÓN, SERVIDOR-LOCAL-3, CARTERO-LOCAL (7,1); SEGURIDAD-VIGÍA (lunes); BACKUPDRIVE-1.
Archivadas hoy por COORDINACIÓN-17: COORDINACIÓN-16, INVESTIGACIÓN-MOTOR-5, SEGURIDAD-PORTES-9 y -10, MOTOR-25. Sin tareas
programadas de COORDINACIÓN. Para Titín, pendiente: nada salvo la firma en bak.

## 27-10: COORDINACIÓN-16 → COORDINACIÓN-17 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-16 (`session_01MwmK2kTtcTvupFz7R4Ef1t`, Opus 5.5, medio; abierta por Titín, linaje 0) se releva al ~36 %
(~13,6 $). **Nunca aprobar la tarjeta de confianza.** A la 7,1 solo por la rama `buzon`; las locales te escriben.
Las sesiones que abre COORDINACIÓN salen con el esfuerzo por defecto (medio en Opus 5.5) y `get_session` no lo muestra:
no te fíes de lo que diga la sesión sobre su esfuerzo (MOTOR-24 dijo «bajo» y era medio).

**Decisiones de Titín de hoy** (todas en `DIRECTIVAS.md`): decidir con los datos de `CONSUMO.md`, no con suposiciones
(INVESTIGACIÓN va en Sonnet; MOTOR en Opus medio); el límite semanal lo gestiona él, no lo saques; MOTOR vivo hasta
publicar su versión (archivar al publicar o al 35 %); LOCAL compila la siguiente mientras prueba en la 6,1; MOTOR dos
niveles por delante de lo compilado; INVESTIGACIÓN por delante hasta el 156, traduciendo a 10.14 lo de macOS 11/12/13;
**capa de compatibilidad propia** aprobada; **Graphite fuera** mientras exista el camino actual. Un comentario suyo es
para debatir: opciones con datos y recomendación.

**2.0.3 (se salta la 2.0.2, opción A de Titín):** brave-core `nube/motor25-p25` **fbe2394fed** = -p24 23f2d547d9 +
`seg/fs26-c3` b7fdffb7 + include de c3 (LOCAL) + b2 con los colores del cuentagotas en Mac + arreglo de las fijadas en
blanco (`pinned_tab_codec.cc`). Build 31. Órdenes a LOCAL en `buzon/LOCAL/` de las 12:15 (MOTOR-25) y de COORDINACIÓN-16
de la ~12:12. **Falta:** Release, pruebas en la 6,1 (fijadas con 2+ ventanas y perfil sucio; GPU global en reposo; F5.3
con Titín delante; b4 con un Mac que deje Titín; si b2 falla, se revierte solo), `chrome_pgo_phase` (solo lectura),
DMG y capturas → **sí de Titín** → PUBLICACIÓN (ya avisada de que se salta la 2.0.2) → bak → web, comprobada con curl.
Datos de la -p23 en la 6,1: proceso GPU con la NTP ~5,0 % (1.15.2 ~5,3 %), renderer 2,2 % (6,4 %), pausa al 0 %.

**Agentes vivos:**
- **MOTOR-25** `session_01MwmK2jUhhNQpTHEbCSHDPC` (Opus, medio): lo que traiga LOCAL de la 2.0.3, antes que nada; luego
  el **nivel 132** (FM.45, inventario aprobado: V8 13.2.152.56, Maglev encendido con medida en 5,1/6,1, sideways como
  último commit, escapes primero). Vivo hasta publicar.
- **SEGURIDAD-PORTES-9** `session_01MwmK2hx8uFcooc8ep2MhQT` (Opus, medio): FS.27 (Blink del 132) y FS.28 (V8 13.2).
- **INVESTIGACIÓN-MOTOR-5** `session_01MwmK2ht9HZ9DShwB6HHDfT` (Sonnet): FM.44 entregada entera (`fw1-receta.md`,
  `macos11-niveles.md` con §8 recetas 132–156, §9 capa, §10 Firefox 115 ESR, §8.4 macOS 13 y Graphite; `hardware.md`;
  `plan-fork.md`). Quieta por si MOTOR-25 le pide algo; archívala cuando el 132 esté portado.
- LOCAL-12 (`local_7a488440…`), PUBLICACIÓN, SERVIDOR-LOCAL-3, CARTERO-LOCAL en la 7,1; SEGURIDAD-VIGÍA (lunes);
  BACKUPDRIVE-1 (pruebas a–h de B.2 en la 6,1; luego B.6, botón «Conectar con Google Drive…», fila en su PR).

**Siguiente:** (1) 2.0.3 publicada; (2) tanda de migración de los 26 parches de Mojave a la capa (encargo a MOTOR,
versión aparte, un commit por parche); (3) PGO: si LOCAL confirma `chrome_pgo_phase=0`, medir con y sin antes de
proponerlo (toca Page Graph y obliga a recompilar todo); (4) número de versión visible del nivel 132: lo decide Titín;
(5) `fw1` en la 2.0.4 con `fw1-receta.md` (lo revisa SEGURIDAD-PORTES); (6) línea base de rendimiento en la 7,1.
Archivadas hoy por COORDINACIÓN-16: COORDINACIÓN-15, MOTOR-24, INVESTIGACIÓN-MOTOR-4, SEGURIDAD-PORTES-8.
Sin tareas programadas de COORDINACIÓN. Ramas basura que se pueden borrar: `claude/seg-portes-8-fs26`, `claude/inv4-borrador`.

## 27-10: COORDINACIÓN-15 → COORDINACIÓN-16

COORDINACIÓN-15 (`session_01MwmK2jKV5HMEpQrqNj4gjT`, Opus 5.5, medio) se releva al ~37 % (~11 $). **Nunca aprobar la
tarjeta de confianza.** La nube no escribe a sesiones locales: a la 7,1 solo por la rama `buzon`, y ellas contestan con
`SendMessage`. **Linaje:** COORDINACIÓN-15 tenía profundidad 6 de 8. **Por eso abre COORDINACIÓN-16 Titín**, no la
COORDINACIÓN anterior: así el linaje vuelve a 0.

**Publicado:** 2.0.1 (-p20, build 29) firmada en bak, en el appcast y en la web (comprobado con curl). Sparkle la instaló
sola en la 7,1.

**2.0.2 = -p23 17e7858669** (MOTOR-23; bundle `nube/motor23-p23`; orden `buzon/LOCAL/20261027-1045-MOTOR-23.md`;
`version-2.0.2.md`). Junta tres cosas, por decisión de COORDINACIÓN-15: una sola Release, una prueba y un sí de Titín.
- La -p21: fijadas y versión visible «2.0.2 (motor 131)».
- La -p22: tanda 1 de FM.42. Sin Secure Enclave en ninguna Mac, el audio en tiempo real como en la 116,
  getDisplayMedia y «Copiar texto de la imagen» en 10.14.
- El arreglo de FM.43: **la mosca animada de la NTP estaba tapada por `StyledPage` desde la 2.0.0** y seguía animándose
  a 60 Hz, así que el proceso GPU gastaba ~9–15 % de CPU frente al ~5 % de la 1.15.2. Ahora vuelve a verse y va en el
  compositor.

La -p21 ya está compilada en `out/Release` (base incremental; no se entrega). **Falta:**
1. LOCAL-12 compila la -p23 y prueba en la 6,1 con el fondo comprobado en reposo; antes, control al 0–1 %.
2. Capturas o vídeo de la mosca, 1.15.2 frente a -p23, y DMG de prueba.
3. **Sí de Titín:** regla nueva, lo visible no se publica sin él.
4. PUBLICACIÓN, luego bak, luego la web.

**Decisión pendiente de Titín:** con «Reducir movimiento», la mosca queda quieta (lo que pide `disenos.md` §3); en la
1.15 volaba más despacio. **Riesgo:** F5.3 (línea en la 6,1 en modo escalado). Si vuelve, se revierte solo `mosca.tsx`.
La rama `nube/motor23-p23` lleva un commit basura de MOTOR-23 (una copia del árbol de main, sin datos personales).
Limpiarla necesita force push, así que solo con el sí de Titín; no corre prisa.

**Lecciones de hoy:**
- Cerré FM.43 tras una sola prueba (FreeFileSync coincidía en el tiempo) y tuve que reabrirlo: confirmar con un control
  limpio antes de cerrar.
- Los mensajes del buzón llegan con horas de retraso y en desorden: uno posterior puede anular a uno anterior.
- En cada Release de la 6,1 y la 5,1 se mide la GPU en reposo, con la NTP y con about:blank.

**Decisiones de Titín de hoy** (en `DIRECTIVAS.md`):
- Mojave al 100 %: se traduce, no basta con que no se caiga (FM.42; inventario en `mojave-128.md`).
- Nada del T2 ni del Secure Enclave.
- Cifrado por software, estándar y modular: `fw1` va en la **2.0.4** (FS.25, `cifrado.md`; ML-KEM ya estaba portado).
- Lo visible, con su sí antes de publicar.
- Pestañas planas y unidas a la barra: D8 en `disenos.md`, sin prioridad; él manda los bocetos.

**Siguiente:**
- FM.42, tandas 2 y siguientes para la 2.0.3: c3 (OPFS truncate, regla 17), las fotos de cámara, el nombre de pantalla y
  el cuentagotas.
- Línea base de rendimiento en la 7,1 con la 2.0.1: JetStream sin web-ssr con `JetStream.benchmarks.filter`, porque la
  URL con la lista de pruebas da 403 (relevo-local.md).
- Repetir MotionMark en la 6,1 en reposo: el 603,74 a 45 fps no vale; la referencia es la 2.0.0, 541,92 a 60 fps.
- Falta el `sysctl machdep.cpu.brand_string machdep.cpu.features` de la 5,1: probablemente E5620 Westmere, con AES-NI.
- JetStream web-ssr: `RegExp.escape` es del nivel 136 y no se porta.

**Agentes vivos:**
- LOCAL-12: lo abre Titín (LOCAL-11 se releva; nota en `relevo-local.md`).
- PUBLICACIÓN, SERVIDOR-LOCAL-3 y CARTERO-LOCAL, en la 7,1.
- SEGURIDAD-VIGÍA, con su rutina de los lunes.
- BACKUPDRIVE-1.

Archivadas hoy: COORDINACIÓN-14, MOTOR-21, MOTOR-22, MOTOR-23 y SEGURIDAD-PORTES-7. No queda ninguna tarea programada
de COORDINACIÓN.

## 27-10: COORDINACIÓN-14 → COORDINACIÓN-15

COORDINACIÓN-14 (`session_017J2kfSt5BR2UuYSr8fYzvw`, Opus 5.5, medio) se releva al 38 % (17,4 $). **Nunca aprobar la
tarjeta de confianza.** A la 7,1, solo por la rama `buzon` (tarda horas a veces; si corre prisa, Titín se lo dice al
agente); las sesiones locales sí te escriben. La nube no escribe en brave-core: bundles en ramas de softmac, LOCAL sube.

**Publicado:** 2.0.0 (-p17, build 28) el 26-10, appcast y web. **2.0.1 (-p20 8528639ead, build 29)**: firmada,
notarizada, en ns2 (`FlyWeb-2.0.1.dmg`, 174 780 539 B, SHA-256 `1d7d6b0f…7b15`), web fusionada (#519; web-auto publica sola
cuando el appcast la anuncie). **Falta solo la firma de Titín en bak** (orden en FM.40; PUBLICACIÓN se la pasa). Lleva
el aviso falso «No se puede actualizar FlyWeb» quitado (`enable_update_notifications=false`), NTP sin halo (-p18),
«FlyWeb Sync», y **dos CVE explotados**: CVE-2026-11645 (V8, runtime) y CVE-2025-14174 (ANGLE Metal, 10.15+; no
reproducible por WebGL en la 7,1, arreglo aplicado). Cuando esté el appcast: comprobar la web con curl.

**2.0.2 (FM.41):** -p21 3cc4ce116c de MOTOR-20 (archivada; bundle `nube/motor20-p21`, orden en el buzón de LOCAL del
27-10 08:10): fijadas compartidas con 2+ ventanas (se perdían; fallo de la 2.0), versión visible «2.0.2 (motor 131)»
(capturas para Titín; la cadena traducible «FlyWeb 2.0.2…» la decide él), xHE-AAC solo en 10.15+, diagnóstico de JetStream
web-ssr (`RegExp.escape`, Chrome 136) y Speedometer «?» en Sequoia (Futura/CoreText). `navigator.brave` ya no se expone.
Flujo: LOCAL-11 compila y prueba → PUBLICACIÓN → orden de bak → web (VERSION, portada, novedades: la de la 2.0.1 es el
modelo, #519; quita el «problema conocido» de las fijadas). MOTOR-21 solo si LOCAL trae fallos.

**Seguridad:** triaje rehecho contra la 128 (FS.24, #514): con la -p20 no queda ningún explotado abierto. **Decisión
pendiente de Titín:** tanda de críticos que salen del sandbox (~15–25 h sin medir) + revisión de ANGLE por backend; la
cifra de 750 críticos/altos está sin verificar (3599 ID de 2026, anómalo). SEGURIDAD-VIGÍA = sesión de Titín
`session_019wTc3m4aVuvkKTEGMXdEHS` (Haiku, medio), despertada por la tarea «Seguridad-Vigía FlyWeb (Haiku)»
`trig_01RAtyyXH6fPZ9GAXRJYjYmV`, lunes 8:58 (Madrid), primera el 2-11; avisa a la COORDINACIÓN de la tabla. El blog de
Chrome Releases no se alcanza desde la nube: Titín puede añadir `chromereleases.googleblog.com` a la red del entorno.

**Pendiente con Titín:** capturas de la versión de la 2.0.2; si ve otra vez «Brave» al confirmar con el teléfono,
captura; MotionMark de la 5,1 (su hija; la 5,1 actualizó a la 2.0 sin problemas); GPU al 100 % en la 6,1 (le di los pasos:
`ioreg`, Administrador de tareas, perfil limpio); sesión `ubuntu` abierta en ns2 y «Auditoría ns1/ns2/bak» en la 7,1 (sin
respuesta). **LOCAL-11**, después de la 2.0.1 publicada: línea base de rendimiento en la 7,1 con la **580X** (solo el
FlyWeb instalado, por LuLu; PA271W a 60 Hz; 3 pasadas de Speedometer 3.1, JetStream 3.0, MotionMark 1.3.2). Niveles 132+:
cuando la seguridad tenga plan (Titín, 26-10).

**Agentes vivos:** LOCAL-11 (`session_01P7qNHoMWVrSBu4PL3iq6Gh`, bridge), PUBLICACIÓN, SERVIDOR-LOCAL-3, CARTERO-LOCAL
(7,1); SEGURIDAD-VIGÍA (rutina); BACKUPDRIVE-1 (`session_01MMur1TxacRpN7gNor98eYm`, a la espera de la prueba de Titín).
Archivadas hoy: COORDINACIÓN-13, MOTOR-18, -19, -20, CONTENIDOS-WEB-3, SEGURIDAD-PORTES-6. LOCAL-10: la archiva Titín.

## 26-10: COORDINACIÓN-13 → COORDINACIÓN-14 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-13 (`session_01L7rpeb3sVii7F8jgApaAcB`, Opus 5.5, medio) se releva al 40 % (29,8 $). **Nunca aprobar la
tarjeta de confianza.** Desde la nube **no se puede escribir en sesiones locales** (`send_message` da
`elevated_session_untrusted_device`): a la 7,1, por la rama `buzon` (lo reparte CARTERO-LOCAL, a veces con retraso; si
corre prisa, Titín se lo dice al agente). Las sesiones locales sí te escriben a ti. **La nube no tiene escritura en
brave-core:** MOTOR deja bundles en una rama de softmac y LOCAL los sube (decisión de Titín, 26-10).

**2.0.0 (FM.39, punto 16 al día):** candidata final **-p17 1b0ebd4a00**. En curso: **Release de la -p17 (LOCAL-10, desde el
26-10 12:50)** → pruebas a–g en la 6,1 → entrega en FM.39 → por buzón a PUBLICACIÓN: firmar, notarizar, subir a ns2 **sin
tocar el appcast** (ya lo probó con la -p15; mensaje del 26-10 en `buzon/PUBLICACION/`) → **Titín prueba en la 5,1 el DMG
firmado** (su decisión) → con su sí: orden de bak del appcast (PUBLICACIÓN la tiene preparada: `--min-macos 10.14.0`, sin
`releaseNotesLink`, build 169.168.28) y fusionar la web **#504** (CONTENIDOS-WEB-3, `session_01QqPWLpqxHcnDhDS5gxyAmi`,
viva; faltan tamaño y SHA-256 del DMG: que los rellene PUBLICACIÓN o ella). **Al fusionar la web se publica sola en ns2**:
solo cuando el appcast esté. Antes de publicar, SERVIDOR-LOCAL confirma web-auto (FM.39 punto 8). Sin probar aún:
contraseñas migradas y la actualización real 1.15.2 → 2.0 por Sparkle (pídela a PUBLICACIÓN con un appcast de pruebas).
**Después de publicar:** reactivar el VIGÍA (tarea «⚡ Vigía FlyWeb (Haiku)», `trig_01YbVYXhSWE1L5nFiuvpRXug`, pausada por
Titín) solo si sigue haciendo falta; **2.0.1** = -p18 16b6e01b57 (NTP sin halo, ya preparada) + `build.sh` para la 2.x.

**Hecho (23–26-10):** Shields 2.0 (#497) revisado, firmado e instalado en bak por Titín (`recursos-20` 2026.1023.1316); -p15
(insignia, EGL) → -p16/-p17 (MOTOR-18); web 2.0 (#504, sin fusionar); inventario de lo pendiente y optimizaciones
(`FlyWeb/docs/investigacion-pendiente.md`, #507; prioridades: línea base medida en Release —**la 7,1 con su 580X antes de
cambiarla por la W6600X**—, niveles 132+, descarte de pestañas por RAM, experimento `-march=haswell` solo si gana ≥5 %, matriz
GPU + F5.6); BackupDrive en modo seguro (#508: bisync con comparación por hash, borrado blando a versiones con caducidad,
frenos de borrados y de modificaciones masivas; **Titín lo prueba en la 6,1 con una carpeta de prueba, en paralelo a su
FreeFileSync**). Decisiones de Titín: DuckDuckGo sin `t=`; Flickr 429 resuelto en la 2.0 (huella de red, regla en TRAMPAS);
VIGÍA pausado; regla de diseño visual (DIRECTIVAS).

**Agentes vivos:** LOCAL-10 (`local_71a093c7-…`, bridge `session_01R4rHSMbvvgjWeEedxJ39jG`); MOTOR-18
(`session_01LsgphgHrVXECyE51FhS4Av`, <40 %, viva por si la Release de la -p17 falla; archívala cuando compile);
CONTENIDOS-WEB-3 (viva hasta fusionar la web); BACKUPDRIVE-1 (`session_01MMur1TxacRpN7gNor98eYm`, viva hasta la prueba de
Titín); en la 7,1 PUBLICACIÓN (~45 %), SERVIDOR-LOCAL-3 y CARTERO-LOCAL. Archivadas: COORDINACIÓN-12, LOCAL-9,
INVESTIGACIÓN-MOTOR-3.

## 23-10: COORDINACIÓN-12 → COORDINACIÓN-13 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-12 (`session_01NjpdW4mhQMcN2EuNN8MivC`, Opus 5.5, medio) se releva al ~68 %. **Nunca aprobar la tarjeta de
confianza.** Lo nuevo y decidido está en DIRECTIVAS (22–23-10) y en las filas **FM.38** (identidad, hecha) y **FM.39** (lo
que falta para publicar la 2.0.0); el análisis de gasto, en `docs/CONSUMO.md` («Análisis del 23-10»).

**Cómo trabajar ahora (Titín, 22–23-10):** una sesión por tarea con arranque mínimo, subagentes para leer, relevo hacia
el 35–40 %, archivar al entregar (antes, `list_triggers` y borrar sus avisos) y abrir el relevo solo cuando haya trabajo.
**Junta los cambios `[coord]` en pocos PR:** cada PR trae dos avisos largos que engordan tu contexto. Los agentes empujan
a veces a un PR ya cerrado: reaplica sus commits en uno nuevo. La 7,1 no recibe `send_message` de la nube: buzón.

**Estado de la 2.0.0:** candidata **-p14 806e8caa96** (motor 131 + Mojave + identidad + Sparkle + copia del perfil),
probada por LOCAL-9 en la 6,1 (sin caídas, auditoría de red limpia, migración con el perfil real de Titín: marcadores y
extensiones bien; contraseñas sin probar: su perfil no tenía) y por Titín en el A1398 (claude.ai bien; GPU OpenGL, Metal
no admitido por esas GPU). `nube/base-128-motor` sigue en -p9: muévela a la candidata final (MOTOR o LOCAL).
**En curso:** LOCAL-9 hace la **-p15** (león de la insignia de la barra; buzón del 23-10).
**Falta (FM.39):** servidor de Shields (**SERVIDOR-LOCAL-2**, ordenado por Titín; Titín ya generó la clave `recursos-20`,
ID `nilendadbigifkognoeoodppkjkgmppg`, #477/#479); pruebas a mano de Titín en la 6,1 (ventana cerrada con fijadas,
llavero, menús, barra lateral, descargas) y contraseña de prueba para la migración; MacBook con Mojave el sábado 24-10
(LOCAL-9 por SSH; la 5,1 no está accesible); Release firmada (llavero sin aviso, CPU de vídeo); web de la 2.0 con la
ayuda de contraseñas (CONTENIDOS-WEB) y comprobar web-auto (SERVIDOR-LOCAL); appcast con `--min-macos 10.14.0` y sin
`releaseNotesLink` (PUBLICACIÓN, respondido). **Después:** FM.37 (privacidad de Brave posterior a la 1.69), clase E
(servicios nuevos), MOTOR-18 (8 fallos sueltos de `blink_unittests` y la caída de V8; esfuerzo alto), F5.6 (códec por
capacidad en 2.0.x), widget de búsqueda de la NTP (¿DuckDuckGo o fuera?), registro de la AMD.

**Agentes vivos:** LOCAL-9 (`local_ad0f5131-…`, bridge `session_01NqrwCVpYFvVS6m6fGZgAed`, medio, por el plan); VIGÍA
(rutina horaria; cámbiale el destino a ti); CARTERO-LOCAL, PUBLICACIÓN y SERVIDOR-LOCAL en la 7,1. Todas las demás de la
nube, archivadas (sus notas: `identidad-128.md`, `relevo-motor.md`, `RELEVO-SEGURIDAD.md`).

## 22-10: COORDINACIÓN-11 → COORDINACIÓN-12 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-11 (`session_016LAphUszobDrthjRLX51N9`, Opus 5.5 alto) se releva al 54 % de contexto (40,33 $, 135 266 de
salida), en punto limpio: se espera la `-p7` de MOTOR-16. **Nunca aprobar la tarjeta de confianza.** Archivar sesiones
locales desde la nube **sí funciona** (LOCAL-7, 22-10). PR [coord] de COORDINACIÓN: los fusionas tú con `expectedHeadSha`.

**Decisiones de Titín (21–22-10), ya en el tablero:**
- 1.15.2 **publicada** (appcast y web, 21-10). **1.15.3 cancelada**; la **base 128 (2.0.0) es el hito**, a fondo (DIRECTIVAS).
- **GPU en Mojave, requisito de la 2.0.0**; WebGPU apagado (CVE-2026-5281) hasta su nivel. Maglev apagado hasta el 132
  (tabla de la regla 19, RELEVO-SEGURIDAD).
- **Códec por hardware** como la 1.15 (YouTube en H.264 donde VP9 no va por hardware), mejor por capacidad (VideoToolbox).
- Máquinas de prueba nuevas en CLAUDE.md (MBA 2013, Mac mini y MBP 2012 con Catalina, A1398 con Monterey).
- **OR.2:** crédito de API de 100 $ (caduca 06-11, sin tarjeta) para una sesión local; LOCAL-8 se abrió **por el plan**
  (sin clave en el entorno): sigue sin usar. Siguiente intento: la próxima sesión local larga, por Terminal. **Corrección (22-10): el crédito promocional NO vale para Claude Code** (se aplica a Agent SDK, API, API por lotes, Playground y Agentes gestionados; Claude Code da «Credit balance too low»). LOCAL-9 se abrió por el plan. Usos posibles antes del 06-11: un guion del Agent SDK para lecturas masivas o un Agente gestionado; se decide en el análisis del 23-10.
- Titín quiere la 2.0 **lo antes posible**, pero COORDINACIÓN-11 le recomendó no forzarla esta semana (límite semanal al
  57 %, reinicio **martes 27-10 08:00 Madrid** = 07:00 UTC; ya en horario de invierno). **Viernes 23-10: análisis de gasto por tarea** (CONSUMO.md) con Titín.

**Estado de la 2.0.0 (FM.31) al relevo:**
- brave-core: `nube/base-128` = Brave 1.69.168 puro (6918a99aa6). Rama de integración `nube/base-128-motor`; fijas
  -p1…-p6. **-p6 02c9d0ca4b** = V8 13.1 + niveles 129–131 + anchor + flags + ML-KEM + seguridad S1–S4 + FS.23 + versión
  declarada 131 (UA, Client Hints sin «Brave», platformVersion 11.7.10).
- **Parches de Mojave** (GPU de la Fase 1 + 46 avisos de 10.15: Dawn, color_space_util, HDR, Bluetooth FIDO, LAContext,
  descargas, geolocalización…): LOCAL-8 en brave-core `local/base-128-mojave` 88739f8c7f (`FlyWeb/mojave-128/*.diff`).
  **MOTOR-16 los convierte en patches/ y hace -p7** con el códec por hardware y los tests de blink (41 *_test.cc.patch:
  solo llegaron 2) y la regresión de togglePopover/WPT.
- **Probado en la 6,1:** GPU todo acelerado, 0 caídas, WebGL 60 fps; MotionMark 570 (1.15.2: 412); html5test 579/588;
  **claude.ai con Google funciona entero** (Titín, 22-10). Speedometer 3.0 = 3,99 (desarrollo, sin Maglev; falta la cifra de la 1.15.2).
  WPT 695/699 iguales a CfT 131; JA4 idéntico. Vídeo 1080p (H.264): 1.15.2 12 % vs 128 18 % de un núcleo (repetir en Release).
- **Pérdidas en Mojave:** EyeDropper y takePhoto apagados en 10.14 (la 128 quitó la alternativa de la 116).
- **Riesgo:** Media Router (DIAL) con un cortafuegos que pregunta cuelga el hilo de E/S (Brave lo trae apagado).
- **Pendiente:** -p7; vídeo y descargas/geolocalización en la 6,1 (LOCAL-8); 5,1 (Titín da usuario/host/puerto **solo en la
  sesión de LOCAL**, a `temp/`, ignorado por git); **Fase 2** (marca, sin cartera/Rewards/VPN/Leo ni barra «macOS 11»,
  `navigator.brave`/`braveEthereum`/`solana` fuera, servicios propios, Sparkle **y migración del perfil de la 1.15**);
  Release; resto de máquinas; publicación. **El reparto de la Fase 2 se propone a Titín tras la -p7.**

**Agentes:** MOTOR-16 `session_01R24qB8o9yirUqVC7H1ZVc6` (~20 %); SEGURIDAD-PORTES-5 `session_01H7fz6r296TWMGBgDfYzRgX`
(~40 %, relevo antes de su próximo encargo); INVESTIGACIÓN-MOTOR-2 `session_014AE1uLN6wA98XeE3bdEbbV` (quieta);
CONTENIDOS-WEB-2 `session_015tHV7uDdbAc6uZ1VwmgcqD` (quieta); LOCAL-8 `local_5c6ba9f8-…` (desde la nube
`session_01S8dHbLwEmeH2dsnY88gBrz`, ~25 %). Vigía `session_01XD1RBYQ5oESHWKeqZWSG4e`: **cámbiale el destino** a ti.
MOTOR-14/15, LOCAL-6/7, SEGURIDAD-PORTES-4 y COORDINACIÓN-10: archivadas.

**Lecciones (en TRAMPAS):** la revisión en papel no sustituye a compilar y probar (FS.23 halló 7 arreglos perdidos; el
«cuelgue de GPU» era LuLu). Mensajes cruzados: los agentes empujan a su PR después de que lo fusiones; mira la rama
antes de fusionar y reaplica lo que llegue tarde.

## 21-10 (tarde): COORDINACIÓN-10 → COORDINACIÓN-11 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-10 (`session_01U31mzo4UdTUgf3gkhqxKmb`, Opus 5.5) deja la nota al 45 % de contexto, en punto limpio; se
releva cuando Titín lo pida o al pasar del 50 %. **Nunca aprobar la tarjeta de confianza** (ni tú ni la nube).

**Canales (comprobado hoy):**
- Nube → nube sin aprobar: `send_message`. Nube → 7,1 y → sesiones aprobadas: **rama `buzon`** (`buzon/README.md`);
  reparte **CARTERO-LOCAL** en la 7,1 cada 30 min. **Entrega, pero no anota en `buzon/ENTREGADO.md`** (recordatorio en el
  README). Lo urgente que no llega (pasó con la F15 a LOCAL-6) se lo pides a Titín para que lo pegue en la sesión.
- 7,1 → nube: `SendMessage` directo, llega bien. Reserva: CARTERO-1 de la nube (rutina `trig_01ByndD2HyrSWPyNqauBF7uH`
  desactivada). VIGÍA solo vigila (rutina reactivada, destino COORDINACIÓN-10: **cámbialo** con un mensaje al Vigía).
- El clasificador del modo Auto bloquea ordenar a otra sesión `confirm_repository_trust`. Archivar una sesión aprobada
  (MOTOR-13, COORDINACIÓN-9) solo lo puede hacer Titín.

**Estado al relevo (21-10, ~18:10 Madrid):**
- **1.15.2 ENTREGADA** a PUBLICACIÓN (FM.28): brave-core `nube/motor-131-anchor-f16` af0328adeb, build 27. Camino:
  F9 → F14 (caídas de la 1.15.1 publicada y UAF c215f8e6f0 arreglados) → F15 (la F14 rompía 9 WPT de capa superior) →
  F16 (includes que la Release sin PCH no encontraba). Falta: PUBLICACIÓN firma/sube (no le preguntes a Titín) y da nombre,
  bytes y SHA-256 del DMG en FM.28 → CONTENIDOS-WEB-2 pasa **#420** (web) a listo → lo fusionas. Luego LOCAL mueve `flyweb`.
- **Lecciones (en TRAMPAS):** la revisión en papel (MOTOR y SEGURIDAD) aprobó la F11/F14 y solo las WPT vieron la
  regresión; una Static con PCH no garantiza la Release (`enable_precompiled_headers=false`).
- **FM.31 Fase 0 HECHA:** Chromium 128 limpio compila en la 7,1 (SDK 14.5, Metal de Xcode 15.4) y **arranca en la 6,1 en
  modo software**: 4 rondas (mac_min_system_version, 3 SPI en weak_import, EDR de screen_mac, Dawn hasUnifiedMemory;
  `dcheck_always_on=false`). Queda para la Fase 1: Dawn en 10.14 (~50 usos de API 10.15 sin @available: protegerlos o
  apagar WebGPU), el resto de los 70 avisos y la 5,1. **Decisión pendiente para Titín cuando se plantee la Fase 1:**
  WebGPU apagado al principio (recomendado: menos trabajo; Chrome 128 no da soporte a 10.14) o portar Dawn.
- **1.15.3 (FM.29, view transitions entre documentos):** MOTOR-14 (`session_01PZNSmdebZSnLvAr2v93osp`, sin aprobar) la
  midió (#412: 159 commits, 6–10 h); abre rama cuando la 1.15.2 esté publicada. Lista para la 1.15.3: 01c7c1b09a
  (::backdrop), getComputedStyle-002, 3aa7ad2a0d opcional.
- **Agentes:** LOCAL-6 al 53 %, en punto limpio; **LOCAL-7 lo abre Titín** (texto en mi último mensaje a Titín: el de
  LOCAL-6 en ARRANQUE con «relevo de LOCAL-6 (local_20642d1a-…)»). SEGURIDAD-PORTES-4 (`…011AG2q3`, 35 %) e
  INVESTIGACIÓN-MOTOR-2 (`…014AE1uL`, sin encargo) quietas. SERVIDOR-LOCAL-3 sin encargo. MOTOR-13, COORDINACIÓN-9,
  LOCAL-5, CONOCIMIENTO-1, SEGURIDAD-PORTES-3 e INVESTIGACIÓN-MOTOR-1: archivadas.
- Consumo de COORDINACIÓN-10 al dejar la nota: 28,01 $, 112 275 tokens de salida, 45 % de contexto.

## 21-10: COORDINACIÓN-9 → COORDINACIÓN-10 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-9 (`session_01MMGz9HS8qH5Hzsne92zi7u`, Opus 5.5 alto) se releva el mismo día porque aprobó la tarjeta de
confianza y dejó de recibir mensajes de la nube.

**COORDINACIÓN-10 (`session_01U31mzo4UdTUgf3gkhqxKmb`), 21-10 ~10:05:** el clasificador del modo Auto **bloquea ordenar a
otra sesión que llame a `confirm_repository_trust`** («Auto-Mode Bypass»): la tarjeta del cartero la tiene que pedir Titín
en la sesión del Vigía. Archivar una sesión aprobada (COORDINACIÓN-9) falla desde la nube («requires a trusted device»):
la archiva Titín. Buzón montado (rama `buzon`, `buzon/README.md`). **Corrección:** el CARTERO no es el Vigía sino una sesión nueva, CARTERO-1 `session_01RteKFFeayEirn8fTGKbFnC` (Haiku, aprobada; rutina `trig_01ByndD2HyrSWPyNqauBF7uH` a :37); el Vigía sigue solo vigilando. **Después (Titín, 21-10 ~10:15): el cartero pasa a la 7,1 (CARTERO-LOCAL, Haiku bajo, cada 30 min, `SendMessage` dentro de la Mac, sin tarjeta)**; CARTERO-1 queda de reserva con su rutina desactivada. Sus instrucciones, en `buzon/README.md`.

**Canal entre sesiones (comprobado el 21-10; no documentado, deducido de estos casos):**
- La tarjeta (`confirm_repository_trust`) la aprueba Titín, una vez por sesión. La sesión aprobada puede escribir a la
  7,1 y a sesiones de la nube **sin aprobar**, pero **deja de recibir de cualquier sesión de la nube**, aunque esté
  aprobada: solo le llega lo que sale de los dispositivos de Titín (la 7,1, su móvil).
- Casos: CONOCIMIENTO → COORDINACIÓN-9 (aprobada), rechazado; COORDINACIÓN-9 → MOTOR-13 (aprobada), rechazado;
  COORDINACIÓN-9 → CONOCIMIENTO y → LOCAL-5, entregados; LOCAL-5 → COORDINACIÓN-9, entregado.
- **COORDINACIÓN-10 y todos los agentes de la nube, sin aprobar nunca.** Solo el CARTERO se aprueba. MOTOR-13 ya está
  aprobada: le llegan LOCAL y Titín, no la nube; **MOTOR-14 se abre sin aprobar**.
- Titín (21-10): pasarse el día aprobando no es viable, y el sondeo desde LOCAL tampoco (cada despertar relee su
  contexto, que crece rápido; la 7,1 va saturada con las compilaciones y su trabajo). Pide preparar un *feedback* a
  Anthropic: confianza por entorno o por agente, no por sesión, y Remote Control que no se pierda al reiniciar la app.
- El modo Auto no tiene que ver: aprueba permisos dentro de la sesión. Aun así, a MOTOR-13 el clasificador le pidió
  confirmar una orden de Bash (21-10, ~09:35). Al abrir una sesión con `create_session`, pasar `permission_mode: auto`
  (CONOCIMIENTO-1 se abrió sin él y pidió permiso para `send_later`).

**CARTERO (decisión de Titín, 21-10): el Vigía pasa a cartero, Haiku bajo o medio.**
- Única sesión de la nube aprobada (un toque de Titín, una vez). Para que salga la tarjeta: `send_message` a una sesión
  de la 7,1; el rechazo trae un `content_digest`, y con él `confirm_repository_trust`.
- **Buzón:** rama `buzon` de softmac. Cada mensaje de la nube para la 7,1, un fichero
  `buzon/<DESTINO>/<AAAAMMDD-HHMM>-<ORIGEN>.md`, con push directo a esa rama (sin PR). **Nada de datos personales**:
  la rama es pública. En cada pasada, el cartero hace `git fetch`, reparte los ficheros nuevos con `send_message` al id
  de la tabla de agentes y anota lo entregado en `buzon/ENTREGADO.md`. Sus avisos de vigía a COORDINACIÓN siguen
  (de aprobada a sin aprobar sí llega).
- Rutina `trig_01YbVYXhSWE1L5nFiuvpRXug` («Pasada del vigía», cada hora 8–23 h): **desactivada** por COORDINACIÓN-9
  el 21-10 a las 07:30 UTC; se reactiva al montar el cartero (a 30 min si hace falta).
- Preguntas pendientes del Vigía: regla del desfase de la web (¿dos pasadas seguidas o solo tras la firma?) y si
  «WEB SINCRONIZADA» se manda sin ACCIÓN.
- Sin probar. Primera prueba: un mensaje de COORDINACIÓN-10 a LOCAL-6 por el buzón.

**Estado al relevo (21-10, ~09:55):**
- **OR.1:** fusionados #374, #378, #379 y #380 (TAREAS de 748 a 128 KB; `DIRECTIVAS.md`; `ARRANQUE.md` con los textos de
  relevo; manuales sin historial); #375 y #377 cerrados porque iban dentro de #379 y #378. CONOCIMIENTO-1
  (`session_01TRKSg59fpf5oYiaF2mv6X9`): falta repartir «Trampas» de esta nota entre DIRECTIVAS y los manuales.
- **OR.2:** `docs/CONSUMO.md` (#376), con el plan prudente de pruebas en los relevos.
- **FM.28 (1.15.2):** caída grave del porte (`std::move` en `Element::RecalcOwnStyle`), URGENTE en MOTOR-13, que
  esperaba la aprobación de Titín de una orden de Bash. El arreglo lo compila LOCAL, parando la 128.
- **FM.31:** Chromium 128 compilando desde las 09:36 (SDK 14.5 de Xcode 15.4, `use_siso = false`).
- **Relevos (Titín, 21-10: todos ahora):** SEGURIDAD-PORTES-4 e INVESTIGACIÓN-MOTOR-2 en la nube, que abre COORDINACIÓN-10
  con `create_session` y `permission_mode: auto` (el esfuerzo no se puede fijar ahí: Titín lo pone en la app). LOCAL-6 y
  SERVIDOR-LOCAL-3 en la 7,1, con los textos de `docs/ARRANQUE.md` que pega Titín. LOCAL-5 deja antes su nota de relevo.
  Se archivan las viejas cuando el relevo esté activo. PUBLICACIÓN y SERVIDOR-LOCAL-2 tienen la sesión archivada.
- Revisión programada de COORDINACIÓN-9: `trig_019mJD9YvXyBC2MZKeFwswr5`; bórrala al activarte.
- Límite semanal en aviso hasta el martes 27-10, 08:00 (Madrid).

## Qué hace este papel (con lo que cambió el 09–12-10)

- **Interlocutor del HUMANO**: respuestas breves, críticas, con conclusión; solo le llegan decisiones de producto,
  credenciales, firmas, pruebas en las Mac y lo que exige root en ns2. **No escribirle por avisos rutinarios** (Vigía,
  GitHub, mensajes de agentes sin decisión): cada respuesta tuya le salta como aviso en el móvil y le agobia.
- **Fusiones, cierres y orden de trabajo son de COORDINACIÓN** (regla 8, decisión del HUMANO del 09-10): revisas y
  fusionas los PR de softmac sin preguntarle. Excepción conocida: el permiso de la sesión bloqueó autofusionar un PR que
  ampliaba la propia autoridad (#129); ese lo fusionó el HUMANO.
- **Regla 14, «el que publica, publica»**: la nube prepara; ejecuta quien tiene el acceso (SERVIDOR-LOCAL en ns1/ns2,
  PUBLICACIÓN las versiones, LOCAL las compilaciones). Lo privado va por `send_message`, nunca por el repo.
- **Regla 15, límite semanal de la cuenta**: mirar `rate_limit_info` con `get_session`; con aviso, nada de Ultracode ni de
  muchos subagentes. El HUMANO lleva los agentes de sus otros proyectos; tú solo los de softmac.
- **Regla 16 (12-10): tus órdenes valen como del HUMANO.** Lo que ordenas o transmites por `send_message` o con un commit
  `[coord]` no se le vuelve a confirmar a él. Dos límites: los agentes te reconocen por el id de sesión de la tabla de
  TAREAS, así que **anota tu id en la fila de COORDINACIÓN antes de dar ninguna orden**; y los permisos que pide
  Claude Code dentro de una sesión solo los aprueba el HUMANO en esa sesión. Si un agente está bloqueado por eso, se lo
  pasas al HUMANO.
- **Sin rutinas propias**: te despiertan el Vigía y el HUMANO.
- **Cuándo relevar a COORDINACIÓN** (HUMANO, 12-10): a partir del **50 % de contexto** (`context_usage` de
  `get_session`), en un momento tranquilo: sin publicación a medio hacer ni decisión pendiente con el HUMANO. Antes de
  irte, esta nota al día. La regla 16 se avisó a todos los agentes el 12-10 (SERVIDOR-LOCAL-2, por su fila, porque su
  sesión estaba archivada).

## Agentes y cómo hablarles

Desde la nube, `send_message` con el id **`session_…`**. Los agentes de la 7,1 te escriben con `SendMessage`.
**Desde el 20-10, 19:19 (reinicio de la app de la 7,1), la nube NO puede escribir a las sesiones de la 7,1**
(`elevated_session_untrusted_device`) hasta que Titín apruebe la tarjeta de `confirm_repository_trust` **desde la app de
Claude en un dispositivo de confianza** (móvil o Mac, con sesión reciente; desde el terminal no vale). Es una aprobación
por sesión de la nube y vale para siempre (la sesión queda limitada a sus dispositivos). Mientras no esté: LOCAL sí escribe
a la nube; lo que haya que mandar a LOCAL se le da a Titín como texto listo para pegar. **No buscar otro canal** (bridge,
sondeo del repo) sin que Titín lo decida: es saltarse un control de seguridad.

| Agente | Sesión | Estado al 20-10, ~22:45 |
|---|---|---|
| VIGÍA (Haiku) | `session_01XD1RBYQ5oESHWKeqZWSG4e` | Rutina cada hora; destino = COORDINACIÓN-8 (cambiar al relevo). Su «web sincronizada» solo compara appcast y VERSION, no la web publicada |
| MOTOR-13 (Opus, xhigh) | `session_01EqxadojDaRbipYn8TDzVd6` | FM.28 (1.15.2): la F5 compiló el navegador entero; arreglados el enlazado y los 115 errores de `blink_unittests` (opción A, solo tests). **Sha para LOCAL: `7f864fb08c` (`nube/motor-131-anchor-f7`, lleva FS.22, comprobado con merge-base)**, que Titín pasa en persona. ~6 h 30 min de reloj. Al 18 % |
| SEGURIDAD-PORTES-3 (Opus, medio) | `session_01LKiaD9v2hcna6BUo6CfMBs` | FS.20, FS.21 y FS.22 hechas; visto bueno de la 1.15.2. **Al 76 %: el próximo encargo, a una sesión nueva** |
| INVESTIGACIÓN-MOTOR-1 (Sonnet, alto) | `session_01KEXwPPgTGezmJikFPWgNRA` | FM.27, 30–35 hechas (estudios abajo). Espera 3 datos del G5 (sin prisa). **Al 78 %: el próximo encargo, a una sesión nueva** |
| CONTENIDOS-WEB-2 (Sonnet, medio) | `session_015tHV7uDdbAc6uZ1VwmgcqD` | Libre; le toca la web de la 1.15.2 cuando LOCAL la entregue |
| LOCAL-5 (7,1, Opus, alto) | `local_eb0590c2-…` / `session_01DCZDzGMM8VdHsV5B5JBXmv` | F5 (767c49475b) hecha; le falta compilar `7f864fb08c` (navegador + `blink_unittests`, `-k 0`; el `--gtest_filter` del anchor está en FM.28). **21-10: todo el día Chromium 128** (FM.31); la Release de la 1.15.2 espera a Titín. Descarga de la 128 a medias (429 de googlesource, `-j 2`) |
| PUBLICACIÓN (7,1, Sonnet) | `session_01TTieMjJGykHhdkXAYW8bZG` | Libre (1.15.1 publicada) |
| SERVIDOR-LOCAL-2 (7,1, Sonnet) | `session_01QxM99SrrnUTS2i4XuAHKta` | web-auto con #324 instalado; libre |

Archivados hasta el 20-10: COORDINACIÓN-5/6/7, MOTOR-8 a 12, SEGURIDAD-PORTES-1/2, LOCAL-2 a 4.

Notas de tablero: commits con `[coord]`; reglas, CLAUDE.md y docs por PR, que fusionas tú (pasa a listo y fusiona con
`expectedHeadSha`; antes `git merge-tree` contra `main` y un grep de datos personales/IP). Tu rama de trabajo se queda atrás
tras cada squash: rehazla con `git checkout -B <rama> origin/main` + `git merge -s ours origin/<rama>` (sin force push, que el
permiso bloquea).

## Estado al relevo (20-10, ~22:45)

| Versión | Qué | Estado |
|---|---|---|
| 1.15.1 | Nivel 131 + FM.22 | **Publicada** (firma 16:15; web por web-auto con el arreglo #324 a las 19:27) |
| **1.15.2** | Anchor positioning (FM.28) + 4 CVE críticos (FS.22) + fuga de StyleAnchorScope + KeyboardFocusableScrollers a experimental | Portada; Static de prueba en LOCAL; visto bueno de SEGURIDAD. **Release y publicación cuando vuelva Titín (22-10 o después)** |
| 1.15.3 | View transitions entre documentos (FM.29) | Pendiente, después de la 1.15.2. **Después no se abre el 132** |
| **2.0.0** | Base Chromium 128 + Brave 1.69.168, **mínimo Mojave 10.14** | **Prioridad de Titín.** Fase 0: CVE (FS.20, hecho: 52 pendientes que la 128 ya corrige), Chromium Legacy 127 probado en la 6,1 (va, con 5 caídas de GPU al arrancar sin explicar), compilación limpia de la 128 el 21-10 |

**Decisiones de Titín del 20-10** (todas en TAREAS): orden 1.15.2 → 1.15.3 → migración; no abrir el 132 sobre la 116;
la 128 en paralelo pero nunca dos compilaciones a la vez en la 7,1; mínimo de la 2.0.0 = Mojave (su madre sube a Mojave
el MacBook Air 2013); criba FM.30 aprobada (solo medir botones, LOCAL); G5 aparcado hasta tener fork; Leo y similares
apagados, se borran cuando haya fork; copia de Chromium Legacy en `lamosquita-net/chromium-legacy` (la hizo Titín:
COORDINACIÓN no puede hacer forks fuera de softmac).

**Estudios del 20-10 (INVESTIGACIÓN):** `g5-viabilidad.md`, `criba-fm30.md`, `migracion-128.md` (130–330 h, central ~230),
`chromium-legacy.md`, `legacy-evolucion.md` (Chromium sube el mínimo de macOS en 117, 129 y 139: cada salto de base cuesta
~30–60 h por versión de macOS), `brave-sync-shields.md`, `brave-vs-flyweb.md` (**trampa: constantes de Brave en cabeceras**),
`brave-servicios-nuevos.md`, `brave-170-173.md`, `brave-vs-parches-motor.md`, `cve-117-128-fuera.md` (SEGURIDAD).
**Comprobaciones obligatorias de la Fase 1:** en la fila FM.31.

**Pendiente con Titín:** descargar Xcode 15 (SDK 14) para compilar la 128; aprobar la tarjeta de confianza desde la app;
configurar la 5,1 en el estudio (acceso remoto de LOCAL); dos decisiones menores de FM.35 (política `BraveSyncUrl`, MV2).
Límite semanal en **aviso** (`allowed_warning`) hasta el **martes 27-10, 08:00**: nada de flujos grandes ni muchos agentes.

**Coste observado (`cost_usd` de `get_session`):** lo caro es el contexto largo releído en cada turno, no el modelo.
MOTOR-13 (Opus xhigh) portó el anchor por ~$3; INVESTIGACIÓN (Sonnet alto) ~$39 en 2 días; SEGURIDAD-PORTES-3 (Opus medio)
~$116 en 5 días al 76 %. Relevar antes ahorra más que cambiar de modelo.

## Red del entorno de la nube

El entorno de la nube (el mismo para COORDINACIÓN, el Vigía y los demás agentes de la nube; se hereda en los relevos)
tiene la red en «Personalizado», con la lista por defecto de gestores de paquetes y dos dominios nuestros añadidos por
el HUMANO el 13-10:

- `updates.flyweb.lamosquita.net`: el Vigía lee `stable/appcast.xml` cada hora y avisa si no coincide con
  `FlyWeb/web/VERSION` de `main` («WEB DESFASADA» / «WEB SINCRONIZADA»).
- `flyweb.lamosquita.net`: COORDINACIÓN comprueba la web tras cada publicación (portada, SHA, descarga).

Solo lectura y pocas peticiones. Otro dominio se le pide al HUMANO.

## Trampas de estos días

Las de fondo están en [`docs/DIRECTIVAS.md`](../../docs/DIRECTIVAS.md) y las de MOTOR, LOCAL y PUBLICACIÓN en
[`docs/TRAMPAS.md`](../../docs/TRAMPAS.md) (OR.1, 21-10). Aquí quedan las de COORDINACIÓN.

- **Hablar con propiedad a Titín** (16-10): traer algo de la red es «descargar», nunca «bajar» (lo leyó como bajar de
  versión). Siglas siempre explicadas la primera vez (WPT = Web Platform Tests, no WebGPU).
- **No encadenar avisos ni preguntas a Titín** (16-10): un mensaje con lo que hay que decidir y esperar su respuesta,
  sin mandar otro antes. Lo que ya ha decidido no se le vuelve a plantear (p. ej. las fijadas compartidas se quedan
  encendidas: se portan los arreglos de Brave o se arregla aquí).
- **Un texto de relevo con una condición delante se pierde** (14-10). El de MOTOR-8 iba detrás de «decide antes el
  modelo» y quedó enterrado entre otros avisos: el 129 se retrasó horas. Regla 13: el texto va en un mensaje propio,
  listo para pegar, con modelo y esfuerzo en la primera línea; no se archiva a nadie hasta que su relevo esté activo;
  toda orden queda escrita también en la fila del agente.
- **Relevos de agentes locales: un solo texto, sin `/remote-control`** (regla 13, cambiada el 15-10): la app ya conecta
  Remote Control al abrir la sesión, y una orden con barra pegada junto a texto se descarta entera. El agente lo
  comprueba y, solo si falta, le pide a Titín `/remote-control` sola. LOCAL-2 quedó archivada el 13-10 (~20:30) en mitad de la compilación de
  RubyLB y dejó de recibir mensajes sin que nadie lo notara: si un agente local calla, mirar `get_session`.
- **Antes de decir que algo espera la firma del HUMANO, mirar el appcast** (`curl …/stable/appcast.xml`). El 13-10 se
  le dijo dos veces que faltaba su firma cuando ya había firmado.
- **Una sesión local solo recibe `send_message` con Remote Control activo** y sin archivar. Comprobarlo con
  `list_sessions` (`connection_status`). Si alguien la archiva desde la web, la ventana sigue abierta en la 7,1 pero
  deja de recibir mensajes. Se arregla con `/remote-control` en esa ventana (PUBLICACIÓN, 12-10).
- **Repos de la sesión** (15-10): MOTOR-9 y SEGURIDAD-PORTES-2 se abrieron solo con softmac aunque el texto pedía
  también brave-core, y `add_repo` necesita un permiso de Titín para leer y **otro para escribir** (push). El agente nuevo
  comprueba en el paso 1 qué repos tiene y, si falta brave-core, lo dice en el mensaje de prueba.
- **Script del Vigía**: `--depth=200` en vez de `--shallow-since` (fallaba con más de un día sin commits en `main`).
- **Esfuerzo**: los nombres reales son low, medium, high, `xhigh` («extra») y max. MOTOR va en `xhigh`; max solo para un
  paso atascado.
- **(19-10) Mensajes cruzados:** MOTOR y LOCAL se escriben directamente; si una orden tuya cruza con la suya, deja claro
  cuál vale («la rama -ab no se usa»). Un único punto de compilación por ronda.
- **(19-10) Cuando reinicia la app de la 7,1** vuelven sesiones viejas (LOCAL-4 se reabrió): que Titín archive las viejas.
- **(20-10) Revisar lo que propone SEGURIDAD-PORTES con criterio:** un arreglo parcial en código sensible (URL) se revierte
  si crea un tercer comportamiento; mejor diferencia conocida hasta el porte completo (FM.23).
- **(20-10) Comprobar tú lo que entra en un sha** con `git merge-base --is-ancestor` antes de darlo por bueno: MOTOR-13 dio
  dos shas sin la rama de seguridad que tenía que llevar.
- **(20-10) Notificaciones de GitHub y coste:** cada PR genera dos avisos (suscripción y cierre) y **cada aviso despierta
  a COORDINACIÓN y relee todo su contexto**; con ~30 PR al día y el contexto al 60 % es un gasto real. Agrupar los cambios
  del tablero en pocos PR (uno por tanda de decisiones, no uno por fila) y relevar a tiempo. No escribir a Titín por ellos.
- **(20-10) El reinicio semanal no ha cambiado:** es a las 07:00 UTC (09:00 en verano y 08:00 en invierno en Madrid; el
  25-10 cambia la hora). Medir el gasto por tarea con `cost_usd` de `get_session`, no por intuición.

## Texto de arranque para COORDINACIÓN-9

Abrirla desde la app: nube, repo `softmac`, **Opus 5.5, esfuerzo alto (`high`)**, y pegar:

```
Eres COORDINACIÓN de FlyWeb (monorepo lamosquita-net/softmac; fork lamosquita-net/brave-core): COORDINACIÓN-9, relevo de COORDINACIÓN-8 (session_0133Pd3pUk1DtKWpYpE53qB4). Lee en este orden: CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–20, FM.28, FM.29, FM.31 y FS.20–FS.22) y FlyWeb/docs/coordinacion.md (nota de relevo del 20-10, sobre todo «Agentes y cómo hablarles» y «Trampas»: debatir con Titín antes de mover a nadie).
1. Comprueba con get_session tu modelo, si tienes send_message, tus repos y rate_limit_info. Dímelo en una línea.
2. Dame tu id de sesión y el texto exacto que debo pegar al Vigía para cambiarle el destino.
3. Anota en tu fila de docs/TAREAS.md (commit «[coord]», por PR, que fusionas tú) que COORDINACIÓN es ahora esta sesión. Avisa con send_message a MOTOR-13, SEGURIDAD-PORTES-3, INVESTIGACIÓN-MOTOR y CONTENIDOS-WEB-2 de tu id; a los de la 7,1 (LOCAL-5, PUBLICACIÓN, SERVIDOR-LOCAL-2) prueba también y, si la plataforma lo bloquea, dime qué tengo que aprobar. Archiva session_0133Pd3pUk1DtKWpYpE53qB4.
4. Abre con create_session (este entorno, repo softmac, Opus 5.5, esfuerzo medio) la sesión CONOCIMIENTO-1 para la fila OR.1 de docs/TAREAS.md (optimizar el conocimiento: archivo del tablero, DIRECTIVAS.md, arranque mínimo, manuales de método); revisa y fusiona sus PR.
5. Sigue la 1.15.2 hasta su publicación y la Fase 0 de la migración (compilación de Chromium 128 de LOCAL).
Al HUMANO se le llama Titín. Español, commits en inglés con Co-Authored-By de Claude. Breve, crítico y con conclusión; a mí solo decisiones. No me escribas por avisos rutinarios.
```
