# Generador de bindings de Blink sin compilar

Para comprobar cambios en IDL o en el generador (`bindings/scripts/web_idl`, `bind_gen`) sin compilar FlyWeb. Lo usó NUBE
en el nivel 124 (iteración asíncrona de `ReadableStream`).

1. Montar un árbol `…/src/` con `third_party/blink` de Chromium 116.0.5845.188, `third_party/{mako,ply,pyjson5}`,
   `tools/idl_parser` y `build/gn_helpers.py`. Aplicar encima todos los `patches/third_party-blink-*.patch` de la rama de
   brave-core y enlazar `src/brave` → brave-core (Brave inyecta su `interface.py` en el generador).
2. `runbind.sh <src> async_iterator callback_function callback_interface dictionary enumeration interface namespace observable_array sync_iterator typedef union`
   recoge las IDL (producción y pruebas, con dos IDL generadas sustituidas por esqueletos), construye la base de datos
   y genera todo en `/tmp/claude-0/port/out/gen` (~1,5 min, ~60 MB). Sin tareas, solo construye la base de datos.
3. `checklist.py <src> <out>` escribe la lista de ficheros de `bindings/BUILD.gn`; con ella,
   `check_generated_file_list.py` comprueba los `generated_in_*.gni`. `validate_web_idl.py` valida los atributos extendidos.

Comparar la salida con la de la rama sin el cambio (`diff -rq`) dice exactamente qué bindings cambian.
