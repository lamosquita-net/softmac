#!/usr/bin/env python3
# flags-nivel.py <crN-1> <crN> [<cr116>] : flags de Blink (runtime_enabled_features.json5) que cambian entre dos
# niveles (MOTOR-8, nivel 129). Salida TSV: tipo (A_STABLE = pasa a stable, NEW = nueva, CHANGE, REMOVED), nombre,
# estado antes, estado después y, con cr116, el estado en la 116. Necesita `pip install json5`.
import json5, sys
F = 'third_party/blink/renderer/platform/runtime_enabled_features.json5'
def load(d):
    return {f['name']: f for f in json5.load(open(d + '/' + F, encoding='utf-8'))['data']}
def st(f):
    s = f.get('status')
    return s if isinstance(s, str) else ('dict:' + str(s)) if s else 'none'
a, b = load(sys.argv[1]), load(sys.argv[2])
c = load(sys.argv[3]) if len(sys.argv) > 3 else {}
rows = []
for n, f in b.items():
    if n not in a:
        rows.append(('NEW', n, '-', st(f)))
    elif st(a[n]) != st(f):
        rows.append(('A_STABLE' if st(f) == 'stable' else 'CHANGE', n, st(a[n]), st(f)))
rows += [('REMOVED', n, st(f), '-') for n, f in a.items() if n not in b]
for r in sorted(rows):
    print('\t'.join(r + (('en116:' + (st(c[r[1]]) if r[1] in c else 'no'),) if c else ())))
