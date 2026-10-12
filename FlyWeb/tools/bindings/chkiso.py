# Uso: chkiso.py <dir gen> → llamadas generadas a ToWrappableUnsafe(isolate, …) sin «v8::Isolate* isolate» declarado en su función.
import re,sys,os
bad=0
for root,_,fs in os.walk(sys.argv[1]):
  for fn in fs:
    if not fn.endswith('.cc'): continue
    p=os.path.join(root,fn); L=open(p).read().split('\n'); start=0
    for i,l in enumerate(L):
      if re.match(r'^[A-Za-z][^=;]*\(.*\)\s*(const\s*)?\{\s*$',l) and not re.match(r'^(if|for|while|switch|else|do)\b',l): start=i
      if 'ToWrappableUnsafe(isolate,' in l:
        seg='\n'.join(L[start:i+1])
        if not re.search(r'v8::Isolate\*\s+isolate\b',seg):
          bad+=1
          if bad<=8: print(p.split('/gen/')[-1],i+1,L[start][:80])
print('sin isolate declarado:',bad)
