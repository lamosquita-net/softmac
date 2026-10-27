# Relevo de LOCAL (MacPro7,1)

Nota de relevo del agente LOCAL de FlyWeb (compila, prueba y lleva `flyweb`). La deja cada LOCAL al salir; el siguiente
la lee después de `CLAUDE.md` y de `docs/TAREAS.md` (tabla, reglas y filas FM/FS abiertas).

## LOCAL-10 → LOCAL-11 (26-10-2026)

LOCAL-10 (`local_71a093c7-b93c-41a7-b6ca-888bdc07bd50` «Compilación Local (10)»; Opus 5.5 medio, modo auto, Remote Control, plan Max;
23-10 ~14:20 – 26-10 ~20:00). Nota al ~33 % de contexto (directiva: relevo hacia el 35–40 %). Guiones en `~/proyectos/softmac/temp/local10/`.
**Canales:** COORDINACIÓN-14 («Coordinación (14)», `session_017J2kfSt5BR2UuYSr8fYzvw`) por `SendMessage` con el nombre de `ListAgents`
(una vía). Encargos por **Cartero-Local FlyWeb**; si tarda, `git fetch origin buzon` y leer `buzon/LOCAL/` (el 26-10 llegaron con horas
de retraso). Las sesiones de la nube archivadas (MOTOR-18) salen como «not reachable»: entonces, a COORDINACIÓN.

### Estado al relevar

- **Release de la -p19** 4b4bb3cc68 (2.0.1, build 29) compilando con nohup desde las 19:40, **incremental** sobre `out/Release` de la -p17
  (`release-p19.sh`, PID en `release-p19.pid`). Deja copia sin firmar y DMG de prueba en la carpeta de entregas de red
  (`FlyWeb-2.0.1-p19-release/`). **No es entrega:** la 2.0.1 que se firma es la **-p20** (SEGURIDAD-PORTES-6: -p19 + 45f275a00e CVE-2026-11645
  V8 + 8528639ead CVE-2025-14174 ANGLE Metal), que llega como bundle en `nube/seg6-p20` con orden en el buzón: subirla (comprobar sha y
  padres), compilar en incremental (`release-p19.sh` con `SHA=` y nombres) y probar.
- brave-core: -p16 a66f0e3b1f, -p17 1b0ebd4a00, -p18 16b6e01b57 y -p19 4b4bb3cc68 subidas (desde bundles de MOTOR: el `src/brave` de
  `~/proyectos/brave-128` tiene de `origin` el espejo `~/proyectos/softmac/FlyWeb/brave-core.git`; push al espejo y del espejo a GitHub).
