#!/usr/bin/env python3
"""Últimos recortes de docs/TAREAS.md (OR.1, 21-10-2026):
1. La lista de casillas de «Despliegue de la organización del 09-10» pasa tal cual al archivo
   (se quedan en el tablero el título, un enlace y las notas fijas de debajo).
2. Las líneas cortas de filas archivadas que ya no cita ninguna fila viva se quitan; las que
   quedan, se acortan (id, tarea abreviada y enlace).

Uso: compactar-tablero.py [--dry-run] [ruta del repo]
"""
import re
import sys

DRY = '--dry-run' in sys.argv
args = [a for a in sys.argv[1:] if not a.startswith('--')]
ROOT = args[0] if args else '.'
TAREAS = f'{ROOT}/docs/TAREAS.md'
ARCHIVO = f'{ROOT}/docs/TAREAS-archivo.md'
MARCA = 'archivada: [TAREAS-archivo.md](TAREAS-archivo.md) |'
TITULO = '## Despliegue de la organización del 09-10'

L = open(TAREAS, encoding='utf-8').read().split('\n')
A = open(ARCHIVO, encoding='utf-8').read().rstrip('\n').split('\n')
orig = list(L)

# 1. Casillas del despliegue.
i = L.index(TITULO)
fin = next(k for k in range(i + 1, len(L)) if L[k].startswith('**Prohibido'))
lista = L[i + 2:fin - 1]
assert lista and lista[0].startswith('Lo hace el HUMANO') and L[fin - 1] == ''
L[i + 2:fin - 1] = ['Lista de casillas del despliegue (todas cerradas o superadas), tal cual en '
                    '[`TAREAS-archivo.md`](TAREAS-archivo.md#despliegue-de-la-organización-del-09-10).']
h = A.index('## Historial')
A[h:h] = [TITULO, ''] + lista + ['']

# 2. Líneas cortas.
row_id = lambda l: l.split(' | ')[0][2:].strip()
cortas = [l for l in L if l.endswith(MARCA)]
vivo = '\n'.join(l for l in L if not l.endswith(MARCA))
citada = lambda k: re.search(r'(?<![\w.])' + re.escape(k) + r'(?![\d])', vivo)
nuevas, quitadas = [], []
for l in L:
    if not l.endswith(MARCA):
        nuevas.append(l)
    elif citada(row_id(l)):
        tarea = re.sub(r'\*\*|\s+', ' ', l.split(' | ')[1]).strip()
        tarea = tarea if len(tarea) <= 80 else tarea[:80].rstrip() + '…'
        nuevas.append(f'| {row_id(l)} | {tarea} | | | {MARCA}')
    else:
        quitadas.append(row_id(l))
L = nuevas

# Comprobaciones: las filas cortas quitadas están completas en el archivo; las casillas, también.
for k in quitadas:
    assert any(a.startswith(f'| {k} | ') for a in A), k
assert all(x in A for x in lista)
sin_lista = orig[:i + 2] + orig[fin - 1:]
assert [l for l in sin_lista if not l.endswith(MARCA)] == \
       [l for l in L if not l.endswith(MARCA) and not l.startswith('Lista de casillas del despliegue')]

tam = lambda ls: len('\n'.join(ls).encode())
print(f'TAREAS.md: {tam(orig)} -> {tam(L)} bytes; líneas cortas: {len(cortas)} -> {len(cortas) - len(quitadas)} '
      f'(quitadas: {", ".join(quitadas)})')
if not DRY:
    open(TAREAS, 'w', encoding='utf-8').write('\n'.join(L))
    open(ARCHIVO, 'w', encoding='utf-8').write('\n'.join(A) + '\n')
