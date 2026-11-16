#!/usr/bin/env python3
# ARQUITECTURA · reparto del hilo principal del renderer a partir de un `sample` de macOS 10.14.
# Uso: reparto-renderer.py toma.txt "/ruta/FlyWeb Framework.dSYM/Contents/Resources/DWARF/FlyWeb Framework"
# Simboliza FlyWeb Framework con atos y clasifica cada muestra del hilo principal en una categoría.
# Aviso: `sample` congela el renderer en cada toma; vale el reparto, no el % de ocupación (rendimiento-3x.md §2.1).
import re, subprocess, sys, collections

ESPERA = re.compile(r'^(mach_msg_trap|mach_msg2_trap|__psynch_cvwait|__workq_kernreturn|kevent64|kevent_id|kevent|__select|'
                    r'semaphore_wait_trap|semaphore_timedwait_trap|__ulock_wait|__semwait_signal|read|__recvmsg|poll|swtch_pri|'
                    r'thread_switch)$')
LINEA = re.compile(r'^([\s+!:|]*?)(\d+) (.*)$')
# Fases: mandan si aparecen en cualquier punto de la pila.
FASES = [
    ('GC (V8 y Oilpan)', re.compile(r'v8::internal::(Heap::CollectGarbage|Heap::PerformGarbageCollection|Scavenger|ScavengerCollector|'
                                    r'MarkCompactCollector|MinorMarkSweep|IncrementalMarking|Sweeper|GCTracer)|cppgc::internal::(Marker|Sweeper|'
                                    r'HeapBase::CollectGarbage|StatsCollector)|blink::ThreadState::(Collect|RunTermination)')),
    ('Compilar JS (parser, bytecode, Sparkplug/Maglev/TurboFan en el hilo)', re.compile(
        r'v8::internal::(Compiler::|parsing::|Parser|ParserBase|PreParser|interpreter::BytecodeGenerator|baseline::|maglev::|'
        r'compiler::|OptimizedCompilationJob|TieringManager|Runtime_CompileLazy|Runtime_CompileOptimized|wasm::.*Compil)')),
    ('Estilo, layout y pintado', re.compile(
        r'blink::(StyleEngine|StyleResolver|Document::UpdateStyle|LocalFrameView::(UpdateLifecycle|UpdateAllLifecycle|RunStyleAndLayout|'
        r'UpdateStyleAndLayout|RunPaint|RunPrePaint)|PrePaintTreeWalk|PaintArtifactCompositor|LayoutView::|BlockNode::Layout|'
        r'FramePainter|PaintLayerPainter)')),
]
# Resto: de la hoja hacia la raíz, la primera que encaje.
HOJA = [
    ('Cliente del command buffer (GLES2Implementation)', re.compile(r'gpu::(gles2::|CommandBuffer|TransferBuffer|.*CmdHelper|ClientDiscardable|ImplementationBase)')),
    ('base::FeatureList', re.compile(r'base::FeatureList')),
    ('Math.sin / Math.cos (ieee754)', re.compile(r'ieee754::|base::ieee754')),
    ('Enlaces WebGL de Blink (con el paso de V8 a Blink)', re.compile(
        r'blink::(WebGL|V8WebGL|DrawingBuffer|WebGL2|V8PerIsolateData|NativeValueTraits)|WebGL|v8_webgl|'
        r'v8::(Value::Is|ArrayBufferView|TypedArray|Object::)|JSTypedArray')),
    ('Código JS compilado (JIT)', re.compile(r'^\?\?\?|^0x[0-9a-f]+$|<unknown binary>')),
    ('V8: builtins, runtime e IC', re.compile(r'v8::|Builtins_|v8_')),
    ('Blink: lo demás (rAF, DOM, planificador)', re.compile(r'blink::|WTF::|cc::')),
]

def marco(t):
    m = re.match(r'^(.*?)\s+\(in (.+?)\)(.*)$', t)
    if not m: return t.strip(), '', None
    ab = re.search(r'\[(0x[0-9a-f]+)', m.group(3))
    return m.group(1).strip(), m.group(2), (ab.group(1) if ab else None)

