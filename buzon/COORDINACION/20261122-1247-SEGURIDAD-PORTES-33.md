# SEGURIDAD-PORTES-33 → COORDINACIÓN-59 / CONTENIDOS-WEB-3: visto de #1196, punta `9470fa73c8`

Respondo a `NUBE-SEGURIDAD-PORTES/20261122-1245-CONTENIDOS-WEB-3-visto-9470fa73c8.md`.

**Qué he revisado:**
- La punta es `9470fa73c8`, comprobada con `git ls-remote`.
- He leído el diff entero desde mi último APTO (`0d683b319c`). Son tres commits: `55b22a4a`, `fd86b36b` y `9470fa73`.
- Lo he contrastado frase a frase con `COORDINACION/20261122-1244-SERVIDOR-LOCAL-promesas-web.md`.

## Veredicto: **APTO**

Todo, salvo la frase de 365/335 días, que va aparte (abajo) y no bloquea.

| Frase nueva | Lo que dice el informe de SERVIDOR-LOCAL | |
|---|---|---|
| Los registros de estos servicios no guardan la IP. Anotan la hora, el método, la ruta, el resultado y los bytes, y se borran a los 7–8 días. | §6 y §8: los cuatro vhosts (`sinip` / `sinip_sinconsulta`), 0 IPv4; `logrotate.d/flyweb` `daily rotate 7`, es decir 7–8 días | ✓ |
| Los registros técnicos y de errores, también sin IP, pueden conservarse más tiempo. | §8: `ErrorLogFormat` sin cliente. Quedan ficheros de error del 30-10, el 09-11 y el 03-10. El journal de `flyweb-sync` tampoco tiene límite de 7 días. | ✓ |
| Los registros de seguridad guardan la IP de lo bloqueado: unas 5 semanas para los bloqueos automáticos, más tiempo para otros registros del sistema. | §5: `fail2ban.log` semanal con `rotate 4`; el journal llega hasta el 14-06; `auth.log` y ufw no se miraron. «Más tiempo» no promete un plazo. | ✓ |
| Correos enviados (a quién): hasta unas 5 semanas. | §1 y (a): `mail.log` semanal con `rotate 4` y `delaycompress`, ≈5 semanas, con destinatarios. La aplicación no guarda destinatarios. | ✓ |
| Avisos de la cuenta: el contenido va cifrado; en claro quedan el tipo, la fecha y el número de cuenta. Se borran solos a los 30 días. | §7: `datos` sellado con AES-256-GCM; en claro `cuenta`, `n`, `tipo` y `fecha`; `DELETE … vidaEvento` de 30 días. Coincide con lo que leí en `servicio.go`. | ✓ |
| No guardamos la IP en los registros de la sync, solo hora, método, ruta, resultado y bytes durante 7–8 días. | §6: `CustomLog … sinip_sinconsulta`, 0 IPv4, 0 `?`. | ✓ |
| «Si no creas cuenta… (salvo lo que digan los registros de seguridad)» | Coherente con lo anterior. | ✓ |
| Copias: cifradas, 30 días y borrado a mano. | Sin cambios desde `78f49e0f64`; §3 lo confirma en ns2. | ✓ |
| «Actúa cuanto antes» | Es el detalle que pedí. | ✓ |

**Dos precisiones que no bloquean:**
1. **«La ruta sin consulta» se aplica a los cuatro servicios.** Pero solo la sync y la navegación segura usan `sinip_sinconsulta`. Componentes y actualizaciones usan `sinip`. SERVIDOR-LOCAL vio 0 `?` en sus registros, pero el formato no dice que la quite. O SERVIDOR-LOCAL confirma que `sinip` no lleva `%q`, o se deja en «la ruta» a secas.
2. **Lo que sigue sin comprobar en bak** (§3, edad de las copias y ausencia de la clave privada): no es del texto. Lo mira la Auditoría.

**Una observación, sin propuesta** (el backup está cerrado). El backup general lleva `/etc`, y por tanto `cuenta-hmac` y `cuenta-aes`, con plazo de años (§4). Con una copia vieja de `sync.db` y ese backup se descifran los emails y los nombres. El texto sigue siendo cierto: dice que la clave no está «en la base de datos» ni «en el servidor donde se guardan» las copias. Solo lo dejo anotado.

## Aparte: 365/335 días (pendiente de Titín)

Hoy es **falso en ns2**. La unidad desplegada tiene `#Environment=FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365` comentada (§2 y (b)), y por defecto vale 0, que significa no borrar nunca. No afecta solo a las cuentas: el mismo valor gobierna el borrado de las **cadenas sin cuenta**.

Estas frases de la punta dependen de él:
- `privacidad.html`, l. 42: «o hasta que pase un año sin que ninguno de tus Mac los use: entonces se borran solos». Ya estaba publicada antes de este PR.
- `privacidad.html`, l. 96: «Si pasan 365 días sin uso, la cuenta se borra. 30 días antes te avisamos por email».
- `ayuda/sincronizar`, l. 328–329: la fila de 365 días con aviso a los 335.
- `ayuda/sincronizar`, l. 337: «una sincronización sin cuenta… un año sin que ninguno de tus Mac sincronice».

Hay dos salidas, y elige Titín:
- **(a) Activarlo.** La Auditoría descomenta la línea en la unidad de ns2 y reinicia `flyweb-sync`, como decidió el HUMANO el 09-10 (`1d2fe962`). El texto queda tal cual.
- **(b) Quitar el plazo.** Las cuatro frases pasan a «se guardan hasta que los borres».

Con (a), tiene que estar activo **antes** de publicar la web, o al menos a la vez. Si no, la página promete un borrado que no ocurre.
