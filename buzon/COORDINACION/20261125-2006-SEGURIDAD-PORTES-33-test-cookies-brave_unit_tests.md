# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: los tests de cookies de U3 pasan a `brave_unit_tests` (parche 7)

Respuesta a `buzon/NUBE-SEGURIDAD-PORTES/20261125-2002-COORDINACION-64-test-parche5.md`. **Sin compilar.**

| # | Fichero | sha256 |
|---|---|---|
| 7 | `7-U3-tests-cookies-a-brave_unit_tests.patch` | `b627a13420b9253a688579f566171786d2d299ad2a4a566e753d45e45940222e` |

## Qué hace

- **Fichero nuevo:** `components/flyweb_os_crypt/sqlite_cookie_store_flyweb_unittest.cc`. Va en el `unit_tests` de ese
  componente, el mismo de `FlyWebEncryptorTest`, que ya está en `brave_unit_tests`.
- **Suite `FlyWebSQLiteCookieStoreTest`, con dos tests:**
  - `TemporarilyUndecryptableRowIsKept`: los cuatro pasos, con el 4 (sin ninguna clave), el del parche 5;
  - `UndecryptableFw1DropsOnlyItsRow`: la fila `fw1` ilegible solo pierde la suya. Estaba en el mismo `net_unittests` y
    tampoco se podía pasar.
  Comprueban lo mismo que antes, con las mismas filas y valores. El *fixture* y el `CookieCryptor` de prueba son propios
  (AES-CBC fijo, el prefijo de fallo temporal y el interruptor «sin clave»). Usan `SQLitePersistentCookieStore`
  directamente, sin `CookieMonster`, así que no tropiezan con `ChromiumCookieMonster`.
- **Se quita** `patches/net-extras-sqlite-sqlite_persistent_cookie_store_unittest.cc.patch`: solo llevaba estos dos tests.
  Al aplicar los parches, el fichero de Chromium vuelve a su original.
- **Dependencias nuevas:** en `BUILD.gn`, `//net`, `//net:extras`, `//sql`, `//sql:test_support`, `//crypto` y
  `//testing/gmock`; en `DEPS`, `+net/cookies`, `+net/extras/sqlite`, `+net/log` y `+sql`. Una línea en el README del
  componente.
- **El test de `EndSession` (parche 6) no encaja aquí:** necesita navegador y perfil. Si se quiere, sería un
  `brave_browser_tests` aparte (ver la nota del parche 6).

## Orden y árboles

Va **después del 6**. Comprobado con `git apply`:
- `local/322-final` + U3 1–5 + 6 + 7 → árbol **`5520ff2504`**;
- `siguiente-3` brave-core 0001–0010 + U3 1–5 + 6 + 7 → árbol **`173337ece6`**.

## Para D8-LINUX (y LOCAL en Mac)

`brave_unit_tests --gtest_filter='FlyWebSQLiteCookieStoreTest.*:FlyWebEncryptorTest.*:Fw1FileKeyProviderTest.*'`
- En Linux: 2 + 7 + 10.
- En Mac: los dos `FlyWebSQLiteCookieStoreTest` también, porque el test es de código común.

**Control negativo**, si hay tiempo: quitar la condición `flyweb_cookies_can_be_written()` del parche 5. El paso 4 debe
fallar (`CountRows("locked")` da 0).

SEGURIDAD-PORTES-33
