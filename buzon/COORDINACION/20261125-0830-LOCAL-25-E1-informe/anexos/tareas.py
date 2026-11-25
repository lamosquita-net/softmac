#!/usr/bin/env python3
# LOCAL-25 · vídeo (a): qué atienden CrGpuMain y Chrome_ChildIOThread en un sample del proceso GPU.
# Por cada pila activa (sin esperas), la tarea = los marcos justo debajo del último RunTask del bucle (TaskAnnotator::RunTaskImpl
# o RunTask); si no hay, el primer marco de FlyWeb bajo el bucle del sistema (fuentes del CFRunLoop, kevent…). Cuentas en muestras de 1 ms.
import sys, os, re, collections, json
sys.path.insert(0, os.path.expanduser('~/proyectos/softmac/temp/local21'))
os.environ.setdefault('DSYM', os.path.expanduser('~/proyectos/b2-porte-mac/src/out/Release-322/FlyWeb Framework.dSYM/Contents/Resources/DWARF/FlyWeb Framework'))
import analizar_sample as A
HILOS = ('com.apple.main-thread', 'CrGpuMain', 'Chrome_ChildIOThread', 'VizCompositorThread')
RUN = re.compile(r'TaskAnnotator::RunTaskImpl|TaskAnnotator::RunTask\b|ThreadControllerWithMessagePumpImpl::DoWorkImpl')
RUIDO = re.compile(r'^(base::internal::Invoker|base::OnceCallback|base::RepeatingCallback|base::internal::FunctorTraits|base::internal::DecayedFunctorTraits|'
                   r'base::internal::InvokeHelper|std::__1::__invoke|base::TaskAnnotator|base::sequence_manager|base::internal::BindState|'
                   r'base::internal::RunMixin|void base::internal|decltype)')
def tarea(c):
    idx = [i for i, x in enumerate(c) if RUN.search(x['f'])]
    if idx:
        resto = [x for x in c[idx[-1]+1:] if not RUIDO.match(x['f'])]
        return 'tarea: ' + ' > '.join(A.corto(x['f']) for x in resto[:2]) if resto else 'tarea: (bucle)'
    fw = [x for x in c if x['mod'] == 'FlyWeb Framework' and not re.match(r'^(ChromeMain|main|base::MessagePump|base::RunLoop|base::Thread)', x['f'])]
    return 'fuera de tarea: ' + ' > '.join(A.corto(x['f']) for x in fw[-2:]) if fw else 'fuera de tarea: ' + A.corto(c[-1]['f'])
def informe(fn):
    hs = A.leer(fn); A.simbolizar(hs); r = {}
    for h in hs:
        if h['nombre'] not in HILOS: continue
        cs = A.caminos(h); act = sum(s for s, c in cs if not A.ESPERA.match(c[-1]['f']))
        t = collections.Counter(); hoja = collections.Counter()
        for s, c in cs:
            if A.ESPERA.match(c[-1]['f']): continue
            t[tarea(c)] += s; hoja[A.corto(c[-1]['f']) + ' [' + c[-1]['mod'] + ']'] += s
        r[h['nombre']] = {'total': h['total'], 'activo': act, 'tareas': t.most_common(25), 'hojas': hoja.most_common(12)}
    return r
if __name__ == '__main__':
    print(json.dumps({os.path.basename(f): informe(f) for f in sys.argv[1:]}, indent=1, ensure_ascii=False))
