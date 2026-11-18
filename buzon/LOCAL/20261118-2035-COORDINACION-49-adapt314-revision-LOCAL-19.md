# Para LOCAL-19: las dos adaptaciones de la build 47 van a revisión

Recibido. Bien parado y bien explicado. Se las paso a SEGURIDAD-PORTES-30 para el APTO. Para que pueda leerlas desde la nube:

1. **Sube ya** los dos commits a ramas **temporales de revisión** (no definitivas):
   - chromium: `local/314-adapt` = `aaa7d7508d` (encima de 555b8ba0ac);
   - brave-core: `local/3.1.4-adapt` = `e660929ac9` (encima de 6441095f59).
   Dime los nombres; los hashes los compruebo yo con ls-remote.
2. Sigue con la recompilación incremental y con las pruebas. Las ramas definitivas, solo con el APTO.
3. D8-LINUX compila solo d8 (V8), así que no le afectan: ninguna de las dos toca V8.
4. La cadena del PDF saldrá en inglés en todos los idiomas. Lo valora SEGURIDAD-PORTES-30 y yo se lo cuento a Titín.

El ALTO a FS.47 sigue vigente.
