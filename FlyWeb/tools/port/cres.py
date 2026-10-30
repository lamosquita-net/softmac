#!/usr/bin/env python3
# cres.py <fichero> <elección>...: resuelve en orden los bloques de conflicto de merge-file (<<<<<<< fw / ======= /
# >>>>>>> up). Elección: fw, up, both (fw y luego up), o @<fichero> con el texto a poner. MOTOR-36.
import sys,re
p=sys.argv[1]; ch=sys.argv[2:]; s=open(p).read()
pat=re.compile(r'<<<<<<< fw\n(.*?)(?:\|\|\|\|\|\|\| base\n.*?)?=======\n(.*?)>>>>>>> up\n',re.S)
i=0
def r(m):
    global i
    c=ch[i]; i+=1
    if c=='fw': return m.group(1)
    if c=='up': return m.group(2)
    if c=='both': return m.group(1)+m.group(2)
    if c.startswith('@'): return open(c[1:]).read()
    raise SystemExit('elección '+c)
s=pat.sub(r,s); assert i==len(ch),(i,len(ch)); open(p,'w').write(s); print(p,'resueltos',i,'quedan',s.count('<<<<<<< fw'))