def leer(fn):
    base = None
    for l in open(fn, errors='replace'):
        b = re.match(r'^\s*(0x[0-9a-f]+)\s+-\s+0x[0-9a-f]+\s+.*/FlyWeb Framework\s*$', l)
        if b: base = b.group(1)
    hilos, pila, actual, dentro = [], [], None, False
    for l in open(fn, errors='replace'):
        l = l.rstrip('\n')
        if l.startswith('Call graph:'): dentro = True; continue
        if not dentro: continue
        if l.startswith(('Total number in stack', 'Sort by top of stack', 'Binary Images')): break
        m = LINEA.match(l)
        if not m: continue
        ind, n, t = len(m.group(1)), int(m.group(2)), m.group(3).strip()
        if t.startswith('Thread_') and ind <= 4:
            mm = re.match(r'^Thread_\d+\s*(?:DispatchQueue_\d+:\s*([^ ]+).*|:\s*(.+))?$', t)
            nombre = ((mm.group(2) or mm.group(1)) if mm else None) or 'sin nombre'
            actual = {'nombre': nombre.strip(), 'total': n, 'nodos': []}; hilos.append(actual); pila = [(ind, -1)]; continue
        if actual is None: continue
        while pila and pila[-1][0] >= ind: pila.pop()
        padre = pila[-1][1] if pila else -1
        f, mod, off = marco(t)
        actual['nodos'].append({'n': n, 'f': f, 'mod': mod, 'off': off, 'padre': padre, 'hijos': 0})
        if padre >= 0: actual['nodos'][padre]['hijos'] += n
        pila.append((ind, len(actual['nodos']) - 1))
    return hilos, base

def simbolizar(hilos, base, dsym):
    offs = sorted({x['off'] for h in hilos for x in h['nodos'] if x['off'] and x['mod'] == 'FlyWeb Framework'})
    tab = {}
    for i in range(0, len(offs), 2000):
        trozo = offs[i:i+2000]
        out = subprocess.run(['atos', '-o', dsym, '-arch', 'x86_64', '-l', base] + trozo, capture_output=True, text=True).stdout.split('\n')
        for o, s in zip(trozo, out): tab[o] = re.sub(r'\s+\(in FlyWeb Framework\).*$', '', s.strip())
    for h in hilos:
        for x in h['nodos']:
            if x['off'] and x['mod'] == 'FlyWeb Framework': x['f'] = tab.get(x['off'], x['f'])

def pila_de(h, i):
    r = []
    while i >= 0:
        x = h['nodos'][i]; r.append(x); i = x['padre']
    return r  # de la hoja a la raíz

def clasificar(p):
    if ESPERA.match(p[0]['f']): return 'espera'
    nombres = [(x['f'] if x['mod'] != '<unknown binary>' else '<unknown binary>') for x in p]
    for cat, rx in FASES:
        if any(rx.search(n) for n in nombres): return cat
    for n in nombres:
        for cat, rx in HOJA:
            if rx.search(n): return cat
    return 'Otros (sistema, base, mojo)'

def main():
    fn, dsym = sys.argv[1], sys.argv[2]
    hilos, base = leer(fn)
    simbolizar(hilos, base, dsym)
    print('== Hilos del proceso (muestras activas / total)')
    for h in hilos:
        act = sum(x['n'] - x['hijos'] for x in h['nodos'] if x['n'] > x['hijos'] and not ESPERA.match(x['f']))
        if act: print(f"  {h['nombre']:<50} {act:>5} / {h['total']}  {100*act/h['total']:5.1f} %")
    print(f"  (hilos en total: {len(hilos)}; con alguna muestra activa: "
          f"{sum(1 for h in hilos if any(x['n'] > x['hijos'] and not ESPERA.match(x['f']) for x in h['nodos']))})")
    pr = next(h for h in hilos if 'main-thread' in h['nombre'])
    cuenta = collections.Counter()
    for i, x in enumerate(pr['nodos']):
        propias = x['n'] - x['hijos']
        if propias > 0: cuenta[clasificar(pila_de(pr, i))] += propias
    activo = sum(v for k, v in cuenta.items() if k != 'espera')
    print(f"== Hilo principal: {pr['total']} muestras, {activo} activas")
    for k, v in cuenta.most_common():
        if k != 'espera': print(f"  {100*v/activo:5.1f} %  {k}")

main()
