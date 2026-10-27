# Relevo de MOTOR: de MOTOR-23 a MOTOR-24 (27-10-2026, ~10:45)

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
