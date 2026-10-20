#!/usr/bin/env python3
# autores.py <fichero>: resuelve los conflictos de git merge-file --diff3 en los que upstream = base + algo añadido
# (al final o al principio): el resultado es área + lo añadido. Imprime cuántos resolvió y cuántos quedan. MOTOR-13.
import sys,difflib

def _del_only(base,up):
    return all(t in ('equal','delete') for t,*_ in difflib.SequenceMatcher(None,base.splitlines(True),up.splitlines(True)).get_opcodes())
def _apply_del(area,base,up):
    bl,ul=base.splitlines(True),up.splitlines(True); al=area.splitlines(True)
    for t,i1,i2,j1,j2 in reversed(difflib.SequenceMatcher(None,bl,ul).get_opcodes()):
        if t!='delete': continue
        blk=bl[i1:i2]
        pos=[k for k in range(len(al)-len(blk)+1) if al[k:k+len(blk)]==blk]
        if len(pos)!=1:
            # un bloque borrado que el área no tiene entero: si ninguna de sus líneas está, no hay nada que borrar
            if not any(l.strip() for l in blk): continue
            return None
        del al[pos[0]:pos[0]+len(blk)]
    return ''.join(al)

import re
RN={}
def _nocom(t):
    return [l.strip() for l in t.split('\n') if l.strip() and not l.strip().startswith(('//','/*','*'))]
_ID=re.compile(r'[A-Za-z_][A-Za-z0-9_]*|\S')
_KW=set('void bool int unsigned float double char auto const constexpr static inline virtual override final return if else for while switch case default break continue true false nullptr class struct enum namespace public private protected template typename using new delete this sizeof size_t wtf_size_t LayoutUnit'.split())
def _renmap(base,up):
    tb,tu=_ID.findall(base),_ID.findall(up)
    if len(tb)!=len(tu) or tb==tu: return None
    mp={}
    for x,y in zip(tb,tu):
        if x==y: continue
        if not (re.match(r'[A-Za-z_]',x) and re.match(r'[A-Za-z_]',y)): return None
        # FM.28 (MOTOR-13): un cambio de palabra clave o tipo básico no es un renombre (void→bool).
        if x in _KW or y in _KW: return None
        if mp.get(x,y)!=y: return None
        mp[x]=y
    return mp

def _gni_ok(base,up):
    ops=difflib.SequenceMatcher(None,base.splitlines(True),up.splitlines(True)).get_opcodes()
    return all(t in ('equal','delete','insert') for t,*_ in ops)
def _gni(area,base,up):
    bl,ul=base.splitlines(True),up.splitlines(True); al=area.splitlines(True)
    for t,i1,i2,j1,j2 in difflib.SequenceMatcher(None,bl,ul).get_opcodes():
        if t=='delete':
            for l in bl[i1:i2]:
                k=[n for n,x in enumerate(al) if x.strip()==l.strip()]
                if len(k)==1: del al[k[0]]
        elif t=='insert':
            # inserta cada línea nueva tras la línea del área que corresponde a la anterior de la base
            prev=bl[i1-1].strip() if i1>0 else None
            k=[n for n,x in enumerate(al) if prev is not None and x.strip()==prev]
            pos=k[0]+1 if len(k)==1 else len(al)
            ind=al[pos-1][:len(al[pos-1])-len(al[pos-1].lstrip())] if pos>0 else ''
            for l in reversed(ul[j1:j2]): al.insert(pos, ind+l.lstrip())
    return ''.join(al)

def _blockish(add):
    # lo añadido es un bloque completo (declaraciones o funciones enteras): vale al final o al principio
    t=add.strip()
    if not t: return True
    last=t.split('\n')[-1].strip()
    return last.endswith((';','}','*/','},')) or last.startswith('//')
