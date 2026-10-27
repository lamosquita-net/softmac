#!/usr/bin/env python3
# renarea.py <fichero> <viejo=nuevo>...: resuelve todos los conflictos del fichero con la parte del área aplicándole
# los renombres dados (sustitución literal). Para commits de upstream que solo renombran. MOTOR-13.
import sys
f=sys.argv[1]; R=[a.split('=',1) for a in sys.argv[2:]]; s=open(f).read(); out=[]; i=0; n=0
while True:
    a=s.find('<<<<<<< area\n',i)
    if a<0: out.append(s[i:]); break
    b=s.index('||||||| base\n',a); d=s.index('>>>>>>> upstream\n',b)
    t=s[a+13:b]
    for o,nw in R: t=t.replace(o,nw)
    out.append(s[i:a]); out.append(t); i=d+17; n+=1
open(f,'w').write(''.join(out)); print(f'{f}: {n} conflictos resueltos con renombre')
