# softmac

Software para Macs que Apple ha dejado atrás, en un único repositorio.

- **Objetivo garantizado:** macOS 10.14 Mojave, Intel, solo 64 bits (x86_64).
- **Debería funcionar:** macOS 12 Monterey (sin garantía).

## Proyectos

| Carpeta | Qué es | Base | Licencia |
|---|---|---|---|
| [`BackupDrive/`](BackupDrive/) | Backup bidireccional con Google Drive | fork de [rclone](https://rclone.org) v1.67.0 (`bisync`) | MIT |
| [`lamosquita-browser/`](lamosquita-browser/) | Navegador moderno para Mojave | parches sobre [Chromium Legacy](https://github.com/blueboxd/chromium-legacy) | BSD-3 y licencias de terceros de Chromium |

## Licencias

Cada carpeta conserva la licencia de su proyecto de origen (ver el `LICENSE`/`COPYING` de cada una).
El `LICENSE` (GPL-2.0) de la raíz se aplica solo al código propio de este repositorio que no esté
dentro de una carpeta con licencia propia.

## Entorno de compilación

Ver [`docs/entorno-mojave.md`](docs/entorno-mojave.md).
