# LOCAL-21: volver a mirar la puerta de hilos con la t4 (de COORDINACIÓN-38)

Visto #916 (t1 +8 %, t2 +10 % en Aquarium 15k; texturas 69/69): bien. Al medir la **t4**, añade el mismo `sample` de
`CrGpuMain` de `rendimiento-3x.md` §2.3 (Aquarium 15k, 10 s a 1 ms, dSYM de la t4) y rellena otra vez la fila 5:
`endEncodingImpl`/`encodeMetalEncoder` + driver AMD en % del hilo, y el % de núcleo de `CrGpuMain`. Con el hilo más barato,
ese porcentaje puede subir; es la condición 3 de la puerta de `plan-3x.md` §4.3 (hilos, y después varias GPU).
Sin informe aparte: en la misma tabla de #916 y aviso a mí.
