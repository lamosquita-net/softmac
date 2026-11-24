# LOCAL-25 · cruce por segundo de M3: fps (rAF), % de GPU (ioreg), CPU del hilo principal del renderer y de CrGpuMain.
# Aparta los segundos de cada sample (fecha del fichero = fin de la toma; ventana [fin-6, fin+1]).
import json, os, sys, glob, statistics as st
etq = sys.argv[1]
ms = []
for l in open(f'{etq}/muestras.jsonl'):
    try: ms.append(json.loads(l))
    except Exception: pass
casos = json.load(open(f'{etq}-conductor/resultados.json'))['casos']
tomas = [os.stat(f).st_mtime for f in glob.glob(f'{etq}/sample-rend-p*.txt')]
def en_toma(t): return any(f - 6 <= t <= f + 1 for f in tomas)
def principal(m, tipo):
    best = None
    for p, h in m['hilos'].items():
        if h['tipo'] == tipo and h.get('h'):
            if best is None or h['h'][0][0] > best[0]: best = (h['h'][0][0], p)
    return best
filas = []
for i, c in enumerate(casos, 1):
    raf = c.get('raf') or {}; fs = raf.get('muestras') or []
    t0 = c['t0']
    for k, f in enumerate(fs):
        t = t0 + k + 1
        m = min(ms, key=lambda x: abs(x['t'] - t))
        if abs(m['t'] - t) > 1: continue
        r = principal(m, 'renderer'); g = principal(m, 'gpu-process')
        gpu = max((m.get('gpu') or {}).values() or [0])
        filas.append(dict(p=i, s=k + 1, fps=f, toma=en_toma(t), gpu=gpu, r=r[0] if r else None, g=g[0] if g else None, vram=m.get('vram')))
def resumen(sel, nombre):
    sel = [x for x in sel if x['r'] is not None and x['g'] is not None and x['fps'] > 0]
    if not sel: return
    fps = st.median(x['fps'] for x in sel)
    rms = st.median(x['r'] * 10 / x['fps'] for x in sel); gms = st.median(x['g'] * 10 / x['fps'] for x in sel)
    print(f"  {nombre:<34} {len(sel):>4} s  fps {fps:5.1f}  GPU {st.median(x['gpu'] for x in sel):4.0f} %  "
          f"renderer {st.median(x['r'] for x in sel):4.0f} % = {rms:5.1f} ms/f  CrGpuMain {st.median(x['g'] for x in sel):4.0f} % = {gms:5.1f} ms/f")
fuera = [x for x in filas if not x['toma']]
print(f'{etq}: {len(filas)} s con fps; {sum(x["toma"] for x in filas)} s apartados por las tomas')
for p in sorted({x['p'] for x in filas}):
    resumen([x for x in fuera if x['p'] == p], f'pasada {p} (sin toma)')
resumen([x for x in fuera if x['fps'] < 50], 'TODOS los s lentos (< 50 fps)')
resumen([x for x in fuera if x['fps'] >= 55], 'TODOS los s rápidos (≥ 55 fps)')
# tramos lentos justo después de una toma
for x in filas:
    if not x['toma'] and x['fps'] < 50 and any(0 < (casos[x['p']-1]['t0'] + x['s']) - f <= 5 for f in tomas):
        print(f"  lento tras toma: pasada {x['p']} s {x['s']} {x['fps']} fps")
