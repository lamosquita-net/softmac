# FlyWeb 3.2 — sincronización con cuenta (F7.7): diseño

ARQUITECTURA, 09-11-2026, por orden de Titín (vía COORDINACIÓN-36). Revisado el 11-11 tras la primera y la segunda
pasada de SEGURIDAD-PORTES-21 (PR #905, comentarios 6797345699 y 6807160010). **Rehecho el 12-11** por dos motivos:

- **Decisiones de Titín del 12-11** (`docs/DIRECTIVAS.md`, «Sync con cuenta de la 3.2»; buzón de COORDINACIÓN-39): un
  Mac se añade con el **modelo de Firefox Accounts** (protocolo «onepw» de Mozilla), **sin aprobación desde otro
  Mac**. Cambian §3 a §7 y lo que cuelga de ellos. El resumen de qué cambia está en §13.
- **Tercera pasada de SEGURIDAD** (comentario 6820589854): aprobable para H1 sobre el diseño anterior, con N3 por
  corregir. N3 está aplicado aquí (§6.7, §10), adaptado al modelo nuevo.

Ampliado el mismo 12-11 con los cuatro puntos que SEGURIDAD avisó que miraría (buzón de las 10:54; tabla en §14):
coste del estiramiento y puerta de medida (§4, P23), separación de claves (§4.3), cambio de contraseña (§4.6) y Mac
robado (§6.3).

**Cuarta pasada de SEGURIDAD** (SEGURIDAD-PORTES-22, comentario 6834786251, sobre `bb75d529`): **aprobable para H1,
sin bloqueantes.** Sus correcciones para antes de H2 están aplicadas aquí: N4 (§6.2, §10), N5 (§10) y los opcionales
O11 y O12 (§4, §14). La propuesta E queda preparada en §6.8 y **no está en vigor** hasta que Titín la confirme.

Solo papel: nada compilado ni probado. **Propone; decide Titín.** Antes de H2 faltan las confirmaciones de §13, y
hasta entonces, ni una línea de código.

Marcas: **[V]** visto en el código o en los documentos citados; **[I]** inferido; **[P]** propuesta mía; **[S]**
propuesta de SEGURIDAD adoptada; **[T]** decisión de Titín del 12-11. Sin datos personales de nadie.

## 1. Resumen

- **La cuenta envuelve la cadena; la cadena no cambia.** Hoy una cadena de sync es una semilla de 32 bytes que vive
  solo en los Macs del usuario; de ella salen las 24 palabras, la clave de firma Ed25519 con la que el navegador se
  identifica ante ns2 y la clave con la que cifra los datos [V]. Todo eso sigue igual. Encima va una **cuenta** cuyo
  papel es **llevar la semilla a un Mac nuevo sin teclear 24 palabras**.
- **Un Mac nuevo entra con email + contraseña + código por email, y nada más** [T]. La semilla está en el servidor
  **cifrada con una clave que sale de la contraseña**, estirada en el Mac; el servidor no ve ni la contraseña ni la
  semilla (§4, §5). Quien no quiera contraseña usa un **código visible** que le enseña un Mac ya sincronizado.
- **Lo que se gana:** un viaje y ningún código largo que copiar entre Macs; y quien pierde su único Mac recupera todo
  con email y contraseña, sin las 24 palabras.
- **Lo que se paga, y Titín lo ha aceptado** [T]: quien robe la base de datos puede probar contraseñas sin conexión
  hasta abrir la semilla de las cuentas con contraseña débil. Dos consecuencias más del mismo modelo, que hay que
  tener a la vista: **quien tenga la contraseña y el buzón es el dueño a todos los efectos**, y quien controle ns2
  entero ataca las contraseñas con menos coste que quien solo roba la base (§14).
- **Tres factores: la cadena, la contraseña y el buzón. Con dos se hace todo; con uno, casi nada** (§3.2, §6.7)
  [S, N1 y N3]. La cadena sola sirve para defenderse y deja lo demás programado a 14 días; el buzón solo, para pedir
  empezar de cero a 14 días [T]; la contraseña sola, para nada.
- **Las 24 palabras siguen siendo la clave de recuperación** [T]. Perder todos los Macs, la contraseña y las palabras
  es perder los datos, y la página lo dice.
- **Cada operación sobre la cuenta avisa por correo y en los Macs** [T]. No hay topes diarios que se puedan agotar:
  solo ritmo y códigos largos (§6.7, §10) [T; S, N3].
- **Todo lo nuevo es aditivo:** el protocolo de sync y `flyweb-sync` siguen iguales; las cuentas son rutas y tablas
  nuevas en el mismo binario y el mismo SQLite. La 2.7.x y la 3.0.x siguen sincronizando con palabras contra el mismo
  servidor; los 7 usuarios de hoy no tienen que hacer nada hasta que quieran crear su cuenta.
- **Datos personales en ns2:** el email y el nombre que el usuario ponga a cada Mac [T], los dos cifrados con una
  clave que no está en la base. Sin IP y sin registro de peticiones. Plazos en §7; propuesta de papeles legales en
  [`sync-cuenta-rgpd.md`](sync-cuenta-rgpd.md).
- **Riesgo medio-alto** (`plan-3x.md` §5.2). Criptografía de la que ya trae BoringSSL (scrypt, HKDF, AES-256-GCM,
  Ed25519) [V]; el diseño nuevo **quita** X25519, HPKE y los dos códigos tecleados.

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
| Copia de `sync.db` | prevista en bak, cifrada; hasta hoy sin decidir | `servidor/sync/instalar-ns2.md:154` |

## 3. Modelo: quién tiene qué y qué puede hacer

| Cosa | Usuario | Mac sincronizado | Mac nuevo (antes de entrar) | Servidor (ns2) |
|---|---|---|---|---|
| Contraseña | la sabe | **no la guarda**, ni nada que salga de ella | la teclea | **nunca**: un verificador (§4) |
| Semilla / 24 palabras | las tiene guardadas (clave de recuperación) | sí, en el llavero | **no**, hasta que entra | **nunca en claro**: la envoltura, cifrada con una clave que sale de la contraseña (§4) |
| Datos sincronizados | — | en claro, en el perfil | no | cifrados, ilegibles |
| Email | — | lo guarda (lo enseña la página) | lo teclea | HMAC (para entrar) + cifrado con clave del servidor (para escribirle) |
| Código visible (§5.2) | lo copia de un Mac a otro | lo genera y lo enseña 24 h | lo teclea | un verificador y otra envoltura, 24 h |
| Token de aparato (§10) | — | sí, en el llavero | sí, tras entrar | hash |

**Los tres factores:**

- **La cadena:** tener la semilla. La tiene cualquier Mac sincronizado y quien tenga las 24 palabras.
- **La contraseña:** solo en la cabeza del usuario (o en su gestor). El Mac no la guarda, y por eso distingue al
  dueño de quien le roba el Mac.
- **El buzón:** poder leer un código enviado al email de la cuenta.

**Contraseña + buzón dan la cadena** (es lo que ha decidido Titín): con los dos se entra y se recibe la semilla. Así
que «dos de tres» significa, en la práctica, la cadena más uno de los otros dos, o los otros dos juntos.

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

### 3.2 Qué abre cada cosa

| Operación | Solo la contraseña | Solo el buzón | Solo la cadena | Dos de tres |
|---|---|---|---|---|
| Crear la cuenta | — | sí: código al email (y prueba de cadena si liga una cadena que ya existe) | — | — |
| **Añadir un Mac** (recibir la semilla) | **no** (ni saber si es correcta) | **no** | ya la tiene | **contraseña + código por email**; o código visible + código por email (§5) |
| Leer eventos; renovar su token; quitar un aparato de la lista; generar un código visible | — | — | sí | sí |
| «No he sido yo»; cancelar un borrado pedido por email; borrar la cuenta y los datos en todos, al momento | — | — | sí | sí |
| **Poner o cambiar la contraseña; cambiar el email; cambiar la clave de sincronización** | no | no | **solo programado a 14 días**, cancelable | sí, al momento |
| Cancelar una de esas operaciones programadas | no | no | **no** | sí |
| Pedir «Empezar de cero» o el borrado de la cuenta sin tener ningún Mac | — | sí, **con demora de 14 días** [T] | — | — |

Cuatro conclusiones del modelo:

1. **Con la contraseña sola no se hace nada**, y con el buzón solo, únicamente pedir un borrado que cualquier Mac del
   usuario cancela. Nunca se hace nada al momento solo con el email (decisión 4 de Titín, que se mantiene).
2. **Con un Mac robado** (la cadena sola) se leen los datos hasta que el dueño cambie la clave, pero no se toma la
   cuenta: al ladrón le falta el segundo factor, y lo que programe lo cancela el dueño.
3. **Con contraseña y buzón se es el dueño.** Es el modelo de Firefox Accounts y es lo decidido; el diseño anterior
   lo impedía con la aprobación desde otro Mac. La defensa que queda es enterarse (avisos) y adelantarse (§6.2).
4. **Ya no hay sesiones «sin cadena».** En el diseño anterior, quien entraba con contraseña y buzón quedaba a la
   espera de aprobación; ahora, quien entra recibe la semilla. Eso simplifica el servidor y deja sin función el
   estado «cuenta bloqueada» (§6.2).

## 4. Punto 1: claves. La contraseña envuelve la clave de la cadena

**Objetivo (COORDINACIÓN-30 y decisión 2 de Titín):** la contraseña se transforma en el cliente; el servidor guarda
un verificador y la semilla envuelta, y no puede abrirla sin adivinar la contraseña.

1. **Normalizar** el email (minúsculas, sin espacios, NFC) y la contraseña (NFC). Longitud mínima de contraseña: 10.
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
   la contraseña o el email, ni con el código visible. Recibe `KL` y la envoltura `E`; para abrir `E` hace falta
   `KU`, y a `KU` solo se llega adivinando la contraseña y pagando el estiramiento del paso 2.
4. **Envoltura** (la calcula un Mac que tiene la semilla): `E = AES-256-GCM(KU, nonce aleatorio de 96 bits, semilla,
   dato asociado = "flyweb-envoltura-v1" ‖ SHA-256(email))` (`EVP_aead_aes_256_gcm` [V]). Lleva autenticación: una
   envoltura cambiada, o hecha por quien no sabe la contraseña, **no abre**. Esto sustituye al «código de
   confirmación» del diseño anterior: el servidor no puede colar una semilla suya.
5. **Estiramiento en el servidor:** `KS = scrypt(KL, sal_servidor (16 bytes aleatorios por cuenta), N = 2^14, r = 8,
   p = 1)`, y de `KS`, con HKDF, el **verificador** `V` y una clave `KW`. El servidor guarda `sal_servidor`, `V` y
   `EE = AES-256-GCM(KW, E)`: la envoltura va **envuelta otra vez**. Al entrar, compara `V` en tiempo constante, abre
   `EE` con `KW` y entrega `E`; no guarda ni `KL` ni `KW` ni `E`.
6. **Cambiar la contraseña** es volver a envolver: el Mac (que tiene la semilla) calcula `KE`, `KL` y `KU` nuevos y
   manda `KL` nuevo y `E` nueva en una sola llamada; el servidor genera `sal_servidor` nueva y sustituye `V` y `EE`
   a la vez. **Solo se recifran 32 bytes; los datos sincronizados no se tocan**, así que cambiarla no puede perder
   datos. Se invalidan los tokens de los demás aparatos, que sacan otro con la prueba de cadena y reciben el aviso de
   §6.2 [S, B2]. Cambiar la contraseña **no echa** a quien ya recibió la semilla: para eso está §6.3.
   Tres seguros para que un cambio a medias no deje la cuenta sin una envoltura válida [P]:
   - **antes de enviar**, el Mac abre la `E` nueva con la `KU` nueva y comprueba que sale su semilla;
   - el servidor sustituye `sal_servidor`, `V` y `EE` en **una sola transacción** de SQLite: vale la contraseña
     vieja o la nueva, nunca ninguna de las dos;
   - si la respuesta se pierde, el Mac repite la misma llamada, y el servidor contesta lo mismo si ya la aplicó.

   Y aunque todo eso fallara, la semilla sigue en cada Mac sincronizado y en las 24 palabras: lo peor que puede pasar
   es tener que poner la contraseña otra vez desde un Mac.
7. **Contraseña olvidada** (detalle en §6.1): **se recupera con un Mac sincronizado o con las 24 palabras**, porque
   con la cadena y el buzón se pone una contraseña nueva y se envuelve de nuevo. Sin Mac y sin palabras no hay nada
   que abra la envoltura: los datos se pierden y solo queda «Empezar de cero». El email por sí solo **no cambia la
   contraseña**.
8. **Respuestas iguales exista o no la cuenta** [S, O1]: las llamadas sin sesión contestan lo mismo y tardan lo mismo;
   para un email desconocido el servidor calcula un scrypt de relleno y aplica **la misma espera** por fallos
   (§10) [S, N4].

**Comparación con «onepw» de Mozilla** (fuente en §15; lo que no dice esa página no lo afirmo):

| | onepw (Firefox Accounts) [V en la página] | FlyWeb [P] | Por qué |
|---|---|---|---|
| Estiramiento en el cliente | PBKDF2, 1000 vueltas, con el email como sal | scrypt N = 2^17 (128 MiB) | En onepw, quien ve lo que llega al servidor ataca a 1000 vueltas por intento («fácil», dice la propia página). El nuestro es mucho más caro por intento |
| Lo que viaja | `authPW`, derivada con HKDF | `KL`, igual | — |
| Estiramiento en el servidor | scrypt «64k/8/1» sobre `authPW`, con sal aleatoria | scrypt N = 2^14 sobre `KL`, con sal aleatoria | El coste grande ya está en el cliente |
| Clave envuelta | `kB` = XOR de tres valores, **sin MAC**; la sortea el servidor | la **semilla que ya existe**, con AES-256-GCM | La cadena la crea el primer Mac [T]; con autenticación el Mac detecta una envoltura falsa |
| Doble envoltura | sí (`wrapwrapKey`) | sí (`KW`) | Con la base robada, todo intento paga los dos estiramientos. Aquí añade poco (un 12 %), pero es gratis: el servidor ya calcula ese scrypt |
| Segundo paso | las claves no se entregan hasta verificar el email | código por email en cada Mac nuevo | [T] |
| Cambio de contraseña | el cliente abre y vuelve a envolver `kB`; sal nueva | igual | — |
| Contraseña olvidada | se cambia por email y **se pierden los datos** | no se cambia por email; se recupera con la cadena, y sin ella queda «Empezar de cero» | Las 24 palabras son la recuperación [T] |

**Por qué scrypt y no Argon2:** BoringSSL del árbol trae `EVP_PBE_scrypt` y no trae Argon2 [V]; SEGURIDAD lo aceptó.
**Por qué no OPAQUE ni SRP:** evitarían que el servidor vea `KL`, que es justo lo que abarata el ataque a quien
controla ns2 (§14). No los propongo para la 3.2 porque no están en BoringSSL y serían criptografía nueva en el
cliente y en el servidor; si SEGURIDAD lo considera necesario, es el sitio donde cambiarlo.

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
segundo. **Entre medio segundo y segundo y medio en la 5,1**; la 6,1, algo menos. Se paga **una vez por Mac y por
contraseña tecleada**, nunca al sincronizar.

**Puerta de medida, antes de publicar** [P]: los parámetros no se pueden cambiar después sin una versión `v2` y sin
que cada usuario vuelva a teclear su contraseña (se envuelve otra vez, como en §4.6). Así que el número se cierra
con una medida, que es la prueba P23 de §12:

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

Tres matices:

- **La sal sale del email**, así que el trabajo no se comparte entre cuentas: hay que repetirlo por cada una.
- **Con onepw de Mozilla**, el mismo ataque con la base paga 1000 vueltas de PBKDF2 y un scrypt de 2^16: el nuestro
  cuesta algo más del doble por intento. La diferencia grande está en quien **controla el servidor o ve el
  tráfico**: en onepw paga solo las 1000 vueltas («fácil», dice su página); aquí sigue pagando el scrypt de 2^17.
- **Una cuenta sin contraseña** (código visible de 80 bits, §5.2) no tiene este riesgo.

La página lo dirá al pedir la contraseña, con un indicador de fuerza y sin obligar: es la decisión de Titín.

## 5. Punto 2: añadir un Mac

**Objetivo (Titín, 12-11):** email + contraseña (o código visible) + código por email, sin aprobación desde otro
Mac. Sustituye entero al §5 anterior (petición, aprobación con HPKE y dos códigos de 16 caracteres tecleados).

### 5.1 Con contraseña

1. **Mac nuevo:** el usuario teclea email y contraseña. El Mac calcula `KE`, `KL` y `KU` y llama a `entrar/empezar`
   con el email y `KL`.
2. **Servidor:** antes de mirar nada aplica la **espera por fallos** de §10, igual exista o no la cuenta [S, N4]. Si
   la cuenta existe y `KL` es correcta, manda un **código al email** (8 caracteres de base32, 10 min), devuelve un
   identificador de solicitud y **deja un evento en los Macs de la cuenta** («Alguien ha escrito bien tu contraseña
   desde un Mac nuevo», §6.2): quien controle el buzón puede borrar el correo, pero no el evento. Si no, devuelve un
   identificador falso con la misma forma y el mismo tiempo, y no manda nada: **quien no lee el buzón no sabe si la
   contraseña era buena**.
3. **Mac nuevo:** el usuario teclea el código y da un **nombre al Mac** [T] (por defecto, el modelo). El Mac llama a
   `entrar/terminar` con la solicitud, `KL`, el código, el modelo y el nombre.
4. **Servidor:** si todo coincide, devuelve el `cuenta_id`, un token de aparato y la envoltura `E`. **Un solo error**
   para contraseña y código, sin decir cuál falla [S, O9].
5. **Mac nuevo:** abre `E` con `KU`. Si no abre, no activa nada y avisa («La clave recibida no es válida. No se ha
   activado nada.»). Si abre: `SetSeed` con las palabras y se une a la cadena exactamente como hoy. **Olvida la
   contraseña, `KE`, `KL` y `KU`**: en el Mac solo quedan la semilla y el token, como hoy.
6. **Aviso:** correo al email de la cuenta y evento en todos los Macs: «Se ha añadido el Mac «nombre» (modelo). Si no
   has sido tú, …» (§6.2).

Si el Mac nuevo ya tenía datos, elige combinar o sustituir (§9), como antes.

### 5.2 Con código visible, para quien no tiene contraseña

Titín: «email + (contraseña puesta o código visible) + código por email», y «unirse con un código» deja de ser una
opción aparte. **Mi lectura** [I, a confirmar]: la contraseña es opcional, y el código visible es el heredero de las
«palabras con tiempo» de hoy: lo enseña un Mac ya sincronizado y se teclea en el nuevo.

1. **Mac sincronizado:** «Añadir un Mac» genera un código aleatorio de **80 bits**: 16 caracteres de base32 en 4
   grupos de 4 (alfabeto sin I, L, O ni U, sin distinguir mayúsculas). Lo pasa por la misma cadena de §4 (como si
   fuera una contraseña), y sube con prueba de cadena su clave de entrada y su envoltura. Lo enseña en pantalla.
2. **Servidor:** guarda un verificador y una envoltura aparte, **de un solo uso y con 24 horas de vida** [P]. Un
   código vivo por cuenta: uno nuevo anula el anterior.
3. **Mac nuevo:** email + código visible + código por email, por las mismas dos llamadas de §5.1. Al entregarla, el
   servidor borra esa envoltura.

Por qué así: es **un viaje y un solo código** (antes eran dos códigos y, con los Macs en sitios distintos, dos
viajes). Al ser aleatorio y de 80 bits, la base robada no permite adivinarlo, así que **una cuenta sin contraseña no
tiene el riesgo aceptado en la decisión 2**. Y no es otra clave de recuperación: caduca, así que la recuperación
siguen siendo las 24 palabras [T].

Dos límites del código visible:

- **Hay que estar delante de un Mac sincronizado** para verlo. El caso «navegadores en casa, usuario fuera» lo
  resuelve la contraseña; quien no la ponga tendrá que esperar a volver, o llevar las 24 palabras.
- **No cuenta como segundo factor** (§6.7): lo puede generar cualquiera que tenga el Mac, también quien lo ha robado.

**El código visible no tiene espera por fallos** [P; S, N4.2 pedía que fuera aparte de la de la contraseña]. Con
80 bits no hay nada que adivinar en línea, así que no hace falta frenarlo, y sin espera **nadie que sepa el email
puede cerrar esta vía**. La llamada dice qué credencial presenta (contraseña o código visible) y el servidor la
compara solo con ese verificador: decir «código visible» no sirve para probar contraseñas por otra puerta. El Mac
borra el código de sus prefs a las 24 h de generarlo, tenga red o no [S].

### 5.3 Qué ve el servidor y qué se ha perdido

**Ve:** email (HMAC y cifrado), `KL` al entrar (no la guarda), el verificador, la envoltura doble, y modelo, nombre
(cifrado) y fechas de cada aparato. **No ve** la contraseña, `KU`, la semilla ni los datos.

**Lo que protegía la aprobación y ya no hay** (para que la decisión quede con todas sus consecuencias a la vista):

| Antes (aprobación desde otro Mac) | Ahora (modelo de Firefox Accounts) |
|---|---|
| Contraseña + buzón no llegaban a los datos | **Contraseña + buzón son la cuenta entera** |
| ns2 entero no podía obtener la semilla | ns2 entero, o quien robe la base, **ataca las contraseñas sin conexión**; las débiles caen |
| Perder el único Mac sin las palabras = perder los datos | Se recuperan con email y contraseña |
| Dos códigos de 16 caracteres y, a veces, dos viajes | Un paso, como cualquier servicio |

## 6. Punto 3: recuperación y defensa de la cuenta

Qué queda del §6 anterior: **se mantienen** la clave de recuperación (§6.6), «Cambiar la clave de sincronización»
(§6.3), la demora para borrar sin Mac (§6.4, ahora 14 días), y el segundo factor de N1, generalizado a «dos de
tres» (§6.7). **Desaparecen** los dos códigos tecleados, las peticiones pendientes, la recuperación de la contraseña
solo por email, las sesiones sin cadena y, como estado, la cuenta bloqueada (§6.2).

### 6.1 Casos de recuperación

| Situación | Qué hace el usuario | Qué pasa con los datos |
|---|---|---|
| **Olvidé la contraseña, tengo un Mac sincronizado** | «He olvidado la contraseña» en ese Mac → código al email → contraseña nueva. El Mac vuelve a envolver (§4.6) | **Ni se tocan** |
| **Olvidé la contraseña, no tengo ningún Mac, tengo las 24 palabras** | En el Mac nuevo, «Tengo mi clave de recuperación» → teclea las palabras → ese Mac ya tiene la cadena → fila anterior | **Ni se tocan.** Sí: la contraseña se recupera con las 24 palabras |
| **Perdí todos los Macs, recuerdo la contraseña** | Entra con email + contraseña + código (§5.1) | Los recupera todos. Es lo nuevo de este modelo |
| **Perdí todos los Macs, no tengo contraseña ni palabras** | Solo le queda el buzón | **Datos perdidos.** La página lo dice con el texto de Titín y ofrece «Empezar de cero» (§6.4) |
| **Cuenta sin contraseña, perdí todos los Macs** | Las 24 palabras, o nada | Como las dos filas anteriores |
| **Un Mac no puede leer sus claves** (llavero cambiado) | La página lo detecta (`failed_to_decrypt`) y ofrece «Volver a unir este Mac» | Es volver a entrar (§5) o las palabras. Sus datos locales siguen en el perfil; al unirse, §9 decide combinar o sustituir |

**Códigos por email** [T, decisión 6; S, C4 y N3]: todos de **8 caracteres de base32 (40 bits)** y 10 min. **No hay
tope diario ni cierre.** Contra la fuerza bruta: **un intento cada 10 s por solicitud de código**, contado sobre el
identificador que recibió quien lo pidió, de modo que un tercero no gasta los intentos del dueño. Sale a 60 intentos
por código; con el máximo de 5 códigos por hora y cuenta (§10), unos 100 000 intentos en 14 días y una probabilidad de
acierto de 10⁻⁷ [I]. El código de 6 dígitos del diseño anterior desaparece: sin cierre diario se quedaba corto, y
ahora el código de entrada guarda la semilla.

### 6.2 «¿Has sido tú?» y «No he sido yo» [S, B2; T, decisión 6]

**Cada operación avisa** en todos los Macs sincronizados (evento de §10; barra como la de «cuenta borrada» que ya
existe en brave-core [V]) **y por correo**: Mac añadido, contraseña puesta o cambiada, email cambiado, clave de
sincronización cambiada, operación programada o cancelada, borrado pedido. Los Macs leen los eventos aunque su token
esté invalidado, porque la prueba de cadena basta.

**Probar la contraseña en línea también avisa** [S, N4]. Sin cierres, quien tenga el buzón solo, o un Mac robado,
puede probar contraseñas contra el servidor al ritmo de §10. Si acierta con el buzón en la mano, tiene la cuenta
entera, y el correo de aviso lo borra él. Por eso los dos avisos van **a los Macs**, donde no los puede borrar:

- **Contraseña acertada desde un Mac nuevo:** al mandar el código de entrada, evento «Alguien ha escrito bien tu
  contraseña desde un Mac nuevo. Si no has sido tú, cámbiala ya.» El correo del código dice lo mismo: quien recibe
  un código que no ha pedido sabe que alguien conoce su contraseña.
- **Contraseña fallada**, al entrar o como segundo factor: evento con el resumen («N intentos fallidos de contraseña
  desde el día D», y desde qué Mac si venían con prueba de cadena). **El primero, al momento; después, como mucho
  uno por hora y cuenta**, así que el número de avisos está acotado. Por correo, como mucho uno al día [P].

Quien se equivoca al teclear su propia contraseña verá ese aviso en sus otros Macs; es el precio, y es pequeño.

**«No he sido yo»** (con la cadena sola) hace lo inmediato y lleva al remedio:

- Al momento: invalida todos los tokens de aparato, anula el código visible vivo y cancela los borrados pedidos por
  email.
- Después, la página guía según el aviso: **cambiar la contraseña** (deja fuera a quien la sabía y aún no había
  entrado), **cambiar la clave de sincronización** (§6.3; deja sin datos nuevos a quien ya entró) y, si el buzón no
  es de fiar, **cambiar el email** (§6.5). Las tres piden segundo factor (§6.7).

**El estado «cuenta bloqueada» desaparece, y es consecuencia de la decisión 2** [P, a confirmar por Titín]. El
bloqueo servía para dejar fuera a quien tenía contraseña y buzón pero no la cadena. Ahora ese intruso recibe la
cadena al entrar, así que:

- si ya entró, tiene los tres factores y desbloquearía igual que el dueño;
- si aún no ha entrado, lo que le cierra la puerta es cambiar la contraseña;
- y dejarlo como estaba daría un arma a quien robe el único Mac de un usuario: bloquear, para que el dueño no pueda
  recuperar sus datos con email y contraseña, que es justo lo que este modelo le promete.

La decisión 4 de Titín («nunca solo por email») **se cumple entera**: con el buzón solo no se hace nada al momento.
Si Titín prefiere conservar el bloqueo tal cual, se puede, con ese coste; lo dejo dicho en §13.

**Límite que hay que decir claro:** contra un intruso con contraseña **y** buzón no hay defensa más que adelantarse.
Tiene lo mismo que el dueño; quien cambie antes la clave, la contraseña y el email se queda la cuenta, y el otro
conserva los datos que ya tenía en sus Macs. Es el mismo límite de Firefox Accounts.

### 6.3 Un Mac perdido o robado: «Cambiar la clave de sincronización» [S, C2]

Todos los Macs de una cadena comparten la misma clave: **quitar un aparato de la lista no le quita la semilla**. Un Mac
robado seguiría sincronizando y leyendo lo que se escriba después. La página no promete lo que no hace:

- **«Quitar de la lista».** Texto: «Este Mac deja de aparecer aquí, pero conserva la clave de sincronización. Si lo
  has perdido o te lo han robado, cambia la clave de sincronización.»
- **«Cambiar la clave de sincronización»** (con la cadena **y segundo factor**, §6.7 [S, N1]): genera una semilla
  nueva, vuelve a subir los datos cifrados con ella, liga la cuenta a la cadena nueva (prueba con la clave vieja y
  con la nueva), **sube la envoltura nueva**, hace `ClearServerData` y desactiva la cadena vieja, y enseña las
  **24 palabras nuevas** para guardarlas. Los demás Macs reciben «La clave de sincronización se ha cambiado desde
  otro Mac» y **vuelven a entrar con email, contraseña y código** (§5); el robado no puede: no tiene ni contraseña
  ni buzón. El servidor guarda 30 días la marca «cadena sustituida» para dar ese aviso en vez de un
  `DISABLED_BY_ADMIN` sin explicación.
- Si el segundo factor fue el código por email (contraseña olvidada), en el mismo paso se pone contraseña nueva. Una
  cuenta sin contraseña sigue sin ella y los demás Macs vuelven con un código visible.
- **Desde un Mac nuevo:** quien perdió su único Mac entra con email y contraseña en otro y cambia la clave al
  momento. Antes necesitaba las 24 palabras.

**Por qué el segundo factor:** el Mac robado también tiene la cadena. Si bastara con ella, el ladrón cambiaría la
clave antes que el dueño. Con el segundo factor solo puede dejar el cambio programado a 14 días; el dueño lo ve en
sus Macs y en su correo, lo cancela y hace el suyo al momento.

**Resumen: qué puede hacer quien roba un Mac y cómo lo corta el dueño.** Vale para un Mac con la **sesión de macOS
abierta**. Con la sesión cerrada no tiene nada: la semilla y el token están cifrados con una clave del llavero
[V, §2], y el llavero se abre con la contraseña de macOS [I].

| El ladrón, con la cadena sola | ¿Puede? | Cómo lo corta el dueño |
|---|---|---|
| Leer lo que ya estaba en ese Mac (contraseñas guardadas, marcadores, historial) | sí; está en el disco | la cuenta no lo remedia: cambiar las contraseñas de las webs guardadas |
| Seguir sincronizando: leer lo nuevo, escribir y borrar; ver las 24 palabras y unir otros aparatos | sí, **hasta el cambio de clave** | **«Cambiar la clave de sincronización»**, al momento, con su contraseña o con un código a su email |
| «Borrar en todos» | sí, al momento | no se impide (§6.7); cada Mac conserva su copia local y el dueño vuelve a crear cadena y cuenta |
| Cambiar la contraseña, el email o la clave | **solo programado a 14 días**, con aviso en los Macs y por correo | lo cancela con dos de tres (§6.7); el aviso lleva su código |
| Hacer al momento cualquiera de esas tres; cancelar las del dueño; cerrarle el paso a fuerza de fallos; volver a entrar tras el cambio de clave | **no** | — |

**Lo que hace el dueño, por orden:** (1) desde otro Mac, o desde uno nuevo con email, contraseña y código,
**cambia la clave de sincronización**; el Mac robado deja de leer en ese momento y no puede volver a entrar. (2)
Guarda las 24 palabras nuevas. (3) Cambia las contraseñas de las webs que estaban guardadas en el Mac robado. No
necesita cambiar la contraseña de la cuenta: el Mac no la guarda (§11).

**Cómo se entera:** del robo, por sí mismo; de lo que haga el ladrón, por el evento en sus otros Macs y por el
correo, que no se descartan (§6.2, §6.7).

**Límite: el Mac robado y abierto suele tener también el correo** [I]. Con Mail o el webmail con la sesión iniciada,
el ladrón tiene el buzón: son dos de tres, y con la regla de §6.7 cambia la contraseña, el email y la clave **al
momento**. Lo único que ese Mac no tiene es la contraseña de la cuenta. Hoy el diseño trata contraseña y buzón como
segundos factores iguales, y en este caso no lo son.

**Propuesta E** [P; SEGURIDAD recomienda adoptarla en la cuarta pasada; la decide Titín, §13]: en las cuentas **con
contraseña**, el código por email deja de valer como segundo factor al momento y la contraseña manda. El dueño, que
sabe la contraseña, entra desde otro Mac, cancela y cambia la clave al momento; el ladrón, con el Mac y el correo,
no puede adelantarse. Está escrita entera en **§6.8** y **no está en vigor** hasta que Titín la confirme.

### 6.4 «Empezar de cero» y borrar sin ningún Mac [S, C3; T]

Con el buzón solo (sin Mac, sin palabras, sin contraseña) **no se borra nada al momento**. La cadena nueva se crea en
el acto en ese Mac (semilla nueva, palabras nuevas que hay que guardar) y sincroniza como una cadena sin cuenta; el
**borrado de la cadena vieja y el cambio de ligadura esperan 14 días** [T], con correo y evento a los Macs de la
cadena vieja, que pueden cancelarlo con la cadena sola. Es la misma demora que el borrado de la cuenta de §7.

Si un Mac lo cancela, no se puede volver a pedir hasta pasados 30 días [S, O10]: sin ese tope, quien tenga el buzón lo
repetiría sin fin. **Límite** [I]: por lo mismo, quien tenga un Mac robado puede impedir que un dueño que solo
conserva el buzón libere su dirección. Ese dueño no pierde datos (ya los había perdido) y puede abrir cuenta con
otra dirección; lo apunto para la cuarta pasada.

### 6.5 Cambio de email [S, O6]

Como la sal del estiramiento sale del email, cambiarlo obliga a **volver a envolver**: el usuario teclea la contraseña
y el Mac calcula las claves viejas (que hacen de segundo factor) y las nuevas. Exige **la cadena, segundo factor
(§6.7) y un código enviado a la dirección nueva**; la vieja recibe un aviso y todos los Macs, un evento. Quien no
recuerda la contraseña usa como segundo factor el código al email actual y pone contraseña nueva en el mismo paso.
Con la cadena sola, el cambio queda programado a 14 días (§6.7).

### 6.6 Clave de recuperación [T, decisión 1]

**Las 24 palabras de siempre**, que genera el primer Mac. Se presentan como «Clave de recuperación: guárdala impresa
o en un gestor de contraseñas. Es la única forma de recuperar tus datos si pierdes todos tus Macs y olvidas la
contraseña». La entrada «Tengo mi clave de recuperación» acepta las 24 palabras (`SyncSetupGetPureSyncCode` ya existe
[V]) y también las 25 con fecha que enseña una 2.7.x o una 3.0.x, para poder unir una 3.2 a una cadena que aún no
tiene cuenta [P]. La opción B (clave corta guardada en el servidor) queda descartada.

### 6.7 Dos de tres y operaciones programadas [S, N1 y N3]

Un Mac robado tiene la cadena, igual que el dueño. Lo que no tiene es lo que no está guardado en el Mac: **la
contraseña y el buzón**. Lo que cambia quién controla la cuenta pide uno de los dos.

- **Operaciones de control:** poner o cambiar la contraseña (§4.6), cambiar el email (§6.5) y cambiar la clave de
  sincronización (§6.3). La contraseña entra en la lista porque ahora abre la puerta a los Macs nuevos; «desbloquear»
  sale porque ya no hay bloqueo.
- **Segundo factor:** el `KL` de la contraseña actual, o un **código enviado al email actual** que el Mac pide con
  prueba de cadena. Va dentro del cuerpo que firma la prueba. **El código visible no vale** (§5.2), así que en una
  cuenta sin contraseña el segundo factor es solo el buzón.
- **Sigue bastando la cadena sola** para lo defensivo: leer eventos, renovar el token, «No he sido yo», cancelar un
  borrado pedido por email, quitar aparatos, generar un código visible y borrar en todos al momento. Borrar no pide
  segundo factor porque quien tiene la cadena puede destruir los datos igualmente, borrándolos por la sincronización
  normal [I].
- **Sin cierres que se puedan agotar** [S, N3a y N4; T]: los fallos del segundo factor **no cierran nada**. Códigos:
  un intento cada 10 s por solicitud (§6.1). `KL`: la espera creciente de §10, **con tope de 15 minutos**; es la
  misma que al entrar, y cada fallo sale en el aviso de §6.2. El ladrón y el dueño presentan la misma prueba de
  cadena, así que cualquier cierre lo gastaría el ladrón para dejar fuera al dueño.

**Con la cadena sola:** la operación de control se admite y queda **programada a 14 días** [P: el diseño revisado
decía 7; propongo un solo plazo para todo, el de Titín para el borrado; si se prefiere 7 aquí, es un número].

- **Aviso inmediato, que nunca se descarta** [S, N3b]: evento en todos los Macs («Se ha pedido cambiar la contraseña
  / el email / la clave desde el Mac X. Se hará el día D.») y correo al email actual. Los avisos **no comparten cupo
  con los códigos** y esperan en cola si el servidor de correo no responde (§10).
- **El correo del aviso lleva un código de cancelación** [P]: 16 caracteres de base32 (80 bits), válido hasta el día
  D. Así el dueño que tiene el buzón puede cancelar **sin pedir un código nuevo**, que es lo que el ladrón podría
  estorbar acaparando los 5 códigos por hora. Va **ligado a esa operación**, se guarda como hash y es de **un solo
  uso** [S, condiciones de la cuarta pasada].
- **Cancela quien presente dos de tres** [S, N3c]: la cadena más la contraseña, la cadena más el código de
  cancelación, o contraseña y buzón sin cadena. Este último caso no necesita regla propia: quien tiene contraseña y
  buzón entra desde cualquier Mac (§5), recibe la cadena y cancela. **La cadena sola no cancela:** si bastara, el
  ladrón anularía una y otra vez la operación del dueño.
- **Qué espera en el servidor:** para la contraseña, el verificador y la envoltura nuevos; para el email, la dirección
  nueva ya confirmada con su código, y verificador y envoltura nuevos; para la clave, solo el permiso: el cambio lo
  hace al vencer el Mac que lo pidió. Una operación programada por cuenta y tipo; el permiso caduca a los 30 días de
  vencer.

**Límites que quedan** [I]:

- **Dueño y ladrón con la cadena sola** (el dueño no tiene ni contraseña ni buzón): presentan lo mismo y el servidor
  no los distingue; se cumple lo que se pidió antes. La página lo previene al crear la cuenta y en el aviso de Mac
  perdido. Sus datos siguen en sus Macs y siempre puede abandonar esa cadena y crear otra.
- **Dueño sin contraseña frente a un ladrón insistente:** el ladrón puede acaparar los 5 códigos por hora y retrasar
  una operación al momento del dueño. No puede impedírsela: el dueño cancela lo del ladrón con el código del aviso y
  programa la suya, que el ladrón no puede cancelar. Peor caso, 14 días.
- **Contraseña y buzón en manos de otro:** es el dueño (§6.2).

**Alternativa que no adopto** [P, para SEGURIDAD]: dar ventaja a los Macs antiguos, de modo que un aparato añadido
hace menos de 14 días no pueda hacer operaciones de control al momento ni cancelar las de un Mac antiguo. Frenaría al
intruso con contraseña y buzón, pero también al dueño que acaba de perder su único Mac y quiere cambiar la clave ya
desde uno nuevo. Son dos casos opuestos y el segundo es el que la decisión 2 quiere resolver.

### 6.8 Propuesta E: la contraseña manda sobre el buzón [P; S la recomienda; pendiente de Titín]

**No está en vigor.** Queda escrita entera para que, si Titín la confirma, solo haya que activar lo que dice la lista
del final. Si no la confirma, este apartado se quita y el resto no cambia.

**Por qué:** un Mac robado y abierto suele tener también el correo (§6.3), y con la regla de §6.7 eso son dos de
tres. La contraseña es el único de los tres factores que **no está en el Mac**.

**La regla, solo para las cuentas con contraseña.** Cuanto menos se presenta, más se espera; y una operación
programada solo la cancela quien presenta **más** que quien la programó:

| Quién pide la operación de control | Cuándo se hace | Quién la cancela |
|---|---|---|
| Con la contraseña: cadena + contraseña, o contraseña + buzón entrando desde otro Mac | al momento | — |
| Cadena + código del email, **sin la contraseña** | **a los 3 días** | **solo quien presente la contraseña.** La cadena con un código del email **no** cancela [S]: si cancelara, el ladrón con Mac y correo anularía una y otra vez el cambio del dueño |
| La cadena sola | a los 14 días | quien presente la contraseña, o la cadena con un código del email (vale el del aviso) |

Lo que no cambia:

- **Cuentas sin contraseña:** todo sigue como en §6.7; el buzón es su único segundo factor. Poner contraseña por
  primera vez es al momento, con la cadena y un código del email.
- **Entrar desde un Mac nuevo** (§5): igual.
- **Una operación programada por cuenta y tipo:** se cumple la que se pidió antes.

Lo que cambia para el usuario:

- **Contraseña olvidada** (§6.1, las dos primeras filas): con un Mac o con las 24 palabras, más el código del email,
  la contraseña nueva entra **a los 3 días**. Mientras tanto sus Macs siguen sincronizando y todos reciben el aviso.
- **Cambio de email o de clave sin recordar la contraseña:** también a los 3 días.

**La espera de la contraseña, con E** [P]. Con E la contraseña pasa a ser el único factor que actúa al momento, y
su espera por fallos es una por cuenta (§10): un ladrón con solo la cadena podría ocupar los turnos de 15 minutos y
retrasar al dueño. Para que no pueda, la contraseña presentada **junto con un código válido del email** (cadena +
código + contraseña) se comprueba con una **espera aparte**, que quien no lee el buzón no puede tocar. Quien tenga
Mac y correo dispone de las dos esperas: unos 192 intentos al día en lugar de 96, con los mismos avisos.

**Límites que quedan con E** [S, I]:

- **El dueño olvidó la contraseña y el ladrón tiene Mac y correo.** Presentan lo mismo y el servidor no los
  distingue: se cumple lo que se pidió antes y el otro no puede cancelarlo. El dueño conserva los datos de sus Macs
  y puede abrir una cadena nueva.
- **El dueño olvidó la contraseña y ha perdido un Mac:** cambiar la clave tarda 3 días, y el Mac perdido sigue
  leyendo hasta entonces.
- **El ladrón cambia además la contraseña del buzón:** el dueño se queda con un solo factor.
- **Las cuentas sin contraseña** no ganan nada con E.

**Qué se toca en este documento si Titín la confirma:** §3.2 (la fila de las operaciones de control), §6.1 (las dos
primeras filas), §6.3 (el límite pasa a estar cubierto), §6.5, §6.7 (segundo factor y cancelación), §9 (el estado
`cambio programado` gana el plazo de 3 días), §10 (`FLYWEB_SYNC_DEMORA_BUZON_DIAS=3` y la espera aparte), §12 (P11,
P21 y P25) y §14 (la fila del Mac robado con buzón).

## 7. Punto 4: RGPD y privacidad

**Qué guarda ns2 por cuenta:**

| Dato | Para qué | Cómo | Cuánto tiempo |
|---|---|---|---|
| `email_hmac` = HMAC-SHA256(clave_servidor, email normalizado) | entrar; no repetir cuentas | clave fuera de la base. **Sigue siendo dato personal** (seudonimizado, considerando 26): reduce el riesgo, no saca el dato del RGPD | mientras exista la cuenta |
| `email_cifrado` | mandar códigos y avisos | AES-256-GCM, nonce aleatorio de 96 bits, `email_hmac` como dato asociado [S, O3]; clave en una credencial de systemd (`LoadCredential`), no en la base ni en el repo | mientras exista la cuenta |
| `verificador`, `sal_servidor`, envoltura doble `EE` | comprobar `KL`; entregar la semilla envuelta | §4. **Con la base robada permite probar contraseñas sin conexión** (riesgo aceptado) | mientras exista la cuenta y tenga contraseña |
| lo mismo, del código visible | añadir un Mac sin contraseña | §5.2; código aleatorio de 80 bits | un solo uso; 24 h como máximo |
| `cadena` (= `client_id` de go-sync) | ligar la cuenta con su cadena | seudónimo (clave pública) | mientras exista la cuenta |
| aparatos: `token_hash`, modelo, **nombre**, alta, último uso | listar; decir en los avisos qué Mac ha sido; «N navegadores» en la confirmación de borrado | hash del token, que caduca a los 180 días sin uso [S, O2]. **El nombre es dato personal** [T, decisión 10]: lo elige el usuario, lo ve solo él, y va cifrado como el email [P] | hasta salir en ese Mac, caducar o borrar la cuenta |
| códigos por email: hash, caducidad, último intento | entrar, segundo factor, cancelar | SHA-256; sin contador diario (§6.1) | 10 min; el de cancelación, hasta el día D |
| operaciones programadas: tipo, fecha, lo que espera | §6.7 | verificador, envoltura y email nuevo cifrado | hasta cumplirse o cancelarse; el permiso, 30 días |
| `ultimo_uso` | borrado de inactivas | fecha, sin más | — |
| esperas por fallos de contraseña (§10) | frenar la adivinación en línea | **solo en memoria**, con `email_hmac` como clave; incluye emails **sin cuenta**, porque la espera tiene que ser la misma [S, N4] | 24 h desde el último intento; nunca en disco ni en la copia de bak |

**Dónde más acaba el email** [S, C6; T, decisión 7]:

- **Registro y cola del servidor de correo.** El MTA anota `to=<email>` y guarda la cola. Requisito: retención del
  registro de correo de **7 días** y cola de rebotes vaciada a diario. `flyweb-sync` no guarda copia ni escribe el
  email en su registro.
- **Copia de `sync.db` en bak: sí, cifrada, 30 días** [T]. Propuesta de cómo [P, para SERVIDOR]: se cifra **en ns2,
  antes de salir**, con una clave pública cuya privada no está ni en ns2 ni en bak (la guarda Titín); así bak solo
  tiene un fichero que no puede abrir. Las dos credenciales de systemd (HMAC y AES) **no van en esa copia**: sin
  ellas una base restaurada no sirve para entrar ni para escribir a nadie, así que necesitan su propia custodia.
- **Los 30 días son un borrado de verdad.** La regla de la casa en servidores es mover a cuarentena y que vacíe
  Titín; aquí la cuarentena alargaría el plazo que publicamos. Hace falta que Titín apruebe expresamente esa rotación
  automática como excepción, o que el plazo publicado incluya la cuarentena. Lo señalo; no lo decido.
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
y los avisos), el modelo y el nombre que dé a cada equipo, y, si pone contraseña, esa clave cifrada con su
contraseña: no recibe la contraseña, pero su seguridad depende de que sea difícil de adivinar. El servidor de correo
conserva durante 7 días el registro de los mensajes enviados, y las copias de seguridad, cifradas, se conservan
30 días.» Base legal de la cuenta: **ejecución del servicio que usted solicita** (art. 6.1.b RGPD). Derechos: acceso
y supresión desde la propia cuenta; lo demás, en la dirección de contacto del texto. **No soy abogado:** W2 sigue con
su «revisión legal».

