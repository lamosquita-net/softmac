"""B2 en papel (FM.55): clasifica los parches y envoltorios de brave-core 1.69 que siguen en FlyWeb y NO existen en 1.98.63.

Uso: python3 -I b2-ausentes.py SALIDA.tsv
Necesita (rutas editables abajo):
  BC   clon de lamosquita-net/brave-core con el remoto `up` = brave/brave-core y las etiquetas v1.69.168 y v1.98.63
       (git fetch --filter=blob:none --depth=1 up tag v1.69.168 tag v1.98.63) y la rama origin/flyweb
  WT69/WT98  worktrees dispersos de las dos etiquetas (sparse-checkout de /patches/ y /chromium_src/)
  CR   repositorio bare con las etiquetas 128.0.6613.138 y 156.0.8078.80 de github.com/chromium/chromium
       (git fetch --filter=blob:none --depth=1 o tag ...), solo para listar nombres de fichero.
Clasificación por heurística (ver brave-propio.md §11): el resultado es una propuesta para revisar a mano.
"""
import subprocess, re, os, sys, collections, csv
BC='/home/user/lamosquita-net/brave-core'
WT69='/home/user/work/wt-v1.69.168'; WT98='/home/user/work/wt-v1.98.63'
CR='/home/user/work/cr'
T128,T156='128.0.6613.138','156.0.8078.80'

def sh(*a,**k): return subprocess.check_output(a,**k).decode('utf8','replace')
def tree(repo,ref,*paths):
    out=sh('git','-C',repo,'ls-tree','-r',ref,*paths)
    d={}
    for l in out.splitlines():
        meta,p=l.split('\t',1); d[p]=meta.split()[2]
    return d
def crnames(tag): return set(sh('git','-C',CR,'ls-tree','-r','--name-only',tag).splitlines())

fly=tree(BC,'origin/flyweb','patches','chromium_src')
a69=tree(BC,'v1.69.168','patches','chromium_src')
a98=tree(BC,'v1.98.63','patches','chromium_src')
c128,c156=crnames(T128),crnames(T156)
n128={p.replace('/','-')+'.patch':p for p in c128}
base156=collections.defaultdict(list)
for p in c156: base156[os.path.basename(p)].append(p)
base128={os.path.basename(p) for p in c128}

PLAT=re.compile(r'(^|[/_-])(android|ios|win|win32|windows|linux|chromeos|chromeos_ash|lacros|ash|cros|fuchsia|jni)([/_.-]|$)')
FEAT=[('wallet',r'wallet|ethereum|solana|zcash|bitcoin|filecoin|decentralized_dns|web3|ledger'),
 ('rewards/ads',r'rewards|brave_ads|(^|/)ads(/|_)|bat_ads|challenge_bypass|skus|greaselion|referral|ntp_background|sponsored'),
 ('leo/ai',r'ai_chat|ai_rewriter|leo|aichat|ai_.*chat'),('vpn',r'vpn'),('news',r'brave_news|(^|[/_-])news([/_-])'),
 ('ipfs',r'ipfs'),('p3a/stats',r'p3a|brave_stats|misc_metrics|web_discovery|federated'),('talk',r'brave_talk|(^|[/_-])talk'),
 ('player/psst/webcompat',r'brave_player|psst|webcompat|day_zero|script_injector'),
 ('tor',r'(^|[/_-])tor([/_-]|$)|onion'),('speedreader',r'speedreader|distill'),('playlist',r'playlist'),('sidebar',r'sidebar'),
 ('webtorrent/wayback/commander/otr',r'webtorrent|wayback|commander|request_otr|brave_search')]
FEAT=[(n,re.compile(p)) for n,p in FEAT]
def feat(s):
    s=s.lower()
    for n,rx in FEAT:
        if rx.search(s): return n
    return ''
def norm(l): return re.sub(r'\s+',' ',l).strip()
def lines_of(path,is_patch):
    try: txt=open(path,encoding='utf8',errors='replace').read()
    except Exception: return []
    out=[]
    for l in txt.splitlines():
        if is_patch:
            if not l.startswith('+') or l.startswith('+++'): continue
            l=l[1:]
        n=norm(l)
        if len(n)>=14 and not n.startswith(('//','#include','#if','#endif','#pragma','#define','#else','/*','*')): out.append(n)
    return out
# conjunto de líneas de 1.98 (patches + chromium_src); para cada línea, un fichero donde está
idx98={}
for root in ('patches','chromium_src'):
    for dp,_,fs in os.walk(os.path.join(WT98,root)):
        for f in fs:
            full=os.path.join(dp,f); rel=os.path.relpath(full,WT98)
            for n in lines_of(full,root=='patches'): idx98.setdefault(n,rel)
rows=[]
for p in sorted(set(fly)&set(a69)-set(a98)):
    if p.startswith('patches/v8/') or not (p.startswith('patches/') or p.startswith('chromium_src/')): pass
    kind='parche' if p.startswith('patches/') else 'envoltorio'
    if kind=='parche':
        name=os.path.basename(p); tgt=n128.get(name,'?')
    else:
        tgt=p[len('chromium_src/'):]
    e128=tgt in c128; e156=tgt in c156
    # parche del que se ocupa ahora 1.98 para el mismo objetivo con otra forma
    alt=''
    if kind=='parche':
        a='chromium_src/'+tgt
        if a in a98: alt=a
    else:
        a='patches/'+tgt.replace('/','-')+'.patch'
        if a in a98: alt=a
    ren=''
    if not e156 and e128: ren=';'.join(base156.get(os.path.basename(tgt),[])[:3])
    L=lines_of(os.path.join(WT69,p),kind=='parche')
    found=collections.Counter(idx98[l] for l in L if l in idx98)
    frac=(sum(found.values())/len(L)) if L else None
    where=found.most_common(1)[0][0] if found else ''
    f=feat(p)+'' or feat(tgt)
    if not f:  # por contenido: includes de brave/<función>
        txt=open(os.path.join(WT69,p),encoding='utf8',errors='replace').read()
        mm=set(feat(m) for m in re.findall(r'brave/([A-Za-z0-9_/\.]+)',txt)); mm.discard('')
        f=','.join(sorted(mm))
    plat=''
    m=PLAT.search(tgt.lower()) if tgt!='?' else None
    if m: plat=m.group(2)
    rows.append(dict(tipo=kind,fichero=p,objetivo=tgt,e128=int(e128),e156=int(e156),plataforma=plat,funcion=f,
        modificado_flyweb=int(fly[p]!=a69[p]),otra_forma_en_198=alt,candidatos_renombre=ren,
        lineas_brave=len(L),frac_en_198=('' if frac is None else '%.2f'%frac),donde_198=where))
with open(sys.argv[1],'w',newline='') as fh:
    w=csv.DictWriter(fh,fieldnames=list(rows[0]),delimiter='\t'); w.writeheader(); w.writerows(rows)
print(len(rows),'filas')
