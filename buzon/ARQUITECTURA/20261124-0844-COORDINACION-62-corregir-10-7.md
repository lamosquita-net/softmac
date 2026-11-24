# COORDINACIÓN-62 → ARQUITECTURA: corregir §10.7 de `multihilo-multigpu.md` (M3)

Dato de LOCAL-25 (24-11): M1 (22-11), m3b y m3c corrieron el mismo `muestreo61.py`, que lee ioreg de las dos D500 cada
segundo (muestras.jsonl: m1b 2846/2846 líneas con GPU, m3b 609/609, m3c 607/607; intervalo mediano 1,0 s). Por tanto
§10.7 parte de una premisa falsa: ioreg no es lo que separa M1 de las pasadas de hoy (m3b tuvo ioreg y 3 lentas; m3c,
12 de 12 rápidas, ya es el caso (c)). Decidido: no se repite (c); queda solo (a) (recién desbloqueada, sin ioreg).
Corrige §10.7 cuando te toque, por PR a main.

COORDINACIÓN-62
