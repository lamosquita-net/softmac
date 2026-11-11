# Estudio: multihilo + multiGPU (decisión de Titín, 11-11)

De COORDINACIÓN-39 (`session_01MwmK2mJmxGn5H9FT1kg9Bo`). Solo estudio, sin código. Entrega en
`FlyWeb/docs/multihilo-multigpu.md` por PR (lo reviso y fusiono yo). La sync de la 3.2 (#905) va primero en el plan;
esto no la retrasa (la revisión de #905 la hace SEGURIDAD-PORTES-21).

**Hipótesis de Titín:** en la 6,1 la GPU ya va al 100 % en las pruebas; solo multihilo daría poco o nada porque el
cuello pasaría a la GPU; hace falta multihilo + multiGPU a la vez.

**Datos que ya hay (no pedir medidas repetidas):** LOCAL-18: Aquarium igual con una o dos D500. LOCAL-21 (#916/#922,
`rendimiento-3x.md`): con la 3.1 el cuello pasa del hilo del proceso de GPU (57–65 %) al hilo del renderer (100 %).
3.1.0 en la 6,1: Aquarium 15k mediana 41,9 fps.

**Preguntas que tiene que contestar, con fuentes (código de Chromium/ANGLE/Metal, docs de Apple, medidas existentes):**
1. ¿«GPU al 100 %» es el hardware (D500) o el hilo de CPU del proceso de GPU? Cómo medirlo bien en la 6,1 si no se ha medido.
2. Multihilo: qué se puede repartir del renderer y del proceso de GPU (decodificación de comandos, contextos WebGL,
   raster) y techo esperado en Aquarium/MotionMark.
3. MultiGPU en macOS/Metal sin peer groups (6,1: dos D500; 7,1: hasta 4 MPX): ¿se puede repartir UN canvas/contexto entre
   GPU o solo contextos/pestañas distintas en GPU distintas? Coste de copiar entre GPU para componer.
4. Para cada opción: ganancia esperada en páginas reales (no solo Aquarium), riesgo, tamaño del porte y qué se rompe
   con cada actualización de Chromium.
5. Recomendación con una puerta medible (qué número tiene que salir para invertir en implementarlo).
Comprobaciones antes de afirmar; si algo es suposición, márcalo.
