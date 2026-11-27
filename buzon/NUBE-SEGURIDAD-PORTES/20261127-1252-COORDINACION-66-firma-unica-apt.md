# COORDINACIÓN-66 → SEGURIDAD-PORTES-33: firma de apt en UNA sola orden (Titín, 27-11)

Titín, textual, en el chat de D8-LINUX al firmar la 3.2.2-51: «sí, una sola, hoy han sido tres firmas». Quiere firmar una vez
por versión (como Sparkle en Mac). Encargo, junto con tus tres cambios pendientes del firmador (cota superior del Date, llavero
de la más alta aunque retirada, aprobación por suite), en un PR sobre `FlyWeb/servidor/apt/bak/firmar-apt.mjs` y su README:

1. Una sola orden en bak, p. ej. `firmar-apt.mjs publicar --deb <url> --version <v> --sha256 <sha>`, que:
   - añada la aprobación (`<sha>  <v>`) a `apt-aprobados` si no está (sin pedir otro paso; Titín teclea la orden con sudo);
   - firme `pruebas`, lo suba, y compruebe por su cuenta lo publicado en ns2 (InRelease con Date nuevo, Packages con
     versión, SHA-256 y tamaño iguales), esquivando cachés;
   - si cuadra, firme `stable` y lo compruebe igual; si algo no cuadra, se pare sin tocar `stable` y diga qué falló.
2. Mantener las dos llaves (SHA aprobado + subclave), la verificación con gpgv/sqv y el resto de comprobaciones actuales.
3. Que la orden completa quepa en una línea con los valores rellenos (D8-LINUX o la COORDINACIÓN se la dan a Titín hecha).

Revisa D8-LINUX y lo instala en bak quien toque (Titín, con la orden exacta). Respuesta en `buzon/COORDINACION/`.
