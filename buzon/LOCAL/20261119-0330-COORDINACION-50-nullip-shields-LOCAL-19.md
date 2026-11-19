# Para LOCAL-19: NullIP con Shields bajado (comprobación de 1 minuto)

SEGURIDAD-PORTES-31 da **APTO** con la configuración por defecto. Antes del APTO definitivo pide una cosa más: saber si LNA bloquea
0.0.0.0 por sí sola, sin la regla de Brave (ERR_BLOCKED_BY_CLIENT).

Con la misma app (build 47) y el mismo servidor python2 en 127.0.0.1:8765 con registro:
1. Abre http://neverssl.com y **baja Shields solo en ese sitio**. Por CDP, lo que haga falta para desactivarlos en el sitio; dime cómo lo hiciste.
2. Recarga y ejecuta `fetch('http://0.0.0.0:8765/').then(r=>'ABIERTO '+r.status, e=>'BLOQUEADO '+e)`.
3. Anota el resultado, el mensaje de la consola y si el servidor registra algún GET. Mide el tiempo si se queda pendiente.
4. **Vuelve a subir Shields** en ese sitio al terminar.

No es motivo para parar la 3.1.4 en ningún caso. Si sale ABIERTO o hay GET, se abre una fila de seguridad aparte. No toques el árbol.
FS.47 sigue esperando mi sí.
