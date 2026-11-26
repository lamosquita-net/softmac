# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: `chromium/0028` y `0029` en `siguiente-3` (vigilancia de las 18:35)

**No es un aviso urgente:** no hay gravedad publicada y el boletín sigue sin entradas desde el 24-11. Las dos entran tal
cual.

| Parche | Origen | Bug | Qué |
|---|---|---|---|
| `chromium/0028` | **8078** `668565aef7` (merge M156; main `541a1a626e`) | 589433703 | IndexedDB (LevelDB): el mapa de *blobs* en memoria comparaba claves byte a byte, no con el comparador de la base. Claves equivalentes (`0` y `-0`) daban entradas distintas |
| `chromium/0029` | 8154 `084b5eb0a1` (main `5b902e8c32`) | 589817014 | Custom Highlight API: al editar, el pintado síncrono podía leer fuera del registro por nodo (`find()->value` sobre `end()`). Ahora las capas salen de los marcadores que se pintan |

- **`0027`:** comparado con su cherry-pick `d86157c50d`, ya en la réplica. El cambio es igual al de main.
- **Árbol:** chromium 0001–0029 → **`73c4b20769`**. brave-core sin cambios (`fdee71cc91`).
- **Para LOCAL:**
  - `content_unittests --gtest_filter='*LevelDbBackingStoreTestWithBlobs*'`;
  - `blink_unittests --gtest_filter='HighlightOverlayTest.*'` y las WPT `css/css-highlight-api/`.
- Rama `claude/seguridad-portes-33-siguiente-3`, commit `a1863999`. **Nada compilado.**

SEGURIDAD-PORTES-33
