# Brief común T0 (porte de brave-core de FlyWeb a Chromium 156)

Contexto: FlyWeb es un fork de Brave (brave-core 1.69.168 sobre Chromium 128, más cambios propios de FlyWeb: marca,
`flyweb://`, poda de Wallet/Rewards/Ads/P3A/Tor/etc.). Lo estamos portando a **Chromium 156.0.8078.90**. No hay
checkout de Chromium ni se compila: se edita en papel con los ficheros de Chromium 156 bajados uno a uno.
Una medida real (MOTOR-30, en Ubuntu) aplicó a mano unos "arreglos de medida" (lista 3, `/tmp/claude-0/lista3.tsv`,
columnas fichero / qué). Tu trabajo es rehacer **bien**, dentro de brave-core, las entradas de tu grupo, para que
la próxima medida no necesite ningún arreglo a mano. Objetivo final de toda la tanda: `gn gen --check` limpio y
`apply_patches` sin fallos en los ficheros de la lista 3.

## Repos y herramientas
- Tu worktree: `/home/user/wt/<G>` (rama local `t0-<G>`, sobre `nube/b2-porte-t0` = 4127545c). Trabaja SOLO ahí.
  No hagas push; no toques otros worktrees ni `/home/user/brave-core`.
- Etiquetas locales: `v1.69.168` (lo que heredamos de Brave) y `v1.98.63` (**donante**: Brave ya portado a
  Chromium 156.0.8078.80). Todos los blobs están locales: `git show v1.98.63:<ruta>`, `git diff v1.69.168 v1.98.63 -- <ruta>`,
  `git diff v1.69.168 HEAD -- <ruta>` (= cambios propios de FlyWeb; hay que conservarlos).
- Herramientas (añade al PATH: `export PATH=<ruta de FlyWeb/tools/brave-inventario>:$PATH`):
  - `b2-cr156 <ruta>`: baja (con caché en /tmp/claude-0/cr156) el fichero de Chromium 156.0.8078.90 y escribe su ruta
    local. `v8/...` va al repo de v8 de esa versión. Si no existe en 156, sale con error `NO_EXISTE_EN_156`.
  - `b2-mkpatch <ruta-chromium> <fichero-modificado> > patches/<nombre>.patch`: parche al estilo de Brave
    (`git diff --full-index`) del original de 156 al modificado. Nombre: ruta con `/` → `-` (p. ej.
    `chrome/browser/BUILD.gn` → `patches/chrome-browser-BUILD.gn.patch`); `v8/BUILD.gn` → `patches/v8/BUILD.gn.patch`.
  - `b2-chkpatch <ruta-absoluta-del-.patch>`: `git apply --check` contra 156 (APLICA / NO_APLICA).
  - Chromium 156 cualquier fichero: `https://raw.githubusercontent.com/chromium/chromium/156.0.8078.90/<ruta>`;
    listar directorio: `https://api.github.com/repos/chromium/chromium/contents/<dir>?ref=156.0.8078.90`
    (o `b2-cr156` del BUILD.gn del directorio).

## Método (obligatorio)
1. Del donante se toma **el cambio de la causa**, no el fichero entero: no arrastres funciones nuevas de Brave 1.98
   ni referencias a objetivos `//brave/...` que no existen en nuestro árbol (compruébalo con `ls`/`grep` en tu
   worktree). Conserva las ediciones de FlyWeb (`git diff v1.69.168 HEAD -- <fichero>`).
2. Para un parche de Chromium: parte del fichero de 156 (`b2-cr156`), aplica a mano lo que hacía nuestro parche actual
   (semántica de 1.69 + FlyWeb), usando el parche de 1.98.63 como guía de dónde anclarlo en 156; genera con
   `b2-mkpatch` y verifica con `b2-chkpatch`. Quita del parche lo que 156 ya trae (backports) y lo que apunta a
   directorios podados.
3. No borres una línea de Brave "porque falla": busca qué hizo el donante (objetivo movido/renombrado en 156) y
   síguelo. Si el objetivo de Chromium desapareció sin sustituto, quita la línea y anótalo.
4. Ningún "arreglo de medida" (comentar líneas para seguir, `testonly` quitado a mano en Chromium, etc.) sin que
   quede como cambio de verdad en brave-core (parche o fichero de Brave).
5. Comprobación estática al final: rutas `//brave/...` y `#include "brave/..."` que añadas existen; no hay
   marcadores de conflicto, `}` sueltos ni líneas en blanco dobles; para `.py` `python3 -m py_compile`.
6. Commits por causa, en inglés, asunto `[b2-porte-t0] <qué>`, con estas dos líneas al final del mensaje:
   `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` y
   `Claude-Session: https://claude.ai/code/session_01MwmK2gqciFCPCBxxQQaRW8`.
   `git -c user.name="Claude" -c user.email="noreply@anthropic.com" commit ...`
7. Sin datos personales. No toques ficheros fuera de tu grupo salvo que sea imprescindible (dilo en el informe).
   No toques `FlyWeb/scripts/build.sh` (no está en este repo de todos modos) ni nada de T1–T9 (código C++ de Brave
   que rompe por API de 156: eso es lista 1, otra tanda), salvo lo que tu grupo nombra.

## Al terminar
Antes de responder: `git -C /home/user/wt/<G> rebase nube/b2-porte-t0` (puede haber avanzado con otros grupos;
resuelve conflictos tú, que conoces tus cambios). Informe final (breve, en español, ≤ 40 líneas): commits (sha y
asunto), por cada entrada de la lista 3 de tu grupo: **bien hecha** / **parcial** / **no hecha** y por qué; qué
dejas dudoso; ficheros fuera de tu grupo tocados; cuántos ficheros de la lista 1 (`/tmp/claude-0/lista1.tsv`) crees
que deberían caer por tu cambio (si alguno).
