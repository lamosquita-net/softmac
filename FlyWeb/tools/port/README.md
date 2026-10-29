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
  espacio final de `ui-views-controls-menu-menu_separator.cc.patch`, que aplica igual). Al final pasa `gnirama.py`; sale
  con error si hay problemas y con 2 si la rama o la base no existen (antes daba «0 parches, 0 problemas»). Los «SIN
  BASE» de `patches/third_party/angle/*` (FS.22) son de subrepositorio y se esperan.
- `addflag.py <json5> <Nombre> <status>` — inserta una flag en `runtime_enabled_features.json5` en orden.
- `delflag.py <json5> <Nombre>` — quita la entrada de una flag (con sus líneas `//` de dentro; el comentario que va
  justo antes de la `{` se queda y hay que quitarlo a mano).
- Lotes de escapes (FM.22): `tanda.py <prefijo> <lista>` porta cada línea `FLAG ADD [REM]` de `<lista>` sobre la rama
  actual de brave-core (entrada del json5 quitada o en `stable`, ficheros de chrome://flags y variaciones como
  estaban); si no quedan `.rej`, genera, hace commit `FM.22 <prefijo>: <flag>` y pasa `chk.sh`; si quedan, lo lista
  para hacerlo a mano. **Que aplique sin `.rej` no quiere decir que compile:** revisar cada diff contra las APIs de
  la 116 (nombres NG, `Size()` como `LayoutSize`, funciones que upstream renombró en el mismo commit…).
  Para los manuales: `rp.sh <flag> <add> [<rem>…]` vuelve a montar `w-<flag>` y enseña los `.rej` útiles, y
  `fin.sh <flag> <prefijo> <add> [<rem>…]` termina (genera, commit, `chk.sh`); `NOTE=…` añade un párrafo al mensaje
  y `MSGFILE=<fichero>` pone un mensaje entero. **Antes de portar, mirar que la columna «commit que la quita» no
  sea una reversión** (`git log -1 --format=%s`): en FM.22 hubo tres.
  Los dos usan `portarng.sh` (rutas y nombres de LayoutNG de la 116): con `portar.sh`, un commit posterior al
  renombrado NG (finales de 2023) que toca `layout/inline/line_breaker.cc` no deja `.rej`, simplemente no se aplica;
  `tanda.py` pasa a mano cualquier fichero que no exista en la 116.
  `rp.sh` también enseña los `.rej` de un commit que otro posterior pisó en el mismo fichero (marcados «pisado»).
  `jdiff.sh [<rev>]` da el cambio real del json5 de flags entre `<rev>~1` y `<rev>` (para ver que un parche regenerado
  no se ha comido entradas).
  `flip.sh <flag> <prefijo> <nivel> [nota]` pasa a `stable` un flag que ya está en la 116 con su código completo
  (solo el json5), con su commit y `chk.sh`; antes, comprobar en `cr116`/`cr131` que el código detrás del flag es el
  mismo (FM.22 D). Si a un área ya montada le falta un fichero (por ejemplo, el `ng/` de la 116 que corresponde a un
  `.rej`), añadirlo con `addfiles.sh` o volver a montarla con `mkws.sh`: un fichero copiado a mano después del commit
  `raw116` sale entero como fichero nuevo en el parche.
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

## Lecciones del inventario del 130 (MOTOR-9)

- **`medir.sh` contaba de más los rechazos** (hasta el 15-10): `grep -c FAILED` sumaba también la línea de resumen de
  `patch` («3 out of 4 hunks FAILED»), uno más por fichero con rechazos. Ahora cuenta solo `Hunk #… FAILED`. Las
  medidas del 129 están infladas en esa cantidad (el orden de costes no cambia).
- **`medirng.sh <nombre> <commit>…`**: `medir.sh` con el traductor de LayoutNG (`ngmap.json` de
  `ngmap.py cr116 cr<N>`). Sin él, los ficheros renombrados (`layout/inline/line_breaker.cc` frente a
  `layout/ng/inline/ng_line_breaker.cc`) salen como «ausentes» y el porte parece más barato de lo que es.
- `mkcr.sh` no baja `net/` ni `chrome/browser`: para medir algo de red, `echo /net/base/ >> .git/info/sparse-checkout`
  y `git sparse-checkout reapply` en la copia.