**Si se roba `sync.db`** (cambia con el modelo nuevo): datos cifrados por los navegadores; emails y nombres cifrados
con una clave que no está en el fichero; seudónimos; y, de cada cuenta con contraseña, verificador y envoltura. **Con
eso se prueban contraseñas sin conexión**, pagando los dos estiramientos por intento, y la que se acierte abre la
semilla y, con ella, los datos de esa cuenta que van en el mismo fichero. Es una brecha que hay que tratar como tal
(`sync-cuenta-rgpd.md` §3): avisar a los usuarios para que cambien la contraseña **y la clave de sincronización**.
Además, rotar la clave de cifrado del email y la del HMAC (hay que guardar la versión de clave por fila).

## 8. Punto 5: compatibilidad y transición desde las 24 palabras

- **El protocolo de cadena no cambia.** Mismo `POST /v2/command/`, mismo token, mismo cifrado. La 2.7.x y la 3.0.x
  siguen funcionando contra ns2 sin saber que existen las cuentas; una 3.2 y una 3.0.1 pueden compartir cadena.
- **Crear cuenta desde un Mac ya sincronizado** (el caso de los 7 usuarios): email, código por email y, si quiere,
  contraseña → la cuenta se liga a la cadena existente con la **prueba de cadena** de §3.1 (operación «ligar») y, si
  hay contraseña, el Mac sube la envoltura. **No vale el token de sync** [S, B3]. No se resincroniza nada. Los demás
  Macs de la cadena reciben el evento «Esta sincronización se ha ligado a una cuenta».
