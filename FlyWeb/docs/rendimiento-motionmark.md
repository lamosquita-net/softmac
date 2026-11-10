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

## Reglas `[style…]`: de dónde salen y arreglo (MOTOR-44, 10-11-2026)

Encargo de COORDINACIÓN-38 tras la medida de LOCAL-19. Lectura de código (brave-core `bf4262a094` y `local/3.0.1`
`77ae53e`, iguales en todo lo que importa aquí; Chromium 156.0.8078.90 por gitiles) y **medido en Chromium 153 (Playwright,
contenedor de la nube)**, no en la 7,1.

### 1. Por qué Blink serializa el `style`
- `RuleSet::FindBestBucketAndAdd` (`css/rule_set.cc`, 707–731) mete cada regla en un cubo según el **compuesto de más a
  la derecha**: id, si no clase, si no atributo (el último del compuesto), si no etiqueta. Si el atributo es `style`,
  marca `has_bucket_for_style_attr_`.
- `RuleSetGroup` (`resolver/match_request.cc`, 19–23) pone `need_style_synchronized_` en cuanto **una** hoja del grupo
  tiene ese cubo. Las `adoptedStyleSheets` son del grupo de autor; la hoja de usuario de `InjectStylesheet`, del suyo.
- `ElementRuleCollector::CollectMatchingRulesInternal` (`css/element_rule_collector.cc`, 886–920): con el indicador
  puesto pide `element.Attributes()` en vez de `AttributesWithoutStyleUpdate()`. Eso sincroniza el atributo `style`:
  si el estilo en línea está sucio (cualquier `el.style.x = …`), lo vuelve a escribir como texto. Lo hace para **cada
  elemento en cada recálculo**, aunque ninguna regla llegue a casar. Es la pila que vio LOCAL-19.
- Una regla con clave de clase cuyo último compuesto es `div[style…]` (`.ad-wrap div[style*=…]`) también crea el cubo.
  Una con clase en el último compuesto (`div.x[style…]`) no.

### 2. De dónde salen y cuántas son
- **adblock-rust 0.13.3** (el que lleva la 3.0.x, `third_party/rust/chromium_crates_io/vendor/adblock-v0_13`):
  `add_generic_filter` (`cosmetic_filter_cache_builder.rs`, 92–131) guarda las genéricas que **no empiezan por `.` ni
  por `#`** en `misc_generic_selectors`. También van ahí las que solo tienen dominios negados (`~sitio.com##…`, vía
  `hidden_generic_rule`). `hostname_cosmetic_resources` (`cosmetic_filter_cache.rs`, 338–355) las mete en
  `hide_selectors` de **todas las páginas**, salvo con `$generichide`.
- **brave-core**, `cosmetic_filters_js_handler.cc`, `CSSRulesRoutine`: en modo estándar van a
  `kHideSelectorsInjectScript`, que las añade a `CC.cosmeticStyleSheet` y la adopta en el documento. En modo agresivo,
  `InjectStylesheet`, como hoja de usuario. Las genéricas con clave de clase o id (`HiddenClassIdSelectors`) siguen el
  mismo camino, pero solo cuando la página tiene esa clase o ese id.
- **Recuento** con las listas que empaqueta nuestro servidor (`FlyWeb/servidor/componentes/listas.json`), bajadas el
  10-11 de `brave/adblock-lists-mirror`. Lo hace `FlyWeb/parches/3.1-cosmetic-style/pruebas/contar-style.py`,
  que imita los dos repartos de arriba:

| Lista | Genéricas sin clase ni id (en todas las páginas) | Crean el cubo `[style]` |
|---|---|---|
| Por defecto (Brave Default Adblock + Privacy: uBO, EasyList, EasyPrivacy, Brave…) | 559 | **23** |
| Primera parte (`E99CBD02`) | 87 | 7 (6 repetidas de la anterior) |
| Avisos de cookies (`AC023D22`) | 450 | 1 (repetida) |
| Promociones de apps, español, español y portugués | 31 | 0 |
| **Distintas** | | **24** |

  Basta **una** para que Blink pague el coste. Qué son: **14 capas** invisibles o casi, a pantalla completa o encima de
  un enlace, para secuestrar clics (`z-index: 2147483647`, `opacity: 0.01`, fondo transparente); **6** de
  `quick-fixes.txt` con dominios negados, casi todas huecos de anuncio de tamaño fijo (300×250, 160×600, 728×90,
  `ins[id][style*="--gn-ov-ad-height"]`); y **4** sueltas (Criteo `div[id^="crt-"][style]`, `div[id^="st"][style^="z-index…"]`,
  un `iframe` con `sandbox` y una ventana con `box-shadow`). Lista completa en
  `pruebas/recuento-10-11.txt`. El número cambia con las listas: hay que volver a contarlo, no fijarlo.

