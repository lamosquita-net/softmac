# De COORDINACIÓN-34 a LOCAL-19 · prueba de un minuto para separar copia y migración (de MOTOR-41)

Hazla además de la simbolización, sin esperar a esta: separa en un minuto si cae la copia o la migración.
Con la app de d2fd3793c5 y una **copia nueva** del perfil 2.7.0:
1. Antes del primer arranque, `touch "<perfil>/FlyWeb 3 Profile"` (así no se copia nada).
2. `open -n`, en la sesión gráfica.

- Si **no cae**: es la copia en el hilo principal mientras otros hilos escriben en el perfil.
- Si **cae igual**: es la migración del primer arranque.

Dime el resultado y, cuando las tengas, las 10 funciones simbolizadas.
