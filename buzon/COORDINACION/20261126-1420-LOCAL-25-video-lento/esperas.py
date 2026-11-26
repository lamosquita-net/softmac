#!/usr/bin/env python3
# LOCAL-25 · vídeo lento (ARQUITECTURA, 25-11): en un sample de un cliente (renderer o navegador), quién llama a las
# esperas y envíos al proceso de GPU, por hilo y por rama: los N marcos con nombre propio por ENCIMA del primer marco
# objetivo. Uso: esperas.py <sample> [N=6]
import sys, os, re, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DSYM', os.path.expanduser('~/proyectos/b2-porte-mac/src/out/Release-322/FlyWeb Framework.dSYM/Contents/Resources/DWARF/FlyWeb Framework'))
import analizar_sample as A
OBJ = re.compile(r'(CommandBufferProxyImpl::(WaitForGetOffsetInRange|WaitForTokenInRange|Flush|OrderingBarrier|EnsureWorkVisible|'
                 r'SignalSyncToken|SignalQuery|CreateGpuFence|GetLastState)|GpuChannelHost::(Send|EnqueuePending|EnsureFlush|VerifyFlush)|'
                 r'CommandBufferHelper::(WaitForAvailableEntries|Finish|WaitForToken|Flush)|ClientSharedImageInterface|SharedImageInterfaceProxy::|'
                 r'GLES2Implementation::(Finish|Flush|ShallowFlushCHROMIUM|GetIntegerv|GetError|ReadPixels|GenSyncToken|VerifySyncTokens|WaitSync)|'
                 r'(Raster|Context)Implementation::(Finish|Flush|ShallowFlush|GenSyncToken|WaitSync)|SyncPointClient|mojo::SyncCallRestrictions|'
                 r'SyncHandleRegistry::Wait|mojo::.*SyncCall)')
RUIDO = re.compile(r'^(base::internal::|base::OnceCallback|base::RepeatingCallback|std::__Cr::|<deduplicated_symbol>|void base::internal|decltype|'
                   r'base::apple::CallWithEHFrame|invocation function for block|0x[0-9a-f]+|\?\?\?)')
fn = sys.argv[1]; N = int(sys.argv[2]) if len(sys.argv) > 2 else 6
hs = A.leer(fn); A.simbolizar(hs)
print(f'\n### {os.path.basename(fn)}\n')
algo = False
for h in hs:
    ramas = collections.Counter(); obj = collections.Counter(); tot = 0
    for s, c in A.caminos(h):
        idx = [i for i, x in enumerate(c) if OBJ.search(x['f'])]
        if not idx: continue
        i0 = idx[0]; tot += s
        obj[A.corto(c[i0]['f']) + ('  (espera)' if A.ESPERA.match(c[-1]['f']) else '  (activo)')] += s
        arriba = [A.corto(x['f']) for x in c[:i0] if not RUIDO.match(x['f'])][-N:]
        ramas[' < '.join(reversed(arriba)) + '  ⇒  ' + A.corto(c[i0]['f'])] += s
    if not tot: continue
    algo = True
    print(f'**{h["nombre"]}**: {tot} de {h["total"]} muestras (1 ms) bajo funciones objetivo\n')
    for k, v in obj.most_common(8): print(f'- {v} · {k}')
    print('\n| muestras | quién lo pide (de cerca a lejos) ⇒ función objetivo |\n|---|---|')
    for k, v in ramas.most_common(12): print(f'| {v} | {k[:400]} |')
    print()
if not algo: print('Ningún hilo pasa por las funciones objetivo.\n')
