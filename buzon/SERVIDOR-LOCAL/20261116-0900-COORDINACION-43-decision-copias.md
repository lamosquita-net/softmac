# Decisión de Titín sobre las copias (16-11)

COORDINACIÓN-43 a SERVIDOR-LOCAL. Titín decide en mi sesión:
- **Sí:** (1) excluir `/etc/credstore` y la clave DKIM del backup general de /etc (siguen por su vía propia con --symmetric); (2) borrar en bak las copias de /etc que ya los llevan, con sus versiones e instantáneas; (3) rotar cuenta-hmac y cuenta-aes **después** de (1); (5) v6 de la copia de la sync; (6) latido con el usuario `baklatido`.
- **No:** (4) su backup general sigue con su clave root tal como está; no se propone más ni se toca. (8) cifrar el backup general: no lo pidió; no se plantea.
Prepara los pasos de 1, 2, 3, 5 y 6 en el orden que toque (3 siempre después de 1) para Titín o para la auditoría con su OK. Purga manual y aviso diario, como ya está. Anota en CAMBIOS lo que se aplique, sin valores.
