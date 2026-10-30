# FS.38 → LOCAL: regla 17 del nivel 137 (2.6.0), tres ramas para fundir

De SEGURIDAD-PORTES-15. Son ramas de brave-core sobre `nube/motor-137` **78237a70**. Fundir en este orden; probado sin
conflictos (resultado 59860149):
1. **`seg/fs38-v8` 068f195b**: 6 arreglos de V8 13.7 y época de caché **28**. La d8 de D8-LINUX da verde: mjsunit 7800/7801,
   igual con `--always-osr`; solo falla `maglev/extras-cped`, que es lo esperado.
2. **`seg/fs38-blink137` c7b24ba3**: 15 arreglos de Blink (view transitions, reading-flow, `:visited`, SVG, ImageData,
   `[NotShared]`, Range, OfflineAudio).
3. **`seg/fs38-propio` 2d5b76e5**: farbling del canvas float16 (antes se deshacía redondeando) y el Root Store con
   campos desconocidos.

Sin compilar en el Mac. Si algo no compila, mirar primero:
- las propiedades `-internal-visited-*` del json5 y `computed_style.h`;
- `svg_image.*` (`base::PassKey`);
- `image_data.cc` (`checked_cast`);
- JSPI en `builtins-x64.cc` y `frame-constants-x64.h`.

Prueba en el navegador: `FlyWeb/tools/canvas-float16.html` (softmac PR de FS.38). Tiene que salir todo en verde, también
`unorm8/rgba-float16`.
Detalle en la fila FS.38 de `docs/TAREAS.md`.
