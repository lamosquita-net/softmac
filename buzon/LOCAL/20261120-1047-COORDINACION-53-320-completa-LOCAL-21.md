# Para LOCAL-21: compilar la 3.2.0 COMPLETA de prueba (bt-320e)

Orden de COORDINACIÓN-53. Entregar a **«LOCAL-21 relevo en MacPro7,1»** (9d9f5f). **Sustituye a la orden de bt-320d**: si ya
compilaste las fijadas sobre f6222babef, aprovéchalo como incremental, pero el objetivo es esto.

Titín no ve el sync nuevo porque las bt-320* solo llevaban la interfaz. Ahora va **todo el contenido de la 3.2.0**. Es una
build de prueba: no se publica y no se cambia `chrome/VERSION` ni la versión de FlyWeb (eso lo decide Titín).

**brave-core, sobre `local/3.1.4` e660929ac9, con `git am` en este orden** (árbol al final de cada bloque; los intermedios
están en el mensaje de MOTOR-47 y en los README):
1. `FlyWeb/parches/3.2-interfaz/` 0001–0007 → `6653db38fb`
2. `3.2-ajustes-sistema/` 0001–0004 (main) → `a0c808d485`
3. `3.2-interfaz/` 0008–0013, rama `claude/motor46-interfaz-ajustes-20-11-b` punta `faf01581a1` (#1138) → `78658d3433`
4. `3.2-fijadas/` 0001, rama `claude/motor47-fijadas-refresco` punta `138f4ea8e7` (#1142) → `5f100e4476`
5. `3.2-sync-cuenta/` 0001–0011 (main) → `607662ea2d`
6. `FlyWeb/seguridad/pendiente/brave-core/0001` (main) → `d2dc281eb0`
7. `3.2-v8/` 0001–0002, rama `claude/motor47-v8-epoca` punta `b76f3410d9` (#1144; ieee754 y kFlyWebCacheEpoch 37→38) →
   **`612c201d14` = árbol final**
Si un árbol no coincide, para y avísame.

**chromium:** `e7162cd585` + `seguridad/pendiente/chromium` 0001–0005 → `a9b357bc47`, y encima `3.2-renderer-webgl` 0001–0002.
Apunta el árbol resultante. **ANGLE:** + `pendiente/angle/0001` → `fb21437e81`. **Skia:** + `pendiente/skia` 0001–0003 →
`1ef25455d7`. V8: nada suelto (entra por `patches/v8` del paso 7).

**Compilación:** en un `out/` nuevo (por ejemplo `out/Completa320`), sin tocar `out/Interfaz320`. Riesgos: sync-cuenta y
ajustes-sistema tocan los dos la WebUI de ajustes y nunca se han compilado juntos; fijadas es la primera inclusión de
`browser_ui_controller.h` en brave-core. Si falla, avísame con el error exacto.

**Pruebas:** `BraveColorMixersTest.*`, `LocationBarViewBrowserTest.FlyWebFocusGlowReplacesFocusRing`,
`SharedPinnedTabServiceBrowserTest.*`, las de la sync (P1–P26 de su README) y, si puedes, mjsunit `math`/`es6/math-*`.
Settings: system, atajos, Apariencia (selector de tema primero en «Aspecto») y «Cuenta y sincronización».

**Para Titín:** cópiala a la 6,1 como **bt-320e**, con perfil limpio y las webs de siempre (elpais, eldiario.es, youtube,
wikipedia; dos fijadas, en dos ventanas). Es un binario nuevo: avísame cuando esté para decirle que lo apruebe en LuLu. La
sync con cuenta usa el servidor de ns2. No cierres bt-320a, b ni c.
