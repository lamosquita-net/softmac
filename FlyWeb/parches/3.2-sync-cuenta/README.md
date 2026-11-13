# FlyWeb 3.2: cliente de la sync con cuenta (H3)

MOTOR-46, 13-11-2026, por encargo de COORDINACIÓN-41. Es el hito H3 de [`sync-cuenta.md`](../../docs/sync-cuenta.md) §12:
el cliente que describe §11, con las decisiones de §10.1 y el protocolo del servidor de #977 (SYNC-NUBE-1, rama
`claude/sync-cuenta-h2` en **07c086cee0**, ls-remote del 13-11; referencia: `servidor/sync/cuenta/README.md`).

**Sin compilar.** Se compila cuando la 3.1 esté medida (`plan-3x.md` §5.2) y después de que SEGURIDAD-PORTES revise
el código. Esta sesión no tiene push a brave-core, así que la entrega va como `git format-patch`.

## Base y cómo se aplica

Base: brave-core **`local/3.1.1` = 3e2c12fad5** (ls-remote del 13-11), la 3.1.1 publicada. Rama local
`nube/sync-cuenta-h3` (no subida).

```sh
git checkout -b nube/sync-cuenta-h3 3e2c12fad5
git am FlyWeb/parches/3.2-sync-cuenta/000*.patch
```

| Parche | Qué hace |
|---|---|
| `0001-…account-crypto…` | `components/brave_sync/crypto/account_crypto.{h,cc}`: normalización del email y la contraseña, `KE = scrypt(2^17, 8, 1)` con `max_mem` de 130 MiB, `KL`/`KU` con HKDF-SHA256, la envoltura AES-256-GCM, la clave de cadena (la misma derivación que `BraveSyncAuthManager`, que no se toca) y la prueba de cadena. Pruebas con vectores calculados fuera (`vectores.py`) |
| `0002-…account-client-service…` | `browser/sync/account/`: `flyweb_sync::AccountService`, uno por perfil. Las llamadas a `/cuenta/v1`, las prefs cifradas, los estados de §9, el sondeo de eventos y todas las operaciones |
| `0003-…` | Página «Cuenta y sincronización»: manejadores en `BraveSyncHandler`, interfaz y cadenas (inglés, con traducción es y es-419) |
| `0004-…` | Barras de aviso: «¿Has sido tú?» con «No he sido yo» y «La clave se ha cambiado desde otro Mac» |

## Qué hace el cliente

- **Servidor:** las rutas `/cuenta/v1/…` del mismo origen que `--sync-url`. Esa opción la pone siempre
  `brave_main_delegate` a partir de `brave_sync_endpoint`. Así una instancia de prueba (P12, P15 y P19) solo necesita
  `--sync-url=https://…/v2`. Solo HTTPS, salvo HTTP contra la propia máquina (127.0.0.1 o localhost). Cada petición
  va solo en JSON y sin cookies, con 30 s de límite (§9, P10).
- **Prueba de cadena:** primero pide `nonce`; después firma `"flyweb-cuenta-v1" ‖ lp(POST) ‖ lp(ruta completa) ‖
  lp(op) ‖ lp(cuenta) ‖ lp(nonce) ‖ SHA-256(cuerpo)` con la clave Ed25519 de la cadena y la manda en `X-FlyWeb-*`.
  `cadena/cambiar` firma con la cadena vieja y con la nueva, con el mismo nonce. El cuerpo firmado es exactamente el
  que se envía.
- **Prefs nuevas** (`flyweb_sync_account.*`), cifradas con OSCrypt como la semilla: id y email de la cuenta, id del
  aparato, token y último evento leído. Si alguna no se descifra, el estado es «claves ilegibles» (P9). Sin cifrar
  solo va `notice` (`cuenta-borrada` o `cadena-cambiada`), que no tiene datos personales.
- **Contraseña** (§11): se estira fuera del hilo de la interfaz, una sola a la vez, y la cadena se borra con
  `OPENSSL_cleanse`. Las claves viven en `SecretKey`, que se borra sola. Ver «Para SEGURIDAD-PORTES».
- **Sondeo** (§11): cada 15 min con la sync activa y al abrir la página. Va con el token; si el servidor lo da por
  inválido, lo renueva con la prueba de cadena. Una petición cada vez; si falla, espera 30 min, luego 60, y se queda
  en 60. El primer sondeo tras entrar en una cuenta solo marca como leída la historia (no avisa de ella). Los eventos
  de una operación propia no avisan (ver S3).
- **Cadena desactivada desde otro Mac:** cuando la sync borra la semilla (`DISABLED_BY_ADMIN`), el servicio pregunta
  `eventos` con la clave vieja, que aún tiene en memoria. Si la respuesta es `cadena-sustituida`, el estado es «clave
  cambiada desde otro Mac» y sale su barra (no la de «cuenta borrada» de Brave). Si no, el estado es «cuenta borrada».
- **Mac unido con las 24 palabras** (decisión 11): en cuanto el sondeo dice que la cadena tiene cuenta, se da de alta
  solo, con nombre = modelo (`hw.model`), y el nombre se puede cambiar después. Pendiente de COORDINACIÓN; ver S1.
