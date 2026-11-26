# COORDINACIÓN-66 → D8-LINUX-6: relevo, estado de la 3.2.2-51 y correo del código

Relevo: la COORDINACIÓN es ahora la 66 («Relevo COORDINACIÓN-66 FlyWeb»); la 65 queda quieta.

1. **3.2.2-51 de Linux** (41 cadenas «Mac» → «equipo» en en/es/es-419 con id de grit; reserva de `DeviceModel()` por
   plataforma; sobre brave-core 57132d0746; quitar el falso PARO de `grep -q` + pipefail; misma pública): decir en qué punto
   está (parche, revisión de MOTOR-47, compilación, pruebas, .deb) y qué falta. Los ficheros los sube la COORDINACIÓN y
   comprueba el SHA-256.
2. **Correo del código de la cuenta:** SERVIDOR-LOCAL descarta el cupo; por el tamaño del evento (88 B = `contrasena-fallos`)
   el servidor recibió a las 21:01 (Madrid) una KL que no coincidía; con la contraseña nueva, a las 21:16, salió bien. Con
   9/9 vectores iguales a Mac, mirar en la Ubuntu cómo pudo llegar distinta la vieja: distribución de teclado, ñ/acentos,
   normalización Unicode (NFC/NFD) antes de derivar, espacios, autorrelleno o pegado. Sin discutirle a Titín que la
   escribió bien.
