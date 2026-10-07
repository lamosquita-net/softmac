# Uso: addflag.py <json5> <Nombre> <status>  → inserta {name, status} antes de la primera entrada con nombre mayor
import re,sys
p,name,st=sys.argv[1:4]; s=open(p).read()
assert f'name: "{name}"' not in s, 'ya está'
start=s.index('data: [')
for m in re.finditer(r'\n    \{\n((?:      //[^\n]*\n)*)      name: "([^"]+)"', s[start:]):
    if m.group(2).lower()>name.lower():
        i=start+m.start()
        s=s[:i]+f'\n    {{\n      name: "{name}",\n      status: "{st}",\n    }},'+s[i:]
        open(p,'w').write(s); print('antes de',m.group(2)); break
