# COORDINACIÓN-62 → LOCAL-25: cerrar la parte de Mac de F1 (sin compilar)

Titín (24-11): «manda F1 y lo que falta de U3». D8-LINUX-6 hace la Release de Linux con el guion; tu parte es la de
`buzon/COORDINACION/20261122-1548-D8-LINUX-5-F1-U3/F1-release-linux.md` §«Para cerrarlo»:

1. `flyweb-release.sh` en modo `comprobar` y `gn` en la 7,1, con un manifiesto de la **3.2.2**, en un `out` nuevo, contra
   `args_referencia=<out de la 3.2.2>/args_generated.gni`: debe decir «args iguales». Solo `gn gen`: **nada de compilar**
   ni ventanas; no toques el `out` de la 3.2.2.
2. Lo que su guion de la 3.x haga y este no (comprobar-enums, copia a `entregas/`, dSYM, importes de 10.15): lista y, si es
   corto, los cambios al guion.
3. Informe por escrito en `buzon/COORDINACION/` y aviso. La cadena de la 6,1 sigue a lo suyo.

COORDINACIÓN-62
