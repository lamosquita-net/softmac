#!/usr/bin/env python3
# trasmove.py <área> <base>: usos de una variable después de std::move(variable) en la misma función, cuando el move
# o el uso son líneas que añade el porte (git diff <base>..HEAD). En upstream ComputedStyle es GC (puntero crudo: el
# move no lo vacía); en la 116 es scoped_refptr y queda nulo (caída de RecalcOwnStyle, FM.28). MOTOR-13.
import subprocess,re,sys,os
W=f'/tmp/claude-0/port/w-{sys.argv[1]}'; base=sys.argv[2]
g=lambda *a: subprocess.run(['git']+list(a),capture_output=True,text=True,cwd=W).stdout
files=[f for f in g('diff','--name-only','--diff-filter=AM',base,'HEAD','--','*.cc','*.h').split()]
def added(f):
    s=set(); n=0
    for l in g('diff','-U0',base,'HEAD','--',f).split('\n'):
        m=re.match(r'@@ -\S+ \+(\d+)(?:,(\d+))? @@',l)
        if m: n=int(m.group(1)); continue
        if l.startswith('+') and not l.startswith('+++'): s.add(n); n+=1
    return s
def strip(t):
    t=re.sub(r'//[^\n]*',lambda m:' '*len(m.group(0)),t)
    t=re.sub(r'/\*.*?\*/',lambda m:re.sub(r'[^\n]',' ',m.group(0)),t,flags=re.S)
    return re.sub(r'"(\\.|[^"\\\n])*"',lambda m:'"'+' '*(len(m.group(0))-2)+'"',t)
tot=0
for f in files:
    t=strip(open(os.path.join(W,f),errors='ignore').read()); add=added(f)
    if not add: continue
    line=lambda p: t.count('\n',0,p)+1
    for m in re.finditer(r'std::move\(\s*(\w+)\s*\)',t):
        v=m.group(1); p=m.end()
        # final de la función: donde la profundidad de llaves baja por debajo de la del move
        d=0; q=p
        while q<len(t):
            c=t[q]
            if c=='{': d+=1
            elif c=='}':
                d-=1
                if d<0: break
            q+=1
        body=t[p:q]
        for u in re.finditer(r'(?<![\w.>:])'+re.escape(v)+r'\b(?!\s*=[^=])',body):
            # una reasignación (v = ...) corta la búsqueda
            pre=body[:u.start()]
            if re.search(r'(?<![\w.>:])'+re.escape(v)+r'\s*=[^=]',pre): break
            lm,lu=line(m.start()),line(p+u.start())
            if lm in add or lu in add:
                print(f'{f}:{lm} move({v}) → uso en {lu}: {t.split(chr(10))[lu-1].strip()[:100]}'); tot+=1
            break
print(f'{tot} candidatos')
