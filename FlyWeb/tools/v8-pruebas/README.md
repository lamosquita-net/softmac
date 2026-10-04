# Pruebas de V8 para los portes de seguridad

Se pasan con un `d8` de la V8 de FlyWeb (11.6.189.20), compilado con `FlyWeb/scripts/v8-d8.sh`, no con FlyWeb
(usan `%` de `--allow-natives-syntax`). Copiar los `.js` a `test/mjsunit/compiler/` (o `regress/wasm/` el de Wasm) del
árbol de V8 y ejecutar `tools/run-tests.py --outdir=out/x64 mjsunit/compiler/<nombre>`, que aplica la línea `// Flags:`.

| Fichero | Origen | Comprueba |
|---|---|---|
| `regress-360700873.js` | V8 4ddcbf2 | CVE-2024-7971: falla (aborta) en la 11.6 sin parche, pasa con `seg/cve-2024-7971` |
| `regress-475479135-1.js`, `-2.js` | V8 9b5250b9 | El fallo que introducía el arreglo de CVE-2025-13223 si se portaba sin la dependencia de representación |
| `flyweb-13223-mixed.js` | SEGURIDAD | CVE-2025-13223: ampliación del almacén de propiedades optimizada con campos Smi, Double, HeapObject y Tagged mezclados con accesores; con `--trace-turbo-graph --turbo-filter=extend` se ve el tipo de cada hueco |
