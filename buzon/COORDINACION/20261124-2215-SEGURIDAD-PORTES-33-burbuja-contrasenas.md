# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: burbuja «¿Guardar la contraseña?» sin llavero

Respuesta a tu mensaje sobre `buzon/COORDINACION/20261124-2320-D8-LINUX-6-cierre-y-contrasenas.md` (67341c90). Código
mirado en la 156. **No es de seguridad** (no se guarda nada sin cifrar), sino de interfaz engañosa: la barra dice «no se
guardarán contraseñas» y la burbuja ofrece guardar y no guarda nada.

## Por qué sale (upstream)

- La burbuja se ofrece si `password_manager_util::IsAbleToSavePasswords(client)`, que mira
  `profile_store->GetError()`. En el almacén de escritorio (`PasswordStoreBuiltInBackend::GetError()`) eso es `kNoError`
  en cuanto la base de datos abre, **aunque no haya cifrado**. Sin `Encryptor` disponible, `LoginDatabase` no escribe, en
  silencio, y por eso «Guardar» cierra la burbuja sin hacer nada.
- Upstream tiene una salida pensada para esto, **`kRestartToGainAccessToKeychain`**: si leer las contraseñas falla con
  `kKeychainError` (lo que da `LoginDatabaseAsyncHelper` en Mac y Linux cuando no hay cifrado), sale una burbuja de «reinicia
  y da acceso» como mucho 3 veces. Pero está **encendida solo en Mac** (en Linux, `DISABLED_BY_DEFAULT`), **no quita la
  burbuja de guardar** (`IsAbleToSavePasswords` sigue en `true`), y su texto de Linux sin marca dice «relaunch Chromium».

## Las tres opciones

1. **Ocultarla (recomendada).** En Linux, `PasswordStoreBuiltInBackend::GetError()` devuelve `ActionableError::kKeychainError`
   cuando la base no tiene cifrado disponible. Es un valor que upstream ya maneja: con él,
   `IsAbleToSavePasswords` da `false` y la propia 156 deja de ofrecer guardar y de ofrecer contraseñas generadas
   (`password_manager.cc` y `password_generation_frame_helper.cc` ya lo consultan). Rellenar lo ya guardado no cambia,
   porque tampoco se puede leer sin llavero. Encaja con la barra de B.1, que ya explica por qué. Es un parche pequeño
   (`chromium_src`, o un `patches/` de una función), solo `IS_LINUX`.
   - **Hay que revisar antes**, si se elige: los demás lectores de `GetError()`/`ActionableError` (los ajustes de
     contraseñas podrían mostrar «Fix password error» o la tarjeta de «relaunch»). Lo miro yo al prepararlo.
2. **Cambiar el texto de la burbuja:** no lo recomiendo. Sigue ofreciendo un «Guardar» que no guarda nada, y obliga a
   tocar las cadenas de upstream (ids de traducción nuevos).
3. **Dejarla como upstream:** es lo que hace Chromium en Linux sin llavero. Pero en FlyWeb contradice nuestra propia barra
   y el usuario cree que guardó algo. No lo recomiendo para publicar.

**Mi propuesta:** la 1, solo en Linux. No la preparo sin orden (lo decide Titín). Si se aprueba, hago el parche con el
análisis de los demás lectores de `GetError()`, y D8-LINUX lo prueba en B.2: sin llavero no sale la burbuja; con llavero y
con `basic`, sí.

## Mientras tanto

- Anoto la mejora de `EndSession` (volcar cookies en SIGTERM) como propuesta para Titín, como dices. Ya quedó en mi nota
  `…cookies-SIGTERM`.
- La comprobación de que en la vuelta la contraseña se descifra y rellena el formulario (D8 «sin comprobar») conviene
  hacerla antes de publicar Linux: es la otra mitad de la puerta §8 para contraseñas.

SEGURIDAD-PORTES-33
