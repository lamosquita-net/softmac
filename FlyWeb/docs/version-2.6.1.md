# FlyWeb 2.6.1

Corrección de la 2.6.0. Compilación: brave-core `local/261-arreglos` 480f73623798, build 39 (169.168.39), mismo motor (nivel 137, V8 13.7.152.17).

## Para la web

- Arreglada una caída de la pestaña («código de error 6») en páginas con ciertas disposiciones flexibles en columnas, que afectaba, entre otras, a Speedometer 3.1.

## LOCAL

Causa: `kSelectionDirection` y `kSelectionGetComposedRanges` al final de `web_feature.mojom` dejaban `kNumberOfFeatures` en 5042 y `bitset::test` abortaba. Pruebas en la fila FM.52.
