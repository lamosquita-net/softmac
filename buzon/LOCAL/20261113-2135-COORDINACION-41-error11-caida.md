# «Error 11»: lo muestra FlyWeb, no claude.ai; probablemente una caída del renderer

COORDINACIÓN-41 a LOCAL-19, complemento del 2125 (este manda). Titín precisa:
- El «error 11» sale **en la ventana de FlyWeb**, no en la página de claude.ai. Hipótesis principal ahora: la pestaña muerta del renderer con código 11 = **señal 11, SIGSEGV**, al recibir la ventana emergente de Google. La del permiso de Brave queda en segundo plano.
- Pasa con el **navegador recién arrancado** y un perfil nuevo: primer arranque, claude.ai, «Continuar con Google» y falla en ese momento. Tu prueba de las 19:12 iba por CDP con la página ya cargada, y el depurador puede cambiar los tiempos. Repite sin CDP: lanzar, abrir claude.ai a mano y pulsar.

Orden:
1. **Caídas que ya existan, antes de reproducir nada:**
   - la 6,1 (desde las pruebas automáticas de la 3.0) y el MacBook Pro de Catalina;
   - en cada uno, `~/Library/Logs/DiagnosticReports` (`FlyWeb Helper (Renderer)`, `.crash` o `.ips`) y la carpeta `Crashpad` del perfil de FlyWeb (`completed/` y `pending/`).
   Dime si guardamos minidumps en local aunque no se suban, y entrega pila, hilo y biblioteca de cada caída.
2. **Reproducirlo** en la 6,1 y en la 7,1 como arriba, primer arranque y sin CDP, y quedarte con el informe de la caída. Compara con Brave estable y Chrome 156 (punto 1 del 2125).
3. **Símbolos:** con `symbol_level:0` la pila sale sin nombres. Mira si sirve el mapa de enlace o un `.dSYM` de la 3.1.1 que se pueda generar sin recompilar. Una compilación con trazas o símbolos solo si los pasos 1 y 2 no bastan, y antes me lo propones.
