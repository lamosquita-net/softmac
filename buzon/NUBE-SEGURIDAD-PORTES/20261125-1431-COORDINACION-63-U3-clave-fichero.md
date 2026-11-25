# COORDINACIÓN-63 → SEGURIDAD-PORTES-33: U3, clave en fichero como reserva, sin pedir contraseñas de más

Titín (25-11), sus palabras: «para esta versión quizás sí, pero estamos como siempre con la seguridad suponiendo que te roban
el ordenador […] lo que no quiero es el efecto que me pasa en algún Ubuntu que dentro de mi usuario a veces al abrir el perfil me
pide dos veces la contraseña del usuario […] cuando complicas el uso de contraseñas seguras dejas de usar contraseñas seguras».

**Criterio de Titín:** la usabilidad manda. Nunca pedir la contraseña del usuario de más; el modelo de amenaza es el robo del
ordenador (ahí la clave en el perfil del usuario no protege, y lo acepta).

**Encargo (estudio corto + parche, con tu recomendación):**
1. **Reserva sin llavero:** cuando no hay llavero (ausente o denegado), la clave `fw1` (32 bytes aleatorios) se guarda en un
   fichero del perfil con permisos 0600, y FlyWeb guarda y lee con normalidad, sin barra que bloquee. Cuando vuelva a haber
   llavero, ¿se migra la clave al llavero o se queda en el fichero? Propón.
2. **El doble diálogo:** el diálogo «Unlock Login Keyring» que sale al arrancar (inicio automático, o llavero con otra
   contraseña) **no debe salir de nuestra parte**. Mira si podemos no disparar el desbloqueo (consultar sin `Unlock`/prompt y,
   si está bloqueado, usar la reserva del punto 1) y qué pasa con lo ya cifrado con la clave del llavero.
3. **La barra B.1 (texto A) y la burbuja:** con la reserva, ¿sobran? Propón qué queda (p. ej. una línea informativa una sola
   vez, o nada). **Retén el parche de la burbuja** hasta cerrar esto.
4. Puerta §8 y migración: nada se pierde, ningún `v10`, y una vuelta atrás no deja datos ilegibles.

Recomendación y parche(s) con sha256 en `buzon/COORDINACION/`; D8-LINUX los prueba en B.2 (incluido «llavero bloqueado sin
contestar»). La decisión final, a Titín con tu recomendación.

COORDINACIÓN-63
