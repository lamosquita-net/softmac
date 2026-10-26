# BackupDrive

Copia de seguridad de carpetas locales con Google Drive para macOS 10.14 Mojave, con una regla: **nunca perder nada**.

Punto de partida: [rclone](https://rclone.org) **v1.67.0**, importado en [`rclone/`](rclone/) como
`git subtree`. Es la última versión de rclone cuyo `go.mod` pide Go 1.20, la última versión de Go
que funciona en Mojave. La sincronización normal son dos pasadas de [`rclone copy`](https://rclone.org/commands/rclone_copy/)
(modo seguro, ver abajo); [`rclone bisync`](https://rclone.org/bisync/) queda solo como opción avanzada.

Licencia: MIT (ver [`LICENSE`](LICENSE) y el original [`rclone/COPYING`](rclone/COPYING)).

## Cómo funciona (para Titín)

**Modo seguro (el de siempre, salvo que digas lo contrario).** Cada hora, por cada carpeta: lo nuevo o cambiado en Drive
baja al Mac y lo nuevo o cambiado en el Mac sube a Drive. **BackupDrive nunca borra un fichero tuyo**, ni en el Mac ni en Drive.

| Si… | Pasa esto |
|---|---|
| **Borro un fichero en el Mac** | Sigue en Drive y **no vuelve a bajar** (así puedes liberar espacio en el Mac). |
| **Borro un fichero en Drive** | Sigue en el Mac y **no vuelve a subir**. |
| **Borro y luego alguien cambia el fichero en el otro lado** | Vuelve (hay algo nuevo que no quieres perder). |
| **Edito un fichero en un sitio** | Gana el cambio: se copia al otro lado. La versión anterior queda guardada (ver abajo). |
| **Edito el mismo fichero en los dos sitios** antes de la siguiente pasada | **Se conservan los dos.** El de Drive queda con el nombre de siempre y el del Mac se renombra «nombre (conflicto Mac 20261026-103000).ext» y también sube a Drive. Salta un aviso. Tú decides con cuál te quedas. |
| **Sobrescribo un fichero** | La versión anterior va a la carpeta de versiones, con la fecha en el nombre (`informe-20261026-103000.docx`). |
| **Pasan 90 días** | Las versiones más viejas de 90 días se borran (por la fecha del nombre). Es lo único que BackupDrive borra, y solo dentro de esas carpetas: la carpeta no crece sin fin. |

**Dónde están las versiones** (misma estructura de carpetas que el original):
- Del lado del Mac: `~/Library/Application Support/BackupDrive/versions/<carpeta>-<número>/` (fuera de tu carpeta).
- Del lado de Drive: carpeta oculta `.backupdrive-versions` dentro de la carpeta sincronizada en Drive. Nunca baja al Mac.

**Cuántos días:** por defecto 90. Tercera columna del perfil: `/ruta/local|gdrive:Carpeta|180`. Con `0` no caducan nunca.

**Cómo borrar de verdad en los dos lados:** como un borrado no se propaga, hay que borrar a mano en el Mac **y** en Drive
(web, o app de Drive). Si además quieres que no quede ninguna versión vieja, borra también su copia en las carpetas de
versiones (o espera a que caduque). Lo borrado en Drive va a la papelera de Drive 30 días.

**Qué no hace:** no copia los documentos nativos de Google (Docs, Hojas, Presentaciones): no son ficheros, y
exportarlos a .docx/.xlsx crearía duplicados que luego se subirían de nuevo. Esos documentos viven solo en Drive; para
tener copia hay que descargarlos desde Drive («Descargar como…»). Tampoco sincroniza `.DS_Store` ni lo que pongas en `filters.txt`.

**Primera vez:** una carpeta nueva no se sincroniza sola. Primero la simulación (`--resync --dry-run`, no cambia nada y el
registro dice qué haría) y luego `--resync`. Es el mismo botón «Primera sincronización» de la app.

**Modo avanzado «bisync» (cuarta columna: `…|gdrive:Carpeta|90|bisync`).** Mantiene las dos carpetas idénticas y **PROPAGA
LOS BORRADOS**: borrar en un lado borra en el otro (con papelera de Drive, nada más). Úsalo solo para una carpeta espejo
donde eso es lo que quieres.

### Detalles técnicos del modo seguro

- Dos pasadas por perfil: `rclone copy Drive→Mac` y `rclone copy Mac→Drive`, ambas con `--update` (gana el más
  reciente) y `--backup-dir <versiones> --suffix -AAAAMMDD-HHMMSS --suffix-keep-extension` (la versión sobrescrita se
  guarda). Nunca `sync`, `move` ni `--delete*`.
- **Caducidad por el nombre, no por `--min-age`:** rclone conserva la fecha de modificación original al mover un
  fichero a la carpeta de versiones, así que `rclone delete --min-age 90d` borraría hoy la versión de un fichero viejo
  recién sobrescrito. Se lee la fecha del sufijo y solo se borra dentro de las carpetas de versiones; lo que no
  lleva fecha en el nombre no se toca. En Drive se borra de verdad (no a la papelera) para no gastar cuota.
- **Conflictos y borrados** (rclone 1.67 no los distingue en `copy`): tras cada pasada correcta se guardan en
  `state/` las listas de ficheros de los dos lados (ruta, tamaño, fecha a segundos). En la siguiente, un fichero que
  cambió en los dos lados se renombra en el Mac; uno que falta en un lado y no cambió en el otro se excluye de las
  pasadas. Sin listas (primera vez) no hay conflictos ni borrados: gana el más reciente y la otra versión se guarda.
- Límites conocidos: dos pasadas en el mismo segundo comparten sufijo (una versión podría pisar a otra); un nombre de
  fichero con salto de línea o tabulador rompe las listas; Drive permite dos ficheros con el mismo nombre en una carpeta
  y rclone se queja («duplicate»): hay que renombrar uno en Drive.
- Pruebas: `BACKUPDRIVE_BIN=<rclone> BackupDrive/tests/test-sync-safe.sh` (remoto local de rclone, dos carpetas, sin
  Drive): primera sincronización, borrar en cada lado, editar en uno y en los dos, caducidad. La CI las ejecuta.

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

# 2. Perfiles: una línea por carpeta, "carpeta local|remoto:ruta[|días de versiones[|modo]]"
echo "/ruta/de/mi/carpeta|gdrive:MiCarpeta" >> "$APP/profiles"

# 3. Primera sincronización (modo seguro): primero en simulación y después de verdad
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
- Conflictos y primera sincronización: ver «Cómo funciona». Solo en modo `bisync`: gana la versión más reciente y la
  otra se conserva con sufijo numerado (`--conflict-resolve newer --conflict-loser num`); en su `--resync`, si un
  fichero difiere en los dos lados gana el más reciente y el otro **se sobrescribe sin copia**. Por eso: primero `--dry-run`.
- Registro rotado: al pasar de 5 MB se guarda como `.1` (hasta `.4`).
- Un solo perfil: `backupdrive-sync.sh --profile "/ruta/local"` (con o sin `--resync`/`--dry-run`).
- Cada perfil guarda su último resultado en `"$APP/state/"`, y `status.json` los lista todos (con su `mode`): `ok`, `error`,
  `skipped` (carpeta inexistente o línea incompleta), `needs-resync` (falta la primera sincronización,
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
  (primero simulada; después la real, con confirmación) y el modo del perfil (seguro / bisync);
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

1. Validar el modo seguro con Google Drive en Mojave. ← estamos aquí
2. ~~Renombrar el binario y la versión (`backupdrive`), con perfiles.~~ Hecho.
3. ~~Programar ejecuciones con `launchd`.~~ Hecho (cada hora).
4. App Cocoa de barra de menú que controle el motor: primera versión en `app/` (falta probarla en Mojave).
