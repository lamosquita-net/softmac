# FlyWeb 3.2 — sincronización con cuenta (F7.7): diseño

ARQUITECTURA, 09-11-2026, por orden de Titín (vía COORDINACIÓN-36). **Revisado el 11-11** tras la revisión de
SEGURIDAD-PORTES-21 (PR #905, comentario 6797345699): resueltos B1–B3 y C1–C6 y adoptados O1–O6; el detalle, en §14.
**Revisado otra vez el 11-11** tras su segunda pasada (comentario 6807160010): aplicados N1 y N2 y adoptados O7–O10.
Solo papel: nada compilado ni probado. Desarrolla los puntos 1–6 de `plan-3x.md` §5.1 con el flujo que eligió Titín el
06-11 (`TAREAS.md:281`) y las condiciones de COORDINACIÓN-30. **Propone; decide Titín** (hito 1 de `plan-3x.md` §5.2).
Antes de su sí y de la tercera pasada de SEGURIDAD, ni una línea de código.

Marcas: **[V]** visto en el código o en los documentos citados; **[I]** inferido; **[P]** propuesta mía; **[S]**
propuesta de SEGURIDAD adoptada. Sin datos personales de nadie.

## 1. Resumen

- **La cuenta envuelve la cadena; la cadena no cambia.** Hoy una cadena de sync es una semilla de 32 bytes que vive
  solo en los Macs del usuario; de ella salen las 24 palabras, la clave de firma Ed25519 con la que el navegador se
  identifica ante ns2 y la clave con la que cifra los datos [V]. El diseño deja todo eso igual y pone encima una
  **cuenta** (email + contraseña + código por email) cuyo único papel es **llevar la semilla de un Mac a otro sin
  teclear 24 palabras**, con la aprobación de un Mac ya sincronizado.
- **El servidor no guarda nada que descifre nada, y tampoco puede colarse en la aprobación.** La contraseña solo
  autentica (el servidor ve un verificador); la semilla viaja de Mac a Mac cifrada para el Mac que la pide; el usuario
  **teclea** dos códigos de 16 caracteres (uno en cada sentido) que ni el servidor ni un intruso pueden falsificar
  (§5) [S]; la **clave de recuperación son las 24 palabras de siempre**. Perder todos los Macs y las palabras = perder
  los datos, como dijo Titín, y la página lo dice con su texto.
- **El factor fuerte es tener la cadena, no la contraseña.** Todo lo delicado (aprobar, bloquear, borrar al momento,
  ligar la cadena) exige una **prueba de cadena** de un solo uso, firmada con la clave de la cadena (§3) [S]. Con
  email + contraseña + buzón se entra en la cuenta, pero no se llega a los datos ni se puede echar al dueño.
- **Lo que cambia quién controla la cuenta pide además algo que no está guardado en el Mac** [S, N1]: desbloquear,
  cambiar el email y cambiar la clave de sincronización exigen la prueba de cadena **y** la contraseña actual o un
  código enviado al email actual. Con solo la cadena, esas tres operaciones esperan 7 días y se pueden cancelar. Así
  un Mac robado no puede quedarse con la cuenta (§6.7).
- **Todo lo nuevo es aditivo:** el protocolo de sync y `flyweb-sync` siguen iguales; las cuentas son rutas y tablas
  nuevas en el mismo binario y el mismo SQLite. La 2.7.x y la 3.0.x siguen sincronizando con palabras contra el mismo
  servidor; los 7 usuarios de hoy no tienen que hacer nada hasta que quieran crear su cuenta desde un Mac sincronizado.
- **El email es el único dato personal** en ns2: HMAC para entrar y cifrado con una clave que no está en la base para
  mandar códigos y avisos; sin IP, sin nombre, sin registro de peticiones. El registro del servidor de correo y las
  copias de la base tienen plazo (§7).
- **Riesgo medio-alto** (`plan-3x.md` §5.2): criptografía elegida entre lo que ya trae BoringSSL (scrypt, X25519,
  HPKE, Ed25519) para no meter dependencias nuevas.

## 2. Punto de partida: lo que ya hay [V]

| Pieza | Qué es hoy | Dónde |
|---|---|---|
| Semilla | 32 bytes aleatorios (`GetSeed`), mostrados como 24 palabras BIP39; con la fecha, 25 («palabras con tiempo», caducan) y QR v2 con `not_after` | `components/brave_sync/crypto/crypto.{h,cc}`, `time_limited_words.h`, `qr_code_data.h` |
| Identidad ante el servidor | HKDF-SHA512 de la semilla → par Ed25519; `client_id` = clave pública en hex. **Todos los Macs de una cadena comparten esa clave** | `crypto.cc:43-55`, `brave_sync_auth_manager.cc:35-52` |
| Token de cada petición | `base64(timestamp_hex\|firma_hex\|clave_pública_hex)`; go-sync comprueba la firma **solo de la hora** y la acepta ±1 día: quien vea un token puede reutilizarlo 24 h | `brave_sync_auth_manager.cc:94-120`; go-sync `auth/auth.go` (revisión de SEGURIDAD) |
| Cifrado de los datos | Chromium (Nigori) con frase personalizada = las palabras; el servidor solo ve cifrado | `brave_sync_service_impl.cc:212-220` |
| Dónde vive la semilla | pref `brave_sync_v2.seed`, cifrada con OSCrypt (llavero de macOS); si el llavero no la descifra, `failed_to_decrypt` y la cadena queda inservible en ese Mac | `brave_sync_prefs.cc:23-24,123-146` |
| Servidor | go-sync de Brave + SQLite + caché en memoria (con caducidad y lectura de un solo uso); tablas `entities`, `tags`, `disabled`, `counts`; solo `POST /v2/command/`; sin IP ni registro de peticiones | `servidor/sync/main.go`, `sqlite.go:24-40`, `cache.go` |
| Borrar cuenta | `PermanentlyDeleteAccount` (hasta 5 intentos) → el servidor hace `ClearServerData` y marca la cadena en `disabled`; los demás Macs reciben `DISABLED_BY_ADMIN` y `ResetEngine` deja pendiente el aviso «cuenta borrada» | `brave_sync_service_impl.cc:231-287,290+`; `sqlite.go:381-424` |
| Cadenas sin uso | `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS` (0 = no; 365 previsto); desactiva la cadena como si el usuario la hubiera borrado | `main.go:99-113`, `sqlite.go:84-110` |
| Usuarios | 7 (Titín, 06-11) | `TAREAS.md:281` |
| Página de ajustes | en la 3.0.0 estaba sin manejadores (FS.43, arreglado en la 3.0.1 por MOTOR-43); `DISABLED_BY_ADMIN` sigue sin tratar en la página | `parches/3.0.2-sync-ajustes/README.md` |
| Ubicación | ns2 en OVH, Francia (UE) | `docs/SERVIDOR.md:13` |

## 3. Modelo: quién tiene qué y qué puede hacer

| Cosa | Usuario | Mac sincronizado | Mac nuevo (antes de aprobarlo) | Servidor (ns2) |
|---|---|---|---|---|
| Contraseña | la sabe | no la guarda | la teclea | **nunca**: verificador (§4) |
| Semilla / 24 palabras | las tiene guardadas (clave de recuperación) | sí, en el llavero | **no** hasta la aprobación | **nunca** |
| Datos sincronizados | — | en claro, en el perfil | no | cifrados, ilegibles |
| Email | — | no hace falta | lo teclea | HMAC (para entrar) + cifrado con clave del servidor (para escribirle) |
| Token de aparato (§10) | — | sí, en el llavero | sí, tras entrar | hash |
| Par X25519 de la petición (§5) | — | — | privada en el llavero; pública en el servidor | pública |

### 3.1 La prueba de cadena [S, B3]

El token de sync de hoy **no sirve** como prueba de que alguien tiene la cadena: firma solo la hora, va en cada petición
y vale 24 h. La cuenta usa una prueba propia, de un solo uso, firmada con la misma clave Ed25519 de la cadena:

`prueba = Ed25519(SK_cadena, "flyweb-cuenta-v1" ‖ operación ‖ cuenta_id ‖ nonce_servidor ‖ SHA-256(cuerpo))`

- `nonce_servidor`: lo pide el Mac antes (`nonce`), es **de un solo uso** y caduca a los 5 min. Como `nonce` va sin
  sesión, el servidor **no guarda los pendientes** [O8, con una variante]: el nonce lleva 16 bytes aleatorios, su
  caducidad y un HMAC con una clave que el servidor genera al arrancar, y solo se apuntan **los ya usados con una
  prueba válida**, hasta que caducan (comprobar y apuntar bajo el mismo cerrojo, como hace hoy la caché [V]). Nadie
  llena la memoria pidiendo nonces, y nadie deja sin nonces a los demás, que es lo que permitiría un tope fijo de
  pendientes. Si SEGURIDAD prefiere el tope de 1000 que propuso, el cambio es pequeño.
- `operación` es una etiqueta fija por llamada («aprobar», «bloquear»…): una prueba no vale para otra operación, ni
  para otra cuenta, ni para otro cuerpo. Campos de longitud fija o con prefijo de longitud.
- El prefijo de dominio no se puede leer como una hora en decimal: una firma de cuenta no sirve como token de sync, ni
  al revés.
- En el cliente es una función nueva en `components/brave_sync/crypto`; **no toca** `brave_sync_auth_manager`.

### 3.2 Qué abre cada credencial

«Segundo factor» es la contraseña actual (`KL`) o un código enviado al email actual: lo que no está guardado en el
Mac (§6.7) [S, N1].

| Operación | Sin sesión | Token de aparato **sin** cadena | Prueba de cadena sola | Prueba de cadena **y** segundo factor |
|---|---|---|---|---|
| Alta, entrar, «he olvidado la contraseña» | sí (con código por email) | — | — | — |
| Crear su petición de unión, recogerla, ver **cuántas** hay pendientes | — | sí | sí | sí |
| Cambiar la contraseña (tecleando la actual) | — | sí | sí | sí |
| Pedir el borrado de la cuenta o «Empezar de cero»: **con demora de 7 días** | — | sí | — | — |
| Ver las peticiones con su clave pública, aprobar, rechazar; quitar un aparato de la lista; renovar su token | — | **no** | sí | sí |
| Leer eventos; «No he sido yo» (bloquear); cancelar un borrado; ligar la cadena; borrar en todos **al momento** | — | **no** | sí | sí |
| **Desbloquear; cambiar el email; cambiar la clave de sincronización** | — | **no** | **solo programado a 7 días**, cancelable | sí, al momento |
| Cancelar una de esas tres operaciones programadas | — | **no** | **no** | sí |

Conclusión del modelo: **con email + contraseña + buzón no se llega a los datos ni se echa al dueño.** Se entra en la
cuenta, se puede cambiar la contraseña, crear peticiones (que nadie aprobará) y programar un borrado que cualquier Mac
del usuario cancela. Un Mac con la cadena no depende de su token: si se lo invalidan, saca otro con la prueba de cadena.
**Y con un Mac robado se llega a los datos hasta que el dueño cambie la clave, pero no se echa al dueño:** al ladrón
le falta el segundo factor.

## 4. Punto 1: derivación de claves sin que el servidor vea la contraseña

**Objetivo (COORDINACIÓN-30):** la contraseña se transforma en el cliente; el servidor guarda solo un verificador.

1. **Normalizar** el email (minúsculas, sin espacios, NFC) y la contraseña (NFC). Longitud mínima de contraseña: 10.
2. **Clave de inicio de sesión** `KL = scrypt(contraseña, sal = SHA-256("flyweb-cuenta-v1" ‖ email), N = 2^17, r = 8,
   p = 1, 32 bytes)`. La sal es determinista (sale del email) para no pedir al servidor una sal por cuenta antes de
   entrar, que delataría si el email existe. Aceptado por SEGURIDAD (mínimo de OWASP; la sal por email solo permite
   precalcular contra un email concreto). Coste: 128 MiB y del orden de medio segundo en la 6,1 [I].
3. **Verificador** en el servidor: `V = scrypt(KL, sal_servidor (16 bytes aleatorios por cuenta), N = 2^14, r = 8,
   p = 1)`. El cliente manda `KL`; el servidor compara en tiempo constante. Quien se lleve la base tiene `V` y la sal:
   no puede sacar `KL` sin romper scrypt, y con `KL` solo entraría en la cuenta (§3.2), no en los datos.
4. **Cambio de contraseña:** `KL` nuevo → `V` nuevo. **No hay nada que recifrar** porque la contraseña no envuelve ni
   la semilla ni los datos: cambiarla nunca puede perder datos. Al cambiarla se invalidan los tokens de aparato salvo
   el de quien la cambió; **los Macs con la cadena sacan un token nuevo con la prueba de cadena** y reciben el aviso
   de §6.2 [S, B2].
5. **Respuestas iguales exista o no la cuenta** [S, O1]: `alta`, `entrar` y «he olvidado la contraseña» contestan lo
   mismo y tardan lo mismo; para un email desconocido el servidor calcula un scrypt de relleno.
6. **Por qué scrypt y no Argon2:** BoringSSL del árbol trae `EVP_PBE_scrypt` y no trae Argon2 [V]; SEGURIDAD lo
   acepta. **Por qué no OPAQUE ni SRP:** SEGURIDAD confirma que el verificador basta: `KL` no abre ningún dato y las
   operaciones de riesgo no dependen de `KL` sino de la prueba de cadena.

## 5. Punto 2: aprobación entre aparatos

**Objetivo (Titín, d):** un Mac nuevo o recuperado no recibe la semilla hasta que lo apruebe un Mac ya sincronizado, que
se la pasa cifrada; el servidor no la ve. **Matiz:** sin móvil la aprobación no es inmediata; la petición espera sin
caducar.

Dos códigos, los dos de **80 bits**: 16 caracteres de base32 en 4 grupos de 4 (`K7QM-2XRA-…`; alfabeto sin I, L, O
ni U, sin distinguir mayúsculas). **Se teclean enteros; no se comparan a ojo** [S, B1 y C1].

- **Código de aprobación** `CA = trunc80(SHA-256("flyweb-aprobacion-v1" ‖ clave_pública_nueva))`. No depende de nada
  que elija el servidor.
- **Código de confirmación** `CC = trunc80(SHA-256("flyweb-confirmacion-v1" ‖ clave_pública_cadena ‖
  clave_pública_nueva))`.

Protocolo:

1. **Mac nuevo:** entra en la cuenta (email, contraseña → `KL`, código por email). Genera un par X25519 y guarda la
   privada en el llavero (pref cifrada con OSCrypt, como la semilla). Envía `petición = {clave pública, modelo del Mac
   (p. ej. «MacPro6,1»), versión de FlyWeb}` y muestra el **código de aprobación**: «Para unir este Mac, teclea este
   código en uno de tus Macs sincronizados: K7QM-2XRA-…». El código no es secreto: se puede apuntar o fotografiar.
   **No te lo mandes por el correo de la cuenta** (es el canal que un intruso podría tener).
2. **Macs sincronizados:** barra de aviso («Un Mac pide unirse a tu cuenta»). La página lista modelo y fecha de cada
   petición, **sin código**. «Aprobar» pide **teclear el código** que muestra el Mac nuevo. El Mac que aprueba pide
   las peticiones con su clave pública (prueba de cadena; un token sin cadena solo ve cuántas hay [S, O4]), calcula
   el `CA` de cada una y aprueba **solo la que coincide**. Si ninguna coincide: «Ese código no corresponde a ninguna
   petición», sin pistas.
3. **Aprobar:** cifra la semilla para esa clave pública con HPKE (DHKEM X25519 + HKDF-SHA256 + ChaCha20-Poly1305,
   `EVP_HPKE` de BoringSSL [V]; `info = "flyweb-aprobacion-v1" ‖ cuenta_id ‖ id de petición` [S, O5]) y lo sube con
   prueba de cadena (operación «aprobar»; el cuerpo firmado incluye el cifrado y la clave pública de la petición).
   Después muestra el **código de confirmación**: «Para terminar, teclea este código en el Mac nuevo: …». Queda
   visible en la lista de «aprobadas, pendientes de confirmar» de cualquier Mac sincronizado.
4. **Mac nuevo:** sondea cada 30 s con la página abierta y cada 15 min en segundo plano, con retroceso exponencial
   (regla de la casa: nunca en bucle contra ns2). Al recibir la respuesta queda en **«Falta confirmar»** y guarda
   **el blob cifrado tal cual, no la semilla** [S, O7]: con dos viajes puede pasar días esperando. Solo cuando el
   usuario teclea el código de confirmación descifra en memoria con su privada, deriva de la semilla la clave pública
   de la cadena, calcula `CC` y compara. Hasta que coincida no guarda la semilla ni activa la sincronización. Si no
   coincide: descarta lo recibido y avisa («La clave recibida no viene del Mac que aprobó. No se ha activado nada.»).
   Si coincide: `SetSeed` con las palabras y se une a la cadena exactamente como hoy. Borra el par X25519.
5. **Sin caducidad:** la petición espera días si hace falta (Titín: «navegadores en casa, usuario fuera»). En ese caso
   son dos viajes: apuntar `CA` donde está el Mac nuevo, teclearlo en casa y apuntar `CC`, y teclear `CC` a la vuelta.
   Topes: 10 peticiones pendientes por cuenta; rechazar borra; la lista muestra la fecha. Una petición huérfana (Mac
   reinstalado) se reconoce por la fecha y se rechaza; una aprobada que nadie confirma en 30 días se borra [P].

**Qué protege cada código:**

- `CA` (lo teclea el usuario en el Mac que aprueba) garantiza que la semilla se cifra **para el Mac que el usuario
  tiene delante**. Un intruso con contraseña y buzón puede crear peticiones, pero su código es otro y nadie lo teclea.
  Un servidor malicioso no puede cambiar la clave pública por la suya sin que cambie el código, y fabricar otra clave
  con el mismo código cuesta 2^80.
- `CC` (lo teclea el usuario en el Mac nuevo) garantiza que la semilla recibida **es la de su cadena**. HPKE en modo
  base no autentica a quien cifra: sin `CC`, un servidor malicioso podría cifrar una semilla suya para el Mac nuevo, que
  le subiría sus contraseñas al combinar.

**Qué ve el servidor:** email (HMAC), modelo del Mac, clave pública efímera, un blob cifrado y fechas. Nada descifrable.

**Alternativa que no propongo para la 3.2:** un solo código *secreto* (el Mac nuevo lo genera, el que aprueba lo usa
como clave precompartida) ahorraría el segundo viaje, pero el código pasa a ser un secreto que el usuario apunta, y es
una construcción propia que SEGURIDAD tendría que revisar desde cero. Los dos códigos públicos son lo ya revisado.

## 6. Punto 3: recuperación y defensa de la cuenta

### 6.1 Casos de recuperación

| Situación | Qué hace el usuario | Qué pasa con los datos |
|---|---|---|
| **Olvidé la contraseña, tengo un Mac sincronizado** | «He olvidado la contraseña» en ese Mac → código por email + **prueba de cadena** → contraseña nueva | **Ni se tocan**: la semilla sigue en sus Macs. Los demás reciben el aviso de §6.2 |
| **Olvidé la contraseña y no tengo ningún Mac sincronizado** | «He olvidado la contraseña» → **código de recuperación** por email (8 caracteres de base32, 40 bits) → contraseña nueva. Queda una sesión **sin cadena** (§3.2) | Para los datos hace falta la clave de recuperación (fila siguiente) |
| **Perdí todos los Macs, tengo la clave de recuperación (24 palabras)** | En el Mac nuevo, «Tengo mi clave de recuperación» → teclea las 24 palabras | Se une a la cadena directamente, sin aprobación (la clave de recuperación *es* la semilla). Ese Mac ya puede dar prueba de cadena |
| **Perdí todos los Macs y no tengo la clave** | Recupera la cuenta por email | **Datos perdidos.** La página lo dice con el texto de Titín y ofrece «Empezar de cero» (§6.4) |
| **Un Mac no puede leer sus claves** (llavero cambiado) | La página lo detecta (`failed_to_decrypt`) y ofrece «Volver a unir este Mac» | Es una petición de §5 (o las palabras). Sus datos locales siguen en el perfil; al unirse, §9 decide combinar o sustituir |

**Códigos por email** [S, C4]: 6 dígitos para alta y como segundo factor al entrar (donde además hace falta `KL`);
**8 caracteres de base32** cuando el código es el único factor (recuperar la contraseña sin Mac). Caducan a los 10 min.
**Tope: 10 códigos fallidos cada 24 h por cuenta**; al pasarlo, la recuperación por email se cierra hasta el día
siguiente y solo queda hacerlo desde un Mac sincronizado o con las 24 palabras. Ningún tope ni bloqueo por fallos se
aplica a quien presenta prueba de cadena, salvo el del segundo factor (§6.7). Sin IP, cualquier tope por cuenta lo puede agotar un tercero que sepa el
email: por eso el dueño siempre tiene dos vías que no pasan por esos topes (un Mac con la cadena, o las 24 palabras).

### 6.2 «Se ha cambiado la contraseña. ¿Has sido tú?» y el bloqueo [S, B2]

El aviso aparece en todos los Macs sincronizados (evento de §10; barra como la de «cuenta borrada» que ya existe en
brave-core [V]). Los Macs lo leen aunque su token esté invalidado, porque **la prueba de cadena basta** para leer
eventos y para renovar el token. «Sí» lo cierra.

**«No he sido yo»** (solo con prueba de cadena) **bloquea la cuenta**: invalida todos los tokens sin cadena, cancela
las peticiones pendientes y los borrados programados, y cierra para las sesiones sin cadena la entrada, el alta de
peticiones y «he olvidado la contraseña». El intruso, aunque tenga el buzón, queda fuera y **no puede volver a entrar
por email**.

**Desbloquear** se hace **solo** desde un Mac con la cadena y con segundo factor (§6.7) [S, N1]: prueba de cadena más
la contraseña actual o un código enviado al email actual. En ese paso se pone la contraseña nueva. El dueño al que el
intruso cambió la contraseña usa el código; el intruso también lo lee, pero no le sirve sin la cadena. Si el buzón
está comprometido, justo después cambia el email (§6.5) con la contraseña que acaba de poner. Con las 24 palabras
cualquier Mac se convierte en un Mac con la cadena. **Nunca solo por email, y nunca al momento solo con la cadena:**
sin contraseña ni buzón, el desbloqueo queda programado a 7 días (§6.7). La sincronización entre los Macs ya unidos no se
interrumpe en ningún momento (tienen la semilla; el protocolo de cadena no pasa por la cuenta).

Si la cuenta está bloqueada y el usuario no tiene ni Macs ni palabras, los datos ya estaban perdidos (§6.1); la
cuenta bloqueada se puede **borrar por email con la demora de 7 días** (cancelable desde cualquier Mac con la cadena)
para liberar la dirección y empezar otra [P]. Si un Mac lo cancela, no se puede volver a programar hasta pasados
30 días [S, O10]: sin ese tope, quien tenga el buzón lo repetiría sin fin.

### 6.3 Un Mac perdido o robado: «Cambiar la clave de sincronización» [S, C2]

Todos los Macs de una cadena comparten la misma clave: **quitar un aparato de la lista no le quita la semilla**. Un Mac
robado seguiría sincronizando y leyendo lo que se escriba después. La página no promete lo que no hace:

- **«Quitar de la lista».** Texto: «Este Mac deja de aparecer aquí, pero conserva la clave de sincronización. Si lo
  has perdido o te lo han robado, cambia la clave de sincronización.»
- **«Cambiar la clave de sincronización»** (desde un Mac con la cadena **y con segundo factor**, §6.7 [S, N1]): genera una semilla nueva, vuelve a subir los
  datos cifrados con ella, liga la cuenta a la cadena nueva (prueba con la clave vieja y con la nueva), hace
  `ClearServerData` y desactiva la cadena vieja, y enseña las **24 palabras nuevas** para guardarlas. Los demás Macs
  reciben el evento «La clave de sincronización se ha cambiado desde otro Mac» y piden unirse otra vez (§5); el robado
  también puede pedirlo, pero nadie tecleará su código. El servidor guarda 30 días la marca «cadena sustituida» para
  poder dar ese aviso en vez de un `DISABLED_BY_ADMIN` sin explicación. Casi todo son piezas que ya existen
  (abandonar cadena, crear cadena, borrar datos del servidor).

**Por qué el segundo factor:** el Mac robado también tiene la cadena. Si bastara con ella, el ladrón podría cambiar la
clave antes que el dueño y quedarse con la cuenta: los Macs del dueño tendrían que pedirle a él la vuelta. Con el
segundo factor, el ladrón solo puede dejar el cambio programado a 7 días; el dueño lo ve en todos sus Macs y en su
correo, lo cancela y hace el suyo al momento.

### 6.4 «Empezar de cero» [S, C3]

Sin Mac sincronizado (solo email + contraseña + buzón) **no se borra nada al momento**. La cadena nueva se crea en el
acto en ese Mac (semilla nueva, palabras nuevas que hay que guardar) y sincroniza como una cadena sin cuenta; el
**borrado de la cadena vieja y el cambio de ligadura esperan 7 días**, con correo y evento a los Macs de la cadena
vieja, que pueden cancelarlo (y bloquear). Es la misma demora que el borrado de la cuenta de §7.

### 6.5 Cambio de email [S, O6]

Como la sal de `KL` sale del email, cambiarlo obliga a teclear la contraseña: el cliente calcula el `KL` viejo, que
hace de segundo factor, y el nuevo para el verificador. Exige **prueba de cadena, segundo factor (§6.7) [S, N1] y un
código enviado a la dirección nueva**; la vieja recibe un aviso y todos los Macs, un evento. Quien no recuerda la
contraseña usa como segundo factor el código al email actual y pone contraseña nueva en el mismo paso. Sin contraseña
ni buzón actual, el cambio queda programado a 7 días (§6.7).

### 6.6 Clave de recuperación

**Opción A (la que propongo y SEGURIDAD apoya): las 24 palabras de siempre.** Es lo que el usuario ya tiene; no inventa
criptografía; no sube nada al servidor; la vía «unirse con código» sigue valiendo como recuperación (aceptando las 24
palabras sin fecha: `SyncSetupGetPureSyncCode` ya existe [V]). Se presenta con otro nombre: «Clave de recuperación:
guárdala impresa o en un gestor de contraseñas. Es la única forma de recuperar tus datos si pierdes todos tus Macs».
**Opción B:** una clave corta que envuelve la semilla y se guarda, cifrada, en el servidor; más cómoda de apuntar, pero
añade un secreto en ns2 y código nuevo. SEGURIDAD (segunda pasada): B solo es segura si la clave **la genera la
máquina** con al menos 100 bits (20 caracteres de base32) y se envuelve con un KDF lento; si la eligiera el usuario,
quien se lleve `sync.db` podría probar claves sin conexión hasta dar con la semilla. Recomienda A. Decide Titín (§13).

### 6.7 Segundo factor y operaciones programadas [S, N1]

Un Mac sincronizado guarda la semilla, así que **siempre** puede dar prueba de cadena, y las 24 palabras son esa misma
semilla. Un Mac robado tiene lo mismo que el dueño salvo dos cosas que no están en el Mac: **la contraseña y el
buzón**. Lo que cambia quién controla la cuenta pide una de las dos.

- **Operaciones de control:** desbloquear (§6.2), cambiar el email (§6.5) y cambiar la clave de sincronización (§6.3).
- **Segundo factor:** el `KL` de la contraseña actual, o un **código enviado al email actual** (8 caracteres de
  base32, 10 min) que el Mac pide con prueba de cadena. Va dentro del cuerpo que firma la prueba.
- **Quién pasa y quién no:** el intruso con contraseña y buzón no tiene la cadena; el ladrón del Mac no tiene ni
  contraseña ni buzón; el dueño tiene la cadena y al menos uno de los dos.
- **Sigue bastando la prueba de cadena sola** para lo defensivo: leer eventos, renovar el token, «No he sido yo»,
  cancelar un borrado, borrar en todos al momento (las copias locales quedan), aprobar y quitar aparatos. Pedir
  segundo factor para aprobar no protegería nada: quien tiene la semilla puede dársela a quien quiera sin aprobar.
- **Fallos del segundo factor:** 10 códigos fallidos cada 24 h por cuenta, en un contador **propio** de los intentos
  con prueba de cadena, y espera creciente para `KL`. Es la única excepción a «ningún tope para quien presenta prueba
  de cadena»: sin ella, el ladrón probaría códigos sin límite. Un tercero sin la cadena no puede gastar ese contador.

**Con la cadena, pero sin contraseña y sin buzón:** la operación se admite con la prueba de cadena sola y queda
**programada a 7 días**.

- **Aviso inmediato:** evento en todos los Macs («Se ha pedido desbloquear / cambiar el email / cambiar la clave desde
  el Mac X. Se hará el día D.») y correo al email actual.
- **Cancela cualquier Mac con prueba de cadena y segundo factor.** La prueba sola no cancela: si bastara, el ladrón
  anularía una y otra vez la del dueño.
- **Qué espera en el servidor:** para desbloquear, el verificador nuevo; para el email, la dirección nueva ya
  confirmada con su código y el verificador nuevo; para la clave, solo el permiso: el cambio lo hace al vencer el Mac
  que lo pidió, con prueba de cadena. Una operación programada por cuenta y tipo; el permiso caduca a los 30 días de
  vencer.
- **Límite que queda** [I]: si el dueño no tiene ni contraseña ni buzón y el ladrón tiene un Mac, los dos presentan lo
  mismo y el servidor no puede distinguirlos; se cumple la que se pidió antes. La página lo previene: al crear la
  cuenta y en el aviso de Mac perdido dice que la contraseña o el buzón son lo que distingue al dueño. Sus datos
  siguen en sus Macs, y siempre puede abandonar esa cadena y crear otra.

## 7. Punto 4: RGPD y privacidad

**Qué guarda ns2 por cuenta:**

| Dato | Para qué | Cómo | Cuánto tiempo |
|---|---|---|---|
| `email_hmac` = HMAC-SHA256(clave_servidor, email normalizado) | entrar; no repetir cuentas | clave fuera de la base. **Sigue siendo dato personal** (seudonimizado, considerando 26): reduce el riesgo, no saca el dato del RGPD | mientras exista la cuenta |
| `email_cifrado` | mandar códigos y avisos | AES-256-GCM, nonce aleatorio de 96 bits, `email_hmac` como dato asociado (liga el cifrado a su fila) [S, O3]; clave en una credencial de systemd (`LoadCredential`), no en la base ni en el repo | mientras exista la cuenta |
| `verificador`, `sal_servidor` | comprobar `KL` | §4 | mientras exista la cuenta |
| `cadena` (= `client_id` de go-sync) | ligar la cuenta con su cadena | seudónimo (clave pública) | mientras exista la cuenta |
| aparatos: `token_hash`, modelo, alta, último uso | listar; «N navegadores» en la confirmación de borrado | hash del token; **caduca a los 180 días sin uso** y se renueva con el uso [S, O2]; el nombre que el usuario ponga viaja dentro de la cadena cifrada, no aquí | hasta salir en ese Mac, caducar o borrar la cuenta |
| peticiones: clave pública, modelo, blob cifrado, fechas | §5 | opaco | hasta aprobar/rechazar; aprobadas sin confirmar, 30 días |
| códigos por email: hash, caducidad, fallos | segundo factor y recuperación | SHA-256; 10 min; tope de 10 fallos en 24 h (§6.1) | 10 min (el contador, 24 h) |
| `ultimo_uso` | borrado de inactivas | fecha, sin más | — |

**Dónde más acaba el email** [S, C6] (la primera versión decía «no se guardan copias»; no era cierto):

- **Registro y cola del servidor de correo.** El MTA anota `to=<email>` y guarda la cola. Requisito: retención del
  registro de correo de **7 días** y cola de rebotes vaciada a diario. El servicio `flyweb-sync` en sí no guarda copia
  ni escribe el email en su registro.
- **Copias de `sync.db`.** Una copia conserva las cuentas ya borradas. Requisito: si se hacen copias, **30 días** de
  conservación, y el plazo publicado. Hoy la copia en bak está «pendiente de decidir» (`instalar-ns2.md` [V]).
- Los dos plazos van al texto de privacidad. Los valores son decisión de Titín (§13).

**Lo que no hay:** IP (Apache no se la pasa al servicio y no la registra, como hoy [V]); nombre; registro de
peticiones; nada en terceros. Los correos llevan solo el código o el aviso, sin nombre («Tu código para FlyWeb:
123456. Caduca en 10 minutos. Si no has sido tú, ignora este mensaje.») y salen por el MTA del propio servidor
[I: SERVIDOR confirma remitente, SPF y DKIM].

**Borrado:**
- «Borrar la cuenta y los datos en todos» desde un Mac con la cadena (prueba de cadena): inmediato (`ClearServerData`
  + `disabled` + borrado de las filas de la cuenta + tokens revocados). Confirmación: «Se desconectarán N navegadores.
  Los datos que cada uno tiene en su perfil no se borran.»
- Lo mismo pedido **sin** cadena (solo email + contraseña): **demora de 7 días** con correo y evento a los Macs;
  cualquier Mac con la cadena lo cancela. SEGURIDAD: siete días bastan, siempre que «Empezar de cero» (§6.4) y el
  desbloqueo (§6.2) no se los salten; ya no se los saltan.
- **Inactivas:** `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365` pasa a activarse con la 3.2 (Titín, 06-11) y se añade
  `FLYWEB_SYNC_AVISO_DIAS=30`: a los 335 días sin uso, un correo; a los 365, borrado de cuenta, cadena y email. Una
  cadena en uso renueva su ficha a diario [V], así que nunca llega. Las cadenas **sin cuenta** siguen con la regla de
  hoy, sin aviso (no hay a quién escribir).
- **Historial:** caduca a los 14 días en el servidor, como hoy.

**Obligaciones que aparecen al haber cuentas** [S, C6c]; no son de diseño, son de Titín con quien lleve lo legal:

- El tratamiento deja de ser ocasional: **registro de actividades** (art. 30), una página.
- **Contrato de encargado con OVH** (art. 28): comprobar que el que hay lo cubre.
- **Procedimiento de brechas** (art. 33): quién avisa a la AEPD en 72 h y con qué datos.
- SEGURIDAD no ve necesaria una evaluación de impacto (art. 35): poca escala y datos cifrados de extremo a extremo.

**Texto de privacidad (W2):** la fila de `sync.flyweb.lamosquita.net` de `web-flyweb.md` §2 cambia a: «Sincronizar
contraseñas, marcadores, historial y ajustes entre sus equipos, y aprobar desde uno de ellos los equipos nuevos. Recibe
sus datos cifrados en su equipo con una clave que nunca sale de él, y, si crea una cuenta, su dirección de correo (para
los códigos de verificación y para avisarle antes de borrar una cuenta sin uso). No recibe su contraseña. El servidor de
correo conserva durante 7 días el registro de los mensajes enviados, y las copias de seguridad se conservan 30 días.»
Base legal de la cuenta: **ejecución del servicio que usted solicita** (art. 6.1.b RGPD). Derechos: acceso y supresión
desde la propia cuenta; lo demás, en la dirección de contacto del texto. **No soy abogado:** W2 sigue con su «revisión
legal».

**Si se roba `sync.db`:** datos cifrados por los navegadores; emails cifrados con una clave que no está en el fichero;
verificadores de scrypt; seudónimos. Rotar la clave de cifrado del email (recifrado masivo) y la del HMAC (se recalcula
en el siguiente inicio de sesión de cada cuenta: hay que guardar la versión de clave por fila).

## 8. Punto 5: compatibilidad y transición desde las 24 palabras

- **El protocolo de cadena no cambia.** Mismo `POST /v2/command/`, mismo token, mismo cifrado. La 2.7.x y la 3.0.x
  siguen funcionando contra ns2 sin saber que existen las cuentas; una 3.2 y una 3.0.1 pueden compartir cadena.
- **Crear cuenta desde un Mac ya sincronizado** (el caso de los 7 usuarios): email, contraseña, código → la cuenta se
  liga a la cadena existente con la **prueba de cadena** de §3.1 (operación «ligar», con el id provisional que devuelve
  `alta`). **Ya no vale el token de sync** [S, B3]: era reutilizable 24 h y permitía a quien viera uno ligar la cadena
  de otro a su cuenta. No se resincroniza nada. Los demás Macs de la cadena reciben el evento «Esta sincronización se
  ha ligado a una cuenta», para que una ligadura que el usuario no ha hecho no pase en silencio.
- **Crear cuenta en un Mac sin cadena:** crea cadena nueva (semilla local, como hoy «Empezar una cadena») y la liga;
  muestra la clave de recuperación y pide confirmar que se ha guardado antes de seguir.
- **Las 24 palabras siguen existiendo** como clave de recuperación (§6.6) y, si Titín quiere, como vía avanzada
  «Unirse con un código» (QR y palabras con tiempo) para quien no quiera cuenta. Propongo **mantenerla visible pero
  secundaria** («Otras opciones»); ocultarla rompería a los 7 usuarios de hoy si alguno no crea cuenta (§13).
- **Una cadena, una cuenta.** Una cadena ligada no se puede ligar a otra cuenta sin borrar la primera.
- **Vuelta de la 3.x a la 2.7.x** (lección 6, último punto): la 2.7.0 publicada no se puede cambiar; la salida
  documentada es restaurar la copia «antes de 3.0» (marca «FlyWeb 3 Profile», `coordinacion.md:136` [V]). Si algún día
  se publica una 2.7.1, que se niegue a abrir un perfil con esa marca. No es parte de la 3.2.

## 9. Punto 6: lecciones del 09-11 → requisitos de la página

| Requisito (`plan-3x.md` §5.1.6) | Cómo lo cumple el diseño | Dónde se prueba (§12) |
|---|---|---|
| Dos botones, dos alcances | «Salir de la sincronización en este Mac» (local: abandona la cadena, revoca su token, conserva el perfil) y «Borrar la cuenta y los datos en todos» (con confirmación que dice N navegadores y que lo local no se borra) | P7, P8 |
| Nada «en curso» para siempre | toda llamada a la cuenta y a sync con tiempo límite de 30 s en el cliente; estado «error» con el motivo (sin red, servidor no responde, código caducado, contraseña incorrecta) y botón Reintentar; ningún spinner sin salida | P10 |
| Claves locales ilegibles = estado propio | `failed_to_decrypt` de la semilla o del token → estado «Este Mac no puede leer sus claves de sincronización (ha cambiado el llavero)» con «Volver a unir este Mac» (§6.1) | P9 |
| Volver a unir sin duplicar | al unirse con datos locales, elegir: **Combinar** (lo de Chromium: contraseñas por clave natural, marcadores por GUID) o **Sustituir lo de este Mac por lo de la cuenta** (hace antes una copia del perfil con el mecanismo de «antes de 3.0», vacía los tipos sincronizados y se une). Después de combinar, botón «Quitar marcadores duplicados» (misma URL, título y carpeta) con la copia como vuelta atrás [P] | P9 |
| Cadena borrada desde otro Mac | `DISABLED_BY_ADMIN` → estado «La cuenta se ha borrado desde otro Mac» (o «La clave de sincronización se ha cambiado», §6.3) con sus salidas; nada de lista vacía con botones muertos | P8, P16 |
| Servidor: contadores anónimos | `flyweb-sync` escribe cada hora, a nivel `warn`, «cuentas borradas: n; DISABLED_BY_ADMIN devueltos: n; peticiones aprobadas: n; correos enviados: altas n, cuentas n, con prueba de cadena y avisos n» sin identificar cadenas ni cuentas | P8, P18 |
| «Passwords» traducido | ya en la 3.0.1 (FS.43, parche 0002) | — |
| La 2.7.x no abre un perfil 3.x | §8, último punto (fuera de la 3.2) | — |

**Estados de la página** (cada uno con su texto y sus botones, ninguno sin salida):

`sin cuenta` → (crear / entrar) → `pendiente de aprobación` (código de aprobación, Cancelar) → `falta confirmar`
(pide el código de confirmación) → `sincronizado` (aparatos, peticiones, cambiar contraseña, cambiar email, cambiar la
clave de sincronización, salir en este Mac, borrar en todos, ver clave de recuperación) · `claves ilegibles` (volver a
unir) · `cuenta borrada desde otro Mac` · `clave cambiada desde otro Mac` (pedir unirse) · `contraseña cambiada: ¿has
sido tú?` (barra) · `cuenta bloqueada` (desbloquear, solo en un Mac con la cadena y con contraseña o código) ·
`borrado programado` (cancelar) · `cambio programado` (desbloqueo, email o clave a 7 días: cancelar con contraseña o
código) ·
`sin red` (lo último que se sabía + Reintentar).

## 10. Servidor

- **Dónde:** el mismo binario `flyweb-sync`, paquete nuevo `cuenta/`, rutas `POST /cuenta/v1/...` montadas junto a
  `/v2`, mismas tablas SQLite más las de §7. Un binario y un fichero, como pidió Titín el 03-10; el vhost de Apache
  solo añade la ruta, y sigue sin pasar la IP.
- **Tres niveles de autenticación** (§3.2): sin sesión; **token de aparato** (32 bytes aleatorios; el Mac lo guarda
  cifrado con OSCrypt; el servidor, su SHA-256; `Authorization: Bearer`; caduca a los 180 días sin uso y se rota al
  cambiar la contraseña [S, O2]); y **prueba de cadena** de un solo uso (§3.1), que basta por sí sola salvo en las
  tres operaciones de control, que piden además segundo factor (§6.7) [S, N1].
- **Llamadas:** `alta` (email → código), `alta/confirmar` (código, `KL`, prueba de cadena opcional → cuenta, token),
  `entrar` (email, `KL`, código → token; **un solo error** para `KL` y código, sin decir cuál falla [S, O9]), `nonce`,
  `segundo-factor/codigo` (prueba de cadena → código al email actual), `programadas` (listar / cancelar), `aparatos/renovar` (prueba → token), `contrasena/cambiar`,
  `contrasena/olvidada` + `/confirmar`, `email/cambiar`, `peticiones` (crear / contar / listar / aprobar / rechazar /
  recoger), `aparatos` (listar / quitar), `eventos` (contraseña cambiada, petición nueva, cuenta bloqueada, borrado
  programado, cambio programado, cadena ligada, clave cambiada), `cuenta/bloquear`, `cuenta/desbloquear`, `cuenta/borrar` (inmediato con
  prueba; diferido sin ella), `cuenta/borrar/cancelar`, `cadena/cambiar`, `cuenta/empezar-de-cero` (diferido), `salir`.
- **Forma de las peticiones** [S, C5]: solo `Content-Type: application/json` (lo demás, 415) y **ninguna cabecera
  CORS**, para que una web no pueda disparar `alta` desde el navegador de quien la visita.
- **Límites** [S, C4 y C5]: 10 códigos fallidos por cuenta cada 24 h (§6.1); 5 códigos por hora y cuenta; 10
  peticiones pendientes por cuenta; tope global de entradas por minuto; un borrado programado sin prueba de cadena
  cada 30 días por cuenta [S, O10]. Los fallos de contraseña ralentizan (espera creciente), no bloquean, y nada de
  esto se aplica a quien presenta prueba de cadena, salvo el contador del segundo factor (§6.7). Sin IP no hay límite
  por IP: es deliberado (privacidad).
- **Cupos de correo, separados** [S, N2]: (1) `alta` a direcciones **sin cuenta**: 20 por hora en total; (2) correos
  a **cuentas existentes** sin prueba de cadena (entrar, recuperar la contraseña): 60 por hora en total, y 5 por
  cuenta; (3) correos pedidos **con prueba de cadena** (segundo factor) y **avisos** (contraseña cambiada, borrado o
  cambio programado, inactividad): fuera de los dos topes globales, con solo el límite de 5 por hora y cuenta, y en
  cola si el MTA no responde: no se descartan. Así 60 altas falsas agotan solo el cupo (1), y quien tiene la cadena
  nunca se queda sin su código. Aviso en el registro al alcanzar cada tope; el contador anónimo de §9 los da por
  separado.
- **Correo:** por el MTA local del servidor desde un remitente del dominio de FlyWeb [I: SERVIDOR confirma SPF y DKIM
  y que el MTA acepta de `DynamicUser`], con el registro de correo a 7 días (§7). Si no hay MTA utilizable, un relé en
  ns1; nunca un servicio de correo de terceros.
- **Configuración:** `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365`, `FLYWEB_SYNC_AVISO_DIAS=30`, `FLYWEB_SYNC_CORREO_DESDE`,
  `FLYWEB_SYNC_CORREOS_HORA=60`, `FLYWEB_SYNC_CORREOS_ALTA_HORA=20`, y dos credenciales de systemd: clave del HMAC y clave AES del email, con versión.
- **Pruebas:** `go test -race` con los casos de §12 en HTTP contra SQLite; `pruebas/go-sync.sh` sigue pasando (nada de
  go-sync se toca); y, en ns2, siempre desde el propio servidor con `curl --resolve ...:127.0.0.1` (regla de la casa).

## 11. Cliente

- **Página:** la de Sincronización de hoy (`flyweb://settings/braveSync`) pasa a llamarse «Cuenta y sincronización» y
  gana los estados de §9; los manejadores nuevos se suman a `BraveSyncHandler` [V].
- **Criptografía:** scrypt (`EVP_PBE_scrypt`), X25519, HPKE (`EVP_HPKE_*`) y Ed25519 de BoringSSL. Funciones nuevas en
  `components/brave_sync/crypto`: la firma con dominio de §3.1 y el cálculo de los dos códigos de §5. Nada nuevo en
  `third_party`; nada que dependa de macOS (vale en Mojave). **No toca** el motor de sync, Nigori ni
  `brave_sync_auth_manager` (confirmado por SEGURIDAD).
- **Prefs nuevas** (cifradas con OSCrypt como la semilla): token de aparato, privada X25519 de la petición pendiente,
  id de cuenta, marca del último evento leído. Todas con el mismo tratamiento de `failed_to_decrypt` que la semilla.
- **Sondeo de eventos:** cada 15 min con sync activa, y al abrir la página; con token y, si el servidor lo rechaza,
  renovándolo con prueba de cadena. Una petición por vez, retroceso exponencial hasta 1 h si falla.
- **Barras de aviso:** `brave_sync_account_deleted_infobar` [V] como patrón para «petición nueva», «contraseña
  cambiada», «borrado programado» y «clave cambiada».

## 12. Hitos y pruebas de aceptación

- **H1 (Titín):** este diseño aprobado tras la segunda revisión de SEGURIDAD y las decisiones de §13.
- **H2 (SERVIDOR-LOCAL / SERVIDOR, NUBE para el código Go):** `flyweb-sync` con `cuenta/`, pruebas en verde, instalado
  en ns2 con el procedimiento de `instalar-ns2.md` y probado desde el propio servidor.
- **H3 (MOTOR el código, LOCAL compilar y probar; revisión de SEGURIDAD del código antes):** cliente en la 7,1; después
  en la 6,1; la 5,1 cuando Titín pueda. Se compila cuando la 3.1 esté medida (`plan-3x.md` §5.2).

**Guion de prueba con tres Macs** (contra ns2 real; una cuenta de prueba; cada paso se anota con resultado):

| # | Caso | Pasa si |
|---|---|---|
| P1 | Mac A sincronizado con palabras (3.0.1) crea cuenta | la cadena queda ligada con prueba de cadena; nada se resincroniza |
| P2 | Mac B nuevo entra y pide unirse | B muestra el código de aprobación; A ve la petición con modelo y fecha, sin código |
| P3 | En A se teclea el código de B y se aprueba; en B se teclea el de confirmación | B no activa nada hasta confirmar; después recibe contraseñas y marcadores; en `sync.db` solo hay cifrado y claves públicas |
| P4 | Mac C pide unirse; nadie aprueba en 2 días; luego se aprueba y confirma | C sigue esperando sin error y se une al confirmar |
| P5 | Petición de un intruso (sesión con la contraseña desde otro perfil) | su sesión no ve las claves de las demás peticiones; al teclear en A el código de B solo se aprueba B; el intruso no recibe nada |
| P6 | El «intruso» cambia la contraseña | A y C sacan token nuevo con prueba de cadena y muestran «¿Has sido tú?»; «No he sido yo» en A bloquea; el intruso **no puede desbloquear por email**; A desbloquea con prueba de cadena y el código enviado al email actual; la sync A–B–C no se corta |
| P7 | «Salir en este Mac» en C | C conserva su perfil; A y B ya no lo listan; el servidor no borra nada |
| P8 | «Borrar en todos» en A | B y C muestran «cuenta borrada desde otro Mac»; `sync.db` sin filas de la cuenta; el contador anónimo sube |
| P9 | En B, cambiar el llavero | estado «claves ilegibles» → «volver a unir» → combinar sin duplicados; luego lo mismo con «sustituir» y comprobar la copia previa |
| P10 | Servidor parado a mitad de cada operación | ningún estado «en curso» pasa de 30 s; mensaje y Reintentar |
| P11 | Recuperación sin Macs, con palabras y sin palabras | con palabras, se une y puede dar prueba de cadena; sin palabras, texto de pérdida |
| P12 | Inactividad (instancia de prueba con plazos de 1 día) | llega el correo de aviso y luego se borra cuenta, cadena y email |
| P13 | Una 3.0.1 con palabras y una 3.2 con cuenta en la misma cadena | sincronizan entre sí; NetLog solo con `sync.flyweb.lamosquita.net` |
| P14 | **Reutilización** (B3): usar un token de sync capturado como prueba; repetir una prueba ya usada; usarla en otra operación | las tres dan 401 |
| P15 | **Servidor malicioso simulado** (B1, C1; instancia de prueba que cambia la clave pública de la petición, o que entrega una semilla propia) | en el primer caso, el código tecleado no coincide con ninguna petición; en el segundo, el código de confirmación no coincide y B no activa nada |
| P16 | **Cambiar la clave de sincronización** (C2) tras «quitar de la lista» a C, desde A con su contraseña | hasta el cambio, C sigue sincronizando (y la página lo avisaba); después, C no lee nada nuevo y ve «clave cambiada»; A enseña palabras nuevas |
| P17 | **Códigos** (C4): 11 códigos fallidos en 24 h | la recuperación por email se cierra; desde A (prueba de cadena) sigue funcionando |
| P18 | **Correo** (C5, N2): 21 altas a direcciones distintas en una hora y, después, entrar en una cuenta real y pedir un segundo factor desde A; `alta` con otro `Content-Type` o desde una web | el correo 21 de alta no sale y el registro avisa; el código de entrada y el del segundo factor **sí** llegan; 415; sin cabeceras CORS |
| P19 | **«Empezar de cero»** sin Mac (C3) y borrado diferido | nada se borra en 7 días (plazo corto en la instancia de prueba); A lo cancela |
| P20 | **Rastros del email** (C6) | tras borrar la cuenta, el email no está en `sync.db`; el registro de correo no pasa de 7 días |
| P21 | **Mac robado** (N1): C, con la cadena pero sin contraseña ni código, intenta desbloquear, cambiar el email y cambiar la clave; después intenta cancelar una operación programada por A | las tres dan 401 o quedan programadas a 7 días (plazo corto en la instancia de prueba) con aviso en A, en B y en el correo; A las cancela con prueba de cadena y contraseña; C no puede cancelar la de A; 11 códigos de segundo factor fallidos desde C cierran el código, y A sigue pudiendo con la contraseña |

**Aceptación de la 3.2** (`plan-3x.md` §5.2): P1–P21 en verde en los tres Macs; datos ilegibles comprobados en ns2;
texto de privacidad publicado; la 3.1 no retrocede.

## 13. Para Titín

Decisiones de producto, con mi recomendación. Las de seguridad ya están cerradas con SEGURIDAD (§14).

1. **Clave de recuperación:** A, las 24 palabras de siempre (recomiendo; SEGURIDAD la recomienda también en su segunda
   pasada); o B, clave corta envuelta en el servidor, que solo es segura si la genera la máquina con 20 caracteres o
   más (§6.6).
2. **Dos códigos de 16 caracteres tecleados por cada Mac nuevo** (§5), y dos viajes si los Macs están en sitios
   distintos. Es el precio de que ni el servidor ni un intruso puedan colarse. Recomiendo aceptarlo: se hace una vez por
   Mac.
3. **Demora de 7 días** para borrar la cuenta y para «Empezar de cero» cuando se pide sin un Mac sincronizado
   (§6.4, §7). Recomiendo 7 (SEGURIDAD: bastan).
4. **Cuenta bloqueada:** solo se desbloquea desde un Mac con la cadena o con las 24 palabras, nunca por email (§6.2),
   **y además con la contraseña o con un código al email** (punto 13). Consecuencia: sin Macs y sin palabras, la
   cuenta bloqueada solo se puede borrar (7 días) y crear otra. Recomiendo aceptarlo: en ese caso los datos ya estaban
   perdidos.
5. **Textos de «Quitar de la lista»** y la función nueva **«Cambiar la clave de sincronización»** (§6.3). Recomiendo
   los textos propuestos.
6. **Tope de códigos:** tras 10 códigos fallidos en 24 h, recuperar por email se cierra hasta el día siguiente (§6.1).
   Recomiendo aceptarlo.
7. **Plazos de RGPD** (§7): registro del servidor de correo 7 días; copias de `sync.db` 30 días (y decidir si hay
   copia en bak, que sigue pendiente). Recomiendo esos valores.
8. **Obligaciones legales** (§7): registro de actividades, contrato de encargado con OVH y procedimiento de brechas.
   Son de Titín con quien lleve lo legal, junto con la revisión de W2.
9. **La vía «unirse con un código»** (QR / palabras con tiempo): visible como «Otras opciones» (recomiendo) o
   escondida.
10. **Modelo del Mac en las peticiones** («MacPro6,1»): basta (recomiendo) o se pide un nombre, que viajaría en claro
    hasta la aprobación.
11. **Nombre de la página:** «Cuenta y sincronización» (recomiendo) u otro.
12. **Remitente de los correos** y si ns2 los manda él mismo: lo confirma SERVIDOR; Titín elige la dirección.
13. **Nuevo (segunda pasada de SEGURIDAD): contraseña o código para tres operaciones.** Desbloquear, cambiar el email
    y cambiar la clave de sincronización piden, además de estar en un Mac sincronizado, la contraseña actual o un
    código que llega al email. Quien no tenga ni contraseña ni buzón puede hacerlas igual, pero **esperando 7 días**
    (§6.7). Es lo que impide que un Mac robado se quede con la cuenta. Recomiendo aceptarlo. Consecuencia práctica:
    con un Mac robado, lo urgente es cambiar la clave de sincronización, y para hacerlo al momento hay que recordar la
    contraseña o tener el buzón.

## 14. Revisión de seguridad

**Modelo de amenazas (corregido el 11-11):**

| Atacante | Qué consigue | Qué no consigue | Dónde se apoya |
|---|---|---|---|
| Tiene email + contraseña y **no** el buzón | nada: el código por email lo para | — | §6.1 |
| Tiene el buzón, con o sin la contraseña (sin ella, la recupera por email) | entra en la cuenta: ve cuántas peticiones hay, crea las suyas, cambia la contraseña, programa un borrado o un «empezar de cero» a 7 días | la semilla y los datos; que se apruebe su petición; ver las de otros; borrar al momento; bloquear o desbloquear; seguir dentro tras «No he sido yo» | §3.2, §5, §6.2 |
| Solo sabe el email | agotar los topes de códigos de esa cuenta durante un día; agotar durante una hora el cupo de correos de `alta` | impedir nada a un Mac con la cadena ni a quien tenga las 24 palabras; dejar sin correo a las cuentas existentes | §6.1, §10 |
| Ve tráfico descifrado (proxy que inspecciona TLS, registro con cabeceras) | tokens de sync reutilizables 24 h, como hoy | usarlos como prueba de cadena: es de un solo uso, con operación, cuenta y cuerpo firmados | §3.1 |
| Se lleva `sync.db` | datos cifrados, verificadores, HMAC de emails, claves públicas, blobs HPKE | emails en claro; contraseñas; semillas | §4, §7 |
| Controla ns2 entero | lo anterior más los emails en claro; negar el servicio; ver quién aprueba y cuándo | **la semilla**: no puede cambiar la clave pública de una petición sin que falle el código de aprobación (2^80), ni colar una semilla suya sin que falle el de confirmación | §5 |
| Roba un Mac sincronizado (y abre la sesión) | la semilla: lee y escribe hasta que el usuario **cambie la clave de sincronización**. Con la prueba de cadena puede bloquear la cuenta, aprobar y quitar aparatos, borrar en todos (las copias locales quedan) y **dejar programado a 7 días** un desbloqueo, un cambio de email o un cambio de clave | hacer al momento ninguna de esas tres: no tiene contraseña ni buzón; cancelar las operaciones del dueño; quedarse con la cuenta mientras el dueño conserve la contraseña o el buzón; seguir leyendo después del cambio de clave; que le aprueben la vuelta | §6.3, §6.7 |
| Roba un Mac **y además** tiene la contraseña o el buzón | lo mismo que el dueño | — (dos de los tres factores: fuera de lo que el diseño puede distinguir) | §6.7 |
| En la red (sin romper TLS) | nada | — | — |

**Cómo queda cada hallazgo de SEGURIDAD-PORTES-21** (comentario 6797345699 del PR #905):

| Hallazgo | Resolución | Dónde |
|---|---|---|
| **B1** código de 30 bits con `id` del servidor | adoptado: 80 bits, sin nada que elija el servidor, **tecleado** | §5 |
| **B2** el cambio de contraseña deja a los Macs sin defensa; desbloqueo por email | adoptado: la prueba de cadena basta para eventos, renovar token y «No he sido yo»; desbloqueo solo con cadena o 24 palabras | §3.2, §4.4, §6.2 |
| **B3** el token de go-sync como prueba | adoptado: prueba propia de un solo uso con dominio, operación, cuenta, nonce y cuerpo | §3.1, §8 |
| **C1** el servidor puede colar su semilla | adoptado: código de confirmación tecleado antes de activar nada | §5 |
| **C2** revocar no corta la sincronización | adoptado: texto honesto y «Cambiar la clave de sincronización» | §6.3 |
| **C3** «Empezar de cero» borraba al momento | adoptado: misma demora de 7 días, cancelable | §6.4 |
| **C4** códigos adivinables; bloqueo por fallos | adoptado: 10 fallos/24 h, 8 caracteres de base32 cuando el código es el único factor, sin bloqueos para quien da prueba de cadena | §6.1, §10 |
| **C5** correo masivo; CORS | adoptado: 60 correos/hora globales, solo JSON, sin CORS (cupos separados después, N2) | §10 |
| **C6** email fuera de la columna cifrada; art. 30, 28, 33 | adoptado como requisitos (7 días, 30 días) y como obligaciones para Titín | §7, §13 |
| **O1** respuestas iguales | adoptado | §4.5 |
| **O2** caducidad del token | adoptado: 180 días renovables; rotación al cambiar la contraseña | §7, §10 |
| **O3** AAD y nonce del cifrado del email | adoptado | §7 |
| **O4** peticiones con código solo con prueba de cadena | adoptado y reforzado: la lista ya no enseña códigos | §3.2, §5 |
| **O5** `cuenta_id` en el `info` de HPKE | adoptado | §5 |
| **O6** cambio de email | adoptado como operación | §6.5 |

**Segunda pasada de SEGURIDAD-PORTES-21** (comentario 6807160010; B1–B3, C1–C6 y O1–O6 dados por resueltos):

| Hallazgo | Resolución | Dónde |
|---|---|---|
| **N1** un Mac robado se queda con la cuenta | adoptado: desbloquear, cambiar el email y cambiar la clave piden prueba de cadena **y** contraseña actual o código al email actual; con solo la cadena, 7 días y cancelable con segundo factor; fila del Mac robado corregida; prueba P21 | §3.2, §6.2, §6.3, §6.5, §6.7, §12 |
| **N2** 60 altas falsas dejan a todos sin códigos | adoptado: cupo de `alta` aparte (20/h), cupo de cuentas existentes (60/h) y correos con prueba de cadena y avisos fuera de los topes globales; contador anónimo por separado | §10, P18 |
| **O7** guardar el blob, no la semilla | adoptado | §5 |
| **O8** tope de nonces pendientes | adoptado **con una variante**: nonce sin estado (HMAC del servidor) y solo se apuntan los usados con prueba válida. Motivo: un tope fijo de pendientes dejaría a cualquiera agotar los nonces de todos. Lo señalo para la tercera pasada | §3.1 |
| **O9** error único en `entrar` | adoptado | §10 |
| **O10** borrado reprogramado sin fin | adoptado: uno cada 30 días por cuenta | §6.2, §10 |
| **1B** solo segura si la genera la máquina | recogido en la opción y en «Para Titín» | §6.6, §13 |

**Lo que este documento no cubre:** el texto legal definitivo (W2, revisión legal), la implementación en Go y en
C++, Android/iOS (cuando existan, la aprobación desde el móvil es la misma petición de §5, tecleando o escaneando los
códigos), y cualquier migración de datos del servidor (no hay: tablas nuevas).

## 15. Fuentes y límites

Código: `brave-core` rama `flyweb` (`components/brave_sync/crypto/*`, `brave_sync_prefs.cc`,
`components/sync/service/brave_sync_auth_manager.cc`, `brave_sync_service_impl.cc`, `browser/ui/webui/settings/brave_sync_handler.cc`,
`browser/infobars/brave_sync_account_deleted_infobar_delegate.*`); `FlyWeb/servidor/sync/{README.md,main.go,sqlite.go,cache.go,instalar-ns2.md}`;
BoringSSL del árbol 156 (`evp.h`: `EVP_PBE_scrypt`; `hpke.h`). Documentos: `plan-3x.md` §5, `TAREAS.md:281` (F7.7),
`coordinacion.md:136,265-269`, `DIRECTIVAS.md:258-264`, `parches/3.0.2-sync-ajustes/README.md`, `web-flyweb.md` §2,
`docs/SERVIDOR.md:13`; revisiones de SEGURIDAD-PORTES-21 (PR #905, comentarios 6797345699 y 6807160010); de la primera salen los datos
sobre `auth/auth.go` de go-sync, que no he vuelto a comprobar. No se ha medido el coste de scrypt en la 6,1 ni se ha
probado nada contra ns2.
