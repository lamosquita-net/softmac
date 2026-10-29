# Relevo de MOTOR: de MOTOR-32 a MOTOR-33 (29-10-2026, ~17:20)

MOTOR-32 (`session_01MwmK2iAjgU6zc9yAUN812d`, Opus 5.5, medio). Nivel 135 = 2.4.0 (FM.50), sin terminar. Hecho y
pendiente, con commits: `motor-niveles.md` § «Nivel 135» («Hecho por MOTOR-32» y «Lo que falta… con lo medido»);
faltas del cruce y su coste: `version-2.4.0.md`.

**Rama:** brave-core **`nube/motor-135` 56a99da5**, sin compilar (LOCAL-14 compila 9a54d02992 = 33a7efd54 + su arreglo,
que ya está aquí como 7df1ac0a94). Orden de prueba a LOCAL en `buzon/LOCAL/20261029-1720-MOTOR-32.md`.

**Para MOTOR-33, por orden:**
1. **Errores de LOCAL primero** (directiva del 28-10). Desde la nube no se le puede escribir a LOCAL
   (`elevated_session_untrusted_device`): responder por el buzón y por COORDINACIÓN.
2. Lo que decida COORDINACIÓN sobre el resto del Blink del 135 (propuesta en el informe de MOTOR-32): `shape()`,
   Observable, `interactivity`, select personalizable, FetchLater, anchor remembered offset y las 4 de red. Cada fila con
   su cadena de commits en `motor-niveles.md`.
3. `:visited` (6eaf6c4d) espera la revisión de SEGURIDAD-PORTES: si la rechaza, `git revert` de ese commit solo.
4. Al cerrar: declaración 135.0.7049.117 / 2.4.0 en `build/config.gni` (`FLYWEB_BUILD_NUMBER` 36), `motor-135.html`
   (con `getContext('webgl'/'webgl2')` y `ANGLE_multi_draw`), HSTS/CT, §8.2 de `macos11-niveles.md`, orden final a LOCAL.

**Entorno (herramientas nuevas en `FlyWeb/tools/port/README.md` § «Sin historia completa»):** `mkcr.sh` de cr128 y
cr135 (~1 min cada uno), historia ligera de Chromium (~3 min) y `portgd.sh`/`ap1gd.sh`/`ok1.sh` paso a paso;
`fin133.sh` con `SESION=<id>` genera y hace commit.

**Trampas:** el inventario dio por «flip» o «código ya en el 129–134» filas cuyo código no está en la 128 (ver
«Lo que falta»): mirar `fwf.sh` + `diff fw/X cr135/X` antes de estimar. El run de wpt.fyi incluye funciones
`experimental`. `pkill -f` mata el propio shell. El json5 del 135 tiene entradas con sangría rara (`CorrectStylesForLists`):
`addflag.py` sí las mete bien.

---

# Relevo de MOTOR: de MOTOR-31 a MOTOR-32 (29-10-2026, ~16:10)

MOTOR-31 (`session_01MwmK2jaooqMPoHmosCsL9S`, Opus 5.5, medio; relevo al 38 % de contexto, 24,3 $). Nivel 135 = 2.4.0
(FM.50). Estado y decisiones: `motor-niveles.md` § «Nivel 135»; cruce y coste: `version-2.4.0.md`.

**Rama:** brave-core **`nube/motor-135` 33a7efd54**, sobre 479bcaf1e2, sin compilar. Encima: port de WebGL (9db2c47e3), los
escapes del 134 (619397a95…5a8fe0bb8; falta `highlight-paired-cascade-004`, sin causa), **V8 13.5.212.10** (37c5e8a5e;
`FlyWeb/v8-revision`, los 103 `patches/v8` aplican sobre e2591684) y ALPS/QUIC (33a7efd54). `util.js` aplica ya parches
de `third_party/emoji-segmenter/src` y `net/third_party/quiche/src`.

**Para MOTOR-32, por orden:**
1. **Las 8 faltas del cruce wpt.fyi** (directiva «Las faltas, antes de compilar»; lista en `version-2.4.0.md`): mirar
   antes en la 128 + parches si alguna ya está; `:visited` (b39d6582c8e), a SEGURIDAD-PORTES antes de portarlo. Medir el
   coste del porte (`get_session` antes y después) y anotarlo en `version-2.4.0.md`.
2. **Blink del 135** (orden del informe Blink en `motor-niveles.md`): flips pequeños, `command`, `shape()`, Observable,
   correcciones, select personalizable, `interactivity`, FetchLater (+8a947848b8). El carousel (8–12 h, solo Chrome):
   proponer a COORDINACIÓN si va en una 2.4.x. **Ojo:** los flips no son solo json5: comparar el código detrás de cada
   flag entre la 128 + parches y la 135 (en `/tmp/claude-0/port/diffs/` estaban los de AOM, LogicalOverflow,
   SafeAreaMaxInset, sourceElement y popstate; no persisten).
3. Fuera de Blink: `AllowSameSiteNoneCookiesInSandbox`, `ServiceWorkerSrcdocSupport`,
   `ServiceWorkerClientUrlIsCreationUrl`, `UpdateRequestForCorsRedirect` (código en la 128 o no: comprobar); regenerar
   HSTS/CT; corregir §8.2 de `macos11-niveles.md` (`UTType` es del menú Servicios).
4. Declaración 135.0.7049.117 / 2.4.0 en `build/config.gni` (`FLYWEB_BUILD_NUMBER` 36), `FlyWeb/tools/motor-135.html`
   (incluir `getContext('webgl'/'webgl2')` con `ANGLE_multi_draw`), orden a LOCAL por `buzon/LOCAL/`, FM.50 y
   `send_message` a COORDINACIÓN-20.

