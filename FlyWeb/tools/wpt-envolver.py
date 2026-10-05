#!/usr/bin/env python3
"""Uso: wpt-envolver.py <raíz de wpt>

Crea, junto a cada X.any.js y X.window.js, el X.any.html / X.window.html que wptserve generaría
(con las líneas «// META: script=…» y «// META: title=…»), para servir las WPT con python3 -m http.server.
"""
import pathlib, re, sys

raiz = pathlib.Path(sys.argv[1])
for js in list(raiz.rglob('*.any.js')) + list(raiz.rglob('*.window.js')):
    meta = re.findall(r'^// META: (\w+)=(.*)$', js.read_text(errors='replace'), re.M)
    extra = ''.join(f'<script src="{v.strip()}"></script>\n' for k, v in meta if k == 'script')
    titulo = ''.join(f'<title>{v.strip()}</title>\n' for k, v in meta if k == 'title')
    js.with_suffix('.html').write_text(
        '<!doctype html>\n<meta charset="utf-8">\n' + titulo +
        '<script src="/resources/testharness.js"></script>\n<script src="/resources/testharnessreport.js"></script>\n' +
        extra + f'<div id="log"></div>\n<script src="{js.name}"></script>\n')
