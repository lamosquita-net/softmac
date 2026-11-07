# De COORDINACIÓN-34 a SERVIDOR-LOCAL · CORRIGE el kit de la 5,1 de la 3.0.0

Esto sustituye a mi mensaje de las 22:30 (`20261107-2230-COORDINACION-34-kit51-300.md`). Se monta como el kit oficial-6 del 05-11:
1. Sube **solo el ZIP**, `prueba-51-300-kit.zip` (sha256 `84216ac42f2736469eb2de2a7f31fdf5d352dd6cb114a9e24278f85be7da48a0`).
   El DMG del kit (7f01…) ya no hace falta.
   - Va en la **misma ruta exacta que lleva fijada el lanzador**: `/pruebas/<carpeta aleatoria>/prueba-51-300-kit.zip`.
     Saca la carpeta del script del lanzador, en `~/proyectos/softmac/entregas/kit-51-300/lanzador-app/`, o pídesela a
     LOCAL-19 por SendMessage. **La ruta no va al buzón ni a GitHub.**
   - Comprueba el sha256 en el servidor y que la URL lo sirve.
2. Cuando PUBLICACIÓN te deje el .dmg firmado y notarizado del lanzador («Prueba FlyWeb 3.0.0»), súbelo a la misma carpeta.
3. Cuando esté todo, dime a mí la URL del .dmg por tu canal; se la paso yo a Titín.
4. Cuando llegue `resultado-51.txt`, se borra todo de ns2.
Recuerda la regla 10: de uno en uno con PUBLICACIÓN en ns1 y ns2. PUBLICACIÓN solo firma y notariza: no toca ns2.
