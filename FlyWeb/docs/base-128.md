# FlyWeb — estudio del salto de base 116 → 128 (INVESTIGACIÓN-MOTOR, 19-10-2026)

Estudio en papel (fila FM.26). Sin código ni ramas de brave-core. Propone; deciden ARQUITECTURA o el HUMANO.
Pregunta: ¿qué APIs de macOS 10.15 usa Chromium 117–128, qué habría que reponer para que funcione en Mojave 10.14,
con horas y riesgo por componente?

> **Revisado el 20-10 (FM.32):** con el diff real de Chromium Legacy (44 ficheros de 10.15, 31 idénticos en la 128) la parte de APIs baja de 85–220 h a **25–55 h**; ver `migracion-128.md` §6. Lo que sigue es el análisis original.

**Etiquetas de evidencia:** **[V]** visto en el código o la página citada; **[I]** inferido de lo visto;
**[H]** hipótesis sin comprobar. Las horas son **estimación mía** (trabajo efectivo de un agente o de LOCAL, **sin**
esperas de compilación ni tiempo del HUMANO delante de las máquinas), no una medición.

## 1. Resumen

1. **Qué cambia en 117 [V]:** Chromium sube el destino de despliegue de 10.13 a **10.15** (`mac_deployment_target` y
   `mac_min_system_version`, comparado en los tags 116.0.5845.188, 117.0.5938.62 y 128.0.6613.138; el SDK oficial pasa
   de 13.3 a **14.0**). Lo hace con una serie de ~22 commits «Remove 10.13, 10.14 support from …» que borran las
   guardas `@available(macOS 10.15)` y los caminos antiguos. **La 128 es la última con 10.15**; la 129 exige macOS 11
   (`motor.md`, principio 13).
2. **Lo que hay que reponer es acotado, pero no trivial.** De los 22 commits, **14 tocan APIs de 10.15** y **8 solo
   10.13/10.14** (Mojave ya tiene esas APIs; no hay que reponer nada). Con lo catalogado salen **15 bloques, 55–130 h**;
   con lo que ese catálogo no ve (cambios de 118–128 y conflictos por código movido) el total de reposición de APIs es
   **85–220 h (central ~140 h)**, más 20–40 h de pruebas en la 6,1 y la 5,1.
3. **Tres cosas rompen el arranque o cada proceso hijo** si no se reponen (§3, filas 2, 3 y 4), y una cuarta, la
   estadística de permisos de la fila 8, si se ejecuta al arrancar.
4. **El coste de la API no es el coste del salto.** Rebasar brave-core 1.57 → 1.69 (**más de 5 000 commits** [V]),
   repasar los 45 pasos de FlyWeb y los portes de los niveles 117–131 suma, en orden de magnitud, **otras 230–450 h**
   (§5, más 20–40 h de pruebas). Total del salto: **~330–710 h (central ~500)**.
5. **Recomendación (confianza media): no saltar todavía; medir primero** (§7). El argumento serio a favor del salto no
   es el motor (Blink/V8 ya van por niveles) sino la **superficie de seguridad fuera de Blink y V8** (net, media, GPU,
   Skia, ANGLE, códecs, WebRTC), que hoy sigue en la 116 y solo recibe los parches que SEGURIDAD-PORTES elige. Eso se
   puede cuantificar con una medición barata (≈1 día de LOCAL + cruce con `cve-triage.md`) antes de gastar 330–710 h.

## 2. Método y límites

