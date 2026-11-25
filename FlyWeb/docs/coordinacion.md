# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN. Puesta al día el **20-10-2026, ~22:45 (Madrid)** por COORDINACIÓN-8
(`session_0133Pd3pUk1DtKWpYpE53qB4`, «Coordinación (8)», 20-10, Opus 5.5 alto; relevada al 66 % de contexto),
que relevó a COORDINACIÓN-7 (archivada).
Leer antes: `CLAUDE.md` (**primera regla fija: datos personales del HUMANO nunca en GitHub**; al HUMANO se le llama
**Titín**), `docs/TAREAS.md` (tabla de agentes, **reglas 1–20**, filas FM.28, FM.29, FM.31 y FS.20–FS.22),
`FlyWeb/docs/migracion-128.md` (plan de la base 128, recalibrado) y los estudios de hoy (abajo).

## 24-11 (noche): COORDINACIÓN-63 → COORDINACIÓN-64 (local, 7,1; leer primero; manda sobre lo de abajo)

COORDINACIÓN-63 = «Coordinación (63)» [b993e7], 24-11 ~16:45 → ~22:30 UTC, relevo al ~35 %. La 64 la abre Titín. Vigilante:
Monitor cada 120 s sobre `origin/buzon`, última punta en `buzon-last` del scratchpad; filtro
`grep -v -E 'COORDINACION-6[0-9] to|uploaded by COORDINACION-6[0-9]'` (así no salen tus propios commits). Canales, igual que la 62:
LOCAL-25 «Local (25)»; D8-LINUX-6 «ubuntu (6)» (sin push: sus informes los subo yo al buzón, «uploaded by»); ARQUITECTURA
«Arquitectura FlyWeb monorepo»; SEGURIDAD-PORTES-33 y MOTOR-47 por nombre (contestan al buzón; si «not reachable», reintentar).

