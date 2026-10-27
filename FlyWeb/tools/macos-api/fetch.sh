#!/bin/bash
S=${S:?carpeta de trabajo}
cd $S/cr
for t in "$@"; do
  git fetch -q --depth=1 --filter=blob:none origin tag $t --no-tags || { echo "FAIL fetch $t"; continue; }
  git worktree add -q --no-checkout $S/t/$t $t 2>/dev/null
  (cd $S/t/$t && git sparse-checkout set --no-cone --stdin < $S/sparse.txt >/dev/null 2>&1 && git checkout -q 2>&1 | tail -1)
  echo "DONE $t $(find $S/t/$t -type f | wc -l)"
done
