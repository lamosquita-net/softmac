# cuenta — la cuenta de la sincronización (FlyWeb 3.2, hito H2)

Implementa la parte de servidor de [`FlyWeb/docs/sync-cuenta.md`](../../../docs/sync-cuenta.md) (§10), con el modelo
simplificado A–E y las correcciones N1–N6. Va en el mismo binario `flyweb-sync` y el mismo `sync.db`; go-sync no se
toca. **Solo se activa si systemd le da las dos credenciales** (abajo): sin ellas, `flyweb-sync` funciona como antes.

Los huecos del diseño están cerrados en «Decisiones de H2» de `sync-cuenta.md` (§10.1, COORDINACIÓN-41, 13-11).

## Protocolo

Todas las rutas son `POST /cuenta/v1/<ruta>`, con `Content-Type: application/json` (si no, 415), cuerpo de 64 KiB
como mucho y **sin cabeceras CORS**. Los binarios van en base64 estándar salvo `nonce`, `solicitud` y `token`
(base64url sin relleno). Las horas son segundos Unix.

**Prueba de cadena** (§3.1), en cabeceras:

```
X-FlyWeb-Cadena: <clave pública Ed25519 de la cadena, hex> (la misma que el client_id de go-sync)
X-FlyWeb-Nonce:  <lo que dio /nonce> (un solo uso, 5 min)
X-FlyWeb-Prueba: base64(Ed25519(SK_cadena, M))
M = "flyweb-cuenta-v1" ‖ lp("POST") ‖ lp(ruta) ‖ lp(op) ‖ lp(cuenta) ‖ lp(nonce) ‖ SHA-256(cuerpo)
lp(x) = u16(len x) ‖ x
```

`u16` en big endian; `ruta`, la completa que recibe el servicio (`/cuenta/v1/eventos`); `cuerpo`, los bytes exactos
del cuerpo HTTP; `cuenta`, el id de la cuenta que el Mac conoce
(vacío en `alta/confirmar` y `empezar-de-cero/confirmar`; en `eventos` y `aparatos/renovar` se acepta vacío
también, y la cuenta la fija la cadena: S1). Referencia: `FirmarPrueba` en `prueba.go`.

**Token de aparato**: `Authorization: Bearer <token>`; solo sirve para `eventos` y `aparatos/listar`. Caduca a los
180 días sin uso; se invalida al cambiar la contraseña, la clave o con «No he sido yo» (se saca otro con
`aparatos/renovar` y la prueba de cadena).

**Tamaños**: `kl` 32 bytes; `envoltura` 60 bytes (`nonce GCM 12 ‖ semilla cifrada 32 ‖ etiqueta 16`, §4.4); `modelo`
hasta 64 caracteres `[A-Za-z0-9,._ -]`; `nombre` hasta 64 caracteres sin controles; código, 8 de base32 (se aceptan
guion, espacios y minúsculas).

