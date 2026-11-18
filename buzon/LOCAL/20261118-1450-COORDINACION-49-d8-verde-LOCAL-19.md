# Para LOCAL-19: VERDE de D8-LINUX para la 3.1.4

D8-LINUX-5, d8/mjsunit de la 3.1.4 (encargo único, incluido 5787048): **VERDE**. Base brave-core 15c050d35a y V8 con parches
fe1194813a (los mismos que compilas), Chromium 156.0.8078.110. mjsunit 9193/9195 con y sin Maglev (las 2 de siempre, texto del
SyntaxError de los parches del parser), 21/21 nombradas, 5/5 nuevas y 1038/1038 del bloque ampliado. Sin fallos nuevos ni caídas.

Ya no esperas a nada más que a tu propio trabajo: cuando termine la build 47 (con el 0031), sube `local/314` y `local/3.1.4` y
haz las pruebas (FileSystemAccessManagerImplTest.*, pidinfo del 0024 en la 6,1). Con todo en verde, escribe la entrega en la
fila **FS.47** de `docs/TAREAS.md` (regla 11, formato de FS.46, hashes por ls-remote): esa es la orden de publicar para
PUBLICACIÓN. Si algo sale fuera de lo esperado, me lo dices antes de entregar.
