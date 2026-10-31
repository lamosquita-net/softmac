#!/usr/bin/env python3
"""Detecta trozos de parche aplicados fuera de su función (MOTOR-39, 30-10-2026).

Uso: fuera.py [--base 128.0.6613.138] [--ref 137.0.7151.122] [--cache DIR] [--nombres] <parche>...

Para cada parche de brave-core sobre un fichero C/C++ de Chromium: lo aplica a la base, y por cada línea añadida
compara su cadena de ámbitos (namespace/clase/función/switch/if/for…) en el resultado con la que tiene esa misma línea
en Chromium <ref>. Si la línea existe en <ref> y ninguna de sus apariciones tiene la misma cadena, avisa. Encuentra los
fallos típicos del fuzz de `patch`: un `case` tras el cierre del `switch`, una constante de clase dentro de una
función, una llamada fuera de su función. Las líneas que no están en <ref> (adaptadas a mano) no se miran.
Ficheros: raw.githubusercontent.com (se guardan en --cache). Sale con 1 si hay avisos.
"""
import argparse
import os
import re
import subprocess
import sys
import tempfile
import urllib.request

EXT = ('.cc', '.h', '.mm', '.cpp', '.c')
CONTROL = ('if', 'else', 'for', 'while', 'switch', 'do', 'try', 'catch')
CHAIN_MIN = 8  # longitud mínima de una línea (sin espacios) para mirarla


def fetch(tag, path, cache):
    dst = os.path.join(cache, tag, path)
    if not os.path.exists(dst):
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        url = 'https://raw.githubusercontent.com/chromium/chromium/%s/%s' % (tag, path)
        try:
            with urllib.request.urlopen(url) as r:
                data = r.read()
        except Exception:
            return None
        with open(dst, 'wb') as f:
            f.write(data)
    with open(dst, encoding='utf-8', errors='replace') as f:
        return f.read()


def kind(header):
    h = ' '.join(header.split())
    h = re.sub(r'^(?:(?:public|private|protected)\s*:\s*)+', '', h)
    h = re.sub(r'^(?:(?:case\s+(?:[^:]|::)+?|default)\s*:(?!:)\s*)+', '', h)
    if not h:
        return 'block'
    m = re.match(r'(namespace|class|struct|union|enum(?:\s+class)?)\b\s*([\w:]*)', h)
    if m:
        return '%s %s' % (m.group(1), m.group(2))
    first = re.match(r'(?:\}\s*)?(\w+)', h)
    if first and first.group(1) in CONTROL:
        return first.group(1)
    if h.endswith('=') or h.endswith('return') or re.search(r'[=,(]\s*$', h):
        return 'init'
    if re.search(r'\]\s*(?:\([^)]*\))?\s*(?:mutable\s*)?(?:->\s*[\w:<>*& ]+)?$', h):
        return 'lambda'
    m = re.findall(r'(~?[A-Za-z_]\w*(?:::~?[A-Za-z_]\w*)*)\s*\(', h)
    if m:
        name = m[0]
        if name in ('if', 'for', 'while', 'switch'):
            return name
        return 'fn ' + name.split('::')[-1]
    return 'init'


def scopes(text):
    """Para cada línea (índice 0), la cadena de ámbitos abiertos al principio de la línea."""
    out = []
    stack = []
    header = []
    i, n = 0, len(text)
    line_start = True
    out.append(tuple(stack))
    while i < n:
        c = text[i]
        if line_start:
            j = i
            while j < n and text[j] in ' \t':
                j += 1
            if j < n and text[j] == '#':
                # Preprocesador (con continuaciones): no cuenta.
                while i < n:
                    if text[i] == '\n':
                        if text[i - 1] != '\\':
                            break
                        out.append(tuple(k for k, _ in stack))
                    i += 1
                continue
            line_start = False
        if c == '\n':
            out.append(tuple(k for k, _ in stack))
            header.append(' ')
            line_start = True
            i += 1
            continue
        if text.startswith('//', i):
            while i < n and text[i] != '\n':
                i += 1
            continue
        if text.startswith('/*', i):
            j = text.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.extend([tuple(k for k, _ in stack)] * text.count('\n', i, j))
            i = j
            continue
        m = re.match(r'R"([^(]*)\(', text[i:i + 20]) if c == 'R' else None
        if m:
            end = ')' + m.group(1) + '"'
            j = text.find(end, i)
            j = n if j < 0 else j + len(end)
            out.extend([tuple(k for k, _ in stack)] * text.count('\n', i, j))
            header.append('""')
            i = j
            continue
        if c in '"\'':
            if c == "'" and i > 0 and text[i - 1].isalnum():
                i += 1  # separador de dígitos 1'000
                continue
            j = i + 1
            while j < n and text[j] != c and text[j] != '\n':
                j += 2 if text[j] == '\\' else 1
            header.append(c + c)
            i = j + 1
            continue
        if c == '{':
            stack.append((kind(''.join(header)), None))
            header = []
        elif c == '}':
            if stack:
                stack.pop()
            header = []
        elif c == ';':
            h = ''.join(header)
            if h.count('(') > h.count(')'):
                header.append(c)  # for (;;), if (init; cond)
            else:
                header = []
        else:
            header.append(c)
        i += 1
    return out


def norm(line):
    return ''.join(line.split())


