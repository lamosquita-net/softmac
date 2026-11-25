# LOCAL-25 · vídeo (b): por pasada, segundos hasta que Aquarium 5000 se asienta (3 s seguidos ≥ 58), fps de 0-15 s y 15-45 s,
# y fotogramas perdidos del vídeo: durante la carga (carga→inicio, s15) y después (inicio→fin).
import json,glob,statistics as st,sys
pre = sys.argv[1] if len(sys.argv)>1 else 'e1vib'
res={}
print('| Pasada | Versión | s hasta asentarse | med. fps 0–15 s | med. fps 15–45 s | perdidos carga→s15 | perdidos s15→fin | vídeo |\n|---|---|---|---|---|---|---|---|')
for d in sorted(glob.glob(f'{pre}-*-conductor')):
    c=[c for c in json.load(open(d+'/resultados.json'))['casos'] if 'fps_seg' in c][0]
    f=[x if x is not None else 0 for x in c['fps_seg']]; v=c['video']
    asi=next((i for i in range(len(f)-2) if min(f[i:i+3])>=58), None)
    p1=v['inicio']['perdidos']-v['carga']['perdidos']; p2=v['fin']['perdidos']-v['inicio']['perdidos']
    ver=d.split('-')[-2]
    res.setdefault(ver,[]).append((asi,p1,p2))
    print(f"| {d[:-10]} | {ver} | {asi} | {st.median(f[:15]):.1f} | {st.median(f[15:]):.1f} | {p1} | {p2} | {v['fin']['resolucion']} |")
print()
for ver,x in res.items():
    print(f"- {ver}: s hasta asentarse {[a for a,_,_ in x]} (mediana {st.median([a if a is not None else 99 for a,_,_ in x])}); perdidos en la carga {[p for _,p,_ in x]} (mediana {st.median([p for _,p,_ in x])}); después {[p for _,_,p in x]}")
