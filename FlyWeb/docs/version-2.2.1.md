# FlyWeb 2.2.1 — `attr()` con tipo (nivel 133)

MOTOR-29, 28-10-2026. Orden de COORDINACIÓN-18 (regla 18): `attr()` avanzado, lo único del 133 que no entró en la 2.2.0,
va en una 1.N.x propia antes de abrir el 134. Mismo nivel declarado (133.0.6943.141).

**Rama:** brave-core `nube/motor-133-attr` **25c9ea731d** = `nube/motor-133` 2f268ee217 (2.2.0) + los dos commits WIP de
MOTOR-28 (5ce740bb, 59d488dd) + 888963ca5 (el resto de la cadena) + 25c9ea731 (`flyweb_version` 2.2.1). Sin compilar.
`FLYWEB_BUILD_NUMBER=35`.

## Qué trae

`CSSAdvancedAttrFunction` completo y en `stable` (como en Chrome 133): `attr(data-x type(<length>))`, unidades
(`attr(data-x px)`), `string` explícito, sustitución de `var()` dentro del valor del atributo, marca de *taint* del valor
entero (un `attr()` no puede acabar en una `url()`) y búsqueda del atributo por nombre local sin espacio de nombres.

Commits de upstream, en orden: 8026a18f3f … 58743c5967 (8, MOTOR-28), 1fc628b444, 0692e7d9b9, 8e710e2016 (MOTOR-28),
5189858a61, 0c00afffe9, **01b72da0c0**, 96a736734d, **774c4ce6b3**, c8d50d1a89, 162e74449d, 1bf714b913, 3d832173db,
8e507ecf45, 82d879b09e, 0c50bb37c1, ac008e348d. Los dos en negrita faltaban en la lista de MOTOR-28 (sin ellos no existe
`CSSAttrType` ni la sintaxis `type()`): salieron con `git log` de la 133 sobre `css_attr_type.*` y `style_cascade.cc`.

## Adaptaciones a la 128 (dónde puede fallar la compilación)

- `CSSVariableParser::ContainsValidVariableReferences()` toma el texto y valida con el `ConsumeUnparsedDeclaration()` de
  *streaming*; los validadores sobre `CSSParserTokenRange` se van, como en upstream. Llamadores: `style_value_factory.cc` y
  `AddCSSPaintArgument()` en `css_parsing_utils.cc` (este serializa los tokens, como ya hacía).
- `CSSParserTokenStream` gana un constructor `(CSSTokenizer&, rangos de taint)`: en la 128 el *stream* lee de un
  `CSSTokenizer`, no del texto. `css_attr_type.cc` y `ResolveAttrInto()` crean su `CSSTokenizer`.
- `ResolveAttrInto()` con la forma final de la 133. Sin `ElementResolveContext::GetUltimateOriginatingElementOrSelf()` en
  la 128: un ayudante local sube desde el pseudoelemento. `ResolveTokensInto()` de la 128 no tiene `stop_type`.
- `ConsumeUnparsedDeclaration()` de la 128 no tiene `comma_ends_declaration` (lo traía 5189858a61).
- `CSSVariableData::Create()` gana `is_attr_tainted` en tercera posición: todos los llamadores están revisados (el de
  `CSSTokenizedValue`, solo de la 128, pasa `false`). Si sale un «no matching function» en `Create`, es un llamador nuevo.
- `css_attr_value_tainting.{cc,h}` desaparecen, como en upstream (sus parches, borrados).

Los `_test.cc` no se portan (como siempre): si LOCAL compila tests de Blink, `css_variable_parser_test.cc` y
`style_cascade_test.cc` no compilarán.

## Pruebas

`FlyWeb/tools/motor-133.html`: seis líneas nuevas de `attr()` (en Chromium 153 salen ok; con la 2.2.0, FALLO). WPT:
`FlyWeb/tools/wpt-221-lista.txt` frente a CfT 133. Riesgo: toca el análisis de propiedades personalizadas y de toda
propiedad con `var()`, así que hay que mirar también `css/css-variables/` y `css/css-properties-values-api/` enteras y
una ronda de sitios (claude.ai, YouTube, GitHub).

## Para la web

FlyWeb 2.2.1 completa el nivel de Chrome 133 con la función `attr()` de CSS ampliada: los atributos de un elemento se
pueden usar como longitudes, colores, números con unidad y cualquier otro tipo de valor en cualquier propiedad, no solo
como texto en `content`. Sin cambios visibles en la interfaz.
