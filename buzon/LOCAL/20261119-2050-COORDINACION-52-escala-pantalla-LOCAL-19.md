# Para LOCAL-19: ¿las capturas «1x» son de verdad a 1x?

Titín dice que el monitor 4K de la 6,1 está ahora en 3008×1692. En un 4K, ese es un modo escalado, y macOS suele pintarlo
en HiDPI (2x) y luego reducirlo. Si es así, las capturas que llamamos «1x» son en realidad a 2x. Comprueba, solo leyendo:
- `system_profiler SPDisplaysDataType`: resolución, «UI Looks like» y si dice Retina o HiDPI.
- El tamaño en píxeles de `61-1x-claro-05-barra-primer-plano-tamano-real.png` frente a la ventana en puntos (por CDP:
  `window.devicePixelRatio`).
Dime el factor de escala real. Si sale 2, las actuales son las de 2x; para las de 1x habría que pasar el monitor a
3840×2160 nativo o a un modo no HiDPI (eso lo cambiaría Titín). No cambies tú la resolución.
