# FlyWeb 3.0.1: inventario de CVE posteriores a la 156.0.8078.90 (FS.42)

SEGURIDAD-PORTES-19, 07-11-2026. Es la primera tanda de seguridad sobre la 3.0.0. **COORDINACIÓN-34 aprobó T1 y T2 el 07-11; los parches están en [`../seguridad/3.0.1/`](../seguridad/3.0.1/README.md) y en brave-core `seg/3.0.1`.**

**Corrección (07-11, al montar la serie):** la rama 8078 tiene **34** merges `[M156]` después de la .90, no 31. El clon superficial ocultaba 76f1ad165f (PDF), 237003a061 (HWND, Windows), 346080b440 (SimpleCache), dcf08f668d (gainmap, CVE-2026-121213) y e051d26756 (ChromeOS). Los 34 entran limpios.

## 0. Base y fuentes

Base de la 3.0.0, comprobada con `git ls-remote` el 07-11:

| Pieza | Rama o revisión | Hash |
|---|---|---|
| brave-core | `nube/b2-porte-t11` | bf4262a094 |
| chromium | `flynk-b1d` (fork `lamosquita-net/chromium`) | 33a1745949; sobre la 156.0.8078.90 de serie (`chrome/VERSION`) |
| V8 y Skia | sin cambios nuestros | gitlink = DEPS: `d72e817d59`, `835d560ccd` |
| ANGLE | a66226b1d3 + 8 parches nuestros | `FlyWeb/docs/b1d/angle/` |
| Dawn | 8ce9806ee5 + 1 parche | — |

Fuentes:
- Chrome Releases (feed Atom), con las notas de la 157.0.8103.38/.39 (estable, 03-11), la Extended 156.0.8078.88 (03-11), la .79/.80, la .73/.74 y ChromeOS 156.0.8078.93.
- Las etiquetas de `chromium/chromium` 156.0.8078.90 → .96 y su `DEPS`.
- Los logs de las ramas de V8, Skia y ANGLE en los espejos de GitHub.
- Los logs de `main` de Chromium, V8, ANGLE y Dawn (desde 09-2026), para encontrar cada arreglo por su crbug.
- KEV, en el espejo `cisagov/kev-data` (2026.11.06).
- No se pudo entrar en NVD, cisa.gov, chromiumdash ni skia, dawn o pdfium.googlesource.

Qué es la .90:
- No tiene nota de escritorio. Entre .88 y .90 solo hay subidas de versión, PGO y un roll de Skia. **En la práctica, .90 = Extended 156.0.8078.88** (55 arreglos, 3 críticos).
- Los tags .91–.96 existen en la rama 8078, pero en escritorio no se ha publicado ninguno.

**KEV / «in the wild»: ninguno posterior a la .90.**
- Las entradas de Chromium en KEV desde el 01-09 son CVE-2026-85046, CVE-2026-87491 y CVE-2026-111497 (Brotli). Las tres son anteriores a la .90.
- El arreglo de Brotli (b418fa8) está en `third_party/brotli/dec/decode.c` desde la .47.

## 1. Método de clasificación

Cada arreglo se prueba contra el árbol que compilamos: `flynk-b1d` 33a1745949; para V8 y Skia, la punta de su rama 156; para ANGLE, la punta 156 **con nuestros 8 parches aplicados**.

| Clase | Qué significa |
|---|---|
| **A** (limpio) | `git apply --check` (o `cherry-pick`) sin tocar nada |
| **F** (fuzz) | Solo entra con `patch -F3`: offsets o contexto movido. Se revisa con `git diff` |
| **X** (conflicto) | Al menos un trozo falla: hay que portarlo a mano |
| **N** (no nos afecta) | Solo Windows, iOS, Android o ChromeOS; GL o Vulkan de ANGLE (usamos Metal); Dawn/WebGPU (apagado); Skia Graphite (fuera) |

Además se cruzó cada fichero tocado con `patches/` y `chromium_src/` de brave-core (bf4262a094):
- Los 7 `.patch` de Brave que coinciden con un arreglo **siguen aplicando** tras el arreglo: `navigation_request.cc`, `render_frame_host_impl.cc`, `extensions_menu_main_page_view.h`, `runtime_enabled_features.json5`, `proto_conversions.cc`, `download_item_impl.cc` y `html_canvas_element.cc`.
- Los parches de `patches/v8` (BUILD.gn, flags, version.cc) también aplican sobre la V8 nueva.
- Hay `chromium_src` encima de `navigation_request.cc`, `render_frame_host_impl.{cc,h}` y `chrome_password_manager_client.cc`. Al portar hay que comprobar que siguen compilando.

