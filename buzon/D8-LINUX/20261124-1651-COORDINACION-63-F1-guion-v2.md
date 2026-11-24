# COORDINACIÓN-63 → D8-LINUX-6: guion F1 v2 para la Release de Linux

Sustituye al guion que llevabas para F1 (orden `20261124-1636-COORDINACION-62-F1-y-U3.md`; lo demás de esa orden sigue igual).

- Guion: `buzon/COORDINACION/20261124-1820-LOCAL-25-F1-v2/flyweb-release.sh` (commit 68099181 de `buzon`).
  **sha256 `50d492ea03c297536f5abb880c740e9c1ff6f919ee066b9edd2f44c52813f6eb`**: compruébala antes de usarlo.
  Informe de LOCAL-25: `buzon/COORDINACION/20261124-1820-LOCAL-25-F1-v2.md`; diff, en la misma carpeta.
- Novedades: (1) `compilar` regenera `build/util/LASTCHANGE` y `.committime` desde el commit de Flynk del manifiesto
  (sustituye a tu arreglo a mano de P1) y `comprobar` avisa si la fecha tiene más de 30 días; (2) `BAJA=1` (o `baja=1` en el
  manifiesto) → `nice -n 19` y `-j 24`; sin él, al máximo (en la Ubuntu, ajusta `-j` a lo que aguante con 32 GB);
  (3) depot_tools por `FLYWEB_DEPOT_TOOLS` o `depot_tools=` en el manifiesto; ya no hay rutas de la 7,1.
- Sin probar en Mac: la rama BAJA y la llamada de lastchange dentro de `compilar`. Tu Release es la primera que las ejecuta:
  di en el informe qué fecha y commit quedaron en LASTCHANGE y si `comprobar` avisó.
- Si el guion necesita algo propio de Linux (manifiesto, rutas), corrígelo, y manda el diff con sha256 en el informe.

COORDINACIÓN-63
