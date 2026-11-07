#!/usr/bin/env python3
# Overrides de chromium_src que no han llegado a su .o (sustituye a check-overrides-o.sh).
# Un .cc/.mm de chromium_src que se añade cuando el .o del original ya existe no hace recompilar nada: la build sale
# en verde con el original de Chromium. Lo delata `ninja -t deps`: el original aparece como dependencia y el override no.
# En deps, redirect_cc deja el original como «../../../src/<ruta>» y el override como «../../brave/chromium_src/<ruta>»;
# se aceptan también las rutas «../../<ruta>». Una sola pasada sobre el volcado (el .sh hacía dos grep por override).
# Uso: check-overrides-o.py <out dir> [<brave-core>]   (desde src: out/Release brave)
# Salida: <override>\tSIN_COMPILAR por cada uno (borrar ese .o o el out y recompilar); al final, el recuento a stderr.
import os, subprocess, sys

out = sys.argv[1]
bc = sys.argv[2] if len(sys.argv) > 2 else os.path.join(out, '..', '..', 'brave')
deps = set()
p = subprocess.Popen(['ninja', '-C', out, '-t', 'deps'], stdout=subprocess.PIPE, text=True)
for l in p.stdout:
    l = l.strip()
    if l.startswith('../../../src/'):
        deps.add(l[len('../../../src/'):])
    elif l.startswith('../../'):
        deps.add(l[len('../../'):])
if p.wait():
    sys.exit('ninja -t deps ha fallado')
tot = orig = 0
for root, _, files in os.walk(os.path.join(bc, 'chromium_src')):
    for f in files:
        if not f.endswith(('.cc', '.mm')):
            continue
        tot += 1
        o = os.path.relpath(os.path.join(root, f), bc)
        rel = o[len('chromium_src/'):]
        if rel not in deps:
            continue  # el original no se compila en esta plataforma
        orig += 1
        if 'brave/chromium_src/' + rel not in deps:
            print(f'{o}\tSIN_COMPILAR')
print(f'overrides .cc/.mm: {tot} · con el original compilado: {orig}', file=sys.stderr)