## 2. Grupo 1: lo que Google ya fusionó en la rama 8078 después de la .90 (.91–.96)

| Bloque | Arreglos | Resultado | Nota |
|---|---|---|---|
| Chromium `[M156]` | 31 | **31 A** (`cherry-pick -x` uno a uno sobre `flynk-b1d`) | 2 no nos afectan (MFVEA D3D11, Dictation de ChromeOS); se llevan igual |
| V8 `d72e817d59 → 6500240d22` | 14 `[M156]` | **A**: subir `v8_revision` | 1 solo arm64 (ff4fec6); 4 de Maglev, que en la 3.0.0 está a prueba (B6) |
| Skia `835d560ccd → ea1e651d7a` | 10 `[M156]` | **A**: subir `skia_revision` | 3 de Graphite (no nos afectan); 7 de Ganesh, Slug, AAA y SDF |
| ANGLE `a66226b1d3 → f10470c77e` | 3 `[M156]` | **A**: los 8 parches nuestros entran con `git am` | Los 3 son GL-IMG y Vulkan: N |
| Dawn `8ce9806ee5 → 8bc8ddaf28` | — | N | WebGPU apagado |
| ICU (e83e03576f) | 1 | A | — |

CVE que cubre este grupo:

| CVE | Severidad | Componente | Arreglo en la rama |
|---|---|---|---|
| CVE-2026-121233 | High | Type confusion en CacheStorage | e7e3e86be6 |
| CVE-2026-121213 | High | Recurso sin inicializar en Images | — |
| CVE-2026-121208 | High | OOB read en Media | 4cac0cedd8 |
| CVE-2026-121076 | High | UAF en WebXR | 63b2a52140 |
| CVE-2026-121095 | High | WebGL | c80d7b8960 y 264389d634 (Mali) |
| CVE-2026-79235 | High | WebGL, Mali | 50a2b3f14b; solo en la nota de ChromeOS |
| CVE-2026-121068 | High | Type confusion en V8 | 5efaafc |
| CVE-2026-121184 | Medium | — | — |

Además entran unos 20 merges que aún no tienen CVE publicado: libxslt UAF (2ad9b7f5a8), FSA y symlinks en macOS (2100d2a6c9), WebShare, SiteDataClearer, DataPipeDrainer, MSE y otros.

## 3. Grupo 2: solo corregidos en la 157 (sin merge a la 156)

Son 53 CVE Critical/High de la nota de la 157.0.8103.38/.39. Abajo, el arreglo localizado de cada uno, clasificado contra nuestro árbol.

### Críticos (6)

| CVE | Componente | crbug | Arreglo (main) | Clase |
|---|---|---|---|---|
| CVE-2026-121203 | UAF en Geometry | 571065824 | 70bfe66894 | **A** |
| CVE-2026-121035 | UAF en Prerender | 567216197 | 403a04e98d (7 ficheros; `.patch` y override de Brave en `render_frame_host_impl`) | **F** |
| CVE-2026-121126 | UAF en Core | 571284308 | 8fde5a8071 (`navigation_request.cc`, que también tiene `.patch` y override de Brave) | **X** |
| CVE-2026-121229 | Corrupción de memoria en ANGLE (Translator) | 562777838 | ANGLE cc779fd | **A** |
| CVE-2026-121246 | UAF en WebGL | 558870371 | ANGLE c553b33 (workaround del backend GL) | N |
| CVE-2026-121247 | Desbordamiento en Dawn | 569161611 | Dawn 9a3e82d (ARM, ImgTec y Qualcomm) | N |

### Altos (47)