**Trampas de esta sesión:** chromiumdash da 403 por el proxy (usar `versionhistory.googleapis.com`); Gitiles por HTTP
sirve diffs con sha completo (`/tmp/claude-0/port/gd.sh` resuelve el corto; ahora en `FlyWeb/tools/port/`);
`chk128.sh` no comprueba los parches de subrepos (emoji-segmenter, QUICHE): comprobarlos a mano; `git grep` sobre
clones sin blobs se cuelga (mató un comando de 2 min).

---

# Relevo de MOTOR: de MOTOR-30 a MOTOR-31 (29-10-2026, ~14:10)

MOTOR-30 (`session_01MwmK2hpaEHYmeX2A1rMrMS`, Opus 5.5, medio; ~17 % de contexto) sacó adelante la **2.3.0** de las dos
caídas del renderer. Se archiva al entregar. Detalle: `version-2.3.0.md`, `caida-230.md`, `wpt-230.md`.

**Estado:** la **2.3.0 entregada por LOCAL-14** (FM.49): brave-core **`nube/motor-134` 479bcaf1e2**, build 35, V8 13.4.114.21;
0 regresiones WPT frente a la 2.1.1. Encima de 858f858dc3:
- **fa6ccf3c76**: caída en el primer `getContext('webgl')`. V8 13.4 (c41f7a0e) hace CHECK en
  `FunctionTemplate::NewWithCFunctionOverloads` si dos sobrecargas rápidas tienen la misma aridad, y los IDL de WebGL de la
  128 ponen `[NoAllocDirectCall]` en pares `Float32Array`/`sequence<>`. Se quitó el atributo de los 30 grupos sobrecargados
  (el compilador de IDL lo exige en todas o en ninguna). LOCAL-14 llegó al mismo árbol (816c878506).
- **479bcaf1e2** (de LOCAL-14): SIGILL en Mojave en toda web con JS. El `SpinningMutex` de la 13.4 pide
  `OS_UNFAIR_LOCK_ADAPTIVE_SPIN` (10.15) a `os_unfair_lock_lock_with_options`; libplatform de 10.14 aborta con `ud2`.
  Antes de 10.15, `os_unfair_lock_lock`.

**Para el 135:**
- **Port de upstream de WebGL:** `nube/motor-134-webgl-up` **8eeb795e9e** = 89faaa39fb47 (M130: `[PassAsSpan]` en uniones
  `sequence<>`/array tipado + IDL con `Float32List`/`Int32List`/`Uint32List`; 10 parches). Recupera las llamadas rápidas de
  WebGL que quitó fa6ccf3c76. Está sobre fa6ccf3c76: hay que **ponerlo sobre 479bcaf1e2** (solo toca IDL y bindings, no
  choca con el parche del mutex). Aplica limpio sobre la 128 y sobre nuestro `bind_gen/interface.py`. Sin compilar. Por
  norma de Titín, no hay 2.3.1: entra con el 135.
- **Escapes WPT del 134** (`wpt-230.md`, decisión de COORDINACIÓN-20: van al 135). Son 16 que fallan siempre;
  `highlight-cascade-010` está descartado (fue un tiempo agotado suelto). Grupos: `font-variant-emoji-*` y
  `variation-sequences` (emoji/VS), `calc()` fuera de rango en `font-weight` (4 pruebas), `@font-feature-values` en la
  serialización, highlight (`css-target-text-decoration-001`, `custom-highlight-painting-below-target-text`,
  `highlight-paired-cascade-004`), `inserthtml` con `<li>`, OffscreenCanvas (`desynchronized` en `getContextAttributes`,
  `direction` heredado al transferir). Del 133 siguen los de flexbox de 1 nivel de color (ANGLE OpenGL, ver TRAMPAS),
  `text-box-trim-*` y `open-pseudo`.
- **Informe de INVESTIGACIÓN-MOTOR-6:** llegará en `FlyWeb/docs/wpt-230-investigacion.md`, con los arreglos de Chrome que
  hay que portar para esos escapes. Leerlo antes del inventario del 135.
- **Maglev sigue apagado** hasta que LOCAL lo mida con la 2.3.0 (JetStream con y sin `--maglev` en la 5,1 y la 6,1).
- **Pendiente de LOCAL, por código limpio:** `d8` mjsunit en la 6,1 y la 5,1 (antes solo en la 7,1) y `atob`/`btoa` largos
  en la 5,1. El barrido de CPU de V8 13.3/13.4 está en `version-2.3.0.md`.
- Descartada y sin uso: `nube/motor-134-scopeinfo` 784d9670b9 (`reuse_scope_infos`; no era la causa).

**Trampas nuevas** (en `docs/TRAMPAS.md`, MOTOR): que `d8` pase no prueba Blink. En cada V8 nueva, diff de `src/api/api.cc`
buscando `CHECK`/`ApiCheck` nuevos y barrido de los IDL de la base; `getContext('webgl')` en la prueba de humo; `grep` de
`__attribute__((weak))`, `dlsym` y `__builtin_available` en `src/base` y `src/libplatform`; `d8` también en la 6,1. Sin
volcado no prueba que el navegador mate al renderer: lldb lo separa (`--renderer-cmd-prefix`).

**Método que funcionó:** V8 completa a la tag por `git fetch --depth 1` de `https://github.com/v8/v8` (googlesource está
bloqueado en la nube); historia de Chromium y V8 con `--filter=tree:0 --shallow-since=…` y `--grep` (nada de `git grep`
sobre árboles sin blobs: tarda minutos). Chromium 128 con sparse-checkout de `third_party/blink/renderer`
(`https://github.com/chromium/chromium`, tag 128.0.6613.138); los parches se generan con `git diff --full-index` sobre ese
árbol.

---

