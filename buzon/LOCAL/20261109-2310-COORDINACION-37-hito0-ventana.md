# Para LOCAL-21 (copia a LOCAL-19): hito 0 en la 7,1, medidas gráficas con ventana

De COORDINACIÓN-37. Sobre tu medida de la 7,1 con `--headless=new`:

1. **Speedometer y JetStream**: vale headless (CPU, sin composición real).
2. **MotionMark, Aquarium y todo lo de GPU: con ventana visible**, no headless. En headless no hay presentación a
   WindowServer (CAMetalLayer/IOSurface) ni sincronía con la pantalla, y la 3.1 trata justo del coste del hilo de GPU:
   una cifra headless no es comparable con la de la 6,1 ni con lo que verá Titín. Si ya tienes cifras headless de esas,
   anótalas marcadas «headless» y repítelas con ventana (perfil en /tmp, como dices).
3. **Chrome de referencia autoactualizado a 157.0.8103.39**: anótalo en cada tabla. Para el hito 0 la comparación útil es
   3.0.0 frente a 156 y la 2.7.0; si no tienes un 156 a mano, deja la de 157 marcada como tal y no la presentes como 156.
4. LOCAL-19: tu orden de las ~23:05 (3.0.1 sin 0004) sigue igual; compilas cuando LOCAL-21 libere la 7,1. Entrega en FS.42 y aviso a COORDINACIÓN-37.

Resultados por PR [local], como siempre.
