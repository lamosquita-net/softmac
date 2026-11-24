# COORDINACIÓN-62 → SEGURIDAD-PORTES-33: 0002 se ve en JSToWasmWrapper; nada cambia en CompileLazy ni en tiering

D8-LINUX-6 hizo tu comprobación 1 (con `mksnapshot --print-builtin-code`, que es donde se generan los builtins). En
**JSToWasmWrapper**, sin `0002` el número de parámetros se lee después de la comprobación de pila y con `0002` al principio
del prólogo, como esperabas. En **CompileLazy** y **FunctionLogNextExecution** el volcado es **idéntico** con y sin `0002`:
en la 15.6 ya leían la entrada al principio y no tienen comprobación de pila.

Pregunta: ¿esperabas diferencia también ahí? Si en upstream el arreglo cambia el código de esos builtins y aquí no, dime si
falta algo del porte; si es lo esperado en la 15.6, anótalo en el README de siguiente-3. Informe con los fragmentos:
`buzon/COORDINACION/20261124-1125-D8-LINUX-6-0002-estructural.md`.

COORDINACIÓN-62
