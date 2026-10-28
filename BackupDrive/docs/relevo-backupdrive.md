# Relevo de BACKUPDRIVE

Para el siguiente relevo de BACKUPDRIVE. Historia: **BACKUPDRIVE-1 (`session_01MMur1TxacRpN7gNor98eYm`, 26-10) → 2**.
Leer antes: `CLAUDE.md` (sección BackupDrive), `docs/DIRECTIVAS.md`, en `docs/TAREAS.md` las reglas y las filas B.2–B.7,
`BackupDrive/README.md` (sección «Cómo funciona») y `BackupDrive/scripts/backupdrive-sync.sh` (la cabecera lo explica todo).
No tocar `BackupDrive/rclone/` (subtree). A Titín, siempre en castellano; commits en inglés.

## BACKUPDRIVE-1 → 2 (28-10-2026, ~19:50)

**Hecho (todo fusionado en `main`):**
- #508: sincronización «nunca perder nada» sobre `rclone bisync` 1.67 bien configurado (comparación por lado contra la última
  pasada, conflicto = se conservan los dos, borrado = la copia del otro lado va a versiones, `--max-delete`, freno de
  modificaciones masivas con pasada en seco previa, estado perdido = `--resync` que solo copia, versiones con caducidad por la
  fecha del nombre, 90 días). `tests/test-sync-safe.sh`: 52 pruebas con remoto local; la CI las ejecuta.
- #590: `--dry-run` enseña el plan completo (antes se cortaba en «FRENADO»). Fila B.6.
- #593: maqueta de la interfaz (fila B.7).

**1. Maqueta de la interfaz.** Artefacto (privado, en la cuenta de Titín; no se borra):
https://claude.ai/artifact/U9zvBLep3hycT8kTeTAUZh. Fuente en el repo: `BackupDrive/prototipo-ui/index.html` (#593; la misma
página, con el diagrama de mermaid cargado desde cdnjs). Cuatro superficies: menú de la barra, ventana principal (Inicio,
Versiones, Actividad), asistente de conexión (B.6) y Preferencias (General, Carpetas, Protección, Avisos, Avanzado). Titín la
revisa, pule el diseño y cambia los iconos (los de la maqueta son provisionales, sin la mosca). Después, el agente INTERFAZ
(decisión de COORDINACIÓN) la lleva a Objective-C/AppKit: Mojave no tiene SwiftUI. La interfaz solo lanza `backupdrive-sync.sh`
y lee `status.json`; el motor no cambia.

**2. Tres decisiones pendientes de Titín** (tal como se las planteé):
1. *Cuenta de Google:* clave compartida de rclone (un clic, pero fue lenta: 40 ficheros, 3 min 51 s) o clave propia (cuota propia;
   hay que dar de alta la aplicación en Google Cloud una vez y publicarla para que el token no caduque a los 7 días). Propuesta:
   la compartida por defecto y la propia en Avanzado.
2. *Cuánto se enseña* en los frenos y conflictos. Propuesta: lenguaje llano y siempre un botón «Ver qué cambia» antes de
   «Continuar de todos modos».
3. *Restaurar versiones desde la app,* o basta con abrir la carpeta de versiones en el Finder. Mi opinión: la pantalla de
   Versiones es la más cara de construir pero la que hace visible «nunca perder nada»; si hay que recortar alcance, recortar
   Actividad y no Versiones.

**3. Prueba h pendiente** (B.2, en la 6,1): con la app abierta, el icono y el perfil con ✓ ya se ven; falta confirmar
«Sincronizar ahora» (el icono debe pasar a «sincronizando» y volver) y «Sincronizar cada hora» (debe aparecer
`net.lamosquita.backupdrive` en `launchctl list`). Después, quitar el agente
(`launchctl unload -w ~/Library/LaunchAgents/net.lamosquita.backupdrive.plist`) y la línea de prueba de `profiles`.

**4. Estado de B.2 y lo siguiente.**
- B.2 en la 6,1 (Mojave 10.14.6, Drive real, carpeta de prueba de 40 ficheros, client_id compartido): a–g correctas (borrar en
  cada lado, editar, conflicto, carpeta vacía, borrado masivo → `blocked`, cifrado simulado → `blocked`; con `--force` los
  originales quedan en versiones). Solo falta h.
- Rendimiento: primera sincronización 3 min 51 s; pasadas de 5 s a 2 min con 40 ficheros (sin cambios ~26 s); variable de Drive.
  Por medir con clave propia y con miles de ficheros: la pasada en seco previa duplica las llamadas; si pesa, valorar evitarla.
- Titín debe **reinstalar** con el artefacto `BackupDrive-mojave` de `main` para tener el `--dry-run` corregido (#590).
- Siguiente: B.6 (botón «Conectar con Google Drive…» y perfiles con selector, sin el asistente del shell), después de cerrar h y de
  que Titín decida lo de la clave de Google; B.7 la implementa INTERFAZ cuando COORDINACIÓN la abra.

**Trampas aprendidas:**
- Un `--dry-run` de bisync también aplica `--max-delete`; por eso la simulación pasa `--force` (inofensivo: no cambia nada).
- `--min-age` mira la fecha original del fichero, no la de cuando se movió a versiones: la caducidad lee la fecha del sufijo.
- bisync exige que la carpeta de versiones no esté dentro de la sincronizada (en Drive va «`<carpeta> (versiones)`» al lado) y que
  el remoto lleve una carpeta, no la raíz.
- Titín pega bloques de órdenes en un terminal nuevo: las variables `APP`, `CONF`, `L`, `R` no existen en un terminal nuevo;
  darle siempre el bloque de definiciones, sin comentarios `#` (rompen el asistente de `config`).
- El freno de borrados es solo un porcentaje: en carpetas de menos de 10 ficheros borrar uno ya lo activa (`--force`).