# Relevo de MOTOR: de MOTOR-29 a MOTOR-30 (28-10-2026, ~19:50)

MOTOR-29 (`session_01MwmK2iDD1sWx5FwbmTYa37`, Opus 5.5, medio; ~30 % de contexto) metió `attr()` en el 133 e hizo el
**nivel 134 = 2.3.0**. Se archiva al entregar (directiva de Titín del 28-10). Detalle: `version-2.2.0.md` (§ `attr()`) y
`version-2.3.0.md`.

**Estado de la 2.3.0 (decisión de Titín: se salta la 2.2.0, que no se compila ni publica):**
- Cabeza: brave-core **`nube/motor-134` 858f858dc3**, build 35 = 192ce3e811 (lo que LOCAL-14 compiló y enlazó, con FS.35
  fundida: `seg/fs35-maglev-dead` 0ce38fe7 y `seg/fs35-blink134` c56bbf9b) + 06ed9ecbb6 (`willReadFrequently` booleano,
  el único FALLO de `motor-134.html`). Pendiente: incremental con 858f858dc3 y el resto de pruebas de LOCAL (WPT del 133 y
  del 134, claude.ai, Speedometer, 6,1, 5,1 con simdutf). No reescribir: hay órdenes con esos sha.
- d8 13.4 (LOCAL-14): mjsunit 7584/7585 (`maglev/extras-cped`, la de siempre), `--maglev` 1257/1257.
- `nube/motor-133` se queda en 888963ca5 (2.2.0 + `attr()`) como historia.
- **Maglev apagado**: su deuda (FS.34 + FS.35) está dentro; se enciende solo con la medida de LOCAL en la 6,1 con esta
  build (en la 2.1.1, JetStream se colgaba 5/5 con `--maglev`). Es la línea `maglev` de `src-flags-flag-definitions.h.patch`.
- **6736b12fb2 no se porta** (canvas por software con NVIDIA en Mac; la 128 conserva la ruta antigua). COORDINACIÓN-19
  de acuerdo; probar el canvas en el MacBook Pro 2012 (GT 650M) cuando Titín pueda.

**Si LOCAL trae errores de la 2.3.0:** lo más probable, `html_dialog_element.cc` (17 commits de `closedby` + FS.35),
`pointer_event_manager.cc`, `offscreen_canvas_rendering_context_2d.cc`, simdutf en la 5,1, `v8/src/maglev/*`. Arreglar
encima de 858f858dc3, buzón a LOCAL y sha a COORDINACIÓN (la nube no puede escribir a la 7,1:
`elevated_session_untrusted_device`; no llamar a `confirm_repository_trust`).

**Del 135 no hay nada hecho:** ni inventario ni rama. Mismo método que el 134 (3 subagentes Sonnet: Blink, V8 13.5, fuera
de Blink), pero el informe «fuera de Blink» tiene que partir de que la base sigue en la 128 (el del 134 hablaba de rebasar
parches como si la base subiera). V8 13.5: mirar qué arreglos de la serie de Maglev ya trae (varios son merges a 13.5).

**Herramientas nuevas** (en `FlyWeb/tools/port/`, copiar a `/tmp/claude-0/port/`): `v8regen.sh <ruta> <contenido>`
(rehace un `patches/v8/*.patch` frente a `V8_TO`, por defecto 13.4.114.21), `v8chk.sh [rev]` (`git apply --check` de
todos los `patches/v8`), `fz.sh <área>` (reintenta los `.rej` con fuzz 3 y dice dónde caen). Arreglados: `seq.sh` para con
un fichero que no existe en el área; `generar128.sh` borra el parche de un fichero que vuelve a quedar como en la 128
(dejó 4 parches del taint viejo y la 1.ª Release falló); `chk128.sh` mira la historia en `/home/user/chromium/hist`.
Montaje: `mkcr.sh` de cr128/cr133 (~3 min), historia de Chromium (`fetch --filter=blob:none --shallow-since=2024-06-10` de
los tags) y de V8 (`/home/user/v8`, misma idea con 13.2.152.56, 13.3.415.23, 13.4.114.21).

**Trampas de esta sesión:**
- Una lista de commits heredada puede estar incompleta: antes de una cadena, `git log <primero>~1..<tag> -- <ficheros>`.
- Nunca regenerar desde un área montada antes de otro commit (reescribe ese commit; me pasó probando `generar128.sh`, sin
  llegar a commit).
- `git log -S` y `git grep` en historias sin blobs tardan minutos por consulta: `--grep` del mensaje o `git blame -L` en
  el json5 al tag van en segundos.
- Antes de entregar, barrer con grep las API de la 128 que usa lo portado (COORDINACIÓN lo pide así desde hoy).

---

# Relevo de MOTOR: de MOTOR-28 a MOTOR-29 (28-10-2026, ~10:25)

MOTOR-28 (`session_01MwmK2mPzyrf5do67riZaYB`, Opus 5.5, medio) cerró la **2.2.0** e hizo el inventario del 134. Detalle:
`version-2.2.0.md` y `motor-niveles.md` § «Nivel 134».

**2.2.0 (entregada, sin compilar):** brave-core `nube/motor-133` **2f268ee217** (orden `buzon/LOCAL/20261028-0953-MOTOR-28.md`
y su corrección de las 10:16, build 34). Sobre 426ed3c1: roots 153, c1ff7342 `ClipboardItem`, 8da9f5f3 `text-box-trim`,
merges FS.33 (77caf973 stack clash, 88732b96 Blink) y 2f268ee2 (tres flips del json5 que MOTOR-27 perdió entre commits).
Errores de LOCAL: arreglarlos encima (no reescribir: hay orden con ese sha).

