# Uso: python3 idscan.py <w-área> <commit base del área>
# Busca en las líneas añadidas desde <base> identificadores que no existen en la 116 (cr116: third_party/blink y
# build). Al final («possibly undeclared») lista los que en el área solo aparecen tras «.», «->» o «::» sin una
# definición: candidatos a nombres de upstream sin traducir (GetPhysicalFragment, GetBreakToken…). Salen también
# flags generadas y cosas de parches de niveles anteriores: revisar a mano.
import os,re,subprocess,sys,pickle
area,base=sys.argv[1],sys.argv[2]
cache='/tmp/claude-0/port/ids116.pkl'
tok=re.compile(r'[A-Za-z_][A-Za-z0-9_]*')
if os.path.exists(cache):
    ids=pickle.load(open(cache,'rb'))
else:
    ids=set()
    for root in ['/home/user/cr116/third_party/blink','/home/user/cr116/build']:
        for dp,_,fs in os.walk(root):
            for f in fs:
                if f.endswith(('.h','.cc','.json5','.idl')):
                    try: ids.update(tok.findall(open(os.path.join(dp,f),errors='ignore').read()))
                    except Exception: pass
    pickle.dump(ids,open(cache,'wb'))
cur=set()
for dp,_,fs in os.walk(area):
    if '.git' in dp: continue
    for f in fs:
        if f.endswith(('.h','.cc')):
            cur.update(tok.findall(open(os.path.join(dp,f),errors='ignore').read()))
diff=subprocess.run(['git','-C',area,'diff',base,'HEAD','--','*.cc','*.h'],capture_output=True,text=True).stdout
added=[l[1:] for l in diff.split('\n') if l.startswith('+') and not l.startswith('+++')]
# defined in the area's new code: names that appear in declarations; approximate by "anything in cur that is also defined in added lines"
cand={}
for l in added:
    code=re.sub(r'//.*','',l); code=re.sub(r'"[^"]*"','',code)
    for t in tok.findall(code):
        if t not in ids:
            cand.setdefault(t,l.strip())
# names introduced by the port itself appear in the area in a definition context; report all, flagging those absent from area too
for t,l in sorted(cand.items()):
    print(('NEW ' if t in cur else 'MISSING ')+t+'  |  '+l[:110])

# Second pass: NEW identifiers never declared in the area (all occurrences are member accesses).
print('==== possibly undeclared')
files=[]
for dp,_,fs in os.walk(area):
    if '.git' in dp: continue
    files+= [os.path.join(dp,f) for f in fs if f.endswith(('.h','.cc'))]
texts={f:open(f,errors='ignore').read() for f in files}
for t in sorted(k for k in cand if k in cur):
    decl=False
    for f,s in texts.items():
        for m in re.finditer(r'(.{0,2})\b%s\b'%re.escape(t),s):
            pre=m.group(1)
            if pre.endswith('.') or pre.endswith('->'):
                continue
            if pre.endswith('::'):
                # Class::Name at line start is a definition
                ls=s.rfind('\n',0,m.start())+1
                line=s[ls:s.find('\n',m.start())]
                if re.match(r'^[\w:<>,\s\*&]*\b\w+::%s\('%re.escape(t),line) or re.match(r'^\w+::%s\('%re.escape(t),line.strip()):
                    decl=True;break
                continue
            decl=True;break
        if decl: break
    if not decl:
        print('UNDECLARED',t,' | ',cand[t][:100])
