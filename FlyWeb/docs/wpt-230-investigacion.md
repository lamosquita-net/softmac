# Investigación de las diferencias WPT de la 2.3.0 (nivel 134) frente a Chrome

INVESTIGACIÓN-MOTOR-6, 29-10. Encargo de Titín: antes de que MOTOR analice, buscar si Chrome tuvo el mismo fallo y cómo
lo resolvió. Parte de las 17 diferencias de [`wpt-230.md`](wpt-230.md) (nivel 134, `nube/motor-134` 479bcaf1e2, frente a
CfT 134.0.6998.165). Solo papel: no se ha portado nada ni mirado el árbol de brave-core, así que lo que dice cómo está
**nuestro** código es inferencia (marcada «supuesto»).

## Resultado en una línea

**Ninguna diferencia es un fallo que Chrome arreglara después del 134.** Todas las que tienen arreglo conocido lo tienen en
la 129–134 (dos de ellas ya en la 131 o la 133): son portes que faltan o flags de `runtime_enabled_features.json5` que en la 128 estaban
apagados. `highlight-cascade-010` sale de la lista (LOCAL: no se cuelga ni en la 2.3.0 ni en la 2.1.1; PASS al repetir;
tiempo agotado suelto).

## Tabla

Clasificación: (a) se porta un arreglo conocido de Chrome; (b) es de la 128 y hay que portar la función entera;
(c) entorno de prueba; (d) no se sabe. «V» = verificado en Gitiles/wpt.fyi; «S» = supuesto.

