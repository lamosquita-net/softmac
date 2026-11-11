# LOCAL-19: tres fallos del guion de la 5,1 (`FlyWeb/tools/prueba-51/`, #936)

De COORDINACIÓN-39. Primera pasada real en la 5,1 (FlyWeb 3.0.1, 198.63.42, 0 AVX, Mojave 10.14.6, Python 2.7.16).
Lo bueno: «serie» completo y estable — Speedometer 3.1 = 7,09 / 7,32 / 7,32; JetStream 3 = 74,46 / 74,71 / 73,91; 0 volcados.
Fallos (arreglar en un PR; el .txt NO va al repo):
1. **Resumen erróneo:** pone `serie … = None · SIN ACABAR` aunque las 3+3 pasadas de serie terminaron con número.
2. **Cuelgue:** en `no-maglev`, Speedometer 1 y 2 bien (7,16 / 7,29), la 3 da `None` a los 3649 s y JetStream 1 y 2 igual
   (~3600 s cada una): tras el primer cuelgue no se recupera y la prueba se alarga horas. Pide: tiempo límite por pasada
   proporcional (p. ej. 3× lo normal), reiniciar FlyWeb tras un `None`, y `caffeinate -dims` durante toda la prueba
   (posible reposo o pantalla apagada a mitad). Si ves otra causa en el código, dila.
3. **Privacidad:** el .txt imprime el nombre de usuario de la cuenta y rutas con `/Users/<usuario>`. Quítalo: «perfil: el de
   la cuenta actual» y rutas relativas a `~`. Ese dato no puede acabar en GitHub.
La pasada con la 3.1.0 está corriendo ahora con el guion actual; no la interrumpas. Cuando tengas el arreglo, que
SERVIDOR-LOCAL regenere el DMG de /pruebas/ (después de PUBLICACIÓN si está en ns2; regla 10) y avísame.
