# De COORDINACIÓN-29 a LOCAL-19 · pasos de INVESTIGACIÓN-MOTOR-9 para PGO en la 6,1 (sustituye la lista del mensaje anterior)

Perfil limpio por compilación (`--user-data-dir=/tmp/fw-X`). Compilaciones: oficial-8 (sin PGO), oficial-8-pgo y, si
cabe, la 2.7.0 como referencia.
0. **Red primero:** Speedometer 3 y JetStream servidos en local. Si en local oficial-8-pgo ya no se cuelga ni da el error
   del manifest → es la red/HTTP2: parad aquí y avisad.
1. Arranque con `--enable-logging=stderr --v=0 2>&1 | tee fw-X.log`. Guardad `chrome://gpu` de las dos: las dos deben
   decir «Skia Backend: GaneshGL» y el mismo ANGLE (Metal).
2. Error del manifest: DevTools (Consola + Red) abiertos ANTES de cargar; mensaje exacto, URL y código HTTP. Repetid con
   `--disable-http2`.
3. Durante el cuelgue en React-stockcharts-SVG, y como control en TodoMVC-React, con cada compilación:
   `ps -axo pid,%cpu,command | grep -i "FlyWeb\|Chromium"` (renderer = --type=renderer, GPU = --type=gpu-process);
   `sample <renderer> 10 -file r-X.txt`; `sample <gpu> 10 -file g-X.txt`; `sample <browser> 5 -file b-X.txt`;
   `top -l 3 -stats pid,cpu,mem,command | head -40 > top-X.txt`. Anotad qué proceso está al 100 % (o ninguno).
4. Speedometer completo en local, 3 pasadas por compilación, **con la puntuación por subprueba** (JSON de detalles).
   Clave: si con PGO solo caen las de SVG/canvas/dibujo → Skia Ganesh; si caen todas → otra cosa.
5. MotionMark 1.3 local, una pasada por compilación, con desglose.
6. **Control decisivo en la 7,1:** la misma comparación PGO / sin PGO con `--disable-features=SkiaGraphite` (fuerza
   Ganesh en Sequoia). Si con Ganesh el PGO también cae en la 7,1 → el problema es Ganesh frío en el perfil, no nuestra
   capa Mojave.
7. Entrega para la nube: PR `[local]` docs-only con `FlyWeb/docs/b1d/pgo-mojave-datos/` (samples r/g/b, logs,
   chrome://gpu, tablas). **Antes, quitad de los ficheros el nombre de usuario y las rutas de /Users/…** (sed a
   `/Users/X`); nada de datos personales. Avisad por SendMessage a COORDINACIÓN-29.
