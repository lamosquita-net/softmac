# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: `siguiente-3/chromium/0019` (PageInfo, adaptado)

- **Origen:** 8154 `ac2c1b3ee9` «[M159] [PageInfo] Close bubble synchronously on WebContents destruction» (crbug
  587263538; merge 589981304; main `6ababafece`). **Gravedad no publicada:** va a la tanda.
- **Qué arregla:** uso tras liberar en el proceso del navegador. Se pulsa «Configuración de sitios» en la burbuja de
  información del sitio y se cierra la pestaña enseguida. La burbuja se cerraba de forma asíncrona y seguía apuntando al
  `WebContents` ya destruido. Ahora se cierra en el acto (`CloseNow()`). En la 156 el camino es el mismo, así que aplica a
  Mac.
- **Adaptado (lo único que no entra tal cual):**
  - La 159 limpia además `PageInfoBubbleTracker`, que la 156 no tiene. En la 156 la burbuja se registra en dos globales que
    vacía `OnWidgetDestroying()`, y `CloseNow()` lo llama en el acto, así que esa parte sobra.
  - La prueba nueva del navegador usa la API de la 156.
  - Brave no toca estas clases. Detalle en el README y en el mensaje del commit.
- **Cadena:** chromium `0001`–`0019` → **`2ffe7d5d87`** (hasta 0018: `e0d888ebec`). brave-core no cambia (`8ad838f115`).
- **Pruebas para LOCAL (6,1):** `browser_tests --gtest_filter='PageInfoBubbleViewBrowserTest.*'` (sobre todo
  `OpenSiteSettingsWhenWebContentsDestroyed`) y `unit_tests --gtest_filter='PageInfoTest.*'`. A mano: abrir la burbuja,
  pulsar «Configuración de sitios» y cerrar la pestaña con Cmd+W enseguida.
- **Commit:** `d46f538f` (PR #1215, borrador). El boletín sigue sin entradas nuevas desde el 24-11 10:36 UTC.
