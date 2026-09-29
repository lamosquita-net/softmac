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

- Antes de la primera sincronización, **autodiagnóstico** (solo lectura): `scripts/mojave-selftest.sh`. Comprueba
  la versión de macOS, que el binario arranca y no exige un macOS más nuevo, TLS con Google (certificados de
  Mojave), la hora del sistema (OAuth falla si está desfasada), el token de cada remoto, los perfiles y launchd.
- Log: `~/Library/Logs/BackupDrive/backupdrive.log`.
- Estado para la futura app de barra de menús: `"$APP/status.json"`, con el estado (`running`/`idle`), el
  resultado (`ok`/`error`/`interrupted`) y el detalle por perfil. Se escribe de forma atómica.
- Nunca se solapan dos ejecuciones: si launchd lanza una mientras otra sigue en marcha, la nueva sale sin hacer
  nada. Si falla algún perfil, aparece una notificación de macOS (`BACKUPDRIVE_NOTIFY=0` para desactivarla).
- Filtros opcionales comunes a todos los perfiles: `"$APP/filters.txt"`, con la
  [sintaxis de rclone](https://rclone.org/filtering/). Por ejemplo, `- .DS_Store` y `- *.tmp`.
- Conflictos: gana la versión más reciente y la otra se conserva con sufijo numerado
  (`--conflict-resolve newer --conflict-loser num`).
- Los documentos nativos de Google (Docs, Sheets) se ignoran (`--drive-skip-gdocs`).
- En Monterey, si una carpeta protegida da "Operation not permitted", hay que dar a `/bin/sh`
  acceso total al disco. En Mojave, `~/Documents` no está protegido.
- Probado con dos carpetas locales (altas, cambios y borrados en ambos sentidos). **Falta probarlo
  contra Google Drive real en Mojave.**

## App de barra de menús

`app/` es una app mínima en Objective-C (`main.m`, sin proyecto de Xcode) que **no sincroniza por sí
misma**: enseña el estado que deja `backupdrive-sync.sh` en `status.json` y controla el motor.

- Icono en la barra de menús: normal, sincronizando o con error (imágenes *template*, se adaptan al modo oscuro).
- Menú: resumen de la última sincronización, cada perfil con ✓/✗ (clic: abre la carpeta local),
  **Sincronizar ahora** (lanza `/usr/local/bin/backupdrive-sync.sh`; su bloqueo evita solapes con launchd),
  **Sincronizar cada hora** (carga o descarga el LaunchAgent con `launchctl -w`), ver el registro en Consola
  y abrir la carpeta de configuración.
- Sin icono en el Dock (`LSUIElement`). Para que arranque sola: Preferencias del Sistema > Usuarios y grupos >
  Ítems de inicio.

```sh
BackupDrive/app/build-app.sh      # build/BackupDrive.app; basta con las herramientas de línea de comandos de Xcode 11
cp -R BackupDrive/build/BackupDrive.app /Applications/
```

La CI la compila en macOS (artefacto `backupdrive-menubar-app`) como x86_64 para 10.14, y falla si el
código usa alguna API posterior a 10.14. La firma es *ad hoc*: la primera vez, abrirla con clic derecho > Abrir.
Los PNG de `app/Resources` salen de los SVG de `branding/` con `branding/render-icons.js` (Mojave no lee SVG).

## Actualizar la base de rclone

```sh
git subtree pull --prefix=BackupDrive/rclone https://github.com/rclone/rclone <tag> --squash
```

No pasar de v1.67.x mientras el objetivo sea Mojave (v1.68 exige Go 1.21).

## Hoja de ruta

1. Compilar y validar `bisync` con Google Drive en Mojave. ← estamos aquí
2. ~~Renombrar el binario y la versión (`backupdrive`), con perfiles.~~ Hecho.
3. ~~Programar ejecuciones con `launchd`.~~ Hecho (cada hora).
4. App Cocoa de barra de menú que controle el motor: primera versión en `app/` (falta probarla en Mojave).
