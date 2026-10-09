# softmac — contexto para Claude

Monorepo de software para Macs obsoletos de lamosquita.net. Idioma de trabajo: español; commits en inglés.

## Reglas fijas
- **Datos personales del HUMANO, NUNCA en GitHub** (decisión del HUMANO, 09-10-2026; por encima de cualquier otra regla):
  nombre, NIF, domicilio, teléfono, documentos o cualquier dato que lo identifique no van en el repo (es **público e
  indexado**), ni en ramas, commits, mensajes de commit, PR, comentarios o el tablero. Se pasan solo por `send_message`
  al agente que los necesita y viven fuera del repo (p. ej. una imagen que SERVIDOR-LOCAL instala en el servidor).
  **Antes de mover cualquier dato personal, decirle al HUMANO por dónde va a pasar y dónde va a quedar.** Si alguno
  llega a GitHub por error: avisarle enseguida, reescribir la rama y preparar la petición a GitHub Support.
- Objetivo garantizado: **macOS 10.14 Mojave, Intel, solo x86_64**. Monterey "debería" funcionar, sin garantía.
- Un software por carpeta; **cada uno con su propia licencia** heredada del origen. La raíz es MIT.
- Nada de binarios que exijan AVX (la MacPro5,1 no lo tiene).

## Trabajo en paralelo
Agentes en la nube (VIGÍA, COORDINACIÓN, MOTOR, SEGURIDAD-VIGÍA, SEGURIDAD-PORTES, CONTENIDOS-WEB) y en la 7,1
(LOCAL compila, PUBLICACIÓN publica, SERVIDOR-LOCAL opera ns1/ns2, ARQUITECTURA decide), más el humano. Modelo y
reparto de cada uno en la tabla de `docs/TAREAS.md`. **Leer `docs/TAREAS.md` al empezar**: reparto, ramas y reglas.
Hoja de ruta de FlyWeb: `FlyWeb/docs/hoja-de-ruta.md`.

## Máquinas
- **MacPro7,1** (macOS 15 Sequoia, Xcode 26.3, 16 núcleos / 32 hilos, 96 GB, SSD 2 TB): host de compilación principal.
- **MacPro6,1** (Mojave, Xcode 11.3.1, 64 GB): compilación y pruebas en Mojave.
- **MacPro5,1** (Mojave, 48 GB, sin AVX): pruebas de "peor caso", en el estudio.

## Estructura en disco (MacPro7,1)
Los metadatos de git van en el disco local; los ficheros de trabajo, en la red (Samba, que se
sincroniza con Google Drive y más adelante con BackupDrive). Se monta con `git clone --separate-git-dir`.

| Qué | Git (local) | Ficheros de trabajo (red) |
|---|---|---|
| softmac | `~/proyectos/softmac/softmac.git` | `/Volumes/googledrive/clientes/software/softmac/` |
| brave-browser (fork) | `~/proyectos/softmac/FlyWeb/brave-browser.git` | `…/softmac/FlyWeb/brave-browser/` |
| brave-core (fork) | `~/proyectos/softmac/FlyWeb/brave-core.git` | `…/softmac/FlyWeb/brave-core/` |
| Checkout y compilación de Chromium | **local**: `~/proyectos/flyweb-build/` | — (no se sincroniza; se regenera desde los forks) |

Flujo de FlyWeb: se edita y se hace commit en la red (rama `flyweb`). En el checkout de compilación,
`brave-browser` es un worktree *detached* del `.git` local y `src/brave` es un **clon `--shared`** del
`.git` local de brave-core (no un worktree: gclient solo reconoce carpetas `.git` reales).
`FlyWeb/scripts/build.sh` hace `fetch` local y los pone en el último commit de `flyweb`. Solo se compila lo
que tiene commit. **Nunca `gclient sync -D`** en `flyweb-build` (borró el worktree antiguo).

## Proyectos
### BackupDrive/
- rclone **v1.67.0** (MIT) como `git subtree --squash` en `BackupDrive/rclone/`: es la última versión
  compatible con **Go 1.20**, la última versión de Go que funciona en Mojave. No subir de v1.67.x.
- Compilar: `BackupDrive/scripts/build-macos.sh` → `build/backupdrive` (exige Go 1.20.x). CI: `.github/workflows/backupdrive.yml`.
- `scripts/backupdrive-sync.sh`: lanza bisync para cada perfil de `~/Library/Application Support/BackupDrive/profiles`;
  `launchd/net.lamosquita.backupdrive.plist` lo ejecuta cada hora.
