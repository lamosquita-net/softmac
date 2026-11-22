# Para «Local (22)» (LOCAL-21): compilación final de la FlyWeb 3.2.1, build 49 (COORDINACIÓN-59)

**Versión decidida por Titín (22-11): 3.2.1, `FLYWEB_BUILD_NUMBER` = 49** (DIRECTIVAS #1190). Contenido: #1165 (punta 51d8f94d45)
y #1171 (punta 1dff7b4353), comprobadas con `git ls-remote` a las 09:47 UTC. Nada más entra (#1183 va a la versión siguiente).

1. **Montaje:** el mismo que tus pruebas (`local/321-seguridad` y `local/321-final`), **sin** los apaños solo de prueba
   (exclusión de blink, scripted_animation, CoreText, blinkpy, wptserve). Árboles: chromium **e6aa9fedc5** (con renderer-webgl),
   brave-core **af99cc3984** sobre 4d7ccceaf3 antes del commit de la versión, `patches/v8` a4c9a44d28, V8 c8e7b3da27, época 39.
   Si alguno no cuadra, para y avisa.
2. **Versión:** `flyweb_version` 3.2.1 y build 49 en `build/config.gni`, como en la 3.2.0 (build 48). Nada más cambia.
3. **Compilar:** hoy domingo, al máximo sin preguntar; si pasa al lunes 23, pregúntale antes a Titín. `ps` antes de `build.sh`.
4. **Pruebas de pantalla, en la 6,1, con la build final** (antes de la entrega): vídeo HLS `.m3u8` y más visitados de la nueva
   pestaña (con la 3.2.0 de contraste). Los menús FOR_DROP (soltar un enlace en una carpeta de marcadores, con Esc, y abrir y
   cerrar menús) los hace Titín a mano: avísale en el chat con la ruta de la app cuando esté lista (y si LuLu la retiene).
   Si algo sale rojo, para y avísame: no se entrega.
5. **Entrega:** regla 11, como la 3.2.0 (fila en `docs/TAREAS.md`: ramas, puntas y árboles, cada prueba, imports 10.15 y AVX,
   capturas en `entregas/`), solo con lo de pantalla en verde. Esa entrega es la orden de publicar para PUBLICACIÓN.
   Sube las dos ramas `local/321-final` a los forks. Avísame por `SendMessage` al dejarla.
Tras cada SEGV o timeout, `pgrep -fl _unittests`. Ventanas de Titín en la 6,1: no se tocan. Todo en español.
