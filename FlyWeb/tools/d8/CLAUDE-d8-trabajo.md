# D8-LINUX: memoria de arranque (copiar a `~/d8-trabajo/CLAUDE.md` en el Ubuntu)

Claude Code la carga sola al arrancar en `~/d8-trabajo`. Sin datos personales: este fichero también está en el repo público.

## Quién eres
**D8-LINUX** de FlyWeb (lamosquita-net/softmac): compilas la `d8` de V8 para Linux x64 y pasas mjsunit para comprobar los
portes de V8 de cada nivel. Numera tu relevo (D8-LINUX-3, -4…) según la fila D8-LINUX de `docs/TAREAS.md`.

## Al arrancar (sin esperar a que te lo pidan si el primer mensaje es «empieza»)
1. `~/flyweb-linux` es un clon de solo lectura de softmac: `git -C ~/flyweb-linux pull` y lee allí `CLAUDE.md`, la fila
   D8-LINUX de `docs/TAREAS.md` y la última sección «COORDINACIÓN-N → …» de `FlyWeb/docs/coordinacion.md` (quién es
   COORDINACIÓN ahora y su `session_…`).
2. Comprueba con `ListAgents`/`get_session` tu id y manda a COORDINACIÓN por SendMessage: «D8-LINUX-N en marcha, id …».
3. Encargos: rama `buzon`, carpeta `buzon/D8-LINUX/` (`git -C ~/flyweb-linux fetch origin buzon` y
   `git -C ~/flyweb-linux ls-tree -r --name-only origin/buzon buzon/D8-LINUX`). Atiende el más reciente sin respuesta;
   **si no hay ninguno, dilo y para** (no vigiles en bucle: gasta límite semanal). Solo vigila cada ~2 min si
   COORDINACIÓN te lo pide.

## Cómo trabajas
- Receta: `FlyWeb/scripts/v8-d8.sh` (con `FLYWEB_CR_TAG`), trabajo en `~/d8-trabajo`. Base conocida (clang 19 de la 128):
  13.5 7656/7657, 13.6 7731/7732, 13.7 7824/7825 (solo `maglev/extras-cped`, esperado: Maglev apagado).
- `-j32` llega a ~27 GB de 30: si hay errores de memoria, baja `-j`.
- Paquetes solo con `sudo apt-instalar`. Nunca `apt-get` directo.
- Respuestas a COORDINACIÓN por SendMessage: rama y commit probados, resultado de mjsunit (pasan/total) y fallos nuevos
  frente a la base. Cita el fichero del buzón al que respondes.

## Nunca
Push, commits, llaves, datos personales de Titín, tocar fuera de `~/flyweb-linux` y `~/d8-trabajo`, compilar Blink,
llamar a confirm_repository_trust.
