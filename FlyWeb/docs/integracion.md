# FlyWeb — Orden de integración de ramas (para LOCAL)

Las ramas `nube/*` de `lamosquita-net/brave-core` salen todas de `flyweb` 77b25c6b y **ninguna está compilada**.
Se integran **de una en una, compilando y probando entre cada una**. Así, si algo falla, se sabe qué rama lo
rompió. NUBE ha comprobado que las once se fusionan juntas sin conflictos (fusión de prueba).

Compilar siempre con `FlyWeb/scripts/build.sh` (modo `Static` por defecto). Después de cada compilación, pasar
también `FlyWeb/scripts/check-no-avx.sh ~/proyectos/flyweb-build/brave-browser/src/out/Static`.

> Nota: `Static` no es build oficial, así que usa la marca de desarrollo (`BRANDING.development`). La app se
> llama **"FlyWeb Development.app"**, con bundle id `net.lamosquita.flyweb.development` y perfil en
> `~/Library/Application Support/LaMosquita/FlyWeb-Development`. Es lo esperado.

## Mecánica de cada paso

En el árbol de trabajo de `brave-core` (red, rama `flyweb`):

```sh
git fetch origin
git merge --no-ff origin/nube/<rama>      # un merge commit por rama: fácil de revertir
FlyWeb/scripts/build.sh                   # desde softmac; compila el último commit de flyweb
# ... pruebas del paso ...
git push origin flyweb                    # solo si compila y las pruebas pasan
```

Si falla la compilación o una prueba: **no hacer push**. Deshacer con `git reset --hard HEAD~1` (el merge aún
es solo local), apuntar el error en `docs/TAREAS.md` (las últimas 30 líneas del log de ninja) y avisar a NUBE.

## Pasos

