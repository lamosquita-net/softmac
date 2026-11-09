# FlyWeb 3.2 — sincronización con cuenta (F7.7): diseño

ARQUITECTURA, 09-11-2026, por orden de Titín (vía COORDINACIÓN-36). Solo papel: nada compilado ni probado. Desarrolla
los puntos 1–6 de `plan-3x.md` §5.1 con el flujo que eligió Titín el 06-11 (`TAREAS.md:281`) y las condiciones de
COORDINACIÓN-30. **Propone; decide Titín** (hito 1 de `plan-3x.md` §5.2). Antes de su sí y de la revisión de SEGURIDAD
(§14), ni una línea de código.

Marcas: **[V]** visto en el código o en los documentos citados; **[I]** inferido; **[P]** propuesta mía. Sin datos
personales de nadie.

## 1. Resumen

- **La cuenta envuelve la cadena; la cadena no cambia.** Hoy una cadena de sync es una semilla de 32 bytes que vive
  solo en los Macs del usuario; de ella salen las 24 palabras, la clave de firma Ed25519 con la que el navegador se
  identifica ante ns2 y la clave con la que cifra los datos [V]. El diseño deja todo eso igual y pone encima una
  **cuenta** (email + contraseña + código por email) cuyo único papel es **llevar la semilla de un Mac a otro sin
  teclear 24 palabras**, con la aprobación de un Mac ya sincronizado.
- **El servidor no guarda nada que descifre nada.** La contraseña solo autentica (el servidor ve un verificador); la
  semilla viaja de Mac a Mac cifrada para el Mac que la pide; la **clave de recuperación son las 24 palabras de
  siempre**, que no se suben a ningún sitio [P]. Perder todos los Macs y las palabras = perder los datos, como dijo
  Titín, y la página lo dice con su texto.
- **Todo lo nuevo es aditivo:** el protocolo de sync y `flyweb-sync` siguen iguales; las cuentas son rutas y tablas
  nuevas en el mismo binario y el mismo SQLite. La 2.7.x y la 3.0.x siguen sincronizando con palabras contra el mismo
  servidor; los 7 usuarios de hoy no tienen que hacer nada hasta que quieran crear su cuenta desde un Mac sincronizado.
- **El email es el único dato personal** en ns2: se guarda como HMAC para entrar y cifrado con una clave que no está en
  la base para mandar códigos y el aviso de borrado; sin IP, sin nombre, sin registro de peticiones.
- **Riesgo medio-alto** (`plan-3x.md` §5.2): criptografía elegida entre lo que ya trae BoringSSL (scrypt, X25519,
  HPKE) para no meter dependencias nuevas, y una lista de preguntas concretas para SEGURIDAD en §14.

## 2. Punto de partida: lo que ya hay [V]

| Pieza | Qué es hoy | Dónde |
|---|---|---|
| Semilla | 32 bytes aleatorios (`GetSeed`), mostrados como 24 palabras BIP39; con la fecha, 25 («palabras con tiempo», caducan) y QR v2 con `not_after` | `components/brave_sync/crypto/crypto.{h,cc}`, `time_limited_words.h`, `qr_code_data.h` |
| Identidad ante el servidor | HKDF-SHA512 de la semilla → par Ed25519; `client_id` = clave pública en hex | `crypto.cc:43-55`, `brave_sync_auth_manager.cc:35-52` |
| Token de cada petición | `base64(timestamp_hex\|firma_hex\|clave_pública_hex)`; go-sync comprueba firma y hora (±1 día) | `brave_sync_auth_manager.cc:94-120`; `servidor/sync/README.md` |
| Cifrado de los datos | Chromium (Nigori) con frase personalizada = las palabras; el servidor solo ve cifrado | `brave_sync_service_impl.cc:212-220` |
| Dónde vive la semilla | pref `brave_sync_v2.seed`, cifrada con OSCrypt (llavero de macOS); si el llavero no la descifra, `failed_to_decrypt` y la cadena queda inservible en ese Mac | `brave_sync_prefs.cc:23-24,123-146` |
| Servidor | go-sync de Brave + SQLite + caché en memoria; tablas `entities`, `tags`, `disabled`, `counts`; solo `POST /v2/command/`; sin IP ni registro de peticiones | `servidor/sync/main.go`, `sqlite.go:24-40` |
| Borrar cuenta | `PermanentlyDeleteAccount` (hasta 5 intentos) → el servidor hace `ClearServerData` y marca la cadena en `disabled`; los demás Macs reciben `DISABLED_BY_ADMIN` y `ResetEngine` deja pendiente el aviso «cuenta borrada» | `brave_sync_service_impl.cc:231-287,290+`; `sqlite.go:381-424` |
| Cadenas sin uso | `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS` (0 = no; 365 previsto); desactiva la cadena como si el usuario la hubiera borrado | `main.go:99-113`, `sqlite.go:84-110` |
| Usuarios | 7 (Titín, 06-11) | `TAREAS.md:281` |
| Página de ajustes | en la 3.0.0 estaba sin manejadores (FS.43, arreglado en la 3.0.1 por MOTOR-43); `DISABLED_BY_ADMIN` sigue sin tratar en la página | `parches/3.0.2-sync-ajustes/README.md` |
| Ubicación | ns2 en OVH, Francia (UE) | `docs/SERVIDOR.md:13` |

