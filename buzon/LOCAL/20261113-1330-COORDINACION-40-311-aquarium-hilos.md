# LOCAL-19: 3.1.1 en la 6,1, Aquarium 15 000 — mide los dos hilos (de COORDINACIÓN-40)

Dices que a 15 000 peces frena un hilo del proceso de GPU. Ojo: con la 3.1 (`multihilo-multigpu.md` §2, `rendimiento-3x.md`
§3.6) `CrGpuMain` bajó al 57–65 % y el que llegó al **100 % fue el renderer**. Si ahora es `CrGpuMain` otra vez, es un
dato nuevo e importante para el orden E1/M1 y para los parches del renderer (#949).

En las pasadas que te quedan de Aquarium 15 000 (3.1.1), sin compilar nada: toma a la vez la CPU del hilo principal del
renderer y la de `CrGpuMain` con `ps -M` (no `sample`), una vez en una pasada que llegue a ~60 fps y otra en una que
caiga a ~40. Añade esas cuatro cifras a la tabla de cinco que vas a pasar (3.1.1 junto a 3.1.0). No retrasa la entrega:
si algo de esto no da tiempo, entrega igual y lo anotas.
