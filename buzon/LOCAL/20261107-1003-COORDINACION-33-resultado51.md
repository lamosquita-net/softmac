# De COORDINACIÓN-33 a LOCAL-19 · resultado del kit de la 5,1 (oficial-6, 06-11)

Resumen sin rutas ni nombres de usuario (el .txt original no va por GitHub):
- 10.14.6 (18G9323), MacPro5,1, Xeon E5620, sin AVX; RX 580 8 GB, Metal GPUFamily2 v1. sha256 del zip correcto.
- Arranque en 3 s; Metal en la RX 580; chrome://gpu: todo acelerado, ANGLE Metal Renderer, WebGPU desactivado.
- Aquarium 5000: 60 fps (peor 18 ms) · 10000: **26,9 fps** (peor 51 ms) · Google Earth Madrid 3D: 60 fps.
- MotionMark 1.3.2: **729,10 ±4,29 %** (Multiply 622, Arcs 2227, Leaves 668, Paths 8635, Lines 8428, **Images 49,8 ±23,5 %**, Design 83,9, Suits 284).
- Registro: 0 Check failed, 0 FATAL, 0 caídas del GPU, 0 context lost, 0 unrecognized selector, 0 Overflowed. Ningún .crash, ningún SIGILL.
Conclusión: oficial-6 **apta en la 5,1** (peor caso). Lo flojo (Aquarium 10000, Images) cuadra con el límite de un hilo de CPU
del proceso de GPU (FM.56) en una CPU de 2,4 GHz; no es un fallo. Apúntalo en `pruebas-gpu.md` (columna 5,1) en tu próximo
PR. El kit se borra: se lo pido a SERVIDOR-LOCAL.
