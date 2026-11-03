"""B2: cuenta «ficheros rotos» a partir del registro de una compilación de brave-core contra el árbol 156.

Uso: python3 -I b2-cuenta.py REGISTRO.log [LISTA_PARCHEADOS.txt] > resumen.tsv
  REGISTRO.log        salida de `autoninja -C out/B2 -k 0 brave 2>&1 | tee REGISTRO.log` (-k 0 = seguir tras el primer error)
                      y, antes, de `gn gen out/B2 --check 2>&1` si se quiere contar también los errores de GN (el mismo formato `ERROR at //...`)
  LISTA_PARCHEADOS    ficheros de Chromium que tocan los parches de Brave (uno por línea, ruta relativa a src/); sale de
                      `ls patches/ | ...` o de `git -C src diff --name-only` tras `apply_patches` (opcional)
Qué cuenta (cada fichero, una vez, en la primera categoría que cumpla):
  gn            `ERROR at //ruta:línea` (error de GN)
  brave_falta   `fatal error: '...' file not found` cuya cabecera empieza por brave/ o es de un fichero movido (probable: donante 1.98 o poda incompleta)
  brave         error en un fichero de src/brave/ (código de Brave, fuera de chromium_src)
  envoltorio    error en un fichero de src/brave/chromium_src/
  parcheado     error en un fichero de Chromium que tiene parche de Brave
  chromium_via_brave  error en un fichero de Chromium sin parche, pero con un fichero de brave/ en la pila `In file included from` (cabecera de Chromium cambiada)
  otro          el resto
`ruta_rota` = el fichero donde el compilador marca el error (no la unidad de compilación que lo incluía).
Es una **medida por fichero**, no por error: un fichero con 40 errores cuenta 1. Los errores de enlace (`ld: ... undefined`) se cuentan aparte por símbolo.
"""
import sys, re, collections
log=open(sys.argv[1],encoding='utf8',errors='replace').read().splitlines()
patched=set(l.strip() for l in open(sys.argv[2])) if len(sys.argv)>2 else set()
ERR=re.compile(r'^(?:\.\./)*(?:src/)?([^\s:][^:]*?):(\d+):(?:\d+:)?\s*(?:fatal )?error:\s*(.*)$')
INC=re.compile(r'^In file included from (?:\.\./)*(?:src/)?([^:\s]+):\d+')
GN=re.compile(r'^ERROR at //([^:]+):(\d+)')
NOTFOUND=re.compile(r"'([^']+)' file not found")
files={}        # ruta -> (categoría, ejemplo de error)
stack=[]
ld=collections.Counter()
for l in log:
    m=INC.match(l)
    if m: stack.append(m.group(1)); continue
    m=GN.match(l)
    if m:
        files.setdefault(m.group(1),('gn','')); stack=[]; continue
    m=re.match(r'^ld: .*undefined|^\s*"([^"]+)", referenced from',l)
    if m and m.group(1): ld[m.group(1)]+=1
    m=ERR.match(l)
    if m:
        p,_,msg=m.groups(); p=re.sub(r'^(\.\./)+','',p)
        nf=NOTFOUND.search(msg)
        if nf and (nf.group(1).startswith('brave/') or '/brave/' in nf.group(1)): cat='brave_falta'
        elif p.startswith('brave/chromium_src/'): cat='envoltorio'
        elif p.startswith('brave/'): cat='brave'
        elif p in patched: cat='parcheado'
        elif any(s.startswith('brave/') for s in stack): cat='chromium_via_brave'
        else: cat='otro'
        files.setdefault(p,(cat,msg[:100]))
        stack=[]
    elif l and not l.startswith(('In file included','   ','\t')) and not l.startswith(('In file','from ')):
        pass
c=collections.Counter(v[0] for v in files.values())
print('categoria\tficheros')
for k,v in sorted(c.items()): print(f'{k}\t{v}')
print(f'TOTAL\t{sum(c.values())}')
print(f'enlace_simbolos\t{len(ld)}')
print('\nruta_rota\tcategoria\tprimer_error')
for p,(k,m) in sorted(files.items()): print(f'{p}\t{k}\t{m}')
