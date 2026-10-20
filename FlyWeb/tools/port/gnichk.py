#!/usr/bin/env python3
# gnichk.py <área>: entradas "x.cc"/"x.h" de los .gni del área que no existen ni en el área ni en la 116 (cr116).
import sys,os,re,subprocess
W=f'/tmp/claude-0/port/w-{sys.argv[1]}'; C='/home/user/cr116'
os.chdir(W)
gn=subprocess.run(['git','ls-files','*.gni','*.gn'],capture_output=True,text=True).stdout.split()
for g in gn:
    d=os.path.dirname(g)
    for n,l in enumerate(open(g),1):
        for m in re.findall(r'"([^"$:]+\.(?:cc|h|idl|mm))"',l):
            p=m[2:] if m.startswith('//') else os.path.normpath(os.path.join(d,m))
            if not (os.path.exists(p) or os.path.exists(os.path.join(C,p)) or os.path.exists('/home/user/brave-core/patches/'+p.replace('/','-')+'.patch')):
                print(f'{g}:{n}: {m}')
