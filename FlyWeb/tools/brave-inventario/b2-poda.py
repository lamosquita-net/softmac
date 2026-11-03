"""P1/P2 en papel: plan de poda de brave-core `flyweb` (solo escritorio) con lo que cuelga de ello.

Uso: python3 -I b2-poda.py CHECKOUT_FLYWEB SALIDA_DIR
Reutiliza las reglas de p0.py (muertas por ruta). Produce en SALIDA_DIR:
  dirs.tsv    directorios cuyo contenido (código+pruebas de escritorio) es >=90 % de una función muerta: candidatos a `git rm -r`
  costuras.tsv  ficheros VIVOS que mencionan (include, deps de GN, DEPS, cadena) una función muerta: las ediciones a mano
  gn.tsv      líneas de BUILD.gn/*.gni/DEPS con rutas de funciones muertas, fuera de los propios directorios muertos
Heurística (ruta + `brave/<ruta>` / `//brave/<ruta>` en el contenido). Revisar a mano antes de borrar.
"""
import os, re, sys, collections, csv, subprocess
R=sys.argv[1]; OUT=sys.argv[2]; os.makedirs(OUT,exist_ok=True)
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
DEAD=[('wallet',r'brave_wallet|wallet|ethereum|solana|zcash|bitcoin|filecoin|decentralized_dns|crypto_wallets|trezor|web3|ledger_bridge|unstoppable'),
 ('rewards/ads/skus',r'brave_rewards|rewards|brave_ads|(^|/)ads(/|_)|bat_ads|challenge_bypass|(^|/)skus|brave_adaptive_captcha|greaselion|brave_referrals|referral|ad_notification|ntp_background_images|sponsored'),
 ('leo/ai',r'ai_chat|ai_rewriter|leo_assistant|/leo/|brave_leo|aichat'),('vpn',r'brave_vpn|(^|/)vpn'),
 ('news',r'brave_news|(^|/)news(/|_)'),('ipfs',r'ipfs'),('player/psst/webcompat',r'brave_player|psst|webcompat|day_zero|script_injector'),
 ('p3a/stats',r'p3a|brave_stats|misc_metrics|brave_federated|time_period_storage|web_discovery'),('talk',r'brave_talk|(^|/)talk')]
DEAD=[(n,re.compile(p)) for n,p in DEAD]
def dead(p):
    p=p.lower()
    for n,rx in DEAD:
        if rx.search(p): return n
    return ''
files=[f for f in subprocess.check_output(['git','-C',R,'ls-files','-z']).decode('utf8','replace').split('\0') if f]
desk=[f for f in files if not f.startswith(('android/','ios/','third_party/','patches/','chromium_src/')) and not re.search(r'\.(png|jpg|svg|icns|woff2?|ttf|xtb|json|pdf)$',f)]
# 1) directorios muertos
cnt=collections.defaultdict(lambda:[0,0,''])
for f in desk:
    parts=f.split('/')
    for d in range(2,min(len(parts),5)):
        k='/'.join(parts[:d]); c=cnt[k]; c[0]+=1
        n=dead(k+'/')
        if n: c[1]+=1; c[2]=n
dirs=[(k,v) for k,v in cnt.items() if v[0]>=3 and v[1]/v[0]>=0.9]
# quitar subdirectorios de otros ya listados
dirs.sort(); keep=[]
for k,v in dirs:
    if keep and k.startswith(keep[-1][0]+'/'): continue
    keep.append((k,v))
with open(os.path.join(OUT,'dirs.tsv'),'w') as fh:
    fh.write('dir\tficheros\tfuncion\n')
    for k,v in keep: fh.write(f'{k}\t{v[0]}\t{v[2]}\n')
deadd=tuple(k+'/' for k,_ in keep)
# 2) costuras: ficheros vivos que mencionan funciones muertas
INC=re.compile(rb'(?:brave/|//brave/)((?:components|browser|common|renderer|utility|services|app|chromium_src|ui|build|test)/[A-Za-z0-9_\-./:]+)')
seam=[]; gn=[]
for f in desk:
    if f.startswith(deadd) or dead(f): continue
    if re.search(r'\.(grd|grdp|xtb|md|txt|py|patch)$',f) and not f.endswith(('.gni',)): continue
    try: data=open(os.path.join(R,f),'rb').read()
    except Exception: continue
    if len(data)>3_000_000: continue
    refs=collections.Counter()
    for m in INC.finditer(data):
        r=m.group(1).decode('utf8','ignore')
        n=dead(r)
        if n: refs[n]+=1
        if n and f.endswith(('BUILD.gn','.gni','DEPS')):
            gn.append((f,m.group(0).decode('utf8','ignore')[:100],n))
    if refs: seam.append((f,';'.join(f'{k}:{v}' for k,v in refs.most_common())))
with open(os.path.join(OUT,'costuras.tsv'),'w') as fh:
    fh.write('fichero\tfunciones(n referencias)\n')
    for f,r in sorted(seam): fh.write(f'{f}\t{r}\n')
with open(os.path.join(OUT,'gn.tsv'),'w') as fh:
    fh.write('fichero\treferencia\tfuncion\n')
    for t in sorted(set(gn)): fh.write('\t'.join(t)+'\n')
print(len(keep),'directorios,',len(seam),'costuras,',len(set(gn)),'lineas GN/DEPS')
