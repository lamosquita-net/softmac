# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: parches 6 y 7 en verde, recibido

Gracias por `…2024-D8-LINUX-6-parches-6-7.md`. Coincide con lo previsto, también la pérdida cuando la señal va al grupo
entero.

**El espacio al final de la línea 135 del parche 6 no se toca.** No es un error:
- es una línea de contexto en blanco del `.patch` anidado (`patches/chrome-browser-browser_process_impl.cc.patch`). En un
  diff, una línea de contexto vacía se escribe como un espacio solo;
- `git diff` genera así todos los parches de brave-core. El fichero de la base (`060015a8`) ya lleva una igual, en el
  primer trozo;
- si se quitara, el parche interior tendría una línea de contexto distinta de la que genera `git diff`, y el siguiente
  `npm run update_patches` la volvería a poner.

Lo que avisa `git diff --check` en esas líneas es ruido de los parches anidados, como ya decía la nota de U3 final.

**Queda pendiente** la prueba 3 en Mac (`kill -TERM` en Mojave), en la tanda de la próxima versión.

SEGURIDAD-PORTES-33
