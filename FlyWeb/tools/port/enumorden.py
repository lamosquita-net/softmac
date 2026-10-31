#!/usr/bin/env python3
r"""Enums con valores fuera de orden delante de un contador implícito (MOTOR-41, 31-10-2026).

Uso: enumorden.py <parche>...  Aplica cada parche a la 128 y avisa si un miembro sin `=` (p. ej. kNumberOfFeatures,
kMaxValue implícito) vale menos o igual que un valor explícito anterior: un bitset o array dimensionado con él
se queda corto (2.6.0: 5040/5041 tras 5374 en web_feature.mojom, aborto de UseCounter en Speedometer).
Candidatos: `grep -l "^+ *k[A-Za-z0-9_]* = [0-9]\+," patches/*.mojom.patch patches/*.h.patch`.
"""
import sys,re,os,subprocess,tempfile,urllib.request
base='128.0.6613.138'
for p in sys.argv[1:]:
    t=open(p).read(); m=re.match(r'diff --git a/(\S+) b/',t); path=m.group(1)
    with tempfile.TemporaryDirectory() as d:
        dst=os.path.join(d,path); os.makedirs(os.path.dirname(dst))
        try: data=urllib.request.urlopen('https://raw.githubusercontent.com/chromium/chromium/%s/%s'%(base,path)).read()
        except Exception: print('nofetch',path); continue
        open(dst,'wb').write(data)
        r=subprocess.run(['git','apply',os.path.abspath(p)],cwd=d,capture_output=True)
        if r.returncode: print('noapply',path); continue
        s=open(dst,errors='replace').read()
    s=re.sub(r'//[^\n]*','',s)
    for em in re.finditer(r'enum\s+(?:class\s+)?(\w+)[^{;]*\{([^}]*)\}',s):
        name,body=em.group(1),em.group(2)
        cur=-1; mx=-1; mxn=None; bad=[]
        for e in [x.strip() for x in body.split(',') if x.strip()]:
            e=re.sub(r'\[[^\]]*\]','',e).strip()
            mm=re.match(r'(\w+)\s*(?:=\s*(.+))?$',e,re.S)
            if not mm: continue
            n,v=mm.group(1),mm.group(2)
            if v is None: cur+=1
            else:
                v=v.strip()
                if re.fullmatch(r'-?\d+',v): cur=int(v)
                elif re.fullmatch(r'0x[0-9a-fA-F]+',v): cur=int(v,16)
                else: cur=None; break
            if v is None and cur<=mx: bad.append((n,cur,mxn,mx))
            if cur>mx: mx,mxn=cur,n
        if cur is not None and bad: print(path,name,bad)
