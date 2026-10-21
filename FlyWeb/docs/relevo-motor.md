# Relevo de MOTOR: de MOTOR-12 a MOTOR-13 (20-10-2026, ~16:55)

MOTOR-12 (`session_011EsiQBkq6YnhGgGrmbgtLD`, Opus 5.5, `xhigh`) cerró FM.22 y la 1.15.1. Lo hecho está en la fila FM.22,
en `FlyWeb/docs/version-1.15.1.md` y en `FlyWeb/tools/port/fm22-escapes.tsv` (decisión y commit por flag). **Tu encargo es
FM.28 (1.15.2 = anchor positioning)**; FM.29 (view transitions entre documentos) va después. Aquí va lo que no está allí.

**Ramas de brave-core:**

| Rama | Cabeza | Estado |
|---|---|---|
| `nube/motor-131-escapes` | **fa4fae392f** | **1.15.1** (FM.22 entero, 9b35099024, + `flyweb_version` 1.15.1). Base de FM.28: abre `nube/motor-131-anchor` sobre ella |
| `nube/motor-131` | 057630a8c8 | 1.15 publicada; solo de referencia |
| `nube/motor-131-escapes-c` | 27184cd455 | descartada: punto de compilación de A+B+C (= a06c3c195f + el revert de URL), ya dentro de la principal |
| `nube/motor-131-escapes-ab` | bd51b99f03 | descartada (COORDINACIÓN-7, 19-10) |
| `nube/motor-131-v8`, `nube/motor-130`, `nube/motor-130-v8` | 9b19e7dafc, ccc74ea171, a7b5f3f4aa | de niveles anteriores, ya fundidas; no tocar |

Las `seg/*` son de SEGURIDAD-PORTES; para la 1.15.2 hay que preguntarle cuáles van encima (regla 17, fila FS al abrir el
porte).

**Anchor positioning: lo que ya se sabe (inventario a medias, sin medir).**

- **Flags** (TSV, «anchor positioning (grande)»): CSSAnchorPositioning (stable en 125, quitada en 129; en la 116 es
  `experimental` con la sintaxis vieja: `anchor-default`, `@position-fallback`, `anchor-scroll`), CSSPositionAreaProperty
  y CSSPositionAreaValue (129; antes `inset-area`, flag CSSInsetAreaProperty), CSSPositionTryFallbacks (129; antes
  `position-try-options`, CSSPositionTryOptions, 128) y LastSuccessfulPositionOption (127). **Falta en el TSV
  `CSSAnchorScope`** (`anchor-scope`, stable en la 131 con 19879a57c77; cadena ed85a5d9dac → d8145fe9e98): entra en el
  mismo porte. `CSSAnchorSizeInsetsMargins` sigue en `experimental` en la 131: no se porta.
- **Cadena:** `FlyWeb/tools/port/anchor-commits.tsv`, **351 commits** 116→131 que tocan Blink o cc (por mensaje y por
  ruta; incluye refactors de layout fuera de flujo que no son de anchor). Autores principales: Rune Lillesveen y Anders
  Hartvoll Ruud (78 cada uno; cascada y estilos «try»), Xianzhu Wang (26; pintado y scroll), Xiaocheng Hu, Ian
  Kilpatrick, Mason Freed. Picos: 67 en marzo y 57 en abril de 2024 (el empuje para enviar en la 125); de junio a octubre
  de 2024, ~60 más (renombres a `position-area`/`position-try-fallbacks`, `anchor-scope`, arreglos). Hay ~13 de caídas,
  CHECK y DCHECK (011f3e7fbc4 `anchor-center`, 90dcf85bbd0 recursos de degradado, fa46d3db922 pseudoelementos,
  e31ab09377f/614e1399b0a inspector con `@position-try`, ae3e1415f4d bloque contenedor *inline*…): no saltarse ninguno.
  Los «[Anchor]» de Android (plegables, pulsación larga) son ruido.
