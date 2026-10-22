# mark.py <commits-file>: P/p/-/? por commit (líneas de código de Blink añadidas que ya están en w-all), y sus tests.
import subprocess,sys,os,re
CH='/home/user/chromium/hist'; W='/tmp/claude-0/port/w-all'
env=dict(os.environ,GIT_NO_LAZY_FETCH='1')
def g(*a): return subprocess.run(['git','-C',CH,'-c','diff.renames=false']+list(a),capture_output=True,text=True,errors='ignore',env=env).stdout
TEST=re.compile(r'(_test\.cc|_unittest\.cc|_test\.h|test_helpers|_test_util|/testing/|web_tests/|\.json5$|\.gni?$|BUILD\.gn$|\.md$|OWNERS$|DEPS$|/test/)')
cache={}
def ours(f):
    if f not in cache:
        p=os.path.join(W,f); cache[f]=open(p,errors='ignore').read() if os.path.isfile(p) else None
    return cache[f]
for line in open(sys.argv[1]):
    if line.startswith('  '): continue
    c=line.split()[0]; d=g('show','--no-renames','--format=','--unified=0',c,'--','third_party/blink/renderer')
    tot=hit=0; cur=None; nofile=set(); tests=set()
    for l in d.splitlines():
        if l.startswith('+++ '): cur=l[6:] if l.startswith('+++ b/') else None; continue
        if cur is None or not cur.startswith('third_party/blink/renderer'): continue
        if TEST.search(cur):
            if re.search(r'(_test\.cc|_unittest\.cc|_test\.h|test_helpers|_test_util|/testing/)',cur): tests.add(cur)
            continue
        if l.startswith('+') and len(l[1:].strip())>3:
            o=ours(cur)
            if o is None: nofile.add(cur); continue
            tot+=1; hit+= l[1:] in o
    mark='P' if tot and hit>=0.8*tot else ('p' if hit else ('?' if not tot else '-'))
    print(f'{mark} {hit}/{tot} {line.strip()[:120]}')
    for f in sorted(nofile): print('   NOFILE',f)
    for t in sorted(tests): print('   T',t, '' if ours(t) is not None else '(nuevo)')
