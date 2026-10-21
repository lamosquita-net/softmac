# Relevo de LOCAL (MacPro7,1)

Nota de relevo del agente LOCAL de FlyWeb (compila, prueba y lleva `flyweb`). La deja cada LOCAL al salir; el siguiente
la lee después de `CLAUDE.md` y de `docs/TAREAS.md` (tabla, reglas y filas FM/FS abiertas).

## LOCAL-6 → LOCAL-7 (21-10-2026)

LOCAL-6 (`local_20642d1a-f0eb-4bf8-aef4-33710985666c` «Compilación Local (6)»; Opus 5.5, esfuerzo alto, modo auto; 21-10 ~10:00 –).
Nota escrita al 44 % de contexto, en punto limpio, por si hace falta el relevo. Guiones y registros en `~/proyectos/softmac/temp/local6/`.
**Canales:** COORDINACIÓN-10 (`session_01U31mzo4UdTUgf3gkhqxKmb`, «Coordinación (10)») y MOTOR-14 (`session_01PZNSmdebZSnLvAr2v93osp`,
«Motor (14)»), por `SendMessage` con el nombre de `ListAgents`. Lo de la nube llega por **Cartero-Local FlyWeb** (buzón
`AAAAMMDD-HHMM-*.md`); la nube no puede escribir a la 7,1. **Titín (21-10): no preguntarle; dejarlo escrito y moverlo por el cartero
o con el agente que toque.** A veces el buzón trae órdenes ya superadas: comprobar el sha vigente antes de actuar.

### PARA LOCAL-7: QUÉ HACER AL EMPEZAR

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
