# Buzón nube → 7,1

Rama `buzon` de softmac (pública: **nada de datos personales, hosts ni IP**). Montado por COORDINACIÓN-10 el 21-10-2026
(decisión de Titín; `FlyWeb/docs/coordinacion.md`, sección del 21-10, en `main`).

## Para quien escribe (sesiones de la nube)
- Un fichero por mensaje: `buzon/<DESTINO>/<AAAAMMDD-HHMM>-<ORIGEN>.md` (hora UTC; DESTINO = papel: `LOCAL`,
  `SERVIDOR-LOCAL`, `PUBLICACION`, `ARQUITECTURA`; sin tildes en el nombre de carpeta).
- Push directo a `buzon` (sin PR). Antes, `git pull --rebase origin buzon`.

## Para el CARTERO (CARTERO-LOCAL, en la MacPro7,1; decisión de Titín, 21-10)
Haiku, esfuerzo bajo; lo abre Titín. **Desde el 28-10 (COORDINACIÓN-19, con Titín): vigilante en segundo plano** (Monitor) sobre
un clon de `buzon` que mira cada 120 s y solo despierta al cartero cuando hay ficheros sin anotar; sin cron. Probado:
entrega en ~2,5 min (19:22 → 19:25 UTC). COORDINACIÓN da por caído al cartero si hay ficheros de más de 45 min sin anotar. En cada pasada:
1. `git fetch origin buzon main` y lista los ficheros de `buzon/*/` que no estén en `buzon/ENTREGADO.md`.
2. Para cada uno: busca la sesión activa del DESTINO en la tabla de agentes de `docs/TAREAS.md` de `main` y mándale con
   `SendMessage` (misma Mac, `ListAgents` para el nombre) el contenido tal cual, empezando por
   `[Buzón · <fichero> · de <ORIGEN>]`. No resumas ni cambies nada. Si el fichero nombra dos sesiones de un papel, la activa.
3. Anota en `buzon/ENTREGADO.md` una línea por fichero: `<fichero> → <DESTINO> <sesión> · <AAAA-MM-DD HH:MM UTC> · entregado|fallo: <motivo>`,
   commit en inglés y push a `buzon`.
4. Si un envío falla: anótalo y avisa a COORDINACIÓN (la sesión de la tabla de agentes). No busques otro canal.
5. Sin ficheros nuevos, no escribas a nadie.
6. **Recordatorio de COORDINACIÓN-10 (21-10, 13:05):** desde las 08:07 UTC no hay ninguna línea nueva en `ENTREGADO.md`
   aunque los mensajes llegan. Anota cada entrega (paso 3) y haz push; si el push falla, díselo a COORDINACIÓN con el error.
   Los ficheros ya entregados sin anotar: anótalos de una vez con la hora aproximada.

Reserva: CARTERO-1 de la nube (`session_01RteKFFeayEirn8fTGKbFnC`, aprobada; rutina `trig_01ByndD2HyrSWPyNqauBF7uH`
desactivada). Si CARTERO-LOCAL falla, COORDINACIÓN reactiva esa rutina.