**Medida del mecanismo** (`pruebas/medir.js`: 2000 `div` con `style.transform` nuevo en cada pasada y un
`offsetHeight` que fuerza el estilo; mediana de 5; ms por pasada):

| Hoja adoptada | ms |
|---|---|
| ninguna, o una regla de clase | 3,9 |
| `[data-fw…]{display:none}` (el marcador del arreglo) | 3,8 |
| una regla `[style…]` | 12,9 |
| una regla `.ad-wrap div[style*=…]` | 13,1 |
| una regla `div.x[style*=…]` (clase en el último compuesto) | 5,9 |
| las 23 de la lista por defecto | **36,4** |

Con las 23, la pasada de estilo es **9,4 veces** más lenta. Encaja con el 22 % de LOCAL-19 y con que Multiply casi se
doble sin el filtrado. El caso `div.x[style…]` también cuesta algo sin crear el cubo; no lo he investigado, porque el
arreglo lo cubre igual.

### 3. Arreglo que conserva el bloqueo
Parche candidato: `FlyWeb/parches/3.1-cosmetic-style/0001-…patch` (brave-core, sobre `bf4262a094`; aplica también
sobre `local/3.0.1`). **Sin compilar**; no va a ninguna rama de producción.
- En C++, los cuatro caminos (`hide_selectors`, `force_hide_selectors`, clase/id y agresivo) **sacan de la hoja** todo
  selector con `[style` y se lo pasan a `content_cosmetic.ts`. El filtro es más amplio que el reparto de Blink (cubre el
  caso `.ad-wrap div[style…]`).
- En JS se casan en los **nodos añadidos** (el `MutationObserver` que ya existe) y en un **barrido cada segundo**, que
  pilla los `style` cambiados después de insertar y quita la marca a lo que deja de casar. Lo que casa recibe un atributo
  aleatorio por página (`data-fw` + 16 hex) que oculta **una sola regla** de hoja de usuario. Esa regla no crea el cubo
  `[style]` (fila «marcador» de la tabla).
- Modo estándar: los selectores pasan por las mismas colas de primera parte que cualquier genérica
  (`pumpCosmeticFilterQueues`). Si una casa contenido propio, deja de ocultar, como antes. Los `force` y el modo agresivo
  se saltan esa comprobación, como antes.
- `--disable-features=FlyWebDeferStyleAttrSelectors` vuelve al comportamiento de Brave sin recompilar.
- **Probado** (`pruebas/funcional.js`, Chromium 153, con la hoja de usuario emulada por una hoja adoptada): capa
  insertada con el `style` ya puesto, oculta al momento; `style` puesto después, oculta en el siguiente barrido; marca
  quitada cuando el `style` deja de casar; elemento normal, visible; aviso propio con texto (estándar), visible; selector
  no válido, descartado. La pasada de estilo con 2000 `div` baja a 3,5 ms (3,9 sin hoja), y un barrido cuesta 5–6 ms.

**Lo que se pierde en webs reales:**
- Una capa cuyo `style` se pone **después** de insertarla queda visible y clicable hasta **1 s** (el barrido). Es el caso
  típico de los secuestradores de clics, que son 14 de las 24 reglas. Con el `style` puesto
  antes de insertar se oculta al momento, salvo cuando el script ha pasado a sondeo (más de 1000 «puntos» por segundo):
  entonces también hasta 1 s.
- Los elementos ocultados llevan un atributo `data-fw…` **visible para la página**: sale en el DOM y en sus
  `MutationObserver`, y un detector de bloqueadores lo puede ver. La hoja actual no se ve desde la página.
- El barrido cuesta un recorrido del documento por segundo (5–6 ms con 2000 elementos en la nube; más en la 5,1). No se
  hace con la pestaña oculta.
- No cambia: las reglas `:style()` de sitio (`style_selectors`), que solo van a su sitio, ni el resto de genéricas.