| Prueba | Función | Bug / CL de Chrome | Versión | Clase | Receta corta para MOTOR |
|---|---|---|---|---|---|
| `highlight-cascade-010` | HighlightInheritance, registro tardío de propiedad | — | — | (c) fuera de lista | Sin acción. LOCAL: PASS al repetir. |
| `css-target-text-decoration-001`, `custom-highlight-painting-below-target-text` | HighlightInheritance | Sin bug propio. «Ship CSS Highlight Inheritance» `921cea2e125a` ([CL 6219603](https://chromium-review.googlesource.com/c/chromium/src/+/6219603)); antes `4b2c325630d1` ([CL 5900446](https://chromium-review.googlesource.com/c/chromium/src/+/5900446)), revertido en 131 (`921435f58472`, Tailwind) | Flag `stable` en 131.0.6778.69 y 134; `experimental` en 128–130, 132, 133 | (d) casi seguro flag/porte incompleto (V: pasan en Chrome 134 y con el flag apagado fallan en 128/129/133) | 1) `HighlightInheritance` en `stable` y que el ejecutor no lo apague. 2) Comparar: `d6f74a7b1435` (custom properties en highlight pseudos, [CL 6053860](https://chromium-review.googlesource.com/c/chromium/src/+/6053860)), `4d2736408dfb` (crash con propiedades registradas, 381362600), `3b9b9aaf293d` (MPC), `0112c990f8af`. Ficheros: `style_resolver.cc`, `highlight_style_utils.cc`, `highlight_painting_utils.cc`. |
| `highlight-paired-cascade-004` (mismatch) | HighlightInheritance, cascada emparejada de `::target-text` | Ninguno | — | (d) no se sabe (V: pasa en Chrome 128–134 con el flag apagado y encendido, así que no es «flag apagado») | Probar en la build: `getComputedStyle(el,'::target-text').backgroundColor` tras `#:~:text=…`, y `document.fragmentDirective`. Lanzar `css-pseudo/target-text-*` y `highlight-cascade-001..011`. Dos hipótesis (S): fragmento de texto no activo en el ejecutor, o `::target-text` no suprime el fondo por defecto con color fijado. |
| `editing/run/inserthtml.html` (3 subpruebas `<li>abc</li>`) | InsertHTML / ReplaceSelectionCommand | `347bc308e2` «Paste plain text as new list item in list» ([CL 5999033](https://chromium-review.googlesource.com/c/chromium/src/+/5999033), bug 41247646) | 133 (flag `PasteListItemOutsidePreviousListItem`, `stable`) | (a) | Añadir el flag; aplicar los dos hunks en `replace_selection_command.cc` (`InsertAsListItems`: li como hermano; condición «pegar li dentro de li» con `RemoveNode(block_start)` vacío); portar `editing/pasteboard/paste_plain_text_in_list.html`. Comparar los otros 8 flags de editing 133–134 con las 9 correcciones ya portadas (lista abajo). |
| `test_font_feature_values_parsing.html` (2 subpruebas) | CSSFontFeatureValuesRule (parser) | `20d6d52ab7` «Handle allowed rules during parsing using bits» ([CL 6171270](https://chromium-review.googlesource.com/c/chromium/src/+/6171270), bug 325504770), 17-ene-2025. Quita esas 2 líneas FAIL del `-expected.txt` de Chrome | 134.0.6963.0 (no está en 134.0.6962.0) | (a) y (b): arreglo de rebote de un cambio de parser grande | Mínimo (S, sin compilar): en `ConsumeAtRuleContents`, rama `kFontFeatureRules`, llamar a `ConsumeErroneousAtRule(stream, id)` antes de `return nullptr` (hoy el `@blah` no consume prelude ni bloque y el `@styleset` se cuela). Fiel: portar `20d6d52ab7` entero (`allowed_rules.h`, `ConsumeAtRuleContents` con `switch`, `ComputeNewAllowedRules`). Comparar con los 37 FAIL del `-expected.txt` de Chrome 134. Además: `[Exposed(Window ExposeCSSFontFeatureValuesRule)]` en el IDL. |
| `at-font-face-descriptors`, `font-parse-numeric-stretch-style-weight`, `font-shorthand`, `font-weight-parsing` (calc fuera de rango en `font-weight`) | Clamp de `calc()` en `font-weight` | `738a7c5fd4` «Use media values in @font-face to resolve calc()» ([CL 5830895](https://chromium-review.googlesource.com/c/chromium/src/+/5830895), bug 40946458); `8c249d6e26` «Resolve font-weight values with CSSLengthResolver» ([CL 6172306](https://chromium-review.googlesource.com/c/chromium/src/+/6172306), fixed 386860174) | 130.0.6708.0 y 134.0.6969.0 (no está en la 133) | (a), repartido en dos niveles (V: Chrome 128 fallaba las mismas) | Nivel 130: `ConsumeFontWeight` (rechazar por rango solo si es literal); `FontFace::GetFontSelectionCapabilities` con `EnsureLengthResolver()` y `media_values_`. Nivel 134: `StyleBuilderConverterBase::ConvertFontWeight(CSSLengthResolver, …)` con `std::clamp(…,1.,1000.)` y sus llamantes (`style_builder_converter`, `font_style_resolver.cc`, `css_font_weight_interpolation_type.cc`). Cuidado: el 134 arregla un crash de `font-weight-computed.html` (crbug 386860174); portar solo el 130 puede reintroducirlo. Verificar antes qué hay de la serie 40946458 (`ComputeNumber`, `CSSLengthResolver`). |
| `font-variant-emoji-003`, `-004` | font-variant-emoji, segmentación por variation selectors | `2dd4dd5c8e` ([CL 5558566](https://chromium-review.googlesource.com/c/chromium/src/+/5558566)); `02f86b6b3e` (símbolos por VS); `4022019412` (keycap); `1d107b9505` ([CL 5857777](https://chromium-review.googlesource.com/c/chromium/src/+/5857777), Intent-to-Ship) | Código en 128 (flag `test`); estable en 131.0.6738.0 | (b) función sin portar o flag apagado (S: json5 de FlyWeb como el de 128) | 1) `FontVariantEmoji`, `FontVariationSequences`, `SystemFallbackEmojiVSSupport` a `stable`; comprobar `CSS.supports('font-variant-emoji','text')`. 2) Si no basta, orden: `d95ffd45a4`, `2557af8502`, `68d2660233`, `d6804f67fb`, `02f86b6b3e` + `4022019412` (más el emoji-segmenter a 955936be), `cdd7df039d`. Pruebas con web fonts solo: no dependen del sistema (V). |
| `variation-sequences.html` | Variation sequences | `821199b80e` (Mac, Apple Symbols), `2557af8502` (tablas de color), flag `FontVariationSequences` | 129.0.6657.0 y 132.0.6793.0; estable 131 | (b)/(a) | Igual que la fila anterior; Mac: `font_cache_mac.mm`. Fallback de sistema `sans-serif` (puede depender de fuentes). |
| `font-variant-emoji-2.html` | font-variant-emoji, fallback del sistema | `ea2b9d906c` (CL 5915498), `7b4f82e35c` (CL 5923974: «STIX Two Math» solo en macOS 13+), `821199b80e`, `2557af8502` | 129–132 | (c)+(b): usa `serif` con U+263A, depende de Apple Color Emoji/Apple Symbols. En Chrome 128 estaba `[ Mac ] Failure Pass` (crbug 1377794); en 134 ya sin excepción en Mac | Tras la receta de arriba, comparar capturas Sequoia/Mojave; no verificado que Mojave coincida. Portar `font_cache_mac.mm` de 134 entero (cambió mucho: `96d2ad0df4` quitó `FontMatchingCTMigration` en 130). |
| `canvas.2d.offscreen.transferred.direction.inherit(.document).html` | OffscreenCanvas, `direction="inherit"` | `ba17fa15de` «Fix direction = "inherit" for offscreen canvas» ([CL 6173291](https://chromium-review.googlesource.com/c/chromium/src/+/6173291), bug 390272618), 22-ene-2025 | 134.0.6998.0 (no está en 133) | (a) | `CanvasRenderingContextHost::GetTextDirection`; `HTMLCanvasElement::GetTextDirection` (código de `ToTextDirection`); `OffscreenCanvas` con `text_direction_` (en ventana, toma `documentElement()->CachedDirectionality()`); `transferControlToOffscreen` llama a `SetTextDirection`; `ToTextDirection` delega en el host. Un commit pequeño. |
| `getContextAttributes.html` (`desynchronized: true`) | OffscreenCanvas `getContextAttributes` | `06ed9ecbb6` ([CL 6157723](https://chromium-review.googlesource.com/c/chromium/src/+/6157723), bug 388290815); `147011978a` (CL 6169595); `01423875ef` (CL 6190630, flag a stable) | 134 (9–24-ene-2025) | (a) | Añadir `desynchronized_specified` a `CanvasContextCreationAttributesCore`; rellenarlo en `ToCanvasContextCreationAttributes` (mantener `desynchronized=false` en Mac); devolverlo en `ToCanvasRenderingContext2DSettings`. Chrome no implementa `desynchronized` real en Mac y la prueba pasa porque devuelve el valor pedido. Supuesto: ya tenemos `147011978a`. |

## Lo que cambia respecto a la lectura provisional de LOCAL-14

- «Parece de la 128 y no portado»: `font-variant-emoji` y `variation-sequences` son **flags apagados en la 128** (`test` y
  `experimental`), no función ausente; el clamp de `calc()` **no es de la 128**, es de dos niveles (130 y 134); la dirección
  de OffscreenCanvas y `desynchronized` son **de la 134** (commits de enero de 2025), no de la 128.
- `HighlightInheritance` y la edición (`inserthtml`): el arreglo de edición es de la **133**; los de highlights son
  estado de flag. `CSSFontFeatureValuesRule`: arreglo de la **134** por un cambio del parser.
- Ningún caso encaja con «Chrome tuvo el mismo fallo, lo arregló varias versiones después de la nuestra». Lo más
  parecido: `20d6d52ab7` (CSSFontFeatureValuesRule) y `8c249d6e26` (clamp), que Chrome arregló **dentro** del 134 sin que
  nadie los reportara como fallo de la prueba; las pruebas pasan en CfT 134 por esos commits, no por Finch.
- Finch/campo: descartado donde se miró (el estado de los flags sale de `runtime_enabled_features.json5`, sin base feature).

## Editing: commits de `editing/` entre 128 y 134 para comparar con las 9 correcciones portadas

133: `347bc308e2` (falta, arriba); `40b7ad251` (CL 6108523); `c628c8740` (CL 6147627, límite 133/134, S); fuera de
`commands/`: `5e3445b32` y `b88ffb57d` (serialización de table/list al copiar), `79f70da3e`. 134: `149cf3a35` (CL 6147652),
`039ad3ac2` (6151777), `ccd35d9b2` (6090765, `ConsiderFullChildNodeContentForListify`), `b4d5bf638` (6123536),
`30a2b3096` (6121394), `49f2e7b91` (6214650), `60f09135f`, `0f305ff7a`, `a6a397a84`. 129–132: ver la lista completa en el
informe de origen (144 commits, no guardado en el repo). MOTOR sabe cuáles son las 9: este cruce es lo que queda por hacer.

## Método (repetible en cada nivel)

1. **Lista de diferencias** del informe WPT de LOCAL (`wpt-NNN.md`). Agrupar por función, no por prueba.
2. **Descartar flaky**: pedir a LOCAL que repita las colgadas/sueltas antes de investigar (caso `highlight-cascade-010`).
3. **Estado del flag**: `+/refs/tags/<N.0.B.0>/third_party/blink/renderer/platform/runtime_enabled_features.json5?format=TEXT`
   (base64) en la 128 y en el tag del nivel. Un flag `test`/`experimental` en nuestra base y `stable` en el nivel es lo
   más barato de descartar.
4. **Historial**: Gitiles **deniega** `+log/<ref>/<ruta>` y `+blame` (401/403) y bloquea con CAPTCHA algunas redirecciones.
   Lo que sí funciona: `+log/<tagA>..<tagB>?format=JSON&name-status=1` sin ruta, recorrido por rangos y filtrado local por
   ruta y mensaje; `+/<sha>?format=JSON` y `+/<sha>^!/?format=TEXT` (base64); `+/<tag>/<ruta>?format=TEXT` para comparar ids
   de blob entre tags (bisección). El tag que contiene un commit se localiza por bisección de tags de desarrollo.
   No se evaden bloqueos.
5. **Qué pasa en Chrome**: wpt.fyi (API JSON, runs stable por versión) para la prueba; `-expected.txt`, `TestExpectations`,
   `WPTOverrideExpectations`, `NeverFixTests` y `FlagExpectations` en el tag; los `-expected.txt` modificados por un
   commit muestran qué pruebas arregló. Los mensajes traen `Bug:` y `Reviewed-on: …/c/chromium/src/+/NNN`.
6. **Clasificar** (a)–(d); el nivel de cada arreglo es el primer tag que lo contiene. Marcar siempre lo verificado frente
   a lo supuesto.
7. **Entorno**: comprobar si la prueba usa fuentes del sistema (`serif`/`sans-serif`, Apple Color Emoji) antes de culpar al motor.
8. Tiempo: ~6 agentes en paralelo, 8–40 min cada uno; el cuello de botella es el recorrido del log por tags.

## Límites de esta investigación

- No hay acceso a `issues.chromium.org` como fuente (los números de bug salen de los mensajes de commit) ni a
  `+log/<ruta>` de Gitiles; los commits se localizan por comparación de contenido entre tags y por filtrado de mensajes,
  búsqueda por palabras clave no exhaustiva.
- No se ha visto el árbol de brave-core: «falta tal commit» es una hipótesis hasta que MOTOR compare.
- Recetas marcadas como suposición: no compiladas ni ejecutadas.

## Nota de relevo (INVESTIGACIÓN-MOTOR-6)

Hecho: las 16 diferencias restantes, informadas arriba; `highlight-cascade-010` fuera por orden de COORDINACIÓN-20.
Pendiente para MOTOR: (1) json5: los tres flags de emoji/variación y `HighlightInheritance` a `stable`; medir; (2) portar
`ba17fa15de`, `06ed9ecbb6`, `347bc308e2`, los dos de `font-weight` y `20d6d52ab7` (o su mínimo); (3) cruzar la lista de editing con las
9 correcciones; (4) `highlight-paired-cascade-004` sin causa: probar `::target-text` y fragmentos de texto en el ejecutor.
Trampas: raw.githubusercontent.com no sirve historial; Gitiles `+log/<ruta>` no funciona; github.com/chromium/chromium da 403.
