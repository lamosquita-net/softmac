#!/usr/bin/env python3
# Copyright (c) 2026 lamosquita.net. MIT license (softmac root).
"""PNG con alfa → XPM (icono de 32 del instalador de Linux, product_logo_32.xpm).

XPM solo tiene transparencia binaria: alfa < 128 → «None»; el resto se compone sobre blanco. Necesita Pillow.
Uso: python3 -I png2xpm.py <entrada.png> <salida.xpm>
"""
import string
import sys

from PIL import Image

src, dst = sys.argv[1], sys.argv[2]
im = Image.open(src).convert("RGBA")
w, h = im.size
pix = []
datos = im.tobytes()
for i in range(0, len(datos), 4):
    r, g, b, a = datos[i:i + 4]
    if a < 128:
        pix.append(None)
    else:
        f = a / 255
        pix.append("#%02X%02X%02X" % tuple(round(c * f + 255 * (1 - f)) for c in (r, g, b)))
colores = sorted({p for p in pix if p}) + ([None] if None in pix else [])
abc = string.ascii_letters + string.digits + ".#+@$%&*=-;>,')!~{]^/(_:<[}|`"
cpp = 1 if len(colores) <= len(abc) else 2
claves = [abc[i] if cpp == 1 else abc[i // len(abc)] + abc[i % len(abc)] for i in range(len(colores))]
cod = dict(zip(colores, claves))
lineas = ['"%d %d %d %d",' % (w, h, len(colores), cpp)]
lineas += ['"%s c %s",' % (cod[c], c or "None") for c in colores]
filas = ["".join(cod[p] for p in pix[y * w:(y + 1) * w]) for y in range(h)]
lineas += ['"%s",' % f for f in filas[:-1]] + ['"%s"' % filas[-1]]
with open(dst, "w") as f:
    f.write("/* XPM */\nstatic char *product_logo_32[] = {\n" + "\n".join(lineas) + "\n};\n")
