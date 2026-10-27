#!/usr/bin/env python3
# chk116.py <brave-core> <rama o commit> <clon parcial de Chromium 116.0.5845.188> <carpeta de trabajo>
# Prueba en seco todos los patches/*.patch (no los de V8) de la rama contra Chromium 116: baja de una vez solo los
# ficheros que tocan (sparse-checkout) y hace `git apply --check` de cada uno. SEGURIDAD, 07-10-2026.
# El clon parcial sale de `git clone --filter=blob:none --no-checkout --depth=1 --branch 116.0.5845.188
# https://github.com/chromium/chromium` (v8-d8.sh ya deja uno en <carpeta>/chromium).
import subprocess, sys, os
bc, rev, cr, out = sys.argv[1:5]
os.makedirs(out, exist_ok=True)
names = subprocess.run(['git','-C',bc,'ls-tree','--name-only',rev,'patches/'],capture_output=True,text=True,check=True).stdout.split()
names = [n for n in names if n.endswith('.patch')]
# read all patches in one batch
inp = ''.join(f'{rev}:{n}\n' for n in names)
p = subprocess.run(['git','-C',bc,'cat-file','--batch'],input=inp.encode(),capture_output=True,check=True).stdout
pos=0; contents={}
for n in names:
    hdr_end=p.index(b'\n',pos); size=int(p[pos:hdr_end].split()[2]); body=p[hdr_end+1:hdr_end+1+size]; pos=hdr_end+1+size+1
    contents[n]=body
targets={}; new=set()
for n,b in contents.items():
    t=None
    for line in b.split(b'\n')[:8]:
        if line.startswith(b'+++ b/'): t=line[6:].decode()
        if line.startswith(b'new file mode'): new.add(n)
    targets[n]=t
paths=sorted({t for n,t in targets.items() if t and n not in new})
subprocess.run(['git','-C',cr,'sparse-checkout','set','--no-cone']+['/'+x for x in paths]+['/build/','/buildtools/','/tools/clang/'],check=True)
subprocess.run(['git','-C',cr,'checkout','-q'],check=False)
bad=[]
for n in names:
    t=targets[n]; f=os.path.join(out,n.replace('/','_')); open(f,'wb').write(contents[n])
    if t is None: bad.append((n,'sin cabecera')); continue
    if n in new:
        if os.path.exists(os.path.join(cr,t)): bad.append((n,'NUEVO PERO EXISTE'))
        continue
    if not os.path.exists(os.path.join(cr,t)): bad.append((n,'SIN BASE (subrepo o fichero ausente)')); continue
    r=subprocess.run(['git','-C',cr,'apply','--check',f],capture_output=True,text=True)
    err='\n'.join(l for l in r.stderr.splitlines() if not l.startswith('warning'))
    if r.returncode!=0: bad.append((n,'NO APLICA: '+err[:200]))
for n,why in bad: print(n,'|',why)
print(f'{rev}: {len(names)} parches, {len(bad)} problemas')