- **Cambios fuera de Blink**, comprobación rápida: `BASE_FEATURE(...)` de `net/base/features.cc`,
  `services/network/public/cpp/features.cc`, `content/public/common/content_features.cc` y
  `third_party/blink/common/features.cc` en las dos etiquetas (con `git show <tag>:<ruta>`) y comparar el valor por
  defecto; más `prefs_tab_helper.cc`, `locale_settings*.grd` y `ssl_client_socket_impl.cc`.
- **Rutas GN nuevas de V8:** comparar las etiquetas `"//…"` de `BUILD.gn` y `gni/` entre la V8 N−1 y la N y buscar
  cada una en el árbol de la 116 (`git cat-file -e 116.0.5845.188:<ruta>`). En la 13.0 salió `//third_party/fast_float`.
- Sin brave-core en la sesión, las medidas se hacen sobre la 116 sola y hay que repetirlas antes de portar.
- **Cambios «por defecto» que se escapan** (WebSQL en la 119, nunca recogido): en cada nivel, además de las flags que
  pasan a `stable`, mirar las que dejan de serlo (`flags-nivel.py`, tipo `CHANGE` con `stable` antes) y las `stable`
  de la 116 que desaparecen. Para saber si una flag desaparecida quitó comportamiento o lo hizo permanente,
  `bisflag.py <flag>…` da el commit que la borra.
- **Finch:** Brave compila con `disable_fieldtrial_testing_config`; Chrome (y Chrome for Testing) no. Un cambio puede
  llegar a Chrome N solo por configuración de campo (los eventos de mutación, en la 127). `ftc.py` lee
  `fieldtrial_testing_config.json` por versión, pero esa configuración son experimentos: solo cuenta lo que confirme
  CfT N o un cambio del código poco después. La comprobación de verdad es `FlyWeb/tools/superficie.html` en FlyWeb y en
  CfT N, comparando los dos ficheros con `diff` (motor.md «Nivel 130» §10).

## Lecciones del porte del 130 (MOTOR-10)

- **Ayudantes nuevos:** `syncf.sh <área> <fichero>…` (vuelve a poner en el área un fichero de la 116 + el parche
  *actual* de brave-core), `commitarea.sh <área> <mensaje>` (commit del área, `generar.sh`, commit en brave-core y
  `chk.sh` de lo cambiado; `TRAILER` con las líneas de atribución), `doflag.sh <área> "<Flag[:status]>…" <mensaje>`
  (flags + `commitarea.sh`) y `edits.py <área> <json>` (reemplazos exactos, cada uno una sola vez, o falla).
- **Orden de las áreas:** un área se monta con los parches que haya en ese momento. Si se monta antes del commit de
  otra que toca el mismo fichero compartido (`runtime_enabled_features.json5`, las listas `.gni`,
  `element_rule_collector.cc`…), `generar.sh` pisa el cambio anterior. Montar cada área después del commit de la
  anterior, o pasar `syncf.sh` por los compartidos antes de generar.
- **Las medidas «2/0» no ven dependencias:** cuatro flags que aplicaban casi limpias usaban tipos o funciones
  posteriores a la 116 (`kPseudoIdPlaceholder`, `MarkerRangeMappingContext`, `StyleUAShadowHostData`,
  `SetScrollOffset` con `bool`). Antes de prometer una flag, buscar en la 116 cada símbolo nuevo que use el diff.
- **El generador de la 116 ordena los enums de palabras clave por id** (y no tiene `kMaxEnumValue`): un enum nuevo
  puede salir con otro orden que en upstream. Si el código mete el enum en un campo de bits o lo compara con otro
  (`white-space` y `text-wrap-mode`), fijar los valores a mano.
- **`addflag.py` inserta sin distinguir mayúsculas**, como el orden del json5; una flag mal colocada no rompe el
  generador, pero sí el siguiente parche que toque al lado.
- **Barrido de `base::Feature`:** incluir `chrome/common/chrome_features.cc` (Web Share en Mac, 129, se escapó por no
  estar ahí).
- **`git apply` sin parche lee la entrada estándar** y se queda esperando: comprobar que la lista no esté vacía.
  `git log -S` en el clon sin *blobs* tarda horas; usar `--grep` o la ruta.

## Inventario del 131 (MOTOR-10)

- **`flags-escapes.py <dir-json5> <json5-flyweb> <raíz>`**: flags que Chrome tuvo en `stable` en algún nivel y FlyWeb
  no. El directorio lleva un json5 por nivel (`<N>.json5`, de la cabeza de cada rama). Las etiquetas 117–128 no estaban
  en el clon: `git ls-remote --tags origin 'refs/tags/1[12][0-9].0.*'` da la última de cada rama, y
  `git fetch --no-tags --filter=blob:none origin refs/tags/<t>:refs/tags/<t> …` las trae en ~20 s. Lo fiable es lo que
  FlyWeb tiene en su json5 pero apagado; lo que no está puede ser un porte del estado final sin la flag.
