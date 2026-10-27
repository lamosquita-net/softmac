#!/usr/bin/env python3
# gnirama.py <rama> [<base>]: en los .gn/.gni que parchea <rama> (con <base>, solo los que cambian desde ahí), cada
# entrada "x.cc"/"x.h"/"x.idl"/"x.mm" tiene que existir en la 116 o en un parche de fichero nuevo de la rama.
# MOTOR-13 (FM.28, pedido de COORDINACIÓN-8: la Static de F2 se paró en [0/1] por anchor_evaluator_impl.cc).
import subprocess,sys,os,re,tempfile
BC='/home/user/brave-core'; CR='/home/user/chromium/chromium'; C116='/home/user/cr116'; TAG='116.0.5845.188'
B=sys.argv[1]; base=sys.argv[2] if len(sys.argv)>2 else None
g=lambda *a,cwd=BC: subprocess.run(['git']+list(a),capture_output=True,text=True,cwd=cwd).stdout
allp=[p for p in g('ls-tree','--name-only',B,'patches/').split() if p.endswith('.patch')]
lst=[p for p in (g('diff','--name-only','--diff-filter=AM',base,B,'--','patches/').split() if base else allp) if p.endswith(('.gni.patch','.gn.patch')) and not p.startswith('patches/third_party/')]  # sin subrepos (ANGLE…)
nuevos=set(); parcheados=set()
for p in allp:
    t=g('show',f'{B}:{p}')
    m=re.search(r'^\+\+\+ b/(\S+)',t,re.M)
    if not m: continue
    parcheados.add(m.group(1))
    if re.search(r'^new file mode',t,re.M): nuevos.add(m.group(1))
def existe116(f):
    if os.path.exists(os.path.join(C116,f)): return True
    return subprocess.run(['git','cat-file','-e',f'{TAG}:{f}'],cwd=CR,capture_output=True).returncode==0
malos=0
for p in lst:
    t=g('show',f'{B}:{p}'); f=re.search(r'^\+\+\+ b/(\S+)',t,re.M).group(1)
    orig=subprocess.run(['git','show',f'{TAG}:{f}'],cwd=CR,capture_output=True,text=True).stdout
    d=tempfile.mkdtemp(); os.makedirs(os.path.join(d,os.path.dirname(f)),exist_ok=True)
    open(os.path.join(d,f),'w').write(orig)
    r=subprocess.run(['git','apply','-'],input=t,text=True,cwd=d,capture_output=True)
    if r.returncode: print(f'NO APLICA {p}'); malos+=1; continue
    dd=os.path.dirname(f)
    for n,l in enumerate(open(os.path.join(d,f)),1):
        if l.lstrip().startswith('#'): continue
        for e in re.findall(r'"([^"$:]+\.(?:cc|h|idl|mm))"',l):
            q=e[2:] if e.startswith('//') else os.path.normpath(os.path.join(dd,e))
            if q in nuevos or q in parcheados or existe116(q): continue
            print(f'FALTA {f}:{n}: {e}'); malos+=1
print(f'{B}: {len(lst)} .gn/.gni parcheados, {malos} entradas sin fichero')
sys.exit(1 if malos else 0)
