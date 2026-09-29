#!/usr/bin/env python3
"""Convert the black paths of the FlyWeb SVG to a Chromium .icon file.

Everything is emitted in absolute coordinates (MOVE_TO, LINE_TO, CUBIC_TO,
ARC_TO, CLOSE) because .icon has no relative cubic shorthand. Also writes a
preview SVG rebuilt from the emitted commands, to check the conversion.
"""
import re
import sys

src, canvas, out, preview = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
svg = open(src).read()
vb = float(re.search(r'viewBox="0 0 ([\d.]+) ', svg).group(1))
k = canvas / vb
ds = [re.search(r'd="([^"]+)"', a).group(1)
      for a in re.findall(r'<path([^>]*)/>', svg) if 'class=' not in a]

NUM = re.compile(r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')


def tokens(d):
    i = 0
    while i < len(d):
        c = d[i]
        if c.isalpha():
            yield c
            i += 1
        elif c in ' ,\n\t':
            i += 1
        else:
            m = NUM.match(d, i)
            yield float(m.group(0))
            i = m.end()


def parse(d):
    toks = list(tokens(d))
    out, i, cmd = [], 0, None
    x = y = sx = sy = 0.0
    last_c2 = None

    def take(n):
        nonlocal i
        v = toks[i:i + n]
        i += n
        return v

    def take_arc():
        # Arc flags can be packed without separators in some SVGs; here they
        # are separated, so plain numbers work.
        return take(7)

    while i < len(toks):
        if isinstance(toks[i], str):
            cmd = toks[i]
            i += 1
            if cmd in 'Zz':
                out.append(('CLOSE',))
                x, y = sx, sy
                last_c2 = None
                continue
        rel = cmd.islower()
        C = cmd.upper()
        ox, oy = (x, y) if rel else (0.0, 0.0)
        if C == 'M':
            px, py = take(2)
            x, y = ox + px, oy + py
            sx, sy = x, y
            out.append(('MOVE_TO', x, y))
            cmd = 'l' if rel else 'L'
            last_c2 = None
        elif C == 'L':
            px, py = take(2)
            x, y = ox + px, oy + py
            out.append(('LINE_TO', x, y))
            last_c2 = None
        elif C == 'H':
            (px,) = take(1)
            x = ox + px
            out.append(('LINE_TO', x, y))
            last_c2 = None
        elif C == 'V':
            (py,) = take(1)
            y = oy + py
            out.append(('LINE_TO', x, y))
            last_c2 = None
        elif C == 'C':
            a = take(6)
            c1 = (ox + a[0], oy + a[1])
            c2 = (ox + a[2], oy + a[3])
            x, y = ox + a[4], oy + a[5]
            out.append(('CUBIC_TO', *c1, *c2, x, y))
            last_c2 = c2
        elif C == 'S':
            a = take(4)
            c1 = (2 * x - last_c2[0], 2 * y - last_c2[1]) if last_c2 else (x, y)
            c2 = (ox + a[0], oy + a[1])
            x, y = ox + a[2], oy + a[3]
            out.append(('CUBIC_TO', *c1, *c2, x, y))
            last_c2 = c2
        elif C == 'A':
            rx, ry, rot, large, sweep, px, py = take_arc()
            x, y = ox + px, oy + py
            out.append(('ARC_TO', rx, ry, rot, int(large), int(sweep), x, y))
            last_c2 = None
        else:
            raise SystemExit('unsupported command ' + cmd)
    return out


def f(v):
    s = ('%.2f' % v).rstrip('0').rstrip('.')
    if s in ('-0', ''):
        s = '0'
    return s if s.lstrip('-').isdigit() else s + 'f'


lines = [
    '// Copyright (c) 2026 lamosquita. All rights reserved.',
    '// This Source Code Form is subject to the terms of the Mozilla Public',
    '// License, v. 2.0. If a copy of the MPL was not distributed with this file,',
    '// You can obtain one at https://mozilla.org/MPL/2.0/.',
    '',
    '// FlyWeb: generated from softmac FlyWeb/branding/icon_FlyWeb.svg.',
    '',
    'CANVAS_DIMENSIONS, %d,' % canvas,
]
pv = []
for n, d in enumerate(ds):
    if n:
        lines.append('NEW_PATH,')
    pd = ''
    for c in parse(d):
        name, args = c[0], list(c[1:])
        if name == 'ARC_TO':
            args = [args[0] * k, args[1] * k, args[2], args[3], args[4],
                    args[5] * k, args[6] * k]
            txt = [f(args[0]), f(args[1]), f(args[2]), str(args[3]),
                   str(args[4]), f(args[5]), f(args[6])]
        else:
            args = [a * k for a in args]
            txt = [f(a) for a in args]
        lines.append(', '.join([name] + txt) + ',')
        letter = {'MOVE_TO': 'M', 'LINE_TO': 'L', 'CUBIC_TO': 'C',
                  'ARC_TO': 'A', 'CLOSE': 'Z'}[name]
        pd += letter + ' '.join(t.rstrip('f') for t in txt) + ' '
    pv.append('<path d="%s"/>' % pd)
open(out, 'w').write('\n'.join(lines) + '\n')
open(preview, 'w').write(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d">%s</svg>'
    % (canvas, canvas, ''.join(pv)))
print(out, len(lines), 'lines')
