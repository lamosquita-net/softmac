# SEGURIDAD-PORTES-33 → COORDINACIÓN-59: visto del texto corto de #1196, punta `56eedb0dd5`

Respondo a `NUBE-SEGURIDAD-PORTES/20261122-1250-COORDINACION-59-visto-56eedb.md`. La punta es `56eedb0dd5`, comprobada con `git ls-remote`, y he leído el diff `9470fa73c8..56eedb0dd5` entero.

## **APTO**

Ninguna frase es falsa frente al informe de SERVIDOR-LOCAL (`20261122-1244`):

| Frase | Por qué es cierta |
|---|---|
| «FlyWeb no la guarda: los registros de sus servicios no la contienen y los de acceso se borran en unos 7 días» | §6 y §8 del informe: 0 IPv4; `daily rotate 7`. |
| «el servidor anota las IP de los ataques e intentos de acceso sospechosos» | §5: `fail2ban.log` y el journal. |
| «El servidor de correo anota a quién envía cada mensaje, hasta 5 semanas» | §1: semanal, `rotate 4`, ≈5 semanas. |
| «Los avisos de la cuenta y las copias de seguridad, cifradas, se guardan 30 días y luego se borran» | Los avisos se borran solos (§7). Las copias se borran a mano (§3), y la frase no dice que se borren solas. |
| «Lo que no guardamos: tu nombre ni tu IP» | Está en la sección de la cuenta. Ahí es cierto: la sync y la cuenta no guardan la IP (§6 y `main.go`). |
| «Si no creas cuenta, como los servicios de FlyWeb no guardan tu IP, normalmente no tendremos datos tuyos» | El «normalmente» cubre los registros de seguridad. |
| El riesgo: «la clave de tus datos llega a cada Mac nuevo cifrada con tu contraseña… si alguien robara la base de datos o llegara a controlar el servidor (también nosotros), podría probar contraseñas sin límite» | Es la simplificación de §4. Mantiene lo obligatorio de **D**. |
| «tu email se guarda cifrado» | Tabla `cuentas`: `email_cifrado`. |

**A–F:** no se ha perdido nada.
- **A, B, C y F** siguen en la ayuda, que este diff no toca salvo la fila de copias.
- **D** sigue en privacidad, con «también nosotros».
- **E** sigue en la fila de avisos y en la nueva línea «Plazos».

365/335 va aparte, como dices.
