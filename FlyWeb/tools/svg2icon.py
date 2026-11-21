#!/usr/bin/env python3
# Copyright (c) 2026 lamosquita.net. MIT license (softmac root).
"""Convierte un SVG de un solo color (iconos de Titín) al formato .icon de Chromium.

Uso:
  svg2icon.py ico-atras.svg --rejilla 20 [--escala 2.2642] [--espejo]
              [--flips-in-rtl] [-o arrow_back.icon] [--png vista.png]

- Solo usa la biblioteca estándar (y PIL para --png).
- Elementos: path (M L H V C S Q T A Z, absolutos y relativos), polygon, rect
  (con rx) y circle. Sin transform: los SVG de Titín no los llevan.
- Escala común (dip por unidad del SVG) para conservar las proporciones entre
  iconos que Titín dibujó en Illustrator. Por defecto, 12 dip para el ancho de
  ico-atras.svg (5,3 unidades), como la flecha de atrás de Chromium en la
  rejilla de 20. El icono se centra en el lienzo (CANVAS_DIMENSIONS = rejilla).
- --espejo refleja en horizontal (adelante = atrás en espejo).
- Regla de relleno: no nula (FILL_RULE_NONZERO), la de SVG por defecto.
"""

import argparse
import math
import re
import sys
import xml.etree.ElementTree as ET

ESCALA_POR_DEFECTO = 12.0 / 5.3