- `medirng.sh` lee el clon de Chromium de `CH` (por defecto `/home/user/chromium/chromium`); antes estaba fijado a la
  ruta de MOTOR-9 y medía todo a cero sin avisar.
- **Después de un `--amend`, el hash cambia:** el id que se da a otro agente se lee con `git ls-remote` después del
  `push`, nunca de la salida de `commitarea.sh` (MOTOR-10 dio c6ab0716d4 por 303e498fb5 en la 1.14.1).
- **Fuera de Blink, también BoringSSL:** ML-KEM (131) es un cambio de `net::features` que exige código nuevo en
  BoringSSL. Comparar `boringssl_revision` del DEPS y buscar en ese repositorio (`github.com/google/boringssl`, sin
  *blobs*) los ficheros que pide el cambio.

- `llevar.sh`: lleva commits de LOCAL a una rama `nube/*` y la fusiona en otra, sin checkout (ver `FlyWeb/docs/coordinacion.md`).

## Porte grande con fusión a tres bandas (MOTOR-13, FM.28: anchor positioning)

Para cadenas largas de upstream sobre ficheros que la 116 ya no tiene como upstream (230 commits, unos 3000 hunks).
Diffs traducidos con `ngtraducir.py` (mapa en `ngmap-fm28.json.gz`, descomprimir como `ngmap.json`); fases y orden en
`anchor-fases.tsv`.

- `sig.sh <área> <lista>` — bucle: `paso.sh` (aplica con `ap.sh` lo que entra limpio y hace commit), en el primer commit
  con rechazos `m3.sh` (fusión a tres bandas por fichero, con la base y la versión de upstream traducidas) y
  `autores.py` (reglas de autorresolución). Si no quedan conflictos, hace commit «[m3]» y sigue; si quedan, se para y
  los enseña. Tras cada tanda pasa unos controles: `css_properties.json5` sin `Member` ni `valid_for_permission_element`,
  sin API de upstream en `properties/` (`CSSParserTokenStream& stream`, `value_phase`) y `fmtdelta.sh`.
- `ok.sh <área> <hash> [nota]` cierra a mano un commit resuelto; `fixc.sh <área> <mensaje>`, un arreglo propio (se
  niega si hay `.rej`, es decir, si el siguiente commit está a medio aplicar). `cf.py <fichero> <n> area|upstream|base|-`
  resuelve un conflicto; `trf.py <rev> <ruta>` da el fichero de upstream ya traducido.
- Controles del área: `fmtchk.sh` y `fmtdelta.sh` (clang-format reindenta mucho más que antes = bloque mal colocado),
  `perdidas.py` (líneas que añade upstream y no llegaron; `MIN=1` para todas), `audit.py` (ficheros del diff que el
  commit no cambió), `gnichk.py` (entradas de `.gni` sin fichero en el área, la 116 ni un parche), `ciclos.py` (ciclos de
  `#include` nuevos) e `idmiss.py` (identificadores que no existen en la 116 ni en el área).
- Controles de la rama, antes de cada entrega a LOCAL: `gnirama.py <rama> [<base>]` (entradas de los `.gn`/`.gni`
  parcheados sin fichero en la 116 ni en un parche; con `<base>`, mucho más rápido), `barrido.py <área>` (frente a la
  1.15.1 reconstruida en `base115/` = 116 + parches de la rama de partida: identificadores que desaparecen de las
  cabeceras y funciones que pierden una aridad, con sus usos fuera del área) y `sueltas.py <área> <base>` (sentencias a
  nivel de espacio de nombres; orientativo, con falsos positivos).
- `custfn.py <dir>`: cada método «custom» de `css_properties.json5` (`style_builder_custom_functions`,
  `property_methods`) tiene su `Clase::Método` en `properties/*/*.cc`; si falta, el navegador compila y no enlaza (0 en la
  116). `ver.sh <ruta>`: el fichero como queda en brave-core (116 + su parche), sin los `chromium_src` de Brave.
- `trasmove.py <área> <base>`: usos de una variable después de `std::move(variable)` en la misma función, cuando el
  move o el uso los añade el porte (da falsos positivos: cada aviso se mira a mano).
