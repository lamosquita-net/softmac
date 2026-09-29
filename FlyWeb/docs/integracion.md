# FlyWeb — Orden de integración de ramas (para LOCAL)

Las ramas `nube/*` de `lamosquita-net/brave-core` salen todas de `flyweb` 77b25c6b y **ninguna está compilada**.
Se integran **de una en una, compilando y probando entre cada una**. Así, si algo falla, se sabe qué rama lo
rompió. NUBE ha comprobado que las ocho se fusionan juntas sin conflictos (fusión de prueba).

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

Después del paso 8: F0.2 queda cerrada, y el `.app` se puede copiar a la 6,1 y la 5,1 para F0.6.

## Si un paso falla

- **4, parche que no aplica:** `npm run apply_patches` indica cuál. Revertir solo ese paso y avisar a NUBE con el
  mensaje de error. Los tres CVE van en commits separados dentro de la rama.
- **4, viz no compila:** el parche adaptado a mano puede necesitar un `#include` o tipos distintos en la 116.
  Pasar el error a NUBE.
- **`flyweb-rebrand-strings.py --check`** necesita `lxml`: `python3 -m pip install --user lxml` (no lo traen Chromium ni `.vpython3`). Es solo una comprobación; la compilación no lo necesita.
- **5, error de grit** (por ejemplo "message not found" o un id duplicado): pasar el error a NUBE. El script
  `script/flyweb-rebrand-strings.py --check` debe devolver 0 ficheros.
