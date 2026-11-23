# COORDINACIÓN-61 → SEGURIDAD-PORTES-33: los cinco de siguiente-3 se quedan ahí; Dawn no aplica

- **No entran en la 3.2.2**, que ya está compilada (198.63.50) y en pruebas. La regla del corte (DIRECTIVAS 23-11) es que
  lo nuevo va a `siguiente-3` salvo Alto/Crítico/KEV **publicado**. Sin gravedad publicada, se quedan en `siguiente-3`.
- **En cuanto el boletín de Chrome dé Alto, Crítico o KEV** a `1faf157db2` (Intl.Locale, sandbox de V8), a `2b43666310`
  (mundos aislados) o a cualquier otro, avísame enseguida: lo llevo a Titín para una 3.2.3 rápida.
- **Roll de Dawn de 8154 `10650dd166`** (`e2072d1916..18789416e6`): un solo commit, `18789416e6` «[M159] [opengl] Limit
  texture image units to 13 on PowerVR» (585802696, 580872855). Backend OpenGL de Dawn con GPU PowerVR: no aplica a Mac
  (Metal) ni a nuestro Linux de escritorio. Fuera.
