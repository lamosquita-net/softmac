# MotionMark: por qué la 3.0.0 pierde en Multiply, Leaves y Suits

MOTOR-43, 10-11-2026, por encargo de COORDINACIÓN-38. **Solo lectura de código, nada medido.** Parte del hito 0 de la 7,1
([`rendimiento-3x.md`](rendimiento-3x.md) §1.1): sin ventana, la 3.0.0 frente a Chrome 157 da Multiply −48 %, Leaves −24 %,
Suits −22 % y Design −13 %; Canvas Arcs, Paths, Canvas Lines e Images empatan.

**Lo que dice el patrón:** pierden las pruebas que **crean y quitan muchos nodos del DOM** a cada cambio de complejidad:
Multiply (`div`), Leaves (`img`), Suits (SVG) y Design (texto). Las de **canvas**, que dibujan en un solo elemento, empatan.
El raster por GPU (Graphite) y la composición no parecen el problema: los usan todas las pruebas. Lo que solo pagan las
que mueven el DOM es el **hilo principal del renderer**.

## Hipótesis, por orden

### H1. El filtrado cosmético de Shields (lo más probable)
- `components/cosmetic_filters/resources/data/content_cosmetic.ts` se inyecta en **todas** las páginas con Shields
  activo, 127.0.0.1 incluido. Lo hace `BraveContentRendererClient::RenderFrameCreated`, si
  `BraveAdblockCosmeticFiltering` está activo (por defecto lo está).
- Pone un `MutationObserver` sobre `document.documentElement` con `subtree`, `childList` y los atributos `id`/`class`.
  En cada lote de mutaciones:
  - recorre los nodos añadidos;
  - hace `querySelectorAll('[id]…,[class]…')` en cada subárbol;
  - pide reglas nuevas al proceso del navegador (IPC, con un tope de una cada 100 ms).
- Si en un segundo pasa de 1000 «puntos» (`switch_to_polling_threshold`), cambia a **sondeo**: durante 10 s hace
  `querySelectorAll` del **documento entero** cada 500 ms. Luego vuelve al observador.
- MotionMark sube la complejidad añadiendo cientos o miles de elementos por fotograma: justo lo que dispara esto. Ese
  tiempo sale del presupuesto de 16,7 ms del fotograma, y el controlador de MotionMark lo lee como «no aguanta más
  complejidad».
- Encaja también con **Speedometer −13 %**, que crea y destruye DOM sin parar (TodoMVC).
- Brave 1.98 tiene el mismo mecanismo; nuestra copia es más antigua, pero la estructura es igual. Chrome no tiene nada
  parecido, así que la comparación con Chrome no es limpia: hay que medir con el filtro y sin él.

### H2. `performance.now()` redondeado a 1 ms (`BraveRoundTimeStamps`)
- `chromium_src/third_party/blink/renderer/core/timing/time_clamper.cc` deja la resolución de `TimeClamper` en
  **1000 µs**, frente a los 5 µs o 100 µs de Chrome. Eso redondea `performance.now()` y las marcas de tiempo de rAF y de
  eventos.
- **Diverge de Brave 1.98:** allí `kBraveRoundTimeStamps` está **apagado** por defecto. En nuestro
  `chromium_src/third_party/blink/common/features.cc` está **encendido** (`FEATURE_ENABLED_BY_DEFAULT`), como en un
  Brave anterior.
- MotionMark decide la complejidad midiendo la duración de los fotogramas con esas marcas. Con 1 ms de grano, un
  fotograma de 16,7 ms se lee como 16 o 17, y el controlador puede ser más conservador.
- **Contra esta hipótesis:** también afectaría a las pruebas de canvas, que empatan. Por eso va segunda. Pero es una
  diferencia real con Brave 1.98 y se comprueba con un solo flag.

### H3. Versión: Chrome 157 frente a la base 156
- El hito 0 se midió contra Chrome **157**. Con ventana, [`comparativa-71.md`](comparativa-71.md) daba la 3.0.0 a −7,4 %
  de Chrome **156** en MotionMark (3576 frente a 3861), la mitad del −14,7 % de ahora.
- Parte del hueco puede ser de Blink 157 (estilo, layout, paint). Lo separa la repetición de LOCAL-19 con Chrome 156.

### H4. PGO de Google sobre un árbol que no es el de Google
- La 3.0.0 usa el perfil PGO de Chromium 156 sobre un árbol con Brave y FlyWeb. Las funciones que cambiamos o que se
  mueven pierden el perfil.
- En el renderer (Blink, V8) los cambios son pocos, así que debería pesar poco. Se ve también en la comparación con
  Chrome 156: si con H1 y H2 descartadas sigue habiendo hueco en Speedometer y JetStream, apunta aquí.
  `b1d/pgo-mojave.md` ya lo apunta para ANGLE.

### H5. Configuración de GPU sin ventana
- El hito 0 dice «Skia Graphite» para los dos, pero hay que confirmarlo en esas mismas condiciones (`--headless=new`):
  backend de Graphite (Metal o Dawn), «Rasterization: Hardware accelerated», OOP-R, y ningún «Software only». Una
  diferencia ahí afectaría también a Canvas, que empata, así que es poco probable.
