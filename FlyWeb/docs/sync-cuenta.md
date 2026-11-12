# FlyWeb 3.2 — sincronización con cuenta (F7.7): diseño

ARQUITECTURA. Primera versión del 09-11-2026, por orden de Titín (vía COORDINACIÓN-36). **Esta versión, del 12-11 por
la noche, está rehecha con la simplificación de Titín** (`docs/DIRECTIVAS.md`, «Sync con cuenta de la 3.2»,
«Simplificación», #962; buzón de COORDINACIÓN-40 de las 22:46). Su criterio: **sencillo para el usuario y para el
desarrollo; no diseñar para casos extremos que tampoco se resuelven.**

Qué cambia frente a la versión anterior (`ca7e1ac8`):

- **La contraseña de la cuenta es obligatoria.** Desaparece el «código visible» de 16 caracteres.
- **No hay bloqueo de cuenta** ni propuesta E (la espera de 3 días para el Mac robado con el correo abierto).
- **No hay cambios programados a 14 días**, ni códigos de cancelación, ni reglas sobre quién cancela [P; lo
  explico en §6.7 y lo dejo a la vista en §13].
- Las correcciones N4 y N5 de la cuarta pasada de SEGURIDAD siguen, en su versión más simple (§6.2, §10).
- La copia de bak se borra de verdad a los 30 días (§7).

El diseño ha pasado cuatro revisiones de SEGURIDAD-PORTES (21 y 22); la cuarta dio la versión anterior por aprobable
para H1, sin bloqueantes. **Esta versión no la ha visto SEGURIDAD todavía.** Qué queda de cada hallazgo, en §14.

Solo papel: nada compilado ni probado. **Propone; decide Titín.** Hasta que apruebe H1, ni una línea de código.

Marcas: **[V]** visto en el código o en los documentos citados; **[I]** inferido; **[P]** propuesta mía; **[S]**
propuesta de SEGURIDAD adoptada; **[T]** decisión de Titín del 12-11. Sin datos personales de nadie.

## 1. Resumen

- **La cuenta envuelve la cadena; la cadena no cambia.** Hoy una cadena de sync es una semilla de 32 bytes que vive
  solo en los Macs del usuario; de ella salen las 24 palabras, la clave de firma Ed25519 con la que el navegador se
  identifica ante ns2 y la clave con la que cifra los datos [V]. Todo eso sigue igual. Encima va una **cuenta** cuyo
  papel es **llevar la semilla a un Mac nuevo sin teclear 24 palabras**.
- **Un Mac nuevo entra con email + contraseña + código por email, y nada más** [T]. La semilla está en el servidor
  **cifrada con una clave que sale de la contraseña**, estirada en el Mac; el servidor no ve ni la contraseña ni la
  semilla (§4, §5).
- **La contraseña olvidada se cambia desde cualquier Mac que ya sincroniza, con un código por email** [T]. Sin ningún
  Mac, con las 24 palabras, que siguen siendo la clave de recuperación.
- **Tres cosas: la cadena, la contraseña y el buzón. Con dos se tiene la cuenta; con una, no** (§3).
- **Lo que se gana:** un paso, como en cualquier servicio; y quien pierde su único Mac recupera todo con email y
  contraseña, sin las 24 palabras.
- **Lo que se paga, y Titín lo ha aceptado** [T]:
  - quien robe la base de datos puede probar contraseñas sin conexión hasta abrir la semilla de las cuentas con
    contraseña débil (§4);
  - quien tenga **un Mac desbloqueado y el correo** del usuario tiene su cuenta (§6.3);
  - quien tenga **la contraseña y el buzón** es el dueño a todos los efectos.
- **Cada operación sobre la cuenta avisa por correo y en los Macs** [T]. No hay topes que se puedan agotar ni nada
  que se cierre por fallos: solo ritmo y códigos largos (§6.1, §10).
- **Todo lo nuevo es aditivo:** el protocolo de sync y `flyweb-sync` siguen iguales; las cuentas son rutas y tablas
  nuevas en el mismo binario y el mismo SQLite. La 2.7.x y la 3.0.x siguen sincronizando con palabras contra el mismo
  servidor; los 7 usuarios de hoy no tienen que hacer nada hasta que quieran crear su cuenta.
- **Datos personales en ns2:** el email y el nombre que el usuario ponga a cada Mac [T], los dos cifrados con una
  clave que no está en la base. Sin IP y sin registro de peticiones. Plazos en §7; propuesta de papeles legales en
  [`sync-cuenta-rgpd.md`](sync-cuenta-rgpd.md).
- **Riesgo medio-alto** (`plan-3x.md` §5.2). Criptografía de la que ya trae BoringSSL (scrypt, HKDF, AES-256-GCM,
  Ed25519) [V].

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
| Copia de `sync.db` | prevista en bak, cifrada | `servidor/sync/instalar-ns2.md:154` |

## 3. Modelo: quién tiene qué y qué puede hacer

| Cosa | Usuario | Mac sincronizado | Mac nuevo (antes de entrar) | Servidor (ns2) |
|---|---|---|---|---|
| Contraseña | la sabe | **no la guarda**, ni nada que salga de ella | la teclea | **nunca**: un verificador (§4) |
| Semilla / 24 palabras | las tiene guardadas (clave de recuperación) | sí, en el llavero | **no**, hasta que entra | **nunca en claro**: la envoltura, cifrada con una clave que sale de la contraseña (§4) |
| Datos sincronizados | — | en claro, en el perfil | no | cifrados, ilegibles |
| Email | — | lo guarda (lo enseña la página) | lo teclea | HMAC (para entrar) + cifrado con clave del servidor (para escribirle) |
| Token de aparato (§10) | — | sí, en el llavero | sí, tras entrar | hash |

**Las tres cosas:**

- **La cadena:** tener la semilla. La tiene cualquier Mac sincronizado y quien tenga las 24 palabras.
- **La contraseña:** solo en la cabeza del usuario (o en su gestor). El Mac no la guarda, y por eso distingue al
  dueño de quien le roba el Mac.
- **El buzón:** poder leer un código enviado al email de la cuenta.

**Dos cualesquiera dan la tercera:**

| Con… | …se consigue | Cómo |
|---|---|---|
| contraseña + buzón | la cadena | entrando desde un Mac nuevo (§5) |
| cadena + buzón | la contraseña | poniendo una nueva (§6.1) [T] |
| cadena + contraseña | el buzón | cambiando el email de la cuenta (§6.5) |

Así que **con dos se tiene la cuenta entera**, y no hay forma de distinguir de su dueño a quien las tenga.

### 3.1 La prueba de cadena [S, B3]

El token de sync de hoy **no sirve** como prueba de que alguien tiene la cadena: firma solo la hora, va en cada petición
y vale 24 h. La cuenta usa una prueba propia, de un solo uso, firmada con la misma clave Ed25519 de la cadena:

`prueba = Ed25519(SK_cadena, "flyweb-cuenta-v1" ‖ operación ‖ cuenta_id ‖ nonce_servidor ‖ SHA-256(cuerpo))`

- `nonce_servidor`: lo pide el Mac antes (`nonce`), es **de un solo uso** y caduca a los 5 min. El servidor **no
  guarda los pendientes** [O8, variante aceptada por SEGURIDAD en la tercera pasada]: el nonce lleva 16 bytes
  aleatorios, su caducidad y un HMAC con una clave que el servidor genera al arrancar. Solo se apuntan **los ya usados
  con una prueba válida**, hasta que caducan, y **después de verificar la firma**; comprobar y apuntar van bajo el
  mismo cerrojo, como hace hoy la caché [V].
- `operación` es una etiqueta fija por llamada («ligar», «cambiar-clave»…): una prueba no vale para otra operación, ni
  para otra cuenta, ni para otro cuerpo. Campos de longitud fija o con prefijo de longitud.
- El prefijo de dominio no se puede leer como una hora en decimal: una firma de cuenta no sirve como token de sync, ni
  al revés.
- En el cliente es una función nueva en `components/brave_sync/crypto`; **no toca** `brave_sync_auth_manager`.

### 3.2 Qué pide cada operación

| Operación | Qué hace falta |
|---|---|
| Crear la cuenta | un código enviado al email y una contraseña nueva; prueba de cadena si liga una cadena que ya existe (§8) |
| **Añadir un Mac** (recibir la semilla) | **email + contraseña + código por email** [T] |
| Leer eventos; renovar el token; quitar un aparato de la lista o cambiarle el nombre; «No he sido yo»; cancelar un borrado pedido por email; salir en este Mac | la cadena |
| Borrar la cuenta y los datos en todos, al momento | la cadena |
| **Cambiar la contraseña**, o poner una nueva si se olvidó | la cadena + **un código enviado al email** [T] |
| **Cambiar el email** | la cadena + **la contraseña** + un código enviado a la dirección nueva |
| **Cambiar la clave de sincronización** | la cadena + **la contraseña** |
| Pedir «Empezar de cero» o el borrado de la cuenta sin tener ningún Mac | el buzón solo, **con demora de 14 días** [T] |

Tres conclusiones:

1. **Con una sola de las tres no se toma la cuenta.** La contraseña sola no sirve para nada. El buzón solo, para
   pedir un borrado a 14 días que cualquier Mac del usuario cancela. La cadena sola (un Mac robado, sin el correo)
   lee y escribe los datos hasta que el dueño cambie la clave, y puede borrarlos, pero no cambia nada de la cuenta.
2. **Con dos se es el dueño.** Contraseña y buzón: es el modelo de Firefox Accounts [T]. Mac desbloqueado y correo:
   riesgo aceptado [T] (§6.3).
3. **No hay estados intermedios:** ni cuenta bloqueada, ni sesiones a medias, ni cambios programados. Lo único que
   lleva fecha es el borrado pedido solo con el buzón (§6.4).

## 4. Punto 1: claves. La contraseña envuelve la clave de la cadena

**Objetivo (COORDINACIÓN-30 y decisión 2 de Titín):** la contraseña se transforma en el cliente; el servidor guarda
un verificador y la semilla envuelta, y no puede abrirla sin adivinar la contraseña.

1. **Normalizar** el email (minúsculas, sin espacios, NFC) y la contraseña (NFC). Longitud mínima de contraseña: 10
   [P]. La contraseña es **obligatoria** [T].
2. **Estiramiento en el cliente:** `KE = scrypt(contraseña, sal = SHA-256("flyweb-cuenta-v1" ‖ email), N = 2^17,
   r = 8, p = 1, 32 bytes)`. La sal sale del email para no pedir al servidor una sal por cuenta antes de entrar, que
   delataría si el email existe (aceptado por SEGURIDAD en la primera pasada). Coste: 128 MiB y, por cálculo, entre
   medio segundo y segundo y medio en la 5,1 [I, sin medir]; el detalle y la puerta de medida están más abajo, en
   «Coste del estiramiento».
3. **Dos claves de `KE`, separadas con HKDF-SHA256** (`HKDF` de BoringSSL [V]):
   - `KL = HKDF(KE, info = "flyweb-cuenta-v1/entrar")`: **clave de entrada**. Es lo único que viaja al servidor.
     Es el `authPW` de onepw.
   - `KU = HKDF(KE, info = "flyweb-cuenta-v1/envolver")`: **clave de envoltura**. No sale del Mac. Es el
     `unwrapBKey` de onepw.

   De `KL` no se saca `KU` ni `KE`: HKDF no se invierte, y las dos salidas son independientes para quien no tiene
   `KE`. **El servidor no recibe nunca nada que abra la semilla:** ni al crear la cuenta, ni al entrar, ni al cambiar
   la contraseña o el email. Recibe `KL` y la envoltura `E`; para abrir `E` hace falta `KU`, y a `KU` solo se llega
   adivinando la contraseña y pagando el estiramiento del paso 2.
4. **Envoltura** (la calcula un Mac que tiene la semilla): `E = AES-256-GCM(KU, nonce aleatorio de 96 bits, semilla,
   dato asociado = "flyweb-envoltura-v1" ‖ SHA-256(email))` (`EVP_aead_aes_256_gcm` [V]). Lleva autenticación: una
   envoltura cambiada, o hecha por quien no sabe la contraseña, **no abre**. El servidor no puede colar una semilla
   suya.
5. **Estiramiento en el servidor:** `KS = scrypt(KL, sal_servidor (16 bytes aleatorios por cuenta), N = 2^14, r = 8,
   p = 1)`, y de `KS`, con HKDF, el **verificador** `V` y una clave `KW`. El servidor guarda `sal_servidor`, `V` y
   `EE = AES-256-GCM(KW, E)`: la envoltura va **envuelta otra vez**. Al entrar, compara `V` en tiempo constante, abre
   `EE` con `KW` y entrega `E`; no guarda ni `KL` ni `KW` ni `E`.
6. **Cambiar la contraseña** es volver a envolver. Se hace en un Mac que ya sincroniza, con **un código enviado al
   email** [T]; no se pide la contraseña anterior, así que es también lo que hace quien la ha olvidado. El Mac (que
   tiene la semilla) calcula `KE`, `KL` y `KU` nuevos y manda `KL` nuevo y `E` nueva en una sola llamada, con la
   prueba de cadena y el código; el servidor genera `sal_servidor` nueva y sustituye `V` y `EE` a la vez. **Solo se
   recifran 32 bytes; los datos sincronizados no se tocan**, así que cambiarla no puede perder datos. Se invalidan
   los tokens de los demás aparatos, que sacan otro con la prueba de cadena y reciben el aviso de §6.2 [S, B2].
   Cambiar la contraseña **no echa** a quien ya recibió la semilla: para eso está §6.3.
   Tres seguros para que un cambio a medias no deje la cuenta sin una envoltura válida [P]:
   - **antes de enviar**, el Mac abre la `E` nueva con la `KU` nueva y comprueba que sale su semilla;
   - el servidor sustituye `sal_servidor`, `V` y `EE` en **una sola transacción** de SQLite: vale la contraseña
     vieja o la nueva, nunca ninguna de las dos;
   - si la respuesta se pierde, el Mac repite la misma llamada, y el servidor contesta lo mismo si ya la aplicó.

   Y aunque todo eso fallara, la semilla sigue en cada Mac sincronizado y en las 24 palabras: lo peor que puede pasar
   es tener que poner la contraseña otra vez desde un Mac.
7. **Sin ningún Mac y sin contraseña** quedan las 24 palabras [T]: con ellas un Mac nuevo se une a la cadena y, ya
   sincronizado, pone una contraseña nueva (§6.1). Sin Mac, sin contraseña y sin palabras no hay nada que abra la
   envoltura: los datos se pierden y solo queda «Empezar de cero». El email por sí solo **no cambia la contraseña**.
8. **Respuestas iguales exista o no la cuenta** [S, O1]: las llamadas sin sesión contestan lo mismo y tardan lo mismo;
   para un email desconocido el servidor calcula un scrypt de relleno y aplica **la misma espera** (§10) [S, N4].

**Comparación con «onepw» de Mozilla** (fuente en §15; lo que no dice esa página no lo afirmo):

| | onepw (Firefox Accounts) [V en la página] | FlyWeb [P] | Por qué |
|---|---|---|---|
| Estiramiento en el cliente | PBKDF2, 1000 vueltas, con el email como sal | scrypt N = 2^17 (128 MiB) | En onepw, quien ve lo que llega al servidor ataca a 1000 vueltas por intento («fácil», dice la propia página). El nuestro es mucho más caro por intento |
| Lo que viaja | `authPW`, derivada con HKDF | `KL`, igual | — |
| Estiramiento en el servidor | scrypt «64k/8/1» sobre `authPW`, con sal aleatoria | scrypt N = 2^14 sobre `KL`, con sal aleatoria | El coste grande ya está en el cliente |
| Clave envuelta | `kB` = XOR de tres valores, **sin MAC**; la sortea el servidor | la **semilla que ya existe**, con AES-256-GCM | La cadena la crea el primer Mac [T]; con autenticación el Mac detecta una envoltura falsa |
| Doble envoltura | sí (`wrapwrapKey`) | sí (`KW`) | Con la base robada, todo intento paga los dos estiramientos. Aquí añade poco (un 12 %), pero es gratis: el servidor ya calcula ese scrypt |
| Segundo paso | las claves no se entregan hasta verificar el email | código por email en cada Mac nuevo | [T] |
| Cambio de contraseña | el cliente abre y vuelve a envolver `kB`; sal nueva | el Mac envuelve de nuevo la semilla, que ya tiene | — |
| Contraseña olvidada | se cambia por email y **se pierden los datos** | se cambia desde un Mac que ya sincroniza, con un código por email, **sin perder nada**; sin Mac, las 24 palabras | La semilla está en los Macs y en las palabras [T] |

**Por qué scrypt y no Argon2:** BoringSSL del árbol trae `EVP_PBE_scrypt` y no trae Argon2 [V]; SEGURIDAD lo aceptó.
**Por qué no OPAQUE ni SRP:** evitarían que el servidor vea `KL`, que es justo lo que abarata el ataque a quien
controla ns2 (§14). No están en BoringSSL y serían criptografía nueva en el cliente y en el servidor; SEGURIDAD lo
aceptó para la 3.2 y queda como deuda para una `v2`.

### Coste del estiramiento: en el Mac y para el atacante

**Parámetros** [P]: cliente, scrypt con N = 2^17, r = 8, p = 1 y salida de 32 bytes; servidor, scrypt con N = 2^14,
r = 8, p = 1. Van ligados a la etiqueta `flyweb-cuenta-v1`.

**Qué cuesta un intento, contado en el código** [V, `third_party/boringssl/src/crypto/evp/scrypt.cc`]:

- **Memoria:** N × 2r × 64 bytes = **128 MiB** (más 2 KiB). `EVP_PBE_scrypt` rechaza por defecto todo lo que pase de
  65 MiB (`SCRYPT_MAX_MEM`, línea 150): hay que llamarla con `max_mem` de 130 MiB o falla con
  `EVP_R_MEMORY_LIMIT_EXCEEDED`. Es un fallo que solo se vería al probar; queda escrito en §11.
- **Cálculo:** 2N mezclas de bloque con 16 Salsa20/8 cada una, unos **4,2 millones de Salsa20/8**, más 131 072
  lecturas de 1 KiB en posiciones al azar de esos 128 MiB.
- **La versión de BoringSSL es escalar** (`salsa208_word_specification`, sin SSE ni AVX): que la 5,1 no tenga AVX
  **no cambia nada**; cuenta la velocidad de un núcleo y la de la memoria.

**Tiempo en la 5,1** (2 × Xeon E5620 Westmere a 2,4 GHz, 48 GB [V, `docs/TAREAS.md` FS.25 y `docs/entorno-mojave.md`]): **no
está medido, y no lo mido yo** (ARQUITECTURA no mide rendimiento). Por cálculo [I]: a 200–350 ciclos por Salsa20/8
con su XOR, de 0,35 a 0,6 s, más la reserva de la memoria y los fallos de caché; la cifra clásica del autor de
scrypt para N = 2^14 en un equipo de 2009 (unos 100 ms, citada de memoria, sin releer) lleva a algo menos de un
segundo. **Entre medio segundo y segundo y medio en la 5,1**; la 6,1, algo menos. Se paga **una vez por contraseña
tecleada**, nunca al sincronizar.

**Puerta de medida, antes de publicar** [P]: los parámetros no se pueden cambiar después sin una versión `v2` y sin
que cada usuario vuelva a teclear su contraseña. Así que el número se cierra con una medida, que es la prueba P23 de
§12:

- La primera compilación del cliente cronometra `EVP_PBE_scrypt` con estos parámetros en la 6,1 y en la 5,1.
- **Hasta 2 s en la 5,1, se queda N = 2^17.** Si pasa de 2 s, **N = 2^16** (64 MiB, la mitad de tiempo): el ataque
  se abarata a la mitad, un bit.
- Si la 5,1 no está disponible ese día, vale la 6,1 con el límite en **1 s** [I: la E5620 es más lenta por núcleo
  que la 6,1, pero no el doble].
- Sin compilar, quien tenga un Python 3 enlazado con OpenSSL 1.1 o posterior puede adelantar la cifra, porque el
  scrypt de OpenSSL es el mismo código escalar [I]:
  `python3 -c "import hashlib,time;t=time.time();hashlib.scrypt(b'x',salt=b'y',n=2**17,r=8,p=1,maxmem=2**28,dklen=32);print(time.time()-t)"`

**Frente al ataque sin conexión con la base robada** (el riesgo que acepta Titín): cada contraseña probada paga
**los dos estiramientos**, 2^17 y 2^14, y necesita 128 MiB. La tabla usa como unidad **0,3 s por intento y núcleo**
de una máquina moderna: es un **supuesto**, no una medida [I; S, O11]. Un atacante real usará tarjetas gráficas, y
scrypt deja cambiar memoria por tiempo, así que no hay un número fijo de intentos a la vez por tarjeta. Lo que está
demostrado es que el producto de memoria por tiempo no baja (Alwen y otros, «Scrypt is Maximally Memory-Hard»,
EUROCRYPT 2017; lo cita SEGURIDAD y no lo he releído). El coste real por intento **se mide en P22** con
`hashcat -b -m 8900`, llevado a N = 2^17. **Los veredictos no dependen de la unidad:** con un atacante cien veces
más rápido, 30 bits siguen cayendo y 50 siguen aguantando; lo que se mueve es la fila de 40.

| Contraseña | Intentos | Coste con ese supuesto [I] | Veredicto |
|---|---|---|---|
| Está en la lista del millón más usadas | 10⁶ | 3,5 días de un núcleo | **Cae.** Horas con cien núcleos |
| 30 bits (palabra con adornos, fecha y nombre) | 10⁹ | 10 años-núcleo | **Cae** ante quien alquile mil núcleos unos días |
| 40 bits (dos o tres palabras al azar y una cifra) | 10¹² | 10 000 años-núcleo | Cara: solo un atacante con muchos medios y contra una cuenta concreta |
| 50 bits o más (cuatro palabras al azar, o de gestor) | 10¹⁵ | 10 millones de años-núcleo | Fuera de alcance |

Dos matices:

- **La sal sale del email**, así que el trabajo no se comparte entre cuentas: hay que repetirlo por cada una.
- **Con onepw de Mozilla**, el mismo ataque con la base paga 1000 vueltas de PBKDF2 y un scrypt de 2^16: el nuestro
  cuesta algo más del doble por intento. La diferencia grande está en quien **controla el servidor o ve el
  tráfico**: en onepw paga solo las 1000 vueltas («fácil», dice su página); aquí sigue pagando el scrypt de 2^17.

La página lo dirá al pedir la contraseña, con un indicador de fuerza y sin obligar a más que la longitud mínima: es
la decisión de Titín.

## 5. Punto 2: añadir un Mac

**Objetivo (Titín, 12-11):** email + contraseña + código por email, sin aprobación desde otro Mac.

### 5.1 Los pasos

1. **Mac nuevo:** el usuario teclea email y contraseña. El Mac calcula `KE`, `KL` y `KU` y llama a `entrar/empezar`
   con el email y `KL`.
2. **Servidor:** antes de mirar nada aplica la **espera** de §10, igual exista o no la cuenta [S, N4]. Si la cuenta
   existe y `KL` es correcta, manda un **código al email** (8 caracteres de base32, 10 min), devuelve un
   identificador de solicitud y **deja un evento en los Macs de la cuenta** («Alguien ha escrito bien tu contraseña
   desde un Mac nuevo», §6.2): quien controle el buzón puede borrar el correo, pero no el evento. Si no, devuelve un
   identificador falso con la misma forma y el mismo tiempo, y no manda nada. **En los dos casos la espera crece
   igual** (§10): quien no lee el buzón no sabe si la contraseña era buena, ni por la respuesta ni por la espera.
3. **Mac nuevo:** el usuario teclea el código y da un **nombre al Mac** [T] (por defecto, el modelo). El Mac llama a
   `entrar/terminar` con la solicitud, `KL`, el código, el modelo y el nombre.
4. **Servidor:** si todo coincide, devuelve el `cuenta_id`, un token de aparato y la envoltura `E`. **Un solo error**
   para contraseña y código, sin decir cuál falla [S, O9].
5. **Mac nuevo:** abre `E` con `KU`. Si no abre, no activa nada y avisa («La clave recibida no es válida. No se ha
   activado nada.»). Si abre: `SetSeed` con las palabras y se une a la cadena exactamente como hoy. **Olvida la
   contraseña, `KE`, `KL` y `KU`**: en el Mac solo quedan la semilla y el token, como hoy.
6. **Aviso:** correo al email de la cuenta y evento en todos los Macs: «Se ha añadido el Mac «nombre» (modelo). Si no
   has sido tú, …» (§6.2).

Si el Mac nuevo ya tenía datos, elige combinar o sustituir (§9).

**Si ha olvidado la contraseña** [T]: la página del Mac nuevo lo dice con dos salidas. «Cámbiala en un Mac que ya
sincroniza (Cuenta y sincronización → He olvidado la contraseña) y vuelve aquí.» Y, si no tiene ninguno, «Tengo mi
clave de recuperación» (§6.6).

### 5.2 Qué ve el servidor y qué se ha perdido

**Ve:** email (HMAC y cifrado), `KL` al entrar (no la guarda), el verificador, la envoltura doble, y modelo, nombre
(cifrado) y fechas de cada aparato. **No ve** la contraseña, `KU`, la semilla ni los datos.

**Lo que protegía la aprobación desde otro Mac del primer diseño y ya no hay** (para que la decisión quede con todas
sus consecuencias a la vista):

| Antes (aprobación desde otro Mac) | Ahora (modelo de Firefox Accounts) |
|---|---|
| Contraseña + buzón no llegaban a los datos | **Contraseña + buzón son la cuenta entera** |
| ns2 entero no podía obtener la semilla | ns2 entero, o quien robe la base, **ataca las contraseñas sin conexión**; las débiles caen |
| Perder el único Mac sin las palabras = perder los datos | Se recuperan con email y contraseña |
| Dos códigos de 16 caracteres y, a veces, dos viajes | Un paso, como cualquier servicio |

## 6. Punto 3: recuperación y defensa de la cuenta

### 6.1 Casos de recuperación

| Situación | Qué hace el usuario | Qué pasa con los datos |
|---|---|---|
| **Olvidé la contraseña, tengo un Mac sincronizado** | «He olvidado la contraseña» en ese Mac → código al email → contraseña nueva. El Mac vuelve a envolver (§4.6) [T] | **Ni se tocan** |
| **Olvidé la contraseña, no tengo ningún Mac, tengo las 24 palabras** | En el Mac nuevo, «Tengo mi clave de recuperación» → teclea las palabras → ese Mac ya sincroniza → fila anterior [T] | **Ni se tocan** |
| **Perdí todos los Macs, recuerdo la contraseña** | Entra con email + contraseña + código (§5.1) | Los recupera todos |
| **Perdí todos los Macs, no tengo contraseña ni palabras** | Solo le queda el buzón | **Datos perdidos.** La página lo dice con el texto de Titín y ofrece «Empezar de cero» (§6.4) |
| **Un Mac no puede leer sus claves** (llavero cambiado) | La página lo detecta (`failed_to_decrypt`) y ofrece «Volver a unir este Mac» | Es volver a entrar (§5) o las palabras. Sus datos locales siguen en el perfil; al unirse, §9 decide combinar o sustituir |

«Cambiar la contraseña» y «He olvidado la contraseña» son **la misma operación** con dos nombres: cadena, código al
email y contraseña nueva.

**Códigos por email** [T, decisión 6; S, C4 y N3]: todos de **8 caracteres de base32 (40 bits)** y 10 min. **No hay
tope diario ni cierre.** Contra la fuerza bruta: **un intento cada 10 s por solicitud de código**, contado sobre el
identificador que recibió quien lo pidió, de modo que un tercero no gasta los intentos del dueño. Sale a 60 intentos
por código; con el máximo de 5 códigos por hora y cuenta (§10), unos 100 000 intentos en 14 días y una probabilidad de
acierto de 10⁻⁷ [I].

### 6.2 «¿Has sido tú?» y «No he sido yo» [S, B2; T, decisión 6]

**Cada operación avisa** en todos los Macs sincronizados (evento de §10; barra como la de «cuenta borrada» que ya
existe en brave-core [V]) **y por correo**: Mac añadido, contraseña cambiada, email cambiado, clave de sincronización
cambiada, aparato quitado, borrado pedido o cancelado. Los Macs leen los eventos aunque su token esté invalidado,
porque la prueba de cadena basta.

**Probar la contraseña en línea también avisa, en los Macs** [S, N4]. Sin cierres, quien tenga el buzón solo, o un
Mac robado, puede probar contraseñas contra el servidor al ritmo de §10. Si acierta con el buzón en la mano, tiene
la cuenta entera, y el correo de aviso lo borra él. Por eso estos dos avisos van **a los Macs**, donde no los puede
borrar:

- **Contraseña acertada desde un Mac nuevo:** al mandar el código de entrada, evento «Alguien ha escrito bien tu
  contraseña desde un Mac nuevo. Si no has sido tú, cámbiala ya.» El correo del código dice lo mismo: quien recibe
  un código que no ha pedido sabe que alguien conoce su contraseña.
- **Contraseña fallada:** evento con el resumen («N intentos fallidos de contraseña desde el día D», y desde qué Mac
  si venían con prueba de cadena). **El primero, al momento; después, como mucho uno por hora y cuenta.**

Quien se equivoca al teclear su propia contraseña verá ese aviso en sus otros Macs; es el precio, y es pequeño.

**«No he sido yo»** (con la cadena sola) hace lo inmediato y lleva al remedio:

- Al momento: invalida todos los tokens de aparato y cancela los borrados pedidos por email.
- Después, la página guía según el aviso: **cambiar la contraseña** (deja fuera a quien la sabía y aún no había
  entrado), **cambiar la clave de sincronización** (§6.3; deja sin datos nuevos a quien ya entró) y, si el buzón no
  es de fiar, **cambiar el email** (§6.5).

**No hay bloqueo de cuenta** [T]. Con este modelo no dejaría fuera a nadie: quien entra con contraseña y buzón recibe
la cadena, y desbloquearía igual que el dueño. Y daría un arma a quien robe el único Mac de un usuario: bloquear,
para que no pueda recuperar sus datos con email y contraseña.

**Límite que hay que decir claro:** contra un intruso con contraseña **y** buzón no hay defensa más que adelantarse.
Tiene lo mismo que el dueño; quien cambie antes la clave, la contraseña y el email se queda la cuenta, y el otro
conserva los datos que ya tenía en sus Macs. Es el mismo límite de Firefox Accounts.

### 6.3 Un Mac perdido o robado: «Cambiar la clave de sincronización» [S, C2]

Todos los Macs de una cadena comparten la misma clave: **quitar un aparato de la lista no le quita la semilla**. Un Mac
robado seguiría sincronizando y leyendo lo que se escriba después. La página no promete lo que no hace:

- **«Quitar de la lista».** Texto: «Este Mac deja de aparecer aquí, pero conserva la clave de sincronización. Si lo
  has perdido o te lo han robado, cambia la clave de sincronización.»
- **«Cambiar la clave de sincronización»** (con la cadena **y la contraseña** [S, N1]): el usuario teclea su
  contraseña; el Mac genera una semilla nueva, vuelve a subir los datos cifrados con ella, liga la cuenta a la
  cadena nueva (prueba con la clave vieja y con la nueva), **sube la envoltura nueva**, hace `ClearServerData` y
  desactiva la cadena vieja, y enseña las **24 palabras nuevas** para guardarlas. Los demás Macs reciben «La clave
  de sincronización se ha cambiado desde otro Mac» y **vuelven a entrar con email, contraseña y código** (§5); el
  robado no puede: no tiene la contraseña. El servidor guarda 30 días la marca «cadena sustituida» para dar ese
  aviso en vez de un `DISABLED_BY_ADMIN` sin explicación.
- **Si ha olvidado la contraseña:** primero la cambia (código al email) y después cambia la clave [T].
- **Desde un Mac nuevo:** quien perdió su único Mac entra con email, contraseña y código en otro y cambia la clave.

**Por qué la contraseña:** el Mac robado también tiene la cadena; si bastara con ella, el ladrón cambiaría la clave
antes que el dueño. Y hay que teclearla de todos modos: la semilla nueva se envuelve con una clave que sale de ella.

**Resumen: qué puede hacer quien roba un Mac y cómo lo corta el dueño.** Vale para un Mac con la **sesión de macOS
abierta**. Con el Mac apagado o bloqueado no tiene nada [T]: la semilla y el token están cifrados con una clave del
llavero [V, §2], y el llavero se abre con la contraseña de macOS [I].

| El ladrón, con el Mac y **sin el correo** | ¿Puede? | Cómo lo corta el dueño |
|---|---|---|
| Leer lo que ya estaba en ese Mac (contraseñas guardadas, marcadores, historial) | sí; está en el disco | la cuenta no lo remedia: cambiar las contraseñas de las webs guardadas |
| Seguir sincronizando: leer lo nuevo, escribir y borrar; ver las 24 palabras y unir otros aparatos | sí, **hasta el cambio de clave** | **«Cambiar la clave de sincronización»**, con su contraseña |
| «Borrar en todos» | sí, al momento | no se impide; cada Mac conserva su copia local y el dueño vuelve a crear cadena y cuenta |
| Probar contraseñas | unas 96 al día, con aviso en los demás Macs (§10) | una contraseña que no esté en las listas |
| Cambiar la contraseña, el email o la clave; volver a entrar tras el cambio de clave | **no** | — |

**Lo que hace el dueño, por orden:** (1) desde otro Mac, o desde uno nuevo con email, contraseña y código,
**cambia la clave de sincronización**; el Mac robado deja de leer en ese momento y no puede volver a entrar. (2)
Guarda las 24 palabras nuevas. (3) Cambia las contraseñas de las webs que estaban guardadas en el Mac robado. No
necesita cambiar la contraseña de la cuenta: el Mac no la guarda (§11).

**Riesgo aceptado: el Mac robado y abierto que además tiene el correo** [T]. Con Mail o el webmail con la sesión
iniciada, el ladrón tiene la cadena y el buzón: pone una contraseña nueva y, con ella, cambia la clave y el email.
**Tiene la cuenta.** Gana quien llegue antes: si el dueño cambia la clave primero, el ladrón se queda sin cadena, y
con el buzón solo ya no puede nada; en ese caso al dueño le conviene cambiar también la contraseña de su correo. Si
llega antes el ladrón, el dueño conserva los datos que tiene en sus Macs y pierde la cuenta. No se añade ninguna
espera para este caso: es la decisión de Titín, y lo que protege es la contraseña de macOS.

### 6.4 «Empezar de cero» y borrar sin ningún Mac [S, C3; T]

Con el buzón solo (sin Mac, sin palabras, sin contraseña) **no se borra nada al momento**. La cadena nueva se crea en
el acto en ese Mac (semilla nueva, palabras nuevas que hay que guardar) y sincroniza como una cadena sin cuenta; el
**borrado de la cadena vieja y el cambio de ligadura esperan 14 días** [T], con correo y evento a los Macs de la
cadena vieja, que pueden cancelarlo con la cadena sola. Es la misma demora que el borrado de la cuenta de §7, y el
único plazo del diseño.

Si un Mac lo cancela, no se puede volver a pedir hasta pasados 30 días [S, O10]: sin ese tope, quien tenga el buzón lo
repetiría sin fin. **Límite** [I]: por lo mismo, quien tenga un Mac robado puede impedir que un dueño que solo
conserva el buzón libere su dirección. Ese dueño no pierde datos (ya los había perdido) y puede abrir cuenta con
otra dirección.

### 6.5 Cambio de email [S, O6]

Como la sal del estiramiento sale del email, cambiarlo obliga a **volver a envolver**: el usuario teclea la contraseña
y el Mac calcula las claves viejas y las nuevas. Exige **la cadena, la contraseña y un código enviado a la dirección
nueva**; la vieja recibe un aviso y todos los Macs, un evento. No pide código a la dirección vieja: así puede cambiar
de email quien ya no tiene acceso al buzón anterior. Quien no recuerda la contraseña la cambia primero (§6.1).

### 6.6 Clave de recuperación [T, decisión 1]

**Las 24 palabras de siempre**, que genera el primer Mac. Se presentan como «Clave de recuperación: guárdala impresa
o en un gestor de contraseñas. Es la única forma de recuperar tus datos si pierdes todos tus Macs y olvidas la
contraseña». La entrada «Tengo mi clave de recuperación» acepta las 24 palabras (`SyncSetupGetPureSyncCode` ya existe
[V]) y también las 25 con fecha que enseña una 2.7.x o una 3.0.x, para poder unir una 3.2 a una cadena que aún no
tiene cuenta [P]. La opción B (clave corta guardada en el servidor) queda descartada.

### 6.7 Por qué cada cambio pide lo que pide [S, N1; T]

Un Mac robado tiene la cadena, igual que el dueño. Lo que no tiene es lo que no está guardado en el Mac: **la
contraseña y el buzón**. Lo que cambia quién controla la cuenta pide uno de los dos, además de la cadena:

| Cambio | Además de la cadena | Por qué eso y no lo otro |
|---|---|---|
| La contraseña | un código al email actual [T] | es también la vía de quien la ha olvidado: no se le puede pedir la que no recuerda |
| El email | la contraseña, y un código a la dirección nueva | hay que teclearla de todos modos para volver a envolver; y sirve a quien ha perdido el buzón viejo |
| La clave de sincronización | la contraseña | hay que teclearla de todos modos para envolver la semilla nueva; y no depende del correo, que el ladrón puede tener abierto |

- **Sigue bastando la cadena sola** para lo defensivo: leer eventos, renovar el token, «No he sido yo», cancelar un
  borrado pedido por email, quitar aparatos y borrar en todos al momento. Borrar no pide más porque quien tiene la
  cadena puede destruir los datos igualmente, borrándolos por la sincronización normal [I].
- **Sin cierres que se puedan agotar** [S, N3a y N4; T]: los fallos **no cierran nada**. Códigos: un intento cada
  10 s por solicitud (§6.1). Contraseña: la espera de §10, con tope de 15 minutos, y aviso en los Macs (§6.2). El
  ladrón y el dueño presentan la misma prueba de cadena, así que cualquier cierre lo gastaría el ladrón para dejar
  fuera al dueño.
- **Ya no hay cambios programados** [P]. La versión anterior admitía estos tres cambios pedidos con la cadena sola
  y los dejaba «a 14 días», con aviso, código de cancelación y reglas sobre quién podía cancelar. Servían a un solo
  caso: el dueño que ha olvidado la contraseña **y** ha perdido el buzón. Ese caso tiene otra salida (abajo), y a
  cambio el mecanismo daba a quien roba un Mac una forma de quedarse la cuenta si el dueño no veía el aviso en
  14 días. Quitarlo deja menos estados en la página, menos correo y menos que probar. Con la cadena sola, estos
  cambios **no se admiten**.

**Límites que quedan** [I]:

- **Mac desbloqueado y correo:** es la cuenta (§6.3) [T].
- **Contraseña y buzón en manos de otro:** es el dueño (§6.2) [T].
- **El dueño ha olvidado la contraseña y ha perdido el buzón:** no puede cambiar nada de la cuenta. Sus Macs siguen
  sincronizando y puede unir otros con las 24 palabras. Si quiere una cuenta que le sirva, borra la cuenta en todos
  y crea otra con otra dirección: cada Mac conserva sus datos.
- **Un ladrón con el Mac abierto que insiste** (falla contraseñas para tener la espera a tope, o pide los 5 códigos
  de cada hora) puede **retrasar** al dueño. No puede quitarle la cuenta ni cerrarle nada, y el dueño ve cada intento
  en sus Macs y en su correo. La salida que no depende de turnos ni de códigos es borrar en todos y crear cadena y
  cuenta nuevas.

## 7. Punto 4: RGPD y privacidad

**Qué guarda ns2 por cuenta:**

| Dato | Para qué | Cómo | Cuánto tiempo |
|---|---|---|---|
| `email_hmac` = HMAC-SHA256(clave_servidor, email normalizado) | entrar; no repetir cuentas | clave fuera de la base. **Sigue siendo dato personal** (seudonimizado, considerando 26): reduce el riesgo, no saca el dato del RGPD | mientras exista la cuenta |
| `email_cifrado` | mandar códigos y avisos | AES-256-GCM, nonce aleatorio de 96 bits, `email_hmac` como dato asociado [S, O3]; clave en una credencial de systemd (`LoadCredential`), no en la base ni en el repo | mientras exista la cuenta |
| `verificador`, `sal_servidor`, envoltura doble `EE` | comprobar `KL`; entregar la semilla envuelta | §4. **Con la base robada permite probar contraseñas sin conexión** (riesgo aceptado) | mientras exista la cuenta |
| `cadena` (= `client_id` de go-sync) | ligar la cuenta con su cadena | seudónimo (clave pública) | mientras exista la cuenta |
| aparatos: `token_hash`, modelo, **nombre**, alta, último uso | listar; decir en los avisos qué Mac ha sido; «N navegadores» en la confirmación de borrado | hash del token, que caduca a los 180 días sin uso [S, O2]. **El nombre es dato personal** [T, decisión 10]: lo elige el usuario, lo ve solo él, y va cifrado como el email [P] | hasta salir en ese Mac, caducar o borrar la cuenta |
| códigos por email: hash, caducidad, último intento | entrar, cambiar la contraseña, confirmar el email nuevo | SHA-256; sin contador diario (§6.1) | 10 min |
| borrado pedido solo con el buzón: fecha | §6.4 | — | hasta cumplirse o cancelarse; la marca de cancelación, 30 días |
| `ultimo_uso` | borrado de inactivas | fecha, sin más | — |
| esperas de la contraseña (§10) | frenar la adivinación en línea | **solo en memoria**, con `email_hmac` como clave; incluye emails **sin cuenta**, porque la espera tiene que ser la misma [S, N4] | 24 h desde el último intento; nunca en disco ni en la copia de bak |

**Dónde más acaba el email** [S, C6; T, decisión 7]:

- **Registro y cola del servidor de correo.** El MTA anota `to=<email>` y guarda la cola. Requisito: retención del
  registro de correo de **7 días** y cola de rebotes vaciada a diario. `flyweb-sync` no guarda copia ni escribe el
  email en su registro.
- **Copia de `sync.db` en bak: sí, cifrada, 30 días** [T]. Propuesta de cómo [P, para SERVIDOR]: se cifra **en ns2,
  antes de salir**, con una clave pública cuya privada no está ni en ns2 ni en bak (la guarda Titín); así bak solo
  tiene un fichero que no puede abrir. Las dos credenciales de systemd (HMAC y AES) **no van en esa copia**: sin
  ellas una base restaurada no sirve para entrar ni para escribir a nadie, así que necesitan su propia custodia.
- **Los 30 días son un borrado de verdad** [T]. La regla de la casa en servidores es mover a cuarentena y que vacíe
  Titín; aquí la cuarentena alargaría el plazo que publicamos, y Titín ha aprobado esta rotación automática como
  **excepción** (`DIRECTIVAS.md`, «Simplificación», D). Vale solo para estas copias.
- Los dos plazos van al texto de privacidad.

**Lo que no hay:** IP (Apache no se la pasa al servicio y no la registra, como hoy [V]); nombre de la persona;
registro de peticiones; nada en terceros. Los correos llevan solo el código o el aviso («Tu código para FlyWeb:
K7QM-2XRA. Caduca en 10 minutos. Si no has sido tú, alguien conoce tu contraseña: cámbiala.») y salen desde
`noreply@` del dominio de FlyWeb [T, decisión 12], por el MTA del propio servidor [I: SERVIDOR confirma SPF y DKIM].

**Borrado:**
- «Borrar la cuenta y los datos en todos» con la cadena: inmediato (`ClearServerData` + `disabled` + borrado de las
  filas de la cuenta + tokens revocados). Confirmación: «Se desconectarán N navegadores. Los datos que cada uno tiene
  en su perfil no se borran.»
- Lo mismo pedido **solo con el buzón**: **demora de 14 días** [T] con correo y evento a los Macs; cualquier Mac con
  la cadena lo cancela.
- **Inactivas:** `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365` pasa a activarse con la 3.2 (Titín, 06-11) y se añade
  `FLYWEB_SYNC_AVISO_DIAS=30`: a los 335 días sin uso, un correo; a los 365, borrado de cuenta, cadena y email. Una
  cadena en uso renueva su ficha a diario [V], así que nunca llega. Las cadenas **sin cuenta** siguen con la regla de
  hoy, sin aviso (no hay a quién escribir).
- **Historial:** caduca a los 14 días en el servidor, como hoy.

**Obligaciones que aparecen al haber cuentas** [S, C6c; T, decisión 8]: registro de actividades (art. 30), contrato
de encargado con OVH (art. 28) y procedimiento de brechas (art. 33 y 34). La propuesta, con marcadores en lugar de
los datos del responsable, está en [`sync-cuenta-rgpd.md`](sync-cuenta-rgpd.md). SEGURIDAD no ve necesaria una
evaluación de impacto (art. 35).

**Texto de privacidad (W2):** la fila de `sync.flyweb.lamosquita.net` de `web-flyweb.md` §2 cambia a: «Sincronizar
contraseñas, marcadores, historial y ajustes entre sus equipos. Recibe sus datos cifrados en su equipo con una clave
que nosotros no tenemos. Si crea una cuenta, recibe también su dirección de correo (para los códigos de verificación
y los avisos), el modelo y el nombre que dé a cada equipo, y esa clave cifrada con su contraseña: no recibe la
contraseña, pero su seguridad depende de que sea difícil de adivinar. El servidor de correo conserva durante 7 días
el registro de los mensajes enviados, y las copias de seguridad, cifradas, se conservan 30 días.» Base legal de la
cuenta: **ejecución del servicio que usted solicita** (art. 6.1.b RGPD). Derechos: acceso y supresión desde la propia
cuenta; lo demás, en la dirección de contacto del texto. **No soy abogado:** W2 sigue con su «revisión legal».

**Si se roba `sync.db`:** datos cifrados por los navegadores; emails y nombres cifrados con una clave que no está en
el fichero; seudónimos; y, de cada cuenta, verificador y envoltura. **Con eso se prueban contraseñas sin conexión**,
pagando los dos estiramientos por intento, y la que se acierte abre la semilla y, con ella, los datos de esa cuenta
que van en el mismo fichero. Es una brecha que hay que tratar como tal (`sync-cuenta-rgpd.md` §3): avisar a los
usuarios para que cambien la contraseña **y la clave de sincronización**. Además, rotar la clave de cifrado del email
y la del HMAC (hay que guardar la versión de clave por fila).

## 8. Punto 5: compatibilidad y transición desde las 24 palabras

- **El protocolo de cadena no cambia.** Mismo `POST /v2/command/`, mismo token, mismo cifrado. La 2.7.x y la 3.0.x
  siguen funcionando contra ns2 sin saber que existen las cuentas; una 3.2 y una 3.0.1 pueden compartir cadena.
- **Crear cuenta desde un Mac ya sincronizado** (el caso de los 7 usuarios): email, código por email y contraseña →
  la cuenta se liga a la cadena existente con la **prueba de cadena** de §3.1 (operación «ligar») y el Mac sube la
  envoltura. **No vale el token de sync** [S, B3]. No se resincroniza nada. Los demás Macs de la cadena reciben el
  evento «Esta sincronización se ha ligado a una cuenta».
- **Crear cuenta en un Mac sin cadena:** crea cadena nueva (semilla local, como hoy «Empezar una cadena») y la liga;
  muestra la clave de recuperación y pide confirmar que se ha guardado antes de seguir.
- **«Unirse con un código» deja de ser una opción aparte** [T, decisión 9]. Un Mac se añade con la cuenta (§5); las
  24 palabras quedan como clave de recuperación (§6.6), que es también la manera de unir una 3.2 a una cadena sin
  cuenta.
- **Una cadena, una cuenta.** Una cadena ligada no se puede ligar a otra cuenta sin borrar la primera.
- **Vuelta de la 3.x a la 2.7.x** (lección 6, último punto): la 2.7.0 publicada no se puede cambiar; la salida
  documentada es restaurar la copia «antes de 3.0» (marca «FlyWeb 3 Profile», `coordinacion.md:136` [V]). Si algún día
  se publica una 2.7.1, que se niegue a abrir un perfil con esa marca. No es parte de la 3.2.

## 9. Punto 6: lecciones del 09-11 → requisitos de la página

| Requisito (`plan-3x.md` §5.1.6) | Cómo lo cumple el diseño | Dónde se prueba (§12) |
|---|---|---|
| Dos botones, dos alcances | «Salir de la sincronización en este Mac» (local: abandona la cadena, revoca su token, conserva el perfil) y «Borrar la cuenta y los datos en todos» (con confirmación que dice N navegadores y que lo local no se borra) | P7, P8 |
| Nada «en curso» para siempre | toda llamada a la cuenta y a sync con tiempo límite de 30 s en el cliente; estado «error» con el motivo (sin red, servidor no responde, código caducado, contraseña o código incorrectos) y botón Reintentar; ningún spinner sin salida. El estiramiento de la contraseña (medio segundo o más) se anuncia | P10 |
| Claves locales ilegibles = estado propio | `failed_to_decrypt` de la semilla o del token → estado «Este Mac no puede leer sus claves de sincronización (ha cambiado el llavero)» con «Volver a unir este Mac» (§6.1) | P9 |
| Volver a unir sin duplicar | al unirse con datos locales, elegir: **Combinar** (lo de Chromium: contraseñas por clave natural, marcadores por GUID) o **Sustituir lo de este Mac por lo de la cuenta** (hace antes una copia del perfil con el mecanismo de «antes de 3.0», vacía los tipos sincronizados y se une). Después de combinar, botón «Quitar marcadores duplicados» (misma URL, título y carpeta) con la copia como vuelta atrás [P] | P9 |
| Cadena borrada desde otro Mac | `DISABLED_BY_ADMIN` → estado «La cuenta se ha borrado desde otro Mac» (o «La clave de sincronización se ha cambiado», §6.3) con sus salidas; nada de lista vacía con botones muertos | P8, P16 |
| Servidor: contadores anónimos | `flyweb-sync` escribe cada hora, a nivel `warn`, «cuentas borradas: n; DISABLED_BY_ADMIN devueltos: n; Macs añadidos: n; correos enviados: altas n, códigos n, avisos n» sin identificar cadenas ni cuentas | P8, P18 |
| «Passwords» traducido | ya en la 3.0.1 (FS.43, parche 0002) | — |
| La 2.7.x no abre un perfil 3.x | §8, último punto (fuera de la 3.2) | — |

**Estados de la página «Cuenta y sincronización»** [T, decisión 11] (cada uno con su texto y sus botones, ninguno
sin salida):

`sin cuenta` → (crear / entrar / tengo mi clave de recuperación) → `falta el código del email` (Reenviar, Cancelar)
→ `sincronizado` (aparatos con su nombre, cambiar la contraseña o «He olvidado la contraseña», cambiar el email,
cambiar la clave de sincronización, salir en este Mac, borrar en todos, ver la clave de recuperación) · `claves
ilegibles` (volver a unir) · `cuenta borrada desde otro Mac` · `clave cambiada desde otro Mac` (volver a entrar) ·
`¿has sido tú?` (barra, con «No he sido yo») · `borrado programado` (cancelar) · `sin red` (lo último que se sabía +
Reintentar).

Son nueve. De versiones anteriores se van `pendiente de aprobación`, `falta confirmar`, `cuenta bloqueada` y `cambio
programado`.

## 10. Servidor

- **Dónde:** el mismo binario `flyweb-sync`, paquete nuevo `cuenta/`, rutas `POST /cuenta/v1/...` montadas junto a
  `/v2`, mismas tablas SQLite más las de §7. Un binario y un fichero, como pidió Titín el 03-10; el vhost de Apache
  solo añade la ruta, y sigue sin pasar la IP.
- **Tres niveles de autenticación** (§3.2): sin sesión; **token de aparato** (32 bytes aleatorios; el Mac lo guarda
  cifrado con OSCrypt; el servidor, su SHA-256; `Authorization: Bearer`; caduca a los 180 días sin uso y se rota al
  cambiar la contraseña [S, O2]), que solo sirve para leer eventos y listar aparatos; y **prueba de cadena** de un
  solo uso (§3.1), sola, con un código del email o con la contraseña (§6.7).
- **Llamadas:** `alta` (email → código), `alta/confirmar` (código, prueba de cadena, `KL` y envoltura → cuenta,
  token), `entrar/empezar` (email, `KL` → solicitud y, si procede, código), `entrar/terminar` (solicitud, `KL`,
  código, modelo, nombre → token, envoltura), `nonce`, `contrasena/codigo` (prueba de cadena → código al email
  actual), `contrasena/cambiar` (prueba de cadena, código, `KL` y envoltura nuevas), `email/cambiar/empezar` (prueba
  de cadena, `KL` actual, dirección nueva → código a la dirección nueva), `email/cambiar/terminar` (código, `KL` y
  envoltura nuevas), `cadena/cambiar` (prueba con la clave vieja y con la nueva, `KL`, envoltura nueva), `aparatos`
  (listar / quitar / renovar / renombrar), `eventos`, `no-he-sido-yo`, `cuenta/borrar` (inmediato con prueba),
  `cuenta/borrar-por-email` y `cuenta/empezar-de-cero` (diferidos), `cuenta/borrar/cancelar`, `salir`.
- **Forma de las peticiones** [S, C5]: solo `Content-Type: application/json` (lo demás, 415) y **ninguna cabecera
  CORS**, para que una web no pueda disparar `alta` desde el navegador de quien la visita.
- **Ritmos, sin cierres** [T, decisión 6; S, N3 y N4]: un intento cada 10 s por solicitud de código; 5 códigos por
  hora y cuenta; un borrado por email cada 30 días por cuenta tras una cancelación [S, O10]. **Ningún contador
  diario y nada que se cierre por fallos.** Sin IP no hay límite por IP: es deliberado (privacidad).
- **Espera de la contraseña** [S, N4]: una por email, la misma al entrar y cuando la contraseña acompaña a una
  prueba de cadena (cambio de email o de clave).
  - **Se dobla** (10 s, 20 s, 40 s…) **con tope de 15 minutos**: tras cada `entrar/empezar`, **acierte o no**, y
    tras cada contraseña fallada con prueba de cadena. A tope deja unos 96 intentos al día.
  - **Vuelve a cero** cuando la contraseña buena llega con algo más: al terminar una entrada con el código del
    email, con una contraseña correcta junto a una prueba de cadena, o al cambiar la contraseña. También a las 24 h
    sin intentos.
  - **Por qué un acierto en `entrar/empezar` no la pone a cero** [P, corrección mía a la versión anterior]: si lo
    hiciera, la propia espera diría a quien no lee el buzón si la contraseña era buena. `entrar/terminar` no pasa
    por esta espera: una solicitud verdadera solo existe si la contraseña ya fue buena, y la frena el ritmo del
    código.
  - **Igual exista o no la cuenta** [S, N4]: la clave de la tabla es `email_hmac`, y la espera se aplica **antes**
    de mirar si hay cuenta y antes de calcular ningún scrypt. Si no, la espera delataría qué emails tienen cuenta
    (O1).
  - **Solo en memoria** [P]: tabla de tamaño fijo, con caducidad a las 24 h. No va a `sync.db` ni a la copia de
    bak, para no dejar en disco el HMAC del email de quien no tiene cuenta. Al reiniciar el servicio las esperas
    vuelven a cero [I: límite menor].
  - Durante la espera el servidor no comprueba nada y contesta cuándo acaba. La página lo dice («Demasiados
    intentos. Podrás volver a probar a las HH:MM.»); el Mac no guarda la contraseña para reintentar solo (§11).
- **Avisos de la contraseña** [S, N4]: los dos eventos de §6.2, acierto desde un Mac nuevo y resumen de fallos.
- **Semáforo de scrypt** [S, N5]:
  - como mucho **tantos scrypt a la vez como núcleos tenga ns2**;
  - las peticiones de más **esperan en cola** hasta 25 s (por debajo del límite de 30 s del cliente, §9) y, si no
    les llega el turno, reciben «servidor ocupado»;
  - **tope de memoria explícito:** 16 MiB por scrypt en curso, una cola de longitud fija y `MemoryMax` en la unidad
    de systemd [I: los valores los pone SERVIDOR con los núcleos y la memoria de ns2 a la vista];
  - el scrypt de relleno de los emails sin cuenta pasa por el mismo semáforo;
  - lo que no calcula scrypt (todo lo que va con prueba de cadena y sin contraseña) no pasa por él.
- **Límites conocidos** [I]:
  - **La espera de la contraseña se disputa.** Es una por email, así que quien sepa un email puede mantenerla a tope
    y ocuparle al dueño los turnos de 15 minutos: le retrasa añadir un Mac y cambiar el email o la clave. No cierra
    nada. No afecta a quien ya sincroniza ni a cambiar la contraseña (va con código, y al cambiarla la espera vuelve
    a cero); y un Mac se puede unir siempre con las 24 palabras.
  - **Una avalancha de `entrar/empezar` con emails inventados llena la cola.** Añadir un Mac se vuelve lento y puede
    dar «servidor ocupado» mientras dure; quien ya sincroniza no lo nota. Sin IP, la aplicación no distingue a
    quien inunda. Si hiciera falta un freno por IP, iría delante, en Apache, y es cosa de SERVIDOR [I, no lo
    propongo aquí].
- **Cupos de correo, separados** [S, N2 y N3b]: (1) `alta` a direcciones **sin cuenta**: 20 por hora en total; (2)
  códigos de entrada a **cuentas existentes**: 60 por hora en total y 5 por cuenta, y solo se mandan con `KL`
  correcta, así que quien no sabe la contraseña no gasta este cupo ni llena el buzón de nadie; (3) códigos pedidos
  **con prueba de cadena** (cambio de contraseña, email nuevo): fuera de los topes globales, 5 por hora y cuenta;
  (4) **avisos**: **sin cupo y nunca se descartan**; van a una cola propia y se reintentan si el MTA no responde. Su
  número queda acotado porque lo que avisa pide un código o la contraseña, o solo se puede hacer una vez (quitar un
  aparato, pedir un borrado, borrar); «No he sido yo» no repite aviso si no cambia nada. Aviso en el registro al alcanzar cada tope; el contador anónimo de §9 los da
  por separado.
- **Correo:** por el MTA local del servidor, desde `noreply@` del dominio de FlyWeb [T; I: SERVIDOR confirma SPF y
  DKIM y que el MTA acepta de `DynamicUser`], con el registro de correo a 7 días (§7). Si no hay MTA utilizable, un
  relé en ns1; nunca un servicio de correo de terceros.
- **Configuración:** `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365`, `FLYWEB_SYNC_AVISO_DIAS=30`,
  `FLYWEB_SYNC_DEMORA_DIAS=14`, `FLYWEB_SYNC_CORREO_DESDE`, `FLYWEB_SYNC_CORREOS_HORA=60`,
  `FLYWEB_SYNC_CORREOS_ALTA_HORA=20`, `FLYWEB_SYNC_ESPERA_TOPE_MIN=15`, `FLYWEB_SYNC_SCRYPT_A_LA_VEZ` (por defecto,
  los núcleos), `FLYWEB_SYNC_SCRYPT_COLA_S=25`, y dos credenciales de systemd: clave del HMAC y clave AES (email y
  nombres), con versión.
- **Pruebas:** `go test -race` con los casos de §12 en HTTP contra SQLite; `pruebas/go-sync.sh` sigue pasando (nada de
  go-sync se toca); y, en ns2, siempre desde el propio servidor con `curl --resolve ...:127.0.0.1` (regla de la casa).

## 11. Cliente

- **Página:** la de Sincronización de hoy (`flyweb://settings/braveSync`) pasa a llamarse «Cuenta y sincronización» y
  gana los estados de §9; los manejadores nuevos se suman a `BraveSyncHandler` [V].
- **Criptografía:** scrypt (`EVP_PBE_scrypt`), HKDF (`HKDF`), AES-256-GCM (`EVP_aead_aes_256_gcm`) y Ed25519 de
  BoringSSL, todos en el árbol 156 [V]. Funciones nuevas en `components/brave_sync/crypto`: la firma con dominio de
  §3.1 y la cadena de claves y la envoltura de §4. Nada nuevo en `third_party`; nada que dependa de macOS (vale en
  Mojave). **No toca** el motor de sync, Nigori ni `brave_sync_auth_manager`.
- **Lo que el Mac no guarda nunca:** la contraseña, `KE`, `KL`, `KU`. Se calculan al teclear y se borran de memoria
  al terminar la llamada, con `OPENSSL_cleanse`, sin pasar por ninguna pref ni por el registro [S: lo comprobará al
  revisar el código de H3]. Tampoco se guardan para reintentar tras una espera. De esto depende que la contraseña
  proteja la cuenta frente a un Mac robado (§6.7).
  Tampoco la guarda el **gestor de contraseñas** del navegador: la página es interfaz propia y no un formulario web,
  así que no debería ofrecerlo [I]; se comprueba en P23.
- **Llamada a scrypt** [V, `scrypt.cc:150-177`]: `EVP_PBE_scrypt` con `max_mem` de 130 MiB; con el valor por defecto
  (65 MiB) falla. Reserva 128 MiB y ocupa un núcleo alrededor de un segundo: va **fuera del hilo de la interfaz**,
  en una tarea del grupo de hilos, y una sola a la vez. La página enseña «Comprobando la contraseña…» mientras dura.
- **Prefs nuevas** (cifradas con OSCrypt como la semilla): token de aparato, id y email de la cuenta y marca del
  último evento leído. Todas con el mismo tratamiento de `failed_to_decrypt` que la semilla.
- **Sondeo de eventos:** cada 15 min con sync activa, y al abrir la página; con token y, si el servidor lo rechaza,
  renovándolo con prueba de cadena. Una petición por vez, retroceso exponencial hasta 1 h si falla (regla de la casa:
  nunca en bucle contra ns2).
- **Barras de aviso:** `brave_sync_account_deleted_infobar` [V] como patrón para «Mac añadido», «contraseña
  cambiada», «borrado programado» y «clave cambiada».

## 12. Hitos y pruebas de aceptación

- **H1 (Titín):** este diseño aprobado. Antes lo revisa SEGURIDAD-PORTES-22 en esta versión.
- **H2 (SERVIDOR-LOCAL / SERVIDOR, NUBE para el código Go):** `flyweb-sync` con `cuenta/`, pruebas en verde, instalado
  en ns2 con el procedimiento de `instalar-ns2.md` y probado desde el propio servidor.
- **H3 (MOTOR el código, LOCAL compilar y probar; revisión de SEGURIDAD del código antes):** cliente en la 7,1; después
  en la 6,1; la 5,1 cuando Titín pueda. Se compila cuando la 3.1 esté medida (`plan-3x.md` §5.2).

**Guion de prueba con tres Macs** (contra ns2 real; una cuenta de prueba; cada paso se anota con resultado). Los
números no se renumeran, para no romper las referencias de las revisiones: **P3** (código visible) y **P25**
(propuesta E) quedan retiradas.

| # | Caso | Pasa si |
|---|---|---|
| P1 | Mac A sincronizado con palabras (3.0.1) crea cuenta | pide contraseña y no deja seguir sin ella; la cadena queda ligada con prueba de cadena; hay envoltura en `sync.db`; nada se resincroniza |
| P2 | Mac B nuevo entra con email + contraseña + código por email; después, Mac C igual | B y C reciben contraseñas y marcadores; A recibe evento y correo «Se ha añadido el Mac «nombre» (modelo)»; en `sync.db` solo hay cifrado |
| P4 | Contraseña mala; contraseña buena y código malo | con contraseña mala no sale ningún correo y la respuesta es igual que con la buena; el error final es uno solo |
| P5 | «Intruso» con la contraseña y sin el buzón. Después (N4), **20 contraseñas malas seguidas** contra la cuenta y contra un email sin cuenta | no recibe nada, y **ni la respuesta ni la espera le dicen que la contraseña era buena**; el dueño recibe un código que no ha pedido, con el texto de aviso, y A y B muestran «contraseña acertada desde un Mac nuevo». Con las malas: aviso de fallos en A y en B, el primero al momento y no más de uno por hora; **el ritmo medido** se dobla hasta 15 min y es el mismo para el email sin cuenta; con la espera a tope, A cambia la contraseña con un código y la espera vuelve a cero |
| P6 | Cambio de contraseña en A, con un código del email y sin teclear la anterior | B y C sacan token nuevo con prueba de cadena y muestran «¿Has sido tú?»; la contraseña vieja ya no entra; un Mac nuevo entra con la nueva; la sync A–B–C no se corta. «No he sido yo» en B invalida tokens y lleva a cambiar contraseña y clave |
| P7 | «Salir en este Mac» en C | C conserva su perfil; A y B ya no lo listan; el servidor no borra nada |
| P8 | «Borrar en todos» en A | B y C muestran «cuenta borrada desde otro Mac»; `sync.db` sin filas de la cuenta; el contador anónimo sube |
| P9 | En B, cambiar el llavero | estado «claves ilegibles» → «volver a unir» → combinar sin duplicados; luego lo mismo con «sustituir» y comprobar la copia previa |
| P10 | Servidor parado a mitad de cada operación | ningún estado «en curso» pasa de 30 s; mensaje y Reintentar |
| P11 | **Contraseña olvidada:** con un Mac; sin Macs y con las palabras; sin nada; y desde un Mac nuevo | con un Mac: código al email y contraseña nueva, datos intactos; con las palabras: se une y hace lo mismo; sin nada: texto de pérdida y «Empezar de cero»; el Mac nuevo enseña las dos salidas de §5.1 |
| P12 | Inactividad (instancia de prueba con plazos de 1 día) | llega el correo de aviso y luego se borra cuenta, cadena y email |
| P13 | Una 3.0.1 con palabras y una 3.2 con cuenta en la misma cadena | sincronizan entre sí; NetLog solo con `sync.flyweb.lamosquita.net` |
| P14 | **Reutilización** (B3): usar un token de sync capturado como prueba; repetir una prueba ya usada; usarla en otra operación | las tres dan 401 |
| P15 | **Servidor malicioso simulado** (instancia de prueba que entrega una envoltura cambiada, o la de otra semilla) | el Mac nuevo no la abre y no activa nada |
| P16 | **Cambiar la clave de sincronización** (C2) tras «quitar de la lista» a C, desde A con su contraseña | hasta el cambio, C sigue sincronizando (y la página lo avisaba); después, C no lee nada nuevo y ve «clave cambiada»; A enseña palabras nuevas; B vuelve a entrar con email, contraseña y código |
| P17 | **Códigos sin cierre** (decisión 6, N3a): 100 códigos fallidos seguidos | el servidor impone 10 s entre intentos de una solicitud y nunca cierra; los fallos de otra solicitud no retrasan la del dueño |
| P18 | **Correo** (C5, N2, N3b): 21 altas a direcciones distintas en una hora; después, entrar en una cuenta real; después, agotar los 5 códigos de la hora y quitar un aparato; `alta` con otro `Content-Type` o desde una web | el correo 21 de alta no sale y el registro avisa; el código de entrada **sí** llega; el **aviso** del aparato quitado **llega** con los códigos agotados; 415; sin cabeceras CORS |
| P19 | **«Empezar de cero»** solo con el buzón (C3) y borrado diferido | nada se borra en 14 días (plazo corto en la instancia de prueba); A lo cancela; no se puede volver a pedir en 30 días |
| P20 | **Rastros del email** (C6) | tras borrar la cuenta, el email no está en `sync.db`; el registro de correo no pasa de 7 días; la copia de bak no se abre sin la clave privada y no hay copias de más de 30 días |
| P21 | **Mac robado** (N1): C, con la cadena sola, intenta cambiar la contraseña, el email y la clave; después falla **20 contraseñas seguidas** (N4) y pide los 5 códigos de la hora | ninguna de las tres se hace ni queda pendiente; los fallos de C no cierran nada, dan aviso de fallos en A y en B (el primero al momento, luego uno por hora) y el ritmo medido llega a 15 min; A recibe los correos de los códigos que no ha pedido; A cambia la clave con su contraseña en cuanto le llega el turno, y C deja de leer |
| P22 | **Lo que hay en `sync.db`** (decisión 2) | no están ni `KL` ni la envoltura interior; con la contraseña de prueba y los dos estiramientos la semilla sale (es el riesgo aceptado, y queda medido el tiempo por intento); el coste por intento del atacante se mide con `hashcat -b -m 8900`, llevado a N = 2^17, y con esa cifra se corrige la tabla de §4 (O11) |
| P23 | **Coste del estiramiento** (§4): cronometrar el scrypt del cliente en la 6,1 y en la 5,1, con la primera compilación y **antes de publicar**; mirar la memoria del proceso; poner la contraseña con el gestor de contraseñas activo | hasta 2 s en la 5,1 (o hasta 1 s en la 6,1 si la 5,1 no está disponible): se queda N = 2^17; si no, N = 2^16 y se corrige §4. La interfaz no se congela; los 128 MiB se devuelven al terminar; el gestor no ofrece guardar la contraseña de la cuenta |
| P24 | **Avalancha de entradas** (N5): más `entrar/empezar` a la vez que núcleos, con emails inventados, durante varios minutos | nunca hay más scrypt en curso que el máximo; la memoria del servicio no pasa del tope; las peticiones de más esperan y a los 25 s reciben «servidor ocupado»; mientras dura, A y B sincronizan y leen eventos sin retraso |
| P26 | **Cambio de email** (§6.5) en A, con la contraseña y un código a la dirección nueva; después, con la contraseña mal | la dirección vieja recibe el aviso y B el evento; un Mac nuevo entra con la dirección nueva y la misma contraseña, y no con la vieja; con la contraseña mal no cambia nada ni sale ningún código |

**Aceptación de la 3.2** (`plan-3x.md` §5.2): todas las pruebas de la tabla en verde en los tres Macs; datos
ilegibles comprobados en ns2; texto de privacidad publicado; la 3.1 no retrocede.

## 13. Para Titín

**Decisiones del 12-11 y dónde han quedado:**

| # | Decisión | Dónde |
|---|---|---|
| 1 | Las 24 palabras siguen siendo la recuperación | §6.6 |
| 2 | Añadir un Mac como en Firefox Accounts, sin aprobación; riesgo de las contraseñas débiles aceptado | §4, §5, §14 |
| 3 | Demora de 14 días para borrar y para «Empezar de cero» | §6.4, §7 |
| 4 | Nunca solo por email | §3.2: con el buzón solo no se hace nada al momento |
| 5 | Textos de «Quitar de la lista» y «Cambiar la clave de sincronización» | §6.3, para su estudio |
| 6 | Sin tope diario de códigos; aviso por correo de cada operación; ritmo y códigos largos | §6.1, §6.2, §10 |
| 7 | Correo 7 días, `sync.db` 30 días, copia en bak cifrada 30 días | §7 |
| 8 | Propuesta nuestra de los papeles legales, con marcadores | [`sync-cuenta-rgpd.md`](sync-cuenta-rgpd.md) |
| 9 | «Unirse con un código» no es opción aparte | §8 |
| 10 | El Mac se identifica por modelo y nombre elegido | §5.1, §7 |
| 11 | «Cuenta y sincronización» | §9 |
| 12 | Correos desde `noreply@` | §7, §10 |
| 13 | Lo que cambia quién controla la cuenta pide algo más que tener el Mac | §6.7 |

**Simplificación del 12-11 por la noche:**

| | Decisión | Dónde |
|---|---|---|
| A | No hay bloqueo de cuenta | §6.2 |
| B | Contraseña obligatoria; no hay código visible. La contraseña se cambia, o se pone nueva si se olvidó, desde un Mac que ya sincroniza con un código por email. Sin ningún Mac, las 24 palabras | §4, §5.1, §6.1 |
| C | Un solo plazo de 14 días | §6.4, §7 |
| D | La copia de bak se borra de verdad a los 30 días | §7 |
| E | No hay espera de 3 días. Riesgo aceptado: Mac desbloqueado + correo = cuenta | §6.3 |

**Lo que he decidido yo al aplicarla, para que lo vea antes de aprobar H1.** Sale de su criterio, pero no lo dijo con
esas palabras:

1. **He quitado los cambios «programados a 14 días»** (§6.7). Eran para quien pedía cambiar la contraseña, el email
   o la clave teniendo solo el Mac, y arrastraban avisos, códigos de cancelación y reglas de quién cancela. Con su
   decisión B, quien olvida la contraseña ya tiene vía directa; el único que los usaría es quien ha olvidado la
   contraseña **y** ha perdido el buzón, que tiene otra salida. La decisión C queda así para el borrado sin ningún
   Mac y «Empezar de cero». Si prefiere conservarlos, vuelven como estaban.
2. **Para cambiar la contraseña no se pide la anterior**, solo el código del email: «cambiar» y «he olvidado» son la
   misma pantalla. Es la lectura literal de B.
3. **Cambiar el email y cambiar la clave de sincronización piden la contraseña**, no un código al correo. Hay que
   teclearla de todos modos, y así el cambio de clave, que es lo que se hace cuando roban un Mac, no depende del
   correo. Quien la haya olvidado la cambia primero.
4. **Los fallos de contraseña avisan en los Macs, no por correo.** Antes proponía además un correo al día.

**Tres consecuencias de lo ya decidido, para tenerlas presentes:**

- **Quien consiga la contraseña y el buzón de un usuario tiene su cuenta y sus datos**, y no hay forma de
  distinguirlo del dueño.
- **Quien tenga un Mac desbloqueado y el correo abierto en él, también.** Un Mac apagado o bloqueado lo protege la
  contraseña de macOS.
- El riesgo aceptado no es solo el robo de la base: **quien controle ns2** ve pasar la clave de entrada y ataca las
  contraseñas con algo menos de coste. Para una contraseña buena no cambia nada; para una floja, sí.

## 14. Revisión de seguridad

**Modelo de amenazas (rehecho el 12-11 por la noche para la versión simplificada):**

| Atacante | Qué consigue | Qué no consigue | Dónde se apoya |
|---|---|---|---|
| Tiene la contraseña y **no** el buzón | nada, ni saber si es correcta; el dueño recibe un código que no ha pedido y un evento en sus Macs | — | §5.1, §6.2, §10 |
| Tiene el buzón y **no** la contraseña | pedir un borrado o un «empezar de cero» a 14 días, que cualquier Mac cancela; **probar contraseñas en línea, unas 96 al día a tope** [S, N4]. Si acierta, pasa a la fila siguiente | entrar; la semilla; cambiar la contraseña (hace falta la cadena); nada al momento; probar sin que se sepa: los Macs avisan desde el primer fallo y él no puede borrar ese aviso | §3.2, §6.2, §6.4, §10 |
| **Tiene la contraseña y el buzón** | **todo: es el dueño.** Entra, recibe la semilla y puede cambiar contraseña, email y clave | pasar inadvertido: evento en todos los Macs y correo (que puede borrar del buzón, no de los Macs) | §5.2, §6.2 |
| Solo sabe el email | agotar durante una hora el cupo de correos de `alta`; mantener a tope (15 min) la espera de la contraseña de esa cuenta y retrasar al dueño al añadir un Mac o al cambiar email o clave; con una avalancha de emails inventados, hacer lento añadir Macs | impedir nada a quien ya sincroniza; impedir cambiar la contraseña ni unir un Mac con las 24 palabras; llenar el buzón del dueño; cerrar nada | §10 |
| Ve tráfico descifrado (proxy que inspecciona TLS, registro con cabeceras) | tokens de sync reutilizables 24 h, como hoy; **y `KL`, con la que puede probar contraseñas sin conexión**; con `KL` y el buzón, entrar | usar un token como prueba de cadena | §3.1, §4 |
| Se lleva `sync.db` | datos cifrados, HMAC de emails, y verificador y envoltura de cada cuenta: **prueba contraseñas sin conexión** pagando los dos estiramientos, y las que acierte le abren los datos de esa cuenta | emails y nombres en claro; contraseñas buenas | §4, §7 |
| Controla ns2 entero | lo anterior más los emails en claro, negar el servicio, y `KL` de quien entre: **ataca las contraseñas pagando solo el estiramiento del cliente**; también puede entregarse a sí mismo la envoltura sin pasar por el buzón | las semillas de quien tenga una contraseña que no se adivine; colar una semilla suya (la envoltura va autenticada) | §4, §5.2 |
| Roba un Mac sincronizado y abre la sesión, **sin el correo** | la semilla: lee y escribe hasta que el dueño **cambie la clave de sincronización**. Puede quitar aparatos de la lista, borrar en todos (las copias locales quedan) y **probar la contraseña**, unas 96 veces al día y con aviso en los demás Macs [S, N4]; insistiendo, retrasar al dueño (§6.7) | cambiar la contraseña, el email o la clave; quedarse la cuenta; seguir leyendo tras el cambio de clave; volver a entrar | §6.3, §6.7 |
| Roba un Mac abierto **con el correo abierto** | **la cuenta**, si llega antes que el dueño: pone contraseña nueva y cambia clave y email. **Riesgo aceptado** [T] | nada con el Mac apagado o bloqueado | §6.3 |
| En la red (sin romper TLS) | nada | — | — |

**Lo que SEGURIDAD no ha visto y conviene que mire en esta versión:**

1. **Los cambios programados, fuera** (§6.7). Con la cadena sola ya no se admite ningún cambio de control. Quita
   N3c y el código de cancelación, y cambia la forma de N1.
2. **Qué pide cada cambio** (§6.7): la contraseña, con cadena y código del email y **sin la contraseña anterior**; el
   email y la clave, con cadena y contraseña.
3. **La espera de la contraseña crece igual con acierto o con fallo en `entrar/empezar`** (§10). En la versión que
   revisó, un acierto la ponía a cero, y eso le decía a quien no lee el buzón que la contraseña era buena. Quien
   tiene la cadena sí lo sabe, porque lee los eventos; para él no cambia el ritmo.
4. **Los límites que quedan escritos** en §6.7 y §10: el ladrón que insiste retrasa pero no cierra; la espera se
   disputa.
5. **Sin correo diario de fallos de contraseña**: el aviso va solo a los Macs.

**Qué queda de cada hallazgo de las cuatro pasadas.** Primera (comentario 6797345699), segunda (6807160010) y
tercera (6820589854), de SEGURIDAD-PORTES-21; cuarta (6834786251), de SEGURIDAD-PORTES-22. Las letras son las suyas.

| Hallazgo | Cómo queda | Dónde |
|---|---|---|
| **B1** código de 30 bits con `id` del servidor | sin objeto desde el modelo de Firefox Accounts: no hay código de aprobación | — |
| **B2** el cambio de contraseña deja a los Macs sin defensa | se mantiene: la prueba de cadena basta para eventos, renovar token y «No he sido yo»; nada se hace solo por email | §3.2, §4.6, §6.2 |
| **B3** el token de go-sync como prueba | se mantiene: prueba propia de un solo uso | §3.1, §8 |
| **C1** el servidor puede colar su semilla | se mantiene: la envoltura va autenticada con una clave que sale de la contraseña | §4.4 |
| **C2** revocar no corta la sincronización | se mantiene: texto honesto y «Cambiar la clave de sincronización» | §6.3 |
| **C3** «Empezar de cero» borraba al momento | se mantiene, a 14 días | §6.4 |
| **C4** códigos adivinables; bloqueo por fallos | 40 bits siempre, ritmo, sin cierre (decisión 6) | §6.1, §10 |
| **C5** correo masivo; CORS | se mantiene | §10 |
| **C6** email fuera de la columna cifrada; art. 30, 28, 33 | se mantiene; plazos decididos y propuesta legal aparte | §7 |
| **O1**, **O2**, **O3**, **O9**, **O10** | se mantienen | §4.8, §10, §7, §5.1, §6.4 |
| **O4**, **O5**, **O7** (peticiones, `info` de HPKE, guardar el blob) | sin objeto: no hay peticiones ni HPKE | — |
| **O6** cambio de email | se mantiene, con nueva envoltura y con la contraseña | §6.5 |
| **O8** nonces | variante sin estado, aceptada en la tercera pasada | §3.1 |
| **N1** un Mac robado se queda con la cuenta | se mantiene, más simple: con la cadena sola no se cambia nada de la cuenta, ni al momento ni programado | §6.7, P21 |
| **N2** 60 altas falsas dejan a todos sin códigos | se mantiene | §10 |
| **N3a** topes que el ladrón puede gastar | se mantiene: nada se cierra por fallos | §6.7, §10, P17, P21 |
| **N3b** avisos que se pueden quedar sin enviar | se mantiene: sin cupo y en cola propia. El código de cancelación desaparece con los cambios programados | §10, P18 |
| **N3c** dueño con contraseña y buzón, sin cadena | sin objeto: no hay nada que cancelar; contraseña y buzón dan la cadena | §3 |
| **N4** la contraseña se puede adivinar en línea sin que nadie se entere | se mantiene: evento en los Macs al acertar y resumen de fallos; tope de 15 min; misma espera exista o no la cuenta, con `email_hmac`. La espera por credencial (N4.2) queda sin objeto: solo hay una credencial | §5.1, §6.2, §10, P5, P21 |
| **N5** el tope global de entradas lo agota cualquiera | se mantiene: semáforo de scrypt con cola de 25 s y tope de memoria | §10, P24 |
| **E** Mac robado con el correo abierto | **descartada por Titín**; riesgo aceptado | §6.3 |
| Código visible (prefs, vida de 24 h) | sin objeto: no hay código visible | — |
| `KE`, `KL` y `KU` en memoria | se mantiene: `OPENSSL_cleanse`, sin prefs ni registro; SEGURIDAD lo mirará en el código de H3 | §11 |
| `KL` en el servidor | aceptado para la 3.2; un PAKE queda como deuda para una `v2` | §4 |
| **O11** unidades de la tabla de aguante | se mantiene: el coste por intento es un supuesto que se mide en P22 | §4, P22 |
| **O12** sal sacada del email | se mantiene, con un matiz (abajo) | aquí |
| **1B** clave corta en el servidor | descartada por la decisión 1 | §6.6 |

**Cálculo por adelantado** [S, O12]: como la sal del estiramiento del cliente sale del email, quien apunte a una
dirección concreta puede calcular **antes** de robar la base los `KL` de un diccionario para ese email, y después
del robo pagar solo el 2^14 del servidor por candidata. El coste total es el mismo; cambia cuándo se paga, y que
el ataque tras el robo sea rápido. **Matiz mío:** SEGURIDAD dice que cambiar la contraseña invalida ese trabajo,
y solo es así si la nueva no está en el diccionario, porque la tabla depende del email y no de la contraseña
anterior. Lo que la invalida del todo es cambiar el email. En la `v1` no tiene arreglo sin pedir al servidor una
sal antes de entrar, que delataría qué emails tienen cuenta; queda, con el PAKE, como deuda para una `v2`.

**Los cuatro puntos que SEGURIDAD avisó que miraría** (buzón de COORDINACIÓN-39, 12-11, 10:54):

| Punto | Cómo queda | Dónde |
|---|---|---|
| 1. KDF de la envoltura y su coste con la base robada; parámetros y tiempo en la 5,1 | scrypt N = 2^17, r = 8, p = 1 en el cliente y N = 2^14 en el servidor; cada intento paga los dos y 128 MiB; tabla de aguante por fuerza de contraseña. **El tiempo en la 5,1 es un cálculo (0,5 a 1,5 s), no una medida:** queda como puerta P23 antes de publicar, con la regla para bajar a 2^16 | §4 «Coste del estiramiento», P23 |
| 2. Separar la clave de autenticación de la de envoltura | `KL` (= `authPW`) y `KU` (= `unwrapBKey`) salen de `KE` por HKDF con etiquetas distintas; al servidor solo llega `KL`, que no abre nada | §4.3, §5.2 |
| 3. Cambio de contraseña sin perder datos | se vuelven a envolver 32 bytes; los datos no se tocan; comprobación antes de enviar, transacción única y llamada repetible | §4.6 |
| 4. Mac robado: qué puede el ladrón y cómo lo corta el dueño | tabla resumen; el corte es «Cambiar la clave de sincronización» con la contraseña; avisos por evento y correo. El Mac robado con el correo abierto es riesgo aceptado | §6.3, §6.7, P16, P21 |

**Lo que este documento no cubre:** el texto legal definitivo (W2, revisión legal), la implementación en Go y en
C++, Android/iOS, y cualquier migración de datos del servidor (no hay: tablas nuevas).

## 15. Fuentes y límites

Código: `brave-core` rama `flyweb` (`components/brave_sync/crypto/*`, `brave_sync_prefs.cc`,
`components/sync/service/brave_sync_auth_manager.cc`, `brave_sync_service_impl.cc`, `browser/ui/webui/settings/brave_sync_handler.cc`,
`browser/infobars/brave_sync_account_deleted_infobar_delegate.*`); `FlyWeb/servidor/sync/{README.md,main.go,sqlite.go,cache.go,instalar-ns2.md}`;
BoringSSL del árbol 156, comprobado el 12-11 (`evp.h:718` `EVP_PBE_scrypt`; `hkdf.h:35` `HKDF`; `aead.h:122`
`EVP_aead_aes_256_gcm`).

Documentos: `plan-3x.md` §5, `TAREAS.md:281` (F7.7), `DIRECTIVAS.md` («Sync con cuenta de la 3.2», 12-11, y su
«Simplificación», #962, leída en `main` el 12-11), `coordinacion.md:136,265-269`,
`parches/3.0.2-sync-ajustes/README.md`, `web-flyweb.md` §2, `docs/SERVIDOR.md:13`; buzón
`buzon/ARQUITECTURA/20261112-{1003,1017,1020,1054}-COORDINACION-39-*.md` y
`20261112-{2015,2246}-COORDINACION-40-*.md`; revisiones de SEGURIDAD-PORTES-21 (PR #905, comentarios 6797345699,
6807160010 y 6820589854) y cuarta pasada de SEGURIDAD-PORTES-22 (comentario 6834786251, leído entero el 12-11); de la
primera salen los datos sobre `auth/auth.go` de go-sync, que no he vuelto a comprobar.

**onepw:** «Firefox Accounts: onepw protocol», Mozilla,
<https://mozilla.github.io/ecosystem-platform/explanation/onepw-protocol>, leída el 12-11-2026 (la página dice que su
última revisión de fondo es de 2014). De ahí sale todo lo marcado [V] en la tabla de §4: PBKDF2 de 1000 vueltas con
el email como sal, `authPW` por HKDF, scrypt «64k/8/1» en el servidor, `wrap(wrap(kB))`, la falta de MAC en
`wrap(kB)`, la pérdida de los datos de clase B al olvidar la contraseña y su análisis de seguridad (ataque «difícil»
con la base robada, «fácil» para quien ve el tráfico o controla el servidor). **No he podido comprobar** qué
estiramiento usa Mozilla hoy: la página de su versión 2 no está en esa dirección, y no lo cito.

**Coste de scrypt:** `third_party/boringssl/src/crypto/evp/scrypt.cc` del árbol 156, leído el 12-11 (versión
escalar, líneas 46-137; `SCRYPT_MAX_MEM` de 65 MiB, línea 150; comprobación de memoria, 173-177). CPU de la 5,1:
`docs/TAREAS.md` FS.25 (Xeon E5620, comprobado por Titín el 29-10) y `docs/entorno-mojave.md:9`.

**Límites:** no se ha medido el coste de scrypt en la 6,1 ni en la 5,1: lo de §4 es un cálculo sobre el código, y la
cifra de 2009 del autor de scrypt está citada de memoria; las cifras de aguante de §4 y las probabilidades de §6.1
son cuentas mías. No se ha probado nada contra ns2. La unidad de la tabla de aguante (0,3 s por intento) es un
supuesto hasta P22, y el artículo de Alwen y otros lo cito por SEGURIDAD, sin releerlo. SEGURIDAD revisó el diseño en
`bb75d529`; **esta versión simplificada no la ha visto**, y los cinco puntos de §14 son los que más cambian.