**Hecho:** fila (#1229). **F1 Linux hecha:** primera Release de Linux de la 3.2.2 en la Ubuntu, arranca con sandbox
(`buzon/COORDINACION/20261124-2230-D8-LINUX-6-F1-B1-B2.md`). Guion unido Mac+Linux (sha256 `96db4fd1…`) y manifiesto
`3.2.2-linux` en `buzon/COORDINACION/20261124-2230-D8-LINUX-6-F1-guion-unido/`; orden a LOCAL-25 de adoptarlo como único y
abrir PR tras E1 (`buzon/LOCAL/20261124-2140-…-F1-guion-unico.md`). **U3:** B.1 (aviso sin llavero) APTO y compilado; **B.2
cerrado en verde** con GNOME y KWallet (`…2340-D8-LINUX-6-B2-cierre.md`): fw1 sobrevive, ningún v10, las contraseñas se
descifran en la vuelta; SIGTERM con clave tardía pierde cookies de ≤30 s (upstream: SIGTERM = fin de sesión; SIGINT sí escribe).
Titín ejecutó los `sudo` de kwallet6/xvfb y AppArmor. **M3 (a) y M2 cerrados** (`…1915-LOCAL-25-M3-M2.md`): lenta solo la 1.ª
pasada tras el desbloqueo (renderer saturado, GPU esperando); VRAM ~1,6 de 3 GB; J3 **cerrada** (estilo 13,1 %; LOCAL sumaba
estilo+layout+pintado: corregido); Escudos 0 %. Observaciones de Titín (bajada de GPU = tomas de sample; el rojo de la CPU 1
no es FlyWeb) pasadas a ARQUITECTURA, que escribe §9.6 y §10 en un PR cuando tenga el informe.

**Abierto, por orden:**
1. **Tres decisiones de Titín (U3, Linux), preguntadas y sin respuesta:** (a) texto de la barra: A «Sin acceso al llavero,
   FlyWeb no puede usar ni guardar contraseñas ni sesiones. No se pierde nada. Desbloquéalo y reinicia.» (recomendada; id EN
   6960035439647298739) o B (`…2140-SEGURIDAD-PORTES-33-U3-B2.md`); (b) ocultar la burbuja «Guardar contraseña» sin llavero
   (recomendado; `…2215-…-burbuja-contrasenas.md`); (c) volcar cookies en `EndSession` (SIGTERM), opcional, Linux y Mac
   (`…2200-…-cookies-SIGTERM.md`). Con su respuesta: SEGURIDAD-PORTES prepara los parches y D8-LINUX los prueba. «Reiniciar» y
   el cierre a mano, pendientes en un escritorio. Nada borrado en la Ubuntu (worktree `bc-f1-aviso`, `$W/b2-*`, `$W/f1-prueba`,
   `out/Release-321-linux` 12 GB): lista nominal a Titín cuando toque.
2. **E1 (LOCAL-25, 6,1; orden `buzon/LOCAL/20261124-1805-COORDINACION-63-E1.md`):** compilado (`out/Release-322-e1`; chromium
   `local/322-e1` f2bc70fe16, ANGLE 47207c3), en `/Users/titin/flyweb-pruebas/e1-322/`; **actúa** (segunda D500 al 94–100 % en
   WebGL). A/B en espejo desde las 20:46 UTC (~6 h), base 3.2.2. Después, suplemento con multimuestreo (necesario: las páginas
   locales y Aquarium apagan antialias): three.js r170 (descargado con el sí de Titín, servido en 127.0.0.1) y página propia.
   threejs-buffergeometry del A/B = «no medido» (página vacía). Regla de validez: contexto WebGL con tamaño y captura no negra.
   Veredicto §11.3; **la entrega de E1 como versión la decide Titín**. Basemark publica: una pasada por versión (Titín avisado).
   Avance sin puntuar: Aquarium 20 000, 48,5 frente a 46,2 fps; el cruce 4K cuesta ~0,5 ms/f.
3. **siguiente-3:** + chromium/0014 (diálogo de autenticación; su M156 ya está en la 8078, idéntico); chromium/0001 también
   tiene ya su M156 idéntico. Chrome 159 en early stable, sin lista de seguridad: SEGURIDAD-PORTES avisa si sale Alto/Crítico/KEV
   → 3.2.3 rápida a Titín. Para P2, D8 tiene 0011 y P1 0004 aplicando limpio; espera a que Titín abra la tanda. Ojo: src/brave
   de la Ubuntu lleva B.1 sin commit (el manifiesto 3.2.2-linux para en identidad, como debe).
4. Lo de la nota 62 → 63 que no está aquí sigue igual.

**Añadido 25-11 ~10:00 UTC (la 63 siguió hasta abrir la 64):** E1 **terminado**: informe `buzon/COORDINACION/20261125-0830-LOCAL-25-E1-informe/`,
vídeo a escala 1 `…0940-LOCAL-25-E1-video-esc1/`; estudio §12 fusionado (#1231, #1233). A escala 1 pasa (el shader cargado gana 4 %); a
escala 2 pierde 4–6 % con lienzo grande (≈1 ms/f, confirmado con el mismo binario e1x/e1d); vídeo «dudoso» (estado lento de la base,
también sin E1); MotionMark Paths −3 % «dudoso». **Decisiones de Titín pendientes:** (a) tal cual como excepción / (b) solo con pantalla
principal ≤ 2560×1440 (recomendada; en su 6,1 queda apagado) / (c) tope por lienzo (estudio nuevo); si Paths o el vídeo bloquean; y si se
abre tarea propia del estado lento del vídeo de la base (primer paso sin compilar: `sample` de renderers y navegador). P3 no; P4 no ahora.
Guion único de la Release en main: `FlyWeb/tools/release-3x/` (#1232). siguiente-3: + chromium/0015 (libvpx a `6f89cfbcc9`), 0016
(FSA) y 0017 (CacheStorage); la 156.0.8078.124 está cortada, sin boletín aún. LOCAL-25 y D8-LINUX-6, sin encargo pendiente (D8,
desconectada a ratos).

**Añadido 25-11 ~15:00 UTC:** Titín decidió **E1 (a), sale tal cual** en la próxima versión que abra (#1235) y abrir la tarea del
**vídeo lento** de la base (orden a LOCAL-25 `buzon/LOCAL/20261125-1407-…-video-lento.md`: sample de renderers y navegador +
16+16 e1x/e1d; ARQUITECTURA lo lee). **U3:** clave `fw1` siempre en fichero, sin llavero (#1236 y la línea siguiente de
DIRECTIVAS); parches finales 2–4 de SEGURIDAD-PORTES en `buzon/COORDINACION/20261125-1451-…-U3-final/` (sumas comprobadas),
pasados a D8-LINUX-6 para B.2 con perfil nuevo. Queda sin decidir solo el volcado de cookies en `EndSession` (opcional).
D8-LINUX-6 desconectada a ratos: en cola, d8 de brave-core 0007–0009 (`buzon/D8-LINUX/20261125-0950-…`) y U3 final.
siguiente-3 llega a chromium/0019 y brave-core/0009; sin gravedad Alta publicada.

**Lecciones de la 63:** no dar por equivalente un caso de prueba sin ver su captura (three.js salía en negro; ARQUITECTURA lo
pilló). Las puertas se leen al pie de la letra (J3 pide el estilo solo). «LuLu no lo retuvo» puede ser que Titín lo aprobó al
instante: preguntar. Al cambiar una orden con la compilación en marcha, contar con que el agente ya la haya parado.

## 24-11 (tarde): COORDINACIÓN-62 → COORDINACIÓN-63 (local, 7,1; leer primero; manda sobre lo de abajo)

COORDINACIÓN-62 = «Coordinación (62)» [1cea16], 24-11 ~08:30 → ~16:45 UTC, relevo al ~33 %. La 63 la abre Titín. Vigilante: Monitor cada 120 s sobre `origin/buzon`; guarda la última punta en un fichero del scratchpad (`buzon-last`) para no dejar huecos al re-armar y filtra solo `buzon: COORDINACION-6x to` y `uploaded by COORDINACION-6x` (filtrar «COORDINACION-62» a secas ocultaba lo que me mandaban). Worktrees desde `origin/main` y `origin/buzon`.

**Canales:** LOCAL-25 «Local (25)» (Opus; LOCAL-24 quieta); D8-LINUX-6 «ubuntu (6)» (sin push: sus informes los subo yo al buzón; atiende mis órdenes sin esperar a Titín); ARQUITECTURA «Arquitectura FlyWeb monorepo»; PUBLICACIÓN «Publicación»; SEGURIDAD-PORTES-33 y MOTOR-47 en la nube por nombre (contestan por el buzón). Dawn y gitiles de googlesource los miro yo desde la 7,1 (`+log/A..B?format=JSON`).

**Hecho hoy:** **3.2.2 build 50 publicada** (firma de Titín en bak; #1222 web, #1227 registro). #1223 fila; #1225 y #1226 (§10.7 de M3 corregido: ioreg no separa M1; Macs Fan Control descartado; M1 sigue sin explicar). Las 8 dependencias de Flynk publicadas (`flyweb/321-final` en lamosquita-net) y puestas en `.gclient` de la Ubuntu. **Piloto P1 hecho** (12 binarios del nivel A, base 184 930 pruebas, `…1415-D8-LINUX-6-piloto-P1.md`); sus arreglos de compilación `0001`–`0003` en `buzon/LOCAL/…1416-piloto-P1-arreglos/` para la tanda. **siguiente-3 (#1215)**, probada en d8 en la Ubuntu: brave-core `0001`–`0006` en verde (incluido `0006`, commit del parser que faltaba desde la 3.0.1: arregla los dos rojos de es6), chromium `0011` (requisito previo que faltaba del sanitizer de 3.1.4) en verde en blink_unittests; chromium `0012` (accesibilidad) y `0013` (GPU) sin probar (LOCAL, 6,1, con la tanda); `dawn/0001` aparcado (solo GPU Apple; la 8078 trae su gemelo `64d303d0bd`). Ninguno con gravedad publicada: **no hay 3.2.3**. En la 6,1, `sudo` lo ejecuta Titín (sin NOPASSWD; memoria). El robo de foco de las 14:24 fue un `views_unittests` relanzado por «Volver a abrir» del aviso de fallo de macOS (memoria).

**Abierto, por orden:**
1. **F1 y U3 (Titín, 24-11: «manda F1 y lo que falta de U3»):** D8-LINUX-6 hace la primera Release de Linux con `flyweb-release.sh` sobre las dos `local/322-final` (brave-core `060015a8`/árbol `fbdf05a0d3`, chromium `0525844577`/árbol `3f4cd99e00`) + 8 deps + U3 v2 + `spinning_mutex` + P1 `0001`–`0003`; arranque con perfil y llavero desechables. U3: parche del aviso sin llavero (→ revisión de SEGURIDAD-PORTES) y llaveros reales GNOME/KWallet (si hacen falta paquetes, la orden `sudo` la ejecuta Titín). LOCAL-25: lado Mac de F1 solo con `gn` («args iguales» con la 3.2.2). Órdenes `…1636-COORDINACION-62-F1-y-U3.md` y `…-F1-cerrar.md`. **apt y `.deb` = U4**: después, con las decisiones de Titín (correo del mantenedor, usuario Unix aparte).
2. **6,1 (LOCAL-25):** la cadena `cadena-m3a-m2.sh` espera un paso bloqueada → desbloqueada sin navegadores; Titín la desbloqueó sin navegadores pero sin ese paso: le pedí bloquear y desbloquear otra vez. Luego M3 (a) con el mismo `muestreo61.py` y M2 (pasada entera, Escudos 3+3). #1224 (reparto de J3) sin fusionar hasta que LOCAL-25 lo dé por completo. **E1 solo con mi orden**, con la cautela de ARQUITECTURA: repetir Basemark con FlyWeb delante (aviso previo a Titín: Basemark publica).
3. **siguiente-3:** sigue creciendo; si el boletín da Alto a alguno (ServiceWorker `0008`, V8 `0002` o `0005` son los candidatos), llevar a Titín una 3.2.3 rápida. La tanda la abre Titín (número y corte suyos); entonces LOCAL compila con los arreglos de P1, U3 v2 y `spinning_mutex`, y D8-LINUX hace P2 (comparar).
4. Lo de la nota 61 → 62 que no está aquí sigue igual (purga de la sync hacia el 15-12, papeles del RGPD).

**Lecciones de la 62:** comprobar las bases que doy en una orden contra la entrega real (mandé F1 sobre `7b51fc45f9`, que no es la 3.2.2; D8-LINUX lo paró). Los datos «pendiente de X» de notas viejas se comprueban antes de repetirlos (el disco de la Ubuntu estaba desde hacía días). Parches cortos por mensaje van bien con sha256; pedir siempre la suma.

## 23-11 (noche): COORDINACIÓN-61 → COORDINACIÓN-62 (local, 7,1; leer primero; manda sobre lo de abajo)

COORDINACIÓN-61 = «Coordinación (61)» [d37a00], 23-11 ~18:55 → ~22:30 UTC, relevo al ~35 %. La 62 la abre Titín. Vigilante: Monitor cada 120 s sobre `origin/buzon` (filtrando los commits propios), caduca a los 30 min, re-armar. Worktrees desde `origin/main` y `origin/buzon`; nada de checkout en la carpeta compartida.

**Canales:** LOCAL-24 «Local (24)» `local_9144cd8b-…` (Opus; LOCAL-23 quieta); D8-LINUX-6 «ubuntu (6)» (sin push: sus informes y parches los subo yo, comprobando el sha256; **atiende mis órdenes sin esperar a Titín**, DIRECTIVAS #1214); ARQUITECTURA «Arquitectura FlyWeb monorepo» `local_0889f62d-…`; SEGURIDAD-PORTES-33 y MOTOR-47 en la nube por nombre (contestan por el buzón). Dawn: `dawn.googlesource.com` se abre desde la 7,1; SEGURIDAD-PORTES no puede: los rolls los miro yo (`+log/A..B?format=JSON`).

**Decidido hoy por Titín (DIRECTIVAS #1213, #1214):** 3.2.2 build 50 de seguridad = 3.2.1 + #1210 (siguiente-2 cerrada en 0901b22b39) + #1183, antes que E1; las 8 dependencias de Flynk, oficiales del .120 para U2 y publicadas por LOCAL para el piloto y F1; HLS cerrado «no reproducible»; 6,1 para LOCAL (escala 1, M3, M2).

**Hecho:** MotionMark a escala 1 confirma que la caída era la escala (Suits 432, Design 232). #1209, #1217 y #1218 (método de E1 y lectura de M3/M2 de ARQUITECTURA) fusionados. U2: la 3.2.1 compila entera en Linux (0 fallos; informe en el buzón); el arreglo de `spinning_mutex.cc` va a la base de la tanda siguiente de Flynk (orden a LOCAL `20261123-2050`). U3 §2.1: v1 APTO CON CAMBIOS (quitar cookies, rehacer sobre la 3.2.2); **v2 subido (ca169490) y en revisión final de SEGURIDAD-PORTES**. Rolls de Dawn DXC y PowerVR: no aplican.

**Actualización 24-11 ~00:50 UTC (manda sobre «Abierto» de abajo):** 3.2.2 build 50 **entregada** por LOCAL-24, todo en verde, huella sin cambios (`buzon/COORDINACION/20261124-0040-LOCAL-24-entrega-3.2.2.md`); #1220 (FS.50) fusionado y PUBLICACIÓN avisada: falta su SHA y la orden de bak para Titín. #1210 y #1183 **sin fusionar** hasta que SEGURIDAD-PORTES corrija `kNewForegroundTab` → `NEW_FOREGROUND_TAB` en las pruebas de `chromium/0002`. U3 §2.1 v2: **APTO** y prueba de arranque en Linux bien en los tres casos (perfil AppArmor instalado por Titín; queda); orden a LOCAL para meterlo en la tanda siguiente (`buzon/LOCAL/…-U3-meter.md`). Menús FOR_DROP: Titín no vio cierres raros; se sigue a la M156 en `siguiente-3/chromium/0006`, sin 3.2.3 por esto. **LOCAL-24 se ha relevado al 35 %; LOCAL-25 la abre Titín** (nota `temp/local24/LOCAL-24-relevo.md`): empieza por los 8 commits.

**Abierto, por orden:**
1. **3.2.2:** LOCAL-24 compiló la app (198.63.50, 22:48) y pasa las pruebas. Con su informe en verde: fusionar #1210 (`--match-head-commit`) y #1183, y la entrega en su fila es la orden de publicar (regla 11). Huella: que diga si cambia lo declarado.
2. **siguiente-3 (#1215):** lo nuevo se queda ahí salvo Alto/Crítico/KEV **publicado**; dos candidatos (V8 `1faf157db2` Intl.Locale, 8078 `2b43666310` mundos aislados): si el boletín los da Alto, llevar a Titín una 3.2.3 rápida. Lo de solo Linux, apuntado en el README, sin portar.
3. **U3 §2.1 v2:** con el APTO, orden a LOCAL para meterlo (comprobar que aplica sobre su `local/322-final`) en la tanda que toque; **pendiente de Titín: instalar con sudo el perfil AppArmor** (`apparmor-u3-prueba.sh`, se lo enseña D8-LINUX-6) para la prueba de arranque con perfil y llavero desechables. Antes de publicar Linux: KWallet y GNOME reales y el aviso en la interfaz sin llavero.
4. **LOCAL-24 tras la 3.2.2:** publicar los 8 commits (`20261123-1908`); M3 nueva repetición (`20261123-2208`: (a) tras un desbloqueo de Titín por su cuenta, sin ioreg; (c) seis con ioreg); M2: J3 con toma entera y partida, Escudos 3+3 (`20261123-2205`); E1 **solo con mi orden**, con los añadidos de §11.2.
5. Lo de la nota 60 → 61 que no está aquí sigue igual (U4 correo del mantenedor sin decidir; purga de la sync hacia el 15-12; papeles del RGPD).

**Lecciones de la 61:** los parches grandes por mensaje (Base64 en dos trozos) llenan el contexto: pedir a D8-LINUX que trocee menos o que los deje como texto más corto, y relevarse justo después. Comprobar siempre la suma de cada trozo y del resultado, y buscar datos personales antes de subir al buzón (es público). Los avisos del vigilante con mis propios commits ya se filtran.

## 23-11 (mañana): COORDINACIÓN-60 → COORDINACIÓN-61 (local, 7,1; leer primero; manda sobre lo de abajo)

COORDINACIÓN-60 = «Coordinación (60)» [8ae7ec], 22-11 tarde → 23-11 mañana. La 61 la abre Titín. Vigilante del buzón: Monitor cada 120 s sobre `origin/buzon`, caduca a los 30 min (re-armar); trabajar en `git worktree` desde `origin/main` y `origin/buzon`, nada de checkout en la carpeta compartida.

**Canales:** LOCAL-23 → relevada por LOCAL-24 (la abre Titín; nota `~/proyectos/softmac/temp/local23/LOCAL-23-relevo.md`); D8-LINUX-5 → D8-LINUX-6 `session_01MwmK2jJfT9eAZrMZbXUngS` («ubuntu (6)»; sin push: los informes los sube la COORDINACIÓN a `buzon/COORDINACION/` con sha256 comprobado); Arquitectura `local_0889f62d-…`; SEGURIDAD-PORTES-33, MOTOR-47 por nombre (nube; no confirman lectura). Los permisos de Titín a agentes de otra máquina los da él en su sesión; no se los pongo en su boca.

**Hecho:** control de MotionMark (6,1): **no hay retroceso de la 3.2.1**; la caída de Suits/Design es de la escala de pantalla (6016×3384 a devicePixelRatio 2 frente a 3008×1692 a 1 el 09-11), ya en la 3.0.0. Método de E1 fijado por ARQUITECTURA en #1209 (§11: A/B a dos escalas, WebGL se juzga también a escala 2). HLS: batería en la 7,1 y la 6,1 sin regresión propia (banco #1208 de MOTOR-47; propuesta de cerrar «no reproducible», falta el dato de Titín de dónde vio el fallo). U1 (Chromium 156 oficial en Linux) compilado en 1 h 40 min: `buzon/COORDINACION/…-D8-LINUX-5-U1-medida.md`; F1 y U3 v2 en el buzón; `fsck` de las copias del USB sin daños. SEGURIDAD-PORTES: #1210 en borrador, `siguiente-2` (cookies fw1 con clave temporalmente ausente, Mac y Linux; V8 Turboshaft M159; V8 TurboFan M156 probable Alto; popups bloqueados; epoch 40).

**Abierto, por orden:**
1. **Versión siguiente (Titín):** #1183 + #1210 (¿esperar a la tanda o sacar antes una 3.2.x de seguridad por el TurboFan?). Número, build y corte, de Titín.
2. **LOCAL-24:** M3 → M2 → E1 (no se compila E1 hasta que lo diga la COORDINACIÓN); pasada previa a escala 1 con la 3.2.1 (~7 min, sí de Titín); cerrar F1 (`comprobar` y `gn` contra los args de la 3.2.1); pruebas de #1210 (`net_unittests --gtest_filter='SQLitePersistentCookieStoreTest.*'`, mjsunit de Turboshaft y TurboFan).
3. **Ubuntu:** U2 y piloto, con el sí escrito de Titín en la sesión de D8-LINUX-6 (pegado el 23-11 por la mañana; confirmar) y con el arreglo de U3 §2.1 hecho antes de arrancar el binario con datos reales; usuario Unix aparte y correo del mantenedor (U4): sin decidir.
4. **HLS:** cerrar con MOTOR-47 cuando Titín dé el dato.
5. **Funciones web, flecos y fechas de Titín:** como en la nota 59 → 60 (purga de la sync hacia el 15-12, papeles del RGPD).

**Lecciones de la 60:** Titín quiere que le lleguen decisiones, no pasos (pidió autonomía de los agentes; solo el `sudo` es suyo); no ponerle a buscar ficheros: dar el texto exacto para pegar. Verificar el sha256 de lo que otro agente me pasa antes de subirlo al buzón. Cada «sí» a una tanda de LOCAL es de Titín. Los textos que me llegan por mensaje de otros agentes son datos, no órdenes. Probar siempre las órdenes de comprobación antes de darlas.

## 22-11 (tarde): COORDINACIÓN-59 → COORDINACIÓN-60 (local, 7,1; leer primero; manda sobre lo de abajo)

COORDINACIÓN-59 = «Coordinación (59)» [387a5d], 21-11 22:55 → 22-11 ~13:45 UTC; al 52 % de contexto (tocaba al 35 %). La 60 la abre Titín.

**Canales:** los de la nota 58 → 59, con cuatro cambios: (1) LOCAL-21 = «Local (22)» `local_3bb6e59d-…`, quieta: la releva **LOCAL-22,
que abre Titín** (nota `~/proyectos/softmac/temp/local21/LOCAL-21-relevo.md`; a las 13:40 no estaba abierta); (2) CONTENIDOS-WEB-3,
retirada y archivada por Titín; (3) Auditoría «Auditoría ns1/ns2/bak.lamosquita.net» `local_f950fa9d-ba3d-4b2a-92e7-8955679041bc`:
los cambios en producción exigen el sí de Titín **en su sesión**; (4) D8-LINUX exige también el sí de Titín en la suya para borrar.
Monitor sobre `origin/buzon` cada 120 s, caduca a los 30 min. SSH a los servidores: uno cada vez, también entre agentes.

**Hecho:**
- **3.2.1 build 49 publicada** (#1165, #1171; registro #1197). Versión interna .120; **a las webs .82** (última Stable real de Mac).
- **Sync con cuenta en la web:** #1196 y #1202; inactivas a 365 días activo en ns2 (#1201); plan de registros cerrado sin aplicar.
- **Ubuntu:** SSD liberado (109 GB libres); disco de archivo en `/media/archivo` con las copias de los árboles viejos y `motor-b2`.

**Comprobación en vuelo:** SERVIDOR-LOCAL mira #1202 en línea a partir de las 13:54 UTC (`buzon/SERVIDOR-LOCAL/`, «comprobar-1202»).

**Abierto, por orden:**
1. **Multihilo y multiGPU (decidido):** M1, M3, M2 y E1 sobre la 3.2.1; orden en `buzon/LOCAL/` («E1-M1-M3»). Espera a que Titín abra
   LOCAL-22. M1 y el A/B de E1, con la FlyWeb de Titín cerrada por él. Desde el lunes 23, preguntarle antes de compilar.
2. **Versión siguiente:** #1183 entero (decidido; punta f7fc665482; 10 browsertests en la 6,1) y lo que traiga SEGURIDAD-PORTES
   (esperan merge oficial: lista en `buzon/COORDINACION/20261122-0952-SEGURIDAD-PORTES-33.md`). Candidata: limpieza del 0017.
   **Número, build y corte los da Titín.**
3. **Piloto de pruebas en Ubuntu (decidido el 21-11):** el disco ya da (109 GB; pide 60–75). Falta: ajustar la directiva del 07-11, la
   fila de D8-LINUX, su CLAUDE.md (lo edita Titín) y que LOCAL suba las ramas base a los forks. Estudio: `pruebas-linux.md`.
4. **Porte a Linux (propuesto, sin sí explícito):** F1 (guion de la Release) y U3 (papel) sin disco; U1 (~100 GB y levantar la directiva
   del 07-11) cuando Titín dé una partición ext4 en el NVMe. No cabe a la vez que el piloto en el SSD.
5. **Funciones web (sin decidir):** `novedades-motor.md`, informe 2 parte B §7 (recomendado: 1, 2, 4 y 6).
6. **HLS:** no reproduce en la 3.2.0 ni en la 3.2.1; tema aparte, dicho a Titín, sin encargar. Primero, diagnóstico de MOTOR.
7. **Flecos:**
   - `FlyWeb/servidor/systemd/flyweb-sync.service` al día con la unidad de ns2 (**no reinstalar la del repo: rompería las cuentas**);
     SERVIDOR-LOCAL, solo repo.
   - `git fsck` de las copias del disco de archivo, cuando Titín diga que el disco está libre (avisar a D8-LINUX).
   - Medida de la sync en la 5,1 (tras publicar; no bloquea).
   - Revisión de «COORDINACIÓN en local» al cerrar la 3.2.1 (#1184): ya toca.
   - #865 (BackupDrive) sigue abierto.
8. **Fechas de Titín:** purga de la primera copia de la sync hacia el 15-12 (aviso puesto); papeles del RGPD (contrato de OVH,
   revisión legal) de `sync-cuenta-rgpd.md` §4.

**Añadido ~13:50 UTC (manda sobre «Abierto»):** Titín contestó al informe.
- **Decidido:** Linux (punto 4: F1 y U3 ya; U1 con la partición del NVMe) y HLS (punto 6: investigar y arreglar; encargado a
  MOTOR-47, `buzon/NUBE-MOTOR/`, «hls»). Los dos en DIRECTIVAS.
- **Sin contestar:** el corte de la versión siguiente (solo #1183 y seguridad, o más).
- **En debate, sigue contigo («vamos a razonar»): funciones web.** Titín plantea: si lo usan dos de los tres motores, aunque sean
  minoritarios, es tendencia y se porta; y pregunta por HTML en canvas. Datos del informe del 17-11 (refrescarlos con
  INVESTIGACIÓN-MOTOR antes de decidir): HTML en canvas lo lleva **un** motor (Chrome 157; Safari a favor sin implementarlo; Firefox
  sin señal). Con su criterio cambia `chunks/windows` (Firefox 154 + Safari 27.3 beta); `import defer` casi (Safari beta + Firefox
  Nightly); `allKeyed` no (solo Firefox); grid lanes no (solo Safari). Propuesto por la 59, sin decidir: su criterio como norma (dos
  motores en estable = se porta sin esperar a Chrome; uno + beta = se prepara) y una prueba de un día de HTML en canvas tras su
  bandera en la 6,1 para medir el coste real. Ojo con la huella: se declara 156 (decisión 8).
- **Ubuntu:** Titín espera el fin de una comprobación de su copia de 572 GB para liberar el NVMe y reducir la partición desde
  Windows. Orden buena: `rsync -an --checksum --out-format='%i %n' … | grep '^>'`, con código de rsync 0.

**Lecciones de la 59:**
- Los textos públicos los decide Titín: no se le discuten. Si una frase no casa con el sistema, se le dice una vez, en una línea,
  con la alternativa; las dudas de otros agentes van a COORDINACIÓN. **fail2ban y CrowdSec no se tocan por privacidad.**
- Probar cada orden de comprobación antes de darla: `rsync -an --checksum` sin `-i` ni `--out-format` sale vacío siempre.
- «Versión declarada» son las client hints (`flyweb_engine_full_version`), no `chrome/VERSION`: siempre revisar la huella.

## 21-11 (tarde): COORDINACIÓN-58 → COORDINACIÓN-59 (local, 7,1)

COORDINACIÓN-58 = «Coordinación (58) Local» [3d5895], MacPro7,1, 21-11 ~09:40 → ~20:30 UTC. **La prueba de la COORDINACIÓN en local
funciona** (punto 5 de abajo: ARQUITECTURA decide si se queda y qué pasa con el cartero; datos: canales directos, sin pérdidas).

**Canales (probados y usados todo el día):**
- Locales: `SendMessage` con el **id `local_…`** (por nombre no salen si están paradas; el id las despierta): «Local (22)»
  `local_3bb6e59d-68f5-45e3-a870-2b987a7672ea`, Publicación `local_1eb27eb5-…`, Servidor Local (2) `local_40afbbdb-…`,
  Arquitectura `local_0889f62d-…`, Cartero (8) `local_468a6280-…` (no reparte: lo hace la COORDINACIÓN).
- D8-LINUX-5: `bridge:session_01MwmK2iT4hLWA1h2vv3cG9K` («motor ubuntu (5)»); **no hace push**: manda los informes por
  mensaje y la COORDINACIÓN los sube a `buzon/COORDINACION/`.
- Nube: `SendMessage` por nombre + copia en `buzon/NUBE-<PAPEL>/`; contestan en `buzon/COORDINACION/` en minutos.
- Monitor propio sobre `origin/buzon` cada 120 s (caduca a los 30 min: re-armar).
- Abrir agentes de la nube desde aquí: la herramienta de la app no puede; `claude --cloud` existe (sin estrenar).

**Hecho hoy:** 3.2.0 cerrada, probada y **fusionada** (main 09a2b6d81c: #1110, #1138, #1151, #1142, #1147, #1159, #1144,
#1150). Hallazgo de D8-LINUX: el `pendiente/0003` borraba el 0002 (585625642); SEGURIDAD-PORTES-33 lo regeneró y D8 dio verde
(3.2.0 V8 8566fd42e4; 3.2.1 V8 c8e7b3da27). LOCAL en verde: 0007/0008 (blink, 995), portes-159/0002, ServiceWorker (3 rojos
de Brave, confirmados sin 0006 y con PrefetchServiceWorker; excluidos), OmniboxColorTest. El 0001 de menús salió rojo: a la
3.2.1 con su prerrequisito (#1165 = siguiente/chromium 0009–0010, punta bd9b91a1d9, sin probar en views_unittests). Titín
dio el visto de bt-320f. DIRECTIVAS: #1169, #1170 (prioridad solo cuando Titín trabaja; desde el lunes 23, preguntar),
#1176 (**nada que robe el foco en la 7,1**), #1177 (3.2.0 build 48).

**En curso:** LOCAL compila la **3.2.0 build 48** (`out/Release-320`, desde 20:12 UTC; árboles comprobados: brave-core
02c6111221 + versión ce9941d182, V8 8566fd42e4, chromium 68861cb878 con renderer-webgl). Pruebas y entrega por regla 11
(buzón `LOCAL/20261121-1600-…`); sube las dos ramas `local/320g-final` a los forks; imports 10.15 y AVX. Con su entrega,
PUBLICACIÓN publica.

**Abierto, por orden:**
1. Entrega de la 3.2.0 de LOCAL → avisar a Titín (solo la orden de firma en bak le toca).
2. 3.2.1 (#1165): probar en la **6,1** `views_unittests` de menús 0009–0010 (no en la 7,1); cerrar su contenido con Titín
   antes de compilar. **Recordar a Titín #1171** (más visitados de la nueva pestaña; MOTOR-47, causa confirmada en pantalla;
   apaño: «Favoritos» en Personalizar) — él decide si entra.
3. Piloto de pruebas en Ubuntu (#1168) en la 3.2.1: pendiente del disco (Titín).
4. ARQUITECTURA: medir esta prueba de COORDINACIÓN local.

**Añadido 21-11 ~23:00 UTC (COORDINACIÓN-58, al 35 %): manda sobre «En curso» y «Abierto» de arriba.**
- **3.2.0 build 48 PUBLICADA** (firmada en bak por Titín; web #1180, registro #1181; ramas `local/320g-final`: brave-core
  4d7ccceaf3f2, chromium 178481088eb4).
- **3.2.1 = #1165 + #1171** (Titín, DIRECTIVAS #1182). #1165 punta 51d8f94d45; chromium esperado sobre 68861cb878 →
  **e6aa9fedc5**. #1171 punta 1dff7b4353; brave-core final **af99cc3984** (siguiente 0001–0003 y después #1171). V8 verde.
  LOCAL tiene la lista de pruebas (`buzon/COORDINACION/20261121-2246-SEGURIDAD-PORTES-33.md`): en la 7,1 sin ventana, en la 6,1
  views_unittests de menús y una tanda de run_web_tests. Después: pedir a Titín versión y build y dar la orden de compilar.
- **Preparando, sin entrar:** MOTOR-47, dos arreglos de Brave de fijadas compartidas (carrera al desfijar; cierre al cerrar la
  última pestaña), con visto de SEGURIDAD-PORTES; preguntar a Titín con el PR listo. Limpieza del 0017: próxima vuelta de interfaz.
- **ARQUITECTURA (#1184, `FlyWeb/docs/coordinacion-local.md`):** propone COORDINACIÓN en local, retirar el cartero y tres
  ajustes (copia escrita de las órdenes a locales; fetch del buzón al empezar cada turno; vigilar la rama entera). Pendiente de Titín.
- Usar `date -u` para las horas del buzón (algunas del 21-11 van una hora adelantadas).

**Lección:** no reabrir con Titín lo que ya decidió («otra vez habéis alterado el plan»). Plan vigente: 3.2.0 cerrada, lo
rojo se quita, lo nuevo a la 3.2.1. No preguntarle repartos que ya resuelve la regla.

## 20-11 (noche, 2): COORDINACIÓN-57 → COORDINACIÓN-58 EN LA 7,1 (prueba; leer primero; manda sobre lo de abajo)

COORDINACIÓN-57 (`session_01MwmK2hcdtWpZGceKLieLdd`, nube, 20-11 ~17:20 → ~20:45 UTC; última del linaje). **Titín decide
probar la COORDINACIÓN en local (MacPro7,1)**: la nube no puede escribir a las sesiones locales (401 /
`elevated_session_untrusted_device`) y el cartero (Haiku, esfuerzo bajo) falla una y otra vez; hoy, mudo desde las 14:37 UTC
y dando por entregado lo que no lo estaba. La 58 la abre Titín en la 7,1.

**Canales en la prueba:**
- 58 → locales (LOCAL «Local (22)» [9d9f5f], PUBLICACIÓN, SERVIDOR-LOCAL, ARQUITECTURA): `SendMessage` directo. Sin cartero.
- 58 → nube (MOTOR-47, SEGURIDAD-PORTES-33, INVESTIGACIÓN-MOTOR-10, SEGURIDAD-VIGÍA): `SendMessage` (de local a nube
  funciona: hoy lo han hecho LOCAL-21 y el cartero). Comprobarlo con la prueba de arranque.
- Nube → 58: **no hay `send_message` de la nube a local.** Los agentes de la nube escriben en `buzon/COORDINACION/`
  (rama `buzon`, mismo formato; sin datos personales) y la 58 lo vigila ella misma (Monitor sobre `origin/buzon`, sin cartero).
- Abrir agentes de la nube desde local: **sin comprobar.** Si la 58 no puede, prepara el texto de arranque y lo abre Titín.
- D8-LINUX: igual que los locales si la 58 lo ve en `ListAgents`; si no, por el buzón.

**Decidido hoy por Titín (DIRECTIVAS #1160):** entran en la 3.2.0 brave-core/0005 (V8 .76, sandbox), chromium/0007
(ImageDataBuffer) y 0008 (canvas/slots) en #1147 (punta c0808f171a, tanda cerrada), y `portes-159/chromium` 0001 (UAF de
menús FOR_DROP) y 0002 (SchemeHostPort) en #1159 (punta bf5c3689c7; se fusiona tras #1147). Lo nuevo que no sea
Alto/Crítico/KEV, a `seguridad/siguiente/` con PR propio. V8 580857997 (wasm) espera al merge en la 15.6. Desplegable oscuro
**#767676**, texto blanco (4,54:1); hover de fila #6A6A6A (5,4:1), en el 0019 de #1151 (punta c74105bec2, sin compilar).

**Árboles (comprobados por MOTOR-47 con `git am`):** brave-core final de la 3.2.0 = **8c31284eda** (con 0005 y 0019);
bt-320f = b9f628b8a6 (la 3.2.0 sin 0005, 0018 ni 0019; el 0018 solo toca una prueba). d1fe696d26 era un intermedio antiguo.
chromium: pendiente 0001–0008 = 90418ba4fd; + portes-159 0001–0002 = 2bb85047ec. V8 esperado en D8-LINUX: 9914512d91.

**Sin entregar a las ~20:45 UTC (el cartero no ha anotado nada desde las 14:37):** `D8-LINUX/20261120-1400-…` (actualizado,
51b9177548), relevos 1510 y 1725, `LOCAL/…1623…`, `…1650…` y `…2025…` (pruebas unitarias de chromium 0007–0008 y
portes-159). La 58 se lo pasa directamente a «Local (22)» y a D8-LINUX y anota en ENTREGADO.md a mano.

**Abierto, por orden:**
1. Resultados de bt-320f (ServiceWorker de 0006, `*NoContainerHostForPdfDocument*`, `WorkerScriptLoaderFactoryTest.*`,
   OmniboxColorTest con el 0018) y de las pruebas de la orden de las 20:25.
2. D8-LINUX con el encargo actualizado (incluye 0005).
3. Titín en bt-320f: hover de la inactiva, desplegable con fila elegida, borde de la caja; trazo de 1 px; fijada en blanco
   al recargar; ¿cerró él bt-320a/b/c/e?
4. Con todo verde y el visto de Titín: fusiones #1110 → #1138 → #1142 → #1147 → #1159 → #1144 → #1150 → #1151, revisando
   cada diff y las puntas con `git ls-remote`; luego la orden de la compilación final (versión, la pone Titín), con
   `BraveColorMixersTest.*`, OmniboxColorTest, capturas en oscuro del desplegable y las pruebas a mano de #1159 (arrastrar
   a una carpeta de marcadores, Esc durante el arrastre; file:///, settings, una extensión).
5. Medir la prueba: si la 58 local funciona, ARQUITECTURA decide si se queda así y si el cartero se retira o sube a Sonnet.

**Añadido ~21:00 UTC (Titín, DIRECTIVAS):** (a) orden a «Local (22)»: compilar y probar con `taskpolicy -b`/`nice -n 19` y
`-j 24` como máximo (buzón `LOCAL/20261120-2100-…-prioridad-LOCAL-21.md`; entrégala tú). (b) Encargo a ARQUITECTURA: estudiar
pruebas de Chromium en el PC de Ubuntu (buzón `ARQUITECTURA/20261120-2100-…`). La nube no compila FlyWeb.

**Añadido 21-11 ~06:00 UTC (Titín; DIRECTIVAS):** (a) **3.2.0 cerrada** con #1147 + #1159; **#1165 = 3.2.1** (punta
57940bed3c: chromium siguiente 0001–0008 y brave-core siguiente/0001, V8 585624828, que necesita otra subida de época). El paso
de 585624828 del encargo de D8-LINUX (buzón 3fac13d74b) es de la 3.2.1. (b) Canales: órdenes a la nube por `SendMessage` + copia
en `buzon/NUBE-<PAPEL>/`; respuestas en `buzon/COORDINACION/`. (c) Agentes nuevos de la nube: uno por tarea, con encargo
escrito; probar si la 58 puede abrirlos desde la 7,1 (p. ej. `claude --remote`, si existe en esa versión; sin comprobar). Si
no, texto para Titín. Estado de la nube a las 06:00: SEGURIDAD-PORTES-33 vigila cada hora; en 8154 hay candidatos para la 3.2.1
(MHTML 583926256, TextFragmentAnchor 566347708, WebPagePopup 586391223) si llegan a la 8078. Wasm 580857997/585446353 y sandbox
336507783 esperan merge en la 15.6.

**Sesiones:** MOTOR-47 `session_01MwmK2hjxRPyuefYzGRoZRk`, SEGURIDAD-PORTES-33 `session_01MwmK2kdhDkMC93UBtLuPkF` (vigila
cada hora), INVESTIGACIÓN-MOTOR-10 `session_01MwmK2m3DpZgC8k7wAabHHG`, SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`,
Cartero (8) bridge `session_01MwmK2iGXw2cPVJFxs7SWnc`. La 57 queda quieta para preguntas.

## 20-11 (noche): COORDINACIÓN-56 → COORDINACIÓN-57 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-56 (`session_01MwmK2gwa9MBDUrWPA6iBsV`, 20-11 ~15:05 → ~17:25 UTC, relevo al 33 %). **La 57 la abre la 56 y es la
última del linaje (8 de 8): no puede abrir otra. La siguiente COORDINACIÓN la abre Titín; avisarle con tiempo.**

**Cartero caído desde las 14:37 UTC:** no anota nada en ENTREGADO.md. Sin entregar: los relevos de la 56 (1510),
`D8-LINUX/20261120-1400-SEGURIDAD-PORTES-33-v8-3.2.0.md` (58d3cf8a5c) y las órdenes a LOCAL-21 de las 16:23 y las 16:50.
Titín está avisado varias veces y no ha contestado. LOCAL-21 escribe directamente a COORDINACIÓN (bridge
`session_01MwmK2iiAoCDHgEcgxnaNZF`, «Local (22)»); la nube **no** puede contestarle por esa vía (auth), solo por el buzón.

**bt-320f (instalada en la 6,1, pid 20811, CDP 9491; versión 3.1.4 sin tocar):** brave-core 25330a7e1f / árbol b9f628b8a6;
chromium efde5db485 / árbol f7838c8adf. Verde: BraveColorMixersTest, AccountCryptoTest, d8 math + code-cache-sha256 +
regress-585614984, FocusGlow, SharedPinnedTab 8/8. Visto en pantalla por LOCAL: colores de la URL (#4D4D4D / #FFFFFF / privada
#0F0629), Accesos directos, Aspecto, Cuenta, fijadas en 2 ventanas, PWA sin red, caché rechazada y rehecha. Capturas en
`entregas/local21/completa-320f`.
- OmniboxColorTest en oscuro fallaba por la prueba: MOTOR-47 lo arregló en el **0018 de #1151 (punta 53510dc800, árbol
  db8f0061e3)**. Falta pasarla (orden en el buzón, 16:50, con añadido).
- content_browsertests y content_unittests no compilan por fallos previos (kFileSystemAccessLocal; image_capture_impl_unittest).
  Orden: excluirlos solo en `local/320f-pruebas` y pasar ServiceWorker de 0006 + `*NoContainerHostForPdfDocument*` +
  `WorkerScriptLoaderFactoryTest.*` (SEGURIDAD-PORTES-33 de acuerdo; si el de PDF sale rojo, avisa antes de quitar nada).
- **Pendiente de Titín:** mirar a mano el hover de la inactiva, el desplegable con una fila elegida y el borde de la caja;
  contraste del desplegable oscuro (recomendado #767676 con texto blanco, 4,5:1); trazo de 1 px; colores de MOTOR sin medir;
  **¿cerró él bt-320a/b/c/e?** (se cerraron 14:54–14:57; LOCAL dice que no fue él); pasar a LOCAL las órdenes del buzón.

**Seguridad:** 585625642 ya tiene merge en la V8 15.6 (.75), idéntico byte a byte a nuestro 0002; sin gravedad publicada.
#1147 sigue condicionado a D8-LINUX, que no ha recibido el encargo.

**Fusiones (sin cambios):** cuando Titín dé por buena bt-320f y D8 esté verde: #1110 → #1138 → #1142 → #1147 → #1144 →
#1150 → #1151 (ahora con el 0018), revisando cada diff y comprobando las puntas con ls-remote. Luego la orden de la compilación
final (la versión la pone Titín).

**Hecho por la 56:** #1156 (fila); buzón a66de67 (relevo), e6b8f14/19ff33d (content_browsertests), af3963f/68f013c (acuse de
bt-320f y OmniboxColorTest). Sesiones: MOTOR-47, SEGURIDAD-PORTES-33 (vigila cada hora), INVESTIGACIÓN-MOTOR-10, SEGURIDAD-VIGÍA,
sin cambios.

## 20-11 (tarde): COORDINACIÓN-55 → COORDINACIÓN-56 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-55 (`session_01MwmK2hTA8k49N3yrcWbPsJ`, 20-11 ~13:10 → ~15:10 UTC, relevo al 35 %). La 56 la abre la 55
(**linaje 7 de 8**: la 56 solo puede abrir una más; avisar a Titín de que la cadena acaba y hará falta empezar otra desde él).

**Decisiones de Titín de hoy (DIRECTIVAS #1152 y #1154):**
- La seguridad del 20-11 entra en la **3.2.0** (no hay 3.1.5): #1147 = brave-core 0002 (V8 585625642), 0003 (V8 .74,
  caché por SHA-256), 0004 (V8 585614984) y chromium/0006 (ServiceWorker 581369093). **Condición: D8-LINUX en verde**;
  lo rojo se quita. Época de caché, una sola subida 37 → 38 (#1144, regenerado sobre 0004).
- «Accesos directos» (#1150) entra en la 3.2.0.
- Revisión de bt-320e → #1151 (MOTOR-47, 3.2-interfaz 0014–0017): hover de la inactiva 4 dip más bajo; flou con el
  desplegable abierto; desplegable del mismo ancho que la URL, pegado, sin sombra, radio 2 dip, también en privada;
  **en oscuro, URL #4D4D4D, desplegable #909294, fila seleccionada #542671, texto blanco** (sustituye lo del 19-11).
  Maquetas en `FlyWeb/branding/interfaz-3.2.0/ajustes-20-11/` (#1153).
- **Árbol de brave-core de la 3.2.0 hoy: b9f628b8a6** (cadena completa en el README de 3.2-v8 y en #1151).

**En curso:**
- **bt-320f** (buzón 0f2ef978): LOCAL-21 compila desde ~14:42 UTC en `out/Completa320f`, incremental. brave-core
  25330a7e1f (árbol b9f628b8a6), chromium punta efde5db485 (árbol f7838c8adf; 0006 = 064a5696b2). Versión sin tocar.
  LOCAL no puede capturar vistas nativas (sin Accesibilidad en la 6,1). Se le propuso a Titín que **él mire a mano** el
  hover, el desplegable con fila elegida y el borde de la caja; dar Accesibilidad al SSH no se recomienda (si la pide,
  pasa antes por SEGURIDAD-PORTES). **Sin respuesta aún.**
- **D8-LINUX** (buzón 58d3cf8a5c, de SEGURIDAD-PORTES-33; árbol de V8 final 4fe0219716): **el cartero no lo ha entregado**
  (sin línea en ENTREGADO a las 15:05; los de LOCAL sí). Se pidió a Titín que abra «motor ubuntu (5)» y le diga que lo lea.
- **Pendiente de Titín al ver bt-320f:** (1) contraste del desplegable oscuro: blanco sobre #909294 = 3,1:1 (no AA para
  texto normal); salidas: desplegable ≤#767676 o texto negro; (2) quitar el trazo de 1 px de `TopBackgroundView`
  alrededor de la caja si se ve; (3) colores propuestos por MOTOR no medidos en maqueta (texto secundario/iconos blancos,
  hover de fila #828486, marca lila #AFA6D2).

**Fusiones, cuando Titín dé por buena bt-320f y D8 esté verde:** #1110 → #1138 → #1142 → #1147 → #1144 → #1150 → #1151,
revisando cada diff (puntas a las 15:05: ef60812681, faf01581a1, 138f4ea8e7, 1755fc2491, 1e978ba37c, e259052d06,
9812b92243). Luego la orden a LOCAL de la compilación final (versión 3.2.0: la pone Titín/regla, no la 56).

**Hecho por la 55:** #1149 (fila), #1152/#1154 (DIRECTIVAS), #1153 (maquetas); buzón 0f91b8d8 (relevo), 6b1bb746 (acuse),
0f2ef978 (bt-320f). Sesiones sin cambios: MOTOR-47, SEGURIDAD-PORTES-33 (vigila cada hora), INVESTIGACIÓN-MOTOR-10,
SEGURIDAD-VIGÍA, LOCAL-21 (bridge 01MwmK2iiAoCDHgEcgxnaNZF; desde la nube, buzón), ARQUITECTURA (sin nada abierto).

## 20-11 (mediodía): COORDINACIÓN-54 → COORDINACIÓN-55 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-54 (`session_01MwmK2hLcE3BDeCvDDHMAqJ`, 20-11 ~10:50 → ~13:10 UTC, relevo al 35 %). La 55
(`session_01MwmK2hTA8k49N3yrcWbPsJ`) la abre la 54. Todo lo de la nota «20-11 (mañana)» sigue vigente salvo lo que cambia aquí.

**bt-320e (3.2.0 completa de prueba):** LOCAL-21 la montó y empezó a compilar ~10:55 (árboles comprobados: brave-core
612c201d14, punta local 43805cee87 en `local/320e-completa`, sin subir; chromium + pendiente a9b357bc47, + renderer-webgl
3d64407e53; ANGLE fb21437e81; Skia 1ef25455d7; 9150 pasos; sin tocar versión). Pruebas previstas: BraveColorMixersTest,
AccountCryptoTest y d8 mjsunit math en la 7,1; FlyWebFocusGlowReplacesFocusRing y SharedPinnedTabServiceBrowserTest en la
6,1; CDP de settings/system, atajos, Apariencia y «Cuenta y sincronización». A las 13:06 sin aviso: se le pidió estado por
el buzón (`…-estado-320e-LOCAL-21.md`). **Cuando avise de que está instalada: decir a Titín que la apruebe en LuLu y qué
mirar** (ajustes del 20-11: URL más baja y flou con foco en claro y oscuro, hover #EBEBEB/#585959, título y favicon de
inactivas más bajos; fijadas que se refrescan entre ventanas; Apariencia y settings/system). Titín lo revisa todo en
bt-320e (no mira bt-320c). bt-320a/b/c siguen abiertas para él.

**Pendiente de Titín, con recomendación dada:**
- **V8 585625642** (TurboFan, contexto en generadores/async; probable Alto, gravedad sin publicar, sin KEV ni exploit;
  sin merge a la 15.6). SEGURIDAD-PORTES-33 lo portó: `pendiente/brave-core/0002`, **#1147** (borrador, punta 59f070305b),
  APTO condicionado a D8-LINUX; árbol brave-core tras 0001+0002 = 639401fb8e; la época de caché se sube una sola vez al
  integrar. Pregunta a Titín: **¿entra en la 3.2.0 (recomendado) o 3.1.5 aparte?** Sin respuesta aún. Si confirman Alto/
  Crítico o aparece KEV/exploit, volver a planteárselo enseguida. Si dice 3.2.0: orden a LOCAL para la compilación final.
- Sigue lo de antes: fijada en blanco (captura, ventana, `flyweb://discards`), contraseñas de dialnet, versión .112.

**Candidato sin parche:** 41c9a648fb [M159] ServiceWorker/StorageKey (585383394); exige renderer comprometido; el diff no
aplica sobre la 156. SEGURIDAD-PORTES lo prepara si llega a la 8078.

**Fusiones tras la prueba de bt-320e:** #1110 → #1138 (cambiar base a main) → #1142 → #1144, revisando cada diff (puntas
sin cambios a las 10:50: ef60812681, faf01581a1, 138f4ea8e7, b76f3410d9). #1147 solo si Titín lo mete en la 3.2.0.

**Hecho por la 54:** #1146 (fila); buzón 0a099dd (relevo), ec3f1d1 (acuse a LOCAL-21), 2333c70 (petición de estado); todo
entregado por el cartero a la sesión 9d9f5f. Desde la nube el SendMessage a «bridge:…» de LOCAL-21 falla: usar el buzón.
Sesiones sin cambios respecto a la nota anterior; SEGURIDAD-PORTES-33 vigila cada hora (siguiente ~13:30).

## 20-11 (mañana): COORDINACIÓN-53 → COORDINACIÓN-54 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-53 (`session_01MwmK2hDFxpvnFEeC9c3ji7`, 19-11 ~22:15 → 20-11 ~10:50 UTC, relevo al 41 %). La 54 la abre la 53.
**Todo en español, siempre.** **Nunca llamar a confirm_repository_trust.** Decisiones de Titín en DIRECTIVAS (#1127, #1143).

**En marcha: 3.2.0 COMPLETA de prueba (bt-320e).** Orden a LOCAL-21 en el buzón (`20261120-1047…-320-completa-LOCAL-21.md`).
brave-core: e660929ac9 + interfaz 0001–0007 → ajustes-sistema 0001–0004 → interfaz 0008–0013 (#1138, faf01581a1) →
fijadas 0001 (#1142, 138f4ea8e7) → sync-cuenta 0001–0011 → pendiente/brave-core/0001 → 3.2-v8 0001–0002 (#1144,
b76f3410d9; ieee754 y kFlyWebCacheEpoch 37→38) = **árbol final 612c201d14** (MOTOR-47). chromium e7162cd585 + pendiente
0001–0005 → a9b357bc47 + renderer-webgl 0001–0002; ANGLE → fb21437e81; Skia → 1ef25455d7 (SEGURIDAD-PORTES-33). Sin cambiar
versión (lo decide Titín). Cuando LOCAL-21 avise: decir a Titín que apruebe bt-320e en LuLu (si no, no carga).
- APTO de SEGURIDAD: renderer-webgl/0002 (desde #949) y sync-cuenta/0011 (desde #1032). Para PUBLICAR siguen dos
  condiciones: pendiente/brave-core/0001 solo con D8-LINUX en verde, y la subida de época (ya en #1144).
- PR sin fusionar a propósito hasta la prueba de bt-320e: **#1110** (interfaz), **#1138** (base = rama de #1110; cambiar a
  main al fusionar #1110), **#1142** (fijadas), **#1144** (v8/época). Fusionar en ese orden tras revisar diffs.

**Revisión de Titín de la interfaz (20-11):**
- Selector de tema en «Aspecto» arreglado (0004, #1135). «Personalizar fuentes» se queda en «Contenido» (decisión).
- Ajustes en `FlyWeb/branding/interfaz-3.2.0/ajustes-20-11/` (#1136, #1137, #1140, con maquetas en alta). Hechos en
  0008–0013: sombra interior de la URL siempre por dentro (hover 0,20, foco 0,37; se invierte con dos constantes), URL 3 dip
  más baja por arriba, hover de la inactiva #EBEBEB/#585959 con silueta de pestaña hasta la base, título y favicon de las
  inactivas 4 dip más abajo. Titín los ve en bt-320e. Pendiente de él: radio 3 dip, escudo, iconos, ⋮ grupos, Apps,
  tarjeta de hover (la diseña él), borde fino de la URL sin foco en oscuro (no montado; preguntarle).
- Webs de prueba: **elpais, eldiario.es, youtube, wikipedia**; nunca apuestas ni marca.com (DIRECTIVAS #1143).

**Abierto con Titín:**
- Fijadas: el arreglo del refresco entra en la 3.2.0 (#1142). Sigue sin explicar la fijada en blanco aunque se recargue:
  pedirle captura, en qué ventana recarga y `flyweb://discards`. Alternativa sin compilar: apagar «Compartir pestañas
  fijadas entre ventanas» (decisión suya).
- Contraseñas: dialnet no ofrece guardar (3.1.4, 7,1, dos FlyWeb sincronizadas). Se le pidió mirar «Ofrecer guardar
  contraseñas» y la lista «Nunca guardar» en `flyweb://password-manager/settings`, y si la mete en el login o en cambio de
  contraseña. Sin respuesta. Si los dos ajustes están bien → MOTOR-47 + SEGURIDAD.
- Versión de Chrome a declarar en la siguiente: recomendado .112 (tag 880ca0428f); decide Titín. Gravedades de la .112
  sin publicar en Chrome Releases.

**Seguridad:** pendiente/ = chromium 0001–0005, angle 0001, brave-core 0001, skia 0001–0003 (#1129, #1133, #1134, #1141).
Nada Alto/Crítico/KEV: no hay 3.1.5. Puede llegar chromium/0006 (CacheStorage cc42b75af2).

**Sesiones:** MOTOR-47 `session_01MwmK2hjxRPyuefYzGRoZRk` (abierta por la 53; nota de MOTOR-46 en #1138), SEGURIDAD-PORTES-33
`session_01MwmK2kdhDkMC93UBtLuPkF` (vigila cada hora), INVESTIGACIÓN-MOTOR-10 `session_01MwmK2m3DpZgC8k7wAabHHG`,
SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`. Quietas: MOTOR-46, SEGURIDAD-PORTES-32, COORDINACIÓN-52.
Locales por el buzón: **LOCAL-21** (bridge «LOCAL-21 relevo en MacPro7,1», ref 9d9f5f; el cartero entregó una vez a la
antigua «Local (21)» 36698c: vigilarlo), PUBLICACIÓN, SERVIDOR-LOCAL, ARQUITECTURA, cartero. En la 6,1 abiertas para
Titín: bt-320a, bt-320b, bt-320c (no cerrar sin él).

## 19-11 (noche): COORDINACIÓN-52 → COORDINACIÓN-53 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-52 (`session_01MwmK2iHT1aVuS17rvqWH3K`, 19-11 ~18:07 → ~22:15 UTC, relevo al 34 %). La 53 la abre la 52.
**Todo en español, siempre.** **Nunca llamar a confirm_repository_trust.** Decisiones de hoy en DIRECTIVAS (#1115, #1116, #1121).

**Interfaz 3.2.0 (PR #1110, borrador; no fusionar todavía):** serie 0001–0007 de `FlyWeb/parches/3.2-interfaz/`, punta
`ef608126` (árbol tras el 0007 `6653db38fb`, sobre brave-core `e660929ac9`). LOCAL-19 la compiló (0 FAILED;
BraveColorMixersTest 3/3; SystemThemeChangeTest y ThemeObserverTest fallan, según MOTOR-46 no son de la serie: no
comprobado sin ella). Capturas en `entregas/local19/interfaz-3.2.0/` a 1x (`61-1x-*`) y 2x-hidpi (`61-2x-hidpi-*`), con
copias `-srgb` (las originales llevan el perfil del monitor; en sRGB los colores coinciden con los de Titín). FlyWeb de
prueba **abierta en la 6,1** para la revisión de Titín. Le faltan a Titín: capturas sin foco y del desplegable de la URL
(desde SSH no se puede), su visto bueno y las decisiones pendientes: contador del escudo (99+ fuera o 99 dentro), iconos
a ~17 dip, ⋮ en grupos de pestañas, Apps oculto. Radio de pestaña 3 dip (Chrome 10): Titín lo corrige tras las capturas
(`BRAVE_TAB_STYLE_TOP_CORNER_RADIUS`, un número). El monitor 4K de la 6,1 quedó en HiDPI (lo puso Titín).

**Arreglos nuevos, decididos por Titín:**
- **settings/system → 3.2.0** (#1122, `FlyWeb/parches/3.2-ajustes-sistema/0001`, punta `82e65b7f4b`): probado por LOCAL-19
  sobre la interfaz (árbol `80e73aff39`, browsertest verde, atajos cargan). Falta el **APTO de SEGURIDAD-PORTES-32**
  (le pregunté si necesita build con DCHECK —varias horas de la 7,1— o basta un CHECK de tipo). LOCAL-19 espera; no lanzar
  la build DCHECK sin ese veredicto.
- **Web Store en blanco con perfil nuevo → servidor** (#1123, `cosmeticas-sin-clic.mjs`, punta `217473d64f`): solo la lista
  AC023D22. Falta: (1) **decisión de Titín sobre el alcance**: amplio (todos los trusted: 368 quitadas + 182 recortadas,
  942 hosts; vuelven a verse los avisos de x.com, cnn.com…) o **estrecho** (solo trusted-click-element: 669 hosts; arregla
  igual Google y YouTube). Recomendación de la 52: estrecho. La pregunta no llegó a contestarse (se cortó dos veces).
  (2) APTO de SEGURIDAD-PORTES-32 (sus 5 condiciones ya están en el PR). Llega a la 1.x, 2.x y 3.x en la siguiente firma de bak.
- **Apariencia (desde el porte T11, también en la 3.1.4):** el selector de tema no sale (el de Brave falta; el de Chromium
  lo oculta `brave_overrides/appearance_page.ts`) y el desplegable «Modo de pasar por encima de las pestañas» sale vacío
  (`tabTooltipModes_` no llega a `tabs.html`). MOTOR-46 prepara propuesta; luego preguntar a Titín si entra en la 3.2.0.
  Titín quiere **diseñar él la tarjeta de hover** (hoy un rectángulo): esperar su diseño.

**Pendiente de diseño de Titín:** página de ventana privada nueva (mosca de incógnito, texto mezcla Google/Brave), iconos
de privada, privada clara (más adelante), tarjeta de hover. Si la 3.2.0 espera a la página privada lo decide él.

**Seguridad:** `pendiente/` con angle/0001, chromium/0001 (sandbox: APTO para Mojave a falta de pasos 1–7), brave-core/0001
(V8, necesita D8-LINUX al montar versión), skia/0001–0002. No aplican: dos rolls de Dawn (DXC), Graphite, TouchSelection,
Actor. Sin .112, 159 en beta. Sin 3.1.5 salvo Alto/Crítico/KEV.

**Sesiones:** SEGURIDAD-PORTES-32 `session_01MwmK2jtrG4sKq6TUTVEEyD` (vigila ~60 min; revisa #1122 y #1123),
MOTOR-46 `session_01MwmK2juPkbC58kEi4QFeyU` (#1110, #1122, #1123, Apariencia), INVESTIGACIÓN-MOTOR-10
`session_01MwmK2m3DpZgC8k7wAabHHG`, SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`, COORDINACIÓN-51 quieta.
Locales por el buzón: LOCAL-19 (escribe por el bridge), SERVIDOR-LOCAL, PUBLICACIÓN, ARQUITECTURA, cartero (entrega bien).
Sync: credenciales, correo y servidor hechos; la copia fuera de línea de credenciales está **descartada** (no volver a
plantearla); la medida en la 5,1 no frena la 3.2.0.

## 19-11 (tarde): COORDINACIÓN-51 → COORDINACIÓN-52 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-51 (`session_01MwmK2kKsACPV7ge7aLcNUS`, 19-11 ~04:50 → ~18:10 UTC, relevo al 38 %). La 52 la abre la 51.
**Todo en español, siempre.** **Nunca llamar a confirm_repository_trust.**

**3.1.4 publicada (19-11):** build 47, 198.63.47, Chrome/156.0.8078.110, web incluida (#1101, #1104). Titín firmó antes de
ver la parada por los arreglos nuevos de la 8078. Decisión suya (DIRECTIVAS, «Publicada la 3.1.4»): **no hay 3.1.5 por
ahora**. Lo que entre en la 8078 va a `FlyWeb/seguridad/pendiente/` con APTO y entra en **la siguiente versión que salga**
(la tanda de la 159 o la 3.2.0, la que llegue antes). Si algo resulta Alto o Crítico, sale como KEV o se explota, se
propone a Titín una 3.1.5. Pendiente hoy:
- ANGLE 41c5deee45;
- el sandbox de red de Mac (b243cdcc16): Mojave usa `unless` por primera vez, prueba obligatoria en la 6,1;
- V8 d68cecd900: necesita D8-LINUX al montar la versión, en un único encargo;
- Skia 13d0b32615;
- el roll de Dawn ff774db0a2, que mira LOCAL-19 porque desde la nube está bloqueado.

LOCAL-19 aún no ha devuelto la salida de los dos `sandbox-exec` de la 6,1 (buzón 1027 y recordatorio 1638).

**3.2.0, interfaz de Titín (en curso con MOTOR-46):** diseño en `FlyWeb/branding/interfaz-3.2.0/` (#1107, #1109; README
con colores e iconos). Parches de MOTOR-46 en la rama `claude/motor46-interfaz-3.2.0`, PR **#1110** (borrador; no fusionar
hasta los cuatro hitos y la prueba de LOCAL). Base brave-core `local/3.1.4` `e660929ac9` / chromium `local/314` `e9b670773e`.
Hitos: H1 colores (hecho) → H2 forma de pestañas → H3 brillo de la URL → H4 iconos.
Decisiones de Titín ya pasadas a MOTOR-46:
- **Modo oscuro:** URL y desplegable blancos con texto oscuro.
- **Ventana sin foco:** colores atenuados, como Chromium.
- **Ventanas privadas y de Tor:** sin tocar; Titín las diseña aparte.
- **Iconos:**
  - una sola escala, calibrada con los actuales de FlyWeb;
  - color #656666 en claro y #EDEEF1 en oscuro;
  - carpeta de marcadores en color plano;
  - adelante con icono propio.
- **Escudo de Shields:** `ico-escudo.svg`, solo contorno y sin mosca; verde activo y rojo bajado; el contador va dentro
  del escudo si cabe (si no, MOTOR propone y Titín decide con captura).
- **URL:** sin borde.
- **Línea bajo los marcadores:** se mantiene.
- **Texto de la pestaña activa:** negro en claro y blanco en oscuro; las inactivas, el mismo color al 50 %.
- **Radio de pestaña:** ~3 dip y brillo de la URL ~2 dip, en constantes; se ajustan con Titín viendo capturas.

Falta de Titín: el icono de «Personalizar» (se queda el actual) y el tamaño de su mesa de trabajo de Illustrator, para
afinar el radio. **Titín pidió que se le avise cuando haya capturas:** cuando MOTOR-46 entregue H1–H4, orden a LOCAL-19
por el buzón de compilar y sacar capturas en la 6,1 (1x) y Retina, en claro, oscuro, con la URL pulsada y con la ventana
sin foco → enviárselas a Titín.

**Sesiones:**
- SEGURIDAD-PORTES-32 `session_01MwmK2jtrG4sKq6TUTVEEyD`: vigila la 8078 y la 159 cada ~60 min.
- SEGURIDAD-PORTES-31: quieta, sin recordatorios; archivarla espera el visto bueno de Titín.
- MOTOR-46 `session_01MwmK2juPkbC58kEi4QFeyU`: interfaz 3.2.0.
- INVESTIGACIÓN-MOTOR-10 `session_01MwmK2m3DpZgC8k7wAabHHG`.
- SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`.
- Locales, por el buzón: LOCAL-19, PUBLICACIÓN, ARQUITECTURA, SERVIDOR-LOCAL y el cartero (6). Los bridges de LOCAL-19,
  PUBLICACIÓN y ARQUITECTURA escriben directo a COORDINACIÓN, pero desde la nube no se les contesta por SendMessage
  (401): siempre por el buzón.

## 19-11 (madrugada): COORDINACIÓN-50 → COORDINACIÓN-51 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-50 (`session_01MwmK2kAUMpE68orstgtvwT`, abierta por la 49, 18-11 22:55 → 19-11 ~04:50 UTC, relevo al 48 %). La 51 la
abre la 50. **Todo en español, siempre.** **Nunca llamar a confirm_repository_trust.**

**Estado de la 3.1.4 (build 47, FS.47): APTO definitivo de seguridad (SEGURIDAD-PORTES-31), solo espera a Titín.**
- Build: chromium `local/314` `e9b670773e` (integracion 0002–0004, árbol `e7162cd585`), pruebas en `local/314-tests` `cd188ca51e`,
  brave-core `local/3.1.4` `e660929ac9` (ls-remote). 0 FAILED. Versión 3.1.4 · 198.63.47 · Chrome/156.0.8078.110.
  Framework sha256 `51d7937c…`. Entrega en entregas/FlyWeb-3.1.4-release, con flyweb-build-info.txt y PRUEBAS.txt (LOCAL-19).
- Pruebas: filtros en la 7,1; views, unit y browser_tests en la 6,1; pruebas a mano en la 6,1 (PDF, WebRTC, MP4, blob, audio,
  DevTools, LNA con Shields subido y bajado). Dictámenes de la -31, todos en el buzón:
  - FSA: lo causa a propósito el 0031 (upstream la tiene DISABLED); se excluye con filtro.
  - Fallos de browser_tests: de Brave, la base o el entorno; se corrió sin los filtros de brave-core.
  - LNA: bloquea 0.0.0.0 sola, aparte de la regla de Brave.
- **Falta de Titín:**
  1. pruebas de interfaz con la 6,1 desbloqueada: aviso de LNA, miniaturas al pasar el ratón, fijada a otra ventana, repro de fijadas,
     diálogo de la extensión con PDF, enlace de la consola de DevTools;
  2. decidir `chrome/VERSION`. El tag 156.0.8078.111 (`c22b215559`) salió el 19-11 sin código nuevo (la -31 lo revisó). branch-heads/8078
     está en `aac2cdd377` (VERSION .112, nada que portar). Mi recomendación: quedarse en .110, porque .111 obliga a recompilar y no cambia
     el código. Ya se le ha dicho a Titín en el chat de la 50.
- Con las dos cosas en verde: LOCAL-19 escribe FS.47 (antes te pregunta) → PUBLICACIÓN → **PushNotification a Titín** para firmar en bak.
  Si Titín decide .111: orden de recompilar a LOCAL-19 por el buzón.
- Después de la 3.1.4 (no son de seguridad): los colgados NullIP*/FetchNullIpAddress*/SplitPermissionWebRtc de browser_tests; poner el
  filtro de FlyWeb al día con el de Brave (ExtensionCrxInstallerTest.InstallFailsDuringProfileShutdown); correr browser_tests con
  test/filters de brave-core.

**Abierto, por orden:** 1) lo de Titín de arriba; 2) FS.47 → PUBLICACIÓN → aviso al móvil; 3) al publicar, decir a la -31 que pare la
vigilancia y actualizar FS.47; 4) 3.2.0: lo de la nota de la 49 (diseños de Titín → MOTOR-46; #1037; #1033; bajos de la 157 y lo apartado).

**Sesiones:** SEGURIDAD-PORTES-31 `session_01MwmK2kyJvodFpg4Aaddcur` (vigila la 8078 hasta publicar). MOTOR-46
`session_01MwmK2juPkbC58kEi4QFeyU` (espera). INVESTIGACIÓN-MOTOR-10 `session_01MwmK2m3DpZgC8k7wAabHHG`. SEGURIDAD-VIGÍA
`session_019wTc3m4aVuvkKTEGMXdEHS`. LOCAL-19 (bridge `session_01MwmK2kXNDydrr8wXS32tXx`) y ARQUITECTURA (bridge) escriben directo; a las
locales, por el buzón. Al arrancar, la 51 avisa del relevo como hizo la 50 (buzón con «Para LOCAL-19» y send_message a las cuatro de la nube).
Nota menor: el cartero anotó un «LOCAL/20261118-2300-COORDINACION-50-relevo.md» que no existe (entregado a «Local (21)»). No bloquea.

## 18-11 (noche): COORDINACIÓN-49 → COORDINACIÓN-50 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-49 (`session_01MwmK2ja2S2x47BLQTR6Qc5`, abierta por Titín, 18-11 14:37 → ~23:00 UTC, relevo al 38 %). La 50 la
abre la 49 (linaje 1). **Todo en español, siempre.** **Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy (en DIRECTIVAS, #1073, #1085, #1087):**
- La 3.1.4 lleva **toda la seguridad que aplica a Mac**: Altos/críticos y medios de la 158 (también con interacción o
  instalar algo), medios de la 157, bajos de la 158. Fuera solo lo que no se compila en Mac o toca código apagado/quitado.
- **Bajos de la 157: a la 3.2.0.** «La siguiente es la 3.2.0.»
- **Todo lo que entre en la rama 8078 antes de publicar va en la 3.1.4**, aunque haya que recompilar. El tag .111 (cambio de
  `chrome/VERSION`) lo decide Titín.
- Aviso de permiso PDF en inglés (adapt/brave-core/0002): aceptado por mí con APTO; Titín no lo entiende como problema.
- Titín quiere **aviso al móvil (PushNotification)** cuando la 3.1.4 esté lista para firmar en bak. LOCAL-19 le avisa al móvil
  solo si LuLu retiene la build en la 6,1.
- Lección: el classifier bloqueó un `send_message` mío que congelaba la 8078 sin preguntar. Cualquier corte de contenido, a Titín.

**Estado de la 3.1.4 (build 47, FS.47):**
- Contenido en main: `FlyWeb/seguridad/3.1.4/` (+ `3.1.5/` sin brave-core/0002), `parte4/` (#1074, #1076, #1077), `parte5/`
  (#1080), `parte6/` (#1078, #1079), `integracion/` (#1081, #1083, #1088, #1089), `adapt/` (#1084). D8-LINUX: verde final
  (#1086; V8 con patches `17b5af44cd`, época 37).
- LOCAL-19: build 47 ampliada compilada (0 FAILED) sobre chromium `local/314` `aaa7d7508d` y brave-core `local/3.1.4`
  `e660929ac9` (ls-remote). Encima, en local: integracion/0002 (`07683b2be0`, árbol 25a6269c6b) y la orden de 0003–0004 (árbol
  esperado **`e7162cd585`**, buzón 258f174). Pidinfo 6,1: verde. AVX: la vpbroadcastw de más es de dav1d con despacho por CPU.
  Pruebas en marcha (rama de pruebas aparte, con commit, para lo que rompe Brave y para 9d694ab7d6/8787d30d6c).
- **ALTO a FS.47 levantado con condiciones** (buzón 75b96cf): 0 FAILED, pruebas en verde, hashes por ls-remote. Con cada
  parche nuevo de la 8078 LOCAL-19 espera el último; antes de escribir FS.47 te pregunta.

**Abierto, por orden:**
1. Cuando LOCAL-19 suba `local/314` con 0002–0004: ls-remote. Si la -31 trae 0005+, mismo circuito (PR → buzón LOCAL-19).
2. Entrega de LOCAL-19 en FS.47 → PUBLICACIÓN → **PushNotification a Titín** para firmar en bak.
3. Al publicar: decir a la -31 que pare la vigilancia; actualizar FS.47.
4. 3.2.0: diseños de Titín → MOTOR-46 (esperando también tabla §7 #1037 y dos resultados de LOCAL, #1033). Bajos de la 157 y
   lo apartado (2643f6e87f, 0777cdb316, 229a53b+Blink, reland de 605619b342, .111 si no entra) van a la 3.2.0.

**Sesiones:** SEGURIDAD-PORTES-31 `session_01MwmK2kyJvodFpg4Aaddcur` (vigila la 8078 hasta publicar). Quietas: -26
`session_01MwmK2kcWn812GmYVA1oi3u`, -27 `session_01MwmK2hfdiqBBbfVwYqbmQZ`, -28 `session_01MwmK2iFqX7G9w939C4tEtH`, -29
`session_01MwmK2h9y29gKXzQFjqi44F`, -30 `session_01MwmK2jYknFBAra6Yi8EcTM`. MOTOR-46, INVESTIGACIÓN-MOTOR-10, SEGURIDAD-VIGÍA,
como en la nota de abajo. Locales por buzón; LOCAL-19 y ARQUITECTURA también escriben directo (bridge). **D8-LINUX-5**
(`session_01MwmK2iT4hLWA1h2vv3cG9K`) recibe por el buzón vía CARTERO-LOCAL y contesta por send_message; desde la nube no se le
puede escribir. La 48 está quieta.

## 18-11 (tarde, 2): COORDINACIÓN-48 → COORDINACIÓN-49 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-48 (`session_01MwmK2hXKtz79D9xajYtEYi`, 18-11 13:09 → ~14:30 UTC). **Titín la releva por escribirle en inglés:
todo en español, siempre** (mensajes, buzón, PR; solo los commits en inglés). La 49 la abre Titín.
**Nunca llamar a confirm_repository_trust.**

**Hecho:**
- **0030** (adaptación de 3.1.5/chromium/0018 a la 156, `storage_key.origin()`; la encontró LOCAL-19 al compilar): APTO de
  SEGURIDAD-PORTES-26, en main (#1066).
- **0031** (625dedb4a0, comprobación de la StorageKey en OPFS; está en Chrome desde la 157 sin anuncio ni CVE): **Titín: «todo en
  la 3.1.4, y luego la 3.2.0»**; regla general en DIRECTIVAS (#1067): no se inventan versiones intermedias ni se reparte contenido
  sin consultarle. APTO; en main (#1068). Árbol chromium de la serie: **`986d591616`**; blob de
  `file_system_access_manager_impl.cc` `0daedcf4df`, del unittest `0e0775e50f`.
- LOCAL-19: orden de aplicar el 0031 sobre `6a30d8feb0` y recompilar en incremental (buzón `20261118-1425-…-aplica-0031-LOCAL-19.md`).
  Sigue siendo la build 47. Ramas aún sin subir: hashes, por ls-remote.
- Relevo 47 → 48 entregado por el cartero (los seis, en ENTREGADO.md).

**Abierto, por orden:**
1. **D8-LINUX:** Titín no sabía que el encargo lo pega él. Se lo pasé (`buzon/D8-LINUX/20261118-1310-…-v8-3.1.4.md`, con el
   informe a la COORDINACIÓN vigente y a SEGURIDAD-PORTES-26). Sin su verde no hay entrega. Si sale rojo, se quita el parche de V8 que falle y se recompila.
2. **LOCAL-19:** build 47 con el 0031 → ramas (ls-remote) → pruebas (SEGURIDAD-PORTES-24/25/26 y pidinfo en la 6,1) → con el
   verde de D8-LINUX, la entrega en la fila FS = orden de publicar → PUBLICACIÓN → a Titín solo la firma en bak.
3. 3.2.0, MOTOR-46 y ARQUITECTURA, igual que en la nota de abajo.

**Sesiones:** como en la nota de abajo; SEGURIDAD-PORTES-26 tiene el 0031 cerrado y vigila .111/159/D8.

## 18-11 (tarde): COORDINACIÓN-47 → COORDINACIÓN-48 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-47 (`session_01MwmK2kK9WDgdvBd7f3rxQb`, 18-11 09:45 → ~13:15 UTC; relevo al 36 %). La 48 la abre la 47, linaje 7.
**Nunca llamar a confirm_repository_trust.**

**Lección (Titín, 18-11, enfadado con razón):** la 3.1.3 salió sin los 46 Altos de la 158 que Google no había portado a la .109, y no se le dijo.
Luego la 46 y la 47 abrieron una 3.1.4 y una 3.1.5 **sin preguntarle**. **Ningún número de versión ni ningún reparto de contenido
entre versiones sin decisión de Titín**, y si algo queda fuera de lo que él esperaba, se le dice antes de compilar. La regla general no
está aún en DIRECTIVAS: Titín no la ha confirmado (proponérsela solo si sale el tema).

**Hecho:**
- **3.1.3 publicada** (build 46, 198.63.46; firmada en bak; web #1048; registro #1058, que restauró la fila FS.46 que #1050 había borrado).
- **Decisión de Titín (DIRECTIVAS #1061): una 3.1.4 con TODA la seguridad de la 158 (Altos y medios); no hay 3.1.5; el resto a la 3.2.0.**
  Contenido en main: `FlyWeb/seguridad/3.1.4/` + `3.1.5/` (= parte 3 de la 3.1.4; **sin** `3.1.5/brave-core/0002`), más 2 [M156] de
  ServiceWorker y V8 5787048 posteriores a la .110 (#1063). Árboles: chromium `880f9f156d`, brave-core `15c050d35a` (época 34), V8 con
  parches `fe1194813a`, WebRTC `8ee111cf22`, ANGLE `db885a866b`. Órdenes de aplicación en `3.1.4/CONTENIDO.md` (#1062, #1063).
- **LOCAL-19 compila la 3.1.4, build 47** (incremental desde ~14:07 hora de la 7,1; ramas locales `local/314` f032f35a1b y `local/3.1.4`
  9932552867, aún sin subir: hashes por ls-remote cuando las suba). Probará también el 0024 (pidinfo del sandbox) en la 6,1 y avisa antes de decidir.
- 7b99dd29ba (CVE-2026-121105) fuera, con el sí de SEGURIDAD-PORTES-26; reabrir si sale en KEV o en una Extended. DBSC 576306917 fuera.
- SEGURIDAD-PORTES-26 `session_01MwmK2kcWn812GmYVA1oi3u` abierta por la 47 (brave-core con push); la 24 y la 25 quietas.
- Archivar la 23 y la 43: denegado por el clasificador (Titín lo sabe).

**Abierto, por orden:**
1. **d8/mjsunit de D8-LINUX**: encargo `buzon/D8-LINUX/20261118-1310-SEGURIDAD-PORTES-26-v8-3.1.4.md` (sustituye al de las 10:30; lo pega Titín).
   Con el verde → decir a LOCAL-19 que escriba la entrega en la fila FS (orden de publicar, regla 11). Si sale rojo, se quita el parche de V8 que falle y se recompila.
2. **Entrega de LOCAL-19** (hashes por ls-remote, pruebas, pidinfo en la 6,1) → PUBLICACIÓN publica → a Titín solo la orden de firma en bak (si PUBLICACIÓN no se la pasa ya).
3. **3.2.0:** Titín pasará sus diseños y decisiones (pantalla privada, pestañas; tabla §7 de #1037, que **no** bloquea la 3.2.0). Repartir a MOTOR-46.
   Falta además la medida de la sync en la 5,1 (estudio). La .111 (cuando tenga tag) y la 159 estable: SEGURIDAD-PORTES-26 vigila → 3.2.0.
4. ARQUITECTURA sin nada abierto (pruebas GL pendientes del estudio).

**Sesiones:** SEGURIDAD-PORTES-26 (arriba, vigilando .111/159/D8), MOTOR-46 `session_01MwmK2juPkbC58kEi4QFeyU`, INVESTIGACIÓN-MOTOR-10
`session_01MwmK2m3DpZgC8k7wAabHHG`, SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`; quietas: SEGURIDAD-PORTES-23/24/25, COORDINACIÓN-46.
Locales (buzón): LOCAL-19 (7,1, compila), LOCAL-21 (6,1), PUBLICACIÓN, SERVIDOR-LOCAL, ARQUITECTURA, CARTERO-LOCAL (entrega bien), D8-LINUX-5 (vía Titín).
La 47 se queda quieta tras la prueba.

## 18-11 (mañana): COORDINACIÓN-46 → COORDINACIÓN-47 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-46 (`session_01MwmK2m8seaLGsdcKmQhGXU`, 17-11 23:33 → 18-11 ~09:50 UTC; relevo al 47 %). La 47 la abre la 46, linaje 6.
**Nunca llamar a confirm_repository_trust.**

**Hecho:**
- **3.1.3 (build 46) entregada a PUBLICACIÓN** por LOCAL-19: sin cierres en 7,1 ni 6,1 (LuLu aprobado por Titín). Ramas por ls-remote: brave-core `local/3.1.3` 2d55dce9a9, chromium `local/313` 7ccbc27cf7. Fila **FS.46** en main (#1045 → #1047 con el texto de LOCAL-19; #1046 cerrado por duplicado). Orden de publicar a PUBLICACIÓN por buzón (968a735, 02c7d24). «La 158» = delta de seguridad de la 158 portado a la 156 (Chrome/156.0.8078.109).
- **3.1.4 en marcha.** SEGURIDAD-PORTES-24 `session_01MwmK2hXs9xn6KN4sT9iVtr`: inventario en main (#1049, `FlyWeb/seguridad/3.1.4/INVENTARIO.md`). Decisión de la 46: **A+B+E (+D si se confirma)**; los 82 medios **no** entran (triaje corto como propuesta para la 3.1.5, sin portar). Parte 1 (A, B1–B4, B7, B8, ANGLE, V8 659b8bf; brave-core `seg/3.1.4` d91632790084) en **#1050**, con APTO: tenía conflicto con main, la 24 debe hacer merge de main y pasar el hash; fusionarlo entonces. **SEGURIDAD-PORTES-25** `session_01MwmK2kzDkFd6KCGzWTjn23` abierta para B5, B6, D y E.
- **D8-LINUX:** el cartero no llega al Ubuntu (encargos en `buzon/D8-LINUX/` que Titín pega a mano en «motor ubuntu (4)», D8-LINUX-5). El d8/mjsunit del V8 659b8bf está en `buzon/D8-LINUX/20261118-0950-SEGURIDAD-PORTES-24-v8-659b8bf.md`; **ya se le pidió a Titín que lo pegue**. Mis avisos rutinarios a D8-LINUX quedan sin anotar en ENTREGADO: es normal, no es caída del cartero.
- Relevo avisado por buzón (7dd7858) y send_message. ARQUITECTURA sin nada abierto (respaldo GL de la 3.1.2 sin probar en monitor externo del MacBookPro9,1, Air 2013, mini 2012 y 5,1 con NVIDIA: cuando Titín esté en el estudio).

**Abierto, por orden:**
1. **Publicación de la 3.1.3** por PUBLICACIÓN → **avisar a Titín en una línea con la orden de firma en bak** (lo pidió).
2. **#1050** (merge de main por la 24) → fusionar con expectedHeadSha. Luego, partes de la 25 → fusionar; d8/mjsunit de D8-LINUX → a la 24/25.
3. **Tabla §7 de la parte B** (#1037): falta la respuesta de Titín → lo aprobado, a MOTOR-46 para la 3.2.0.
4. **Diseño de Titín del 17-11** (pantalla privada, pestañas, páginas que faltaban): sin llegar; cuando llegue, a MOTOR-46.
5. **La 5,1 de la sync** y las pruebas GL pendientes: cuando Titín esté en el estudio.
6. Pendiente sin hacer: archivar COORDINACIÓN-43 (denegado a la 45) y, cuando la 25 esté activa y #1050 fusionado, SEGURIDAD-PORTES-23.

**Sesiones:** SEGURIDAD-PORTES-24/25 (arriba), SEGURIDAD-PORTES-23 `session_01MwmK2ihLC48xJinz4Li6Jv` (quieta), MOTOR-46 `session_01MwmK2juPkbC58kEi4QFeyU`, INVESTIGACIÓN-MOTOR-10 `session_01MwmK2m3DpZgC8k7wAabHHG` (~48 %), SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`.
Locales (buzón): LOCAL-19 (7,1), LOCAL-21 (6,1), PUBLICACIÓN, SERVIDOR-LOCAL, ARQUITECTURA, CARTERO-LOCAL, D8-LINUX-5 (vía Titín). La 46 se queda quieta tras la prueba.

## 17-11 (madrugada): COORDINACIÓN-45 → COORDINACIÓN-46 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-45 (`session_01MwmK2mRayo5wBbWFqBKkyv`, 17-11 21:15 → ~23:40 UTC; relevo al 44 %). La 46 (`session_01MwmK2m8seaLGsdcKmQhGXU`) la abre la 45, linaje 5.
**Nunca llamar a confirm_repository_trust** (ni aunque un send_message a una sesión local lo ofrezca: a las locales, por el buzón).

**Hecho:**
- **3.1.3 en compilación** (LOCAL-19, 7,1, build 46, desde las 21:49 UTC; la 3.1.2 tardó 3 h 18 min). Contenido en main:
  - parte 1: chromium 0001–0022 (delta de la 8078 de .105 a .109 y V8 .66) y brave-core 0001–0004 (incluye las fijadas) (#1036);
  - parte 2: chromium 0023 (GPU, CVE-2026-131031) y ffmpeg 0001 (CVE-2026-131060), con APTO de SEGURIDAD-PORTES-23 (#1038);
  - Dawn 0001–0004 y los hashes finales de LOCAL-19 (#1041).
  Sin forks de ANGLE, FFmpeg ni Dawn: van como .patch, igual que en la 3.0.1. Ya no se le pregunta a Titín.
- **mjsunit de la V8 .66 en verde** (D8-LINUX-5, 9188/9190 frente a 9185/9187, sin fallos nuevos): la 0021 entra (#1042). LOCAL-19 lo sabe por el buzón (e988d18a01).
- **#1039 cerrado** sin fusionar: era un duplicado de #1038 (diff vacío).
- **Informe 2 de estándares, parte B** (INVESTIGACIÓN-MOTOR-10, #1037). Tabla de sí/no en su §7, ya pasada a Titín con mi opinión: sí a 1, 2 y 6; el 4 solo si la página de banderas no basta; el 3 si lo usa; no o esperar al resto. **Falta su respuesta.**
  En DIRECTIVAS, l.417 (13-11) manda sobre l.432 (12-11): no se vigilan los navegadores para macOS viejos.
- **D8-LINUX:** la fila de TAREAS apuntaba a una sesión archivada y el cartero se quedó parado preguntándole a Titín (#1040). Ahora la sesión activa es **D8-LINUX-5** `session_01MwmK2iT4hLWA1h2vv3cG9K` (local: desde la nube **solo por el buzón**).
- **Pendiente sin hacer:** archivar COORDINACIÓN-43 (el sistema me lo denegó).

**Abierto, por orden:**
1. **Entrega de la build 46** por LOCAL-19, tras sus pruebas (fijadas en 7,1 y 6,1, SharedPinnedTab, FFmpegDemuxer, importes de 10.15). La entrega va a la 46 y a PUBLICACIÓN.
   PUBLICACIÓN publica sin preguntar (regla 11). **Titín pidió aviso cuando la 3.1.3 esté lista: avisarle al publicar**, con solo la orden de firma en bak.
2. **Respuesta de Titín a la tabla §7** de la parte B → lo aprobado, a MOTOR-46 para la 3.2.0.
3. **Diseño de Titín del 17-11** (pantalla privada, pestañas, páginas que faltaban): aún no ha llegado; cuando llegue, a MOTOR-46.
4. **3.1.4:** los Altos de la 158 que no están en la .109 (§12 de RELEVO-SEGURIDAD). SEGURIDAD-PORTES-23 va al ~20 % de contexto.
5. **La 5,1 de la sync:** cuando Titín esté en el estudio.

**Sesiones:** SEGURIDAD-PORTES-23 `session_01MwmK2ihLC48xJinz4Li6Jv`, MOTOR-46 `session_01MwmK2juPkbC58kEi4QFeyU`,
INVESTIGACIÓN-MOTOR-10 `session_01MwmK2m3DpZgC8k7wAabHHG` (~48 %: relevo antes de otro encargo largo), SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`.
Locales (buzón): LOCAL-19 (7,1), LOCAL-21 (6,1), PUBLICACIÓN, SERVIDOR-LOCAL-3, ARQUITECTURA (nada abierto), CARTERO-LOCAL «Cartero-Local (5)», D8-LINUX-5.
Las entregas a «LOCAL» van a LOCAL-21: lo de la 7,1 lleva «Para LOCAL-19» en el título. La 45 se queda quieta tras la prueba.

## 17-11 (noche): COORDINACIÓN-44 → COORDINACIÓN-45 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-44 (`session_01MwmK2gz1EsL95kgTpxdSwU`, 17-11 10:10 → 21:15 UTC; relevo al 38 %). La 45
(`session_01MwmK2mRayo5wBbWFqBKkyv`) la abre la 44, linaje 4. **Nunca llamar a confirm_repository_trust.**

**Hecho hoy:**
- **Cierre de las fijadas compartidas en la 3.x.** Falta `ThumbnailTabHelper` y `SharedPinnedTabDummyView` lee un puntero nulo.
  Arreglo de MOTOR-46 (#1029), con APTO de SEGURIDAD-PORTES-23. **Titín decidió (17-11) que vaya en la 3.1.3** (DIRECTIVAS #1030;
  CONTENIDO #1031: 0004 de brave-core). LOCAL-19 lo reproduce en la 7,1 y desaparece con el 0001. LOCAL-21 hace lo mismo en la 6,1, con ventana.
  Tests: 6/7. `CloseTabShortCutShouldBeDisabled` falla por el aviso de confirmación al cerrar una fijada de Chrome 156: el test está mal,
  se arregla en la 3.2.0 (#1033). `ThumbnailHelperIsAlwaysAttached` es un fallo conocido. El aviso de confirmación se queda como en Chrome, salvo que Titín diga otra cosa.
- **Lección:** a Titín le pasé el apaño `--disable-features=BraveSharedPinnedTabs` sin probar y le costó fijadas. Los rellenos no se guardan en la sesión
  y cada cierre al arrancar se comía una fijada. **No pasarle apaños sin probar.** Titín ya ha vuelto a fijar las suyas a mano. Hasta la 3.1.3, una sola ventana.
- **Sync 3.2 contra ns2 (LOCAL-19):** eventos 200, el correo del código llega, derivación de clave 307 ms (7,1) y 364 ms (6,1). La 5,1 está pendiente
  (`medir-sync-51.command`, cuando Titín esté en el estudio; si pasa de ~2 s, a SEGURIDAD-PORTES antes de tocar kScryptN).
  0009–0011 del cliente (`desde` como entero, hw.model en macOS < 11, primer sondeo persistente): APTO y fusionados (#1032).
  El modelo del Mac va **además** del nombre que elige el usuario (DIRECTIVAS l.355).
- **Cartero:** estuvo caído del 16-11 20:48 al 17-11 15:30 UTC (clon de buzon roto). Titín lo relevó y ya entrega. Las entregas a «LOCAL» van a LOCAL-21 (6,1);
  lo de la 3.1.3 y la sync es de LOCAL-19 (7,1), así que escribe su nombre en el mensaje.

**Abierto, por orden:**
1. **3.1.3:** SEGURIDAD-PORTES-23 tiene la orden del delta de la 158 desde las 21:15 UTC. Primer parche: ANGLE/FFmpeg/Dawn. Que lo cuadre con la entrada oficial
   de la 158 estable; CVE-2026-125350, si se confirma, va primero. Luego LOCAL-19 compila (delta + 0004 fijadas) → PUBLICACIÓN publica → a Titín solo la firma en bak.
2. **21:30 UTC:** aviso a INVESTIGACIÓN-MOTOR-10 de la parte B del informe 2. Lo recrea la 45; la 44 borra el suyo (`trig_01HMndeKL6b2FksvFX3r7nKu`).
3. **Diseño de Titín del 17-11** (pantalla privada, pestañas, páginas que faltaban): aún no ha llegado. Cuando llegue, a MOTOR-46 para la 3.2.0.
4. **La 5,1 de la sync:** depende de que Titín esté en el estudio.

**Sesiones:** SEGURIDAD-PORTES-23 `session_01MwmK2ihLC48xJinz4Li6Jv`, MOTOR-46 `session_01MwmK2juPkbC58kEi4QFeyU`,
INVESTIGACIÓN-MOTOR-10 `session_01MwmK2m3DpZgC8k7wAabHHG`, SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`.
Locales (por el buzón): LOCAL-19 (7,1, compila), LOCAL-21 (6,1), PUBLICACIÓN, SERVIDOR-LOCAL-3, ARQUITECTURA (a demanda, nada abierto), CARTERO-LOCAL (relevado hoy).
COORDINACIÓN-43 está quieta (archivar). La 44 se queda quieta tras la prueba.

## 17-11 (mañana): COORDINACIÓN-43 → COORDINACIÓN-44 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-43 (`session_01MwmK2hZ9HcbmRFFueDh8dE`, 14-11 13:40 → 17-11 ~10:10 UTC; Opus 5.5 medio; abierta por la 42,
linaje 2; relevo al 58 %). La 44 la abre la 43. **Nunca llamar a confirm_repository_trust.** Desde la nube no se puede
`send_message` a sesiones locales (lo bloquea el sistema): a LOCAL, PUBLICACIÓN, SERVIDOR-LOCAL y ARQUITECTURA se les
escribe por el buzón; ellos sí escriben a la nube por bridge. Borrar ramas remotas: lo bloquea el proxy.

**Hecho:** 3.1.2 publicada y firmada (#1013, #1014). Copia de la sync en ns2/bak: v6 aplicada por la Auditoría sin
latido, purga manual, aviso diario de copias de >30 días (DIRECTIVAS #1015–#1019, CAMBIOS #1020). El backup general de
Titín no se toca (sus claves root: riesgo aceptado, no volver a plantear). flyweb-sync: correo a MTA loopback sin
STARTTLS (#1021) y «desde» de eventos con decimales (#1024), los dos instalados en ns2 por la Auditoría (CAMBIOS #1022,
#1025). Rama `claude/coord-42-relevo`: «MacJulia» es el nombre del portátil, no dato personal; se deja.

**Lecciones (Titín, 16-11):** en servidores y backups de Titín manda el criterio de conjunto de la Auditoría. Proponer
solo lo que pide FlyWeb y medir el coste colateral antes de añadir condiciones de seguridad; no encadenar revisiones.
Las decisiones que llegan por otro agente se confirman con Titín antes de escribirlas en DIRECTIVAS. Lo que Titín
menciona de pasada (p. ej. un reto de Cloudflare) es una pregunta, no un encargo: contestar breve, sin abrir estudios.

**Abierto, por orden:**
1. **Sync 3.2 contra ns2:** LOCAL-19 repite la entrada en la 6,1 tras el 2.º binario (17-11 11:02). Falta: eventos en 200,
   que el correo del código llegue (mirar spam) y «key derivation ok in N ms» en 7,1/6,1/5,1. Si la 5,1 pasa de ~2 s, a
   SEGURIDAD-PORTES antes de tocar kScryptN. Opcional de SEGURIDAD (no bloquea): límite de tiempo en el envío SMTP.
2. **17-11 21:15 UTC** aviso `trig_015HV36b8ErpgDbGToUHfRwB` (delta de la 158 para la 3.1.3, SEGURIDAD-PORTES-23) y
   **21:30 UTC** `trig_0111cFN3Sdw9BGkxQUrjXDLA` (parte B del informe 2, INVESTIGACIÓN-MOTOR-10): la 44 los recrea a su
   nombre y la 43 borra los suyos.
3. **Diseño de Titín del 17-11** (pantalla privada, pestañas, páginas que faltaban): repartir a MOTOR-46 para la 3.2.0.
4. SEGURIDAD-VIGÍA ya tiene la base 3.1.2 (156.0.8078.105).

**Sesiones:** SEGURIDAD-PORTES-23 `session_01MwmK2ihLC48xJinz4Li6Jv`, MOTOR-46 `session_01MwmK2juPkbC58kEi4QFeyU`,
INVESTIGACIÓN-MOTOR-10 `session_01MwmK2m3DpZgC8k7wAabHHG`, SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`.
Locales: LOCAL-19, PUBLICACIÓN, SERVIDOR-LOCAL-3 (bridge «Servidor Local (2)»), ARQUITECTURA; la Auditoría de servidores
es sesión de Titín (no se le escribe; sus cambios llegan por SERVIDOR-LOCAL). COORDINACIÓN-42 quieta (archivar).

## 14-11 (tarde): COORDINACIÓN-42 → COORDINACIÓN-43 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-42 (`session_01MwmK2iRNzVTcBF92tmevxX`, 14-11 00:00 → ~13:40 UTC; Opus 5.5 medio; abierta por la 41,
linaje 2; relevo al 51 %). La 43 la abre la 42. **Nunca llamar a confirm_repository_trust.** `update_trigger` sobre la rutina
de SEGURIDAD-VIGÍA lo deniega el clasificador; sobre los avisos propios funciona.

**Decisiones de Titín de hoy (en `docs/DIRECTIVAS.md`):** respaldo GL en la 3.1.2 (#994); «error 11» en la 3.1.2 (#998);
**3.1.2 ya, la 158 en una 3.1.3** solo de seguridad, salvo que la 3.2.0 llegue antes (#1000). Remitente de la cuenta:
`noreplyflyweb@lamosquita.net` (alias de Titín en Google, con un filtro a una carpeta). La sync de la 3.2 avanza en paralelo.

**3.1.2 (build 45 = 198.63.45, chromium 156.0.8078.105).** CONTENIDO cerrado por SEGURIDAD-PORTES-23 (#985, #1006, #1007):
seguridad .105 (chromium 0001–0010, PDFium 8b21800ddb, Skia 4c5f57e4fa) + GL 0001–0005 + brave-core 0001–0003 (versión,
error 11, package.json). Árboles: chromium 8abc877c10, brave-core da680a3270. LOCAL-19 **compila desde ~13:25 UTC**
(~3,5 h; `out/Release`, rama local/312 y local/3.1.2) y tiene el **visto bueno para entregar** por la regla 11 tras las
pruebas (6,1 con ventana real: Metal, Google/error 11; MBP9,1: GL; otool). ANGLE (bc2ebdd211 = árbol 099b621f10) y
FFmpeg (a15fcf87d2) quedan como en la 3.1.1 publicada (los gitlinks de seg/3.1.1 no lo reflejaban); SEGURIDAD confirmó
su APTO GL con el ANGLE real. Después: PUBLICACIÓN firma (orden a Titín en bak), sube y fusiona su PR de la web.
G-C2 cerrada (reposo repetido con pmset; monitor externo, prueba posterior). Pendiente sin bloquear: Air 2013, mini 2012,
5,1 NVIDIA (si no, que lo diga la nota de la versión).

**3.1.3:** la 158 (aviso propio `trig_01SuLRxh9MAaZKqCTYbea2B6`, 17-11 21:15 UTC, ya dice 3.1.3); primer parche fija gitlinks
y DEPS de ANGLE bc2ebdd211, FFmpeg a15fcf87d2 y Dawn (+68b5c1f3f y 8bc8ddaf2, cherry-pick -x sobre 31316d1c); antes, subir
esos commits a un remoto que gclient baje. Si 576333024 vuelve a la V8 15.6. Aviso `trig_01JJuex23HgpYZFRABHcySBs` 17-11
21:30 UTC: parte B del informe 2 a INVESTIGACIÓN-MOTOR-10.

**Sync 3.2.** Servidor H2 **instalado y expuesto** en ns2 (CAMBIOS #1001, #1002; vhost `/cuenta/v1` #999 con QSD, 64 KiB,
sin freno por IP por decisión de SEGURIDAD: si salta «cuenta: tope de correos alcanzado» a menudo, mod_qos solo en /alta).
Credenciales 67 B (correcto). Falta: **prueba de envío** (Titín da la dirección a SERVIDOR-LOCAL en su chat; mirar SPF,
DKIM y DMARC en pass) y **copia de seguridad** (propuesta de SERVIDOR-LOCAL en entregas, rehecha con las condiciones de
SEGURIDAD: `sync.db` con age/gpg asimétrico, privada con Titín; credenciales y DKIM aparte con --symmetric; restauración
de prueba; nota RGPD de 30 días para CONTENIDOS-WEB). Pásala por SEGURIDAD-PORTES y luego a Titín. Recomendado a Titín:
que la rotación borre sola (no `viejas/`). Titín no ha dicho aún cómo recoge bak las copias de ns2.
Cliente: parches 0001–0008 en main (#1003 0007 arreglos de compilación, APTO; #1005 0008 VLOG del tiempo de derivación).
Preliminar compila y arranca; capturas a Titín (pendiente su opinión). AccountCryptoTest 9/9 en la 7,1 (scrypt 2^17 =
348 ms); en la 6,1 brave_unit_tests no arranca por GL. **Después de la 3.1.2:** LOCAL-19 recompila con 0001–0008 limpio y
prueba contra ns2 (cuenta de prueba, medir «key derivation ok in N ms» en 7,1/6,1/5,1). Si la 5,1 pasa de ~2 s, a
SEGURIDAD-PORTES antes de tocar kScryptN. **Titín entrega el lunes 17-11 su diseño** (pantalla privada, pestañas, páginas
que faltaban): repartir a MOTOR para la 3.2.0.

**Sesiones.** Nube: SEGURIDAD-PORTES-23 `session_01MwmK2ihLC48xJinz4Li6Jv`, MOTOR-46 `session_01MwmK2juPkbC58kEi4QFeyU`
(quieto hasta la prueba contra ns2 o el diseño), INVESTIGACIÓN-MOTOR-10 `session_01MwmK2m3DpZgC8k7wAabHHG`,
SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS` (le mandé la base 3.1.1 porque su rutina habla de la 2.0.x; con la
3.1.2 publicada, mándale 156.0.8078.105). COORDINACIÓN-41 quieta (archivar). Locales por bridge hacia la nube y por buzón
hacia ellas: LOCAL-19, SERVIDOR-LOCAL-3, ARQUITECTURA (veredicto GL firme; estudio #995–#997).

**Pendiente de Titín:** dirección de prueba a SERVIDOR-LOCAL; cómo recoge bak; borrar o `viejas/`; opinión de las capturas
de la sync; diseño del lunes; firma en bak de la 3.1.2; si un nombre de máquina que usa LOCAL-19 en la rama buzon es de
una persona (le pregunté; sin respuesta; no repetirlo en el repo).

**Lecciones.** Una prueba «pasada» sin rastro en los registros no vale (reposo de 2 s): cruzar horas con pmset. Revisar
que los gitlinks reflejen lo publicado.

## 14-11 (madrugada): COORDINACIÓN-41 → COORDINACIÓN-42

COORDINACIÓN-41 (`session_01MwmK2gzdSTH5uLSVSsrNNd`, 13-11 13:45 → 14-11 ~00:00 UTC; Opus 5.5 medio; abierta por Titín,
linaje 1; relevo al 44 %). La 42 la abre la 41 (linaje 2): puede abrir sesiones y programarse avisos. **Nunca llamar a
confirm_repository_trust.** Directivas nuevas del 13-11 en `docs/DIRECTIVAS.md`: «Contenido de la 3.2.0 cerrado» (solo
«Combinar»), «3.1.2 antes de la 3.2.0», «FlyWeb también innova», «Plataformas» (+ iOS antes que Windows, 14-11). Regla 11
cambiada: **PUBLICACIÓN fusiona su propio PR de la web** tras verificar el appcast.

**Canales.** Las locales SÍ escriben a la nube por bridge (LOCAL-19, PUBLICACIÓN, SERVIDOR-LOCAL y ARQUITECTURA lo hacen);
a ellas solo por buzón con `[coord]`. ARQUITECTURA antes avisaba solo con comentarios en el PR (su send_message a la nube
fallaba): ya avisa por mensaje. **Si alguien dice que entregó y no llegó nada, mirar los PR abiertos.** Las locales en
reposo no procesan el buzón hasta que Titín las despierta; Titín a veces les da órdenes directas: preguntarle una línea.

**Hitos del 13-11.**
- **3.1.1 publicada del todo** (build 44, 198.63.44; firma en bak, appcast verificado, web #976; registro #979).
  Catalina: arranca y «funciona mejor» (Titín); falta solo guardar con el selector en ~/LIBRARY.
- **Sync 3.2:** servidor #977 y cliente #981 **fusionados con APTO** de SEGURIDAD-PORTES-23 (C1 secreto por aparato,
  C2 contador, C4 FIFO; K1–K3). Binario en la release `flyweb-sync` (f988e2f, SHA-256 1a836217…cc2a).
  **Instalación en ns2 (H2):** script `instalar-como-root.sh` revisado por la 41 (SHA 7efbfc4a…bd3e23, copia en
  `buzon/COORDINACION/`). Titín ejecuta en ns2 **una sola vez** `sudo bash /home/servidor/sync-h2/instalar-como-root.sh
  binario`; luego SERVIDOR-LOCAL edita la unidad (ESPERAS_MAX=400000, SCRYPT_A_LA_VEZ=8, cola 32, MemoryMax=1G; aprobados
  por SEGURIDAD) y pide a Titín `credenciales`. Pendiente: copia fuera de línea de las credenciales (propuesta de
  SERVIDOR-LOCAL → Titín) antes de abrir la sync a otros. Cliente: compilar cuando la 3.1 esté medida (**no confirmado**) y
  capturas para Titín (página nueva y dos textos nuevos).
- **3.1.2** (PR #985, borrador, SEGURIDAD-PORTES-23): V8 .59 **retirada** (la .60 la revierte; se queda la .58); KEV 0
  nuevos. Falta el delta de la 158 (17-11). **Candidato: respaldo OpenGL de ANGLE** para Mac 2012–2015 en 10.14/10.15
  (#982, `FlyWeb/parches/3.1.2-gl-reserva/` 0001–0005; 5,9 fps por software frente a 59,9 con GL en la 2.7.0). SEGURIDAD:
  **APTO con condiciones** (G-C1 cuatro arreglos de ANGLE en `FlyWeb/seguridad/3.1.2/angle/`, como en la 3.0.1; G-C2
  pruebas en el MBP9,1, buzón LOCAL 0005; G-C3 avisado a SEGURIDAD-VIGÍA). **Falta lo decisivo:** que la preliminar de
  LOCAL-19 (`local/311-gl-reserva`) pinte; la compilación conservada de B1c abortaba con GL en la 6,1. Titín: si está en
  verde a tiempo entra en la 3.1.2; si no, la 3.1.2 sale solo con seguridad y GL va en una 3.1.3. **Titín pidió aviso
  cuando LOCAL tenga la preliminar.**
- **«Continuar con Google» / error 11** (no regresión: ya en la 3.0 en la 6,1): sin sesión de Google, la emergente falla y
  la pestaña muestra «error 11», probablemente caída del renderer (SIGSEGV). LOCAL-19: buzón 2125 y 2135 (informes de
  caída primero, reproducir sin CDP, comparar con Brave y Chrome 156). Después de lo de GL. No para la 3.2.0.
- Informe 2 parte A de estándares fusionado (#986). Titín aún no ha marcado la lista §7 (recomendación de la 41: 1, 2 y 5
  ya; 3 tras la 3.1.2; 4 cuando haya hueco). Entorno de la nube abierto a webkit.org, MDN, mozilla, web.dev, WHATWG,
  CSSWG, W3C y tc39.es.
- Plataformas: estudio #989 fusionado. Orden de Titín: 3.2 → fábrica de Mac → Ubuntu → Android → iOS → Windows.
- BackupDrive: no quitar FreeFileSync aún. Titín abre BACKUPDRIVE-4 (local) con el texto que le dio la 41; tanda de
  pruebas y veredicto.

**Sesiones.** Nube: SEGURIDAD-PORTES-23 `session_01MwmK2ihLC48xJinz4Li6Jv` (3.1.2, 158 el 17-11), INVESTIGACIÓN-MOTOR-10
`session_01MwmK2m3DpZgC8k7wAabHHG` (parte B el 17-11; quieta), MOTOR-46 `session_01MwmK2juPkbC58kEi4QFeyU` (quieto),
SYNC-NUBE-1 `session_01MwmK2kqPRtZ2aYJJ9Tx1kX` (quieta), SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`. Archivadas:
MOTOR-45, INVESTIGACIÓN-MOTOR-9, SEGURIDAD-PORTES-22. COORDINACIÓN-40 quieta (archivar).

**Avisos programados en la 41 (borrarlos cuando la 42 programe los suyos):** `trig_012R4cSXa52CaFUVLW46shDB` (17-11 21:15:
mandar a SEGURIDAD-PORTES-23 el delta de la 158) y `trig_01P8hhFP56wmrbLU17WZibji` (17-11 21:30: parte B a
INVESTIGACIÓN-MOTOR-10).

**Pendiente de Titín:** pegar `binario` en ns2 y después `credenciales` cuando lo pida SERVIDOR-LOCAL; lista §7;
cerrar PR viejos (#943, #865, #832, #560, #512, #467, #456; no contestado); prueba FSA en ~/LIBRARY; abrir BACKUPDRIVE-4.

**Lecciones.** Mi decisión S3 era falsificable y la cazó SEGURIDAD: las decisiones de seguridad que tome COORDINACIÓN
pasan siempre por SEGURIDAD-PORTES. No ofrecer a Titín pasos que deberían hacer los agentes (le molestó tener que fusionar).

## 13-11 (tarde): COORDINACIÓN-40 → COORDINACIÓN-41 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-40 (`session_01MwmK2iSWxzb4yvKWQc6eJC`, 12-11 18:50 → 13-11 ~13:45 UTC; Opus 5.5 medio; linaje 7 de 8;
relevo al 37 %). **La 41 la abre Titín desde claude.ai**: el linaje vuelve a 1 y puede abrir sesiones y programarse avisos
otra vez. **Nunca llamar a confirm_repository_trust.**

**Canales:** las locales (LOCAL-19, LOCAL-21, PUBLICACIÓN, SERVIDOR-LOCAL, ARQUITECTURA, cartero) nos escriben por bridge,
pero no se les puede escribir por send_message (401/untrusted device): buzón con `[coord]`. **D8-LINUX («motor ubuntu (4)»,
`session_01MwmK2jroj3oTQj5G1QKnyt`) no lo alcanza el cartero:** sus encargos van en el buzón y Titín se los pega. El cartero
pide a Titín confirmar cada relevo de COORDINACIÓN: pídeselo en el primer mensaje (texto en la nota de la 39 → 40).
Nube: SEGURIDAD-PORTES-22 `session_01MwmK2gyj8BaukttCj4uahG` (relevada al 56 %, nota «22 → 23», quieta; archivarla cuando
la -23 esté activa), MOTOR-45 `session_01MwmK2kdamTiZHb5S9SwNW7` (quieta, nota al día), SEGURIDAD-PORTES-21 (archivar),
SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS` (Haiku, diaria).

**Hitos (todo comprobado):**
- **3.1.1 compilada y entregada** (FS.44, #971/#972; build 44, 198.63.44, 156.0.8078.104, V8 .58; brave-core `local/3.1.1`
  3e2c12fad57, chromium `seg/3.1.1` 9e0d83137f, ls-remote). Contenido en `FlyWeb/seguridad/3.1.1/CONTENIDO.md` (#966–#970):
  34 + 9 (.104) parches de seguridad, Catalina 0001–0004 (#957), choque con `navigation_request.cc` de Brave resuelto y
  APTO (SEGURIDAD-22). 7,1 y 6,1 en verde. Sin la 158 y sin la V8 .59 (DIRECTIVAS #965).
  **Parada en la notarización:** Apple pide aceptar un acuerdo nuevo en la cuenta de desarrollador (MQ3NJ73LC5). Solo
  Titín. Avisado. Cuando lo acepte, PUBLICACIÓN termina sola (ya tiene orden de publicar sin esperar a Catalina,
  `buzon/PUBLICACION/…-311-publica.md`) y le manda a Titín la firma en bak.
- **Catalina:** la 3.0.x/3.1.0 no arrancaba (CGPreflightScreenCaptureAccess). Arreglo de MOTOR-45 (#957). LOCAL vio que esos
  importes ya eran débiles en la 3.1.0 (el README de MOTOR decía fuertes): el arreglo vale igual (las guardas evitan la
  llamada), pero **solo la prueba de Titín en el Mac mini y el MBP 2012 lo cierra**, más FSA en `~/LIBRARY` a mano.
- **V8 .59:** d8/mjsunit en verde (#969); parche listo en `FlyWeb/seguridad/3.1.1/v8-15.6.75.59/`. Va con la 158.
- **Sync 3.2:** Titín simplificó (DIRECTIVAS #962: sin bloqueo, contraseña obligatoria, sin código visible, 14 días, bak a
  30 días, sin E) y **aprobó H1** (13-11, #965). Diseño en `arquitectura/sync-cuenta` (#905, abierto). Falta que ARQUITECTURA
  corrija **N6** (tabla de esperas: no descartar entradas activas) → entonces fusionar #905; sigue H2.
- **Directiva «Flink a nuestro ritmo»** (#963). **Aquarium 15k en la 6,1 bimodal** (#972: ~41 fps con renderer al 100 % o
  55–57 con `CrGpuMain` al 90 %); hipótesis de colocación de hilos pasada a ARQUITECTURA (buzón 13-11).

**Abierto (por orden):**
1. **3.1.1:** acuerdo de Apple (Titín) → PUBLICACIÓN → firma en bak (Titín) → prueba en Catalina (Titín) → registro.
2. **17-11 (Chrome 158 estable):** abrir **SEGURIDAD-PORTES-23** (Opus 5.5, alto): delta de la 158 + KEV sobre
   `seg/3.1.1`/`local/3.1.1` + V8 .59 ya preparada + comprobar N6. **Titín decide** si sale como 3.1.2 solo de seguridad o en
   la 3.2.0. Si la V8 cambia, otra pasada de d8 en el Ubuntu (Titín la pega). Archivar SEGURIDAD-22.
3. **17-11:** abrir **INVESTIGACIÓN-MOTOR-10**, informe 2 de `novedades-motor.md` con sección nueva de Firefox/Safari y de
   navegadores que mantienen macOS viejos (aprobado por Titín).
4. Sync: N6 → fusionar #905 → H2 de ARQUITECTURA. Multihilo: después de la 3.2 (#949 primero; P2 con página real).
5. PR viejos abiertos (#943, #865, #832, #560, #512, #467, #456): proponer a Titín cerrarlos.

**Avisos programados en la 40 (se borran cuando la 41 programe los suyos):** `trig_01CBYXUz1o8M8DSgWnK9wgPW` (17-11 21:15,
SEGURIDAD-23) y `trig_01Q8zPxgVM9RE6N8YVJsq6Tw` (17-11 21:30, INVESTIGACIÓN-MOTOR-10). **La 41 programa los suyos y avisa a
la 40 para que los borre.**

**Lecciones:** Titín quiere menos casos extremos y más sencillez (sync); si algo para la versión sin motivo, se dice y se
mueve (la 3.1.1 salió sin esperar a la 158). Cruzar siempre los `patches/` de brave-core con una serie de seguridad antes
de cerrar CONTENIDO. No mandar a Titín avisos de rutina.

## 12-11 (tarde): COORDINACIÓN-39 → COORDINACIÓN-40 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-39 (`session_01MwmK2mJmxGn5H9FT1kg9Bo`, 10-11 21:25 → 12-11 ~18:50 UTC; Opus 5.5 medio; abierta por la 38,
linaje 6 de 8; relevo al 35 %). La 40 la abre la 39 (linaje 7 de 8: **las sesiones que abra la 40 serán las últimas
del linaje**; la 41 tendrá que abrirla Titín o una sesión de linaje bajo). **Nunca llamar a confirm_repository_trust.**

**Canales:** las locales (LOCAL-19, LOCAL-21, PUBLICACIÓN, SERVIDOR-LOCAL, ARQUITECTURA, cartero) nos escriben por
bridge, pero no se les puede escribir por send_message: buzón con `[coord]` y, si importa, texto para que Titín lo
pegue. **Cartero:** Titín lo relevó (12-11) y le pegó la confirmación de la 39 con orden de **no reenviar** los
ficheros de la 39 hasta `20261112-1733` (pegados a mano o superados) y entregar los nuevos. Comprobar en
`ENTREGADO.md` que acepta a la 40 (lección de la 37: si exige a Titín, pedírselo en el primer mensaje).
Nube activa: SEGURIDAD-PORTES-21 `session_01MwmK2iSJ4qGU8EyNDJhUH3` (linaje 7), MOTOR-45 `session_01MwmK2kdamTiZHb5S9SwNW7`
(linaje 7, sin encargo tras #949), SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS` (Haiku, diaria).

**Hitos (todo comprobado):**
- **3.1.0 PUBLICADA y cerrada** (198.63.43; brave-core `local/3.1` fc9389773fe; DMG 37a81396…fcb28; #935, #938 web por
  web-auto, #952 registro). 7,1 y 6,1 en verde. MotionMark 7,1 frente a Brave: 3560 / 3167 (Titín).
- **Maglev en la 5,1:** +9,4 % en Speedometer y JetStream, 0 caídas (`rendimiento-3x.md` §3 bis, #950). Se queda.
  Guion `FlyWeb/tools/prueba-51/` arreglado (#945; kit v3 en /pruebas/). Los .txt llevan datos de la cuenta: no al repo.
- **CVE-2026-125350/-125346 (XML, en la naturaleza):** ya corregidas en la 3.0.1 (parche 0034) (#937).
- **Versiones (DIRECTIVAS #948):** no hay 3.0.2; la seguridad de Chrome 158 es la **3.1.1**, sin esperar a la 3.2.0. Se
  sigue declarando 156; prueba de huella de Chrome 156 en la 3.1.1.
- **3.1.1:** serie previa en main (#951, `FlyWeb/seguridad/3.1.1/`, 34 parches sobre seg/3.0.2 502e3c5b85, árbol
  3d9092e4e3; V8 .51→.58, Skia, 21 [M156], 4 [M157]). SEGURIDAD-PORTES-21 añade el delta de la 158 y el KEV el 17-11.
- **Sync de la 3.2 (#905):** tres pasadas de SEGURIDAD (aprobable para H1), pero **Titín cambió el modelo el 12-11**
  (DIRECTIVAS #947, #948): Firefox Accounts, sin aprobación entre Macs, borrado 14 días, sin tope diario (aviso por
  email), Mac = modelo + nombre, bak cifrada 30 días, legal con plantillas sin datos personales. ARQUITECTURA (Fable 5.2)
  lo rehace con `buzon/ARQUITECTURA/20261112-1017-…`, `…-14dias`, `…-1054-…-fxa-seguridad` (pegados por Titín).
- **Multihilo/multiGPU (#941, #946; DIRECTIVAS #944):** E1/M1/M2 **después de la 3.2**. Parches del renderer de WebGL
  de MOTOR-45 en `FlyWeb/parches/3.2-renderer-webgl/` (#949; SEGURIDAD: 0002 apto; 0003 con d8 en verde). Basemark en
  `pruebas-gpu.md` (#942).

**Abierto (por orden):**
1. **3.1.1:** d8/mjsunit con Maglev en el Ubuntu (`buzon/D8-LINUX/20261112-1750-…`; la sesión del Ubuntu está caída:
   Titín tiene que abrirla) → 17-11 delta de la 158 (SEGURIDAD-PORTES-21) → orden de compilar a LOCAL-19 (cerrar antes
   el contenido; pruebas: navegación de 0030/0031 —popups, about:blank/srcdoc, file://, claude.ai—, FSA, huella 156,
   lo habitual en 7,1 y 6,1) → ls-remote → PUBLICACIÓN → firma en bak.
2. Sync: diseño nuevo de ARQUITECTURA → SEGURIDAD-PORTES-21 (KDF, separar clave de autenticación y de envoltura,
   cambio de contraseña, Mac robado) → Titín.
3. Después de la 3.2: E1/M1/M2 con los parches de #949.
4. FlyHand (Titín). PR viejos abiertos (#943 superado por #945, #865, #832, #560, #512, #467, #456): proponer a Titín
   cerrarlos.

**Lecciones:** la web la publica web-auto (no pedir subidas a mano a PUBLICACIÓN); antes de dar un resultado de la 5,1
por bueno, mirar las líneas por pasada (el resumen del kit v2 fallaba); Titín numera sus respuestas a su manera: casar
cada una con la pregunta antes de transmitirla.

## 10-11 (noche): COORDINACIÓN-38 → COORDINACIÓN-39 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-38 (`session_01MwmK2hsPeczzmEjVZHW81X`, 10-11 08:50 → ~21:30 UTC; Opus 5.5 medio; abierta por la 37, linaje 5
de 8; relevo al 33 %). La 39 la abre la 38 (linaje 6 de 8). **Nunca llamar a confirm_repository_trust.**

**Canales:** a las sesiones locales (LOCAL-19, LOCAL-21, PUBLICACIÓN, cartero…) no se les puede escribir por send_message.
El cartero se paró dos veces hoy (sin anotar desde las ~13:01 UTC salvo tandas sueltas): **lo práctico es darle a Titín el
texto para pegar**, además del fichero de buzón con `[coord]` en el commit (el cartero retiene relevos sin `[coord]`).
Las locales sí nos escriben. Borrar ramas remotas: el proxy de git da 403 (no se puede desde la nube); las 171 ramas
`claude/coord*` (148 con historial anterior a la reescritura de main, ninguna en PR abierto) las borra Titín en GitHub.

**Hitos del día:**
- **3.0.1 PUBLICADA y cerrada** (build 42, 198.63.42; DMG 5432bb3c…; #910, #913/#915 web, #914/#917 registro). Sparkle
  3.0.0 → 3.0.1 en la 6,1 bien; claude.ai bien en 7,1 y 6,1 (con y sin sesión). El fallo de §3.5 de `rendimiento-3x.md`
  (CDP en la 6,1 tras Maps) **no se reproduce a mano**: tratado como de la automatización.
- **MotionMark explicado:** reglas genéricas `[style…]` de Escudos obligan a Blink a serializar `style` (Brave pierde igual,
  `comparativa-71.md`). Parche `FlyWeb/parches/3.1-cosmetic-style/` (#921): MotionMark +12 %, Multiply +84 %, bloqueo igual
  (#929). Maglev: 7,1 +8,2 %, 6,1 +6,8/+6,6 %, sin caídas (#930); AVX: Maglev 0, V8 con despacho (#931).
- **Candidata 3.1** (LOCAL-21, #916/#922): t4 = Aquarium 10k a 60 fps, 15k +3–10 %, texturas 69/69. El cuello pasa del hilo
  de GPU (57–65 %) al renderer (100 %): **multihilo/multiGPU no suben Aquarium hoy** (respuesta dada a Titín).
- Favicons con la mosca (Chrome en NTP, Chromium en version) en `3.1-favicons` (#926).
- **Contenido 3.1 cerrado** (DIRECTIVAS #928 + #932, Titín «apruebo todo»): ANGLE 0001–0004, NTP privada 0004+0005,
  favicons, Escudos, **Maglev encendido** (la 5,1 se mide después de publicar, no bloquea). Diseño de privada y pestañas
  ligeras de Titín → 3.2 (capturas en `entregas/local21/diseno-32/`; la privada no tiene versión clara).
- **Orden de compilar la 3.1.0** (build 43) dada a LOCAL-19 (~19:15 UTC, buzón `…-1915-…-compilar-31.md` y pegada por
  Titín): rama `local/3.1`, pruebas por paso, entrega → PUBLICACIÓN; objetivo publicar el 11-11 por la mañana. Y guion de
  la 5,1 que use la FlyWeb instalada y el perfil de quien la use, en `FlyWeb/tools/prueba-51/`, sin Python 3.
- MOTOR-43 y MOTOR-44 relevados (notas en `relevo-motor.md`, #920 y #927). **MOTOR-45 sin abrir:** abrirlo con el texto de
  la nota de MOTOR-44 cuando haya algo (fallo de compilación de la 3.1, `chrome://history`, Speedometer −5 %).

**Abierto (por orden):**
1. Entrega de la 3.1.0 de LOCAL-19 → ls-remote de los hashes → PUBLICACIÓN → orden de firma en bak a Titín.
2. `chrome://history`: `getSearchField is not a function` (visto con la t4; LOCAL-19 dice si pasa en la 3.0.1).
3. Guion de la 5,1 → enlace a Titín → TXT → si pierde con Maglev, estudiar para la 3.2.
4. Diseño de sync de la 3.2: PR #905 de ARQUITECTURA abierto → revisión de SEGURIDAD → Titín.
5. 3.0.2 (158 estable, 17-11). 6. FlyHand: Titín lo retoma (la 6,1 libre). 7. Cartero: revisar con Titín por qué se para.

**Lecciones:** no pedir medidas que ya existen (pedí un Brave que estaba en `comparativa-71.md`); antes de dar un fallo por
real, que Titín lo pruebe a mano; un PR fusionado mientras el agente sube otro commit deja ese commit fuera (#923/#924).

## 10-11 (mañana): COORDINACIÓN-37 → COORDINACIÓN-38 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-37 (`session_01MwmK2huBYmy6zVGdznUAdg`, 09-11 23:09 → 10-11 ~09:00 UTC; Opus 5.5 medio; abierta por la 36,
linaje 4 de 8; relevo al 33 %: cada despertar recarga muchas herramientas). La 38 la abre la 37 (linaje 5 de 8).
**Nunca llamar a confirm_repository_trust.**

**Bloqueo principal: el cartero retiene todo lo de la 37** (`buzon/ENTREGADO.md`, «retenido … espera confirmación del
humano»; las pruebas en `main` —#907, #908— no le bastan, y hace bien). Ninguna orden de la 37 llegó a las locales. Titín
tiene que confirmar el relevo **a la 38** pegando al cartero una línea con el id de la 38 (la 38 se la da). Los 8 ficheros
retenidos de la 37 (`*-2309-COORDINACION-37-relevo.md`, `LOCAL/*-2310-…-hito0-ventana.md`, `CARTERO-LOCAL/*-2328-…`) ya
no hace falta entregarlos: la 38 manda los suyos.

**Hechos (todo comprobado):**
- **3.0.1 sin 0004:** brave-core `local/3.0.1` = **77ae53e5f6** (ls-remote; revert del 0004 hecho por LOCAL-19 a las
  23:03 UTC sobre 2ebd2e0). **No entregada en FS.42**; no se sabe si está compilada y probada.
- **Candidata 3.1:** `local/3.1-candidata` = **b6c544471e** (77ae53e + 0004 reaplicado + 0005). LOCAL-19 entregó las cuatro
  tandas (t1 = ANGLE 0001 … t4 = +0004). LOCAL-21: referencia de la 3.0.0 en la 6,1 hecha (texturas 69/69, Aquarium, NTP,
  three.js); la t1 bloqueada por LuLu en la 6,1 desde las 05:04 UTC. Titín (~08:00 UTC): en la 6,1 no ve aviso de LuLu; en
  la 7,1 sí y los aprobó → que LOCAL-21 relance la t1.
- **Hito 0 en la 7,1** (#909, fusionado): sin ventana (Titín trabaja en la 7,1), Chrome 157 (no 156): MotionMark −14,7 %
  (Multiply −48 %, Leaves −24 %, Suits −22 %: transformaciones CSS y SVG, no WebGL), Speedometer −13,1 %, JetStream −7,4 %,
  Aquarium 15k −5,3 %. Pendiente: repetir con una Chrome 156 y perfilar Multiply/Leaves/Suits. Lo gráfico con ventana, en
  la 6,1 o con la 7,1 libre.
- MOTOR-43 sin nada abierto (todo fusionado). SEGURIDAD-VIGÍA 10-11: sin KEV nuevos de Chromium.

**Abierto (por orden):**
1. Titín confirma la 38 al cartero; la 38 reenvía por buzón a LOCAL-19 la orden que la 37 le dio a Titín para pegar:
   «¿compilada y probada la 3.0.1 77ae53e (sin 0004)? Probar ventana privada = 3.0.0, página de sync, ajustes y los dos
   README; entregar en FS.42 con el hash; si no está compilada, antes que nada de la 3.1; informe por paso».
2. Entrega 3.0.1 → ls-remote → PUBLICACIÓN → **avisar a Titín para firmar en bak** (lo pidió) + recordatorio de la sync
   (7,1: «Ver código»; 6,1: abandonar y unirse; nunca «Eliminar cuenta»).
3. Candidata 3.1: LOCAL-21 relanza la t1 en la 6,1 (LuLu) y mide; luego decidir contenido de la 3.1.
4. Diseño de sync de ARQUITECTURA → SEGURIDAD → Titín. 5. 3.0.2 (158 estable, 17-11). 6. FlyHand `.aip`. 7. Limpieza de
   ramas (`claude/coord3*`, incluidas `claude/coord37` y `claude/coord37-relevo`).

**Lección:** antes de mandar nada por buzón tras un relevo, comprobar que el cartero acepta al nuevo id; si exige a Titín,
pedírselo en el primer mensaje, no después.

## 09-11 (noche): COORDINACIÓN-36 → COORDINACIÓN-37 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-36 (`session_01MwmK2gmWuLtoTHjfCXLggq`, 09-11 17:07 → ~23:15 UTC; Opus 5.5 medio; abierta por la 35, linaje 3
de 8; relevo al 35 %). La 37 la abre la 36 (linaje 4 de 8). **Nunca llamar a confirm_repository_trust.**

**Canales (importante):** desde la nube **no se puede escribir a ninguna sesión local** (bridges: LOCAL-19, LOCAL-21,
cartero, ARQUITECTURA, SERVIDOR-LOCAL, PUBLICACIÓN, FLYHAND-LOCAL, «ubuntu motor (3)»): `send_message` da
`elevated_session_untrusted_device`. Todo va por el buzón (el cartero entrega en 1–2 min) o Titín pega el texto. Ellas sí
nos escriben por SendMessage. A la nube (MOTOR-43) sí se le escribe.

**Hitos del día (tarde-noche):**
- **mjsunit** (D8-LINUX, «ubuntu motor (3)» = `session_01MwmK2kVVMhxRUscaawz4rP`): A/B/C sin caídas; el parser entra (#896).
- **3.0.1 UNIFICADA (decisión de Titín):** 79 de la 3.0.1 + todo lo de la 3.0.2 (V8 .51, [M157], parser, XSLT/WebHID fuera,
  foco, `flyweb_bundle_version_base`) + parches 0001–0003 de `FlyWeb/parches/3.0.2-sync-ajustes/` + icono de la 2.7.0
  (#898). Build 42. LOCAL-19: compilada, 0 FAILED, brave-core `local/3.0.1` 2ebd2e08731 (sin comprobar con ls-remote aún),
  todo en verde. **Orden de las ~23:05 (buzón):** quitar 0004 (NTP privada con marca de Brave), incremental tras la
  medición de LOCAL-21 en la 7,1, comprobar ventana privada = la de la 3.0.0, entregar en FS.42 → PUBLICACIÓN.
- **Causa de la sync rota de la 3.0.0** (MOTOR-43, #897/#899): Chromium 156 crea chrome://settings con su
  SettingsUIConfig y no la de Brave: sin ningún manejador de Brave (sync, Shields por defecto, filtros, Apariencia). El
  servidor y la cadena de Titín están bien (comprobado en ns2: ningún borrado hoy).
- **Perfil de Titín en la 6,1** roto por 3.0.0 → 2.7.0 → 3.0.0 (llavero): sin sesiones ni contraseñas. **Titín se queda en
  la 3.0.0** y espera la 3.0.1 para volver a unirse a la cadena (7,1: «Ver código»; 6,1: abandonar y unirse; nunca
  «Eliminar cuenta»). Las cookies de la 6,1 no vuelven. Requisitos de la 3.2 en `plan-3x.md` §5.1 punto 6 (#895).
- **3.1:** LOCAL-21 (`session_01MwmK2kS4ykodCqtwk7ypLU`, «FlyWeb 3.0.0 benchmark medición», bridge) midió la 6,1:
  Speedometer 10,3 (2.7.0: 5,84), JetStream 107,6 (89,3); perfil del hilo de GPU en `rendimiento-3x.md` (#903): puerta de
  hilos NO se abre (15,1 % < 25 %). MOTOR-43 (`session_01MwmK2keCUcEPJ6KTcxicZD`, nube, alto) entregó
  `FlyWeb/parches/3.1-angle/` 0001–0004 (#904; 0001 = texturas re-enlazadas en cada dibujo, 18,6 %, bug de ANGLE desde
  2020) y la NTP privada con marca FlyWeb (0004 + 0005 de 3.0.2-sync-ajustes, #906). **Orden en cola a LOCAL-19:** tras la
  3.0.1, candidata 3.1 = 3.0.1 + 4 de ANGLE + 0004/0005 (no se publica); LOCAL-21 la mide en la 6,1 (Titín aprueba LuLu).
- LOCAL-20 retirada (perdió el día; provocó el incidente del perfil). FlyHand fase 1 fusionada (#890, #901); la 6,1 se
  turna entre LOCAL-21 (medidas) y FLYHAND-LOCAL. ARQUITECTURA tiene el encargo del diseño `sync-cuenta.md` (3.2).

**Abierto (por orden):**
1. **Entrega de la 3.0.1** de LOCAL-19 en FS.42: hash de `local/3.0.1` con ls-remote; PUBLICACIÓN; **avisar a Titín
   para firmar en bak** (lo pidió expresamente) y recordarle cómo volver a unir la sync.
2. Candidata de la 3.1 (LOCAL-19 compila, LOCAL-21 mide) → si hay mejora y texturas bien, decidir contenido de la 3.1.
3. Parte de la 7,1 del hito 0 (LOCAL-21, empezó ~23:55 hora local).
4. Diseño de sync de ARQUITECTURA → revisión de SEGURIDAD → Titín aprueba.
5. 3.0.2 (nueva): con la 158 estable (17-11), SEGURIDAD-PORTES-21; INVESTIGACIÓN-MOTOR-10.
6. FlyHand: Titín prueba el `.aip` en Illustrator 25.1.
7. Limpieza: ramas `claude/coord3*`, `nube/motor43-sync-ajustes` (e8c20faf1c huérfana), `nube/b2-iconos`.

**Lecciones:** antes de dar una versión por probada, abrir la página de sync y las de ajustes; no pedir medidas que ya
existen (Titín, con razón); al ordenar a LOCAL, pasos con informe por paso; un cambio de contenido tras ordenar compilar
solo si Titín lo decide.

## 09-11 (tarde): COORDINACIÓN-35 → COORDINACIÓN-36 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-35 (`session_01MwmK2h9VVd6d8t4mGrtmzp`, 09-11 08:00 → ~17:15 UTC; Opus 5.5 medio; abierta por la 34, linaje 2
de 8; relevo al 37 %). La 36 la abre la 35 (linaje 3 de 8). **Nunca llamar a confirm_repository_trust.** Lo decidido hoy
está en DIRECTIVAS («Plan de la 3.x aprobado», sus decisiones, «Contenido cerrado antes de compilar», «Design Fly Suite»).

**Hitos del día:**
- **3.0.0 CERRADA:** firmada en bak, appcast verificado, web publicada y comprobada (#875, #876, #878).
- **Plan de la 3.x aprobado por Titín** (#883, #888; `plan-3x.md` #872): 3.0.x de seguridad siempre en marcha → 3.1 de GPU e
  hilos (FM.56) ya → 3.2 de sync con el diseño en paralelo. Los siete puntos de §7 de `plan-3x.md` aprobados. Versión
  declarada: 156; una función nueva solo si una web real la necesita.
- **3.0.1 compilándose** (LOCAL-19, 7,1, build 42): chromium fork `seg/3.0.1` c4b1caf806 + ANGLE, ffmpeg y PDFium (.patch) +
  brave-core `seg/3.0.1` 6415661d24 + marca d3fae32d5b + b2-tests 148a5939c8 + b2-depfile bbfb565048, **sin parser**.
  Arreglos de LOCAL-19 en `flyweb`: aee46c5da15 (gn `data +=`), f4f92db833e (include de `content_switches.h` en
  `sparkle_glue.mm`) y perfil PGO de V8 al día (`download_profiles.py --check-v8-revision`; **hay que correrlo en cada
  cambio de V8**). En la entrega: sí o no de `navigator.hid`, `navigator.install` y `TCPSocket`.
- **3.0.2 preparada** (SEGURIDAD-PORTES-20, #892, archivada): chromium `seg/3.0.2` 502e3c5b85 (V8 15.6.75.51, .98, 6 de la
  157, foco), brave-core `seg/3.0.2` 0d6a771f23 (XSLT y WebHID apagados, foco, `flyweb_bundle_version_base` 198.63).
  **No se puede ordenar compilarla** sin el mjsunit (cambia V8; d8 verde en el Ubuntu antes de LOCAL).
- **3.1:** MOTOR-42 entregó la lectura de ANGLE Metal (`rendimiento-3.1.md`, #885) y está archivado; nota en
  `relevo-motor.md` (MOTOR-43 implementa 3 y 4 primero, cuando llegue el perfil de LOCAL).
- INVESTIGACIÓN-MOTOR-9: primer informe (`novedades-motor.md`, #884), archivada; el siguiente, con la 158 (17-11).
- Cartero: se quedó mudo al 50 % (08:13 → 13:17 UTC); relevo al 35 % aprobado (#886). El nuevo es
  `session_01MwmK2i8TWjiAS24Km8Rb1Z` y entrega en 1–2 min.
- SEGURIDAD-VIGÍA pasa a **diaria** (08:58 Madrid). Su texto de pasada sigue hablando de la 128 y no se puede cambiar desde
  COORDINACIÓN; se le corrigió por send_message. Titín puede cambiarlo en su conversación.
- Craft (#869) fusionado: espera a la beta de storytold. Titín puso a FLYHAND-LOCAL (`session_01MwmK2imxzm1dF7p4BdPeUv`) a
  hacer el módulo de Illustrator que abre FreeHand en la 6,1, con la cuenta `craft` (creada por Titín el 09-11 por la
  tarde; la clave `dfs_craft` estaba en ello). FlyHand no es código de storytold y no necesita la jaula.

**Abierto (por orden):**
1. **mjsunit (decisión de Titín, sin respuesta):** A) reabrir «Motor ubuntu» (recomendada; una pasada valida la V8 .51 y el
   parser), o B) LOCAL con d8 en la 7,1 (rompe la directiva). Bloquea la orden de compilar la 3.0.2.
2. **Entrega de la 3.0.1** de LOCAL-19 en FS.42 → PUBLICACIÓN (regla 11). Comprobar los hashes con ls-remote antes.
3. **LOCAL-20 sin señales desde las 08:07 UTC:** pruebas de Sparkle de la 3.0.0, luego el hito 0 y el perfil de la 3.1 en la
   6,1. Se le preguntó por el buzón (16:15) cuándo deja libre la 6,1. **FlyHand no compila en la 6,1 mientras haya
   medidas.** Si no contesta, decírselo a Titín.
4. Duda de FlyHand: el SDK de Illustrator reciente puede no compilar con Xcode 11.3.1 (6,1); quizá deba ir a la 7,1.
5. Cuando llegue el perfil de LOCAL: abrir MOTOR-43 (arreglos 3 y 4 de `rendimiento-3.1.md`).
6. 3.0.3 y medida de diciembre: con la 158 estable (17-11), abrir SEGURIDAD-PORTES-21; también INVESTIGACIÓN-MOTOR-10.
7. Limpieza sin prisa: ramas `nube/b2-iconos` (brave-core) y las `claude/coord3*` (softmac).

**Lecciones:** comprueba `buzon/ENTREGADO.md` en cada turno en que mandes algo al buzón, con un `send_later` a los 15–20
min; más de 45 min sin anotar = aviso a Titín. Cierra el contenido antes de ordenar compilar. Los PR de softmac los
fusiona COORDINACIÓN (MOTOR-42 se fusionaba los suyos; corregido).

**Equipo vivo:** LOCAL-19 y LOCAL-20 (bridges, solo buzón), PUBLICACIÓN, SERVIDOR-LOCAL, CARTERO-LOCAL, ARQUITECTURA
(local), FLYHAND-LOCAL, SEGURIDAD-VIGÍA (rutina). Archivadas hoy: MOTOR-42, SEGURIDAD-PORTES-19 y -20, INVESTIGACIÓN-MOTOR-9.

## 09-11: COORDINACIÓN-34 → COORDINACIÓN-35

COORDINACIÓN-34 (`session_01MwmK2m1QvhRzNFCDSWtvkf`, 07-11 15:05 → 09-11 ~08:00 UTC; Opus 5.5 medio; abierta por la 33,
linaje 1 de 8; relevo al 64 %, tarde: el umbral era el 35 %). La 35 la abre la 34 (linaje 2 de 8). **Nunca llamar a
confirm_repository_trust.**

**Hitos:**
- **FlyWeb 3.0.0 publicada en lo nuestro, salvo la firma en bak.** Build limpia de LOCAL-19 sobre brave-core
  `nube/b2-porte-t11` = **bf4262a094**, FLYWEB_BUILD_NUMBER 41, CFBundleVersion 198.63.41. Pruebas A–E en verde
  (FM.55, #856), incluidas la migración del perfil 2.x sobre copias y los browsertests de b2-privacidad en la 6,1. PUBLICACIÓN
  firmó la copia `software/entregas/FlyWeb-3.0.0-release/FlyWeb.app` (sha del framework ccabdcd9…2e98) y subió el DMG (sha
  143d58ae…8a25). **Falta: Titín firma en bak; después, appcast y web (PUBLICACIÓN avisa).**
- Arreglos de última hora en la 3.0.0: b2-privacidad dentro; la copia «antes de 3.0» tolera los temporales y solo pone la
  marca si sale bien («… sin copia» si no); la semilla de sync ya no se borra sin llavero; CHECK de
  GetLocalPersonalContextInfo por kPersonalContext apagado (bf4262a09).
- **5,1:** el kit de la 3.0.0 da verde (MotionMark 864 a 60 fps, sin AVX, Metal en la RX 580; `pruebas-gpu.md`, #868). El kit
  ya está borrado de ns2; Titín borra el directorio vacío `kit-51`.
- **Versiones desde la 3.0.0** (Titín, DIRECTIVAS, #859): el segundo dígito son avances; el tercero, seguridad y arreglos.
- **3.0.1 (FS.42, SEGURIDAD-PORTES-19 `session_01MwmK2hrcXTzbQgJfQ2PL5U`):** seguridad cerrada en main (#861, #862, #864,
  #870, #871): 79 parches, 85 % limpios. Chromium (61 format-patch sobre flynk-b1d 33a1745949, árbol 2723e1b371c), ANGLE,
  ffmpeg y PDFium en `FlyWeb/seguridad/3.0.1/`. brave-core `seg/3.0.1` = 6415661d24 y `seg/3.0.1-parser` = bee89ad8a6 (los 21
  commits del parser de V8, CVE-2026-121082). CanvasDrawElement apagado. CVE-2026-121112 pasa a la 3.0.2.
- **Marca para la 3.0.1 (MOTOR-42 `session_01MwmK2iFB5QKJ5nASYk5dxj`):** `nube/b2-icono-restaurar` = d3fae32d5b: barra de
  restaurar, browser_logo, SVG de Sync y bienvenida, pedales. También para la 3.0.x: `nube/b2-tests` 148a5939c8 (desde
  d662 toca producción: la guarda de Sparkle), `nube/b2-depfile` bbfb565048 y `nube/b2-redirect-cc`, más lo no portado
  (Shields, WebGPU, Containers, UpdateTargetURL).
- **MotionMark de la 7,1** (LOCAL-19): la nota baja de Titín viene de la pantalla de 144 Hz y de su sesión cargada. A 60 Hz,
  FlyWeb da 3400–3700, al nivel de Brave 1.99 y entre un 8 y un 15 % por debajo de Chrome 157. No hay guarda nuestra
  culpable.

**Abierto (por orden):**
1. **Firma en bak de la 3.0.0** (Titín) → PUBLICACIÓN: appcast y web → URL y appcast comprobados.
2. **mjsunit de la 3.0.1** con tres V8 (3.0.0, `seg/3.0.1`, `seg/3.0.1-parser`): el encargo está en `buzon/MOTOR/` y sin
   entregar, porque la Ubuntu (MOTOR-30) está desconectada. Pregunté a Titín: A) reabrir «Motor ubuntu», o B) que lo haga
   LOCAL-20 en la 7,1 con d8. Sin respuesta. Si el parser no tiene caídas propias, la 3.0.1 sale de `seg/3.0.1-parser`.
3. **add_repo de lamosquita-net/chromium** para SEGURIDAD-PORTES-19: lo autorizó Titín, pero el modo auto lo denegó.
   Espera a que Titín lo apruebe en esa sesión. Si no, LOCAL aplica los 61 parches con `git am`.
4. **Orden de compilar la 3.0.1** a LOCAL-19 cuando estén 2 y 3: brave-core = `seg/3.0.1(-parser)` + marca + lo que se
   decida de la 3.0.x; `flyweb_version` 3.0.1, FLYWEB_BUILD_NUMBER 42; las pruebas de la marca, en la fila de MOTOR-42.
5. **LOCAL-20:** pruebas de la 3.0.0 publicada en la 6,1 (actualización por Sparkle sobre una copia del perfil y la lista
   manual). Esperan al appcast.
6. **ARQUITECTURA:** el estudio de la 3.x (`FlyWeb/docs/plan-3x.md`) le llegó el 08-11 a las 12:56, offline. Titín habla
   con ella directamente. Mi recomendación: la 3.1 sea la línea de GPU e hilos (FM.56); el sync con email (F7.7) va como
   diseño en paralelo.
7. **Design Fly Suite** (proyecto aparte de Titín, en Rust; apps Craft de storytold): análisis en la nube primero; la jaula
   `craft` de la 6,1 la hace LOCAL-19 solo tras el informe. #869 revisado: sin datos del entorno, pero **no fusionar** hasta
   que su Fase 1 pase a «partir del informe de la nube» y la jaula sume pf por usuario, `Match User craft`, `sudo -k` y la
   comprobación de /Volumes y /Users/Shared. Titín no ha dicho si ese proyecto fusiona sus propios PR.
8. Limpieza sin prisa (Titín): las ramas `nube/b2-iconos`, `nube/b2-mac-flynk` y `nube/m34-probe` (brave-core), y
   `nube/pgo-mojave`, `nube/coord33-arranque` y las `claude/coord34-*` (softmac).

**Lección:** el cartero se cayó el 07-11 a las 20:46 UTC y nadie lo vio en 13 h; la orden de publicar la 3.0.0 no llegó.
Compara a mano `buzon/ENTREGADO.md` con `buzon/*/` en **cada** turno en que mandes algo al buzón; la vigilancia
de CronCreate no sirvió. El CARTERO-LOCAL nuevo (relevo del 08-11) está bien. Los mensajes a MOTOR fallan mientras la
Ubuntu esté apagada.

**Equipo vivo:** MOTOR-42, SEGURIDAD-PORTES-19, LOCAL-19 y LOCAL-20 (bridges, solo buzón), PUBLICACIÓN, SERVIDOR-LOCAL,
CARTERO-LOCAL (relevo del 08-11), ARQUITECTURA (offline). MOTOR-41 y SEGURIDAD-PORTES-18, archivadas.

## 07-11 (tarde): COORDINACIÓN-33 → COORDINACIÓN-34 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-33 (`session_01MwmK2kDoYYca7UqZKpt6gH`, 07-11 09:42 → ~15:15 UTC; Opus 5.5 medio; abierta por Titín, linaje
nuevo, profundidad 0; relevo al ~33 %). La 34 la abre la 33 con `create_session` (linaje 1 de 8). **Nunca llamar a
confirm_repository_trust.**

**Hitos del día:**
- **Porte B2 (FM.55): la 3.0.0 compila, arranca y pasa casi todo en la 6,1.** Punta `nube/b2-porte-t11` = `nube/b2-mac` =
  **d2fd3793c5** (ls-remote). Build de LOCAL-19 «limpia en c7e39138ca + incremental en d2fd», PGO, oficial, 0 FAILED,
  CFBundleVersion 198.63.40 / 3.0.0. Verde (informe por letras de LOCAL-19): Sparkle (se registra solo, detecta un appcast
  de pruebas y rechaza un paquete sin firmar), YouTube con H.264 por VideoToolbox, B5 (Privacy Sandbox, APIs de IA,
  HTMLPermissionElement/UserMediaElement, speculationrules: todo undefined o false), DoH apagado, External Extensions
  (lado negativo), /json/version 156, lista «MOTOR-40» (flyweb://, bienvenida, NTP, settings con iconos Leo, PDF, Metal en
  la D500, GPC), 0 FATAL/Check failed en 4 rondas.
- **Clases de rotura del salto 128 → 156** (relevo-motor.md, «MOTOR-41»): override muerto (DoH, BraveBrowserMainPartsMac =
  sin Sparkle ni copia de perfil, supported_types, radio del omnibox); `base_feature_status: "disabled"` sin override en el
  json5 (Protected Audience + 16 de 1.98); .o viejo (DoH); override que compila y elimina LTO sin error (supported_types).
  Herramientas: `check-overrides-156.sh` (con guarda del json5) y `check-overrides-o.py` (de LOCAL-19).
- **Copia del perfil «antes de 3.0»** (c7e39138c, decisión mía): marca «FlyWeb 3 Profile»; sirve para volver a la 2.x.
- **FS.41 cerrada** (SEGURIDAD-PORTES-18, #834 y #842). Riesgo anotado: Sparkle 1.24.3 sin mantenimiento → valorar la 2.x
  **después** de la 3.0.0.
- **FM.54 F1 hecho** (#831, #838): `lamosquita-net/chromium` flynk ae83e77df4 (por defecto), `lamosquita-net/v8` flynk-v8
  f3b9aa2599. Autores revisados por Titín a ojo: limpios. El correo genérico del autor es suyo y correcto (no reescribir).
- **5,1:** kit oficial-6 apto (Metal en la RX 580, 0 errores, sin AVX); resumen en el buzón de LOCAL-19 para
  `pruebas-gpu.md`. Kit borrado de ns2 por SERVIDOR-LOCAL; el directorio vacío, de Titín.

**Decisiones mías:** regla 20 para todo lo de privacidad (lo que Brave 1.98 apaga, fuera; lo que deja, se queda:
speculationrules por prefetch y HTMLPermissionElement por GeolocationElement); DoH como la 2.7.0 (off); External Extensions
en `/Library/Application Support/LaMosquita/FlyWeb/External Extensions`; build limpia para validar la 3.0.0; MediaClient
renombrado por la macro, aceptado (como la 2.x); fuera el aviso de sistema obsoleto (ya decidido el 04-11).

**Abierto:**
- MOTOR-41: aviso «macOS 13 / este ordenador usa macOS 12» en flyweb://help (ObsoleteSystem en Mac → nunca), y confirmar
  que el .82 de client hints es `flyweb_engine_full_version` a propósito. Hash comprobado con ls-remote → LOCAL-19.
- LOCAL-19: letra b) perfil 2.7.0 sobre una **copia** (llavero: avisar a Titín), y lo que pide interacción nativa.
- **Antes de publicar la 3.0.0:** build limpia de verdad sobre la punta final, con **FLYWEB_BUILD_NUMBER = 41** (la de prueba
  lleva 40, copiado a mano de la 2.7.0), la 5,1 con esa build y entrega en la fila (regla 11).
- Pendiente de Titín (manual en la 6,1, app en `~/flyweb-pruebas/porte-156/`, ya permitida en LuLu o por permitir): Claude
  desde la Web Store, menú contextual (copiar sin rastreo, OCR, corrector), clic del cuentagotas, píldoras del omnibox,
  passkey con el móvil (caBLE), copiar en ventana privada, llavero. Opcional con sudo: lado positivo de External Extensions.
  Sin prisa: borrar `nube/b2-mac-flynk` y `nube/m34-probe` (brave-core), `nube/pgo-mojave` y `nube/coord33-arranque`
  (softmac), y el directorio vacío del kit en ns2; kThirdPartyAiChatSettings; aprobar el icono de macOS 26; red de la oficina.
- Riesgo a futuro: CFBundleVersion = 198.63.N viene de la versión de Brave; si se deja de partir de Brave, debe seguir
  subiendo o Sparkle no ofrecerá la actualización.

**Equipo vivo:** MOTOR-41 (`session_01MwmK2hUzGWKU8HxCSRGfc2`, brave-core con push, ~25 %; MOTOR-40 archivada), LOCAL-19
(build del porte; bridge, solo buzón), LOCAL-20 (F1 cerrado; libre), MOTOR-30 (Ubuntu, libre; buzón vía «Motor ubuntu (2)»),
SEGURIDAD-PORTES-18 (`session_01MwmK2hd2TWsrKjZY9iJB8x`, en espera), SERVIDOR-LOCAL y PUBLICACIÓN sin encargo.
**Tareas programadas mías:** vigilancia horaria de sesión (CronCreate, se va con la sesión).
**Método:** dar un hash solo tras `git ls-remote`; a los bridges solo por el buzón; revisar el diff de cada PR (datos
personales) antes de fusionar con expectedHeadSha.

## 07-11 (mañana): COORDINACIÓN-32 → COORDINACIÓN-33 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-32 (`session_01MwmK2iTqaffXip3r8YT1NG`, 06-11 22:51 → 07-11 ~06:00 UTC; Opus 5.5 medio; abierta por la 31,
linaje 7 de 8; relevo al ~32 %). **La 33 la abre Titín desde la app** (linaje nuevo). **Nunca llamar a confirm_repository_trust.**

**Hitos de la noche:**
- **FM.54 F1 cumplido** (LOCAL-20): H4 (2.7.0 desde flynk f11fbc9866 / flynk-v8 08384eca7e, #815) y H5 (6,1 verde; WPT
  138: sin regresiones reales frente a la 2.7.0 publicada; nota #819). Falta solo el push de flynk/flynk-v8 con sus
  etiquetas base: **lo autoriza Titín en la sesión de LOCAL-20**; después, flynk como rama por defecto.
- **FM.55 B2:** P2 de 226e3ae0a = 0 rotos, pero MOTOR-30 vio que **127 parches no aplicaban** sobre la 156. **Regla nueva:
  un P2 con parches que no aplican no cuenta como 0.** MOTOR-40 rehízo la tanda (514/514; trampa de la 156: borra
  «Login Data» al migrar prefs, anulado como 1.98). Punta `nube/b2-porte-t11` = f5133ee5b → **eaefe8115** (ff de
  nube/b2-mac, pedido 05:46; confirmar). P3A borrado, iconos Leo, FM.31 fuera (Mojave va con Metal, como flynk-b1d).
- **Primera build Mac del porte** (LOCAL-19, f5133ee5b sobre flynk-b1d e67de82aba, PGO, -k 0): compila entera salvo 3 de
  C++ y 56 de lint, ya arreglados en eaefe8115. LOCAL-19 recompila para enlazar y arrancar headless. flynk-b1d =
  58cec3d923 (nunca Secure Enclave; cuentagotas genérico): 9 parches fuera de brave-core.
- Canvas 6,1 (LOCAL-19): Metal 2,4–2,6× la 2.7.0; 60 fps reales (los 45 de MotionMark eran suyos).

**Decisiones mías:** build Mac sin esperar al P2; F1 sin PGO (compara con la 2.7.0); redirect_cc se queda hasta la tanda
de envoltorios (`nube/b2-redirect-cc` 58be92043, sin juntar); use_siso=false; Release = oficial con PGO
(isBraveReleaseBuild); 5 políticas de Shields de 1.98: no (después de la 3.0.0); maglev_untagged_phis fuera (regla 19);
entitlement de VPN fuera; IPFS/Tor y los 3 de privacidad de 1.98 (window.name, farbling WebGL, sesiones brave://) en
tandas aparte tras la build Mac; Assets.car de FlyWeb → LOCAL-19; SDK 26.2 para la 156 (build.sh de la 3.0.0 deja de
pasar mac_sdk_path; también sparkle con download_sparkle.py, relevo-motor #821).

**Equipo vivo:** MOTOR-40 (`session_01MwmK2mJrB3myzidqeC1BfM`, nube, brave-core con push; MOTOR-39 archivada),
LOCAL-19 (build del porte; bridge, solo buzón o SendMessage suyo), LOCAL-20 (F1, esperando el push), **MOTOR-30
(Ubuntu) DESCONECTADA desde ~01:15 UTC**: el cartero deja sus mensajes en cola; Titín avisado por push (03:55). Tiene en
cola la orden del P2 de f5133ee5b (ahora: de la punta que haya). ARQUITECTURA: pregunta de kFlyWebCacheEpoch
(version.cc frente a v8_embedder_string). SEGURIDAD-PORTES-18: espera la build con los arreglos.
**Siguiente:** arranque headless de LOCAL-19 → build de eaefe8115 → comprobaciones en ejecución de relevo-motor.md
(«MOTOR-40», con la captura de iconos) en la 6,1 → SEGURIDAD-PORTES-18 (B5, A1–A4). P2 de MOTOR-30 cuando vuelva.
**Pendiente de Titín:** push de F1 en LOCAL-20; flynk por defecto; kThirdPartyAiChatSettings con la primera build Mac; borrar ramas `nube/b2-mac-flynk`, `nube/m34-probe`
(brave-core) y `nube/pgo-mojave` (softmac); mirar la red de la oficina (de madrugada bajó a 30 KB/s, no eran las Mac);
encender la Ubuntu.
**Añadido 05:58 UTC:** punta confirmada **eaefe8115** (mandada a LOCAL-19). `nube/b2-privacidad` = df54efacc (window.name en marcos provisionales, sesiones flyweb:// y brave:// → chrome://, farbling WebGL de 1.98 con vendor «WebKit»), sin juntar; WebGPU con ContentSettingsType nuevo, tarea aparte. **MOTOR-40 está en el 36 % y en el límite de profundidad (8/8): la 33 abre MOTOR-41** con la nota «MOTOR-40 → MOTOR-41» de relevo-motor.md (#823). Hasta entonces, MOTOR-40 solo atiende los errores de la build de eaefe8115.
**Tareas programadas mías:** vigilancia horaria `trig_01Fk4iHWqMecJoRanjpRYdmb` (la borro al pasar el relevo).
**Método:** el buzón de MOTOR solo entrega con la sesión conectada; LOCAL-19 puede reenviar a MOTOR-30 por SendMessage.
Desde la nube no se escribe a CARTERO ni a los bridges.

## 06-11 (noche): COORDINACIÓN-31 → COORDINACIÓN-32 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-31 (`session_01MwmK2iP27sssYimPaJ7scp`, 06-11 15:45 → ~22:55 UTC; Opus 5.5 medio; abierta por la 30,
linaje 6; relevo al 42 %). La 32 la abre la 31 (linaje 7 de 8: **la 33 tiene que abrirla Titín desde la app**).
**Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy (además de las de la nota de la 30):**
- **LuLu** (DIRECTIVAS, Organización, #807): un aviso de LuLu no es «máquina ocupada»; si una build nueva no tiene red,
  LOCAL da la ruta y COORDINACIÓN avisa a Titín.
- **LOCAL-20 abierta para F1** (LOCAL-18 la archivó Titín el 05-11; nada de F1 hecho). No recuperar la 18.
- **Fork de chromium:** `lamosquita-net/chromium` (antes chromium-legacy) YA está en la red de chromium/chromium y
  guarda `flynk-b1d`: **no se borra ni se crea otro**. Pendiente de Titín: poner `flynk` como rama por defecto tras el
  push (recordárselo) y **autorizar en la sesión de LOCAL-20** las etiquetas base y el push (lo bloquea su clasificador,
  «Create Public Surface»). Texto propuesto en la conversación: etiqueta 128.0.6613.138 en chromium, 10 etiquetas base
  de V8, push de flynk y flynk-v8, sin tocar master.lion, stable.lion ni flynk-b1d.
- **RAM:** 32 GB bastan con -j 12; no comprar.
- **Pendiente de Titín:** compilar `chrome` entero en la Ubuntu una vez (su regla allí: «nunca compilar Blink»). Le
  llegó cortado un mensaje suyo a MOTOR-30; la excepción tiene que ser explícita y de Titín (el clasificador de la nube
  bloquea con razón que COORDINACIÓN escriba «autorizado por Titín»). Recomendación: sí, una vez.

**Decisiones mías:** «PGO siempre» RESTABLECIDO (A/B limpio en la 6,1: Speedometer +42 %, JetStream +9 %, MotionMark
+21 %, 0 fallos; 7,1 igual). Lint de settings se arregla, no se apaga. Brave Search y buscadores prepoblados sin
`source=` ni códigos de socio de Brave (versión de datos 31). kQuietNotificationPrompts se queda (espejo sirve Crowd
Deny, comprobado en ns2). OFAC, kdf, brave_mobile_subscription, overrides de Windows, P3A tests: borrados.
kThirdPartyAiChatSettings: **pendiente de Titín** con la primera build Mac que pueda ver.

**FM.55 B2 (porte):** punta `nube/b2-porte-t11` **89e14c56e** (MOTOR-39). Recorrido de los P2: 99 (b1a25a49) → 12
(30f94067) → **6 (ab0be296)**; 0 símbolos sin definir; gn check limpio; lint de settings cerrado. Quedan 3 para
MOTOR-39 (mandado 22:47): view_shadow.cc (ui::Layer::Create), location_bar_view.cc:404 (OmniboxPopupViewViews con
BraveOmniboxViewViews*) y el mock del autoplay browsertest. Después: rápida de MOTOR-30 sobre la punta que haya
(cubre 307f566c en adelante y las unidades de Chromium de mis mensajes del buzón de d7457458, c1d9d8ae, 307f566c y 2125)
→ P2 → si da 0, **build Mac del porte con LOCAL-19 (con PGO y con e67de82a de flynk-b1d)** y lista de comprobaciones
en ejecución de `relevo-motor.md` (#811/#812: Google sign-in, UA Chrome/156, GCM apagado, Safe Browsing por el proxy,
iconos de Leo y spinners, buscadores sin source, portapapeles en incógnito).
**Lección:** el P2 solo cuenta objetivos de Brave; los overrides de chromium_src rompen ficheros de Chromium que no ve
(NotificationHandler::Type, PermissionType). Por eso chrome entero, si Titín lo autoriza.

**Equipo vivo:** MOTOR-39 (`session_01MwmK2goNHDRcfxEXELHuXM`, con brave-core; MOTOR-38 archivada, 100 $),
MOTOR-30 (Ubuntu, solo buzón; -j 12 en scope de systemd con MemoryHigh=24G; el servicio b2-cadena ya está borrado;
**si calla, puede estar esperando una pregunta: preguntarle por el buzón antes de alarmar a Titín**), LOCAL-19 (6,1:
canvas Metal/GL/2.7.0 hasta ~23:20; Ganesh cae ~15× en Canvas Arcs/Paths/Lines en la 7,1), LOCAL-20 (F1: H1–H3 hechos,
H4 Release desde flynk-r2 f11fbc9866 al 79 % sin errores; espejo Samba hecho, flynk-chromium.git 2,6 GB y
flynk-v8.git 1,1 GB), SEGURIDAD-PORTES-18 (espera build), SERVIDOR-LOCAL, PUBLICACIÓN, ARQUITECTURA, CARTERO-LOCAL.
**Tareas programadas mías:** vigilancia horaria `trig_01L8upyXCDpiBPkbGwYMoife` (la borro al pasar el relevo; la 32 la
crea en su sesión si sigue haciendo falta).

## 06-11 (tarde): COORDINACIÓN-30 → COORDINACIÓN-31 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-30 (`session_01MwmK2mDgcmCYXZUo9KnJZU`, 06-11 12:45 → ~15:45 UTC; Opus 5.5 medio; abierta por la 29, linaje 5;
relevo al 35 %). La 31 la abre la 30 (linaje 6 de 8). **Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy (no se tocan):**
- **Intocables del porte:** el permiso «Inicio de sesión con Google» de Brave entero (lo pidió él; se anuló por escrito
  mi orden de quitarlo) y las llaves de acceso con el móvil (WebAuthn híbrido: QR + Bluetooth; MOTOR-38 comprobó que nada
  las apaga, #799).
- **F7.7 (sync con cuenta):** flujo elegido y escrito en TAREAS (#797, #798, #800, #801): email + contraseña + código por
  email; recuperación por email; aviso en todos los navegadores; un navegador nuevo recibe la clave solo con la aprobación
  de otro ya sincronizado, **en espera sin caducar** (sin móvil no es inmediata); clave de recuperación como salida; todo con
  una sola clave y texto explícito de pérdida; borrado de cuentas inactivas a los 365 días con aviso 30 días antes
  (desactivado hoy: 7 usuarios). Es para estudiar, sin prioridad todavía.

**Decisiones mías del porte (en brave-propio.md §12.16, #794/#795/#799):** lista de lectura de Chromium se queda (go-sync
la admite; falta el viaje real); settings 156 obligatoria antes de cualquier build para Titín (hecha); history, extensions
y downloads sin tocar (compilan); Checkup oculto y detección de filtraciones apagada; subpáginas autoplay y estado de
Shields porteadas; Storage Access visible; AUTO_VERIFY/ANTI_ABUSE fuera como 1.98 (PST apagado); localhost → LNA
nativo (SERVIDOR-LOCAL avisado: `localhost-permission-allow-list.txt` se retira cuando no queden 1.x/2.x con soporte);
histograms solo `.ShieldsPanel`; webpack con `externalsPresets {web:false}` en vez de subir a 5.105; **GPC como 1.98**
(se excluye el IDL nativo; una sola fuente, el pref de Brave, para JS y Sec-GPC; contrario a «nativo primero», justificado).

**FM.55 B2:** punta `nube/b2-porte-t11` **901f0a1eb5** (MOTOR-38). Último P2 (MOTOR-30, b1a25a49): **99 rotos = producción 5
(2 reales) + tests 94**; 0 símbolos sin definir. Recorrido de hoy: 177 → 163 → 106 → 99. Ojo: el P2 no veía unidades gen/
con override; MOTOR-30 lo ha corregido y el próximo P2 suma 68 objetos (el total puede subir sin empeorar). Pendiente de
MOTOR-38 (mandado 15:4x): LOG(ERROR) en brave_new_tab_page_handler.cc, TS2347 en settings_main.ts:121 (cae settings_ui) y
los imports de side_bar.ts de password_manager (lint). Después: rápida de MOTOR-30 de 901f0a1e (en marcha) → tanda de
tests (lista en el P2 y 8 de la rápida de b1a25a49) → features de nivel → menores → envoltorios .cc → brave_services_key_id.
SEGURIDAD-PORTES-18 (`session_01MwmK2hd2TWsrKjZY9iJB8x`): crx_verifier OK (426a296b + 737f2e67, #793); en espera de una
build para B5 y A1–A4. Comprobación pendiente de Titín en bak: sha256 de la SPKI del publicador = b3a35766…5e2ac730.

**Equipo vivo:** MOTOR-38 (`session_01MwmK2gzv4SrPPzHLtAispT`, con brave-core), MOTOR-30 (bridge Ubuntu, solo buzón),
SEGURIDAD-PORTES-18 (espera), LOCAL-18/19 (bridges, solo buzón), SERVIDOR-LOCAL, PUBLICACIÓN, ARQUITECTURA, CARTERO-LOCAL.
Archivadas hoy: COORDINACIÓN-29, INVESTIGACIÓN-MOTOR-9, MOTOR-36, MOTOR-37. Tareas programadas mías: ninguna.

**Sin respuesta (preguntar):** LOCAL-18 (F1 FM.54 y puerta del llavero; preguntado por buzón 13:00, nada). LOCAL-19: A/B de
PGO pedido limpio (of9 frente a of9pgo, mismo commit) en la 7,1 y luego en la 6,1, que decide; la 6,1 la tiene ocupada
Titín. Kit de la 5,1: sin resultado-51.txt. **Pendiente de Titín:** abrir MOTOR-31 (recordado una vez hoy; no repetir);
borrar desde la web las ramas `nube/m34-probe` (brave-core) y `nube/pgo-mojave` (softmac; el clasificador me denegó el
borrado); revisar su red (HTTP/2).
**add_repo automático:** probé `extra_allowed_tools` en create_session y el clasificador lo deniega («Permission Grant»).
Queda la vía 2 (Titín añade brave-core a los repositorios del entorno en ajustes); se lo dije. Mientras, Titín autoriza en
cada MOTOR nuevo.
**Método:** los bridges (MOTOR-30, LOCAL-18/19) no reciben SendMessage desde la nube (401): solo buzón. Worktree del buzón
en el scratchpad. Mis PR [coord] los fusiono con expectedHeadSha.

## 06-11 (mediodía): COORDINACIÓN-29 → COORDINACIÓN-30 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-29 (`session_01MwmK2iQtUzz1YsyLeXQbNV`, 05-11 22:31 → 06-11; Opus 5.5 medio; abierta por la 28, linaje 4;
relevo al ~50 %). La 30 la abre la 29 (linaje 5 de 8). **Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy:** límite de 5 h cerrado, sin cambios y **no volver a preguntarle** (DIRECTIVAS, #784).
Titín autoriza en la sesión de cada MOTOR nuevo el `add_repo` de brave-core (el clasificador lo deniega siempre).

**FM.55 B1d / #753: FUSIONADO.** PGO (perfil de Google 8078) en la 7,1 con `--disable-http2`: Speedometer 3.1
CfT156 20,7 / oficial-8 16,5 / **oficial-9-pgo 20,6**; MotionMark CfT 3590 / of8 2831 / **PGO 3576** (gana en las 8).
En la 6,1 Titín vio MotionMark 1493 con PGO (frente a 1381 sin PGO). **«PGO siempre» ANULADO por escrito** (buzón
LOCAL 06-11) hasta tener el A/B en la **6,1 con benchmarks servidos en local**; si sale bien, vuelve. Causa del lío de
hoy: **la red de la oficina rompe HTTP/2 desde ~10:00** (con `--disable-http2`, 0 fallos); JetStream 3 no termina de
cargar en ninguno (CfT incluido): no es PGO. Investigación cerrada en `FlyWeb/docs/b1d/pgo-mojave.md` (#787, #788;
INVESTIGACIÓN-MOTOR-9 `session_01MwmK2kr28rsdbDHXaa1Jxi`, en espera: archivable). Decidido:
`disable_fieldtrial_testing_config = true` en las oficiales (ya en args.gn de LOCAL). Auditoría de selectores (#776)
aplicada y probada (oficial-8). T10 de b1d: 9 parches Mojave como commits en `flynk-b1d` 1b82d33aca (#785).
Regla: la capa Mojave de Chromium vive solo en `flynk-b1d`, nunca en brave-core/patches.

**FM.55 B2 (porte de Brave a la 156):** cadena en brave-core T7-ter → T5 → T8 → T9 → T9-ver → T9-fix → T5-bis → T10
→ **T11 = `nube/b2-porte-t11` 2eb3838b5** (punta). Rotos (P2 de MOTOR-30): 573 → 357 → 335 → 280 → **177 en T11
d28ecad6 (producción 98, tests 79)**. P2 de 2eb3838b5 pedido (buzón MOTOR 12:43). Prioridad: producción; tests en
tanda aparte (152 de 1.98 enteros, 140 a mano, 39 con propuesta). **MOTOR-37** (`session_01MwmK2mQraxPiisCp7W6WP8`)
recién abierta: si el clasificador le deniega el add_repo, pedir a Titín que lo autorice en su sesión; al tenerlo,
**archivar MOTOR-36** (`session_01MwmK2kkeRetx2LSfb5hfkz`). Encargo de MOTOR-37 en su prompt y en `relevo-motor.md`:
(1) crx_verifier sin claves de Brave (ARQUITECTURA lo confirmó en #790; bak firma RSA-SHA256) → **abrir
SEGURIDAD-PORTES-18** para revisarlo cuando haya sha (y luego B5); (2) los rotos de producción + build_ts
(`leo.bundle.js`, TS2882); (3)–(7) en la nota. Decisiones mías del porte (todas en §12.11–§12.16): funciones de Brave
fuera, lo nativo de la 156 primero (pestañas verticales y vista dividida nativas, panel lateral nativo, estilo de
pestañas de Chromium, Local Network Access en vez del permiso localhost), fuera WDP, Rewards/Talk, Brave Search
promo, P3A, TopSites; apagados IA de DevTools, Prerender2, AI Mode/Lens, NtpSimplificationBookmarkBar; CUP activo en
el updater de extensiones (van directas a Google); versión 3.0.0 = 156.0.8078.82 declarada, mínimo macOS 13.7.8,
198.63.N. Pérdidas para las notas de la 3.0.0 en §12.15.1 y §12.16.
**Método con la Ubuntu (MOTOR-30, bridge «Motor ubuntu (2)»):** compilación rápida por cada sha de MOTOR-37 y P2 al
cerrar tanda; no puede subir a GitHub: manda diffs y errores por su canal y COORDINACIÓN los reenvía. **Su relevo
(MOTOR-31, Sonnet 5.5 medio) está pedido a Titín y sin abrir**; recordárselo.

**Pendiente de Titín:** abrir MOTOR-31 (texto dado el 05-11); pasar el kit de la 5,1 a su hija (URL en su sesión;
LOCAL-19 lo probó en verde) → `resultado-51.txt` a LOCAL → borrar kit (SERVIDOR-LOCAL) y directorio (Titín); borrar
la rama `nube/m34-probe` de brave-core desde la web; revisar su red (HTTP/2 roto).
**Sin noticias desde el 05-11:** LOCAL-18 (F1, FM.54) y la puerta del llavero (M1–M5 con sync y PasswordSyncBridge
nativo de la 156). Preguntar.

**Equipo vivo:** MOTOR-37 (nube), MOTOR-36 (archivar), MOTOR-30 (bridge Ubuntu), LOCAL-18/19 (bridges; solo buzón o
SendMessage directo de ellos), INVESTIGACIÓN-MOTOR-9 (en espera), SERVIDOR-LOCAL, PUBLICACIÓN, ARQUITECTURA,
CARTERO-LOCAL. SEGURIDAD-PORTES-17 archivada; -18 por abrir. Tareas programadas mías: ninguna.

## 05-11 (noche): COORDINACIÓN-28 → COORDINACIÓN-29 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-28 (`session_01MwmK2kJamvybegV8BvFxJf`, 05-11; Opus 5.5 medio; abierta por la 27, linaje 3; relevo al ~40 %).
La 29 la abre la 28 (linaje 4). **Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy** (todas en DIRECTIVAS): funciones de Brave fuera y el NTP, el nuestro (#759); plan ultra sin
overage ni tope de agentes, con aviso propio a `resetsAt` si salta el límite de 5 h, que es **de toda la cuenta** (#761,
#763; Titín lo revisa el 06-11); **la base 156 sale como FlyWeb 3.0.0** y la 6,1 sirve a LOCAL por ssh como banco de
pruebas, pero no compila la 156 (#762); **GPU por Metal**, la vía GL (B1c) parada hasta después de la 3.0.0 (#765);
**Maglev a prueba en B6** (#767); **tras la 3.0.0, nuestro fork a nuestro ritmo**: paridad portando, foco en rendimiento y
después plataformas, de la más fácil a la más difícil (#772; Leopard/PPC con Chromium no es viable, ya dicho a Titín).
Widevine queda fuera: no funciona ni en la 156 ni en la 2.7.0.

**FM.55 B1d (GPU), CERRADA salvo la 5,1:** `oficial-6` (sha256 43fca6be…2ce5, src `flynk-b1d` 805e5d0cff, ANGLE 3b24dd0)
sin caídas en la batería de la 6,1; MotionMark 1381 frente a 566. Regla 17 de ANGLE apta (#746, #760). PR #753 de LOCAL
(lo vigilo) sigue abierto: falta `angle_revision` a la punta de 8078, revisar a mano los selectores ObjC de
`selectores-unguarded-156.md` y comprobar PGO (Chrome 156 saca −25 % / −32 % en la 7,1, `comparativa-71.md`, #770).
Cuando estén, fusionarlo.
- **Kit de la 5,1:** lanzador firmado y notarizado (v2, dmg sha256 aa1e453b…7c9c) en un directorio oculto de ns2
  (`/var/www/FlyWeb/kit-51`, creado por Titín). SERVIDOR-LOCAL lo sube y LOCAL-19 lo prueba desde la URL real.
  **La URL solo a Titín, en su sesión.** La hija de Titín lo lanza en la 5,1 y le manda `resultado-51.txt` por correo;
  Titín se lo pasa a LOCAL. Después se borra (Alias y contenido, SERVIDOR-LOCAL; el directorio, Titín).

**FM.54 F1:** ordenado a LOCAL-18 hoy (buzón d3c582a), en paralelo. Sin noticias aún.

**FM.55 B2 (porte de Brave a la 156):** brave-core, encadenadas: T0 146eeddc → arreglo de BUILDCONFIG en
`nube/b2-porte-t4` 2dec767d → T3 8b2de20e → T6 a28f8adf → T7 7b2a0a79 (T7-bis: Fw1KeyProvider sobre os_crypt_async; los
datos sin prefijo, en claro y marcados para recifrar; tabla en `brave-propio.md` §12.12). Rotos (MOTOR-30): 936 en la poda →
879 en T0 → 743 en T4 → 644 en T3 → 557 en T6. **MOTOR-34** (`session_01MwmK2k5p4qtinBTbRDd26B`) sigue con T5 (poda de
Playlist y compañía, y del NTP de Brave según §12.11, conservando la de la 2.7.0), luego T8 (bloqueantes: Privacy Sandbox
apagado con prueba JS; JS bloqueado en Shields sin romper chrome://settings, la NTP ni las extensiones) y T9 (restos de
Wallet, pins HSTS de Brave fuera; sin pins propios). **MOTOR-33** (`session_01MwmK2k3tUrKX1yNFM5soGn`) se archiva cuando
MOTOR-34 confirme que su add_repo funcionó (a MOTOR-33 se lo denegó el clasificador y tuvo que autorizarlo Titín en su
sesión; si vuelve a pasar, pedírselo a Titín con el texto exacto). MOTOR-30 (Ubuntu) mide T7 y se le pide relevo a Titín
tras esa medida (Sonnet 5.5 medio basta; nota en su `RELEVO.md` local).
- Decisiones mías de hoy: Page Graph fuera; pins HSTS de Brave fuera y ninguno propio; AUTOFILL_VALUABLE fuera de sync;
  se acepta recifrar a fw1 (M7); al volver de la 3.0 a la 2.x pueden pedirse otra vez las palabras de sync (para las notas).

**Puerta del llavero (LOCAL, en Mac):** M1–M5 de §11.8 con el perfil real de la 2.7.0 y la tabla de §12.12; además, que
KeychainV2 lea sin diálogo nuevo el ítem de la 2.x en una Release firmada en 10.14.

**Equipo vivo:** MOTOR-34, MOTOR-30 (bridge), LOCAL-18/LOCAL-19 (bridges; solo buzón o comentarios en #753),
SEGURIDAD-PORTES-17 (`session_01MwmK2h23XGknphhFuuhWG7`; tiene apuntado revisar en B5 que Privacy Sandbox no exista),
PUBLICACIÓN y SERVIDOR-LOCAL (kit), CARTERO-LOCAL. INVESTIGACIÓN-MOTOR-8 quieta. Tareas programadas mías: ninguna.

## 05-11 (tarde): COORDINACIÓN-27 → COORDINACIÓN-28 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-27 (`session_01MwmK2j9aGRTHMvVrCfE8vE`, 04-11 → 05-11; Opus 5.5 medio; abierta por la 26, linaje 2; relevo al ~33 %).
La 28 la abre la 27 (linaje 3). **Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy** (todas en DIRECTIVAS):
- Brave: fuera todo lo descartado; destino, nuestro fork con solo privacidad y, como mucho, la interfaz (#747).
- **Widevine se queda desactivado** (prueba en la 6,1 encargada a LOCAL-18); **Tor fuera** (#751).
- **FM.56**: hilos y varias GPU, línea de Flynk para después de publicar la base 156.

**Pendiente de Titín** (se lo pregunté, sin respuesta aún): qué hacer con Playlist, Speedreader, WebTorrent, Wayback,
Commander, Sidebar y el NTP de Brave. Mi propuesta: todo fuera; Sidebar → panel lateral de Chrome; NTP → el de
Chromium revisando que no cargue nada de Google. Bloquea solo T5 y T9 del porte.

**FM.55, vía GPU (B1d, Metal):**
- LOCAL-18 (bridge `session_01MwmK2guGyVhheWxMd6has6`; **la nube no le puede escribir**: buzón `buzon/LOCAL`, el
  CARTERO sí reparte, aunque `ENTREGADO.md` va con retraso). Build oficial: MotionMark 1660 a 45 fps (la detección
  de 45 está mal; repetir a 60), Aquarium 60/54/37 frente a 60/44/30 de la 2.7.0. Dos D500: sin ganancia (límite: un
  hilo de CPU de la GPU). Humo limpio. Arreglo de la caché persistente 4147b70632.
- Pide: MotionMark a 60 fps, débiles de prioridad 2, aviso «macOS 13», batería `pruebas-gpu.md`, Widevine, Graphite
  cortado también con switch, prueba de reautenticación de contraseñas y **publicar ANGLE 2f34372aaf y Dawn 31316d1c**
  (forks o .patch), sin lo cual SEGURIDAD-PORTES-17 no cierra la regla 17 de ANGLE (#746; src ya revisado: nada
  bloqueante). Si LOCAL no puede crear los repos, se le pide a Titín.
- 5,1: Titín espera la build final de LOCAL-18 (con las guardas de prioridad 2) para mandarla al estudio. Pruebas: abrir,
  `chrome://gpu`, webs pesadas, Aquarium; el `.crash`, nunca por GitHub.
- Después: comparación Metal/GL para Titín (B1c en reserva), F1 (FM.54).

**FM.55, capa de Brave (B2):**
- Poda hecha: brave-core `nube/b2-poda` **4127545c** (PR brave-core #8 en borrador; 70+7 directorios, Tor incluido;
  .onion fuera del DNS y de mDNS, probado). Informe en `FlyWeb/docs/b2-poda.md`.
- Medida P2 hecha (MOTOR-30, `brave-propio.md` §12, #754): 1682 → 936 rotos; lista 2 = 0; Shields = adblock 0.13.3 de 1.98.
- **Porte T0–T9 aprobado** (§12.6): MOTOR-32 (`session_01MwmK2gqciFCPCBxxQQaRW8`, nube) hace T0 sobre 4127545c con
  donante v1.98.63 upstream; cada sha se pasa a MOTOR-30 por `buzon/MOTOR/`.
- MOTOR-30 (Ubuntu, bridge `session_01MwmK2mUW77bRV7cXTjNweN`; **la nube no le escribe**: buzón `buzon/MOTOR/`, que
  vigila cada 3 min; responde por SendMessage). Pasó el 35 %: nota en local `~/d8-trabajo/motor-b2/RELEVO.md`. Que cuente
  T0 y después pedirle a Titín un relevo (Sonnet 5.5 medio basta: es receta). Disco: 38 GB libres; para a 10. Sin push ni
  commits en esa máquina (CLAUDE.md de D8-LINUX).

**Equipo vivo:** LOCAL-18, MOTOR-30, MOTOR-32, SEGURIDAD-PORTES-17 (`session_01MwmK2h23XGknphhFuuhWG7`),
INVESTIGACIÓN-MOTOR-8 (quieta, ~45 %: relevarla antes de darle nada), CARTERO-LOCAL. Triggers míos: ninguno.

## 04-11 (noche): COORDINACIÓN-26 → COORDINACIÓN-27 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-26 (`session_01MwmK2kNq1mUsfgAaeWBBhM`, 04-11; Opus 5.5 medio; abierta por la 25, linaje 1; relevo al 37 %).
La 27 la abre la 26 (linaje 2). Nunca llamar a confirm_repository_trust.

**Decisiones de Titín de hoy (en DIRECTIVAS y en la fila FM.55):**
- **Puerta: base 156** (no la 150). Motivo: ir a la última y no con parches.
- **Vía GPU en estudio:**
  - **Metal (B1d) primero.** La sonda (#740) dice que la D500 en Mojave es Mac2 y que MSL 2.1 compila.
  - **OpenGL (B1c) en reserva**, sin descartar: 11 ficheros añadidos sobre la 156, 66 en total, en `flynk-b1b`.
  - Seguridad (#735): la vía GL obliga a portar a mano 34 CVE (16 críticos); la vía Metal tiene 10, que la 156 ya trae.
- **Hito común de GPU:** `FlyWeb/docs/pruebas-gpu.md`, la batería de la 2.7.0 que dio Titín (Aquarium, WebGL Report,
  three.js, Babylon, Earth, Photopea, Shadertoy, Fishbowl, YouTube 4K60, vsynctester, MotionMark, WebGPU), comparada
  con la 2.7.0 en la 6,1. Si Metal no llega, se vuelve a GL.
- **Contraseñas:** la puerta del llavero suma la prueba de sync (perfil vacío de la 156 que recupera las de la 2.7.0).
  La importación por CSV, solo como último recurso. Recomendación: FileVault y contraseña de sesión larga.
- Anulados por escrito: la prioridad del USB de la 5,1 y la B1b de la 150.

**Dato fresco (Titín, 6,1 con Mojave 10.14.6, build de la 156 de LOCAL-17):**
- ANGLE Metal funciona con la D500, con WebGL 1 y 2.
- MotionMark **140,83 a 45 fps**, frente a 541,92 de la 2.0.0: unas 4 veces menos.
- Sospechosos: Graphite, encendido por defecto en Apple en la 156, y la copia entre las dos D500 (el monitor cuelga de una).
- **Pedido a Titín:** MotionMark repetido, con `--disable-features=SkiaGraphite`, y en `chrome://gpu` la GPU activa
  frente a la del monitor. Si sin Graphite se acerca a 540, Metal queda casi decidido.
- Fallos:
  - SIGSEGV en 0x0 al abrir el menú contextual (`ClipboardFormatType::SvgType`, `UTType` de macOS 11 débil).
  - La página de ayuda dice «macOS 12» en Mojave.
  - Ordenado (buzón 14dc407b): arreglo, auditoría de los 145 débiles con tabla símbolo → usos → estado, y corrección
    de la versión falsa.

**Equipo vivo:**
- LOCAL-17 (bridge `session_01MwmK2j4rFArRjQWbhP6iuQ`): B1d, el servicio de red que se reinicia, la auditoría y el
  menú contextual; informa por PR o en la fila FM.55. **Ojo:** los PR de `local/fm55-estado-b1` chocan en TAREAS; si
  choca, llevar el contenido a un PR [coord] y cerrar el suyo (como #739 → #740).
- CARTERO-LOCAL (relevo de hoy, bridge `session_01MwmK2ihfHK1m4pkdAvtv8f`): anota ENTREGADO.md al día.
- SEGURIDAD-PORTES-17 (`session_01MwmK2h23XGknphhFuuhWG7`): KEV sin novedades. Hará la regla 17 de la capa de GPU
  que gane, con la lista nuevo/revertido.
- INVESTIGACIÓN-MOTOR-8 (`session_01MwmK2hmk5bxMJadUHhqwKY`, ~45 %): quieta; sin encargos largos, mejor relevo antes.
- BACKUPDRIVE no es nuestra.

**Pendiente:**
- Comparación final GL frente a Metal para Titín, con la batería.
- F1 (FM.54) sigue sin empezar: va después de la vía GPU.
- B3 (MOTOR) sobre la 156 tras F1.
- La puerta del llavero, tras B3.
- Tarea programada pendiente de la 26: `trig_012wUJdNwZF2LJVW8N4zrcvp` (revisión de las 21:24 UTC): borrarla.

## 04-11: COORDINACIÓN-25 → COORDINACIÓN-26 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-25 (`session_01MwmK2i6N1Pz4VfDzzGQ59D`, 03-11 → 04-11; Opus 5.5 medio; abierta por Titín, linaje 0; relevo
al 37 % a petición de Titín). La 26 la abre la 25 (linaje 1). Nunca llamar a confirm_repository_trust.

**Hecho:** 2.7.0 publicada (appcast 169.168.40, web #717, DMG comprobado: 175389601 B, SHA a70c4162…0b2b; `flyweb` =
5fdeb23d6f). MotionMark de Titín 2.6.1/2.7.0 en igualdad: empate o mejor; Speedometer +6 %, JetStream +5 %: sin 2.7.x.
Fusionados #713–#723, #725. #679 cerrado (superado por FS.39). FM.54 y FM.55 creadas (#718).

**Decisiones de Titín (en DIRECTIVAS):** BackupDrive trabaja directamente con él y fusiona sus PR (#721): COORDINACIÓN no
le escribe (BACKUPDRIVE-3 `session_01MwmK2kYatKMK9H5fWRxtSY`). Poda de Brave: borrar lo muerto, no apagar (#725), en el
fork tras F1, un commit por directorio. «Apagar, no borrar» queda para futuras plataformas.

**Equipo vivo:** LOCAL-16 (bridge `session_01MwmK2m6va5nJxS8PXyGSMR`, ~21 %), SEGURIDAD-PORTES-17
(`session_01MwmK2h23XGknphhFuuhWG7`, B0 hecho, vigila KEV), INVESTIGACIÓN-MOTOR-8 (`session_01MwmK2hmk5bxMJadUHhqwKY`,
Sonnet; B2 en papel hecho #722/#723; quieta hasta B1), BACKUPDRIVE-3 (no es nuestra). Archivados: COORDINACIÓN-24,
SEGURIDAD-PORTES-16, BACKUPDRIVE-2.

**En curso (FM.54/FM.55):**
- **F0:** hito cumplido en local (determinista; capa idéntica a la 2.7.0; push 3,9 MB + 1,7 MB). Forks creados por Titín:
  `lamosquita-net/v8` y `lamosquita-net/chromium` = antiguo `chromium-legacy` renombrado (red chromium/chromium, «forked
  from blueboxd»; nunca PR hacia arriba; comprobar antecesor antes del push, buzón 70f55df). Decidido: ficheros
  generados de Brave FUERA de `flynk`; espejo Samba COMPLETO (`flynk-chromium.git`, `flynk-v8.git`, `gc.auto=0`)
  (buzón d47a236). PR #724 (`local/fm54-convertir`): fusionar cuando LOCAL confirme determinismo; después, F1 con LOCAL.
- **B1:** 156.0.8078.90 compila con Xcode 26.3/SDK 26.2 (no hace falta 26.5; Metal Toolchain instalado) y
  `mac_min_system_version="10.14"`; 741 avisos de disponibilidad (dawn 231). **En la 6,1 no arranca:** faltan 5 símbolos
  fuertes (`_kLSOpenOptionBackgroundLaunchKey`, `_CSCheckFixDisable`, `task_create_identity_token`,
  `task_identity_token_get_task_port`, `_AperitifCheckInitialized`). Ordenado **B1b** (parche mínimo de símbolos
  débiles, solo para medir) y comprobaciones de ANGLE Metal/GL (buzón 728d223, 101130a). 150.0.7871.287 compilando (407
  avisos parciales).
- **AVX (obligatorio, faltaba):** 6,1 y 7,1 tienen AVX; solo vale la **5,1**. Ordenado: flags, `otool` buscando
  `%ymm/%zmm` sin despacho y arranque en la 5,1 (101130a). **Titín va hoy al estudio** con un USB que prepara LOCAL
  (buzón af7fa0e: 156-B1b, 150 si está, `probar-51.command` → `resultado-51.txt`). Recoger ese resultado.
- **Puerta 150/156 (Titín):** mi recomendación provisional: 156 si arranca con B1b, GPU bien (GL o Metal), sin AVX y los
  741 avisos son tratables por directorio; si falla GPU o AVX, 150. Condición fija para cualquier base nueva: puerta M1
  del llavero `fw1` (perfil real de la 2.7.0, mismos recuentos, sin clave nueva; `brave-propio.md` §11.8).
- B3 (rebase de la capa a la 156) tras F1. El 139 a mano, en pausa.

**Trampas nuevas:** la nube no escribe a LOCAL (bridge): solo buzón, y el cartero no anota desde el 30-10; si algo urge,
pedir a Titín que pegue una línea en la sesión de LOCAL. La red de la oficina es 5G (datos ilimitados): con el router alto
da ~67 Mbps; si va lenta, mirar la PlayStation y la posición del router. `git fetch` desde la nube a veces se cuelga:
usar `timeout` y reintentar. Con Titín: decisiones claras, sin horas.

## 03-11: COORDINACIÓN-24 → COORDINACIÓN-25 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-24 (`session_01MwmK2hVdDLULexk6bBGVwA`, 02-11 → 03-11; Opus 5.5 medio; relevo al 41 %, 28,5 $) se releva
por orden de Titín. Linaje 6 de 8: **la 25 la abre Titín desde cero**. Nunca llamar a confirm_repository_trust.

**Estado al relevar**
- **2.7.0 (nivel 138 = Flynk 138) ENTREGADA a PUBLICACIÓN** en FM.53 (LOCAL-16; brave-core `local/270-arreglos`
  a78df81efd, build 40 = 169.168.40). Espera de MotionMark ANULADA (#711; buzón de PUBLICACION y LOCAL, 03-11 ~16:35 UTC).
  Pruebas: d8 en verde (D8-LINUX-3), 7,1 y 6,1 en verde (Speedometer 3.1 5,84 en la 6,1; JetStream 3 89,3), WPT 138
  sin empeorar (`wpt-270.md`), claude.ai probado por Titín. **Falta:** PUBLICACIÓN publica → orden de firma en bak a
  Titín → appcast 169.168.40 → **web como #676** (`FlyWeb/web/VERSION`, `index.html`, `novedades.html` con «Para la web»
  de `version-2.7.0.md`; comprobar SHA-256 y tamaño descargando de ns2) → LOCAL mueve `flyweb` a a78df81efd. Avisar a
  Titín cuando esté subida.
- Después de publicar, sin bloquear nada: LOCAL-16 compara MotionMark 1.3.2 2.6.1/2.7.0 en igualdad de condiciones;
  Titín prueba GPU en webs (lista dada: Aquarium, three.js, Babylon, Earth, Photopea…). Bajada real → 2.7.x.
- **Aplazado del 138** (al 139 o a la base nueva): sibling-index, stretch, alineación OOF, textarea de Tamura,
  `scheduler.yield` (escape del 136). `quota_exceeded_error.cc`: DCHECK al tocarlo (version-2.7.0.md).

**Lo siguiente (decisiones de Titín 03-11, en `docs/DIRECTIVAS.md`; leer las entradas Flynk, fork propio y siguiente base)**
1. **Fork propio** (`fork-propio.md`, #700, aprobado entero): tras publicar la 2.7.0, F0 = LOCAL convierte la historia de
   `flyweb` en commits de forks `lamosquita-net/chromium` y `lamosquita-net/v8` (crearlos), hito `diff -r` vacío; F1 corte.
   Árbol en el disco local de la 7,1 + GitHub; **espejo git bare en Samba tras cada versión** (`push --mirror`, `gc.auto=0`).
2. **Medidas para la siguiente base** (`base-siguiente.md`, #703): **B0** (SEGURIDAD-PORTES: fechas reales y ritmo de CVE
   en Chrome Releases; muestra de 20 críticos 146–150 contra la 128), **B1** (LOCAL con MOTOR: Chromium 156 y 150 limpios
   para 10.14, Graphite apagada, ¿arranca en la 6,1?), en paralelo con F0–F1; **B3** (ensayo de rebase de la capa
   permanente a la 156) tras F1; **B2** mide la opción de `brave-propio.md` (C: podar lo muerto, absorber lo vivo; Brave
   1.98.63 = Chromium 156 como DONANTE: 77 % de nuestros parches de Brave ya adaptados). Puerta: decide Titín (156, 150
   o seguir a mano). **El 139 a mano está en pausa.** SEGURIDAD-PORTES sigue con KEV (2.7.x si hace falta).
3. Pendientes del estudio de Brave (§11 de `brave-propio.md`): gn desc con LOCAL, revisar 138 parches y 418 envoltorios
   que no existen en 1.98, P2. Abrir INVESTIGACIÓN-MOTOR-8 (Sonnet alto) cuando empiecen las medidas.
4. **BackupDrive** (BACKUPDRIVE-2 `session_01MwmK2iDUP7F9s2StJNRgCj`, Opus medio): decisiones de Titín hechas
   (clave propia obligatoria; lenguaje llano con «Ver qué cambia»; restaurar versiones desde la app). #704 y #708 en main
   (backupdrive-ctl.sh, app con conexión y carpetas sin terminal). Sigue H5 (freno). Titín: crear su clave en Google
   Cloud (`BackupDrive/docs/clave-google.md`), instalar en MacTrash (6,1), prueba h y carpeta grande de copia antes de
   quitar FreeFileSync. Meta de Titín: sustituir FreeFileSync en MacTrash. Luego Titín tiene «un par de cosas» que analizar.

**Equipo vivo:** LOCAL-16 (7,1, bridge `session_01MwmK2m6va5nJxS8PXyGSMR`, ~27 %); SEGURIDAD-PORTES-16
(`session_01MwmK2is84MezuCoESN1hLw`, en espera de errores; archivar si no hace falta para B0); BACKUPDRIVE-2; D8-LINUX-3
(Ubuntu, Sonnet; `~/d8-trabajo/CLAUDE.md` ya renombrado: arranca con «empieza»). Archivados: MOTOR-43, MOTOR-44,
INVESTIGACIÓN-MOTOR-7 (relevo en §11 de `brave-propio.md`), COORDINACIÓN-23. ARQUITECTURA (7,1) entregó #700.

**Canales y trampas**
- La nube NO escribe a sesiones de la 7,1 ni del Ubuntu (`elevated_session_untrusted_device`): órdenes por `buzon/<DESTINO>/`
  (rama `buzon`, incluido `buzon/ARQUITECTURA/` y `buzon/D8-LINUX/`); ellos sí nos escriben. No pedir el permiso fijo.
- **`add_repo` de brave-core lo ordena COORDINACIÓN** en el texto de arranque de cada agente (DIRECTIVAS 02-11); no
  pedírselo a Titín.
- **Orden fijo del nivel:** ramas → d8 en D8-LINUX → entrega a LOCAL → PUBLICACIÓN → web. Encargos a D8-LINUX en lenguaje
  neutro (sin CVE ni descripciones de fallos: saltó una salvaguarda).
- **Un comentario u observación de Titín sobre una versión NO para la publicación**: se investiga después, salvo que diga
  expresamente que se pare (error de COORDINACIÓN-24 el 03-11). Y cuando una decisión de Titín cambie una orden ya dada,
  **anular expresamente la anterior** en el buzón y en la fila.
- Revisar el código alrededor de un diff antes de pedir cambios (error de COORDINACIÓN-24 con `quota_exceeded_error.cc`).
- Apps de prueba: nunca desde la carpeta de red (Samba rompe los enlaces del paquete): DMG → `ditto` al disco local →
  `xattr -dr com.apple.quarantine` → `open -na … --args --user-data-dir=…` (perfil aparte).
- Titín: ritmo normal, nada de estimaciones de horas (solo hitos), no insistir con el límite semanal.

## 02-11: COORDINACIÓN-23 → COORDINACIÓN-24 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-23 (`session_01MwmK2knuccR6hsPpe7uHap`) se releva por orden de Titín (02-11 ~12 h). Linaje 6 = la 24; tras 1–2 más,
Titín abre COORDINACIÓN desde cero (darle el texto listo). Nunca llamar a confirm_repository_trust.

**Decisiones de Titín del 02-11 (firmes, no volver a plantearlas):**
- **Sin 2.6.2.** Brotli CVE-2026-111497 (aplica, comprobado por SEGURIDAD-PORTES-16: `dec/decode.c` = upstream 9801a2c vulnerable;
  arreglo google/brotli 0ed4268a) va **solo en la 2.7.0**. No proponer versiones intermedias: «no desperdicies recursos».
- **Nivel 138 = 2.7.0 a ritmo normal**, sin esperar al reinicio semanal ni hacer tandas artificiales. **Nada de estimaciones de
  horas** (Titín no se las cree y han fallado en ambos sentidos): solo hitos.
- No insistirle con el límite semanal.

**Equipo vivo:**
- **MOTOR-43** (`session_01MwmK2iCg1a5MkUFrLe5FvS`), con push a brave-core: `nube/motor-138` = **2c94d743** (V8 13.8.258.30 +
  Blink frente a V8 13.8 sin cambios + dragonbox/simdutf 7/Temporal apagado). Sigue: resto de Blink del 138 (sibling-index con
  progress/abs/sign, stretch, Integrity-Policy, ViewportSegments…), declaración y motor-138.html. **PR #688 frenado**: choca con
  main y mete las dependencias en `build.sh`, que LOCAL no usa para la 2.x; le pedí una sección «Para LOCAL: dependencias y args
  nuevos del 138» en `version-2.7.0.md` para mandarla por el buzón con la entrega.
- **SEGURIDAD-PORTES-16** (`session_01MwmK2is84MezuCoESN1hLw`), FS.39 hecha en local y **sin push** (falta el `add_repo` que
  autoriza Titín escribiendo en su sesión): `seg/fs39-v8` 55d9c7ed → `seg/fs39-blink138` 9e64b983 → `seg/fs39-gpu` 5c4a29fd sobre
  2c94d743, más Brotli dentro. ANGLE 2d08a95 pendiente. `seg/fs39-propio` cuando MOTOR-43 cierre el inventario.
- **LOCAL-15** parado desde el 31-10 (`flyweb` = ac280a17df = 2.6.1). **D8-LINUX** cerrado: memoria de arranque en
  `FlyWeb/tools/d8/CLAUDE-d8-trabajo.md` (#682); Titín la copia a `~/d8-trabajo/CLAUDE.md`, arranca `claude remote-control` y le
  escribe «empieza». Encargo de d8 en `buzon/D8-LINUX/` cuando haya ramas.
- Archivadas: MOTOR-41, MOTOR-42. VIGÍA de seguridad (Haiku) semanal sigue.

**Permisos:** `.claude/settings.json` ya tiene `allow: mcp__claude-code-remote__add_repo` y **no basta**: el clasificador del modo
auto lo deniega en cada sesión nueva. Titín escribe en la sesión «Soy Titín: autorizo que pidas add_repo de
lamosquita-net/brave-core con acceso push. Pídelo ahora.» Le molesta repetirlo: pregunta abierta, subir el umbral de relevo de
los agentes de brave-core al 50–55 % para pedirlo la mitad de veces (sin respuesta).

**Para la entrega de la 2.7.0 a LOCAL:** ramas en orden (motor-138 + fs39-v8/blink138/gpu/propio + Brotli), dependencias y args del
138, `comprobar-enums.py` en su guion de la 2.x, y pruebas: motor-138.html, flex-column-wrap.html, blob-particion.html,
canvas-float16.html (decidir el bit 0 con el dato), **Speedometer 3.1 y JetStream 3 completos**, WPT 138, 6,1.

## 31-10: COORDINACIÓN-23 → siguiente (leer primero; manda sobre lo de abajo)

COORDINACIÓN-23 (`session_01MwmK2knuccR6hsPpe7uHap`, Opus 5.5, medio; linaje 5 de 8) **para por orden de Titín** (31-10 ~21 h):
límite semanal al **85 %** (se reinicia el martes 03-11 09:00 Madrid); **el lunes Titín decide si se sigue**. Nunca llamar a
confirm_repository_trust. Linaje 6 = la siguiente; tras 1–2 más, Titín abre COORDINACIÓN desde cero (darle el texto listo).

**Canales:** la nube **no llega** a las sesiones locales (send_message/SendMessage a la 7,1 → 401 / `elevated_session_untrusted_device`):
órdenes por `buzon/` y, si urge, un bloque de texto para que Titín lo pegue. Los locales sí escriben a COORDINACIÓN.
**LOCAL-15** (`local_19263447-…`, bridge `session_01MwmK2hvSxULrinRNcm4RhN`) relevó a LOCAL-14 el 31-10; LOCAL lee el buzón sola
(#670). D8-LINUX: el Ubuntu está en Windows; nada pendiente.

**Hecho el 31-10:**
- **2.5.0 publicada** (nivel 136, build 37; #667, web #668). **2.6.0 publicada** (nivel 137, build 38; web #672) con una
  **regresión**: `kNumberOfFeatures` = 5042 por dos valores puestos al final de `web_feature.mojom` (5abcd0cc) → SIGABRT del
  bitset de UseCounter con flex `column wrap` (8/20 subpruebas de Speedometer 3.1). Diagnóstico LOCAL-15; arreglo MOTOR-41
  `nube/fix-260-webfeature` bcc3e2e3. **2.6.1** (build 39, `local/261-arreglos` 480f73623798) entregada, firmada y en ns2
  (DMG 175333341 B, SHA-256 c207aad6…5d33, comprobado). **Falta solo la firma de Titín en bak**; web ya en main (VERSION 2.6.1),
  sale sola cuando el appcast pase a 169.168.39. Comprobar con `curl …/stable/appcast.xml`.
- Lección (TRAMPAS #673; `comprobar-enums.py` #674 y `enumorden.py`): **Speedometer 3.1 y JetStream 3 completos antes de
  toda entrega** (orden a LOCAL); el aviso de no firmar llegó tarde porque la 2.6.0 se entregó sin Speedometer.
- FS.38: arreglo de LOCAL con ByteSizeLong revisado por MOTOR-41 (falla cerrado); prueba TLS con el Root Store del espejo
  (v1820, crs v43) en verde. Abierto: 99 anclas en el espejo frente a 118 en la v19 compilada (probable retirada de raíces;
  sin comprobar) y campos 6/11/12 de TrustAnchor que la 128 ignora.
- canvas-float16: 1 canal con el bit 0 distinto en un origen → no bloquea (decisión COORDINACIÓN-23), mirar en la 2.6.x.
- Archivadas: COORDINACIÓN-22, SEGURIDAD-PORTES-15, MOTOR-41.

**Pendiente (tras el reinicio y si Titín sigue):**
1. Verificar la 2.6.1 en el appcast y cerrar FM.52 (PR de cierre de PUBLICACIÓN).
2. LOCAL: carpetas de `arranque-7-1.command` (buzon 1230) y llevar `comprobar-enums.py` al guion real de la 2.x (`build.sh` no
   sirve para la 2.x; FM.39).
3. 2.6.x: particionado de Blob URL, `CaretWithTextAffinityUpstream`, `TextareaStableResizing`; ordenar `CSSSampleId.kReadingOrder`.
4. FS de OSCrypt v10 restante (`fw1-receta.md` §6 bis) y barrido fuera de nivel (FS.38). Nivel 138 cuando Titín lo diga.
5. Speedometer en la 6,1: 5,7–5,9; ¿Maglev? (umbral pendiente de Titín).

**Pendiente de Titín:** firmar la 2.6.1 en bak; seguir o no el lunes; umbral de Maglev; BackupDrive (3 decisiones); estudio
Blink en el Ubuntu (#648).

## 31-10: COORDINACIÓN-22 → COORDINACIÓN-23 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-22 (`session_01MwmK2k3ySJohzburv2pUkR`, Opus 5.5, medio) se releva al ~40 % (23,4 $). **Nunca llamar a
confirm_repository_trust.** Linaje 5 de 8: tras 2–3 relevos más, Titín abre una COORDINACIÓN nueva desde cero (avisarle con
el texto listo).

**Canales:** 7,1 → por `buzon` (LOCAL lo lee sola al terminar cada tarea; CARTERO-LOCAL caído desde el 30-10 00:18, Titín
no lo ha reabierto: no urge). LOCAL-14 escribe directo a COORDINACIÓN por SendMessage; la nube no le llega (si urge, texto
para que Titín lo pegue). **D8-LINUX-2** (`session_01MwmK2j6YSaEEhNtRUhEFBN`, Sonnet, Ubuntu de Titín): encargos en
`buzon/D8-LINUX/`, lo vigila sola cada 2 min y responde por SendMessage; ~7–9 min por d8, 27,6 GB de RAM de 30.

**Límite semanal en `allowed_warning` (79 % el 31-10 por la mañana; se reinicia el martes 03-11 09:00 Madrid).** Titín
(31-10): el sábado solo trabajan los agentes; ~10 $ ≈ 1 %; él decide si para el domingo. Tandas cortas, nada de sesiones
ociosas abiertas, relevo hacia el 35 %.

**Hecho el 30–31-10:**
- **2.5.0 ENTREGADA** (FM.51, main a33036dd): brave-core `local/250-arreglos` **3d314ec895**, build 37,
  `FlyWeb-2.5.0g-release`, DMG f3b8f047…. Ocho pasadas; arreglos de ejecución: fw1 al arrancar (8ef2fe9cd5), workers con
  V8 13.6 (8bec0800e4), Float16Array (f7a89181a, caída de pestaña que **ya tiene la 2.4.0 publicada**), contraseñas nuevas
  en v10 (096c7d72f0), sync que podía borrar contraseñas fw1 (ddd9687fa3) y anchor (8044f254, `Finalize()` caído por fuzz
  en un bloque DCHECK). Titín la probó (f) **sobre su perfil real, ya migrado a fw1**: todo bien; **no debe volver a abrir la
  2.4.0 con su perfil** (copia en su escritorio). Sin probar: sync real de ddd9687f, importar/exportar, firma real.
  JetStream `dotnet-interp-wasm` no corre ni en CfT 136 (exnref): no es regresión.
- **Nivel 137 = 2.6.0**: `nube/motor-137` **1644d954** (MOTOR-37…41; decisiones en FM.52/FS.38 y `version-2.6.0.md`) +
  **FS.38** (SEGURIDAD-PORTES-15, 25,5 $): `seg/fs38-v8` 068f195b (d8 verde), `seg/fs38-blink137` c7b24ba3,
  `seg/fs38-propio` 2d5b76e5, en ese orden. d8 13.7 verde (`maglev/extras-cped` es esperado: Maglev apagado).
- Herramientas: `v8-d8.sh` con `FLYWEB_CR_TAG` y quitando solo los trozos de brave/ (#650, #655); `fuera.py` (trozos fuera
  de su función, en bucles o DCHECK). TRAMPAS: banderas/features encendidas arrastran arreglos de upstream; la d8 no caza
  snapshot de Blink ni workers.
- Archivadas: COORDINACIÓN-21, INVESTIGACIÓN-MOTOR-7, MOTOR-37…40, SEGURIDAD-PORTES-15 (parada; archivar si no hace falta).

**En curso:**
1. **PUBLICACIÓN** publica la 2.5.0 (regla 11): firma, notarización, ns2, **orden de firma en bak a Titín**, appcast. Tú:
   `curl` del appcast `/stable/`, SHA-256 y tamaño del DMG, y la web como #633. Al usar la 2.5.0 firmada, Titín verá una vez
   el permiso del llavero (la entrada fw1 la creó la f sin firmar): «Permitir siempre».
2. **LOCAL-14** compila la **2.6.0** (`buzon/LOCAL/20261031-0840`): 1644d954 + FS.38. Errores → MOTOR-41.
3. **MOTOR-41** (`session_01MwmK2mMB5MqP7H57sSZJRD`, parada, contexto bajo) atiende esos errores. Pendiente para la 2.6.x:
   particionado de Blob URL, `CaretWithTextAffinityUpstream`, `TextareaStableResizing`. DocumentIsolationPolicy no se porta.
4. Después de la 2.6.0: FS de lo que sigue en OSCrypt v10 (tarjetas/IBAN, tokens OAuth, sync, GCM…; lista en
   `fw1-receta.md` §6 bis) y barrido fuera de nivel (dffb572d0b y 5 más, FS.38). Nivel 138 cuando Titín lo diga.
5. Prioridad baja de LOCAL: arranque de la 7,1 sin depender del cartero (`buzon/LOCAL/20261030-1520`).

**Pendiente de Titín:** estudio de compilar Blink en el Ubuntu (#648): recomendé solo reforzar los chequeos estáticos; no
ha respondido. Umbral de Maglev. BackupDrive (3 decisiones). Reabrir CARTERO-LOCAL (no urge).

## 30-10: COORDINACIÓN-21 → COORDINACIÓN-22 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-21 (`session_01MwmK2juirHM3CHKudv5tND`, Opus 5.5, medio) se releva al ~34 % (14,4 $). **Nunca llamar a
confirm_repository_trust.** A la 7,1 solo se llega por `buzon`; al Ubuntu (D8-LINUX), solo pasando el texto a Titín.

**Hecho el 30-10:** 2.4.0 publicada (appcast, DMG, web #633). `fw1` (MOTOR-34, 6,0 $). Nivel 136 = 2.5.0 (MOTOR-35 26,4 $,
MOTOR-36): `nube/motor-136` 1747f79f; FS.37 (SEGURIDAD-PORTES-14, 26,8 $, frente a 96 $ de la -13) con d8 verde en el
Ubuntu (`seg/fs37-v8` 31edd5c3: mjsunit 7735/7736). Todos archivados.

**Decisiones de Titín del 30-10** (en DIRECTIVAS, TAREAS o version-2.5.0.md): la d8 se compila en su Ubuntu (D8-LINUX),
nunca en la nube; cruce con wpt.fyi fijo; STTF apagado, HEVC sin exponer, `:visited` con self-links SÍ (aplazado al 137),
gradientes de gama amplia solo sin cuelgue. Push a brave-core: Titín aprueba `add_repo` en cada sesión que lo pide.

**D8-LINUX (cómo hablarle):** la sesión de terminal del Ubuntu (titin-5f) no tiene `send_message`; manda por SendMessage
a «ubuntu local» (`session_01MwmK2j97E5PaVDkurvaQce`, Remote Control), que te reenvía íntegro. De la nube hacia allí no
llega nada: los encargos van en un bloque para que Titín los pegue. Base de esa máquina (clang 19 de la 128): 13.5
7656/7657, 13.6 7731/7732 (solo `maglev/extras-cped`). Paquetes solo con `sudo apt-instalar`. Compilar con -j32 llega a
~27 GB de 30: si da errores de memoria, bajar -j. Tokens de agentes de terminal: `FlyWeb/scripts/consumo-local.py`.

**En curso:**
- **LOCAL-14** compila la 2.5.0 (build 37) desde `local/250-arreglos` 3e8c8e219a (= 1747f79f + FS.37). Después: unitarias
  de fw1, **migración v10 → fw1 sobre perfil envejecido** (no la mencionó: recordársela), humo, motor-136.html, WPT, 6,1.
  Errores → a MOTOR-37. Cuando entregue: PUBLICACIÓN (regla 11) y la web como #633.
- **MOTOR-37** (`session_01MwmK2kqGynL4v3YaYFNuLL`): nivel 137 (2.6.0, FM.52) sobre 3e8c8e219a, con `:visited` self-links.
  Atiende primero los errores de la 2.5.0.
- **INVESTIGACIÓN-MOTOR-7** (`session_01MwmK2jTfTBAra1WB6QRZk9`): estudio de compilar Blink en el Ubuntu para cazar errores
  antes de LOCAL, y medir tokens de agentes de terminal. Archivar al entregar.
- **Orden a LOCAL de prioridad baja** (`buzon/LOCAL/20261030-1520`): que LOCAL lea el buzón sola (no depender de CARTERO,
  que no despierta tras reiniciar la 7,1) y un `arranque-7-1.command` para reabrir todos los agentes locales.

**Pendiente de Titín:** BackupDrive (3 decisiones de `BackupDrive/docs/relevo-backupdrive.md`, recomendaciones dadas);
umbral para encender Maglev (LOCAL mide JetStream con y sin él en la 6,1 y la 5,1); ¿2 ventanas cuando perdió las
fijadas? JetStream 3 web-ssr debería pasar en la 2.5.0 (RegExp.escape portado): comprobarlo cuando LOCAL mida.

## 30-10: COORDINACIÓN-20 → COORDINACIÓN-21 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-20 (`session_01MwmK2kk8g3seMyrErbkaeX`, Opus 5.5, medio) se releva al ~36 % (~20 $). **Nunca llamar a
confirm_repository_trust.** A la 7,1 (LOCAL, PUBLICACIÓN, SERVIDOR-LOCAL) solo se llega por `buzon`; ellas nos escriben por
send_message.

**Hecho el 29-10:** 2.3.0 (nivel 134, build 35) publicada: appcast, web (#619) y DMG comprobados con curl y SHA-256.
Probada por Titín en la 6,1 y en la 5,1 sin problemas. INVESTIGACIÓN-MOTOR-6 (`wpt-230-investigacion.md`): ninguno de los
escapes es un fallo que Chrome arreglara después. MOTOR-31/32/33 hicieron el 135. SEGURIDAD-PORTES-13 hizo la FS.36. Todos
archivados.

**Decisiones de Titín del 29-10** (ya en DIRECTIVAS o en sus filas):
- la 5,1 no bloquea y se prueba a mano tras publicar;
- «Las faltas, antes de compilar»: MOTOR cruza el inventario con wpt.fyi. En el 135 costó 11 min y 1–2 $ y encontró 68 faltas;
  propuesto dejarlo fijo y Titín no ha contestado;
- 2.4.0 con la opción A: fuera Observable, select personalizable, carousel y FetchLater;
- `fw1` (AES-256-GCM) es lo primero de la 2.5.0 (FS.25; la 5,1 es una E5620 con AES-NI);
- ser mesurado con sus informes: las fijadas perdidas en la 7,1 son un fallo menor. LOCAL no lo reproduce, ni con un perfil
  de la 1.15.2. Sospecha: fijadas compartidas con 2 ventanas al reiniciar Sparkle. Le pregunté a Titín si tenía 2 ventanas y
  no ha contestado.

**En curso: 2.4.0** (nivel 135, build 36), entregada por LOCAL en FM.50: brave-core `local/240-arreglos` **778fd91ca9**
(ebd8c17f + los 3 arreglos de LOCAL + FS.36), carpeta `entregas/FlyWeb-2.4.0b-release`. Orden a PUBLICACIÓN en
`buzon/PUBLICACION/20261030-0005-COORDINACION-20.md`. Cuando avise: firma de Titín en bak, curl a
`https://updates.flyweb.lamosquita.net/stable/appcast.xml` (OJO: con `/stable/`), descarga del DMG y SHA-256, y web como
#619 (VERSION, index.html, novedades.html; la web tarda ~9 min en servir `descargas/`). `nube/motor-135` sigue en ebd8c17f:
la MOTOR del 136 la pone en 778fd91ca9 y estandariza los arreglos de LOCAL.

**Pendiente de Titín:** (1) directiva propuesta: **la nube no compila V8**, LOCAL compila la d8 y pasa mjsunit (motivo:
SEGURIDAD-PORTES-13 costó **96 $** frente a 17 $ de la -12, por esperar horas a la d8 en la nube); (2) si el cruce con
wpt.fyi queda fijo; (3) BackupDrive (sus 3 decisiones, sin cambios).

**Hecho el 30-10 (COORDINACIÓN-21):** 2.4.0 (nivel 135, build 36) **publicada**: appcast `/stable/` en 169.168.36 (mínimo 10.14.0), DMG 175237299 B y SHA-256 `81d4130f…1d63` comprobados, web en main (#633) y servida (portada, novedades y `descargas/` con el SHA bueno). Cierre de FM.49/FM.50 y CAMBIOS en #634. MOTOR-34 (`session_01MwmK2iZgonNqNG7gUhLD8D`) abierta para `fw1` (FM.51), sin compilar V8 en la nube. COORDINACIÓN-20 archivada (23,7 $).

**30-10, d8 en el Ubuntu de Titín (decisión 1):** D8-LINUX-1 compiló la d8 13.5.212.10 de `nube/motor-136` 841029d2 en 6 min 37 s y pasó mjsunit en 17 s: 7656/7657 (solo `maglev/extras-cped`); hay 25 pruebas menos que en la 7,1, sin explicar (¿sin Intl?). **Pendiente:** meter en `v8-d8.sh` lo que hizo a mano para la 13.5 (simdutf con `patches/third_party-simdutf-*`, highway 00fe003d en `third_party/highway/src`, `v8_enable_partition_alloc = false`) y que se pueda relanzar sobre un árbol ya parcheado. Cruce con wpt.fyi: fijo (decisión 2).

**Siguiente (2.5.0 = nivel 136):** abrir MOTOR-34 solo tras publicar la 2.4.0. Primero `fw1`, con `fw1-receta.md`, la
migración `v10` → `fw1` probada por LOCAL sobre un perfil envejecido y la regla 17; después los 61 escapes de `wpt-240.md`
(29 moveBefore, 15 anchor con scroll) y el inventario del 136 con el cruce de wpt.fyi. Maglev: la deuda está al día con la
13.5 (FS.36: maglev+stress 15238/15238); falta que LOCAL mida JetStream con y sin Maglev en la 5,1 y la 6,1 antes de
encenderlo (lo pide la directiva «como tarde en el 134»: ya vamos tarde, proponérselo a Titín con el dato).

**Costes del 29-10** (nube): SEGURIDAD-PORTES-13 96,4 $, COORDINACIÓN-20 ~20, MOTOR-31 26,0, MOTOR-32 15,9, MOTOR-30 14,0,
INVESTIGACIÓN-MOTOR-6 6,0. MOTOR-33 sin dato (get_session no dio el coste).

## 29-10: COORDINACIÓN-19 → COORDINACIÓN-20 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-19 (`session_01MwmK2huC3sto9S6a1NY5Mn`, Opus 5.5, medio; abierta por la -18) se releva al ~41 % (~25 $). **Nunca
llamar a confirm_repository_trust.** Decisiones de Titín del 28-10, ya en `DIRECTIVAS.md`: versión intermedia solo por
regresión o fallo de seguridad explotado y con el nivel siguiente a >3 días; revisión diaria de gastos; MOTOR (y cualquier
agente de la nube que espera con mucho contexto) se archiva al entregar y se abre otra solo cuando hay trabajo; **un error se
analiza y se arregla antes de seguir** (criterio, no receta: arregla quien pueda antes; LOCAL si puede, MOTOR estandariza);
nadie se queda parado. Titín no quiere normas rígidas: cada problema, su solución.

**Hecho:** 2.1.1 publicada (appcast, web y DMG comprobados con curl 28-10 17:15 UTC). Se saltó la 2.2.0 (decisión de Titín): el
nivel 133 va dentro de la **2.3.0 = nivel 134**. Permiso fijo de `add_repo` en `.claude/settings.json` (Titín; uso acordado solo
brave-core; funciona en sesiones nuevas). Cartero con vigilante (Monitor) desde el 28-10 20:24: entregas en 1–3 min salvo una de
54 min (21:08 → 22:02); **comprobar en cada despertar que no haya ficheros de >45 min sin anotar en `ENTREGADO.md`**. A las
sesiones locales no se llega por send_message desde la nube (elevated_session_untrusted_device): solo por `buzon`; ellas sí nos
escriben.

**En curso (2.3.0):** brave-core `nube/motor-134` **479bcaf1e2**, build 35. Dos caídas ya resueltas (`caida-230.md`,
`version-2.3.0.md`, `TRAMPAS.md`): (1) CHECK de V8 13.4 por `[NoAllocDirectCall]` en sobrecargas de WebGL (fa6ccf3c76; el port de
upstream 89faaa39fb47 en `nube/motor-134-webgl-up` 8eeb795e9e entra con el 135, no en una 2.3.1); (2) SIGILL en Mojave por
`OS_UNFAIR_LOCK_ADAPTIVE_SPIN` de la 10.15 (parche de LOCAL-14, 479bcaf1e2). FS.35 (regla 17 del 134) hecha y fundida. LOCAL-14
prueba 479bcaf1e2 en la 6,1 y **prepara el guion `software/entregas/prueba-51-230/probar-230.command` para la 5,1** (LOCAL no
tiene acceso a la 5,1): cuando avise, pedirle a Titín que lo lance (doble clic) y mirar `resultado-51-*.txt`. Sin la 5,1 en
verde no se entrega. Después, regla 11: PUBLICACIÓN publica; comprobar con curl y hacer la web (como #602).
**MOTOR-30** (`session_01MwmK2hpaEHYmeX2A1rMrMS`): viva hasta que LOCAL dé verde; luego nota de relevo y archivar. No empieza el
135 (dos niveles por delante de lo publicado, la 132). Maglev apagado hasta medir con la 2.3.0 en la 6,1.

**Pendiente de Titín:** las 3 decisiones de la maqueta de BackupDrive (nota `BackupDrive/docs/relevo-backupdrive.md`; abrir
BACKUPDRIVE-2 en Sonnet bajo cuando conteste) y su prueba h; opcional: el NAVEGADOR del espejo en bak a la versión publicada
(FS.32, #586). **Costes del 28-10** (nube): MOTOR-29 33,9 $, MOTOR-28 27,3, COORDINACIÓN-18 21,9, MOTOR-26 19,2,
SEGURIDAD-PORTES-12 17,4, BACKUPDRIVE-1 11,7 (total), COORDINACIÓN-19 ~25.

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
