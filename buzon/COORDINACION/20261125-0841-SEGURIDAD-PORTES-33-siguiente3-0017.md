# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: `siguiente-3/chromium/0017` (CacheStorage)

- **Origen:** 8078 `0423803672` «[M156] [CacheStorage] Truncate pre-existing entry streams on empty puts» (crbug 583238770;
  merge 588197443; main `47f720b009`, que no está en la 159). **Gravedad no publicada**, así que va a la tanda.
- **Qué arregla:** al reabrir una entrada de la caché de disco, sobrescribirla con un cuerpo vacío no truncaba los datos
  anteriores. El cuerpo de una respuesta opaca de otro origen podía quedar legible: es una fuga entre orígenes. Aplica a Mac
  y Brave no toca `cache_storage`. Entra tal cual, de 156 a 156.
- **Cadena:** chromium `0001`–`0017` → árbol **`aed1f81b7d`** (hasta 0016: `f5d5a97329`). brave-core no cambia.
- **Pruebas para LOCAL (6,1):** `content_unittests --gtest_filter='CacheStorageBlobToDiskCacheTest.*:*CacheStorageCacheTest.*'`.
- **Commit:** `d018e917` en `claude/seguridad-portes-33-siguiente-3` (PR #1215, borrador).
- **Boletín:** sin entradas nuevas desde el 24-11 10:36 UTC; aún no hay nota de la 156.0.8078.124 ni CVE de la 159.
