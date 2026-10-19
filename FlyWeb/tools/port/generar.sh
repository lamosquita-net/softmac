#!/bin/bash
# Uso: [BASE_REF=<rama>] generar.sh <nombre>  → escribe los .patch de w-<nombre> en brave-core/patches
W=/tmp/claude-0/port/w-$1; cd $W; find . -name "*.rej" | grep -q . && { echo "QUEDAN .rej"; exit 1; }
BASE=$(git rev-list --max-parents=0 HEAD); ESCRITOS=""; for f in $(git diff --name-only $BASE HEAD); do P=/home/user/brave-core/patches/$(echo $f | tr / -).patch; git diff --full-index $BASE HEAD -- $f > $P; ESCRITOS="$ESCRITOS $P"; done
# Ficheros del área que vuelven a ser los de la 116: su parche sobra si lo creó este porte, es decir, si no estaba en
# BASE_REF (la rama de brave-core de la que salió el porte). Sin BASE_REF solo avisa (MOTOR-5, RubyLB R2).
for f in $(git ls-tree -r --name-only $BASE); do n=patches/$(echo $f | tr / -).patch; p=/home/user/brave-core/$n
  [ -f $p ] && git diff --quiet $BASE HEAD -- $f || continue
  if [ -n "${BASE_REF:-}" ] && ! git -C /home/user/brave-core cat-file -e $BASE_REF:$n 2>/dev/null; then
    rm -f $p; echo "obsoleto, borrado: $(basename $p)"
  else echo "AVISO: $f es igual que en la 116 pero tiene parche (¿no aplicó al montar el área?): $(basename $p)"; fi; done
# Solo los parches que se acaban de escribir (antes, los ~1500 en cada vuelta: unos 2 min).
for P in $ESCRITOS; do /tmp/claude-0/port/fixnew.sh $P; done
cd /home/user/brave-core && git status --short | wc -l
