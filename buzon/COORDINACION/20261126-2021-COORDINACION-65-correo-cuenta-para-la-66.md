# COORDINACIÓN-65 → COORDINACIÓN-66: correo del código de la cuenta en Linux, último análisis de SERVIDOR-LOCAL

(Sustituye al punto 2 de la nota de relevo, que lo daba como fallo del servidor.)

SERVIDOR-LOCAL, con el código de main y los registros de ns2 (sin SSH nuevo):
- 21:01:51 (Madrid) entrar/empezar → 200 **sin correo**. A las 21:03:30, `eventos` de otro equipo devolvió 165 B frente a 77:
  88 B = exactamente un evento `contrasena-fallos` (`{"n":N,"tipo":"contrasena-fallos","fecha":F,"datos":{"n":1,"desde":F}}`);
  un `contrasena-acertada` habría ocupado 55 B. Camino: `operaciones.go` 278 (registrarFallo) y 279 (200 falso, a propósito).
- Con contraseña buena: 282 (evento acertado), 287 (cupo, que deja aviso en el journal: no lo hay), 292–293 (emailDe y envío en
  la misma petición; no espera confirmación de ningún equipo). Único hueco silencioso: el else de 292 (emailDe falla sin
  registrar), que aquí no se dio.
- 21:14:09: otro fallo (un aviso por hora). 21:15:48: sin correo, 6 s tras el cambio de contraseña en el Mac. 21:16:17 con la
  nueva: **enviado, 250 OK de Gmail**. Linux deriva bien la nueva (y D8: 9/9 vectores iguales a Mac).
- Sin PR de servidor. Opcional: registrar en el journal el error de emailDe (línea 292).

Titín sostiene que la primera era correcta y que sus Mac le preguntaron «¿eras tú?». Pendiente: el texto exacto de ese aviso
(«intentos fallidos» frente a «ha escrito bien»). Si dice «ha escrito bien», el análisis de tamaños está mal y hay que volver al
else de 292. Si es «intentos fallidos», D8 compara cómo se escribe la contraseña vieja en la Ubuntu (teclado, ñ, acentos,
autorrelleno). Tratarlo con datos y sin discutirle: la primera vez se le dio por mala sin pruebas.

## Añadido 21:25 (Madrid): cupo descartado por SERVIDOR-LOCAL

Binario de ns2 = f47aafb3…0886 (#1024, incluye la ruta actual). FLYWEB_SYNC_CORREOS_HORA sin definir (60). 0 líneas de «tope de
correos», «descartado» o «el MTA no acepta» en todo el día; servicio arrancado a las 03:32 y sin correos antes de las 21:15, así
que a las 21:01:51 el cupo estaba vacío. Con el tamaño del evento (88 B = contrasena-fallos), **el servidor recibió a las 21:01
una KL que no coincidía**. D8 comprobó que el cálculo de Linux es igual al de Mac, y la contraseña nueva funcionó desde Linux
a las 21:16. Lo que queda es lo que se escribió en la Ubuntu con la vieja: teclado, ñ, acentos o autorrelleno. Titín contestó «sí,
era yo» en su Mac; el servidor no espera esa confirmación (operaciones.go). Arreglos propuestos, para después y a Titín: registrar
cada rechazo de cupo y el error de emailDe (línea 292), y que el aviso de los Mac distinga «contraseña fallida» con claridad.
