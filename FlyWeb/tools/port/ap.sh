#!/bin/bash
# Uso: ap.sh <área> <commit>  Aplica <commit>.ng.diff (de portarng.sh STEP=1 o addfilesng.sh) en w-<área> con
# `git apply --reject`, sin commit, y dice por fichero qué hunks se rechazaron y cuáles entraron. Los rechazados
# se resuelven a mano antes del siguiente commit; los que entraron no se vuelven a aplicar.
P=/tmp/claude-0/port; cd $P/w-$1 || exit 1
git apply --reject --recount -v --whitespace=nowarn $P/$2.ng.diff 2>&1 | awk '
  /^Applying patch .* with [0-9]+ reject/ { f=$3; next }
  /^Applied patch / { f=""; next }
  /^Hunk #[0-9]+ (applied cleanly|succeeded)/ { if (f) ok[f]=ok[f] " " $2; next }
  /^Rejected hunk #[0-9]+/ { r=$3; sub(/\.$/, "", r); rej[f]=rej[f] " " r; next }
  /does not exist|No such file/ { print }
  END { for (f in rej) printf "%s: rechazados%s%s\n", f, rej[f], (ok[f] ? "; entraron" ok[f] : "") }'