def added_lines(patch_text):
    """(nº de línea en el fichero nuevo, texto) de cada línea añadida."""
    res = []
    new = 0
    for ln in patch_text.splitlines():
        m = re.match(r'@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@', ln)
        if m:
            new = int(m.group(1))
            continue
        if ln.startswith('+++') or ln.startswith('---'):
            continue
        if ln.startswith('+'):
            res.append((new, ln[1:]))
            new += 1
        elif ln.startswith(' '):
            new += 1
    return res


def check(patch, base_tag, ref_tag, cache, names=False):
    with open(patch, encoding='utf-8', errors='replace') as f:
        ptxt = f.read()
    m = re.match(r'diff --git a/(\S+) b/', ptxt)
    if not m or not m.group(1).endswith(EXT) or '\nnew file mode' in ptxt[:300]:
        return []
    path = m.group(1)
    base = fetch(base_tag, path, cache)
    ref = fetch(ref_tag, path, cache)
    if base is None or ref is None:
        return []
    with tempfile.TemporaryDirectory() as d:
        dst = os.path.join(d, path)
        os.makedirs(os.path.dirname(dst))
        with open(dst, 'w', encoding='utf-8') as f:
            f.write(base)
        r = subprocess.run(['git', 'apply', os.path.abspath(patch)], cwd=d, capture_output=True, text=True)
        if r.returncode:
            return [(path, 0, 'NO APLICA: ' + r.stderr.strip().splitlines()[0], '', '')]
        with open(dst, encoding='utf-8', errors='replace') as f:
            result = f.read()
    res_sc = scopes(result)
    ref_lines = ref.split('\n')
    ref_sc = scopes(ref)
    ref_idx = {}
    for k, l in enumerate(ref_lines):
        ref_idx.setdefault(norm(l), []).append(k)
    warn = []
    for no, txt in added_lines(ptxt):
        key = norm(txt)
        if len(key) < CHAIN_MIN or key.startswith('//') or key in ('}', '};', 'break;', 'returnfalse;', 'returntrue;', 'returnnullptr;'):
            continue
        hits = ref_idx.get(key)
        if not hits:
            continue
        mine = res_sc[no - 1] if no - 1 < len(res_sc) else ()
        theirs = {ref_sc[k] for k in hits if k < len(ref_sc)}
        if mine in theirs:
            continue
        # Mismo ámbito salvo bloques sin nombre o inicializadores: no es un fallo.
        simp = lambda t: tuple(x for x in t if x not in ('block', 'init', 'lambda'))
        if simp(mine) in {simp(t) for t in theirs}:
            continue
        # Por defecto solo cuenta el esqueleto (namespace/clase/función/switch): un `case` fuera de su `switch`, una
        # constante de clase dentro de una función, una llamada fuera de toda función. Los nombres de función y los
        # if/for/else cambian mucho entre la base y <ref> y dan ruido; se ven con --nombres.
        if not names:
            def skel(t):
                out = []
                for x in t:
                    if x.startswith('fn '):
                        x = 'fn'
                    elif x.startswith('namespace'):
                        # a::b cuenta como dos; el anónimo no cuenta.
                        out.extend(['namespace'] * len([p for p in x[10:].split('::') if p]))
                        continue
                    elif x.split(' ')[0] in ('class', 'struct', 'union', 'enum'):
                        x = x.split(' ')[0]
                    elif x != 'switch':
                        continue
                    if not (x == 'fn' and out and out[-1] == 'fn'):
                        out.append(x)
                return tuple(out)
            # Una llamada que upstream hace una vez en su función y aquí cae dentro de un bucle (o bajo un if/for
            # más hondo que en <ref> que empieza por un bucle) cambia de semántica aunque el esqueleto cuadre:
            # `Finalize()` de ToBoxFragment acabó en el `for` de un `#if DCHECK_IS_ON()` del 136 (MOTOR-41).
            def into_loop(t):
                a, b = simp(mine), simp(t)
                return (len(a) > len(b) and a[:len(b)] == b and
                        any(x.split(' ')[0] in ('for', 'while', 'do') for x in a[len(b):]))
            if skel(mine) in {skel(t) for t in theirs} and not all(into_loop(t) for t in theirs):
                continue
        warn.append((path, no, txt.strip(), ' > '.join(mine) or '(fuera de todo)',
                     ' | '.join(sorted(' > '.join(t) or '(fuera de todo)' for t in theirs))))
    return warn


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--base', default='128.0.6613.138')
    ap.add_argument('--ref', default='137.0.7151.122')
    ap.add_argument('--cache', default='/tmp/claude-0/fuera-cache')
    ap.add_argument('--nombres', action='store_true', help='avisar también si cambia el nombre de la función o un if/for')
    ap.add_argument('patches', nargs='+')
    a = ap.parse_args()
    total = 0
    for p in a.patches:
        for path, no, txt, mine, theirs in check(p, a.base, a.ref, a.cache, a.nombres):
            total += 1
            print('%s:%d: %s\n    aquí:  %s\n    en %s: %s' % (path, no, txt[:100], mine, a.ref, theirs))
    print('%d aviso(s) en %d parche(s)' % (total, len(a.patches)), file=sys.stderr)
    return 1 if total else 0


if __name__ == '__main__':
    sys.exit(main())
