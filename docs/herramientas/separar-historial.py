#!/usr/bin/env python3
"""Saca tal cual un tramo de líneas de un documento a otro fichero y deja un enlace (OR.1, paso 4).

Uso: separar-historial.py ORIGEN DESDE HASTA DESTINO "TÍTULO DEL DESTINO" "LÍNEA QUE QUEDA EN EL ORIGEN"
DESDE y HASTA son números de línea (1 = primera; HASTA incluida). Si DESTINO existe, el tramo se
añade al final. Comprueba que origen + destino contienen todas las líneas originales, en orden.
"""
import os
import sys

orig_path, desde, hasta, dest, titulo, enlace = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4], sys.argv[5], sys.argv[6]
lines = open(orig_path, encoding='utf-8').read().split('\n')
tramo = lines[desde - 1:hasta]
nuevo = lines[:desde - 1] + [enlace, ''] + lines[hasta:]

if os.path.exists(dest):
    previo = open(dest, encoding='utf-8').read().rstrip('\n').split('\n') + ['']
else:
    previo = [f'# {titulo}', '',
              f'Sacado tal cual de `{os.path.basename(orig_path)}` (OR.1, 21-10-2026, '
              '`docs/herramientas/separar-historial.py`): es historial; el método vigente sigue en el original.', '']
destino = previo + tramo

assert nuevo[:desde - 1] + tramo + nuevo[desde + 1:] == lines, 'el origen no se reconstruye'
assert destino[-len(tramo):] == tramo
open(orig_path, 'w', encoding='utf-8').write('\n'.join(nuevo))
open(dest, 'w', encoding='utf-8').write('\n'.join(destino).rstrip('\n') + '\n')
print(f'{orig_path}: {len(tramo)} líneas -> {dest}')