## 3. Modelo: quién tiene qué

| Cosa | Usuario | Mac sincronizado | Mac nuevo (antes de aprobarlo) | Servidor (ns2) |
|---|---|---|---|---|
| Contraseña | la sabe | no la guarda | la teclea | **nunca**: verificador (§4) |
| Semilla / 24 palabras | las tiene guardadas (clave de recuperación) | sí, en el llavero | **no** hasta la aprobación | **nunca** |
| Datos sincronizados | — | en claro, en el perfil | no | cifrados, ilegibles |
| Email | — | no hace falta | lo teclea | HMAC (para entrar) + cifrado con clave del servidor (para escribirle) |
| Token de aparato (§10) | — | sí, en el llavero | sí, tras entrar | hash |
| Par X25519 de la petición (§5) | — | — | privada en el llavero; pública en el servidor | pública |
| Peticiones pendientes | las ve y aprueba | las ve | la suya | modelo, fecha, clave pública, código corto |

Conclusión del modelo: **con email + contraseña + buzón de correo no se llega a los datos.** Se llega a la cuenta (lista de
aparatos, peticiones, cambio de contraseña, borrado con demora), nunca a la semilla.

## 4. Punto 1: derivación de claves sin que el servidor vea la contraseña

**Objetivo (COORDINACIÓN-30):** la contraseña se transforma en el cliente; el servidor guarda solo un verificador.

1. **Normalizar** el email (minúsculas, sin espacios, NFC) y la contraseña (NFC). Longitud mínima de contraseña: 10.
2. **Clave de inicio de sesión** `KL = scrypt(contraseña, sal = SHA-256("flyweb-cuenta-v1" ‖ email), N = 2^17, r = 8,
   p = 1, 32 bytes)` [P]. La sal es determinista (sale del email) para no tener que pedir al servidor una sal por cuenta
   antes de entrar, que delataría si el email existe. Coste: 128 MiB y del orden de medio segundo en la 6,1 [I].
3. **Verificador** en el servidor: `V = scrypt(KL, sal_servidor (16 bytes aleatorios por cuenta), N = 2^14, r = 8,
   p = 1)` [P]. El cliente manda `KL`; el servidor compara `scrypt(KL, sal_servidor)` con `V` en tiempo constante.
   Quien se lleve la base tiene `V` y la sal: no puede sacar `KL` sin romper scrypt, y con `KL` solo entraría en la
   cuenta (§3), no en los datos.
4. **Cambio de contraseña:** `KL` nuevo → `V` nuevo. **No hay nada que recifrar** porque la contraseña no envuelve ni
   la semilla ni los datos [P]. Es la consecuencia más útil del modelo de §3: cambiar la contraseña nunca puede perder
   datos. Al cambiarla, el servidor invalida los tokens de aparato salvo el que hizo el cambio y manda a los demás el
   aviso de §6 («¿Has sido tú?»).
5. **Por qué scrypt y no Argon2:** BoringSSL del árbol trae `EVP_PBE_scrypt` y no trae Argon2 [V]; Argon2 sería una
   dependencia nueva en el navegador (y otra cosa que portar en cada base). En Go hay las dos (`x/crypto`). Si
   SEGURIDAD prefiere Argon2id, el cambio es local a este paso.
6. **Por qué no OPAQUE ni SRP:** evitan que `KL` viaje al servidor, pero son protocolos de varios pasos con poca
   implementación en Chromium y en Go, y el beneficio es pequeño: `KL` viaja por TLS y, aun interceptado, no abre los
   datos. Queda como alternativa si SEGURIDAD lo exige (§14).

## 5. Punto 2: aprobación entre aparatos

**Objetivo (Titín, d):** un Mac nuevo o recuperado no recibe la semilla hasta que lo apruebe un Mac ya sincronizado, que
se la pasa cifrada; el servidor no la ve. **Matiz:** sin móvil la aprobación no es inmediata; la petición espera sin
caducar.

Protocolo [P]:

