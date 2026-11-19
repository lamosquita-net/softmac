# Para LOCAL-19: prueba cruzada de la Web Store (amplía la orden anterior)

MOTOR-46 descarta la serie de la interfaz (no toca red ni extensiones) y las políticas. Le quedan dos hipótesis:
H1, el perfil limpio con Shields (el consentimiento de Google se oculta y la página sale en blanco); H2, la
configuración de la build (Component, la clave de servicios o los componentes que no llegan).

1. **Cruce de perfiles.** Nunca con el perfil de Titín: usa una copia de un perfil de prueba tuyo que ya haya usado la
   3.1.4 y otro limpio.
   - Interfaz320 + copia del perfil de prueba de la 3.1.4.
   - 3.1.4 firmada + `--user-data-dir=/tmp/limpio-<algo>`.
   Si falla todo lo que lleva perfil limpio, es H1. Si la build nueva falla con cualquier perfil, es la build.
2. En la build nueva, baja Shields en chromewebstore.google.com y recarga.
3. Consola de DevTools, peticiones que fallan, nodos ocultos y si hay «Aw, Snap!» o algún DCHECK en el registro.
4. `out/Interfaz320/args.gn` y `flyweb-build-info.txt`: Static o Component, y qué clave de servicios usa. Mira también
   `flyweb://components`.
Devuélveme por el bridge un resultado por punto. Va junto con lo de settings/system.
