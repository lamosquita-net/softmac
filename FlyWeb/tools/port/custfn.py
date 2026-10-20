#!/usr/bin/env python3
# custfn.py <dir>: cada propiedad de css_properties.json5 con style_builder_custom_functions o property_methods tiene
# su definición Clase::Método en properties/{longhands,shorthands}/*_custom.cc (si no, el enlazado falla:
# Position::ApplyInherit, FM.28). MOTOR-13.
import re,sys,os,glob
D=sys.argv[1]; P=os.path.join(D,'third_party/blink/renderer/core/css')
t=open(os.path.join(P,'css_properties.json5')).read()
t=re.sub(r'//[^\n]*','',t)
cc={}
for f in glob.glob(os.path.join(P,'properties/*/*.cc')):
    cc[f]=open(f,errors='ignore').read()
todo=''.join(cc.values())
def camel(n):
    n=n.lstrip('-'); return ''.join(p[:1].upper()+p[1:] for p in n.split('-'))
AP={'initial':'ApplyInitial','inherit':'ApplyInherit','value':'ApplyValue'}
bad=0
for m in re.finditer(r'\{\s*name:\s*"([^"]+)",(.*?)\n\s*\},',t,re.S):
    name,body=m.group(1),m.group(2)
    if re.search(r'\balias_for\b',body): continue
    cls=camel(name)
    meths=[]
    s=re.search(r'style_builder_custom_functions:\s*\[([^\]]*)\]',body)
    if s: meths+= [AP[x] for x in re.findall(r'"(\w+)"',s.group(1)) if x in AP]
    s=re.search(r'property_methods:\s*\[([^\]]*)\]',body)
    if s: meths+= re.findall(r'"(\w+)"',s.group(1))
    for me in meths:
        if not re.search(r'\b'+cls+r'::'+me+r'\s*\(',todo):
            print(f'FALTA {cls}::{me}  ({name})'); bad+=1
print(f'{bad} métodos sin definir'); sys.exit(1 if bad else 0)
