# softmac

Software para Macs que Apple ha dejado atrás, en un único repositorio.

- **Objetivo garantizado:** macOS 10.14 Mojave, Intel, solo 64 bits (x86_64).
- **Debería funcionar:** macOS 12 Monterey (sin garantía).

## Proyectos

| Carpeta | Qué es | Base | Licencia |
|---|---|---|---|
| [`BackupDrive/`](BackupDrive/) | Backup bidireccional con Google Drive | fork de [rclone](https://rclone.org) v1.67.0 (`bisync`) | MIT |
| [`FlyWeb/`](FlyWeb/) | Navegador para Mojave | fork de [Brave](https://github.com/brave/brave-core) 1.57.64 (Chromium 116) | MPL-2.0 (Brave) + BSD-3 y terceros (Chromium) |

## Licencias

**Cada software va con su propia licencia**, la que herede de su proyecto de origen:
[`BackupDrive/LICENSE`](BackupDrive/LICENSE) (MIT) y [`FlyWeb/LICENSE`](FlyWeb/LICENSE) (MPL-2.0). El [`LICENSE`](LICENSE) (MIT) de la raíz cubre solo el código
propio del repositorio que no esté en una carpeta con licencia propia (documentación, scripts comunes).

## Estructura de repos

- Este repositorio contiene BackupDrive completo (rclone incluido como subtree) y la documentación de FlyWeb.
- El código de FlyWeb vive en dos forks aparte, en la rama `flyweb`:
  [`lamosquita-net/brave-browser`](https://github.com/lamosquita-net/brave-browser) y
  [`lamosquita-net/brave-core`](https://github.com/lamosquita-net/brave-core). Se clonan dentro de
  `FlyWeb/`, que el `.gitignore` excluye (ver [`FlyWeb/README.md`](FlyWeb/README.md)).
- La disposición en disco (git en local, ficheros de trabajo en red) está en [`CLAUDE.md`](CLAUDE.md).

## Máquinas y entorno de compilación

Ver [`docs/entorno-mojave.md`](docs/entorno-mojave.md).
