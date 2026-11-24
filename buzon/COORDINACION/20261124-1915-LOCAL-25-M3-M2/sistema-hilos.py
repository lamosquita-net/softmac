# LOCAL-25 · proporción de tiempo de sistema por hilo (ps -M de muestreo61.py: [%CPU, estado, PRI, sistema s, usuario s]).
import json, sys
def carga(etq):
    ms = []
    for l in open(f'{etq}/muestras.jsonl'):
        try: ms.append(json.loads(l))
        except Exception: pass
    return ms, json.load(open(f'{etq}-conductor/resultados.json'))['casos']
for etq in sys.argv[1:]:
    ms, casos = carga(etq)
    for c in casos:
        if not any(k in c['caso'] for k in ('Speedometer', 'JetStream', 'Aquarium')): continue
        t0, t1 = c['t0'] / 1000 if c['t0'] > 1e11 else c['t0'], c['t1'] / 1000 if c['t1'] > 1e11 else c['t1']
        tramo = [m for m in ms if t0 <= m['t'] <= t1]
        print(f"{etq} · {c['caso']} ({c.get('resultado')}, {len(tramo)} s)")
        for tipo, nom in (('renderer', 'hilo principal del renderer'), ('gpu-process', 'CrGpuMain')):
            # el renderer con más CPU en el tramo
            pids = {p for m in tramo for p, h in m['hilos'].items() if h['tipo'] == tipo and h.get('h')}
            mejor = None
            for p in pids:
                xs = [m['hilos'][p]['h'] for m in tramo if p in m['hilos'] and m['hilos'][p].get('h')]
                if len(xs) < 2: continue
                s0, u0 = xs[0][0][3], xs[0][0][4]; s1, u1 = xs[-1][0][3], xs[-1][0][4]
                S0 = sum(h[3] for h in xs[0]); U0 = sum(h[4] for h in xs[0]); S1 = sum(h[3] for h in xs[-1]); U1 = sum(h[4] for h in xs[-1])
                r = (s1 - s0, u1 - u0, S1 - S0, U1 - U0, len(xs))
                if mejor is None or r[0] + r[1] > mejor[1][0] + mejor[1][1]: mejor = (p, r)
            if not mejor: print(f'  {nom}: sin datos'); continue
            p, (ds, du, DS, DU, n) = mejor
            print(f'  {nom} (pid {p}): sistema {ds:.1f} s, usuario {du:.1f} s → sistema {100*ds/max(ds+du,1e-9):.1f} %'
                  f' · proceso entero: sistema {100*DS/max(DS+DU,1e-9):.1f} % ({DS+DU:.0f} s CPU en {n} s)')
