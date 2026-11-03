"""B2 con donante: qué ficheros de patches/ y chromium_src/ de `flyweb` se pueden sustituir por los de Brave 1.98.63 y cuáles chocan.
Uso: python3 -I b2-donante.py SALIDA.tsv   (necesita BC con origin/flyweb y las etiquetas v1.69.168 y v1.98.63; no escribe en el repo)
Por cada fichero que está en flyweb Y en 1.69 Y en 1.98:
  igual_198      el blob de flyweb ya es el de 1.98 (nada que hacer)
  sustituible    flyweb == 1.69 (FlyWeb no lo tocó) y 1.98 lo cambió: se puede copiar el de 1.98 (el donante ya está adaptado a Chromium 156)
  choque         flyweb != 1.69 (FlyWeb lo modificó) y 1.98 lo cambió: hay que fusionar a mano (3 vías: 1.69 → flyweb, 1.69 → 1.98)
  sin_cambio_198 1.98 == 1.69 y FlyWeb lo tocó: se queda el de FlyWeb
Y los que ya no están en 1.98 (los 138 + 418 de b2-ausentes.py) van aparte: ahí no hay donante.
Cautela [I]: un donante de 1.98 puede incluir cabeceras de brave/ que solo existen en el código de 1.98; en la compilación saldrá como «file not found: brave/...» (b2-cuenta.py lo separa).
"""
import subprocess, sys, csv, collections
BC='/home/user/lamosquita-net/brave-core'
def tree(ref):
    d={}
    for l in subprocess.check_output(['git','-C',BC,'ls-tree','-r',ref,'patches','chromium_src']).decode().splitlines():
        m,p=l.split('\t',1); d[p]=m.split()[2]
    return d
f,a,b=tree('origin/flyweb'),tree('v1.69.168'),tree('v1.98.63')
rows=[]; c=collections.Counter()
for p in sorted(set(f)&set(a)):
    kind='parche' if p.startswith('patches/') else 'envoltorio'
    if p not in b: est='ausente_198'
    elif f[p]==b[p]: est='igual_198'
    elif f[p]==a[p]: est='sustituible'
    elif a[p]==b[p]: est='sin_cambio_198'
    else: est='choque'
    rows.append((kind,p,est)); c[(kind,est)]+=1
with open(sys.argv[1],'w',newline='') as fh:
    w=csv.writer(fh,delimiter='\t'); w.writerow(['tipo','fichero','estado']); w.writerows(rows)
for k,v in sorted(c.items()): print(v,k)
