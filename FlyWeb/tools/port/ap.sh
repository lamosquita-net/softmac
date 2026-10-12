#!/bin/bash
# Uso: ap.sh <área> <commit>  Aplica <commit>.ng.diff (de portarng.sh STEP=1 o addfilesng.sh) en w-<área> con
# `git apply --reject`, sin commit, y lista los rechazos. Se resuelven a mano antes de pasar al siguiente commit.
P=/tmp/claude-0/port; cd $P/w-$1 || exit 1
git apply --reject --whitespace=nowarn $P/$2.ng.diff 2>&1 | grep -E "Rejected|error|does not exist"
find . -name "*.rej" -newer $P/$2.ng.diff | sed 's#^\./##'