- **Crear cuenta en un Mac sin cadena:** crea cadena nueva (semilla local, como hoy «Empezar una cadena») y la liga;
  muestra la clave de recuperación y pide confirmar que se ha guardado antes de seguir.
- **«Unirse con un código» deja de ser una opción aparte** [T, decisión 9]: su sitio lo ocupa el código visible de
  §5.2. Las 24 palabras quedan como clave de recuperación (§6.6), que es también la manera de unir una 3.2 a una
  cadena sin cuenta.
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
→ `sincronizado` (aparatos con su nombre, añadir un Mac, poner o cambiar contraseña, cambiar email, cambiar la clave
de sincronización, salir en este Mac, borrar en todos, ver clave de recuperación) · `claves ilegibles` (volver a
unir) · `cuenta borrada desde otro Mac` · `clave cambiada desde otro Mac` (volver a entrar) · `¿has sido tú?` (barra,
con «No he sido yo») · `borrado programado` (cancelar) · `cambio programado` (contraseña, email o clave a 14 días:
cancelar con contraseña o con el código del aviso) · `sin red` (lo último que se sabía + Reintentar).

Se van los estados `pendiente de aprobación`, `falta confirmar` y `cuenta bloqueada`.

## 10. Servidor

- **Dónde:** el mismo binario `flyweb-sync`, paquete nuevo `cuenta/`, rutas `POST /cuenta/v1/...` montadas junto a
  `/v2`, mismas tablas SQLite más las de §7. Un binario y un fichero, como pidió Titín el 03-10; el vhost de Apache
  solo añade la ruta, y sigue sin pasar la IP.
