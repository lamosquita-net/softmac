#!/bin/bash
# FM.54 F0 (fork-propio.md §6): brave-core `flyweb` patch history -> commits
# of the Chromium tree (`flynk`) and of V8 (`flynk-v8`). Only git, no build.
#
#   convertir.sh preparar     bare repos in $FLYNK, objects borrowed from the
#                             local clean checkouts (alternates), not copied
#   convertir.sh src|v8       convert (repeatable: same input, same SHAs)
#   convertir.sh comprobar    hito: flynk tree == src of the release after
#                             apply_patches (tracked files, no .git)
#
# Variables (defaults are the 7,1):
#   BRAVE  brave-core repo         RANGE  brave-core range to convert
#   FLYNK  where the bare repos go SRC    src after apply_patches
#   BASE128 clean Chromium 128 checkout
set -euo pipefail
H=$(cd "$(dirname "$0")" && pwd)
BRAVE=${BRAVE:-$HOME/proyectos/softmac/FlyWeb/brave-core.git}
RANGE=${RANGE:-v1.69.168..flyweb}
FLYNK=${FLYNK:-$HOME/proyectos/flynk}
SRC=${SRC:-$HOME/proyectos/brave-128/brave-browser/src}
BASE128=${BASE128:-$HOME/proyectos/chromium-128/src}
TAG=128.0.6613.138
V8_GIT=https://chromium.googlesource.com/v8/v8.git

prestar() {  # prestar <bare repo> <checkout whose objects it borrows>...
  local r=$1; shift
  [ -d "$r" ] || git init -q --bare "$r"
  : > "$r/objects/info/alternates"
  for c in "$@"; do
    echo "$(git -C "$c" rev-parse --path-format=absolute --git-common-dir)/objects" \
      >> "$r/objects/info/alternates"
    s="$(git -C "$c" rev-parse --path-format=absolute --git-common-dir)/shallow"
    [ -f "$s" ] && cat "$s" >> "$r/shallow"
  done
  [ -f "$r/shallow" ] && sort -u -o "$r/shallow" "$r/shallow"
  git -C "$r" config gc.auto 0
}

comparar() {  # comparar <repo> <release checkout> <clean base> <branch>
  # Tree of the release checkout (tracked + new non-ignored files) built in a
  # temporary index of the flynk repo, so that the user's index is untouched.
  local R=$1 W=$2 base=$3 rama=$4 T arbol flynk sub n
  T=$(mktemp -d)
  GIT_INDEX_FILE="$T/index" git --git-dir="$R" --work-tree="$W" read-tree "$base"
  GIT_INDEX_FILE="$T/index" git --git-dir="$R" --work-tree="$W" add -A .
  arbol=$(GIT_INDEX_FILE="$T/index" git --git-dir="$R" write-tree)
  flynk=$(git --git-dir="$R" rev-parse "$rama^{tree}")
  echo "== $rama: release $arbol, $rama $flynk"
  # DEPS subrepos are gitlinks in the tree: their revision is DEPS business
  # (v8 is flynk-v8), so they are counted apart, not compared.
  git --git-dir="$R" diff --raw --no-renames "$flynk" "$arbol" > "$T/raw"
  sub=$(awk '$1 == ":160000" || $2 == "160000"' "$T/raw" | wc -l | tr -d ' ')
  awk '$1 != ":160000" && $2 != "160000"' "$T/raw" | cut -f2 | sort > "$T/ficheros"
  # A differing file that the patches touch is a conversion error. One that
  # flynk leaves as the clean base was written by the Brave build outside
  # apply_patches (updateBranding, l10n rebase, chrome/VERSION).
  git --git-dir="$R" diff --name-only "$base^{tree}" "$flynk" | sort > "$T/parcheados"
  comm -12 "$T/ficheros" "$T/parcheados" > "$T/malos"
  echo "subrepos de DEPS distintos (no cuentan): $sub"
  echo "ficheros parcheados: $(wc -l < "$T/parcheados" | tr -d ' ')," \
       "distintos de la release: $(wc -l < "$T/malos" | tr -d ' ')"
  echo "ficheros que escribe el build de Brave fuera de apply_patches:" \
       "$(comm -23 "$T/ficheros" "$T/parcheados" | wc -l | tr -d ' ')"
  if [ -s "$T/malos" ]; then
    head -40 "$T/malos"; return 1
  fi
  echo "capa de parches IDÉNTICA"
  rm -rf "$T"
}

case "${1:-}" in
preparar)
  prestar "$FLYNK/chromium.git" "$BASE128"
  git -C "$BASE128" rev-parse "$TAG^{commit}" >/dev/null
  git -C "$FLYNK/chromium.git" update-ref "refs/tags/$TAG" \
    "$(git -C "$BASE128" rev-parse "$TAG^{commit}")"
  prestar "$FLYNK/v8.git" "$BASE128/v8" "$SRC/v8"
  ;;
src)
  python3 "$H/convertir.py" --kind src --brave "$BRAVE" --range "$RANGE" \
    --repo "$FLYNK/chromium.git" --base "$TAG" --ref refs/heads/flynk \
    --map "$FLYNK/flynk-src.map"
  ;;
v8)
  # V8 of the clean 128 (DEPS); later levels come from FlyWeb/v8-revision.
  V8=$(git -C "$BASE128" show "$TAG:DEPS" |
       sed -n "s/.*'v8_revision': '\([0-9a-f]*\)'.*/\1/p")
  python3 "$H/convertir.py" --kind v8 --brave "$BRAVE" --range "$RANGE" \
    --repo "$FLYNK/v8.git" --base "$V8" --ref refs/heads/flynk-v8 \
    --map "$FLYNK/flynk-v8.map" --fetch "$V8_GIT"
  ;;
comprobar)
  r=0
  comparar "$FLYNK/chromium.git" "$SRC" "$TAG" flynk || r=1
  v8=$(git -C "$BRAVE" show flyweb:FlyWeb/v8-revision | grep -v '^ *#' | grep . | head -1)
  comparar "$FLYNK/v8.git" "$SRC/v8" "$v8" flynk-v8 || r=1
  exit $r
  ;;
*)
  sed -n '2,15p' "$0"; exit 2 ;;
esac
