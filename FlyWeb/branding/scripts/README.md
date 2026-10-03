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

**Alternativa de NUBE (sin integrar en `flyweb`, rama `nube/iconos-entrega`):**

**Desde la entrega del HUMANO (02/10):** `generar-entrega.js` sustituye a `render-brand.js` y a `leo-icons.py`. Saca
cada recurso de su maestro elegido (M1-01, O1-01, M2, M3_1, M4, O2-02) y a su tamaño exacto:

```sh
B=<brave-core>
ICNS_TMP=/tmp/flyweb-icns node generar-entrega.js $B        # PNG de brave-core y PNG para los .icns
for c in "" beta/ dev/ nightly/; do python3 icns.py $B/app/theme/brave/mac/${c}app.icns $(for s in 16 32 64 128 256 512 1024; do printf "%s=/tmp/flyweb-icns/M1-%s.png " $s $s; done); done
python3 icns.py $B/app/theme/brave/mac/development/app.icns $(for s in 16 32 64 128 256 512 1024; do printf "%s=/tmp/flyweb-icns/O1-%s.png " $s $s; done)
python3 icns.py $B/app/theme/brave/mac/document.icns $(for s in 16 32 64 128 256 512 1024; do printf "%s=/tmp/flyweb-icns/O2-%s.png " $s $s; done)
python3 svg2icon.py ../M3_1.svg 32 $B/vector_icons/components/omnibox/browser/vector_icons/product.icon /tmp/pv32.svg
python3 svg2icon.py ../M3_1.svg 96 $B/vector_icons/ui/message_center/vector_icons/product.icon /tmp/pv96.svg
python3 svg2icon.py ../M3_1.svg 24 $B/components/vector_icons/brave/product.icon /tmp/pv24.svg
cp ../M2.svg $B/ui/webui/resources/flyweb_icons/product-brave-color.svg
cp ../M3_1.svg $B/ui/webui/resources/flyweb_icons/product-brave-monochrome.svg
```

- `icns.py` crea el `.icns` con fragmentos PNG, válidos desde 10.7, sin `iconutil`.
- Comprobación en el Mac: `iconutil -c iconset app.icns` debe sacar los diez tamaños.

Siguen con el dibujo provisional la bienvenida (M8) y el botón de Shields (M6): no se han entregado.

## Antes de la entrega (provisional)

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
