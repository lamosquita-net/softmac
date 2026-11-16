# FlyWeb 3.2: cliente de la sync con cuenta (H3)

MOTOR-46, 13-11-2026, por encargo de COORDINACIÓN-41. Es el hito H3 de [`sync-cuenta.md`](../../docs/sync-cuenta.md) §12:
el cliente que describe §11, con las decisiones de §10.1 y el protocolo del servidor de #977 (SYNC-NUBE-1, rama
`claude/sync-cuenta-h2`, ahora en **cbe0221b49**, con S1–S3 (ls-remote del 13-11); referencia: `servidor/sync/cuenta/README.md`).

**Sin compilar.** Se compila cuando la 3.1 esté medida (`plan-3x.md` §5.2) y después de que SEGURIDAD-PORTES revise
el código. Esta sesión no tiene push a brave-core, así que la entrega va como `git format-patch`.

## Base y cómo se aplica

Base: brave-core **`local/3.1.1` = 3e2c12fad5** (ls-remote del 13-11), la 3.1.1 publicada. Rama local
`nube/sync-cuenta-h3` (no subida). Servidor de referencia: #977 en cbe0221b49.

```sh
git checkout -b nube/sync-cuenta-h3 3e2c12fad5
git am FlyWeb/parches/3.2-sync-cuenta/000*.patch
```

Comprobado: los ocho entran limpios con `git am` sobre 3e2c12fad5 y dan el árbol **1f10366325**, igual que la rama
local. Servidor de referencia para K3: #977 en **60cc1d0800** (ls-remote del 13-11). El TypeScript de la página pasó `tsc` estricto, con módulos de relleno para los import. El C++ no se ha
compilado.

**Para que Titín los vea antes de publicar** (cambian lo que se ve):
- el título de la sección;
- toda la página nueva;
- dos textos que el diseño no daba y he escrito yo: el de «datos perdidos» de §6.1 (`…FORGOT_NOTHING`) y el aviso
  de los 14 y 30 días (`…DELAY_WARNING`).

