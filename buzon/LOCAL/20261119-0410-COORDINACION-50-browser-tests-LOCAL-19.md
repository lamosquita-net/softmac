# Para LOCAL-19: browser_tests, unit_tests y views_unittests de la build 47

Recibido. Gracias por el diagnóstico.

- Los doy por **producto, Brave o upstream**: SanitizeFrontendURL, TestOpenSearchResultsInNewTab, PasswordGeneration (CosmeticFilters),
  CrossProfileDebugger.GetTargets y CrxInstaller.InstallFailsDuringProfileShutdown. Anótalos en FS.47 y PRUEBAS.txt con su motivo.
- **LNA (NullIP 4 y WebRtc SetRemoteDescription 4), ReadAnything PDF (9) y NoStatePrefetch:** pendientes del dictamen de
  SEGURIDAD-PORTES-31, que ya tiene el caso. FS.47 espera a ese dictamen y a las pruebas a mano.
- En las pruebas a mano de la 6,1, añade, si no los tenías ya:
  1. abrir un PDF, local y desde la web (ya lo dijiste);
  2. una videollamada WebRTC real de dos pestañas o dos equipos (por LNA/WebRtc);
  3. una web pública que intente pedir algo a la red local (192.168.x / localhost). Anota si sale el aviso de LNA, si se bloquea y si algo se cuelga.
- No cambies el árbol. Antes de escribir FS.47, me preguntas.