1. **Mac nuevo:** entra en la cuenta (email, contraseña → `KL`, código por email). Genera un par X25519 y guarda la
   privada en el llavero (pref cifrada con OSCrypt, como la semilla). Envía `petición = {clave pública, modelo del Mac
   (p. ej. «MacPro6,1»), versión de FlyWeb}`. El servidor le devuelve un `id` y el Mac muestra un **código corto** de 6
   caracteres = base32 de `SHA-256(clave pública ‖ id)` [P], con el texto: «Aprueba este Mac desde otro de tus Macs
   sincronizados. Allí verás este código: …».
2. **Macs sincronizados:** al sondear la cuenta (§10) ven la petición nueva y muestran una barra de aviso («Un Mac
   nuevo pide unirse a tu cuenta»); la página de Sincronización lista modelo, fecha y **el mismo código corto**.
   El usuario compara el código con el que ve en el Mac nuevo y pulsa Aprobar o Rechazar.
3. **Aprobar:** el Mac que aprueba cifra la semilla para la clave pública de la petición con HPKE (DHKEM X25519 +
   HKDF-SHA256 + ChaCha20-Poly1305, `EVP_HPKE` de BoringSSL [V]), con `info = "flyweb-aprobacion-v1" ‖ id`, y sube el
   resultado. El servidor lo guarda tal cual (para él es opaco) y marca la petición como aprobada.
4. **Mac nuevo:** sondea cada 30 s mientras la página esté abierta y cada 15 min en segundo plano, con retroceso
   exponencial si hay errores (regla de la casa: nunca en bucle contra ns2). Al recibir la respuesta, descifra con su
   privada, llama a `SetSeed` con las palabras y se une a la cadena exactamente como hoy. Borra el par X25519.
5. **Sin caducidad:** la petición espera días si hace falta (Titín: «navegadores en casa, usuario fuera»). Topes:
   10 peticiones pendientes por cuenta; rechazar borra; la lista muestra la fecha para reconocer las viejas. Si el Mac
   nuevo se reinstala antes de aprobarlo, su petición queda huérfana (no tiene ya la privada): el usuario la verá con su
   fecha y la rechazará; una petición aprobada que nadie recoge en 30 días se borra [P].

**Qué protege el código corto:** quien tenga email + contraseña + buzón puede entrar y crear una petición. Sin el
código corto, el usuario podría aprobar por error la petición del intruso creyendo que es la de su Mac nuevo. Con el
código, lo que aprueba es *ese* Mac y no otro; una petición que no reconoce se rechaza. **No es un canal secreto** (el
servidor lo calcula igual): es una ayuda para que el humano apruebe la petición correcta.

**Qué ve el servidor:** email (HMAC), modelo del Mac, clave pública efímera, un blob cifrado y fechas. Nada descifrable.

## 6. Punto 3: recuperación

| Situación | Qué hace el usuario | Qué pasa con los datos |
|---|---|---|
| **Olvidé la contraseña, tengo al menos un Mac sincronizado** | «He olvidado la contraseña» en Sincronización → código por email → contraseña nueva (`V` nuevo) | **Ni se tocan**: la semilla sigue en sus Macs. Los demás Macs reciben «Se ha cambiado la contraseña. ¿Has sido tú?» (abajo) |
| **Perdí todos los Macs, tengo la clave de recuperación (24 palabras)** | Recupera la cuenta por email si hace falta; en el Mac nuevo, «Tengo mi clave de recuperación» → teclea las 24 palabras | Se une a la cadena directamente, sin aprobación (la clave de recuperación *es* la semilla). La cuenta se liga a la cadena con la prueba firmada de §10 |
| **Perdí todos los Macs y no tengo la clave** | Recupera la cuenta por email | **Datos perdidos.** La página lo dice con el texto de Titín y ofrece «Empezar de cero»: borra en el servidor lo cifrado de la cadena vieja y crea una cadena nueva (nueva semilla, nuevas palabras que debe guardar) |
| **Un Mac no puede leer sus claves** (llavero cambiado) | La página lo detecta (`failed_to_decrypt`) y ofrece «Volver a unir este Mac» | Es una petición de §5 (o las palabras). Sus datos locales siguen en el perfil; al unirse, §8 decide combinar o sustituir |

**«Se ha cambiado la contraseña. ¿Has sido tú?»** aparece en todos los Macs sincronizados (evento de §10, barra de aviso
como la de «cuenta borrada» que ya existe en brave-core [V]). «Sí» la cierra. **«No he sido yo»** desde un Mac
sincronizado (lleva token de aparato y prueba firmada de la cadena, que el intruso no tiene) → el servidor **bloquea la
cuenta**: invalida todos los tokens de aparato, cancela las peticiones pendientes, exige contraseña nueva con código por
email y manda un correo de aviso. La sincronización entre los Macs ya unidos **no se interrumpe** (tienen la semilla; el
protocolo de cadena no pasa por la cuenta). El intruso, mientras tanto, nunca ha podido llegar a los datos (§3).