- La sesión de nube **no llega a `chromium.googlesource.com`** (el proxy lo deniega) ni tiene copia de Chromium. Se ha
  usado: el espejo `chromium/chromium` en GitHub (ficheros por tag), las páginas de commits de
  **[Chromium Legacy](https://github.com/blueboxd/chromium-legacy)** (blueboxd; BSD-3; Mojave incluida) y búsquedas.
- **Pista principal [V]:** Chromium Legacy, para seguir en Mojave, **revirtió** exactamente esa serie el 29-06 y el
  13-07-2023 (22 reverts, más «Revert "Bump the macOS deployment target to 10.15"»). Sus títulos y diffs son un
  inventario fiable de lo que Chromium quitó. Lo que **no** da: lo que se escribió **después** (118–128) asumiendo 10.15.
- Límite: el resumen de cada diff lo hace una herramienta que a veces no muestra ficheros (los de prueba sobre todo).
  Las líneas son las de **los reverts de Legacy** (incluyen tests y comentarios), no el código de producción neto.
- **Cómo cerrar lo que falta (para LOCAL):** compilar con `mac_deployment_target = "10.14"`. La configuración de Apple
  de Chromium ya lleva `-Wunguarded-availability` [V: `build/config/compiler/BUILD.gn` en 128], así que clang listará
  toda llamada sin guarda a una API posterior a 10.14. Eso da el inventario exacto de lo **declarado**; lo que clang no
  ve (símbolos C sin anotar, SPI privados, cambios de comportamiento, perfiles del sandbox, Metal) está en §4.

## 3. Inventario por componente (solo lo que toca 10.15)

Gravedad si no se repone: **A** = no arranca o cae cada proceso hijo; **B** = cae al usar una función corriente;
**C** = función rara o solo estadísticas. Riesgo = probabilidad de que la reposición salga mal o rompa algo más
(incluye conflictos con el código de 128, que movió `base/mac`→`base/apple`, `media/capture/video/mac`→`apple` y el
selector de color a `components/`, y migró a ARC).

| # | Componente | Qué usa la 117–128 sin guarda (10.15) | Qué reponer | Revert de Legacy | Horas | Riesgo | Grav. |
|---|---|---|---|---|---|---|---|
| 1 | Destino de despliegue (`build/config/mac/mac_sdk.gni`, plists, Brave) | `mac_deployment_target`/`mac_min_system_version` = 10.15 | Volver a 10.14 (FlyWeb: lo que declare hoy) y arreglar lo que clang señale | +1/−1 | 1–3 | Bajo | A |
| 2 | **AuthenticationServices** (`chrome/browser/BUILD.gn`, `app_controller_mac.mm`, `auth_session_request.*`, `chrome_content_browser_client.cc`, `mac_intent_picker_helpers.mm`) | Framework enlazado fuerte (Chromium lo pasó de débil a fuerte en e56fff9 [V]; en 10.14 no existe → dyld no deja arrancar [I]); `ASWebAuthenticationSession`, `SFUniversalLink` | Enlace débil + `API_AVAILABLE(macos(10.15))` y guardas. Alternativa: apagar la función por GN (sin inicio con Apple/passkeys en Mojave) | 2 commits: +159/−35 y +259/−218 (casi todo pruebas) | 3–8 | Medio (Brave toca `app_controller_mac`) | **A** |
| 3 | **Sandbox: `_CSCheckFixDisable`** (`sandbox/mac/system_services.cc`) | Se llama sin guarda en `DisableCoreServicesCheckFix()` [V en 128]; símbolo nuevo de 10.15 | `if (__builtin_available(macOS 10.15, *))` | +5/−3 | 0,5–2 | Bajo | **A** (cada hijo) |
| 4 | **Pantallas** (`ui/display/mac/screen_mac.mm`) | `-[NSScreen localizedName]` y `maximum(Potential)ExtendedDynamicRangeColorComponentValue` sin `@available` [V en 128] → *unrecognized selector* al enumerar pantallas | Guardas + el nombre por IOKit (`IODisplayCreateInfoDictionary`) | +137/−18 (con pruebas) | 3–6 | Bajo | **A** |
| 5 | Lanzar apps y abrir URL/ficheros (`base/mac/launch_application.mm`, `chrome/browser/platform_util_mac.mm`) | `NSWorkspaceOpenConfiguration` y `openURL:configuration:completionHandler:` | Camino antiguo `launchApplicationAtURL:`/`openURLs:withAppBundleIdentifier:…` | +73/−24 y parte de +159 | 4–8 | Medio (cambió a ARC y `base::apple`) | B (enlaces externos, «mostrar en Finder») |
| 6 | Puente CTFont ↔ NSFont (`base/apple/bridging.h`, `base/mac/foundation_util.mm`) y `substring_util.mm` | Antes de 10.15 CTFont **no** es toll-free con NSFont: los *casts* directos fallan; `-[NSFont fontWithSize:]` | Helpers de conversión + `NSFontManager convertFont:toSize:` | +48/−1, +68/−2, +62/−5 | 6–14 | **Medio-alto** (toca `CFCast` de toda la base; el archivo se movió) | B (fuentes, IME, accesibilidad) |
| 7 | **Captura de vídeo** (`media/capture/video/apple/*`, `media/base/mac/…_helpers.mm`) | `AVCaptureDeviceDiscoverySession` y `AVCapturePhotoOutput` (10.15) | Enumeración con `[AVCaptureDevice devices]` y `AVCaptureStillImageOutput` (+ el flag de prueba) | +25/−13 y +107/−18 | 10–24 | **Alto** (código muy reescrito entre 117 y 128; hace falta una webcam real en Mojave) | B (Meet, Zoom web, `getUserMedia`) |
| 8 | Permisos de captura de pantalla y estadísticas (`system_media_capture_permissions_*`, `ui/base/cocoa/permissions_utils.mm`, `chrome/browser/media/webrtc`, `media_router_*`) | «Grabación de pantalla» es permiso de 10.15 (`CGPreflightScreenCaptureAccess`…); en 10.14 no existe. La estadística de arranque la llama sin guarda | `IsAtLeastOS10_15()` y `@available`; quitar la estadística (FlyWeb no envía UMA) | +133/−84, +81/−62, +71/−43 | 5–10 | Medio | B (`getDisplayMedia`); la estadística es **A** si se ejecuta al arrancar [I] |
| 9 | Códecs de audio (`media/base/supported_types.cc`, `media/filters/mac/audio_toolbox_audio_decoder.cc`) | xHE-AAC y AAC por AudioToolbox de 10.15 | `__builtin_available(macOS 10.15)` → `false` en 10.14 | +52/−36 | 2–4 | Bajo | C (si no, anuncia un códec que no decodifica) |
| 10 | Cuentagotas (`chrome/browser/ui/views/eye_dropper/*`, hoy en `components/`) | `NSColorSampler` (10.15); Chromium borró la implementación antigua (−107 líneas) | Reponer `EyeDropperView` o **apagar** la API en Mojave | +16/−107 | 2–6 | Bajo | C |
| 11 | **Truncado en el sandbox** (`FileUtilitiesHost::SetLength`, `file_system_access_regular_file_delegate.cc`, `seatbelt_unittest.cc`, mojom) | Desde 10.15 el sandbox deja al renderer truncar un descriptor ya abierto; en Mojave lo bloquea (el test de Seatbelt de Legacy espera error) y hay que pedirlo al proceso del navegador | Reponer el mensaje Mojo `SetLength` (`[EnableIf=is_mac]`) y su rama `!IsAtLeastOS10_15()` | +123/−7 | 5–10 | Medio. **Toca un `.mojom` de Blink → pasa por la regla 17** | B (OPFS, `FileSystemSyncAccessHandle.truncate()`) |
| 12 | Bluetooth y mandos (`device/bluetooth/bluetooth_adapter_mac.mm`, `device/gamepad/…`) | `CBCentralManager.authorization`, `GCController.productCategory` (10.15) | Guardas | +24/−16 | 2–4 | Bajo | B/C (cae al conectar un mando) |
| 13 | Enterprise y remoting (`secure_enclave_client_impl.mm`, `remoting/host/*`) | `kSecUseDataProtectionKeychain`; el anfitrión de Escritorio remoto | **No compilar** (no son del navegador ni de Brave) | +54/−21 y +37/−11 | 0–1 | Bajo | — |
| 14 | **Listas de GPU** (`gpu/config/gpu_driver_bug_list.json`, `software_rendering_list.json`, `gpu_workaround_list.txt`) | Chromium borró apaños «para versiones de macOS que ya no admite» y entradas de bloqueo; Legacy los **revirtió el 03-02-2024** | Reponer las entradas (datos, no código) | datos | 4–12 | **Alto** (hay que probar en las GPU reales) | B: **colores mal con aceleración en Mojave en 117–119** [V, issue 191 de Legacy] |
| 15 | **Dawn / ANGLE / Skia** (repos propios de `DEPS`) | Dawn: `[MTLDevice hasUnifiedMemory]` y `supportsFamily:` (10.15; Legacy los guardó en oct-2023 y mayo-2024) [V]; ANGLE: sin cambios visibles, a medir [H] | Guardas en cada repo; **WebGPU** en Mojave: aparte | no visible (están en fusiones) | 6–16 | **Alto** (cae el proceso de GPU = no pinta) | A/B según backend [H] |

**Subtotal catalogado: 55–130 h.** (La suma de los rangos de las filas es 53,5–128 h.)

### Lo que NO hay que reponer (8 de los 22 commits) [V]

Notificaciones (`UserNotifications`, 10.14), tema oscuro y colores nativos (10.14), `ui/` de modo oscuro, código
empresarial (10.10/10.13.4), `network_session_configurator` (caché SimpleCache; solo cambia para <10.14),
soporte de variaciones de fuentes de CoreText (10.14), «Remove 10.13 support», y remoting. Mojave **ya tiene** esas APIs.
Eso recorta mucho el trabajo respecto a «volver al estado de la 116».

## 4. Lo que el catálogo no ve (hallazgos de Legacy, a medir)

- **Frameworks y símbolos tras 117** que Legacy tuvo que guardar entre 2023 y 2024 y cuyo mínimo no he podido fijar:
  `CryptoTokenKit.framework` (enlace débil), `VTIsHardwareDecodeSupported()`, `kSecGuestAttributeDynamicCode*`,
  `change_fdguard_np()`, `kAEGetURL` [H]. El compilador dirá cuáles superan 10.14.
- **Skia y colores:** Legacy cambió `CGColorSpaceCopyICCData` por `CopyICCProfile` (feb-2024); es de 10.13 (según mi conocimiento de la API, [I]), **no** de 10.15: no aplica a Mojave.
- **Reloj de hilo:** Legacy revirtió «Use clock_gettime to get thread time on Mac» (12-10-2023) [V el revert; H el motivo].
- **Perfiles del sandbox:** el 26-06-2023 Legacy evitó un `(allow sysctl-read (if …` en cascada que hacía fallar
  `SeatbeltExecServer` («car: argument 1 must be: pair»); y en 2024 «re-guarding prefix/xpc-service-name/sysctl-name».
  No sé en qué macOS ocurría [H: ≤10.13]; **hay que probar el sandbox V2 en Mojave** (la herramienta de pruebas de
  `sandbox/mac` ya existe).
- **Crash de TFLite en 121+** ([issue 242 de Legacy](https://github.com/blueboxd/chromium-legacy/issues/242)):
  `AutofillModelExecutor::Preprocess` vía `OptimizationGuide`, en varios macOS viejos, con Mac Pro entre ellos;
  su apaño es `--disable-features=OptimizationHints`. **Comprobar que Brave 1.69 ya lo trae apagado** (Brave apaga
  `OptimizationGuide`, pero no lo he visto en esta versión) [H].
- **AVX:** no he encontrado en 117–128 un cambio de base x86-64 (`-msse3` sigue), pero TFLite/XNNPACK, libyuv, WebRTC,
  Dawn y Skia traen rutas AVX2/AVX-512 con despacho en ejecución. En la 5,1 (sin AVX) habrá que probar uno a uno
  [H; regla fija: nada de binarios que exijan AVX].
- **Toolchain:** SDK 14.0 (Xcode 15.0) y el clang de Chromium. La 7,1 compila con él; el SDK 14 con destino antiguo
  pidió a Legacy dos parches de cabecera de `GameController.framework` (`strong`→`assign` en `GCDevice.h` y
  `GCDevicePhysicalInput.h`) [V, su wiki]. 8–16 h para dejar `setup-build.sh`/`build.sh` con SDK 14.

## 5. Costes que no son de macOS pero deciden (orden de magnitud, [H])

| Bloque | Dato | Horas |
|---|---|---|
| brave-core 1.57.64 → **1.69.168** (Chromium 128; última Brave con 10.15, §8) | +5 000 commits en el rango [V]; los 45 pasos de FlyWeb y la marca (`rebranding.md`) se reaplican sobre `chromium_src/` y parches | 150–300 |
| Portes de motor 117–131 | Los de ≤128 pasan a estar ya en el árbol (se descartan); hay que **revisar** los arreglos, los flags de la regla 19 y lo apagado por la regla 20; y **volver a cortar** los de 129–131 (≈216 commits en `FlyWeb/tools/port/nivel129–131-commits.tsv`) sobre la 128 (más fácil que sobre la 116) | 60–120 |
| V8 | **Independiente de la base**: se fija con `FlyWeb/v8-revision`; la 128 trae la 12.8 | 5–15 |
| SEGURIDAD-PORTES | Los parches propios sobre la 116 (62 en V8) en su mayoría **dejan de hacer falta** hasta la 128; los de 129+ se rehacen con menos conflictos | −(ahorro) |
| Toolchain y SDK 14 | §4 | 8–16 |
| Pruebas en la 6,1 y la 5,1 (checklist de «Ciclo continuo» + cámara, GPU, WebGL, sandbox) | tiempo del HUMANO, no del agente | 20–40 |

## 6. Valoración crítica

**A favor del salto**
- **Seguridad fuera de Blink/V8.** FlyWeb sube Blink y V8 por niveles, pero `net/`, `media/`, GPU, Skia, ANGLE, códecs,
  PDF, WebRTC y `content/` siguen en la 116: 12 hitos de correcciones sin aplicar salvo las elegidas (hoy, por KEV y
  triaje). Pasar a la 128 las trae todas de golpe y deja la distancia a los parches futuros en ~15 hitos en lugar de ~27
  respecto a una rama ≥140 (menos conflictos al portar). **Es el único argumento fuerte.**
- Cada nivel posterior se porta sobre código más cercano al original (Blink de 128).

**En contra**
- **Es un punto final, no un camino.** La 129 exige macOS 11: pasar de 128 a 129 repone 11.0 *además* de 10.15, y no
  hay otra base mantenida (Legacy está parado desde mayo de 2024: última 127.0.6494.0 [V]). Tras el salto el problema
  vuelve a empezar, y la 128 lleva **dos años sin parches de Google**. Es exactamente la objeción de `motor.md`
  («ganar 8 versiones y volver a quedarse parados»), con 12 en lugar de 8.
- **Regresiones documentadas en Mojave** con 117+ ([colores mal con GPU 117–119](https://github.com/blueboxd/chromium-legacy/issues/191),
  [crash TFLite 121+](https://github.com/blueboxd/chromium-legacy/issues/242)); Legacy cerró el proyecto con ambos
  abiertos o resueltos solo con un flag. Hoy FlyWeb **funciona** en Mojave con la 116; el salto lo pone en riesgo.
- El esfuerzo (~330–710 h) compite con los niveles 132+ y con lo que Titín considere prioritario (iOS, Linux, PPC).
- La API de macOS es la parte **barata** (≈ un tercio): la mayor parte es rebasar Brave y repasar nuestros cambios.

**Alternativa de bajo coste que logra parte del beneficio:** subir el listón del triaje de CVE (Alto/Crítico en `net`,
`media`, GPU, Skia, ANGLE y códecs, no solo KEV) y portar esas correcciones sobre la 116. No elimina el coste (cada
parche aplica peor cuanto más lejos), pero lo reparte y no arriesga Mojave.

## 7. Propuesta

1. **Medición (LOCAL, ~1 día de trabajo + una compilación Static; hace falta un checkout de la 128 aparte, ~100–150 GB; no tocar `flyweb-build`):** en el tag
   128.0.6613.138 de Chromium **puro** (sin Brave), con `mac_deployment_target = "10.14"` y SDK 14.0: contar los avisos
   `-Wunguarded-availability` (cierra el «lo que el catálogo no ve» del §4), y arrancar el resultado en la 6,1 para ver
   qué cae primero (sandbox, GPU, cámara). **Entregable:** número de avisos por directorio y lista de lo que cae al
   arrancar.
2. **Donante (LOCAL):** añadir `blueboxd/chromium-legacy` como *remote* del checkout y sacar con `git diff` el
   delta de los ficheros de macOS entre su `127.0.6494.0` (rama `master.lion`) y el Chromium de esa versión. Es BSD-3
   (compatible con la raíz MIT; cada software con su licencia, regla fija) y evita reescribir las filas 2–12. Habrá que
   quitar lo de 10.7–10.13, que a nosotros nos sobra.
3. **SEGURIDAD-VIGÍA/PORTES:** contar en `cve-triage.md` cuántos CVE de severidad Alta/Crítica de 117–128 **fuera de
   Blink y V8** aplican a la 116 y no están portados. Ese número es lo que compra el salto.
4. **Decisión (ARQUITECTURA o HUMANO) con esos tres datos.** Mi pronóstico: si el punto 3 da decenas de CVE sin
   portar y el punto 1 da menos de ~300 avisos y un arranque limpio en la 6,1, el salto compensa; si no, la alternativa
   de §6.
5. Si se hace, orden: filas 1–4 y 13 (arranque) → 14–15 (GPU) → 7–8 (cámara, pantalla) → 5, 6, 11 → 9, 10, 12; una
   rama `nube/base-128` desde `v1.69.168` de brave-core, no sobre `flyweb`; compilar Static en la 6,1 tras cada grupo.

## 8. Fuentes

- Chromium, valores por tag: `build/config/mac/mac_sdk.gni` en
  [116.0.5845.188](https://raw.githubusercontent.com/chromium/chromium/116.0.5845.188/build/config/mac/mac_sdk.gni),
  [117.0.5938.62](https://raw.githubusercontent.com/chromium/chromium/117.0.5938.62/build/config/mac/mac_sdk.gni) y
  [128.0.6613.138](https://raw.githubusercontent.com/chromium/chromium/128.0.6613.138/build/config/mac/mac_sdk.gni);
  `sandbox/mac/system_services.cc` y `ui/display/mac/screen_mac.mm` en 128.0.6613.138.
- Commit [«Remove 10.13, 10.14 support in chrome/» (e56fff9, bug 1410851)](https://github.com/chromium/chromium/commit/e56fff98165514375405c81e9eaf8d7f1183ee49);
  [Electron 27: aviso de que Chromium deja 10.13/10.14](https://github.com/electron/electron/pull/38917).
- Reverts de Legacy (junio–julio de 2023): [lista de commits](https://github.com/blueboxd/chromium-legacy/commits/master.lion?author=blueboxd&since=2023-06-01&until=2024-06-30&after=f37ef1f2adb14bc43270ebe9cde30a6ce5b70718+139);
  por ejemplo [Bump 10.15](https://github.com/blueboxd/chromium-legacy/commit/6f464a073bd589d0927db35a01162f4093b5b5c5),
  [/base](https://github.com/blueboxd/chromium-legacy/commit/12def3b0f5eb48efe3ea463cb4a530c3e2af1fc0),
  [chrome/](https://github.com/blueboxd/chromium-legacy/commit/ad21b776a9545e60a9caa5b11d2071ce2ceeb1e7),
  [ui/](https://github.com/blueboxd/chromium-legacy/commit/fa6f4a48c4acbe3fb825a256b1d0676a9ad57ee3),
  [sandbox/](https://github.com/blueboxd/chromium-legacy/commit/e3ce31c1492cae43b8d518ec44702636f7aca240),
  [sandbox (truncado)](https://github.com/blueboxd/chromium-legacy/commit/959e7987efce97ffdf9d8238b88ad55986c7ad5b),
  [/media](https://github.com/blueboxd/chromium-legacy/commit/eeecfa3ba12e4639db832826d71716219d2f3a38),
  [device/](https://github.com/blueboxd/chromium-legacy/commit/7a1ef289b443eab3fa0371e27c65defdd19d26c4).
- Legacy: [wiki Building](https://github.com/blueboxd/chromium-legacy/wiki/Building) (SDK 14+, clang 18+, parches de
  GameController), [releases](https://github.com/blueboxd/chromium-legacy/releases) (última: 127.0.6494.0, 29-05-2024),
  issues [191](https://github.com/blueboxd/chromium-legacy/issues/191) y [242](https://github.com/blueboxd/chromium-legacy/issues/242);
  forks de [Dawn](https://github.com/blueboxd/dawn/commits/master.lion?author=blueboxd) y
  [Skia](https://github.com/blueboxd/skia/commits/for-lion?author=blueboxd).
- Brave: [última versión para 10.15 = 1.69.168 con Chromium 128; 1.57.64/116 para 10.13 y 10.14](https://support.brave.app/hc/nl/articles/18347246446733-Changes-to-macOS-desktop-browser-requirements);
  [comparación brave-core v1.57.64…v1.69.168](https://github.com/brave/brave-core/compare/v1.57.64...v1.69.168)
  (5 000+ commits).
- Proyecto: `motor.md` (decisión del 04-10 y principio 13), `hoja-de-ruta.md` (Fase 6), `docs/TAREAS.md` (reglas 15, 17–20).

## 9. Pendiente de verificar (para la próxima vuelta)

- **Respondido (20-10):** ANGLE usa **OpenGL 4.1 por defecto** en la 116, en Mojave y en Sequoia; Metal solo con
  `--use-angle=metal` (`multimedia.md` §3). Falta saber el valor por defecto de Chromium 128 y si Dawn/WebGPU funciona
  en Mojave (WebGPU está apagado, `integracion.md` paso 2); con OpenGL por defecto, la fila 15 es menos grave para el
  arranque, pero pasa a ser decisiva si se quiere Metal (`vision-motor.md`, V16).
- Si Brave 1.69 apaga `OptimizationGuide` y el modelo de autorrelleno (crash 242).
- El mínimo real de macOS de los símbolos del §4 (lo cierra la medición).
