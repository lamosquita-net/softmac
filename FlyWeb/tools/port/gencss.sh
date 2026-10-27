#!/bin/bash
# Uso: gencss.sh <dir>  Comprueba sin compilar los json5 de Blink que tocan los portes de CSS/estilo: monta <dir>/src con
# third_party/blink de /home/user/cr116 + los parches third_party-blink-* de /home/user/brave-core (rama actual) y
# ejecuta los generadores de flags, ComputedStyle, palabras clave y propiedades CSS y elementos HTML en
# <dir>/src/out/gen. Necesita en cr116 (sparse) third_party/{mako,ply,pyjson5,jinja2,markupsafe} y build. Compara
# con el de otra rama con `diff -r`.
set -u
D=$1/src; C=/home/user/cr116; BC=/home/user/brave-core
rm -rf "${D:?}"; mkdir -p $D/third_party $D/build $D/out
cp -r $C/third_party/blink $C/third_party/mako $C/third_party/ply $C/third_party/pyjson5 $C/third_party/jinja2 \
  $C/third_party/markupsafe $D/third_party/; cp $C/build/*.py $D/build/
cd $D; git init -q; git add -A >/dev/null; git -c user.email=x -c user.name=x commit -qm raw116
bad=0; for P in $BC/patches/third_party-blink-*.patch; do f=$(sed -n 's#^+++ b/##p' $P | head -1)
  [ -e "$f" ] || head -4 $P | grep -q '^new file' || continue
  git apply $P 2>/dev/null || { echo "NO APLICA: $(basename $P)"; bad=$((bad+1)); }; done
echo "parches que no aplican: $bad"
R=../third_party/blink/renderer; S=$R/build/scripts; G=gen/third_party/blink/renderer; cd out; err=0
mkdir -p $G/build/scripts  # runtime_enabled_features.pickle
export PYTHONPATH=$S:../third_party:../third_party/pyjson5/src
run() { o=$1; shift; mkdir -p $o; python3 "$@" --output_dir $o > /tmp/claude-0/port/gencss.log 2>&1 \
  || { echo "FALLA: $*"; tail -5 /tmp/claude-0/port/gencss.log; err=$((err+1)); }; }
run $G/platform $S/make_runtime_features.py $R/platform/runtime_enabled_features.json5
CSS="$R/core/css/css_properties.json5 $R/core/css/computed_style_field_aliases.json5 $R/platform/runtime_enabled_features.json5"
GP="--gperf $(command -v gperf || echo gperf)"
run $G/core/style $S/core/style/make_computed_style_base.py $CSS $R/core/style/computed_style_extra_fields.json5 \
  $R/core/style/computed_style_diff_functions.json5 $R/core/css/css_value_keywords.json5 \
  $R/core/css/css_properties_ranking.json5 $R/core/css/css_group_config.json5 $GP
run $G/core/style $S/core/style/make_computed_style_initial_values.py $CSS $R/core/style/computed_style_extra_fields.json5 $GP
run $G/core/css $S/core/css/make_css_value_id_mappings.py $CSS $R/core/css/css_value_keywords.json5 $GP
run $G/core/css/properties $S/core/css/properties/make_css_property_subclasses.py $CSS \
  $R/core/css/properties/css_property_methods.json5 $GP
run $G/core/css/properties $S/core/css/properties/make_css_property_instances.py $CSS $GP
run $G/core $S/core/css/make_cssom_types.py $CSS $GP
run $G/core $S/make_element_factory.py $R/core/html/aria_properties.json5 $R/core/html/html_tag_names.json5 \
  $R/core/html/html_attribute_names.json5 --generate_tag_enum
run $G/core $S/make_element_type_helpers.py $R/core/html/html_tag_names.json5
command -v gperf >/dev/null && { run $G/core/css $S/core/css/make_css_property_names.py $CSS $GP
  run $G/core $S/core/css/make_css_value_keywords.py $R/core/css/css_value_keywords.json5 $GP; } \
  || echo "sin gperf: no se generan css_property_names ni css_value_keywords"
echo "generadores con fallo: $err; salida en $D/out/gen"
