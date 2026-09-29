# FlyWeb — Hoja de ruta

Base: `brave-core` v1.57.64 / Chromium 116.0.5845.188. Objetivo: navegador usable y razonablemente seguro
en Mojave (MacPro6,1 y 5,1). Criterio de aceptación: claude.ai, Gmail, Drive y Workspace.

Cada fase termina con un **hito comprobable**. No se pasa a la siguiente sin cumplirlo.
Orden de ejecución: **0 → 1 → 3A → 4 → 2 → 3B → 5 → 6 → 7**. La seguridad básica va antes que la
infraestructura propia; mientras no exista la Fase 2, los componentes se descargan del go-updater de Brave.
Reparto de tareas entre agentes: [`../../docs/TAREAS.md`](../../docs/TAREAS.md).

---

## Fase 0 — Compilación reproducible

1. Resolver el punto "sin probar" del README: `mac_sdk_path` con el SDK 13.3 y Xcode 26 activo. Si `find_sdk.py`
   o `sdk_info.py` fallan, usar `DEVELOPER_DIR=~/proyectos/sdk/Xcode-14.3.1.app/Contents/Developer` solo para la compilación.
2. **CPUs sin AVX (MacPro5,1):**
   - Nada de `-march=native` ni `target-cpu=native` en C++ ni en Rust. Chromium no los usa por defecto; hay que
     vigilar que ningún parche los introduzca.
   - `scripts/check-no-avx.sh`: revisa los comandos de compilación (`ninja -t commands`), no el binario, porque
     Chromium siempre contiene código AVX con selección en tiempo de ejecución. Falla con flags `native` o con
     flags AVX en más del 5 % de los comandos (señal de flag global).
   - Prueba de arranque en la 5,1 en cada release.
3. Release con `is_official_build=true` y `symbol_level=0`. Compilación incremental con sccache para el día a día
   (`npm config set sccache …`, ya soportado por `config.js`).
4. `scripts/build.sh` genera un `.app` identificable: versión FlyWeb, commit de `flyweb` y commit de Chromium.
5. **Firma con Developer ID (Team `MQ3NJ73LC5`) y notarización con `notarytool`**. `altool` ya no funciona, y el
   flujo de Brave lo usa. Las primeras compilaciones pueden ir sin firmar.

**Hito:** el mismo commit produce un `.app` firmado que arranca en la 6,1 y en la 5,1.

## Fase 1 — Rebranding y corte de servicios de Brave

1. Completar `docs/rebranding.md`. Ya están hechos el nombre, el bundle id, el perfil, el llavero y los iconos.
   Faltan las cadenas (`script/chromium-rebase-l10n.py`) y los logotipos de la nueva pestaña y de bienvenida.
2. Desactivar Rewards/BAT, Sync, P3A y estadísticas, Wallet, News, Talk y referrals. Usar buildflags donde existan
   (ya en `build.sh`) y parches pequeños donde no.
3. Quitar las claves de API de Brave y de Google del build.
4. **Auditoría de red** con mitmproxy o Little Snitch, automatizada con un script que falle si aparece un destino
   no permitido. Decidir qué hacer con la redirección de CRLSet al proxy de Brave
   (`chromium_src/chrome/browser/component_updater/crl_set_component_installer.cc`, `components/constants/network_constants.cc`).
5. Informes de fallos solo locales: sin subida a Brave, con volcados en disco para depurar en la 5,1.

**Hito:** en 30 minutos de uso normal, cero conexiones no previstas. Se permite `go-updater.brave.com` y lo que
redirija para componentes, hasta completar la Fase 2.

## Fase 3A — Seguridad inmediata

