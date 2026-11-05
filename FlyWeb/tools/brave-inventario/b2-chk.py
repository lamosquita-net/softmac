"""Comprobación estática sin compilar (B2, MOTOR-31): #include "brave/..." y etiquetas //brave/... que apuntan a algo
inexistente, en ficheros de escritorio. Uso: python3 -I b2-chk.py CHECKOUT_BRAVE_CORE > salida.txt; comparar con la salida
de la rama base (comm -13 base.txt rama.txt) para ver solo lo nuevo. Generados (.mojom.h, grit/, buildflags.h): basta
con que exista el directorio."""
import re,os,subprocess,sys
os.chdir(sys.argv[1])
files=subprocess.check_output(['git','ls-files']).decode().split('\n')
skip=lambda f: f.startswith(('android/','ios/','chromium_src/ios/','third_party/','patches/')) or '/android/' in f or f.endswith(('_android.cc','_android.h','_ios.mm','_ios.h'))
inc=re.compile(r'#\s*(?:include|import)\s+"brave/([^"]+)"')
lab=re.compile(r'"//brave/([A-Za-z0-9_\-./]+)(?::[^"]*)?"')
gen=('.mojom.h','.mojom-forward.h','.mojom-shared.h','.mojom-blink.h','.mojom-blink-forward.h','.pb.h','_jni.h','.mojom-test-utils.h')
for f in files:
    if not f or skip(f): continue
    if f.endswith(('.cc','.h','.mm','.m')):
        try: t=open(f,errors='ignore').read()
        except: continue
        for m in inc.finditer(t):
            p=m.group(1)
            if os.path.exists(p): continue
            if (p.endswith(gen) or '/grit/' in p or p.endswith('buildflags.h')) and os.path.isdir(os.path.dirname(p).split('/grit')[0]): continue
            print('INC',p,f)
    if f.endswith(('BUILD.gn','.gni')):
        t=open(f,errors='ignore').read()
        for m in lab.finditer(t):
            p=m.group(1).rstrip('/')
            if ('.' in os.path.basename(p)) and os.path.exists(p): continue
            if os.path.isdir(p): continue
            print('GN',p,f)
