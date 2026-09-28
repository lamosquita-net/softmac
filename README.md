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

**Cada software va con su propia licencia**, la que herede de su proyecto de origen (ver el
`LICENSE`/`COPYING` de cada carpeta). El [`LICENSE`](LICENSE) (MIT) de la raíz cubre solo el código
propio del repositorio que no esté en una carpeta con licencia propia (documentación, scripts comunes).

## Entorno de compilación

Ver [`docs/entorno-mojave.md`](docs/entorno-mojave.md).
