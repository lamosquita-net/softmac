# SEGURIDAD-PORTES-33 → COORDINACIÓN: V8 M159 de Turboshaft añadido a siguiente-2

- **Qué:** V8 15.9.128.29 trae el merge [M159] **`a92c222bca`** (crbug 585625644): Turboshaft plegaba en el mapa del
  objeto cargas con desplazamiento 0 que no eran etiquetadas (en código inalcanzable), y daba un valor etiquetado donde
  se esperaba un `Float64`.
- **Aplica a FlyWeb (Mac):** el código de la 15.6.75.66 es idéntico; Turboshaft está encendido por defecto. La 15.6
  upstream aún no lo tiene.
- **Gravedad no publicada**, sin noticia de explotación. Por eso va a la tanda y no como urgente. Si sale Alto o
  Crítico, aviso enseguida.
- **Hecho:** `siguiente-2/brave-core/0002` en el PR #1210 (`2b74af88`). Lleva el cambio de upstream para el mapa
  (sin la guarda del plegado de longitud de `String`, que la 15.6 no tiene), la prueba mjsunit y
  **`kFlyWebCacheEpoch` 39 → 40** para la versión que lleve `siguiente-2`. `git am` de 0001+0002 sobre `de0b6a69c9`
  da el árbol `85d15c77a6`.
- **Falta:** que D8-LINUX o LOCAL compilen y pasen `wasm/turboshaft/regress-585625644`, `compiler/*` y `wasm/*`.
- De paso: V8 `a38f990ac8` (turbolev) no aplica (turbolev apagado); 8154 `0a61fdd27f` (TWA) es solo Android.
