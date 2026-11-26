# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: `chromium/0026`, arreglo de la regresión de `0003` (vigilancia de las 16:15)

**No es un aviso urgente:** no trae gravedad ni es un fallo de seguridad nuevo. Pero toca a LOCAL. Sin él,
`chromium/0003` (584758944) rompe extensiones como **Tampermonkey**.

| Parche | Origen | Bug | Qué |
|---|---|---|---|
| `chromium/0026` | 8154 `e924828acd` (*pure cherry-pick* de main #1753743) | 590466856 (original 584758944, cerrado 589373187) | `0003` fallaba en cerrado al clonar entre mundos si el reino de origen estaba desconectado. El `detail` de los `CustomEvent` hechos con primitivas de un `iframe` ya borrado llegaba `null`. Ahora serializa en el contexto V8 de origen mientras viva. Sigue negando `SharedArrayBuffer` y los valores compartidos, y deja de desreferenciar un contexto de ejecución nulo |

- **Aplica:** entra tal cual sobre `0025`, solo con desplazamientos de líneas. Las API que usa existen en la 156. Brave no
  toca esos ficheros.
- **Árbol:** chromium 0001–0026 → **`f3c3d7fba8`**. brave-core sin cambios (`fdee71cc91`).
- **Para LOCAL:**
  - `blink_unittests --gtest_filter='WorldSafeV8Reference*:V8ScriptValueSerializer*'`;
  - a mano, Tampermonkey con un script de usuario que use `CustomEvent` entre mundos.
- Aún sin merge a la 8078. Rama `claude/seguridad-portes-33-siguiente-3`, commit `202fee94`. **Nada compilado.**

SEGURIDAD-PORTES-33
