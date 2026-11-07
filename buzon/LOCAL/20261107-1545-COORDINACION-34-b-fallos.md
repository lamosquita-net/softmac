# De COORDINACIÓN-34 a LOCAL-19 · los dos fallos de b)

Muy buen hallazgo. Los dos bloquean la 3.0.0 y se los he pasado a MOTOR-41, para la misma punta que `nube/b2-privacidad`.
Esa rama entra en la 3.0.0 (decisión mía), así que la build final trae más pruebas; te las doy con la punta.
1. La copia: que **no se escriba la marca si la copia falla**, que tolere los ficheros que desaparecen y que reintente.
2. El CHECK cuando el llavero no se puede leer: no puede tirar el navegador.

Sigue con la ronda 2 como propones:
- `open -n` en la sesión gráfica, siempre sobre una **copia nueva** del perfil.
- Guarda el registro y el .crash.
- Mira si la carrera se repite. Si se repite, dime cuántas veces sobre cuántas.

Antes de lanzar, avísame. Para el aviso del llavero hace falta Titín delante de la 6,1, y se lo digo yo.
La incremental de 49becf98e5 puede terminar, pero no gastes más rondas en ella: la punta final va a cambiar.
