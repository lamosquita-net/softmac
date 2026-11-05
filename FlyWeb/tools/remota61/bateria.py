# FlyWeb: batería de pruebas por CDP contra un navegador remoto (túnel abierto por prueba-remota.sh).
# Uso: bateria.py <puerto> <dir_capturas> <pruebas…>
#   pruebas: gpu (la batería de FlyWeb/docs/pruebas-gpu.md), motor138 (FlyWeb/tools/motor-138.html servido en la máquina
#   remota), gpuinfo (chrome://gpu), o una prueba suelta de gpu por su número (1a, 3c, 9…).
# Solo usa la biblioteca estándar. Cada prueba va en una pestaña nueva; si el renderer cae, se anota y se sigue.
import base64, json, os, select, socket, struct, sys, time, urllib.request

PORT = int(sys.argv[1]); CAP = sys.argv[2]; PRUEBAS = sys.argv[3:]
MOTOR_URL = os.environ.get('FW_MOTOR_URL', 'http://127.0.0.1:9492/motor-138.html')
os.makedirs(CAP, exist_ok=True)


class Pest:
    """Pestaña nueva con su WebSocket de DevTools."""

    def __init__(s):
        req = urllib.request.Request(f'http://127.0.0.1:{PORT}/json/new?about:blank', method='PUT')
        s.t = json.load(urllib.request.urlopen(req, timeout=20))
        s.s = socket.create_connection(('127.0.0.1', PORT)); s.buf = b''; s.n = 0; s.cayo = False; s.err = []
        k = base64.b64encode(os.urandom(16)).decode(); path = s.t['webSocketDebuggerUrl'].split(f':{PORT}', 1)[1]
        # El Host tiene que ser válido: la 156 corta el WebSocket con un Host inventado.
        s.s.sendall((f'GET {path} HTTP/1.1\r\nHost: 127.0.0.1:{PORT}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n'
                     f'Sec-WebSocket-Key: {k}\r\nSec-WebSocket-Version: 13\r\n\r\n').encode())
        while b'\r\n\r\n' not in s.buf:
            s.buf += s.s.recv(4096)
        s.buf = s.buf.split(b'\r\n\r\n', 1)[1]

    def rd(s, n, fin):
        while len(s.buf) < n:
            if not select.select([s.s], [], [], max(0, fin - time.time()))[0]:
                raise TimeoutError
            b = s.s.recv(1 << 20)
            if not b:
                raise ConnectionError
            s.buf += b
        d, s.buf = s.buf[:n], s.buf[n:]
        return d

    def frame(s, fin):
        _, b2 = s.rd(2, fin); n = b2 & 0x7f
        if n == 126:
            n = struct.unpack('>H', s.rd(2, fin))[0]
        elif n == 127:
            n = struct.unpack('>Q', s.rd(8, fin))[0]
        return json.loads(s.rd(n, fin))

    def call(s, m, p=None, seg=25):
        s.n += 1; b = json.dumps({'id': s.n, 'method': m, 'params': p or {}}).encode()
        h = bytes([0x81, 0x80 | len(b)]) if len(b) < 126 else bytes([0x81, 0x80 | 126]) + struct.pack('>H', len(b))
        mk = os.urandom(4); s.s.sendall(h + mk + bytes(x ^ mk[j % 4] for j, x in enumerate(b)))
        fin = time.time() + seg
        while True:
            r = s.frame(fin); m2 = r.get('method', '')
            if m2 == 'Inspector.targetCrashed':
                s.cayo = True; raise RuntimeError('caída')
            if m2 == 'Runtime.exceptionThrown':
                d = r['params']['exceptionDetails']
                s.err.append((d.get('exception', {}).get('description') or d.get('text', ''))[:300])
            if r.get('id') == s.n:
                return r.get('result', {})

    def ev(s, e, **k):
        return s.call('Runtime.evaluate', {'expression': e, 'returnByValue': True, **k}).get('result', {}).get('value')

    def cierra(s):
        try:
            s.s.close(); urllib.request.urlopen(f'http://127.0.0.1:{PORT}/json/close/{s.t["id"]}', timeout=5).read()
        except Exception:
            pass


FPS = '''new Promise(r=>{const t=[];const t0=performance.now();const f=n=>{t.push(n);if(n-t0<10000)requestAnimationFrame(f);else{
const d=t.slice(1).map((x,i)=>x-t[i]).sort((a,b)=>a-b);r(`fps ${(1000*(d.length)/(t[t.length-1]-t[0])).toFixed(1)} · p95 ${d[Math.floor(d.length*.95)].toFixed(0)} ms · peor ${d[d.length-1].toFixed(0)} ms`)}};requestAnimationFrame(f)})'''
GL = ("(()=>{const o={};for(const v of ['webgl','webgl2']){const g=document.createElement('canvas').getContext(v);"
      "if(!g){o[v]='NO';continue}const e=g.getExtension('WEBGL_debug_renderer_info');"
      "o[v]=e?g.getParameter(e.UNMASKED_RENDERER_WEBGL):'sí'}return JSON.stringify(o)})()")
