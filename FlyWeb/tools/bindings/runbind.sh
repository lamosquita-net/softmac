#!/bin/bash
# FlyWeb (NUBE). Ver README.md.
# Uso: runbind.sh [árbol] [tareas...]  → collect_idl_files, build_web_idl_database y generate_bindings sobre el árbol (src/ con brave/)
set -eu
T=${1:-/tmp/claude-0/port/src}; O=/tmp/claude-0/port/out; rm -rf "${O:?}"; mkdir -p $O/gen $O/stub
printf "enable_brave_page_graph = false\nenable_brave_page_graph_webapi_probes = false\n" > $O/args.gn; cd $O
export PYTHONPATH=$T/brave/script:$T/build
S=$T/third_party/blink/renderer/bindings/scripts; B=$T/third_party/blink/renderer/bindings
echo '[Exposed=Window] interface InternalRuntimeFlags {};' > $O/stub/internal_runtime_flags.idl
echo '[Exposed=Window] interface InternalSettingsGenerated {};' > $O/stub/internal_settings_generated.idl
P=""
for c in core modules; do for t in prod testing; do
  python3 - "$B/idl_in_$c.gni" "$T" $t > $O/idl_${c}_$t.txt <<'PY'
import re,sys
s=open(sys.argv[1]).read()
parts=re.split(r'\n(?=\w+_for_testing\s*=)',s)
s=parts[0] if sys.argv[3]=='prod' else ''.join(parts[1:])
for p in re.findall(r'"(//[^"]+\.idl)"',s): print(sys.argv[2]+p[1:])
PY
  [ $c-$t = core-testing ] && ls $O/stub/*.idl >> $O/idl_${c}_$t.txt
  F=""; [ $t = testing ] && F=--for_testing
  python3 $S/collect_idl_files.py --idl_list_file $O/idl_${c}_$t.txt --component $c --output $O/web_idl_in_${c}_$t.pickle $F
  P="$P $O/web_idl_in_${c}_$t.pickle"
done; done
python3 $S/build_web_idl_database.py --output $O/web_idl_database.pickle --runtime_enabled_features $T/third_party/blink/renderer/platform/runtime_enabled_features.json5 -- $P
shift || true
[ $# -gt 0 ] && python3 $S/generate_bindings.py --web_idl_database $O/web_idl_database.pickle --root_src_dir $T/ --root_gen_dir $O/gen \
  --output_reldir core=third_party/blink/renderer/bindings/core/v8/ --output_reldir modules=third_party/blink/renderer/bindings/modules/v8/ "$@"
echo OK; find $O/gen -type f | wc -l
