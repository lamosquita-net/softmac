# BackupDrive

Copia de seguridad de carpetas locales con Google Drive para macOS 10.14 Mojave, con una regla: **nunca perder nada**.

Punto de partida: [rclone](https://rclone.org) **v1.67.0**, importado en [`rclone/`](rclone/) como
`git subtree`. Es la última versión de rclone cuyo `go.mod` pide Go 1.20, la última versión de Go
que funciona en Mojave. La sincronización es [`rclone bisync`](https://rclone.org/bisync/) configurado para no perder nada
(ver «Cómo funciona»).

Licencia: MIT (ver [`LICENSE`](LICENSE) y el original [`rclone/COPYING`](rclone/COPYING)).

## Cómo funciona (para Titín)

Cada hora, por cada carpeta: lo nuevo o cambiado en Drive baja al Mac y lo nuevo o cambiado en el Mac sube a Drive.
**Nunca se pierde nada:** lo que se borra o se sobrescribe se guarda en una carpeta de versiones y solo desaparece
cuando caduca (90 días).

| Si… | Pasa esto |
|---|---|
| **Borro un fichero en el Mac** | En Drive, su copia **se mueve a la carpeta de versiones** (no se borra de verdad) y no vuelve al Mac. Igual al revés. |
| **Edito un fichero en un sitio** | El cambio se copia al otro lado y la versión anterior de ese lado queda en versiones (`informe-20261026-103000.docx`). |
| **Edito el mismo fichero en los dos sitios** antes de la siguiente pasada | **Se conservan los dos**, con sufijo `conflict` en el nombre, en los dos lados. Tú decides con cuál te quedas. **No manda la fecha**: la fecha de Drive puede ser la de subida, y los relojes de los Mac no coinciden. |
| **Un Mac sube una copia vieja con fecha nueva** | Si el otro lado no había cambiado, la copia vieja se copia, pero la versión buena queda en versiones (recuperable 90 días). Si había cambiado, es un conflicto y se conservan las dos. |
| **La carpeta aparece vacía o desmontada** (disco externo) | BackupDrive se niega a sincronizar con un lado vacío y no toca nada. |
| **Borro muchos ficheros de golpe** (más del 10 %) | **Se detiene** sin tocar nada; el perfil sale con ⚠ y un aviso. Si es lo que quieres: `backupdrive-sync.sh --profile "/ruta" --dry-run` para ver qué pasaría y luego `--force`. |
| **Se pierde o se estropea el estado** (`bisync/`) | La pasada siguiente solo copia (lo que falta en un lado se copia; nada se borra) y avisa en el registro. |
| **Pasan 90 días** | Las versiones más viejas de 90 días se borran (por la fecha del nombre). Es lo único que BackupDrive borra de verdad, y solo dentro de las carpetas de versiones. |

**Dónde están las versiones** (misma estructura de carpetas que el original):
- Del lado del Mac: `~/Library/Application Support/BackupDrive/versions/<carpeta>-<número>/`.
- Del lado de Drive: una carpeta **al lado** de la sincronizada, `<carpeta> (versiones)` (p. ej. `Clientes (versiones)`).
  No puede estar dentro: bisync lo prohíbe. Por eso el perfil debe apuntar a una carpeta de Drive, no a la raíz.

**Cuántos días:** 90 por defecto. Tercera columna del perfil: `/ruta/local|gdrive:Carpeta|180`. Con `0` no caducan nunca.

**Cómo borrar de verdad en los dos lados:** borra el fichero en un lado (el otro se mueve a versiones) y después borra su
copia en las carpetas de versiones (o espera 90 días). Lo borrado en Drive va además a la papelera de Drive.

**Qué no hace:** no copia los documentos nativos de Google (Docs, Hojas, Presentaciones): no son ficheros, y
exportarlos a .docx/.xlsx crearía duplicados que luego se subirían de nuevo. Esos documentos viven solo en Drive; para
tener copia hay que descargarlos desde Drive («Descargar como…»). Tampoco sincroniza `.DS_Store` ni lo que pongas en `filters.txt`.

**Primera vez:** una carpeta nueva no se sincroniza sola. Primero la simulación (`--resync --dry-run`, no cambia nada y el
registro dice qué haría) y luego `--resync` (solo copia). Es el mismo botón «Primera sincronización» de la app. En esa
primera pasada, si un fichero es distinto en los dos lados no hay historia que consultar: gana el más reciente y el otro se
guarda en versiones.

### Detalles técnicos

- **Es `rclone bisync` 1.67 bien configurado, no un invento propio.** Comprobado que cubre lo pedido:
  `--compare size,modtime,checksum --slow-hash-sync-only` (cambio por lado contra la última pasada, por tamaño, fecha y
  hash; el hash local, que es lento, solo se calcula para lo que cambió; el MD5 de Drive es gratis),
  `--conflict-resolve none` (si cambiaron los dos y son distintos, se conservan los dos con sufijo),
  `--backup-dir1/--backup-dir2` + `--suffix -AAAAMMDD-HHMMSS --suffix-keep-extension` (borrado blando y versiones),
  `--max-delete 10` (freno) y `--resilient --recover`. El estado está en `bisync/` (`--workdir`), fuera de las carpetas.
- bisync se niega por sí solo a sincronizar con un lado vacío («Cannot sync to an empty directory»).
- **Estado perdido:** con el perfil ya iniciado, si bisync no encuentra sus listas el guion hace una pasada
  `--resync` (solo copia; el perdedor de un fichero distinto en los dos lados, el menos reciente, va a versiones).
- **Caducidad por el nombre, no por `--min-age`:** rclone conserva la fecha de modificación original al mover un
  fichero a versiones, así que `rclone delete --min-age 90d` borraría hoy la versión de un fichero viejo recién
  sobrescrito. Se lee la fecha del sufijo y solo se borra dentro de las carpetas de versiones; lo que no
  lleva fecha en el nombre no se toca. En Drive se borra de verdad (no a la papelera) para no gastar cuota.
- Límites: el freno es un porcentaje (bisync no tiene umbral absoluto); en una carpeta pequeña (menos de 10 ficheros)
  borrar uno solo ya lo activa y pide `--force`. Dos pasadas en el mismo segundo comparten sufijo. Drive permite dos
  ficheros con el mismo nombre en una carpeta y rclone se queja: hay que renombrar uno en Drive. Con `--compare` con
  hash, cambiar los ajustes exige un `--resync`.
- Pruebas: `BACKUPDRIVE_BIN=<rclone> BackupDrive/tests/test-sync-safe.sh` (remoto local de rclone, dos carpetas, sin
  Drive): primera sincronización, borrado deliberado en cada lado, editar en uno y en los dos, el caso de la 5,1,
  carpeta vacía, freno, estado perdido y caducidad. La CI las ejecuta.

## Compilar (en el Mac)

```sh
cd BackupDrive
./scripts/build-macos.sh          # genera build/backupdrive (x86_64, macOS 10.14+)
./build/backupdrive version
```

También se puede descargar el binario ya compilado desde la CI: pestaña Actions, artefacto `backupdrive-darwin-amd64`.

## Instalar (lo más fácil)

La CI genera un zip con todo (artefacto **`BackupDrive-mojave`**: binario, motor, autodiagnóstico,
LaunchAgent y app). En el Mac:

```sh
unzip BackupDrive-mojave.zip && cd BackupDrive
./install.sh              # pide la contraseña solo para /usr/local/bin
```

`install.sh` instala o actualiza sin tocar la configuración ni los perfiles, deja el LaunchAgent copiado pero
**sin activar** (la primera vez hay que hacer `--resync` a mano) e imprime los pasos siguientes.
`./install.sh --uninstall` lo quita todo menos la configuración y los registros. También funciona desde el
repositorio, tras compilar (`scripts/install.sh`).

## Instalar y programar a mano

```sh
sudo cp build/backupdrive scripts/backupdrive-sync.sh /usr/local/bin/
APP="$HOME/Library/Application Support/BackupDrive"
mkdir -p "$APP"

# 1. Remoto de Google Drive (tipo "drive"), con tu propio client_id/client_secret de Google Cloud
backupdrive --config "$APP/backupdrive.conf" config

# 2. Perfiles: una línea por carpeta, "carpeta local|remoto:ruta[|días de versiones]"
echo "/ruta/de/mi/carpeta|gdrive:MiCarpeta" >> "$APP/profiles"

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
- Conflictos, borrados y primera sincronización: ver «Cómo funciona».
- Registro rotado: al pasar de 5 MB se guarda como `.1` (hasta `.4`).
- Un solo perfil: `backupdrive-sync.sh --profile "/ruta/local"` (con o sin `--resync`/`--dry-run`).
- Cada perfil guarda su último resultado en `"$APP/state/"`, y `status.json` los lista todos : `ok`, `error`,
  `skipped` (carpeta inexistente o línea incompleta), `blocked` (frenado por borrados masivos), `needs-resync` (falta la primera sincronización,
  con su propio aviso) o `never`.
- Los documentos nativos de Google (Docs, Sheets) se ignoran (`--drive-skip-gdocs`): ver «Qué no hace».
- En Monterey, si una carpeta protegida da "Operation not permitted", hay que dar a `/bin/sh`
  acceso total al disco. En Mojave, `~/Documents` no está protegido.
- Probado con un remoto local de rclone (altas, cambios, borrados, conflictos y caducidad; ver `tests/`). **Falta probarlo
  contra Google Drive real en Mojave.**

## App de barra de menús

`app/` es una app mínima en Objective-C (`main.m`, sin proyecto de Xcode) que **no sincroniza por sí
misma**: enseña el estado que deja `backupdrive-sync.sh` en `status.json` y controla el motor.

- Icono en la barra de menús: normal, sincronizando o con error (imágenes *template*, se adaptan al modo oscuro).
- Menú: resumen de la última sincronización; cada perfil con ✓ / ✗ / ⚠ (falta la primera sincronización) /
  ○ (nunca ejecutado) y un submenú para abrir la carpeta, ver el error o hacer la **primera sincronización**
  (primero simulada; después la real, con confirmación);
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

1. Validar la sincronización segura con Google Drive en Mojave. ← estamos aquí
2. ~~Renombrar el binario y la versión (`backupdrive`), con perfiles.~~ Hecho.
3. ~~Programar ejecuciones con `launchd`.~~ Hecho (cada hora).
4. App Cocoa de barra de menú que controle el motor: primera versión en `app/` (falta probarla en Mojave).
