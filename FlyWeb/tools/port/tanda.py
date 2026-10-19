#!/usr/bin/env python3
# tanda.py <prefijo> <tsv> : porta cada flag "FLAG ADD [REM]" de <tsv> (una por línea, en orden) con portar.sh sobre la
# rama actual de brave-core; arregla solo la entrada del json5 (quitarla si upstream la quitó, o dejarla en stable),
# devuelve a su estado los ficheros de chrome://flags y variaciones, y si no queda ningún .rej genera, comprueba
# (chk.sh) y hace commit. Lo que tenga rechazos se queda en w-<flag> y se lista al final para hacerlo a mano.
import subprocess, sys, os, glob, re
P='/tmp/claude-0/port'; BC='/home/user/brave-core'; CR='/home/user/chromium/chromium'
J='third_party/blink/renderer/platform/runtime_enabled_features.json5'
SKIP=re.compile(r'android_webview|testing/variations|chrome/browser/about_flags\.cc|flag_descriptions|flag-metadata\.json|tools/metrics|ios/')
def sh(c, cwd=None): return subprocess.run(c, shell=True, cwd=cwd, capture_output=True, text=True)
pref=sys.argv[1]; manual=[]
for line in open(sys.argv[2]):
    if not line.strip() or line.startswith('#'): continue
    flag, add, *rem = line.split()
    W=f'{P}/w-{flag}'
    out=sh(f'./portar.sh {flag} {add} {" ".join(rem)}', cwd=P).stdout
    # Ficheros de flags de Chrome y variaciones: como estaban.
    for f in sh('git diff --name-only HEAD~%d' % (1+len(rem)) , cwd=W).stdout.split():
        pass
    base=sh('git rev-list --max-parents=0 HEAD', cwd=W).stdout.strip()
    brave=sh(f'git rev-list --ancestry-path {base}..HEAD | tail -1', cwd=W).stdout.strip()
    for f in sh(f'git diff --name-only {brave} HEAD', cwd=W).stdout.split() + [r[:-4] for r in glob.glob('**/*.rej', root_dir=W, recursive=True)]:
        if SKIP.search(f):
            sh(f'git checkout {brave} -- {f} 2>/dev/null || rm -f {f}', cwd=W); sh(f'rm -f {f}.rej', cwd=W)
    jrej=os.path.exists(f'{W}/{J}.rej')
    if jrej: os.remove(f'{W}/{J}.rej')
    if os.path.exists(f'{W}/{J}'):
        s=open(f'{W}/{J}').read(); has=re.search(r'name: "'+re.escape(flag)+r'"', s)
        if rem and has: sh(f'python3 {P}/delflag.py {J} {flag}', cwd=W)
        if not rem and not has: sh(f'python3 {P}/addflag.py {J} {flag} stable', cwd=W)
        if not rem and has:
            s=open(f'{W}/{J}').read()
            m=re.search(r'\n    \{\n(?:      //.*\n)*      name: "'+re.escape(flag)+r'",\n(?:      .*\n|        .*\n)*?    \},', s)
            blk=m.group(0); nb=re.sub(r'status: (\{[^}]*\}|"[^"]*")', 'status: "stable"', blk, count=1)
            if 'status:' not in nb: nb=nb.replace('name: "'+flag+'",\n', 'name: "'+flag+'",\n      status: "stable",\n')
            if nb!=blk: open(f'{W}/{J}','w').write(s.replace(blk,nb)); print('  status -> stable', flag, flush=True)
    rej=[r for r in glob.glob('**/*.rej', root_dir=W, recursive=True)]
    if rej:
        manual.append(f'{flag}: '+' '.join(rej)); print('MANUAL', flag, rej, flush=True); continue
    sh('git add -A && git -c user.email=x -c user.name=x commit -qm fix', cwd=W)
    g=sh(f'BASE_REF=nube/motor-131-escapes ./generar.sh {flag}', cwd=P)
    if sh('git status --short patches', cwd=BC).stdout.strip()=='' :
        print('SIN CAMBIOS', flag, flush=True); continue
    subj=sh(f'git log -1 --format=%s {add}', cwd=CR).stdout.strip()
    msg=f'FM.22 {pref}: {flag}\n\nPort of {add} ("{subj}")' + (f' and its flag removal {" ".join(rem)}' if rem else ', flag stable') + '.\n\nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>\nClaude-Session: https://claude.ai/code/session_01E9YyQZz5fNhwE1HdRNzw6f\n'
    open(f'{P}/msg.txt','w').write(msg)
    sh(f'git add -A patches && git commit -q -F {P}/msg.txt', cwd=BC)
    c=sh(f'{P}/chk.sh HEAD HEAD~1', cwd=BC).stdout.strip().split('\n')[-1]
    warn=[l for l in g.stdout.split('\n') if 'AVISO' in l]
    print('OK', flag, c, ' '.join(warn), flush=True)
print('\nA MANO:\n'+'\n'.join(manual))
