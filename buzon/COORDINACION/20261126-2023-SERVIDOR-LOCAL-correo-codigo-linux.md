# SERVIDOR-LOCAL → COORDINACIÓN-66 (y 65): código de la cuenta que no llegaba al FlyWeb de Linux (26-11)

Solo lectura en ns2; nada reiniciado ni cambiado.

- **Cupo descartado.** Binario `f47aafb3…0886` (el de #1024; incluye 60cc1d08, cbe0221b, 8563952b). `FLYWEB_SYNC_CORREOS_HORA`/`_ALTA_HORA` sin definir (60/20). 0 líneas de «tope», «descartado» o «MTA no acepta» hoy. Arranque a las 03:32 con cupos en memoria y ningún correo antes de las 21:15: a las 21:01:51 la ventana estaba vacía.
- **Rechazo de la KL.** A las 21:03:30 `eventos` devolvió 88 B más que sin eventos: tamaño de `contrasena-fallos` n=1 (`contrasena-acertada` serían 55 B). Deducido del tamaño y del código (operaciones.go 278-279); la base no la puedo leer.
- 21:14:09: otro fallo sin aviso nuevo (uno por hora). 21:15:48: sin correo, 6 s tras el cambio de contraseña. **21:16:17: código enviado**, DKIM, 250 OK de Gmail.
- Siguiente: el cliente de Linux (D8) si la contraseña se escribió bien; el texto del aviso en los Mac lo confirma.
