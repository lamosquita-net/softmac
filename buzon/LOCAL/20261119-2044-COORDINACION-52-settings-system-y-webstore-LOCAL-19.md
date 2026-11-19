# Para LOCAL-19: dos fallos que ha visto Titín en la FlyWeb de prueba (diagnóstico, sin arreglar nada)

Titín revisa la build de la interfaz 3.2.0 en la 6,1 y ha encontrado dos fallos. Según él, el primero viene al menos de la
3.1.3, así que no es de la serie de la interfaz.

## 1. `flyweb://settings/system` → «¡Vaya!», RESULT_CODE_KILLED_BAD_MESSAGE
El navegador mata el proceso de la página de Ajustes > Sistema por un mensaje IPC incorrecto. Necesito el motivo exacto:
- Arranca la FlyWeb de prueba con un perfil limpio y registro:
  `--enable-logging=stderr --v=0 --user-data-dir=<perfil nuevo>` (o el registro del perfil de prueba), abre
  `flyweb://settings/system` y busca la línea «Terminating renderer for bad IPC message, reason N», o
  «mojo::ReportBadMessage» con su texto (p. ej. «interface not registered» y el nombre de la interfaz).
- Repítelo con la 3.1.4 publicada (build 47), también con perfil limpio, para confirmar que ya fallaba.
- Abre también las demás páginas de Ajustes (apariencia, privacidad, búsqueda, descargas, idiomas, accesibilidad, sync,
  Shields…) y dime cuáles fallan igual.

## 2. Chrome Web Store: al entrar no carga nada, así que no se pueden añadir extensiones
- Con la FlyWeb de prueba, abre `https://chromewebstore.google.com/` y la ficha de una extensión cualquiera.
- Por CDP (puerto 9484 u otro), apunta las peticiones que fallan (URL del host, código o error de red) y los errores de
  la consola. Mira también si lo bloquea Shields (contador del escudo) o una política
  (`flyweb://policy`: ExtensionInstallBlocklist, ExtensionInstallSources, etc.).
- Compara con la 3.1.4 publicada.

Devuélveme por el bridge las líneas tal cual, sin datos personales. No cambies nada del código ni de LuLu, y no toques
el perfil de Titín.
