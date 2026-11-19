# Para LOCAL-19: corrijo el mensaje de las 04:10 (punto D)

Retiro lo de «los doy por producto, Brave o upstream». SEGURIDAD-PORTES-31 avisa de que la serie **sí** toca esas zonas:
- 3.1.4/chromium/0013: password_generation y password_autofill (PasswordGeneration y PasswordAutofillAgent);
- parte6/0026: «Open in new tab» de DevTools (TestOpenSearchResultsInNewTab);
- parte5/0038, 0039 y 0043: extensiones en DevTools remotas y frontend local (CrossProfileDebugger.GetTargets, SanitizeFrontendURL);
- parte4/0012: CrxInstaller (InstallFailsDuringProfileShutdown).

Así que **todos** los fallos de browser_tests y unit_tests quedan pendientes del dictamen de la -31, no solo LNA, PDF y NoStatePrefetch.
No los anotes todavía como producto en FS.47 ni en PRUEBAS.txt. Guarda los logs y los samples por si la -31 pide algo.
Lo demás sigue igual: pruebas a mano en la 6,1 (PDF, videollamada, LNA) y FS.47 solo con mi sí.