**Alternativas, de menos a más pérdida:** (a) este parche; (b) quitar esas 24 genéricas en nuestro empaquetador
(`empaquetar.mjs`), sin tocar el navegador, perdiendo esa protección del todo; (c) dejarlo como está: Brave 1.98 sigue el
mismo camino (MOTOR-43; no lo he medido). **Recomiendo (a), y medirlo antes de decidir:** Multiply y MotionMark con y sin el
flag en la 7,1, y comprobar que una página con capa de clics (cualquiera de las de la lista) sigue tapándola.
**Lo decide Titín.**

### 4. Speedometer −12 % y JetStream −8,5 %: Maglev apagado, primero
La 3.0.x **lleva Maglev apagado**: `patches/v8/src-flags-flag-definitions.h.patch` pone `DEFINE_BOOL(maglev, false…)`
(HUMANO, 05-10; `bf4262a094` y `local/3.0.1`). Chrome 156 lo trae encendido. JetStream es casi todo JS, donde Brave apenas
corre código propio, y ahí es donde más pesa el compilador intermedio. El blog de V8 (5-12-2023, «Maglev - V8's Fastest
Optimizing JIT») solo da las ganancias de JetStream 2 y Speedometer 2 en gráficas, sin cifra en el texto, así que no
pongo número. **Cómo separarlo:** el mismo binario con `--js-flags=--maglev` frente a sin él (Speedometer 3.1 y
JetStream 3, tres pasadas). Lo que quede, con el A/B de PGO que ya está en `plan-3x.md`. Maglev ya tiene su puerta de
seguridad (B6, `DIRECTIVAS.md`), así que esta medida es la (2) de esa puerta.

## Medida de Maglev y del parche `[style…]` (LOCAL-19, 7,1, 10-11-2026)
Órdenes A y B de COORDINACIÓN-38. MacPro7,1, `--headless=new`, perfil nuevo en `/tmp` por caso, puerto 9446, mismos
guiones que la medida anterior (`m71.py`, `caso.sh`), bancos servidos en local. Todo en serie, sin nada más corriendo.

### A. Maglev (sin compilar)
La 3.0.1 publicada (`out/Release`, framework `efbe530f…`, build 42), con `--js-flags=--maglev` y sin él. Tres pasadas.

| 3.0.1 | Speedometer 3.1 | JetStream 3 |
|---|---|---|
| Sin Maglev (como se publica) | **19,36** (19,1 / 19,36 / 19,5) | **168,3** (166,4 / 168,5 / 168,3) |
| `--js-flags=--maglev` | **20,95** (20,6 / 20,95 / 21,0) · +8,2 % | **182,1** (181,3 / 183,2 / 182,1) · +8,2 % |
| Chrome 156 de serie (c0-ch, arriba) | 22,0 | 176,1 |

- **Sin caídas ni errores con Maglev:** 0 `FATAL` / `Check failed` en el registro del navegador y 0 subpruebas de
  JetStream en error, con y sin Maglev.
- Con Maglev, JetStream pasa de −4,4 % frente a Chrome a **+3,4 %**, y Speedometer de −12 % a **−4,8 %**. Maglev cierra
  todo el hueco de JetStream y el 60 % del de Speedometer. Lo que queda de Speedometer es para el A/B de PGO.
- Maglev sigue apagado (decisión de Titín del 05-10); esto solo mide. Es la medida (2) de la puerta B6.

### B. Parche `3.1-cosmetic-style` compilado
- brave-core `local/3.0.1-style` = `77ae53e5f6` + `git am` del `0001` → **`40856a11d15`** (subida a `origin`). Aplica
  limpio.
- Release igual que la 3.0.1 (`porte-build.sh`, PGO, build 42 sin cambiar): incremental, 349/349, **0 FAILED**.
  Framework `fd42df36…`. No se publica.
- **Corrección (LOCAL-19, 10-11 noche):** el árbol de ANGLE estaba en `bc2ebdd` (los cuatro parches de
  `3.1-angle`, de la candidata t4), y esta build recompiló esos ficheros de Metal. El binario es, por tanto, 3.0.1 +
  `3.1-angle` 0001–0004 + este parche. El A/B por flag sigue valiendo, porque es el mismo binario. Con el flag apagado da
  lo mismo que la 3.0.1 publicada (3270 frente a 3332 en MotionMark; Speedometer 18,7 frente a 18,9), así que ANGLE no
  mueve estas dos pruebas.
- El mismo binario con el parche y con `--disable-features=FlyWebDeferStyleAttrSelectors`. Como control, la 3.0.1
  publicada (copia de entregas, `efbe530f`) en la misma tanda.

