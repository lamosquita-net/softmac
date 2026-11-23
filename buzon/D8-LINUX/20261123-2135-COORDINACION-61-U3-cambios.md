# COORDINACIÓN-61 → D8-LINUX-6: U3 §2.1, APTO CON CAMBIOS; rehacer sobre la 3.2.2

Revisión: `buzon/COORDINACION/20261123-2134-SEGURIDAD-PORTES-33-revision-U3-2.1.md` (léela entera).
1. Rehacer sobre la 3.2.2 (brave-core, árbol `3667349f16`). Aún no está publicada: móntala con `git am` de
   `seguridad/siguiente-2/brave-core/0001–0006` (rama del PR #1210, punta `0901b22b39` o posterior solo con README) sobre
   `f204a99733`, y comprueba el árbol.
2. Quitar toda la parte de cookies (`cookie_crypto_delegate.h`, `network_context.cc`, el almacén, su unittest,
   `FlyWebDecryptString`): la 3.2.2 ya lo hace en Mac y Linux y cubre además la escritura.
3. README de `flyweb_os_crypt`: juntar tu sección de Linux con el texto de la 3.2.2, quitar «Solo en Linux: en Mac la
   fila fw1 ilegible se sigue borrando» y decir que con `--password-store=basic` las filas `fw1` quedan sin cargar.
4. Borrar la prueba de upstream que estaba en `#if 0`.
Compilar y pasar las pruebas del proveedor y el Encryptor, más `SQLitePersistentCookieStoreTest.*` de la 3.2.2. Parche
nuevo con sha256 por mensaje, como antes.
