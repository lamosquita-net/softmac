#!/usr/bin/env python3
# setflag.py <json5> <Nombre> <status|-> : pone status de una flag de runtime_enabled_features.json5 (o lo quita con -). MOTOR-27.
import re,sys
p,n,st=sys.argv[1:4]; s=open(p).read()
i=s.index('name: "%s",'%n); a=s.rfind('{\n',0,i); b=s.index('\n    },',i)
blk=s[a:b]; ind=re.search(r'\n(\s*)name:',blk).group(1)
if re.search(r'\n\s*status: [^\n]*', blk):
    nb=re.sub(r'\n\s*status: [^\n]*','',blk,1) if st=='-' else re.sub(r'(\n\s*status: )[^\n]*', lambda m:m.group(1)+'"%s",'%st, blk,1)
else:
    nb=blk.replace('name: "%s",'%n, 'name: "%s",\n%sstatus: "%s",'%(n,ind,st),1)
open(p,'w').write(s[:a]+nb+s[b:]); print(nb)
