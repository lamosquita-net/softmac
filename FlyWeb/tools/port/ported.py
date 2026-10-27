# ported.py <test-path>... : commits 128..131 que tocan cada test; marca P si sus líneas añadidas de código (no test) ya
# están en nuestro árbol (w-all o cr128), p si en parte, - si no.
import subprocess,sys,os,re
CH='/home/user/chromium/hist'; W='/tmp/claude-0/port/w-all'; CR='/tmp/claude-0/port/cr128'
def g(*a): return subprocess.run(['git','-C',CH]+list(a),capture_output=True,text=True,errors='ignore').stdout
TEST=re.compile(r'(_test|_unittest|test_helpers|_test_util|/testing/|web_tests/|\.json5$|\.gni?$|BUILD\.gn$|\.md$|OWNERS$|DEPS$|/test/)')
cache={}
def ours(f):
    if f in cache: return cache[f]
    for r in (W,CR):
        p=os.path.join(r,f)
        if os.path.isfile(p): cache[f]=open(p,errors='ignore').read(); return cache[f]
    t=g('show','128.0.6613.138:'+f); cache[f]=t; return t
for T in sys.argv[1:]:
    print('##',T)
    for line in g('log','--reverse','--format=%h %ad %s','--date=short','128.0.6613.138..131.0.6778.264','--',T).splitlines():
        c=line.split()[0]; d=g('show','--format=','--unified=0',c)
        tot=hit=0; cur=None
        for l in d.splitlines():
            if l.startswith('+++ b/'): cur=l[6:]; continue
            if cur is None or TEST.search(cur) or not cur.startswith('third_party/blink/renderer'): continue
            if l.startswith('+') and not l.startswith('+++') and len(l.strip())>3:
                tot+=1; hit+= l[1:] in ours(cur)
        mark='P' if tot and hit>=0.8*tot else ('p' if hit else ('?' if not tot else '-'))
        print(f'{mark} {hit}/{tot} {line[:110]}')
