#!/usr/bin/env python3
# ciclos.py <área>: ciclos de #include que pasan por cabeceras cambiadas por el porte (frente al commit «brave»).
import sys,os,re,subprocess
W=f'/tmp/claude-0/port/w-{sys.argv[1]}'; C='/home/user/cr116'
ch=set(subprocess.run(['git','-C',W,'diff','--name-only','a0f41ed','HEAD','--','*.h'],capture_output=True,text=True).stdout.split())
inc=re.compile(r'^#include "([^"]+\.h)"',re.M); memo={}
def deps(h):
    if h in memo: return memo[h]
    p=os.path.join(W,h) if os.path.exists(os.path.join(W,h)) else os.path.join(C,h)
    try: t=open(p,errors='ignore').read()
    except: t=''
    memo[h]=[d for d in inc.findall(t) if d.startswith(('third_party/blink','cc/'))]
    return memo[h]
found=set()
for s in ch:
    # DFS para encontrar un camino s -> ... -> s
    stack=[(s,[s])]; seen=set()
    while stack:
        n,path=stack.pop()
        for d in deps(n):
            if d==s and len(path)>1:
                cyc=tuple(path); k=frozenset(cyc)
                if k not in found:
                    found.add(k); print(' -> '.join(x.replace('third_party/blink/renderer/','') for x in path+[s]))
            elif d not in seen and len(path)<8:
                seen.add(d); stack.append((d,path+[d]))
