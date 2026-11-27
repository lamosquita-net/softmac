# Versión de producto que sube en cada publicación (aviso de reiniciar en Linux)

MOTOR-47, 27-11-2026, por encargo de COORDINACIÓN-66 (`…-aviso-reiniciar-linux.md`; visto por D8-LINUX-6 con la 3.2.2-51).
**Sin compilar.** Va en la próxima versión de Mac y Linux. El número lo decide Titín.

## Causa

- En Linux, `UpgradeDetectorImpl` ejecuta el binario instalado con `--product-version`
  (`get_installed_version_linux.cc`) y lo compara con `version_info::GetVersion()` (`InstalledVersionPoller`):
  - si es mayor, avisa de reiniciar;
  - si es igual, no hace nada;
  - si es menor, lo trata como *rollback*.
- La versión de producto sale de `src/chrome/VERSION`. `apply_patches` la reescribe con la de Brave
  (`updateChromeVersion.js`: `MAJOR` de Chromium y `MINOR.BUILD.PATCH` = 1.98.63). Por eso todas las publicaciones de FlyWeb
  dicen **156.1.98.63**, y la -50 y la -51 eran iguales.

## Propuesta (este parche)

- En una compilación publicada (`FLYWEB_BUILD_NUMBER` en el entorno), `apply_patches` escribe **`156.1.99.N`**, con
  N = `FLYWEB_BUILD_NUMBER`, el mismo N de `CFBundleVersion` 198.63.N y de la revisión `-N` del `.deb`.
  - `BUILD=99` la pone por encima de todas las 156.1.98.x ya instaladas.
  - N sube en cada publicación (regla de siempre).
  - Sin la variable (desarrollo), sigue la de Brave.
- `checkVersionsMatch` espera ese valor y no avisa en falso.
- **Seguro en `BUILD.gn`:** si `flyweb_build_number > 0` y `chrome/VERSION` no es `x.1.99.N` con la misma N, `gn gen` se para.
  Así no se puede publicar con la versión vieja por olvido.
- **`flyweb-release.sh`** pasa `FLYWEB_BUILD_NUMBER="$BUILD"` a `npm run apply_patches`. `build.sh` ya lo hereda, porque la
  variable se le da en la línea de órdenes.
- **Número en la próxima:** `156.1.99.<N de la próxima>`. La -51 usó 51, así que la próxima será ≥ 52: con 52, `156.1.99.52`.

## Lo declarado a las webs y la huella: no cambia

- **UA:** `Chrome/<nivel>.0.0.0`, del nivel de motor (`patches/components-version_info-version_info_with_user_agent.cc.patch`).
- **Client Hints / `userAgentData`:** `uaFullVersion` y `fullVersionList` salen de `flyweb_engine_full_version`
  (156.0.8078.82). El mayor, del nivel.
- **Safe Browsing:** `FlyWebDeclaredVersionNumber`. **DIAL:** `GetBraveChromiumVersionNumber`.
- **`flyweb://version`, Acerca de y `crashes`:** `GetBraveVersionNumberForDisplay` → «3.2.x (motor 156)».
- **Lo que sí llevará el número nuevo:** peticiones a servicios, no a webs, que mandan `prodversion` (componentes de nuestro
  `components.flyweb…` y, si alguien instala extensiones de la Chrome Web Store, la consulta de actualizaciones a Google).
  Hoy ya mandan 156.1.98.63, que tampoco es de Chrome, así que la huella ante Google no cambia de clase.
  **Para SERVIDOR:** que nuestro servidor de componentes no filtre por `prodversion`.
  **Prueba propuesta a LOCAL:** `net-export` de una sesión normal y buscar `156.1.9` en el registro. No debe aparecer en
  ninguna petición a una web.

## Mac

- **Sparkle:** compara `CFBundleVersion` = `flyweb_bundle_version_base.N` = 198.63.N (`tweak_info_plist.py`, base
  congelada), que no depende de `chrome/VERSION`. `CFBundleShortVersionString` = `flyweb_version`. No cambia nada.