**Clave de recuperación = las 24 palabras (opción A, la que propongo).** Es lo que el usuario ya tiene; no inventa
criptografía; no sube nada al servidor; y la vía «unirse con código» de hoy sigue valiendo tal cual como vía de
recuperación (aceptando las 24 palabras sin fecha: `SyncSetupGetPureSyncCode` ya existe [V]). Se presenta con otro
nombre y en otro sitio: «Clave de recuperación: guárdala impresa o en un gestor de contraseñas. Es la única forma de
recuperar tus datos si pierdes todos tus Macs». **Opción B:** una clave corta (p. ej. 20 caracteres) que envuelve la
semilla y se guarda, cifrada, en el servidor; más cómoda de apuntar, pero añade un secreto en ns2 y código nuevo. Decide
Titín (§13).

## 7. Punto 4: RGPD y privacidad

**Qué guarda ns2 por cuenta [P]:**

| Dato | Para qué | Cómo | Cuánto tiempo |
|---|---|---|---|
| `email_hmac` = HMAC-SHA256(clave_servidor, email normalizado) | entrar; no repetir cuentas | hash con clave fuera de la base | mientras exista la cuenta |
| `email_cifrado` | mandar códigos y el aviso de borrado por inactividad | AES-256-GCM con una clave que vive en una credencial de systemd (`LoadCredential`), no en la base ni en el repo | mientras exista la cuenta |
| `verificador`, `sal_servidor` | comprobar `KL` | §4 | mientras exista la cuenta |
| `cadena` (= `client_id` de go-sync) | ligar la cuenta con su cadena; borrar en todos | ya es un seudónimo (clave pública) | mientras exista la cuenta |
| aparatos: `token_hash`, modelo, fecha de alta y de último uso | listar y revocar; «N navegadores» en la confirmación de borrado | hash del token; el nombre que el usuario ponga viaja **dentro de la cadena cifrada**, no aquí | hasta que el usuario salga en ese Mac o borre la cuenta |
| peticiones: clave pública, modelo, código corto, blob cifrado, fechas | §5 | opaco | hasta aprobar/rechazar; aprobadas sin recoger, 30 días |
| códigos por email: hash, caducidad, intentos | segundo factor y recuperación | SHA-256; 6 dígitos; **10 min**; 5 intentos; 5 códigos por hora y cuenta | 10 min |
| `ultimo_uso` | borrado de inactivas | fecha, sin más | — |

**Lo que no hay:** IP (Apache no se la pasa al servicio y no la registra, como hoy [V]); nombre; registro de
peticiones; identificadores de publicidad; nada en terceros. Los **correos** llevan solo el código o el aviso, sin nombre
(«Tu código para FlyWeb: 123456. Caduca en 10 minutos. Si no has sido tú, ignora este mensaje.»), salen por el MTA del
propio servidor [I: SERVIDOR confirma remitente, SPF y DKIM] y no se guardan copias.

**Borrado:**
- «Borrar la cuenta y los datos en todos» desde un Mac sincronizado: inmediato (`ClearServerData` + `disabled` como
  hoy + borrado de las filas de la cuenta + tokens revocados). Confirmación: «Se desconectarán N navegadores. Los datos
  que cada uno tiene en su perfil no se borran.»
- Lo mismo pedido desde una sesión **sin** Mac sincronizado (solo email + contraseña): **demora de 7 días** con correo y
  evento a los Macs; cualquier Mac sincronizado puede cancelarlo [P]. Es lo que impide que quien robe un buzón borre lo
  del servidor en silencio (los Macs conservan sus copias de todos modos).
- **Inactivas:** `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365` pasa a activarse con la 3.2 (Titín, 06-11) y se añade
  `FLYWEB_SYNC_AVISO_DIAS=30`: a los 335 días sin uso, un correo («Tu cuenta de FlyWeb se borrará el …; basta con abrir
  FlyWeb con la sincronización activa»); a los 365, borrado de cuenta, cadena y email. «Uso» = cualquier petición
  autenticada de un aparato; una cadena en uso renueva su ficha a diario [V], así que nunca llega. Las cadenas **sin
  cuenta** (2.7.x/3.0.x) siguen con la regla de hoy, sin aviso (no hay a quién escribir).
- **Historial:** caduca a los 14 días en el servidor, como hoy.

**Texto de privacidad (W2):** la fila de `sync.flyweb.lamosquita.net` de `web-flyweb.md` §2 cambia a: «Sincronizar
contraseñas, marcadores, historial y ajustes entre sus equipos, y aprobar desde uno de ellos los equipos nuevos. Recibe
sus datos cifrados en su equipo con una clave que nunca sale de él, y, si crea una cuenta, su dirección de correo (para
el código de verificación y para avisarle antes de borrar una cuenta sin uso). No recibe su contraseña.» Base legal de la
cuenta: **ejecución del servicio que usted solicita** (art. 6.1.b RGPD), distinta del interés legítimo del resto.
Derechos: acceso y supresión desde la propia cuenta («Borrar la cuenta en todos»); lo demás, en la dirección de contacto
del texto. Conservación: hasta el borrado o 365 días de inactividad. **No soy abogado:** W2 sigue con su «revisión
legal».

