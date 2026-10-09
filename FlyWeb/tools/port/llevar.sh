#!/usr/bin/env bash
# Lleva commits de LOCAL (que solo cambian ficheros enteros de patches/) a una
# rama nube/* y fusiona el resultado en otra, sin checkout (brave-core pesa
# mucho y el disco del contenedor es justo). Usa GIT_INDEX_FILE + commit-tree.
#
#   llevar.sh <repo-brave-core> <rama-destino> <rama-a-fusionar|-> <commit>...
#   p. ej.: llevar.sh ~/brave-core nube/motor-124 nube/form-vertical 65c71f02 fd0514e0
#
# Cada commit se aplica copiando sus ficheros tal cual quedan en él (no es un
# cherry-pick con diff3): antes comprueba que esos ficheros son idénticos en el
# padre del commit y en la rama destino; si no, para. Imprime las órdenes de
# push para revisarlas; no sube nada.
set -euo pipefail
repo=$1; dest=$2; up=$3; shift 3
cd "$repo"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
tip() { git ls-remote origin "refs/heads/$1" | cut -f1; }
B=$(tip "$dest"); git fetch -q origin "$B"
# Los commits de LOCAL deben estar ya en local (git fetch origin local/<rama>).
pie=$'\n\nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>'
C=$B
for s in "$@"; do
  for f in $(git diff --name-only "$s^" "$s"); do
    a=$(git rev-parse -q --verify "$s^:$f" || true); b=$(git rev-parse -q --verify "$C:$f" || true)
    [ "$a" = "$b" ] || { echo "PARA: $f difiere entre $s^ y $dest" >&2; exit 1; }
  done
  export GIT_INDEX_FILE=$tmp/index
  git read-tree "$C"
  for f in $(git diff --name-only "$s^" "$s"); do
    if git cat-file -e "$s:$f" 2>/dev/null; then
      git update-index --add --cacheinfo "$(git ls-tree "$s" "$f" | awk '{print $1","$3}')","$f"
    else git update-index --force-remove "$f"; fi
  done
  T=$(git write-tree); unset GIT_INDEX_FILE
  msg="$(git log -1 --format=%B "$s" | sed '/^Co-Authored-By/d;/^Claude-Session/d')"
  C=$(printf '%s\n(cherry picked from commit %s)%s\n' "$msg" "$(git rev-parse "$s")" "$pie" |
      GIT_AUTHOR_NAME="$(git log -1 --format=%an "$s")" GIT_AUTHOR_EMAIL="$(git log -1 --format=%ae "$s")" \
      GIT_AUTHOR_DATE="$(git log -1 --format=%aD "$s")" git commit-tree "$T" -p "$C")
done
echo "git push origin $C:refs/heads/$dest"
if [ "$up" != - ]; then
  V=$(tip "$up"); git fetch -q origin "$V"
  T=$(git merge-tree --write-tree "$V" "$C") || { echo "PARA: conflictos al fusionar en $up" >&2; exit 1; }
  M=$(printf 'Merge %s into %s%s\n' "$dest" "$up" "$pie" | git commit-tree "$T" -p "$V" -p "$C")
  echo "git push origin $M:refs/heads/$up"
fi
