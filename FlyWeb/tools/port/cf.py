#!/usr/bin/env python3
# cf.py <fichero> <n> <area|upstream|base|->: resuelve el conflicto n (desde 1) de git merge-file --diff3 con la
# parte del área, la de upstream, la base, o el texto de la entrada estándar ('-'). Sin <n> ni opción: lista. MOTOR-13.
import sys,re
f=sys.argv[1]; L=open(f).read().split('\n')
blocks=[]; i=0
while i<len(L):
    if L[i].startswith('<<<<<<< '):
        a=i; b=next(j for j in range(i,len(L)) if L[j].startswith('||||||| '))
        c=next(j for j in range(b,len(L)) if L[j]=='=======')
        d=next(j for j in range(c,len(L)) if L[j].startswith('>>>>>>> '))
        blocks.append((a,b,c,d)); i=d+1
    else: i+=1
if len(sys.argv)<4:
    print(len(blocks),'conflictos'); sys.exit(0)
n=int(sys.argv[2]); a,b,c,d=blocks[n-1]; how=sys.argv[3]
rep={'area':L[a+1:b],'base':L[b+1:c],'upstream':L[c+1:d]}.get(how)
if rep is None:
    t=sys.stdin.read()
    rep=t[:-1].split('\n') if t.endswith('\n') else t.split('\n')
    if t=='': rep=[]
L[a:d+1]=rep
open(f,'w').write('\n'.join(L))
print(f'{f}: conflicto {n} → {how}; quedan {len(blocks)-1}')
