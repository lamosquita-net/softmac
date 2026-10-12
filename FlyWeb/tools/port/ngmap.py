#!/usr/bin/env python3
"""ngmap.py <cr116> <cr128> > ngmap.json

Mapa de renombres de LayoutNG entre la 116 y una versión posterior de Chromium (FM.16, RubyLB). Upstream quitó el
prefijo NG de ficheros (`layout/ng/inline/ng_line_breaker.cc` → `layout/inline/line_breaker.cc`) y de clases
(`NGLineBreaker` → `LineBreaker`, `LayoutNGBlockFlow` → `LayoutBlockFlow`). Lo usa ngtraducir.py para pasar diffs de
upstream a las rutas y los nombres de la 116. Necesita dos copias parciales con third_party/blink/renderer.
"""
import json, os, re, sys

R = 'third_party/blink/renderer/'
EXT = ('.cc', '.h', '.mm', '.gni', '.gn', '.py', '.json5', '.idl', '.tmpl', '.typemap')
# Renombres que no siguen la regla de quitar «ng» (fichero o clase con otro nombre).
EXTRA_FILES = {
    R + 'core/layout/ng/layout_ng_ruby_run.cc': R + 'core/layout/layout_ruby_column.cc',
    R + 'core/layout/ng/layout_ng_ruby_run.h': R + 'core/layout/layout_ruby_column.h',
}
EXTRA_SYMS = {'LayoutNGRubyRun': 'LayoutRubyColumn', 'LayoutRubyAsInline': 'LayoutRuby'}


def files(root):
    out = set()
    for d in ('core', 'modules', 'platform'):
        for dp, _, fs in os.walk(os.path.join(root, R, d)):
            for f in fs:
                if f.endswith(EXT):
                    out.add(os.path.relpath(os.path.join(dp, f), root))
    return out


def guard(path):
    return re.sub(r'[^A-Z0-9]', '_', path.upper()) + '_'


def main(c116, c128):
    f116, f128 = files(c116), files(c128)
    ren, same = {}, []
    for f in f116:
        if '/ng/' not in f and not os.path.basename(f).startswith(('ng_', 'layout_ng_')):
            continue
        g = re.sub(r'/(layout|paint)/ng/', r'/\1/', f).replace('/ng/', '/')
        b = os.path.basename(g)
        if b.startswith('ng_'):
            b = b[3:]
        b = b.replace('layout_ng_', 'layout_')
        g = os.path.join(os.path.dirname(g), b)
        if g in f128 and f not in f128:
            if g in f116:
                # La ruta nueva ya existe en la 116 (upstream fusionó LayoutNGBlockFlow en LayoutBlockFlow, que en la
                # 116 sigue siendo la clase base): no se traduce; ngtraducir.py avisa para mirar cada hunk.
                same.append(g)
                continue
            ren[f] = g
    for a, b in EXTRA_FILES.items():
        if a in f116 and b in f128:
            ren[a] = b
    text116 = {f: open(os.path.join(c116, f), errors='ignore').read() for f in ren}
    text128 = ' '.join(open(os.path.join(c128, g), errors='ignore').read() for g in ren.values())
    cand = {}
    for s in text116.values():
        for m in re.finditer(r'\b(NG|LayoutNG)([A-Z]\w+)\b', s):
            old = m.group(0)
            new = m.group(2) if m.group(1) == 'NG' else 'Layout' + m.group(2)
            cand[old] = new
    cand.update(EXTRA_SYMS)
    # Tipos declarados en la 116 (toda Blink): si el nombre nuevo ya era un tipo de la 116 (p. ej. LayoutBlockFlow, que
    # en la 116 es la clase de la que deriva LayoutNGBlockFlow), no se traduce solo.
    decl = set()
    decl_re = re.compile(r'\b(?:class|struct|enum class|enum|using|typedef)\s+(?:CORE_EXPORT\s+|PLATFORM_EXPORT\s+|MODULES_EXPORT\s+)?(\w+)')
    for f in files(c116):
        if f.endswith(('.h', '.cc')):
            decl.update(decl_re.findall(open(os.path.join(c116, f), errors='ignore').read()))
    sym, ambiguous = {}, []
    for old, new in sorted(cand.items()):
        if not re.search(r'\b' + new + r'\b', text128) or re.search(r'\b' + old + r'\b', text128):
            continue
        if new in decl and new not in EXTRA_SYMS.values():
            ambiguous.append(new)
            continue
        sym[new] = old
    # Nombres nuevos que en la 116 ya son métodos (`result->PhysicalFragment()`, `ContainingBlock()`,
    # `ConstraintSpace()`…): seguidos de «(» no se traducen (ngtraducir.py avisa para revisarlos a mano).
    calls = set()
    call_re = re.compile(r'(?<![A-Za-z0-9_])(\w+)\s*\(')
    for f in files(c116):
        if f.endswith(('.h', '.cc')):
            code = re.sub(r'//[^\n]*|"(?:\\.|[^"\\\n])*"', '', open(os.path.join(c116, f), errors='ignore').read())
            calls.update(n for n in call_re.findall(code) if n in sym)
    paths = {g: f for f, g in ren.items()}
    guards = {guard(g): guard(f) for g, f in paths.items() if g.endswith('.h')}
    json.dump({'paths': paths, 'syms': sym, 'guards': guards, 'ambiguous': sorted(ambiguous),
               'calls': sorted(calls), 'same_paths': sorted(same)}, sys.stdout, indent=0, sort_keys=True)
    print(f'ficheros {len(paths)}, símbolos {len(sym)}, ambiguos {len(ambiguous)}, también métodos {len(calls)}, '
          f'rutas que ya existen en la 116 {len(same)}', file=sys.stderr)


if __name__ == '__main__':
    main(*sys.argv[1:3])
