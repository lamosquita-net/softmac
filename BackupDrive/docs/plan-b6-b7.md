# Plan de B.6 y B.7: BackupDrive sin terminal

BACKUPDRIVE-2, 03-11-2026. Hitos sin horas. Objetivo de Titín: cerrar BackupDrive e instalarlo en MacTrash (MacPro6,1,
Mojave 10.14.6). Maqueta de referencia: `BackupDrive/prototipo-ui/index.html`.

## Decisiones firmes (Titín, 03-11)

1. **Cuenta de Google: la clave propia de cada usuario** (cambio de Titín del 03-11, por la tarde, que sustituye a «la
   compartida por defecto»): ningún ID ni secreto en el repo; por qué y cómo en `docs/clave-google.md`. La compartida de rclone
   queda solo para pruebas (`connect --shared`). **Va antes que el resto**: Titín quiere sustituir FreeFileSync en MacTrash pronto.
2. **Frenos y conflictos:** lenguaje llano y siempre «Ver qué cambia» antes de «Continuar de todos modos».
3. **Restaurar versiones desde la app: sí.** Si hay que recortar alcance, se recorta Actividad, no Versiones.

## Principios

- **El motor no cambia de diseño** (`backupdrive-sync.sh` y `status.json`). Lo nuevo que no es sincronizar (conectar, perfiles,
  versiones, plan del freno) va a un guion de órdenes nuevo, `backupdrive-ctl.sh`, y la app solo lanza esos dos guiones y lee
  ficheros. Ventajas: todo se puede hacer también por línea de órdenes (requisito de B.7) y se prueba en la CI de Linux con un
  remoto local, como `test-sync-safe.sh`. Ampliación de «la interfaz solo lanza `backupdrive-sync.sh`» **aprobada por COORDINACIÓN-24 (03-11)**.
- **AppKit puro, sin nib ni SwiftUI**, SDK y objetivo 10.14, como `app/main.m`. La CI ya falla con APIs posteriores a 10.14.
- **Nada se pierde tampoco al restaurar:** lo que se reemplaza va antes a versiones.
- No se toca `BackupDrive/rclone/` (subtree v1.67.x, Go 1.20).

## Hitos

**H0. Cerrar B.2** (Titín, prueba h en la 6,1, tras reinstalar con el artefacto `BackupDrive-mojave` de `main`).

**H1. `backupdrive-ctl.sh` con pruebas (nube, CI). Hecho (03-11):** `plan` lee el registro que guarda cada simulación
(`state/<id>.plan.log`).
- `connect [--client-id X --client-secret Y]`: `backupdrive --config <conf> config create gdrive drive scope=drive [...]`.
  rclone abre el navegador y espera en `127.0.0.1:53682`; sin preguntas. Comprueba con `about gdrive:`.
- `folders <remoto:ruta>` (lista carpetas en JSON con `lsjson --dirs-only`) y `mkdir`.
- `profile add|remove|list`: escribe `profiles` de forma atómica, conserva los comentarios y valida (no la raíz de Drive, no
  solapar con otro perfil, la carpeta de versiones no puede caer dentro).
- `versions list <perfil> [ruta]` (los dos lados, agrupado por fichero y fecha del sufijo) y `versions restore`: copia la versión
  a su sitio en el Mac; si existe el actual, va antes a versiones; la siguiente pasada lo sube a Drive.
- `plan <perfil>`: `--dry-run` y un resumen legible por la app (`state/<id>.plan.json`: se borrarían / cambiarían / conflictos).
- Pruebas en `tests/test-ctl.sh` con remoto local; la CI las ejecuta. `connect` real solo se prueba en un Mac (H3).

**H2. La app, por partes (nube, CI). Hecho (03-11), junto con lo esencial de H3 en el mismo PR.** Partir `main.m` en módulos (estado, motor, menú) sin cambiar lo que hace; `build-app.sh`
compila varios `.m`. Prueba: lo mismo que la prueba h.

**H3. Asistente de conexión (B.6, nube + Titín). Hecho en lo esencial (03-11):** conectar con la clave propia, añadir y
quitar carpetas; el navegador de subcarpetas de Drive se queda en un desplegable con las de primer nivel y ruta escrita. «Conectar con Google Drive…»: hoja «Autoriza en el navegador…» con Cancelar
(mata el proceso), comprobación y paso siguiente: elegir carpeta del Mac (`NSOpenPanel`) y de Drive (navegador de carpetas con
`folders`, «Nueva carpeta»), y la primera sincronización que ya existe (simulada → real). **Prueba de Titín en la 6,1:**
conectar su cuenta desde cero, sin el asistente de `config`. Por verificar ahí: que rclone abre el navegador por defecto de
Mojave y que no hace preguntas.

**H4. Ventana principal: Inicio (nube + Titín).** Estado general, cada carpeta con su último resultado, «Sincronizar ahora».

**H5. Frenos y conflictos (nube + Titín).** Avisos en lenguaje llano; «Ver qué cambia» abre la lista de `plan`; solo después
aparece «Continuar de todos modos» (`--force`). Conflictos: lista de pares `conflict` con «Quedarme con este» (el otro va a
versiones).

**H6. Versiones (nube + Titín).** Buscar por fichero, ver fechas y lado, «Restaurar» y «Mostrar en el Finder».

**H7. Preferencias.** Carpetas (alta/baja, días de versiones), Protección (umbrales del freno), Avisos, Avanzado (cambiar la clave de
Google; el asistente de H3 ya la pide desde el principio) y General (abrir al iniciar sesión).

**H8. Actividad** (recortable si falta alcance): las últimas pasadas desde el registro.

**H9. Cierre e instalación en MacTrash (Titín).** Iconos definitivos de Titín (B.3, con la mosca), `install.sh` final, perfiles
reales creados desde la app, «Sincronizar cada hora» activado y una semana de uso sin terminal.

## Riesgos y dudas

- **Rendimiento:** con la clave compartida, 40 ficheros tardaron 3 min 51 s la primera vez; la pasada en seco del freno duplica
  los listados. Con la clave propia (ya obligatoria) hay que volver a medir, con miles de ficheros, antes de quitar FreeFileSync.
- **La credencial de rclone sigue en claro** en `backupdrive.conf` (README, «Qué no protege»). Cifrarla con `RCLONE_CONFIG_PASS`
  guardada en el llavero es posible después de H9; no entra en este plan salvo que Titín lo pida.
- **Quién programa la interfaz:** BACKUPDRIVE en la nube, con la CI de macOS; las pruebas con ventana, Titín en la 6,1
  (COORDINACIÓN-24, 03-11).
