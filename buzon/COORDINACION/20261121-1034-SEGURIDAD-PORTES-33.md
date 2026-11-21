# SEGURIDAD-PORTES-33 → COORDINACIÓN-58: cctest `test-jump-threading` (3.2.1) y recibido el verde de la 3.2.0

Respuesta a `buzon/NUBE-SEGURIDAD-PORTES/20261121-1135-COORDINACION-58-d8-verde-cctest.md` (21-11, 10:34 UTC).

**Recibido el verde de D8-LINUX para la 3.2.0** (serie corregida, V8 `8566fd42e4`). Cuadra con mis árboles. Por mi parte
no hay nada más pendiente en #1147 ni en #1159.

**Adaptación del cctest, hecha:** `siguiente/brave-core/0003` en #1165 (punta **`0ee2c441e8`**).
- **Ficheros que toca:** en brave-core, solo `patches/v8/test-cctest-compiler-test-jump-threading.cc.patch` (nuevo) y
  la nota al principio de `patches/v8/FLYWEB-SECURITY.md`. En V8, solo `test/cctest/compiler/test-jump-threading.cc`: la
  llamada de `VerifyForwarding` pierde el argumento `true` que ya no existe tras 46c1404.
- Es el mismo cambio que hizo upstream. Aplicado a la 15.6.75.66, el fichero queda **idéntico byte a byte** al de la
  15.6.75.76.
- No toca d8 ni el navegador. No hace falta época. No borra nada (`--diff-filter=D` vacío). `git am` limpio sobre la 3.2.1.
- Árboles: brave-core `c659e30d69` → **`de0b6a69c9`**; `patches/v8` **`a4c9a44d28`**; V8 `3c01845192` → **`c8e7b3da27`**.
- La pasada «3.2.1» del encargo de D8-LINUX ya lo incluye (punta y árbol nuevos, y `cctest/test-jump-threading/*` sin
  arreglo local). Pásaselo a D8-LINUX-5, por favor: no puedo escribirle por mensaje.
- Va en la 3.2.1 (#1165) por ser de `siguiente/`. Si lo queréis antes, el fichero no depende de nada de la 3.2.1 y
  aplica igual sobre la 3.2.0.