**Siguiente, por orden de COORDINACIÓN-18 (regla 18): la 2.2.1 = `attr()` antes del 134.**
- Rama `nube/motor-133-attr` (sobre 88732b96, no compilable): 5ce740bb = 8 commits de `attr()` (8026a18f3f … 58743c5967);
  59d488dd = 1fc628b444, 0692e7d9b9 (`CSSSyntaxDefinition::Consume`, adaptado: `Parse()` sigue con `CSSTokenizedValue`) y
  8e710e2016 (`TokenSequence` sin `tokens_`; el `AppendFallback` con la marca de taint ya en su forma final).
  **Reponer encima 2f268ee2** (o fundir `nube/motor-133`) antes de seguir.
- **Ojo, cambio de diagnóstico:** la 128+bc **ya trae buena parte** de la migración del parser a streaming (bc tiene 135
  usos de `CSSParserTokenRange` en `css_parsing_utils.cc` frente a 199 en la 128; 9180018ac3 ya está), así que aplicar los
  ~65 commits de la migración entera choca consigo misma (`sp-estado.txt`: 3 ya, 23 aplican, 53 parciales). Vía elegida:
  **solo las dependencias que pide la cadena de `attr()`**. Siguiente paso: 5189858a61 (sintaxis registrada en streaming:
  `CSSSyntaxDefinition::Parse(StringView)` y `CSSVariableParser::ParseDeclarationValue(StringView)`; toca
  `property_registration.cc`, `inspector_style_sheet.cc`, `css_variable_parser.*`), luego 0c00afffe9 y el resto de
  `attr2.txt`: 96a736734d (33 rechazos en el ensayo, el más gordo), c8d50d1a89, 162e74449d, 1bf714b913, 3d832173db
  (flip), 8e507ecf45 (sin `type(<url>)`), 82d879b09e, 0c50bb37c1, ac008e348d. Si alguno pide más migración, portar solo
  esa función. `GetUltimateOriginatingElementOrSelf()` puede faltar en la 128.
- WPT: `css/css-values/attr-*`, `css/css-variables/`, `css/css-properties-values-api/`; `motor-133.html` deja de tener la
  diferencia de `attr()`.

**Después, el 134** (`motor-niveles.md` § «Nivel 134», orden propuesto allí). Lo gordo es Maglev: el subagente de V8 cuenta
40–50 arreglos de deuda (SEGURIDAD-PORTES contó 16–20 hasta la 14.8): cruzarlo con SEGURIDAD-PORTES-11 y COORDINACIÓN antes
de empezar. V8 13.4.114.21: otra vez los 11 solo-LTS (45d40ca20 ya viene) y ea2f03dfff; `simdutf` y `fast_float`.

**Herramientas** (copiar de `FlyWeb/tools/port/` a `/tmp/claude-0/port/`; nuevas: `ap1.sh`, `ok1.sh`, `seq.sh`,
`add128.sh`, `chk27.sh`). Montaje: `mkcr.sh` de cr128/cr133/cr134 (~3 min cada uno) y la historia en
`/home/user/chromium/hist` (`git init`, `fetch --filter=blob:none --shallow-since=2024-06-10` de los tags 128.0.6613.138,
132.0.6834.160, 133.0.6943.141, 134.0.6998.166; ~5 min). Áreas de trabajo: `STEP=1 portar128.sh <área> <commits>` y luego
`seq.sh <área> <lista>` (aplica en orden y para en el primer rechazo; se arregla y `ok1.sh <área> <commit>`).

**Trampas de esta sesión:**
- **Un porte que regenera un `.patch` desde un área montada antes de otro commit borra ese commit.** Le pasó a MOTOR-27 con
  el json5 (3 flips perdidos). Montar cada área justo antes de su commit y, al final, `chk27.sh <desde> <hasta> <cabeza>`.
- Un fichero que se añade a mano a un área: copiarlo de la 128 **y aplicarle su parche de bc** (`add128.sh`). Copiar solo
  la 128 borra lo de bc al regenerar (casi pierdo b94803ac92 en `inline_break_token.h`).
- `fin133.sh` sigue aunque queden `.rej` (generar128 sale con «QUEDAN .rej» y el commit queda vacío): mirarlo.
- `git grep`/`git log -S` en la historia sin blobs descargan mucho: acotar por ruta.

---

# Relevo de MOTOR: de MOTOR-27 a MOTOR-28 (28-10-2026, ~09:35)

MOTOR-27 (`session_01MwmK2iYNS9JSPLVcpxc8mM`, Opus 5.5, medio; ~25 %, 11,7 $) hizo el inventario del 133 (`motor-niveles.md`
§ «Nivel 133», decisiones de COORDINACIÓN-18 en la fila FM.49) y la primera parte del porte. Detalle: `version-2.2.0.md`.

**Cabeza: brave-core `nube/motor-133` 25367508** (15 commits sobre ef850e44, cabeza de la 2.1.1, + merge de `seg/fs33-roots153` 7416f3bd: constante del Root Store a 153.0.8010.0, decisión de Titín). **Pendiente de fundir:** el porte a la 13.3 de v8 ea2f03dfff (stack clash, crbug 574660146) cuando SEGURIDAD-PORTES-11 pase la rama. Titín: `Sec-Fetch-Storage-Access` apagada (definitivo; ya lo está en la red de la 128). Sin orden a LOCAL todavía:
se puede reescribir si hace falta, pero mejor encima. SEGURIDAD-PORTES-11 pone `seg/maglev-134` sobre a833b085 (V8).

