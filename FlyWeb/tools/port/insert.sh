#!/bin/bash
# insert.sh <área> <commit ya aplicado> <commit nuevo>... : deshace en el área el commit (y sus .rej), aplica antes los
# commits nuevos (añadiendo los ficheros que falten desde la 128 + parche de la rama) y vuelve a aplicar el primero.
W=/tmp/claude-0/port/w-$1; C=$2; shift 2; CH=/home/user/chromium/hist; cd $W
EXC=(':!*_test.cc' ':!*unittest*' ':!*/web_tests/*' ':!*/test/*' ':!*browsertest*' ':!tools/metrics/*' ':!*.md')
git add -A; git -c user.email=x -c user.name=x commit -qm manual >/dev/null; A=$(git log --format=%H --grep="^$C$"); find . -name "*.rej.$C" -delete; git show $A --format= -- . ':!*.rej.*' | git apply -R || { echo "NO SE DESHACE $C"; exit 1; }
git add -A; git -c user.email=x -c user.name=x commit -qm "sin $C"
for c in "$@" $C; do
  for f in $(git -C $CH show --name-only --format= $c -- . "${EXC[@]}"); do [ -e $f ] && continue
    mkdir -p $(dirname $f); cp /tmp/claude-0/port/cr128/$f $f 2>/dev/null || git -C $CH show 128.0.6613.138:$f > $f 2>/dev/null || { rm -f $f; continue; }
    p=/home/user/brave-core/patches/$(echo $f|tr / -).patch; [ -f $p ] && git apply $p; done
  git add -A; git -c user.email=x -c user.name=x commit -qm "base $c" >/dev/null
  git -C $CH show --format= $c -- . "${EXC[@]}" > /tmp/claude-0/port/$c.diff
  out=$(git apply --reject --whitespace=nowarn /tmp/claude-0/port/$c.diff 2>&1); r=$(echo "$out" | grep -c "Rejected hunk")
  for x in $(find . -name "*.rej"); do mv $x $x.$c; done
  git add -A; git -c user.email=x -c user.name=x commit -qm $c; echo "$c rechazos=$r"
done
