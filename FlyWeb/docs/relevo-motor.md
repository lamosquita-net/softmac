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

# Relevo de MOTOR: de MOTOR-11 a MOTOR-12 (19-10-2026, ~14:00)

MOTOR-11 (`session_01E9YyQZz5fNhwE1HdRNzw6f`, Opus 5.5, `xhigh`) ha hecho FM.22 (escapes posteriores al 131) hasta la
mitad de la tanda D. **Lo decidido por flag está en `FlyWeb/tools/port/fm22-escapes.tsv`** (columnas «decisión», «motivo»
y «hecho en») **y el estado, en la fila FM.22.** Aquí va solo lo que no está allí.

**Ramas de brave-core** (sin compilar salvo lo que diga LOCAL; `chk.sh` limpio en cada commit):

| Rama | Cabeza | Qué |
|---|---|---|
| `nube/motor-131-escapes` | **7fde3677af** | 1.15 (057630a8c8) + tandas A, B y C + la D a medias + los dos arreglos de abajo (bf66b41dcb, 7fde3677af) |
| `nube/motor-131-escapes-c` | **233ad89d5e** | la C (4ea0170cd0) + include de TextControlElement en shadow_root.cc (546e638220) + alfa de :visited en VisitedDependentContextPaint (233ad89d5e, como upstream bb0351bff33): la que compila LOCAL-5 (Static, luego ASan) |
| `nube/motor-131-escapes-ab` | bd51b99f03 | descartada por COORDINACIÓN-7 (no quiere dos rondas de compilación) |

**Por dónde seguir:**

1. **Tanda D, 20 flags sin hacer** (filas «portar · tanda D» del TSV sin «hecho en»). Mi triaje, sin verificar del todo:
   - Probablemente asequibles: AutoSizeLazyLoadedImages (`sizes=auto`; 5d4b16edc6d solo añade el flag, la cadena
     está alrededor), MediaSessionChapterInformation (dd19278e217), MediaSessionEnterPictureInPicture (26c41733c2c),
     MonitorTypeSurfaces (4db3cbc8d10), WebCodecsContentHint (bfda23bf51c, toca `media/video/*_encoder.cc`),
     WebCodecsCopyToRGB (46a82a1b82b), WebCodecsHBDFormats (4d37f17e7a5), WritingSuggestions (0c2f288d8f7 +
     6a27d827306), SecurePaymentConfirmationExtensions (64dc287e677 + fa9c2e1d1a1).
   - Ya están en la 116 como `experimental`: WebGLDrawingBufferStorage y LongAnimationFrameTiming. Comparar el código de
     `cr116` con el del nivel en que pasaron a `stable` (122 y 123) antes de usar `flip.sh`.
   - Mirar primero si la 116 tiene lo que hace falta: RTCRtpEncodingParametersCodec (c5c522ba916; ¿lo soporta la
     WebRTC de la 116?), CSSPhraseLineBreak (9b3d76990e5 solo renombra el flag; ¿hay segmentación por frases en la
     116?), CSSTextSpacingTrim (c94bf36519f solo añade el flag; la implementación es una cadena larga).
   - Grandes, para proponer como porte propio: StorageBuckets, BackForwardCacheNotRestoredReasons,
     CSSScrollSnapChangeEvent/ChangingEvent/Events (la cadena de los eventos de snap toca cc) y
     DocumentPictureInPictureUserActivation (lado navegador).
2. **Pendiente de SEGURIDAD-PORTES:** ClipboardSvg (e5ade70967, escritura de SVG con DOMParser), JS Self-Profiling
   apagado (a9733521ba, `Profiler` tras el flag propio `JSSelfProfiling`) y el arreglo de :visited (233ad89d5e), escrito
   a partir de su descripción porque bb0351bff33 es posterior a la 131 y no está en el clon.
3. **Decidido por COORDINACIÓN-7:** LayoutBlockButton + LayoutBaselineFix, porte propio después de la D; LOCAL compila
   `-c` y la D irá en otra ronda. LOCAL-5 tiene la lista de WPT de A+B (`FlyWeb/tools/wpt-fm22-ab-lista.txt`, 903 pruebas).
4. Cosmético: tres comentarios del json5 quedaron encima de la entrada equivocada (MetaRefreshNoFractional,
   MoveEndingSelectionToListChild, NoIncreasingEndOffsetOnSplittingTextNodes).

**Método de la D** (herramientas en `FlyWeb/tools/port`, README): por cada flag, ver su uso en `cr116`/`cr131`
(`grep -rn <Flag>`) y la cadena con `git log --grep` (los mensajes rara vez nombran el flag: buscar por la API). Si el
código ya está completo en la 116, `flip.sh`; si no, `portarng.sh <flag> <commits…>` o `rp.sh`, arreglar a mano,
`fin.sh` con `MSGFILE=`, `jdiff.sh HEAD` y `push` cada pocos commits.

**Entorno de MOTOR-11, que no pasa a otra sesión:**

- `/home/user/chromium/chromium`: clon sin *blobs* con las etiquetas 116.0.5845.188, 130.0.6723.192, 131.0.6778.265
  y .268. `git grep` sobre él no acaba (baja *blobs*): para buscar, las copias parciales.
- `/home/user/cr116` (sparse de la 116, con `components/`, `cc/paint`, `cc/trees`) y `/tmp/claude-0/port/cr131`
  (`mkcr.sh`); `/tmp/claude-0/port` con las herramientas y `ngmap.json`.

**Trampas de esta sesión:**

- Rechazos solapados: si dos commits de una cadena fallan en el mismo fichero, el `.rej` del segundo pisa al primero
  (pasó con el json5 de HTMLSelectElementShowPicker). `rp.sh` los enseña; mirar siempre que el flag quedó en el json5.
- `portarng.sh` solo monta los ficheros que tocan los commits: si falta el json5 (para poner el flag en `stable`) o el
  `ng/` de la 116 que corresponde a un `.rej`, volver a montar con `mkws.sh` o usar `addfiles.sh`.
- El `context_usage` de `get_session` puede ir atrasado; contar con el contador de tokens.
- LOCAL-5 (`session_01DCZDzGMM8VdHsV5B5JBXmv`) sí recibe `send_message` desde la nube.
- Notificaciones en cola: dos órdenes de COORDINACIÓN llegaron con 30–45 min de retraso. Leer `ReadNotifications` en
  cada hito.

---

# Relevo de MOTOR: de MOTOR-10 a MOTOR-11 (15-10-2026, ~18:35)

MOTOR-10 (`session_017osmPdTipjmbHoMeuQDeJ4`, Opus 5.5, `xhigh`) ha hecho el nivel 130 en código (1.14), el recorte de
superficie, los dos escapes de seguridad y el inventario del 131. **Lo decidido del 131 está en `motor.md` «Nivel 131»
§1–§10 y en la fila FM.21**; lo del 130, en «Nivel 130» §12, FM.20 y `version-1.14.md`. Aquí va solo lo que no está
allí.

**Ramas de brave-core:**

| Rama | Cabeza | Qué |
|---|---|---|
| `nube/escapes-seg-1.14.1` | **303e498fb5** | **la 1.14** (decisión de COORDINACIÓN-6): `nube/motor-130` + los dos escapes de seguridad. El nombre de la rama es anterior a esa decisión |
| `nube/motor-130` | ccc74ea171 | nivel 130 + FS.14 + FS.15 (`seg/popup-sandbox`) |
| `nube/motor-130-v8` | a7b5f3f4aa | solo el paso de V8 13.0 (referencia) |
| `seg/ml-kem` | fc0f45c433 | FS.17 (SEGURIDAD-PORTES-3). **Solo en `nube/motor-131`, nunca en una 1.14.x.** Con `git merge-tree` entra sin conflictos sobre 303e498fb5. Cambia `build/commands/lib/util.js` (BoringSSL entra en `flywebRepos`) y `chromium_src/net/base/features.*`: si se tocan, avisar a SEGURIDAD-PORTES-3 |
| `seg/oopsif` | 57c1b3fa2a | la 1.14.1 (la 1.14 + OOPSIF); no es de MOTOR |
| `nube/prueba-motor10` | 0c95523439 | la prueba de escritura; el proxy no deja borrar ramas (403) |

**Por dónde empezar** (orden de §10; el 131 empieza ya, por orden de COORDINACIÓN-7):

1. `nube/motor-131` desde **303e498fb5**; `git merge` de `seg/ml-kem` fc0f45c433.
2. Paso de V8: `FlyWeb/v8-revision` → `9c09e7876ff830e1f9a731aa930040d1028ff5a1` (13.1.201.22, la V8 de la
   131.0.6778.265 y cabeza de su rama); `v8re.sh 3551594a5f6604c7e5070f408cc81d60d08ddbbf 9c09e787…`; en Blink, solo
   `use_counter_callback.cc` (`kImportAssertionDeprecatedSyntax` → `kOBSOLETE_ImportAssertionDeprecatedSyntax`); en
   `flag-definitions.h` desaparece `wasm_to_js_generic_wrapper`. Avisar a SEGURIDAD-PORTES-3 con la rama (como en el
   130: MOTOR rehace `patches/v8`, ella revisa y sube la época de caché a 16).
