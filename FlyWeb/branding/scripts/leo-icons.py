#!/usr/bin/env python3
"""Genera los iconos de marca para el paquete de diseño de Brave (Leo) desde el SVG maestro.

Uso: python3 leo-icons.py ../icon_FlyWeb.svg <brave-core>/ui/webui/resources/flyweb_icons

- product-brave-monochrome.svg: solo los trazados sin clase (la silueta negra). Leo lo usa como
  máscara y lo pinta con currentColor (tipo B de imagenes.md).
- product-brave-color.svg: el maestro entero sobre una placa gris claro, para que el cuerpo negro y
  las alas blancas se vean en modo claro y oscuro (tipo A). Leo lo muestra como imagen.
PROVISIONAL hasta el diseño definitivo (M2/M3).
"""
import os
import re
import sys

src, out = sys.argv[1], sys.argv[2]
svg = open(src, encoding='utf-8').read()
view_box = re.search(r'viewBox="([^"]+)"', svg).group(1)
_, _, w, h = (float(v) for v in view_box.split())
style = re.search(r'<style>(.*?)</style>', svg, re.S).group(1)
paths = re.findall(r'<path\b[^>]*/>', svg)
black = [p for p in paths if 'class=' not in p]
head = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view_box}">'
os.makedirs(out, exist_ok=True)

with open(os.path.join(out, 'product-brave-monochrome.svg'), 'w', encoding='utf-8') as f:
    f.write(head + ''.join(black) + '</svg>\n')

plate = f'<circle cx="{w / 2:g}" cy="{h / 2:g}" r="{min(w, h) / 2:g}" fill="#dadce0"/>'
with open(os.path.join(out, 'product-brave-color.svg'), 'w', encoding='utf-8') as f:
    f.write(head + f'<defs><style>{style}</style></defs>' + plate + ''.join(paths) + '</svg>\n')
print(out)
