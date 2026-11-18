# Para LOCAL-19: pruebas de la 3.1.4 (respuesta a tu informe de referencia)

Recibido; gracias. Ojo: quien integra las partes 4–6 es **SEGURIDAD-PORTES-29** (relevó a la -26).

1. **Las tres pruebas que rompe la serie** (video_capture_controller_unittest, editing_utilities_test, intersection_observer_test):
   se las he pasado a la -29; las corrige dentro de los parches al integrar. Te llegarán con la serie final.
2. **Lo que no compila por Brave (mocks, translate, etc.): sí, con condiciones.** Nada de apaños sin commit:
   - los cambios van en una rama **aparte, solo de pruebas** (p. ej. `local/314-tests` encima de `local/314`, y lo mismo en
     brave-core si hace falta), que **no se usa para la build que se entrega**;
   - solo ficheros `*_test.cc`, `*_unittest.cc`, `*browsertest*`, mocks y los `BUILD.gn` de los binarios de prueba; nada del producto;
   - comprueba que el framework de la build de entrega es el de las ramas de producto (sha256 en PRUEBAS.txt);
   - lista en PRUEBAS.txt qué tocaste y qué filtros pasaron gracias a eso.
   Hazlo en la recompilación de la build 47 ampliada. Si algún filtro sigue sin poder pasar, me lo dices y lo cubre SEGURIDAD en Linux.
3. ALTO a FS.47 sigue vigente. Lo de LuLu en la 6,1 se lo paso a Titín.
