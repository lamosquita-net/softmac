#!/usr/bin/env python3
"""ngtraducir.py <ngmap.json> < diff_upstream > diff_116

Pasa un diff de upstream (posterior a los renombres de LayoutNG) a las rutas, los nombres de clase y las guardas de
cabecera de la 116, con el mapa de ngmap.py. No toca los identificadores ambiguos (los lista en stderr si aparecen).
Las líneas `index` se quitan: el diff resultante se aplica con `git apply --reject` o `patch`, no a tres bandas.
"""
import json, os, re, sys
KEEP_STD = os.environ.get('FLYWEB_STD_OPTIONAL') == '1'
OPT = {'std::optional': 'absl::optional', 'std::nullopt': 'absl::nullopt', 'std::make_optional': 'absl::make_optional',
       '#include <optional>': '#include "third_party/abseil-cpp/absl/types/optional.h"'}
OPT_RE = re.compile('(?:' + '|'.join(re.escape(k) for k in sorted(OPT, key=len, reverse=True)) + r')(?![A-Za-z0-9_])')

m = json.load(open(sys.argv[1]))
paths, syms, guards = m['paths'], m['syms'], m['guards']
path_re = re.compile('|'.join(re.escape(p) for p in sorted(paths, key=len, reverse=True))) if paths else None
# Rutas sin «third_party/blink/renderer/» (las de los #include van completas; las de los .gni, relativas).
short = {p.split('third_party/blink/renderer/', 1)[1]: f.split('third_party/blink/renderer/', 1)[1]
         for p, f in paths.items()}
# Los nombres que en la 116 también son métodos no se traducen delante de «(» (`->PhysicalFragment()` sigue igual).
calls = set(m.get('calls', []))
sym_re = re.compile(r'\b(' + '|'.join(sorted(map(re.escape, syms), key=len, reverse=True)) + r')\b(\s*\()?') \
    if syms else None
seen_calls = set()
guard_re = re.compile('|'.join(sorted(map(re.escape, guards), key=len, reverse=True))) if guards else None
amb = set(m.get('ambiguous', []))
seen_amb = set()
same = set(m.get('same_paths', []))
seen_same = set()
base, files116 = m.get('base', {}), set(m.get('files116', []))
seen_mid = {}
any_path_re = re.compile(r'third_party/blink/renderer/[\w/.-]+\.(?:h|cc|mm)\b')


def mid(x):
    # Ruta intermedia de upstream (ni de la 116 ni del mapa): por el nombre canónico, si es único en la 116.
    p = x.group(0)
    if p in files116 or p in same or p in paths.values():
        return p
    # FM.28: solo en core/layout (los renombres NG); css/anchor_query.* es un fichero nuevo, no ng_anchor_query.
    if '/core/layout/' not in p:
        return p
    b = os.path.basename(p)
    cb = b[3:] if b.startswith('ng_') else b.replace('layout_ng_', 'layout_')
    if cb in base:
        seen_mid[p] = base[cb]
        return base[cb]
    return p


def tr(text):
    if path_re:
        text = path_re.sub(lambda x: paths[x.group(0)], text)
    if files116 and ('#include' in text or text.startswith(('diff --git', '--- ', '+++ '))):
        text = any_path_re.sub(mid, text)
    if guard_re:
        text = guard_re.sub(lambda x: guards[x.group(0)], text)
    if sym_re:
        text = sym_re.sub(sym_sub, text)
    # FM.28 (MOTOR-13): la 116 tiene absl::optional distinto de std::optional (ABSL_OPTION_USE_STD_OPTIONAL 0);
    # upstream pasó a std::optional en febrero de 2024 (d2b5c17eff3). Sin FLYWEB_STD_OPTIONAL=1, se vuelve a absl.
    if not KEEP_STD:
        text = OPT_RE.sub(lambda x: OPT[x.group(0)], text)
    return text


def sym_sub(x):
    name, paren = x.group(1), x.group(2) or ''
    if paren and name in calls:
        seen_calls.add(name)
        return x.group(0)
    return syms[name] + paren


out = []
gni_dir = ''
for line in sys.stdin:
    if line.startswith('index '):
        continue
    if line.startswith('+++ b/') or line.startswith('--- a/'):
        g = line[6:].strip()
        gni_dir = (g[len('third_party/blink/renderer/'):-len('build.gni')]
                   if g.startswith('third_party/blink/renderer/') and g.endswith('/build.gni') else '')
    if line.startswith(('diff --git', '--- ', '+++ ', 'rename ', 'similarity')):
        if line.startswith('+++ b/') and line[6:].strip() in same:
            seen_same.add(line[6:].strip())
        out.append(tr(line))
        continue
    if line[:1] in ' +-':
        body = tr(line[1:])
        # Rutas cortas en listas de .gni ("inline/line_breaker.cc"): solo las que acaban en comillas.
        for s, f in short.items():
            body = body.replace('"' + s + '"', '"' + f + '"')
            # FM.28 (MOTOR-13): en el .gni de la carpeta, la entrada va relativa a ella ("anchor_evaluator_impl.cc"
            # en core/layout/build.gni → "ng/ng_anchor_query.cc").
            if gni_dir and s.startswith(gni_dir):
                t = f[len(gni_dir):] if f.startswith(gni_dir) else '//third_party/blink/renderer/' + f
                body = body.replace('"' + s[len(gni_dir):] + '"', '"' + t + '"')
        for a in amb:
            if re.search(r'\b' + a + r'\b', body):
                seen_amb.add(a)
        out.append(line[0] + body)
    else:
        out.append(line)
# FM.28 (MOTOR-13): CSSValueFromComputedStyleInternal tiene 3 argumentos en la 116 (sin CSSValuePhase).
for i in range(1, len(out)):
    m = re.match(r'([ +-])(\s*)CSSValuePhase(?: value_phase)?\) const(.*)$', out[i], re.S)
    if m and out[i - 1][:1] == m.group(1) and out[i - 1].rstrip().endswith('bool allow_visited_style,'):
        out[i - 1] = out[i - 1].rstrip()[:-1] + ') const' + m.group(3)
        out[i] = None
sys.stdout.write(''.join(x for x in out if x is not None))
if seen_amb:
    print('AMBIGUOS sin traducir: ' + ' '.join(sorted(seen_amb)), file=sys.stderr)
if seen_mid:
    print('RUTAS intermedias traducidas por el nombre: ' + ' '.join(f'{a}->{b}' for a, b in sorted(seen_mid.items())),
          file=sys.stderr)
if seen_same:
    print('RUTAS que también existen en la 116 (sin traducir; en upstream es la clase fusionada con la NG, mirar a '
          'qué clase de la 116 corresponde cada hunk): ' + ' '.join(sorted(seen_same)), file=sys.stderr)
if seen_calls:
    print('LLAMADAS sin traducir (método en la 116; revisar si es un constructor): ' + ' '.join(sorted(seen_calls)),
          file=sys.stderr)
