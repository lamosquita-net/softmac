# Para LOCAL-19: NullIP, prueba a mano OBLIGATORIA antes de FS.47

SEGURIDAD-PORTES-31 retira la hipótesis del entorno (tu curl la descarta). Mantiene que **la serie no lo causa**, pero dice que
**la protección no está probada**: las 4 pruebas se cuelgan en vez de bloquear. Sospecha de algo de Brave o FlyWeb en el camino
de la petición (BraveProxyingURLLoaderFactory / BraveRequestHandler). Es una conjetura.

Prueba en la 6,1, con el FlyWeb 3.1.4 de la build 47. Por CDP vale; no hace falta la pantalla:
1. Servidor: `python -m SimpleHTTPServer 8765` atado a 127.0.0.1 (la 6,1 no tiene python3). Guarda su log: tiene que verse si llega algún GET.
2. Web pública **no segura** (p. ej. http://neverssl.com). Ejecuta en esa página:
   `fetch('http://0.0.0.0:8765/').then(r=>'ABIERTO '+r.status, e=>'BLOQUEADO '+e)`
   → debe dar **BLOQUEADO enseguida**, con el aviso de Local Network Access en la consola y **ningún GET** en el servidor. Si se queda pendiente, mide cuánto tarda.
3. Lo mismo con `http://127.0.0.1:8765/` y `http://localhost:8765/`: los dos deben dar BLOQUEADO.
4. Desde **https://example.com**, el mismo fetch a `http://0.0.0.0:8765/`: debe dar BLOQUEADO (contenido mixto) o pedir permiso de red
   local. **Nunca** debe llegar el GET sin preguntar.

**Si alguno da ABIERTO o el servidor registra un GET: para y avísame enseguida.** No es APTO para publicar.

Opcional, para la causa: relanza NullIPBlockedOnNonsecure con
`--enable-logging=stderr --v=0 --vmodule=*local_network_access*=2,url_loader=2,brave_request_handler=2,brave_proxying_url_loader_factory=2 --log-net-log=/tmp/nullip.json`.
No hace falta compilar content_browsertests.

Lo demás de tus comprobaciones (1–5): recibido y correcto. No toques el árbol; me preguntas antes de FS.47.
