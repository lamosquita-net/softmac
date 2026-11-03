"""B2 en papel, segunda pasada: ¿el parche de Brave aplica sobre el fichero de Chromium 156? ¿el envoltorio sigue teniendo qué sobrescribir?

Uso: python3 -I b2-aplica.py ausentes ENTRADA.tsv SALIDA.tsv   ENTRADA = salida de b2-ausentes.py (los 138+418 ausentes de 1.98)
     python3 -I b2-aplica.py todos SALIDA.tsv                   los 590 parches de Brave 1.69 que siguen en FlyWeb, con el de 1.69 y, si existe, el de 1.98 (donante)
Rutas (CR, WT69, WT98) editables abajo. CR es un repositorio parcial de github.com/chromium/chromium: los blobs se bajan por lotes (`git fetch o <oids>`).
`git apply --check` sobre un único fichero (sin los demás parches): es una **cota de papel** de «el parche aplica»; no sustituye a compilar.
Columnas ap128/ap156 = 1 si aplica; ap156_c1 = aplica tolerando una línea menos de contexto (-C1); ident_faltan = identificadores de los #define del envoltorio que ya no están en 156.
"""
import subprocess, sys, os, csv, re, tempfile, shutil
CR='/home/user/work/cr'; WT69='/home/user/work/wt-v1.69.168'; WT98='/home/user/work/wt-v1.98.63'
BC='/home/user/lamosquita-net/brave-core'
T128,T156='128.0.6613.138','156.0.8078.80'
def ls(tag):
    d={}
    for l in subprocess.check_output(['git','-C',CR,'ls-tree','-r',tag]).decode().splitlines():
        m,p=l.split('\t',1); d[p]=m.split()[2]
    return d
CACHE='/home/user/work/crcache'
def cpath(tag,path): return os.path.join(CACHE,tag,path)
def prefetch(pairs):
    """Baja los ficheros de Chromium con curl en paralelo desde raw.githubusercontent.com (`git fetch <oid>` en el repo parcial iba de uno en uno: ~20 s por blob)."""
    todo=[(t,p) for t,p in sorted(set(pairs)) if not os.path.exists(cpath(t,p))]
    lst=tempfile.NamedTemporaryFile('w',delete=False)
    for t,p in todo:
        os.makedirs(os.path.dirname(cpath(t,p)),exist_ok=True); lst.write(f'{t} {p}\n')
    lst.close()
    subprocess.run(['xargs','-P','8','-L','1','sh','-c','curl -sf --retry 2 -o "$0/$1/$2" https://raw.githubusercontent.com/chromium/chromium/$1/$2 || rm -f "$0/$1/$2"',CACHE],stdin=open(lst.name),check=False)
    os.unlink(lst.name)
def blob(tp):
    f=cpath(*tp); return open(f,'rb').read() if os.path.exists(f) else None
def check(patch,path,data,extra=()):
    d=tempfile.mkdtemp()
    try:
        full=os.path.join(d,path); os.makedirs(os.path.dirname(full),exist_ok=True); open(full,'wb').write(data)
        r=subprocess.run(['git','apply','--check',*extra,patch],cwd=d,capture_output=True)
        return r.returncode==0,(r.stderr.decode('utf8','replace').strip().splitlines() or [''])[0]
    finally: shutil.rmtree(d)
t128,t156=ls(T128),ls(T156)
n128={p.replace('/','-')+'.patch':p for p in t128}
mode=sys.argv[1]
if mode=='ausentes':
    rows=[dict(x) for x in csv.DictReader(open(sys.argv[2]),delimiter='\t')]; outp=sys.argv[3]
    for x in rows: x['wt']=WT69
else:
    outp=sys.argv[2]; rows=[]
    fly=set(subprocess.check_output(['git','-C',BC,'ls-tree','-r','--name-only','origin/flyweb','patches']).decode().split('\n'))
    a69=set(subprocess.check_output(['git','-C',BC,'ls-tree','-r','--name-only','v1.69.168','patches']).decode().split('\n'))
    for p in sorted(fly&a69):
        if not p.endswith('.patch') or '/' in p[len('patches/'):]: continue
        rows.append(dict(tipo='parche',fichero=p,objetivo=n128.get(os.path.basename(p),'?'),
            e128='',e156='',wt=WT69,en198=int(os.path.exists(os.path.join(WT98,p)))))
need=[]
for x in rows:
    t=x['objetivo']; x['e128']=int(t in t128); x['e156']=int(t in t156)
    if t in t128: need.append((T128,t))
    if t in t156: need.append((T156,t))
prefetch(need)
for x in rows:
    for k in ('ap128','ap156','ap156_c1','ap156_donante','ident_total','ident_faltan','nota'): x[k]=''
    t=x['objetivo']
    if not (x['e128'] and x['e156']): continue
    full=os.path.join(x['wt'],x['fichero'])
    if x['tipo']=='parche':
        for k,tag,tt,extra in (('ap128',T128,t128,()),('ap156',T156,t156,()),('ap156_c1',T156,t156,('-C1',))):
            d=blob((tag,t))
            if d is None: x[k]='sin_blob'; continue
            ok,msg=check(full,t,d,extra); x[k]=int(ok)
            if k=='ap156' and not ok: x['nota']=msg[:140]
        if x.get('en198'):  # el parche de 1.98 sobre 156: debe aplicar (Brave compiló la 156)
            d=blob((T156,t)); ok,msg=check(os.path.join(WT98,x['fichero']),t,d); x['ap156_donante']=int(ok)
    else:
        txt=open(full,encoding='utf8',errors='replace').read()
        ids=set(re.findall(r'#define\s+([A-Za-z_][A-Za-z0-9_]*)\s+[A-Za-z_][A-Za-z0-9_]*(?:_ChromiumImpl|_BraveImpl|_Chromium|_Brave)\b',txt))
        d=blob((T156,t))
        if d is not None and ids:
            s=d.decode('utf8','replace'); miss=[i for i in ids if not re.search(r'\b'+re.escape(i)+r'\b',s)]
            x['ident_total']=len(ids); x['ident_faltan']=','.join(sorted(miss))[:200]
for x in rows: x.pop('wt',None)
keys=[]
for x in rows:
    for k in x:
        if k not in keys: keys.append(k)
with open(outp,'w',newline='') as fh:
    w=csv.DictWriter(fh,fieldnames=keys,delimiter='\t'); w.writeheader(); w.writerows(rows)
print('ok',len(rows))
