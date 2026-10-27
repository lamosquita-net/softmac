#!/usr/bin/env python3
# idmiss.py <área> <fichero>...: identificadores de los ficheros que no aparecen en ningún .h/.cc de la 116 (cr116:
# blink renderer, base, cc, ui/gfx) ni en el área. Para adaptar a la 116 un fichero llevado al estado de upstream. MOTOR-13.
import sys,os,re,pickle
A=sys.argv[1]; ident=re.compile(r'\b[A-Za-z_][A-Za-z0-9_]{3,}\b')
cache='/tmp/claude-0/port/ids116.pkl'
if os.path.exists(cache): ids=pickle.load(open(cache,'rb'))
else:
    ids=set()
    for root in ['/home/user/cr116/third_party/blink','/home/user/cr116/cc','/home/user/cr116/components/viz']:
        for dp,_,fs in os.walk(root):
            for f in fs:
                if f.endswith(('.h','.cc','.json5','.idl','.tmpl')):
                    try: ids.update(ident.findall(open(os.path.join(dp,f),errors='ignore').read()))
                    except: pass
    pickle.dump(ids,open(cache,'wb'))
W='/tmp/claude-0/port/w-'+A; aids=set()
for dp,_,fs in os.walk(W):
    if '/.git' in dp: continue
    for f in fs:
        if f.endswith(('.h','.cc','.json5')): aids.update(ident.findall(open(os.path.join(dp,f),errors='ignore').read()))
for f in sys.argv[2:]:
    t=open(f).read(); t=re.sub(r'//[^\n]*','',t)
    miss=sorted(set(ident.findall(t))-ids-aids-{'std','absl','base'})
    print(f, len(miss)); print('  '+' '.join(miss))
