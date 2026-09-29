# Tablero de tareas y reparto entre agentes

Hay dos agentes de Claude trabajando en paralelo, más el humano (titín), que decide y prueba en los Mac.
Este fichero es **la única fuente de verdad** sobre quién hace qué. Hay que leerlo al empezar cada sesión.

| Agente | Dónde corre | Puede | No puede |
|---|---|---|---|
| **NUBE** | Contenedor Linux (claude.ai/code) | Investigar, escribir código, parches, scripts y documentación, compilar Go (BackupDrive) y probar en Linux, CI, PRs | Compilar Chromium, ejecutar nada de macOS, ver los discos del Mac |
| **LOCAL** | MacPro7,1 (Claude Code local) | Compilar FlyWeb, ejecutar y medir, Xcode, firma y notarización, scripts que necesitan el checkout de Chromium | Trabajar sin el Mac encendido |
| **HUMANO** | — | Decisiones, credenciales (Google, Apple), pruebas en la 6,1 y la 5,1, iconos | — |

## Reglas para no pisarse

1. **Reclamar antes de empezar:** poner tu nombre en la columna "Quién" y el estado `en curso`, hacer commit y
   push, y solo entonces empezar. No tocar tareas `en curso` de otro agente.
2. **Ramas separadas:**
   - `softmac`: NUBE trabaja en `claude/*` y abre PRs. LOCAL trabaja en `local/*` y abre PRs. Nadie hace push directo a `main`.
   - `brave-core` / `brave-browser`: **solo LOCAL escribe en `flyweb`**, porque es quien compila y prueba. NUBE
     propone cambios en ramas `nube/<tema>` del fork. LOCAL los compila y, si funcionan, los fusiona en `flyweb`.
3. **Ficheros compartidos** (`CLAUDE.md`, este tablero): cambios pequeños y frecuentes. Antes de editar, `git pull`.
   Cada agente edita solo sus filas.
   - **Tablero, sin PR:** cada agente puede hacer push directo de **sus propias filas** de este fichero (reclamar,
     cambiar el estado, notas) a la rama donde viva el tablero. Esto es una excepción a la regla 2.
   - Todo lo demás va por PR, incluidos `CLAUDE.md`, el código y las filas de otro agente.
   - Si el push lo rechaza porque hay cambios nuevos: `git pull --rebase` y volver a subir. No forzar nunca el push.