- **Ficheros:** `FlyWeb/tools/port/anchor-ficheros.txt` (los 287 commits con etiqueta, sin tests). Lo más tocado:
  `layout/out_of_flow_layout_part.cc` (64; en la 116 `layout/ng/ng_out_of_flow_layout_part.cc`), `longhands_custom.cc` y
  `css_properties.json5` (38), `runtime_enabled_features.json5` (31), `style_resolver.cc`, `css_math_expression_node.cc`,
  `style_engine.cc`, `anchor_position_scroll_data.cc` (en la 116 `anchor_scroll_data.cc`), `element.cc`,
  `layout_box.cc`, `anchor_evaluator_impl.cc`, `absolute_utils.cc`, `style_cascade.cc`, `paint_property_tree_builder.cc`,
  y en cc `cc/trees` (8: el ajuste por scroll en el compositor). Ficheros nuevos de la 131: `css/anchor_query.*`,
  `css/anchor_results.*`, `css/css_position_try_rule.*`, `css/css_position_try_descriptors.*`, `css/try_value_flips.*`,
  `css/try_tactic_transform.h`, `css/out_of_flow_data.h`, `layout/anchor_evaluator_impl.*`, `layout/anchor_query_map.*`,
  `layout/anchor_position_visibility_observer.*`, `style/position_area.*`, `style/position_try_fallbacks.*`,
  `style/anchor_specifier_value.*`, `style/style_anchor_scope.h`.
- **Ya en brave-core** sobre esos ficheros: `ng_anchor_query.cc/.h` y `ng_out_of_flow_layout_part.cc/.h`
  (GetComputedStyleOutOfFlowInsetsFix, FM.22 C, 97e933485b) y `ng_absolute_utils.cc` (align-self/justify-self en
  absolutos, nivel 122, 0bb9d3bf1a). Además el layout lleva RubyLB (128). Cuenta con ellos al medir.
- **Propuesta de método:** medir antes de prometer (`medirng.sh anchor $(cut -f1 anchor-commits.tsv | grep -v '^#')`);
  separar lo que es solo refactor de OOF; portar por fases cronológicas: hasta el envío de la 125 (abril de 2024), luego
  126–131. Muchos commits de 2024 reescriben lo de 2023 (renombres), así que para algunas partes puede salir más barato
  portar el estado final a mano (lección de los niveles 117–124). Privacidad (regla 20): sin superficie nueva aparente
  (es layout), pero `position-visibility` y el observador de visibilidad conviene mirarlos. Estimación de MOTOR-11:
  18–28 h, riesgo alto de caídas de layout.

**Entorno que no pasa a otra sesión** (en esta: ~30 GB libres al empezar; ~15 min en montarlo):

- brave-core: `git clone --depth 1 --branch nube/motor-131-escapes https://github.com/lamosquita-net/brave-core
  /home/user/brave-core` (tras `add_repo` con `push`), y `git fetch --depth 300 origin <rama>` para historia.
- Historia de Chromium para `git show`/`git log` (la usan `portarng.sh`, `chk.sh`, `mkws.sh`): en `/home/user/chromium/chromium`,
  `git init`, `git remote add origin https://github.com/chromium/chromium`, `git config gc.auto 0`,
  `git fetch --filter=blob:none --shallow-since=2023-05-15 origin refs/tags/116.0.5845.188:refs/tags/116.0.5845.188
  refs/tags/131.0.6778.265:refs/tags/131.0.6778.265` (~2 min, ~500 MB; los *blobs* bajan solos al pedirlos).
- `cp FlyWeb/tools/port/* FlyWeb/tools/bindings/*.{sh,py} /tmp/claude-0/port/`; `mkcr.sh /home/user/cr116
  116.0.5845.188` y `mkcr.sh /tmp/claude-0/port/cr131 131.0.6778.265` (~1 min cada una);
  `python3 ngmap.py /home/user/cr116 /tmp/claude-0/port/cr131 > /tmp/claude-0/port/ngmap.json` (~1 min).
- **Cambiar la sesión en las firmas:** `fin.sh`, `flip.sh` y `tanda.py` llevan fija la sesión de quien los usó; en la copia
  de `/tmp/claude-0/port`, `sed -i 's/session_011EsiQBkq6YnhGgGrmbgtLD/<tu sesión>/' fin.sh flip.sh tanda.py`.