- **Operaciones:** crear la cuenta (ligando la cadena de este Mac o una nueva, con la clave de recuperación),
  entrar con email + contraseña + código (la envoltura tiene que abrir, P15), las 24 palabras (o 25 con fecha
  válida), cambiar la contraseña con un código, cambiar el email, cambiar la clave de sincronización (semilla nueva,
  salir y volver a entrar; los datos suben otra vez cifrados con la clave nueva), aparatos (listar, quitar,
  renombrar), «No he sido yo», borrar en todos, cancelar un borrado programado, salir en este Mac, y lo que se hace
  solo con el buzón: borrar por email y «Empezar de cero».
- **No toca** el motor de sync, Nigori ni `BraveSyncAuthManager`. Entra y sale de las cadenas con las llamadas
  públicas de `BraveSyncServiceImpl` (`SetSyncCode`, `ResetSync`, `StopAndClearWithResetLocalDataReason`), como la
  página de hoy.

## Pendiente de COORDINACIÓN (preguntas del 13-11)

El cliente ya está escrito para las dos respuestas posibles. Lo que falte se nota así:

- **S1** (servidor): un Mac que no conoce el `cuenta_id` firma con cuenta vacía y hoy recibe 401. El cliente ya lee
  `cuenta` de `eventos` si llega. Sin el cambio, un Mac unido con palabras no sabe que su cadena tiene cuenta: no
  avisa ni se da de alta (sigue sincronizando).
- **S2** (servidor): `email` en `eventos`. El cliente ya lo lee si llega. Sin él, ese mismo Mac no puede cambiar la
  contraseña, el email ni la clave (error `email`), porque el email es la sal del scrypt.
- **S3** (servidor): `datos.aparato` en los eventos. Si llega, el cliente se salta los eventos que ha causado él.
  Mientras no llegue, se salta solo el primer evento del mismo tipo que llegue en el sondeo justo después de la
  operación, y solo si no es más antiguo que la operación (con 5 s de margen).
- **C1:** solo «Combinar»; «Sustituir» y «Quitar marcadores duplicados» no están (P9 a medias).
- **C2:** cadenas en inglés, con traducción es y es-419.
- **C3:** zxcvbn para el indicador de fuerza; solo se exige la longitud mínima.

## Para SEGURIDAD-PORTES (lo que pide revisar §11)

1. **Dónde pasa la contraseña:** `<input type=password>` (sin `<form>`) → mensaje WebUI → `BraveSyncHandler` → por
   valor a `AccountService` → `std::unique_ptr<std::string>` hacia una tarea del grupo de hilos → NFC → scrypt →
   `WipeString` de las dos cadenas. Lo que no se puede borrar: la copia del renderer, la del `base::ListValue` del
   mensaje WebUI y, en contraseñas no ASCII, los búferes internos de ICU (`UnicodeString`); las ASCII no pasan por ICU.
   No va a ninguna pref ni al registro.
2. **`KL` y `KU` en memoria entre dos pasos:** en «entrar» (`entrar/empezar` → código → `entrar/terminar`, que
   necesita `KL` y luego `KU` para abrir la envoltura) y en «cambiar el email» (los de la dirección nueva, más la `KL`
   actual para «Reenviar»). Viven en `SecretKey` dentro de `Flow` hasta terminar, cancelar o pasar los 10 min del
   código; nunca en disco. Es la única forma de no volver a pedir la contraseña después del código. **Lectura mía de
   «se borran de memoria al terminar la llamada»: la operación son los dos pasos.**
3. **Indicador de fuerza:** la contraseña va a C++ a cada pausa al teclear (zxcvbn, como el gestor de contraseñas).
   Son más copias de corta vida; si se prefiere evitarlas, se calcula en JS solo la longitud.
4. **Clave de cadena:** se guarda en memoria (`ChainKeys`, privada borrada al destruirse) mientras la semilla
   exista, y un momento después, para preguntar por qué se desactivó la cadena. `BraveSyncAuthManager` ya la tiene en
   memoria; no se añade nada en disco.
5. **Envoltura:** antes de enviar una envoltura nueva (crear, cambiar la contraseña, el email o la clave, empezar de
   cero), se comprueba que abre (§4.6, primer seguro). Al entrar, si no abre, no se activa nada (P15).
6. **Cambio de clave a medias:** el servidor liga la cadena nueva y borra la vieja en la misma llamada. Si FlyWeb
   se para entre la respuesta y unirse a la cadena nueva, este Mac se queda sin cadena. El remedio es volver a entrar
   con email, contraseña y código: la envoltura nueva ya está en el servidor y los datos siguen en el perfil. No
   guardo la semilla nueva antes de la llamada, para no dejarla en una pref si la llamada falla.

## Pruebas para LOCAL (al compilar)

**Pruebas unitarias:** `brave_unit_tests --gtest_filter='AccountCryptoTest.*'`. `KeysRealCost` escribe en el
registro cuánto tarda el scrypt real; ese es el primer dato para P23.