- **Trampas que salieron en este porte:**
  - **La autorresolución pega código fuera de su sitio.** Un método de una clase que no existe en la 116 (p. ej.
    `CSSMathExpressionIdentifierLiteral`) acaba fuera de cualquier clase, y un `case` de una función que no existe acaba
    entre dos funciones. `autores.py` rechaza ahora lo que añade llaves desequilibradas y los renombres de palabras
    clave (`void`→`bool`). Aun así, `fmtdelta.sh` tras cada commit.
  - **Pérdidas silenciosas.** Un cambio de `status` en `runtime_enabled_features.json5` que la fusión resuelve como «área»
    deja el commit vacío (19879a57c77 «Enable anchor-scope for stable»). Al cerrar una fase: buscar los commits del área
    sin ficheros cuyo `.ng.diff` no esté vacío, y comparar el `status` final de cada flag que toca la cadena con el de la
    etiqueta N.
  - **Renombres de fichero de upstream** (`inset_area` → `position_area`, `successful_position_option` →
    `successful_position_fallback`, `position_try_options` → `position_try_fallbacks`): el diff traducido los da como
    fichero nuevo, sin las adaptaciones a la 116 del viejo, y el viejo se queda. Hacer el fichero nuevo con
    `git merge-file` (área vieja, base y upstream traducidos) y borrar el viejo si lo creó el porte. Un fichero de la 116
    que deja de compilarse vuelve a su versión de la 116, sin parche.
  - **Rutas de `.gni` relativas a su carpeta** (`"anchor_evaluator_impl.cc"` en `core/layout/build.gni`): el traductor no
    las cambiaba y ninja se paraba en [0/1]. Ya las traduce, pero `gnichk.py` antes de cada entrega.
  - **Includes cruzados por la traducción:** `css/anchor_query.h` (fichero nuevo) no es `layout/ng/ng_anchor_query.h`
    (el `AnchorQuery` de la NG). Un include mal traducido de uno al otro hizo un ciclo, y LOCAL vio 4208 errores repetidos
    de 3 cabeceras. `ciclos.py`.
  - **Diferencias con el commit `brave`, no con la 116 pelada:** al revisar, comparar con el estado de partida
    (la 1.15.1 ya trae niveles portados, p. ej. `kNestedDeclarationsRule`). Lo que es de la 116 se mira en `cr116`.
  - **La lista de commits se queda corta en los ficheros compartidos:** `git log <116>..<131> -- <ficheros propios del
    anchor>` salió completa, pero c959fdf8dd8 (quitar `position-try-options`) solo tocaba `css_properties.json5` y otros
    compartidos. Comparar también las propiedades del json5 (flag, `surrogate_for`, `priority`) con las de la N.
  - **`ComputedStyle` no es GC en la 116:** los tipos de campo con `Member<>` (p. ej. `StyleAnchorScope`) llevan
    `Persistent<>`, con constructores fuera de línea donde el tipo apuntado está completo.
  - **API de la 116 que no se puede cambiar para todos:** cuando upstream cambia una firma usada por mucho código de la
    116 (`ResolvedAlignSelf(StyleSelfAlignmentData)`), se porta la versión nueva y se deja una sobrecarga con la firma
    vieja para el resto.
  - **Segunda Static (40 errores en 17 ficheros): API de upstream que la 116 llama de otra forma.** `MarginInlineStart`
    → `MarginStart`, `GetPhysicalFragment` → `PhysicalFragment`, `has_value`/`value` de `crdtp::Maybe` →
    `isJust`/`fromJust`, `AddMatchedProperties` con `AddMatchedPropertiesOptions::Builder`, `ConsumeDeclarationList` con
    `nested_declarations_start_index` (del nivel 130). `ConversionChecker` no es GC en la 116: `std::make_unique`, sin
    `Trace`, y los miembros a objetos GC con `Persistent`. `barrido.py` frente a `base115/`, no frente al commit F1.
  - **Una fusión de `runtime_enabled_features.json5` puede borrar la flag de al lado** (`CSSPictureInPicture`, con 3
    errores en 2 ficheros que no son del anchor). Al cerrar: comparar los nombres de flag con los de la 1.15.1.
  - **Tercera Static: el navegador compiló entero y no enlazó.** La fusión de 8d091495b13 borró `Position::ApplyInherit`
    junto a lo de `position-fallback-bounds`, y la 116 la sigue declarando en el json5. `custfn.py` antes de entregar.
  - **`blink_unittests` no se había compilado nunca con los niveles** (115 errores en 33 ficheros, unos 88 de antes del
    anchor). Muchos vienen de los `chromium_src` de Brave, que renombran o envuelven clases de Chromium
    (`TimeClamper`, `WebSocketChannelImpl` → `_ChromiumImpl`, un virtual puro nuevo en `LinkLoaderClient`): mirar
    `brave-core/chromium_src/<ruta>` antes de buscar el cambio en los niveles; `ver.sh` no los ve. Se arreglan en el
    test, sin tocar el navegador ni quitar tests del build (COORDINACIÓN-8). Los tests de la 116 entran al área con
    `addf.sh`. clang para en 20 errores por fichero: un test con 19–20 errores en la lista esconde más.
  - **Lo que compila puede caerse: `ComputedStyle` es GC en upstream y `scoped_refptr` en la 116.** Upstream hace
    `layout_style(std::move(new_style))` y luego lee `new_style->…`; con un puntero GC sigue valiendo, y en la 116 el move
    lo deja nulo. Resultado: el renderer se caía en cada recálculo de estilo (F7, SEGV 0x38 en `RecalcOwnStyle`). Antes de
    entregar: `trasmove.py`, y buscar miembros `const ComputedStyle*` que añada el porte (en upstream los mantiene vivos el
    GC; en la 116, nadie).
  - **Nombres que upstream reutiliza con otro sentido:** `HasScrollableOverflow()` de la 131 es el `HasLayoutOverflow()`
    de la 116 (se renombró «layout overflow» → «scrollable overflow»); `HasScrollableOverflowX/Y()` de la 116 es otra cosa
    (exige `overflow: auto/scroll`). Traducirlo por parecido dejó fuera los `overflow: hidden` del ajuste por scroll, y solo
    lo vio un reftest de las WPT. Ante un nombre de upstream que existe en la 116, mirar qué hace en las dos.
  - **Lo que se descarta como «refactor de OOF» puede traer arreglos:** 1624b1441b9 (capa superior al final del OOF de la
    raíz) estaba en `oof-otro` y arreglaba un fallo del anchor con `<dialog>` y una caída que ya tenía la 1.15.1. Y una
    flag que se enciende (ScrollNodeForOverflowHidden) arrastra arreglos posteriores sin etiqueta de anchor (14c9714ba83e
    en cc): buscar en la historia por el nombre de la flag y por lo que crea, no solo por la etiqueta. Las WPT de la
    función, frente a CfT N, antes de la Release.

