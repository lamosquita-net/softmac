# edits.py <área> <fichero> <old> <new> ...  (pares en un fichero JSON) → reemplazos exactos (una vez cada uno)
import json,sys
area,spec=sys.argv[1],sys.argv[2]
for p,pairs in json.load(open(spec)).items():
    path=f'/tmp/claude-0/port/w-{area}/{p}'
    s=open(path).read()
    for old,new in pairs:
        assert s.count(old)==1,(p,old[:120])
        s=s.replace(old,new)
    open(path,'w').write(s)
print('ok')
