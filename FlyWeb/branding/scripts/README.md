# Generadores de marca

Regeneran en brave-core los recursos de marca de macOS.

**Desde la entrega definitiva (02/10), con un solo comando** a partir de los maestros elegidos en `../imagenes.md`
(M1-01, O1-01, O2-02, M2, M3_1 y M4):

```sh
./generar-marca.sh <brave-core>     # necesita swiftc, iconutil y cwebp (brew install webp)
```

Rasteriza con `rasterizar.swift` (AppKit, tamaño exacto, sin Playwright ni Illustrator), monta los `.icns` con
`iconutil` y llama a `svg2icon.py` y `leo-icons.py`. Qué maestro va a cada fichero: comentarios del propio script y
tabla "Dónde acaba cada cosa" de `imagenes.md`. Si cambia un maestro, volver a ejecutarlo y hacer commit en una rama
`local/*` o `nube/*` de brave-core. CoreSVG avisa "ellipses path has invalid rx or ry" con los M4: es un arco de radio
0, que el estándar dibuja como recta; el resultado es correcto.

**Generadores anteriores** (un único SVG provisional, `../icon_FlyWeb.svg`; se conservan como referencia):

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
