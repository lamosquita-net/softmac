# softmac — contexto para Claude

Monorepo de software para Macs obsoletos de lamosquita.net. Idioma de trabajo: español; commits en inglés.

## Reglas fijas
- Objetivo garantizado: **macOS 10.14 Mojave, Intel, solo x86_64**. Monterey "debería" funcionar, sin garantía.
- Un software por carpeta; **cada uno con su propia licencia** heredada del origen. La raíz es MIT.
- Nada de binarios que exijan AVX (la MacPro5,1 no lo tiene).

## Máquinas
- **MacPro7,1** (macOS 15 Sequoia, Xcode 26.3): host de compilación principal.
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

`src/brave` del checkout de compilación será un `git worktree` de `~/proyectos/softmac/FlyWeb/brave-core.git`,
de modo que los commits se ven en los dos sitios sin push/pull.

## Proyectos
### BackupDrive/
- rclone **v1.67.0** (MIT) como `git subtree --squash` en `BackupDrive/rclone/`: es la última versión
  compatible con **Go 1.20**, la última versión de Go que funciona en Mojave. No subir de v1.67.x.
- Compilar: `BackupDrive/scripts/build-macos.sh` (exige Go 1.20.x). CI: `.github/workflows/backupdrive.yml`.
- Siguiente: probar `bisync` con Google Drive en Mojave → renombrar a `backupdrive` → launchd → app Cocoa de barra de menú.

### FlyWeb/ (navegador)
- Base: **Brave 1.57.64** = Chromium **116.0.5845.188**, la última versión con soporte oficial en 10.13/10.14.
- Forks: `lamosquita-net/brave-core` y `lamosquita-net/brave-browser`, rama `flyweb` desde el tag `v1.57.64`.
- Checkout de compilación fuera de este repo: `~/proyectos/flyweb/brave-browser` (100–150 GB).
- Compilar con **Xcode 14.3 / SDK macOS 13.3** (oficial de Chromium 116). En la 7,1: extraer
  `MacOSX13.3.sdk` de Xcode 14.3.1 y pasarlo con `mac_sdk_path`; no usar el SDK 26.
- Obligaciones: MPL-2.0 (publicar los ficheros de Brave modificados), `about:credits`, **quitar la marca
  Brave** (nombre, iconos, bundle id `net.lamosquita.flyweb`, servicios de Brave).
- Riesgo asumido: Chromium de 2023 → aplicar parches de seguridad poco a poco.
- Criterio de aceptación: claude.ai funciona por completo.

### Cliente Claude
- Descartado un cliente propio con cuentas Pro/Max: los términos de Anthropic (feb. 2026) solo
  permiten esas credenciales en Claude Code y claude.ai. Claude Code exige macOS 13 o superior.
- Vía elegida: claude.ai dentro de FlyWeb.

## Iconos
SVG maestro de 1024×1024 (o PNG transparente) en `<Proyecto>/branding/`; de ahí se genera `.icns` con `iconutil`.
