# BackupDrive

Backup bidireccional de carpetas locales con Google Drive para macOS 10.14 Mojave.

Punto de partida: [rclone](https://rclone.org) **v1.67.0**, importado en [`rclone/`](rclone/) como
`git subtree`. Es la última versión de rclone cuyo `go.mod` pide Go 1.20, la última versión de Go
que funciona en Mojave. La sincronización bidireccional es [`rclone bisync`](https://rclone.org/bisync/).

Licencia: MIT (ver [`LICENSE`](LICENSE) y el original [`rclone/COPYING`](rclone/COPYING)).

## Compilar (en el Mac)

```sh
cd BackupDrive
./scripts/build-macos.sh          # genera build/rclone (x86_64, macOS 10.14+)
./build/rclone version
```

## Primera prueba con Google Drive

```sh
./build/rclone config             # crear remoto "gdrive" (tipo drive)
./build/rclone bisync ~/Documentos/BackupDrive gdrive:BackupDrive --resync --dry-run
```

Crea tu propio OAuth client ID en Google Cloud Console (`client_id`/`client_secret` en
`rclone config`). El ID compartido de rclone tiene límites de cuota bajos.

## Actualizar la base de rclone

```sh
git subtree pull --prefix=BackupDrive/rclone https://github.com/rclone/rclone <tag> --squash
```

No pasar de v1.67.x mientras el objetivo sea Mojave (v1.68 exige Go 1.21).

## Hoja de ruta

1. Compilar y validar `bisync` con Google Drive en Mojave. ← estamos aquí
2. Renombrar el binario y la versión (`backupdrive`), con perfiles predefinidos.
3. Programar ejecuciones con `launchd`.
4. App Cocoa de barra de menú (Xcode 11, Swift 5.1 / Objective-C) que controle el motor.
