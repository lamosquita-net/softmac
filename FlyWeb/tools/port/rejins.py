#!/usr/bin/env python3
# Uso: rejins.py <fichero> <.rej> <nº de hunk en el .rej, desde 1> <texto ancla> [aparición]
# Inserta las líneas añadidas de un hunk rechazado que solo añade (sin «-») justo después de la línea que contiene
# <texto ancla> (única, salvo que se dé [aparición], desde 1). El ancla es la línea de contexto que precede al bloque
# en el hunk, no la anterior a ella. Imprime el bloque insertado.
import sys,re
f,rej,n,anchor=sys.argv[1:5]; occ=int(sys.argv[5]) if len(sys.argv)>5 else None
hunks=re.split(r'^(?=@@ )',open(rej).read(),flags=re.M)[1:]
h=hunks[int(n)-1].split('\n')[1:]
assert not any(l.startswith('-') for l in h), 'hunk has removals'
add=[l[1:] for l in h if l.startswith('+')]
# the added lines must be contiguous
idx=[i for i,l in enumerate(h) if l.startswith('+')]
assert idx==list(range(idx[0],idx[-1]+1)), 'non-contiguous additions'
lines=open(f).read().split('\n')
m=[i for i,l in enumerate(lines) if anchor in l]
if occ: m=[m[occ-1]]
assert len(m)==1,('anchor matches',len(m))
lines[m[0]+1:m[0]+1]=add
open(f,'w').write('\n'.join(lines))
print('\n'.join(add))