RECHAZA = ("(()=>{const b=[...document.querySelectorAll('button,input[type=submit]')].find(x=>/rechazar|reject/i"
           ".test(x.textContent||x.value||''));if(b){setTimeout(()=>b.click(),200);return 'consentimiento rechazado'}"
           "return 'sin aviso'})()")


def captura(p, nombre):
    png = p.call('Page.captureScreenshot', {'format': 'png'}, seg=30).get('data')
    if png:
        open(os.path.join(CAP, nombre + '.png'), 'wb').write(base64.b64decode(png))


def prueba(n, nombre, url, espera=15, antes=None, extra=None):
    p = Pest()
    try:
        p.call('Page.enable'); p.call('Runtime.enable')
        p.call('Page.navigate', {'url': url}); time.sleep(espera)
        if antes:
            # Sin esperar a la promesa: un consentimiento puede navegar y destruir el contexto.
            p.ev(antes, userGesture=True, timeout=20000); time.sleep(8)
        f = p.ev(FPS, awaitPromise=True, timeout=30000)
        x = p.ev(extra, awaitPromise=True, timeout=20000) if extra else ''
        captura(p, n)
        js = f' · errores JS: {len(p.err)} ' + '; '.join(e.splitlines()[0][:100] for e in p.err[:2]) if p.err else ''
        print(f'{n} {nombre}: {f}{" · " + str(x) if x else ""}{js}', flush=True)
    except Exception as e:
        print(f'{n} {nombre}: {"CAÍDA DEL RENDERER" if p.cayo else type(e).__name__ + " " + str(e)[:150]}', flush=True)
    p.cierra(); time.sleep(2)


YT_PON = ("new Promise(r=>{const m=document.getElementById('movie_player');if(!m)return r('sin reproductor');m.mute();"
          "m.setPlaybackQualityRange('hd2160','hd2160');m.playVideo();"
          "setTimeout(()=>r('calidades: '+m.getAvailableQualityLevels().join(',')),3000)})")
YT_MIDE = ("new Promise(r=>setTimeout(()=>{const m=document.getElementById('movie_player'),v=document.querySelector('video');"
           "const s=m.getStatsForNerds?m.getStatsForNerds():{};const q=v.getVideoPlaybackQuality();"
           "r(`${s.resolution||''} ${s.codecs||''} · ${v.videoWidth}x${v.videoHeight} · fotogramas ${q.totalVideoFrames}"
           " perdidos ${q.droppedVideoFrames}`)},20000))")


def youtube(n='9'):
    p = Pest(); url = 'https://www.youtube.com/watch?v=LXb3EKWsInQ'
    try:
        p.call('Page.enable'); p.call('Runtime.enable'); p.call('Page.navigate', {'url': url}); time.sleep(10)
        c = p.ev(RECHAZA, userGesture=True, timeout=20000); time.sleep(12)
        if 'watch' not in str(p.ev('location.href', timeout=20000)):
            p.call('Page.navigate', {'url': url}); time.sleep(10)
        a = p.ev(YT_PON, awaitPromise=True, userGesture=True, timeout=20000)
        m = p.ev(YT_MIDE, awaitPromise=True, timeout=60000)
        captura(p, n)
        print(f'{n} YouTube 4K60: {c} · {a} · {m}', flush=True)
    except Exception as e:
        print(f'{n} YouTube 4K60: {"CAÍDA DEL RENDERER" if p.cayo else type(e).__name__ + " " + str(e)[:150]}', flush=True)
    p.cierra(); time.sleep(2)