- **Tres niveles de autenticación** (§3.2): sin sesión; **token de aparato** (32 bytes aleatorios; el Mac lo guarda
  cifrado con OSCrypt; el servidor, su SHA-256; `Authorization: Bearer`; caduca a los 180 días sin uso y se rota al
  cambiar la contraseña [S, O2]), que solo sirve para leer eventos y listar aparatos; y **prueba de cadena** de un
  solo uso (§3.1), sola o con segundo factor (§6.7).
- **Llamadas:** `alta` (email → código), `alta/confirmar` (código, prueba de cadena, y `KL` y envoltura si hay
  contraseña → cuenta, token), `entrar/empezar` (email, `KL` → solicitud y, si procede, código), `entrar/terminar`
  (solicitud, `KL`, código, modelo, nombre → token, envoltura), `nonce`, `visible/crear` (prueba de cadena, `KL` y
  envoltura del código), `segundo-factor/codigo` (prueba de cadena → código al email actual), `contrasena/cambiar`,
  `email/cambiar`, `cadena/cambiar`, `programadas` (listar / cancelar), `aparatos` (listar / quitar / renovar /
  renombrar), `eventos`, `no-he-sido-yo`, `cuenta/borrar` (inmediato con prueba), `cuenta/borrar-por-email` y
  `cuenta/empezar-de-cero` (diferidos), `cuenta/borrar/cancelar`, `salir`.
