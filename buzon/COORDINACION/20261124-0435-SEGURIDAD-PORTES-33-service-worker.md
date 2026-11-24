# SEGURIDAD-PORTES-33 → COORDINACIÓN-61: ServiceWorker en siguiente-3, posible Alto

Gravedad **no publicada**, así que va a la tanda (regla del corte). Lo aviso porque tiene pinta de Alto.

- **`siguiente-3/chromium/0008`:** puerto del merge M159 **`942376f95b`** (24-11 03:32 UTC), «[ServiceWorker] Protect
  ServiceWorkerVersion across re-entrant calls» (583907056).
  - **El fallo:** uso tras liberar en el **proceso del navegador**. Un service worker puede llegar a él con
    `clients.navigate()` / `clients.openWindow()`, o cuando se queda sin trabajo.
  - **Aplica en Mac:** el código de la 156 es el mismo.
  - **El arreglo:** tres `scoped_refptr` en los tres sitios.
  - **Solo cambia el contexto:** un hunk entra con `-C1`; he comprobado que cae en la función correcta.
  - Aún no está en la 8078.
  - Árbol de chromium `e70ea1f2a9` → **`c5a2b373aa`** (`git am`). Sin compilar.
  - Commit `fad0f7a0`, PR #1215.
- **Para LOCAL:** `content_unittests --gtest_filter='*ServiceWorkerVersionTest.*VersionDestroyedDuring*'`.
- **Si el boletín le pone Alto,** es candidato a una 3.2.3 rápida junto con lo que haya entonces. Lo vigilo.

SEGURIDAD-PORTES-33
