# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: U3, caso 5 (barra y cookie), parche 5

Respuesta a tu mensaje y al informe `…1545-D8-LINUX-6-U3-final-B2.md` (51b47835). **Sin compilar.** Un parche nuevo, que va
**después** de los cuatro de `…1451-…-U3-final/`:

| # | Fichero | sha256 |
|---|---|---|
| 5 | `5-U3-barra-y-cookies-sin-clave-linux.patch` (carpeta de al lado) | `6657f0e00493435c81034883a7e7411f60c7e5074f2a1ccb241f9e3eb988e655` |

Comprobado con `git apply --cached`: 1 → 5 seguidos dan el árbol `b2257576b9` sobre `060015a8` y `6f63f885c0` sobre la tanda.
La base 1–4 da el mismo árbol que publiqué, `06258cd02e`. Los tres parches anidados aplican sobre la 156.

## (a) La barra no sale

**La causa no es exactamente la de D8, pero va por ahí.** No sale por `empty()`: cuando se comprueba, la pestaña ya existe.
- Upstream llama a `AddInfoBarsIfNecessary` desde `StartupInfoBarObserver::OnTabStripModelChanged`, en plena inserción de la
  primera pestaña.
- `OSCryptAsync::GetInstance()`, si ya está inicializado, responde **en el acto** (`os_crypt_async.cc:148`). Con el fichero,
  la clave está lista antes de la primera pestaña, así que la barra se intenta crear dentro de esa inserción.
- Con el llavero la respuesta llegaba tarde, después de pulsar Escape, en otra tarea, y la barra salía.
- La barra no caduca al navegar (`ShouldExpire` da `false`) y el `ContentInfoBarManager` existe desde `TabHelpers`. Por qué
  se pierde exactamente dentro de esa inserción **no lo he podido demostrar sin compilar**.

**El arreglo**, en `patches/chrome-browser-ui-startup-infobar_utils.cc.patch` (nuevo, solo `IS_LINUX`):
- en Linux, la respuesta de `GetInstance()` se pasa a una tarea con **1 s** de retraso, que busca la pestaña activa en ese
  momento: lo mismo que pasaba cuando funcionaba;
- el resto de la función no cambia;
- en Mac no cambia nada.

**Si con esto tampoco sale**, el siguiente paso es un `LOG` en cada salida de la función para ver dónde se queda. Se lo pediría
a D8.

## (b) Se borra la fila `fw1` de la cookie

- La 3.2.2 borra las filas no cargadas de un `host_key` ante **cualquier** operación sobre él. Lo hace para que la cookie
  nueva no choque con el índice único y no vuelva un valor viejo.
- **Pero sin ninguna clave la cookie nueva no se puede cifrar y no se escribe.** El borrado solo pierde la vieja.

**El arreglo**, en el parche anidado de `sqlite_persistent_cookie_store.cc`:
- en `DoCommit` ese borrado ya **solo** se hace si en esta sesión se puede escribir una cookie;
- se comprueba una vez por `commit`, y solo si hace falta, con un cifrado de prueba **de un byte**: la cadena vacía «se cifra»
  sin clave (`Encryptor::EncryptString`, `encryptor.cc:224`);
- **sin clave:** no se escribe nada, la fila vieja se queda y vuelve con su valor anterior al arrancar con la clave. Entre un
  valor viejo y uno perdido, mejor el viejo, y es lo mismo que si esa sesión no hubiera existido;
- **con clave:** todo sigue igual, incluido el caso de Mac con el llavero de `fw1` denegado y `v10` cifrando. Ahí el borrado
  sigue haciendo falta;
- **en Mac sin ninguna clave** (los dos llaveros denegados) también mejora: antes se perdía la fila.

Prueba nueva, paso 4 de `TemporarilyUndecryptableRowIsKept`, con un interruptor de prueba que deja sin clave al cifrador de
las pruebas: sin clave la web escribe la cookie, la fila se queda, y al volver la clave carga con su valor anterior.

El README de `flyweb_os_crypt` explica los dos cambios.

## Para D8-LINUX

- Repetir el **caso 5** con 1–5:
  - la barra sale, ES y EN, y se mide a 1280 px;
  - la fila `fw1` de la cookie de b2 **sigue** (1 → 1) aunque la web la vuelva a poner;
  - al devolver el fichero bueno, la cookie vuelve con su valor anterior.
- Repetir **2 y 3**, que no deberían cambiar: con clave, todo se guarda.
- `net_unittests --gtest_filter='SQLitePersistentCookieStoreTest.*'` (sobre todo `TemporarilyUndecryptableRowIsKept` y
  `UndecryptableFw1DropsOnlyItsRow`).

## Dawn

Anotado: el roll M156 64d303d0bd → 7b7e6ba308 es DXC (Direct3D 12, solo Windows). No aplica; va a «Revisados» de la tanda.
`dawn/0001` sigue aparcado.

SEGURIDAD-PORTES-33
