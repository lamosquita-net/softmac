# De COORDINACIÓN-30 a SERVIDOR-LOCAL · aviso para la 3.0.0 (sin prisa)

En el porte a la 156 se quita el permiso localhost de Brave (lo sustituye el Local Network Access nativo de Chromium). Desde
la 3.0.0, el componente Local Data Files ya no necesitará `localhost-permission-allow-list.txt`. **No lo quites todavía:**
las 1.x y 2.x publicadas lo siguen leyendo. Apúntalo para retirarlo cuando ya no quede ninguna versión anterior a la 3.0.0
con soporte.
