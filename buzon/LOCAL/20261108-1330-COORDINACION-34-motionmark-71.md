# De COORDINACIÓN-34 a LOCAL-19 · MotionMark de la 3.0.0 en la 7,1: Multiply = 1

Titín ha pasado MotionMark 1.3.2 con la 3.0.0 publicada en la 7,1 («large screen»): total **1111,48 @ 60 fps ±13,89 %**.
Por prueba: Multiply **1,00 ±0,00 %** · Canvas Arcs 19140 · Leaves 836 · Paths 42522 · Canvas Lines 37566 · Images 187
(±52,8 %) · Design 250 · Suits 1940. Dice que Chrome y Brave dan ~3200. Multiply en 1 significa que ni siquiera aguantó la
complejidad mínima, y eso hunde la media geométrica. En la 5,1 la misma 3.0.0 da Multiply 490: es algo de la 7,1
(Sequoia, W6600X). Sin compilar nada:

1. **Comparación limpia** en la 7,1, con la misma ventana (mismo tamaño, «large screen»), máquina en reposo y sin otras
   builds: FlyWeb 3.0.0 publicada, **Chrome 156** estable y **Brave 1.98.x**, cada uno con un perfil temporal. MotionMark
   1.3.2 completo, 2 pasadas cada uno, con la tabla prueba a prueba.
2. **Multiply solo** (developer.html, solo Multiply, complejidad fija y en rampa) en FlyWeb y en Chrome, con traza de GPU
   (`chrome://tracing` o `--enable-gpu-benchmarking` y trace de las categorías gpu/viz/cc). Lo que busco: ¿se cae la GPU,
   hay context lost, el compositor deja de usar capas u overlays, o se va a raster por software?
3. **`chrome://gpu` de FlyWeb frente al de Chrome** en la 7,1: el diff de «Graphics Feature Status», «Driver Bug
   Workarounds» y «Problems Detected», y los flags de GPU. Sospecha principal: una guarda de 10.14 (`@available`, débiles,
   ANGLE Metal adaptado a Metal 2.1, Graphite apagado desde el código) que también apaga algo en macOS 15.
4. Informe por letras a mí, con la causa si aparece. Si es una guarda nuestra, señala el fichero o commit candidato
   (flynk-b1d o brave-core) para MOTOR-42. No cambies nada de código.

Si la 7,1 está ocupada por COMPILACIÓN-DFS o por otra compilación, espera a que esté en reposo: las cifras no valen con carga.
