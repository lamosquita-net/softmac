#!/bin/bash
# FlyHand fase 1: pasa fh2raw y fh2svg por ~/flyhand/corpus (6,1, cuenta craft).
# Los nombres reales solo quedan en ~/flyhand/corpus-map.txt (700, no sale de la 6,1).
# Por pantalla y en resultados/fase1.tsv solo aparecen docNN.
set -u
umask 077
for s in /tmp/local*-61-en-uso; do
  if [ -e "$s" ]; then echo "6,1 ocupada: $s"; exit 3; fi
done
C=$HOME/flyhand/corpus
B=$HOME/flyhand/prefix/bin
O=$HOME/flyhand/salida
R=$HOME/flyhand/resultados
mkdir -p "$O" "$R"
MAP=$HOME/flyhand/corpus-map.txt
TSV=$R/fase1.tsv
: > "$MAP"
printf 'doc\tversion\tpag_pdf\traw_rc\tsvg_rc\tsvg_kb\tavisos\tpaginas_raw\ttrazados\ttexto_raw\tusa\tmensajes\n' > "$TSV"

tiempo() { perl -e 'alarm shift; exec @ARGV' "$@"; }

version() {
  perl -e 'open F,"<",$ARGV[0] or exit; binmode F; read F,$b,262144;
    if ($b =~ /^FH3/) { print "3" } elsif ($b =~ /AGD(.)/s) { print ord($1)-0x30+5 } else { print "?" }' "$1"
}

usa() {
  perl -e 'open F,"<",$ARGV[0] or exit; binmode F; local $/; $b=<F>;
    my @c=(["tintas planas",qr/SpotColor6?\0|PantoneColor\0/],["tintes",qr/TintColor6?\0/],
      ["proceso",qr/ProcessColor\0|Color6\0/],["texto",qr/TextBlok\0|Paragraph\0|TextColumn\0/],
      ["texto en trazado",qr/PathText\0|TextInPath\0|TFOnPath\0/],["mezclas",qr/BlendObject\0|NewBlend\0|MultiBlend\0/],
      ["envolventes",qr/Envelope\0/],["simbolos",qr/SymbolInstance\0/],
      ["degradados",qr/LinearFill\0|RadialFillX?\0|NewRadialFill\0|ContourFill\0|ConeFill\0/],
      ["imagenes",qr/ImageImport\0|EPSImport\0/],["lentes",qr/LensFill\0/],["paginas maestras",qr/MasterPageElement\0/],
      ["patrones",qr/PatternFill\0|TileFill\0/],["efectos",qr/FW\w+Filter\0/]);
    print join(", ", map {$_->[0]} grep {$b =~ $_->[1]} @c)' "$1"
}

pdfpag() {
  local p="$1"; [ -f "$p" ] || { echo "-"; return; }
  local n; n=$(mdls -raw -name kMDItemNumberOfPages "$p" 2>/dev/null)
  case "$n" in ''|'(null)') n=$(perl -e 'local $/; open F,"<",$ARGV[0]; binmode F; $b=<F>; my $n=()=$b=~m{/Type\s*/Page[^s]}g; print $n' "$p");; esac
  echo "$n"
}

i=0
find "$C" -type f ! -iname '*.pdf' ! -name '.*' | sort | while IFS= read -r f; do
  i=$((i+1)); id=$(printf 'doc%02d' $i)
  printf '%s\t%s\n' "$id" "${f#$C/}" >> "$MAP"
  base="${f%.*}"; pdf="-"
  for e in pdf PDF; do [ -f "$base.$e" ] && pdf="$base.$e"; done
  v=$(version "$f")
  tiempo 300 "$B/fh2raw" "$f" > "$O/$id.raw" 2> "$O/$id.raw.err"; rr=$?
  tiempo 300 "$B/fh2svg" "$f" > "$O/$id.svg" 2> "$O/$id.svg.err"; rs=$?
  kb=$(( $(stat -f %z "$O/$id.svg") / 1024 ))
  av=$(cat "$O/$id.raw.err" "$O/$id.svg.err" | wc -l | tr -d ' ')
  msg=$(cat "$O/$id.raw.err" "$O/$id.svg.err" | sed -E 's/[0-9]+/N/g' | sort | uniq -c | sort -rn | head -3 | sed -E 's/^ +//' | cut -c1-80 | tr '\n\t' '; ')
  pg=$(grep -c 'startPage' "$O/$id.raw")
  tr_=$(grep -cE 'drawPath|drawPolygon|drawPolyline|drawRectangle|drawEllipse' "$O/$id.raw")
  tx=$(grep -c 'startTextObject' "$O/$id.raw")
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "$v" "$(pdfpag "$pdf")" "$rr" "$rs" "$kb" "$av" "$pg" "$tr_" "$tx" "$(usa "$f")" "$msg" >> "$TSV"
done
chmod 600 "$MAP"
cat "$TSV"
