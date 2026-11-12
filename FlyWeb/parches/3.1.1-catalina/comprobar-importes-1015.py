#!/usr/bin/env python3
# Comprueba, sin compilar, qué importes de un binario de FlyWeb no existen en un SDK de macOS
# (por defecto el 10.15 de Xcode 11.3.1, que está en la 6,1) y si son débiles o fuertes.
# MOTOR-45, 12-11-2026. Uso en un Mac:
#   python3 comprobar-importes-1015.py \
#     "/Applications/FlyWeb.app/Contents/Frameworks/FlyWeb Framework.framework/FlyWeb Framework" \
#     /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk
# Salida: una línea por símbolo que falta en el SDK, con «débil» o «FUERTE» y la biblioteca.
# Un FUERTE que falta es el caso de _CGPreflightScreenCaptureAccess en la 3.1.0: dyld lo enlaza en la
# primera llamada y aborta («lazy symbol binding failed»). Un débil que falta vale NULL: no aborta al
# cargar, pero llamarlo o leerlo cuelga igual. Lo que importa en los dos casos es la guarda del código.
import glob
import os
import re
import subprocess
import sys


def tbd_names(sdk):
    names = set()
    paths = glob.glob(os.path.join(sdk, 'System/Library/Frameworks/**/*.tbd'), recursive=True)
    paths += glob.glob(os.path.join(sdk, 'System/Library/PrivateFrameworks/**/*.tbd'), recursive=True)
    paths += glob.glob(os.path.join(sdk, 'usr/lib/**/*.tbd'), recursive=True)
    for p in paths:
        try:
            text = open(p, errors='ignore').read()
        except OSError:
            continue
        for tok in re.findall(r"[A-Za-z_$][\w$.:]*", text):
            names.add(tok)
    return names, len(paths)


def system_libraries(binary):
    """Hoja del nombre de cada dylib → si es del sistema (/System o /usr/lib)."""
    out = subprocess.run(['otool', '-L', binary], capture_output=True, text=True).stdout
    libs = {}
    for line in out.splitlines()[1:]:
        path = line.strip().split(' (')[0]
        if not path:
            continue
        leaf = os.path.basename(path).split('.')[0]
        libs[leaf] = path.startswith('/System/') or path.startswith('/usr/lib/')
    return libs


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__ or 'uso: comprobar-importes-1015.py <binario> [<SDK>]')
    binary = sys.argv[1]
    sdk = sys.argv[2] if len(sys.argv) > 2 else \
        '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk'
    names, ntbd = tbd_names(sdk)
    if ntbd == 0:
        sys.exit(f'no hay .tbd en {sdk}')
    libs = system_libraries(binary)
    nm = subprocess.run(['nm', '-m', binary], capture_output=True, text=True).stdout
    missing, total = [], 0
    for line in nm.splitlines():
        m = re.search(r'\(undefined\) (weak )?external (\S+) \(from ([^)]+)\)', line)
        if not m:
            continue
        weak, sym, lib = bool(m.group(1)), m.group(2), m.group(3)
        if not libs.get(lib, False):
            continue  # Sparkle, frameworks propios, etc.
        total += 1
        key = sym
        for prefix in ('_OBJC_CLASS_$_', '_OBJC_METACLASS_$_', '_OBJC_EHTYPE_$_', '_OBJC_IVAR_$_'):
            if sym.startswith(prefix):
                key = sym[len(prefix):]
        if key in names or sym in names or ('_' + key) in names:
            continue
        missing.append((lib, sym, weak))
    missing.sort()
    for lib, sym, weak in missing:
        print(f"{'débil ' if weak else 'FUERTE'}\t{lib}\t{sym}")
    strong = sum(1 for _, _, w in missing if not w)
    print(f'# {total} importes del sistema; {len(missing)} no están en {os.path.basename(sdk)} '
          f'({strong} fuertes, {len(missing) - strong} débiles); {ntbd} .tbd leídos', file=sys.stderr)


if __name__ == '__main__':
    main()
