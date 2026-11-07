# De COORDINACIÓN-34 a ARQUITECTURA · estudio: cómo avanzar después de la 3.0.0

La 3.0.0 (base 156) se publica hoy. Titín ha fijado las versiones (DIRECTIVAS, «Versiones desde la 3.0.0», #859):
el **segundo dígito** (3.1, 3.2…) son nuestros avances; el **tercer dígito** (3.0.1…), tandas de seguridad al ritmo de
Chrome estable más arreglos. Titín quiere que empieces ya el estudio y se lo presentes; él decide.

**Qué pido, en un documento nuevo `FlyWeb/docs/plan-3x.md` (PR [arq]; lo reviso y fusiono yo):**
1. **Contenido y orden de la 3.1, 3.2…** Punto de partida: la directiva del 05-11 noche, con rendimiento primero (PGO,
   GPU, hilos y varias GPU, Maglev con sus tres condiciones de B6, OpenGL de comparación). claude.ai es criterio de
   aceptación en cada versión. Para cada avance: qué se gana (medido o con fuente publicada), su coste, su riesgo y la
   máquina donde se mide (la 6,1, la 5,1 o las ocasionales con Intel o NVIDIA).
2. **Cómo convive con la seguridad.** SEGURIDAD-PORTES-19 empieza ya el inventario de CVE posteriores a la 156.0.8078.90
   para la 3.0.1. Propón cómo se reparten la capa de seguridad y la de avances sin pisarse: ramas, cadencia y quién compila
   qué. Usa la medida mensual de «cuántos entran limpios».
3. **Cuándo hace falta otra base.** Con qué datos se decide (porcentaje de CVE con conflicto, divergencia con Chrome) y
   con qué umbral.
4. **Riesgos conocidos que hay que tener en cuenta:**
   - Sparkle 1.24.3 sin mantenimiento (valorar la 2.x);
   - CFBundleVersion 198.63.N, que viene de Brave y debe seguir creciendo;
   - lo pendiente de la 3.0.x en la fila de MOTOR (b2-tests, b2-depfile, b2-redirect-cc, Shields, WebGPU, Containers,
     UpdateTargetURL).

Sin estimaciones de horas: solo hitos y criterios. Las dudas, a mí. Contéstame con el plan de trabajo que vas a seguir antes
de redactar.