**Si se roba `sync.db`:** datos cifrados por los navegadores; emails cifrados con una clave que no está en el fichero;
verificadores de scrypt; seudónimos. Lo exigible: avisar a la AEPD en 72 h si hay riesgo (dependerá de si la credencial
de systemd se fue con la base); rotar la clave de cifrado del email (recifrado masivo, posible porque el servidor sí
puede leerlos) y la del HMAC (obliga a recalcular en el siguiente inicio de sesión de cada cuenta: hay que guardar la
versión de clave por fila).

## 8. Punto 5: compatibilidad y transición desde las 24 palabras

- **El protocolo de cadena no cambia.** Mismo `POST /v2/command/`, mismo token, mismo cifrado. La 2.7.x y la 3.0.x
  siguen funcionando contra ns2 sin saber que existen las cuentas; una 3.2 y una 3.0.1 pueden compartir cadena.
- **Crear cuenta desde un Mac ya sincronizado** (el caso de los 7 usuarios): email, contraseña, código → la cuenta se
  liga a la cadena existente con la **prueba firmada**: el Mac manda su token de sync de hoy
  (`timestamp|firma|clave_pública`) en la llamada de alta; el servidor lo comprueba con la misma `auth.Authorize` de
  go-sync [V] y así sabe que quien liga la cadena la tiene. **No se resincroniza nada.**
- **Crear cuenta en un Mac sin cadena:** crea cadena nueva (semilla local, como hoy «Empezar una cadena») y la liga;
  muestra la clave de recuperación y pide confirmar que se ha guardado antes de seguir.
- **Las 24 palabras siguen existiendo** como clave de recuperación (§6) y, si Titín quiere, como vía avanzada
  «Unirse con un código» (QR y palabras con tiempo) para quien no quiera cuenta. Propongo **mantenerla visible pero
  secundaria** («Otras opciones»); ocultarla rompería a los 7 usuarios de hoy si alguno no crea cuenta (§13).
- **Una cadena, una cuenta.** Una cadena ligada a una cuenta no se puede ligar a otra sin borrar la primera. Si un Mac
  con cadena ligada intenta crear otra cuenta, la página dice que ya tiene una.
- **Vuelta de la 3.x a la 2.7.x** (lección 6, último punto): la 2.7.0 publicada no se puede cambiar; la salida
  documentada es restaurar la copia «antes de 3.0» (marca «FlyWeb 3 Profile», `coordinacion.md:136` [V]). Si algún día
  se publica una 2.7.1, que se niegue a abrir un perfil con esa marca. No es parte de la 3.2 pero se anota aquí porque
  afecta al llavero de sync.

## 9. Punto 6: lecciones del 09-11 → requisitos de la página

| Requisito (`plan-3x.md` §5.1.6) | Cómo lo cumple el diseño | Dónde se prueba (§12) |
|---|---|---|
| Dos botones, dos alcances | «Salir de la sincronización en este Mac» (local: abandona la cadena, revoca su token, conserva el perfil) y «Borrar la cuenta y los datos en todos» (con confirmación que dice N navegadores y que lo local no se borra) | P7, P8 |
| Nada «en curso» para siempre | toda llamada a la cuenta y a sync con tiempo límite de 30 s en el cliente; estado «error» con el motivo (sin red, servidor no responde, código caducado, contraseña incorrecta) y botón Reintentar; ningún spinner sin salida | P10 |
| Claves locales ilegibles = estado propio | `failed_to_decrypt` de la semilla o del token → estado «Este Mac no puede leer sus claves de sincronización (ha cambiado el llavero)» con «Volver a unir este Mac» (§6, última fila) | P9 |
| Volver a unir sin duplicar | al unirse con datos locales, elegir: **Combinar** (lo de Chromium: contraseñas por clave natural, marcadores por GUID) o **Sustituir lo de este Mac por lo de la cuenta** (hace antes una copia del perfil con el mecanismo de «antes de 3.0», vacía los tipos sincronizados y se une). Después de combinar, botón «Quitar marcadores duplicados» (misma URL, título y carpeta) con la copia como vuelta atrás [P] | P9 |
| Cadena borrada desde otro Mac | `DISABLED_BY_ADMIN` → estado «La cuenta se ha borrado desde otro Mac» con «Crear una cuenta nueva», «Unirme con un código» y «Seguir sin sincronizar»; nada de lista vacía con botones muertos | P8 |
| Servidor: contadores anónimos | `flyweb-sync` escribe cada hora, a nivel `warn`, «cuentas borradas: n; DISABLED_BY_ADMIN devueltos: n; peticiones aprobadas: n» sin identificar cadenas ni cuentas | P8 |
| «Passwords» traducido | ya en la 3.0.1 (FS.43, parche 0002) | — |
| La 2.7.x no abre un perfil 3.x | §8, último punto (fuera de la 3.2) | — |

