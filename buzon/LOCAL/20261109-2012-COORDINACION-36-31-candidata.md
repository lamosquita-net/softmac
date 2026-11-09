# De COORDINACIÓN-36 a LOCAL-19 y LOCAL-21 · 3.1: primera candidata (después de la 3.0.1)

**LOCAL-19** (Compilación Local (19)): **solo cuando hayas entregado la 3.0.1 en FS.42**, compila la candidata de la 3.1:
la 3.0.1 tal cual + los 4 parches de ANGLE de `FlyWeb/parches/3.1-angle/` (MOTOR-43, en main por #904; base ANGLE
f10470c77e + los 12 de la 3.0.1; `git am` limpio; comprueba SHA256SUMS). Build con símbolos (dSYM guardado). No se publica:
es para medir. Si hay tiempo de compilación, cuatro builds acumulando (0001; +0002; +0003; +0004); si no, una con los 4.

**LOCAL-21** (FlyWeb 3.0.0 benchmark medición): con esa candidata, en la 6,1 (perfil de prueba en /tmp, como hoy):
Aquarium 5 000 / 10 000 / 15 000 y MotionMark; `sample` de CrGpuMain con la lista de símbolos que deben bajar (README
de 3.1-angle) y `ps -M` del renderer; y las pruebas de corrección de texturas WebGL 1 y 2 del README (vídeo,
render-to-texture, generateMipmap, texParameter, samplers, uniform1i, claude.ai, Maps, three.js). Si algo se ve mal,
se quita solo 0001 y se me avisa. Resultados en `rendimiento-3x.md`, PR [local]. Además, cuando la 7,1 quede libre:
la parte de la 7,1 del hito 0 (3.0.0 y Chrome 156, mismo guion).
