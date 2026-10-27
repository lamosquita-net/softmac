#!/usr/bin/env python3
# flags-escapes.py <dir-json5> <json5-flyweb> <raíz-softmac> : flags que Chrome tuvo en `stable` (Mac) en algún nivel y
# FlyWeb no tiene en `stable` (MOTOR-10, nivel 131, motor.md «Nivel 131» §6). <dir-json5> lleva un
# runtime_enabled_features.json5 por nivel con nombre <N>.json5 (`git show <cabeza de la rama N>:<ruta>`), del 117 en
# adelante; <json5-flyweb>, el de la 116 con los parches de brave-core (p. ej. el que monta gencss.sh). Salida TSV:
# flag, primer nivel en `stable`, qué pasa después, estado en FlyWeb ('-' = no está), y si algún documento la nombra.
# Ojo: muchas son falsos positivos (portes del estado final sin la flag); lo fiable es estado != '-' (flag apagada).
import glob, os, re, sys
import json5
def load(p):
    out = {}
    for f in json5.load(open(p))['data']:
        s = f.get('status', '')
        if isinstance(s, dict): s = s.get('Mac', s.get('default', ''))
        out[f['name']] = s
    return out
d, fwp, root = sys.argv[1:4]
fw = load(fwp)
lv = {int(os.path.basename(p).split('.')[0]): load(p) for p in glob.glob(d + '/*.json5')}
top = max(lv)
docs = ''.join(open(p, errors='ignore').read() for p in
               glob.glob(root + '/FlyWeb/docs/**/*.md', recursive=True) + glob.glob(root + '/docs/*.md') +
               glob.glob(root + '/FlyWeb/tools/port/*.tsv'))
names = set().union(*({n for n, s in v.items() if s == 'stable'} for v in lv.values()))
for n in sorted(names):
    if fw.get(n) == 'stable': continue
    first = min(v for v in lv if lv[v].get(n) == 'stable')
    last = max(v for v in lv if n in lv[v])
    after = ('quitada en %d' % (last + 1)) if last < top else ('stable en %d' % top if lv[top].get(n) == 'stable'
                                                                 else 'en %d: %s' % (top, lv[top].get(n) or 'none'))
    named = 'sí' if re.search(r'\b' + re.escape(n) + r'\b', docs) else 'no'
    print(n, first, after, fw.get(n, '-'), named, sep='\t')
