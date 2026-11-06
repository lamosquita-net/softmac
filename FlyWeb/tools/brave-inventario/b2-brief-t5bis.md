# Brief común T5-bis (MOTOR-35): porte de brave-core de FlyWeb a Chromium 156

Contexto: FlyWeb es un fork de Brave (brave-core 1.69.168 sobre Chromium 128, más cambios propios de FlyWeb: marca,
`flyweb://`, poda de Wallet/Rewards/Ads/P3A/Tor/Sidebar/Playlist…). Lo estamos portando a **Chromium 156.0.8078.90**.
No hay checkout de Chromium ni se compila: se edita "en papel" con los ficheros de Chromium 156 bajados uno a uno.
Decisión de fondo (Titín, 05-11): lo descartado de Brave se BORRA sin paliativos; solo quedan mejoras de privacidad
(Shields, sync propio, políticas) y una capa de interfaz mínima. Lo que Chromium 156 ya trae nativo se queda nativo.

## Repos y herramientas
- Tu worktree: `/home/user/wt/<G>` (rama local indicada en tu encargo). Trabaja SOLO ahí. No hagas push; no toques
  otros worktrees ni `/home/user/brave-core`.
- Etiquetas locales: `v1.69.168` (lo heredado de Brave) y `v1.98.63` (**donante**: Brave ya portado a 156.0.8078.80).
  Usa `git show v1.98.63:<ruta>`, `git diff HEAD v1.98.63 -- <ruta>`, `git diff v1.69.168 HEAD -- <ruta>` (= cambios de
  FlyWeb y del porte; consérvalos). Los blobs se bajan bajo demanda: **NO uses `git grep` sobre las etiquetas** (no
  termina); usa `git ls-tree -r --name-only v1.98.63 <dir>` y `git show`.
- `export PATH=/home/user/softmac/FlyWeb/tools/brave-inventario:$PATH`:
  - `b2-cr156 <ruta>`: baja el fichero de Chromium 156.0.8078.90 y escribe su ruta local (sale con `NO_EXISTE_EN_156`).
  - `b2-mkpatch <ruta-chromium> <fichero-modificado> > patches/<nombre>.patch` (ruta con `/`→`-`).
  - `b2-chkpatch <ruta-absoluta-del-.patch>`: `git apply --check` contra 156 (APLICA / NO_APLICA).
  - `python3 -I b2-chk.py <worktree> | sort`: includes `brave/...` y etiquetas `//brave/...` rotas.

## Método (obligatorio)
1. Para quitar una función: borra sus ficheros y TODAS sus referencias (BUILD.gn/sources.gni, includes, prefs,
   comandos, ids de color/icono, flags de about_flags, chromium_src y parches que solo existen para ella, tests).
   Si un parche de Chromium mezcla esa función con otras cosas, regenera el parche (b2-cr156 + b2-mkpatch) sin ella
   y compruébalo con b2-chkpatch. No dejes código muerto (#if de una flag que ya no existe, ganchos vacíos).
2. Para portar: del donante se toma el cambio de la causa; un fichero de 1.98 entero solo si FlyWeb no lo tocó
   (`git diff v1.69.168 HEAD -- <f>` vacío o solo renombres del porte). Parches de Chromium: reanclar a tres vías
   (nuestro parche de 128, la intención de FlyWeb, el fichero de 156) usando el parche de 1.98 como guía.
3. No arrastres funciones nuevas de Brave 1.98 ni referencias `//brave/...` que no existen en nuestro árbol.
4. En chromium_src se usa `-iquote`, no `-I`. Flags de `runtime_enabled_features.json5`: comprueba que existen en 156.
5. Comprobación final: `python3 -I b2-chk.py /home/user/wt/<G> | sort > /tmp/chk-<G>.txt` y
   `comm -13 <tu-scratchpad>/chk-base.txt (salida de b2-chk en la punta de partida) /tmp/chk-<G>.txt`
   debe salir VACÍO; sin marcadores de conflicto, sin `}` sueltos ni líneas en blanco dobles; `.py` con py_compile.
6. Commits por causa, en inglés, asunto `[b2-porte-t5-bis] <qué>`, cuerpo breve y al final exactamente:
   `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`
   `Claude-Session: https://claude.ai/code/session_01MwmK2jBqgc4rNEXcQwzpbr`
   con `git -c user.name=Claude -c user.email=noreply@anthropic.com commit ...`
7. Sin datos personales. No toques ficheros fuera de tu encargo salvo que sea imprescindible (dilo en el informe).

## Al terminar
`git -C /home/user/wt/<G> rebase nube/b2-porte-t5-bis` (puede haber avanzado; resuelve tú los conflictos). Informe
final breve en español (≤ 40 líneas): commits (sha y asunto); qué quitaste/portaste y qué quedó a medias y por qué;
funciones perdidas (para las notas de la 3.0.0); ficheros fuera de tu encargo tocados; dudas.