| Ruta | Autenticación | Cuerpo | Respuesta |
|---|---|---|---|
| `nonce` | — | `{}` | `nonce` |
| `alta` | — | `email` | `solicitud` (igual exista o no la cuenta) |
| `alta/confirmar` | prueba `alta`, cuenta vacía | `solicitud codigo kl envoltura modelo nombre` | `cuenta aparato token` |
| `entrar/empezar` | — (espera) | `email kl` | `solicitud` (igual sea buena o no) |
| `entrar/terminar` | — | `solicitud codigo kl modelo nombre` | `cuenta aparato token envoltura` |
| `contrasena/codigo` | prueba `contrasena-codigo` | `{}` | `solicitud` |
| `contrasena/cambiar` | prueba `contrasena-cambiar` | `solicitud codigo kl envoltura [aparato]` | `[aparato token]` |
| `email/cambiar/empezar` | prueba `email-empezar` + contraseña (espera) | `email kl` | `solicitud` (código a la nueva) |
| `email/cambiar/terminar` | — | `solicitud codigo kl envoltura` | `{}` |
| `cadena/cambiar` | prueba `cadena-cambiar` con la vieja **y** `X-FlyWeb-Cadena-Nueva`/`X-FlyWeb-Prueba-Nueva` (mismo nonce) + contraseña | `kl envoltura [aparato]` | `[aparato token]` |
| `aparatos/listar` | token o prueba `aparatos-listar` | `{}` | `aparatos: [id modelo nombre alta ultimo_uso este]` |
| `aparatos/quitar` | prueba `aparatos-quitar` | `aparato` | `{}` |
| `aparatos/renovar` | prueba `aparatos-renovar` | `aparato`, o `modelo nombre` para darse de alta (Mac unido con las 24 palabras; avisa) | `cuenta aparato token` |
| `aparatos/renombrar` | prueba `aparatos-renombrar` | `aparato nombre` | `{}` |
| `eventos` | token o prueba `eventos` (si vienen las dos, cuenta la prueba) | `desde` (último `n` leído) | `estado [cuenta] [email, solo con prueba: S2] [borrado] eventos: [n tipo fecha datos]` |
| `no-he-sido-yo` | prueba `no-he-sido-yo` | `{}` | `{}` |
| `cuenta/borrar` | prueba `cuenta-borrar` | `{}` | `{}` |
| `cuenta/borrar/cancelar` | prueba `borrado-cancelar` | `{}` | `cancelado` |
| `cuenta/borrar-por-email` | — | `email` | `solicitud` |
| `cuenta/borrar-por-email/confirmar` | — | `solicitud codigo` | `fecha` |
| `cuenta/empezar-de-cero` | — | `email` | `solicitud` |
| `cuenta/empezar-de-cero/confirmar` | prueba de la cadena **nueva** `empezar-de-cero`, cuenta vacía | `solicitud codigo kl envoltura` | `fecha` |
| `salir` | prueba `salir` | `aparato` | `{}` |

`estado` de `eventos`: `activa`, `borrado-programado` (con `borrado`), `cadena-sustituida` (la clave se cambió desde
otro Mac, 30 días) o `sin-cuenta`. Tipos de evento: `mac-anadido`, `contrasena-acertada`, `contrasena-fallos`
(`datos.n`, `datos.desde`, `datos.mac`), `contrasena-cambiada`, `email-cambiado`, `cadena-cambiada`, `cadena-ligada`,
`aparato-quitado`, `aparato-renombrado`, `no-he-sido-yo`, `borrado-pedido` (`datos.fecha`), `borrado-cancelado`.
`datos.aparato` es el autor, solo cuando está verificado (S3): el aparato del token que acompaña a la llamada, el que
recibe token nuevo al cambiar contraseña o clave, o el nuevo al añadirse; nunca el `aparato` del cuerpo.

**Errores** (`{"error": …}`): 400 `peticion`; 401 `prueba` / `token`; 403 `credenciales` (contraseña o código, sin
decir cuál, O9); 404 `sin-cuenta` / `aparato`; 409 `cadena-ligada` / `cadena-borrada` / `email-ocupado` /
`programado`; 415; 429 `espera` (con `hasta`) o `cupo`; 503 `ocupado` (no hubo turno; no cuenta como intento).

`contrasena/cambiar`, `alta/confirmar` y `email/cambiar/terminar` se pueden **repetir** con una prueba nueva si se
perdió la respuesta (§4.6): con la misma `kl` y `envoltura` contestan lo mismo (con un token nuevo).

## Lo que hace el servidor

- **Claves** (§4.5): `KS = scrypt(KL, sal, 2^14, 8, 1)` (16 MiB), `V` y `KW` por HKDF; guarda `sal`, `V` y
  `EE = AES-256-GCM(KW, E)`. Nunca `KL`, `KW` ni `E`. Email y nombres de los Mac, cifrados con la clave AES de la
  credencial; para buscar, `email_hmac`. Tablas: `cuentas`, `cuenta_aparatos`, `cuenta_eventos`, `cuenta_programados`,
  `cuenta_sustituidas` (`almacen.go`).
- **Espera de la contraseña** (N4, N6; `esperas.go`): por `email_hmac`, solo en memoria, 10 s → 15 min; se mira antes
  de pedir turno y se anota al recibirlo; con la tabla llena de esperas, la máxima sin comprobar nada.