- Siguiente: probar con Google Drive real en Mojave → app Cocoa de barra de menú.

### FlyWeb/ (navegador)
- Base: **Brave 1.57.64** = Chromium **116.0.5845.188**, la última versión con soporte oficial en 10.13/10.14.
- Forks: `lamosquita-net/brave-core` y `lamosquita-net/brave-browser`, rama `flyweb` desde el tag `v1.57.64`.
- Checkout de compilación: `~/proyectos/flyweb-build/` en local (100–150 GB). `FlyWeb/scripts/setup-build.sh`
  (una vez) y `FlyWeb/scripts/build.sh` (cada compilación; pasa `mac_sdk_path` y `symbol_level:0`).
- Compilar con **Xcode 14.3 / SDK macOS 13.3** (oficial de Chromium 116). En la 7,1: extraer
  `MacOSX13.3.sdk` de Xcode 14.3.1 y pasarlo con `mac_sdk_path`; no usar el SDK 26.
- Obligaciones: MPL-2.0 (publicar los ficheros de Brave modificados), `about:credits`, **quitar la marca
  Brave** (inventario en `FlyWeb/docs/rebranding.md`).
- **Identidad decidida (no cambiar sin migración):** empresa `lamosquita`, producto `FlyWeb`, bundle id
  `net.lamosquita.flyweb[.canal]`, Team ID `MQ3NJ73LC5`, perfil `~/Library/Application Support/LaMosquita/FlyWeb`,
  llavero `FlyWeb Safe Storage`. Aplicado en `brave-core` rama `flyweb`.
- Servicios: componentes desde nuestro servidor `components.flyweb.lamosquita.net` (ns2: Shields y datos locales
  propios firmados en bak, componentes de Google en espejo; `FlyWeb/servidor/`); News y Talk fuera; sync propio en
  `sync.flyweb.lamosquita.net` (`FlyWeb/servidor/sync`, go-sync con SQLite; cifrado de extremo a extremo); stats y variations
  con URL inertes; updater de Brave (Omaha), P3A, Leo y VPN desactivados (args en `build.sh`); actualizaciones con Sparkle desde `updates.flyweb.lamosquita.net`, firmadas en bak (`FlyWeb/servidor/actualizaciones`); Wallet y Rewards quitados
  en el código (brave-core `nube/no-wallet`); Safe Browsing estándar por política (`FlyWeb/policies/flyweb-policies.mobileconfig`;
  en 1.57 su arg rompe `gn gen`), a través del proxy propio `proxy.flyweb.lamosquita.net` en ns2: nada pasa por proxies de Brave.
- Pendiente de marca: cadenas de la interfaz con `script/chromium-rebase-l10n.py` (necesita el checkout de
  Chromium; no editar .grd/.xtb a mano: los ids de traducción son hashes del texto inglés), logotipos de NTP/welcome.
- **Motor (Fase M, `FlyWeb/docs/motor.md`):** la base sigue en 116, pero el motor crece por niveles de Chrome portando
  Blink/V8 función a función. Versión declarada a **todas** las webs = último nivel completo (sin excepciones por sitio);
  versión visible 1.N.x: N sigue al nivel (**1.1 = nivel 117**, 1.2 = 118…) y x cuenta las versiones con parches de
  seguridad sobre el último nivel publicado (1.1.1, 1.1.2…). Ambos en brave-core `build/config.gni`
  (`flyweb_engine_level`, `flyweb_version`); `FLYWEB_BUILD_NUMBER` sube en cada versión publicada (1.1 = 2). Un nivel
  se da por cumplido con `FlyWeb/tools/motor-N.html` en verde y las WPT de la N iguales a las del propio Chrome N.
- Riesgo asumido: Chromium de 2023 → aplicar parches de seguridad poco a poco.
- Criterio de aceptación: claude.ai funciona por completo.

### Cliente Claude
- Descartado un cliente propio con cuentas Pro/Max: los términos de Anthropic (feb. 2026) solo
  permiten esas credenciales en Claude Code y claude.ai. Claude Code exige macOS 13 o superior.
- Vía elegida: claude.ai dentro de FlyWeb.

## Iconos
SVG maestro de 1024×1024 (o PNG transparente) en `<Proyecto>/branding/`; de ahí se genera `.icns` con `iconutil`.