- **Forma de las peticiones** [S, C5]: solo `Content-Type: application/json` (lo demás, 415) y **ninguna cabecera
  CORS**, para que una web no pueda disparar `alta` desde el navegador de quien la visita.
- **Ritmos, sin cierres** [T, decisión 6; S, N3 y N4]: un intento cada 10 s por solicitud de código; 5 códigos por
  hora y cuenta; un borrado por email cada 30 días por cuenta tras una cancelación [S, O10]. **Ningún contador
  diario y nada que se cierre por fallos.** Sin IP no hay límite por IP: es deliberado (privacidad).
- **Espera por fallos de la contraseña** [S, N4]: tras cada `KL` fallada la espera se dobla (10 s, 20 s, 40 s…)
  **con tope de 15 minutos**; vuelve a cero con un acierto o a las 24 h sin intentos [P]. A tope deja unos 96
  intentos al día; con el tope anterior, de un minuto, eran 1 440.
  - **Una por email y por credencial.** La de la contraseña es la misma en `entrar/empezar` y como segundo factor:
    un intento es un intento, venga por donde venga. El código visible no tiene espera (§5.2).
  - **Igual exista o no la cuenta** [S, N4.4]: la clave de la tabla es `email_hmac`, y la espera se aplica **antes**
    de mirar si hay cuenta y antes de calcular ningún scrypt. Si no, la espera delataría qué emails tienen cuenta
    (O1).
  - **Solo en memoria** [P]: tabla de tamaño fijo, con caducidad a las 24 h. No va a `sync.db` ni a la copia de
    bak, para no dejar en disco el HMAC del email de quien no tiene cuenta. Al reiniciar el servicio las esperas
    vuelven a cero [I: límite menor].
  - Durante la espera el servidor no comprueba nada y contesta cuándo acaba. La página lo dice («Demasiados
    intentos. Podrás volver a probar a las HH:MM.»); el Mac no guarda la contraseña para reintentar solo (§11).
- **Avisos de la contraseña** [S, N4.1]: los dos eventos de §6.2, acierto desde un Mac nuevo y resumen de fallos.
- **Semáforo de scrypt** [S, N5], en lugar del tope global de entradas por minuto, que cualquiera podía agotar con
  emails inventados para que nadie pudiera añadir un Mac:
  - como mucho **tantos scrypt a la vez como núcleos tenga ns2**;
  - las peticiones de más **esperan en cola** hasta 25 s (SEGURIDAD propone unos 30; lo dejo por debajo del límite
    de 30 s del cliente, §9) y, si no les llega el turno, reciben «servidor ocupado»;
  - **tope de memoria explícito:** 16 MiB por scrypt en curso, una cola de longitud fija y `MemoryMax` en la unidad
    de systemd [I: los valores los pone SERVIDOR con los núcleos y la memoria de ns2 a la vista];
  - el scrypt de relleno de los emails sin cuenta pasa por el mismo semáforo;
  - lo que no calcula scrypt (todo lo que va con prueba de cadena y sin contraseña) no pasa por él.
- **Límites conocidos** [I]:
  - **La espera de la contraseña se disputa.** Es una por email, así que quien sepa un email puede mantenerla a tope
    y ocuparle al dueño los turnos de 15 minutos. No cierra nada: al dueño le quedan el código visible, que no tiene
    espera, y las 24 palabras, y quien ya sincroniza no la necesita.
  - **Una avalancha de `entrar/empezar` con emails inventados llena la cola.** Añadir un Mac se vuelve lento y puede
    dar «servidor ocupado» mientras dure; quien ya sincroniza no lo nota. Sin IP, la aplicación no distingue a
    quien inunda. Si hiciera falta un freno por IP, iría delante, en Apache, y es cosa de SERVIDOR [I, no lo
    propongo aquí].
- **Cupos de correo, separados** [S, N2 y N3b]: (1) `alta` a direcciones **sin cuenta**: 20 por hora en total; (2)
  códigos de entrada a **cuentas existentes**: 60 por hora en total y 5 por cuenta, y solo se mandan con `KL`
  correcta, así que quien no sabe la contraseña no gasta este cupo ni llena el buzón de nadie; (3) códigos pedidos
  **con prueba de cadena**: fuera de los topes globales, 5 por hora y cuenta; (4) **avisos**: **sin cupo y nunca se
  descartan**; van a una cola propia y se reintentan si el MTA no responde. Su número queda acotado porque lo que
  se puede pedir con un solo factor está acotado: una operación programada por cuenta y tipo, un borrado por email
  cada 30 días, 10 renovaciones de token por hora, un resumen de fallos de contraseña al día por correo (§6.2), y
  «No he sido yo» no repite aviso si no cambia nada. Aviso en el
  registro al alcanzar cada tope; el contador anónimo de §9 los da por separado.
- **Correo:** por el MTA local del servidor, desde `noreply@` del dominio de FlyWeb [T; I: SERVIDOR confirma SPF y
  DKIM y que el MTA acepta de `DynamicUser`], con el registro de correo a 7 días (§7). Si no hay MTA utilizable, un
  relé en ns1; nunca un servicio de correo de terceros.
