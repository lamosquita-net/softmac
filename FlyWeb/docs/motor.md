# FlyWeb — evolución del motor (fase M, decidida el 04-10-2026)

## Decisión (HUMANO, 04-10)

Hacer crecer el motor de la 116 **función a función**, en lugar de cambiarlo. No se pasa a Chromium Legacy: está
parado desde mayo de 2024 (última estable 124.0.6367.207, último canary 127.0.6494;
[releases](https://github.com/blueboxd/chromium-legacy/releases),
[discusión #274](https://github.com/blueboxd/chromium-legacy/discussions/274)), y cambiar de base obligaría a portar
brave-core y los 45 pasos de FlyWeb para ganar 8 versiones y volver a quedarse parados.

> **Cambio de base (HUMANO, 20-10):** la base pasa a la 128 (FlyWeb 2.0.0), la última que se toma de fuera; desde
> ella FlyWeb es un fork que sigue creciendo por niveles con este mismo método (idea rectora en
> [`docs/DIRECTIVAS.md`](../../docs/DIRECTIVAS.md); plan en [`migracion-128.md`](migracion-128.md)). Hasta la 2.0.0, lo
> de abajo vale tal cual sobre la 116; el principio 9 («la base no se mueve») deja de valer en el salto a la 128.

## Principios

1. **El CSS y casi todo Blink no dependen de macOS.** Son C++ sin Cocoa ni Metal; Chromium dejó Mojave por la GPU,
   el vídeo, la captura de pantalla y el SDK. Lo que separa la 116 de una función nueva es la antigüedad del código,
   no Mojave. Donde sí hay dependencia del sistema (barras de desplazamiento nativas, corrector, vídeo, GPU, fuentes),
   se estudia caso por caso.
2. **Objetivo: las funciones Baseline** (las que ya funcionan en Chrome, Safari y Firefox), porque son las que usan las
   webs. Las que solo tiene Chrome se dejan para cuando una web importante las exija.
3. **Niveles por versión de Chrome.** El nivel *N* está completo cuando FlyWeb tiene todo lo Baseline que Chrome
   publicó hasta la *N*: CSS portado o encendido, JavaScript con polyfills (componente firmado en bak) y las API que
   importen.
4. **Versión declarada = nivel real.** El User-Agent y los Client Hints dicen la versión del último nivel completo, no
   más: si una web cree que somos la 120, es porque lo somos en lo que usa. **Y a todas las webs igual** (HUMANO,
   04-10): sin excepciones por sitio; si una web nos rechaza, es un dato de qué nivel necesita. (FlyWeb 1.1: 117.)
5. **Flags, caso por caso, nunca en bloque.** Lo que está tras un flag en la 116 puede estar incompleto o ser una
   versión antigua de la especificación. Ejemplo: el `harmony_array_grouping` de la V8 11.6 ya instala
   `Object.groupBy`/`Map.groupBy`, pero también `Array.prototype.groupToMap`, que no publicó ningún navegador; por eso
   no se enciende el flag tal cual, sino que se parchea como lo dejó la V8 11.7 (la de Chrome 117).
   JavaScript: parche de V8 cuando el código está en la 11.6; si no, polyfill en un componente.
   **Antes de encender un flag *harmony*, comprobar que no son esqueletos** (`grep -n TODO src/builtins/<función>*.tq`
   y los `.cc`): en la 11.6, `Map.groupBy` devolvía `undefined` («TODO(v8:12499): Implement») y el paso 46 lo dejó
   expuesto; lo vio `motor-117.html` y LOCAL portó la implementación de la 11.7 (paso 49).
   **Y traer la serie entera de la función hasta que se publicó** (`git log --grep=<función> <11.6>..<versión que la
   publicó>` en V8; para `groupBy` eran 6 commits, no 1), **probando con tamaños grandes**: sin dos arreglos de la 11.7,
   un grupo de más de ~33 000 elementos cerraba la pestaña (LOCAL, paso 50).
6. **Inventario de cada nivel (método de LOCAL):** con la copia de Chromium, `git log -E --grep=<flag|propiedad>
   <N-1>..<N> -- third_party/blink` saca lo que se escribió después de la rama: la implementación que falte (lo que
   pasó con `transition-behavior`) y los arreglos de lo que se enciende. Se portan en orden de llegada; si uno no
   aplica, se busca el commit previo del que depende (como 43a6c81e7182 para 3a16f4331fe5).
7. **Validación:** una página de comprobación por nivel (`FlyWeb/tools/motor-N.html`, sin red) y las
   web-platform-tests de cada función en `wpt.live`, comparadas con el Chrome que la publicó (`wpt.fyi`).
8. **Seguridad:** cada función portada o encendida añade código al renderer; sus correcciones posteriores entran en la
   vigilancia de CVE (`cve-triage.md`).
9. **Coste por porte, una sola vez:** la base no se mueve, así que un porte no hay que rehacerlo con cada versión de
   Chromium.
10. **Caché de código de V8 (lección de la 1.1, LOCAL 05/10):** V8 acepta la caché del perfil si coinciden
   `Version::Hash()` (11.6.189.20, que nuestros parches no cambian) y los flags *no por defecto*; cambiar builtins o el
   valor por defecto de un flag no la invalida y las webs con JIT caen. Por eso **todo nivel o parche de seguridad que
   toque `patches/v8/` sube `kFlyWebCacheEpoch`** (`patches/v8/src-utils-version.h.patch`; 2 = 1.1.1, 3 = nivel 119).
   Y cada versión se prueba también **actualizando un perfil usado por la anterior** (Gmail, Drive, claude.ai,
   YouTube), no solo con perfil nuevo.
11. **V8 por niveles (decisión del HUMANO, 05-10; FM.5):** cada nivel N lleva la V8 de Chrome N en vez de portar
   funciones a la 11.6: brave-core `FlyWeb/v8-revision` la fija y `build.sh` la pone antes de los parches (sin el
   fichero, la de la 116). Por nivel: `patches/v8/` rehechos contra esa V8 (los de seguridad son de SEGURIDAD),
   `chromium_src/v8` de la versión de Brave de ese Chromium, y los parches de Blink para las APIs que esa V8 quita.
   Los avisos de APIs obsoletas de V8 van apagados en `build.sh`. 118 = 11.8.172.18, 119 = 11.9.169.7,
   120 = 12.0.267.17.
   **Solo se parchea (seguridad) la V8 del nivel que se publica**; las ramas intermedias son pasos de desarrollo.
   **Criterio de parada (HUMANO, 05-10):** se sube V8 mientras el salto cueste poco en Blink (unos pocos parches,
   como los tres de la 11.9). Si una V8 exige cambios grandes en Blink o en `gin`/bindings (p. ej. el paso de V8 a
   `Tagged<>` y handles directos en la API pública), o deja de funcionar en Mojave o en la 5,1, **se para en la última
   V8 que pasó** y desde ahí se vuelve a portar funciones sueltas de JavaScript, como antes. LOCAL anota en FM.5 cuántos
   errores de Blink dio cada salto para decidirlo con datos.
   **Parar no es automático (HUMANO, 05-10):** cuando un salto salga caro, antes de parar se comparan los dos dolores
   de cabeza: (a) **adaptar Blink** a esa V8 (cuántos ficheros y cuánto riesgo) frente a (b) **dejar V8 estacionada**
   y vivir de parches: portar a mano cada función nueva de JavaScript (lo de la 11.6 → 117 dio tres fallos en un día:
   `Map.groupBy` vacío, pestaña cerrada con grupos grandes, caché de código vieja) y rehacer cada parche de seguridad
   sobre un código que se aleja cada vez más del de V8 (CVE-2024-0519 ya no aplicaba en la 11.8). El coste de (b)
   crece con el tiempo; el de (a) se paga una vez por salto. Se decide con esas cifras (errores de Blink del salto,
   portes y parches pendientes en la V8 estacionada), no por costumbre.
   **Blink no se sustituye entero como V8:** V8 es un repositorio aparte con una API de incrustación estable; Blink
   está dentro de Chromium y depende de `content/`, `cc`/`viz`, `gpu`, Mojo y `base` de la misma versión. Cambiarlo
   entero es subir Chromium, que es justo lo que no funciona en Mojave (principio 1). En Blink se sigue portando
   función a función.
12. **Las subfunciones cuentan (decisión del HUMANO, 05-10; FM.8):** un nivel N no está completo con las funciones
   nuevas de web-features; también hacen falta las **subfunciones** Baseline que Chrome publicó en la N (`by_compat_key`
   de web-features: partes nuevas de funciones que ya existían, como `float: inline-start` o las opciones de
   `checkVisibility()`). Si la función completa es Baseline más tarde (colores relativos → 125, `@scope`), la
   subfunción va con el nivel de la función. El inventario de cada nivel se hace con las dos listas y con los flags que
   pasan a `stable` en `runtime_enabled_features.json5` entre la N−1 y la N (las versiones de BCD no siempre son exactas).
   Los niveles 117–121 se hicieron sin esto: se completan con un commit más por rama (opción A del HUMANO, aceptando una
   compilación más por nivel).
13. **Huella de red coherente con el Chrome N (ARQUITECTURA por encargo del HUMANO, 12-10; F4.8):** un nivel N no se
   da por cumplido si la huella TLS/HTTP/2 de FlyWeb no es una que el Chrome N real pueda tener. La red sigue siendo la
   de la 116 y no se migra (principio 1); lo que cambia con los niveles son los valores por defecto que una web puede
   ver: GREASE ECH (Chrome 117), `zstd` (123, excepción del HUMANO), intercambio poscuántico Kyber (124), ML-KEM
   (131). **Receta de LOCAL en cada nivel**, junto a `motor-N.html`: desde la app, `https://tls.peet.ws/api/all`
   (JA4, huella HTTP/2 «akamai», orden de cabeceras, `Accept-Encoding`) comparada con la publicada para Chrome N
   (ja4db.io), no con el Chrome de la 7,1. No se busca una JA3 idéntica (Chrome baraja el orden de las extensiones
   desde la 110): se busca que la huella sea plausible para la versión declarada. Lo que la 116 trae apagado se
   enciende (Fase 6.2, con `base::Feature` en brave-core, no con args de GN); lo que exija tocar BoringSSL lo porta
   SEGURIDAD-PORTES.
   **Confirmado con la 1.11 (F4.8, 12-10):** adidas.es (Akamai) bloqueaba y claude.ai (Cloudflare) retaba porque
   faltaban `sec-ch-ua`, `-mobile` y `-platform`. Con esas *client hints* pasan los dos. La regla vale también para
   ellas: cabeceras, `navigator.userAgentData` y User-Agent declaran lo mismo (versión completa real del Chrome N,
   `flyweb_engine_full_version` en `config.gni`; GREASE con la semilla N; marcas GREASE + `Chromium`, sin `Brave` ni
   `Google Chrome`). La medición de F4.8 (`tls.peet.ws` y la lista de sitios de la fila) entra en la receta de cada
   nivel. **`platformVersion` (decisión del HUMANO, 12-10, a propuesta de ARQUITECTURA):** la versión real de macOS si el
   Chrome N la admite; si no, la mínima que admite el Chrome N (127–128: 10.15.7; 129–138: 11.7.10; 139+: 12.7.6), en
   `config.gni` y revisada en cada nivel contra los requisitos publicados de Chrome. Excepción al principio 4 por dos
   motivos: Chrome 127 en 10.14 es una combinación que no existe (un antibot la lee como suplantación), y **privacidad**:
   10.14.6 identifica a muy pocos usuarios, mientras que 10.15.7 es lo que ya dice el User-Agent congelado de todos los
   Mac. Hecho en brave-core `local/huella-127` (1608096de2c).

## Tipos de trabajo y coste estimado

| Tipo | Ejemplo | Coste |
|---|---|---|
| Encender un flag que ya está completo | subgrid, `@starting-style` (nivel 117) | Horas + pruebas |
| Porte pequeño (parser, estilos) | `light-dark()`, `:user-valid`, unidades `cap`, `mask` sin prefijo | Días |
| Porte mediano | colores relativos, nesting relajado, `field-sizing` | 1–2 semanas |
| Porte grande | view transitions, anchor positioning | Semanas o meses: solo si una web importante lo exige |
| JavaScript | `Object.groupBy` (parche de V8), `Promise.withResolvers`, métodos de `Set`… | Parche de V8 si ya está el código; si no, polyfill: horas |

## Versiones (HUMANO, 04-10)

El número menor de FlyWeb sigue al nivel de motor: **1.0 = Chromium 116, 1.1 = nivel 117**, 1.2 = nivel 118… Los
arreglos sobre un mismo nivel son 1.1.1, 1.1.2… Aparte, `FLYWEB_BUILD_NUMBER` (→ `CFBundleVersion` 157.64.N, lo que
compara Sparkle) sube en cada versión publicada: 1.0 = 0, 1.0.1 = 1, 1.1 = 2. Ambos números (`flyweb_version`,
`flyweb_engine_level`) están en brave-core `build/config.gni`; el nivel es también la versión declarada.

## Niveles 117–131

Lo portado, decidido y medido en cada nivel (inventarios, escapes, flags, huella), tal cual: [`motor-niveles.md`](motor-niveles.md). Cada nivel nuevo añade allí su sección.

## Apuntado para niveles futuros

- **143 — `onselectionchange` como atributo de elemento** (`<div onselectionchange=…>`, `setAttribute`): Chromium
  añade `kOnselectionchangeAttr` a la tabla `AttributeTriggers` de `html_element.cc` en la 143. De la 120 a la 142,
  `selection/textcontrols/onselectionchange-content-attribute.html` y `selectionchange-bubble.html` están en
  `TestExpectations` como `[ Timeout ]`, así que en el nivel 127 cuentan como «igual que Chrome 127» (MOTOR-3,
  COORDINACIÓN-4, 12-10).

## Inventario: CSS Baseline publicado después de la 116

Datos de [web-features](https://www.npmjs.com/package/web-features) 3.40.1 (el catálogo de Baseline) y del fichero de
flags de la 116 (`runtime_enabled_features.json5`). De 102 funciones de CSS posteriores a la 116, estas 46 son
Baseline; el resto son solo de Chrome.

| Chrome | Función | Baseline | En la 116 |
|---|---|---|---|
| 117 | @starting-style | reciente | flag (`CSSInitialPseudo`) |
| 117 | Subgrid | amplia | flag (`LayoutNGSubgrid`) |
| 117 | transition-behavior | reciente | porte (3 commits; el flag de la 116 no tenía la propiedad) |
| 118 | cap unit | amplia | porte (nivel 118) |
| 118 | rcap unit | reciente | porte (nivel 118) |
| 118 | transform-box | reciente | porte (13 commits de SVG, nivel 118) |
| 119 | :user-valid and :user-invalid | amplia | porte (nivel 119) |
| 119 | Clip path boxes | amplia | porte adaptado a mano (nivel 119) |
| 119 | rect() and xywh() | amplia | porte (nivel 119) |
| 120 | :dir() | amplia | porte (17 commits, nivel 120) |
| 120 | Exponential functions (CSS) | amplia | flag encendido (nivel 120) |
| 120 | Masks | amplia | porte (25 commits, nivel 120) |
| 120 | Nesting | amplia | porte relajado (11 commits, nivel 120) |
| 120 | scripting media query | amplia | porte (nivel 120) |
| 121 | Spelling and grammar text decorations | reciente | flag + 2 arreglos (nivel 121) |
| 121 | scrollbar-color | reciente | porte (nivel 121) |
| 121 | scrollbar-width | reciente | porte (nivel 121) |
| 123 | align-content in block layouts | reciente | no está |
| 123 | field-sizing | reciente | no está |
| 123 | light-dark() | reciente | interno (`-internal-light-dark`) |
| 123 | paint-order | amplia | no está |
| 124 | Vertical form controls | reciente | flag (`FormControlsVerticalWritingModeSupport`) |
| 125 | :state() | reciente | porte (nivel 125) |
| 125 | Active view transition | reciente | porte a mano (nivel 125) |
| 125 | Relative colors | reciente | porte a mano (nivel 125) |
| 125 | round(), mod(), and rem() | reciente | flag + 2 arreglos (nivel 125) |
| 125 | view-transition-class | reciente | porte a mano (nivel 125) |
| 127 | font-size-adjust | reciente | flag + 15 arreglos (nivel 127) |
| 128 | ruby-align | reciente | no está |
| 130 | text-wrap | reciente | no está |
| 131 | ::details-content | reciente | no está |
| 133 | :open | reciente | no está |
| 135 | shape() | reciente | no está |
| 136 | print-color-adjust | reciente | no está |
| 138 | abs() and sign() | reciente | flag (`CSSSignRelatedFunctions`) |
| 138 | progress() | reciente | no está |
| 138 | sibling-count() and sibling-index() | reciente | no está |
| 143 | @scope | reciente | flag (`CSSScope`, versión antigua) |
| 146 | text-indent: each-line | reciente | no está |
| 146 | text-indent: hanging | reciente | no está |
| 147 | contrast-color() | reciente | no está |
| 148 | Name-only container queries | reciente | no está |
| 148 | crisp-edges | reciente | no está |
| 148 | text-decoration-skip-ink: all | reciente | no está |
| 150 | light-dark() image values | reciente | no está |
| 151 | alpha() | reciente | no está |

46 funciones.