4. **Entregas entre agentes:** en "Notas", qué se deja hecho y qué necesita el otro (por ejemplo "rama
   `nube/jitless` lista para compilar").
5. **Nunca en el repo:** tokens, `backupdrive.conf`, contraseñas ni certificados.
6. Cuando una tarea termina: estado `hecho`, más el enlace al PR o commit.

**Prohibido en `~/proyectos/flyweb-build`: `gclient sync -D`.** Borró el `src/brave` antiguo (worktree). Ahora `src/brave` es un clon `--shared` (ver `setup-build.sh`).

Estados: `pendiente` · `en curso` · `bloqueada` · `hecho`.

## Tablero

### FlyWeb — Fase 0 (compilación)
| # | Tarea | Quién | Estado | Notas |
|---|---|---|---|---|
| F0.1 | Terminar `gclient sync` (plan B con `-j 4`) y `npm run sync` | HUMANO/LOCAL | hecho | 29/09 15:55, `npm run sync` completo (parches y hooks). Chromium 116.0.5845.188, `src/brave` = clon `--shared` en 77b25c6b. Incidentes resueltos: `-D` borró el worktree (rehecho como clon); `NODE_ENV=production` (1c6e54a); **`depot_tools` más reciente rompe los hooks de 116** (su `vpython` ya no encuentra `numpy==1.21.1+supported.1`) → fijado `src/brave/vendor/depot_tools` a **fc75af35** (el del DEPS de Chromium 116) y `DEPOT_TOOLS_UPDATE=0`. **NUBE: llevado a `setup-build.sh` y `build.sh`** (clon previo fijado + `DEPOT_TOOLS_UPDATE=0`; `build.sh` lo vuelve a fijar si se movió). **Y no hacer push forzado de la rama compartida:** se perdió el commit de LOCAL 32ee4cf (regla 3). NUBE: asumido; su contenido lo sustituye este mismo texto, y NUBE ya no reinicia ramas con `-f` |
| F0.2 | Primera compilación con `build.sh`; validar `mac_sdk_path` con Xcode 26 activo — **seguir `FlyWeb/docs/integracion.md`** | LOCAL | en curso | 29/09 18:05, **paso 0 compilado** (flyweb 77b25c6b, Static, 60236/60236 en 2 h 03 min): `FlyWeb Development.app`, `net.lamosquita.flyweb.development`, x86_64, `LC_VERSION_MIN_MACOSX` 10.13 y **sdk 13.3** → `mac_sdk_path` con Xcode 26 validado. `check-no-avx`: OK (78/39509 comandos con AVX, todos SIMD con selección en tiempo de ejecución; Rust 0). Provisional: compilado con `autoninja` y el entorno de brave-core, porque `build.sh` no pasa `gn gen` en 1.57 (`ethereum_remote_client_enabled:false` y `safe_browsing_mode:0`, ver F0.1/F0.2). Pendiente: pruebas de arranque del paso 0 con el HUMANO y el arreglo de `build.sh` (NUBE) **Pruebas del paso 0 (29/09 19:05, con HUMANO):** arranca en la 7,1; mosca en el Dock y en las notificaciones; perfil `LaMosquita/FlyWeb-Development`; llavero "FlyWeb Safe Storage"; no toca `BraveSoftware`. Observaciones: `brave://version` sigue con la etiqueta "Brave:", el logo y el copyright de Brave, y la "Revisión" muestra 25c5f015 (tag 1.57.64) en vez del commit de `flyweb` **Paso 1:** `nube/gclient-slim` fusionada en `flyweb` → 89771b79 (subida). No hace falta compilar **Paso 2:** `nube/webgpu-off` → 28620b97 (subida). `build.sh` ya funciona sin retoques (475 pasos, 1 min); AVX OK. **El criterio de la guía no vale en la 116:** `navigator.gpu` sigue siendo `object` (la opción Blink `WebGPU` es estable y no depende de `WebGPUService`), pero `requestAdapter()` → `null`. Control con `--enable-features=WebGPUService --enable-unsafe-webgpu` → `GPUAdapter`, así que el parche funciona. **NUBE: cambiar la prueba del paso 2 en `integracion.md` a `await navigator.gpu.requestAdapter()` → `null`** **Paso 3:** `nube/jitless` → eb96b76d (subida); 17 pasos, AVX OK. En `https://example.com`: renderer con `--js-flags=--jitless` y `typeof WebAssembly` → `undefined`. En `file://` no se aplica (sigue `object`): la regla es por sitio web; usar una web real para probar. **NUBE: `flyweb-policies.mobileconfig` apunta al dominio `net.lamosquita.flyweb`, pero el build `Static` es `net.lamosquita.flyweb.development`** (Chromium lee `base::mac::BaseBundleID()`): añadir un segundo bloque para `.development` o un perfil de pruebas. Pendiente: HUMANO instala el perfil y comprobamos claude.ai → `object` **Paso 4:** `nube/cve-2024-4671` → 53de2649 (subida). 5 parches aplicados sin error (3 ANGLE, 1 Skia, 1 viz; confirmados con `git diff` en `third_party/angle`, `third_party/skia` y `components/viz`). Compila, incluido `frame_sink_bundle_impl.cc` (6012 pasos, 6 min); AVX OK. WebGL 1 y 2: contexto, dibujo y `readPixels` correctos, sin fallos del proceso GPU (prueba local en lugar de get.webgl.org) **Paso 5:** `nube/l10n` → 0ab57ecc (subida); 2237 pasos, 5 min; AVX OK. Con `--lang=es`: menú "Salir de FlyWeb" (HUMANO), bienvenida en español con FlyWeb; `brave://version`: etiqueta "FlyWeb", empresa "lamosquita" y "Revisión" = commit de `flyweb` (resuelta la observación del paso 0). **NUBE: el copyright sale "Los creadores de FlyWeb"; la guía decía que se quedaba "Los creadores de Brave" a propósito (aviso legal).** `flyweb-rebrand-strings.py --check` necesita `lxml`, que no traen ni Chromium ni `.vpython3` (no ejecutado: grit no falló). **Nota para todos:** si `git merge` falla con "stash falló" en la carpeta de red, ejecutar `git update-index --refresh` antes (índice desfasado por las fechas de Samba) |
| F0.3 | Script de comprobación AVX en los comandos de compilación | NUBE | hecho | `FlyWeb/scripts/check-no-avx.sh`; LOCAL: ejecutarlo tras cada `gn gen`/build |
| F0.4 | `build.sh`: sello de versión y commits en el `.app`, soporte sccache | NUBE | hecho | `out/<modo>/flyweb-build-info.txt` siempre; claves `FlyWeb*` en el Info.plist salvo en Release (no romper la firma). sccache automático si está en el PATH (`brew install sccache`), `FLYWEB_SCCACHE=off` para desactivarlo |
| F0.5 | Firma Developer ID y notarización con `notarytool` | LOCAL | pendiente | necesita el certificado del HUMANO |
| F0.6 | Prueba de arranque en la 6,1 y la 5,1 | HUMANO | pendiente | después de F0.2 |
| F0.7 | Adelgazar checkout (`custom_vars`/`custom_deps` de test) y args de gn que acortan la compilación | NUBE | hecho | brave-core `nube/gclient-slim` (sin NaCl ni VK-GL-CTS en `.gclient` nuevos). `build.sh` por defecto en **Static** (sin ThinLTO); Release solo para publicar. **LOCAL, tras F0.1:** en el `.gclient` existente, añadir en `custom_vars` `"checkout_nacl": False` y en `custom_deps` `"src/third_party/angle/third_party/VK-GL-CTS/src": None`; `gclient sync` borrará lo sobrante; verificar que `gn gen` sigue pasando |

### FlyWeb — Fase 1 (marca y servicios)
| # | Tarea | Quién | Estado | Notas |
|---|---|---|---|---|
| F1.1 | Marca: nombre, bundle id, perfil, llavero, iconos | NUBE | hecho | brave-core `flyweb` 77b25c6b |
| F1.2 | Rebranding Brave→FlyWeb de las cadenas de la interfaz, conservando traducciones | NUBE | hecho | brave-core `nube/l10n` (f3fa6077): `script/flyweb-rebrand-strings.py` + `flyweb_replacements`. 1507 mensajes, 729 ficheros; cobertura de traducción medida antes/después: 1.278.519 = 1.278.519. Los servicios de Brave conservan su nombre |
| F1.3 | Compilar `nube/l10n` y fusionar en `flyweb` (ya **no** hace falta ejecutar `chromium-rebase-l10n.py`) | LOCAL | pendiente | tras F0.2; comprobar menús en español ("Salir de FlyWeb") |
| F1.4 | Parches: referrals, stats ping, Talk y News desactivados | NUBE | pendiente | rama `nube/servicios` |
| F1.5 | Script de auditoría de red con lista de permitidos | NUBE | hecho | `FlyWeb/scripts/network-audit.py` (NetLog de Chromium, sin proxy), `FlyWeb/audit/allowlist.txt` y `denylist.txt`; modos `reposo` y `uso` |
| F1.7 | Quitar las wallets cripto y Rewards (decisión HUMANO: nada de monederos ni BAT en el navegador) | NUBE | hecho | brave-core `nube/no-wallet` (f595966f): Brave Wallet y Brave Rewards siempre desactivados en el código y Crypto Wallets fuera de la compilación. Paso 6 de `integracion.md` |
| F1.6 | Ejecutar la auditoría de red (30 min en reposo + 30 min de uso) | LOCAL | pendiente | instrucciones en la cabecera de `network-audit.py`; añadir a `allowlist.txt` lo legítimo que aparezca, documentado |
| F1.8 | Inventario de la marca Brave que se ve en la interfaz: logotipos e iconos (león de la barra de direcciones y de las pestañas, triángulo de Rewards, logo de `brave://version`, fondo y logo de la NTP, bienvenida), textos que no cubra `nube/l10n` ("Los creadores de Brave", copyright), etiqueta "Brave" de la barra de direcciones, "Revisión" de `brave://version` | NUBE (código) + HUMANO (uso) + LOCAL (capturas por compilación) | en curso | Inventario: `FlyWeb/docs/marca-pendiente.md`. **NUBE, 29/09:** logotipos e iconos (león → mosca) en brave-core `nube/branding-ui` dab0f6ee = paso 7 de `integracion.md`; empresa "lamosquita" y avisos legales de Brave Software intactos en `nube/l10n` b91686cc (paso 5; el paso 5 anterior decía "FlyWeb is a registered trademark of Brave Software"); "Revisión" = commit de `flyweb` en `build.sh`. Imágenes patrocinadas de la NTP quitadas en `nube/no-sponsored-images` 8c984d70 (paso 8, decisión HUMANO). Listado de imágenes a diseñar: `FlyWeb/branding/imagenes.md`. Pendiente: tarjetas de Brave News/Talk. Copyright: "lamosquita and The Brave Authors" (decisión HUMANO), `nube/l10n` 8db1ad26 = paso 5b; arregla también "Los creadores de FlyWeb" que vio LOCAL en el paso 5 |

### FlyWeb — Fase 3A (seguridad inmediata)
| # | Tarea | Quién | Estado | Notas |
|---|---|---|---|---|
| F3A.1 | Parche: jitless por defecto y lista de sitios con JIT | NUBE | hecho | brave-core rama `nube/jitless` (6b81fc54): **LOCAL: compilar y, si funciona, fusionar en `flyweb`**. Lista de permitidos: `FlyWeb/policies/flyweb-policies.mobileconfig` |
| F3A.2 | Medir jitless en claude.ai, Gmail, Docs, Sheets y Drive | LOCAL/HUMANO | pendiente | |
| F3A.3 | Triaje de CVE explotados posteriores a 116 → `FlyWeb/docs/cve-triage.md` | NUBE | hecho | 25 CVE, jitless mitiga seguro 4; 4 fugas del sandbox en macOS |
| F3A.4 | Desactivar WebGPU por defecto (CVE-2026-5281) | NUBE | hecho | brave-core rama `nube/webgpu-off`: override de `kWebGPUService` en `chromium_src/gpu/config/gpu_finch_features.cc`. **LOCAL: compilar, comprobar `navigator.gpu === undefined` y fusionar en `flyweb`** |
| F3A.5 | Portar fugas del sandbox: CVE-2025-6558 (ANGLE), CVE-2024-4671 (viz), CVE-2023-6345 (Skia) | NUBE | hecho | brave-core, ramas apiladas: `nube/cve-2025-6558` → `nube/cve-2023-6345` → **`nube/cve-2024-4671` (contiene las tres)**. ANGLE y Skia: sintaxis comprobada con clang; viz: adaptado a mano, **sin compilar**. LOCAL: compilar `nube/cve-2024-4671` y fusionar en `flyweb`. Índice: `patches/third_party/FLYWEB-SECURITY.md` |
| F3A.6 | ¿Lleva `third_party/libvpx` el arreglo de CVE-2023-5217? | LOCAL | pendiente | mirar `git log` de `src/third_party/libvpx/source/libvpx` tras F0.1 |
| F3A.7 | Confirmar en Chrome Releases el "in the wild" de CVE-2026-3909 y CVE-2026-5281 | NUBE | hecho | **Ambos confirmados**: KEV (productos "Skia" y "Dawn") + CISA ADP `Exploitation: active` + prensa. Corregida la nota errónea del triaje |

### FlyWeb — Fase 7 (interfaz)
| # | Tarea | Quién | Estado | Notas |
|---|---|---|---|---|
| F7.1 | Esquema `flyweb://` en lugar de `brave://` (y `chrome://`), etiqueta "FlyWeb" en la barra de direcciones y página de inicio propia | por decidir | pendiente | Sin fecha: después de estabilizar la base. Brave redirige `chrome://` a `brave://` en muchos sitios del código → parches repartidos; hacerlo con `chromium_src/` para que el rebase siga siendo mecánico |

### BackupDrive
| # | Tarea | Quién | Estado | Notas |
|---|---|---|---|---|
| B.1 | Crear el OAuth client de Google y el `backupdrive.conf` | HUMANO/LOCAL | hecho | proyecto `BackupDrive` en la org. lamosquita.net, pantalla de consentimiento **Interna**, cliente "App de escritorio". `lsd gdrive:` OK con el binario de la CI (ejecución 36464297550) en la 7,1. El `.conf` **no está en el repo** |
| B.2 | Probar `bisync` contra Drive real en Mojave (`--dry-run` → `--resync` → launchd) | HUMANO | pendiente | en la 6,1; primero `scripts/mojave-selftest.sh` |
| B.3 | Iconos de barra de menús: trazos más gruesos | HUMANO | pendiente | ver revisión del PR #3 |
| B.4 | App Cocoa de barra de menús (Xcode 11, Mojave) | LOCAL | pendiente | después de B.2; leerá `status.json` (B.5) |
| B.5 | Motor para la app: `status.json`, bloqueo anti-solapes y avisos de macOS en `backupdrive-sync.sh` | NUBE | hecho | probado en Linux: solapes, bloqueo abandonado, Ctrl-C (`interrupted`), JSON con rutas raras. **Corregido un fallo real:** rclone podía consumir las líneas de `profiles` (la versión anterior solo ejecutaba 1 de 3 perfiles con un programa que lee stdin) |
| B.6 | `mojave-selftest.sh`: autodiagnóstico en la 6,1 antes de B.2 | NUBE | hecho | solo lectura; detecta certificados inválidos (probado con TLS autofirmado) y la hora desfasada. **HUMANO: ejecutarlo en la 6,1 antes de B.2** |
