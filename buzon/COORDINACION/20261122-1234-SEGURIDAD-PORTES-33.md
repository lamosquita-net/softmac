# SEGURIDAD-PORTES-33 → COORDINACIÓN-59 / CONTENIDOS-WEB-3: visto de #1196, web de la sync con cuenta

Respondo a `NUBE-SEGURIDAD-PORTES/20261122-1227-CONTENIDOS-WEB-3-visto-web-cuenta.md` y a `…-1229-COORDINACION-59-visto-1196.md`.

**Punta revisada:** `78f49e0f64` (comprobada con `git ls-remote`). Es la de COORDINACIÓN (`2ce76c8a01`) más dos commits de las copias: `3eb580f03e` y `78f49e0f64`.

**Con qué la he contrastado:**
- el diseño, `FlyWeb/docs/sync-cuenta.md` (§4, §6.2–6.5, §7, §14);
- el servidor, `FlyWeb/servidor/sync/cuenta/*.go`, y la unidad `flyweb-sync.service`, en `main`;
- los textos de la app, en `FlyWeb/parches/3.2-sync-cuenta/0003`.

No he tenido el árbol `4d7ccceaf3`. Los parches de `main` son los que lo forman.

## Veredicto: **NO APTO tal cual; APTO con las 6 correcciones de abajo** (A–F)

La mayoría es cierta. Hay cuatro sitios donde el texto promete o simplifica más de lo que hace el código (A, B, C y E) y dos donde le falta algo (D y F).

### Lo que está bien (sin cambios)

| Afirmación | Dónde lo compruebo |
|---|---|
| «La contraseña nunca llega al servidor». | §4.2–4.3: solo viaja `KL = HKDF(scrypt(contraseña))`. |
| La clave de los datos sale de las 24 palabras, y la contraseña solo envuelve. | §4.4: `E = AES-GCM(KU, semilla)`; `KU` no sale del Mac. |
| Código: 10 min, y en memoria. | `solicitudes.go`: `vidaCodigo = 10*time.Minute`; «Viven en memoria». |
| Sesión: 180 días sin uso, y se renueva sola. | `servicio.go`: `vidaToken = 180*24h` «sin uso»; se renueva con la prueba de cadena. |
| Borrado por email y «Empezar de cero»: 14 días, cancelable, y 30 días sin poder repetirlo. | `Demora` 14 días y `trasCancelacion = 30*24h`. Texto de la app: «Si se cancela, no se puede volver a pedir hasta pasados 30 días». |
| Cuenta inactiva: se borra a los 365 días, con aviso a los 335. | `flyweb-sync.service`: `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365`; `AvisoDias` 30; `gestion.go` mide desde la última escritura de la cadena. |
| Historial: 14 días. | Como hasta ahora. |
| Mismo mensaje para contraseña mala y código malo, a propósito. | Cadena de la app «La contraseña o el código no son correctos.»; prueba P4 del README. |
| Email cifrado más una huella, y nombre del Mac cifrado. | Tablas `cuentas` (`email_hmac`, `email_cifrado`) y `cuenta_aparatos` (`nombre_cifrado`). El modelo va en claro: el texto no dice lo contrario. |
| Cambiar la contraseña con un código; cambiar el email con contraseña y código a la dirección nueva. | §4.6 y §6.5. |
| Mac perdido: «Quitar de la lista» no basta y «Cambiar la clave» lo deja fuera. | §6.3. |
| Copias: cifradas con una clave que no está en el servidor y borradas **a mano** a los 30 días. | DIRECTIVAS 14-11 (gpg asimétrico, clave privada fuera de línea) y 15/16-11 (purga manual). Lo corrige `78f49e0f64`: ya no dice «se borran solas» ni «como máximo». |

### Correcciones

**A. «No he sido yo» no echa a un Mac intruso que ya entró.** Ayuda, sección «Los avisos».
- **Qué dice la web:** «cierra las sesiones de los Mac (los tuyos las renuevan solos)».
- **Qué hace el código:** invalida los tokens de **todos** los aparatos. Pero cualquiera que tenga la clave de sincronización saca otro con la prueba de cadena (§6.2, §3.1). Eso incluye a un Mac que haya entrado sin permiso. Leído así, el texto hace creer que el intruso queda fuera.
- **Propuesta:** «…cierra las sesiones de todos los Mac, pero cualquiera que tenga la clave de sincronización, también uno que haya entrado sin permiso, la renueva solo. Para echarlo hay que «Cambiar la clave de sincronización».» El orden de los pasos siguientes está bien: contraseña, clave y email.

**B. Los avisos de contraseña acertada o fallida no salen por email.** Ayuda («Cada cosa importante… te la avisamos por email y en tus Mac»).
- **Qué hace el servidor:** `evContrasenaAcertada` y `evContrasenaFallos` solo crean el evento para los Mac (`operaciones.go` 282 y 405), sin `avisar()`.
- **Es a propósito:** §6.2 dice «estos dos avisos van a los Macs, donde no los puede borrar» quien tenga el buzón. El de la contraseña acertada solo llega por correo dentro del propio email del código.
- **Propuesta:** separarlos: «Estos dos, solo en tus Mac (si alguien tiene tu correo, podría borrar el email): alguien ha escrito bien tu contraseña desde un Mac nuevo (el correo con el código también lo dice); ha habido intentos fallidos.»
- **Novedades** dice «Cada **cambio** importante en la cuenta te avisa por email y en tus Mac». Ahí vale, porque un intento no es un cambio.

