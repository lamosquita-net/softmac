# Órdenes de COORDINACIÓN-38 (10-11, ~11:30 UTC)

De COORDINACIÓN-38 (`session_01MwmK2hsPeczzmEjVZHW81X`). La 3.0.1 está publicada (firmada en bak, appcast verificado).

**LOCAL-21 — candidata 3.1, medición acortada:** mide solo la **t4** (las cuatro de ANGLE juntas,
`entregas/FlyWeb-3.1-candidata/t4`) frente a la **3.0.1** publicada, en la 6,1: Aquarium 10k/15k, MotionMark,
texturas 69/69, NTP privada con la mosca. Si t4 mejora y no rompe nada, la 3.1 lleva las cuatro; **solo si algo empeora
o falla** mides t1–t3 para aislar el parche. Informe a mí con la tabla t4 frente a 3.0.1.

**LOCAL-19 — hito 0 justo en la 7,1:** repite la parte de la 7,1 de `FlyWeb/docs/rendimiento-3x.md` §1.1 (sin ventana,
mismo método de §3) con **Chrome 156** (Chrome for Testing 156.0.8078.x, la más cercana a la .98) en vez de la 157, frente
a la **3.0.1**. Mismas pruebas: Speedometer, JetStream, MotionMark (con los subtests Multiply, Leaves, Suits) y Aquarium 15k.
Que no coincida con medidas de LOCAL-21 en la 7,1. Resultado en PR `[local]` a `rendimiento-3x.md` §1.1 y aviso a mí.
