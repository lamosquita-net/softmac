# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: cookies en `EndSession()` (Mac y Linux), parche 6

Respuesta a `buzon/NUBE-SEGURIDAD-PORTES/20261125-1956-COORDINACION-64-cookies-EndSession.md` (Titín, DIRECTIVAS #1243).
**Sin compilar.** Parche en la carpeta de al lado, con `SHA256SUMS`.

| # | Fichero | sha256 |
|---|---|---|
| 6 | `6-U3-cookies-EndSession-mac-linux.patch` | `90993701d2211501fa787b4b0144f9868e14083d2f0d2220ca3eb7af87187aac` |

## Dónde va

Detrás de U3 final (1–5), en la tanda de la próxima versión, **Mac y Linux**. Toca los mismos dos ficheros que U3:
`chromium_src/chrome/browser/browser_process_impl.cc` y `patches/chrome-browser-browser_process_impl.cc.patch`.

Comprobado con `git apply`:
- sobre `local/322-final` `060015a8` + U3 1–5 (árbol `b2257576b9`), da el árbol **`3dc6bd5337`**;
- sobre la tanda `siguiente-3` brave-core 0001–0010 (árbol `8dc666451e`) + U3 1–5, da el árbol **`582c0ef54b`**.

El `.patch` de Chromium está regenerado sobre el original de la 156 (blob `bed9453f`, el de `branch-heads/8078`).

## Qué hace

- En el bucle de perfiles de `EndSession()`, junto al `CommitPendingWrite` de las preferencias, se añade una línea
  (`BRAVE_BROWSER_PROCESS_IMPL_END_SESSION_FLUSH_COOKIES`). Pide `FlushCookieStore` al `StoragePartition` por defecto de cada
  perfil cargado, con **el mismo `RundownTaskCounter` y el mismo tope de 10 s** (`kEndSessionTimeout`). El peor caso de
  tiempo no cambia.
- **Por qué no `GetCookieManagerForBrowserProcess()`:** el hilo de la interfaz está bloqueado en `TimedWait()`, así que la
  respuesta de mojo no llegaría nunca y siempre se esperarían los 10 s. El parche abre una tubería `CookieManager` propia
  (`GetNetworkContext()->GetCookieManager`) y la ata a una secuencia del *thread pool*. La respuesta llega ahí y descuenta
  el contador.
- **Si el proceso de red ya no está**, la desconexión cuenta como hecho: no se espera al tope.
- **Camino comprobado en la 156:** `CookieManager::FlushCookieStore` → `CookieMonster::FlushStore` →
  `SQLitePersistentCookieStore::Flush` → `Commit()` en segundo plano. Si el almacén aún no ha cargado (clave todavía no
  disponible), `FlushStore` responde enseguida: no hay nada escrito que perder.

## Límites (para que consten)

- **Solo ayuda si el proceso de red sigue vivo** cuando llega la petición. Con SIGTERM al PID del navegador (la prueba de
  D8), lo está.
- **Cuando la señal va a todos los procesos a la vez**, el de red puede morir en paralelo y no hay nada que hacer. Puede
  pasar con systemd al cerrar sesión o al apagar, porque manda SIGTERM a todo el *scope*; en Mac, con launchd al apagar
  [S]. En ese caso no se espera más que hoy.
- **Privacidad:** no cambia nada de fondo. Este camino nunca ha borrado las cookies de «borrar al salir», porque el almacén
  no se destruye, y los lotes anteriores ya estaban en disco. El parche solo añade lo de los últimos 30 s como mucho.
- **Sin prueba automática:** `EndSession()` termina el proceso. Una prueba de navegador sería posible: poner una cookie,
  llamar a `EndSession()` y leer el SQLite, como hace `ProfileBrowserTest` con las preferencias. No encaja en
  `brave_unit_tests`. Si se quiere, la preparo para `brave_browser_tests`.

## Pruebas para D8-LINUX (y LOCAL en Mac, la 3)

1. **SIGTERM al PID del navegador, con la clave tardía a 15 s y a 25 s.** Se pone la cookie después de llegar la clave y se
   manda SIGTERM antes de los 30 s. **La cookie debe quedar escrita.** Antes del parche, con 25 s salía 0.
2. **SIGINT (o `flyweb://quit`):** sin cambios frente a hoy.
3. **Mac:** `kill -TERM <pid>` con FlyWeb abierto, en Mojave. La cookie queda escrita y la salida tarda menos de 1 s.
4. **Informativa:** SIGTERM a todo el grupo (`kill -TERM -- -<pgid>`). Anotar si la cookie queda; no es puerta.
5. **En todas:** salida en menos de 1 s, y nunca 10 s. Si tarda 10 s, la respuesta no está llegando: avisadme.

SEGURIDAD-PORTES-33
