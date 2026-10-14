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
  Con `BASE_REF=<rama de brave-core de la que salió el porte>` borra además los parches que creó el porte para ficheros
  que vuelven a quedar como en la 116; sin `BASE_REF` solo avisa.
- `fixnew.sh` — lo llama `generar.sh`: rehace un parche de «fichero nuevo» si el fichero sí existe en la 116.
- `chk.sh <rama> [<base>]` — comprueba que todos los parches de la rama (con `<base>`, solo los que cambian desde ahí)
  aplican sobre la 116 (el único aviso conocido es el
  espacio final de `ui-views-controls-menu-menu_separator.cc.patch`, que aplica igual).
- `addflag.py <json5> <Nombre> <status>` — inserta una flag en `runtime_enabled_features.json5` en orden.
- `addfiles.sh <nombre> <commit>…` — añade a `w-<nombre>`, ya montado, los ficheros de esos commits que aún no estén
  (116 + parche de Brave) y guarda sus diffs. Así se aplica una cadena paso a paso, con un commit del área por paso
  (FM.17).
- `args1.py <fichero>…` — lista las llamadas de un solo argumento a `ToScriptWrappable`, `ToWrappableUnsafe` y
  `GetInternalField<…>` (para cuando upstream quita la versión sin `Isolate`).