**Ojo con la 1.ª pasada:** con perfil nuevo, la primera pasada de MotionMark empieza antes de que se carguen las listas
de Shields. En los tres casos salió «como sin filtrado» (Multiply ~2700). Por eso la tabla compara las pasadas 2 y 3, con
las listas ya cargadas. La 1.ª va entre paréntesis.

| MotionMark 1.3.2 (pasadas 2 y 3) | Total | Multiply |
|---|---|---|
| Con el parche | **3683 / 3781** (1.ª 3690) | **2715 / 2830** (1.ª 2717) |
| Mismo binario, flag apagado | 3218 / 3322 (1.ª 3659) | 1466 / 1493 (1.ª 2711) |
| 3.0.1 publicada (control) | 3302 / 3362 (1.ª 3561) | 1498 / 1507 (1.ª 2689) |
| Referencia: 3.0.1 sin filtrado cosmético (c1-cosm, arriba) | 3701 | 2723 |

| Speedometer 3.1 (3 pasadas) | Mediana |
|---|---|
| Con el parche | 19,2 (19,2 / 19,2 / 18,45) |
| Flag apagado | 18,7 (18,5 / 18,95 / 18,7) |
| 3.0.1 publicada | 18,9 (18,6 / 19,0 / 18,9) |

- **MotionMark +12 % y Multiply +84 %** frente a la 3.0.1 (medias de las pasadas 2 y 3: 3732 frente a 3332; 2773
  frente a 1503). Queda al nivel de apagar todo el filtrado cosmético (c1-cosm), pero sin perder el bloqueo.
- Con el flag apagado, el binario se comporta como la 3.0.1: el A/B por flag es válido.
- **Speedometer no cambia** (19,2 / 18,7 / 18,9: dentro del ruido). El parche solo arregla MotionMark.
- 0 `FATAL` / `Check failed` en todos los registros.

**Sigue bloqueando:**
- `pruebas/funcional.js`, pasada en la FlyWeb compilada en vez de en el Chromium de playwright (aquí no hay playwright
  y no se descarga nada). Mismo cuerpo de `p.evaluate`, el `kStyleAttrSelectorsInjectScript` sacado del `.cc` compilado
  y el bundle real (`gen/brave/web-ui-cosmetic_filters/cosmetic_filters.bundle.js`). Guion: `funcional71.py`.
  - Estándar: `invalid_dropped`, `propio_1p_visible`, `insertado_oculto`, `tarde_tras_barrido`, `tarde_desmarcado` y
    `normal_visible`, todos **true**. `tarde_al_momento` es false, como se espera: el `style` puesto después espera al
    barrido de 1 s. Pasada de estilo 3,59 ms, barrido 5 ms. Sin errores de página.
  - Agresivo: lo mismo, salvo `propio_1p_visible` false (el agresivo también oculta lo propio, como antes). 3,62 ms,
    barrido 4 ms.
  - Coincide con lo que MOTOR-44 obtuvo en Chromium 153.
- **Con listas reales:** página en `prueba.test` con la regla genérica de la lista por defecto
  `body > div[style="position: fixed; inset: 0px; z-index: 2147483647; background: transparent; cursor: pointer;"]`.
  Lleva una capa puesta en el HTML, otra insertada a los 1,5 s y un `div` normal, y las capas llevan una imagen de otro
  dominio, porque en modo estándar una capa vacía cuenta como contenido propio y no se oculta, con parche o sin él.
  - Con el parche y con el flag apagado: las dos capas quedan en **`display: none`** en cuanto llegan las listas
    (~20 s con perfil nuevo); el `div` normal, visible.

Guiones y resultados en la 7,1: `temp/local19/m71/` (casos `a0-sin-maglev`, `a1-maglev`, `b0-style`, `b1-style-off`,
`b2-301-control`) y `temp/local19/style/` (`funcional71.py`, `e2e71.py`, `f71/`).

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
- MOTOR-44: Chromium 156.0.8078.90 (`css/rule_set.cc`, `css/resolver/match_request.cc`,
  `css/element_rule_collector.cc`); adblock-rust 0.13.3 vendorizado en brave-core; `patches/v8/` de brave-core;
  `list_catalog.json` de `brave/adblock-resources` y las listas de `brave/adblock-lists-mirror` (10-11-2026);
  v8.dev/blog/maglev (leído para comprobar que no da cifras en el texto).