- Comprobaciones sin compilar: en `cr116`, `git sparse-checkout add /third_party/mako/ /third_party/ply/
  /third_party/pyjson5/ /tools/idl_parser/ /build/ /third_party/jinja2/ /third_party/markupsafe/`; luego `mksrc.sh
  /tmp/claude-0/port/b`, `runbind.sh /tmp/claude-0/port/b/src async_iterator … union` (~2 min), `checklist.py` y, **desde
  `/tmp/claude-0/port/out`** (si no, falla buscando `args.gn`), `check_generated_file_list.py` y `validate_web_idl.py`;
  `gencss.sh <dir>` para json5 de flags, estilo y CSS (aquí no había `gperf`: sin `css_property_names` ni
  `css_value_keywords`; para el anchor, que añade propiedades y palabras clave, intenta instalarlo).
  `chk.sh HEAD` entero tarda ~15–20 min (en segundo plano).
- Lista de WPT: `git ls-tree -r --name-only 131.0.6778.265 third_party/blink/web_tests/external/wpt/` en la historia de
  Chromium y filtrar (`css/css-anchor-position/` entero; ver `wpt-fm22-d-lista.txt` como formato).
- `webrtc.googlesource.com` (y googlesource en general) no es accesible desde la nube; GitHub sí.

**Trampas de FM.22 que sirven para el anchor:**

- **API de la 116 aunque la V8 sea la 13.1:** en Blink, `Vector<v8::Local<v8::Value>>` y `ToV8()` (no `v8::LocalVector`
  ni `ToV8Traits<T>::ToV8`), `ScriptPromise` sin tipo, `absl::optional`, `gfx::RectF` solo desde `gfx::SizeF` (el único
  error del Static de la D, 9b35099024). Antes de entregar, buscar en el código añadido (`git show … -- patches | grep
  '^++'`) `std::optional`, `base::expected`, `raw_ptr`, `LocalVector`, `ToV8Traits`, `ScriptPromise<`, y comprobar que cada
  `#include` añadido existe en la 116, en un parche o es generado.
- **Los tests de Blink compilan** (LOCAL construye `blink_unittests`): `portarng.sh` excluye los `_test.cc`; si un commit
  renombra una API, hay que llevar también su test (como en AutoSizeLazyLoadedImages).
- **El commit que «añade la flag» casi nunca trae el código:** buscar la cadena por etiqueta del mensaje y por ruta, y
  mirar los commits entre el de la flag y el que la quita.
- **Listas y nombres de la 116:** `idl_in_modules.gni` con otra sangría, `BUILD.gn` con los nombres viejos
  (`type_converters.cc`), `generated_in_*.gni` (comprobado por `check_generated_file_list`). En el anchor, sobre todo
  `css_properties.json5` y `css_value_keywords.json5`: ver las trampas de R4–R5 del README (sin `invalidate:` ni
  `valid_for_permission_element`, `ParseSingleValue` con `CSSParserTokenRange`, `CSSValueFromComputedStyleInternal` de 3
  argumentos).
- **Enums con valor de upstream** (`web_feature.mojom`, `bad_message.h`, `css_property_id.mojom`): insertar con el número
  de upstream y comentario «FlyWeb: upstream value (M1xx)».
- **Flags de Blink y `base::Feature`:** cada entrada del json5 sin `base_feature: "none"` genera
  `blink::features::k<Nombre>`; el navegador puede usarla.
- **Git:** en un clon de una sola rama, `git push origin HEAD:<otra rama>` no actualiza `origin/<otra rama>`: hacer
  `git fetch origin <rama>` antes de `checkout -B` sobre ella. El sha que se da a otro agente, de `git ls-remote` tras el
  push.
- **Cambios en `url/` o en el navegador entero:** consultarlo antes con SEGURIDAD-PORTES; un porte parcial en código
  compartido (el analizador de URL de FM.22) se revirtió por dar un tercer comportamiento.

---

**Relevos anteriores** (MOTOR-2 a MOTOR-12): [`relevo-motor-historial.md`](relevo-motor-historial.md).
