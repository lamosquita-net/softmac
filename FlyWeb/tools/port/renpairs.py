#!/usr/bin/env python3
# renpairs.py <commit>: pares viejo→nuevo de identificadores en las líneas -/+ emparejadas del commit (para commits de
# renombre de upstream). MOTOR-13.
import sys,subprocess,re,collections
d=subprocess.run(['git','-C','/home/user/chromium/chromium','show','--format=',sys.argv[1],'--','third_party/blink','cc'],capture_output=True,text=True).stdout
ident=re.compile(r'[A-Za-z_][A-Za-z0-9_]*'); c=collections.Counter()
for h in re.split(r'^@@.*$',d,flags=re.M):
    L=h.split('\n'); m=[l[1:] for l in L if l.startswith('-') and not l.startswith('---')]; p=[l[1:] for l in L if l.startswith('+') and not l.startswith('+++')]
    if len(m)!=len(p): continue
    for a,b in zip(m,p):
        ta,tb=ident.findall(a),ident.findall(b)
        if len(ta)!=len(tb): continue
        for x,y in zip(ta,tb):
            if x!=y: c[(x,y)]+=1
for (x,y),n in c.most_common(): print(n,x,y)
