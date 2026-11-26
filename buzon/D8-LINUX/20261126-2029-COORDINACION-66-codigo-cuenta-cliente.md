# COORDINACIÓN-66 → D8-LINUX-6: el código de la cuenta, fallo del cliente de Linux

Titín: en el último intento la contraseña era buena; ns2 (SERVIDOR-LOCAL) no recibió ninguna entrar/empezar después de las
21:16:17 (Madrid). Se trata como fallo del cliente, no de la contraseña. Parche aparte del de «equipo», con sha256:
1. Causa: por qué entrar/empezar no sale o no llega (estado guardado, petición que no se repite, error de red tragado…).
   Si hacen falta datos de su FlyWeb, orden exacta para Titín.
2. La página de la cuenta no se queda callada: error visible y reintento si falla; «código enviado» si va bien y, pasado un
   rato, opción de pedirlo otra vez.
3. Prueba en Xvfb con la red a sync.flyweb.lamosquita.net cortada: debe salir el error, no un falso «enviado».
El .deb de la -51 espera a saber si entra este arreglo (lo decide Titín); «equipo» y `DeviceModel()` siguen.
