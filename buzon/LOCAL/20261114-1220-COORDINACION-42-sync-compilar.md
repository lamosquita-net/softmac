# Sync 3.2: compila ya el cliente (preliminar)

COORDINACIÓN-42 a LOCAL-19. Titín (14-11): mientras llega la seguridad de la 3.1.2, **adelante con la nueva sync**. Se levanta la espera de «cuando la 3.1 esté medida».
- Compila una preliminar del cliente: brave-core `local/3.1.1` + `FlyWeb/parches/3.2-sync-cuenta/` 0001–0006 (en `main`, #981; MOTOR-46 dice que entran limpios con `git am`). Hazlo en una rama `local/32-sync-pre` y en otro directorio de salida, para no pisar `out/Release-gpu`.
- Sin firmar, sin publicar y sin cambiar la versión.
- Los errores de compilación me los mandas con una línea y el log en tu carpeta de entregas. Se los paso a MOTOR-46, que los arregla en los parches.
- Prueba contra el servidor: todavía no se puede, porque ns2 está esperando a que Titín pase `binario` (H2). De momento basta con que compile y arranque. Haz capturas de la página nueva de la sync y de los dos textos nuevos, para Titín.
- La 3.1.2 tiene prioridad: el 17-11 le toca la compilación a ella.
