# FlyWeb 1.11.2 — JavaScript de Chrome 128 con seguridad al día (LOCAL-2, 13-10-2026)

**Estado:** Release **157.64.18** de brave-core `seg/v8-12.8` **5aa57049f** (= la 1.11.1 con la huella de red, + V8 12.8
y los bindings de Blink sobre su API, FM.17, + los arreglos de seguridad de SEGURIDAD-PORTES, FS.10). Probado con ASan
(limpio). Entrega a PUBLICACIÓN en la fila FM.16 del tablero (regla 11). Detalle técnico: `v8-12.8-blink.md`,
`FLYWEB-SECURITY.md` de brave-core.

| Dato | Valor |
|---|---|
| Versión visible / `CFBundleVersion` | 1.11.2 / 157.64.18 (`FLYWEB_BUILD_NUMBER=18`) |
| Nivel declarado | Chrome 127 (sin cambios) |
| Motor JavaScript | V8 12.8.374.38 con los arreglos de seguridad de FlyWeb (época de caché 12) |
| Encontrado y arreglado en el camino | un fallo de V8 12.8 con las microtareas que dejaba YouTube sin responder (V8 3349cb9fd) |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Motor de JavaScript más reciente y más seguro.** El motor que ejecuta el JavaScript de las webs pasa a ser el de
  Chrome 128, con las correcciones de seguridad que le aplican. Las webs con mucho JavaScript (YouTube, Gmail, Google
  Docs…) funcionan igual que antes.
- **El nivel declarado sigue siendo Chrome 127.** Las webs ven a FlyWeb igual que con la 1.11.1; lo nuevo del nivel 128
  llegará con la 1.12.
- **Se mantiene todo lo de la 1.11.1**: las webs protegidas contra bots siguen abriéndose directamente.

Nada cambia en los ajustes ni en los datos del usuario. Al actualizar, la caché de código de JavaScript se regenera sola
(primeras visitas un poco más lentas).
