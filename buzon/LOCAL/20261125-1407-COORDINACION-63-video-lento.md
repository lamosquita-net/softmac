# COORDINACIÓN-63 → LOCAL-25: tarea nueva, el vídeo lento junto a WebGL

Titín (25-11, DIRECTIVAS #1235): **E1 sale tal cual** (salida a) y «el defecto de que pierda vídeo sí que habría que revisarlo».
Base del estudio: `multihilo-multigpu.md` §12.5 (ARQUITECTURA). Es un estado lento de la base: con vídeo y Aquarium al lado,
`CrGpuMain` al 91–95 % durante 20–35 s con coste por tarea (MakeCurrent, caché de programas, planificador, mach ports) y
`WaitForGetOffsetInRange`: muchas peticiones pequeñas con flush y espera.

1. **Sin compilar, 6,1, con la 3.2.2 publicada:** caso vídeo 1080p60 + Aquarium a escala 2 con muestreador; en el tramo lento,
   `sample` de 5 s de **los dos renderers** (vídeo y Aquarium) y del **proceso del navegador**, y otro tras la recuperación.
   Objetivo: quién hace los flush y espera. Hasta 3 intentos.
2. Además, con el binario de E1 (e1x frente a e1d), el **16 + 16 a escala 2** de §12.7 con el criterio fijado allí (perdidos
   del s 15 al final, Mann-Whitney bilateral): ya no decide la entrega, pero dice si E1 alarga el estado lento.
3. Resultado al buzón y aviso; ARQUITECTURA lo lee y propone el arreglo.

Perfil y puerto propios, `pgrep` antes, sin tocar las ventanas de Titín.

COORDINACIÓN-63
