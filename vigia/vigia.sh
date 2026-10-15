#!/bin/bash
export TZ=Europe/Madrid
V=${1:-70}; since=$(( $(date +%s) - V*60 )); W=$(mktemp -d); cd "$W" && git init -q --bare
BC=https://github.com/lamosquita-net/brave-core
refs=$(git ls-remote $BC 'refs/heads/*' | grep -E 'refs/heads/(flyweb|local/|seg/|nube/)' | awk '{print $2}')
git fetch -q --filter=tree:0 --depth=1 $BC $(for r in $refs; do echo "+$r:$r"; done) 2>/dev/null
for r in $refs; do
  t=$(git log -1 --format=%ct $r 2>/dev/null) || continue
  [ "$t" -ge "$since" ] && echo "RAMA ${r#refs/heads/} $(git log -1 --format='%h %cd %s' --date=format-local:%H:%M $r)"
done
git fetch -q --depth=200 https://github.com/lamosquita-net/softmac +main:sm 2>/dev/null
for c in $(git rev-list --reverse --since=@$since sm -- docs/TAREAS.md); do
  git log -1 --format=%s $c | grep -q "\[coord\]" && continue
  echo "TABLERO $(git log -1 --format='%h %cd %s' --date=format-local:%H:%M $c)"
  git show $c -- docs/TAREAS.md | python3 -c '
import sys,re
old={};new={}
for l in sys.stdin:
    m=re.match(r"([-+])\| (\S+) \|",l)
    if m: (old if m.group(1)=="-" else new)[m.group(2)]=l[1:].rstrip()
for k,n in new.items():
    o=old.get(k,""); i=0
    while i<min(len(o),len(n)) and o[i]==n[i]: i+=1
    print("    %s: …%s" % (k, n[i:i+400].replace("\n"," ")))'
done
rm -rf "$W"
