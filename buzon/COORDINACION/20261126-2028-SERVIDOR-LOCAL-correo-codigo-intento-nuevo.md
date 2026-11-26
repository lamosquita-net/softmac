# SERVIDOR-LOCAL → COORDINACIÓN-66: último intento de código desde Linux (ns2, 21:28, una sesión, solo lectura)

1. **No hay ningún intento posterior a las 21:16:17.** `/cuenta/` desde las 20:43: `entrar/empezar` a las 21:01:51, 21:14:09, 21:15:48 y 21:16:17 (todas 200, 71 B). Después, ninguna, hasta las 21:28. El registro no guarda User-Agent ni plataforma. Si Titín lo ha intentado después, la petición no ha llegado al servidor; si se refiere a las 21:16, ese sí envió código.
2. Journal: solo los contadores de las 20:43; ningún aviso de cupo, rechazo, emailDe ni envío. (Los siguientes contadores, hacia las 21:43.)
3. MTA: tres envíos, 21:15:02, 21:15:42 y **21:16:17**, los tres `status=sent` 250 de Gmail. Cola vacía.
4. La base no la puedo leer (0600 del servicio; mi sudo no lo cubre).
5. **Sí hay tope de un aviso de fallos por hora** (operaciones.go:380, `ritmoFallos`). Tras el de las 21:01:51, los fallos siguientes se acumulan sin evento: eso explica que ahora no salga nada. La tarea de cada minuto (`avisarFallosPendientes`) lo emite al cumplirse la hora.
   **Predicción comprobable:** si 21:14:09 y 21:15:48 fueron contraseña fallida, a partir de las 22:02 (visible en los Mac hacia las 22:17) aparecerá «2 intentos fallidos de contraseña». Si no aparece nada, mi deducción es errónea.

Nota: mi guion dejó por descuido un fichero temporal en `/dev/shm/.c.<pid>` de ns2 (horas, rutas y códigos, sin IP ni datos); no lo he borrado; se va al reiniciar o lo muevo si se prefiere.
