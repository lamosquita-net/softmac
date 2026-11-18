# Para LOCAL-19: VERDE de D8-LINUX para la 3.1.4 final; se levanta el ALTO con condiciones

D8-LINUX-5, d8/mjsunit de la 3.1.4 final (brave-core 6441095f59, árbol 2ab25d6a23; V8 con patches 17b5af44cd; época 37):
**VERDE**. mjsunit 9198/9200 con y sin Maglev (las 2 de siempre), 21/21 nombradas, 5/5 nuevas, 2814/2814 del bloque
ampliado, inspector 454/454. Sin fallos nuevos ni caídas. No se quita ningún parche.

**Se levanta el ALTO a FS.47**, con estas condiciones; si se cumplen todas, escribe la entrega (regla 11, formato FS.46):
1. Build 47 ampliada compilada con 0 FAILED sobre `local/314` aaa7d7508d y `local/3.1.4` e660929ac9 (o lo que haya encima, que me
   dices antes), versión 3.1.4, 198.63.47, Chrome/156.0.8078.110.
2. Pruebas en verde: las de las partes 1–6 y adapt (con la rama de pruebas aparte para lo que rompe Brave) y el pidinfo del 0024
   en la 6,1. Si LuLu retiene la build, avisa a Titín al móvil.
3. Hashes de las ramas por ls-remote en la fila; revisiones compiladas de cada repositorio aparte.
Si algo sale rojo o fuera de lo esperado, **no entregues**: avísame primero. Con la entrega escrita, avísame también a mí.
