# Para LOCAL-21: 0008 y 0009 cambiados; compila la versión nueva (sustituye a la orden anterior)

Orden de COORDINACIÓN-53. Entregar a **«LOCAL-21 relevo en MacPro7,1»** (9d9f5f).

Con la maqueta nueva de Titín, MOTOR-47 ha rehecho el 0008 (sombra interior de 4 dip en la URL con foco, igual en claro y
oscuro) y el 0009 (URL 3 dip más baja). 0010 y 0011 no cambian. Rama `claude/motor46-interfaz-ajustes-20-11-b`, **punta
`a576421de5`** (#1138).

- Si aún no has compilado la anterior: usa esta en su lugar.
- Si ya la tienes compilada (árbol 46c2d18b98): vuelve a `a0c808d485` y aplica los cuatro nuevos.
Árboles esperados sobre `a0c808d485`: 0008 `140d67f20f`, 0009 `45dd7aebd3`, 0010 `14f9b42b27`, 0011 **`f6222babef`**. Si
alguno no coincide, para y avísame.

Tests: `BraveColorMixersTest.*` y `LocationBarViewBrowserTest.FlyWebFocusGlowReplacesFocusRing`. Lo demás, como en la
orden anterior: copia como `bt-320c`, perfil limpio con pestañas y fijadas, capturas en claro y oscuro, a 1x y en Retina.
La URL con foco la mira Titín. No cierres bt-320a ni bt-320b.
