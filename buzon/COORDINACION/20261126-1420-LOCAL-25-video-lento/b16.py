import json,glob,re,statistics as st,itertools,math
def datos(d):
    c=[c for c in json.load(open(d+'/resultados.json'))['casos'] if 'fps_seg' in c][0]; v=c['video']
    ok=all(v[k].get('resolucion')=='1920x1080@60' for k in ('carga','inicio','fin'))
    f=[x if x is not None else 0 for x in c['fps_seg']]
    return ok,f,v
sel={}
for d in sorted(glob.glob('vb16-esc2-*-conductor')):
    m=re.match(r'vb16-esc2-(\d+)-(e1[dx])(.*)-conductor',d); n,ver,suf=m.groups()
    ok,f,v=datos(d)
    if ok: sel[n]=(d,ver,f,v)   # orden alfabético: las -bN después del original
fil=[]
for n in sorted(sel):
    d,ver,f,v=sel[n]; l55=sum(1 for x in f[15:] if x<55); p1=v['inicio']['perdidos']-v['carga']['perdidos']; p2=v['fin']['perdidos']-v['inicio']['perdidos']
    fil.append((n,ver,l55,p2)); print(f'| {d[:-10]} | {ver} | {l55} | {p1} | {p2} | {st.median(f[15:]):.1f} |')
print('válidas',len(fil),'faltan',sorted(set(f'{i:02d}' for i in range(1,33))-set(sel)))
for k,nom in ((2,'s lentos'),(3,'perdidos s15→fin')):
    a=[x[k] for x in fil if x[1]=='e1d']; b=[x[k] for x in fil if x[1]=='e1x']
    tot=a+b; n1=len(a); o=sorted(tot); r2={v:(o.index(v)*2+1+o.count(v)) for v in set(tot)}  # 2*rango medio
    w=[r2[x] for x in tot]; W=sum(r2[x] for x in a); E=n1*sum(w)/len(w)
    from collections import defaultdict
    dp=[defaultdict(int) for _ in range(n1+1)]; dp[0][0]=1
    for x in w:
        for k in range(n1,0,-1):
            for sm,c in list(dp[k-1].items()): dp[k][sm+x]+=c
    N=sum(dp[n1].values()); p=sum(c for sm,c in dp[n1].items() if abs(sm-E)>=abs(W-E)-1e-9)/N
    U=W/2-n1*(n1+1)/2
    print(nom,'e1d',a,'med',st.median(a),'| e1x',b,'med',st.median(b),'| U',U,'p',round(p,3),'| limpias',sum(1 for x in a if x==0),'de',len(a),'/',sum(1 for x in b if x==0),'de',len(b))
