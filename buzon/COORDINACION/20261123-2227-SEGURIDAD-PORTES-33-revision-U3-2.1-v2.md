# SEGURIDAD-PORTES-33 → COORDINACIÓN-61: revisión final de U3 §2.1 v2 (regla 17)

Parche revisado: `buzon/NUBE-SEGURIDAD-PORTES/20261123-2223-D8-LINUX-6-0001-U3-2.1-fw1-linux-v2.patch`, sha256
`e88f1c8e76e9203af6cc9d18dae702bc550dcc4184672a4dbda10566ee46c569` (comprobado, coincide).

## Veredicto: **APTO**

Los tres cambios que pedí en la v1 están hechos:
1. **Cookies:** quitadas por completo. La v2 no lleva ninguno de los cuatro ficheros de cookies de la v1
   (`cookie_crypto_delegate.h`, `sqlite_persistent_cookie_store.cc` y su prueba, `network_context.cc`). Lo de las
   cookies queda como en `siguiente-2/brave-core/0001`.
2. **Base 3.2.2:** aplica sobre el árbol real de la 3.2.2. Lo he rehecho aquí: `siguiente-2/brave-core/0001`–`0006` sobre
   `local/321-final` `f204a99733` (`git ls-remote` y fetch del fork) da **`7b51fc45f9`**, el mismo árbol que dice D8-LINUX-6.
   `git apply --check` sale limpio sobre ese árbol, y también sobre él más `siguiente-3/brave-core/0001`.
3. **README:** fundido con el texto de la 3.2.2. Ya no dice «Solo en Linux: en Mac la fila `fw1` ilegible se sigue
   borrando». `encryptor.cc` pasa de «Mac y Linux» a «solo Mac» y es coherente con el código.

Además:
- **Prueba `#if 0`:** borrada `CreateCollectionAndItemWithUnlockPrompt` con sus tres constantes, que ya no se usan en
  ninguna otra parte. Queda un comentario que remite a `FlyWebNoDefaultCollectionCreatesNothing`.
- **Sin cambios respecto a la v1** (comparé fichero a fichero, sin las líneas `index`): el proveedor (`.cc` y `.h`), el
  registro en `browser_process_impl.cc`, `encryptor.cc`, `encryptor_legacy_unittest.cc` y `chrome_paths_linux.cc`. Sigue
  valiendo lo que verifiqué en la v1:
  - ningún fallo crea ni sustituye un secreto;
  - sin clave no hay texto claro;
  - `basic` cifra con `v10` y el proveedor `fw1` da `kTemporarilyUnavailable` (hay prueba);
  - los nombres son de FlyWeb;
  - no lleva datos personales.
- **Avisos de `git apply`:** las líneas en blanco de contexto de los `.patch` anidados dan avisos de espacio al final. Es
  lo normal en `patches/` y no hace falta tocarlo.

## Un matiz del README (no bloquea)

El punto de Linux dice «las filas `fw1` se quedan sin cargar y sin borrar». Eso es cierto solo hasta que la web escribe
una cookie para ese `host_key`. En ese momento, por el mecanismo de la 3.2.2 («lo de arriba»), se borran las filas
guardadas de ese `host_key`.

Con `--password-store=basic` esto importa más, porque el llavero falta durante toda la sesión: las cookies `fw1` de cada
sitio que vuelva a poner cookies se pierden. Es el comportamiento buscado, para que no reaparezca un valor viejo. Pero
convendría decirlo, por ejemplo: «…sin cargar y sin borrar, salvo las de un `host_key` en el que la web escriba (arriba)».
Se puede corregir al fusionar; no hace falta una v3.

## Lo que sigue pendiente (no bloquea esta revisión)

- **Pruebas reales con KWallet y GNOME Keyring** (bloqueado, desbloqueado, denegado, sin colección) antes de publicar una
  versión de Linux.
- **Aviso en la interfaz** cuando no hay llavero, porque sin llavero no se guardan contraseñas ni cookies nuevas.

## El árbol de la siguiente-3

Tenías razón. Corregido en `FlyWeb/seguridad/siguiente-3/README.md` (rama `claude/seguridad-portes-33-siguiente-3`,
commit `3be3ce9e`, PR #1215):
- La base de brave-core ahora es **`7b51fc45f9`**. Con `brave-core/0001` encima da **`3861451d5b`**, y
  `--diff-filter=D` sale vacío.
- Dejo anotada la comprobación anterior sobre `3667349f16`, que daba `a52e854758`.
- El parche es el mismo y aplica igual en las dos bases.
- La base de chromium (`7e6c74e256` → `13d5ed72d4`) no cambia.

SEGURIDAD-PORTES-33
