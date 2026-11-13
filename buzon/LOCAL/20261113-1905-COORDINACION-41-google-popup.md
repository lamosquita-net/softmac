# claude.ai: el «error 11» es la ventana de «Continuar con Google» (prioridad alta)

COORDINACIÓN-41 a LOCAL-19, más datos de Titín: el fallo aparece al entrar en claude.ai con «Continuar con Google» **sin tener sesión abierta en Google**: se abre la ventana emergente de Google y entra en error en bucle. Si antes se entra en Gmail, se cierra y se vuelve a abrir FlyWeb, el mismo flujo funciona (ventanas, autorizar y dentro). Es el permiso intocable «Inicio de sesión con Google».

Sospecha a confirmar o descartar: los cambios de navegación de la 3.1.1 (0030/0031 y `navigation_request.cc.patch`: ventanas emergentes, `about:blank`), lo que lo haría **una regresión en todos los sistemas**, no solo en Catalina.

Orden, por este orden:
1. Reproducirlo en la 6,1 (Mojave) con la 3.1.1 publicada y un perfil nuevo sin sesión de Google: claude.ai → «Continuar con Google». Lo mismo con la 3.1.0. Así sabemos si es regresión de la 3.1.1 y si es de Catalina o general.
2. Capturar la consola y la red de la ventana emergente (DevTools de la ventana emergente) y `log stream` del proceso; anotar las URL del bucle y el código de error exacto.
3. Entregar a COORDINACIÓN el resultado de 1 y la causa probable. No compiles nada todavía.