def _place(area,bl,ul):
    al=area.splitlines(True)
    ops=difflib.SequenceMatcher(None,bl,ul).get_opcodes()
    if not area.strip():
        return ''.join(''.join(ul[j1:j2]) for t,i1,i2,j1,j2 in ops if t=='insert')
    ins=[]
    for t,i1,i2,j1,j2 in ops:
        if t!='insert': continue
        prev=bl[i1-1].strip() if i1>0 else ''; nxt=bl[i1].strip() if i1<len(bl) else ''
        k=[n for n,x in enumerate(al) if prev and x.strip()==prev]
        if len(k)==1: ins.append((k[0]+1,ul[j1:j2])); continue
        k=[n for n,x in enumerate(al) if nxt and x.strip()==nxt]
        if len(k)==1: ins.append((k[0],ul[j1:j2])); continue
        if _blockish(''.join(ul[j1:j2])) and (not prev or not nxt):
            ins.append((len(al) if not nxt else 0, ul[j1:j2])); continue
        return None
    for pos,lines in sorted(ins,key=lambda x:-x[0]): al[pos:pos]=lines
    return ''.join(al)

ENUMS=[]
_EN=re.compile(r'^\s*(k\w+) = (\d+),\s*$')
def _enum_add(base,up):
    ops=difflib.SequenceMatcher(None,base.splitlines(True),up.splitlines(True)).get_opcodes()
    if not all(t in ('equal','insert') for t,*_ in ops): return None
    add=[l for t,i1,i2,j1,j2 in ops if t=='insert' for l in up.splitlines(True)[j1:j2] if l.strip()]
    if not add or not all(_EN.match(l) for l in add): return None
    return [(_EN.match(l).group(1),int(_EN.match(l).group(2))) for l in add]
def _enum_place(text):
    L=text.split('\n')
    for name,val in ENUMS:
        if any(re.match(r'^\s*'+name+r' = ',l) for l in L): continue
        idx=[i for i,l in enumerate(L) if _EN.match(l) and int(_EN.match(l).group(2))>val]
        ind=re.match(r'^(\s*)',[l for l in L if _EN.match(l)][0]).group(1)
        pos=idx[0] if idx else max(i for i,l in enumerate(L) if _EN.match(l))+1
        # si justo encima hay un comentario FlyWeb que describe la siguiente entrada, se inserta antes del comentario
        while pos>0 and L[pos-1].strip().startswith('// FlyWeb:'): pos-=1
        L[pos:pos]=[ind+'// FlyWeb: upstream value (FM.28).',ind+f'{name} = {val},']
    return '\n'.join(L)

def _prefix_apply(area,base,up):
    al,bl,ul=area.splitlines(True),base.splitlines(True),up.splitlines(True)
    n=len(al)
    if n<len(bl) and bl[:n]==al:
        ops=difflib.SequenceMatcher(None,bl,ul).get_opcodes()
        if any(t!='equal' and i2>n for t,i1,i2,j1,j2 in ops if not (t=='insert' and i1==n)): return None
        j=next((j1+(n-i1) for t,i1,i2,j1,j2 in ops if t=='equal' and i1<=n<=i2), None)
        return None if j is None else ''.join(ul[:j])
    if n<len(bl) and bl[len(bl)-n:]==al:
        k=len(bl)-n
        ops=difflib.SequenceMatcher(None,bl,ul).get_opcodes()
        if any(t!='equal' and i1<k for t,i1,i2,j1,j2 in ops if not (t=='insert' and i1==k)): return None
        j=next((j1+(k-i1) for t,i1,i2,j1,j2 in ops if t=='equal' and i1<=k<=i2), None)
        return None if j is None else ''.join(ul[j:])
    return None

def _changes(bl,xl):
    return [(i1,i2,xl[j1:j2]) for t,i1,i2,j1,j2 in difflib.SequenceMatcher(None,bl,xl,autojunk=False).get_opcodes() if t!='equal']
def _fine(area,base,up):
    bl,al,ul=base.splitlines(True),area.splitlines(True),up.splitlines(True)
    ca,cu=_changes(bl,al),_changes(bl,ul)
    for a1,a2,_ in ca:
        for u1,u2,_ in cu:
            if a1<u2 and u1<a2: return None          # solapan
            if a1==a2==u1==u2: return None           # dos inserciones en el mismo punto
            if (a1==a2 and u1<a1<u2) or (u1==u2 and a1<u1<a2): return None
    ch=sorted(ca+cu,key=lambda x:(x[0],x[1]))
    res=[];i=0
    for i1,i2,rep in ch:
        if i1<i: return None
        res+=bl[i:i1]+rep; i=i2
    res+=bl[i:]
    return ''.join(res)