3. Baseline (§2), flags (§3), los cuatro aplazados (§7), los escapes del §6 que no son de seguridad y 4888675b6c9.
   `wpt-131-lista.txt` con **todas** las WPT de color del 131 (decisión iii), para comparar con CfT 131.
4. Declarar 131.0.6778.265 / 1.15; `motor-131.html`, `version-1.15.md`.

**Entorno de MOTOR-10, que no pasa a otra sesión (rehacerlo cuesta ~30 min):**

- Clon sin *blobs* de `github.com/chromium/chromium` en `/home/user/chromium/chromium`, con las etiquetas 116, 117–128
  (la última de cada rama), 129.0.6668.112, 130.0.6723.192, 131.0.6778.265 y .268. Las 117–128 se traen con
  `git ls-remote --tags` + `git fetch --no-tags --filter=blob:none origin refs/tags/<t>:refs/tags/<t>` (~20 s).
  `git config gc.auto 0`, o cada `git show` dispara un `gc`.
- `/tmp/claude-0/port`: copia de `FlyWeb/tools/port` con las copias parciales `cr116`, `cr130` y `cr131` (`mkcr.sh`), y
  `bl/` con `npm install web-features @mdn/browser-compat-data` (3.42.0 / 8.1.6) y `bl/json5/<N>.json5` de cada nivel
  (para `flags-escapes.py`).
- V8: clon sin *blobs* de `github.com/v8/v8` con 13.0.245.25 y 13.1.201.22. BoringSSL: clon sin *blobs* de
  `github.com/google/boringssl`, con ae88f198 (116) y cd952104 (131).
- `gencss.sh` y `mksrc.sh` leen `/home/user/cr116` (sparse de la 116 con `third_party/{mako,ply,pyjson5,jinja2,markupsafe}`
  y `build`).
- `chromium.googlesource.com` está bloqueado: usar los espejos de GitHub. `pip install json5` puede pedir
  `--break-system-packages`.

**Trampas de esta sesión** (las de porte están en `FlyWeb/tools/port/README.md`, «Lecciones del porte del 130» e
«Inventario del 131»):

- Un `--amend` después de `commitarea.sh` cambia el hash. Di c6ab0716d4 por 303e498fb5 a tres agentes. El id se lee
  con `git ls-remote` después del `push`.
- Antes de nombrar una fila FS.N o FM.N, mirar en `docs/TAREAS.md` de `main` que no exista (la FS.16 ya estaba cogida).
- `medirng.sh` medía todo a cero sin avisar cuando la ruta del clon no existía; ahora la lee de `CH`.
- Notificaciones atrasadas: las decisiones de COORDINACIÓN pueden llegar en la cola con más de una hora de retraso
  (las de superficie llegaron después de cerrar el código). Leer `ReadNotifications` al arrancar y antes de cada hito.
- Para escribir a otra sesión, `send_message` del servidor `claude-code-remote` con el `session_…`; `SendMessage` al
  puente `bridge:` falla desde la nube.
- Un dato de compatibilidad (BCD o web-features) no se escribe sin consultarlo: tuve que quitar dos del inventario.

**Mediciones de MOTOR-10** (`get_session` a las 16:22 UTC; desde las 13:46 UTC): salida 482 k, caché leída 299 M,
escrita 1,35 M, 80,3 USD, contexto al 67 % (671 k de 1 M), con una compactación. Tiempos de reloj (hora de Madrid):
paso de V8 13.0 a las ~15:55; nivel 130 en código a las ~17:25; recorte de superficie y documentos hasta las ~17:50;
inventario del 131 de ~17:35 a ~18:05. Retrabajo: el hash del `--amend`, dos datos de compatibilidad sin verificar y
FS.16 → FS.17. La estimación del 130 para MOTOR fue unas cuatro veces pesimista (§9 del 131).

**Abierto al relevar:** PR softmac #264 (`getInnerHTML()` se queda apagado en la 1.14; solo documentos). Lo que
encuentre LOCAL-4 en la 1.14 (303e498fb5) sigue siendo de MOTOR hasta que MOTOR-11 esté activa y anotada.

---

# Relevo de MOTOR: de MOTOR-9 a MOTOR-10 (15-10-2026, ~15:50)

MOTOR-9 (`session_01A2ekckH79a4mrqqLCyERtY`, Opus 5.5, `xhigh`) hizo el inventario del nivel 130 (FM.20) pero no
llegó a portar nada: la sesión no pudo escribir en brave-core. **Todo lo decidido está en `motor.md` «Nivel 130»
§1–§11 y en la fila FM.20.** Aquí va solo lo que no está allí.

- **Base de `nube/motor-130`: `nube/ruby-003` 0c95523439** (aprobada por LOCAL-4). Sale directamente de la 1.13
  (325686916c) y ya lleva la fuente fija japonesa completa (fff00651a17 y las `_ja.xtb`).
- **Preparado para brave-core** en `FlyWeb/tools/port/nivel130/`:
  - `fast_float-revision` va a `FlyWeb/fast_float-revision` de brave-core.
  - `fast_float/BUILD.gn` y `fast_float/README.chromium` van como parches de fichero nuevo
    (`patches/third_party-fast_float-BUILD.gn.patch` y `…-README.chromium.patch`).
  - `gin-opcion-b.diff` es el cambio contra la 116. Se junta con los parches de gin que ya hay, que no tocan
    `GetForegroundTaskRunner`, y el `.patch` se rehace con el área (`mkws.sh` + `generar.sh`).
  - `build.sh` de `main` ya trae `fast_float`; LOCAL-4 lo probó.
- **Esperando a LOCAL-4** (está en su cola), antes de cerrar la lista de apagados:
  - `getInnerHTML()` en CfT 130;
  - `document.domain` en CfT 129;
  - JA4 frente a CfT 129 y 130 para el código ALPS;
  - la primera pasada de `superficie.html`, 1.13 frente a CfT 129.
- **`version-1.14.md`** está por crear. En «Para la web» tiene que decir: «WebSQL ya no existe, como en Chrome desde la
  119» (COORDINACIÓN-6).
- **Avisos al empezar el paso de V8:** a SEGURIDAD-PORTES-2 (`session_01YPgb1ubsQCorSgZWaRVgoF`, FS.14) y a
  COORDINACIÓN-6. Lo que FS.14 tiene que revisar está en §1 y §7.
- **Entorno, ~1 h:**
  - Historia de Chromium sin blobs en `/tmp/claude-0/port/chromium/chromium`, con las cabezas de rama de la 116 a la
    133 (las de la 117–125 y 131–133, en `heads*.txt`).
  - Copias parciales con `mkcr.sh` de la 116, la 129 y la 130.
  - V8 sin blobs y `git worktree` de 12.9.202.28 y 13.0.245.25: para buscar, nunca `git grep` sobre el clon sin blobs.
  - `npm install web-features @mdn/browser-compat-data` y `pip install json5`.
  - brave-core en lectura se clona sin credenciales (es público). Para escribir hace falta `add_repo` con `push`, y
    se clona en otra ruta (`/home/user/brave-core`). `medirng.sh` usa `BC=<ruta>/patches`.
- **Trampas que se repitieron:**
  - `pkill -f` con un patrón que sale en el propio comando mata la shell (me pasó otra vez): matar por PID.
  - En una tubería, `$(…)` se evalúa antes de que termine el comando de la izquierda.
  - `medir.sh` contaba un rechazo de más por cada fichero con rechazos (ya corregido).
  - Copiar la unidad de estimación de otro inventario sin compararla con el tiempo real (§11).
- **Mediciones de MOTOR-9** (`get_session`, de 07:42 a 13:45 UTC, con esperas): salida 217 k, caché leída 97 M,
  escrita 1,09 M, 32,5 USD, contexto al 66 %. Retrabajo:
  - la estimación en «días» (corregida a horas);
  - `MutationEvents`: lo di por no escapado mirando solo el código, y Finch lo apagó en la 127;
  - las medidas sobre la 116 sola, rehechas en cuanto hubo brave-core.

---

# Relevo de MOTOR: de MOTOR-8 a MOTOR-9 (preparada el 14-10-2026, ~22:50; cerrada el 15-10, ~15:45)

MOTOR-8 (`session_01YAuwa2BsTVR6GZqzr1wtex`, esfuerzo extra) lleva el nivel 129 (FM.19) hasta la entrega de
la **1.13**. MOTOR-9 empieza por aquí, la fila FM.19 de `docs/TAREAS.md` (reglas 16–19), `motor.md` «Nivel 129»,
`version-1.13.md` y `FlyWeb/tools/port/README.md` («Lecciones del nivel 129»). Al HUMANO se le llama **Titín**
(CLAUDE.md); en el tablero sigue siendo HUMANO.