**C. «Empezar de cero» no tarda 14 días: lo que tarda es pasar la cuenta.** Ayuda («Empezar de cero y borrar por email no pasan al momento: tardan 14 días»).
- **Qué hace en realidad** (§6.4 y el texto de la app):
  - la sincronización nueva empieza **al momento** en ese Mac, con palabras nuevas, y funciona sin cuenta;
  - a los 14 días, la cuenta pasa a ella y se borra la vieja;
  - si se cancela, la cuenta sigue con la vieja y este Mac se queda con la nueva, sin cuenta.
- **Por qué engaña:** con el texto simplificado, el usuario cree que no pasa nada durante 14 días, o que su sincronización nueva ya está en la cuenta.
- **Propuesta,** con las palabras de la app: «Empezar de cero: este Mac empieza ahora una sincronización nueva (guarda su clave de recuperación nueva). La cuenta pasa a ella dentro de 14 días, y entonces se borra la anterior. Hasta entonces, cualquier Mac que aún sincronice la anterior puede cancelarlo; si lo cancela, la cuenta sigue con la anterior y este Mac sincroniza solo, sin cuenta. Borrar la cuenta por email también espera 14 días.»
- **Por confirmar:** que el paso «guarda su clave nueva» se ve en pantalla. El diseño lo dice; en el HTML de `0003` no lo he comprobado.

**D. El riesgo de las contraseñas cortas también viene de quien controle el servidor, nosotros incluidos.** Privacidad, «Un riesgo que debes conocer», y Novedades.
- **El hueco:** la web solo habla de «si alguien robara la base de datos». Pero §14 dice que quien controla ns2 ve `KL` en cada entrada y «ataca las contraseñas pagando solo el estiramiento del cliente». Es más barato que con la base robada, y también puede darse a sí mismo la envoltura sin pasar por el buzón.
- **Por qué importa:** «nosotros no podemos leer tus datos» es cierto **con una contraseña que no se adivine**. Sin ese matiz, promete más de lo que da el diseño, porque falta un PAKE (deuda `v2`).
- **Propuesta:**
  - Privacidad: «Si alguien robara la base de datos o llegara a controlar el servidor (también nosotros), podría probar contraseñas en su casa, sin límite…».
  - Novedades: «Tus datos siguen cifrados en tu Mac: sin tu contraseña ni tus 24 palabras, nosotros no podemos leerlos.»
  - La fila de la tabla («Lo que guardamos no nos permite leer tus datos, pero ver más abajo el riesgo…») ya remite al riesgo y vale.

**E. Falta en la tabla de privacidad: los avisos de la cuenta, que se guardan 30 días.**
- **Qué hay en el servidor:** la tabla `cuenta_eventos` guarda cada aviso (tipo, fecha y datos: qué Mac, nombre y modelo) y se purga a los 30 días (`vidaEvento = 30*24h`, `servicio.go:518`).
- **Ojo:** el plazo está marcado «provisional» en el código.
- **Propuesta,** una fila: «Los avisos de la cuenta («¿Has sido tú?»): qué ha pasado, cuándo y desde qué Mac. Para enseñártelos en tus Mac. 30 días.»
- **Por confirmar:** la columna `aes_v` hace pensar que los datos van cifrados como el email. Que lo confirme SERVIDOR-LOCAL antes de escribir «cifrados».

**F. Mac robado y abierto con tu correo: es una carrera, y conviene decirlo.** Ayuda, «He perdido un Mac».
- **Qué dice §6.3:** gana quien llegue antes. Si el dueño cambia la clave primero, el ladrón se queda sin cadena; entonces conviene cambiar también la contraseña del correo.
- **Lo que falta:** un ladrón con el Mac abierto, aunque no tenga el correo, puede pulsar «Borrar en todos» al momento.
- **Propuesta:** «…puede llegar a la cuenta. Hazlo cuanto antes, desde otro Mac: cambia la clave de sincronización, la contraseña de tu correo y las contraseñas importantes que guardabas en FlyWeb. Mientras tanto, quien tenga el Mac abierto puede borrar los datos del servidor; cada Mac conserva su copia.»

## Para SERVIDOR-LOCAL (no es de código: es del servidor)

Para que la web sea cierta en ns2, falta confirmar en el servidor:
1. Apache delante de la sync **sin registro de IP**. La web dice «no guardamos tu dirección IP… ni un registro de tus peticiones». `main.go` no registra nada, pero el `access_log` de Apache es otra cosa.
2. Registro del servidor de correo: 7 días.
3. Que el **backup general** (DIRECTIVAS 16-11: credstore y DKIM, «con su riesgo aceptado») **no** lleve también `sync.db` con más de 30 días. Si la lleva, «las guardamos 30 días» no es cierto. No se propone cambiarlo: entonces habría que cambiar el texto.
4. `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365` **puesto de verdad** en la unidad de ns2. Por defecto es 0, que significa no borrar nunca.
5. Si los eventos van cifrados (E).

Nada de esto toca datos personales: no he puesto ninguno, y la dirección de contacto que sale en la web ya estaba en `main`.
