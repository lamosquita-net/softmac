#!/usr/bin/env python3
# LOCAL-25 · vídeo (a): bajo un marco del bucle (p. ej. DoWork, Scheduler::RunNextTask), qué funciones se ejecutan
# (primer marco con nombre propio por debajo, saltando la fontanería de callbacks), lento frente a recuperado.
import sys, os, re, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DSYM', os.path.expanduser('~/proyectos/b2-porte-mac/src/out/Release-322/FlyWeb Framework.dSYM/Contents/Resources/DWARF/FlyWeb Framework'))
import analizar_sample as A
RUIDO = re.compile(r'^(base::internal::|base::OnceCallback|base::RepeatingCallback|std::__Cr::__invoke|<deduplicated_symbol>|base::TaskAnnotator|'
                   r'non-virtual thunk to base::sequence_manager|base::sequence_manager::internal::(ThreadControllerWithMessagePumpImpl|SequenceManagerImpl)|'
                   r'void base::internal|decltype|base::apple::CallWithEHFrame|invocation function for block)')
def carga(fn, hilo, marco, prof):
    hs = A.leer(fn); A.simbolizar(hs)
    for h in hs:
        n = 'CrGpuMain' if h['nombre'] == 'com.apple.main-thread' else h['nombre']
        if n != hilo: continue
        c_ = collections.Counter(); tot = 0
        for s, c in A.caminos(h):
            if A.ESPERA.match(c[-1]['f']): continue
            idx = [i for i, x in enumerate(c) if re.search(marco, x['f'])]
            if not idx: continue
            tot += s
            resto = [A.corto(x['f']) for x in c[idx[-1]+1:] if not RUIDO.match(x['f'])]
            c_[' > '.join(resto[:prof]) if resto else '(propio)'] += s
        return h['total'], tot, c_
fl, fr, hilo, marco = sys.argv[1:5]; prof = int(sys.argv[5]) if len(sys.argv) > 5 else 1
tl, nl, cl = carga(fl, hilo, marco, prof); tr, nr, cr = carga(fr, hilo, marco, prof); esc = tl / tr
print(f'\n#### {hilo} · bajo «{marco}»: lento {nl} de {tl} ms, recuperado {nr} de {tr} ms (escalado ×{esc:.2f})\n')
print('| lento | recuperado (escalado) | diferencia | función |\n|---|---|---|---|')
ks = set(cl) | set(cr)
for k in sorted(ks, key=lambda k: -(cl.get(k, 0) + cr.get(k, 0) * esc))[:25]:
    print(f'| {cl.get(k,0)} | {cr.get(k,0)*esc:.0f} | {cl.get(k,0)-cr.get(k,0)*esc:+.0f} | {k[:170]} |')
