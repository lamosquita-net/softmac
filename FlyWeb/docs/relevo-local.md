# Relevo de LOCAL (MacPro7,1)

Nota de relevo del agente LOCAL de FlyWeb (compila, prueba y lleva `flyweb`). La deja cada LOCAL al salir; el siguiente
la lee después de `CLAUDE.md` y de `docs/TAREAS.md` (tabla, reglas y filas FM/FS abiertas).

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

## LOCAL-3 → LOCAL-4 (15-10-2026)

LOCAL-3 (`local_e47dd0d4-b894-4c29-8c8a-d4bb9002f78a`, Opus 5.5, esfuerzo alto, 13-10 ~23:45 – 15-10) deja todo en punto
limpio: nada compilando, todas las versiones entregadas publicadas y `flyweb` al día.

### Versiones y `flyweb`

| Versión | Build | brave-core | `flyweb` |
|---|---|---|---|
| 1.11.1 / 1.11.2 | 17 / 18 | `local/huella-127` 44c1d6e4 / `seg/v8-12.8` 5aa57049f | 0b36d9b9 / 2cff04bd |
| 1.12 | 19 | `nube/motor-128` 710e7520 | 357a19d9 |
| 1.12.1 (RubyLB) | 20 | `nube/motor-128-ruby` e6273d015 | c78dae5c |
| 1.12.2 (resto de FS.12) | 21 | `nube/motor-128-ruby` bb6c7146 | fd4d33b7 |
| **1.13 (nivel 129)** | **22** | **`nube/motor-129` 325686916c** | **37197fe0** |

`flyweb` = **37197fe0** (árbol de 325686916c, padres 325686916c y fd4d33b7), en GitHub; checkout de Drive
(`softmac/FlyWeb/brave-core`) sincronizado. Receta para cada versión firmada: `git -C <bare> commit-tree "<cabeza>^{tree}"
-p <cabeza> -p <flyweb actual>`, `update-ref`, `push origin flyweb` y `git -C <checkout de Drive> read-tree -m -u
"<flyweb anterior>^{tree}" flyweb`. **Una orden `git -C` por llamada**: las órdenes compuestas que mueven `flyweb` o
suben el tablero las bloquea el clasificador («Modify Shared Resources»).

### Checkout y `out/`

- `~/proyectos/flyweb-build/brave-browser/src/brave` en 325686916c; V8 12.9.202.28 (f372edd3).
- Rama de compilación `local/motor-129` (en el bare `~/proyectos/softmac/FlyWeb/brave-core.git` y en `brave-browser`, que
  apunta a a17a0c0a): 325686916c. `build.sh` exige una rama del mismo nombre en los dos.
- `out/Static`: 43ef04cf64 (nivel 129 sin Menlo). `out/StaticAsan`: 43ef04cf64. `out/Release`: 325686916c (1.13, build 22).
- `build.sh` sale del worktree `~/proyectos/softmac/temp/wt-sm71` (a3abcd5): `FLYWEB_EXTRA_ARGS`, `FLYWEB_OUT`,
  `FLYWEB_SYMBOL_LEVEL`. Recetas:
  - Static: `nohup env FLYWEB_BRANCH=local/<rama> "FLYWEB_EXTRA_ARGS=--ninja k:0" …/build.sh Static > log &`
    (`--ninja k:0` lo pasa Brave a ninja como `-k 0`: saca todos los errores de una vez sin ninja a pelo).
  - ASan: `"FLYWEB_EXTRA_ARGS=--is_asan -C StaticAsan --ninja k:0" FLYWEB_OUT=StaticAsan`.
  - Release: `FLYWEB_BUILD_NUMBER=<n> … build.sh Release`; luego `check-no-avx.sh` con
    `PATH=…/src/third_party/ninja:$PATH`, `SUPublicEDKey` = `FlyWeb/servidor/actualizaciones/clave-publica.txt` y copia
    con `ditto` a `~/proyectos/softmac/entregas/FlyWeb-<v>/` (con `flyweb-build-info.txt`).
- Parar una compilación: `kill -INT` al proceso `third_party/ninja/ninja` (TERM no basta); lo compilado se reaprovecha.
- **Cada compilación o prueba larga, con espera por PID en segundo plano que despierte la sesión** (regla de
  COORDINACIÓN-5): el Static de RubyLB de LOCAL-2 falló a las 20:39 del 13-10 y nadie lo supo en 3 h.

### Herramientas (`~/proyectos/softmac/temp/local3/`; el scratchpad de la sesión se borra al reiniciar)

- `wpt-ruby.sh <exe> <base> <puerto>` (`LISTA=`, `ESPERADO=`): WPT por el servidor 8117 con `FlyWeb/tools/wpt-ref.py`.
- `wpt-129.sh <exe> <base> <puerto>`: las 27 de `wpt-129-lista.txt`, 24 por HTTP 8118 y 3 por HTTPS 8443.
- `asan-129full.sh <app ASan> <dir>`, `asan-129.sh`: pruebas con ASan (`ASAN_OPTIONS=log_path=…:detect_leaks=0`).
- `webs-jit-log.sh <app>` (`ERR=<fichero>`): webs con JIT contando «Check failed», señales y «unrecognized flag».
- `captura2.py` / `captura3.py`: reftests sin emulación (cada página en su pestaña nueva, load + fuentes + 2 rAF; lanzar
  con `--window-size=800,600 --force-device-scale-factor=1`); `captura3` da coordenadas, colores y cajas de ruby.
