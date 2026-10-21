#!/usr/bin/env python3
"""Archiva las filas cerradas de docs/TAREAS.md en docs/TAREAS-archivo.md (OR.1, paso 1).

Mueve tal cual las filas cuyo estado es claramente cerrado (hecho sin traspaso pendiente,
aparcada, cerrada, descartada, anulada, retirada). Las de estado mixto («hecho → X»,
«por compilar», «en PR»…) se quedan vivas. Si una fila viva, la tabla de agentes o las
reglas citan una archivada, en TAREAS.md queda una línea corta que apunta al archivo.

Con --ids=A,B,… archiva además esas filas (las que COORDINACIÓN da por cerradas aunque su
estado sea mixto). Si el archivo ya existe, añade las filas al final de su sección.

Uso: archivar-tablero.py [--dry-run] [--ids=F1.1,FM.2,…] [ruta del repo]
"""
import os
import re
import sys
from collections import OrderedDict

DRY = '--dry-run' in sys.argv
FORZADAS = {x for a in sys.argv[1:] if a.startswith('--ids=') for x in a[6:].split(',') if x}
args = [a for a in sys.argv[1:] if not a.startswith('--')]
ROOT = args[0] if args else '.'
TAREAS = f'{ROOT}/docs/TAREAS.md'
ARCHIVO = f'{ROOT}/docs/TAREAS-archivo.md'

CERRADOS = re.compile(r'^(aparcada|cerrada|descartada|anulada|retirada)\b', re.I)
MIXTO = re.compile(r'→|por compilar|en marcha|sin compilar|en pr\b|falta|diaria|compila|pendiente|en curso', re.I)


def estado(row):
    cells = row.split(' | ')
    return cells[3].replace('*', '').strip() if len(cells) > 4 else ''


MARCA = 'archivada: [TAREAS-archivo.md](TAREAS-archivo.md) |'


def cerrada(row):
    if row.endswith(MARCA):
        return False
    if row_id(row) in FORZADAS:
        return True
    st = estado(row)
    if CERRADOS.match(st.split(' por ')[0]):
        return True
    return st.lower().startswith('hecho') and not MIXTO.search(st)


def row_id(row):
    return row.split(' | ')[0][2:].strip()


src = open(TAREAS, encoding='utf-8').read()
lines = src.split('\n')
board = lines.index('## Tablero')

keep, moved = [], OrderedDict()   # moved: sección -> [(índice, fila)]
section, header = None, {}
for i, l in enumerate(lines):
    if i > board and l.startswith('### '):
        section = l
    if i > board and section and l.startswith('| ') and l.split(' | ')[0] in ('| #', '| Id'):
        header[section] = (l, lines[i + 1])
    if i > board and section and l.startswith('| ') and not l.startswith('|---') \
            and section in header and l != header[section][0] and cerrada(l):
        moved.setdefault(section, []).append((i, l))
        keep.append((i, None))
    else:
        keep.append((i, l))

ids = {row_id(r): r for rows in moved.values() for _, r in rows}
vivo = '\n'.join(l for _, l in keep if l is not None)
citadas = {k for k in ids if re.search(r'(?<![\w.])' + re.escape(k) + r'(?![\d])', vivo)}


def resumen(row):
    c = row.split(' | ')
    tarea = re.sub(r'\s+', ' ', c[1]).strip()
    if len(tarea) > 140:
        tarea = tarea[:140].rstrip() + '…'
    st = estado(row)
    if len(st) > 140:
        st = st[:140].rstrip() + '…'
    return f'| {row_id(row)} | {tarea} | {c[2].strip()} | {st} | {MARCA}'


out = []
for i, l in keep:
    if l is not None:
        out.append(l)
    elif row_id(lines[i]) in citadas:
        out.append(resumen(lines[i]))

nota = ('Las filas cerradas (`hecho` sin traspaso pendiente, `aparcada`, `cerrada`, `descartada`, `anulada`, '
        '`retirada`) están, tal cual, en [`TAREAS-archivo.md`](TAREAS-archivo.md) (OR.1, 21-10); aquí queda una '
        'línea corta de las que cita alguna fila viva.\n')
pos = out.index('## Tablero') + 1
nuevo_bloque = [] if nota.rstrip('\n') in out else ['', nota.rstrip('\n')]
out[pos:pos] = nuevo_bloque

if os.path.exists(ARCHIVO):
    previo = open(ARCHIVO, encoding='utf-8').read().split('\n')
else:
    previo = ['# Archivo del tablero', '',
              'Filas cerradas de [`TAREAS.md`](TAREAS.md), movidas **tal cual** (sin resumir) por '
              '`docs/herramientas/archivar-tablero.py` (OR.1, 21-10-2026). Solo lectura: lo vivo sigue en '
              '`TAREAS.md`.', '']
arch = list(previo)
for sec, rows in moved.items():
    nuevas_filas = [r for _, r in rows]
    if sec in arch:
        j = arch.index(sec) + 1
        while j < len(arch) and not arch[j].startswith('#'):
            j += 1
        while arch[j - 1] == '':
            j -= 1
        arch[j:j] = nuevas_filas
    else:
        if arch[-1] != '':
            arch.append('')
        arch += [sec, '', header[sec][0], header[sec][1]] + nuevas_filas + ['']

# Comprobaciones: nada se pierde.
es_fila = lambda l: l.startswith('| ') and not l.startswith('|---') and l.split(' | ')[0] not in ('| #', '| Id')
orig_rows = [l for i, l in enumerate(lines) if i > board and es_fila(l)]
new_rows = [l for i, l in enumerate(out) if i > out.index('## Tablero') and es_fila(l)]
arch_rows = [r for rows in moved.values() for _, r in rows]
nuevas = {resumen(lines[i]) for i, l in keep if l is None and row_id(lines[i]) in citadas}
stubs = [l for l in new_rows if l in nuevas]
live = [l for l in new_rows if l not in stubs]
assert all(r in arch for r in arch_rows)
it = iter(arch)
assert all(l in it for l in previo), 'el archivo previo ha perdido o desordenado líneas'
assert len(arch_rows) == len(set(arch_rows))
board_live = [l for l in live if l in orig_rows]
assert sorted(board_live + arch_rows) == sorted(orig_rows), 'filas perdidas o duplicadas'
assert len(stubs) == len(citadas)
non_table_orig = [l for l in lines if not (l.startswith('| ') and l in arch_rows)]
sin_bloque = out[:pos] + out[pos + len(nuevo_bloque):]
assert [l for l in sin_bloque if l not in nuevas] == non_table_orig, 'texto fuera de las filas cambiado'

tam = lambda s: len(s.encode('utf-8'))
print(f'filas del tablero: {len(orig_rows)} = {len(board_live)} vivas + {len(arch_rows)} archivadas '
      f'(+{len(stubs)} líneas cortas: {", ".join(sorted(citadas))})')
print(f'TAREAS.md: {tam(src)} -> {tam(chr(10).join(out))} bytes; archivo: {tam(chr(10).join(arch))} bytes')
for sec, rows in moved.items():
    print(f'  {sec[4:]}: {", ".join(row_id(r) for _, r in rows)}')
if not DRY:
    open(TAREAS, 'w', encoding='utf-8').write('\n'.join(out))
    open(ARCHIVO, 'w', encoding='utf-8').write('\n'.join(arch))
