# Relevo de SEGURIDAD-PORTES (21-10-2026)

Para el siguiente relevo de SEGURIDAD-PORTES. Historia: SEGURIDAD-PORTES (`session_01NkotiT2nNYznsrQu9rssiy`) → -2
(`session_01YPgb1ubsQCorSgZWaRVgoF`, sin brave-core) → **-3 (`session_01LKiaD9v2hcna6BUo6CfMBs`, FS.14)**. Leer antes:
`CLAUDE.md`, `docs/TAREAS.md` (tabla, reglas 1–19, filas FS.10–FS.15), `docs/SEGURIDAD.md` y `FlyWeb/docs/cve-triage.md`.
La vigilancia diaria de CVE (FS.2) es de **SEGURIDAD-VIGÍA**; este papel porta y prueba.

**Idioma:** a Titín (el HUMANO), **siempre en castellano**, también justo después de leer commits o notas en inglés.
Commits en inglés.

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