- **Configuración:** `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365`, `FLYWEB_SYNC_AVISO_DIAS=30`,
  `FLYWEB_SYNC_DEMORA_DIAS=14`, `FLYWEB_SYNC_CORREO_DESDE`, `FLYWEB_SYNC_CORREOS_HORA=60`,
  `FLYWEB_SYNC_CORREOS_ALTA_HORA=20`, `FLYWEB_SYNC_ESPERA_TOPE_MIN=15`, `FLYWEB_SYNC_SCRYPT_A_LA_VEZ` (por defecto,
  los núcleos), `FLYWEB_SYNC_SCRYPT_COLA_S=25`, y dos credenciales de systemd: clave del HMAC y clave AES (email y nombres),
  con versión.
- **Pruebas:** `go test -race` con los casos de §12 en HTTP contra SQLite; `pruebas/go-sync.sh` sigue pasando (nada de
  go-sync se toca); y, en ns2, siempre desde el propio servidor con `curl --resolve ...:127.0.0.1` (regla de la casa).

## 11. Cliente

- **Página:** la de Sincronización de hoy (`flyweb://settings/braveSync`) pasa a llamarse «Cuenta y sincronización» y
  gana los estados de §9; los manejadores nuevos se suman a `BraveSyncHandler` [V].
- **Criptografía:** scrypt (`EVP_PBE_scrypt`), HKDF (`HKDF`), AES-256-GCM (`EVP_aead_aes_256_gcm`) y Ed25519 de
  BoringSSL, todos en el árbol 156 [V]. Funciones nuevas en `components/brave_sync/crypto`: la firma con dominio de
  §3.1 y la cadena de claves y la envoltura de §4. **Ya no hacen falta X25519 ni HPKE.** Nada nuevo en
  `third_party`; nada que dependa de macOS (vale en Mojave). **No toca** el motor de sync, Nigori ni
  `brave_sync_auth_manager`.
- **Lo que el Mac no guarda nunca:** la contraseña, `KE`, `KL`, `KU`. Se calculan al teclear y se borran de memoria
  al terminar la llamada, con `OPENSSL_cleanse`, sin pasar por ninguna pref ni por el registro [S: lo comprobará al
  revisar el código de H3]. Tampoco se guardan para reintentar tras una espera. De esto depende que la contraseña
  sirva de segundo factor frente a un Mac robado (§6.7).
  Tampoco la guarda el **gestor de contraseñas** del navegador: la página es interfaz propia y no un formulario web,
  así que no debería ofrecerlo [I]; se comprueba en P23.
- **Llamada a scrypt** [V, `scrypt.cc:150-177`]: `EVP_PBE_scrypt` con `max_mem` de 130 MiB; con el valor por defecto
  (65 MiB) falla. Reserva 128 MiB y ocupa un núcleo alrededor de un segundo: va **fuera del hilo de la interfaz**,
  en una tarea del grupo de hilos, y una sola a la vez. La página enseña «Comprobando la contraseña…» mientras dura.
- **Prefs nuevas** (cifradas con OSCrypt como la semilla): token de aparato, id y email de la cuenta, marca del
  último evento leído, y el código visible mientras esté vivo (se borra a las 24 h, §5.2). Todas con el mismo tratamiento de `failed_to_decrypt`
  que la semilla.
- **Sondeo de eventos:** cada 15 min con sync activa, y al abrir la página; con token y, si el servidor lo rechaza,
  renovándolo con prueba de cadena. Una petición por vez, retroceso exponencial hasta 1 h si falla (regla de la casa:
  nunca en bucle contra ns2).
- **Barras de aviso:** `brave_sync_account_deleted_infobar` [V] como patrón para «Mac añadido», «contraseña
  cambiada», «cambio programado», «borrado programado» y «clave cambiada».

## 12. Hitos y pruebas de aceptación

- **H1 (Titín):** este diseño aprobado. La **cuarta pasada de SEGURIDAD** lo da por aprobable (12-11) y sus
  correcciones están aplicadas; faltan las confirmaciones de §13.
- **H2 (SERVIDOR-LOCAL / SERVIDOR, NUBE para el código Go):** `flyweb-sync` con `cuenta/`, pruebas en verde, instalado
  en ns2 con el procedimiento de `instalar-ns2.md` y probado desde el propio servidor.
- **H3 (MOTOR el código, LOCAL compilar y probar; revisión de SEGURIDAD del código antes):** cliente en la 7,1; después
  en la 6,1; la 5,1 cuando Titín pueda. Se compila cuando la 3.1 esté medida (`plan-3x.md` §5.2).

**Guion de prueba con tres Macs** (contra ns2 real; una cuenta de prueba; cada paso se anota con resultado):

| # | Caso | Pasa si |
|---|---|---|
| P1 | Mac A sincronizado con palabras (3.0.1) crea cuenta con contraseña | la cadena queda ligada con prueba de cadena; hay envoltura en `sync.db`; nada se resincroniza |
| P2 | Mac B nuevo entra con email + contraseña + código por email | B recibe contraseñas y marcadores; A recibe evento y correo «Se ha añadido el Mac «nombre» (modelo)»; en `sync.db` solo hay cifrado |
| P3 | Mac C nuevo entra con **código visible** generado en A | C se une; el mismo código no vale una segunda vez, ni pasadas 24 h (plazo corto en la instancia de prueba) |
| P4 | Contraseña mala; contraseña buena y código malo | con contraseña mala no sale ningún correo y la respuesta es igual que con la buena; el error final es uno solo |
| P5 | «Intruso» con la contraseña y sin el buzón. Después (N4), **20 contraseñas malas seguidas** contra la cuenta y contra un email sin cuenta | no recibe nada; el dueño recibe un código que no ha pedido, con el texto de aviso, y A y B muestran «contraseña acertada desde un Mac nuevo». Con las malas: aviso de fallos en A y en B, el primero al momento y no más de uno por hora; **el ritmo medido** se dobla hasta 15 min y es el mismo para el email sin cuenta; con la espera a tope, entrar con código visible sigue funcionando |
| P6 | Cambio de contraseña en A (tecleando la actual) | B y C sacan token nuevo con prueba de cadena y muestran «¿Has sido tú?»; la contraseña vieja ya no entra; un Mac nuevo entra con la nueva; la sync A–B–C no se corta. «No he sido yo» en B invalida tokens y lleva a cambiar contraseña y clave |
| P7 | «Salir en este Mac» en C | C conserva su perfil; A y B ya no lo listan; el servidor no borra nada |
| P8 | «Borrar en todos» en A | B y C muestran «cuenta borrada desde otro Mac»; `sync.db` sin filas de la cuenta; el contador anónimo sube |
| P9 | En B, cambiar el llavero | estado «claves ilegibles» → «volver a unir» → combinar sin duplicados; luego lo mismo con «sustituir» y comprobar la copia previa |
| P10 | Servidor parado a mitad de cada operación | ningún estado «en curso» pasa de 30 s; mensaje y Reintentar |
| P11 | **Contraseña olvidada:** con un Mac; sin Macs y con las palabras; sin nada | con un Mac: código al email y contraseña nueva, datos intactos; con las palabras: se une y hace lo mismo; sin nada: texto de pérdida y «Empezar de cero» |
| P12 | Inactividad (instancia de prueba con plazos de 1 día) | llega el correo de aviso y luego se borra cuenta, cadena y email |
| P13 | Una 3.0.1 con palabras y una 3.2 con cuenta en la misma cadena | sincronizan entre sí; NetLog solo con `sync.flyweb.lamosquita.net` |
| P14 | **Reutilización** (B3): usar un token de sync capturado como prueba; repetir una prueba ya usada; usarla en otra operación | las tres dan 401 |
| P15 | **Servidor malicioso simulado** (instancia de prueba que entrega una envoltura cambiada, o la de otra semilla) | el Mac nuevo no la abre y no activa nada |
| P16 | **Cambiar la clave de sincronización** (C2) tras «quitar de la lista» a C, desde A con su contraseña | hasta el cambio, C sigue sincronizando (y la página lo avisaba); después, C no lee nada nuevo y ve «clave cambiada»; A enseña palabras nuevas; B vuelve a entrar con email, contraseña y código |
| P17 | **Códigos sin cierre** (decisión 6, N3a): 100 códigos fallidos seguidos | el servidor impone 10 s entre intentos de una solicitud y nunca cierra; los fallos de otra solicitud no retrasan la del dueño |
| P18 | **Correo** (C5, N2, N3b): 21 altas a direcciones distintas en una hora; después, entrar en una cuenta real; después, agotar los 5 códigos de la hora y programar una operación; `alta` con otro `Content-Type` o desde una web | el correo 21 de alta no sale y el registro avisa; el código de entrada **sí** llega; el **aviso** de la operación programada **llega** con los códigos agotados; 415; sin cabeceras CORS |
| P19 | **«Empezar de cero»** solo con el buzón (C3) y borrado diferido | nada se borra en 14 días (plazo corto en la instancia de prueba); A lo cancela |
| P20 | **Rastros del email** (C6) | tras borrar la cuenta, el email no está en `sync.db`; el registro de correo no pasa de 7 días; la copia de bak no se abre sin la clave privada y no hay copias de más de 30 días |
| P21 | **Mac robado** (N1, N3): C, con la cadena sola, intenta cambiar la contraseña, el email y la clave; después intenta cancelar una operación de A; después falla el segundo factor muchas veces, con **20 contraseñas malas seguidas** (N4); por último se usa dos veces un código de cancelación, y en otra operación | las tres quedan programadas a 14 días (plazo corto) con aviso en A, en B y en el correo; A las cancela con su contraseña, y también con el código del aviso; un Mac nuevo que entra con contraseña y buzón las cancela; C no puede cancelar nada; los fallos de C no cierran nada a A, dan aviso de fallos en A y en B (el primero al momento, luego uno por hora) y el ritmo medido llega a 15 min; el código de cancelación vale una sola vez y solo para su operación |
| P22 | **Lo que hay en `sync.db`** (decisión 2) | no están ni `KL` ni la envoltura interior; con la contraseña de prueba y los dos estiramientos la semilla sale (es el riesgo aceptado, y queda medido el tiempo por intento); el coste por intento del atacante se mide con `hashcat -b -m 8900`, llevado a N = 2^17, y con esa cifra se corrige la tabla de §4 (O11); con el código visible caducado no hay nada que atacar |
| P23 | **Coste del estiramiento** (§4): cronometrar el scrypt del cliente en la 6,1 y en la 5,1, con la primera compilación y **antes de publicar**; mirar la memoria del proceso; poner la contraseña con el gestor de contraseñas activo | hasta 2 s en la 5,1 (o hasta 1 s en la 6,1 si la 5,1 no está disponible): se queda N = 2^17; si no, N = 2^16 y se corrige §4. La interfaz no se congela; los 128 MiB se devuelven al terminar; el gestor no ofrece guardar la contraseña de la cuenta |
| P24 | **Avalancha de entradas** (N5): más `entrar/empezar` a la vez que núcleos, con emails inventados, durante varios minutos | nunca hay más scrypt en curso que el máximo; la memoria del servicio no pasa del tope; las peticiones de más esperan y a los 25 s reciben «servidor ocupado»; mientras dura, A y B sincronizan y leen eventos sin retraso |
| P25 | **Solo si Titín confirma E** (§6.8): C, con la cadena y el buzón pero sin la contraseña, pide cambiar la contraseña, el email y la clave; intenta cancelar con la cadena y un código del email; falla la contraseña muchas veces | las tres quedan a 3 días (plazo corto) con aviso; A las cancela con su contraseña; un Mac nuevo que entra con contraseña y buzón las cancela; C no cancela con cadena y código; los fallos de C no retrasan a A cuando A presenta además un código del email |

