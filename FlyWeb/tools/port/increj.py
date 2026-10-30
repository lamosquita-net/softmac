#!/usr/bin/env python3
# increj.py <fichero>: resuelve un .rej que solo añade #include: los mete tras el primer #include de third_party (orden alfabético aproximado). MOTOR-35.
import sys,re
f=sys.argv[1]; rej=open(f+'.rej').read().split('\n')
adds=[l[1:] for l in rej if l.startswith('+#include')]
others=[l for l in rej if (l.startswith('+') or l.startswith('-')) and not l.startswith('+#include') and not l.startswith('+++') and not l.startswith('---') and l.strip() not in ('+','-')]
if others: print('NO SOLO INCLUDES:', f); sys.exit(1)
s=open(f).read().split('\n')
for inc in adds:
  if inc.startswith("#include <"):
    idx=[i for i,l in enumerate(s) if l.startswith("#include <")]
    pos=next((i for i in idx if s[i]>inc), (idx[-1]+1) if idx else 0); s.insert(pos,inc); continue
  if inc in s: continue
  idx=[i for i,l in enumerate(s) if l.startswith('#include "')]
  pos=None
  for i in idx[1:] if len(idx)>1 else idx:
    if s[i] > inc: pos=i; break
  if pos is None: pos=idx[-1]+1
  s.insert(pos,inc)
open(f,'w').write('\n'.join(s)); print('ok',f,len(adds))