**Estados de la página** (máquina de estados; cada uno con su texto y sus botones, ninguno sin salida):

`sin cuenta` → (crear / entrar) → `pendiente de aprobación` (código corto, «esperando a que apruebes desde otro Mac»,
Cancelar) → `sincronizado` (lista de aparatos, peticiones pendientes, cambiar contraseña, salir en este Mac, borrar en
todos, ver clave de recuperación) · `claves ilegibles` (volver a unir) · `cuenta borrada desde otro Mac` ·
`contraseña cambiada: ¿has sido tú?` (barra) · `cuenta bloqueada` (contraseña nueva por email) · `sin red` (lo último
que se sabía + Reintentar).

## 10. Servidor

- **Dónde:** el mismo binario `flyweb-sync`, paquete nuevo `cuenta/`, rutas `POST /cuenta/v1/...` montadas junto a
  `/v2`, mismas tablas SQLite más las de §7 [P]. Un binario y un fichero, como pidió Titín el 03-10; el vhost de Apache
  solo añade la ruta, y sigue sin pasar la IP.
- **Autenticación de las llamadas:** (a) sin sesión: alta, entrar, «he olvidado la contraseña», pedir código; (b) con
  **token de aparato** (32 bytes aleatorios que el servidor da al entrar; el Mac lo guarda cifrado con OSCrypt; el
  servidor guarda su SHA-256; `Authorization: Bearer`); (c) con token de aparato **y prueba firmada de la cadena** (el
  token de sync de hoy) para lo que solo un Mac sincronizado puede hacer: aprobar, ligar cadena, borrar en todos al
  momento, «no he sido yo».
- **Llamadas [P]:** `alta` (email → código), `alta/confirmar` (código, `KL`, prueba firmada opcional → cuenta, token),
  `entrar` (email, `KL`, código → token), `contrasena/cambiar`, `contrasena/olvidada` + `/confirmar`, `peticiones`
  (crear / listar / aprobar / rechazar / recoger), `aparatos` (listar / revocar), `eventos` (desde una marca de tiempo:
  contraseña cambiada, petición nueva, cuenta bloqueada, borrado programado), `cuenta/borrar` (inmediato o diferido),
  `cuenta/borrar/cancelar`, `salir`.
- **Límites:** por cuenta, 10 entradas fallidas por hora y bloqueo de 15 min; 5 códigos por hora; globales de 100
  entradas/min. Sin IP no hay límite por IP: es deliberado (privacidad) y por eso los topes por cuenta son estrictos.
- **Correo:** por el MTA local del servidor (`sendmail`/`localhost:25`) desde un remitente del dominio de FlyWeb
  [I: SERVIDOR confirma SPF y DKIM y que el MTA acepta de `DynamicUser`]. Si no hay MTA utilizable, la alternativa es
  un relé en ns1; nunca un servicio de correo de terceros.
- **Configuración:** `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365`, `FLYWEB_SYNC_AVISO_DIAS=30`, `FLYWEB_SYNC_CORREO_DESDE`,
  y dos credenciales de systemd (`LoadCredential`): clave del HMAC y clave AES del email. Ambas con versión, para poder
  rotarlas (§7).
- **Pruebas:** `go test -race` con casos de §12 en HTTP contra SQLite; `pruebas/go-sync.sh` sigue pasando (nada de
  go-sync se toca); y, en ns2, siempre desde el propio servidor con `curl --resolve ...:127.0.0.1` (regla de la casa).

## 11. Cliente

- **Página:** la de Sincronización de hoy (`flyweb://settings/braveSync`) pasa a llamarse «Cuenta y sincronización» y
  gana los estados de §9; los manejadores nuevos se suman a `BraveSyncHandler` (`SyncGetDeviceList`,
  `SyncSetupSetSyncCode`, `SyncPermanentlyDeleteAccount`… siguen) [V].
- **Criptografía:** scrypt (`EVP_PBE_scrypt`), X25519 y HPKE (`EVP_HPKE_*`) de BoringSSL; HMAC/SHA-256 de siempre.
  Nada nuevo en `third_party`; nada que dependa de macOS (vale en Mojave).
- **Prefs nuevas** (cifradas con OSCrypt como la semilla): token de aparato, privada X25519 de la petición pendiente,
  marca de tiempo del último evento leído. Todas con el mismo tratamiento de `failed_to_decrypt` que la semilla.
