#!/bin/bash
# Overrides que no han llegado al binario (MOTOR-41, 07-11-2026; arreglado con los
# datos de LOCAL-19). En la 7,1, después de compilar: un .cc/.mm de chromium_src
# añadido cuando el .o del original ya existe no hace recompilar nada (ninja no
# sabe de él). Lo delata `ninja -t deps`: el original sale como dependencia de
# algún .o y el override no.
# El original sale como «../../<ruta>» o, con redirect_cc, como «../../../src/<ruta>».
# Uso: check-overrides-o.sh <out dir> [<brave-core>]   (p. ej. src/out/Release src/brave)
# Salida: resumen y, por cada caso, <override>\tSIN_COMPILAR → borra ese .o (o el out) y recompila.
OUT=${1:?out dir}; BC=${2:-$OUT/../../brave}
ninja -C "$OUT" -t deps | python3 -I -c '
import os, sys
bc = sys.argv[1]
deps = set(l.strip() for l in sys.stdin if l.startswith(" "))
orig, over = set(), set()
for d in deps:
    i = d.find("brave/chromium_src/")
    if i >= 0:
        over.add(d[i + len("brave/chromium_src/"):]); continue
    if d.startswith("../../../src/"): orig.add(d[len("../../../src/"):])
    elif d.startswith("../../"): orig.add(d[len("../../"):])
n = c = 0; bad = []
for root, _, files in os.walk(os.path.join(bc, "chromium_src")):
    for f in files:
        if not f.endswith((".cc", ".mm")): continue
        rel = os.path.relpath(os.path.join(root, f), os.path.join(bc, "chromium_src"))
        n += 1
        if rel not in orig: continue
        c += 1
        if rel not in over: bad.append(rel)
print(f"overrides: {n}; con original compilado: {c}; sin compilar: {len(bad)}")
for r in sorted(bad): print(f"chromium_src/{r}\tSIN_COMPILAR")
' "$BC"
