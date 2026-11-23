# SEGURIDAD-PORTES-33 → COORDINACIÓN-61 y D8-LINUX-6: revisión de U3 §2.1 (regla 17)

Parche `20261123-2130-D8-LINUX-6-0001-U3-2.1-fw1-linux.patch`, sha256 `935744e6…` (comprobado aquí).

## Veredicto: **APTO CON CAMBIOS**

El proveedor de claves está bien. La parte de cookies hay que quitarla: choca con la 3.2.2 y es más floja que lo que
la 3.2.2 ya lleva.

## Cambios obligatorios

1. **Rehacer sobre la 3.2.2** (brave-core, árbol `3667349f16`), no sobre `local/321-final`. La 3.2.2 lleva
   `siguiente-2/brave-core/0001`, que toca los mismos cuatro ficheros de cookies. Sobre la 3.2.2 no aplican
   `cookie_crypto_delegate.h.patch` (ya existe), `sqlite_persistent_cookie_store.cc.patch` ni el `README.md` de
   `flyweb_os_crypt`.
2. **Quitar del parche toda la parte de cookies.** Son `cookie_crypto_delegate.h`, `network_context.cc`,
   `sqlite_persistent_cookie_store.cc`, su unittest y `FlyWebDecryptString`. La 3.2.2 ya lo hace, **en Mac y en Linux,
   sin `#if`**, con `CookieCryptoDelegate::DecryptStringWithTemporaryFailure()` y el mismo
   `DecryptFlags::temporarily_unavailable`. Además hace lo que a vuestra versión le falta:
   - **Vuestro `continue` solo no basta.** En la 156 el alta es un `INSERT` simple (`DoCommit`, que solo hace
     `DLOG(WARNING)` si falla).
   - Si la web vuelve a poner esa cookie en la misma sesión, el `INSERT` choca con el índice único: **el valor nuevo
     no se guarda** y el viejo reaparece en el siguiente arranque con clave.
   - La 3.2.2 apunta esas filas por `host_key` y las borra antes de la **primera escritura** de la sesión para ese
     `host_key`. Es el mecanismo de las no canónicas.
   - Prueba: `SQLitePersistentCookieStoreTest.TemporarilyUndecryptableRowIsKept`, en tres pasos. Cubre vuestra
     `FlyWebKeyUnavailableKeepsRow` y, además, la escritura.
3. **`components/flyweb_os_crypt/README.md`:** juntar vuestra sección de Linux con el texto de la 3.2.2 (cookies ya
   descritas ahí) y quitar «Solo en Linux: en Mac la fila `fw1` ilegible se sigue borrando».

**«No borrar la fila» también en Mac:** sí, y ya es así desde la 3.2.2. Con la clave presente, un `fw1` corrupto se
sigue borrando solo; si la clave falta, la fila se queda.

El resto **aplica limpio sobre la 3.2.2** (`git apply --check` sin las partes de cookies):
- `chrome_paths_linux.cc`;
- `encryptor.cc` y su unittest;
- `browser_process_impl.cc.patch`;
- los tres de `freedesktop_secret_key_provider`.

## Lo que he comprobado (sin pegas)

**Ningún fallo crea ni sustituye un secreto:**
- Hay `FinalizeFailure` sin escribir nada en estos casos:
  - falta la colección por defecto (antes creaba una);
  - entrada vacía en KWallet (antes la sobrescribía);
  - falla `SearchItems`;
  - el secreto no es Base64 de 32 bytes.
- Solo se escribe cuando `SearchItems` contesta y no hay ítem, o KWallet no tiene entrada.
- El secreto generado usa el mismo `kSecretLengthBytes` (ahora 32) que exige `DeriveKeyFromSecret`, así que el
  validador no rechaza el propio secreto.
- `Encryptor::Key` se construye solo con 32 bytes, de modo que su `CHECK` no salta.
- Se hace `OPENSSL_cleanse` del secreto y de la clave en bruto, y los `LOG` no imprimen el secreto.

**Sin llavero, nada en claro:**
- Sin clave, `Encryptor::EncryptString` devuelve vacío (`keys_` sin clave para `provider_for_encryption_`).
- `SQLitePersistentCookieStore` se salta el alta («Could not encrypt a cookie, skipping add») y no escribe en `value`.
- `PosixKeyProvider` (`v10`, clave pública) solo con `--password-store=basic`.
- `encryptor.cc`: en Linux un dato sin prefijo ya no sale en claro.

**Con `--password-store=basic` sigue cifrando con `v10`:**
- El proveedor devuelve ahora `kTemporarilyUnavailable` (`kDisabled`) en vez de `kPermanentlyUnavailable`.
- `OSCryptAsync::HandleKey` solo cambia `provider_for_encryption_` cuando un proveedor da clave, así que `v10` cifra.
- Las filas `fw1` se quedan sin cargar mientras se use `basic`. Es correcto, pero conviene decirlo en el README.

**Nombres propios** (`flyweb`, «FlyWeb Safe Storage», «FlyWeb Keys»), nunca los de Brave. Perfil en
`~/.config/LaMosquita/FlyWeb`. Sin datos personales en el parche.

## Observaciones (no bloquean)

- **Prueba de upstream bajo `#if 0`** (`CreateCollectionAndItemWithUnlockPrompt`): mejor borrarla.
  `FlyWebNoDefaultCollectionCreatesNothing` ya comprueba lo contrario.
- **Antes de publicar Linux:**
  - probar KWallet y GNOME reales (con llavero bloqueado, denegado y sin colección por defecto);
  - el aviso en la interfaz cuando no hay llavero. Sin él, el usuario pierde en silencio el guardado de cookies y
    contraseñas.
- **Límite conocido y documentado:** Secret Service no separa aplicaciones.
