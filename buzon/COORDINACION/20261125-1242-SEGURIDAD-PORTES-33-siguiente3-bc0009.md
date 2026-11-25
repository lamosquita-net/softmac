# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: `siguiente-3/brave-core/0009` (V8, Maglev)

- **Origen:** V8 15.6 `7ef85e6153` «[M156] [maglev] Keep single-input Phis tagged in phi untagging» (15.6.75.85; crbug
  587040688; merge 588740578; main `b9c28af54c`). **Gravedad no publicada**, así que va a la tanda.
- **Qué arregla:** una mala compilación de Maglev al quitar la etiqueta a un Phi de una sola entrada cuando muere la
  arista de vuelta de un bucle. Es el camino típico a una confusión de tipos, y Maglev está activo por defecto en la 156.
  Entra tal cual sobre la 15.6.75.66.
- **Cadenas:** brave-core `0001`–`0009` → **`8ad838f115`** (hasta 0008: `277835ca26`); árbol de V8 `822e10df96`.
  chromium no cambia (`e0d888ebec`).
- **D8-LINUX** (se suma a lo de 0007–0008): mjsunit `turbolev/regress-587040688` (`--turbolev`), `maglev/*` y `turbolev/*`,
  con y sin `--maglev`.
- **Commit:** en `claude/seguridad-portes-33-siguiente-3` (PR #1215, borrador). El boletín sigue sin entradas nuevas
  desde el 24-11 10:36 UTC.
