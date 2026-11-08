# Pruebas de BackupDrive en la MacPro6,1 (MacTrash, Mojave 10.14.6)

BACKUPDRIVE-LOCAL-1, 07/08-11-2026, por ssh desde la 7,1. El código es de BACKUPDRIVE-3; aquí solo los resultados.
Rutas con `~` en lugar del usuario. Ni la clave de Google ni datos personales: la clave vive solo en
`~/.config/backupdrive/client_secret.json` (600) de la 7,1 y la 6,1 y en `backupdrive.conf` de la 6,1.

Artefactos `BackupDrive-mojave` probados:
- `37d0e785` (#719, ejecución 41683761099): pruebas 0, 1, h (primera parte) y 7.
- `9b86d0b9` (#851, ejecución 42410434552: secreto por entorno y selftest con 5 columnas): todo lo demás.

## Resumen

| Prueba | Resultado | Nota |
|---|---|---|
| 0. Instalar artefacto + `mojave-selftest.sh` | Sí | `install.sh` sin sudo (`/usr/local/bin` es del usuario); selftest «sin fallos». Con 37d0e785 avisaba de un remoto «`gdrive:X\|90\|20\|5`»: arreglado en 9b86d0b |
| 1. Clave propia (`connect`) | Sí | Con 9b86d0b el secreto no sale en `ps` (`pgrep -f client_secret=` = 0) y queda una sola línea `client_secret` en el conf (600) |
| h. Sincronización y LaunchAgent | Sí | Pasada a mano 8 s (31 ficheros); pasadas de launchd al cargar y cada hora (`StartInterval` 3600), `status.json` ok |
| 3. Carpeta grande | Sí, lenta | 7 233 ficheros / 734,5 MiB: primera sincronización 1 h 45 min; sin cambios: en seco 263 s, real 462 s |
| 4a. Freno de borrados | Sí | 14 % a la Papelera → `blocked`; devueltos → ok |
| 4b. Freno de modificaciones | Sí, lento | 25,7 % cambiados → `blocked` a los 36 min; Drive intacto |
| 5. Conflictos, versiones, ajustes | Parcial | `conflicts list` vacío y `keep` deja copias (sed de BSD); versiones y `profile set` bien |
| 6. App | Pendiente | Pantalla de la 6,1 bloqueada y apagada: sin capturas; necesita a Titín |
| 7. `test-ctl.sh` / `test-sync-safe.sh` con BSD | No / Sí | `test-ctl` 98/104 con `/bin/sh` y bash (los 6 de conflictos); `test-sync-safe` 53/53 |

## Fallos y observaciones (enviados a BACKUPDRIVE-3)

1. **`conflicts list` siempre `[]` en macOS** (`backupdrive-ctl.sh`, `conflict_rows`): el `sed` usa `\|` en una ER básica,
   extensión de GNU que el `sed` de BSD no entiende. Consecuencia: la app no enseña conflictos y `conflicts keep` no mueve
   a versiones las otras copias (queda `nombre.conflict1.ext`). Con `sed -E` y `(…|…)` funciona. La CI no lo ve.
2. **Simulación con la carpeta de Drive sin crear:** `--resync --dry-run` falla con «directory not found» y después `plan`
   devuelve todo a cero sin avisar. Con `backupdrive-ctl.sh mkdir` antes, bien (la app ya la crea al añadir).
3. **`plan` viejo tras un bloqueo:** la simulación previa del freno no guarda su plan; tras la 4b, `plan` enseñaba el de la
   4a (borrados), no las modificaciones. «Ver qué cambia» simula de nuevo, así que en la app no engaña; en `plan` sí.
4. **Freno de modificaciones lento:** la simulación tarda lo que tarda en recorrer todas las copias en seco contra Drive
   (~1 fichero/s): 36 min con 1 858 cambiados, aunque el recuento («Path1: N changes … M modified») sale a los 3 min.
5. **Enlaces simbólicos:** no se copian («Can't follow symlink without -L/--copy-links», dos avisos por enlace); solo
   queda en el registro.
6. `profile add` decía «Añadida ~/BackupDrive-prueba ↔ gdrive:BackupDriveGrande» (la carpeta de otro perfil que empieza
   igual); el perfil se guardó bien.
7. El primer `connect` tras `install.sh` falla con «BackupDrive está sincronizando ahora»: `install.sh` recarga el
   LaunchAgent y launchd lanza una pasada al cargarlo.
8. Una pasada de launchd que coincide con otra sale sin escribir nada en el registro (correcto, pero no queda rastro).
9. La app se abre desde `AppTranslocation` (cuarentena de la descarga, firma ad hoc).

## Detalle

**0.** `install.sh` → «LaunchAgent actualizado y activo», app en `/Applications`. `mojave-selftest.sh`: macOS 10.14.6, binario
`rclone v1.67.0-backupdrive` (mínimo 10.13), TLS con Google, hora sin desfase, token válido, launchd cargado.

**1.** `BACKUPDRIVE_CLIENT_SECRET=… backupdrive-ctl.sh connect --client-id …` en segundo plano; el navegador por defecto de
la 6,1 (FlyWeb) abre la autorización; tras autorizar, `{"ok":true,"name":"gdrive",…}` y `check` ok.

**h.** Perfil existente `~/BackupDrive-prueba|gdrive:BackupDrive-prueba|90|20|5` sin `--resync`: rc 0, «No changes found»,
«Bisync successful». launchd: pasadas a las 21:10 y 21:22 (al cargar) y 23:23 (periódica); la de 22:23 coincidió con el
`--resync` de la prueba 3 y se saltó por el bloqueo.

**3.** Copia con `ditto` (sin datos personales) de las Frameworks del SDK de CommandLineTools y de `/Library/Desktop Pictures`:
7 233 ficheros, 840 enlaces, 1 407 carpetas. `--resync --dry-run` 8 s; `plan`: 7 233 nuevos en el Mac. `--resync`: 1 h 45 min
27 s, sin errores ni límites de Google (~1,1 ficheros/s: manda el número de ficheros, no los bytes). Al terminar, perfil
quitado y carpeta borrada en el Mac y en Drive (a la papelera de Drive).

**4a.** `Kernel.framework` (1 025 ficheros) a `~/.Trash` → rc 1, `blocked` (exit 4): «Safety abort: too many deletes (>10%,
1117 of 8639)». Con `--dry-run`, `plan`: 1 117 borrados en el Mac (cuenta carpetas). Devueltos → ok.

**4b.** 1 858 ficheros con una línea añadida → rc 1 en 2 183 s, `blocked`: «Modificaciones masivas en Path1: 1858 de 7233
ficheros cambian de contenido (umbral 20 % y 50)». Drive sin el cambio y sin versiones nuevas. Deshecho con la copia previa
→ ok, «No changes found».

**5.** `f18.txt` editado en el Mac y en Drive (`backupdrive copyto`) → `f18.conflict1.txt` y `f18.conflict2.txt` en los dos
lados; `profile list` cuenta 4 copias, `conflicts list` da `[]`. `conflicts keep … f18.conflict2.txt` deja `f18.txt` con la de
Drive, pero `f18.conflict1.txt` sigue en los dos lados. `versions list` (28, bien), `versions restore … drive
f18-20261028-103748.txt` (bien; lo que había va a versiones del Mac y la pasada siguiente lo sube), `profile set --days 30
--pct 25 --count 6` y vuelta (bien), `--days -1` → código 6 con mensaje.

**7.** `BACKUPDRIVE_BIN=/usr/local/bin/backupdrive`, con `/bin/sh` y `/bin/bash`: `test-sync-safe.sh` 53/53 (34 s);
`test-ctl.sh` falla en «conflicto: copia del Mac/de Drive (salida: [])», «quedan copias en conflicto en el Mac/en Drive»,
«copia del Mac perdida» y «sin freno», todos por el fallo 1.
