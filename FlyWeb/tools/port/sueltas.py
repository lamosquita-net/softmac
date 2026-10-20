#!/usr/bin/env python3
# sueltas.py <área> <base>: sentencias sangradas a nivel de espacio de nombres en los .cc cambiados (código que la
# autorresolución dejó fuera de su función). <base>: el commit «brave» del área. Orientativo: da falsos positivos
# (macros, inicializadores); cada aviso se mira a mano. MOTOR-13.
import subprocess,re,os,sys
W=f'/tmp/claude-0/port/w-{sys.argv[1]}'
fs=subprocess.run(['git','diff','--name-only','--diff-filter=AM',sys.argv[2],'HEAD','--','*.cc'],capture_output=True,text=True,cwd=W).stdout.split()
for f in fs:
    t=open(os.path.join(W,f),errors='ignore').read()
    t=re.sub(r'/\*.*?\*/',lambda m:'\n'*m.group(0).count('\n'),t,flags=re.S)
    depth=0; ns=[]  # profundidades de los namespaces abiertos
    for n,l in enumerate(t.split('\n'),1):
        s=re.sub(r'//.*','',l); s=re.sub(r'"(\\.|[^"\\])*"','""',s); s=re.sub(r"'(\\.|[^'\\])*'","''",s)
        if s.startswith('#'): continue
        at_ns = depth==len(ns)  # fuera de funciones y clases
        if at_ns and re.match(r'^  +[A-Za-z_][\w:<>\.\->\[\]]*\s*(=|\(|\+\+|--|->|\.)[^;]*;\s*$',s) and not re.match(r'^\s+(return|case|default)\b',s):
            print(f'{f}:{n}: {l.strip()[:100]}')
        for ch in s:
            if ch=='{':
                depth+=1
            elif ch=='}':
                depth-=1
                while ns and ns[-1]>depth: ns.pop()
        if re.match(r'^\s*namespace\b[^;]*\{\s*$',s): ns.append(depth)