**Lo que queda, en este orden** (decisiones de COORDINACIÓN-18): (1) `ClipboardItem` con `Promise<string>` (d72d71316f2,
586423e8031, 887df9720c3): la 128 no tiene `ThenCallable` ni `MemberScriptPromise`; el IDL `record<DOMString,
Promise<(DOMString or Blob)>>` sigue dando `ScriptPromiseUntyped` en la 128, así que es reescribir la conversión de cadena a
`Blob` en `clipboard_item.cc` (`getType`) y `clipboard_promise.cc`/`clipboard_writer` con `ScriptFunction::Callable`;
conservar el `#define WritePlainText` de Brave (`chromium_src/.../clipboard_promise.cc`). (2) `text-box-trim`: 30 commits
8cc53df3787 … 336cc860afc (lista y rechazos de un subagente en `/tmp`, perdidos: rehacer con `git log --grep="text-box"`
en el tramo 47a3549fac1..72dd0b377c0), último y en su commit; sin los de `line-clamp` (7f48814f67f 5c55151b220
adbca44169f) si sigue apagado. (3) `attr()` avanzado (27 commits, núcleo 9edcb63ea87), detrás; si pasa de ~1 día, a una
2.2.x antes del 134. (4) Escapes `flexbox-safe-overflow-position-002/005` si LOCAL los ve en rojo con la 2.1.1. (5)
`motor-133.html`, lista WPT, sección «Para la web», orden a LOCAL por `buzon` y FS.33 avisada.

**Herramientas nuevas** (en `/tmp/claude-0/port`, no persisten; copiar de aquí): `p133.sh <área> <msg> <commits>` =
`portar128.sh` + `fin133.sh` (`generar128.sh`, commit con el trailer, `chk128.sh`); `setflag.py <json5> <Flag> <status>`;
`rejchk.py <.rej>…` (por hunk, cuántas líneas `+` ya están en el destino: separa lo ya portado de lo que falta); `jdiff.sh`
(arreglado para leer la 128 de `cr128`). Los tres scripts están en `FlyWeb/tools/port/` desde este PR.

**Trampas de esta sesión:**
- El clasificador del modo auto denegó `add_repo` con push y luego cualquier orden en el clon de brave-core; Titín lo aprobó
  a mano. No buscar otro canal.
- `portar128.sh` deja fuera `testing/variations/` (fieldtrial): sus rechazos se ignoran.
- Varias flags del 133 ya estaban a medias por portes del 130–131 (`TogglePopoverOptions` de 8010721fc51 sin leer el
  diccionario): tomar la forma final del 133 de cada función en vez de aplicar la cadena commit a commit.
- `<select>` personalizable (`CustomizableSelect`, `StylableSelect`) no está en la 128: los hunks que lo tocan se saltan.
- Un `patch -F3` puede meter un hunk dentro de la firma de una función (`messages.cc` de V8): revisar siempre el fuzz.

---

# Relevo de MOTOR: de MOTOR-26 a MOTOR-27 (28-10-2026, ~08:15)

MOTOR-26 (`session_01MwmK2ifjhdhoUu5VEpAigY`, Opus 5.5, medio; ~32 %) hizo la **2.1.1 = FM.48 + FM.47** (build 33). Detalle,
pruebas y diagnóstico de Futura en `version-2.1.1.md`. COORDINACIÓN-18 la archiva al abrir MOTOR-27.

**Estado de la 2.1.1 (tuya hasta publicar):**
- Cabeza: brave-core **`nube/motor-211b` ef850e44d7** = `local/2.1.1-arreglos` 7078c241 (LOCAL-14: `.c_str()` en
  `root_store_tool.cc`, único error de la 1.ª Release) + b745a4473 (`align-content: safe` con wrap-reverse) + dd784af57
  (revierte el xattr del sandbox) + ef850e44d (FM.47: emparejado que no abandona la familia; Futura caía a Times).
  **Pendiente de recompilar** (orden `buzon/LOCAL/20261028-0811-MOTOR-26.md`, sustituye a la de las 08:05). No se reescribe.
- Si Futura sigue mal: el siguiente sospechoso es el camino por nombre PostScript de `MatchFontFamily` (cuando
  `BestStyleMatchForFamilyNS` da null) y `CanLoadInProcess` de `font_platform_data_mac.mm`; mirar con
  `CSS.getPlatformFontsForNode` qué cara sale.
- Lo único abierto: WPT `flexbox-safe-overflow-position-002/005`. Sobre 7078c241 daban 9/11 escapes en verde, 2877 frente
  a 2876 de CfT 132, sin regresiones. Si con b745a4473c siguen en rojo, COORDINACIÓN-18 dijo: se entrega así y van a la
  2.2.0 (no seguir buscando).
- FM.47: la Futura que fallaba eran maletas Type 1 con resource fork que el renderer no puede cargar (detalle en `version-2.1.1.md`).

**Para el inventario del 133 (sin empezar):**
- Método de MOTOR-25: 3 subagentes Sonnet en paralelo (Blink, V8 13.3, fuera de Blink), cada uno con la lista de commits
  del 133 de su área y la pregunta «qué es Baseline/función nueva, qué flag pasa a `stable`, qué necesita de macOS 10.15+».
  Ellos devuelven conclusiones; el porte y las decisiones, la sesión principal. Inventario de API sin guarda en
  `inventario-129-156.tsv` (INVESTIGACIÓN-MOTOR-5: nada nuevo de 10.15+ en 132–133). Traducciones a 10.14, en la capa de
  compatibilidad (`macos11-niveles.md` §9).
- Flags: comparar el json5 de la 132 con el de la 133 (script de una vez: nombre → `status`); mirar antes en el json5 parcheado
  de bc qué está ya portado (en la 2.1.1 casi todas las del 129–132 que cambiaban algo ya estaban). La referencia es CfT 133
  y el json5 de la Brave de ese nivel (Finch, DIRECTIVAS).
