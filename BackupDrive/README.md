# BackupDrive

Backup bidireccional de carpetas locales con Google Drive para macOS 10.14 Mojave.

Punto de partida: [rclone](https://rclone.org) **v1.67.0**, importado en [`rclone/`](rclone/) como
`git subtree`. Es la última versión de rclone cuyo `go.mod` pide Go 1.20, la última versión de Go
que funciona en Mojave. La sincronización bidireccional es [`rclone bisync`](https://rclone.org/bisync/).

Licencia: MIT (ver [`LICENSE`](LICENSE) y el original [`rclone/COPYING`](rclone/COPYING)).

## Compilar (en el Mac)

```sh
cd BackupDrive
./scripts/build-macos.sh          # genera build/backupdrive (x86_64, macOS 10.14+)
./build/backupdrive version
```

También se puede descargar el binario ya compilado desde la CI: pestaña Actions, artefacto `backupdrive-darwin-amd64`.

## Instalar y programar

```sh
sudo cp build/backupdrive scripts/backupdrive-sync.sh /usr/local/bin/
APP="$HOME/Library/Application Support/BackupDrive"
mkdir -p "$APP"

# 1. Remoto de Google Drive (tipo "drive"), con tu propio client_id/client_secret de Google Cloud
backupdrive --config "$APP/backupdrive.conf" config

# 2. Perfiles: una línea por carpeta, "carpeta local|remoto:ruta"
echo "/Volumes/googledrive/clientes|gdrive:clientes" >> "$APP/profiles"

# 3. Primera sincronización: primero en simulación y después de verdad
backupdrive-sync.sh --resync --dry-run
backupdrive-sync.sh --resync

# 4. Ejecución automática cada hora
cp launchd/net.lamosquita.backupdrive.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/net.lamosquita.backupdrive.plist
```

- Log: `~/Library/Logs/BackupDrive/backupdrive.log`.
- Filtros opcionales comunes a todos los perfiles: `"$APP/filters.txt"`, con la
  [sintaxis de rclone](https://rclone.org/filtering/). Por ejemplo, `- .DS_Store` y `- *.tmp`.
- Conflictos: gana la versión más reciente y la otra se conserva con sufijo numerado
  (`--conflict-resolve newer --conflict-loser num`).
- Los documentos nativos de Google (Docs, Sheets) se ignoran (`--drive-skip-gdocs`).
- En Monterey, si una carpeta protegida da "Operation not permitted", hay que dar a `/bin/sh`
  acceso total al disco. En Mojave, `~/Documents` no está protegido.
- Probado con dos carpetas locales (altas, cambios y borrados en ambos sentidos). **Falta probarlo
  contra Google Drive real en Mojave.**

## Actualizar la base de rclone

```sh
git subtree pull --prefix=BackupDrive/rclone https://github.com/rclone/rclone <tag> --squash
```

No pasar de v1.67.x mientras el objetivo sea Mojave (v1.68 exige Go 1.21).

## Hoja de ruta

1. Compilar y validar `bisync` con Google Drive en Mojave. ← estamos aquí
2. ~~Renombrar el binario y la versión (`backupdrive`), con perfiles.~~ Hecho.
3. ~~Programar ejecuciones con `launchd`.~~ Hecho (cada hora).
4. App Cocoa de barra de menú (Xcode 11, Swift 5.1 / Objective-C) que controle el motor.
