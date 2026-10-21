#!/usr/bin/env python3
"""Pasa el historial de la tabla de agentes y de las filas vivas largas de docs/TAREAS.md a la
sección «Historial» de docs/TAREAS-archivo.md (OR.1, decisión B de COORDINACIÓN-9, 21-10).

Cada corte es un tramo de una fila entre dos marcas de texto (CORTES). El tramo sale tal cual al
archivo, bajo el id de la fila, y en la fila queda un enlace. El script comprueba que, al volver a
poner cada tramo en su sitio, la fila es idéntica a la original.

Uso: historial-tablero.py [--dry-run] [--filas=F0.8,FS.1,…] [ruta del repo]
(--filas: solo esas filas y sin los cortes de la tabla de agentes, que ya se hicieron)
"""
import re
import sys

DRY = '--dry-run' in sys.argv
SOLO = [x for a in sys.argv[1:] if a.startswith('--filas=') for x in a[8:].split(',') if x]
args = [a for a in sys.argv[1:] if not a.startswith('--')]
ROOT = args[0] if args else '.'
TAREAS = f'{ROOT}/docs/TAREAS.md'
ARCHIVO = f'{ROOT}/docs/TAREAS-archivo.md'
TITULO = '## Historial'
ENLACE = ' [historial](TAREAS-archivo.md#historial)'

# (inicio de la fila, marca de inicio del tramo, marca de fin o None = hasta el final de la fila).
# La marca de inicio sale con el tramo; la de fin se queda en la fila.
CORTES = [
    ('| **COORDINACIÓN**', ' Antes: COORDINACIÓN-8', ' Solo la despiertan'),
    ('| **MOTOR**', '(MOTOR-1 = 125 y 126;', '**MOTOR-13 ='),
    ('| **MOTOR**', '; **MOTOR-12 =', ' | '),
    ('| **LOCAL**', ' Antes: LOCAL-4:', ' | '),
    ('| **LOCAL**', ' **Cola de LOCAL-4', ' | '),
    ('| **LOCAL**', ' **LOCAL-4 15/10 — (1) `block-ruby-003` CERRADO', None),
    ('| **SEGURIDAD-PORTES**', ' Antes: SEGURIDAD-PORTES-2:', ' | '),
]

lines = open(TAREAS, encoding='utf-8').read().split('\n')
orig = list(lines)
tramos = []  # (id, tramo)
for pref, ini, fin in ([] if SOLO else CORTES):
    n = [i for i, l in enumerate(lines) if l.startswith(pref + ' ')]
    assert len(n) == 1, f'fila {pref}: {len(n)}'
    l = lines[n[0]]
    a = l.find(ini)
    assert a >= 0 and l.find(ini, a + 1) < 0, f'marca de inicio no única: {ini}'
    if fin is None:
        b = len(l) - len(' |')
        assert l.endswith(' |')
    else:
        b = l.find(fin, a + len(ini))
        assert b >= 0, f'sin marca de fin: {fin}'
    tramos.append((pref.strip('| *'), n[0], a, l[a:b]))
    lines[n[0]] = l[:a] + ENLACE + '\x00' + l[b:]

# Filas vivas largas sin actividad reciente: se quedan el enunciado (lo anterior a la primera
# entrada fechada), la entrada más reciente y las que recogen una decisión; el resto, al archivo.
FILAS = SOLO or ['F0.2', 'F1.8', 'F1.14', 'F2.2', 'F2.6', 'F4.7', 'F4.8', 'F7.2', 'F7.3', 'F7.5', 'F7.8',
         'FM.5', 'FS.2', 'FS.3', 'FM.24', 'SV.6']
ENTRADA = re.compile(r'\*\*(?:(?:[A-ZÁÉÍÓÚÑ][A-ZÁÉÍÓÚÑ0-9\-/ ]{2,}[ ,]*)?(\d{1,2})[/-](\d{2})(?:[^*]{0,12}?(\d{1,2}):(\d{2}))?'
                     r'|Paso \d+)')
