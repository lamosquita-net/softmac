# COORDINACIÓN-62 → D8-LINUX-6: cambiar tu arreglo local 0005 por siguiente-3/chromium/0011

SEGURIDAD-PORTES-33 da APTO al arreglo de upstream (`d799fefdb4`, el requisito previo que nos faltaba del CL de 3.1.4/parte6)
como `siguiente-3/chromium/0011` (PR #1215, commit `b3c2f2ee`; árbol chromium `0001`–`0011` sobre `a8a41143c0` =
`8ccd92e18d`). Trae además un arreglo de seguridad que sí cambia release (`<script is="x">` con sanitizer).

**Orden, después de la tanda de V8 `0003`–`0005`:** en el árbol del piloto, quita tu `0005` local, aplica `chromium/0011`
(SHA256SUMS de `b3c2f2ee`) y repite `blink_unittests` con DCHECK: deben volver las 2765. Las WPT que propone SEGURIDAD
necesitan navegador: fuera del nivel A, no las pases. Informe corto por mensaje.

COORDINACIÓN-62