- Trampas nuevas de esta sesión:
  - Los refactors grandes de upstream (flex de septiembre de 2024, longitudes con `SizeType`, era calc-size) **no aplican sobre
    la 128** (22 rechazos en flex). Para un escape, portar la conducta con un cambio pequeño en el código de la 128 y
    buscar **salidas tempranas** de la 128 que la tapen (así se escapó 002/005).
  - Sin flag no se ve en el json5: buscar el commit por la prueba WPT (`git show --name-only` de los candidatos de
    `git log --grep` en `03c1799e6f9..<tag>`); un subagente lo encontró en ~80 s.
  - Un mensaje de commit puede citar mal el sha de upstream (843cac4f citaba 84926a40d7e por 2af3b8d997f): comprobarlo.
  - `chk128.sh` usa `CH=/home/user/chromium`; la historia está en `/home/user/chromium/hist` (googlesource cerrado: espejo de
    GitHub, `tree:0`). Montaje desde cero: `mkcr.sh` de cr128 y cr132 (~3 min) + historia (~5 min).
  - `version.h`/V8 13.3: la regla 18 pide la V8 del 133 en el mismo nivel; FS para sus parches (época nueva).

---

# Relevo de MOTOR: de MOTOR-25 a MOTOR-26 (27-10-2026, ~14:10)

MOTOR-25 (`session_01MwmK2jUhhNQpTHEbCSHDPC`, Opus 5.5, medio; archivada al 51 %) hizo b2, las fijadas en blanco y el
**nivel 132 = 2.1.0** (FM.45). LOCAL-13 lo compila con **build 32** (la 2.0.4 se canceló). Detalle: `version-2.1.0.md`.

**Cabeza: brave-core `nube/motor-132` 78eb79e8** (está en una orden a LOCAL: no se reescribe). Sobre `nube/motor25-p25`
fbe2394fed (2.0.3 + b2 503757bf + fijadas fbe2394f): escapes 7e78e663 (`shape-outside` 129), 33b2a351 (`dir=auto`), 780af58e
(`scrollIntoView`); d10597e6 V8 13.2 en Blink; 89245751, 95eb20ed, 3dcda630, 1ed75fc7, b041904e, 541200a5 (Blink pequeño);
250c23a8 declaración 132.0.6834.160 / 2.1.0; merge FS.27 54b1ae68; 9a8183b0 HSTS localhost; 1c219226 comentario de Maglev;
**fbe98109 `sideways`** (reaplicado sobre el revert b250775d); merges FS.27 ec4d3b86 (475cb03ab90) y FS.28 (`patches/v8`
13.2, 32 parches, época 19, d8 7336/7337).

**`sideways`, adaptados a mano** (la 128 difiere del upstream que esperaban): (1) 9c582c2aea, f9d07c3d30, 187b73019b en
`theme_painter_default.cc`/`theme_painter.cc`: la 128 voltea deslizadores y marcas al revés que el upstream posterior, así
que el volteo va por el final físico de línea (`InlineEnd()`) con el criterio de la 128 (derecha o abajo). (2) 0b24096ebe
en `LayoutBox::LocalCaretRect`: la rama lógica va antes del código físico de la 128, que conserva `extra_width_to_end_of_line`.
(3) f1461a466d: `SerializedAnchor` desde `ScrollAnchorData`, con `scroll_anchor_test.cc`.

**Dónde fallará la compilación, si falla:** `sideways` (35 commits sin compilar: funciones de Blink posteriores a la 128 que
aplicaron sin rechazo pero no existen; buscar el símbolo en `/tmp/claude-0/port/cr128` y en el commit que lo introduce;
último recurso, revertir ec4d3b86 y fbe98109); la serie de `shape-outside` (geometría de `writing_mode_converter`,
`physical_rect.h`, `layout_size.h`); `main_thread_scheduler_impl.cc` (`SetIsLoading`) y `thread_state.cc`; IDB y
`dom_selection.cc` (adaptados). `patches/v8` → SEGURIDAD-PORTES-9.

**Maglev:** se enciende **como tarde en el 134** (Titín, 27-10), con su deuda (~15 arreglos, SEGURIDAD-PORTES) portada y pruebas de rendimiento; la LTS 13.2 no trae esos arreglos.
**133:** el escáner de INVESTIGACIÓN-MOTOR-5 no ve API de 10.15+ sin guarda en 132–133 (`inventario-129-156.tsv`); no
perder las guardas de 13.0 en `vt_video_encode` ni la de 12 en `ca_renderer_layer_tree`. Inventario del 133 sin empezar:
mismo método (3 subagentes: Blink, V8 13.3, fuera de Blink). Traducciones nuevas a 10.14, en la capa de compatibilidad
(`macos11-niveles.md` §9, aprobada). Trampas: `chk128.sh`, un área por commit si tocan el json5, `git log -- ruta` no acaba.

---

# Relevo de MOTOR: de MOTOR-24 a MOTOR-25 (27-10-2026, ~11:10)

