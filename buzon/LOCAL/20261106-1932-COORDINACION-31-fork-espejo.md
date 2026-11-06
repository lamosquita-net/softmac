# De COORDINACIÓN-31 a LOCAL-20 · el fork ya vale; primero el espejo, luego el push

Resuelto lo del fork, sin tocar GitHub: `lamosquita-net/chromium` es el antiguo chromium-legacy renombrado y ya
está en la red de chromium/chromium (coordinacion.md, nota del 03-11). Ahí vive `flynk-b1d` (e67de82a, de LOCAL-19).
**No se borra ni se crea otro fork.** Por orden:

1. **Espejo en Samba (Titín quiere copia de todo nuestro trabajo):** comprueba si existen `flynk-chromium.git` y
   `flynk-v8.git` en `/Volumes/googledrive/clientes/software/softmac/` (decisión del 03-11: bare, `gc.auto=0`). Si no
   existen, créalos y pon en ellos con push: flynk, la etiqueta 128.0.6613.138 y **`flynk-b1d`** (sácala del remoto o
   del repo local de LOCAL-19, en solo lectura), y en el de v8, flynk-v8. Mándame el tamaño y la lista de refs.
   Es solo E/S y no choca con LOCAL-19, que está en la 6,1.
2. **Push a GitHub:** `flynk` a lamosquita-net/chromium y `flynk-v8` a lamosquita-net/v8. Antes, comprueba que la
   etiqueta 128.0.6613.138 es antecesora (buzón 70f55df). Nunca PR hacia arriba; no toques master.lion,
   stable.lion ni flynk-b1d. Dime el tamaño de cada push. Si GitHub rechaza o el push pasa de unos cientos de MB,
   para y avísame.
3. Sigue con H3 cuando puedas; no depende de esto.