- **Semáforo de scrypt** (N5; `semaforo.go`): tantos a la vez como `FLYWEB_SYNC_SCRYPT_A_LA_VEZ`, cola fija y 25 s.
- **Códigos** (`solicitudes.go`): en memoria, 10 min, un intento cada 10 s por solicitud, sin cierre. Las solicitudes
  falsas tienen la misma forma y el mismo ritmo que las verdaderas.
- **Cupos de correo** (N2, N3b; `cupos.go`) y **correo** (`correo.go`): todo se intenta enviar en el momento (el
  repartidor despierta con cada correo, fuera de la petición); solo queda en la cola lo que el MTA rechaza, para
  reintentarlo (avisos, 3 días; códigos, hasta que caducan). Avisos sin cupo. Textos en `textos.go`.
  Textos en `textos.go`.
- **Tareas cada minuto**: aviso de fallos pendientes (como mucho uno por hora), diferidos cumplidos, caducidades,
  inactivas; una cuenta cuya cadena se desactiva por el protocolo de sync se programa para borrar a 14 días, con
  aviso. **Cada hora**, una línea de contadores anónimos a nivel `warn`.

## Configuración (variables de la unidad)

| Variable | Por defecto | Qué |
|---|---|---|
| `FLYWEB_SYNC_CORREO_DESDE` | — (obligatoria con cuentas) | remitente, `noreply@` del dominio de FlyWeb |
| `FLYWEB_SYNC_SMTP` | `127.0.0.1:25` | MTA local, sin autenticación |
| `FLYWEB_SYNC_CORREOS_HORA` / `_ALTA_HORA` | 60 / 20 | cupos (2) y (1) |
| `FLYWEB_SYNC_ESPERA_TOPE_MIN` | 15 | tope de la espera |
| `FLYWEB_SYNC_ESPERAS_MAX` | 90000 | tamaño de la tabla de esperas |
| `FLYWEB_SYNC_SCRYPT_A_LA_VEZ` | núcleos | scrypt a la vez |
| `FLYWEB_SYNC_SCRYPT_COLA` | 4 × a la vez | longitud de la cola |
| `FLYWEB_SYNC_SCRYPT_COLA_S` | 25 | espera en cola |
| `FLYWEB_SYNC_DEMORA_DIAS` | 14 | borrado y «empezar de cero» por email |
| `FLYWEB_SYNC_AVISO_DIAS` | 30 | aviso antes de borrar una cuenta inactiva |
| `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS` | 0 | la de siempre; con cuentas, 365 (§7) |

**Credenciales** (`LoadCredential=`): `cuenta-hmac` y `cuenta-aes`, una línea por versión, `versión clave_hex`
(32 bytes); la versión más alta es la que escribe, las demás solo leen (rotación tras una brecha, §7). No van en la
copia de `sync.db`. Las genera e instala SERVIDOR-LOCAL; ni claves ni hosts en el repo.

**Memoria, para `MemoryMax`** (O14): 16 MiB por scrypt a la vez; tabla de esperas, unos 150 bytes por entrada (90 000
→ ~14 MiB); solicitudes falsas, unos 250 bytes cada una (50 000 → ~12 MiB); la cola no reserva nada.

## Límites conocidos

- Un reinicio pone a cero esperas, códigos pendientes, cupos y la cola de correo (avisos sin enviar incluidos).
- El contador «DISABLED_BY_ADMIN devueltos» de §9 no está: saldría de go-sync, que no se toca.
- Si alguien envía más de 50 000 códigos con solicitudes falsas en 10 s, todas las comprobaciones de código dicen
  «ocupado» mientras dure (contestar distinto a las verdaderas delataría la contraseña).

## Pruebas

`go test -race ./...` desde `FlyWeb/servidor/sync`: el banco (`banco_test.go`) levanta el servicio por HTTP contra
SQLite, con reloj, correo y go-sync falsos y «Macs» que hacen lo que hará el cliente. Cubre la parte de servidor de
P1, P2, P4–P8, P11 (con un Mac), P12, P14, P17–P22 (sin Macs ni bak), P24 y P26 de §12, más las respuestas iguales
exista o no la cuenta (O1). Sin cubrir aquí: lo que pide Macs, ns2, el MTA o bak (P9, P10, P13, P15, P16 en el
cliente, P20 en el MTA y bak, P23).
