#!/usr/bin/env python3
# LOCAL-25 · vídeo (a): diferencia lento − recuperado por función (inclusiva, solo pilas activas) para un hilo del proceso GPU.
import sys, os, re, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DSYM', os.path.expanduser('~/proyectos/b2-porte-mac/src/out/Release-322/FlyWeb Framework.dSYM/Contents/Resources/DWARF/FlyWeb Framework'))
import analizar_sample as A
def carga(fn):
    out = {}
    for h in (A.simbolizar(hs := A.leer(fn)) or hs):
        n = h['nombre']; n = 'CrGpuMain' if n in ('com.apple.main-thread',) else n
        cs = A.caminos(h); inc = collections.Counter(); hoja = collections.Counter(); act = 0
        for s, c in cs:
            if A.ESPERA.match(c[-1]['f']): continue
            act += s
            for f in {A.corto(x['f']) for x in c}: inc[f] += s
            hoja[A.corto(c[-1]['f'])] += s
        if n not in out: out[n] = {'total': h['total'], 'act': act, 'inc': inc, 'hoja': hoja}
    return out
L, R = carga(sys.argv[1]), carga(sys.argv[2])
for h in sys.argv[3:]:
    l, r = L[h], R[h]
    print(f"\n## {h}: lento {l['act']}/{l['total']} activas ({100*l['act']/l['total']:.0f} %), recuperado {r['act']}/{r['total']} ({100*r['act']/r['total']:.0f} %)")
    for tit, k in (('inclusivas', 'inc'), ('propias (hoja)', 'hoja')):
        print(f'\n### {tit}: más en el tramo lento (muestras de 1 ms; recuperado escalado a la misma duración)\n')
        esc = l['total'] / r['total']
        d = {f: l[k][f] - r[k].get(f, 0) * esc for f in l[k]}
        for f, v in sorted(d.items(), key=lambda x: -x[1])[:30]:
            print(f"| {l[k][f]:5d} | {r[k].get(f,0)*esc:7.0f} | {v:+6.0f} | {f[:160]} |")
