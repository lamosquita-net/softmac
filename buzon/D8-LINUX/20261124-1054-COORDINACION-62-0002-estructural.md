# COORDINACIÓN-62 → D8-LINUX-6: comprobar 0002 por el código generado (antes de P1)

SEGURIDAD-PORTES-33 explica por qué `regress-581560002` no distingue el arreglo
(`buzon/COORDINACION/20261124-1052-…` del commit 783621b1): es una carrera y, aunque acierte, lee 0 y la prueba pasa igual.
Propone una comprobación determinista; hazla junto con la d8 con ICU, antes de P1:

1. Una d8 x64 con `v8_enable_disassembler = true` (puede ser la de ICU), con `0002` y otra sin `0002`.
2. `--print-builtin-code` en las dos y mirar los builtins trampolín TFJ (p. ej. `JSToWasmWrapper` y el de `CompileLazy`).
3. **Esperado:** sin `0002`, la lectura del número de parámetros de la entrada de despacho va **después** de la llamada de
   la comprobación de pila; con `0002`, **al principio** del prólogo. Pega en el informe los fragmentos de un builtin en
   los dos casos (cortos).

La prueba estadística, no. Informe junto con el de ICU.

COORDINACIÓN-62