**Ramas de brave-core:**

| Rama | Cabeza | Qué |
|---|---|---|
| `nube/motor-129` | **325686916c** | **1.13**: paso de V8 + FS.13 + Baseline y flags del 129 + `binaryType` (43ef04cf64) + Menlo. Static y WPT del 129 iguales a Chrome 129; ASan de 43ef04cf64 limpio; Release (build 22) en LOCAL-3 |
| `nube/motor-129-v8` | fdac7ed13b | paso de V8 12.9.202.28 + `seg/v8-12.9` (árbol idéntico); Static y ASan limpios |
| `seg/v8-12.9` / `seg/blink-129` | 2ffa1017bc / 63ea2663a0 | FS.13, fundidas |
| `nube/fuente-menlo` | 325686916c | lo mismo que la cabeza; se puede borrar |

**Lo que queda:**
1. **Entrega de la 1.13** (regla 11): falta que Titín apruebe en LuLu el binario nuevo para las pruebas de red de la
   Release (el caso de RTCDataChannel de `motor-129` necesita UDP local). Si LOCAL-3 encuentra algo, se arregla en
   `nube/motor-129`.
2. **`block-ruby-003`**: falla desde macOS 15.8.1 en la 1.12.2 y la 1.13 (Chrome 129 pasa). Con Menlo debería pasar
   (era la fuente `monospace`); si no, mirar el texto de la anotación (glifo de 5 px).
3. **Nivel 130** (lo abre COORDINACIÓN): inventario primero (Baseline, flags a `stable`, API de V8 13.0), lista de commits
   de `git log <tag 129>..<tag 130>` y fila FS de la regla 17 al abrir un porte grande. **Regla 18:** un nivel, una
   versión, con la V8 de Chrome N; solo un cambio muy amplio se reparte en 1.N.x. **Regla 19:** al saltar de V8,
   comparar `flag-definitions.h` de upstream con nuestras opciones apagadas (la tabla la lleva SEGURIDAD-PORTES).
4. **Fuera del 129, con motivo** (`motor.md`): `hints` y `supplementalPubKeys` de WebAuthn, 3 flags que dependen de
   código posterior a la 116, lo no Baseline (*anchor positioning*, `scheduler.yield()`, `calc-size()`, eventos de
   *scroll snap*) y la lista japonesa de fuente fija (necesita `PrefsFontList`).

**Proceso (COORDINACIÓN-5, 14-10):** COORDINACIÓN funde los PR con *squash*; avisarle antes de subir más commits a un
PR abierto, y si algo llega tarde, PR nuevo (nunca reutilizar el fundido). `patches/v8` es terreno de SEGURIDAD-PORTES:
el permiso de la sesión bloqueó a MOTOR-8 encender una opción de V8 («Security Weaken») y no se rodeó; lo hizo ella.

**Trampas nuevas:**
- **Capturas de reftests:** con emulación de viewport la 116 daba 200 px falsos; `wpt-ref.py` ya no emula (README).
  Antes de declarar una excepción: control sin la función, coordenadas de los píxeles y Chrome for Testing N en el
  mismo Mac.
- **Cambios fuera de Blink:** la fuente fija de Mac (`chrome/app/resources/locale_settings_mac.grd`) cambió en la 118 y
  nadie la vio en cinco niveles. En cada nivel, mirar también `chrome/app/resources/*.grd` y las preferencias web por
  defecto.
- **Tipos del IDL:** comparar el `.idl` con el de la N aunque el commit portado no lo toque (`binaryType`).
- **`chk.sh` no comprueba `patches/v8`:** `git apply --check` de cada parche sobre la V8 limpia (71/71 en la 12.9).
- **Historia del clon de Chromium:** entre la 116 y la 129 está injertada (`git log` devuelve un «Roll R8» falso); para
  fechar un cambio, bajar etiquetas sueltas (`git fetch --depth=1 --filter=tree:0 origin refs/tags/<t>:refs/tags/<t>`)
  y bisecar. `chromium.googlesource.com` no resuelve desde el contenedor. En los clones, `git config gc.auto 0`.
- **`runbind.sh`** solo genera *bindings* si se le pasa la tarea (`runbind.sh <árbol> interface`).

