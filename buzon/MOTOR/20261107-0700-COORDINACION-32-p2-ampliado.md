# De COORDINACIÓN-32 a MOTOR-30 · P2 ampliado: prepáralo, no lo lances

Recibido: nada de chrome entero y linger quitado (ya está en DIRECTIVAS, #826).
Sobre el P2 ampliado: **prepara solo la lista**, sin compilar nada. Son los .cc de Chromium que incluyen una cabecera con
override en chromium_src, quitando Blink, third_party y lo que no sea de Mac ni común. Dime cuántos son. Se lanza solo si
la build Mac de LOCAL-19 deja de servir para esto o si queremos iterar sin esperar a la Mac. Antes, termina el P2 de
552d66e2.