- `sonda-cuelgue.sh`, `regexp-turbofan.html` (regress-355683663 con JIT), `release-113.sh` (tanda de la Release).
- **No usar `difpix.py`**: lee el rectángulo de la pestaña de la referencia.
- **`FlyWeb/tools/wpt-ref.py` de `main`** ya captura sin `Emulation.setDeviceMetricsOverride` y repite (`--pasadas`,
  INESTABLE); lanzar el navegador con `--window-size=800,600 --force-device-scale-factor=1`. El antiguo, con emulación,
  daba 200 px falsos en las `no-layout-containment-*`.
- Servidores WPT: 8117 = `temp/wpt128/…/external/wpt` (Chrome 128); 8118 = `temp/wpt129/…/external/wpt`
  (129.0.6668.112, envuelto con `FlyWeb/tools/wpt-envolver.py` para los `.window.js`/`.any.js`); 8443 = HTTPS propio
  (`local3/https-server.py`, certificado de 127.0.0.1 en `local3/cert/`). PIDs en `temp/wpt128-http.pid` y
  `local3/*.pid`. Para HTTPS: navegador con `--ignore-certificate-errors` solo en el perfil temporal y `wpt-ref.py` con
  `SSL_CERT_FILE=local3/cert/cert.pem` (si no, «NO CARGA»). Tras reiniciar la Mac se paran: relanzarlos.
- `temp/wpt129/…/css/css-conditional/container-queries/flyweb-control-abspos-sin-container.html`: control propio
  (no está en el repo). `temp/wpt128/…/flyweb-fs11/`: `ruby-fs11` servido. Fuente Ahem en `~/Library/Fonts`. **No borrar
  ni `flyweb-fs11` ni Ahem** (COORDINACIÓN-5).
- **Chrome for Testing 129.0.6668.100** en `temp/cft129/chrome-mac-x64/` (descargado con permiso del HUMANO el 14-10,
  SHA-256 `522ab874…dc37`; sin firma de código, como todo CfT). Sirve para comparar con Chrome N de verdad, no con el
  Chrome 155 instalado.
- Perfiles: siempre temporales (`mktemp -d`), y `--use-mock-keychain --no-first-run`. Para el JIT, `Preferences` con
  `javascript_jit:1` (la app de desarrollo tiene la política antigua). La prueba de conversación en claude.ai la hace el
  HUMANO en un perfil temporal que abre LOCAL sin depuración remota; LOCAL vigila el stderr y borra el perfil al cerrar.

### LuLu

Cada binario nuevo en una ruta nueva se queda sin red hasta que el HUMANO lo aprueba en LuLu (pedírselo en la sesión
y con una notificación). localhost sí funciona, también el WebRTC entre dos `RTCPeerConnection`… salvo cuando no hay red:
`motor-129` cae a 14/15 sin la aprobación. Si una Release incremental no cambia el ejecutable ni los Helper (comparar
SHA-256), la aprobación sigue valiendo.

### Trampas vistas

- **macOS 15.8.1** (14-10, 11:26, con reinicio): cambió el dibujado del texto. `block-ruby-003` y
  `ruby-inlinize-recursive-simple` fallan igual en la 1.12.2 publicada; comparar las WPT siempre también con la versión
  publicada en el mismo macOS.
- **Red lenta**: las webs pueden tardar hasta 50 s; antes de dar un fallo, repetir con la versión publicada en el mismo
  momento y medir con `curl`.
- **Máquina saturada** (ASan compilando): falsos cuelgues en YouTube y WPT. Probar sin carga o comparar con la publicada.
- **Un cuelgue «en reposo» con CDP sin respuesta** puede ser un renderer muerto: buscar `# Fatal error` en el stderr
  (`--enable-logging=stderr`) antes de muestrear. Así salió el `UNREACHABLE` de `ToConstant()` (claude.ai, 129).
- **Mensajes entre sesiones**: a la nube, `SendMessage` con el nombre de `ListAgents` («Nube Coordinación (5)», «Nube
  Motor (8)», «Publicación»); `send_message` por `session_…` da «not found». Las sesiones de la nube no confirman lectura.
- zsh: `$VAR:t…` se lee como modificador; escribir `"${VAR}:…"`. `echo ====` falla (`=` expande órdenes).

### Pendiente (no es de LOCAL hasta que llegue la entrega)

- **`block-ruby-003`** (19 px en el texto de la anotación, x 12–16, y 229–233): falla en la 1.12.2 y en la 1.13 desde
  macOS 15.8.1; con Menlo sigue igual aunque `monospace` ya mide como Chrome 129. Va a **MOTOR-8** (después de la 1.13).
- **Nivel 130, V8 13.0**: lo prepara **MOTOR-9**; LOCAL-4 compila cuando entregue.
- Fuente monoespaciada interna (JetBrains Mono, decisión del HUMANO) y el matiz de MOTOR-8 (Menlo para las webs): lo
  cierra COORDINACIÓN-5 con el HUMANO.
