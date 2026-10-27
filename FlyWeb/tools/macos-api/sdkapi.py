#!/usr/bin/env python3
"""Lista de API de macOS posteriores a 10.14 a partir de dos SDK.

1) Símbolos enlazables (funciones C, constantes, clases ObjC): los .tbd del SDK nuevo menos los del 10.14.
2) Métodos, propiedades y constantes de enum de ObjC/C: cabeceras del SDK nuevo con API_AVAILABLE(macos(>10.14)).
Salida TSV: tipo, identificador, versión (o 'tbd'), framework.
Uso: sdkapi.py SDK_1014 SDK_NUEVO > api-1015plus.tsv
"""
import os, re, sys

def tbd_symbols(sdk):
    out = {}
    for root, _, files in os.walk(sdk):
        for f in files:
            if not f.endswith('.tbd'):
                continue
            p = os.path.join(root, f)
            if os.path.islink(p) or 'PrivateFrameworks' in p or '/Swift' in p:
                continue
            txt = open(p, errors='replace').read()
            fw = re.search(r"install-name:\s*'?([^'\n]+)", txt)
            fw = fw.group(1).split('/')[-1] if fw else f
            # bloques de exports con targets/archs; nos quedamos con los que incluyen x86_64
            for blk in re.split(r'\n\s*- (?=targets:|archs:)', txt):
                head = blk[:400]
                if 'x86_64' not in head and 'archs:' not in head and 'targets:' not in head:
                    continue
                if ('targets:' in head or 'archs:' in head) and 'x86_64' not in head.split(']')[0]:
                    continue
                for key, kind in (('symbols', 'sym'), ('objc-classes', 'class'), ('weak-symbols', 'sym')):
                    for m in re.finditer(key + r':\s*\[([^\]]*)\]', blk):
                        for s in m.group(1).replace('\n', ' ').split(','):
                            s = s.strip().strip("'")
                            if not s:
                                continue
                            if kind == 'class':
                                s = s.lstrip('_')
                                if s.startswith('OBJC_CLASS_$_'):
                                    s = s[len('OBJC_CLASS_$_'):]
                            else:
                                if s.startswith('_OBJC_CLASS_$_'):
                                    s, kind2 = s[len('_OBJC_CLASS_$_'):], 'class'
                                    out.setdefault((kind2, s), fw)
                                    continue
                                if s.startswith('_OBJC_') or s.startswith('.objc'):
                                    continue
                                s = s[1:] if s.startswith('_') else s
                            out.setdefault((kind, s), fw)
    return out

VER = r'(\d+)(?:[._](\d+))?'
PATS = [
    re.compile(r'\bmacos(?:x)?\(\s*' + VER),
    re.compile(r'NS_AVAILABLE_MAC\(\s*' + VER),
    re.compile(r'CF_AVAILABLE_MAC\(\s*' + VER),
    re.compile(r'NS_AVAILABLE\(\s*' + VER),
    re.compile(r'NS_CLASS_AVAILABLE_MAC\(\s*' + VER),
    re.compile(r'__MAC_' + VER),
    re.compile(r'MAC_OS_X_VERSION_' + VER + r'_AND_LATER'),
    re.compile(r'API_AVAILABLE_BEGIN\(\s*macos\(\s*' + VER),
]

def newer(text):
    for p in PATS:
        m = p.search(text)
        if m:
            a, b = int(m.group(1)), int(m.group(2) or 0)
            if a > 10 or (a == 10 and b >= 15):
                return f'{a}.{b}'
            return None
    return None

def header_api(sdk):
    out = {}
    for root, _, files in os.walk(sdk):
        for f in files:
            if not f.endswith('.h'):
                continue
            p = os.path.join(root, f)
            fw = p.split('/Frameworks/')[-1].split('.framework')[0] if '/Frameworks/' in p else 'usr/include'
            try:
                txt = open(p, errors='replace').read()
            except OSError:
                continue
            txt = re.sub(r'/\*.*?\*/', ' ', txt, flags=re.S)
            txt = re.sub(r'//[^\n]*', ' ', txt)
            # declaraciones = trozos hasta ';' o '{' o '}' o una línea de @interface
            for stmt in re.split(r'[;{}]|\n(?=\s*@)', txt):
                if 'API_UNAVAILABLE(macos' in stmt and 'macos(' not in stmt.replace('API_UNAVAILABLE(macos', ''):
                    continue
                v = newer(stmt)
                if not v:
                    continue
                s = ' '.join(stmt.split())
                s = re.sub(r'#\s*\w+[^@]*?(?=[-+@]|$)', '', s) if s.startswith('#') else s
                m = re.search(r'(?:^|\s)([-+])\s*\([^)]*\)\s*(\w+)(\s*:)?', s)
                if m:
                    sel = m.group(2) + (':' if m.group(3) else '')
                    out.setdefault(('method', sel, fw), v)
                    continue
                m = re.search(r'@property\s*(?:\([^)]*\))?[^;]*?\b(\w+)\s*(?:API_|NS_|__|AVAILABLE|$)', s)
                if m and '@property' in s:
                    out.setdefault(('property', m.group(1), fw), v)
                    continue
                m = re.search(r'^\s*(\w+)\s+(?:API_|NS_|CF_|__API|AVAILABLE)[^=,]*(?:=[^,]*)?,?\s*$', s)
                if m and m.group(1)[0].isupper() or (m and m.group(1).startswith('k')):
                    out.setdefault(('enum', m.group(1), fw), v)
    return out

if __name__ == '__main__':
    old, new = sys.argv[1], sys.argv[2]
    o, n = tbd_symbols(old), tbd_symbols(new)
    oldnames = set(o)
    for (kind, s), fw in sorted(n.items()):
        if (kind, s) in oldnames or s.startswith('$') or s.startswith('__') or 'Swift' in fw:
            continue
        print(f'{kind}\t{s}\ttbd\t{fw}')
    for (kind, s, fw), v in sorted(header_api(new).items()):
        print(f'{kind}\t{s}\t{v}\t{fw}')