1. **V8 sin JIT por defecto**, con una lista de sitios de confianza que sí usan JIT. Es el mismo modelo que Edge.
   Chromium 116 ya lo trae: ajuste de contenido `JAVASCRIPT_JIT` (renderers jitless por sitio vía
   `IsJitDisabledForSite`) y políticas `DefaultJavaScriptJitSetting` / `JavaScriptJitAllowedForSites` (Chrome 93+).
   - El parche en `brave-core` solo cambia el valor por defecto a BLOCK (rama `nube/jitless`).
   - La lista de permitidos va en `FlyWeb/policies/flyweb-policies.mobileconfig` (perfil de macOS). Hay que
     verificarla en `brave://policy`. Chromium 116 no tiene interfaz para esta lista.
   - Motivo: cerca del 45 % de los CVE de V8 estaban en el JIT (Microsoft Browser Vulnerability Research,
     "Super Duper Secure Mode", 2021).
   - Coste: rendimiento de JS y **sin WebAssembly**. Medir en claude.ai, Gmail, **Docs, Sheets y Drive**.
   - **Realidad según el triaje** (`docs/cve-triage.md`): de los 25 CVE explotados desde 116, jitless solo mitiga
     con seguridad 4. Hay 13 que no mitiga y 8 inciertos. Es una capa útil, pero no sustituye al portado.
   - **Desactivar WebGPU por defecto:** quita una fuga del sandbox explotada (CVE-2026-5281, Dawn) sin portar nada.
2. Mantener el aislamiento de sitios estricto (site isolation) y el sandbox del renderer tal cual.
3. **Triaje inicial:** lista de todos los CVE posteriores a 116 con "exploit in the wild" (Chrome Releases), por
   componente. Marcar cuáles mitiga jitless. **Las fugas del sandbox (Mojo/IPC) no se mitigan con jitless** y
   tienen prioridad para la Fase 3B.
   - Ya incluido en la base: libwebp CVE-2023-4863, corregido en 116.0.5845.187.

4. **Adelantar a esta fase las 4 fugas del sandbox que aplican a macOS**, porque jitless no mitiga ninguna:
   CVE-2025-6558 (ANGLE/GPU), CVE-2024-4671 (viz), CVE-2023-6345 (Skia) y CVE-2026-5281 (Dawn, cubierta con WebGPU
   desactivado). Y comprobar si `third_party/libvpx` ya lleva el arreglo de CVE-2023-5217.

**Hito:** jitless activo con lista de sitios de confianza, WebGPU desactivado, las fugas del sandbox de macOS
portadas y el documento de triaje (`docs/cve-triage.md`) hecho.

## Fase 4 — Compatibilidad web

1. **Diagnóstico por sitio:** clasificar cada fallo como bloqueo por versión declarada (UA / Client Hints), JS
   ausente o CSS ausente.
2. **Versión declarada configurable por sitio**, no global. Es probablemente lo primero que haga falta: Gmail
   avisa de navegador antiguo y la vista HTML básica ya no existe (Google la retiró en 2024).
3. **JS ausente:** polyfills inyectados **en el mundo principal de la página** (un content script normal corre en
   un mundo aislado y no sirve). Hay que tener en cuenta la CSP de cada sitio.
4. **CSS ausente:** no admite polyfill razonable. Se anota como deuda para la Fase 6.
5. **Medición:** subconjunto de web-platform-tests frente a Baseline "widely available".

**Hito:** claude.ai, Gmail, Drive y Workspace funcionan por completo, y hay una lista priorizada de huecos.

## Fase 2 — Servidor de componentes propio

Endpoints en lamosquita.net con protocolo Omaha / component updater. Evaluar primero si el go-updater de Brave
es código abierto y reutilizable (`brave/go-update`, **sin verificar**) antes de escribir un servidor.

| Componente | Estrategia |
|---|---|
| CRLSet, lista de logs de CT, Chrome Root Store | **Espejo sin modificar** de los CRX firmados por Google. Conservan su firma y no hay que tocar hashes. |
| Listas de adblock | CRX propios firmados con tu clave. Hay que sustituir el hash de la clave pública en `brave-core` para cada componente. |
| Actualizaciones del navegador | Sparkle con appcast propio y clave EdDSA propia. Requiere la app firmada y notarizada (Fase 0.5). |

