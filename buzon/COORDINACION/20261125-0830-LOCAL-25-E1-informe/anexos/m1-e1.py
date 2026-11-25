# LOCAL-25 · M1 con E1 y con la base (pasadas e1v-*, con muestreador): por caso y por prueba de MotionMark,
# utilización de cada D500, % del hilo principal del renderer y de CrGpuMain (mediana por segundo) y ms/f si hay fps.
import json, sys, statistics as st
G = ('0x1000006a3', '0x1000006a0')
def hilo(t, tipo):
    v = []
    for m in t:
        hs = [h for h in m['hilos'].values() if h['tipo'] == tipo and h.get('h')]
        if hs: v.append(max(h['h'][0][0] for h in hs))
    return st.median(v) if v else None
def fila(nombre, t, fps):
    u = [round(st.mean(m['gpu'].get(g, 0) for m in t)) for g in G]
    r, g = hilo(t, 'renderer'), hilo(t, 'gpu-process')
    msf = f'{r*10/fps:.1f} / {g*10/fps:.1f}' if fps and r is not None and g is not None else '—'
    print(f'| {nombre} | {fps if fps else "—"} | {u[0]} % | {u[1]} % | {r if r is None else round(r)} % | {g if g is None else round(g)} % | {msf} |')
for etq in sys.argv[1:]:
    ms = [json.loads(l) for l in open(f'{etq}/muestras.jsonl') if l.strip()]
    cs = json.load(open(f'{etq}-conductor/resultados.json'))['casos']
    print(f'\n### {etq.split("/")[-1]}\n\n| Caso | fps | D500 pantalla | otra D500 | renderer | CrGpuMain | ms/f rend / CrGpuMain |\n|---|---|---|---|---|---|---|')
    for c in cs:
        if c.get('pruebas'):
            for p in c['pruebas']:
                t = [m for m in ms if p['t0'] <= m['t'] <= p['t1']]
                if t: fila('MM ' + p['prueba'], t, None)
        elif 'raf' in c and c.get('t0'):
            t = [m for m in ms if c['t0'] <= m['t'] <= c['t1']]
            if t: fila(c['caso'].replace(' pasada 1', ''), t, c['raf'].get('fps'))
