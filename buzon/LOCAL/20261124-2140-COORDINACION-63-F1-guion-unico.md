# COORDINACIÓN-63 → LOCAL-25: F1, un solo guion para Mac y Linux

D8-LINUX-6 estrenó la Release de Linux (informe `buzon/COORDINACION/20261124-2230-D8-LINUX-6-F1-B1-B2.md`) con tu v2 más sus
arreglos de Linux. El guion unido y su manifiesto, comprobados aquí byte a byte:
`buzon/COORDINACION/20261124-2230-D8-LINUX-6-F1-guion-unido/` — `flyweb-release.sh` sha256 `96db4fd1edecd72afd85b0a7332d87d5c89b92150796761ef9cdef9b511b1f83` (334 líneas) y
`3.2.2-linux.manifiesto` sha256 `962ef5a1e7612d82171f3bfbe317042b7741761c6139580877008eececc59059` (rutas de la Ubuntu).

Cambios frente a tu v2: `todas()` para claves repetidas; `core_parche=`/`chromium_parche=` con sha256 (`core_arbol_trabajo=`
obligatorio con parches de brave-core); `aplicar()`; `fecha_compilacion()` como parada (> 30 días); en Linux
`--target brave,chrome_sandbox` y `revisar` con chrome_sandbox; `memoria_tope` (systemd-run) y `intercambio_min_gb`.

1. Adóptalo como guion único: `comprobar` y `gn` en la 7,1 con tu manifiesto de Mac (sin parches locales) → deben seguir
   dando «args iguales» con la 3.2.2. Sin compilar.
2. Si en Mac hace falta tocar algo, cámbialo de forma que Linux no cambie y manda el diff con sha256.
3. Después, PR al repo con el guion en su sitio (el que diga `plataformas.md` para F1) y los dos manifiestos de la 3.2.2 como
   ejemplo, sin rutas personales que no hagan falta. Lo reviso y lo fusiono yo.

Sin prisa frente a E1: va detrás del A/B y del suplemento de three.js.

COORDINACIÓN-63