_NUM = re.compile(r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')
_TOKEN = re.compile(r'[MmLlHhVvCcSsQqTtAaZz]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')
_PARAMS = {'M': 2, 'L': 2, 'H': 1, 'V': 1, 'C': 6, 'S': 4, 'Q': 4, 'T': 2,
           'A': 7, 'Z': 0}


def _tokens_path(d):
    # Los indicadores de arco pueden ir pegados ("0 011.2"): se separan al leer.
    pos = 0
    out = []
    while pos < len(d):
        m = re.compile(r'[\s,]*').match(d, pos)
        pos = m.end()
        if pos >= len(d):
            break
        if d[pos] in 'MmLlHhVvCcSsQqTtAaZz':
            out.append(d[pos])
            pos += 1
            continue
        m = _NUM.match(d, pos)
        if not m:
            raise ValueError('path: no se entiende %r' % d[pos:pos + 20])
        out.append(m.group(0))
        pos = m.end()
    return out


def parse_path(d):
    """Devuelve subtrayectos con segmentos absolutos:
    ('M', x, y) ('L', x, y) ('C', x1, y1, x2, y2, x, y)
    ('A', rx, ry, rot, large, sweep, x, y) ('Z',)."""
    toks = _tokens_path(d)
    segs = []
    i = 0
    cmd = None
    cx = cy = sx = sy = 0.0
    last_ctrl = None  # último punto de control (para S y T)
    last_cmd = None
    while i < len(toks):
        t = toks[i]
        if t in 'MmLlHhVvCcSsQqTtAaZz':
            cmd = t
            i += 1
            if cmd in 'Zz':
                segs.append(('Z',))
                cx, cy = sx, sy
                last_ctrl, last_cmd = None, 'Z'
                continue
        elif cmd is None:
            raise ValueError('path sin orden inicial')
        n = _PARAMS[cmd.upper()]
        if cmd in 'Aa':
            # Arco: los dos indicadores pueden venir pegados al número siguiente.
            vals = []
            while len(vals) < 7:
                tok = toks[i]
                # Un indicador es "0" o "1"; si viene pegado al número
                # siguiente ("01.5" = 0, 1, .5), se toma solo el primer dígito.
                if len(vals) in (3, 4) and len(tok) > 1 and tok[0] in '01':
                    vals.append(float(tok[0]))
                    toks[i] = tok[1:]
                    continue
                vals.append(float(tok))
                i += 1
        else:
            vals = [float(v) for v in toks[i:i + n]]
            i += n
        rel = cmd.islower()
        up = cmd.upper()
        ox, oy = (cx, cy) if rel else (0.0, 0.0)
        if up == 'M':
            cx, cy = ox + vals[0], oy + vals[1]
            sx, sy = cx, cy
            segs.append(('M', cx, cy))
            cmd = 'l' if rel else 'L'  # pares siguientes = líneas
            last_ctrl = None
        elif up == 'L':
            cx, cy = ox + vals[0], oy + vals[1]
            segs.append(('L', cx, cy))
            last_ctrl = None
        elif up == 'H':
            cx = (cx if rel else 0.0) + vals[0]
            segs.append(('L', cx, cy))
            last_ctrl = None
        elif up == 'V':
            cy = (cy if rel else 0.0) + vals[0]
            segs.append(('L', cx, cy))
            last_ctrl = None
        elif up == 'C':
            x1, y1, x2, y2, x, y = vals
            x1, y1, x2, y2, x, y = ox + x1, oy + y1, ox + x2, oy + y2, ox + x, oy + y
            segs.append(('C', x1, y1, x2, y2, x, y))
            last_ctrl = (x2, y2)
            cx, cy = x, y
        elif up == 'S':
            x2, y2, x, y = vals
            x2, y2, x, y = ox + x2, oy + y2, ox + x, oy + y
            if last_ctrl and last_cmd in 'CcSs':
                x1, y1 = 2 * cx - last_ctrl[0], 2 * cy - last_ctrl[1]
            else:
                x1, y1 = cx, cy
            segs.append(('C', x1, y1, x2, y2, x, y))
            last_ctrl = (x2, y2)
            cx, cy = x, y
        elif up in 'QT':
            if up == 'Q':
                qx, qy, x, y = vals
                qx, qy, x, y = ox + qx, oy + qy, ox + x, oy + y
            else:
                x, y = ox + vals[0], oy + vals[1]
                if last_ctrl and last_cmd in 'QqTt':
                    qx, qy = 2 * cx - last_ctrl[0], 2 * cy - last_ctrl[1]
                else:
                    qx, qy = cx, cy
            # Cuadrática como cúbica.
            segs.append(('C', cx + 2 / 3 * (qx - cx), cy + 2 / 3 * (qy - cy),
                         x + 2 / 3 * (qx - x), y + 2 / 3 * (qy - y), x, y))
            last_ctrl = (qx, qy)
            cx, cy = x, y
        elif up == 'A':
            rx, ry, rot, large, sweep, x, y = vals
            x, y = ox + x, oy + y
            segs.append(('A', abs(rx), abs(ry), rot, int(large), int(sweep), x, y))
            cx, cy = x, y
            last_ctrl = None
        last_cmd = cmd
    return segs


def _floats(s):
    return [float(v) for v in _NUM.findall(s)]


def read_svg(path):
    """Devuelve (ancho, alto, figuras); figura = ('path', segs) |
    ('circle', cx, cy, r) | ('rrect', x, y, w, h, r)."""
    root = ET.parse(path).getroot()
    vb = _floats(root.get('viewBox', ''))
    if len(vb) != 4:
        raise ValueError('%s: falta viewBox' % path)
    minx, miny, w, h = vb
    figs = []
    for el in root.iter():
        tag = el.tag.split('}')[-1]
        if el.get('transform'):
            raise ValueError('%s: transform no admitido' % path)
        if tag == 'path':
            figs.append(('path', parse_path(el.get('d'))))
        elif tag == 'polygon':
            pts = _floats(el.get('points'))
            segs = [('M', pts[0], pts[1])]
            segs += [('L', pts[k], pts[k + 1]) for k in range(2, len(pts), 2)]
            segs.append(('Z',))
            figs.append(('path', segs))
        elif tag == 'circle':
            figs.append(('circle', float(el.get('cx', 0)), float(el.get('cy', 0)),
                         float(el.get('r'))))
        elif tag == 'rect':
            rx = el.get('rx') or el.get('ry') or '0'
            figs.append(('rrect', float(el.get('x', 0)), float(el.get('y', 0)),
                         float(el.get('width')), float(el.get('height')), float(rx)))
    # Coordenadas relativas al origen del viewBox.
    out = []
    for f in figs:
        if f[0] == 'path':
            segs = []
            for s in f[1]:
                if s[0] in 'ML':
                    segs.append((s[0], s[1] - minx, s[2] - miny))
                elif s[0] == 'C':
                    segs.append(('C', s[1] - minx, s[2] - miny, s[3] - minx,
                                 s[4] - miny, s[5] - minx, s[6] - miny))
                elif s[0] == 'A':
                    segs.append(('A',) + s[1:6] + (s[6] - minx, s[7] - miny))
                else:
                    segs.append(s)
            out.append(('path', segs))
        elif f[0] == 'circle':
            out.append(('circle', f[1] - minx, f[2] - miny, f[3]))
        else:
            out.append(('rrect', f[1] - minx, f[2] - miny) + f[3:])
    return w, h, out


def transform(w, h, figs, escala, rejilla, espejo):
    """Escala, centra en el lienzo y, si se pide, refleja en horizontal."""
    ox = (rejilla - w * escala) / 2.0
    oy = (rejilla - h * escala) / 2.0

    def X(x):
        return ox + escala * ((w - x) if espejo else x)

    def Y(y):
        return oy + escala * y

    out = []
    for f in figs:
        if f[0] == 'path':
            segs = []
            for s in f[1]:
                if s[0] in 'ML':
                    segs.append((s[0], X(s[1]), Y(s[2])))
                elif s[0] == 'C':
                    segs.append(('C', X(s[1]), Y(s[2]), X(s[3]), Y(s[4]),
                                 X(s[5]), Y(s[6])))
                elif s[0] == 'A':
                    _, rx, ry, rot, large, sweep, x, y = s
                    if espejo:
                        rot, sweep = -rot, 1 - sweep
                    segs.append(('A', rx * escala, ry * escala, rot, large, sweep,
                                 X(x), Y(y)))
                else:
                    segs.append(s)
            out.append(('path', segs))
        elif f[0] == 'circle':
            out.append(('circle', X(f[1]), Y(f[2]), f[3] * escala))
        else:
            _, x, y, rw, rh, r = f
            left = X(x + rw) if espejo else X(x)
            out.append(('rrect', left, Y(y), rw * escala, rh * escala, r * escala))
    return out


def _n(v):
    v = round(v, 2)
    if v == int(v):
        return str(int(v))
    return ('%.2f' % v).rstrip('0').rstrip('.') + 'f'


def to_icon(figs, rejilla, flips_in_rtl, origen):
    lines = ['// This Source Code Form is subject to the terms of the Mozilla Public',
             '// License, v. 2.0. If a copy of the MPL was not distributed with this file,',
             '// You can obtain one at http://mozilla.org/MPL/2.0/.',
             '',
             '// Generado con softmac FlyWeb/tools/svg2icon.py desde %s.' % origen,
             '// No editar a mano: regenerar desde el SVG de Titín.',
             '',
             'CANVAS_DIMENSIONS, %d,' % rejilla]
    if flips_in_rtl:
        lines.append('FLIPS_IN_RTL,')
    first = True
    for f in figs:
        if not first:
            lines.append('NEW_PATH,')
        first = False
        lines.append('FILL_RULE_NONZERO,')
        if f[0] == 'path':
            for s in f[1]:
                if s[0] == 'M':
                    lines.append('MOVE_TO, %s, %s,' % (_n(s[1]), _n(s[2])))
                elif s[0] == 'L':
                    lines.append('LINE_TO, %s, %s,' % (_n(s[1]), _n(s[2])))
                elif s[0] == 'C':
                    lines.append('CUBIC_TO, ' + ', '.join(_n(v) for v in s[1:]) + ',')
                elif s[0] == 'A':
                    _, rx, ry, rot, large, sweep, x, y = s
                    lines.append('ARC_TO, %s, %s, %s, %d, %d, %s, %s,' % (
                        _n(rx), _n(ry), _n(rot), large, sweep, _n(x), _n(y)))
                else:
                    lines.append('CLOSE,')
        elif f[0] == 'circle':
            lines.append('CIRCLE, %s, %s, %s,' % (_n(f[1]), _n(f[2]), _n(f[3])))
        else:
            lines.append('ROUND_RECT, ' + ', '.join(_n(v) for v in f[1:]) + ',')
    return '\n'.join(lines) + '\n'


# --- Vista previa (PIL): aplana curvas y arcos y rellena con regla no nula. ---

def _arc_points(x1, y1, rx, ry, rot, large, sweep, x2, y2, n=24):
    # Conversión de arco SVG (endpoint) a centro (SVG 1.1, apéndice F.6).
    if rx == 0 or ry == 0:
        return [(x2, y2)]
    phi = math.radians(rot)
    cp, sp = math.cos(phi), math.sin(phi)
    dx, dy = (x1 - x2) / 2, (y1 - y2) / 2
    x1p, y1p = cp * dx + sp * dy, -sp * dx + cp * dy
    lam = (x1p ** 2) / rx ** 2 + (y1p ** 2) / ry ** 2
    if lam > 1:
        rx, ry = rx * math.sqrt(lam), ry * math.sqrt(lam)
    num = rx ** 2 * ry ** 2 - rx ** 2 * y1p ** 2 - ry ** 2 * x1p ** 2
    den = rx ** 2 * y1p ** 2 + ry ** 2 * x1p ** 2
    co = math.sqrt(max(num / den, 0)) if den else 0
    if large == sweep:
        co = -co
    cxp, cyp = co * rx * y1p / ry, -co * ry * x1p / rx
    cx = cp * cxp - sp * cyp + (x1 + x2) / 2
    cy = sp * cxp + cp * cyp + (y1 + y2) / 2

    def ang(ux, uy, vx, vy):
        a = math.atan2(ux * vy - uy * vx, ux * vx + uy * vy)
        return a

    t1 = ang(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
    dt = ang((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
    if not sweep and dt > 0:
        dt -= 2 * math.pi
    elif sweep and dt < 0:
        dt += 2 * math.pi
    pts = []
    for k in range(1, n + 1):
        t = t1 + dt * k / n
        pts.append((cx + rx * math.cos(t) * cp - ry * math.sin(t) * sp,
                    cy + rx * math.cos(t) * sp + ry * math.sin(t) * cp))
    return pts


def _polys(figs):
    polys = []
    for f in figs:
        if f[0] == 'circle':
            cx, cy, r = f[1:]
            polys.append([(cx + r * math.cos(2 * math.pi * k / 48),
                           cy + r * math.sin(2 * math.pi * k / 48)) for k in range(48)])
            continue
        if f[0] == 'rrect':
            x, y, w, h, r = f[1:]
            r = min(r, w / 2, h / 2)
            pts = []
            for (ccx, ccy, a0) in ((x + w - r, y + r, -90), (x + w - r, y + h - r, 0),
                                   (x + r, y + h - r, 90), (x + r, y + r, 180)):
                for k in range(7):
                    a = math.radians(a0 + 15 * k)
                    pts.append((ccx + r * math.cos(a), ccy + r * math.sin(a)))
            polys.append(pts)
            continue
        cur = []
        px = py = 0.0
        for s in f[1]:
            if s[0] == 'M':
                if len(cur) > 2:
                    polys.append(cur)
                cur = [(s[1], s[2])]
                px, py = s[1], s[2]
            elif s[0] == 'L':
                cur.append((s[1], s[2]))
                px, py = s[1], s[2]
            elif s[0] == 'C':
                x1, y1, x2, y2, x, y = s[1:]
                for k in range(1, 17):
                    t = k / 16
                    mt = 1 - t
                    cur.append((mt ** 3 * px + 3 * mt * mt * t * x1 + 3 * mt * t * t * x2 + t ** 3 * x,
                                mt ** 3 * py + 3 * mt * mt * t * y1 + 3 * mt * t * t * y2 + t ** 3 * y))
                px, py = x, y
            elif s[0] == 'A':
                cur += _arc_points(px, py, *s[1:])
                px, py = s[6], s[7]
            elif s[0] == 'Z':
                if len(cur) > 2:
                    polys.append(cur)
                cur = [(cur[0][0], cur[0][1])] if cur else []
                if cur:
                    px, py = cur[0]
        if len(cur) > 2:
            polys.append(cur)
    return polys


def preview_png(figs, rejilla, out, pixeles=160):
    from PIL import Image
    s = pixeles / rejilla
    polys = [[(x * s, y * s) for x, y in p] for p in _polys(figs)]
    img = Image.new('L', (pixeles, pixeles), 255)
    px = img.load()
    for j in range(pixeles):
        y = j + 0.5
        for i in range(pixeles):
            x = i + 0.5
            wn = 0
            for p in polys:
                for k in range(len(p)):
                    x1, y1 = p[k]
                    x2, y2 = p[(k + 1) % len(p)]
                    if y1 <= y < y2 and (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1) > 0:
                        wn += 1
                    elif y2 <= y < y1 and (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1) < 0:
                        wn -= 1
            if wn:
                px[i, j] = 0
    # Rejilla de 1 dip en gris claro, para ver el encaje.
    for k in range(rejilla + 1):
        c = min(int(k * s), pixeles - 1)
        for t in range(pixeles):
            if px[c, t] == 255:
                px[c, t] = 225
            if px[t, c] == 255:
                px[t, c] = 225
    img.save(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('svg')
    ap.add_argument('--rejilla', type=int, required=True,
                    help='lienzo en dip (CANVAS_DIMENSIONS): 20 o 16')
    ap.add_argument('--escala', type=float, default=ESCALA_POR_DEFECTO,
                    help='dip por unidad del SVG (por defecto %.4f)' % ESCALA_POR_DEFECTO)
    ap.add_argument('--espejo', action='store_true')
    ap.add_argument('--flips-in-rtl', action='store_true')
    ap.add_argument('-o', '--salida')
    ap.add_argument('--png', help='vista previa en PNG')
    a = ap.parse_args()

    w, h, figs = read_svg(a.svg)
    if max(w, h) * a.escala > a.rejilla:
        sys.exit('%s: %.2f x %.2f dip no cabe en la rejilla de %d' % (
            a.svg, w * a.escala, h * a.escala, a.rejilla))
    figs = transform(w, h, figs, a.escala, a.rejilla, a.espejo)
    origen = a.svg.split('/')[-1] + (' (espejo)' if a.espejo else '')
    texto = to_icon(figs, a.rejilla, a.flips_in_rtl, origen)
    if a.salida:
        with open(a.salida, 'w') as f:
            f.write(texto)
    else:
        sys.stdout.write(texto)
    if a.png:
        preview_png(figs, a.rejilla, a.png)


if __name__ == '__main__':
    main()
