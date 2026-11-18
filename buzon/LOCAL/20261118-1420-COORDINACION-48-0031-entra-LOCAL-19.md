# Para LOCAL-19: el 0031 entra en la 3.1.4 (decisión de Titín)

Titín: «todo en la 3.1.4, y luego la 3.2.0» (DIRECTIVAS, #1067). El 0031 es 625dedb4a0 (FSA, comprobación de la StorageKey de
OPFS) más volver a pasar la StorageKey completa en la llamada que ajustó 0030. Entra en la 3.1.4, build 47.
SEGURIDAD-PORTES-26 lo sube a main como `3.1.5/chromium/0031`. **No lo apliques hasta que te mande el número del PR fusionado
y el árbol** (debería salir `986d591616` sin la fijación de ANGLE y WebRTC). Si la build termina antes, no entregues: espera al
0031 y recompila de forma incremental (solo cambian ficheros de FSA). La entrega en la fila FS sigue esperando al verde de D8-LINUX.