**Aceptación de la 3.2** (`plan-3x.md` §5.2): P1–P24 (y P25 si Titín confirma E) en verde en los tres Macs; datos ilegibles comprobados en ns2;
texto de privacidad publicado; la 3.1 no retrocede.

## 13. Para Titín

**Decisiones del 12-11 y dónde han quedado:**

| # | Decisión | Dónde |
|---|---|---|
| 1 | Las 24 palabras siguen siendo la recuperación | §6.6 |
| 2 | Añadir un Mac como en Firefox Accounts, sin aprobación; riesgo de las contraseñas débiles aceptado | §4, §5, §14 |
| 3 | Demora de 14 días para borrar y para «Empezar de cero» | §6.4, §7 |
| 4 | Nunca solo por email | §3.2; el bloqueo como estado desaparece: ver A más abajo |
| 5 | Textos de «Quitar de la lista» y «Cambiar la clave de sincronización» | §6.3, para su estudio |
| 6 | Sin tope diario de códigos; aviso por correo de cada operación; ritmo y códigos largos | §6.1, §6.2, §10 |
| 7 | Correo 7 días, `sync.db` 30 días, copia en bak cifrada 30 días | §7 |
| 8 | Propuesta nuestra de los papeles legales, con marcadores | [`sync-cuenta-rgpd.md`](sync-cuenta-rgpd.md) |
| 9 | «Unirse con un código» no es opción aparte | §5.2, §8 |
| 10 | El Mac se identifica por modelo y nombre elegido | §5.1, §7 |
| 11 | «Cuenta y sincronización» | §9 |
| 12 | Correos desde `noreply@` | §7, §10 |
| 13 | Contraseña o código para las operaciones de control: **sigue haciendo falta**, y más que antes | §6.7 |

Sobre la 13: es lo único que impide que un Mac robado se quede la cuenta. Queda como «dos de tres» y ahora cubre
también el cambio de contraseña, porque la contraseña ha pasado a abrir la puerta a los Macs nuevos.

**Lo que necesito que confirme** (por orden de importancia):

- **A. El bloqueo de la cuenta desaparece** (§6.2). No contradice la decisión 4: es consecuencia de la 2. Con el
  modelo nuevo ya no deja fuera a nadie, y sí permitiría a quien robe el único Mac de un usuario impedirle recuperar
  los datos con email y contraseña. «No he sido yo» sigue existiendo y lleva a cambiar contraseña y clave.
  Recomiendo quitarlo, y SEGURIDAD está de acuerdo. `docs/DIRECTIVAS.md` dice hoy «Cuenta bloqueada: solo se
  desbloquea con la cadena o con las 24 palabras»: si Titín confirma, esa directiva la corrige COORDINACIÓN.
- **B. Qué es el «código visible»** (§5.2). Lo he leído como: la contraseña es opcional, y sin ella un Mac
  sincronizado enseña un código de 16 caracteres, de un solo uso y 24 horas, que se teclea en el nuevo junto al
  código del email. Si quería decir otra cosa, cambia solo ese apartado.
- **C. Un solo plazo de 14 días** también para lo que un Mac pide sin contraseña ni buzón (§6.7); el diseño anterior
  decía 7. Recomiendo 14: un número para todo y más margen para cancelar.
- **D. La copia de bak se borra de verdad a los 30 días** (§7): es una excepción a la regla de cuarentena que solo
  puede aprobar Titín.
- **E. Mac robado con el correo abierto** (§6.3; la propuesta entera, en §6.8). Un Mac robado con la sesión abierta
  suele tener también el correo, y entonces el ladrón tiene dos de tres y se queda la cuenta al momento. Propuesta:
  en las cuentas con contraseña, lo que se pida con el código del email y sin la contraseña espera **3 días**, y
  solo la contraseña lo cancela. Coste: quien olvide la contraseña espera 3 días para poner otra, con sus Macs
  sincronizando mientras tanto. Límite que queda: si el dueño ha olvidado la contraseña y el ladrón tiene Mac y
  correo, el servidor no los distingue. **SEGURIDAD recomienda adoptarla; yo también.** Está preparada y no está en
  vigor.

SEGURIDAD está de acuerdo también con B (la lectura del código visible es segura) y con C. D no es una cuestión de
seguridad.

**Dos consecuencias de lo ya decidido, para tenerlas presentes:**

- Con este modelo, **quien consiga la contraseña y el buzón de un usuario tiene su cuenta y sus datos**, y no hay
  forma de distinguirlo del dueño. Antes le habría hecho falta además uno de sus Macs.
- El riesgo aceptado no es solo el robo de la base: **quien controle ns2** ve pasar la clave de entrada y ataca las
  contraseñas con algo menos de coste. Para una contraseña buena no cambia nada; para una floja, sí. Una cuenta
  **sin contraseña** (solo código visible) no tiene ninguno de los dos riesgos.

## 14. Revisión de seguridad

**Modelo de amenazas (rehecho el 12-11 para el modelo nuevo):**

| Atacante | Qué consigue | Qué no consigue | Dónde se apoya |
|---|---|---|---|
| Tiene la contraseña y **no** el buzón | nada, ni saber si es correcta; el dueño recibe un código que no ha pedido y se entera | — | §5.1, §6.2 |
| Tiene el buzón y **no** la contraseña | pedir un borrado o un «empezar de cero» a 14 días, que cualquier Mac cancela; **probar contraseñas en línea, unas 96 al día a tope** [S, N4]. Si acierta, pasa a la fila siguiente | entrar; la semilla; cambiar la contraseña; nada al momento; probar sin que se sepa: los Macs avisan desde el primer fallo y él no puede borrar ese aviso | §3.2, §6.2, §6.4, §10 |
| **Tiene la contraseña y el buzón** | **todo: es el dueño.** Entra, recibe la semilla y puede cambiar contraseña, email y clave | pasar inadvertido: evento en todos los Macs y correo (que puede borrar del buzón, no de los Macs) | §5.3, §6.2 |
| Solo sabe el email | agotar durante una hora el cupo de correos de `alta`; mantener a tope (15 min) la espera de la contraseña de esa cuenta y disputarle los turnos al dueño; con una avalancha de emails inventados, hacer lento añadir Macs | impedir nada a un Mac con la cadena ni a quien tenga las 24 palabras; cerrar la vía del código visible, que no tiene espera; llenar el buzón del dueño; cerrar nada | §5.2, §10 |
| Ve tráfico descifrado (proxy que inspecciona TLS, registro con cabeceras) | tokens de sync reutilizables 24 h, como hoy; **y `KL`, con la que puede probar contraseñas sin conexión**; con `KL` y el buzón, entrar | usar un token como prueba de cadena | §3.1, §4 |
| Se lleva `sync.db` | datos cifrados, HMAC de emails, y verificador y envoltura de las cuentas con contraseña: **prueba contraseñas sin conexión** pagando los dos estiramientos, y las que acierte le abren los datos de esa cuenta | emails y nombres en claro; contraseñas buenas; las cuentas sin contraseña | §4, §7 |
| Controla ns2 entero | lo anterior más los emails en claro, negar el servicio, y `KL` de quien entre: **ataca las contraseñas pagando solo el estiramiento del cliente**; también puede entregarse a sí mismo la envoltura sin pasar por el buzón | las semillas de quien tenga una contraseña que no se adivine, ni las de las cuentas sin contraseña; colar una semilla suya (la envoltura va autenticada) | §4, §5.3 |
| Roba un Mac sincronizado (y abre la sesión) | la semilla: lee y escribe hasta que el dueño **cambie la clave de sincronización**. Con la cadena sola puede quitar aparatos, generar un código visible, borrar en todos (las copias locales quedan), **dejar programado a 14 días** un cambio de contraseña, de email o de clave, y **probar la contraseña como segundo factor**, unas 96 veces al día y con aviso en los demás Macs [S, N4] | hacer al momento ninguna de esas tres; cancelar las del dueño; impedir que el dueño cancele (no hay cierres, el aviso no se descarta y lleva su código); quedarse la cuenta mientras el dueño conserve la contraseña o el buzón; seguir leyendo tras el cambio de clave; volver a entrar | §6.3, §6.7 |
| Roba un Mac **y además** tiene la contraseña o el buzón | lo mismo que el dueño. **El buzón es el caso probable:** un Mac abierto suele tener el correo abierto | — (dos de los tres factores); con la propuesta E de §13, el buzón dejaría de bastar en las cuentas con contraseña | §6.3, §6.7 |
| En la red (sin romper TLS) | nada | — | — |

**Tercera pasada de SEGURIDAD-PORTES-21** (comentario 6820589854) **y decisiones de Titín del 12-11:**

| Hallazgo o decisión | Resolución | Dónde |
|---|---|---|
| **N3a** topes que el ladrón puede gastar | adoptado, y extendido a todos los códigos por la decisión 6: sin cierre diario; un intento cada 10 s por solicitud; espera de `KL` con tope (era de un minuto; N4 lo sube a 15) | §6.1, §6.7, §10, P17, P21 |
| **N3b** avisos que se pueden quedar sin enviar | adoptado: los avisos no tienen cupo, no se descartan y van en cola propia. Además, el aviso lleva un código de cancelación para no depender de pedir otro | §6.7, §10, P18 |
| **N3c** dueño con contraseña y buzón, sin cadena | adoptado como regla de dos de tres. Con el modelo nuevo sale solo: contraseña y buzón dan la cadena | §3.2, §6.7, P21 |
| N3, salida de emergencia («borrar en todos») | ya no hace falta nombrarla como salida: no queda ningún cierre que obligue a usarla. Sigue existiendo | §6.7 |
| **Decisión 2** (modelo de Firefox Accounts) | §5 rehecho; fuera HPKE, X25519, `CA` y `CC`; envoltura autenticada en lugar de `CC` | §4, §5 |
| **Decisión 6** (sin tope diario) | códigos de 8 caracteres en todas partes, también al entrar | §6.1 |
| Bloqueo de la cuenta | propongo retirarlo como estado; lo decide Titín (§13, A) | §6.2 |

**Lo que pregunté a la cuarta pasada** (las respuestas, en la tabla de más abajo):

1. Que el servidor vea `KL` (§4): es lo que abarata el ataque a quien controla ns2. La alternativa es un PAKE.
2. La lectura del código visible y su vida de 24 h (§5.2).
3. Que el Mac no guarde nada derivado de la contraseña (§11): de ahí cuelga todo N1.
4. El código de cancelación dentro del correo de aviso (§6.7): es un secreto de 14 días en un buzón.
5. Los dos límites que dejo escritos: la espera de `KL` por cuenta (§10) y el borrado por email que un Mac robado
   puede cancelar sin fin (§6.4).
6. El Mac robado que tiene también el correo abierto (§6.3) y la propuesta E para cortarlo.

**Cuarta pasada de SEGURIDAD-PORTES-22** (comentario 6834786251, sobre `bb75d529`): **aprobable para H1, sin
bloqueantes.** Da por buenos la separación de claves, la doble envoltura, la envoltura autenticada, el cambio de
contraseña, el código visible, el código de cancelación y la tabla del Mac robado.

