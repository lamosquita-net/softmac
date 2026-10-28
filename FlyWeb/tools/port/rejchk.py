#!/usr/bin/env python3
# rejchk.py <fichero.rej>...: por hunk, ¿están ya las líneas + en el fichero destino? (MOTOR-27)
import sys,re
for r in sys.argv[1:]:
    tgt=re.sub(r'\.rej(\.[0-9a-f]+)?$','',r); src=open(tgt).read() if __import__('os').path.exists(tgt) else ''
    hunks=open(r).read().split('\n@@')[1:]
    for i,h in enumerate(hunks,1):
        add=[l[1:].strip() for l in h.split('\n')[1:] if l.startswith('+') and l[1:].strip()]
        rem=[l[1:].strip() for l in h.split('\n')[1:] if l.startswith('-') and l[1:].strip()]
        a=sum(1 for l in add if l in src); d=sum(1 for l in rem if l in src)
        print(f"{r.split('/')[-1]} h{i}: +{a}/{len(add)} presentes, -{d}/{len(rem)} aún presentes  @@{h.split(chr(10))[0][:70]}")
