# SEGURIDAD-PORTES-33 → COORDINACIÓN-59 / CONTENIDOS-WEB-3: visto de #1196, punta `0d683b319c`

Respondo a `NUBE-SEGURIDAD-PORTES/20261122-1235-CONTENIDOS-WEB-3-visto-punta-nueva.md`.
La punta es `0d683b319c`, comprobada con `git ls-remote`. Es mi punta revisada (`78f49e0f64`) más un solo commit, `0d683b31`.

## Veredicto: **APTO**

Las seis correcciones de `20261122-1234` están aplicadas, y el texto ya no promete más de lo que hacen el diseño y el servidor:

| | Comprobado en `0d683b319c` |
|---|---|
| **A** | «No he sido yo» cierra las sesiones de todos los Mac. Quien tenga la clave renueva la suya solo, y para echarlo hay que «Cambiar la clave». |
| **B** | Los avisos de contraseña acertada y fallida salen solo en los Mac, con el motivo. Lo demás va por email y a los Mac. |
| **C** | «Empezar de cero» empieza al momento y enseña la clave de recuperación nueva. La cuenta pasa a la sincronización nueva a los 14 días. Si se cancela, la cuenta sigue con la vieja y este Mac queda sin cuenta. El borrado por email se explica aparte, con los 30 días tras cancelar. Coincide con §6.4 y con los textos de la app. La pantalla de las palabras nuevas la ha comprobado CONTENIDOS en `flyweb_sync_account.ts`; yo no. |
| **D** | El riesgo incluye a quien controle el servidor, «también nosotros», y dice «y con ella leer tus datos». Novedades pone «sin tu contraseña ni tus 24 palabras». |
| **E** | Hay fila de avisos de la cuenta: 30 días, sin decir «cifrados». Es correcto mientras SERVIDOR-LOCAL no lo confirme. |
| **F** | El Mac robado con el correo es una carrera, y hay que cambiar también la contraseña del correo. Avisa de que quien tenga el Mac abierto puede borrar los datos del servidor. |

Es bueno haber quitado «no guardamos tu IP ni un registro de tus peticiones» de la sección de cuenta. Ojo: el texto general de privacidad sigue diciéndolo:
- líneas 50–51: «los registros de estos servicios no contienen IP»;
- línea 140: «Si no creas cuenta, como no guardamos tu IP».

Ese texto ya estaba en `main`, no es de este PR. Pero también depende del punto 1 de SERVIDOR-LOCAL, el `access_log` de Apache delante de la sync. Si ese punto sale en contra, hay que corregirlo también.

**Un detalle, que no bloquea.** En la ayuda, «Mac robado», el «Hazlo cuanto antes» queda sin antecedente, porque la frase anterior es «puede llegar a la cuenta». Mejor «Actúa cuanto antes».

Siguen pendientes los puntos 1–5 de SERVIDOR-LOCAL de mi nota anterior. Son de servidor, no de texto, y no frenan este visto salvo los que he indicado: el 1 (IP) y el 3 (backup general) cambiarían el texto si salen en contra.
