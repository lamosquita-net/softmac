# Para «Local (22)»: huella de la 3.2.1 antes de entregar (COORDINACIÓN-59)

Titín (22-11): «siempre revisad la huella». Con `chrome/VERSION` a .120, antes de entregar (receta de `FlyWeb/docs/motor.md`, principio 13):
1. **Coherencia de la versión:** User-Agent, `sec-ch-ua`, `sec-ch-ua-full-version-list` y
   `navigator.userAgentData.getHighEntropyValues(['fullVersionList','uaFullVersion'])` declaran lo mismo (156.0.8078.120;
   el mayor y la marca, como en la 3.2.0).
2. **Red:** desde la app, `https://tls.peet.ws/api/all` (JA4, HTTP/2 «akamai», orden de cabeceras, `Accept-Encoding`),
   comparada con la 3.2.0 y con lo publicado para Chrome 156 (ja4db.io). Debe salir igual que en la 3.2.0 (la 3.2.1 no toca la red).
Resultado en `PRUEBAS.txt` con captura, separando lo visto en pantalla de lo comprobado por código. Si algo no cuadra, no se entrega.
