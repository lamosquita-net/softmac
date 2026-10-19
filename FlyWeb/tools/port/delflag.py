#!/usr/bin/env python3
# delflag.py <json5> <Nombre>... : quita la entrada de cada flag de runtime_enabled_features.json5
# (con los comentarios que lleve dentro de las llaves).
import re, sys
p = sys.argv[1]; s = open(p).read()
for n in sys.argv[2:]:
    m = re.search(r'\n    \{\n(?:      //.*\n)*      name: "' + re.escape(n) + r'",\n(?:      .*\n|        .*\n)*?    \},', s)
    if not m: sys.exit('no encontrada: ' + n)
    s = s[:m.start()] + s[m.end():]
open(p, 'w').write(s)