DECISION = re.compile(r'DECISI[ÓO]N|DECIDID', re.I)


def clave(m, pos):
    if m.group(1):
        return (int(m.group(2)), int(m.group(1)), int(m.group(3) or 0), int(m.group(4) or 0), pos)
    return (0, 0, 0, 0, pos)


filas_tramos = {}  # índice de línea -> [(posición en la original, tramo)]
for ident in FILAS:
    n = [i for i, l in enumerate(lines) if l.startswith(f'| {ident} | ')]
    assert len(n) == 1, ident
    l = lines[n[0]]
    c = l.split(' | ')
    ini_notas = len(' | '.join(c[:4])) + 3
    notas = l[ini_notas:]
    ms = list(ENTRADA.finditer(notas))
    if len(ms) < 2:
        continue
    segs = [(m.start(), ms[k + 1].start() if k + 1 < len(ms) else len(notas) - 2, m) for k, m in enumerate(ms)]
    ultima = max(segs, key=lambda x: clave(x[2], x[0]))
    fuera = [(a, b) for a, b, m in segs if (a, b, m) != ultima and not DECISION.search(notas[a:a + 120])]
    # Se juntan los tramos contiguos.
    juntos = []
    for a, b in fuera:
        if juntos and juntos[-1][1] == a:
            juntos[-1] = (juntos[-1][0], b)
        else:
            juntos.append((a, b))
    if not juntos:
        continue
    nueva, prev, primero = '', 0, True
    for a, b in juntos:
        nueva += notas[prev:a] + (ENLACE.strip() + ' ' if primero else '')
        primero = False
        prev = b
        tramos.append((ident, n[0], ini_notas + a, notas[a:b]))
    nueva += notas[prev:]
    filas_tramos[n[0]] = [(ini_notas + a, notas[a:b]) for a, b in juntos]
    lines[n[0]] = l[:ini_notas] + nueva
    # Comprobación de la fila: con los tramos en su sitio, vuelve a ser la original.
    rec, pos = nueva.replace(ENLACE.strip() + ' ', '', 1), 0
    for a, b in juntos:
        rec = rec[:a] + notas[a:b] + rec[a:]
    assert rec == notas, f'{ident} no se reconstruye'

# Comprobación: con cada tramo en su sitio, la fila vuelve a ser la original.
for i, l in enumerate(lines):
    r = l
    if i in filas_tramos:
        continue  # comprobadas arriba
    for _, n, _, t in [x for x in tramos if x[1] == i]:
        r = r.replace(ENLACE + '\x00', t, 1)
    assert r == orig[i], f'línea {i + 1} no se reconstruye'
lines = [l.replace('\x00', '') for l in lines]

arch = open(ARCHIVO, encoding='utf-8').read().rstrip('\n').split('\n')
if TITULO not in arch:
    arch += ['', TITULO, '',
             'Tramos de historial sacados tal cual de la tabla de agentes y de las filas vivas de `TAREAS.md` '
             '(OR.1, 21-10-2026, `docs/herramientas/historial-tablero.py`). En la fila queda un enlace aquí.']
ultimo = None
for ident, _, _, t in tramos:
    if ident != ultimo:
        arch += ['', f'### {ident}']
        ultimo = ident
    arch += ['', t.strip()]
assert all(t.strip() in '\n'.join(arch) for *_, t in tramos)

tam = lambda ls: len('\n'.join(ls).encode())
print(f'tramos: {len(tramos)}; TAREAS.md: {tam(orig)} -> {tam(lines)} bytes; '
      f'tabla de agentes: {tam(orig[:29])} -> {tam(lines[:29])} bytes')
if not DRY:
    open(TAREAS, 'w', encoding='utf-8').write('\n'.join(lines))
    open(ARCHIVO, 'w', encoding='utf-8').write('\n'.join(arch) + '\n')
