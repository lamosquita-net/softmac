# FlyWeb 1.12.2 — nivel 128 con dos arreglos más del código de línea (MOTOR-7, 14-10-2026)

**Estado:** en brave-core `nube/motor-128-ruby` **bb6c7146** = la 1.12.1 (e6273d015, entregada a PUBLICACIÓN el 14-10) +
el resto de FS.12 (`seg/inline-116` **907c95074**, SEGURIDAD-PORTES) + `flyweb_version` 1.12.2. Sin compilar: LOCAL-3 la
compila con **`FLYWEB_BUILD_NUMBER=21`** (Static, ASan, Release) y la entrega a PUBLICACIÓN (regla 11). Detalle técnico:
fila FS.12 de `docs/TAREAS.md` y fila FM.18.

| Dato | Valor |
|---|---|
| Versión visible / `CFBundleVersion` | 1.12.2 / 157.64.21 (`FLYWEB_BUILD_NUMBER=21`) |
| Nivel declarado | Chrome 128, sin cambios (128.0.6613.138; `platformVersion` mínimo 10.15.7) |
| Motor JavaScript | el de la 1.12.1: V8 12.8.374.38 con los arreglos de seguridad de FlyWeb (época de caché 12, sin cambios) |
| Lo nuevo | d7020222f64 (crbugs 379143305, 389713711): bucle infinito en `NGInlineLayoutAlgorithm::Layout` con `shape-outside`; 9df6f20935b (crbug 364970793): carrera de datos al copiar un `NGInlineItem` durante el marcado concurrente del recolector |
| Pruebas | las de la 1.12.1 (`motor-128.html`, `wpt-128-ruby-lista.txt`, `ruby-fs11/`) y `ruby-fs11/shape-outside-infinite-crash.html` (prueba de upstream de d7020222f64: no debe colgarse) |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Un cuelgue menos.** Algunas páginas que hacen fluir el texto alrededor de una forma (por ejemplo, un párrafo que
  rodea una imagen con forma) podían dejar la pestaña colgada. Ya no.
- **Más estable al maquetar texto.** Arreglado un fallo poco frecuente que podía aparecer al colocar el texto de una
  página mientras FlyWeb libera memoria en segundo plano.
- **Todo lo demás, igual que en la 1.12.1:** el nivel 128 con el *ruby* nuevo, el motor de JavaScript de Chrome 128 con
  sus arreglos de seguridad y la misma huella de red.

Nada cambia en los ajustes ni en los datos del usuario.
