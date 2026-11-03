# Relevo de BACKUPDRIVE

Para el siguiente relevo de BACKUPDRIVE. Historia: **BACKUPDRIVE-1 (`session_01MMur1TxacRpN7gNor98eYm`, 26-10) → 2 (`session_01MwmK2iDUP7F9s2StJNRgCj`, 03-11) → 3**.
Leer antes: `CLAUDE.md` (sección BackupDrive), `docs/DIRECTIVAS.md`, en `docs/TAREAS.md` las reglas y las filas B.2–B.7, `docs/plan-b6-b7.md`,
`BackupDrive/README.md` (sección «Cómo funciona») y las cabeceras de `scripts/backupdrive-sync.sh` y `scripts/backupdrive-ctl.sh`.
No tocar `BackupDrive/rclone/` (subtree). A Titín, siempre en castellano; commits en inglés.

## BACKUPDRIVE-2 → 3 (03-11-2026, ~17:10)

**Coordinador:** COORDINACIÓN-25 (`session_01MwmK2i6N1Pz4VfDzzGQ59D`). Informes y bloques para Titín, a esa sesión (se los
hace llegar ella). **Linaje:** BACKUPDRIVE-2 era el nivel 7 de 8; el siguiente relevo quizá no pueda crear otro (que lo cree
COORDINACIÓN).

**Decisiones firmes de Titín (03-11):**
1. **Clave propia de Google, obligatoria, de cada usuario y nunca en GitHub** (cambio de la tarde; sustituye a «compartida
   por defecto»). Motivo y pasos: `docs/clave-google.md`. `--shared` solo para pruebas.
2. Frenos y conflictos en lenguaje llano; **siempre «Ver qué cambia» antes de «Continuar de todos modos»**.
3. **Restaurar versiones desde la app.** Si hay que recortar, se recorta Actividad, no Versiones.
4. Objetivo: **sustituir FreeFileSync en MacTrash (6,1) con seguridad**. No tocar FreeFileSync hasta que la prueba h y la de
   la carpeta grande salgan bien.

**COORDINACIÓN-24 aprobó:** la app **solo lanza `backupdrive-sync.sh` y `backupdrive-ctl.sh`** y lee lo que escriben; la
interfaz (B.7) la programa BACKUPDRIVE en la nube (AppKit, objetivo 10.14); Titín prueba con ventana. PR: borrador hasta que
la CI esté en verde, luego listo y aviso a COORDINACIÓN.

**Hecho (plan `docs/plan-b6-b7.md`, H1–H7):**
- #704 (main): `scripts/backupdrive-ctl.sh` (connect, check, folders, mkdir, profile, versions, plan) y `tests/test-ctl.sh`;
  el motor guarda el plan de cada simulación en `state/<id>.plan.log`; arreglo: las versiones `a-FECHA.tar.gz` no caducaban.
- #708 (main): la app por módulos (`AppDelegate`, `BDRunner`, `BDSetup`); «Conectar con Google Drive…», «Añadir carpeta…»,
  «Dejar de sincronizar…». Lleva el arreglo de cancelar `connect` (rclone se quedaba en el puerto 53682 y, con `set -e`, el
  `wait` del trap impedía restaurar la cuenta).
- #710 (main): «Ver qué cambia…» en las carpetas detenidas; «Continuar de todos modos» solo desde ahí; plan viejo detectado
  por la fecha.
- #715 (listo, CI en verde): conflictos (`conflicts list|keep`, «Resolver conflictos (N)…») y ventana «Versiones…»
  (`app/BDVersionsWindow.m`).
- #719 (borrador): «Ajustes de esta carpeta…» y «Abrir al iniciar sesión» (LaunchAgent `net.lamosquita.backupdrive.app`).
- Pruebas: `test-ctl.sh` 99, `test-sync-safe.sh` 53, en la CI con `sh`; en local también con `bash` (el `/bin/sh` de Mojave).

**Pendiente:**
- **Titín en la 6,1** (bloque enviado a COORDINACIÓN-25 a las 16:46, con el añadido de las 16:48): crear la clave → instalar
  el artefacto `BackupDrive-mojave` de main → «Volver a conectar…» con su clave → prueba h → carpeta grande (copia) con
  medida de tiempo → freno con «Ver qué cambia». Con sus resultados: proponer qué carpetas reales pasar y cuándo apagar
  FreeFileSync (H9).
- **Sin probar en un Mac:** todo lo de la app (la CI solo compila) y `backupdrive-ctl.sh` con el `awk`/`date` de BSD.
  Lo más probable que falle: la fecha del plan (`stat -f %m`, con alternativa) y el aspecto de los diálogos (tamaños fijos).
- H8 Actividad (recortable). H3 tiene solo un desplegable con las carpetas de primer nivel de Drive y ruta escrita (sin
  navegador de subcarpetas).
- Filas de `docs/TAREAS.md` B.2/B.6/B.7: al día hasta H2+H3; actualizar con H5–H7 cuando entren.

**Trampas aprendidas (03-11):**
- `config create` de rclone **borra la cuenta antes de autorizar**: `connect` guarda una copia de `backupdrive.conf` y la
  restaura si falla o se cancela. En los `trap`, con `set -e`, todo lo que pueda fallar lleva `|| true`.
- `--suffix-keep-extension` conserva **extensiones compuestas** con tipo MIME conocido (`a-FECHA.tar.gz`): los patrones de
  versiones aceptan `(\.[^/]*)?$`.
- bisync nombra los conflictos `nombre.conflictN.ext` (1 = Mac, 2 = Drive; si vuelve a chocar, la numeración sigue).
- Resolver un conflicto en una carpeta pequeña quita dos ficheros y **activa el freno de borrados** la pasada siguiente:
  correcto; «Ver qué cambia» lo explica.
- Si un PR se fusiona mientras subes un commit, el commit se queda fuera (pasó con #704): comprobar con
  `git merge-base --is-ancestor` y llevarlo en el PR siguiente.
- La CI del PR a veces cancela el trabajo de macOS sin arrancar (15 min sin máquina, cero pasos): relanzarlo una vez.
- `awk -v re=…` quita la barra de `\.` en algunos awk: los patrones, literales dentro del awk.
- Sin dominios de Google ni rclone.org desde la nube: la documentación de rclone está en el subtree
  (`rclone/docs/content/drive.md`).

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
