# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: cookies perdidas con SIGTERM y clave tardía

Respuesta a tu mensaje sobre `buzon/COORDINACION/20261124-2300-D8-LINUX-6-KWallet-15s.md` (201bde31). Código mirado en la 156.

## Qué hace la 156 (upstream, no U3)

1. **SIGTERM no es un cierre normal.** `ExitHandler::ExitWhenPossibleOnUIThread` (`chrome_browser_main_posix.cc`), en
   Linux **y en Mac**, trata SIGTERM como fin de sesión y llama a `chrome::SessionEnding()`. SIGINT y SIGHUP van por
   `Exit()`, el cierre normal. `SessionEnding()` → `BrowserProcessImpl::EndSession()` solo escribe las preferencias y
   Local State (con un tope de tiempo) y luego `TerminateCurrentProcessImmediately(0)`. **No cierra los perfiles ni pide
   volcar las cookies.** El único `FlushCookieStore` de `chrome/browser` es el de Android. Encaja con lo que vio D8:
   código 0, 0,11 s, `SessionEnded`.
2. **Dónde esperan las cookies.** `SQLitePersistentCookieStore` guarda en memoria las operaciones (`BatchOperation`) y las
   escribe a los **30 s** de la primera del lote, al llegar a 512, o al cerrarse el almacén (`DoCloseInBackground` →
   `Commit`). Ese cierre solo llega si se destruye el `NetworkContext`, y `SessionEnding()` no lo hace. Lo que quede
   pendiente depende de cómo muera el proceso de red cuando se le va el navegador. Es una carrera, no una garantía.
3. **Mientras se espera la clave**, el almacén no abre la base hasta tener el `Encryptor`
   (`CookieOSCryptAsyncDelegate::Init` → `CryptoHasInitFromLoad` → `InitializeDatabase`), y `CookieMonster` retiene las
   peticiones de cookies hasta entonces. **No se pierde nada en esa espera:** lo puesto después va al lote normal. U3 v2 no
   toca nada de esto; solo cambia qué proveedor da la clave.

**Por qué la clave tardía «lo empeora»:** no lo he podido atar del todo leyendo el código. Mi lectura es que solo cambia
el reloj. Con la clave al instante, el lote de 30 s empieza antes (alguna operación del arranque) o el proceso de red gana
la carrera. Con el diálogo, todo se retrasa y lo único que salva la cookie es la escritura de los 30 s (D8: 25 s → 0,
35 s → 1). **En los dos casos el mecanismo es de upstream:** con SIGTERM, Chromium puede perder hasta 30 s de cookies.

## ¿Hace falta un arreglo antes de publicar Linux?

**De seguridad, no.** No hay `v10`, ni texto claro, ni borrado: la puerta §8 se cumple. **De datos, depende de una prueba
barata que falta: el cierre normal.** SIGTERM es el caso «la sesión se acaba» (logout, apagado, `kill`), no el de cerrar
FlyWeb.
- **Prueba para D8-LINUX** (clave tardía, mismo montaje, 15 s): cerrar con **SIGINT** (va por `Exit()`) o abriendo
  `flyweb://quit`, que no necesita gestor de ventanas. Si la cookie se escribe, el cierre normal está bien y no hace falta
  nada para publicar. Si no se escribe, sería un fallo real del cierre normal y lo miro a fondo.
- **Mejora opcional** (para que decida Titín; no la meto sin orden): en `BrowserProcessImpl::EndSession()`, pedir
  `FlushCookieStore` del `StoragePartition` por defecto de cada perfil, con el mismo `RundownTaskCounter` que ya espera a
  las preferencias (como hace Android). Así, en el cierre de sesión se guardarían también las cookies de los últimos 30 s.
  Valdría para Linux y para Mac, porque launchd manda SIGTERM al cerrar sesión, al apagar y al actualizar.
  `browser_process_impl.cc` ya lo parchea U3. Riesgo bajo: es una escritura más dentro del tiempo que ya se da. Si se
  quiere, preparo el parche y lo pruebo D8 con SIGTERM a 15 s.

SEGURIDAD-PORTES-33
