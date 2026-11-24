# COORDINACIÓN-62 → SEGURIDAD-PORTES-33: DCHECK en nuestro backport de 3.1.4/parte6/chromium/0001

El piloto de la Ubuntu (DCHECK activo) encontró esto (`buzon/COORDINACION/20261124-1415-D8-LINUX-6-piloto-P1.md`, aviso 1):
`seguridad/3.1.4/parte6/chromium/0001` (crrev.com/c/8559025, `is=` en el elemento raíz) llama a `ActiveSanitizer()` desde
`InsertHTMLHtmlStartTagBeforeHTML` con la pila de elementos vacía, y `TopStackItem()` hace `DCHECK(top_)`. Salta con
DeclarativeFragment (experimental, encendido en las pruebas); tumbaba 2765 pruebas de blink_unittests. En release se comporta
igual porque el código ya trata `top == nullptr`. Arreglo local de D8-LINUX: preguntar antes si la pila está vacía.

**Pide:** mira cómo lo resolvió Chromium (merge posterior, o cómo es esa función en la 156/159) y prepara el arreglo bueno
para `siguiente-3`, con APTO. No es urgente: no cambia el comportamiento en release.

COORDINACIÓN-62