## Sobre la base 128 (MOTOR-15, Fase 3 clase D de FM.31)

Entorno: `CH=/home/user/chromium/hist` (historia sin blobs con las etiquetas 116, 128.0.6613.138, 129.0.6668.112 y
131.0.6778.264), `cr128` con `mkcr.sh` (sparse ampliado a content/browser, cc, viz, services, net, chrome/browser
flags) y `brave-core` en `nube/base-128-motor`. Los parches son diff `--full-index` contra la 128 (incluyen lo de Brave).

- `portar128.sh <área> <commit>|fw:<commit de FlyWeb>…` — como `portar.sh`, sobre la 128 + los parches de la rama; cada
  rechazo queda como `<fichero>.rej.<commit>` (no se pisan). `fw:<sha>` aplica lo que hizo un commit de FlyWeb sobre la
  116 (`fwdiff.sh`), para llevar lo hecho a mano.
- `generar128.sh <área>` — escribe los `.patch` contra el contenido de la 128 (no contra la raíz del área: se pueden
  añadir ficheros al área en cualquier momento) y borra los que vuelven a quedar como en la 128.
- `insert.sh <área> <commit aplicado> <prerrequisito>…` — deshace un commit del área, aplica antes sus prerrequisitos
  (añadiendo los ficheros que falten) y lo vuelve a aplicar. Es lo que más rechazos quita: la 128 se cortó el 23-07-2024
  y muchos commits del 129–131 dependen de otros de agosto (`git log 03c1799e6f9..<commit> -- <fichero>`).
- `fwdiff.sh`, `fwset.sh`, `fwapply.sh` — diff equivalente de un commit de FlyWeb sobre la 116, y aplicarlo.
- `f16.sh <fichero>` — el fichero tal como queda en la 1.15.2 (116 + parche de `nube/motor-131-anchor-f16`).
- `ported.py <test>…` — commits 128→131 que tocan cada test y si su código ya está en la rama (P/p/-/?), para
  portar los hunks de test que faltan (blink_unittests de la base 128). Bajar antes los blobs (trampa en `relevo-motor.md`).
