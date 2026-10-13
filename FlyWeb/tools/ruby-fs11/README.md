# Pruebas de los arreglos de seguridad de RubyLB y de la base de línea (FS.11 y FS.12, FlyWeb 1.12.1)

Pruebas de upstream de los arreglos que SEGURIDAD-PORTES portó en `seg/rubylb-128` (44c2af834, FS.11) y en
`seg/inline-116` (e6273d015, FS.12), y de los dos que añadió MOTOR-7 (e420119c). Son posteriores a la etiqueta 128, así que no están en el WPT de la 128: se copian a la raíz
del servidor WPT (p. ej. `temp/wpt128/flyweb-fs11/`) para que resuelvan `/resources/` y `/fonts/`. Las de `fast/` de
Blink se han cambiado a `/resources/testharness.js`.

Uso: `python3 FlyWeb/tools/wpt-ref.py <puerto> <url base> FlyWeb/tools/ruby-fs11/lista.txt` (una línea `flyweb-fs11/<fichero>` por
prueba, sin las `-ref`). Las de caída salen como «(prueba de caída)»: **pasan si la página carga y el renderer sigue
respondiendo**; si cae o se cuelga, `CAÍDA` o `COLGADO`, y la herramienta sigue en otra pestaña.
Comparar con el Chrome del mismo Mac: tiene que dar lo mismo o mejor.

| Fichero | Tipo | Arreglo (crbug) | Pasa si |
|---|---|---|---|
| `break-spaces-crash.html` | caída | 14ce1a8697 (352467338): RTL + ancho cero + `break-spaces` | no cae |
| `zero-width-base-crash.html` | testharness | c744b03566: división por cero con base de ancho cero | 1/1 |
| `bidi-crash.html` | testharness | a914a61963 (401056618): reordenación BiDi con base vacía | 1/1 |
| `float-beside-whitespace-ruby.html` | caída | c4b4073953 (510947981) | no cae |
| `whitespace-ruby-beside-float.html` | reftest | c4b4073953 (510947981) | igual que `ref-filled-green-100px-square.xht` |
| `ruby-inlinize-fieldset-crash.html` | caída | 634a7e2aca + cb45acdaec: `<fieldset>` con `display: contents` | no cae |
| `hyphens-overflow-rewind.html` | caída | d68c29e9d2d (435058045): índice de guion obsoleto tras `Rewind()`, **acceso fuera de límites** | no cae (mejor aún con ASan) |
| `justification-crash.html` | testharness | 4c7536927f8 (394983447): fin de la base en la justificación | 1/1 |
| `ruby-tab-in-base-00{1,2,3}.html` | reftest | fb5382de24c (505419357): tabuladores dentro de una base | igual que su `-ref` |
| `ruby-tab-in-base-max-content-crash.html` | caída | fb5382de24c | no cae |
| `ruby-align-in-text-align-crash.html` | testharness | 56be91796b = ef8ddcab1d8e (367764861): `text-align` no por defecto | 1/1 |
| `counters-container-crash.html` | caída | 690ccf3b8df (1505164, FS.12): comillas y *container queries* a mitad de la maquetación de línea | no cae (ni salta un `CHECK` de `NeedsCollectInlines`) |

Sin prueba de página: a88ef98354 (`InlineCursor`) y de6bea0628 + e79a89e550 (rubíes anidados en min/max), que upstream
probó con tests de C++ de Blink; y 9edff04ccc (`<video>`/`<audio>`), con un test de C++ de `StyleAdjuster`.

**Referencia en el contenedor de MOTOR-7 (Chromium 141 headless, Linux):** las 4 testharness pasan y 4 de las 5 de caída
cargan sin caer (también `counters-container-crash.html`). `hyphens-overflow-rewind.html` **cuelga la pestaña** en la 141 (su arreglo, d68c29e9d2d, es de junio de
2026): `wpt-ref.py` lo marca `COLGADO`, abre otra pestaña y sigue. Los tres `ruby-tab-in-base` y
`whitespace-ruby-beside-float` fallan en la 141 porque sus arreglos son posteriores (crbugs 505419357 y 510947981). En
la 1.12.1 tienen que pasar todas.
