#!/usr/bin/env python3
# perdidas.py <área> [commit-upstream…]: líneas que el diff traducido añade y que no están en el fichero del área
# tras su commit (pérdida silenciosa en m3/autores). Agrupa en bloques; solo muestra bloques de >= MIN líneas. MOTOR-13.
import sys,subprocess,re,os
A=sys.argv[1]; W=f'/tmp/claude-0/port/w-{A}'; P='/tmp/claude-0/port'
MIN=int(os.environ.get('MIN','3')); only=set(sys.argv[2:])
SKIP=re.compile(r'selectlist|permission_shadow|selectmenu|about_flags|flag_descriptions|flag-metadata|android_webview|fieldtrial|web_tests/|_test\.cc$|_unittest\.cc$|tools/metrics')
def g(*a): return subprocess.run(['git','-C',W]+list(a),capture_output=True,text=True).stdout
for l in g('log','--format=%H %s').split('\n'):
    if not l: continue
    h,s=l.split(' ',1); c=s.split()[0]
    if not re.fullmatch(r'[0-9a-f]{11}',c) or (only and c not in only): continue
    dp=f'{P}/{c}.ng.diff'
    if not os.path.exists(dp): continue
    cur=None; adds={}
    for ln in open(dp,errors='replace'):
        m=re.match(r'^\+\+\+ b/(\S+)',ln)
        if m: cur=m.group(1); adds.setdefault(cur,[]); continue
        if ln.startswith('@@'): adds.get(cur,[]).append(None) if cur else None; continue
        if cur and ln.startswith('+') and not ln.startswith('+++'): adds[cur].append(ln[1:].rstrip('\n'))
    out=[]
    for f,L in adds.items():
        if SKIP.search(f): continue
        txt=g('show',f'{h}:{f}')
        if not txt: continue
        have=set(x.strip() for x in txt.split('\n'))
        blk=[]
        def flush():
            real=[x for x in blk if len(x.strip())>3 and not x.strip().startswith('//')]
            if len(real)>=MIN: out.append((f,blk[:]))
            blk.clear()
        for x in L:
            if x is None or x.strip() in have or not x.strip(): 
                if x is None or x.strip(): flush()
                continue
            blk.append(x)
        flush()
    if out:
        print(f'== {c} {s[12:80]}')
        for f,b in out:
            hd=set(x.strip() for x in g('show',f'HEAD:{f}').split('\n'))
            k=sum(1 for x in b if x.strip() in hd)
            print(f'  {f.replace("third_party/blink/renderer/","")}: {len(b)} líneas (en HEAD {k}): {b[0].strip()[:90]}')