- Sincronización diaria de los componentes de Google desde el servidor.
- EasyList, EasyPrivacy y uBO: mantener atribución y licencias (GPL-3.0 / CC BY-SA) en el servidor y en `about:credits`.

**Hito:** `brave://components` se actualiza desde tus endpoints, una actualización de prueba se instala por
Sparkle, y la auditoría de red ya no muestra ningún destino de Brave.

## Fase 3B — Portado de parches de seguridad

1. Portar primero las librerías de terceros (libvpx, libxml, freetype…): sus parches suelen aplicarse limpios.
2. Después las **fugas del sandbox** y los fallos de V8 explotados activamente que no mitigue jitless.
3. Si un parche depende de una refactorización imposible de portar, documentarlo como mitigado o como riesgo
   aceptado.
4. Un parche por CVE, con referencia al CVE, al bug de Chromium y al commit de origen.
5. Expectativa realista: son varias decenas de fallos explotados, muchos en V8 y tras tres años de cambios. No
   todos serán portables. Eso alimenta la decisión de la Fase 6.

**Hito:** cada CVE con exploit en la práctica está portado, mitigado o aceptado explícitamente.

## Fase 5 — Multimedia y GPU

1. Códecs: Brave ya compila con `proprietary_codecs=true` y `ffmpeg_branding="Chrome"` (`config.js:301`).
   **Aviso legal:** distribuir binarios con decodificador H.264 puede requerir licencias de patentes. Para uso
   propio no es problema.
2. Decodificación por hardware con VideoToolbox: verificar en `chrome://gpu` y `chrome://media-internals` en la
   6,1 y en la 5,1.
3. **Backend de ANGLE:** comparar OpenGL y Metal en las FirePro D300/D500/D700 de la 6,1 y en la GPU de la 5,1.
   Fijar el backend por defecto según la GPU detectada.
4. OpenCL: Chromium no lo usa. No invertir en él sin un caso concreto medible.

**Hito:** tabla de rendimiento por máquina y backend, con el backend por defecto decidido.

## Fase 6 — Punto de decisión: rebase

Cuando el coste de portar parches supere el de un rebase (estimación: tras 2–3 ciclos de la Fase 3B):

1. Evaluar Brave y Chromium más recientes con los shims de Mojave de Chromium Legacy (requiere SDK 14+ y
   clang 18+, disponibles en la MacPro7,1).
2. Condición de paso: la versión nueva cumple el criterio de aceptación en Mojave, en la 6,1 y en la 5,1.
3. Desde el principio, todos los cambios propios van como sobrescrituras en `chromium_src/` y parches mínimos,
   para que el rebase sea mecánico.

## Fase 7 — Interfaz

Solo mediante el patrón `chromium_src/` y recursos propios. Nada de parches amplios en archivos de Chromium.

---

## Ciclo continuo de mantenimiento

Cadencia: **cada 8 semanas**, con un ciclo urgente solo cuando aparezca un "exploit in the wild" que no mitigue
jitless. Cuatro semanas no es sostenible para una sola persona.

1. **Vigilar:** Chrome Releases, notas de versión de Brave, CVE de Chromium.
2. **Triar:** ¿afecta a 116? ¿Hay exploit en la práctica? ¿El parche se aplica limpio? ¿Lo mitiga jitless?
3. **Portar:** un commit por parche, con su referencia.
4. **Compilar:** incremental en la MacPro7,1.
5. **Probar** (checklist fijo en la 6,1 y en la 5,1; automatizar lo posible):
   - Arranque.
   - claude.ai, Gmail, Drive, Workspace.
   - Sede con certificado FNMT.
   - Vídeo H.264.
   - Adblock activo.
   - Script de auditoría de red.
6. **Publicar:**
   - Tag.
   - Binario firmado y notarizado, y appcast de Sparkle.
   - Commit de código fuente enlazado (obligación MPL).
   - `about:credits` actualizado.
7. **Componentes** (independiente del ciclo): sincronización diaria de CRLSet, CT y Root Store. Listas de adblock
   según su propia frecuencia.