| Parche | Qué hace |
|---|---|
| `0001-sync-account-crypto-for-the-FlyWeb-3.2-sync-account-.patch` | `components/brave_sync/crypto/account_crypto.{h,cc}`: normalización del email y la contraseña, `KE = scrypt(2^17, 8, 1)` con `max_mem` de 130 MiB, `KL`/`KU` con HKDF-SHA256, la envoltura AES-256-GCM, la clave de cadena (la misma derivación que `BraveSyncAuthManager`, que no se toca) y la prueba de cadena. Pruebas con vectores calculados fuera (`vectores.py`) |
| `0002-sync-FlyWeb-3.2-sync-account-client-service-H3.patch` | `browser/sync/account/`: `flyweb_sync::AccountService`, uno por perfil. Las llamadas a `/cuenta/v1`, las prefs cifradas, los estados de §9, el sondeo de eventos y todas las operaciones |
| `0003-settings-Cuenta-y-sincronizaci-n-page-for-the-FlyWeb.patch` | Página «Cuenta y sincronización»: manejadores en `BraveSyncHandler` (con zxcvbn para la fuerza) y el componente `settings-flyweb-sync-account` con los nueve estados de §9. Cadenas: 118 de la página y 16 de las barras, en inglés con traducción es y es-419; los id son la huella de grit, comprobada con los mensajes que ya había. El título de la sección pasa a «Cuenta y sincronización» |
| `0004-sync-FlyWeb-3.2-sync-account-warning-bars.patch` | Barras de aviso: «¿Has sido tú?» con «No he sido yo» y «La clave se ha cambiado desde otro Mac» |
| `0005-sync-account-client-fixes-from-the-security-review-S.patch` | Arreglos de la revisión de SEGURIDAD-PORTES-23 (abajo) |
| `0006-sync-device-secret-of-the-sync-account-K3-977-C1.patch` | K3: el secreto de aparato que da el servidor (#977 en 60cc1d0) |
| `0007-sync-build-fixes-for-the-156-tree-first-compile-of-t.patch` | Arreglos de la primera compilación de LOCAL-19 (abajo) |
| `0008-sync-log-how-long-the-account-key-derivation-takes-P.patch` | Registro del tiempo de la derivación, para medir P23 desde la página (abajo) |

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
  de una operación propia no avisan cuando el servidor dice que el autor es este Mac (S3).
- **Cadena desactivada desde otro Mac:** cuando la sync borra la semilla (`DISABLED_BY_ADMIN`), el servicio pregunta
  `eventos` con la clave vieja, que aún tiene en memoria. Si la respuesta es `cadena-sustituida`, el estado es «clave
  cambiada desde otro Mac» y sale su barra (no la de «cuenta borrada» de Brave). Si no, el estado es «cuenta borrada».
- **Mac unido con las 24 palabras** (decisión 11): en cuanto el sondeo dice que la cadena tiene cuenta, se da de alta
  solo, con nombre = modelo (`hw.model`), y el nombre se puede cambiar después (S1).
- **Operaciones:** crear la cuenta (ligando la cadena de este Mac o una nueva, con la clave de recuperación),
  entrar con email + contraseña + código (la envoltura tiene que abrir, P15), las 24 palabras (o 25 con fecha
  válida), cambiar la contraseña con un código, cambiar el email, cambiar la clave de sincronización (semilla nueva,
  salir y volver a entrar; los datos suben otra vez cifrados con la clave nueva), aparatos (listar, quitar,
  renombrar), «No he sido yo», borrar en todos, cancelar un borrado programado, salir en este Mac, y lo que se hace
  solo con el buzón: borrar por email y «Empezar de cero».
- **No toca** el motor de sync, Nigori ni `BraveSyncAuthManager`. Entra y sale de las cadenas con las llamadas
  públicas de `BraveSyncServiceImpl` (`SetSyncCode`, `ResetSync`, `StopAndClearWithResetLocalDataReason`), como la
  página de hoy.

## Decisiones de COORDINACIÓN-41 (13-11) y servidor que se usa

Respuestas a las preguntas de MOTOR-46. El servidor que corresponde es #977 en **cbe0221b49** (ls-remote del 13-11):
S1 en 1f40b49, S2 y S3 en cbe0221.

- **S1:** en `eventos` y `aparatos/renovar` la prueba vale con cuenta vacía, y `eventos` devuelve `cuenta`. Un Mac
  unido con las palabras descubre así la cuenta y se da de alta solo (decisión 11: nombre = modelo y aviso «Mac
  añadido»).
- **S2:** el `email` solo llega en `eventos` con prueba de cadena. Mientras no lo sabe, el cliente sondea con prueba;
  después lo guarda cifrado y sigue con el token.
- **S3:** `datos.aparato` es el autor verificado. El cliente manda su token también en las llamadas con prueba y en
  `email/cambiar/terminar`, y no avisa de los eventos cuyo autor es él. Si el servidor no da el autor, avisa.
- **C1:** solo «Combinar»; «Sustituir» lo decide Titín. Si entra, va en un parche aparte: es un estado más de la
  página y un paso antes de `JoinChain`, sin tocar lo de aquí.
- **C2:** fuente en inglés y traducción es y es-419. **C3:** zxcvbn del árbol, barra de 0 a 4; solo bloquea la
  longitud mínima.

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

## Revisión de SEGURIDAD-PORTES-23 (13-11): APTO con condiciones → 0005

Revisión en #981 (comentario 6865456375), sobre c461080ebe. Arreglos de 0005:

- **K1.** La «línea base» del primer sondeo, que marca la historia como leída sin avisar, solo se aplica después de
  crear la cuenta o entrar en este Mac.
  - Un Mac que descubre la cuenta por el sondeo (S1) siempre avisa con «Esta sincronización se ha ligado a la
    cuenta «email»».
  - Los botones son «He sido yo» y «No la he ligado yo»; este abre la página, donde está «Borrar la cuenta y los
    datos en todos».
  - Solo se saltan los eventos anteriores a cuando este Mac se unió (si lo sabe).
  - Riesgo que cierra: un Mac robado liga la cadena a la cuenta del ladrón sin aviso en los demás Macs.
- **K2.** El email guardado es la sal del scrypt.
  - Con el evento `email-cambiado`, el cliente borra el email guardado y vuelve a sondear con prueba de cadena.
  - Además, cambiar la contraseña, el email o la clave pide antes el email al día con la prueba.
- **K3 (0006).** Secreto por aparato.
  - Lo genera el servidor y lo devuelven `alta/confirmar`, `entrar/terminar` y `aparatos/renovar` cuando da de alta.
  - El cliente lo guarda cifrado, como el token.
  - Lo manda junto a `aparato` en `aparatos/renovar`, `contrasena/cambiar` y `cadena/cambiar`.
  - Si una renovación responde «credenciales», el cliente olvida el aparato y en el siguiente sondeo se da de alta otra
    vez, con el aviso «Mac añadido» en todos los Macs.
  - Lo que evita: que quien tenga solo la cadena se quede con el token de este Mac y aparezca como su autor (S3).
  - 0006 sustituye la generación en el cliente que traía 0005.
- **O-a.** Un reintento de «cambiar la contraseña» manda la misma envoltura, si abre con la misma contraseña, para
  que el servidor repita su respuesta.
- **O-b.** Los avisos sin contestar se guardan cifrados (pref `flyweb_sync_account.warnings`) y siguen ahí tras
  reiniciar.
- **O-c.** Si este Mac sale de la cadena con los botones de Brave y la cuenta sigue activa, el estado ya no es
  «cuenta borrada».
- **Además:** si los eventos venían en varias páginas, se perdían los avisos de la primera; ya no.

Cadenas nuevas, con traducción es y es-419: `IDS_FLYWEB_SYNC_ACCOUNT_WARNING_CHAIN_LINKED_EMAIL` (huella
1700890504399928133) y `…_NOT_LINKED_BY_ME` (9216077204680478027).

## Primera compilación (LOCAL-19, 14-11) → 0007

La preliminar compila y arranca con estos cuatro arreglos. 0001–0006 no cambian; sus SHA256 siguen siendo los mismos.

- `account_crypto.cc`: la BoringSSL de la 156 no define `ED25519_SEED_LEN`. Se usa una constante propia
  `kEd25519SeedLen = 32`, con `static_assert` contra `ED25519_PRIVATE_KEY_LEN / 2` y `ED25519_PUBLIC_KEY_LEN`.
  Revisados contra boringssl 2ea3200c3a, la revisión que fija la 156, los demás símbolos que usa 0001:
  `EVP_PBE_scrypt`, `HKDF`, `EVP_aead_aes_256_gcm`, `ScopedEVP_AEAD_CTX`, Ed25519, `OPENSSL_cleanse` y `SHA256`. Todos
  existen con esas firmas.
- Barra de «borrado pedido»: `base::LocalizedTimeFormatWithPattern` no existe en la 156.
  - La fecha usa ICU con el esqueleto «dMMMM» en el idioma de la interfaz («14 de noviembre», «November 14»).
  - Si ICU falla, se usa `TimeFormatShortDate`.
  - Hacían falta las dependencias `//base:i18n` y `//third_party/icu` en `browser/infobars`.
- `brave_sync_handler.cc`: faltaba el include de `utf_string_conversions.h`.
- `flyweb_sync_account_service.cc`: el valor «fecha» va como `double`. Son segundos Unix, que un double guarda
  exactos.

## Medir P23 desde la página → 0008

Primer dato (LOCAL-19, 14-11): en la 7,1, `AccountCryptoTest` pasa entero (9/9). `KeysRealCost` da 348 ms con
N = 2^17; Python/OpenSSL en la misma máquina da 266–322 ms. `ChainIdIsTheGoSyncClientId` pasa, así que la derivación
da el mismo id de cadena que la sync de siempre. En la 6,1, `brave_unit_tests` muere al iniciar GL (SIGTRAP) antes de
llegar a la prueba. No es un fallo del cifrado.

0008 añade una línea de registro con el tiempo de la derivación y si salió bien. No registra el email ni ninguna clave.
Así se mide en cada Mac con la propia página, contra ns2, sin herramienta aparte:

```sh
FlyWeb.app/Contents/MacOS/FlyWeb --enable-logging=stderr --vmodule=flyweb_sync_account_service=1
```

Se entra o se crea la cuenta y se busca `key derivation ok in N ms`. Sale una línea por
cada derivación: cada vez que la página usa la clave de la cuenta (crearla, entrar, cambiarla, comprobarla).

## Pruebas para LOCAL (al compilar)

**Pruebas unitarias:** `brave_unit_tests --gtest_filter='AccountCryptoTest.*'`. `KeysRealCost` escribe en el
registro cuánto tarda el scrypt real; ese es el primer dato para P23.

**Del guion P1–P26 de §12, lo que toca al cliente.** Contra ns2 con H2 instalado, o contra una instancia de prueba
con `--sync-url`. Cada paso se anota con su resultado:

| # | En el cliente, comprobar |
|---|---|
| P1 | Un Mac sincronizado con palabras crea la cuenta: pide email → código → contraseña (10 como mínimo; no sigue sin ella) y nombre; no se resincroniza nada; los demás Macs (que la descubren por el sondeo) muestran «Esta sincronización se ha ligado a la cuenta «email»» con «No la he ligado yo» (K1) |
| P2 | B y C entran con email + contraseña + código y reciben los datos; A muestra «Se ha añadido el Mac «nombre»»; B no muestra avisos de la historia anterior |
| P4 | Contraseña mala y código malo dan un solo mensaje: «La contraseña o el código no son correctos.» |
| P5 | Con la contraseña buena y sin el buzón, la página del intruso dice lo mismo que con una mala. A y B muestran «Alguien ha escrito bien tu contraseña desde un Mac nuevo». Tras fallos, la barra de fallos y «Demasiados intentos. Podrás volver a probar a las HH:MM.» con la hora del servidor |
| P6 | Cambio de contraseña en A con un código y sin la anterior. A no se avisa a sí mismo. B y C muestran «¿Has sido tú?». «No he sido yo» en B renueva el token solo (prueba de cadena) y lleva a cambiar la contraseña y la clave |
| P7 | «Salir en este Mac» en C: C conserva el perfil, sale de la lista y el estado pasa a «sin cuenta» |
| P8 | «Borrar en todos» en A: confirmación con N navegadores; B y C pasan a «La cuenta se ha borrado desde otro Mac» |
| P9 | Llavero cambiado → «claves ilegibles» → «Volver a unir» → combinar sin duplicados. **«Sustituir», no (C1)** |
| P10 | Servidor parado a mitad de cada operación: a los 30 s como mucho, mensaje y Reintentar; «sin red» con lo último que se sabía |
| P11 | «He olvidado la contraseña» con un Mac (código → contraseña nueva, datos intactos); con las palabras (se une, se da de alta solo y sabe el email: S1 y S2; luego lo mismo); sin nada («Empezar de cero»); en un Mac nuevo, las dos salidas de §5.1 |
| P13 | Una 3.0.1 con palabras y una 3.2 con cuenta en la misma cadena sincronizan entre sí; NetLog solo con `sync.flyweb.lamosquita.net` |
| P15 | Con una instancia que entrega una envoltura cambiada: «La clave recibida no es válida. No se ha activado nada.»; la cadena no cambia |
| P16 | «Cambiar la clave de sincronización» en A con su contraseña: A enseña 24 palabras nuevas y pide confirmar que están guardadas; C (quitado de la lista) deja de leer y muestra «clave cambiada»; B también, y vuelve a entrar con email, contraseña y código |
| P19 | «Empezar de cero» solo con el buzón: el Mac sincroniza ya con una cadena nueva y enseña sus palabras; A muestra «borrado pedido» y lo cancela |
| P21 | En C, con la cadena sola: «Cambiar la contraseña», «el email» y «la clave» piden código o contraseña y no se hacen sin ellos |
| **P23** | **Antes de publicar**, en la 6,1 y en la 5,1: cronometrar el scrypt (la prueba unitaria `KeysRealCost` o el registro de 0008). Mirar en el Monitor de Actividad que el proceso sube unos 128 MiB y los devuelve. Con el gestor de contraseñas activo, comprobar que no ofrece guardar la contraseña de la cuenta. El tiempo sale en el registro de 0008 (arriba). Si la 5,1 pasa de unos 2 s, se avisa a COORDINACIÓN antes de tocar nada: bajar `kScryptN` cambia la seguridad de la cuenta y lo decide SEGURIDAD-PORTES |
| P26 | Cambio de email con la contraseña y un código a la dirección nueva; un Mac nuevo entra con la nueva. Después, en B (que tenía el email viejo), «cambiar la contraseña» funciona y un Mac nuevo entra con el email nuevo y la contraseña nueva (K2) |

P3 y P25 están retiradas. P12, P14, P17, P18, P20, P22 y P24 son del servidor; el cliente solo aporta que siempre
manda JSON, sin cookies y con una prueba nueva en cada llamada.

## Cómo se comporta la página en tres casos

- **Sin cuenta pero con cadena** (el caso de los 7 usuarios): ofrece «Crear cuenta», que liga esta cadena, y «Ver la
  clave de recuperación». No ofrece «Entrar» ni «Tengo mi clave», que cambiarían de cadena a un Mac que ya sincroniza.
- **Clave de recuperación de una cadena nueva** (crear, cambiar la clave, empezar de cero): la cadena ya sincroniza
  cuando la página pide marcar «He guardado la clave de recuperación». No se puede seguir sin marcarla, pero eso no
  para la sincronización.
- **«Claves ilegibles»:** «Volver a unir» (entrar o las palabras) sobrescribe las prefs que no se leen y limpia el
  estado.

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
