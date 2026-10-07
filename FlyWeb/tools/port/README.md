# Herramientas de port del motor (NUBE)

Las usa NUBE para portar funciones de Chromium 117+ a la base 116 como parches de brave-core (`patches/*.patch`, un
fichero de Chromium por parche, diff `--full-index` contra 116.0.5845.188). Las rutas están fijadas a `/home/user/` y
`/tmp/claude-0/port/`: copiar estos ficheros a `/tmp/claude-0/port/` antes de usarlos.

## Entorno (montarlo una vez por sesión, ~30 GB; el clon de Chromium crece con cada descarga)

| Ruta | Qué | Cómo |
|---|---|---|
| `/home/user/brave-core` | fork `lamosquita-net/brave-core` | clon normal; trabajar en `nube/*` |
| `/home/user/chromium/chromium` | historia de Chromium para `git show <commit>`, `git log --grep` | `git clone --filter=tree:0 --no-checkout https://github.com/chromium/chromium` (y `git fetch origin tag 116.0.5845.188 tag <N>…`). **Cada `git show` de un fichero descarga un paquete pequeño**: en una sesión llegaron a 18 000 paquetes y 26 GB. `git log` con rutas es lentísimo (sin árboles); `--grep` sin rutas va en ~5 min. |
| `/home/user/cr116` | copia parcial de la 116 para grep | `git clone --filter=blob:none --sparse … ; git sparse-checkout set third_party/blink/{public,renderer} gin content/{common,public/renderer,renderer} extensions/renderer pdf chrome/renderer components services/accessibility; git checkout 116.0.5845.188` |
| `/home/user/v8` | historia de V8 para `v8re.sh` | `git clone --filter=tree:0 --no-checkout https://github.com/v8/v8` |

## Scripts

- `portar.sh <nombre> <commit>…` — monta `w-<nombre>` con los ficheros de la 116 + los parches de la rama de brave-core
  que esté en `/home/user/brave-core`, y aplica los commits en orden (sin tests). **Ojo:** si dos commits fallan en el
  mismo fichero, el `.rej` del segundo pisa al primero; cada commit del área de trabajo guarda los suyos
  (`git show <commit>:<fichero>.rej`). Con `STEP=1` solo monta y guarda los diffs.
- `mkws.sh <nombre> <fichero>…` — igual pero para portes a mano (sin commits de upstream).
- `generar.sh <nombre>` — escribe los `.patch` de `w-<nombre>` en `brave-core/patches` (diff desde la 116, incluye lo de Brave).
- `fixnew.sh` — lo llama `generar.sh`: rehace un parche de «fichero nuevo» si el fichero sí existe en la 116.
- `chk.sh <rama>` — comprueba que todos los parches de la rama aplican sobre la 116 (el único aviso conocido es el
  espacio final de `ui-views-controls-menu-menu_separator.cc.patch`, que aplica igual).
- `addflag.py <json5> <Nombre> <status>` — inserta una flag en `runtime_enabled_features.json5` en orden.
- `v8re.sh <rev origen> <rev destino>` — rehace `patches/v8/*.patch` al cambiar de V8 (`FlyWeb/v8-revision`).
- Generador de bindings sin compilar: `../bindings/`.

## Lecciones (niveles 117–124)

- Antes de portar un nivel: comparar la API pública de V8 (`include/`) con Blink/gin/content de la 116, y vigilar los
  `#include` transitivos (`v8-context.h`).
- Si una serie de upstream se apoya en refactors que la 116 no tiene, portar **el comportamiento final** a mano (Shadow DOM
  clonable, iterables asíncronos) en vez de arrastrar la cadena de refactors.
- Las flags que un commit añade y otro quita: dejar la flag en `stable` si quitarla arrastra refactors.
- En la 116 `WebThemeEngine::ExtraParams` es una `union`: sin inicializadores por defecto en sus structs.
- Contadores de uso (`web_feature.mojom`): valores de upstream, insertados en orden (`kNumberOfFeatures` = máx + 1).
