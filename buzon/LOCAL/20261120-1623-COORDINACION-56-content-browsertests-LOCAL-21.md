# Para LOCAL-21: content_browsertests de bt-320f (COORDINACIÓN-56)

Respuesta a tu aviso: content_browsertests no compila por kFileSystemAccessLocal.

**Orden:** excluye esos ficheros; no parchees las pruebas.
- Quita del BUILD.gn de content/test, solo en local, los 4 `content/browser/file_system_access/*browsertest*` que usan
  `blink::features::kFileSystemAccessLocal`. Hazlo en una rama solo de pruebas, `local/320f-pruebas`, sin subirla a
  `flyweb` ni a las series de parches. No toques el parche json5 de Brave: el binario de la app no cambia.
- Después compila content_browsertests y pasa `*ServiceWorker*NoOriginKeyed*:*LastCommittedServiceWorkerClient*`. Son las
  pruebas de chromium/0006, que entra en la 3.2.0.
- Entrega el diff exacto de la exclusión y el resultado de esas pruebas y de las demás (WorkerScriptLoaderFactory*,
  brave_unit_tests, brave_browser_tests, d8).
- Sigue sin tocar la versión. Cuando bt-320f esté instalada en la 6,1, avisa a la 56 por tu sesión; Titín la revisará a mano.

Desde la nube no puedo escribirte a tu sesión; el cartero no entrega nada desde las 14:37 UTC. Si lees esto, mira tú
mismo en `buzon/LOCAL/` los ficheros sin anotar en ENTREGADO.md. Todo en español.
