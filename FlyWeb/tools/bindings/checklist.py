# FlyWeb (NUBE). Ver README.md.
# Uso: checklist.py <src> <out>  → escribe <out>/filelist.rsp como lo haría bindings/BUILD.gn (check_generated_file_list)
import re,sys
src,out=sys.argv[1:3]
B=src+'/third_party/blink/renderer/bindings/'
V={}
for g in ('generated_in_core.gni','generated_in_modules.gni'):
    s=open(B+g).read()
    for m in re.finditer(r'(\w+)\s*(\+?=)\s*\[(.*?)\]',s,re.S):
        fl=re.findall(r'"\$root_gen_dir/([^"]+)"',m.group(3))
        V[m.group(1)]=(V.get(m.group(1),[])+fl) if m.group(2)=='+=' else fl
def g(n): return V.get(n,[])
prod=['async_iterator','callback_function','callback_interface','dictionary','enumeration','interface','namespace','observable_array','sync_iterator','union']
toks=['--for_prod']
for k in prod:
    fl=g(f'generated_{k}_sources_in_core')+g(f'generated_{k}_sources_in_modules')
    if k=='interface':
        ex=set(g('generated_interface_extra_sources_in_modules')); fl=[f for f in fl if f not in ex]
    toks+=['--kind',k]+fl
toks+=['--for_testing']
for k in ['callback_function','dictionary','enumeration','interface','union']:
    fl=g(f'generated_{k}_sources_for_testing_in_core')+g(f'generated_{k}_sources_for_testing_in_modules')
    if k=='interface':
        ex=set(g('generated_interface_extra_sources_for_testing_in_modules')); fl=[f for f in fl if f not in ex]
    toks+=['--kind',k]+fl
open(out+'/filelist.rsp','w').write('\n'.join(toks)+'\n')
print(len(toks))