| # | Rama | Commit | Qué cambia | Cómo comprobarlo |
|---|---|---|---|---|
| 0 | `flyweb` (sin fusionar nada) | 77b25c6b | Marca FlyWeb: nombre, bundle id, perfil, llavero, iconos | Compila. Arranca en la 7,1. `brave://version` muestra FlyWeb. El icono del Dock es la mosca. Perfil en `LaMosquita/FlyWeb-Development`. Llavero: entrada "FlyWeb Safe Storage". **Valida también el SDK 13.3 con Xcode 26** (F0.2) |
| 1 | `nube/gclient-slim` | 19a69136 | Solo el generador de `.gclient` (NaCl y VK-GL-CTS fuera) | No afecta a la compilación. Basta con fusionarla (el `.gclient` actual ya lleva esos cambios a mano) |
| 2 | `nube/webgpu-off` | 8c0d680f | WebGPU desactivado (`kWebGPUService`) | Consola de DevTools en cualquier web: `await navigator.gpu.requestAdapter()` → `null`. En la 116 `navigator.gpu` sigue existiendo (la API de Blink es estable y no depende de `WebGPUService`); lo que desaparece es el servicio en el proceso de GPU. Control: con `--enable-features=WebGPUService --enable-unsafe-webgpu` devuelve un `GPUAdapter` |
| 3 | `nube/jitless` | 6b81fc54 | V8 sin JIT por defecto (`JAVASCRIPT_JIT` = BLOCK) | En una web real (en `file://` no se aplica: la regla es por sitio): `typeof WebAssembly` → `"undefined"` (jitless implica `--no-expose-wasm` en el V8 de la 116). Después, instalar `FlyWeb/policies/flyweb-policies.mobileconfig` (cubre `net.lamosquita.flyweb` y `.development`), comprobarlo en `brave://policy` y verificar que en claude.ai `typeof WebAssembly` → `"object"` |
| 4 | `nube/cve-2024-4671` | 54093381 | 3 fugas del sandbox portadas (ANGLE, Skia, viz) y `util.js` aplica parches a `third_party/{angle,skia,libvpx}` | El log de `build.sh` muestra los parches de ANGLE y Skia aplicados sin error. Compila (viz es el único **sin compilar** en la nube: vigilar `frame_sink_bundle_impl.cc`). Prueba rápida: una web con WebGL (p. ej. get.webgl.org) funciona |
| 5 | `nube/l10n` | b91686cc | Cadenas Brave→FlyWeb en 729 ficheros; empresa "lamosquita"; los avisos legales de Brave Software se quedan como están | Arrancar con `--lang=es`: el menú dice "Salir de FlyWeb" y "Acerca de FlyWeb". Ajustes en español sin textos en inglés sueltos. "Brave Rewards" o "Brave Wallet", si aparecen, conservan su nombre. `brave://version`: etiqueta "FlyWeb:" y empresa "lamosquita" (el copyright se corrige en el paso 5b) |
| 5b | `nube/l10n` (otra vez; se puede hacer antes o después del 6, no chocan) | 8db1ad26 | Copyright "lamosquita and The Brave Authors" (en español "lamosquita y los creadores de Brave"; resto de idiomas en inglés). Arregla "Los creadores de FlyWeb", atribución falsa que dejó el paso 5 | `git merge --no-ff origin/nube/l10n` sobre `flyweb` (solo trae ese commit). `brave://version` con `--lang=es`: "Copyright © 2026 lamosquita y los creadores de Brave. Todos los derechos reservados." Solo recompila recursos de cadenas |
| 6 | `nube/no-wallet` | b1c0bd5b | Sin wallets ni Rewards: Brave Wallet y Brave Rewards siempre desactivados (sin botones, sin `window.ethereum` ni `window.solana`); la extensión antigua Crypto Wallets nunca se carga. **Reintento:** el primer intento (f595966f) no compilaba con `ethereum_remote_client_enabled = false` (`external_wallets_importer.cc`); ahora el flag queda como en Brave y se anula la carga de la extensión | Compila (el flag es el mismo de los pasos 0–5). En la consola de una web real: `window.ethereum` → `undefined` y `window.solana` → `undefined`. No hay icono de wallet ni de Rewards (triángulo BAT) en la barra; `brave://wallet` y `brave://rewards` no cargan |
| 7 | `nube/branding-ui` | dab0f6ee | Mosca en lugar del león: icono de pestañas internas, barra de direcciones, notificaciones, logotipos con nombre, logo de `brave://version` y de la bienvenida (F1.8) | `brave://version`: logo mosca + "FlyWeb" (claro y oscuro). Pestaña de `brave://settings`: icono mosca. Barra de direcciones en una página interna: mosca, no león. `brave://welcome`: mosca. Además, con el `build.sh` nuevo, la "Revisión" de `brave://version` es el commit de `flyweb` compilado |
| 8 | `nube/no-sponsored-images` | 8c984d70 | Sin imágenes patrocinadas (publicidad de Brave en la nueva pestaña) ni fondos de "super referral": sus componentes no se registran | Nueva pestaña: solo fotografías, nunca un logo de marca comercial. `brave://components`: no aparece "NTP Sponsored Images" ni "NTP Super Referral". En la auditoría de red (F1.6), ninguna descarga de esos componentes |
| 9 | `nube/branding-ui-2` | 2a4e5198 | Encargos del inventario de LOCAL (`FlyWeb/branding/imagenes.md`): botón de Shields con un PNG por escala (18 y 36 px) en vez de reducir uno de 64, dibujo provisional de escudo con la mosca (verde activo, gris apagado); logo de `brave://version` a 180×53 / 360×106; mosca de bienvenida a 300×358; iconos de la extensión interna | Botón de Shields nítido en barra clara y oscura, sin león. `brave://version`: logo nítido. `brave://extensions` (con "Modo desarrollador" para ver las internas): mosca. Compila `brave_shields_action_view.cc` (único cambio de C++) |
| 10 | `nube/servicios` (reintento) | f0152175 | F1.4 (el primer intento, 93902fc2, fallaba con `-Wunused-function` en `ReadPromoCode`, que solo usa Android; ahora `[[maybe_unused]]`): sin referrals (no se envía el código promocional a `laptop-updates.brave.com`), sin ping diario de uso por defecto, sin Brave Talk en la barra lateral ni en la nueva pestaña, Brave News apagado por defecto (sin tarjeta ni botón); no se registra el componente "Brave Wallet data files" (lo vio LOCAL en el paso 8) | Con un **perfil nuevo**: la barra lateral no tiene Talk; la nueva pestaña no muestra tarjeta de Talk ni de News; `brave://settings/privacy`: "ping diario de uso" desactivado. `brave://components`: sin "Brave Wallet data files". En la auditoría de red en reposo (F1.6), ninguna conexión a `laptop-updates.brave.com`, `talk.brave.com` ni `brave-today-cdn.brave.com` |
| 11 | `nube/cve-2026-3909` | eec87884 | Parche de seguridad de Skia (CVE-2026-3909, explotado activamente): cada glifo del atlas de texto se guarda por ID **y formato de máscara**, y el atlas se elige por el formato de la subejecución. 8 `.patch` nuevos en `patches/third_party/skia/` | El log de `build.sh` muestra los parches de Skia aplicados sin error. Compila (recompila buena parte de Skia). Texto bien dibujado en: una web normal, texto con subpíxeles (LCD) y emoji de color (p. ej. https://getemoji.com), y claude.ai |
| 12 | `nube/buscador` | 67760360 | DuckDuckGo como buscador por defecto en lugar de Brave Search (que era el de España y EE. UU.): la variante regional de DuckDuckGo de cada país; donde no hay, el buscador regional salvo que sea Brave Search (entonces Google). Las ventanas privadas usan el mismo. Brave Search sigue como opción. 2 ficheros de C++ | Con un **perfil nuevo** (un perfil existente conserva el buscador que ya tenía): `brave://settings/search` → DuckDuckGo por defecto, y en la lista siguen Google, Brave, Bing, Qwant, Startpage y Ecosia. Buscar algo en la barra de direcciones → `duckduckgo.com`. Ventana privada: también DuckDuckGo |
| 13 | `nube/no-variations` | d14c62f8 | Sin petición de variations al arrancar (F1.6 vio `flyweb.invalid/?osname=mac&milestone=116`): ya no se pasa `--variations-server-url`, y sin él un Chromium sin marca Google no la hace. Se fusiona limpio con el 12 (probado) | Compila (solo `chrome_main_delegate.cc`). Repetir la auditoría en reposo: ya no aparece `flyweb.invalid`. `chrome://version` → la línea de comandos no lleva `--variations-server-url` |
| 14 | `nube/crash-local` | 2eda550b | (a) **Informes de fallos solo en local:** se guardan en el disco (carpeta `Crashpad` del perfil) y nunca se suben; antes iban a `cr.brave.com` si el usuario aceptaba el diálogo que aparece tras un cierre inesperado, que también se quita. (b) **Geolocalización por los servicios de localización de macOS** (CoreLocation) en lugar de mandar las redes Wi-Fi cercanas a la API de Google (que además fallaría: no hay clave). 3 ficheros; se fusiona limpio con 12 y 13 | Compila (`gn gen` cambia por `enable_crash_dialog`). (a) Abrir `brave://inducebrowsercrashforrealz`, volver a abrir FlyWeb: sin diálogo de "enviar informes"; hay un `.dmp` nuevo en `~/Library/Application Support/LaMosquita/FlyWeb-Development/Crashpad/` (`pending` o `completed`). En la auditoría, ninguna conexión a `cr.brave.com`. (b) En una web que pida ubicación (p. ej. https://browserleaks.com/geo): tras permitirlo en FlyWeb, macOS pide permiso a "FlyWeb" en Preferencias > Seguridad > Localización, y sale la posición. Ninguna conexión a `www.googleapis.com`. **Si macOS no pide permiso o no llega la posición, avisar a NUBE** (en Chromium 116 esta vía está desactivada por defecto) |
| 15 | `nube/polyfills` | e3c10757 | **Fase 4:** polyfills de JavaScript (core-js, 50 KB) inyectados en cada página web antes que sus scripts: lo que la web moderna da por supuesto y Chromium 116 no tiene (`Object.groupBy`, `Promise.withResolvers`, métodos de `Set`, iteradores, `URL.canParse`…). Código nuevo en el proceso de render + un recurso. Se fusiona limpio con 12, 13 y 14 | Compila (nuevo: `renderer/flyweb/`, `IDR_FLYWEB_POLYFILLS_JS`). En la consola de cualquier web: `typeof Object.groupBy` → `"function"`, `typeof Iterator` → `"function"`, `new Set([1]).union(new Set([2])).size` → `2`. Arrancando con `--disable-features=FlyWebPolyfills`, `typeof Object.groupBy` → `"undefined"`. En `brave://version` o una página interna, nada cambia. `about:credits` incluye core-js. Después, el diagnóstico de `FlyWeb/docs/compatibilidad.md` §2 |

Después del paso 11 (el 12 no es necesario para esto): F0.2 queda cerrada, y el `.app` se puede copiar a la 6,1 y la 5,1 para F0.6.

## Prueba en la MacPro5,1 (F0.6)

Xeon Westmere (2010): SSE4.2, **sin AVX**. Lo que puede fallar ahí y no en la 7,1 ni en la 6,1:

1. **Arranque.** Si se cierra al abrir: `~/Library/Logs/DiagnosticReports/FlyWeb*.crash` (o `…Helper*.crash`). Si pone
   `EXC_BAD_INSTRUCTION` / `SIGILL`, se ha colado una instrucción AVX: traer el fichero entero (la línea del hilo que
   falla dice en qué biblioteca). `check-no-avx.sh` solo mira los comandos de compilación, no los binarios.
2. **Procesos auxiliares.** Abrir `brave://gpu` y `brave://version`. Un fallo de AVX puede estar solo en el proceso de
   GPU o de red: la ventana abre, pero las pestañas salen en blanco o con "¡Oh, no!". Guardar `brave://gpu` como texto.
3. **Gráfica.** En `brave://gpu`: modelo de GPU, "WebGL: Hardware accelerated", "Video Decode". Probar
   https://get.webgl.org y un vídeo de YouTube a 1080p mirando la CPU en el Monitor de Actividad (sin decodificación
   por hardware, un vídeo 1080p puede saturar la CPU).
4. **Criterio de aceptación.** Con el perfil de políticas instalado: claude.ai (entrar, conversar, adjuntar un fichero),
   Gmail, Drive y Docs. En `brave://policy`, las políticas cargadas. Anotar si algo va lento.
5. **jitless.** En una web cualquiera que no esté en la lista (p. ej. un periódico): que funcione y cuánto tarda en
   cargar. Es donde más se nota la CPU antigua.
6. **Memoria y CPU en reposo**, con 3 o 4 pestañas abiertas durante 10 minutos.

Traer: los `.crash` si los hay, `brave://gpu` en texto y notas de 1 a 6. Apuntarlo en F0.6 de `docs/TAREAS.md`.

## Si un paso falla

- **4, parche que no aplica:** `npm run apply_patches` indica cuál. Revertir solo ese paso y avisar a NUBE con el
  mensaje de error. Los tres CVE van en commits separados dentro de la rama.
- **4, viz no compila:** el parche adaptado a mano puede necesitar un `#include` o tipos distintos en la 116.
  Pasar el error a NUBE.
- **`flyweb-rebrand-strings.py --check`** necesita `lxml`: `python3 -m pip install --user lxml` (no lo traen Chromium ni `.vpython3`). Es solo una comprobación; la compilación no lo necesita.
- **11, parche de Skia que no aplica o no compila:** revertir solo ese paso y pasar el error a NUBE. Es una adaptación a mano: el fallo más probable sería un tipo o una firma distinta en algún fichero de `src/text/gpu/` o `src/gpu/*/text/`.
- **5, error de grit** (por ejemplo "message not found" o un id duplicado): pasar el error a NUBE. El script
  `script/flyweb-rebrand-strings.py --check` debe devolver 0 ficheros.
