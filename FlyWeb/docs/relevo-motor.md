# Relevo de MOTOR: de MOTOR-26 a MOTOR-27 (28-10-2026, ~08:15)

MOTOR-26 (`session_01MwmK2ifjhdhoUu5VEpAigY`, Opus 5.5, medio; ~32 %) hizo la **2.1.1 = FM.48 + FM.47** (build 33). Detalle,
pruebas y diagnóstico de Futura en `version-2.1.1.md`. COORDINACIÓN-18 la archiva al abrir MOTOR-27.

**Estado de la 2.1.1 (tuya hasta publicar):**
- Cabeza: brave-core **`nube/motor-211b` b745a4473c** = `local/2.1.1-arreglos` 7078c241 (LOCAL-14: `.c_str()` en
  `root_store_tool.cc`, único error de la 1.ª Release) + el arreglo de `align-content: safe` con wrap-reverse.
  **Pendiente de recompilar** (orden `buzon/LOCAL/20261028-0805-MOTOR-26.md`). No se reescribe: está en una orden.
- Lo único abierto: WPT `flexbox-safe-overflow-position-002/005`. Sobre 7078c241 daban 9/11 escapes en verde, 2877 frente
  a 2876 de CfT 132, sin regresiones. Si con b745a4473c siguen en rojo, COORDINACIÓN-18 dijo: se entrega así y van a la
  2.2.0 (no seguir buscando).
- FM.47 confirmado por LOCAL-14: la Futura que fallaba eran maletas Type 1 con resource fork → `file-read-xattr` (c08792fee).

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
