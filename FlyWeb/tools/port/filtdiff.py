#!/usr/bin/env python3
# filtdiff.py <ficheros>... : de un diff por stdin, deja solo los bloques de esos ficheros (MOTOR-43).
import sys, re
keep=set(sys.argv[1:]); out=[]; cur=None
for l in sys.stdin:
    if l.startswith('diff --git '):
        m=re.match(r'diff --git a/(\S+) b/(\S+)', l); cur = m and (m.group(1) in keep or m.group(2) in keep)
    if cur: out.append(l)
sys.stdout.write(''.join(out))
