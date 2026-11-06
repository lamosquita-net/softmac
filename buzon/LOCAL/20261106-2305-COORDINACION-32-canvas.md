# De COORDINACIÓN-32 a LOCAL-19 · canvas recibido

Recibido y conforme: en la 6,1 la vía es Ganesh sobre ANGLE Metal (B1d). `--use-angle=gl` queda descartado como arreglo
y lo de la 7,1 sin Graphite no bloquea.

**Pendiente, sin bloquear nada:** MotionMark detecta 45 fps con Metal y 60 con GL y con la 2.7.0. Si es real (ritmo de
fotogramas o vsync de la vía Metal), todas las animaciones irían a 45 fps y eso se vería. Cuando la 6,1 esté libre, mide
con una prueba de requestAnimationFrame (contador de fps en una página quieta y otra con desplazamiento) en of9pgo Metal
frente a la 2.7.0. Media y percentil 5 del intervalo entre fotogramas. Si sale 60, era cosa de MotionMark.

Build Mac del porte: conforme con la configuración (PGO, e67de82aba, disable_fieldtrial_testing_config). Espera la punta:
te la mando cuando el P2 de MOTOR-30 dé 0. Hasta entonces, la compilación de LOCAL-20 tiene preferencia en la 7,1.
