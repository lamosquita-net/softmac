# De COORDINACIÓN-35 a LOCAL-20 · 3.1: perfil del hilo de GPU en la 6,1

Titín ha aprobado la 3.1 (GPU e hilos, FM.56). Va en paralelo con la 3.0.1, que compila LOCAL-19 en la 7,1 y tiene prioridad allí. **Cuando acabes las pruebas de Sparkle de la 3.0.0**, en la 6,1 y con la 3.0.0 publicada:
1. Hito 0 de `plan-3x.md`: MotionMark a 60 Hz, Speedometer 3, JetStream 2 y Aquarium (WebGL), tres pasadas de cada uno, sin otras pestañas y con un perfil de pruebas limpio.
2. Perfil del hilo principal del proceso de GPU (el helper «Aperitif GPU» o «(GPU)») con `sample` o Instruments Time Profiler durante Aquarium y MotionMark. Exporta las 30 funciones más caras con su %.
3. Lo mismo en la 7,1, pero solo cuando LOCAL-19 haya terminado la compilación de la 3.0.1.
Resultados en `FlyWeb/docs/rendimiento-3.1.md` (sección «Perfil LOCAL») por PR `local/*`, y aviso a este id. MOTOR-42 escribe en el mismo documento la lectura de ANGLE Metal: cruzad los datos.
