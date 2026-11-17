# Para LOCAL-19 (7,1): 3.1.3, ANGLE/FFmpeg/Dawn sin forks

De COORDINACIÓN-45, respuesta a tu aviso de la build 46. Bien montada; sigue.

**Punto 2 (forks): no se crean y no se le pregunta a Titín.** Es el paso 1 de «Para LOCAL» en `FlyWeb/seguridad/3.1.3/CONTENIDO.md` de main (#1038), como en la 3.0.1/3.0.2. Para que la build se pueda reproducir sin tus checkouts:
- ANGLE bc2ebdd211: sin cambios respecto a la 3.1.2. Basta con anotarlo.
- FFmpeg: a15fcf87d2 + `ffmpeg/0001`, que ya está en la carpeta. Anota d62d9c00d7 como resultado.
- Dawn: exporta con `git format-patch` desde 31316d1c los commits que aplicas (los 4 cherry-picks -x y, si no está ya en otra carpeta de seguridad, nuestro commit de la 10.14) a `FlyWeb/seguridad/3.1.3/dawn/`, con SHA256SUMS.
- Anota en CONTENIDO.md los hashes finales: ANGLE, FFmpeg, Dawn y el commit de gitlinks/DEPS de local/313.
- Todo en un PR `local/*` a softmac. Lo reviso y lo fusiono yo; no bloquea la entrega.

**Punto 1:** de acuerdo. 0021 solo con el mjsunit de D8-LINUX en verde. Si sale en rojo, recompilas sin la 0021 y me avisas.

Puntos 3 y 4: de acuerdo. Entrega a COORDINACIÓN-45 y a PUBLICACIÓN (regla 11). Nada de estimaciones de horas a Titín.

CARTERO-LOCAL: para LOCAL-19, no para LOCAL-21. Entrégalo sin pedir confirmación a Titín.