- **Sondeo de eventos:** cada 15 min con sync activa, y al abrir la página; una petición por vez, retroceso exponencial
  hasta 1 h si falla. Sin ventanas esperando red (regla de la casa para las pruebas en la 6,1).
- **Barras de aviso:** reutilizar `brave_sync_account_deleted_infobar` [V] como patrón para «petición nueva»,
  «contraseña cambiada» y «cuenta borrada desde otro Mac».
- **No toca** el motor de sync, Nigori ni `brave_sync_auth_manager`.

## 12. Hitos y pruebas de aceptación

Hitos de `plan-3x.md` §5.2, concretados:

- **H1 (Titín):** este diseño aprobado tras la revisión de SEGURIDAD (§14) y las decisiones de §13.
- **H2 (SERVIDOR-LOCAL / SERVIDOR, NUBE para el código Go):** `flyweb-sync` con `cuenta/`, pruebas en verde, instalado
  en ns2 con el procedimiento de `instalar-ns2.md` (sumas, vuelta atrás) y probado desde el propio servidor.
  Entregable: tabla de llamadas con un ejemplo real cada una, sin emails de nadie (cuenta de prueba en un buzón del
  dominio).
- **H3 (MOTOR el código, LOCAL compilar y probar; revisión de SEGURIDAD del código antes):** cliente en la 7,1; después
  en la 6,1; la 5,1 cuando Titín pueda. Se compila cuando la 3.1 esté medida (`plan-3x.md` §5.2).

**Guion de prueba con tres Macs** (todo contra ns2 real; una cuenta de prueba; cada paso se anota con resultado):

| # | Caso | Pasa si |
|---|---|---|
| P1 | Mac A sincronizado con palabras (3.0.1) crea cuenta | la cadena queda ligada; nada se resincroniza; A recibe su token |
| P2 | Mac B nuevo entra y pide unirse | B muestra el código corto; A ve la petición con el mismo código |
| P3 | A aprueba | B se une en < 1 min y recibe contraseñas y marcadores; el servidor nunca tuvo la semilla (se comprueba en `sync.db`: solo cifrado y claves públicas) |
| P4 | Mac C pide unirse; nadie aprueba en 2 días; luego A aprueba | C sigue esperando sin error y se une al aprobar |
| P5 | Petición de un intruso (sesión con la contraseña desde otro perfil) | A ve dos peticiones con códigos distintos y rechaza la que no reconoce; el intruso no recibe nada |
| P6 | Cambio de contraseña en B | A y C muestran «¿Has sido tú?»; «No he sido yo» en A bloquea la cuenta y la sync A–B–C sigue |
| P7 | «Salir en este Mac» en C | C conserva su perfil; A y B ya no lo listan; el servidor no borra nada |
| P8 | «Borrar en todos» en A | B y C muestran «cuenta borrada desde otro Mac» con sus tres salidas; `sync.db` sin filas de la cuenta; el contador anónimo sube |
| P9 | En B, cambiar el llavero (copia del perfil con llavero nuevo) | estado «claves ilegibles» → «volver a unir» → combinar sin duplicados; luego la misma prueba con «sustituir» y comprobar la copia previa |
| P10 | Servidor parado a mitad de cada operación | ningún estado «en curso» pasa de 30 s; mensaje y Reintentar; al volver el servidor, Reintentar funciona |
| P11 | Recuperación sin Macs: perfil nuevo, «he olvidado la contraseña», con palabras y sin palabras | con palabras, se une; sin palabras, texto de pérdida y «Empezar de cero» crea cadena nueva |
| P12 | Inactividad (con `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=1` y `AVISO=0` en una instancia de prueba) | llega el correo de aviso y luego se borra cuenta, cadena y email |
| P13 | Una 3.0.1 con palabras y una 3.2 con cuenta en la misma cadena | sincronizan entre sí; NetLog solo con `sync.flyweb.lamosquita.net` |

**Aceptación de la 3.2** (`plan-3x.md` §5.2): P1–P13 en verde en los tres Macs; datos ilegibles comprobados en ns2;
texto de privacidad publicado; la 3.1 no retrocede.

## 13. Decisiones para Titín

1. **Clave de recuperación:** A, las 24 palabras de siempre (propongo); o B, clave corta envuelta en el servidor (§6).
2. **La vía «unirse con un código» (QR / palabras con tiempo):** se queda visible como «Otras opciones» (propongo) o se
   esconde.
3. **Borrar la cuenta sin un Mac sincronizado:** demora de 7 días cancelable (propongo) o inmediato.
4. **Modelo del Mac en las peticiones** («MacPro6,1»): basta para reconocerlo (propongo) o se pide un nombre al usuario
   (viajaría en claro al servidor hasta la aprobación).
