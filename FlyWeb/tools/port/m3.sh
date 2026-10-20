#!/bin/bash
# m3.sh <área> <commit> [fichero…]: para cada fichero con .rej en w-<área> (o los dados), deshace lo que ap.sh aplicó y
# fusiona a tres bandas el cambio de upstream (<commit>^ → <commit>, traducido con ngtraducir.py) sobre el fichero del
# área (git merge-file --diff3). Deja marcas de conflicto donde no encaja; dice cuántas. MOTOR-13 (FM.28).
A=$1; c=$2; shift 2; P=/tmp/claude-0/port; W=$P/w-$A; CH=/home/user/chromium/chromium; T=$(mktemp -d)
FS="$*"; [ -z "$FS" ] && FS=$(cd $W && find . -name '*.rej' | sed 's#^\./##; s#\.rej$##')
for f in $FS; do
  # ruta de upstream: la del propio commit cuya traducción da $f (varias rutas pueden ir al mismo fichero de la 116)
  up=$(cd $CH && git show --name-only --format= $c | python3 -c "
import json,sys
m=json.load(open('$P/ngmap.json'))['paths']
c=[p.strip() for p in sys.stdin if p.strip() and m.get(p.strip(),p.strip())=='$f']
print(c[0] if c else '')")
  [ -z "$up" ] && { echo "$f: SIN RUTA DE UPSTREAM en $c (no se toca)"; continue; }
  tr1() { python3 - "$1" "$2" <<'PY'
import sys,subprocess
path,rev=sys.argv[1],sys.argv[2]
r=subprocess.run(['git','-C','/home/user/chromium/chromium','show',f'{rev}:{path}'],capture_output=True,text=True)
lines=r.stdout.split('\n') if r.returncode==0 else []
if lines and lines[-1]=='': lines=lines[:-1]
d=f'--- /dev/null\n+++ b/{path}\n@@ -0,0 +1,{len(lines)} @@\n'+''.join('+'+l+'\n' for l in lines)
o=subprocess.run(['python3','/tmp/claude-0/port/ngtraducir.py','/tmp/claude-0/port/ngmap.json'],input=d,capture_output=True,text=True).stdout
out=[l[1:] for l in o.split('\n')[3:] if l.startswith('+')]
import re
t='\n'.join(out)+('\n' if out else '')
# FM.28: firma de la 116 (sin CSSValuePhase) en CSSValueFromComputedStyleInternal
t=re.sub(r'bool allow_visited_style,\s*CSSValuePhase value_phase\) const', 'bool allow_visited_style) const', t)
sys.stdout.write(t)
PY
  }
  tr1 $up $c^ > $T/base; tr1 $up $c > $T/theirs
  (cd $W && git checkout -q HEAD -- $f 2>/dev/null; rm -f $f.rej)
  git merge-file --diff3 -L area -L base -L upstream $W/$f $T/base $T/theirs; n=$?
  [ $n -gt 0 ] && r=$(python3 /tmp/claude-0/port/autores.py $W/$f) && n=$(echo "$r" | sed -n "s/.*, \([0-9]*\) quedan.*/\1/p") && r=" ($r)"
  echo "$f: $n conflictos${r:-}"; r=""
done
rm -rf $T