- **El *framework*:** pasa a `FlyWeb Framework.framework/Versions/156.1.99.N/`, un nombre distinto en cada versión, como en
  Chrome. Los guiones no lo tienen escrito a mano: `firmar-flyweb.sh` usa `Versions/[0-9]*` y `flyweb-release.sh` usa
  `Versions/Current`.
  **Para PUBLICACIÓN/LOCAL:** si alguna nota o guion fuera del repo tiene `156.1.98.63` escrito, hay que cambiarlo.
- **Aviso de reiniciar en Mac:** no existe por esta vía. En Mac no hay `InstalledVersionPoller` útil: actualiza Sparkle.

## Perfil

- **`Last Version`** (`DowngradeManager`, activo en Mac y Linux, `enable_downgrade_processing = !is_android && !is_chromeos`):
  - pasará de 156.1.98.63 a 156.1.99.N;
  - es una subida dentro del mismo *milestone*, así que **no** hace copia ni migración (solo hace copias en Canary o al
    cambiar de *milestone*).
  - **Bajar de versión** (instalar una anterior a mano) sí sería un *downgrade* para Chromium: pasaría por
    `GetDowngradeType`, que sin política de empresa queda en «no soportado», sin borrar nada. Hoy no se nota porque todas
    eran iguales. Por eso N no debe bajar nunca, como ya pasa con `CFBundleVersion`.
- **Extensiones:** al cambiar la versión, Chromium hace la comprobación de «después de actualizar» (`kLastChromeVersion`),
  como en cada actualización de Chrome. No toca datos.
- **Cachés:** algunas cachés por versión (GPU) se regenerarán tras cada actualización, como en Chrome. `kFlyWebCacheEpoch`
  sigue haciendo falta para recompilaciones con el mismo N.
- **Aplicaciones web instaladas (Mac):** sus lanzadores apuntan al *framework* versionado. Chromium los regenera tras
  actualizar, como en Chrome; el primer arranque puede tardar un momento.

## Base y árboles

brave-core `local/322-final` = **060015a802** (ls-remote del 27-11), árbol `fbdf05a0d3`. Con `git am`, árbol **`1c81ab4a48`**
(comprobado). Toca `BUILD.gn` y `build/commands/lib/{updateChromeVersion,build}.js`; no comparte ficheros con los demás
parches de la tanda.

**Probado aquí:**
- `updateChromeVersion()` sobre un `chrome/VERSION` de prueba con `FLYWEB_BUILD_NUMBER=52` da `MAJOR=156 MINOR=1 BUILD=99 PATCH=52`;
- sin la variable, 1.98.63;
- con un valor no numérico, se para.

## Qué deben comprobar D8 (Linux) y LOCAL (Mac)

1. **Linux:**
   - con la N nueva, `flyweb --product-version` debe dar `156.1.99.N`;
   - con la anterior abierta, `unattended-upgrade` instala la nueva y, en unos minutos (el sondeo es periódico), sale el aviso de
     reiniciar en el menú;
   - **la primera vez** (de 156.1.98.63 a 156.1.99.N) también debe salir.
2. **Mac:**
   - `CFBundleVersion` = 198.63.N y `CFBundleShortVersionString` sin cambios;
   - el *framework* en `Versions/156.1.99.N`;
   - Sparkle ofrece la actualización desde la anterior;
   - firma y notarización bien.
3. **Las dos:**
   - UA y `navigator.userAgentData.getHighEntropyValues(['fullVersionList'])` iguales que antes;
   - `flyweb://version` igual;
   - el perfil abre sin copias ni avisos.

## Ficheros

- `0001-version-product-version-156.1.99.N-in-published-buil.patch` (`git format-patch --full-index`).
- `SHA256SUMS`.
- Además, en este PR: `FlyWeb/tools/release-3x/flyweb-release.sh` (pasa `FLYWEB_BUILD_NUMBER` a `apply_patches`).
