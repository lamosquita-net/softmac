# Para «Local (22)» (LOCAL-21): compilación final de la FlyWeb 3.2.0, build 48 (COORDINACIÓN-58)

**Versión decidida por Titín (21-11): 3.2.0, `FLYWEB_BUILD_NUMBER` = 48.** Contenido cerrado y fusionado en `main` de softmac
(09a2b6d81c, comprobado con `git ls-remote`): #1110, #1138, #1151 (interfaz 0001–0019), #1142 (fijadas), #1147
(seguridad pendiente: brave-core 0001–0005 con el 0003 corregido, chromium 0001–0008), #1159 (portes-159: **solo el 0002**,
SchemeHostPort; el 0001 de menús salió a la 3.2.1), #1144 (3.2-v8 0001–0002, época 37 → 38) y #1150 (ajustes-sistema 0005).
Nada más entra.

1. **Montaje:** la misma composición que bt-320f (base de brave-core y de chromium, renderer-webgl incluido), con los parches
   desde `main` y sus `SHA256SUMS`. Árboles esperados:
   - brave-core antes de la versión: **02c6111221** (MOTOR-47; cadena paso a paso en `buzon/COORDINACION/20261121-1106-MOTOR-47.md`);
     `patches/v8` = **2b1c8d3308**, V8 **8566fd42e4** (D8-LINUX, verde).
   - chromium sin renderer-webgl: **1c458472cc**; con renderer-webgl, anota el que salga (la diferencia debe ser solo esos
     2 commits, como con 078162ae47/317e849352).
   Si alguno no cuadra, para y avisa.
2. **Versión:** `flyweb_version` 3.2.0 y build 48 en `build/config.gni`, como en la 3.1.4 (build 47). Nada más cambia.
3. **Compilar:** al máximo hoy y mañana domingo; desde el lunes 23, pregúntale antes a Titín si está trabajando (DIRECTIVAS).
4. **Pruebas sin ventana (7,1):** `BraveColorMixersTest.*`, `OmniboxColorTest.*`. Con ventana, **solo en la 6,1** (#1176):
   capturas en oscuro del desplegable de la URL (#767676, fila elegida, texto blanco); y a mano lo de SchemeHostPort:
   `file:///`, `flyweb://settings` y una extensión (sin errores ni pantallas en blanco). Revisa también que no salga nada
   raro en la caché de código (época 38).
   Excluidas como «comportamiento de Brave»: `ServiceWorkerBrowserTest.FetchPageWithSaveData`, `.CrossOriginFetchWithSaveData`
   y `.StoppedServiceWorkerWakesUpOnSubresource`.
5. **Entrega:** como siempre, regla 11 (fila en `docs/TAREAS.md`: rama, puntas y árboles, resultado de cada prueba, capturas
   en `entregas/`). Esa entrega es la orden de publicar para PUBLICACIÓN. Avísame por `SendMessage` al dejarla.
Tras cada SEGV o timeout, `pgrep -fl _unittests`. Ventanas de Titín en la 6,1: no se tocan. Todo en español.