- `pchchk.py <lista>` — repaso de includes que tapa el PCH (TRAMPAS, MOTOR) sobre `w-all` (montar con los ficheros de
  todos los `.patch` de la rama y `git apply` de cada uno): símbolos de lo adaptado a mano que solo trae `document.h` +
  `layout_object.h`. Con `--depth` de la historia hasta la 131. Lo que da, mirarlo: casi todo es declaración adelantada.
- **Tests de los portes (MOTOR-17, `blink_unittests` de la base 128):** `w-all` = cr128 + todos los `.patch` de la rama
  (con commit `raw128` y `bc`). `mark.py <lista>` marca cada commit (P/p/-/?) y lista sus tests (lista = salida de
  `git log` de los commits que tocan código parcheado, con sus tests debajo). `m3t.py <lista> [omitir…]` fusiona a tres
  bandas, en orden, los ficheros de test de cada commit en `w-all` (base = `c^`, suyo = `c`) y hace un commit por cada uno;
  con conflicto se para y `res.py <fichero> o|t|ot|to…` resuelve los bloques. `gen128lista.sh <lista>` escribe los
  `.patch` de esos ficheros contra la 128. La lista de commits portados sale de `d128-medida.tsv` y de los mensajes de
  commit de la rama. **Trampas:** git 2.43 no entiende `GIT_NO_LAZY_FETCH`: limitar `git show` a rutas ya bajadas (si no,
  baja blobs uno a uno); un test que entra limpio puede usar API de un commit no portado (p. ej.
  `CSSParserTokenStream(String)` de 5144028324): revisar lo nuevo contra las cabeceras.
- `rejfuzz.sh <área>` — reintenta los `.rej` con fuzz 0 e ignorando espacios. **Nunca con fuzz 3**: en anchor metió una
  entrada de mojom fuera del enum y un miembro en otra struct, y en el json5 subió a stable la flag equivocada.
- **Paso a paso sobre la 128 (MOTOR-28, 28-10):** `STEP=1 portar128.sh <área> <commits>` monta; `ap1.sh <área> <commit>`
  aplica uno con `--reject` y lista rechazos; se arreglan a mano y `ok1.sh <área> <commit>` hace el commit del paso (falla
  si quedan `.rej`). Así los rechazos no se encadenan (con todos de golpe, `text-box-trim` daba 43; paso a paso, 9 reales).
  Un fichero que se añada al área a mano: **copiarlo de la 128 y aplicarle su parche de bc** antes de editar.
  `fin133.sh` toma el id de sesión de `SESION`.


## Sin historia completa de Chromium (MOTOR-32, 29-10)

- **Historia ligera:** `git init /home/user/chromium/hist` + `git fetch --filter=tree:0 --shallow-since=2024-06-01 origin
  refs/tags/135.0.7049.117:… refs/tags/128.0.6613.138:…` (~3 min, 60 MB). Solo commits: `git log --format='%cs %h %s'
  128.0.6613.138..135.0.7049.117 > log128-135.txt` y **buscar por asunto** (con `--grep` sale de todo). `git show <sha>`
  baja árboles y blobs a demanda en ~5 s. `git log -- <ruta>` sigue siendo inviable. El historial de Gitiles
  (`+log/a..b/ruta`) pide sesión (403).
- `gd.sh` usa esa historia y, si falta, Gitiles (~40 s por diff). `msg.sh <sha>…`: fecha, sha y asunto por Gitiles.
- `g128.sh <fichero>`: el fichero en la 128 (cr128 o Gitiles); `generar128.sh`, `chk128.sh` y `add128.sh` lo usan en vez
  de la historia completa.
- `portgd.sh <área> <commits>` (= `portar128.sh` con `gd.sh`; `STEP=1` solo monta), `ap1gd.sh <área> <commit>` y el
  `ok1.sh` de siempre, paso a paso. `mkws128.sh <área> <ficheros>`: área a mano sobre la 128 + parches.
- `fwf.sh <fichero>…`: deja en `fw/` la versión FlyWeb (128 + parche) para `diff fw/X cr135/X`.
- **Ficheros borrados por un commit:** `generar128.sh` no los expresa (aviso «borrado del área»). Se dejan como en la 128
  y se quitan de su `.gni` (caso `invoker_element.idl`).
- **`pkill -f`** vuelve a matar el propio shell: no usarlo.