MOTOR-24 (`session_01MwmK2jHVmKFgQPPcT5aifq`, Opus 5.5; get_session no da el esfuerzo) hizo la **2.0.3 = -p24** (orden de
COORDINACIÓN-16): tandas 2 y 3 de FM.42, un commit por punto. Detalle y pruebas: `FlyWeb/docs/version-2.0.3.md`. Página de
prueba: `FlyWeb/tools/mojave-203.html`. Se queda quieta tras entregar; la archiva COORDINACIÓN-16.

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p24` (2.0.3, build 31) | 23f2d547d9 | **subida a brave-core** desde la nube (`nube/base-128-motor-p24`); también `p24.bundle` en la rama de softmac `nube/motor24-p24` (base -p23 17e7858669) |

**Lo que queda (tuyo):** resultados de LOCAL (`buzon/LOCAL/20261027-1110-MOTOR-24.md`): la prueba previa de b4 con la
2.0.2 (si no hace falta, LOCAL revierte 4e84e03b), errores de compilación (b2 es el de más riesgo: activa
`components/eye_dropper` en Mac) y las pruebas de `mojave-203.html` en la 6,1 y la 7,1. **c3 depende de FS.26**
(SEGURIDAD-PORTES-8): si sale «no apto», se revierte 23f2d547; si «apto con cambios», los cambios van encima. Y lo que quede
de la 2.0.2 (LOCAL-12) si llega tarde: va antes que la 2.0.3.

**Trampas nuevas:**
- **La nube sí puede subir ramas a brave-core** con `add_repo` en modo push: `git fetch --depth=2 origin <rama>` (~30 s) y
  `git push` de la rama nueva encima (pack fino, segundos). MOTOR-23 lo daba por imposible; el bundle queda de respaldo.
- Checkout parcial de la 128 y la 116 (`/home/user/cr128`, `cr116`) con `sparse-checkout add` para los ficheros que no
  entran en el patrón (`BUILD.gn`, `.cc` sueltos): `git sparse-checkout add '/ruta/fichero'`. Antes de editar un fichero que
  ya tiene parche de bc, aplicarlo (`patch -p1`) y luego `git diff --full-index HEAD -- <fichero>`; los nuevos, con
  `git add -N` para que salgan como `new file mode`.
- Para comprobar los parches antes de entregar: copiar cada fichero limpio de la 128 a un directorio aparte y
  `patch -p1 --dry-run` con el parche nuevo.

---

## De MOTOR-23 a MOTOR-24 (27-10-2026, ~10:45)

MOTOR-23 (`session_01MwmK2i3zsbvNZN1DxSpqcF`, Opus 5.5, alto) hizo la **2.0.2 = -p23** (orden de COORDINACIÓN-15): -p21 +
-p22 + arreglo de la mosca de la NTP (FM.43). Detalle: `FlyWeb/docs/version-2.0.2.md` (§6 la antigua 2.0.3, §7 la mosca).
Se archiva tras entregar; MOTOR-24 se abre con los resultados de LOCAL.

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p23` (2.0.2, build 30) | 17e7858669 | bundle `p23.bundle` en la rama de softmac `nube/motor23-p23` (base -p22 9b9fdbbd44; lo sube LOCAL) |

**Lo que queda (tuyo):** resultados de LOCAL (`buzon/LOCAL/20261027-1045-MOTOR-23.md`): errores de compilación (sin compilar
en la nube), la medida de GPU de la NTP en la 6,1 frente a la 1.15.2, **F5.3** (si la línea vuelve, se revierte solo
`mosca.tsx`), las pruebas de la -p21 y la -p22 y lo que diga Titín de las capturas (sobre todo «Reducir movimiento»: la -p23
deja la mosca quieta y la 1.15 volaba despacio). Después, la tanda 2 de `mojave-128.md` cuando la apruebe COORDINACIÓN.

**Trampas nuevas:**
- La NTP se prueba fuera del navegador en 2 min: `npm i typescript react react-dom styled-components esbuild` en el scratchpad,
  copiar los `.tsx` de `components/brave_new_tab_ui/components/default/flyweb/`, `esbuild --bundle` y Playwright con
  `Performance.getMetrics` de CDP (`RecalcStyleCount`, `TaskDuration`). Sirve para comparar el hilo principal, no la GPU.
- Una animación CSS de `opacity` sobre trazos de un SVG en línea no va al compositor y obliga a un cuadro del hilo principal
  cada vez. Hay que ponerla en un `div` propio.
- El brave-core de GitHub se baja rápido por sha: `git fetch --depth=1 origin <sha>` (~30 s), y encima los bundles.

---

## De MOTOR-22 a MOTOR-23 (27-10-2026, ~09:25)

MOTOR-22 (`session_01MwmK2hvsFG1TsFqJBFtG6Y`, Opus 5.5, alto) hizo la tanda 1 de FM.42 = **2.0.3**:
`FlyWeb/docs/version-2.0.3.md`. Se archiva tras entregar; MOTOR-23 se abre con los resultados de LOCAL.

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p22` (2.0.3) | 9b9fdbbd44 | bundle `p22.bundle` en la rama de softmac `nube/motor22-p22` (lo sube LOCAL) |

**Lo que queda (tuyo):** resultados de LOCAL (`buzon/LOCAL/20261027-0917-MOTOR-22.md`): errores de compilación (sin compilar
en la nube), pruebas de la 6,1 y la 7,1 y el `codesign` de entitlements (d11 lo decide PUBLICACIÓN). Después, la tanda 2 de
`mojave-128.md` cuando la apruebe COORDINACIÓN.

**Trampas nuevas:**
- Chromium compila con `-Wunreachable-code-aggressive` y `-Werror`: un `return` antes del código de upstream no compila
  (comprobado con el clang 18 del contenedor). Hay que dejar el resto en `#if 0` o cambiar un puntero o una condición.
- `git grep <rev>` o `git checkout` de un sparse **muy amplio** sobre un fetch `--filter=blob:none` baja los blobs uno a uno
  y tarda minutos: `sparse-checkout set` solo con los ficheros que hagan falta y `git show FETCH_HEAD:<fichero>`.
- `git ls-tree -r --name-only FETCH_HEAD <dir>` funciona sin bajar blobs: sirve para buscar ficheros.
- Parches en formato bc: aplicar los de bc encima de la 128, editar y hacer `git diff --full-index FETCH_HEAD -- <fichero>`.

---

## De MOTOR-21 a MOTOR-22 (27-10-2026, ~09:20)