# La batería de FlyWeb/docs/pruebas-gpu.md (el 8, Fishbowl, ya no existe; el 11, MotionMark, va aparte).
GPU = [
    ('1a', 'Aquarium 5000', 'https://webglsamples.org/aquarium/aquarium.html?numFish=5000', 20, None, None),
    ('1b', 'Aquarium 10000', 'https://webglsamples.org/aquarium/aquarium.html?numFish=10000', 20, None, None),
    ('2', 'WebGL Report', 'https://webglreport.com/?v=2', 8, None, GL),
    ('3a', 'three unreal_bloom', 'https://threejs.org/examples/webgl_postprocessing_unreal_bloom.html', 15, None, None),
    ('3b', 'three animation_keyframes', 'https://threejs.org/examples/webgl_animation_keyframes.html', 15, None, None),
    ('3c', 'three shadowmap', 'https://threejs.org/examples/webgl_shadowmap.html', 15, None, None),
    ('4', 'Babylon Sponza', 'https://www.babylonjs.com/Demos/Sponza/', 40, None, None),
    ('5', 'Google Earth (Madrid 3D)', 'https://earth.google.com/web/@40.4153,-3.7074,650a,900d,35y,30h,65t,0r', 45,
     RECHAZA, None),
    ('6', 'Photopea (6000 px + desenfoque)', 'https://www.photopea.com#' + json.dumps(
        {'files': ['https://upload.wikimedia.org/wikipedia/commons/3/3f/Fronalpstock_big.jpg'],
         'script': 'app.activeDocument.activeLayer.applyGaussianBlur(8);'}), 45, None, None),
    ('7a', 'Shadertoy Seascape', 'https://www.shadertoy.com/view/Ms2SD1', 20, None, None),
    ('7b', 'Shadertoy Elevated', 'https://www.shadertoy.com/view/MdX3Rr', 20, None, None),
    ('9', None, None, 0, None, None),
    ('10', 'vsynctester', 'https://www.vsynctester.com/', 15, None, None),
    ('12', 'WebGPU', 'https://example.com/', 4, None,
     "navigator.gpu?navigator.gpu.requestAdapter().then(a=>a?'adaptador: '+(a.info&&a.info.vendor):'sin adaptador')"
     ":'navigator.gpu no existe'"),
]


def gpu(solo=None):
    for n, nombre, url, espera, antes, extra in GPU:
        if solo and n != solo:
            continue
        if n == '9':
            youtube(n)
        else:
            prueba(n, nombre, url, espera, antes, extra)


MOTOR_LEE = ("(()=>{const l=[...document.querySelectorAll('#res li')];const f=l.filter(x=>x.classList.contains('fallo'));"
             "return JSON.stringify({ua:(document.getElementById('ua')||{}).textContent||'',ok:l.length-f.length,"
             "fallo:f.length,fallos:f.map(x=>x.textContent.trim().slice(0,160))})})()")


def motor138():
    p = Pest()
    try:
        p.call('Page.enable'); p.call('Runtime.enable'); p.call('Page.navigate', {'url': MOTOR_URL}); time.sleep(8)
        r = json.loads(p.ev(MOTOR_LEE, timeout=20000) or '{}')
        captura(p, 'motor138')
        print(f"motor138: ok {r.get('ok')} · FALLO {r.get('fallo')} · {r.get('ua', '')[:120]}", flush=True)
        for x in r.get('fallos', []):
            print(f'  FALLO: {x}', flush=True)
    except Exception as e:
        print(f'motor138: {"CAÍDA DEL RENDERER" if p.cayo else type(e).__name__ + " " + str(e)[:150]}', flush=True)
    p.cierra()


def gpuinfo():
    p = Pest()
    try:
        p.call('Page.enable'); p.call('Runtime.enable'); p.call('Page.navigate', {'url': 'chrome://gpu'}); time.sleep(6)
        t = p.ev("(()=>{const r=document.querySelector('info-view');const s=r&&r.shadowRoot;"
                 "return (s?s.textContent:document.body.innerText).replace(/\\s+/g,' ').slice(0,4000)})()", timeout=20000)
        i = (t or '').find('Graphics Feature Status')
        print('gpuinfo: ' + (t[i:i + 900] if i >= 0 else (t or '')[:900]), flush=True)
    except Exception as e:
        print(f'gpuinfo: {type(e).__name__} {str(e)[:150]}', flush=True)
    p.cierra()


def cerrar():
    """Cierra el navegador entero (Browser.close por el WebSocket del navegador)."""
    try:
        v = json.load(urllib.request.urlopen(f'http://127.0.0.1:{PORT}/json/version', timeout=10))
        p = Pest.__new__(Pest); p.buf = b''; p.n = 0; p.cayo = False; p.err = []; p.t = {'id': ''}
        p.s = socket.create_connection(('127.0.0.1', PORT)); k = base64.b64encode(os.urandom(16)).decode()
        path = v['webSocketDebuggerUrl'].split(f':{PORT}', 1)[1]
        p.s.sendall((f'GET {path} HTTP/1.1\r\nHost: 127.0.0.1:{PORT}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n'
                     f'Sec-WebSocket-Key: {k}\r\nSec-WebSocket-Version: 13\r\n\r\n').encode())
        while b'\r\n\r\n' not in p.buf:
            p.buf += p.s.recv(4096)
        p.buf = p.buf.split(b'\r\n\r\n', 1)[1]
        p.call('Browser.close', seg=10)
    except Exception:
        pass


for t in PRUEBAS:
    if t == 'cerrar':
        cerrar()
    elif t == 'gpu':
        gpu()
    elif t == 'motor138':
        motor138()
    elif t == 'gpuinfo':
        gpuinfo()
    elif any(t == g[0] for g in GPU):
        gpu(t)
    else:
        print(f'{t}: prueba desconocida', flush=True)
