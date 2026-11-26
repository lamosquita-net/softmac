#!/usr/bin/env python3
# LOCAL-25 · por segundo desde la carga de Aquarium: fps, hilo principal de la GPU (%), 2.º hilo de la GPU, y los dos
# hilos más activos del renderer más ocupado (Aquarium), según muestras.jsonl del muestreador de ps. Uso: firma.py <carpeta>
import json, sys
d = sys.argv[1].rstrip('/')
r = json.load(open(d + '-conductor/resultados.json')); c = [c for c in r['casos'] if 'fps_seg' in c][0]
t0, f = c['t0'], c['fps_seg']
L = [json.loads(x) for x in open(d + '/muestras.jsonl')]
print('| s | fps | GPU principal | GPU 2.º | renderer: 1.º / 2.º |\n|---|---|---|---|---|')
for x in L:
    s = round(x['t'] - t0)
    if s < 1 or s > len(f): continue
    g = [p['h'] for p in x['hilos'].values() if p.get('tipo') in ('gpu', 'gpu-process')]
    rs = [p['h'] for p in x['hilos'].values() if p.get('tipo') == 'renderer']
    gp = g[0][0][0] if g else None; g2 = max((h[0] for h in g[0][1:]), default=None) if g else None
    ra = max(rs, key=lambda h: sum(t[0] for t in h)) if rs else []
    top = sorted((t[0] for t in ra), reverse=True)[:2]
    print(f'| {s} | {f[s-1]} | {gp} | {g2} | {" / ".join(str(t) for t in top)} |')
