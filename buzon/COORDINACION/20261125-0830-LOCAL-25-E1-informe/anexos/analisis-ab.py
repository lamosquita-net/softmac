#!/usr/bin/env python3
# LOCAL-25 · E1: veredicto §11.3 del A/B (multihilo-multigpu.md). Uso: analisis-ab.py <prefijo, p. ej. e1ab> [dir entregas]
# Valor por pasada: mediana de los fps por segundo de rAF (MotionMark: puntuación). Validez (regla de ARQUITECTURA/COORD.):
# una pasada WebGL cuenta solo si hay contexto WebGL con tamaño y la captura no es negra, en las dos versiones.
import json, ast, os, sys, glob, statistics as st, subprocess, tempfile, re
PRE = sys.argv[1] if len(sys.argv) > 1 else 'e1ab'
E = sys.argv[2] if len(sys.argv) > 2 else '/Volumes/googledrive/clientes/software/entregas/local24'
TMP = tempfile.mkdtemp()
MM = ['Multiply', 'Canvas Arcs', 'Leaves', 'Paths', 'Canvas Lines', 'Images', 'Design', 'Suits']

def luz(jpg):
    """Media y desviación de luminancia (0-255) de una captura; None si no hay captura."""
    if not os.path.exists(jpg): return None
    bmp = os.path.join(TMP, 'x.bmp')
    subprocess.run(['sips', '-s', 'format', 'bmp', '-Z', '200', jpg, '--out', bmp], capture_output=True)
    d = open(bmp, 'rb').read(); off = int.from_bytes(d[10:14], 'little'); px = d[off:]
    v = [(px[i] + px[i+1] + px[i+2]) / 3 for i in range(0, len(px) - 2, 3)]
    return round(st.mean(v), 1), round(st.pstdev(v), 1)

def entorno(c):
    e = c.get('entorno', {})
    return ast.literal_eval(e) if isinstance(e, str) else e

def veredicto(b, e):
    mb, me = st.median(b), st.median(e)
    ruido = (max(b) - min(b)) / mb if mb else 0
    perd = 1 - me / mb if mb else 0
    if ruido > 0.10: v = 'no medible'
    elif perd <= 0.02: v = 'pasa'
    elif me < min(b): v = 'falla'
    else: v = 'dudoso'
    return mb, me, ruido, perd, v

filas = {}   # (escala, caso) -> {'base': [...], 'e1': [...]}
invalidas = []
estados15 = {}
for d in sorted(glob.glob(f'{E}/{PRE}-*-conductor')):
    m = re.search(r'-(wgl|mm|video|msaa|basemark)-esc(\d)-(\d+)-(base|e1)-conductor$', d) or \
        re.search(r'-(basemark)-esc(\d)-()(base|e1)-conductor$', d) or \
        re.search(r'e1(msaa|shs|shd|mmr|vid)-esc(\d)-(\d+)-(base|e1|e1x|e1d)-conductor$', d)
    if not m: continue
    tipo, esc, n, ver = m.groups()
    r = json.load(open(f'{d}/resultados.json'))
    for c in r['casos']:
        caso = c['caso'].replace(' pasada 1', '')
        if c['caso'].startswith('MotionMark'):
            t = c['texto'].split('\n'); i = t.index('Score')
            tot = float(t[1].split()[0]); sc = [float(x) for x in t[i+2:i+2+len(MM)]]
            for k, v in [('MotionMark total', tot)] + list(zip(['MM ' + x for x in MM], sc)):
                filas.setdefault((esc, k), {'base': [], 'e1': []})[{'e1x': 'e1', 'e1d': 'base'}.get(ver, ver)].append(v)
            continue
        if 'raf' not in c: continue
        en = entorno(c); val = st.median(c['raf']['muestras'])
        if caso == 'threejs-buffergeometry': continue   # no medido (no arranca desde threejs.org)
        bufs = [b for b in en.get('buffers', []) if b[1] > 0 and b[2] > 0]
        nombre = {'cruce4k': 'cruce4k', 'textura2d': 'textura2d', 'shader-local': 'shader-local'}.get(caso)
        ok = True; motivo = ''
        if tipo in ('wgl', 'msaa', 'shs', 'shd'):
            if not bufs: ok, motivo = False, 'sin contexto WebGL con tamaño'
            if caso.startswith(('msaa-', 'three-', 'shader-n')): nombre = caso
            jpg = f'{d}/{nombre}.jpg' if nombre else None
            ms = c.get('msaa')
            if ms is not None and not ms.get('samples'): ok, motivo = False, f'SAMPLES = {ms.get("samples")}'
            if jpg:
                l = luz(jpg)
                if l is None: ok, motivo = False, 'sin captura'
                elif l[0] < 5 and l[1] < 3: ok, motivo = False, f'captura negra {l}'
            elif c.get('extra') in (None, 0) and not caso.startswith('YouTube'):
                ok, motivo = False, 'sin fps de la página'
        if tipo == 'video':
            vi = c.get('extra') if caso.startswith('YouTube') else (c.get('video') or {}).get('antes')
            if not vi or vi.get('total', 0) == 0 or '@60' not in vi.get('resolucion', ''):
                ok, motivo = False, f"vídeo sin 4K60 reproduciéndose ({vi and vi.get('resolucion')}, {vi and vi.get('total')} fotogramas)"
        if not ok:
            invalidas.append((os.path.basename(d), caso, motivo)); continue
        if caso.startswith('Aquarium 15000'):
            estados15.setdefault((esc, ver), []).append(val)
        filas.setdefault((esc, caso), {'base': [], 'e1': []})[{'e1x': 'e1', 'e1d': 'base'}.get(ver, ver)].append(val)

print(f'# Veredicto §11.3 · {PRE} · valor = mediana de fps por segundo (MotionMark: puntuación)\n')
for esc in ('1', '2'):
    print(f'## Escala {esc}\n')
    print('| Caso | Base (pasadas) | E1 (pasadas) | Med. base | Med. E1 | Ruido | Pérdida | Veredicto |')
    print('|---|---|---|---|---|---|---|---|')
    for (e, caso), v in filas.items():
        if e != esc or not v['base'] or not v['e1']: continue
        mb, me, ru, pe, ve = veredicto(v['base'], v['e1'])
        f = lambda xs: ' '.join(f'{x:g}' for x in xs)
        print(f'| {caso} | {f(v["base"])} | {f(v["e1"])} | {mb:g} | {me:g} | {ru*100:.1f} % | {pe*100:+.1f} % | {ve} |')
    print()
print('## Aquarium 15000: estados (≥ 55 fps rápida)\n')
for k, v in sorted(estados15.items()):
    print(f'- escala {k[0]} {k[1]}: {len([x for x in v if x >= 55])} rápidas, {len([x for x in v if x < 55])} lentas: {v}')
print('\n## Pasadas no válidas\n')
for x in invalidas: print('-', *x)
if not invalidas: print('- ninguna')