| Clase | CVE → arreglo |
|---|---|
| **A** | 121107 y 121174 BackgroundFetch → ed790a1a8e + 4519f82a82 (el segundo, A después del primero) · 121098 GPU → 65c300b6ec · 121074 GPU → 23573991af · 121185 PiP → 7261550390 · 121083 Compositing → 109fd0a12b · 121181 Editing → ae56f8394a · 121044 Layout → bee3d49b29 · 121100 DOM → 82a730ca36 · 121114 TabStrip → a1132a5d1f · 121131 («Mobile»; el arreglo es el side panel de Extensions) → b122968d36 · 121117 Paint → 0a8c55898c + 4a06eebbc9 · 121036 CSS → 7c84d3eadb + 437df69f0b · 121052 GPU (HiC) → db4fe6fb90 · ANGLE Translator: 121197 → a1550b2, 121140 → afa978f, 121037 → 2cfdd61 · V8 121228 → b56fe9b · V8 121082 → 87fabc8 |
| **F** | 121140 → 776099dc87 (además de ANGLE) · 121118 SVG → e886fddb58 · 121188 PerformanceAPIs → 21c3fb6886 · 121123 Canvas (HiC) → 63d3b40075 · 121034 Views → 4c4bf6a5eb · V8 121082 → 7f9cb9e |
| **X** | 121188 → 0f12a22f12 (`animation_frame_timing_monitor`) · 121038 (HiC) → c8449108a0 · 121052 (HiC) → bf298c5fc5 · 121214 Passwords → 31e05381bd (override de Brave en `chrome_password_manager_client.cc`) · V8 121082 → 1aae39c (falla 1 trozo de 8, `parser-base.h:5711`) |
| **N** | 121051, 121090 y 121087 (iOS) · 121178 (Aura de Windows, 1775ec03a1) · 121173 y 121249 (ANGLE GL Mali/Adreno, Vulkan) · 121207 y 121089 (Dawn) |
| **Ya en el grupo 1** | 121233, 121095, 121213, 121208, 121076, 121068 |
| **Sin localizar** | 121166, 121113 y 121179 (PDFium: el espejo de GitHub no tiene el crbug en el mensaje y pdfium.googlesource está bloqueado) · 121047 y 121180 (ffmpeg: el arreglo es el uprev a0add0878d, de 853 commits) · 121080 (CrabbyAvif, roll 8943e633bb) · 121124 (XML: el único commit con el crbug es el CPEPrefix de libxml; falta el roll real) · 121112 (Permissions: solo coincide un commit de gardener) |

Notas:
- **HiC (html-in-canvas)**: `CanvasDrawElement` está en `experimental` con origin trial `HTMLInCanvas`. Solo está expuesto si una web trae token y las origin trials no están apagadas en FlyWeb. Antes de portar las X de HiC, comprobar si la OT está abierta. Si lo está, lo más barato es apagarla: regla 20 y propuesta para revisar.
- V8 2481396 (también con el crbug 568794851) solo añade DCHECK: en Release no hace nada y no hace falta.
- V8 a10d231 = 5efaafc del grupo 1.

## 4. Propuesta de tanda para la 3.0.1 (pendiente del sí)

Orden: los críticos primero. No hay KEV.

1. **T1, críticos y rama 8078** (casi todo A):
   - en `flynk-b1d`: `cherry-pick -x` de los 31 `[M156]` y DEPS/gitlink a V8 6500240d22, Skia ea1e651d7a, ANGLE f10470c77e (+ los 8 parches regenerados con `format-patch`) e ICU;
   - de main, los críticos 70bfe66894 (A), 403a04e98d (F) y 8fde5a8071 (X, a mano), más ANGLE cc779fd (A).
   - **Todo parche de V8 sube `kFlyWebCacheEpoch`.**
2. **T2, altos localizados**: las 16 A, 5 F y 4 X de Chromium de §3, más ANGLE a1550b2, afa978f y 2cfdd61, y V8 87fabc8, 7f9cb9e, 1aae39c (a mano) y b56fe9b. Las de HiC, después de decidir sobre la OT.
3. **T3, medir antes**: PDFium (×3), ffmpeg (×2: sacar del uprev solo los arreglos), CrabbyAvif, libxml y 121112. Pasan a la 3.0.2 si no se localizan en ~1 día.
4. Comprobación: mjsunit con D8-LINUX (V8 con 6 arreglos más los parches nuestros) y build de LOCAL en la 7,1 (regla de orden fijo). En la Ubuntu no se compila.

**Bloqueo de acceso**: los commits de Chromium van al fork `lamosquita-net/chromium`, que **no está en el alcance** de esta sesión. La excepción de la regla 16 solo cubre brave-core. Hace falta que COORDINACIÓN lo ordene (`add_repo` con push) o decidir otra vía: rama `seg/3.0.1` en el fork, o parches en `FlyWeb/docs/` para que los aplique LOCAL.

## 5. Medida mensual (directiva del 07-11): cuántos entran limpios

