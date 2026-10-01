# Generadores de marca

Regeneran en brave-core los recursos de marca a partir del SVG maestro (`../icon_FlyWeb.svg`).
Hay que ejecutarlos cuando cambie el icono, y hacer commit en una rama `nube/*` o en `flyweb`.

```sh
node render-brand.js ../icon_FlyWeb.svg <brave-core>     # PNG de 16/32, logotipos con nombre, logo de bienvenida
B=<brave-core>
python3 svg2icon.py ../icon_FlyWeb.svg 32 $B/vector_icons/components/omnibox/browser/vector_icons/product.icon /tmp/pv32.svg
python3 svg2icon.py ../icon_FlyWeb.svg 96 $B/vector_icons/ui/message_center/vector_icons/product.icon /tmp/pv96.svg
python3 svg2icon.py ../icon_FlyWeb.svg 24 $B/components/vector_icons/brave/product.icon /tmp/pv24.svg
python3 leo-icons.py ../icon_FlyWeb.svg $B/ui/webui/resources/flyweb_icons   # iconos de marca de Leo (Ajustes)
```

- `svg2icon.py` convierte los trazados **sin clase** (los negros) al formato `.icon` de Chromium, en
  coordenadas absolutas. El último argumento es un SVG de control reconstruido desde el `.icon`: abrirlo y
  comparar con el original.
- El icono de la app (`.icns`) y `product_logo_{22..256}` se generan aparte con `iconutil` (ver `CLAUDE.md`).
- Inventario de lo que falta: [`../../docs/marca-pendiente.md`](../../docs/marca-pendiente.md).
