# Inventario de brave-core por función (P0 de `brave-propio.md`)

`p0.py <salida.json>` clasifica cada fichero de un checkout de `lamosquita-net/brave-core` (rama `flyweb`) por función
(muerta / sin decisión / sustituida / viva / resto) y por tipo (código, pruebas, `chromium_src`, `patches`, iOS, Android,
`third_party`), cuenta ficheros, líneas y bytes, y deja en `<salida>.dep` los parches y `chromium_src` que mencionan
funciones muertas y los ficheros vivos que las incluyen.

- Se ejecuta con `python3 -I p0.py salida.json` y la variable `R` (ruta del checkout) editada al principio.
- La clasificación es por **ruta con expresiones regulares** (heurística): sirve para órdenes de magnitud, no para
  borrar nada sin mirar. Las reglas están al principio del guion.
- Medido el 03-11-2026 sobre `origin/flyweb` ac280a17df (2.6.1). Resultados en `FlyWeb/docs/brave-propio.md` §2.4.


## B2 en papel (FM.55; `brave-propio.md` §11, INVESTIGACIÓN-MOTOR-8, 03-11-2026)

| Guion | Qué hace |
|---|---|
| `b2-ausentes.py SALIDA.tsv` | Los 138 parches y 418 envoltorios de Brave 1.69 que siguen en `flyweb` y no existen en 1.98.63: objetivo en Chromium, si existe en 128 y 156, plataforma, función, cuánto de su contenido está en otro sitio de 1.98 |
| `b2-aplica.py ausentes ENTRADA SALIDA` / `todos SALIDA` | `git apply --check` de cada parche sobre el fichero de Chromium 156 (y 128 como control); identificadores `#define` de cada envoltorio que ya no existen en 156. Baja los ficheros de Chromium con `curl` desde raw.githubusercontent.com (el `git fetch <oid>` del repo parcial iba de uno en uno: ~20 s por blob) |
| `b2-clasifica.py` | Clasificación final (se cae / se adapta / se reescribe / ya no hace falta), con el commit de Brave que quitó cada fichero; salida `datos/b2-ausentes.tsv` |
| `b2-donante.py SALIDA` | Qué se puede sustituir por el de 1.98 (donante) y qué choca con una modificación de FlyWeb |
| `b2-poda.py CHECKOUT SALIDA_DIR` | Plan de poda sobre `flyweb`: directorios muertos, costuras (ficheros vivos que mencionan funciones muertas), líneas de GN/DEPS (`datos/poda-*.tsv`) |
| `b2-cuenta.py REGISTRO.log [PARCHEADOS]` | Cuenta «ficheros rotos» del registro de `autoninja -k 0` (la medida B2 de verdad; receta en §11.7) |

Entradas: un clon de `lamosquita-net/brave-core` con el remoto `up` = `brave/brave-core` y las etiquetas `v1.69.168` y `v1.98.63`
(`git fetch --filter=blob:none --depth=1 up tag v1.69.168 tag v1.98.63`), dos *worktrees* dispersos de las etiquetas (`sparse-checkout` de `/patches/` y `/chromium_src/`), y un repositorio parcial de
`github.com/chromium/chromium` con las etiquetas `128.0.6613.138` y `156.0.8078.80` (solo árboles, `--filter=blob:none --depth=1`). Las rutas están al principio de cada guion.
