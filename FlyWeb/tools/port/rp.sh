#!/bin/bash
# rp.sh <flag> <add> [<rem>...] : vuelve a montar w-<flag> sobre la rama actual, aplica los commits y enseña los .rej
# (sin los de ficheros de chrome://flags, variaciones y contadores de uso, que se descartan).
set -u
F=$1; shift; P=/tmp/claude-0/port; W=$P/w-$F
cd $P && ./portarng.sh $F "$@" 2>&1 | grep -E "does not exist|PARCHE BRAVE|NUEVO|rechazos=[0-9]+ [^ ]"
cd $W
for r in $(find . -name "*.rej" | sed 's#^\./##'); do
  f=${r%.rej}
  if echo $f | grep -qE "android_webview|testing/variations|chrome/browser/about_flags|flag_descriptions|flag-metadata|tools/metrics|ukm_features|web_feature.mojom|runtime_enabled_features.json5"; then rm -f $r; continue; fi
  echo "=== $r"; tail -n +3 $r
done
git status --short | grep -E "about_flags|flag_descriptions|flag-metadata|android_webview|testing/variations|ukm_features" | awk '{print $2}' | while read f; do git checkout HEAD -- $f 2>/dev/null; done
J=third_party/blink/renderer/platform/runtime_enabled_features.json5
echo "--- json5: $(grep -c "name: \"$F\"" $J 2>/dev/null)"
