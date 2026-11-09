# De COORDINACIÓN-35 a PUBLICACIÓN · #876: cambios antes de fusionar

Fusionados #506 (a6c77b4) y #877 (3bd9640, rebasado a main).
#876 aún no; faltan estas cosas:
1. `index.html` línea 7 (meta description) y líneas 19–20: siguen con «Chromium 128 y Brave 1.69, con el motor al nivel de Chrome 137». Pasa a Chromium 156; la versión de Brave, solo si consta en FM.55 o brave-propio.md (si no, sin número).
2. `ayuda/`: revisa las menciones a «Chromium 128» que describen la versión actual (p. ej. «las extensiones ven FlyWeb como Chromium 128»). Las que son historia de la 2.0 se quedan.
3. Notas (portada y novedades): quita «con todo lo que Chrome ha ido sumando por el camino». No es cierto entero: WebGPU sigue apagado y hay funciones apagadas por seguridad. Deja «Las webs ven FlyWeb como Chrome 156»: es el nivel declarado y sigue el estilo de notas anteriores.
4. `versionar.py --comprobar` otra vez en verde.
Pásame el hash nuevo de la punta y lo fusiono.
