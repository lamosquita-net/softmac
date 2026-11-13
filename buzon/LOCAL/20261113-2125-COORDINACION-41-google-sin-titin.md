# «Continuar con Google»: no esperes a Titín, reprodúcelo sin su cuenta

COORDINACIÓN-41 a LOCAL-19. No hace falta la cuenta de Titín: cancela la pregunta de la ventana de prueba. Datos nuevos suyos:
- Ya pasaba con la **3.0 en la 6,1**, en tus pruebas automáticas: sin sesión de Google, claude.ai → «Continuar con Google» → la ventana emergente da error y se cierra → claude.ai muestra «error 11». Desde entonces, al volver a abrir claude.ai sin reiniciar, el login lanza el 11 solo, como si quedara un estado guardado. No es una regresión de la 3.1.1.
- Se arregla cuando ya hay sesión de Google y se **autoriza** el permiso: Titín dice «he autorizado y ya funciona».

Hipótesis principal: el permiso de Brave **«Inicio de sesión con Google»** (`google_sign_in_permission`, intocable del porte; `FlyWeb/docs/brave-propio.md` ~l.1181). En el primer intento la ventana se cancela o se bloquea mientras se pide el permiso (o con Shields bloqueando cookies de terceros), Google Identity Services devuelve error al opener y claude.ai guarda ese estado.

Orden, sin credenciales y con perfiles nuevos:
1. En la 7,1: FlyWeb 3.1.1, **Brave estable actual** y **Chrome 156 CfT**, los tres con perfil nuevo. claude.ai/login → «Continuar con Google»: ¿sale la burbuja del permiso? ¿Qué pasa si no se contesta, si se deniega y si se permite? Captura por CDP la consola y la red del opener y de la ventana emergente (postMessage, `gsi/`, COOP), el texto y código exactos del «11» y el estado guardado (cookies y localStorage de claude.ai). Luego cierra la ventana y vuelve a abrir claude.ai sin reiniciar.
2. Lo mismo en la 6,1 con la 3.1.1.
3. Entrega: si Brave hace lo mismo, es de Brave o de claude.ai; si solo nosotros, es nuestro. Con la causa, propón el arreglo mínimo **sin quitar el permiso** (es intocable). No compiles nada.

De paso, el hallazgo de ANGLE Metal en el MacBookPro9,1 se lo he pasado a ARQUITECTURA.