**Cierre (15-10, MOTOR-8, en paralelo a MOTOR-9 y solo con esto, por orden de COORDINACIÓN-5/6):** la 1.13 está
publicada (157.64.22). `block-ruby-003` queda **resuelto en `nube/ruby-003` 0c95523439** (encima de 325686916c), probado
por LOCAL-4: la «X» en Menlo y la «る» en Hiragino, como en CfT 129; 0 px en 3/3; ningún diálogo de descarga de
fuentes; WPT de ruby 112/113 (la 1.13 daba 111). **La funde MOTOR-9 en `nube/motor-130` (va con la 1.14).** Causa:
la prueba es `lang="ja"`, y el `monospace` japonés usa la fuente fija del alfabeto (`IDS_FIXED_FONT_FAMILY_JAPANESE`),
que en la 116 era «Osaka-Mono», una fuente que se descarga desde Sierra (también falta en Mojave). Lleva la cadena de
Chrome 127–128: `kPrefsFontList` (`prefs_tab_helper.cc`), la rama de Mac de `FirstAvailableOrFirst` (`font_list.cc`, sin el
diálogo de descarga), la lista «,Osaka,BIZ UDGothic,Menlo» en `locale_settings_mac.grd` y `locale_settings_mac_ja.xtb`,
y «Osaka» → «Osaka-Mono» en `GenericFontFamilySettings::Fixed()` (fff00651a17; el `.xtb` y esta última pieza las encontró MOTOR-9).
**Lección:** las preferencias de fuentes por defecto (recursos de `chrome/` y su lectura en Blink) se escaparon en
cinco niveles; MOTOR-9 las barre del 117 al 130 en FM.20 (#226).

**Mediciones de MOTOR-8** (`get_session`, del 14-10 10:53 a 20:45 UTC, con horas de espera a LOCAL-3 y SEGURIDAD-PORTES):
salida 471 k, caché leída 255 M, escrita 1,68 M, entrada sin caché 34 k; 73,8 USD; contexto al 54 %. Retrabajo: el
cierre de claude.ai en el paso de V8 (opción de V8 apagada, resuelto con la regla 19), 2 diferencias de WPT (una mía,
`binaryType`; otra de la captura) y la fuente fija de la 118. Al cerrar (15-10, 13:44 UTC): salida 527 k, caché leída 311 M, escrita 2,95 M, entrada sin caché 51 k; 96,3 USD;
contexto al 71 %.

---

# Relevo de MOTOR: de MOTOR-7 a MOTOR-8 (14-10-2026, ~10:15)

MOTOR-7 (`session_01FLXeqsEpvbFSdseBoe6hzc`, Opus 5.5, esfuerzo extra) cierra el nivel 128 (1.12.1 entregada) y deja la
1.12.2 en código para LOCAL-3; se releva con el contexto al ~67 % por orden de COORDINACIÓN-5 (nada del 129 en MOTOR-7).
MOTOR-8 empieza por aquí, las filas FM.16 y FM.18 de `docs/TAREAS.md`, `motor.md` «Nivel 128» y `FlyWeb/tools/port/README.md`. No hay nada a medio
escribir ni sin subir.

**Ramas de brave-core:**

| Rama | Cabeza | Qué |
|---|---|---|
| `nube/v1.11.2` | 5aa57049f | 1.11.2, publicada |
| `nube/motor-128` | 710e7520 | 1.12, publicada |
| `nube/motor-128-ruby` | **bb6c7146** | **1.12.2 en código (FM.18), entregada a LOCAL-3 para compilar** (`FLYWEB_BUILD_NUMBER=21`) = 1.12.1 e6273d015 (entregada a PUBLICACIÓN, 157.64.20: 1.12 + RubyLB + f1b26d42 + e420119c + 611642d8 + FS.11 + parte urgente de FS.12) + 907c95074 (resto de FS.12) + `flyweb_version` 1.12.2 |
| `seg/rubylb-128` | 44c2af834 | FS.11, ya fundida en `-ruby` |
| `seg/inline-116` | 907c95074 | FS.12 completa, ya fundida en `-ruby` |

**Lo que queda, en orden (lo ordena COORDINACIÓN):**
1. **1.12.2 (FM.18):** si el Static, el ASan o la Release de LOCAL-3 sobre bb6c7146 dan algo, se arregla en
   `nube/motor-128-ruby`. Lo más probable, si algo sale: el constructor de copia nuevo de `NGInlineItem` (quita el de
   movimiento implícito, igual que upstream). `flyweb` lo mueve LOCAL tras la firma.
2. **Nivel 129**: lo abre COORDINACIÓN. Como el 128, primero inventario (Baseline + subfunciones + flags a `stable`,
   API de V8 12.9 contra la 116) y lista al HUMANO/COORDINACIÓN antes de portar. **Lecciones del 128:** la lista de
   commits de un porte grande sale de `git log <tag 128>..<tag 129>` (con los `Merged:` de la rama) y por autor, no solo
   de `--grep`; la fila FS de la regla 17 se pide al abrir el porte; `wpt-ref.py` compara las WPT del nivel con lo que
   Chrome N falla (`TestExpectations` + `-expected.txt`), como `wpt-128-ruby-esperado.json`. La rama del 129 sale de
   `nube/motor-128-ruby` (la última del 128, con FS.11 y FS.12).

**Hecho en MOTOR-7:** `version-1.12.md` y `version-1.12.1.md` («Para la web»); WPT del 128 (`wpt-128-lista.txt`,
`wpt-128-ruby-*`); `wpt-ref.py` (reftests, testharness y pruebas de caída, con recuperación de pestañas colgadas) y la
carrera del gancho de testharness también en `wpt-cdp.py`; los 20 errores del Static de RubyLB (f1b26d42); tres portes que
faltaban (e420119c: 1f0b377299b6, ef8ddcab1d8e, b877e3948a59 + 7e72ac335691); FS.11 abierta (regla 17) con
`rubylb-ficheros.tsv` y `rubylb-commits.tsv`; revisión y fusión de FS.11 y de la parte urgente de FS.12; pruebas de esos
arreglos en `FlyWeb/tools/ruby-fs11/`; la 1.12.2 (FM.18: revisión y fusión de 907c95074, `flyweb_version`,
`version-1.12.2.md` y la prueba de `shape-outside`).

**Trampas nuevas (además de las de MOTOR-6):**
- **Entorno rápido:** `cr116` y `cr128` se montan en ~1 min cada uno con `git init` + `sparse-checkout` +
  `git fetch --depth 1 --filter=blob:none origin refs/tags/<tag>`. El clon de Chromium sin árboles (`tree:0`) pesa ~1 GB;
  tenerlo en `/tmp/claude-0/port/chromium/` (no en `/home/user`, por el gancho de parada) y cambiar la ruta en las copias
  de los scripts. El área `w-r3` se rehace con `mkws.sh r3 $(cat r-files.txt)` (los ficheros de los parches que cambian
  entre `nube/motor-128` y `-ruby`) y se comprueba con `generar.sh` (0 cambios en brave-core).
- **`git show <tag>:<ruta>` en el clon `tree:0` es lento** (baja árboles); para ficheros de Blink de la 116 usar `cr116`.
- **`pkill -f` / `pgrep -f` con un patrón que aparece en el propio comando lo mata** (me pasó dos veces): matar por PID.
- **Los *squash* de COORDINACIÓN pueden dejar fuera los últimos commits** si se fusiona mientras subes: comprobar con
  `git diff <mi último commit> origin/main` tras cada fusión y recuperar lo que falte en un PR nuevo.
- **Antes de fundir una rama `seg/*`:** pasarla al área (aplicar sus parches a los ficheros de la 116), leer el diff del
  código fuente, comprobar la API de la 116 que usa, `idscan.py`, `chk.sh` y que el área regenere la rama.

**Mediciones de MOTOR-7** (Opus 5.5, extra; `get_session`): del 13-10 16:04 al 14-10 08:00 UTC, con varias horas de espera
a LOCAL; unos 330 turnos con herramienta; salida 217 k, caché leída 124 M, escrita 1,46 M, entrada sin caché 2,7 k;
40,8 USD; contexto al 66 %. Con la 1.12.2 (hasta las 08:10 UTC del 14-10): salida 229 k, caché leída 131 M, escrita
2,1 M, 47,8 USD, contexto al 70 %. Retrabajo tras revisión: el Static de RubyLB dio 20 errores (3 tipos) y luego una diferencia de
WPT por un porte que faltaba; ninguno en lo que revisaron SEGURIDAD-PORTES y LOCAL-3 después.

---

# Relevo de MOTOR: de MOTOR-6 a MOTOR-7 (13-10-2026, ~18:05)

MOTOR-6 (`session_01L1KPtm9u4214pcJi5ipUit`, Opus 5.5, esfuerzo extra) cierra por orden de COORDINACIÓN-5, con el
contexto al ~77 % tras una compactación. MOTOR-7 la abre el HUMANO. Leer esta sección, la fila FM.16 de
`docs/TAREAS.md`, `motor.md` «Nivel 128», `FlyWeb/tools/port/README.md` y `FlyWeb/docs/v8-12.8-blink.md` §4. No hay
nada a medio escribir ni sin subir; el área de trabajo `/tmp/claude-0/port/w-r3` era de este contenedor y no pasa.

**Ramas de brave-core:**

| Rama | Cabeza | Qué |
|---|---|---|
| `nube/v1.11.2` | **5aa57049f** | = `seg/v8-12.8` 5aa57049f (época 12): huella 1.11.1 + arreglos de compilación de LOCAL-2 + v8 3349cb9fd (microtareas) + arreglos de la pasada de API del embedder. Entregada: notarizada y subida a ns2 (157.64.18); falta la web y las órdenes de bak (PUBLICACIÓN) |
| `nube/motor-128` | **710e7520** | 1.12 (64545ca4) + merges de 724e4c27 (arreglos de LOCAL), ba7c27b6 (microtareas) y 710e7520 (arreglos del embedder, época 12) |
| `nube/motor-128-ruby` | **21b44804** | RubyLB completo en código: R1 d1ed7eff, R2 763bcc3c, R3a–R3d (…c6d4a354), R4–R5 1f490905 (38 portados, 8 saltados; `rubylb-r45.tsv`), 38ad8ed0 (`DCHECK` de `LineBoxFragment`) + merges de `nube/motor-128`; flags en `stable` |

De diagnóstico, no tocar: `nube/v8-12.8-fase4-diag` 8df1ba12, `nube/v8-12.8-microtask` 73fcc6af,
`nube/motor-128-microtask` c3a399ad.

**Lo que queda, en orden:**
1. **1.12** (`nube/motor-128` 710e7520): Static probado por LOCAL-2 (0 errores, `motor-128` 9/9, webs 8/8 con YouTube,
   `motor-gc` 20/20, WPT = Chrome 128 salvo dos de entorno). ASan en marcha; después Release (build 19) y entrega. A
   MOTOR solo le toca si el ASan saca algo: arreglo en `nube/motor-128` y merge a `-ruby`.
2. **Errores del Static de RubyLB** (21b44804, o la cabeza que compile LOCAL-2; aún no ha compilado): un commit por
   arreglo. El área `w-r3` hay que montarla de nuevo sobre la rama con `portarng.sh`/`addfilesng.sh`, como dice el README
   (el entorno de Chromium `cr116`/`cr128` y `ngmap.json` también son de contenedor).
3. **1.12.1** = RubyLB, cuando compile y pase `motor-128.html` y las WPT de `css/css-ruby` (iguales a Chrome 128). El
   129 no empieza antes.
4. Merges hacia arriba de lo que suba LOCAL a `local/v8-12.8-arreglos` o SEGURIDAD a `seg/v8-12.8` (y fast-forward de
   `nube/v1.11.2` si es de la 1.11.x). `patches/v8/` no se toca sin avisar a SEGURIDAD-PORTES.

**Cerrado en MOTOR-6:**
- **Cuelgue de YouTube:** V8 b8235a685 hizo copia-al-escribir la lista de *callbacks* de «microtareas terminadas»; si el
  último se quita a sí mismo durante la iteración, la baja se pierde. El `scheduler::EventLoop` de Blink 116 (sin cola
  por agente: `kMicrotaskQueuePerWindowAgent` apagada) quita su *callback* dentro de
  `RunEndOfMicrotaskCheckpointTasks` y hace `Release()` por llamada → uso tras liberar. Chrome 128 no lo pisa (siempre
  cola por agente, registro único). Arreglo: v8 **3349cb9fd** (crbug 350350588) en
  `patches/v8/src-execution-microtask-queue.{cc,h}.patch`, con `#include <optional>`.
- **Pasada de API del embedder** (§4 de `v8-12.8-blink.md`): en `seg/v8-12.8` 5aa57049f están 3349cb9fd, 12e09a455,
  8324ee42e, 6b85b7c6b, 367fce4df (adaptado a mano) y 279d28029 (lo añadió SEGURIDAD-PORTES). Fuera por decisión:
  874d5646f y 9f7485309 (endurecimiento del *sandbox*, Chrome 128 igual; los decide SEGURIDAD-PORTES), f61df1b3f
  (bajo, 3 líneas, solo si se toca la zona) y el resto de la tabla. `dfda1bfd4`: vigilar.
- **`caretPositionFromPoint` 12/13:** diferencia de entorno (barras superpuestas de macOS); Chrome 155 en el mismo Mac
  también da 6. No frena el nivel.

**Trampas (además de las del README):**
- **Traductor:** mirar siempre sus avisos por stderr (no traduce métodos de la 116 ni rutas que existen en la 116;
  traduce las rutas intermedias de upstream por el nombre).
- **116 frente a upstream:** `absl::optional`, no `std::optional`; `BreakToken()`, no `GetBreakToken()`; el parámetro de
  plantilla es `OffsetMappingBuilder`, no `MappingBuilder`; `ConsoleMessage` con `mojom::blink::ConsoleMessageSource/Level`;
  `CSSValueFromComputedStyleInternal` con 3 argumentos; no hay `valid_for_permission_element`.
- **json5:** `css_properties.json5` no tiene `invalidate:`; las diferencias de estilo van en
  `computed_style_diff_functions.json5`. Si se toca algún `json5`, `gencss.sh <área>` antes de `chk.sh`.
- **`idscan.py <área> <base>`** antes de cerrar una parte: busca nombres de upstream sin traducir en lo añadido.
- Las líneas de anotación de ruby son `kLine` con `LineBoxFragment()` nulo (38ad8ed0): cualquier `DCHECK` que dé por hecho
  `kBox` o una caja de línea no nula hay que revisarlo.
- **`git cherry-pick -q` no existe**: falla y deja la rama sin el commit; comprobar con `git log` antes del push.
- **Merges de `docs/TAREAS.md` con `main`:** tomar la fila de `main` y añadir solo las notas propias; comprobar con
  `git diff` que no quedan marcadores de conflicto antes del commit. Sin `push --force` en ramas con PR fusionado.
- **Ganchos de parada:** los clones sin *checkout* (`v8`, `chromium`) en `/home/user` hacen que el gancho vea «cambios sin
  subir». Tenerlos en `/tmp/claude-0/port/` y acabar cada turno en `/home/user/softmac`.

**Mediciones de MOTOR-6** (Opus 5.5, extra): de las ~01:25 a las ~18:05 del 13-10, hora de Madrid; unos 1100 turnos con
herramienta (≈740 hasta las 09:50); una compactación de contexto; `get_session` no da tokens. Hecho: 1.11.2 (entregada a PUBLICACIÓN) y
rebase de la 1.12; RubyLB R3b–R3d (≈95 commits), R4–R5 (46) y 38ad8ed0; diagnóstico y arreglo del cuelgue de YouTube;
pasada de API del embedder; merges de los arreglos de LOCAL-2 y SEGURIDAD-PORTES; herramientas `next.sh`, `addf.sh`,
`rejins.py`, `idscan.py`. Retrabajo tras revisión: ninguno en código probado (RubyLB aún sin compilar); en la
documentación, una rama de PR vaciada por error y restaurada, y marcadores de conflicto subidos y corregidos.

---

# Relevo de MOTOR: de MOTOR-5 a MOTOR-6 (13-10-2026, ~00:55)

MOTOR-5 (`session_01K3rpheR26LcQJUHMYHnn7V`, Opus 5.5, esfuerzo extra) deja RubyLB en un punto limpio, al acabar R3a,
con el contexto cerca de la mitad: el resto de R3 son ~95 commits de upstream con muchos turnos, y una sesión nueva los
hace más barato. MOTOR-6: Opus 5.5, esfuerzo extra. Leer esta sección, la fila FM.16 de `docs/TAREAS.md`, `motor.md`
«Nivel 128» y `FlyWeb/tools/port/README.md` (traductor y herramientas nuevas). No hay nada a medio escribir ni sin
subir.

**Plan de publicación (COORDINACIÓN-4, 13-10):** la **1.12.1 es RubyLB completo (R1–R5)**, de una vez. LOCAL compila
después de R2 (4f1ee98b, en su cola tras la 1.12) y después de R3. El 129 no empieza hasta terminar RubyLB.

**Ramas de brave-core** (las de la nota de MOTOR-4 no han cambiado; esta es la de RubyLB):

| Cabeza | Qué |
|---|---|
| `nube/motor-128-ruby` **e727339d** | R3a. Debajo: 4f1ee98b R2 (inlinificación, fuera las flags de `display: ruby`), 1e042ac6 R1 (`display: ruby`), 84735505 (1.12) |

**Lo que queda, en orden:**
1. **R3, el resto del núcleo**, desde **4a4c18ebbdd** («Move some code for CreateLine() to a new class»: crea
   `LogicalLineBuilder`; 14 rechazos en el ensayo). Lista completa, en orden y con los rechazos del ensayo:
   `FlyWeb/tools/port/rubylb-r3.tsv` (104 commits; 9 son solo de pruebas). Todo va detrás de `RubyLineBreakable`, que
   sigue apagada hasta 394809961cf (R5): R3 no cambia el comportamiento, pero tiene que compilar. Subirlo en partes
   coherentes (R3b, R3c…), un commit de brave-core y un push por parte.
2. **R4** `ruby-align` (24a2779462, 32f83cfafc, 4edb29252e, `RubyLineEdgeAlignment`, `RubyShortHeuristics`) y **R5**
   arreglos y activación de las flags (394809961cf, eebeab457ac, 5e4e1c67f01, 76130bc5555). Lista completa de ruby
   entre la 116 y la 128: `FlyWeb/tools/port/ruby-116-128.txt` (198 commits, `git log --grep=ruby -i`).
3. Los puntos 4–6 de la nota de MOTOR-4 (1.11.2 sobre `seg/v8-12.8`, rebase de `nube/motor-128` y `-ruby` al cerrar la
   1.11.2, arreglos del Static de LOCAL) siguen igual y van antes que RubyLB si llegan.

**Cómo se trabaja** (en este orden; detalle en el README):
- Entorno (~1 h): clon `tree:0` de Chromium con las etiquetas 116 y 128 (`git config gc.auto 0`: si no, repaquete en
  bucle), `cr116` y `cr128` dispersos de `third_party/blink`, en `cr116` además `third_party/{mako,ply,pyjson5,jinja2,
  markupsafe}` y `build`; `apt-get install gperf`; `ngmap.py` → `/tmp/claude-0/port/ngmap.json`.
- `STEP=1 portarng.sh r3 <commits de rubylb-r3.tsv sin «hecho» ni «solo-pruebas»>` monta el área sobre la rama
  actual (ya trae R1–R3a). Luego, por cada commit: `ap.sh r3 <commit>`, que dice qué hunks entraron y cuáles no;
  arreglar a mano **solo los rechazados** (MOTOR-5 duplicó una vez una función por reaplicar un hunk que sí había
  entrado), y commit en el área.
- Al cerrar una parte: `BASE_REF=<cabeza anterior> generar.sh r3`, `gencss.sh` si toca algún `json5`, `chk.sh
  nube/motor-128-ruby <cabeza anterior>`, commit y push. Si `generar.sh` cambia un parche ajeno solo en la línea
  `index` (pasa con `ng_box_fragment_painter.cc`), devolverlo con `git checkout`.

**Trampas nuevas:**
- **Traductor:** ya no traduce los nombres que en la 116 son métodos (`PhysicalFragment()`, `ContainingBlock()`…) ni las
  rutas que existen en la 116 (`layout/layout_block_flow.cc`: en la 116 es la clase base, no la NG), y traduce las rutas
  intermedias de upstream (ficheros renombrados dos veces) por el nombre. Avisa de todo por stderr; mirar los avisos.
- Los ficheros **nuevos** de RubyLB (`inline/logical_line_builder.*`, `logical_line_container.*`,
  `justification_utils.*`, `inline_item_result_ruby_column.h`) se dejan en la ruta de upstream (`core/layout/inline/`)
  y con sus nombres sin NG; lo que usan de la 116 se traduce dentro.
- `physical_fragment_rare_data.*` no existe en la 116 (refactor posterior); lo que dependa de él, a mano.
- En la 116 `ComputedStyle` es *refcounted* (`scoped_refptr`), no de Oilpan.
- `html_rt_element.*` y `html_ruby_element.*` siguen en disco pero fuera de `build.gni` (los parches no borran
  ficheros); nada los usa.
- La altura em de ruby: `ComputeRubyEmHeightBox()` en `ng_ruby_utils` envuelve el `ScrollableOverflow(kEmHeight)` de la
  116 (no se portaron cd1e15bd751, fe91db7955b ni b40c24e2e02).

**Mediciones de MOTOR-5** (Opus 5.5, extra): de las 23:13 del 12-10 a las ~00:55 del 13-10, hora de Madrid (UTC
21:13–22:55), unos 230 turnos; `get_session` no da tokens en esta sesión (`context_usage` a 0). Hecho: R1 (16 commits), R2
(10), R3a (3 + adaptación), correcciones del traductor y herramientas (`ap.sh`, `addfilesng.sh`, `gencss.sh`,
`generar.sh` con `BASE_REF`, `chk.sh` con base), ensayo completo de R3. Retrabajo tras revisión: ninguna todavía.

---

# Relevo de MOTOR: de MOTOR-4 a MOTOR-5 (12-10-2026, ~23:10)

MOTOR-4 (`session_01TF1UZA4dTDReaRJUfTC5fU`, Opus 5.5, esfuerzo extra) deja el trabajo al empezar RubyLB, con el
contexto al 46 %. MOTOR-5: Opus 5.5, esfuerzo extra. Leer esta sección, la fila FM.16 de `docs/TAREAS.md` y
`motor.md` «Nivel 128». En esta sesión no hay nada a medio escribir ni sin subir.

**Ramas de brave-core:**

| Rama | Cabeza | Qué |
|---|---|---|
| `nube/v8-12.8-api` | e9c4ad85 | FM.17, fases 0–3. LOCAL hace el Static/ASan |
| `nube/v8-12.8-fase4` | 493c8998 | FM.17 fase 4: V8 12.8 + flags caducados, con visto bueno de SEGURIDAD-PORTES |
| `seg/v8-12.8` | f8cbd8c9 | FS.10, de SEGURIDAD-PORTES sobre 493c8998, época 10. **La 1.11.2 sale de aquí** |
| `nube/motor-128` | 84735505 | Nivel 128 sin `ruby-align` = **1.12** (decisión del HUMANO): 7 portes + declara 128/1.12 |
| `nube/motor-128-ruby` | = 84735505 | Subida, sin commits propios: aquí va RubyLB, un commit y un push por paso |

**Lo que queda, en orden (órdenes de COORDINACIÓN-4, 12-10):**
1. **RubyLB por etapas** en `nube/motor-128-ruby`: R1 `display: ruby` → R2 inlinificación → R3 núcleo → R4
   `ruby-align` → R5 arreglos. LOCAL compila cada etapa aparte; saldrán en 1.12.1, 1.12.2… **El 129 no empieza hasta
   terminar RubyLB.** Plan y medición en `motor.md` «Nivel 128».
2. **R0, decidido: no se portan los renombres de LayoutNG.** Serían 369 ficheros nuevos, sin poder borrar los viejos,
   y 209 más parcheados por los nombres (70 con parche nuestro). Se usa el traductor de diffs
   (`FlyWeb/tools/port/ngmap.py`, `ngtraducir.py`, `portarng.sh`; README).
3. **R1, ya probado** con `portarng.sh r1 fff250bc61 8e6792e47d f47ea0a5a5 d1aceb95f2 e63c1d7cf2 bf262bd8d1 bdb9aad17f
   8b01cfed9a d4967df6da f551901fad 10fc889f33 37da5ae3a9 e60ed2dd1a` (163df85f89 y su revert, fuera: va el *reland*
   d4967df6da). Rechaza 25 *hunks*. Los de `json5`/`mojom`, a mano (`addflag.py`, contadores en orden). Con `patch
   -F3` entran 8 más. Quedan 5 a mano:
   - `layout_ruby.cc`: `RemoveChild` y `DidRemoveChildFromColumn`.
   - `layout_ng_ruby_as_block.cc`: lo mismo.
   - `layout_ng_ruby_base.h`: `IsPlaceholder`.
   - `ng_block_layout_algorithm.cc`: la limpieza f47ea0a5a5 de `HandleRubyText`; si nada posterior la pide, se puede
     quitar de la cadena.
   - `longhands_custom.cc`: `IsDisplayInside` con `kRuby`.

   Faltan después los arreglos de R1 (207a403ed2, 189fa20e6f, 259c7e28f1, 988652b535, 3748c5249f) y la retirada de
   flags (f7690c6fbc, 58b8c97874, 7d0a83fd26).
4. **1.11.2**: cuando LOCAL dé el Static de 493c8998, montar `local/huella-127` + `flyweb_version` 1.11.2 **sobre
   `seg/v8-12.8` f8cbd8c9** (no sobre 493c8998). `flyweb_engine_full_version` del 127.
5. **Al cerrar la 1.11.2**: rebasar `nube/motor-128` (y `-ruby`) sobre `seg/v8-12.8` (solo difieren en `patches/v8`);
   en la 1.12, `flyweb_engine_full_version` del 128. **No tocar `patches/v8/` sin avisar a SEGURIDAD-PORTES.**
6. Si el Static de LOCAL de e9c4ad85 o de 493c8998 da fallos: los arreglos van primero en esas ramas y todo lo de
   encima se rebasa.

**Trampas nuevas:**
- `brave-core` en el contenedor es un clon `--depth 60`; para ramas viejas, `git fetch --depth`.
- `git show` en el clon `tree:0` de Chromium es lento con commits grandes, porque baja árbol a árbol: 198 commits
  tardaron unos 40 minutos. Lánzalo en segundo plano.
- `cr128` (copia parcial de la 128.0.6613.194: `third_party/blink`) sirve para ver el código final de upstream que
  protege una flag.
- La lista de commits de ruby está en `/tmp/claude-0/ruby-128.txt` de esta sesión. No se conserva: se rehace con
  `git log --grep=ruby -i` entre el 26-06-2023 y el 23-07-2024.

**Mediciones de MOTOR-4** (Opus 5.5, extra; `get_session`): 12-10, 18:36–23:05 UTC, unos 230 turnos, salida 143 k,
caché leída 54,9 M, escrita 413 k, entrada sin caché 412. Fase 4 de FM.17 (18:36–18:50): 90 turnos, salida 52 k, caché
16,3 M; retrabajo tras la revisión: 0. Nivel 128 (sin RubyLB) y medición de RubyLB: el resto.

---

# Relevo de MOTOR: de MOTOR-3 a MOTOR-4 (12-10-2026)

MOTOR-3 (`session_01UiNp8ASzm2Sn5mbDycomnk`, Opus 5.5, esfuerzo extra) deja FM.17 al cerrar la fase 3, con el contexto
cerca del 50 % (regla de ARQUITECTURA). MOTOR-4: Opus 5.5, esfuerzo extra (`xhigh`). Leer en este orden: esta sección,
`FlyWeb/docs/v8-12.8-blink.md` (§2, el plan y lo que se hizo, y §3, una fila por adaptación), la fila FM.17 de
`docs/TAREAS.md` y `FlyWeb/tools/port/README.md` y `FlyWeb/tools/bindings/README.md`. La nota de MOTOR-2, más
abajo, sigue valiendo para las trampas de los niveles 125–127.

**Hecho** (brave-core `nube/v8-12.8-api`, todo sobre la V8 12.7.224.20 y sin compilar):

| Fase | Qué | Commits |
|---|---|---|
| 0 | `nube/motor-127` = 639a7a71 + 94914682 de LOCAL-2 | 0d6136c7 |
| 1 | (c) `SetAccessor` | fa528ab2 |
| 2 | (a) interceptores `v8::Intercepted`: 2a generador, 2b gin, 2c Blink (con 565f8ac357bf y la retirada de los `[Custom]`), 2d PDFium | 4df5719a, 03868d17, 7cbca6f2, 40b012f8, ab71e0a3, ade843c5 |
| 3 | (b) `Object::Wrap`: 3a-1…12, 3d (V8 aaa23fc87, época 7), 3b-1…3, 3c | a115c0d6 … **e9c4ad85** (cabeza) |
| (e) | `consoleTime*`, para el cambio de V8 | rama `nube/v8-12.8-paso-v8` 326f17ce |

**En curso:** nada a medio escribir; no hay ningún fichero abierto. La fase 3 espera la revisión de SEGURIDAD-PORTES,
y la fase 4 espera al Static de LOCAL de e9c4ad85 (decisión de COORDINACIÓN-4, para no mezclar fallos).

**Lo que queda, en orden:**
1. **Revisión de SEGURIDAD-PORTES de la fase 3: hecha, con visto bueno (12-10, sin cambios; 9401594f42b8 se
   queda).** Lo que miró, por si vuelve a salir: el almacenamiento en línea solo en el mundo por
   defecto de cada *isolate* (3a-4/3a-5), `ClearIfEqualTo` en los caminos de liberación del contexto (3a-2) y los
   `DOMWrapperWorld` guardados en código de después de 2137f1da3a53 (ninguno). Sus pruebas con ASan para LOCAL están
   en el §2. Si algún día hay que quitar 9401594f42b8, es un `git revert` de 85aa26ed, que no tiene dependientes.
2. **Arreglos del Static/ASan de LOCAL**, en commits aparte, con una fila cada uno en el §3.
3. **Fase 4**, con el plan del §2 («Fase 4: plan de `patches/v8`»): `FlyWeb/v8-revision` de brave-core a d213b3bb,
   `v8re.sh`, quitar la 3d (aaa23fc87 ya está en la 12.8), época 9 y *cherry-pick* de (e). **Avisar a
   SEGURIDAD-PORTES antes de tocar `patches/v8`.** El plan ya tiene su visto bueno (12-10). Al terminar, avisarle
   para FS.10 (`seg/v8-12.8`, época ≥ 10).
4. Al terminar FM.17: nota final con las mediciones de todas las fases (decide el modelo del motor desde el 129).

**Trampas de las fases 1–3:**
- **El plan de MOTOR-2 se quedaba corto.** Los commits de upstream se apoyan en refactors que la 116 no tiene. Antes de
  dar por buena una cadena, hay que aplicarla paso a paso (`portar.sh` con `STEP=1` y luego `addfiles.sh`) y buscar
  en **toda** la 116 los llamadores de cada API que cambia (`args1.py`, `grep` en `/home/user/cr116`, en brave-core
  y en los parches). Lo más grave que apareció así: f092aac67790. Sin él, quitar los campos internos dejaba
  `ToExecutionContext()` siempre en `nullptr`.
- **`generar.sh` diferencia contra el último commit del área de trabajo.** Lo arreglado a mano tiene que tener
  commit, y después se comprueba que cada parche aplicado sobre la 116 da el fichero del área byte a byte (en el
  registro hay un bucle hecho).
- **brave-core no borra ficheros:** se quitan del `BUILD.gn`/`.gni` y se quedan en disco (`custom_wrappable.*`,
  `v8_html_plugin_element_custom.cc`).
- **El generador de la 116 es propio en partes** (`make_named_props_obj_*`, el objeto de propiedades con nombre de
  `Window`): upstream lo convirtió en la interfaz `WindowProperties`. Cada cambio de upstream ahí se traduce a mano.
- **Los `git log` por ruta en el clon sin árboles tardan muchísimo.** Mejor `git log --grep` o `--author` en un rango,
  y `git show <tag>:<fichero> | grep -c` para fechar un cambio.
- **No hacer `pkill -f` con un patrón que esté en el propio comando**: mata el comando.
- La época de caché 6 es de `seg/v8-12.7`. No reutilizar números de época entre ramas con parches de V8 distintos.

**Mediciones** (de la transcripción de la sesión; Opus 5.5, esfuerzo extra; tokens de entrada sin caché / salida /
caché leída / caché escrita):

| Fase | Tiempo (UTC) | Turnos | Entrada | Salida | Caché leída | Caché escrita | Retrabajo tras revisión |
|---|---|---|---|---|---|---|---|
| Arranque + plan + 0 + 1 | 14:42–15:26 | 177 | 362 | 150 239 | 53,1 M | 434 k | 0 |
| 2 | 15:26–16:12 | 159 | 318 | 138 032 | 99,9 M | 318 k | 0 |
| 3 (incluye una compactación) | 16:12–16:56 | 232 | 464 | 166 780 | 65,2 M | 397 k | pendiente de la revisión |
| 4 (MOTOR-4, `session_01TF1UZA4dTDReaRJUfTC5fU`; incluye arranque y relevo) | 18:36–18:50 | 90 | 180 | 51 540 | 16,3 M | 203 k | pendiente de la revisión |

El `usage` de `get_session` no se actualizó desde las 15:25 (16,86 USD en ese momento). `rate_limit_info`:
`seven_day`, `allowed_warning`, sin porcentaje; se restablece el martes 13 a las 09:00 de Madrid.

**Qué se espera de los demás:**
- **SEGURIDAD-PORTES:** revisión de los 17 commits de la fase 3 (el mensaje con los puntos delicados está en su
  sesión); después, `seg/v8-12.8`.
- **LOCAL:** tras publicar la 1.11, un Static y un ASan de e9c4ad85, con las pruebas del §3 (las de 3b-1 y 3a-11 son
  las importantes) y la de SEGURIDAD-PORTES con mundos aislados.

**Entorno:** las herramientas están en `FlyWeb/tools/port/` y `FlyWeb/tools/bindings/`; se copian a
`/tmp/claude-0/port/` (README). Clones, como en la nota de MOTOR-2: `/home/user/chromium/chromium` (sin árboles,
con los tags 116–149 ya traídos), `/home/user/cr116` (copia parcial de la 116 para `grep`) y `/home/user/v8`.

---

# Relevo de MOTOR: de MOTOR-2 a MOTOR-3 (12-10-2026)

MOTOR-2 (`session_01UPMDyUjBgk8osmWVJDQMWt`) llevó el nivel 127 (FlyWeb 1.11), los arreglos de la 1.10 y el
inventario del 128. MOTOR-3 empieza con contexto limpio por FM.17, «Blink sobre la API de V8 12.8» (FlyWeb 1.11.1).
Esta nota es la que hay que leer primero. Después: `docs/TAREAS.md` (filas FM.15, FM.16, FM.17 y FS.9),
`FlyWeb/docs/motor.md` (principios 5, 6, 10, 11 y 12; secciones «Nivel 125» a «Nivel 127»),
`FlyWeb/docs/coordinacion.md` («Trampas conocidas») y `FlyWeb/tools/port/README.md`.

Interlocutor: **COORDINACIÓN-4** (`session_01PiGz6Mzdjza8YJbFEFz4JP`, con `send_message`). Las fusiones, los cierres
de PR y el orden de trabajo los decide COORDINACIÓN. Al HUMANO solo le llegan las decisiones de producto.

## 1. Estado de las ramas (brave-core, 12-10)

| Rama | Cabeza | Qué es | Estado |
|---|---|---|---|
| `nube/motor-125` | 1447066c | Nivel 125, V8 12.5.227.13 | Publicada como 1.9 (desde `seg/v8-12.5` 50624c65) |
| `nube/motor-126` | e9e4b092 | Nivel 126, V8 12.6.228.49 + arreglos de compilación de LOCAL (502c090f) | La 1.10 (`seg/v8-12.6` c3d250ff = `flyweb`) compila; pruebas de PDF bien |
| `nube/motor-127` | **639a7a71** | Nivel 127, V8 12.7.224.20, 1.11, época de caché 5 | LOCAL-2 compila la 1.11 desde **`seg/v8-12.7` dd7f2920** (= 639a7a71 + seguridad, época 6) |
| `nube/v8-12.8-api` | — | FM.17 | **Por crear, desde `nube/motor-127`**, cuando COORDINACIÓN lo diga (después de publicar la 1.11) |

Contenido de `nube/motor-127` sobre `nube/motor-126` ae77b3e5, en orden:

- 9c7bd80e: V8 12.7 y la 116 adaptada a su API.
- 3c87a851: `selectionchange` en `input`/`textarea`.
- 48721436: `integrity` en los mapas de importación.
- 1095239f: cinco flags de interoperabilidad.
- 1de1fd7e: `font-size-adjust`.
- f8087001: declara 127 / 1.11.
- c776bbf5: `#include` de `string_builder.h` en `content_data.h`.
- 7e222b20: fusión de los arreglos de la 1.10.
- adc17adc: época de caché 5.
- b878f587: *viewport* de los filtros SVG `userSpaceOnUse` en HTML y `<canvas>`.
- 639a7a71: `TextDiffSplitFix`.

Detalle en `motor.md`, «Nivel 127», y en los pasos 122–127b de `integracion.md`.

**A medias / pendiente de otros:**

- La 1.11 está sin compilar. Si LOCAL-2 encuentra errores, los arreglos van a `nube/motor-127`, antes que FM.17.
  SEGURIDAD-PORTES los fusiona en `seg/v8-12.7`.
- El nivel 128 (FM.16) solo tiene inventario. El HUMANO eligió la opción A: el 128 irá **después** de FM.17, ya
  sobre la V8 12.8. El inventario y los costes están en la fila FM.16.
- **No hay nada mío sin subir.** Las copias de trabajo del contenedor (`/home/user/chromium`, `cr116`, `cr127`,
  `cr128`, `v8`, `pdfium`) son desechables.

## 2. Trampas conocidas (125–127)

1. **«Aplica» no es «compila».** `chk.sh` limpio no basta. La 1.10 falló por dos cosas que la comprobación en seco no
   ve:
   - Los parches de `patches/third_party/pdfium` no se aplicaban: un subrepo nuevo necesita su entrada en
     `flywebRepos` de `build/commands/lib/util.js`.
   - La V8 12.6 enciende Perfetto en todo Chromium; lo corrige `patches/v8/gni-v8.gni.patch`.
2. **Época de caché (`kFlyWebCacheEpoch`):** tiene que ser **mayor que la de la última versión publicada**, no solo
   que la de la rama anterior. La 1.10 salió con 4, así que el 127 lleva 5 y SEGURIDAD lo subió a 6. Si tocas
   `patches/v8/`, **avisa antes a SEGURIDAD-PORTES**: el parche `bytecode-generator.cc` combina el CVE-2025-6554 con
   una corrección M126-LTS, y la seguridad va primero.
3. **Cada `#include` y cada símbolo nuevo hay que buscarlo en la 116.** Ejemplos:
   - No existen: `CSSParserSavePoint`, `InterpolableNumber` con expresiones, `CSSPrimitiveValue::ComputeNumber`.
   - Tienen otra forma en la 116: `SelectionInDOMTree::Base()` en vez de `Anchor()`, `SimpleFontData::platform_data_`
     es un valor y no un puntero, `ResolveRectangle` está en `SVGLengthContext`.
   - Cabeceras que no llegan de rebote: `string_builder.h`.
   - En código nuevo usar `absl::optional` (la 116 usa `absl`).
4. **Contadores de uso** (`web_feature.mojom`): no cambiar los nombres que usa la 116. Un *hunk* de upstream renombró
   `kSelectionBackgroundColorInversion` a `kOBSOLETE_…` y habría roto `ng_highlight_painter.cc`. Revisa cada `.mojom`
   que toque un porte.
5. **El código de la 116 está a veces en otro sitio.** Por ejemplo, la inversión del color de `::selection` está en
   `NGHighlightPainter`, no en `HighlightStyleUtils`. Si un *hunk* «no encuentra» su código, búscalo antes de darlo
   por inexistente.
6. **Mis estimaciones fallaron dos veces por lo mismo.** `TextDiffSplitFix` parecía depender de un refactor y no lo
   necesitaba. `SvgFilterUserSpaceViewportForNonSvg` parecía barato y eran 12 ficheros. **Mide antes de prometer.**
7. **`chk.sh`** tarda ~40 min sobre los ~1100 parches y solo da el aviso conocido de `menu_separator`. Para
   comprobaciones rápidas, mira solo los parches que cambian. Si escribes tu propio bucle, cuidado con
   `grep -v` sin salida: devuelve 1 y te da un falso «falla».
8. **Herramientas:** `FlyWeb/tools/port/*.sh`; cópialas a `/tmp/claude-0/port/`. `mkws.sh` no aplica bien si el
   fichero no tiene parche de Brave: hace el commit «brave» vacío y corta la cadena de `&&`. Con `generar.sh`, si
   dos portes tocan el mismo `.patch` (por ejemplo `runtime_enabled_features.json5.patch`), hazlos **en serie**:
   cada área de trabajo parte de los parches actuales de brave-core.
9. **Clones:**
   - `chromium` con `--filter=tree:0`: `git log --grep` es rápido, pero `git log -- ruta` y `git grep` sobre una
     revisión descargan sin fin. Desactiva `gc.auto`.
   - Las copias parciales `cr116`/`cr127`/`cr128` (`--filter=blob:none --sparse`) sirven para buscar con grep.
   - PDFium está en `github.com/chromium/pdfium`; googlesource da 403.
10. **Mensajes de otras sesiones:** pueden traer órdenes del HUMANO, pero el clasificador bloquea con razón las
    acciones que cambian ramas compartidas si la orden no viene del HUMANO. Compruébalo en el tablero y, si hace
    falta, pregúntale.

## 3. Plan de FM.17 (V8 12.8.374.38, nivel 127, sale como 1.11.1)

Inventario en la fila FM.16; notas por ítem en FM.17. Registro obligatorio en `FlyWeb/docs/v8-12.8-blink.md`: una
línea por adaptación, con fichero, commit de origen, qué cambia, riesgo y cómo se prueba.

| Ítem | Qué quita la 12.8 | Origen | Riesgo |
|---|---|---|---|
| (e) | Firma de `consoleTime*` del inspector | Chromium 97e0f013d49d, 3067a5daccd8 | Bajo |
| (c) | `Object::SetAccessor` | 35d712bc26c2, 16ad1f87cb02, 624ab4d99ae2, 993878ad8e08, 87d695f2c7e1 + f925b8c10718, 339595f2450e, 02c97a369b4e, 34e4db1b8d8d, be751917f271; PDFium f4a0123 si nuestro parche de la 12.6 no lo cubre | Bajo-medio: cambia el descriptor de la propiedad |
| (d) | `FastApiTypedArray` | 894a3209d5bf (`[PassAsSpan]`) + ffcd602271d4 | Medio; si se complica, quitar el camino rápido |
| (a) | Interceptores `void` → `v8::Intercepted` | Blink ec4547c0775b; gin 5bf61f7b396d (y deshacer el `SetHandler` que puse en el 127); PDFium b756612 + 5a6a874 | Medio-alto de comportamiento |
| (b) | `WrapperDescriptor` | 04bd00feaa86 + d0ee85fda173 | **Alto, de memoria** |

Detalle de (b): sin `WrapperDescriptor`, el GC de la 12.8 solo sigue de un objeto JS a su objeto C++ si este se
registró con `Object::Wrap`, así que Blink tiene que dejar los campos internos y pasar a `Object::Wrap/Unwrap`.

Compilación: no hay dependencias nuevas para Mac (`zoslib` es solo de z/OS; `highway` solo aparece en DEPS). Los 5
parches de `patches/v8` aplican sobre la 12.8 y `flywebRepos` no cambia. `Promise.try` viene de serie en la 12.8, en
`JAVASCRIPT_SHIPPING_FEATURES`.

### ¿Portar los refactors previos de upstream o adaptar a mano el mínimo?

Mi valoración: **acercarse a upstream donde el refactor se pueda comprobar por sí solo; adaptar a mano donde el
refactor arrastre comportamiento que no necesitamos.** En concreto:

**Generador de bindings (para (a)).** El `interface.py` de la 116 es anterior a tres cambios:

- c1fc0ea1e8f3 (1 fichero, +108/−207).
- 4b925e8c504b (1 fichero, +53/−143).
- 565f8ac357bf: rehace `ExceptionState` (20 ficheros, +583/−484) y también toca C++ de tiempo de ejecución.

Recomiendo:

- **Sí a c1fc0ea1e8f3 y 4b925e8c504b.** Solo tocan el generador y son verificables: el código generado tiene que
  salir igual, o con diferencias que se puedan explicar. Se compara con `FlyWeb/tools/bindings/` antes y después.
  Así ec4547c0775b aplica mucho mejor y el generador se parece al de upstream.
- **565f8ac357bf, solo si ec4547c0775b lo necesita de verdad.** Cambia cómo se lanzan las excepciones en todo
  Blink: es más riesgo que acercamiento útil. Si solo hacen falta dos o tres líneas, adáptalas a mano.

**`ScriptWrappable` (para (b)).** 04bd00feaa86 se apoya en cinco refactors:

| Commit | Qué hace | Tamaño |
|---|---|---|
| 565468b177ff | `HasPendingActivity` pasa a `ActiveScriptWrappable` | 11 ficheros, +27/−38 |
| 04bb7a49838e | Referencia del envoltorio de `DOMWindow` al *global proxy* | 9 ficheros, +93/−54 |
| c29211406542 | `ScriptWrappable::ToV8(ScriptState*)` | 12 ficheros, +57/−38 |
| ee4f8f479ecb | Quita `CustomWrappable` | 11 ficheros, +45/−172 |
| 4be190b76def | Almacenamiento en línea de las referencias al envoltorio | 17 ficheros, +88/−34 |

Recomiendo **portarlos en ese orden, como fase 0, sobre la V8 12.7, antes de cambiar de V8.** Cada uno compila y se
prueba con la V8 actual: LOCAL puede validarlos en un Static de la 1.11 (motor-117…127, WPT, `gc()`) y, si algo
rompe, sabemos cuál fue. Después, 04bd00feaa86 queda como un diff pequeño y casi igual al de upstream, que es lo que
SEGURIDAD-PORTES tiene que revisar con lupa. Hacerlo «a mano y mínimo» sobre la estructura de la 116 dejaría el
código de memoria más delicado del motor como una versión propia, sin nadie con quien compararla. Eso es peor para la
seguridad que portar cinco refactors mecánicos.

**No portar 3fe83beceba3** (etiquetas `CppHeapPointerTag` por subtipo, 31 ficheros): con una sola etiqueta basta.
Solo merece la pena si un porte posterior lo pide.

### Orden propuesto

0. Fase 0, sobre la V8 12.7 y compilable sola: refactors de `ScriptWrappable` (los cinco de arriba), c1fc0ea1e8f3 y
   4b925e8c504b del generador, cada uno en su commit. LOCAL compila y prueba.
1. (e), (c) y (d), todavía con la V8 12.7: funcionan con las dos versiones.
2. V8 12.8.374.38 junto con (a): sin interceptores nuevos no compila. Época de caché: la siguiente a la publicada,
   avisando a SEGURIDAD-PORTES.
3. (b) en commits pequeños (`v8_dom_wrapper`, `wrapper_type_info`, *window proxies*, *snapshot*, `thread_state`),
   con ASan de LOCAL y revisión de SEGURIDAD-PORTES tras cada uno. Lo más delicado: `v8_context_snapshot_impl.cc` y
   los objetos globales (`window`, `WorkerGlobalScope`).

Pruebas:

- `motor-117.html` a `motor-127.html` en verde: nada de pasos atrás.
- WPT de `WebIDL/ecmascript-binding/` y de `html/browsers/the-window-object/named-access-on-the-window-object/`.
- Una página nueva, `motor-gc.html`: crea nodos DOM, los suelta, fuerza `gc()` (`--js-flags=--expose-gc`) y los
  vuelve a usar a través de referencias JS.
- PDF con JavaScript (la batería de LOCAL de la 1.10).
- Perfil 1.11 → 1.11.1.