- En la 7,1 no aplica ninguno de nuestros parches de 10.14 (Metal 2.1, `supportsFamily`).

### Descartado: los parches de `FlyWeb/parches/3.1-angle/`
- Solo tocan el backend Metal de **ANGLE**, que en la 3.x usa WebGL. El CSS, el SVG y el 2D de MotionMark van por Skia
  Graphite sobre Metal directamente, sin ANGLE.
- No mejoran ni empeoran estas pruebas. Ya se verá en la medida de la candidata 3.1, pero no es su objetivo.

## Qué medir (LOCAL, 7,1, mismas condiciones que el hito 0)

Un paso cada vez, FlyWeb 3.0.0 sin ventana como en §1.1, **tres pasadas, mediana**. MotionMark completo, o solo
Multiply, Leaves, Suits y Design desde `developer.html`.

| Paso | Lanzar FlyWeb con | Si la hipótesis es buena |
|---|---|---|
| 0 | nada (referencia del día) | — |
| 1 (H1) | `--disable-features=BraveAdblockCosmeticFiltering` | Multiply, Leaves, Suits y Design se acercan a Chrome; Canvas no cambia. Repetir Speedometer: debería subir |
| 2 (H2) | `--disable-features=BraveRoundTimeStamps` | Sube MotionMark en general, o se estrecha la dispersión |
| 3 | los dos a la vez: `--disable-features=BraveAdblockCosmeticFiltering,BraveRoundTimeStamps` | Lo que quede es H3, H4 o H5 |
| 4 (H3, H4) | paso 3 frente a **Chrome 156** (la repetición de LOCAL-19) | Si queda hueco con la misma base: H4, PGO |
| 5 (H5) | volcar `chrome://gpu` de los dos sin ventana (por CDP, el texto de la página) y comparar | Diferencia en Graphite, raster u OOP-R |

**Confirmación barata de H1 sin repetir benchmarks:** con Multiply en marcha, un `sample` del proceso renderer
(`--type=renderer`) de 10 s. Hay que buscar:
- `MutationObserver` / `V8MutationCallback`;
- `querySelectorAll` (`SelectorQuery`);
- el mundo aislado de Brave (`ISOLATED_WORLD_ID_BRAVE_INTERNAL`);
- el IPC `UrlCosmeticResources` / `HiddenClassIdSelectors`.

Si se ve más de un par de % del hilo principal, H1 queda confirmada.

## Parche candidato: depende de la medida

Ninguna hipótesis está «clara» sin medir. No dejo parche hecho, solo los dos cambios preparados.

- **Si H2 se confirma:** poner `kBraveRoundTimeStamps` en `FEATURE_DISABLED_BY_DEFAULT` en
  `chromium_src/third_party/blink/common/features.cc`, como Brave 1.98. Es una línea.
  - Contrapartida: se vuelve a la resolución de tiempo de Chrome, de 5 µs con aislamiento entre orígenes y 100 µs sin
    él. Es la protección por defecto de Chromium, la misma que deja Brave 1.98.
  - **Lo decide Titín** (privacidad frente a fidelidad de tiempos).
- **Si H1 se confirma:** el filtrado cosmético es una función de Shields, no un fallo. Opciones, de menos a más
  intrusiva:
  - (a) subir `switch_to_polling_threshold` y espaciar el sondeo. Ojo: es un parámetro de feature y no lo podemos
    cambiar por variations, porque las tenemos inertes;
  - (b) que el sondeo no recorra el documento entero, sino solo los nodos añadidos desde la última pasada;
  - (c) cambiar la copia del script por la de Brave 1.98, si al medirla cuesta menos.

  Todas reducen algo la ocultación de anuncios en webs muy dinámicas. Antes de tocar nada conviene medir lo que cuesta
  en webs reales (claude.ai, YouTube, Maps) con un `sample` del renderer, y no solo en MotionMark.
- **Si H3 o H4:** nada que hacer en el código. H3 llega con el nivel 157 de la 3.x; H4 es la fila 6 de
  `rendimiento-3.1.md` (PGO propio).

## Fuentes leídas
- brave-core `nube/b2-porte-t11` bf4262a094 (el código de la 3.0.0):
  - `components/cosmetic_filters/resources/data/content_cosmetic.ts` (observador, sondeo, umbrales);
  - `components/cosmetic_filters/renderer/cosmetic_filters_js_handler.cc` (`ProcessURL`, parámetros);
  - `renderer/brave_content_renderer_client.cc` (inyección);
  - `components/content_settings/renderer/brave_content_settings_agent_impl.cc` (`IsCosmeticFilteringEnabled`);
  - `components/brave_shields/core/common/features.cc` (umbral 1000, sondeo y throttling);
  - `chromium_src/third_party/blink/common/features.cc` y `…/timing/time_clamper.cc`.
- Brave 1.98.63 (`brave/brave-core`, solo lectura): el mismo script y las mismas features; `kBraveRoundTimeStamps`
  apagado.
- `FlyWeb/scripts/build.sh` (args de gn: nada de raster, compositor ni Skia) y
  `FlyWeb/policies/flyweb-policies.mobileconfig` (solo Safe Browsing, Wallet y Rewards).
