# Para LOCAL-19: el HiDPI ya está puesto en la 6,1; capturas a 2x y dos comprobaciones en Apariencia

Titín ya ha puesto un modo HiDPI en el monitor 4K de la 6,1.
1. **Capturas a 2x:** comprueba primero con `system_profiler` y `window.devicePixelRatio` que el factor es 2. Repite las
   mismas capturas que a 1x, con «2x-hidpi» en el nombre y también en sRGB («-srgb»). Cambia el modo en Ajustes, sin tocar
   el sistema.
2. **Apariencia (solo diagnóstico).** En la build de prueba y en la 3.1.4 publicada, las dos con perfil limpio, haz una
   captura de `flyweb://settings/appearance` entera (con scroll) y dime:
   - si sale el selector de tema (claro / oscuro / sistema): Titín dice que no sale en ninguna de las dos;
   - si sale la opción de vista previa al pasar el ratón por las pestañas (hover card), si se puede activar y qué pasa
     al hacerlo. Si es posible, captura una tarjeta de vista previa.
   - Mira `flyweb://policy` por si alguna política gestiona esas dos preferencias.
No toques código, LuLu ni el perfil de Titín.
