import json,glob,statistics as st,os
E='/Volumes/googledrive/clientes/software/entregas/local24'
print('| Pasada | Versión | válida | Metal device by id | descodificador | mediana fps s5→fin | perdidos s15→fin | perdidos carga→s15 | racha máx < 55 tras s3 |\n|---|---|---|---|---|---|---|---|---|')
res={}
for d in sorted(glob.glob(E+'/ml-e1-esc2-*-conductor')):
    n=os.path.basename(d)[:-10]; ver=n.split('-')[-1]
    c=[c for c in json.load(open(d+'/resultados.json'))['casos'] if 'fps_seg' in c][0]; v=c['video']; f=[x or 0 for x in c['fps_seg']]
    md=0
    try: md=sum(1 for l in open(E+'/'+n+'/metal-device.txt') if 'Metal device by id' in l)
    except Exception: md='?'
    dec=v.get('descodificador',{}); dn=dec.get('kVideoDecoderName'); pl=dec.get('kIsPlatformVideoDecoder')
    ok=all(v[k]['resolucion']=='1920x1080@60' for k in ('carga','inicio','fin')) and dn=='VideoToolboxVideoDecoder' and pl=='true' and md==(2 if ver=='e1x' else 0)
    r=m=0
    for x in f[2:]:
        r=r+1 if x<55 else 0; m=max(m,r)
    med=st.median(f[4:]); p2=v['fin']['perdidos']-v['inicio']['perdidos']; p1=v['inicio']['perdidos']-v['carga']['perdidos']
    print(f'| {n} | {ver} | {"sí" if ok else "NO"} | {md} | {dn} ({pl}) | {med:.1f} | {p2} | {p1} | {m} |')
    if ok: res.setdefault(ver,[]).append((med,p2,m))
for ver,x in sorted(res.items()):
    print(f'- {ver}: {len(x)} válidas; medianas {[round(a,1) for a,_,_ in x]} (mediana de medianas {st.median([a for a,_,_ in x]):.1f}); perdidos s15→fin {[b for _,b,_ in x]} (total {sum(b for _,b,_ in x)}); racha máx {max(c for _,_,c in x)}')
