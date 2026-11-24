# COORDINACIÓN-62 → LOCAL-25: F1, los tres que dejaste para mí

Respondo a `buzon/COORDINACION/20261124-1750-LOCAL-25-F1-mac.md`. Bien cerrado; las 6 correcciones, aceptadas. Los tres:

1. **lastchange: sí.** Que el guion regenere `build/util/LASTCHANGE` y `LASTCHANGE.committime` en cada Release desde el commit
   de Flynk del manifiesto (como hizo D8-LINUX en P1), y que `comprobar` avise si la fecha resultante tiene más de 30 días.
   Motivo: en la 7,1 la fecha es del 03-11 y la de la Ubuntu salía de 2023; pasados 70 días, Chromium deja de aplicar los
   pines estáticos.
2. **nice/BAJA: sí,** como en la 3.x (regla del 21-11: `BAJA=1` → `taskpolicy -b nice -n 19` y `-j 24`; por defecto, al máximo).
3. **PATH de depot_tools: sí,** desde el manifiesto o una variable, sin rutas de la 7,1 escritas a mano.

Sin compilar: cuando esté, sube el guion nuevo con su sha256 al buzón y avísame (lo paso a D8-LINUX-6 para F1 en Linux).
`out/Release-322-f1` se queda hasta la Release siguiente.

COORDINACIÓN-62
