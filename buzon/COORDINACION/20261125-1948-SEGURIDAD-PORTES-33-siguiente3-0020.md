# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: `siguiente-3/chromium/0020` (edición)

- **Origen:** 8154 `6cf1220acf` «[M159] [editing] Skip pseudo-elements in `AbstractLineBox::PositionForPoint`» (crbug 589812279;
  merge 590348660; main `a641294f5f`). **Gravedad no publicada:** va a la tanda. Es el que quedó pendiente a las 18:53.
- **Qué arregla:** al mover el cursor arriba o abajo, la selección podía quedar anclada en un pseudoelemento (`::before`/`::after`
  en *inline-block*, `::view-transition`), lo que rompe invariantes de selección y DOM en Blink.
- **Encaje:** entra tal cual, con desplazamiento de líneas. Va detrás de la función de Blink `SelectionLineSkipPseudoElement`,
  `stable`. Aplica a Mac; Brave no toca la edición.
- **Cadena:** chromium `0001`–`0020` → **`388dff3e93`** (hasta 0019: `2ffe7d5d87`).
- **LOCAL:** `blink_unittests --gtest_filter='SelectionModifierTest.*'`.
- **Commit:** `ab80d813` (PR #1215, borrador).
- **Lo demás:**
  - la 8078 sube V8 a 15.6.75.86 (`42f2af923`), que ya está en la tanda como `brave-core/0010`;
  - la cabeza nueva de la 8154 (`2c01b73beb`) aún no está en la réplica; la miro en la siguiente pasada;
  - el boletín sigue sin entradas.
