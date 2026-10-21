#!/usr/bin/env python3
# pchchk.py <lista.txt> : ficheros de la lista (montados en w-all: la 128 + los .patch de la rama) que usan, en líneas
# que no están ni en la 128 ni en la 131 (lo adaptado a mano), un símbolo (clase, enum, using, macro) definido solo en el
# cierre del PCH de Blink core en Mac (document.h + layout_object.h) y no en su propio cierre de includes. Heurístico: no
# ve cabeceras generadas ni funciones libres; salen falsos positivos con declaración adelantada (mirarlos). MOTOR-16.
import os, re, sys, subprocess, collections
W = '/tmp/claude-0/port/w-all'; CR = '/tmp/claude-0/port/cr128'; CH = '/home/user/chromium/hist'
ROOTS = [W, CR]
INC = re.compile(r'^\s*#\s*include\s+"([^"]+)"', re.M)
def res(p):
    for r in ROOTS:
        f = os.path.join(r, p)
        if os.path.isfile(f): return f
    return None
cache = {}
def direct(p):
    if p in cache: return cache[p]
    f = res(p); out = []
    if f:
        try: out = INC.findall(open(f, errors='ignore').read())
        except Exception: pass
    cache[p] = out; return out
def closure(roots):
    seen = set(); st = list(roots)
    while st:
        p = st.pop()
        if p in seen: continue
        seen.add(p); st.extend(direct(p))
    return seen
B = 'third_party/blink/renderer/'
PCH = closure([B + 'core/dom/document.h', B + 'core/layout/layout_object.h'])
unres = [p for p in PCH if not res(p)]
DEF = [re.compile(r'^\s*(?:template\s*<[^>]*>\s*)?(?:class|struct|union)\s+(?:\[\[[^\]]*\]\]\s*)?(?:[A-Z_]+_EXPORT\s+)?(?:GSL_\w+\s+)?(\w+)(?:\s+final)?\s*(?::[^;{]*)?\{', re.M),
       re.compile(r'^\s*enum\s+(?:class\s+)?(\w+)\s*(?::\s*[\w:]+\s*)?\{', re.M),
       re.compile(r'^\s*using\s+(\w+)\s*=', re.M),
       re.compile(r'^\s*#\s*define\s+(\w+)', re.M),
       re.compile(r'^\s*typedef\s+[^;]*?\b(\w+)\s*;', re.M)]
idx = collections.defaultdict(set)
for p in PCH:
    f = res(p)
    if not f: continue
    t = open(f, errors='ignore').read()
    for rx in DEF:
        for m in rx.finditer(t): idx[m.group(1)].add(p)
SKIP = {'Type', 'Value', 'Result', 'Iterator', 'State', 'Mode', 'Status', 'Data', 'Entry', 'Key', 'Options', 'Params',
        'Traits', 'Hash', 'Impl', 'Base', 'Callback', 'Kind', 'Flags', 'Observer', 'Client', 'Delegate', 'Info', 'Item',
        'Node', 'Element', 'Document', 'Visitor'}
ID = re.compile(r'\b([A-Za-z_]\w*)\b')
def base_text(p):
    f = os.path.join(CR, p)
    if os.path.isfile(f): return open(f, errors='ignore').read()
    r = subprocess.run(['git', '-C', CH, 'show', '128.0.6613.138:' + p], capture_output=True, text=True, errors='ignore')
    return r.stdout if r.returncode == 0 else ''
files = [l.strip() for l in open(sys.argv[1])] if len(sys.argv)>1 and sys.argv[1].endswith(".txt") else []
for p in files:
    if not p.startswith(B) or not re.search(r'\.(cc|h)$', p) or not os.path.isfile(os.path.join(W, p)): continue
    cur = open(os.path.join(W, p), errors='ignore').read()
    old = set(base_text(p).splitlines())
    r = subprocess.run(['git', '-C', CH, 'show', '131.0.6778.264:' + p], capture_output=True, text=True, errors='ignore')
    old |= set(r.stdout.splitlines()) if r.returncode == 0 else set()
    added = [l for l in cur.splitlines() if l not in old and not l.strip().startswith('//') and not l.strip().startswith('#include')]
    roots = [p]
    if p.endswith('.cc'): roots.append(p[:-3] + '.h')
    own = closure(roots)
    hits = collections.defaultdict(set)
    for l in added:
        for m in ID.finditer(l):
            s = m.group(1)
            if s in SKIP or s not in idx: continue
            if idx[s] & own: continue
            hits[s] |= idx[s]
    if 'visitor->Trace' in '\n'.join(added) or 'Visitor* visitor' in '\n'.join(added):
        if not any(x.endswith('platform/heap/visitor.h') for x in own): hits['<visitor.h>'].add('platform/heap/visitor.h')
    gen_unres = sum(1 for x in own if not res(x))
    for s, hs in sorted(hits.items()):
        print(f'{p[len(B):]}\t{s}\t{sorted(h[len(B):] if h.startswith(B) else h for h in hs)[:2]}\tgen_sin_resolver={gen_unres}')
print(f'# PCH: {len(PCH)} cabeceras, {len(unres)} sin resolver (generadas)', file=sys.stderr)