def _strip(t):
    t=re.sub(r'//[^\n]*','',t); t=re.sub(r'/\*.*?\*/','',t,flags=re.S)
    return re.sub(r'"(\\.|[^"\\])*"|\'(\\.|[^\'\\])*\'','""',t)
def _bal(t):
    d=0
    for ch in _strip(t):
        if ch=='{': d+=1
        elif ch=='}':
            d-=1
            if d<0: return False
    return d==0
def _sane(f,area,r):
    # FlyWeb (MOTOR-13): lo que la resolución añade al área debe ir equilibrado en llaves (evita métodos de clases
    # que no existen en 116 pegados fuera de su clase).
    if not f.endswith(('.cc','.h','.mm','.cpp')): return True
    al,rl=area.splitlines(True),r.splitlines(True)
    for t,i1,i2,j1,j2 in difflib.SequenceMatcher(None,al,rl,autojunk=False).get_opcodes():
        if t in ('insert','replace') and not _bal(''.join(rl[j1:j2])):
            if t=='replace' and _bal(''.join(al[i1:i2])) is False and _strip(''.join(al[i1:i2])).count('{')-_strip(''.join(al[i1:i2])).count('}')==_strip(''.join(rl[j1:j2])).count('{')-_strip(''.join(rl[j1:j2])).count('}'):
                continue
            return False
    return True
def resolve(f,area,base,up):
    if f.endswith(('css_property_id.mojom','web_feature.mojom')) and _enum_add(base,up) is not None:
        ENUMS.extend(_enum_add(base,up)); return area
    if base and up.startswith(base) and len(up)>len(base) and (area.endswith(base) or not area.strip() or _blockish(up[len(base):])):
        return area+up[len(base):]
    if base and up.endswith(base) and len(up)>len(base) and (area.startswith(base) or not area.strip() or _blockish(up[:len(up)-len(base)])):
        return up[:len(up)-len(base)]+area
    if area.strip() and _prefix_apply(area,base,up) is not None:
        return _prefix_apply(area,base,up)
    if not base.strip() and up.strip() and _blockish(up):
        return area+up   # base vacía: upstream solo añade un bloque entero en este punto
    if up==base or _nocom(up)==_nocom(base):
        return area
    if base and not up.strip() and area.strip() and difflib.SequenceMatcher(None,''.join(area.split()),''.join(base.split())).ratio()>0.85:
        return ''   # upstream borra el bloque entero y el área es casi igual a la base
    if base and all(t in ('equal','insert') for t,*_ in difflib.SequenceMatcher(None,base.splitlines(True),up.splitlines(True)).get_opcodes()):
        return _place(area,base.splitlines(True),up.splitlines(True))
    if base and f.endswith(('.gni','.gn')) and _gni_ok(base,up):
        return _gni(area,base,up)
    if base and _del_only(base,up) and _apply_del(area,base,up) is not None:
        return _apply_del(area,base,up)
    if base and _renmap(base,up) is not None:
        mp=_renmap(base,up); t=area
        for o,n in mp.items(): t=re.sub(r'\b'+re.escape(o)+r'\b',n,t)
        RN.update(mp); return t
    if base and _fine(area,base,up) is not None:
        return _fine(area,base,up)
    return None
f=sys.argv[1]; s=open(f).read(); out=[]; i=0; auto=left=0; insane=0
while True:
    a=s.find('<<<<<<< area\n',i)
    if a<0: out.append(s[i:]); break
    b=s.index('||||||| base\n',a); c=s.index('=======\n',b); d=s.index('>>>>>>> upstream\n',c)
    area,base,up=s[a+13:b],s[b+13:c],s[c+8:d]
    out.append(s[i:a])
    r=resolve(f,area,base,up)
    if r is not None and not _sane(f,area,r): r=None; insane+=1
    if r is None: out.append(s[a:d+17]); left+=1
    else: out.append(r); auto+=1
    i=d+17
res=''.join(out)
if ENUMS: res=_enum_place(res)
open(f,'w').write(res); print(f'{auto} auto, {left} quedan'+(f' (llaves: {insane})' if insane else '')+(' renombres: '+' '.join(f'{a}={b}' for a,b in RN.items()) if RN else ''))