- **2.0.0 = Release -p17** (build 28): entregada en FM.39 (#511) y firmada por PUBLICACIÓN. `out/Release-p15` (la -p15 apartada) se puede borrar.
- Servidor `python3 -m http.server 8125` en `temp/local4/web` (gpu-carga, vídeo 1080p): **comprobar que está vivo** antes de GPU/vídeo en la 6,1.

### PARA LOCAL-11: pendiente (FM.40)

1. **-p20**: subir, Release (build 29), DMG de prueba, y pruebas de la orden `buzon/LOCAL/20261026-1815-MOTOR-19.md` (a–e: aviso falso de
   actualización con `--simulate-outdated`, `flyweb://sync-internals`, NTP sin halo (capturas de los 7 fondos para Titín), pestañas fijadas
   1.15.2 → 2.0 (§3 de `version-2.0.1.md`, vale la -p17), Sparkle con `enable_update_notifications=false`) + las a–g de la -p17 abreviadas
   + la regresión del CVE que indique SEGURIDAD-PORTES-6. Resultados en FM.40.
2. **Después:** línea base de rendimiento en la 7,1 (`…-1834` y `…-1836-COORDINACION-14.md`): solo con el FlyWeb de /Applications, perfil temporal,
   PA271W a 60 Hz, 3 pasadas de Speedometer 3.1, JetStream 3.0 y MotionMark 1.3.2; reproducir web-ssr de JetStream y los «?» de Speedometer.
3. Lo de antes que sigue: MacBook Air con Mojave (acceso, de Titín en la sesión); migración de contraseñas cuando Titín importe su CSV.

### Trampas nuevas (23–26-10)

- **Release oficial de la 128:** Brave 1.69 exige 6 claves más (ya en `build.sh`, #505) y avisa 30 veces de `-Wunguarded-availability-new`
  (APIs de 10.15 en código de Chromium: ASWebAuthenticationSession, AVCapture…): sin `treat_warnings_as_errors:false` no compila. **Falta
  en el `build.sh` del #513** (lo demás coincide con `release-p17.sh`); dicho a COORDINACIÓN-14.
- **`apply_patches` con parches que crean ficheros:** antes de la -p19 (1f77e29f) el reset fallaba entero. Si vuelve a pasar: `git checkout`
  de los ficheros de Chromium de la lista «failures during git reset», borrar el fichero nuevo y sus `.patchinfo`, y repetir.
- **Pruebas por CDP en la NTP y Ajustes:** los paneles de posición fija tienen `offsetParent` nulo (usar `getClientRects()`), React necesita
  clics de ratón reales (`Input.dispatchMouseEvent`), y la primera `.jpg` del DOM es la miniatura oculta de Personalizar (el fondo 1):
  identificar el fondo por captura (`rota61.py`). Un «siempre el fondo 1» del 26-10 fue esto, no una regresión.
- Ajustes de la 128: `cr.sendWithPromise` no existe en las páginas de Ajustes; `chrome.send` sí. Un filtro propio de Shields entra con
  `chrome.send('brave_adblock.updateCustomFilters', [texto])`.
- Una opción repetida en la línea de órdenes (`--user-data-dir`) vale la última: así `en-61-gpu.sh` abre un perfil persistente con `ARGS=`.

### Herramientas (`temp/local10/`)

`release-p17.sh` / `release-p19.sh` (Release completa: checkout, V8, fast_float, apply_patches, build, comprobaciones, copia y DMG ad hoc),
`blink-p17.sh` (blink_unittests en Static con el filtro), `copia61-p17.sh` (DMG a la 6,1 y arranque), `pruebas61-p17.sh` (tanda a–g),
`cdp61.py` (ayudante CDP), `p17-61.py`, `shields61.py`, `ddg61.py`, `wdp61.py`, `visita61.py`, `audit61-udd.sh` (`UDD=`, `VISITA=1`,
`MODO=uso`), `rota61.py` / `rota61.sh` (rotación de fondos), `ntp7-61.py` (Personalizar por clics reales).

## LOCAL-9 → LOCAL-10 (23-10-2026)

LOCAL-9 (`local_ad0f5131-2b0e-4712-8603-7017ddb6f455` «Compilación Local (9)»; Opus 5.5, **medio** (no alto), modo auto;
plan Max; 22-10 ~18:10 – 23-10 ~14:30). Nota al 31 % de contexto, tras entregar la -p15. Guiones en `~/proyectos/softmac/temp/local8/`
(los de compilación y pruebas) y `temp/local9/` (MotionMark, copia de la -p15, insignia).
**Canales:** COORDINACIÓN-13 («Coordinación (13)», `session_01L7rpeb3sVii7F8jgApaAcB`) por `SendMessage` con el nombre de
`ListAgents` (una vía: no contesta aquí). Sus encargos llegan por **Cartero-Local FlyWeb** (buzón).

### Estado al relevar

- **Nada compilando.** `nube/base-128-motor` = `-p15` **dcf6251201** (avance directo desde `-p9`; antes `-p13` 8f3bcc24aa y `-p14`
  806e8caa96 de IDENTIDAD). Checkout `~/proyectos/brave-128`, `src/brave` en la rama local `nube/base-128-motor-p15`, sin cambios locales.
- `-p15` = mosca en la insignia de `flyweb://` (`product_chrome_refresh.icon` ← `product.icon`) y sin `EGL_METAL_DEVICE_ANGLE` con
  ANGLE OpenGL (`patches/gpu-ipc-service-image_transport_surface_overlay_mac.mm.patch`). 6,1: 0 líneas del error (antes ~2 800/min),
  MotionMark 1.3 -p14 562,44 ± 2,38 → -p15 569,81 ± 1,72; GPU acelerada, sin caídas. Detalle en FM.39 y FM.31.
- En la 6,1: `~/flyweb-pruebas/brave128/` = -p14 y `brave128-p15/` = -p15 (las dos aprobadas en LuLu); dos perfiles de desarrollo
  apartados en `LaMosquita/` (`FlyWeb-Development.antes-…` de Titín y `.apartado-…` de LOCAL) y `FlyWeb-Development antes de 2.0
  (2026-10-22)` de la prueba de migración: no borrar sin Titín.

### PARA LOCAL-10: pendiente

1. **Pruebas a mano de Titín** (órdenes enviadas a COORDINACIÓN-12 el 22-10; válidas cambiando la ruta a `brave128-p15`): 6,1 y
   A1398. El zip de la A1398 en `software/entregas/FlyWeb-2.0-p13/` es la -p13: si hace falta, empaquetar la -p15 igual (`ditto -c -k
   --keepParent`) en `FlyWeb-2.0-p15/`.
2. **Sábado 24-10:** MacBook Air con Mojave por red; Titín da el acceso **en la sesión** (nunca al repo). Copiar con `copia61`.
3. **Contraseñas:** la migración de contraseñas no se ha probado (el perfil de Titín tiene 0: usaba «Contraseñas en iCloud», que
   apaga `credentials_enable_service`). Cuando Titín importe su CSV en FlyWeb, repetir `mig61.sh` (solo recuentos).
4. Release oficial y CPU de vídeo: cuando lo ordene COORDINACIÓN (no antes).

### Trampas nuevas (22–23-10)

- **Worktree propio, separado del de SERVIDOR-LOCAL** (COORDINACIÓN-13, 23-10): la carpeta `…/software/softmac` la comparten otras
  sesiones (estaba en `servidor/shields-20`); LOCAL-9 creó su rama desde ahí y arrastró un commit de Shields (PR #498, cerrado). LOCAL
  trabaja en su propio `git worktree add` desde `origin/main` (p. ej. en el scratchpad) y nunca hace `checkout` en la carpeta compartida.
- **LuLu retiene cada binario nuevo**: sin aprobar, las pestañas se quedan en `about:blank` y **la auditoría de red sale limpia en
  falso**. No pedir a Titín que apruebe antes: lanzar y que apruebe cuando salga (memoria). Los guiones esperan a la red.
- La identidad en la 128 rompió la Static tres veces (D-DIN con una línea «Name:», `AIChatUI` fuera del `#if`, `ai_rewriter` en
  `test/BUILD.gn`); ya arreglados en `-p13`. Un `.patch` de Chromium se genera con `git -C src diff --full-index -- <fichero>` y luego
  `git checkout --` del fichero (si no, `apply_patches` choca).
- La barra de direcciones no sale en las capturas CDP: `screencapture -x -R…` en la 6,1 con la página abierta por `/json/new` (el
  argumento URL de `open --args` se ignora).
- claude.ai: «Continuar con Google» abre un hCaptcha con navegador automatizado: claude.ai entero, a mano.
- MotionMark necesita ventana visible (`open -g`, no `-j`) y lanzar el binario directo para tener stderr (`mm61.sh`).

### Herramientas

`temp/local8/`: `b128-pN.sh` (cambiar `SHA=`), `b128-p12-copia61.sh` (a `brave128`), `en-61-gpu.sh`, `id61.py` (identidad por CDP),
`ua61.py`, `pin61.sh` (fijadas con extensión de prueba), `ntp61.py`, `mig61.sh` (migración), `audit61.sh` (`APPP=`, `ETQ=`),
`gpu61-p12.sh` (GPU 10 min), `repro61.py`. `temp/local9/`: `mm61.sh` (`cuenta SEG` / `pasadas N`), `copia61-p15.sh`.

## LOCAL-8 → LOCAL-9 (22-10-2026)

LOCAL-8 (`local_5c6ba9f8-4205-46e5-98a8-b31a3eaa73c0` «Compilación Local (8)»; Opus 5.5, alto, modo auto; facturó por el plan Max;
22-10 ~13:45 – ~17:50). Nota al 49 % de contexto. Guiones y registros en `~/proyectos/softmac/temp/local8/`.
**Canales:** COORDINACIÓN-12 («Coordinación (12)», `session_01NjpdW4mhQMcN2EuNN8MivC`) por `SendMessage` con el nombre de `ListAgents`.
MOTOR-17 e IDENTIDAD-1 (nube) **no salen en `ListAgents`**: a MOTOR-17, por la rama de softmac `local/b128-blinktests-errores`
(sin historia previa; ficheros + `LEEME-*.md`, push directo) y por COORDINACIÓN; a IDENTIDAD-1, por COORDINACIÓN. Sus respuestas
llegan por **Cartero-Local FlyWeb** (buzón).

### PARA LOCAL-9: QUÉ HACER AL EMPEZAR

1. **Compilación en marcha (nohup):** `-p12` **ae5626ab1a** (= motor `-p11` cd9c85656b + identidad `-i5` dff94888fe; orden de
   COORDINACIÓN-12 y MOTOR-17) con `temp/local8/b128-p12.sh` (PID en `b128-p12.pid`; resumen en `b128-p12.nohup`). Encadena:
   navegador Static (`b128-p12-build.log`, 12 796 pasos desde las 17:42) → `blink_unittests` (`b128-p12-tests-build.log`) → la suite
   (`b128-p12-gtest.log` y `.json`). Mira `ps -p $(cat …/b128-p12.pid)` antes de lanzar nada (una compilación a la vez).
   - Args nuevos de identidad: `enable_ai_chat:false`, `enable_brave_vpn:false` (P3A ya iba en false); **sin** `enable_updater`; y
     `flyweb_metal_bin_path:<usr/bin del toolchain de ~/proyectos/sdk/Xcode-15.4.app>/` (la ruta solo en el guion, nunca en el repo).
   - **Diagnóstico LOCAL en `src/brave/test/BUILD.gn`** (no entregable): `gn gen` fallaba en `assert(enable_ai_rewriter)` porque
     `brave/test` añade `//brave/browser/ui/ai_rewriter:browsertest` sin condición. Lo protegí con `if (enable_ai_rewriter)` (diff en
     `temp/local8/diag-ai_rewriter.diff`) y se lo pasé a COORDINACIÓN-12 para IDENTIDAD-1. Cuando llegue el arreglo (`-i6` / `-p13`),
     `git -C src/brave checkout -- test/BUILD.gn` antes de cambiar de commit.
2. **Con el `-p12` compilado** (orden de MOTOR-17, mensaje del buzón 20261022-1526):
   - `blink_unittests`: comparar con `-p10` (26 143 bien, 58 fallos, 40 caídas; lista en `temp/local8/b128-p10-fallos.txt`). Lo nuevo,
     a MOTOR-17 por su rama.
   - ANGLE: en la 7,1, `chrome://gpu` sin flags = `angle=metal` y las 2 WPT pasan (`temp/local8/wpt2-medida.sh`: deja solo los casos
     sin flags; `gpuinfo.py` saca el estado por CDP); en la 6,1 = `angle=opengl`, sin caídas.
   - Identidad: «Qué comprobar en la compilación (LOCAL)» de `FlyWeb/docs/identidad-128.md`, más restaurar sesión con pestañas fijadas
     compartidas en dos ventanas y reabrir una ventana cerrada (sin duplicados ni caídas; ASan si se puede).
   - Repetir Google, WebAuthn y Ajustes en la 6,1 (`repro61.py todo`) y la GPU de 10 min.
3. Resultados en FM.31 (filas de LOCAL-8 como modelo) y a COORDINACIÓN-12; tokens para `CONSUMO.md`.

### Trampas nuevas (22-10)

- **La app del `-p12` se llama `FlyWeb Development.app`** (identidad), no `Brave Browser Development.app`: ruta nueva → **LuLu** la
  retiene en la 7,1 y en la 6,1 (pedir a Titín que la apruebe); actualizar las rutas de los guiones de `temp/local8/` y el patrón de
  informes de `en-61-gpu.sh` (busca `chromium|brave`: añadir `flyweb`). En la 7,1 le aplica la **política antigua sin JIT** del bundle
  de desarrollo (`DefaultJavaScriptJitSetting = 2`): JIT/Wasm, en la 6,1.
- **APIs de 10.15 sin `@available`** = caída en Mojave (Google/WebAuthn por `CBCentralManager.authorization`, Ajustes por `LAContext`).
  Repasados los 46 avisos `-Wunguarded-availability` (patrón de la 116); ya van en `patches/` desde `-p8`. Quedan 9 tras salidas
  tempranas: si sale un aviso **nuevo** en un log, es una caída en potencia.
- **Abrir una descarga no se puede comprobar por CDP** (ni con `Input.dispatchMouseEvent`; tampoco en la 1.15.2): a mano, Titín.
- **CPU de vídeo:** la Static de la 128 tiene `is_official_build=false`; no se compara con la 1.15.2 Release. Decodificador: 1.15.2
  `VDAVideoDecoder`, 2.0 `VideoToolboxVideoDecoder` (hardware las dos).
- **Las 2 WPT de colores/anchor** que difieren de CfT 131 son de ANGLE OpenGL, no del motor (con `--use-angle=metal` pasan).
- **`blink_unittests`**: Brave no los ejecuta (sin filtro); su anti-huella de canvas tumba 39 tests con un `NOTREACHED` (esperado).
- **CDP**: `Runtime.evaluate` con `awaitPromise` se queda colgado si la promesa abre un diálogo (WebAuthn): lanzar sin esperar.
- Lo que se sube a ramas públicas (logs de ninja/gtest): quitar `/Users/titin` y la **`brave_services_key`** (va en la orden de npm).

### Herramientas (`~/proyectos/softmac/temp/local8/`)

`repro61.py <puerto> <modo>` (modos `claude`, `google`, `webauthn`, `ajustes`, `todo`, `extra` —descargas y geolocalización—, `abrir`,
`p9` —togglePopover, `isTypeSupported`, YouTube—, `decoder` —`chrome://media-internals`—) por el túnel de `en-61-gpu.sh`;
`gpu-video61.sh` (GPU 10 min + vídeo frente a la 1.15.2); `wpt2-medida.sh` + `gpuinfo.py` + `wpt-ref-detalle.py`; `tanda-p6-71.sh`
(motor-117…131, WPT, JA4 sin ventana en la 7,1); `brave128-p9.sh` (compilar un `-pN` sin diffs locales; cambiar `SHA=`).

### Pendiente fuera de LOCAL

`launchQueue` (Brave apaga `FileSystemAccessLocal`; lo decide COORDINACIÓN); referencia opcional de `blink_unittests` de Brave 1.69
pura (con el sí de COORDINACIÓN); la 5,1 sigue sin configurar.

## LOCAL-7 → LOCAL-8 (22-10-2026)

LOCAL-7 (`local_f2edb095-eee0-450b-bae3-0c69492607e2` «Compilación Local (7)»; Opus 5.5, esfuerzo alto, modo auto; 21-10 ~18:30 –
22-10 ~00:30). Nota al 49 % de contexto, en punto limpio (sin compilación en marcha). Guiones y registros en `~/proyectos/softmac/temp/local7/`.
**Canales:** COORDINACIÓN-11 («Coordinación (11)», `session_016LAphUszobDrthjRLX51N9`) y MOTOR-16 («Motor (16)»,
`session_01R24qB8o9yirUqVC7H1ZVc6`) por `SendMessage` con el nombre de `ListAgents` (llegan; no contestan directo: su respuesta
viene por **Cartero-Local FlyWeb**, buzón `AAAAMMDD-HHMM-*.md`).

### PARA LOCAL-8: QUÉ HACER AL EMPEZAR

0. **ACTUALIZACIÓN 22-10 08:15 (manda sobre el punto 2):** MOTOR-16 fijó `nube/base-128-motor-p4` **70ebebd097** (= -p3 + v8.gni +
   los 2 de Blink). Compilada (incremental, 2 min, **0 errores**, sin `DIAG`; `brave128-compila.sh` ya tiene ese `SHA`), `minos` 10.14,
   sin AVX obligatorio, y **arranca en la 6,1 en 2 s** (`~/flyweb-pruebas/brave128/`, `temp/local7/b128-copia61.sh`). El User-Agent
   aún dice Chrome/128: la versión declarada (131) va con la capa de FlyWeb, que -p4 no lleva. **Falta toda la tanda de pruebas** de la
   orden de COORDINACIÓN-11 (`blink_unittests`, motor-129…131 y WPT, JA4 y `UseMLKEM`, GPU/caídas/vídeo en la 6,1). Para las pruebas,
   sin Finch de pruebas ni Media Router (`--disable-field-trial-config --disable-features=MediaRouter,DialMediaRouteProvider`).
   **COORDINACIÓN-11 (22-10 06:15):** la versión declarada (Chrome/131) la lleva MOTOR-16 a `-p5` (es motor). La tanda va sobre `-p5`
   cuando MOTOR-16 lo fije; si tarda, empezar por `blink_unittests` y ML-KEM sobre `-p4`, que no dependen de la versión.
   **08:41:** `-p5` 93332ce63a (versión declarada 131) compilado incremental: **1 error de motor**, enviado a MOTOR-16
   (`components/embedder_support/user_agent_utils.cc:455`, el `#define GetUserAgentMetadata …_ChromiumImpl` del `chromium_src` deja sin
   declarar la sobrecarga de dos argumentos). Esperar `-p6`, cambiar `SHA=` en `brave128-compila.sh` y relanzar (~2 min).
   **09:15: `-p6` 02c9d0ca4b COMPILADO (0 errores) y copiado a la 6,1** (`~/flyweb-pruebas/brave128/`): arranca en 2 s; UA
   `Chrome/131.0.0.0`; Client Hints (en `chrome://version`, contexto seguro): marcas Chromium 131 + GREASE «Not_A Brand» 24, sin «Brave»,
   `uaFullVersion`/`fullVersionList` 131.0.6778.265, `platformVersion` 11.7.10. **Empieza por la tanda de pruebas sobre `-p6`.**
   **Antes, LuLu:** el binario nuevo no tiene red en la 6,1 (ni siquiera `http://127.0.0.1:8125` por el túnel): pedir a Titín que lo
   apruebe en LuLu de la 6,1 (ruta `~/flyweb-pruebas/brave128/Brave Browser Development.app`) y comprobar con una pestaña antes de la tanda.
1. **`flyweb` = 1.15.2 publicada** (9401833a66, árbol de `nube/motor-131-anchor-f16` af0328adeb; FM.28). Nada pendiente ahí.
2. **Brave 1.69 / base 128 (FM.31), en `~/proyectos/brave-128/brave-browser`** (aparte de `flyweb-build` y de `chromium-128`):
   - Última compilación: Static sin PCH de `nube/base-128-motor-p3` de4d1b24b1, **diagnóstico** (`DIAG=1`: el hunk de
     `patches/v8/gni-v8.gni.patch` revertido en local; MOTOR-16 ya lo quitó en `nube/base-128-motor-c1` 7aeaf00b0a).
     65 902/66 375 pasos, **solo 2 errores, de motor, ya enviados a MOTOR-16**: `css_selector.cc:1722` (`kPseudoHostHasAppearance`;
     en la 128 es `kPseudoHostHasNonAutoAppearance`) y `style_builder_converter.cc:97` (incluye `style_view_transition_group.h`,
     que la 128 no tiene). Registro: `temp/local7/brave128-compila.log`.
   - **Siguiente:** cuando MOTOR-16 fije `-p4` (sha por el buzón; comprobar con `git ls-remote`), cambiar `SHA=` en
     `temp/local7/brave128-compila.sh` y lanzarlo **sin** `DIAG` (`nohup zsh brave128-compila.sh > brave128-compila.nohup 2>&1 &`):
     es incremental (~65 900 objetos hechos). Luego, la orden de COORDINACIÓN-11: `blink_unittests`, `motor-129…131.html` y WPT (como en
     la 1.15.2), JA4 frente a CfT 131 (0x11ec) y el interruptor `--disable-features=UseMLKEM`; en la 6,1, `chrome://gpu`, caídas y vídeo
     con CPU (`temp/local7/video61.sh`, `en-61-gpu.sh` + `gpu10.py`) frente a la 1.15.2. Resultados en FM.31 y a COORDINACIÓN.
   - Argumentos: SDK 14.5, `mac_deployment_target`/`mac_min_system_version` 10.14, `treat_warnings_as_errors=false`,
     `dcheck_always_on=false`, URL inertes de la 116. **Sin** `enable_ai_chat:false` ni `enable_brave_vpn:false` (Brave 1.69 puro
     hace `assert(enable_ai_chat)` en `brave/test`; va con la Fase 2).
   - Los parches de Mojave van en `temp/local7/parches-128/{src,angle,dawn}.diff` (Fase 0 de LOCAL-6 + Fase 1 de LOCAL-7) y el guion
     los aplica tras `apply_patches`. Si `apply_patches` falla en un fichero que aplica limpio con `git apply --check --cached`, es que
     quedó tocado de una pasada anterior: `git checkout --` ese fichero y repetir.
3. **5,1:** sin configurar (`temp/local5/medir-51.conf` no existe; faltan usuario, puerto y host del estudio, de Titín por mensaje).

### Hallazgos y trampas (21-10)

- **GPU de la 128 en Mojave: hecho en la 6,1** (FM.31). Parches «FlyWeb (LOCAL-7)» en `~/proyectos/chromium-128` y en los diff:
  `ui/gfx/mac/color_space_util.mm` (`kCMFormatDescriptionTransferFunction_sRGB`, 10.15: SEGV al crear IOSurfaces; se repone el
  `@available` de la 116), Dawn `PhysicalDeviceMTL.mm` (2 `supportsFamily:` sin proteger + `GetMTLGPUFamily` con `MTLFeatureSet`) y
  `AlignedAlloc.cpp` (`aligned_alloc` → `posix_memalign`), `components/metal_util/hdr_copier_layer.mm` (sin capa HDR en 10.14).
  Resultado: todo acelerado, 0 caídas en 10 min, WebGL a 60 fps; vídeo 1080p H.264 18 % de un núcleo (1.15.2: 12 %).
- **Patrón (COORDINACIÓN-11):** en cada aviso de los 70, mirar la versión de la 116; si tenía `@available`, recuperarlo.
- **Chromium no oficial aplica `fieldtrial_testing_config.json`** (enciende SkiaGraphite → Dawn → caídas falsas): probar siempre
  con `--disable-field-trial-config`.
- **Cuelgue al arrancar = DIAL + LuLu, no GPU:** `Chrome_IOThread` bloqueado en `__sendto` de `media_router::DialServiceImpl`; en
  Chromium limpio, `--disable-features=MediaRouter,DialMediaRouteProvider`. Para cuelgues: `sample` de TODOS los hilos
  (`temp/local7/c128-cuelgue61.sh`), y la pila de una SEGV se simboliza con `atos -l <carga>` calculando la carga con un marco conocido.
- **Restos en la 6,1:** matar el ssh local no cierra el navegador remoto y el siguiente arranque habla con el viejo por el mismo puerto
  CDP; `en-61-gpu.sh` ya limpia restos de la misma app al empezar.
- **Checkout `brave-128`:** `src` es un clon APFS del `src` de la 128 (copiar el CONTENIDO: brave-browser trae `src/.gitkeep`);
  `src/brave/.env` con `projects_chrome_repository_url` (googlesource, para no volver a bajar Chromium) y
  `projects_depot_tools_revision=31e21628` (el vpython de 2026 no resuelve `src/.vpython3`); `.gclient` con `custom_hooks`
  `vpython3_common`. No usar `npm run sync -- --init` (regenera el `.gclient`). Si `ensure_bootstrap` se queda parado, es
  `gsutil.py version` con una conexión colgada: matar ese python.

## LOCAL-6 → LOCAL-7 (21-10-2026)

LOCAL-6 (`local_20642d1a-f0eb-4bf8-aef4-33710985666c` «Compilación Local (6)»; Opus 5.5, esfuerzo alto, modo auto; 21-10 ~10:00 –).
Nota escrita al 44 % de contexto, en punto limpio, por si hace falta el relevo. Guiones y registros en `~/proyectos/softmac/temp/local6/`.
**Canales:** COORDINACIÓN-10 (`session_01U31mzo4UdTUgf3gkhqxKmb`, «Coordinación (10)») y MOTOR-14 (`session_01PZNSmdebZSnLvAr2v93osp`,
«Motor (14)»), por `SendMessage` con el nombre de `ListAgents`. Lo de la nube llega por **Cartero-Local FlyWeb** (buzón
`AAAAMMDD-HHMM-*.md`); la nube no puede escribir a la 7,1. **Titín (21-10): no preguntarle; dejarlo escrito y moverlo por el cartero
o con el agente que toque.** A veces el buzón trae órdenes ya superadas: comprobar el sha vigente antes de actuar.

### PARA LOCAL-7: QUÉ HACER AL EMPEZAR

0. **ESTADO A LAS 18:05 (lo más reciente; manda sobre los puntos de abajo):**
   - **1.15.2 ENTREGADA a PUBLICACIÓN en FM.28** (commit de188d9): brave-core `nube/motor-131-anchor-f16` **af0328adeb** (F15 + includes), build **27**, `entregas/FlyWeb-1.15.2/FlyWeb.app`; LuLu aprobado por Titín (7,1 `entregas/FlyWeb-1.15.2`, 6,1 `flyweb-pruebas/1152-release`). PUBLICACIÓN avisada. **Pendiente de LOCAL:** cuando PUBLICACIÓN la dé por firmada y verificada en FM.28, `flyweb` = commit con el árbol de af0328adeb y padres af0328adeb + 54b964da54 (receta de LOCAL-3/4: `commit-tree`, `update-ref` con el hash antiguo exacto, `push origin flyweb`, `read-tree -m -u` en el checkout de Drive; una orden `git -C` por llamada).
   - **128:** 7.ª pasada relanzada a las 16:27 (`temp/local6/chromium128-compila7d.sh`; partes 7, 7b y 7c sumadas). Al acabar, `c128-arranque61.sh` (punto 1). Prioridad (COORDINACIÓN-10, 11:35): **FlyWeb primero**; hasta 4 rondas de arranque y luego Fase 1.
   - El punto 2 (F14/F15) ya está resuelto: lo anterior es historial.

1. **Chromium 128 (FM.31, Fase 0), 7.ª pasada COMPILANDO** desde el 21-10 14:13 con `nohup`: `temp/local6/chromium128-compila7.sh`
   (PID en `chromium128-compila.pid`, salida en `chromium128-compila.nohup`, registro en `chromium128-compila.log`; las partes anteriores en
   `local5/chromium128-compila.log` y `local6/chromium128-compila-{2..6}.log`, que el guion suma para los avisos). 48745 pasos (~2 h).
   `args.gn`: lo de LOCAL-5 + `mac_min_system_version = "10.14"` + `dcheck_always_on = false` (como la oficial). **Cambios en el checkout
   `~/proyectos/chromium-128`** (todos comentados «FlyWeb (LOCAL-6)»; `git diff` en `src`, `src/third_party/angle` y `src/third_party/dawn`):
   - ANGLE `src/libANGLE/renderer/metal/BUILD.gn`: `metal`/`metallib` de los shaders internos del **Xcode 15.4**
     (`~/proyectos/sdk/Xcode-15.4.app`, decisión de Titín: ni el 14.3.1 ni la Metal Toolchain de Xcode 26). El resto, con el Xcode 26
     activo (`CR_XCODE_VERSION` va en todas las órdenes: cambiar el Xcode entero = compilar desde cero).
   - 3 SPI en `weak_import` + comprobación de nulo: `base/mac/launch_services_spi.h` y `launch_application.mm`
     (`_kLSOpenOptionBackgroundLaunchKey`), `sandbox/mac/system_services.cc` (`_CSCheckFixDisable`), blink `font_matcher_mac.mm`
     (`CTFontCopyVariationAxesInternal`).
   - `ui/display/mac/screen_mac.mm` (NSScreen EDR y `localizedName`) y Dawn `PhysicalDeviceMTL.mm` (`hasUnifiedMemory`) con `@available`.
   Al acabar: `zsh temp/local6/c128-arranque61.sh` (copia a `~/flyweb-pruebas/chromium128/` de la 6,1 y arranca, **una sesión SSH**; da la
   versión por CDP o la excepción y la pila). Si arranca: `temp/local6/c128-61.sh` por `local5/en-61.sh` (chrome://gpu, example.com, claude.ai).
   **Límite acordado con COORDINACIÓN: si sale otra caída de arranque, una 4.ª ronda y se para** (lo demás, Fase 1). Todo, a la fila FM.31.
2. **Actualización 15:50:** la **F15 079c587c2e** (MOTOR-14) sale limpia en Static (WPT 330/74/1, las 9 de la F14 arregladas; caídas, crashtests y tanda bien), pero **su Release no compila** (includes; `temp/local6/r1152-errores.txt`). Pedida la F16 = F15 + includes. Con ella: Release directa (`temp/local6/release-1152.sh` como modelo: para la 128, build 27, comprueba y copia), tanda corta y caídas con la Release, y entrega en FM.28. La 128 (7.ª pasada) se relanzó a las 15:43 (`chromium128-compila7c.sh`, partes 7 y 7b ya sumadas).
   Lo anterior: **FM.28 (1.15.2): la F14 8cb201690a NO VALE** (9 regresiones de capa superior en WPT: `::backdrop` y popovers; fila FM.28). Se espera la
   **F15 de MOTOR-14**. Con ella: `temp/local6/anchor-f14.sh` como modelo (cambiar sha y nombres; `update-ref` de
   `local/motor-131-anchor` en el bare con el hash antiguo exacto), `copia-f14-61.sh`, y `f14-todo61.sh` (caídas, crashtests, WPT de la lista,
   tanda corta). Referencia de CfT 131: `w28-cft131-*` (no hace falta repetirla). Las 9 a vigilar: `fm28dif-http.txt` actual
   (`wpt-fm28dif.sh fw61 <salida>`). Árbol WPT del 131 con anchor, abspos y popovers descargados hoy (permiso de Titín); lo del 130 en
   `temp/wpt131-fm28-antes/`. **Una compilación a la vez:** COORDINACIÓN dijo «no pares la 128 por la 1.15.2 salvo que Titín lo pida».
3. **Release de la 1.15.2**, solo desde la F15 (o la que MOTOR-14 dé por final): `FLYWEB_BUILD_NUMBER` = 27 (la 1.15.1 es 26),
   `check-no-avx.sh`, `SUPublicEDKey`, `ditto` a `entregas/FlyWeb-1.15.2/`, pruebas de red sin ventana (LuLu de la 7,1 tiene que aprobar
   la ruta nueva) y **entrega en la fila FM.28** (regla 11: es la orden de publicar).
4. **`flyweb` = 1.15.1, 54b964da54** (sin cambios hoy).

### Hallazgos y trampas (21-10)

- **Una Static limpia no garantiza la Release:** la Static usa cabeceras precompiladas (`build/config/pch.gni`: `enable_precompiled_headers = !is_official_build…`; blink core, `precompile_core.h`), que tapan includes que faltan. La Release de la F15 (1.15.2) dio 25 errores de includes del porte (absl::optional, cppgc::Visitor, AnchorQuery) que la Static no vio. Para un porte grande, comprobar también sin PCH o con la Release.
- **La 1.15 y la 1.15.1 publicadas se caen** con `FlyWeb/tools/caidas-fm28.html` (CHECK `has_oof_insets_for_get_computed_style`) y con los
  crashtests `css-conditional/container-queries/crashtests/top-layer-*crash.html` (SEGV null): la 1.15.2 los arregla.
- Para ver si una caída es caída: la Static sin ventana en la 7,1 con `--enable-logging=stderr` (`Received signal`/`Check failed`);
  `titulo.py` (título a los 6 s) para páginas de caída. En una página de prueba, `const top` global choca con `window.top`.
- Un absoluto con `left`/`right` los dos `auto` no es límite de relayout en la 116 (`ObjectIsRelayoutBoundary`).
- **`dyld` solo dice el primer símbolo que falta:** para la lista entera, `nm -m -u` sin `weak external` + `comprueba-simbolos.py` con el
  Python 2.7 de Mojave en la 6,1 (`dyld_stub_binder` sale como falso positivo).
- gitiles da 503 si se pide seguido: una descarga, pausa, y un único reintento.
- Los buzones de la mañana repetían órdenes ya ejecutadas o superadas (F11→F12→F13→F14 en una hora): mirar siempre el último sha.

## LOCAL-5 → LOCAL-6 (21-10-2026)

LOCAL-5 (`local_eb0590c2-6997-4848-bcc7-eb49e4cf6553` «Compilación LOCAL (5)»; desde la nube, `SendMessage` al nombre o
`session_01DCZDzGMM8VdHsV5B5JBXmv`; Opus 5.5, esfuerzo alto; 16-10 ~17:25 – 21-10 ~10:00). Relevo por decisión de Titín
(por COORDINACIÓN-9), con la compilación de la 128 en marcha. Guiones y registros en `~/proyectos/softmac/temp/local5/`.

> **Corrección de LOCAL-6 (21-10, ~10:05):** al entrar, la 128 **no compilaba**: LOCAL-5 la paró a las 09:58 en
> 22412/61389 (punto 2, «FlyWeb primero») y lanzó con `nohup` la **F9 de FM.28, brave-core 6fef4b8068**
> (`nube/motor-131-anchor-f9`, arreglo del `ComputedStyle` nulo de `RecalcOwnStyle`): navegador Static, luego
> `blink_unittests` y el filtro de anchor + `LayoutBoxTest.*` (`temp/local5/anchor-f9.sh`, registros en
> `temp/anchor-f9-*.log`, cerrojo puesto). La 128 se relanza en incremental al acabar la F9.

### PARA LOCAL-6: QUÉ HACER AL EMPEZAR

1. **Chromium 128 (FM.31, Fase 0) COMPILANDO** desde el 21-10 09:36 con `nohup`: `temp/local5/chromium128-compila.sh`
   (PID en `chromium128-compila.pid`, guion en zsh; salida en `chromium128-compila.nohup`, registro de ninja en
   `chromium128-compila.log`). Checkout aparte `~/proyectos/chromium-128` (src = etiqueta 128.0.6613.138, 88 GB, depot_tools
   propio en `~/proyectos/chromium-128/depot_tools`, **nunca** `gclient sync -D` ni tocar `flyweb-build`), salida `out/Mojave`
   (61389 pasos; ~22000 a las 09:56). `args.gn`: `mac_deployment_target = "10.14"`, `mac_sdk_path` =
   **`~/proyectos/sdk/MacOSX14.5.sdk`** (del `Xcode_15.4.xip` de Titín; la 128 oficial usa el 14.0: diferencia anotada),
   `treat_warnings_as_errors = false`, `symbol_level = 0`, `is_official_build = false`, **`use_siso = false`** (la depot_tools
   nueva usa siso por defecto y no acepta `-k 0`), `-k 0`. `-Wunguarded-availability` ya lo pone Chromium en Mac
   (`build/config/compiler/BUILD.gn`). Al acabar, el guion cuenta errores, avisos y avisos de disponibilidad distintos
   (`temp/local5/chromium128-avisos.txt`) y los agrupa por directorio. **Cerrojo** `~/proyectos/flyweb-build/temp/LOCK`
   mientras compila (lo quita al salir). Después: arranque en la 6,1 y la 5,1 (`chrome://gpu`, una web normal, claude.ai),
   comparar con los 44 ficheros de la clase I de `migracion-128.md` y resultado a FM.31.
   - En la descarga: 429 de googlesource con el `-j` por defecto (relanzado con `-j 2`); el hook `vpython3_common` quitado con
     `custom_hooks` en `.gclient` (aioquic 0.9.20+chromium.1 ya no está en el registro); LuLu de la 7,1 tuvo que aprobar el Python
     de `~/Library/Caches/vpython-root.501` (Titín, 21-10).
2. **Regla: FlyWeb primero.** Si MOTOR-13 manda el sha del arreglo de FM.28, **para la 128** (mata el guion y su `autoninja`/ninja;
   ninja retoma donde lo dejó, acordado con Titín), compila FlyWeb y luego relanza la 128 con el mismo guion (incremental).
3. **FM.28 (1.15.2, anchor positioning) a la espera de MOTOR-13.** Último sha probado: `nube/motor-131-anchor-f8` **510aab322e**
   (= F7 7f864fb08c + `dom_wrapper_world_test.cc`). El navegador de la F7 y `blink_unittests` de la F8 compilan y enlazan
   (0 errores). **Caída grave** (pasada como URGENTE): `Element::RecalcOwnStyle` usa `new_style` después de
   `scoped_refptr<const ComputedStyle> layout_style(std::move(new_style))` (en `new_style->HasAnchorFunctionsWithoutEvaluator()`);
   en upstream `ComputedStyle` no va por refcount. Tumba el renderer en cualquier recálculo de estilo de un elemento con caja:
   en la 6,1 `motor-120` (y las pestañas del mismo sitio quedan sin respuesta), en `blink_unittests` 19 caídas del filtro y 9 de
   control (`LayoutBoxTest.*`), todas SEGV 0x38 (lldb: `RecalcOwnStyle` +6221). **1 fallo real:**
   `CSSPropertyParserTest.AnchorPositioningDisabled` (espera que `anchor()`/`anchor-size()` no se analicen con el flag apagado).
   Con el sha nuevo: navegador + `blink_unittests` (`temp/local5/anchor-f7.sh` / `anchor-f8-tests.sh` como modelo), el
   `--gtest_filter='*Anchor*:*PositionTry*:*PositionArea*:*TryTactic*:*TryValueFlips*:*FlipRevert*:*AbsoluteUtils*'` (ojo:
   `*Anchor*` también recoge `ScrollAnchor` y `TextFragmentAnchor`), la tanda en la 6,1 y las pruebas a mano de
   `version-1.15.2.md` (`temp/local5/fm28-mano.py` + `local4/web/fm28-mano.html`: shader `for(;;)`, `window.open`/`_blank`,
   carrusel `overflow:hidden`, página larga; F7 frente a la 1.15.1 de `~/flyweb-pruebas/1151-release/`). `<webview>` de
   extensiones no está automatizado. Release y publicación de la 1.15.2, cuando Titín lo diga.
4. **`flyweb` = 1.15.1, 54b964da54** (20-10; árbol de fa4fae392f47, padres fa4fae392f47 y 0d2daa26da), Drive sincronizado.
5. **5,1 del estudio (pendiente de Titín):** clave `~/.ssh/flyweb_51`, guía en `software/entregas/acceso-51/`; mediciones de
   rendimiento preparadas (`temp/local5/medir-51.sh`, `bench.py`: Speedometer 3, JetStream 2, MotionMark 1.3, arranque y memoria;
   `net.lamosquita.local5.medir51.plist` a las 03:30). **Titín autorizó (20-10) instalar ese launchd en la 7,1 solo cuando la 5,1
   esté configurada**; los datos (usuario, puerto, host) por mensaje, nunca al repo. Después, FM.30 (WPT de botones).

### Lecciones (16–21-10)

- **Un solo `build.sh` a la vez y cerrojo** `~/proyectos/flyweb-build/temp/LOCK` (el 16-10 LOCAL-4 y LOCAL-5 compilaron a la vez en
  `out/Release`: `.rsp` perdidos y Release desde cero). `gn clean` necesita `--root=<src>`.
- **`blink_unittests` solo por `build.sh` con `--target blink_unittests`** (en `FLYWEB_EXTRA_ARGS`): ninja a mano rompe los scripts
  de Python parcheados por Brave (`No module named 'mojo'` / `'import_inline'`).
- **LuLu** retiene cada binario nuevo, aunque vaya a la misma ruta de la 6,1; antes de una tanda larga, una pestaña de prueba
  (`temp/local5/diag-fm22-61.sh`) y, si no llega el GET al 8125, pedir la aprobación a Titín con notificación. También retiene el
  Python de vpython y la Release en una ruta nueva de `entregas/`.
- **`en-61.sh` cierra el navegador a los 30 min**: para tandas largas, `temp/local5/en-61.sh` con `MAXSEG=` (y `cerrar.py` de
  `local4`). Los servidores 8125/8127 no sobreviven a un reinicio: comprobarlos antes (`fm22-pruebas61.sh` ya lo hace).
- **Un renderer que se cae deja la pestaña en `/json/list` con su título pero sin responder a CDP**: buscar `Received signal`
  repitiendo sin ventana en la 7,1 con `--enable-logging=stderr`, y la pila con `lldb` sobre un test que caiga.
- **Avisar a Titín antes de cada tanda que abre ventanas en la 6,1** y decirle si hay que pulsar algo (21-10: vio un aviso de permiso
  de una WPT y no sabía si era para él).
- Los mensajes de COORDINACIÓN no llegaron tras el reinicio de la app del 20-10 19:19 (los de MOTOR sí): si alguien dice que no
  contestas, `ReadNotifications` y avisar a COORDINACIÓN con la sesión buena.

## LOCAL-4 → LOCAL-5 (16-10-2026)

LOCAL-4 (`local_4a2ca263-48ec-4ff1-9ebf-1d1da23e9eee`; desde la nube `send_message` a `session_014pVFQScvJwumdaBwufvESX`;
Opus 5.5, esfuerzo alto, 15-10 ~15:25 – 16-10). Relevo pedido por COORDINACIÓN-7 antes de la Release de la 1.15.

### Estado al relevar

- **1.14 entregada** a PUBLICACIÓN en FM.20 (16-10): brave-core `nube/arreglos-1.14` **d12847a77fde**, build **23**
  (157.64.23), app `~/proyectos/softmac/entregas/FlyWeb-1.14/FlyWeb.app`. Cuando PUBLICACIÓN la firme y verifique: llevar
  `flyweb` a la 1.14 con la receta de LOCAL-3 (`commit-tree "d12847a77fde^{tree}" -p d12847a77fde -p <flyweb actual>`,
  `update-ref`, `push origin flyweb`, `read-tree -m -u` en el checkout de Drive). `flyweb` sigue en **37197fe0** (1.13).
- **1.14.1 (Titín, 16-10: «si ya está hecha, no pares nada»)**: brave-core `local/1.14.1` **13138902af9e** (1.14 +
  `seg/oopsif` 57c1b3fa2a, `flyweb_version` 1.14.1), build **24** (157.64.24), Release en
  `~/proyectos/softmac/entregas/FlyWeb-1.14.1/FlyWeb.app` (check-no-avx OK, `SUPublicEDKey` correcta). Pruebas de FS.15
  hechas (6,1 y ASan, en la fila de LOCAL). **Lo primero de la cola, si no está hecho:** las pruebas de Titín con sus cuentas
  en la 6,1 con la 1.14.1 (Gmail con sesión, extensión de la Chrome Web Store, conversación en claude.ai; el Static
  13138902af9e ya está en `~/flyweb-pruebas/114-303e498f/`), las de red de la Release en la 7,1 sin ventana (LuLu tiene que
  aprobar `entregas/FlyWeb-1.14.1`) y la **entrega en la fila de la 1.14.1** (regla 11).
- **1.15 = brave-core `nube/motor-131` 55b9b4d9d2** (nivel 131 + `seg/oopsif`), **`FLYWEB_BUILD_NUMBER=25`**.
  Static compilando al relevar (rama `local/motor-131` en los dos repos; `temp/m131-static.log`). Si salen errores,
  a MOTOR-11 (`session_01E9YyQZz5fNhwE1HdRNzw6f`, «Nube Motor (11)»): lo más arriesgado son 66a8436ed4 (colores
  relativos), 57dda2531f (`::details-content`) y 1419974606 (`svg_resource`).
- Pruebas de la 1.15 (orden de COORDINACIÓN-7): FM.21 (`motor-131.html`, `motor-130.html`, WPT de `wpt-131-lista.txt` frente
  a CfT 131 con `css/css-color/` entero, JA4 de ML-KEM) y la conversación de Titín en claude.ai (las de OOPSIF ya no se
  repiten). Pruebas con cuentas de Titín: perfil temporal en la 6,1 sin depuración remota, vigilar el registro y borrar el
  perfil al cerrar. Luego ASan corto, Release y entrega en FM.21. Falta descargar CfT 131 (permiso de Titín).
- **Remote Control apagado** desde el reinicio de la app del 16-10 por la mañana; aun así los `send_message` de la nube llegan.

### Estado de la 1.15 (16-10, ~14:30)

- 1.14.1 **entregada** en FS.15 (build 24) y ya publicada (Titín la tiene instalada).
- **1.15 = brave-core `nube/motor-131` 6f7d6a7fa4** (bcc6c90f30 + el `#include` de `css_string_value.h` que puso LOCAL-4;
  MOTOR-11 lo fundió por fast-forward), build **25**. Static sin errores; en la 6,1: `motor-131` 21/21, `motor-117…130` sin
  pasos atrás, `fastapi-129`, `seg-1.14.1`, `js-seg` bien; huella con **X25519MLKEM768** y JA4 igual a CfT 131 sin config;
  superficie: solo `globalPrivacyControl` y `GPUAdapter.requestAdapterInfo` (resto, pasado a MOTOR-11). **ASan compilando.**
- Faltan: WPT de `wpt-131-lista.txt` frente a **CfT 131.0.6778.264** (`temp/cft131`, ya bajado) — bajar las pruebas de gitiles
  necesita el sí de Titín —; la sesión de Titín en la 6,1 (sin `--no-first-run`, para ver la bienvenida: P3A sin barra, sin
  interruptor ni casilla, casilla de diagnóstico desmarcada; net-log sin `p3a*.brave.com`, `star-randsrv.bsg.brave.com`,
  `cr.brave.com`, `clients2.google.com/cr`, `clientservices.googleapis.com`; Ghostery o KeePassXC-Browser desde la Web Store;
  conversación en claude.ai); reproducir el cierre de **`SharedPinnedTabService`** (pila de la 1.14.1 de Titín:
  `OnBrowserSetLastActive` → `OnActiveTabChanged`, puntero nulo) con el ASan: perfil con «Continuar donde lo dejaste», 2
  ventanas, 2–4 fijadas, Cmd+Q, reabrir, pulsar una fijada fantasma desde la otra ventana (variante: segunda ventana desde el
  Dock); pila a MOTOR-11 y COORDINACIÓN-7. Después, Release (build 25) y entrega en FM.21.

### Actualización (16-10, ~15:30)

- **Cabeza de la 1.15: `nube/motor-131` 6a3ea2695a** (e51076b417 —`GPUAdapter.info`, `requestAdapterInfo` fuera— + los arreglos
  de las pestañas fijadas compartidas de Brave posterior). Static compilando con `nohup` (`temp/m131d-static.log`, PID en
  `.pid`). El ASan, una sola vez con esta cabeza. Pruebas de FM.25 con ventanas (fijar/desfijar, ventanas nuevas, arrastrar una
  pestaña fuera y meterla, cerrar con la página viva, reabrir desde el Dock, la reproducción del cierre de Titín y la URL real de
  la fijada de relleno en la ventana inactiva): en la sesión de Titín en la 6,1.
- **WPT del 131:** `temp/wpt131` (copia del árbol del 130 + `css/css-color/` entero descargado como `.tar.gz` de gitiles + las
  42 de la lista con `local4/descarga-wpt131.py`), servido en **8120**; lista completa `local4/lista-131.txt` (294).
  Referencia de CfT 131 corriendo (`local4/w131-cft131.*`).

### PARA LOCAL-5: QUÉ HACER AL EMPEZAR (16-10, ~17:30, relevo pedido por COORDINACIÓN-7)

1. **`flyweb` = 780e380f55** (1.14, build 23; árbol de d12847a77fde, padres d12847a77fde y 37197fe0), en GitHub y con el checkout
   de Drive sincronizado. **La 1.14.1 (`local/1.14.1` 13138902af9e, build 24) está publicada** (Titín la tiene instalada), pero en
   FS.15 aún no consta «firmada y verificada»: cuando PUBLICACIÓN lo escriba, `flyweb` = commit con el árbol de 13138902af9e y
   padres 13138902af9e + 780e380f55 (misma receta; **una orden `git -C` por llamada** y el hash antiguo exacto en `update-ref`).
2. **HECHO (18:15): ASan de c1b778809c limpio** (0 informes, 0 FATAL); **la Release (build 25) ya compila con `nohup`** (`temp/v115-release.log`, PID en `v115-release.pid`): sigue en el paso 3. Lo que había antes en este punto: **ASan de la 1.15 compilando con `nohup`:** cabeza `nube/motor-131` **c1b778809c** (rama `local/motor-131`), registro
   `~/proyectos/softmac/temp/m131-asan3.log`, PID en `m131-asan3.pid`, salida en `out/StaticAsan`. Al acabar (`grep -c ' error:'`
   = 0): ASan corto **sin ventana en la 7,1** con `ASAN_OPTIONS=log_path=…:detect_leaks=0`: `local4/fs15-61.py` (con `EXTPATH`),
   `local4/corta61.py` (motor-130, `togglePopover`, `openDatabase`, js-seg, claude.ai, YouTube) y `local4/diag-cierre.sh` (fijadas
   compartidas); contar «ERROR: AddressSanitizer», FATAL, «Check failed» y señales.
3. **Release de la 1.15:** `nohup env FLYWEB_BRANCH=local/motor-131 FLYWEB_BUILD_NUMBER=25 …/build.sh Release` (el Release
   anterior en `out/Release` es la 1.14.1); `check-no-avx.sh out/Release` con el `ninja` de `third_party` en el PATH;
   `SUPublicEDKey` = `FlyWeb/servidor/actualizaciones/clave-publica.txt`; `ditto` a `~/proyectos/softmac/entregas/FlyWeb-1.15/`
   con `flyweb-build-info.txt`. Pruebas de red de la Release **sin ventana en la 7,1** (`huella-tls-sinventana.sh`,
   `perfil-ascenso-sinventana.sh` desde la 1.14.1, `fs15-61.py`): **LuLu de la 7,1 tiene que aprobar `entregas/FlyWeb-1.15`**
   (pedírselo a Titín con notificación). Falta la conversación de Titín en claude.ai con la 1.15.
4. **Entrega en FM.21** (regla 11) y aviso a PUBLICACIÓN y a COORDINACIÓN-7.
5. DNS (16-10, 17:25, a petición de COORDINACIÓN-7): `components`, `sync`, `proxy` y `updates.flyweb.lamosquita.net` resuelven a
   51.91.19.170 en el resolvedor de la Mac (1.1.1.1) y en 1.1.1.1; los ERR_NAME_NOT_RESOLVED del net-log de FlyWeb no vienen del
   DNS del sistema (¿resolvedor interno o DoH del navegador?).

### Actualización (16-10, ~17:15)

- **Cabeza de la 1.15: `nube/motor-131` c1b778809c** (0fbbf9e775 —pasos A y B de las WPT del 131— + la versión declarada en las
  peticiones de extensiones a la tienda). Static probado en la 6,1: `motor-131` 21/21, sin pasos atrás; WPT del 131 con 4
  diferencias frente a CfT (`lab-004`, `lch-004` por 1/255; `oklab-005` al revés; `scrollIntoView-smooth`, de CfT); superficie:
  solo `globalPrivacyControl`; extensiones de la tienda instaladas por Titín; Cmd+Q limpio. **ASan compilando con nohup**
  (`temp/m131-asan3.log`, PID en `.pid`). Siguen: ASan corto (control, claude.ai, YouTube, fijadas con `local4/ext-fijar`), Release
  build 25 y entrega en FM.21. Guiones nuevos: `local4/diag-cierre.sh`, `diag-crx.sh`, `descarga-cdp.py`, `cmdq61.sh` (Cmd+Q real
  en la 6,1), `sesion-titin-ext.sh`, `tanda131.py`, `gpu61.py`, `huella61.py`.
- En la 7,1 (y quizá en la 6,1), `components.flyweb.lamosquita.net` no se resuelve: pasado a SERVIDOR-LOCAL, sin sondear.

### Lecciones de Titín (16-10)

- **Palabras precisas con Titín:** lo que viene de la red se **descarga** (nunca «bajar», que confunde con bajar de versión).

- **Nunca `npm run update_patches` para un solo parche:** regenera todos y, si el checkout no está completo, borra o cambia
  decenas (pasó: 81 parches tocados al cortarse la sesión). Un solo parche se regenera con `git diff` del fichero de Chromium.
- **Toda tarea larga, en segundo plano con `nohup` y registro**, para que sobreviva a un reinicio de la sesión (la app se
  reinició dos veces el 16-10 y cortó lo que corría como tarea de la sesión).

### Receta nueva (órdenes de Titín del 15-10)

- **Las pruebas de FlyWeb van a la 6,1** (Mojave), con perfil temporal propio y nunca el de Titín (allí tiene su FlyWeb
  abierta). **En la 7,1 solo se compila** y CfT va siempre con `--headless=new`. FlyWeb en la 7,1, solo si hace falta y sin
  ventana. Ventana en la 7,1 solo si Titín lleva ≥ 10 min sin tocar teclado ni ratón
  (`ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1e9); exit}'`); si vuelve (< 60 s), terminar sin ventana.
- `temp/local4/en-61.sh <app desde ~> <puerto> <orden local…>`: **una sola sesión SSH** con túnel `-L` de CDP, `-R 8125`
  (páginas de `temp/local4/web`) y `RPORTS="-R 8127:… -R 8119:…"` para más; `ARGS=` para el navegador; arranca con
  `open -g -j -na` y perfil `/tmp/fw61.*`, cierra por CDP (`cerrar.py`) y borra el perfil. App en la 6,1:
  `~/flyweb-pruebas/114-303e498f/FlyWeb Development.app` (nombre conservado **porque LuLu aprueba por ruta**; `COMMIT.txt`
  dice cuál es). Copiar con `tar -cf - … | ssh … tar -x` a esa misma ruta para no pedir otra aprobación.
- **No editar un guion mientras se ejecuta** (zsh lo lee sobre la marcha: se rompió una tanda así).
- Servidores locales: 8125 `temp/local4/web` (control OOPSIF, `superficie.html`, `toggle.html`, `dom-padre.html`), 8127
  instantánea de `FlyWeb/tools` de `main` en `temp/local4/tools-main` (rehacer con `git archive origin/main FlyWeb/tools`
  cuando cambien las pruebas), 8119 WPT del 130 (`temp/wpt130`, 37 pruebas bajadas de gitiles con
  `temp/local4/descarga-wpt130.py`, permiso de Titín), 8117/8118/8443 de LOCAL-3. PIDs en `*.pid` junto a sus logs.

### Herramientas nuevas (`~/proyectos/softmac/temp/local4/`)

- `tanda61.py` (motor-117…130, fastapi-129, sandbox-popups, seg-1.14.1, js-seg, superficie), `corta61.py` (motor-130,
  `togglePopover`, `openDatabase`, js-seg, claude.ai, YouTube), `fs15-61.py` (OOPSIF: control, control2, extensión
  *sandboxed* de `ext-sandbox/`, claude.ai, YouTube, Gmail; `EXTPATH=` para la ruta de la extensión). Abren **una pestaña
  nueva por página** (`/json/new`): navegar la misma pestaña por el túnel dejaba `Runtime.evaluate` sin respuesta.
- `wpt-base.sh` (`WPT_BASE=`, `EXTRA=--headless=new`, `LISTA=`, `ESPERADO=`), `superficie.sh`, `apagados.sh`, `evalua.py`,
  `fuentes.py/.sh`, `oopsif.sh`, `huella-tls-sinventana.sh`, `perfil-ascenso-sinventana.sh`, `dialogo.py`.
- `herramientas/js-seg.js` ya mide **JIT y WebAssembly en una web http** (`js-seg.sh` navega a `JSSEG_URL`; `JSSEG_ARGS`).
- **Chrome for Testing 130.0.6723.116** en `temp/cft130/` (permiso de Titín, MD5 igual al de Google). Falta CfT 131.

### Trampas nuevas

- **La 7,1 tiene la política antigua para la app de desarrollo** (`/Library/Managed Preferences/titin/
  net.lamosquita.flyweb.development.plist`: `DefaultJavaScriptJitSetting = 2`): las webs van sin JIT en el Static, y desde
  V8 13.0 **una web sin JIT no tiene WebAssembly**. Probar JIT/Wasm en la 6,1 o con la Release (otro bundle id). Así salió
  una falsa alarma el 15-10.
- **CfT trae la configuración de pruebas de campo de serie**: comparar siempre también con `--disable-field-trial-config`
  (eventos de mutación, `getInnerHTML`, ALPS 17613 y el GREASE de HTTP/2 vienen de ahí).
- **LuLu** retiene cada ejecutable nuevo en una ruta nueva también en la 7,1 (Release en `entregas/FlyWeb-1.N`): las webs
  salen en blanco, sin error. Pedirlo con notificación.
- Un renderer muerto deja la pestaña sin responder a CDP (ni `Page.enable`): buscar `FATAL` en el stderr antes de muestrear.
  Así salió el CHECK de `togglePopover` (60cbc4afdd5, arreglado en 685f820c68).
- Una política de la 7,1 no se ve con `ps`; la herencia de `databases_enabled` de `web_view_impl.cc` encendía WebSQL por
  encima del json5 (arreglado en d12847a77f en `BraveContentBrowserClient::OverrideWebkitPrefs`).
- `gh pr create` lo bloquea el clasificador de esta sesión: subir la rama y que el PR lo abra Titín
  (`local/superficie-129` sigue sin PR).

## Relevos anteriores

LOCAL-3 → LOCAL-4 y anteriores: [`relevo-local-historial.md`](relevo-local-historial.md).