- `v8re.sh <rev origen> <rev destino>` — rehace `patches/v8/*.patch` al cambiar de V8 (`FlyWeb/v8-revision`).
- Generador de bindings sin compilar: `../bindings/`.
- **Traductor de LayoutNG (MOTOR-4, 12-10; para RubyLB y los niveles siguientes).** Entre la 116 y la 128 upstream
  quitó el prefijo NG de 428 ficheros (`layout/ng/inline/ng_line_breaker.cc` → `layout/inline/line_breaker.cc`) y de
  347 clases (`NGLineBreaker` → `LineBreaker`). `ngmap.py <cr116> <cr128> > /tmp/claude-0/port/ngmap.json` saca el
  mapa (rutas, símbolos y guardas de cabecera; deja fuera los 7 nombres que en la 116 ya son otra clase, como
  `LayoutBlockFlow`). `ngtraducir.py <mapa> < diff` pasa un diff de upstream a la 116. `portarng.sh <nombre>
  <commit>…` es `portar.sh` con esa traducción. Lo que rechace se reintenta con `patch -F3 -r x.rej <fichero> <
  fichero.rej>`; lo que siga fallando, a mano. **Ojo con el *fuzz* 3:** revisar dónde cayó cada *hunk*. Los
  comentarios con «ruby run» (ahora «ruby column») no se traducen y son la causa habitual de los rechazos.
  **37 nombres nuevos son también métodos en la 116** (`PhysicalFragment()`, `ContainingBlock()`, `ConstraintSpace()`,
  `BreakToken()`…; lista `calls` del mapa): seguidos de «(» no se traducen, y `ngtraducir.py` avisa («LLAMADAS sin
  traducir») para revisar si alguno era un constructor de la clase renombrada (MOTOR-5, 12-10; antes salía
  `result->NGPhysicalFragment()`). **9 rutas nuevas ya existen en la 116** (`layout/layout_block_flow.cc`,
  `layout_view.cc`, `paint/text_painter.cc`…; lista `same_paths`): upstream fusionó ahí la clase NG, pero en la 116
  son la clase base, así que no se traducen y `ngtraducir.py` avisa («RUTAS que también existen») para decidir a mano
  si el hunk va en la clase base o en la NG (antes se mandaba todo a `ng/layout_ng_block_flow.cc`). Las **rutas
  intermedias** de upstream (ficheros renombrados dos veces entre la 116 y la 128, como `layout/layout_text_combine.h`)
  se traducen por el nombre sin «ng_» si es único en la 116 (aviso «RUTAS intermedias»).
- **RubyLB:** `rubylb-r3.tsv` (R3 en orden, con los rechazos del ensayo), `rubylb-r45.tsv` (R4–R5, estado de cada uno) y `ruby-116-128.txt` (los 198 commits de ruby
  entre la 116 y la 128).
- **Paso a paso con el traductor (MOTOR-5, RubyLB):** `STEP=1 portarng.sh <nombre> <commit>…` monta el área y guarda
  los `<commit>.ng.diff`; `ap.sh <nombre> <commit>` aplica uno con `--reject` y lista los rechazos; se arreglan a mano y se
  hace commit en el área antes del siguiente (así los `.rej` de un commit no pisan los del anterior).
  `addfilesng.sh <nombre> <commit>…` traduce más commits y añade al área los ficheros que falten.
- **Herramientas de MOTOR-6 (RubyLB R3, 13-10):** `next.sh <área> <lista>` dice qué commits de la lista faltan en el
  área, en orden (cada commit del área lleva el hash de upstream como primera palabra; los que se saltan, un commit
  vacío `<hash> SKIPPED: motivo`), y evita saltarse uno sin querer (pasó con 505d10868b8). `addf.sh <área> <ruta>…`
  añade ficheros de la 116 + parche de Brave para un arreglo a mano (requisitos que no estaban en la lista).
  `rejins.py` inserta un hunk rechazado que solo añade líneas tras una línea ancla. `idscan.py <w-área> <base>`
  busca nombres de upstream sin traducir en lo añadido. Bucle típico: `c=$(./next.sh r3 lista.tsv | head -1);
  ./ap.sh r3 $c`, y si no hay rechazos, commit `$c` en el área.
- **Trampas de R3 (MOTOR-6):**
  - **Un hunk que entra limpio no está revisado.** El traductor no cambia los métodos renombrados de upstream:
    `GetPhysicalFragment()` → `PhysicalFragment()`, `GetBreakToken()` → `BreakToken()`, `GetConstraintSpace()` →
    `ConstraintSpace()`, `ScrollableOverflowRect()` → `PhysicalLayoutOverflowRect()`, `LogicalFragment` → `NGFragment`.
    Mirar cada commit «ok» y pasar `idscan.py` al cerrar cada parte.
  - **`absl::optional` no es `std::optional` en la 116** (`ABSL_OPTION_USE_STD_OPTIONAL 0`): lo que devuelve o recibe
    código de la 116 va con `absl`; el código nuevo de upstream puede quedarse con `std::optional` si no se mezcla.
  - En la 116 `ShapeResult` es *refcounted* (`scoped_refptr`, `.get()`), `RunFontData` va en `Vector` (no
    `HeapVector`) y `GlyphDataCollection` solo tiene `back()` const.
  - Los commits que **mueven código** (`LogicalLineBuilder`, `justification_utils`) se portan moviendo el código de
    la 116, no aplicando el de upstream.
  - `NGInlineBoxState` no tiene `Member` en la 116: `NGInlineLayoutStateStack` se traza sin `stack_`.
  - `text-box-trim`, `FasterMinContent` e `InlineItemResult::ToString()` no existen en la 116: sus commits se saltan.
- **Trampas de R4–R5 (MOTOR-6, `rubylb-r45.tsv`):**
  - Propiedades CSS nuevas: la 116 no tiene `invalidate:` ni `valid_for_permission_element` en
    `css_properties.json5`; el diff de estilo va en `core/style/computed_style_diff_functions.json5` (p. ej. en
    `DiffNeedsFullLayoutAndPaintInvalidation`). `CSSValueFromComputedStyleInternal` lleva 3 argumentos (sin
    `CSSValuePhase`) y `ParseSingleValue` recibe `CSSParserTokenRange`, no `CSSParserTokenStream`.
  - `ConsoleMessage::Source::k…`/`Level::k…` → `mojom::blink::ConsoleMessageSource::k…`/`ConsoleMessageLevel::k…`.
  - En `ng_inline_items_builder.cc` el parámetro de plantilla es `OffsetMappingBuilder` (upstream: `MappingBuilder`).
  - Los cambios de flags de upstream a `stable` llegan como hunks de `runtime_enabled_features.json5` que suelen
    rechazarse por contexto: aplicarlos a mano y comprobar con `gencss.sh`.
  - Si un commit toca `chrome/browser` (about:flags), portar solo la parte de Blink y devolver `chrome/` a la 116.
- **Lista de commits de un porte grande (MOTOR-7, 13-10):** la de RubyLB (`git log --grep=ruby` en `main` entre dos fechas)
  dejó fuera 1f0b377299b6 (el mensaje no dice «ruby»; daba una diferencia de WPT) y ef8ddcab1d8e (un `Merged:` en la rama
  de la 128, que no está en `main` antes del corte). Para el 129+: `git log <tag N-1>..<tag N>` sobre las etiquetas (trae
  los `Merged:`), más `--author` de los autores del porte, y comparar con la lista antes de dar el porte por completo.
- **Inventario de un nivel (MOTOR-8, 14-10; usado en el 129).** Entorno en ~10 min: `mkcr.sh /tmp/claude-0/port/cr<N> <tag>`
  para la 116, la N−1 y la N (copias parciales, ~800 MB cada una); historia sin blobs desde la 116 con `git init` +
  `git fetch --filter=blob:none --shallow-since=2023-05-15 origin refs/tags/<tag N>:refs/tags/<tag N> …` (~460 MB; con
  árboles, así `git log <tag N-1>..<tag N> -- <ruta>` tarda menos de un segundo); V8 igual, con las dos etiquetas.
  - `baseline-nivel.js <N>` (en un directorio con `npm install web-features @mdn/browser-compat-data`): funciones,
    subfunciones (`by_compat_key`) y claves de BCD que Chrome publicó en la N, y si Firefox y Safari las tienen.
  - `flags-nivel.py <crN-1> <crN> [<cr116>]`: flags de Blink que pasan a `stable`, nacen, cambian o desaparecen
    (necesita `pip install json5`).
  - `medir.sh <nombre> <commit>…`: mide un porte antes de hacerlo: aplica la serie en orden sobre la 116 + los parches
    de la rama de brave-core que haya en `/home/user/brave-core` y cuenta hunks, rechazos y *fuzz*. Para la API de V8:
    `git diff <V8 N-1> <V8 N> -- include/`, buscar en la 116 lo que se quita, y `git apply --check` de cada
    `patches/v8/*.patch` sobre la V8 nueva (y `-R` para ver los que ya están dentro).
  - **Trampa:** `git grep` o `git show` sobre ficheros en un clon `blob:none` baja los blobs uno a uno (minutos); para
    buscar en V8, `git worktree add` de la etiqueta (baja todo de una vez, ~190 MB).
- `gencss.sh <dir>` — ejecuta sin compilar los generadores de Blink de flags (`runtime_enabled_features.json5`),
  `ComputedStyle` (`computed_style_extra_fields.json5`), palabras clave y propiedades CSS sobre la 116 + los parches
  `third_party-blink-*` de la rama actual. Detecta listas incoherentes (p. ej. dos campos con el mismo `type_name` y
  distintas palabras clave) y el paso de bits de los campos. Necesita `gperf` (`apt-get install gperf`) y, en
  `cr116`, `git sparse-checkout add third_party/mako third_party/ply third_party/pyjson5 third_party/jinja2
  third_party/markupsafe build`. Para ver qué cambia, se ejecuta también con la rama base y `diff -r`.

## Lecciones (niveles 117–124)

- Antes de portar un nivel: comparar la API pública de V8 (`include/`) con Blink/gin/content de la 116, y vigilar los
  `#include` transitivos (`v8-context.h`).
- Si una serie de upstream se apoya en refactors que la 116 no tiene, portar **el comportamiento final** a mano (Shadow DOM
  clonable, iterables asíncronos) en vez de arrastrar la cadena de refactors.
- Las flags que un commit añade y otro quita: dejar la flag en `stable` si quitarla arrastra refactors.
- En la 116 `WebThemeEngine::ExtraParams` es una `union`: sin inicializadores por defecto en sus structs.
- Contadores de uso (`web_feature.mojom`): valores de upstream, insertados en orden (`kNumberOfFeatures` = máx + 1).

## Lecciones del nivel 129 (MOTOR-8)

- **Trampa de las WPT de referencia (14-10):** `wpt-ref.py` capturaba con `Emulation.setDeviceMetricsOverride` en una
  sola pestaña, y la 116 a veces sacaba la captura media fila desplazada. Resultado: 200 px falsos (máx. 56) en las 4
  `container-queries/no-layout-containment-{abspos,fixedpos}[-dynamic]`, que Chrome 129 pasa. Casi se declara una
  excepción que no lo era. La pista era la forma del fallo: dos filas de borde antialiasado, no el cuadrado rojo entero
  (10000 px), y una página de control sin `container-type` con los mismos 200 px. Desde entonces `wpt-ref.py` no emula
  nada: lleva el *viewport* real a 800×600 con `Browser.setWindowBounds`, exige `devicePixelRatio` 1
  (`--force-device-scale-factor=1`), captura cada página en una pestaña nueva y repite cada reftest (`--pasadas=N`, 3
  por defecto; si las pasadas no coinciden, sale `INESTABLE`). Antes de declarar una excepción en un reftest: control
  sin la función, coordenadas de los píxeles y comparación con Chrome for Testing N en la misma máquina.
- **Tipos del IDL:** al portar una función, comparar también el `.idl` con el de la N aunque el commit no lo toque. El
  Blob de `RTCDataChannel` dejó `binaryType` como `DOMString` (116) en vez del enum `BinaryType` (129), y un valor no
  válido lanzaba en vez de ignorarse (`RTCDataChannel-binaryType` 3/10).
- **Opciones de V8 que upstream ya no prueba:** con `turboshaft_instruction_selection` apagada, la 12.9 cerraba
  claude.ai (`kTrustedHeapConstant` sin tratar en la ISel de TurboFan). Se resolvió con la regla 19: lo apagado se
  enciende cuando upstream lo lleva de serie. Al saltar de V8, mirar `flag-definitions.h` de upstream frente a nuestras
  opciones apagadas.
- **Regla 18:** un nivel, una versión, con la V8 de Chrome N; nada de partir el nivel en 1.N.x salvo un cambio muy amplio.

- `llevar.sh`: lleva commits de LOCAL a una rama `nube/*` y la fusiona en otra, sin checkout (ver `FlyWeb/docs/coordinacion.md`).