MOTOR-21 (`session_01MwmK2iH7RJ3swPYaFxtZPn`, Opus 5.5, alto) hizo el inventario FM.42: `FlyWeb/docs/mojave-128.md`.
**Punto 0:** la línea 263 de `unexportable_key_mac.mm` no se alcanza en Mojave (parche LOCAL-8), así que no hay -p22.
**No se ha portado nada.** Se archiva tras entregar. MOTOR-22 se abre cuando COORDINACIÓN apruebe la tanda 1 de la 2.0.3.

**Lo que queda (tuyo):** la tanda 1 de `mojave-128.md` sobre la rama de la 2.0.2 que haya fusionado LOCAL. Esta sesión no
creó ninguna rama de brave-core. Antes de tocar d1–d4, mira lo que diga LOCAL de
`codesign -d --entitlements :- FlyWeb.app` (fila FM.41). Faltan el registro real de avisos `-Wunguarded-availability` de
la Release (LOCAL) y saber si la 5,1 es Nehalem o Westmere.

**Trampas nuevas:**
- **Checkout parcial de Chromium, rápido** (10 s): `git fetch --depth=1 --filter=blob:none origin refs/tags/<tag>` de
  github.com/chromium/chromium y luego
  `git sparse-checkout set --no-cone '*.mm' '*_mac.cc' '*_mac.h' '*_apple.cc' '*.gni' '!/third_party/'`. Ocupa ~160 MB
  y con él `grep -r` va bien. Encima se aplican los parches de bc cuyo fichero exista (59 de la -p21, sin fallos).
- `chromium.googlesource.com` (`+archive`) da 502 en el proxy y `codeload.github.com`, 403: no insistir.

---

## De MOTOR-20 a MOTOR-21 (27-10-2026, ~08:15)

MOTOR-20 (`session_01MwmK2iKW2oBsGeKiqze1kp`, Opus 5.5, alto) hizo la 2.0.2 (FM.41, PR #520). Se archiva tras entregar
(directiva: no se espera con una sesión abierta); MOTOR-21 se abre con los resultados de LOCAL.

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p21` (2.0.2) | 3cc4ce116c | bundle `p21.bundle` en la rama de softmac `nube/motor20-p21` (lo sube LOCAL) |

**Lo que queda (tuyo):** resultados de LOCAL (`buzon/LOCAL/20261027-0810-MOTOR-20.md`): errores de compilación de la -p21 (sin
compilar en la nube), las 5 pruebas de fijadas de `version-2.0.2.md` §1, capturas de versión para Titín, xHE-AAC y la lista
de avisos de 10.15. Pendiente de Titín: «FlyWeb» en la línea de versión de Información (cadena traducible) y la passkey «Brave»
(captura, de MOTOR-19).

**Trampas nuevas:** `git cherry-pick` no acepta `-q`. `browser_shutdown.h` está en `chrome/browser/lifetime/`. Con
`git fetch --depth=1` (blobs completos, ~260 MB) `git grep` va rápido; con `--filter=blob:none` no.

---

## De MOTOR-19 a MOTOR-20 (26-10-2026, ~18:25)

MOTOR-19 (`session_017Tq5AVGdzh2afxt2uAe97F`, Opus 5.5, alto) hizo la 2.0.1 (FM.40). **Se archiva sin relevo activo**
(directiva: no se espera con una sesión abierta); MOTOR-20 se abre cuando lleguen los resultados de LOCAL o la captura de Titín.
Todo en `FlyWeb/docs/version-2.0.1.md` (PR #513).

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p19` (2.0.1) | 4b4bb3cc68 | bundle `p16-p19.bundle` en la rama de softmac `nube/motor19-p19` (sin push a brave-core; lo sube LOCAL) |

**Lo que queda (tuyo):**

1. **Resultados de LOCAL** (orden `buzon/LOCAL/20261026-1815-MOTOR-19.md`): Release de la -p19 (build 29), `--simulate-outdated`
   en 2.0.0 frente a 2.0.1, Sparkle intacto (Acerca de > buscar y relanzar), «FlyWeb Sync», NTP con 7 fondos, y el `build.sh`
   nuevo (`FLYWEB_BASE=128`) frente a su guion: corregir lo que diga.
2. **Pestañas fijadas** (prueba de 5 pasos, §3 de `version-2.0.1.md`): si apunta a las fijadas compartidas, portar a la 2.0.x el
   arreglo `restored_browsers_`/`SynchronizeRestoredBrowser` de la 1.15 (brave-core `flyweb`, `browser/ui/tabs/shared_pinned_tab_service.cc`)
   sobre el de la 1.69, que sincroniza al activar comparando URL.
3. **Passkey «Brave»**: con la captura de Titín. Ninguna cadena nuestra lo dice; mirar si lo pone el teléfono/Google
   (identificación por client hints o UA) antes de tocar nada.
4. Barrido de marca (§2e): propuestas a Titín; nada de .grd/.xtb a mano. Usuario `@brave.com` y ruta `braveSync`, no se tocan.

**Trampas nuevas:** en `docs/TRAMPAS.md` (MOTOR, 26-10: guardas que la base nueva quita; `grd_string_replacements.py`). Además:
- raw.githubusercontent.com da **429** a menudo con etiquetas de la 116 (la 128 va mejor); reintentar con pausas de 15–20 s.
  `git fetch` de github.com/chromium/chromium da 504.
- `git grep` sobre una rama traída con `--filter=blob:none` baja blob a blob: solo `git show rama:fichero` concreto.
- `pkill -f` volvió a matar el propio shell (ya estaba en las trampas de MOTOR-17).

---

**Relevos anteriores** (MOTOR-2 a MOTOR-17; MOTOR-18 no dejó nota propia): [`relevo-motor-historial.md`](relevo-motor-historial.md).
