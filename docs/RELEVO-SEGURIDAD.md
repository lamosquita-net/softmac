# Relevo de SEGURIDAD-PORTES (21-10-2026)

Para el siguiente relevo de SEGURIDAD-PORTES. Historia: SEGURIDAD-PORTES (`session_01NkotiT2nNYznsrQu9rssiy`) → -2
(`session_01YPgb1ubsQCorSgZWaRVgoF`, sin brave-core) → **-3 (`session_01LKiaD9v2hcna6BUo6CfMBs`, FS.14)**. Leer antes:
`CLAUDE.md`, `docs/TAREAS.md` (tabla, reglas 1–19, filas FS.10–FS.15), `docs/SEGURIDAD.md` y `FlyWeb/docs/cve-triage.md`.
La vigilancia diaria de CVE (FS.2) es de **SEGURIDAD-VIGÍA**; este papel porta y prueba.

**Idioma:** a Titín (el HUMANO), **siempre en castellano**, también justo después de leer commits o notas en inglés.
Commits en inglés.

## SEGURIDAD-PORTES-21 (`session_01MwmK2iSJ4qGU8EyNDJhUH3`, 11-11)

Abierta por COORDINACIÓN-39. `add_repo` de brave-core **denegado por el clasificador del modo auto** (regla 16 lo
permite en `main`, pero el clasificador decide en cada sesión): brave-core solo en lectura.

