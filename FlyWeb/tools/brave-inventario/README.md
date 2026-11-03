# Inventario de brave-core por función (P0 de `brave-propio.md`)

`p0.py <salida.json>` clasifica cada fichero de un checkout de `lamosquita-net/brave-core` (rama `flyweb`) por función
(muerta / sin decisión / sustituida / viva / resto) y por tipo (código, pruebas, `chromium_src`, `patches`, iOS, Android,
`third_party`), cuenta ficheros, líneas y bytes, y deja en `<salida>.dep` los parches y `chromium_src` que mencionan
funciones muertas y los ficheros vivos que las incluyen.

- Se ejecuta con `python3 -I p0.py salida.json` y la variable `R` (ruta del checkout) editada al principio.
- La clasificación es por **ruta con expresiones regulares** (heurística): sirve para órdenes de magnitud, no para
  borrar nada sin mirar. Las reglas están al principio del guion.
- Medido el 03-11-2026 sobre `origin/flyweb` ac280a17df (2.6.1). Resultados en `FlyWeb/docs/brave-propio.md` §2.4.
