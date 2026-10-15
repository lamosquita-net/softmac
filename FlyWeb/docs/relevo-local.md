# Relevo de LOCAL (MacPro7,1)

Nota de relevo del agente LOCAL de FlyWeb (compila, prueba y lleva `flyweb`). La deja cada LOCAL al salir; el siguiente
la lee después de `CLAUDE.md` y de `docs/TAREAS.md` (tabla, reglas y filas FM/FS abiertas).

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