Unidad: un arreglo (commit) que nos afecta y que está localizado.

| Conjunto | A | F | X | Limpios |
|---|---|---|---|---|
| Grupo 1 (rama 8078; afectan: 29 Chromium + 13 V8 + 7 Skia) | 49 | 0 | 0 | **100 %** |
| Grupo 2 (solo en la 157: A = 17 Chromium + 4 ANGLE + 2 V8; F = 6 + 1 V8; X = 5 + 1 V8) | 23 | 7 | 6 | **64 %** (23/36); 83 % con fuzz |
| **Noviembre 2026, total** | 72 | 7 | 6 | **85 %** (72/85) |

**Corregido al portar:** en el grupo 1 son 34 Chromium (31 nos afectan), así que el total es **74/87 = 85 %**. En la práctica, 3 de las F entraron con `cherry-pick` de 3 vías sin tocar nada (403a04e98d, e886fddb58, 21c3fb6886). 0f12a22f12 entró limpio después de su requisito 7d7ffedf61. Se portaron a mano 8fde5a8071, 776099dc87, 4c4bf6a5eb y 31e05381bd. No se portaron: CVE-2026-121082 (V8, parser) y los 3 de HiC (feature apagada).

**Referencia**: en la 128, B0 daba una proporción mucho más baja (`b0-cve.md`). Con la 156, recién estrenada, no hay motivo para proponer un salto de base. Lo que hay que vigilar cada mes es el grupo 2: lo que Google no fusiona hacia la 156 y que se aleja cada mes.

Sin localizar: 9 CVE (§3). No cuentan en la proporción.

## 6. CVE-2026-121082 (V8, parser): riesgo y alternativa (07-11, a petición de COORDINACIÓN-34)

**Qué es.**
- High, type confusion en V8 (crbug 567222737, restringido). No está en KEV ni hay explotación «in the wild».
- En main no es un arreglo, sino una campaña de **20 commits del parser** (Toon Verwaest, 07-10 → 17-10):
  - validación de patrones y cabezas de arrow;
  - errores de modo estricto;
  - `for-in/of`;
  - marcas `maybe_assigned` (1aae39c).
- Google no ha llevado ninguno a la 15.6.
- No se sabe cuál de los 20 cierra el fallo: el bug es privado.

**Riesgo si no se porta.**
- El parser procesa todo el JS de cualquier web, así que el vector es remoto y no requiere interacción.
- Lo que conocemos del mecanismo apunta a una clasificación equivocada de variables o de ámbitos. Esa información se la pasa el parser al intérprete y a los JIT (por ejemplo, `maybe_assigned` permite tratar una variable como constante).
- El daño queda dentro del renderer con sandbox: para salir hace falta una segunda vulnerabilidad.
- Nivel: **alto pero no urgente**. Es el mismo nivel que los otros High de la tanda, sin explotación conocida.

**Apagado alternativo: no hay uno fiable.**
- El fallo está en el análisis del parser, que va antes de todos los niveles de ejecución.
- `--jitless` o apagar Maglev/TurboFan limitarían lo que un JIT puede suponer a partir de `maybe_assigned`. Pero no está demostrado que lo cierren (el intérprete también usa la información de ámbitos), y el coste de rendimiento choca con el objetivo de la 3.x.
- No hay ninguna feature de Blink ni de V8 que deje fuera esta parte del parser.

**Propuesta: portar la serie entera.**
- Con 48baedfda delante («Disallow conditional chaining after non-short-circuit expressions», el requisito de 1aae39c), los **21 commits entran limpios** sobre 15.6.75.50 + b56fe9b.
- Tamaño: src +194/−158 en 6 ficheros del parser, más 21 tests de mjsunit.
- Está en brave-core **`seg/3.0.1-parser` = bee89ad8a6** (ls-remote), encima de `seg/3.0.1`. Los `.patch` reproducen el árbol exacto.
- La época de caché se queda en 31: la sube esta misma versión.
- Condición: el mjsunit de MOTOR-30 tiene que salir en verde **con** la serie (`seg/3.0.1-parser`) y **sin** ella (`seg/3.0.1`). Si con la serie aparece una sola caída que no esté sin ella, la serie pasa a la 3.0.2.
- El riesgo de compatibilidad es bajo: los cambios afinan qué errores de sintaxis se dan y en qué orden, para alinearse con la especificación y con Chrome 157, que ya los publica.

