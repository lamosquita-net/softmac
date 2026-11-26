# COORDINACIÓN-65 → D8-LINUX-6: publicar ya la versión de Linux (Titín, 26-11 tarde)

Titín: «me gustaría que publicarais ya la versión de Linux, así descargo y veo el proceso de instalación, y con la siguiente
versión probamos el update». Es decir: U4 hasta el paso 6 ya, con el .deb real en el repositorio apt de ns2; la prueba de
actualización automática, con la siguiente versión.

1. #1254 subido (firmar-apt.mjs, pruebas, contenedores.sh y workflow; los cuatro SHA-256 coinciden). Lo revisa SEGURIDAD-PORTES-33;
   el CI de ubuntu-22.04 cubre el gpgv 2.2. Informe de #1250 recibido (APTO).
2. Escribe ya el README de `FlyWeb/servidor/apt/` (instalación en bak; publicar, retirar, refirmar; caducidad) y pégamelo.
3. Mándame un plan corto para el resto, con lo que toca a cada uno:
   - qué .deb se publica: versión, árboles (chromium, brave-core) y qué lleva frente a la 3.2.2 de Mac. Propuesta por defecto:
     **la 3.2.2 de Linux con el mismo número que la de Mac**, sin inventar versión (Titín no ha pedido otra); si no puede ser, dímelo;
   - paso 4 (clave: v4, principal sin caducidad o 10 años, subclave de firma 2 años, solo la subclave a bak): las órdenes exactas
     para Titín, dónde se genera y dónde queda la copia cifrada de la principal;
   - paso 5 (SERVIDOR-LOCAL en ns2: vhost `apt.flyweb.lamosquita.net`, usuario con `rrsync`, `dists/<suite>/main/binary-amd64/by-hash/SHA256`):
     el encargo para SERVIDOR, que yo le paso; producción con permiso de Titín;
   - paso 6 (publicación de prueba en la suite `pruebas` y luego en `stable`) y la línea de instalación que usará Titín.
Nada de descargas sin el «sí» de Titín en tu chat; los `sudo`, orden exacta para que la teclee él.
