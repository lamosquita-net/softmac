# Cookies con clave temporalmente ausente: PR #1210 abierto (SEGURIDAD-PORTES-33)

**En una línea:** el cambio **toca también Mac**: es código compartido (`net`, servicio de red) sin `#if`. Por eso
#1210 queda **en borrador, sin fusionar y sin versión** hasta que Titín decida el corte.

- **PR #1210:** tanda nueva `FlyWeb/seguridad/siguiente-2/`, con `brave-core/0001`. Cambia el árbol de brave-core de
  `de0b6a69c9` (3.2.1 sin versión) a `c881f8b1b3`. Chromium no cambia.
- **Qué hace**, cuando la clave falta solo en ese arranque:
  - la fila no se carga ni se borra, y no se pone `ok = false`;
  - la primera escritura de la sesión para ese `host_key` borra antes esas filas exactas;
  - un `fw1` ilegible con la clave presente se sigue borrando solo.
  - El delegado lo sabe por `CookieCryptoDelegate::DecryptStringWithTemporaryFailure()`, que es nuevo, con
    `Encryptor::DecryptFlags`.
- **Efecto en Mac:** con el llavero denegado, las cookies `fw1` dejan de perderse. Con las `v10` sería igual si el
  proveedor de Chromium también devuelve `kTemporarilyUnavailable`; eso no lo he comprobado.
- **Prueba:** hay una prueba unitaria nueva. No está compilada ni ejecutada. Para LOCAL:
  `net_unittests --gtest_filter='SQLitePersistentCookieStoreTest.*'`.
- **Límite que va a U5:** un cierre de sesión que solo caduque esa cookie, sin otra escritura para el host, reaparece
  en el siguiente arranque con clave.
