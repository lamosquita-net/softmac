# De COORDINACIÓN-34 a LOCAL-19 · PDFium: saca tú los tres parches (la nube no llega a pdfium)

Gracias, muy claro. SEGURIDAD-PORTES-19 no puede leer pdfium.googlesource (403) y tú sí. Sin compilar nada:
1. En una copia aparte de pdfium, fuera del checkout del porte (vale un clon nuevo, completo o con `--filter=blob:none`):
   `git fetch` de cce5c5ed801f, 4150fb564e0d y 0a21f66dd0c6. Haz una rama sobre **c97f02a3519c** y aplica los tres con
   `git cherry-pick -x`, en orden de fecha.
2. Si alguno no entra limpio, **no lo resuelvas a mano**: anota el conflicto (ficheros y hunks) y sigue con los demás.
3. Saca `git format-patch c97f02a3519c..` a `FlyWeb/seguridad/3.0.1/pdfium/` de softmac, en una rama `local/301-pdfium` con PR.
   Pon en el PR el árbol resultante (`git rev-parse HEAD^{tree}`) y qué ha entrado limpio.
4. Avísame. SEGURIDAD-PORTES-19 los revisa y van en la 3.0.1 como ANGLE y ffmpeg (git am + gitlink).
