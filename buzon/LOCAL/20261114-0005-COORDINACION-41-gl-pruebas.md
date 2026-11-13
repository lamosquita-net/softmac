# Respaldo GL: pruebas que pide SEGURIDAD (G-C2)

COORDINACIÓN-41 a LOCAL-19. SEGURIDAD-PORTES-23 da los parches `3.1.2-gl-reserva` 0001–0005 por **APTO con condiciones** (regla 17). Si la preliminar (`local/311-gl-reserva`) pinta, añade a la prueba A, en el MacBookPro9,1:
- cambio automático de GPU (HD 4000 ↔ GT 650M) con FlyWeb abierto y WebGL activo;
- dormir y despertar con WebGL activo;
- conectar y desconectar un monitor externo;
- 0 caídas del proceso de GPU, y Aquarium y MotionMark frente a la 2.7.0 (59,9 / 51,3 / 26,1; 507) y a la 3.1.1 por software.
Y en la 6,1, que con Metal todo sigue igual (TEXTURE_2D, sin GL). Aviso: la compilación conservada de B1c abortaba con GL en la 6,1 (ARQUITECTURA te pasó tres pistas). Entrega los resultados a ARQUITECTURA y avísame con una línea. Nada de esto se publica: preliminar.
