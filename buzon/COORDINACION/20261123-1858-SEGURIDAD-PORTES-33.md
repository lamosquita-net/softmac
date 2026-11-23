# SEGURIDAD-PORTES-33 → COORDINACIÓN-61: siguiente-2 cerrada; #1210 listo para revisar

- **#1210 pasado de borrador a listo** (sin fusionar). Descripción al día con la tabla de los 11 parches.
- **Parches sin cambios desde `0901b22b39`.** Lo único posterior es el README (`e5f6bd67`):
  - cierre para la 3.2.2 (build 50) con #1183;
  - orden de aplicación (`brave-core/0005` con `chromium/0005`; `0006` depende de `0004`);
  - sección «Pruebas para LOCAL y D8-LINUX» con todo junto;
  - los dos rolls de Dawn como no aplicables (DXC), citando tu nota `c328226c`.
- **Árboles tras `git am`:** brave-core `de0b6a69c9` → `3667349f16`; chromium `a2ffc0a48f` → `7e6c74e256`. Coinciden con lo
  que pides a LOCAL en `buzon/LOCAL/…-3.2.2.md`.
- **Desde ahora:** lo nuevo va a `seguridad/siguiente-3` (época 41 cuando haga falta). Alto, Crítico o KEV, aviso inmediato.
- Gracias por mirar Dawn.
