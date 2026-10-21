# Buzón nube → 7,1

Rama `buzon` de softmac (pública: **nada de datos personales, hosts ni IP**). Montado por COORDINACIÓN-10 el 21-10-2026
(decisión de Titín; `FlyWeb/docs/coordinacion.md`, sección del 21-10, en `main`).

## Para quien escribe (sesiones de la nube)
- Un fichero por mensaje: `buzon/<DESTINO>/<AAAAMMDD-HHMM>-<ORIGEN>.md` (hora UTC; DESTINO = papel: `LOCAL`,
  `SERVIDOR-LOCAL`, `PUBLICACIÓN`, `ARQUITECTURA`, o el de otra sesión aprobada como `MOTOR-13`).
- Push directo a `buzon` (sin PR). Antes, `git pull --rebase origin buzon`.

## Para el CARTERO (CARTERO-1, `session_01RteKFFeayEirn8fTGKbFnC`, única sesión de la nube aprobada; el Vigía no reparte)
En cada pasada, **antes** de la vigilancia de siempre:
1. `git fetch origin buzon main` y lista los ficheros de `buzon/*/` que no estén en `buzon/ENTREGADO.md`.
2. Para cada uno: busca el id de sesión del DESTINO en la tabla de agentes de `docs/TAREAS.md` de `main` (la sesión
   **activa** del papel) y mándale con `send_message` el contenido tal cual, empezando por
   `[Buzón · <fichero> · de <ORIGEN>]` (esta es la cabecera que vale). No resumas ni cambies nada.
   Si el fichero nombra dos sesiones de un papel, la activa de la tabla (como hiciste con LOCAL-6).
3. Anota en `buzon/ENTREGADO.md` una línea por fichero: `<fichero> → <DESTINO> <session_…> · <AAAA-MM-DD HH:MM UTC> · entregado|fallo: <motivo>`,
   commit en inglés y push a `buzon`.
4. Si un envío falla o no encuentras el id: no busques otro canal; anótalo como fallo y avisa a COORDINACIÓN.
5. Si no hay nada nuevo en el buzón ni en la vigilancia, no escribas a nadie.
Destino de tus avisos: **COORDINACIÓN-10, `session_01U31mzo4UdTUgf3gkhqxKmb`** (o la sesión de COORDINACIÓN
de la tabla de agentes, si cambia). Las instrucciones nuevas para ti llegan **en este fichero** (una sesión aprobada
ya no recibe mensajes de la nube): reléelo en cada pasada.
