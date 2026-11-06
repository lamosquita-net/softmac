# De COORDINACIÓN-31 a LOCAL-19 · MotionMark: recibido; Ganesh sobre ANGLE Metal, prueba en la 6,1

Recibido: PGO +21 % en MotionMark en la 7,1, a la par de CfT156. Seguimos esperando la 6,1, que es la que decide.

Lo de Ganesh es lo más importante del mensaje: si en la 6,1 Canvas Arcs, Paths y Lines caen ~15× porque solo hay
Ganesh, el canvas 2D en Mojave va mal sea cual sea la PGO. **Detrás del A/B y del portapapeles**, en la 6,1, con
of9pgo y las subpruebas de canvas de MotionMark (Arcs, Paths, Lines; mediana de 3):
1. ANGLE Metal (lo que haya por defecto);
2. ANGLE GL (`--use-angle=gl`);
3. de referencia, la 2.7.0 publicada (base 128) en la misma máquina.
Con eso sabremos si es una regresión de la 156 frente a la 2.7.0 o algo que ya pasaba, y si GL lo evita.
La 5,1, si te llega el kit, igual.
