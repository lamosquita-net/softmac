# FlyWeb 1.12.1 — nivel 128 completo, con el ruby nuevo de Chrome (MOTOR-7, 14-10-2026)

**Estado:** brave-core `nube/motor-128-ruby` **44c2af834** (cabeza final salvo errores del Static) = la 1.12
(`nube/motor-128` 710e7520, ya publicada) + RubyLB completo (R1–R5) + sus arreglos de compilación (f1b26d42) + tres portes
que faltaban (e420119c) + `flyweb_version` 1.12.1 (611642d8) + la revisión de seguridad de RubyLB (FS.11, SEGURIDAD-PORTES,
`seg/rubylb-128` 388643ed: 11 arreglos de seguridad y de caídas de upstream de la 128 a la 149). Static de f1b26d42: 0
errores, `motor-128` 9/9, WPT de `css/css-ruby` 110 de 113 iguales a Chrome 128, 1 mejor y 1 diferencia (arreglada en
e420119c). LOCAL-3 compila 44c2af834 (Static definitivo); después, ASan, Release y entrega (regla 11). Pruebas de los
arreglos de seguridad: `FlyWeb/tools/ruby-fs11/`. Detalle técnico: `motor.md`, «Nivel 128».

| Dato | Valor |
|---|---|
| Versión visible | 1.12.1 (`CFBundleVersion` la pone LOCAL en la entrega) |
| Nivel declarado | Chrome 128, sin cambios desde la 1.12 (128.0.6613.138; `platformVersion` mínimo 10.15.7) |
| Motor JavaScript | el de la 1.12: V8 12.8.374.38 con los arreglos de seguridad de FlyWeb (época de caché 12, sin cambios) |
| Lo nuevo | RubyLB, la reescritura del texto *ruby* de Chrome 124–128: 156 commits de upstream portados, 14 saltados con motivo y 9 solo de pruebas (`FlyWeb/tools/port/rubylb-commits.tsv`) |
| Pruebas | `motor-128.html`, `wpt-128-ruby-lista.txt` y `ruby-fs11/` con `wpt-ref.py` (comparado con la 1.12 y con el Chrome del mismo Mac) |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Texto con anotaciones *ruby*, como en Chrome 128.** El *ruby* son las pequeñas anotaciones sobre el texto: la
  lectura (*furigana*) encima de los kanji en japonés, el *pinyin* o el *zhuyin* en chino. FlyWeb pasa a usar el sistema
  nuevo con el que Chrome lo rehízo:
  - Una palabra anotada larga **se puede partir entre dos líneas** junto con su anotación, en vez de saltar entera a la
    línea siguiente y dejar huecos.
  - Las webs pueden elegir **cómo se reparte la anotación** sobre su texto (`ruby-align`: centrada, al principio o
    repartida) y FlyWeb lo respeta. Las anotaciones cortas y las que caen al borde de la línea se colocan como en Chrome.
  - Las anotaciones **no se montan sobre la línea de arriba**, tampoco cuando en ella hay una imagen o un botón alto.
  - Las anotaciones pueden ir **encima o debajo** del texto, y las webs pueden darles márgenes, bordes y relleno.
  - Los **subtítulos de vídeo** que usan *ruby* se muestran con sus anotaciones.
- **Un detalle de estilo como en Chrome:** la primera letra de una anotación ya no recibe el estilo de «letra capital»
  de la web (`::first-letter`), que antes se le aplicaba por accidente.
- **Todo lo demás, igual que en la 1.12:** el nivel 128, el motor de JavaScript de Chrome 128 con sus arreglos de
  seguridad y la misma huella de red.

Nada cambia en los ajustes ni en los datos del usuario.