| Hallazgo o respuesta | Resolución | Dónde |
|---|---|---|
| **N4** la contraseña se puede adivinar en línea sin que nadie se entere (tope de un minuto: 1 440 intentos al día con el buzón solo o con un Mac robado) | adoptado en sus cinco partes: evento en los Macs al acertar y resumen de fallos (el primero al momento, luego uno por hora); espera por credencial; tope de 15 min al entrar y como segundo factor; misma espera exista o no la cuenta, con `email_hmac` como clave; casos nuevos en P5 y P21 | §5.1, §6.2, §6.7, §10, P5, P21 |
| N4.2, **con una diferencia** [P] | SEGURIDAD pedía una espera aparte para el código visible; lo dejo **sin espera**. Con 80 bits no hay nada que adivinar, y una espera, aunque sea aparte, la puede mantener a tope quien sepa el email. Si SEGURIDAD prefiere la espera aparte, es una línea | §5.2, §10 |
| **N5** el tope global de entradas lo agota cualquiera | adoptado: semáforo de scrypt con cola y tope de memoria. La cola queda en 25 s, por debajo del límite de 30 s del cliente | §10, P24 |
| **E** (Mac robado con el correo abierto) | preparada con las dos precisiones: la cadena con un código del email no cancela lo pedido a 3 días, y el límite que queda está escrito. Añado una espera aparte para la contraseña presentada con un código del email, para que un ladrón con solo la cadena no retrase al dueño. **No está en vigor: la decide Titín** | §6.8, §13, P25 |
| Código de cancelación | ligado a la operación, guardado como hash y de un solo uso; lo comprueba P21 | §6.7, P21 |
| Código visible en las prefs | se borra a las 24 h, con red o sin ella | §5.2, §11 |
| `KE`, `KL` y `KU` en memoria | `OPENSSL_cleanse`, sin prefs ni registro; SEGURIDAD lo mirará en el código de H3 | §11 |
| `KL` en el servidor (mi punto 1) | aceptado para la 3.2; un PAKE queda como deuda para una `v2` | §4 |
| **O11** unidades de la tabla de aguante | adoptado: fuera la cifra de «190 a la vez»; el coste por intento es un supuesto que se mide en P22 | §4, P22 |
| **O12** sal sacada del email | adoptado, con un matiz (abajo) | aquí |
| A, B y C de §13 | SEGURIDAD de acuerdo; D no es de seguridad. Las decide Titín | §13 |

**Límites conocidos que quedan escritos** [I]:

- **Semáforo de scrypt** [S, N5]: una avalancha de entradas con emails inventados no niega el servicio a quien ya
  sincroniza, pero hace lento añadir un Mac y puede dar «servidor ocupado» mientras dure (§10).
- **La espera de la contraseña se disputa** (§10): quien sepa el email puede ocupar los turnos de 15 minutos. Quedan
  el código visible y las 24 palabras.
- **Cálculo por adelantado** [S, O12]: como la sal del estiramiento del cliente sale del email, quien apunte a una
  dirección concreta puede calcular **antes** de robar la base los `KL` de un diccionario para ese email, y después
  del robo pagar solo el 2^14 del servidor por candidata. El coste total es el mismo; cambia cuándo se paga, y que
  el ataque tras el robo sea rápido. **Matiz mío:** SEGURIDAD dice que cambiar la contraseña invalida ese trabajo,
  y solo es así si la nueva no está en el diccionario, porque la tabla depende del email y no de la contraseña
  anterior. Lo que la invalida del todo es cambiar el email. En la `v1` no tiene arreglo sin pedir al servidor una
  sal antes de entrar, que delataría qué emails tienen cuenta; queda, con el PAKE, como deuda para una `v2`.
- **Con E**, los de §6.8.

**Los cuatro puntos que SEGURIDAD avisó que miraría** (buzón de COORDINACIÓN-39, 12-11, 10:54):

| Punto | Cómo queda | Dónde |
|---|---|---|
| 1. KDF de la envoltura y su coste con la base robada; parámetros y tiempo en la 5,1 | scrypt N = 2^17, r = 8, p = 1 en el cliente y N = 2^14 en el servidor; cada intento paga los dos y 128 MiB; tabla de aguante por fuerza de contraseña. **El tiempo en la 5,1 es un cálculo (0,5 a 1,5 s), no una medida:** queda como puerta P23 antes de publicar, con la regla para bajar a 2^16 | §4 «Coste del estiramiento», P23 |
| 2. Separar la clave de autenticación de la de envoltura | `KL` (= `authPW`) y `KU` (= `unwrapBKey`) salen de `KE` por HKDF con etiquetas distintas; al servidor solo llega `KL`, que no abre nada | §4.3, §5.3 |
| 3. Cambio de contraseña sin perder datos | se vuelven a envolver 32 bytes; los datos no se tocan; comprobación antes de enviar, transacción única y llamada repetible | §4.6 |
| 4. Mac robado: qué puede el ladrón y cómo lo corta el dueño | tabla resumen; el corte es «Cambiar la clave de sincronización» con segundo factor; avisos por evento y correo. Queda un límite nuevo a la vista: el correo abierto en el Mac robado | §6.3, §6.7, P16, P21 |

**Hallazgos de la primera pasada** (comentario 6797345699) **y de la segunda** (6807160010). Las letras son las de
SEGURIDAD; lo que el modelo nuevo deja sin objeto se marca así.

| Hallazgo | Resolución | Dónde |
|---|---|---|
| **B1** código de 30 bits con `id` del servidor | **sin objeto**: ya no hay código de aprobación | — |
| **B2** el cambio de contraseña deja a los Macs sin defensa; desbloqueo por email | se mantiene: la prueba de cadena basta para eventos, renovar token y «No he sido yo»; nada se hace solo por email | §3.2, §4.6, §6.2 |
| **B3** el token de go-sync como prueba | se mantiene: prueba propia de un solo uso | §3.1, §8 |
| **C1** el servidor puede colar su semilla | resuelto de otro modo: la envoltura va autenticada con una clave que sale de la contraseña | §4.4 |
| **C2** revocar no corta la sincronización | se mantiene: texto honesto y «Cambiar la clave de sincronización» | §6.3 |
| **C3** «Empezar de cero» borraba al momento | se mantiene, ahora a 14 días | §6.4 |
| **C4** códigos adivinables; bloqueo por fallos | cambia por la decisión 6: 40 bits siempre, ritmo, sin cierre | §6.1, §10 |
| **C5** correo masivo; CORS | se mantiene | §10 |
| **C6** email fuera de la columna cifrada; art. 30, 28, 33 | se mantiene; plazos decididos y propuesta legal aparte | §7 |
| **O1**, **O2**, **O3**, **O9**, **O10** | se mantienen | §4.8, §10, §7, §5.1, §6.4 |
| **O4**, **O5**, **O7** (peticiones, `info` de HPKE, guardar el blob) | **sin objeto**: no hay peticiones ni HPKE | — |
| **O6** cambio de email | se mantiene, ahora con nueva envoltura | §6.5 |
| **O8** nonces | variante sin estado, aceptada en la tercera pasada | §3.1 |
| **N1** un Mac robado se queda con la cuenta | se mantiene y se amplía al cambio de contraseña | §6.7 |
| **N2** 60 altas falsas dejan a todos sin códigos | se mantiene | §10 |
| **1B** clave corta en el servidor | descartada por la decisión 1 | §6.6 |

**Lo que este documento no cubre:** el texto legal definitivo (W2, revisión legal), la implementación en Go y en
C++, Android/iOS, y cualquier migración de datos del servidor (no hay: tablas nuevas).

## 15. Fuentes y límites

Código: `brave-core` rama `flyweb` (`components/brave_sync/crypto/*`, `brave_sync_prefs.cc`,
`components/sync/service/brave_sync_auth_manager.cc`, `brave_sync_service_impl.cc`, `browser/ui/webui/settings/brave_sync_handler.cc`,
`browser/infobars/brave_sync_account_deleted_infobar_delegate.*`); `FlyWeb/servidor/sync/{README.md,main.go,sqlite.go,cache.go,instalar-ns2.md}`;
BoringSSL del árbol 156, comprobado el 12-11 (`evp.h:718` `EVP_PBE_scrypt`; `hkdf.h:35` `HKDF`; `aead.h:122`
`EVP_aead_aes_256_gcm`).

Documentos: `plan-3x.md` §5, `TAREAS.md:281` (F7.7), `DIRECTIVAS.md` («Sync con cuenta de la 3.2», 12-11),
`coordinacion.md:136,265-269`, `parches/3.0.2-sync-ajustes/README.md`, `web-flyweb.md` §2, `docs/SERVIDOR.md:13`;
buzón `buzon/ARQUITECTURA/20261112-{1003,1017,1020}-COORDINACION-39-*.md`; revisiones de SEGURIDAD-PORTES-21 (PR
#905, comentarios 6797345699, 6807160010 y 6820589854) y cuarta pasada de SEGURIDAD-PORTES-22 (comentario
6834786251, leído entero el 12-11; el encargo de aplicarla llegó de COORDINACIÓN-40 por el cartero); de la primera salen los datos sobre `auth/auth.go` de
go-sync, que no he vuelto a comprobar.

**onepw:** «Firefox Accounts: onepw protocol», Mozilla,
<https://mozilla.github.io/ecosystem-platform/explanation/onepw-protocol>, leída el 12-11-2026 (la página dice que su
última revisión de fondo es de 2014). De ahí sale todo lo marcado [V] en la tabla de §4: PBKDF2 de 1000 vueltas con
el email como sal, `authPW` por HKDF, scrypt «64k/8/1» en el servidor, `wrap(wrap(kB))`, la falta de MAC en
`wrap(kB)`, la pérdida de los datos de clase B al olvidar la contraseña y su análisis de seguridad (ataque «difícil»
con la base robada, «fácil» para quien ve el tráfico o controla el servidor). **No he podido comprobar** qué
estiramiento usa Mozilla hoy: la página de su versión 2 no está en esa dirección, y no lo cito.

**Coste de scrypt:** `third_party/boringssl/src/crypto/evp/scrypt.cc` del árbol 156, leído el 12-11 (versión
escalar, líneas 46-137; `SCRYPT_MAX_MEM` de 65 MiB, línea 150; comprobación de memoria, 173-177). CPU de la 5,1:
`docs/TAREAS.md` FS.25 (Xeon E5620, comprobado por Titín el 29-10) y `docs/entorno-mojave.md:9`. Buzón
`buzon/ARQUITECTURA/20261112-1054-COORDINACION-39-sync-fxa-seguridad.md`.

**Límites:** no se ha medido el coste de scrypt en la 6,1 ni en la 5,1: lo de §4 es un cálculo sobre el código, y la
cifra de 2009 del autor de scrypt está citada de memoria; las cifras de aguante de §4 y las
probabilidades de §6.1 son cuentas mías. No se ha probado nada contra ns2. La unidad de la tabla de aguante (0,3 s por
intento) es un supuesto hasta P22, y el artículo de Alwen y otros lo cito por SEGURIDAD, sin releerlo. SEGURIDAD
revisó el diseño en `bb75d529`; **lo añadido después** (N4, N5, §6.8 y las dos diferencias que señalo en §14: el
código visible sin espera y la espera aparte de E) **no lo ha visto todavía**.
