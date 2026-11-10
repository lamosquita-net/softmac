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

## Medida (LOCAL-19, 7,1, 10-11-2026)

Medido sin ventana, con las mismas condiciones y el mismo guion que el hito 0 de la 7,1 ([`rendimiento-3x.md`](rendimiento-3x.md) §1.1 y §1.1 bis), 3 pasadas por caso, **un cambio cada vez** y siempre con la **FlyWeb 3.0.1** (198.63.42, Chrome/156.0.8078.98, PGO). La referencia es **Chrome for Testing 156.0.8078.80**, la de serie y con `--disable-field-trial-config` (ver la nota de abajo). Mediana de 3; entre paréntesis, la dispersión (máx. − mín.) / mediana.

| Paso | Caso | MotionMark | Multiply | Leaves | Suits | Design | Canvas Arcs | Speedometer 3.1 |
|---|---|---|---|---|---|---|---|---|
| 0 | 3.0.1 tal cual | **3202** (1,3 %) | 1374 | 1442 | 1899 | 323 | 18652 | **17,9** (3,9 %) |
| 1 (H1) | `--disable-features=BraveAdblockCosmeticFiltering` | **3701** (2,5 %) | **2723** | **1886** | 2022 | 348 | 18801 | **18,9** (1,6 %) |
| 2 (H2) | `--disable-features=BraveRoundTimeStamps` | 3210 (0,2 %) | 1409 | 1416 | 1871 | 296 | 18620 | 18,8 (4,8 %) |
| 3 | los dos | **3787** (4,2 %) | **2795** | **2012** | 1993 | 334 | 19104 | **19,1** (4,3 %) |
| 4 | Chrome 156 de serie | 3373 (4,8 %) | 2599 | 1926 | 1822 | 319 | 14588 | 22,0 (2,8 %) |
| 4 | Chrome 156 sin pruebas de campo | **3786** (5,5 %) | 2870 | 2088 | 1959 | 346 | 19438 | **21,7** (1,8 %) |
| extra | 3.0.1 con `--enable-features=EnableDrDc,TreesInViz` | 3227 (1,9 %) | 1446 | 1451 | 1850 | 308 | 18661 | sin medir |

Lectura:
- **H1 confirmada.** Sin el filtrado cosmético, MotionMark sube un 15,6 % y Multiply casi se dobla (de 1374 a 2723).
  Leaves sube un 31 %. Las pruebas de canvas no cambian, como se esperaba. Speedometer sube un 5,6 % (de 17,9 a 18,9),
  menos de lo que se esperaba.
- **H2 no influye en la puntuación:** 3210 frente a 3202, y Speedometer 18,8. Sí se nota en la dispersión de
  MotionMark: 0,2 % con el redondeo apagado, frente al 1,3 % normal. Junto a H1 añade un poco (3787 frente a 3701,
  dentro del ruido).
- **Con H1 y H2 apagadas, la 3.0.1 iguala a Chrome 156 en MotionMark:** 3787 frente a 3786, y todas las pruebas
  quedan dentro de un ±5 %. **H3 (versión) y H5 (GPU) quedan descartadas en MotionMark.**
- **Speedometer sigue −12 %** (19,1 frente a 21,7) y JetStream −8,5 % (161,1 frente a 176,1, §1.1 bis), sin DOM
  dinámico de por medio. Lo que queda es H4 (PGO) u otra cosa de Brave fuera de estas dos features; está sin separar.
- **Paso 5 (H5), `chrome://gpu` de los dos sin ventana:** igual en lo que importa. Los dos usan Skia Graphite con
  backend `GraphiteDawnMetal`, «Rasterization: Hardware accelerated», «Multiple Raster Threads: Enabled» y WebGL por
  ANGLE Metal (W6600X). Las únicas diferencias son tres, y salen de `fieldtrial_testing_config`, que Chrome for
  Testing aplica de serie: «Direct Rendering Display Compositor» (EnableDrDc), «TreesInViz» y «WebGPU». Las tres
  están encendidas en Chrome y apagadas en FlyWeb. Con `--disable-field-trial-config` quedan igual que en FlyWeb, y
  Chrome **sube** de 3373 a 3786, sobre todo en Canvas Arcs y Paths. Encenderlas en FlyWeb no cambia nada (3227). Es
  decir, sin ventana alguna de esas pruebas de campo le cuesta a Chrome; FlyWeb no pierde nada por no tenerlas.

**`sample` del renderer durante Multiply** (10 s, unos 25 s después de arrancar MotionMark, con la build de la
candidata 3.1 t4: `symbol_level=1`, el mismo Blink y V8 que la 3.0.1 y solo ANGLE y la NTP cambiados; filtrado
cosmético encendido). Hilo principal: 6943 muestras, de ellas 5297 activas.
- `MutationObserver` / `V8MutationCallback`, `querySelectorAll` / `SelectorQuery` y «cosmetic» **no aparecen**: 0 muestras. El
  mundo aislado de Brave, 1 muestra.
- El 78 % del hilo activo va a `BeginMainFrame` → `UpdateAllLifecyclePhases`; el estilo (`StyleEngine::RecalcStyle`) se
  lleva el 51 %. Dentro de él, **1171 muestras (22 % del activo)** van a
  `ElementRuleCollector::CollectMatchingRules` → `Element::SynchronizeAllAttributes` →
  `SynchronizeStyleAttributeInternal` → `StylePropertySerializer::AsText` → `CSSValueList::CustomCSSText`.
  Es decir: **en cada recálculo de estilo se vuelve a escribir como texto el atributo `style` de cada elemento** que
  MotionMark mueve con `style.transform`.
- Por qué: `third_party/blink/renderer/core/css/element_rule_collector.cc` (unas 888–920) solo sincroniza el atributo
  `style` antes de casar reglas **si alguna hoja tiene un selector de atributo `[style…]`**. El comentario del código lo
  llama «extremely unusual» y «fairly expensive». MotionMark, servido en 127.0.0.1, no tiene ninguno. La candidata
  natural es la **hoja de ocultación genérica que inyecta el filtrado cosmético**: las listas de filtros traen
  selectores como `[style*="…"]`. Con una sola regla así en el documento, Blink serializa el `style` de cada elemento en
  cada fotograma. Encaja con que apagar `BraveAdblockCosmeticFiltering` doble Multiply. **No está comprobado** qué hoja
  ni qué regla. Lo siguiente sería, durante Multiply, buscar `[style` en `document.styleSheets` y en las hojas
  inyectadas (`adoptedStyleSheets` o las hojas de usuario del navegador), y repetir el `sample` con el filtro apagado.
- Así que el coste de H1 en MotionMark **no es el `MutationObserver` ni el sondeo con `querySelectorAll`** que
  describe la hipótesis (en esta página no salen), sino, muy probablemente, el **CSS inyectado con selectores `[style…]`**.
  Afecta a las opciones de arreglo (a)–(c) de arriba, que tocan el observador y el sondeo: habría que añadir otra, (d) quitar o reescribir las reglas genéricas `[style…]` de la hoja inyectada (o inyectarlas solo con coincidencias concretas).

Ficheros (fuera del repo): `temp/local19/m71/` en la 7,1, con los guiones (`lanzar.sh`, `m71.py`, `caso.sh` y
`todo3.sh`), los resultados de cada caso en `c*/resultados.json`, `chrome://gpu` en `c0-fw/`, `c0-ch/` y
`c4-ch-sinft/` (`gpu.txt` y `gpu.png`) y el `sample` en `c6-multiply-sample.txt`.

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
