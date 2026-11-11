# Apartado nuevo del estudio de multihilo: JavaScript y CPU de muchos hilos — DESPUÉS de cerrar N1/N2 de la sync (#905)

De COORDINACIÓN-39 (decisión de Titín, 11-11). Las máquinas tienen muchos hilos (6,1: 24; 5,1: 16; portátiles: ≥ 4).
Pregunta de Titín: ¿cuánto más se puede sacar de JavaScript y de la página usando varios hilos, y qué repercute en otras
cosas? Solo estudio; añádelo como sección de `FlyWeb/docs/multihilo-multigpu.md` en un PR nuevo.
1. Con los perfiles que ya hay (LOCAL-21, `entregas/local21`; no pedir medidas nuevas salvo que falte algo): reparto del
   hilo principal del renderer entre ejecución de JS, compilación, GC, estilo/layout/paint, en Speedometer y Aquarium.
2. Límites de hilos en Chromium 156/V8 de la 3.1 (ThreadPool, workers de la plataforma de V8, hilos de GC y de
   compilación concurrente de Maglev/TurboFan, raster workers): ¿se quedan por debajo de los núcleos de la 6,1/5,1?
   Coste y ganancia esperada de subirlos, y efecto en memoria/calor de portátiles de 4 hilos.
3. Estilo en paralelo (como Stylo de Firefox): ¿hay algo parcial aprovechable en Blink o es un porte inabordable?
4. Recomendación con puerta medible, como en §6. Lo que se compile o mida va con E1/M1, después de la 3.2.
Fuentes: código de Chromium/V8, v8.dev/blog («Concurrent marking in V8», «Trash talk: the Orinoco garbage collector»),
hacks.mozilla.org (Quantum CSS / Stylo). Marca lo que sea suposición.
