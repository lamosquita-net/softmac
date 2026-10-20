#!/usr/bin/env python3
# barrido.py <área>: frente a la 1.15.1 (base115/ = 116 + parches de fa4fae392f), (1) identificadores que desaparecen
# de las cabeceras cambiadas y (2) funciones que pierden una aridad, con sus usos en la 116 fuera del área. MOTOR-13.
import subprocess,re,os,sys
A=sys.argv[1]; W=f'/tmp/claude-0/port/w-{A}'; C='/home/user/cr116'; B='/tmp/claude-0/port/base115'
g=lambda *a: subprocess.run(['git']+list(a),capture_output=True,text=True,cwd=W).stdout
def clean(t):
    t=re.sub(r'//[^\n]*','',t); t=re.sub(r'/\*.*?\*/','',t,flags=re.S); return re.sub(r'"(\\.|[^"\\])*"','""',t)
idre=re.compile(r'\b[A-Za-z_][A-Za-z0-9_]{5,}\b')
dre=re.compile(r'\b([A-Z]\w+)\s*\(([^;{}()]*(?:\([^;{}()]*\)[^;{}()]*)*)\)\s*(?:const)?\s*(?:override|final)?\s*(?:=\s*0)?\s*[;{:]')
def arities(t):
    r={}
    for m in dre.finditer(clean(t)):
        n,p=m.group(1),m.group(2).strip()
        if not p or p=='void': lo=hi=0
        else:
            d=0;parts=['']
            for ch in p:
                if ch in '<([': d+=1
                elif ch in '>)]': d-=1
                if ch==',' and d==0: parts.append('')
                else: parts[-1]+=ch
            hi=len(parts); lo=sum(1 for x in parts if '=' not in x)
        r.setdefault(n,set()).add((lo,hi))
    return r
area=set(g('ls-files').split())
hs=[f for f in area if f.endswith('.h') and os.path.exists(os.path.join(B,f))]
allnow=set()
for f in area:
    if f.endswith(('.h','.cc','.json5','.idl','.tmpl','.py')) and os.path.exists(os.path.join(W,f)):
        allnow|=set(idre.findall(clean(open(os.path.join(W,f),errors='ignore').read())))
removed={}; flag={}
for h in hs:
    b=open(os.path.join(B,h),errors='ignore').read(); a=open(os.path.join(W,h),errors='ignore').read()
    if a==b: continue
    for i in set(idre.findall(clean(b)))-allnow: removed.setdefault(i,h)
    ab,aa=arities(b),arities(a)
    for n,ar in ab.items():
        if n not in aa: continue
        for (lo,hi) in ar:
            if not any(alo<=k<=ahi for (alo,ahi) in aa[n] for k in range(lo,hi+1)): flag.setdefault(n,set()).add(h)
names=set(removed)|set(flag)
out=subprocess.run(['grep','-rlwE','|'.join(sorted(names)),C+'/third_party/blink/renderer','--include=*.cc','--include=*.h','--include=*.mm'],capture_output=True,text=True).stdout.split()
NOISE={'Contains','Set','Get','Evaluate','Width','Height','Create','Trace'}
for f in sorted(out):
    rel=f[len(C)+1:]
    if rel in area: continue
    pp='/home/user/brave-core/patches/'+rel.replace('/','-')+'.patch'
    if os.path.exists(pp):
        tmp='/tmp/claude-0/port/barr.tmp'
        open(tmp,'w').write(open(f,errors='ignore').read())
        subprocess.run(['patch','-s','-o',tmp+'.o',tmp,pp],capture_output=True)
        t=clean(open(tmp+'.o',errors='ignore').read()) if os.path.exists(tmp+'.o') else clean(open(f,errors='ignore').read())
        if os.path.exists(tmp+'.o'): os.remove(tmp+'.o')
    else:
        t=clean(open(f,errors='ignore').read())
    r=[i for i in removed if re.search(r'\b'+i+r'\b',t)]
    a=[n for n in flag if n not in NOISE and re.search(r'\b'+n+r'\(',t)]
    if r or a: print(rel.replace('third_party/blink/renderer/',''),'| quitados:',' '.join(r),'| aridad:',' '.join(a))
