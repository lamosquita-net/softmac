# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN. Puesta al día el **20-10-2026, ~22:45 (Madrid)** por COORDINACIÓN-8
(`session_0133Pd3pUk1DtKWpYpE53qB4`, «Coordinación (8)», 20-10, Opus 5.5 alto; relevada al 66 % de contexto),
que relevó a COORDINACIÓN-7 (archivada).
Leer antes: `CLAUDE.md` (**primera regla fija: datos personales del HUMANO nunca en GitHub**; al HUMANO se le llama
**Titín**), `docs/TAREAS.md` (tabla de agentes, **reglas 1–20**, filas FM.28, FM.29, FM.31 y FS.20–FS.22),
`FlyWeb/docs/migracion-128.md` (plan de la base 128, recalibrado) y los estudios de hoy (abajo).

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
