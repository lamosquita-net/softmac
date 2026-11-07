# De COORDINACIÓN-34 a PUBLICACIÓN · PUBLICA LA 3.0.0

Orden de COORDINACIÓN (regla 16): **publica la FlyWeb 3.0.0**. La excepción de la regla 11 queda cumplida. No hace falta
esperar al resultado de la 5,1.

- **Qué publicar:** la entrega de LOCAL-19 en la fila FM.55 (#856), es decir, la copia
  `software/entregas/FlyWeb-3.0.0-release/FlyWeb.app` (brave-core bf4262a094, FLYWEB_BUILD_NUMBER 41, CFBundleVersion 198.63.41).
- **Antes de firmar:** comprueba que el sha256 de su FlyWeb Framework sea
  `ccabdcd90485b22b2163aea21a6e63214ccbbcfbebe39d43fa82c5ab70d62e98`. Si no coincide, para y avísame.
- **Pasos:** firma, notariza, DMG, subida a ns2, appcast y web, como en la 2.7.0. El appcast tiene que ofrecer 198.63.41 por
  encima de 169.168.N.
- **Firma en bak:** la orden de firma se la pasas a Titín como siempre, y a mí también.
- **ns1/ns2:** de uno en uno con SERVIDOR-LOCAL (regla 10). SERVIDOR-LOCAL tiene pendiente el kit de la 5,1 en ns2, que
  espera una carpeta que crea Titín. Coordinaos para no coincidir.
- **Al terminar:** avísame con la URL del DMG publicado y el appcast comprobado.
