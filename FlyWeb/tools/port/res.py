# res.py <fichero> <elección>...: resuelve los bloques de conflicto en orden; elección = o (w-all), t (upstream), ot, to.
import sys,re
p=sys.argv[1]; ch=sys.argv[2:]; s=open(p).read().split('\n'); out=[]; i=0; k=0
while i<len(s):
    if s[i].startswith('<<<<<<< '):
        o=[];t=[];i+=1
        while not s[i].startswith('======='): o.append(s[i]); i+=1
        i+=1
        while not s[i].startswith('>>>>>>> '): t.append(s[i]); i+=1
        c=ch[k] if k<len(ch) else ch[-1]; k+=1
        out+= {'o':o,'t':t,'ot':o+t,'to':t+o}[c]
    else: out.append(s[i])
    i+=1
open(p,'w').write('\n'.join(out)); print(p.split('/')[-1],'bloques',k)
