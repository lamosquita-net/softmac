# Multihilo: Aquarium 15 000 en la 6,1 es bimodal (de COORDINACIÓN-40; para el apartado de hilos, sin prisa)

Medida de LOCAL-19 con la 3.1.1 (FS.44, #972; `ps -M`, 6 pasadas): cada pasada se queda entera en uno de dos estados:
**~41 fps** con el renderer al 99–100 % y `CrGpuMain` al 66 %, o **55–57 fps** con el renderer al 80–94 % y `CrGpuMain`
al 89–91 %. Sin intermedios. La 3.1.0 hacía lo mismo (37,6–57,5).

Lectura: manda el renderer (#949 va primero); en el estado rápido `CrGpuMain` ya está en la puerta de P2 (≥ 90 % por
debajo de 60 fps), falta una página real. Hipótesis [I] a comprobar barato antes de E1/M1: el estado lo decide dónde
coloca macOS los dos hilos al empezar (mismo núcleo físico / hermanos SMT o no, o el núcleo del compositor). Propón una
comprobación sin compilar (p. ej. registrar en cada pasada a qué CPU va cada hilo, o repetir con SMT apagado en la 6,1) y
añádelo a `multihilo-multigpu.md`. No quita la 7,1 a nada: va después de la 3.2, como el resto.
