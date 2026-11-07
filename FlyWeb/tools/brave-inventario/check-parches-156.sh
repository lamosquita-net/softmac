#!/bin/bash
# Mide los parches de brave-core contra Chromium 156 (MOTOR-40, 07-11-2026).
# Los overrides de chromium_src que se quedan sin efecto (y la guarda del DNS seguro) los mide check-overrides-156.sh: pásalo también.
# Uso: cd <dir vacío> && find <brave-core>/patches -name "*.patch" | sed "s#^<brave-core>/##" | xargs -P 24 -I{} <este script> {}  (BC=brave-core en /home/user/brave-core; ajusta la variable BC)
# usage: check1.sh <patch path relative to brave-core> ; cwd = work dir
p="$1"; BC=/home/user/brave-core; W=$PWD
rel=${p#patches/}; d=$(dirname "$rel")
case "$rel" in
 v8/*) pre=v8; url="https://chromium.googlesource.com/v8/v8/+/c9b3cfcab30ace06c21f9b48a0f0a34805e81e9d";;
 third_party/boringssl/src/*) pre=third_party/boringssl/src; url="https://boringssl.googlesource.com/boringssl/+/2ea3200c3a3ec176613ab7a0b9a4ffc6db846120";;
 third_party/catapult/*) pre=third_party/catapult; url="https://chromium.googlesource.com/catapult/+/f411808cd159db5e47be79ebee59fffca3da1bd4";;
 third_party/devtools-frontend/src/*) pre=third_party/devtools-frontend/src; url="https://chromium.googlesource.com/devtools/devtools-frontend/+/8c62f844ad8e0664ff41a633bfc17c472f1c5fd6";;
 third_party/search_engines_data/resources/*) pre=third_party/search_engines_data/resources; url="https://chromium.googlesource.com/external/search_engines_data/+/5dc9f1afd38a8ac2b26b1972eb4fc1bbd5754e8c";;
 *) pre=.; url="https://chromium.googlesource.com/chromium/src/+/refs/tags/156.0.8078.80";;
esac
T=$W/tree/$pre; mkdir -p "$T"
missing=0
for f in $(grep -E '^--- a/' "$BC/$p" | sed 's#^--- a/##'); do
  if [ ! -s "$T/$f" ] && [ ! -e "$T/$f.404" ]; then
    mkdir -p "$(dirname "$T/$f")"
    for i in 1 2 3; do
      code=$(curl -sS -o "$T/$f.b64" -w '%{http_code}' "$url/$f?format=TEXT")
      [ "$code" = 200 ] && { base64 -d "$T/$f.b64" > "$T/$f"; rm -f "$T/$f.b64"; break; }
      [ "$code" = 404 ] && { touch "$T/$f.404"; rm -f "$T/$f.b64"; break; }
      sleep 2
    done
  fi
  [ -e "$T/$f.404" ] && missing=1
done
if [ $missing = 1 ]; then echo -e "$p\tNOFILE"; exit; fi
err=$(cd "$T" && git apply --check --ignore-space-change --ignore-whitespace -p1 "$BC/$p" 2>&1 | grep -v "^warning" | head -1)
[ -z "$err" ] && echo -e "$p\tOK" || echo -e "$p\tFAIL\t$err"
