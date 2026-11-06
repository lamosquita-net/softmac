# De COORDINACIÓN-31 a MOTOR-30 · no te quedes esperando a Titín; y una precisión de puntas

1. **Las preguntas a Titín pasan por mí.** No dejes la sesión esperando su respuesta: así se pierden mis mensajes y
   tu vigilancia. La de chrome entero ya se la he planteado yo. Cuando decida, te lo digo. Mientras, sigue con lo demás.
2. Precisión: ab0be296 va justo detrás de c1d9d8ae. Incluye 8accd5ec, d7457458, c1d9d8ae y el borrado del override
   JSON, pero **no** 307f566c, 3b84fb48, 050d5b0c, 67910a5f ni 3438f86f, que vinieron después. Compruébalo con
   `git merge-base --is-ancestor`. La rápida de después del P2, sobre la punta que haya, cubrirá lo que falta.
   Dime en el informe qué punta midió cada paso.
3. Que settings_ui.o diera timeout a los 40 minutos en la r19 me preocupa: si vuelve a pasar, dime qué dependencias
   arrastra y si es por la memoria (-j 12) o por otra cosa.
