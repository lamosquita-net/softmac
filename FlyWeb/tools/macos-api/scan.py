#!/usr/bin/env python3
"""Por cada par de árboles (inicio del nivel N, inicio del N+1): guardas de macOS que desaparecen y usos nuevos de API
posteriores a 10.14 (lista de sdkapi.py). Uso: scan.py api.tsv sdk1014 TAG1 TAG2 ... (directorios con los árboles)."""
import os, re, sys, collections, json

api_tsv, sdk1014, trees = sys.argv[1], sys.argv[2], sys.argv[3:]

# nombres de métodos/propiedades que ya existían en 10.14 (ambiguos: no se pueden atribuir por grep)
old_sel = set()
for root, _, files in os.walk(sdk1014):
    for f in files:
        if f.endswith('.h'):
            try:
                t = open(os.path.join(root, f), errors='replace').read()
            except OSError:
                continue
            old_sel.update(re.findall(r'^[-+]\s*\([^)]*\)\s*(\w+)', t, re.M))
            old_sel.update(re.findall(r'@property[^;]*?\b(\w+)\s*(?:[A-Z_]+\(.*\))?\s*;', t))

FW_SKIP = {'UIKit', 'WatchKit', 'HealthKit', 'HomeKit', 'PassKit', 'Matter', 'libusd_ms.dylib', 'WebCore',
           'JavaScriptCore', 'libCommCenterBase.dylib', 'CarPlay', 'ARKit', 'RealityKit', 'SwiftUI'}
api = {}
for line in open(api_tsv):
    kind, name, ver, fw = line.rstrip('\n').split('\t')
    if fw in FW_SKIP:
        continue
    if kind in ('method', 'property'):
        n = name.rstrip(':')
        if n in old_sel or len(n) < 6:
            continue
        api.setdefault(n, (kind, ver, fw))
    elif kind in ('class', 'sym', 'enum'):
        if len(name) < 5:
            continue
        api.setdefault(name, (kind, ver, fw))

GUARD = re.compile(r'@available\(\s*macOS\s+(1[0-9](?:\.\d+)*)|__builtin_available\(\s*macOS\s+(1[0-9](?:\.\d+)*)'
                   r'|IsAtLeastOS(1[0-9])|IsAtMostOS(1[0-9])|IsOS(1[0-9])|MacOSMajorVersion\(\)\s*[<>=!]+\s*(1[0-9])'
                   r'|MacOSVersion\(\)\s*[<>=!]+\s*(1[0-9])|API_AVAILABLE\(\s*macos\(\s*(1[0-9](?:\.\d+)*)')
IDENT = re.compile(r'[A-Za-z_]\w{4,}')

def comp(path):
    p = path
    for pre, c in (('third_party/blink', 'Blink'), ('v8', 'V8'), ('net/', 'red'), ('services/network', 'red'),
                   ('gpu/', 'GPU'), ('ui/gl', 'GPU'), ('components/viz', 'GPU'), ('ui/accelerated_widget_mac', 'GPU'),
                   ('sandbox', 'sandbox'), ('base/', 'base'), ('ui/', 'ui'), ('chrome/browser/ui', 'ui-chrome'),
                   ('media/', 'media'), ('content/', 'content'), ('device/', 'device'), ('crypto/', 'crypto'),
                   ('components/', 'components'), ('chrome/', 'chrome'), ('remoting', 'remoting'), ('services/', 'services')):
        if p.startswith(pre):
            return c
    return 'otros'

def scan(tree):
    guards = collections.Counter()
    uses = collections.defaultdict(collections.Counter)
    for root, dirs, files in os.walk(tree):
        if '.git' in dirs:
            dirs.remove('.git')
        for f in files:
            if not f.endswith(('.mm', '.cc', '.h', '.m')):
                continue
            full = os.path.join(root, f)
            rel = os.path.relpath(full, tree)
            try:
                t = open(full, errors='replace').read()
            except OSError:
                continue
            for m in GUARD.finditer(t):
                v = next(g for g in m.groups() if g)
                guards[(rel, v.split('.')[0] if not v.startswith('10') else '.'.join(v.split('.')[:2]))] += 1
            t2 = re.sub(r'//[^\n]*', '', t)
            for name in IDENT.findall(t2):
                if name in api:
                    uses[rel][name] += 1
    return guards, uses

res = {}
for tr in trees:
    res[tr] = scan(tr)
    print('scanned', tr, file=sys.stderr)

out = []
for a, b in zip(trees, trees[1:]):
    ga, ua = res[a]
    gb, ub = res[b]
    lvl = os.path.basename(a).split('.')[0]
    for k in sorted(set(ga) | set(gb)):
        if ga[k] != gb[k]:
            out.append(dict(level=lvl, type='guard', file=k[0], ver=k[1], before=ga[k], after=gb[k], comp=comp(k[0])))
    for f in sorted(set(ua) | set(ub)):
        for name in set(ua.get(f, {})) | set(ub.get(f, {})):
            x, y = ua.get(f, {}).get(name, 0), ub.get(f, {}).get(name, 0)
            if y > x:
                kind, ver, fw = api[name]
                out.append(dict(level=lvl, type='use', file=f, name=name, kind=kind, ver=ver, fw=fw,
                                before=x, after=y, comp=comp(f)))
# usos totales en el primer árbol (lo que ya trae nuestra base)
g0, u0 = res[trees[0]]
base = [dict(file=f, name=n, cnt=c, **dict(zip(('kind', 'ver', 'fw'), api[n]))) for f in u0 for n, c in u0[f].items()]
json.dump(dict(diff=out, base=base), sys.stdout, indent=0)
