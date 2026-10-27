#!/bin/bash
# Uso: v8re.sh <rev origen> <rev destino>  (en brave-core, rama actual): rehace patches/v8/*.patch de origen a destino.
FROM=$1; TO=$2; BC=/home/user/brave-core; V=/home/user/v8; T=$(mktemp -d)
for P in $BC/patches/v8/*.patch; do
  f=$(grep -m1 "^+++ b/" $P | sed 's#^+++ b/##'); mkdir -p $T/b/$(dirname $f) $T/o/$(dirname $f) $T/t/$(dirname $f)
  git -C $V show $FROM:$f > $T/b/$f || { echo "SIN ORIGEN $f"; continue; }
  cp $T/b/$f $T/o/$f; (cd $T/o && git apply --unsafe-paths $P) || { echo "NO APLICA EN ORIGEN $(basename $P)"; continue; }
  git -C $V show $TO:$f > $T/t/$f || { echo "SIN DESTINO $f"; continue; }
  cp $T/t/$f $T/res; git merge-file -L destino -L origen -L parche $T/res $T/b/$f $T/o/$f; n=$?
  if [ $n -ne 0 ]; then echo "CONFLICTO $(basename $P) ($n) → $T/res"; cp $T/res $T/res-$(basename $P); continue; fi
  (cd $T && mkdir -p g && cd g && rm -rf * .git && git init -q && mkdir -p $(dirname $f) && cp $T/t/$f $f && git add -A && git -c user.email=x -c user.name=x commit -qm b && cp $T/res $f && git diff --full-index > $P)
  echo "ok $(basename $P)"
done
echo "dir: $T"
