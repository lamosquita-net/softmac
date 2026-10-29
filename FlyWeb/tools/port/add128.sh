#!/bin/bash
# add128.sh <área> <fichero>...: añade a w-<área> ficheros de la 128 con su parche de bc (commit «add»). MOTOR-28.
A=$1; shift; P=/tmp/claude-0/port; cd $P/w-$A
for f in "$@"; do [ -e $f ] && continue; mkdir -p $(dirname $f); $P/g128.sh $f > $f
  p=/home/user/brave-core/patches/$(echo $f|tr / -).patch; [ -f $p ] && git apply $p; echo $f >> $P/files-$A.txt; done
git add -A; git -c user.email=x -c user.name=x commit -qm add; echo ok