**Del guion P1–P26 de §12, lo que toca al cliente.** Contra ns2 con H2 instalado, o contra una instancia de prueba
con `--sync-url`. Cada paso se anota con su resultado:

| # | En el cliente, comprobar |
|---|---|
| P1 | Un Mac sincronizado con palabras crea la cuenta: pide email → código → contraseña (10 como mínimo; no sigue sin ella) y nombre; no se resincroniza nada; los demás Macs muestran la barra «Esta sincronización se ha ligado a una cuenta» |
| P2 | B y C entran con email + contraseña + código y reciben los datos; A muestra «Se ha añadido el Mac «nombre»»; B no muestra avisos de la historia anterior |
| P4 | Contraseña mala y código malo dan un solo mensaje: «La contraseña o el código no son correctos.» |
| P5 | Con la contraseña buena y sin el buzón, la página del intruso dice lo mismo que con una mala. A y B muestran «Alguien ha escrito bien tu contraseña desde un Mac nuevo». Tras fallos, la barra de fallos y «Demasiados intentos. Podrás volver a probar a las HH:MM.» con la hora del servidor |
| P6 | Cambio de contraseña en A con un código y sin la anterior. A no se avisa a sí mismo. B y C muestran «¿Has sido tú?». «No he sido yo» en B renueva el token solo (prueba de cadena) y lleva a cambiar la contraseña y la clave |
| P7 | «Salir en este Mac» en C: C conserva el perfil, sale de la lista y el estado pasa a «sin cuenta» |
| P8 | «Borrar en todos» en A: confirmación con N navegadores; B y C pasan a «La cuenta se ha borrado desde otro Mac» |
| P9 | Llavero cambiado → «claves ilegibles» → «Volver a unir» → combinar sin duplicados. **«Sustituir», no (C1)** |
| P10 | Servidor parado a mitad de cada operación: a los 30 s como mucho, mensaje y Reintentar; «sin red» con lo último que se sabía |
| P11 | «He olvidado la contraseña» con un Mac (código → contraseña nueva, datos intactos); con las palabras (se une; luego lo mismo; necesita S1/S2); sin nada («Empezar de cero»); en un Mac nuevo, las dos salidas de §5.1 |
| P13 | Una 3.0.1 con palabras y una 3.2 con cuenta en la misma cadena sincronizan entre sí; NetLog solo con `sync.flyweb.lamosquita.net` |
| P15 | Con una instancia que entrega una envoltura cambiada: «La clave recibida no es válida. No se ha activado nada.»; la cadena no cambia |
| P16 | «Cambiar la clave de sincronización» en A con su contraseña: A enseña 24 palabras nuevas y pide confirmar que están guardadas; C (quitado de la lista) deja de leer y muestra «clave cambiada»; B también, y vuelve a entrar con email, contraseña y código |
| P19 | «Empezar de cero» solo con el buzón: el Mac sincroniza ya con una cadena nueva y enseña sus palabras; A muestra «borrado pedido» y lo cancela |
| P21 | En C, con la cadena sola: «Cambiar la contraseña», «el email» y «la clave» piden código o contraseña y no se hacen sin ellos |
| **P23** | **Antes de publicar**, en la 6,1 y en la 5,1: cronometrar el scrypt (la prueba unitaria `KeysRealCost`, o el tiempo de «Comprobando la contraseña…»). Mirar en el Monitor de Actividad que el proceso sube unos 128 MiB y los devuelve. Con el gestor de contraseñas activo, comprobar que no ofrece guardar la contraseña de la cuenta. Si la 5,1 pasa de 2 s (o la 6,1 de 1 s), `kScryptN` pasa a `1 << 16` en `account_crypto.h` y se corrige §4 |
| P26 | Cambio de email con la contraseña y un código a la dirección nueva; un Mac nuevo entra con la nueva |

P3 y P25 están retiradas. P12, P14, P17, P18, P20, P22 y P24 son del servidor; el cliente solo aporta que siempre
manda JSON, sin cookies y con una prueba nueva en cada llamada.

## Riesgos al compilar

Sin compilar, lo más probable es que fallen:

- nombres de `base::DictValue` y `base::ListValue` y sus métodos `Find*`;
- la firma de `OSCryptAsync::GetInstance`, copiada de `BraveSyncServiceImpl`;
- `CreateConfirmInfoBar`;
- las rutas de zxcvbn;
- las reglas DEPS y `gn check` de `//third_party/icu` y `//third_party/zxcvbn-cpp`;
- el registro de los ficheros TS en los ajustes.

Son errores de compilación, no de diseño. LOCAL los manda por COORDINACIÓN y los arreglo en el parche.

## Ficheros

- `000*.patch`: los parches.
- `vectores.py`: los vectores de 0001. Se ejecuta con `python3 -I vectores.py english.txt`, donde `english.txt` es
  la lista BIP39 inglesa. Necesita `cryptography`. Comprueba además que el `client_id` de las palabras de
  `brave_sync_auth_manager_unittest.cc` sale igual.
- `SHA256SUMS`.
