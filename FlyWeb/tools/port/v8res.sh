#!/bin/bash
# v8res.sh <dir v8re> <patch> <destino|parche|manual>: resuelve un conflicto de v8re.sh y rehace el parche (o lo borra si queda igual que la V8 destino). MOTOR-35.
T=$1; P=/home/user/brave-core/patches/v8/$2; side=$3; R=$T/res-$2
f=$(grep -m1 "^+++ b/" $P | sed 's#^+++ b/##')
if [ $side != manual ]; then python3 - "$R" $side <<'PY'
import sys,re
p,side=sys.argv[1],sys.argv[2]; out=[];st=None
for l in open(p).read().split('\n'):
  if l.startswith('<<<<<<< '): st='d'; continue
  if l=='=======' and st=='d': st='p'; continue
  if l.startswith('>>>>>>> ') and st=='p': st=None; continue
  if st is None or (st=='d' and side=='destino') or (st=='p' and side=='parche'): out.append(l)
open(p,'w').write('\n'.join(out))
PY
fi
grep -q '^<<<<<<<\|^>>>>>>>' $R && { echo "quedan marcas en $R"; exit 1; }
if cmp -s $R $T/t/$f; then git -C /home/user/brave-core rm -q patches/v8/$2; echo "borrado $2 (igual que la destino)"; exit 0; fi
G=$(mktemp -d); (cd $G && git init -q && mkdir -p $(dirname $f) && cp $T/t/$f $f && git add -A && git -c user.email=x -c user.name=x commit -qm b && cp $R $f && git diff --full-index > $P); rm -rf $G; echo "rehecho $2"