5. **Nombre de la página:** «Cuenta y sincronización» (propongo) u otro.
6. **Remitente de los correos** (dirección del dominio de FlyWeb) y si ns2 los manda él mismo: lo confirma SERVIDOR;
   Titín elige la dirección.
7. **Límite de aparatos por cuenta:** go-sync ya tiene el suyo; propongo no añadir otro.

## 14. Para la revisión de seguridad

**Modelo de amenazas que asume el diseño:**

| Atacante | Qué consigue | Qué no consigue | Dónde se apoya |
|---|---|---|---|
| Tiene email + contraseña (phishing, reutilización) y **no** el buzón | nada: el código por email lo para | — | §7 códigos |
| Tiene email + contraseña **y** el buzón | entra en la cuenta: ve modelos de aparatos y fechas, crea peticiones, cambia la contraseña, programa un borrado a 7 días | la semilla y los datos; que se apruebe su petición (código corto); borrar al momento | §3, §5, §6 («no he sido yo»), §7 |
| Se lleva `sync.db` | datos cifrados, verificadores, HMAC de emails, claves públicas, blobs HPKE | emails en claro (clave fuera de la base); contraseñas (scrypt dos veces); semillas | §4, §7 |
| Controla ns2 entero (o es un administrador deshonesto) | lo anterior más los emails en claro y la posibilidad de entregar a un Mac nuevo una petición falsa | descifrar datos; aprobar nada (la aprobación la firma un Mac del usuario y cifra para la clave del Mac nuevo; el servidor no puede sustituir la clave pública sin que cambie el código corto que el humano compara) | §5 |
| Roba un Mac apagado sin FileVault | el perfil en claro, la semilla en el llavero protegido por la contraseña de sesión | — (es la recomendación ya escrita: FileVault y contraseña larga, `DIRECTIVAS.md:258-264`) | — |
| En la red (sin romper TLS) | nada: todo va por HTTPS con el vhost de hoy | — | — |

**Preguntas concretas a SEGURIDAD:**

1. ¿scrypt con N = 2^17, r = 8, p = 1 en el cliente y N = 2^14 en el servidor, o exige Argon2id (dependencia nueva en
   el navegador)? ¿Sal determinista del email aceptable, o prefiere sal por cuenta aunque delate si el email existe?
2. ¿Basta el verificador (`KL` viaja por TLS) o exige OPAQUE/SRP?
3. HPKE de BoringSSL (X25519 + HKDF-SHA256 + ChaCha20-Poly1305) con `info` = id de petición: ¿suficiente contra un
   servidor que sustituya la clave pública de una petición? El control es el código corto que el humano compara (§5).
   ¿Lo acepta como control, o pide que el Mac que aprueba vea y confirme también la huella completa?
4. ¿Los 6 dígitos / 10 min / 5 intentos / 5 códigos por hora bastan sin límite por IP?
5. ¿«No he sido yo» con token de aparato + prueba firmada de la cadena es prueba suficiente de que quien bloquea es
   el dueño? (El intruso con contraseña no tiene ni lo uno ni lo otro.)
6. ¿HMAC con clave fuera de la base para el email, o hash sin clave (más simple, pero un diccionario de emails lo
   rompe)?
7. Borrado con demora de 7 días desde una sesión sin Mac sincronizado: ¿suficiente, o exigir siempre un Mac?
8. ¿Algo del diseño obliga a tocar el motor de sync o Nigori? (Yo digo que no: §11.)

**Lo que este documento no cubre:** el texto legal definitivo (W2, revisión legal), la implementación en Go y en
C++, Android/iOS (cuando existan, la aprobación desde el móvil es la misma petición de §5 con aprobación inmediata),
y cualquier migración de datos del servidor (no hay: tablas nuevas).

## 15. Fuentes y límites

Código: `brave-core` rama `flyweb` (`components/brave_sync/crypto/*`, `brave_sync_prefs.cc`,
`components/sync/service/brave_sync_auth_manager.cc`, `brave_sync_service_impl.cc`, `browser/ui/webui/settings/brave_sync_handler.cc`,
`browser/infobars/brave_sync_account_deleted_infobar_delegate.*`); `FlyWeb/servidor/sync/{README.md,main.go,sqlite.go,cache.go,instalar-ns2.md}`;
BoringSSL del árbol 156 (`evp.h`: `EVP_PBE_scrypt`; `hpke.h`). Documentos: `plan-3x.md` §5, `TAREAS.md:281` (F7.7),
`coordinacion.md:136,265-269`, `DIRECTIVAS.md:258-264`, `parches/3.0.2-sync-ajustes/README.md`, `web-flyweb.md` §2,
`docs/SERVIDOR.md:13`. No se ha medido el coste de scrypt en la 6,1 ni se ha probado nada contra ns2.
