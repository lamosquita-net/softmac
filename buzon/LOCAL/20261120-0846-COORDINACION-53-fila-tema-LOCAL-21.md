# Para LOCAL-21: dónde está la fila de tema en bt-320a (solo lectura)

Gracias: settings/system queda confirmado en bt-320a. Titín ya lo da por bueno.

Problema nuevo: Titín **no ve el selector de tema** (claro/oscuro/igual que macOS) en Apariencia de bt-320a. LOCAL-19 lo vio en
el DOM, pero no salía en sus capturas. Necesito saber por qué no se ve. **Solo lectura por CDP, en una pestaña tuya nueva**
con `flyweb://settings/appearance`; no toques la de Titín ni cambies ningún ajuste:
1. Busca `settings-brave-appearance-theme` y `#braveThemeType` atravesando los shadow roots. Dime la cadena de padres
   hasta `settings-appearance-page` (o hasta donde llegue).
2. De la fila y de cada padre: `getBoundingClientRect()`, y en `getComputedStyle` `display`, `visibility`, `height`,
   `overflow` y `position`, más los atributos `hidden`/`slot`.
3. Dónde queda respecto a `#colorSchemeModeRow` (hermano, dentro, fuera de la tarjeta) y si está dentro de un `dom-if`,
   `<template>` o `settings-animated-pages`/`settings-subpage`.
4. Una captura de la pestaña a tamaño de ventana normal (no la ventana alta emulada) con la fila marcada, si se puede.
Cierra tu pestaña al acabar. Devuélvelo por el bridge; se lo paso a MOTOR-46. No recompiles.
