# m3t.py <lista> [omitir…]: para cada commit de upstream de la lista (formato de mark.py: «<commit> fecha asunto» y debajo «  <fichero de test>»), fusiona
# a tres bandas sus ficheros de test en w-all (base = fichero en c^, suyo = en c, nuestro = w-all) y hace commit "<c> ..." en w-all.
# Con conflictos, deja los marcadores, lo dice y se para (para resolver a mano y seguir con el siguiente).
import subprocess,sys,os,tempfile
CH='/home/user/chromium/hist'; W='/tmp/claude-0/port/w-all'
def g(*a,cwd=CH,inp=None):
    r=subprocess.run(['git','-c','diff.renames=false']+list(a),cwd=cwd,capture_output=True,input=inp)
    return r
skip=set(sys.argv[2:])
done=set(l.split()[0] for l in g('log','--format=%s',cwd=W).stdout.decode().splitlines() if l)
cur=None; items=[]
for l in open(sys.argv[1]):
    if not l.startswith('  '): cur=l.split()[0]; items.append((cur,l.strip(),[]))
    else: items[-1][2].append(l.strip())
for c,desc,files in items:
    if c in done or c in skip: continue
    conf=[]
    for f in files:
        b=g('show',f'{c}^:{f}'); t=g('show',f'{c}:{f}')
        p=os.path.join(W,f)
        if t.returncode!=0:   # borrado en upstream
            if os.path.exists(p): os.remove(p); print('  BORRADO',f)
            continue
        if b.returncode!=0:   # nuevo en upstream
            if not os.path.exists(p):
                os.makedirs(os.path.dirname(p),exist_ok=True); open(p,'wb').write(t.stdout); print('  NUEVO',f); continue
            base=b''
        else: base=b.stdout
        if not os.path.exists(p): print('  FALTA (no está en w-all ni en la 128)',f); continue
        with tempfile.TemporaryDirectory() as d:
            open(d+'/b','wb').write(base); open(d+'/t','wb').write(t.stdout)
            r=subprocess.run(['git','merge-file','-L','w-all','-L','base','-L',c,p,d+'/b',d+'/t'],capture_output=True)
            if r.returncode!=0: conf.append(f'{f} ({r.returncode})')
    print(c,desc[11:90],'CONFLICTOS: '+' '.join(conf) if conf else 'ok')
    if conf: sys.exit(1)
    g('add','-A',cwd=W); g('-c','user.email=x','-c','user.name=x','commit','-qm',f'{c} {desc[11:]}',cwd=W)
