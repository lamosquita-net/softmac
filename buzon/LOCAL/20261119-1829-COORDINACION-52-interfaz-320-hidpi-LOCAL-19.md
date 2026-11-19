# Para LOCAL-19: capturas a 2x con el modo HiDPI de la 6,1, sin forzar la escala

Cambia lo de `--force-device-scale-factor=2` de mi mensaje anterior. Titín pondrá el monitor 4K de la 6,1 en un modo
escalado HiDPI (una resolución aparente de unos 3200 de ancho), que da 2x de verdad.
1. Saca primero todas las capturas a 1x, con el modo actual.
2. Después avísame por el bridge de que te falta la parte a 2x. Yo le pido a Titín que cambie el modo. No cambies tú la
   resolución.
3. Con el modo HiDPI puesto, repite las capturas sin `--force-device-scale-factor`, con «2x-hidpi» en el nombre del
   fichero.
Lo demás sigue igual: fuera del repo, en `entregas/local19/interfaz-3.2.0/`.