**Hecho:**
- **Sync con cuenta (#905, `sync-cuenta.md` de ARQUITECTURA):** revisión en el
  [comentario](https://github.com/lamosquita-net/softmac/pull/905#issuecomment-6797345699).
  - Bloqueantes:
    - B1: código corto de 30 bits que depende del `id` del servidor; un ns2 comprometido lo falsifica en unos 2^30 hashes.
    - B2: el cambio de contraseña deja a los Macs legítimos sin token para «No he sido yo».
    - B3: la «prueba de cadena» es el token de go-sync, que firma solo la hora y vale ±24 h.
  - A corregir: inyección de semilla, revocación que no corta la sync, «Empezar de cero» sin demora, códigos de email
    adivinables, correo masivo y registros del MTA (RGPD).
  - Cuando ARQUITECTURA lo rehaga, volver a revisar contra B1–B3.
- **CVE-2026-125350 (XML UAF, explotado):** es el UAF de libxslt de `xsltTestCompMatchDirect`.
  - Única corrección de código entre 157.0.8103.39 y .51: 049750111b (main 61cab3f772, 8078 2ad9b7f5a8).
  - Ya está en la 3.0.1 publicada (parche `seguridad/3.0.1/chromium/0034`, hunk idéntico) y XSLT va apagado. Nada que portar.
  - [Comentario en #937](https://github.com/lamosquita-net/softmac/pull/937#issuecomment-6797413928). Falta confirmar
    CVE → crbug cuando se abra.

**12-11:**
- **#905:** la segunda pasada encontró N1 (con la prueba de cadena sola, un Mac robado se quedaba con la cuenta) y N2
  (cupos de correo). La tercera la da por **aprobable para H1**, con N3 a corregir en el texto antes de H2: el ladrón agota
  los contadores compartidos; avisos que se pueden suprimir; cancelación con dos de tres factores.
  - **Ojo:** DIRECTIVAS del 12-11 cambia el modelo a Firefox Accounts (sin aprobación entre Macs). Si ARQUITECTURA
    reescribe, hay que revisar de nuevo: KDF de contraseña y ataque sin conexión con la base robada.
- **#949** (parches WebGL del renderer, regla 17): 0002 apto sin condiciones; 0003, con la época de caché y d8.
- **3.1.1:** inventario previo en `FlyWeb/docs/seguridad-3.1.1.md`. Hay un aviso programado para el 17-11 a las
  21:13 UTC (`trig_0111Rpi5tiBPMgw4ehQQyhNj`): nota de la 158 → cerrar el inventario → series `seg/3.1.1` → prueba de
  huella.

**Lecciones:**
- **«Sin commit público» no suele ser verdad:** el crbug se cierra, pero el cherry-pick a la rama estable sí es público.
  Basta con comparar las etiquetas de la versión de la nota (`git fetch --filter=tree:0 --shallow-since=…` de dos tags)
  para encontrarlo el mismo día.
- El token de go-sync (`auth/auth.go`) firma solo la marca de tiempo: no sirve como prueba de posesión para nada nuevo.

## SEGURIDAD-PORTES-17 (`session_01MwmK2h23XGknphhFuuhWG7`, 03-11 → 05-11, relevada al 46 %)

**Hecho:**
- B0 de FM.55 (#720, `b0-cve.md`).
- Lista de seguridad GL 151–156 (#735, `gl-150-156-seg.md`).
- Regla 17 de B1d (Metal en 10.14), cerrada: #746 y #760, `b1d-regla17.md` §1–§10.
- KEV contra la 2.7.0: sin novedad hasta el catálogo 2026.11.04.

**Pendiente:**
- **B5 (privacidad de la 3.0.0)**, aviso de COORDINACIÓN-28 del 05-11.
  - En el porte de Brave a la 156 (MOTOR-33), los 18 *overrides* de `blink::features` de Privacy Sandbox (SharedStorage*,
    PrivateAggregation, Fledge*, InterestGroup…) ya no existen en la 156.
  - En Brave 1.98 se apagan con el parche de `runtime_enabled_features.json5`, que llega en T8. Hasta entonces pueden quedar
    encendidas.
  - Al revisar B5, comprobar en la build que **no existen** esas APIs, ni Topics, ni Attribution Reporting, ni FedCM si aplica.
- **Auditoría de selectores: entregada** (#776, `FlyWeb/docs/b1d/selectores-auditoria-seguridad.md`): 4 A sin caída para
  la compilación de PGO de LOCAL-19 y varios B que conviene blindar. **Toca comprobar en la siguiente rama `flynk-b1d`
  que las A1–A4 se aplicaron** y que la comprobación con `otool` de los frameworks débiles se hizo.
- **Relevo (05-11 ~23:00): al 46 % de contexto.** Esta sesión queda quieta; la siguiente sigue desde aquí.
- Recomendación de `angle_revision`: **hecha**, en 9da2d916 (ANGLE rebasado a f10470c).
- ~~Recomendación abierta: subir `angle_revision` a la punta de `chromium/8078`. Va 3 commits por detrás, de IMG/Vulkan, que
  no afectan a Mac.~~

**Lecciones:**
- Chrome Releases sí se lee desde el contenedor (canal Atom de Blogger).
- La búsqueda de commits de GitHub (`gh api search/commits`) encuentra el arreglo por su número de crbug.
- skia.googlesource está bloqueado: para Skia, ANGLE y Chromium, usar `git fetch --filter=blob:none` desde GitHub.
- Gitiles limita la velocidad: hay que ir en serie y con reintentos.

## SEGURIDAD-PORTES-16: FS.39 entregada (02-11-2026)

FS.39 (regla 17 del 138, 2.7.0), brave-core lineal sobre `nube/motor-138` 06d351d3: `seg/fs39-v8` 380f23cd →
`-blink138` 9a25c236 → `-gpu` 5a0494c3 (con Brotli CVE-2026-111497) → `-propio` 17f009df → `-lts` 7b045fd0 (punta).
d8 13.8 en verde (D8-LINUX-3). Detalle en la fila FS.39, `patches/v8/FLYWEB-SECURITY.md`, `patches/FLYWEB-SECURITY.md`
y `patches/FLYWEB-SECURITY-fs39-propio.md` (brave-core) y `cve-triage.md` § FS.39.

**Para la siguiente:** FS.40 propuesta (barrido de la LTS 138 .185 → .310 fuera de Blink y V8 sobre la 128, para el
139). Pendientes: ANGLE 2d08a95 (pide antes Gerrit 5748789); V8 b01d779c20/19d60f6362 y 28fc9a12ce (a mano);
scheduler.yield 1988acd89 (139). b5db50f99b ya está cubierto.

**Lecciones:**
- **Un CVE nuevo de una biblioteca de terceros se comprueba contra la copia de Chromium, no contra la versión del
  nivel:** Chromium no actualizó brotli de 2022 a 2026 (hasta el 148), así que el arreglo no llega con ningún nivel.
- **La rama «propia» del nivel destapa deuda vieja:** al mirar los ficheros que tocó el porte salieron arreglos de la
  LTS en código de la 128 (PageState, `window.open` con POST, bfcache, MHTML). Revisar por fichero tocado, no solo por
  función portada.
- **Un arreglo de upstream puede necesitar su seguimiento:** ee4d43b9004 dejaba un iterador colgando; lo cierra
  405dcf07fd1. Buscar siempre commits posteriores con el mismo crbug o sobre la misma función.
- **Trabajar en local mientras falta el push funciona**, pero las ramas viven solo en el contenedor: rebasar sobre cada
  avance de MOTOR (tres veces aquí) y subir en cuanto haya permiso.

## SEGURIDAD-PORTES-15: FS.38 entregada (30-10-2026)

FS.38 (regla 17 del 137, 2.6.0) en brave-core sobre `nube/motor-137` 78237a70: `seg/fs38-v8` 068f195b (6 arreglos de V8,
4 de ellos JSPI hechos a mano en x64; época 28), `seg/fs38-blink137` c7b24ba3 (15 de Blink), `seg/fs38-propio` 2d5b76e5
(farbling de float16 y Root Store). Se funden en el orden v8 → blink137 → propio sin conflictos. La d8 13.7 de D8-LINUX
da verde (7800/7801). Detalle en la fila FS.38 y en `patches/v8/FLYWEB-SECURITY.md`.

**Para la siguiente:** quedan fuera del nivel, pendientes de un barrido general: 9fb841bf28, dffb572d0b (parece aplicar
a la 128), 155b785d0e, 6aa38f2d02, 70c9c1f16b y a16cd5c0ad. Riesgos de V8 abiertos: b01d779c20, 19d60f6362, 28fc9a12ce
y b5db50f99b. JSPI y `wasm_deopt` están encendidos desde este nivel: en cada nivel hay que revisar sus arreglos.

**Lecciones:**
- **El código propio también necesita una revisión adversaria.** El farbling de 16/32 bits solo tocaba el bit 0 de la
  mantisa y `Math.round(v*255)` lo borraba: leer en `rgba-float16` un canvas de 8 bits devolvía la huella limpia. La
  prueba (`canvas-float16.html`) comprobaba el bit que cambiaba, no que el cambio sobreviviera al redondeo. Una prueba
  de farbling tiene que intentar deshacerlo.
- **Las banderas por defecto cambian con la V8:** JSPI y `wasm_deopt` estaban apagadas en 13.5 y 13.6 y vienen encendidas
  en 13.7. Hay que mirar `flag-definitions.h` en cada nivel, no solo gin.
- `v8-d8.sh` se salta los parches que llevan hunks `BRAVE_`. Un porte que cambia una firma usada en uno de ellos rompe
  la d8 aunque compile en el Mac (COORDINACIÓN-22 arregla el guion).

## SEGURIDAD-PORTES-14: FS.37 entregada (30-10-2026)

FS.37 (regla 17 del 136, 2.5.0) en brave-core sobre 1747f79f: `seg/fs37-v8` 31edd5c3 (11 arreglos de V8, época 26; 179e9dbd no compilaba),
`seg/fs37-blink136` 367967ae (15 de Blink, `setSinkId` incluido), `seg/fs37-red` 03025063 (c287a87a87, bfcache con
`no-store` y precarga). Orden v8 → blink136 → red, limpio. Detalle en la fila FS.37 y en `patches/v8/FLYWEB-SECURITY.md`.
d8 13.6 de D8-LINUX en verde (7733/7736, sin regresiones). Dudosos de Blink sin portar (para MOTOR o
SEGURIDAD-VIGÍA): 16f576f0d, 5e23d3e57b (`moveBefore` y React), 8bfb9c77e2+b95f9cc4e5, d3246d568e, 3bea7d665d,
004280ecbb, e6b7839c2f, 31adde08d1, 5923de5fab, 8ffa9e3228, 1a31de5394, 75afc91d4a. Riesgos de V8 de FS.36 siguen
abiertos; deuda de Maglev ampliada (lista en `FLYWEB-SECURITY.md`).

**Lecciones:**
- **Encender una función por configuración también pide regla 17:** la bfcache con `no-store` (un cambio de un valor)
  necesitaba un arreglo posterior (páginas precargadas sin vigilar cookies). Mirar los arreglos de lo que se enciende, no
  solo de lo que se porta.
- **Un porte que aplica limpio no compila por eso** (ya lo decía FS.28 y volvió a pasar): 3 de 13 usaban símbolos de V8
  posteriores. Antes de entregar, `grep` en el árbol de cada identificador nuevo que añade el porte.
- Un subagente clasificó 4cf9311810 como «a mano» y ya estaba en `patches/v8` con otro texto: antes de portar, `grep` de
  una línea característica del arreglo en el árbol con parches.
- `patch -F3 --dry-run` cuenta mal: comprobar que no queden `.rej` antes de hacer commit.
- Regenerar parches de Chromium: blob de la 128 (`git fetch --depth 1 --filter=blob:none` del tag en github.com/chromium/
  chromium, `git show 128:<ruta>`) + parche actual con `patch`, editar y `git diff --no-index --full-index`; los hashes
  `index` coinciden con los de brave-core.

## SEGURIDAD-PORTES-13: FS.36 entregada (29-10-2026)

FS.36 (regla 17 del 135, 2.4.0) en brave-core sobre ebd8c17f: `seg/fs36-v8` 2886b9c9 (70 arreglos de V8, época 24),
`seg/fs36-blink135` 99657760 (14), `seg/fs36-red` 93d34511 (4). Orden de fusión v8 → blink135 → red, limpio sobre
`local/240-arreglos` 679e7e5c52. Detalle en la fila FS.36. **Pendiente para la siguiente:** compilación en el Mac de
las adaptaciones a mano de V8 (`JSPromise`, SFI); riesgos abiertos de `FLYWEB-SECURITY.md`; Maglev: ffc18dfff9 y
e321b042d4 al encenderlo.

**Lección:** una prueba de regresión que en un nivel entra «sin cambio de código» puede necesitar el arreglo en el
siguiente si cambia la base (regress-550360762 en la 13.5): repasar las pruebas de la deuda de Maglev en cada nivel.

## SEGURIDAD-PORTES-12 → 13 (28-10-2026, ~19:10)

SEGURIDAD-PORTES-12 (`session_01MwmK2ht74Zw1oGKA6mdQ4i`, Opus 5.5, medio) termina FS.35 (regla 17 del 134). Entregado
para MOTOR-29, en brave-core sobre `nube/motor-134` 5107563b:
- `seg/fs35-maglev-dead` 0ce38fe7: barrido de nodos `Dead` de Maglev sin `maglev_untagged_phis` (si no, el renderer
  cae en cuanto se encienda Maglev). Probado en la `d8` 13.4: 7560/7561, `maglev`+`stress_maglev` 15050/15050.
- `seg/fs35-blink134` c56bbf9b: 9 arreglos de Blink (CloseWatcher, `<dialog>`, MediaDevices, anchor, a11y, editing).
  Sin compilar: si LOCAL trae un error de compilación, mirar primero `html_dialog_element.cc` (el más grande).

**Pendiente para la 13:** al encender Maglev, la medida en la 5,1 y la 6,1 (LOCAL). Revisar en cada nivel la constante
153.0.8010.0 y `kMaxSupportedCTCompatibilityVersion` (hoy, 4 y v43 en main). `FLYWEB-SECURITY.md` §4 sigue diciendo
«época 20» (el código lleva 22): corregirlo cuando se toque.

**Lecciones:**
- **Lo que apagamos cambia lo que upstream prueba:** con `maglev_untagged_phis` apagado, una pasada que upstream siempre
  ejecuta (el selector de phis) deja de limpiar el grafo. Probar Maglev con `stress_maglev` y nuestras opciones, no
  solo con las de upstream; `--maglev-untagged-phis` en la línea de órdenes sirve para aislarlo.
- Para buscar commits de Chromium sin googlesource: `git fetch --filter=tree:0` de `main` (solo mensajes, ~1 min) y
  `--grep`; los ficheros sueltos, con un clon `--depth=1 --filter=blob:none` aparte (el perezoso sobre `tree:0` se cuelga).
  raw.githubusercontent.com devuelve 429.
- `v8-d8.sh` con la 13.4: los `patches/third_party-simdutf-*` de brave-core aplicados en la raíz de V8 dan el
  `third_party/simdutf` que hace falta; compilar, ~55 min con 4 núcleos.

## SEGURIDAD-PORTES-11 → 12 (28-10-2026, ~13:45)

SEGURIDAD-PORTES-11 (`session_01MwmK2m7q9Dk4L6Yc7GdsS9`, Opus 5.5, medio) se releva al ~44 %. Entregado (filas FS.31,
FS.33 y FS.34 de `TAREAS.md`; brave-core):
- **FS.31 → FS.33:** Root Store a **153.0.8010.0** (Titín, con el 133): `seg/fs33-roots153`. Ya fundida por MOTOR-28.
- **FS.33 (regla 17 del 133):** `seg/fs33-blink133` (9044bcbe DevTools, 5e0a7a16, 2a251e72) y **stack clash de TurboFan**
  v8 ea2f03dfff (`seg/v8-stackclash-133`; reserva 13.2 `seg/v8-stackclash-132`, solo si el 133 se atasca). Fundidas por
  MOTOR-28. Los 12 solo-LTS de MOTOR-27: pasan mjsunit en la `d8` 13.3 (7464/7465, el de siempre).
- **FS.34 (deuda de Maglev, nivel 134, V8 13.4.114.21):** `seg/maglev-134`: serie `git am` en `FlyWeb/v8-maglev-134/`
  (19 parches + README con la tabla) sobre la 13.4 **limpia**; quien monte la V8 del 134 la aplica y regenera `patches/v8`.
  Cifra aceptada por COORDINACIÓN-18: **16 arreglos de Maglev** (+2 de TurboFan) contra la 13.4, revisados commit a commit.

**Pendiente para la 12:** cuando MOTOR monte la V8 13.4 del 134, revisar que la serie entre sobre sus `patches/v8` (choca
en `maglev-graph-builder.cc` con el porte de FS.29, 6937df3c, que MOTOR lleva a la 13.4), subir la época de caché
(af7d1483a5 cambia bytecode) y, al encender Maglev, la medida en la 5,1 y la 6,1 (LOCAL). Revisar en cada nivel la
constante 153.0.8010.0 y `kMaxSupportedCTCompatibilityVersion`.

**Lecciones:**
- **Contar la deuda contra la V8 de destino, commit a commit:** contra la 13.3 salían 16, y contra la 13.4 también 16,
  pero no los mismos (entran 3 cuyo código no existía en la 13.3; sale 1). Restar categorías da una cota (84 → 40–50),
  no la cifra. Las pruebas de regresión de upstream en una `d8` limpia dicen qué reproduce (4 de 9 en la 13.3).
- **Un porte que añade una salida de error destapa caminos que upstream nunca recorría:** con las salidas de
  `MaglevCompiler::Compile`, la 13.3/13.4 destruía el trabajo fallido de OSR concurrente con el hilo aparcado (DCHECK en
  `UnregisterStrongRoots`); upstream lo arregló en el dispatcher. Probar siempre la variante OSR.
- **`[[nodiscard]]` nuevo: buscar todas las llamadas** (un `CHECK(AllocateRegisters(...))` habría convertido el corte en
  una caída).
- `v8-d8.sh` con la 13.3+ necesita `third_party/highway` (GitHub google/highway, rev del DEPS) y la 13.4 además
  `third_party/simdutf` (googlesource bloqueado: amalgama v6.1.0 de la release de GitHub y un `BUILD.gn` mínimo). Los
  parches con `//brave/` (BUILD.gn, `src-codegen-compiler.cc`) se dejan fuera de la `d8`. Compilar: ~2 h con 4 núcleos.
- Para buscar fusiones: `/home/user/maglev-inv` con `--filter=blob:none` de las `branch-heads`; nada de `git log -S` ahí
  (se cuelga bajando blobs).

## SEGURIDAD-PORTES-10 → 11 (27-10-2026, ~18:15)

SEGURIDAD-PORTES-10 (`session_01MwmK2iNSPnCnPkiEFHwqZ4`, Opus 5.5, medio) termina el encargo hacia el ~33 %. Entregado,
todo sobre `nube/motor-132` 78eb79e8, en ramas independientes para una 2.1.x (filas en `TAREAS.md`):
- **FS.30** `seg/fs30-ct` 2d022f2c: CT con la forma del M144 (compatibilidad 4). CT estaba apagado en toda la 2.x.
- **FS.31** `seg/fs31-roots` dae06d65: Root Store v17, `permitted_dns_names`, HSTS de la 132,
  `RequireKnownRootCert`; restricciones de versión del Root Store contra una **constante fija 139.0.0.0** (Titín).
- **FS.29** `seg/fs29-v8` 53814453: V8 6937df3c, época 20; mjsunit 7340/7341.

**Pendiente para la 11:** la deuda de Maglev para el 134 (lista en la sección de la -9; 22e588df ya va portado aquí,
también su parte de Maglev). Revisar en cada nivel: `kMaxSupportedCTCompatibilityVersion` (si Google sube a 5, CT se
apaga otra vez) y la constante 139.0.0.0 del Root Store (al subirla, mirar si hay restricciones con campos nuevos).

**Lecciones:**
- **Los datos con versión no son «solo datos»:** el Root Store y la lista de CT llevan restricciones por versión de
  Chrome, que FlyWeb evalúa con la 128 real; sin tocar el código, los datos nuevos no cambian nada.
- **Para leer Chromium sin googlesource:** `git fetch --depth 1 --filter=blob:none` de un tag de github.com/chromium/chromium
  y `git diff --stat` por rutas; **no** usar `git grep` en un clon `blob:none` (baja los blobs de uno en uno; se
  colgó dos veces). Para V8, un clon `--depth 1` sin filtro (36 MB) sí permite `grep`.
- `v8-d8.sh` necesita `gn`: `apt-get update && apt-get install -y generate-ninja`. Compilar tarda ~1,5 h con 4 núcleos.
- Las pruebas de upstream recientes usan ayudas de `mjsunit.js` que la 13.2 no tiene (`assertMaglevved`): adaptarlas.

## SEGURIDAD-PORTES-9 → 10 (27-10-2026, ~13:30)

SEGURIDAD-PORTES-9 (`session_01MwmK2hx8uFcooc8ep2MhQT`, Opus 5.5, medio) se releva al ~38 % (22 $). Entregado: FS.27 y
FS.28 (apto con cambios, filas en `TAREAS.md`), punto 3 (HSTS portado; CT → FS.30) y la 2.0.4 de seguridad.

**Ramas (brave-core):**
- `seg/fs27-blink132` 54b1ae68b (fundida por MOTOR-25 antes de sideways) y `seg/fs27-132` ff9e192c4 sobre
  `nube/motor-132` 50f5d099b (475cb03ab90 + `IgnoreHSTSForLocalhost`).
- `seg/fs28-v8` b9a044721 sobre 50f5d099b: `patches/v8` para 13.2.152.56 (32 parches, época 19). `seg/v8-13.2`: historia,
  no usar.
- `seg/v8-13.1-lle` 09efe2b30 sobre fbe2394fed: los 4 arreglos de late load elimination en 13.1, época 18,
  `flyweb_version` 2.0.4. **La 2.0.4 la canceló Titín (27-10):** la rama queda de reserva por si la 2.1.0 se atasca más de
  2 días. **No está probada en la `d8` 13.1** (se paró la compilación al cancelarse): si se usa, primero `v8-d8.sh` y
  mjsunit. Los mismos cambios sí pasaron en la 13.2.

**Decisión de Titín (27-10, vía COORDINACIÓN-17):** Maglev se enciende **como tarde en el nivel 134**, con su deuda de
seguridad portada antes (la lista de ~15 arreglos está en el informe de FS.28: 0313bc72, 22e588df, 73ef2fa5, a7c1a463,
be59876b, c9856bae, b9013994, 96975bd6, ddc4473b, 645f3356 + 07ad1d3a, 99209d95, fbaaf59c, a0f977f1, d5b0cb2a; más
7076ba13 = `maglev_untagged_phis` apagado) y pruebas de rendimiento en la 5,1 y la 6,1.

**Orden para SEGURIDAD-PORTES-10:** FS.30 → FS.31 (nueva: Root Store v17 + HSTS) → FS.29; la deuda de Maglev, planificada
para el 134.

**FS.30:** paso 2 (CT con la forma del M144, `seg/fs30-ct` sobre la cabeza de `nube/motor-132`,
commit propio) y después FS.29 (22e588df). Fuentes de FS.30: Chromium f961e4985b, 0e9d449fac, 46415d1bdb, 94e9495231,
abab372dda, 25cb1f94e7, e1867ca032, cfd8936a1e, **60533e104a** (forma final); ficheros: proto `log_type`,
`ct_log_info.mojom`, `pki_metadata_component_installer.cc`, `chrome_ct_policy_enforcer.{h,cc}` (leaf index con CBS),
`cert_verifier_service_factory.cc`, `system_network_context_manager.cc`, `ct_known_logs.h`. Brave: `kSCTAuditing` apagado
(`chromium_src/chrome/common/chrome_features.cc`), `kCertificateTransparencyAskBeforeEnabling`
(`chromium_src/chrome/browser/browser_features.cc`), hosts exentos de brave.com en
`chromium_src/chrome/browser/net/profile_network_context_service.cc`.

**Lecciones:**
- **Que un parche aplique limpio no quiere decir que compile:** 153cde95 llama a `WipeAllMaps()`, que la 13.1/13.2 no
  tienen (lo trajo otro commit). Buscar en el diff las funciones nuevas que usa.
- **Un triaje «no aplica por las opciones» caduca con la V8:** la late load elimination de JS estaba apagada en la 12.0 y
  encendida desde la 13.x; nadie volvió a mirarla. Al subir de V8, revisar los valores de las opciones de cada arreglo
  descartado por «apagado».
- Para buscar arreglos de una rama: `git fetch --filter=tree:0` de `refs/branch-heads/X.Y` de github.com/v8/v8 funciona;
  para Chromium por fichero, un clon `--filter=blob:none --shallow-since` (~900 MB, 2 min) y blobs por lotes con
  `git fetch --stdin` (método del subagente de FS.27 en la fila).

## SEGURIDAD-PORTES-5 → 6 (22-10-2026, escrita por COORDINACIÓN-12)

SEGURIDAD-PORTES-5 (`session_01H7fz6r296TWMGBgDfYzRgX`) se archiva **parada y sin encargo**, al ~40 % (criterio de Titín,
22-10: no se tiene una sesión abierta para esperar). Su estado al archivar, según su último mensaje: **S1–S4 entregados**
(brave-core #1–#4, de registro) y **FS.23 hecha** (`seg/128-r17` a9d687a762), fundida por MOTOR-16 en `-p3`. Desde
entonces la integración de la 128 va por `nube/base-128-motor-p12` ae5626ab1a (motor -p11 + identidad -i5; FM.31/FM.38).
SEGURIDAD-PORTES-6 se abre con el siguiente encargo: probablemente la revisión de la regla 17 de lo nuevo de -p10…-p12
y la clase E (servicios nuevos de Brave 1.58–1.69 y auditoría de red, `FlyWeb/docs/brave-servicios-nuevos.md`).

## SEGURIDAD-PORTES-4 → 5 (21-10-2026, ~19:00)

SEGURIDAD-PORTES-4 (`session_011AG2q3vyZyeMypwfR1RDVy`, Opus 5.5, medio) → **-5**. Se releva al 45 % de contexto, antes de S1.

**Estado:**
- **1.15.2 publicada**, con la revisión de la regla 17 cerrada en FS.22. Va de la F9 a la F16 de FM.28; la F16 es
  `nube/motor-131-anchor-f16` af0328adeb.
- **Ramas mías fundidas en la F14:** `seg/top-layer-box` 1f7b9912 (0e454ce616) y `seg/subtree-roots-copy` 49964845
  (c215f8e6f0).
- **Error mío de la F11**, corregido por MOTOR-14 en la F15: di por hecho que `HasPositionedObjects()` de la
  LayoutNGView cubría la capa superior. En la 116 no la cubre.
  **Lección:** una salida temprana que depende de un dato de la 116 se comprueba en el código, no por analogía con
  upstream.
- **1.15.3 cancelada** (Titín, 21-10). En la 1.15.x, solo seguridad urgente: un UAF o una caída explotable en código
  que cambie esa versión se avisa a COORDINACIÓN.
- **Siguiente hito: la base 128** (FM.31).

**Encargo en curso (COORDINACIÓN-11, aprobado):** volver a cortar sobre la 128 los parches de seguridad de la clase D.
- Inventario en [`FlyWeb/docs/seguridad-128.md`](../FlyWeb/docs/seguridad-128.md) (PR #430, fusionado): 41 `.patch` en
  **S1 → S2 → S3 → S4**, 7–10 h.
- **Primero S1**: Blink, aplica limpio, y lleva los dos UAF de 2026.
- **S3 cruza con MOTOR-14** (`line_breaker`, `inline_cursor`, `inline_item*`, `layout_object.cc`). COORDINACIÓN ya le
  avisa; va primero la seguridad.

**Base de cada S:** la 128 de la Fase 1 de FM.31, es decir, Brave **1.69.168** = Chromium **128.0.6613.138**, ANGLE
`713102774487`, Skia `938144dd79c6`.
- En brave-core no hay aún rama de esa base limpia: solo `nube/motor-128*` y `seg/*-128`, que están sobre la 116 y
  **no valen**.
- Antes de S1, pregunta a COORDINACIÓN o LOCAL de qué rama parte. Si no la hay, prepara cada S como `.patch` por
  fichero contra 128.0.6613.138 en una rama `seg/128-s1`… desde el tag `v1.69.168` de brave/brave-core (fetch del tag
  al fork), y LOCAL los lleva a la Fase 1.
- Los `.patch` de Brave 1.69 que ya tocan el mismo fichero mandan: el nuestro se regenera sobre el suyo, como con
  `update_patches`.

**Cómo se midió (`check.sh`, para rehacerlo):**
- Necesita el clon de brave-core con historia (`git fetch --depth=1500 origin <rama>`).
- `./check.sh <commit>` reconstruye, para cada `.patch` del commit, el diff del arreglo a nivel de Chromium:
  `116 + .patch del padre → 116 + .patch del commit`, con los ficheros sacados de `raw.githubusercontent.com`
  (chromium/chromium, google/angle, google/skia; googlesource está bloqueado).
- Luego lo prueba con `patch --dry-run` sobre el fichero de la 128, primero al revés y luego al derecho. Devuelve
  R/A/F/X/N y traduce las rutas `ng/`/`ng_` y los nombres `NG*` de la 116 a los de la 128.
- **X no basta para decidir:** mira la fecha de upstream frente a la rama de la 128 (~22-07-2024) o lee el fichero de
  la 128.
- Para las fechas, `git fetch --filter=tree:0 --shallow-since=2024-07-15 https://github.com/chromium/chromium
  refs/heads/main`. Si un commit falta ahí, es anterior o de una rama.
- Para regenerar: 116 o 128 + `.patch` en un repo temporal, `git diff --full-index`, nombre = ruta con `/` → `-`.

```bash
#!/bin/bash
# check.sh <commit>: per file of the commit, rebuild the Chromium-level fix diff (116+parent.patch -> 116+commit.patch)
# and test it on the 128 file: R = already in 128 (reverse applies), A = applies, F = fuzz, X = fails, N = file absent in 128
BC=/home/user/brave-core; W=/tmp/claude-0/cd/w; c=$1
fetch() { # repo rev path out
  case $1 in cr) u="https://raw.githubusercontent.com/chromium/chromium/$2/$3";; angle) u="https://raw.githubusercontent.com/google/angle/$2/$3";; skia) u="https://raw.githubusercontent.com/google/skia/$2/$3";; esac
  curl -sS -m 60 -f -o "$4" "$u" 2>/dev/null; }
for pf in $(git -C $BC show --format= --name-only $c -- patches | grep -v '^patches/v8/\|FLYWEB-SECURITY\|_test\|unittest'); do
  case $pf in patches/third_party/angle/*) repo=angle; r116=b48983ab8c74d2fcd9ef17c80727affb9e690c53; r128=713102774487cf1a8b3f433529eb8181cbcec31a;;
              patches/third_party/skia/*) repo=skia; r116=bb40886d43b5fcbcdfb5587a2d20db418622990a; r128=938144dd79c6e3664a3c0bbd019daedddf655ffa;;
              *) repo=cr; r116=116.0.5845.188; r128=128.0.6613.138;; esac
  newp=$(git -C $BC show $c:$pf 2>/dev/null); oldp=$(git -C $BC show $c^:$pf 2>/dev/null)
  path=$(echo "${newp:-$oldp}" | sed -n 's#^+++ b/##p;s#^--- a/##p' | head -1)
  rm -rf $W; mkdir -p $W; fetch $repo $r116 $path $W/f116 || { echo "  $pf: sin fichero en la 116"; continue; }
  cp $W/f116 $W/before; cp $W/f116 $W/after
  [ -n "$oldp" ] && { echo "$oldp" > $W/old.patch; (cd $W && sed "s#^--- a/.*#--- a/before#;s#^+++ b/.*#+++ b/before#" old.patch | patch -s -p1 >/dev/null 2>&1); }
  [ -n "$newp" ] && { echo "$newp" > $W/new.patch; (cd $W && sed "s#^--- a/.*#--- a/after#;s#^+++ b/.*#+++ b/after#" new.patch | patch -s -p1 >/dev/null 2>&1); }
  diff -u $W/before $W/after > $W/fix.diff; n=$(grep -c '^[-+][^-+]' $W/fix.diff)
  p128=$path; if ! fetch $repo $r128 $path $W/f128; then p128=$(echo $path | sed 's#/ng/#/#; s#/ng_\([^/]*\)$#/\1#'); [ "$p128" != "$path" ] && fetch $repo $r128 $p128 $W/f128 || { echo "  N  $path (±$n)"; continue; }; sed -i 's/\bNG\([A-Z]\)/\1/g' $W/fix.diff; fi
  cp $W/f128 $W/t; if patch -s -f --dry-run -R $W/t < $W/fix.diff >/dev/null 2>&1; then st=R
  else o=$(patch -f --dry-run $W/t < $W/fix.diff 2>&1); if [ $? -eq 0 ]; then echo "$o" | grep -q fuzz && st=F || st=A; else st=X; fi; fi
  echo "  $st  $p128 (±$n)"
done
```

**Avisos:**
- **A MOTOR-13 no le llega `send_message`** (`elevated_session_untrusted_device`); a MOTOR-14 sí. Las sesiones locales,
  por la rama `buzon` (`docs/ARRANQUE.md`).
- **No hay que llamar nunca a `confirm_repository_trust`.**
- **Revisiones de la regla 17:** MOTOR puede pedirlas directamente; el resultado se le pasa a COORDINACIÓN.
- **Pendiente de la lista de la 1.15.3** (ahora sin versión), por si vuelve a hacer falta:
  - 01c7c1b09a (`::backdrop`, caída por CHECK).
  - 3aa7ad2a0d (especulativo).

## 1. Versiones y ramas de seguridad (15-10)

La 1.13 está publicada (157.64.22): `flyweb` = 37197fe04 = `nube/motor-129` 325686916c, cuyos `patches/v8` son
idénticos a `seg/v8-12.9` y el parche de WebAudio, idéntico a `seg/blink-129` (comprobado con `git diff`).

Cada nivel N lleva la V8 de Chrome N. Las ramas `seg/v8-X.Y` de brave-core salen de `nube/motor-N` (o del paso de V8
de MOTOR) y solo tocan `patches/v8/`; MOTOR las funde en `nube/motor-N` y LOCAL compila desde ahí. Cada una tiene
`patches/v8/FLYWEB-SECURITY.md` con su contenido exacto y sus pruebas. Distinguir siempre **«probado en `d8`»** (solo
V8, Linux, en la nube) de **«compilado en FlyWeb»** (LOCAL, en la 7,1).

| Nivel | Versión | V8 | Rama | Época de caché | Fila |
|---|---|---|---|---|---|
| 118–124 | 1.2–1.8.1 | 11.8 … 12.4 | `seg/v8-11.8` … `seg/v8-12.4` | — | FS.4–FS.7 (historia) |
| 125 | 1.9 | 12.5.227.13 | `seg/v8-12.5` 50624c65 | — | FS.7 |
| 126 | 1.10 | 12.6.228.49 (M126-LTS) | `seg/v8-12.6` c3d250ff | — | FS.8 |
| 127 | 1.11 | 12.7.224.20 | `seg/v8-12.7` 94914682 | — | FS.9 |
| 128 | 1.12, 1.12.1, 1.12.2 | 12.8.374.38 | `seg/v8-12.8` 5aa57049 | 12 | FS.10 |
| 129 | 1.13 | 12.9.202.28 | `seg/v8-12.9` 2ffa1017 | 13 | FS.13 |
| **130** | **1.14** | **13.0.245.25** | **`seg/v8-13.0` 064323b537** | **15** | **FS.14** |

Ramas de Blink (sin V8):

| Rama | Qué | Fila |
|---|---|---|
| `seg/rubylb-128` 44c2af83 | 12 arreglos de caídas y memoria de upstream en el código de RubyLB (6 parches); en la 1.12.1 | FS.11 |
| `seg/inline-116` 907c9507 | deuda de la 116 en LayoutNG inline: CHECK de `NeedsCollectInlines` (posible UAF por *container queries*) en la 1.12.1; d7020222f64 + 9df6f20935b en la 1.12.2 | FS.12 |
| `seg/blink-129` 63ea2663 | `automation_rate_` atómico en WebAudio (8669b50ce1c, crbug 357391257); en la 1.13 | FS.13 |
| `seg/transfer-keys` 1df157fca7 | claves de `TransferList`/`Attachment` con su propia dirección (f66bd3243b, crbug 511006880); la 1.13 no está afectada (LOCAL-4, `nm`: el ICF no las fusionó); higiene para la 1.14 | FS.14 |

Ramas viejas sin uso (no borrar sin preguntar): `seg/cve-2024-7971`, `seg/cve-2025-13223`, `seg/v8-groupby-contexto`.
La época **14** se reservó para un plan B de la 1.12.3 que se abandonó (nunca se subió): **no usarla**.

## 2. Lo apagado o distinto de upstream (regla 19)

Principio (Titín, 14-10): lo que FlyWeb apaga se vuelve a encender cuando upstream lo lleva de serie, está maduro y
trae sus arreglos. Valores comprobados en `src/flags/flag-definitions.h` de cada etiqueta de V8.

| Qué | FlyWeb | Upstream | Punto de decisión |
|---|---|---|---|
| `maglev` | apagado (Titín, 05-10; también en la 116) | encendido desde 11.x | **sigue apagado en el 132** (COORDINACIÓN-16, 27-10): ~15 arreglos de Maglev posteriores a la LTS 13.2 que aplican (4–6 días) y ~1–1,5 nuevos al mes; revisar en cada nivel (FS.28) |
| `maglev_untagged_phis` | apagado (CVE-2026-3910) | encendido en la 13.2; main lo apagó (7076ba13, 03-2026) | se mantiene apagado (igual que main) |
| `turboshaft_wasm` | **encendido en el 132** (de upstream, sin parche) | encendido en 13.2 | hecho (FS.28), con 5 arreglos de Turboshaft-Wasm posteriores a la LTS |
| `turboshaft_load_elimination` (JS) | encendido (de upstream) desde la 13.x | encendido | sus arreglos posteriores no se habían portado: 4 en la 2.0.4 y el 132 (FS.28) |
| `turboshaft_instruction_selection` | apagado 12.3–12.8; **encendido desde 12.9** | encendido desde 12.5 | hecho (1.13). Con él apagado la 12.9 caía en `ToConstant()` (`kTrustedHeapConstant`) |
| `wasm_to_js_generic_wrapper` | apagado 12.3–12.8; **encendido desde 12.9** | encendido desde 12.3 | hecho (1.13) |
| JSPI, `wasm_deopt`, *stack switching* | apagados (experimentales; Blink 116 no tiene *origin trial* de JSPI) | experimentales | cuando upstream los envíe y Blink los exponga |
| `regexp_simd` | encendido (de upstream, nuevo en 13.0) | encendido | hecho (1.14). Exige SSSE3; AVX solo si la CPU lo tiene. Titín lo prueba en la 5,1 con `FlyWeb/tools/regexp-130.html` |
| ORB v0.2 (`OpaqueResponseBlockingV02`) | **encendido en la 1.14** (COORDINACIÓN-6, 15-10; MOTOR-10) | encendido desde la 126 | hecho. Solo cambia la entrega: `ERR_BLOCKED_BY_ORB` en vez de respuesta vacía |
| WebSQL, `MutationEvents`, pantalla completa prefijada de `<video>`, `:--foo`, `includeShadowRoots`, `<template shadowroot>` antiguo, `getInnerHTML()` | **apagados en la 1.14** (motor.md «Nivel 130» §9–§10; `getInnerHTML()` si CfT 130 lo confirma) | apagados en Chrome 119–131 | hecho. WebSQL quita SQLite del renderizador |
| `OriginAgentClusterDefaultEnable` | **encendido en la 1.14** (tras la prueba de LOCAL-4 en CfT 129) | encendido desde la 119 | hecho |
| `IsolateSandboxedIframes` (iframes *sandboxed* del mismo sitio en otro proceso) | apagado (116) | encendido desde la 127, agrupación por origen | **FS.15** (`seg/oopsif`), aprobada; LOCAL-4 midió +2 procesos y +27–39 MB |
| WebGPU (`kWebGPUService`, CVE-2026-5281) | apagado (`chromium_src/gpu/config/gpu_finch_features.cc`, de `nube/webgpu-off`; está en la 1.13) | encendido | **nivel ~140** |
| JIT y WebAssembly | abiertos a todas las webs desde la 1.6 | ídem | interruptor sin recompilar: política `DefaultJavaScriptJitSetting = 2` |

Lo que no es de seguridad (Wallet, Rewards, News, Talk, Leo, VPN, P3A, Omaha) está en `CLAUDE.md`, no aquí.

## 3. FS.14 (nivel 130, V8 13.0): estado

Detalle en la fila FS.14 y en `patches/v8/FLYWEB-SECURITY.md` de `seg/v8-13.0`. Hecho: revisión del rebase de
MOTOR-10, fusiones de 13.1.201.22 y 13.2.152.56 (contra la 13.0 y contra la 12.9 + parches de la 1.13), v8 924c1a79
y 91343bb4, época 15, API del *embedder*, opciones. Método útil: `git show <merge> -- src include BUILD.gn` y
`git apply --check` / `-R --check` sobre el árbol **con los parches de FlyWeb aplicados** (sobre el limpio, lo que
FlyWeb ya lleva sale como «falta»).

- **91343bb4 también falta en la 1.13** (12.9). Decisión del HUMANO (15-10): no hay 1.13.1; va en la 1.14. Red: se
  hace la 1.13.1 si aparece explotación conocida o si la 1.14 no está entregada antes del 17-10 a las 16:00. Entra
  limpio en la 12.9. Mitigación sin recompilar: `DefaultJavaScriptJitSetting = 2`.
- Explotación conocida (15-10): ni crbug 390743124 ni 511006880 están en el KEV de CISA (espejo
  `raw.githubusercontent.com/cisagov/kev-data`, catálogo del 14-10-2026); chromereleases, cisa.gov y NVD están
  bloqueados en el contenedor.
- Pendiente: pruebas en `d8` y mjsunit; arreglos posteriores de upstream en los ficheros que porte MOTOR-10 (sobre
  todo `RTCDataChannel` transferible: sus 2 claves nuevas con `= &Clase::kKey`).

Para buscar arreglos de Chromium por fichero sin el checkout: `git fetch --filter=tree:0 --shallow-since=<fecha>
https://github.com/chromium/chromium refs/heads/main` (solo commits, ~1 min) para los mensajes, y los ficheros con
`raw.githubusercontent.com/chromium/chromium/<etiqueta>/<ruta>` para comparar versiones. `github.com` (web y API sin
credenciales) está bloqueado.

## 4. Riesgos abiertos (anotados, sin portar)

- a7c018806 (crbug 364917763; nunca se fusionó a una rama de release): posible confusión de tipos en la conversión
  JS→Wasm a tipos solo-nulos; **afecta a 1.11–1.12.2**, no confirmada, gravedad media-baja. Titín decidió no sacar
  1.12.3: lo cubre la 1.13 vía Sparkle.
- Igual que antes: las 1.4–1.6 (12.0–12.2) no llevan la M126-LTS; quedan superadas por Sparkle.
- No portados a propósito en FS.12: b94803ac920 y la conversión a `raw_ptr` (demasiado amplios para la 116).

## 5. Entorno y trampas de la `d8`

- El contenedor es efímero: `FlyWeb/scripts/v8-d8.sh` lo rehace todo desde GitHub y commondatastorage (googlesource y
  CIPD están bloqueados). Para no recompilar: `FLYWEB_D8_NO_BUILD=1 v8-d8.sh <carpeta> [brave-core]` y luego `ninja`.
- **Memoria: el contenedor tiene ~15 GB; `ninja -j32` se queda sin memoria.** Usar `-j8`, o `-j4` en los enlaces.
- En el árbol de la `d8`, quitar los ganchos de Brave: `BUILD.gn` importa `//brave/v8/sources.gni` y
  `src/codegen/compiler.cc` usa `BRAVE_COMPILER_GET_FUNCTION_FROM_EVAL`; si no, falla `build.ninja.stamp`.
- **Desde la 12.9**, `BUILD.gn` importa `//third_party/icu/config.gni`: basta un fichero mínimo con
  `icu_use_data_file = false` (si no, `gn gen` pide `copy_icudata`). Sin ICU no se prueba Intl.
- Regenerar parches: rama temporal con **solo** los commits de seguridad (nunca los de pruebas de la `d8`),
  `git diff --full-index` desde la revisión fijada, un `.patch` por fichero, nombre = ruta con `/` → `-`.
- `git am` puede fallar por falta de blobs para el 3-way en clones parciales: `git apply` y revisar a mano.
- `git worktree add` con ruta relativa la crea dentro del repo: rutas absolutas.
- `patch -F3` puede dejar un trozo en un sitio equivocado (comentarios, `switch`): revisar siempre con `git diff`.
- Para matar procesos, `ps` y `kill <PID>`; `pkill -f` con un patrón mató la shell.
- `d8` sin fichero espera en modo interactivo: `-e '' < /dev/null`.
- La `d8` compila con la libstdc++ del sistema: no ve los `#include` que faltan con la libc++ de Chromium (caso
  `<iomanip>`); eso lo encuentra LOCAL.
- **No preparar pruebas de concepto ni variantes de exploits**: un clasificador de seguridad paró dos veces ese
  trabajo. Validar con las pruebas de regresión de upstream, mjsunit y revisión de código.

## 6. SEGURIDAD-PORTES-18 (06-11): revisión del `crx_verifier` del porte B2 (156)

brave-core `nube/b2-porte-t11`, commit 426a296b (punta 507dc0d6). **Veredicto: OK con cambios (no bloquea).**

- (a) Brave fuera: no queda `kBravePublisherKeyHash` ni sus bytes (`93 74 d6 2a…`) en brave-core. Único camino:
  `found_publisher_key` (parche, tras `components/crx_file/crx_verifier.cc:215` de la 156) admite Google, la de
  prueba solo con `CRX3_WITH_TEST_PUBLISHER_PROOF`, y FlyWeb. Hallar la clave no basta: cada prueba se verifica
  contra el archivo (`ReadHashAndVerifyArchive`); comparación de `base::span` con tamaño, sin prefijos. Brave-core no
  rebaja `crx_format_requirement` (por defecto `CRX3_WITH_PUBLISHER_PROOF`, `update_client.h:324` de la 156).
  Ojo, de diseño (ya estaba): la clave de FlyWeb vale también como prueba de publicador para extensiones de la
  Web Store, no solo para componentes.
- (b) Los 32 bytes de `kFlyWebPublisherKeyHash` = `publicador_sha256` de `FlyWeb/servidor/componentes/claves-publicas.json`.
  La SPKI del publicador **no** está en el repo (solo su hash, de `generar-claves.sh`): no se puede recalcular aquí;
  se comprueba en bak con `openssl pkey -pubout -outform DER | sha256sum`.
- (c) El parche aplica limpio a la 156.0.8078.82 (blob `4ae922a8` = índice del parche). `kPublisherKeyHash` de Google
  igual en 128 y 156 (`61f7f2a6…6367cf`; en la 156 es `KeyHash`, `std::array`). Nada permisivo: solo añade un `||`.
- (d) **No se cumple**: `SetFlyWebPublisherKeyHashForTesting` y la copia escribible del hash se compilan también
  en producción (como en Brave). Cambio propuesto a COORDINACIÓN-30: con `OFFICIAL_BUILD` comparar contra el
  `constexpr` (solo lectura) y el setter a `NOTREACHED()`. En B5, comprobar con `nm` que el símbolo no está o no
  escribe.

## 7. SEGURIDAD-PORTES-18 (07-11): FS.41, B5 y A1–A4 de la build Mac del porte B2

Build: chromium `flynk-b1d` 33a1745949 + brave-core `nube/b2-porte-t11` f3f65b603 (Release oficial con PGO). Fila FS.41.

- **A1–A4 aplicadas** (revisadas contra la 156.0.8078.82): A1 `web_drag_dest_mac.mm` l.864–902; A2 `web_drag_source_mac.mm`
  con `_fileUTI`; A4 `media_switches.cc` l.2004–2011 y `audio_loopback_input_mac_impl.mm` l.571–577. **A3 distinta de lo
  propuesto:** en 10.14 abre el cuentagotas genérico (`eye_dropper::EyeDropperView`, como en la 116) en vez de nullptr. Vale
  (foco y gesto; la web solo recibe el píxel elegido), pero falta probarla a mano (ronda 2 de la 6,1).
- **otool (LOCAL-19):** ScreenCaptureKit, UniformTypeIdentifiers y AuthenticationServices, débiles en FlyWeb Framework; el
  resto no las enlaza. `is_official_build` true; `SetFlyWebPublisherKeyHashForTesting` no está (737f2e67 surte efecto).
- **External Extensions (57c54579d6): OK.** Ruta propia `/Library/Application Support/LaMosquita/FlyWeb/External Extensions`;
  se mantienen `ENSURE_PATH_CONTROLLED_BY_ADMIN` y `prompt_for_external_extensions`. Gravedad del hallazgo original: baja
  (la ruta era la global, protegida por root:admin).
- **DoH automático:** no es vulnerabilidad si el DNS del sistema es del mismo proveedor; MOTOR-41 encontró que el override
  «off» de la 2.7.0 quedó muerto en la 156 (`default_dns_over_https_config_source.cc`) y lo vuelve a apagar.
- **B5 no pasa** (prueba 3 por CDP): `joinAdInterestGroup`, `getInterestGroupAdAuctionData` y `protectedAudience` visibles; lo
  demás (Topics, Shared Storage, Attribution Reporting, Fenced Frames, FedCM/`IdentityCredential`, Private State Tokens),
  oculto. **Riesgo: solo superficie.** En la 156 no hay `content/browser/interest_group/` ni binder de `AdAuctionService`, y
  `navigator_auction.cc` son stubs que resuelven `undefined`: ni subasta, ni `updateURL`, ni k-anon.
- **Causa (clase de rotura «override muerto», como el DoH):** el generador de la 156 solo copia el `base::Feature` al flag de
  Blink si está habilitado o cuenta como «overridden»; `base_feature_status: "disabled"` sin override deja `status: "stable"`.
  Brave 1.98+ lo resuelve con `brave_base_feature_overridden` + parche de `features_generated.cc.tmpl` + `BASE_OVERRIDDEN_FEATURE`;
  FlyWeb solo cuenta como «overridden» lo de `OVERRIDE_FEATURE_DEFAULT_STATES` (`chromium_src/base/feature_list.cc:92–121`).
  Arreglo mínimo pedido a MOTOR-41: kAdInterestGroupAPI, kFledge, kFencedFramesRuntime, kParakeet, kPrerender2,
  kControlledFrame, kExtensionScriptTagging (y kUserMediaElement si se sigue a Brave) a DISABLED en ese override.
- **Pendiente:** el sha de MOTOR-41, repetir la prueba 3, A3 a mano y la lista de MOTOR-41 de overrides de `chromium_src`
  muertos (revisarla entera). Lección: tras un salto de base, comprobar en ejecución cada override, no solo que compile.
- **Overrides muertos de la 156 (lista de MOTOR-41), lectura de seguridad:**
  - `BraveBrowserMainPartsMac`: **grave, bloquea la publicación.** La 156 crea las MainParts en `ChromeBrowserMainParts::Create`
    (`chrome_browser_main.cc:779`), así que el `#define` de `chromium_src/.../chrome_content_browser_client.cc:15` no actúa: sin
    `registerWithSparkle` no hay actualizaciones automáticas (la 3.0.0 no recibiría parches) ni copia del perfil. Mover a
    `chromium_src/chrome/browser/chrome_browser_main.cc`; probar con un appcast de pruebas que Sparkle detecta solo, que lleva
    `SUPublicEDKey` y que rechaza un paquete sin firmar (`kUpdateFeedURL` acepta otra URL por línea de comandos).
  - `supported_types` (VP9/AV1 ocultos): media-baja, defensa en profundidad (libvpx-VP9 y dav1d vuelven a estar expuestos).
  - `TOOLBAR_CORNER_RADIUS`: sin lectura de seguridad.
- **07-11 tarde, cerrados** (LOCAL-19, 7,1 headless, d2fd3793c5): **B5** (todo undefined/false, también IA, HTMLPermissionElement,
  HTMLUserMediaElement y speculationrules; arreglo b857fad7aa con las 17 features en `OVERRIDE_FEATURE_DEFAULT_STATES`);
  **VP9/AV1** (WebCodecs y MSE false, true con el flag; 81a466871); **DoH** off, 0 en netlog (5a93b80b92); `check-overrides-o.py`
  vacío; Sparkle con una sola copia y `SUPublicEDKey`. Sparkle en BraveBrowserMainPartsMac: 1e490a6b1.
  **Siguen abiertos en la 6,1:** Sparkle con appcast de pruebas y paquete sin firmar (bloquea la 3.0.0) y A3 a mano. El browsertest
  `flyweb_privacy_sandbox_apis` queda como regresión, no bloquea.
- **07-11, FS.41 cerrada.** Sparkle en la 6,1 sobre d2fd3793c5: se registra solo, detecta la 99.0.0 de un appcast de pruebas
  y rechaza el paquete sin firmar («There is no EdDSA signature»). Ojo: en Sparkle 1.24 la firma se comprueba al instalar,
  no al descargar. A3: Esc → AbortError sin cuelgue. External Extensions: el negativo, en verde. Quedan para Titín, sin
  bloquear: el clic real de A3 (CDP no llega al selector nativo) y el positivo de External Extensions (necesita sudo).
- **Riesgo anotado:** Sparkle 1.24.3 ya no se mantiene (la rama 2.x es la viva y admite 10.13+). Valorar el paso a Sparkle 2
  en un nivel futuro: es lo que valida y aplica todos los parches. Revisarlo en cuanto salga un aviso de Sparkle.
- **Lección:** tras un salto de base, cada override de `chromium_src` y del json5 hay que comprobarlo **en ejecución**:
  compilar no dice nada (DoH, Sparkle, VP9/AV1 y Blink murieron sin un solo error). Guardas: `check-overrides-156.sh` y
  `check-overrides-o.sh`/`.py`.

## 8. SEGURIDAD-PORTES-18 → 19 (07-11-2026)

La -18 (`session_01MwmK2hd2TWsrKjZY9iJB8x`) hizo la revisión del `crx_verifier` (§6) y FS.41 (§7, cerrada). Lo útil que no
está arriba:

- **Fuentes sin checkout:** el Chromium de FlyWeb es público. Un fichero suelto de una rama se baja con
  `raw.githubusercontent.com/lamosquita-net/chromium/<sha de flynk-b1d>/<ruta>` y se compara con
  `raw.githubusercontent.com/chromium/chromium/<etiqueta>/<ruta>`. brave-core se lee con
  `git clone --filter=blob:none` anónimo, sin `add_repo`. Para comparar con Brave de verdad:
  `git clone --depth 1 --filter=blob:none --sparse https://github.com/brave/brave-core` y `git sparse-checkout set patches`
  (master va por la 158; las etiquetas de la 1.98 están sin comprobar).
- **Tras cada salto de base, sospechar de todo override:** en la 156 murieron, sin un solo error de compilación, el `#define`
  de MainParts (Sparkle), el renombrado de `supported_types`, el DoH y los `base_feature_status` del json5. Hay que comprobarlo
  en ejecución (`FlyWeb/tools/seguridad/sondeo-b5.sh`, CDP o netlog) y con `check-overrides-156.sh` y `check-overrides-o.*`.
  Esa guarda del json5 busca el `name` como mucho 3 líneas por encima en el parche: una entrada más larga se escapa.
- **Para que un flag de Blink se apague en FlyWeb, el `base::Feature` tiene que estar en `OVERRIDE_FEATURE_DEFAULT_STATES`**
  (`chromium_src/base/feature_list.cc:92–121`). Si es de `base_feature: "none"`, va con `EnableFeatureFromString(…, false)`
  en `BraveContentRendererClient`. Un nombre mal escrito en esa llamada solo da un DLOG.
- **Pendientes para Titín (no bloquean):** el clic real del cuentagotas (A3) y la prueba positiva de External Extensions
  (`/Library/Application Support/LaMosquita/FlyWeb/External Extensions`, con sudo).
- **Riesgos y propuestas abiertas:**
  - Sparkle 1.24.3 ya no se mantiene. Proponer el paso a 2.x (admite 10.13+); la firma EdDSA se comprueba al instalar.
  - `Versions/156.1.98.63` en la ruta del framework es la versión de Brave (cuestión de marca, para MOTOR o PUBLICACIÓN).
  - El browsertest `flyweb_privacy_sandbox_apis` tiene que entrar en la batería de cada nivel.
  - Copia del perfil «antes de 3.0»: la decide MOTOR o ARQUITECTURA (la 2.x no abre un perfil migrado a la 156).
- **Para la 3.0.1 (CVE posteriores a la 156.0.8078.90):** base de la 156 = Chrome/156.0.8078.90 (`/json/version`).
  `package.json` de brave-core (2f357ccc7e) fija el tag de chrome. Comparar contra la rama `chromium/8078`.

## 9. SEGURIDAD-PORTES-19 (`session_01MwmK2hrcXTzbQgJfQ2PL5U`, 07-11-2026): FS.42, la 3.0.1

Hecho:
- Inventario: `FlyWeb/docs/seguridad-3.0.1.md` (#861).
- Parches (#862):
  - `FlyWeb/seguridad/3.0.1/` en softmac: Chromium 61, ANGLE 12 y ffmpeg 3, como format-patch comprobados con `git am`;
  - brave-core `seg/3.0.1` 6415661d24: V8 b56fe9b, época 31 y `kCanvasDrawElement` apagada.
- Medida de noviembre: 74/87 = 85 % limpios.

Método que funcionó (sin checkout):
- Clon `--filter=blob:none` de `chromium/chromium` con los tags, más el fork (`git fetch` de `lamosquita-net/chromium` por sha).
- Worktree en 33a1745949 y `cherry-pick -x` de 3 vías: entra más que `git apply --check`.
- Para buscar el arreglo de un CVE: `git fetch --filter=tree:0 --shallow-since=<fecha> origin main` y buscar el crbug en `Bug:`/`Fixed:`.
- V8, Skia, ANGLE, Dawn y CrabbyAvif tienen espejo en GitHub. ffmpeg, en `chromium.googlesource.com/chromium/third_party/ffmpeg`.
- **PDFium no es accesible:** pdfium.googlesource da 403 y el espejo de GitHub es de 2025-11.

Trampas:
- **Un clon superficial esconde merges de la rama:** con `--depth=60` salían 31 de 34. Comprobar siempre `merge-base --is-ancestor` de la .90.
- Un `[M156]` que «choca» en el primero de la lista puede ser el borde del clon.
- `git log -- <ruta>` sobre un clon `tree:0` es lentísimo: buscar por mensaje.

**Estado al relevo (09-11, ~32 % de contexto):** todo lo de la 3.0.1 está entregado y en main (#861, #862, #864, #871, #880).

| Pieza | Dónde | Punta (ls-remote) |
|---|---|---|
| Chromium, 61 commits | fork `lamosquita-net/chromium` **`seg/3.0.1`** sobre `flynk-b1d` 33a1745949 (sin tocar); copia en `FlyWeb/seguridad/3.0.1/chromium/` | **c4b1caf806e2**, árbol 2723e1b371c |
| ANGLE 12, ffmpeg 3, PDFium 3 | `.patch` en `FlyWeb/seguridad/3.0.1/` (no tienen fork accesible) | árboles d094abc / fd96f28 / 98a993d818 |
| brave-core | `seg/3.0.1` (V8 b56fe9b, época 31, `kCanvasDrawElement` apagada) | **6415661d24** |
| brave-core, parser | `seg/3.0.1-parser`, encima de la anterior (21 commits para CVE-2026-121082) | **bee89ad8a6** |

- **Acceso:** Titín aprobó el 09-11 el `add_repo` de `lamosquita-net/chromium` (push) en esta sesión. La rama se sube desde un clon parcial (`--filter=blob:none`) con el remoto del fork, sin clonarlo entero.
- **Medida de noviembre:** 79/93 = 85 % limpios (`seguridad-3.0.1.md` §7).

Pendiente para la siguiente:
- **mjsunit de MOTOR-30** con tres V8: 3.0.0, `seg/3.0.1` y `seg/3.0.1-parser`.
  - Si la de parser no tiene caídas propias, la 3.0.1 sale de `seg/3.0.1-parser`.
  - Si las tiene, CVE-2026-121082 pasa a la 3.0.2 y LOCAL usa `seg/3.0.1`.
  - Lo decide COORDINACIÓN, ahora COORDINACIÓN-35 (`session_01MwmK2h9VVd6d8t4mGrtmzp`).
- **3.0.2:**
  - CVE-2026-121112 (Permissions, crbug 40063728): ningún commit de main lo cita;
  - volver a revisar la rama 8078 después de la .96, las notas de la 157 siguientes y KEV;
  - la medida de diciembre.
- **HiC:** si upstream lo pasa a `stable`, se aplica la regla 19 y hay que portar c8449108a0, bf298c5fc5, db4fe6fb90 y 63d3b40075.
- **Tras compilar LOCAL, comprobar en ejecución:**
  - que `drawElementImage` no existe, tampoco con experimental web platform features;
  - que la UA da 156.0.8078.96;
  - el formulario de contraseñas: 31e05381bd se portó a mano.

## 10. SEGURIDAD-PORTES-19 → 20 (09-11-2026, relevada al 43 %): encargo de la 3.0.2, sin empezar

COORDINACIÓN-35 (`session_01MwmK2h9VVd6d8t4mGrtmzp`) lo encargó el 09-11. Lo fijó Titín en DIRECTIVAS (#888, puntos 4 y 9 de la lista de la 3.x). Hay que preparar la **propuesta de tanda en `FlyWeb/docs/seguridad-3.0.2.md`**; no se porta nada que dependa del mjsunit. Contenido:
1. **Serie del parser** (`seg/3.0.1-parser` bee89ad8a6, §9 y `seguridad-3.0.1.md` §6). Depende del mjsunit de MOTOR-30 (tres V8). Con caídas propias hay que analizarlas; sin ellas, entra tal cual.
2. **CVE-2026-121112** (Permissions, crbug 40063728): ningún commit de main cita el número. Buscar en las notas de la 157 siguientes y en `git log --grep` por palabras de Permissions; el bug puede ser antiguo, con otro id interno.
3. **Apagar XSLT.** Antes hay que contar los CVE de libxslt y de `XSLTProcessor` de los últimos 24 meses (Chrome Releases, NVD y `third_party/libxslt` del fork).
   - En la 3.0.1 ya entró un UAF de libxslt (2ad9b7f5a8, sin CVE publicado).
   - Mecanismo: upstream lo está quitando (`XSLTProcessor` y XSLT del navegador detrás de una feature). Buscar el `base::Feature`/json5 de la 156 y apagarlo con `OVERRIDE_FEATURE_DEFAULT_STATES`, como `kCanvasDrawElement`, o con la política que tenga.
4. **CORS en Background Fetch: ya está en la 3.0.1.** ed790a1a8e («Enforce CORS in Background Fetch») y 4519f82a82 son los parches `0041` y `0042` de la serie de Chromium (CVE-2026-121107 y -121174). Comprobar con `FlyWeb/docs/novedades-motor.md` §6.3 si se pide algo más que eso; si no, hay que decírselo a COORDINACIÓN.
5. **BlockingFocusWithoutUserActivation** (§6.3 de `novedades-motor.md`): mirar si en la 156 es una feature de Blink y en qué estado está; encenderla, comprobando la compatibilidad con claude.ai.
6. **`flyweb_bundle_version_base = "198.63"`** (brave-core `build/config.gni`). Es de versión, no de seguridad, pero va en la misma 3.0.2.
7. Medida de diciembre: rama 8078 después de la .96, notas de la 157 siguientes y KEV.

Entorno útil (todo se pierde con el contenedor; se rehace en minutos con §9):
- un clon parcial de `chromium/chromium` con tags y main desde el 20-09;
- el remoto del fork `lamosquita-net/chromium` (`add_repo` con push ya aprobado por Titín en la -19; la -20 tendrá que pedirlo de nuevo);
- los espejos de V8, ANGLE, Dawn, CrabbyAvif y ffmpeg.

## 11. SEGURIDAD-PORTES-20 (`session_01MwmK2kRbhaWsL8yMfFgtD8`, 09-11-2026): FS.43, la 3.0.2

Entregada para compilar (`FlyWeb/docs/seguridad-3.0.2.md`): chromium `seg/3.0.2` 502e3c5b85 y brave-core `seg/3.0.2`
0d6a771f23. Titín aprobó en esta sesión el `add_repo` de brave-core y chromium (push).

Método nuevo, sin worktree ni checkout: `git merge-tree --write-tree --merge-base=C^ <base> C` + `commit-tree` (git 2.43)
hace el cherry-pick de 3 vías y solo baja los blobs necesarios. `git grep` y `read-tree` en un clon `blob:none` son lentísimos
(minutos): leer ficheros concretos con `git show`.

Pendiente para la siguiente:
- mjsunit del parser, ahora con la V8 15.6.75.51; si sale limpio, rebasar `seg/3.0.2` sobre `seg/3.0.1-parser`.
- 460ab884005 (GC, `length.cc`, X) y la nota de la **158 estable (17-11)**: 3.0.3 y medida de diciembre.
- CVE-2026-121112: revisar cuando se abra el crbug 40063728.
- Propuesta a Titín: WebUSB y Web Serial, como WebHID.
- Comprobaciones en ejecución de LOCAL: README de `FlyWeb/seguridad/3.0.2/` y las de §9 (UA ahora .98 en `chrome/VERSION`).

