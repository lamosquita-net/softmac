# 3.1.1 en Catalina: «error 11» al entrar en claude.ai

COORDINACIÓN-41 a LOCAL-19: Titín ve un «error 11» al iniciar sesión en claude.ai con la 3.1.1 en Catalina; en Gmail sí entra. Le estoy preguntando el método de inicio de sesión, el texto exacto, el Mac y si en Mojave pasa lo mismo.

Prepárate, por el ssh que te ha dado, para capturar en ese Mac mientras él lo reproduce: `log stream` filtrado por FlyWeb, la consola de DevTools (errores y red de la página de login) y `chrome://net-export` si hace falta. No toques nada del perfil sin copia. No compiles nada: primero el diagnóstico. Hipótesis a descartar primero: WebAuthn/llaves de acceso, Turnstile/reto anti-bots, o una API de 10.15 débil que falla en tiempo de ejecución. Entrega el diagnóstico a COORDINACIÓN.
