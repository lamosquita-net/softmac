# Ejecuta WPT de tipo reftest (y testharness) en una FlyWeb abierta con --remote-debugging-port, y compara con Chrome.
# Uso: python3 wpt-ref.py [--pasadas=N] <puerto> <url base> <lista> [salida.json] [esperado.json]
# - El navegador se lanza con --force-device-scale-factor=1 (y, si se puede, --window-size=800,600): el script no emula
#   nada; ajusta la ventana para que el viewport real sea 800×600 y para si devicePixelRatio no es 1.
# - Lista: una ruta por línea (relativa a la raíz de WPT); «#» = comentario.
# - Reftest: captura la prueba y sus referencias a 800×600 con escala 1 (como wptrunner), tras `load`, las fuentes y la
#   retirada de `reftest-wait`, cada página en una pestaña nueva. Pasa si coincide con alguna referencia `match` (o
#   difiere de la `mismatch`), con el margen de `<meta name=fuzzy>`, en las N pasadas (3 por defecto); si las pasadas no
#   coinciden, sale INESTABLE con el detalle de cada una. No sigue cadenas de referencias.
#   Trampa (MOTOR-8 y LOCAL-3, 14-10, nivel 129): con Emulation.setDeviceMetricsOverride y una sola pestaña, la 116 daba
#   a veces el cuadrado media fila desplazado en la captura: 200 px falsos en 4 reftests de container-type que Chrome 129
#   pasa. Sin emulación, con una pestaña por página, 0 px en 25/25. No volver a emular la captura.
# - Testharness: el mismo gancho que wpt-cdp.py; pasa si el arnés termina bien y pasan todos los subtests.
# - Sin referencia ni testharness (pruebas de caída): pasa si la página carga y el renderer sigue respondiendo.
# - esperado.json: {ruta: "Failure"} para lo que Chrome falla entero (TestExpectations) y {ruta: [subtests]} para los
#   subtests que falla (sus -expected.txt). Con él, al final dice qué difiere de Chrome.
import base64, json, os, re, socket, struct, sys, time, urllib.parse, urllib.request, zlib

PASADAS = 3
for a in [a for a in sys.argv[1:] if a.startswith('--pasadas=')]:
    PASADAS = max(1, int(a.split('=', 1)[1])); sys.argv.remove(a)
port, base, lista = sys.argv[1], sys.argv[2].rstrip('/'), [l.split('#')[0].strip() for l in open(sys.argv[3])]
lista = [l for l in lista if l]
def conectar(t):  # WebSocket de CDP de la pestaña t, con tiempo máximo por lectura (página colgada → excepción)
    global s, buf, tab
    tab = t; s = socket.create_connection(('127.0.0.1', int(port))); s.settimeout(45)
    key = base64.b64encode(os.urandom(16)).decode()
    s.sendall(f"GET {tab['webSocketDebuggerUrl'].split(f':{port}',1)[1]} HTTP/1.1\r\nHost: 127.0.0.1:{port}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n".encode())
    buf = b''
    while b'\r\n\r\n' not in buf: buf += s.recv(4096)
    buf = buf.split(b'\r\n\r\n', 1)[1]
def abrir():  # pestaña nueva (PUT desde Chrome 111; GET en las anteriores)
    for m in ('PUT', 'GET'):
        try: return json.load(urllib.request.urlopen(urllib.request.Request(f'http://127.0.0.1:{port}/json/new?about:blank', method=m), timeout=10))
        except Exception: pass
    raise SystemExit('no se puede abrir una pestaña por /json/new')
conectar(abrir())
def rd(n):
    global buf
    while len(buf) < n: buf += s.recv(1 << 20)
    d, buf = buf[:n], buf[n:]; return d
cnt = [0]
def call(method, params):
    cnt[0] += 1; i = cnt[0]
    m = json.dumps({'id': i, 'method': method, 'params': params}).encode()
    h = bytes([0x81]) + (bytes([0x80 | len(m)]) if len(m) < 126 else bytes([0x80 | 126]) + struct.pack('>H', len(m)) if len(m) < 65536 else bytes([0x80 | 127]) + struct.pack('>Q', len(m)))
    mk = os.urandom(4); s.sendall(h + mk + bytes(b ^ mk[j % 4] for j, b in enumerate(m)))
    while True:
        b1, b2 = rd(2); n = b2 & 0x7f
        if n == 126: n = struct.unpack('>H', rd(2))[0]
        elif n == 127: n = struct.unpack('>Q', rd(8))[0]
        r = json.loads(rd(n))
        if r.get('id') == i: return r
def ev(expr, wait=False):
    r = call('Runtime.evaluate', {'expression': expr, 'awaitPromise': wait, 'returnByValue': True})
    return r.get('result', {}).get('result', {}).get('value')

# Gancho: un «setter» en window registra el callback en una microtarea al acabar de cargar testharness.js (expone
# add_completion_callback antes de crear `tests`, así que no se puede llamar en el acto). Antes se
# buscaba cada 5 ms y, si el arnés terminaba antes, se perdía el resultado («SIN RESULTADO» intermitente; LOCAL-3, 13-10).
GANCHO = r'''(function(){var cb=function(tests,st){window.__wpt=JSON.stringify({st:st.status,msg:st.message,tests:tests.map(function(x){return [x.name,x.status,x.message]})});};
var f;try{Object.defineProperty(window,'add_completion_callback',{configurable:true,enumerable:true,get:function(){return f;},
set:function(v){f=v;queueMicrotask(function(){try{v(cb);}catch(e){}});}});}catch(e){var t=setInterval(function(){if(window.add_completion_callback){clearInterval(t);
window.add_completion_callback(cb);}},5);}})();'''
def viewport():
    return ev('[innerWidth, innerHeight, devicePixelRatio]')
def preparar():  # sin Emulation: el viewport real se lleva a 800×600 moviendo el tamaño de la ventana
    call('Page.enable', {}); call('Page.addScriptToEvaluateOnNewDocument', {'source': GANCHO})
    for _ in range(3):
        w, h, dpr = viewport()
        if dpr != 1: raise SystemExit(f'devicePixelRatio {dpr}: lanzar el navegador con --force-device-scale-factor=1')
        if (w, h) == (800, 600): return
        v = call('Browser.getWindowForTarget', {}).get('result')
        if not v: break
        b = v['bounds']
        call('Browser.setWindowBounds', {'windowId': v['windowId'], 'bounds': {'windowState': 'normal'}})
        call('Browser.setWindowBounds', {'windowId': v['windowId'], 'bounds': {
            'width': b['width'] + 800 - w, 'height': b['height'] + 600 - h}})
        time.sleep(0.3)
    w, h, _ = viewport()
    if (w, h) != (800, 600): raise SystemExit(f'viewport {w}×{h}, no 800×600: lanzar con --window-size=800,600 (o mayor)')
def pestana_nueva():  # abre otra pestaña y cierra la anterior (en este orden: así la ventana no se cierra)
    viejo, viejo_s = tab, s
    conectar(abrir())
    try: urllib.request.urlopen(f'http://127.0.0.1:{port}/json/close/{viejo["id"]}', timeout=10).read()
    except Exception: pass
    try: viejo_s.close()
    except Exception: pass
    preparar()
preparar()
NOM = {0: 'PASS', 1: 'FAIL', 2: 'TIMEOUT', 3: 'NOTRUN', 4: 'PRECONDITION_FAILED'}
LISTO = '''new Promise(r=>{const t0=Date.now();(function f(){const d=document;
 if((d.readyState==='complete'&&!d.documentElement.classList.contains('reftest-wait'))||Date.now()-t0>10000)
  d.fonts.ready.then(()=>requestAnimationFrame(()=>requestAnimationFrame(()=>r(d.readyState))));
 else setTimeout(f,50);})();})'''

def png(b):  # PNG de 8 bits sin entrelazar (lo que da Chrome) → (ancho, alto, canales, bytes)
    assert b[:8] == b'\x89PNG\r\n\x1a\n'; i, idat = 8, b''
    while i < len(b):
        n, t = struct.unpack('>I4s', b[i:i + 8]); d = b[i + 8:i + 8 + n]; i += 12 + n
        if t == b'IHDR': w, h, bits, ct, _, _, il = struct.unpack('>IIBBBBB', d)
        elif t == b'IDAT': idat += d
    assert bits == 8 and il == 0 and ct in (2, 6), (bits, ct, il)
    c = 4 if ct == 6 else 3; raw = zlib.decompress(idat); st = w * c; out = bytearray(h * st); prev = bytearray(st)
    for y in range(h):
        f = raw[y * (st + 1)]; row = bytearray(raw[y * (st + 1) + 1:(y + 1) * (st + 1)])
        if f == 1:
            for x in range(c, st): row[x] = (row[x] + row[x - c]) & 255
        elif f == 2:
            for x in range(st): row[x] = (row[x] + prev[x]) & 255
        elif f == 3:
            for x in range(st): row[x] = (row[x] + ((row[x - c] if x >= c else 0) + prev[x]) // 2) & 255
        elif f == 4:
            for x in range(st):
                a = row[x - c] if x >= c else 0; bb = prev[x]; cc = prev[x - c] if x >= c else 0
                p = a + bb - cc; pa, pb, pc = abs(p - a), abs(p - bb), abs(p - cc)
                row[x] = (row[x] + (a if pa <= pb and pa <= pc else bb if pb <= pc else cc)) & 255
        out[y * st:(y + 1) * st] = row; prev = row
    return w, h, c, bytes(out)

def diff(a, b):  # (máxima diferencia por canal, píxeles distintos)
    if a == b: return 0, 0
    wa, ha, ca, pa = png(a); wb, hb, cb, pb = png(b)
    if (wa, ha) != (wb, hb): return 255, wa * ha
    mx = n = 0
    for k in range(wa * ha):
        d = max(abs(pa[k * ca + j] - pb[k * cb + j]) for j in range(3))
        if d: n += 1; mx = max(mx, d)
    return mx, n

def captura(url):  # cada captura en una pestaña nueva (ver la trampa del principio)
    pestana_nueva()
    call('Page.navigate', {'url': url}); fin = time.time() + 5
    while ev('location.href') != url and time.time() < fin: time.sleep(0.05)
    ev(LISTO, True)
    return base64.b64decode(call('Page.captureScreenshot', {'format': 'png', 'clip': {'x': 0, 'y': 0, 'width': 800, 'height': 600, 'scale': 1}})['result']['data'])

def rango(v):
    a, _, b = v.strip().partition('-'); return int(a), int(b or a)
def fuzzy(src, ref):  # <meta name=fuzzy content="[ref:]maxDifference=a-b;totalPixels=c-d"> (también «a-b;c-d»)
    for m in re.finditer(r'<meta[^>]*name=["\']?fuzzy["\']?[^>]*>', src, re.I):
        c = re.search(r'content=["\']([^"\']*)', m.group(0)).group(1)
        r, _, resto = c.partition(':')
        if resto and '=' not in r and not re.fullmatch(r'[\d\s-]*', r):
            if urllib.parse.urljoin(base + '/', r.strip()) != ref and not ref.endswith('/' + r.strip()): continue
            c = resto
        val = {'maxDifference': (0, 0), 'totalPixels': (0, 0)}
        for k, x in enumerate(y for y in c.split(';') if y.strip()):
            n, _, v = x.rpartition('='); val[n.strip() or ('maxDifference', 'totalPixels')[k]] = rango(v)
        return val['maxDifference'], val['totalPixels']
    return (0, 0), (0, 0)

res = {}
def una(p):
    url = f'{base}/{p}'
    try: src = urllib.request.urlopen(url).read().decode('utf-8', 'replace')
    except Exception as e: res[p] = {'tipo': '?', 'estado': f'NO CARGA {e}'}; print(f'{"NO CARGA":9s} {p}', flush=True); return
    refs = [(m.group(1).lower(), urllib.parse.urljoin(url, re.search(r'href=["\']?([^"\'\s>]+)', m.group(0)).group(1)))
            for m in re.finditer(r'<link[^>]*rel=["\']?(match|mismatch)\b[^>]*>', src, re.I)]
    if 'testharness.js' in src:
        call('Page.navigate', {'url': url}); fin = time.time() + 25; r = None
        while time.time() < fin:
            time.sleep(0.5); v = ev('window.__wpt||""')
            if v: r = json.loads(v); break
        t = [[n, NOM.get(st, st), m] for n, st, m in r['tests']] if r else []
        ok = sum(1 for x in t if x[1] == 'PASS'); harn = 'SIN RESULTADO' if not r else 'OK' if r['st'] == 0 else f"ERROR {r['msg']}"
        res[p] = {'tipo': 'testharness', 'estado': 'PASS' if harn == 'OK' and ok == len(t) else 'FAIL', 'arnes': harn, 'tests': t}
        print(f'{res[p]["estado"]:9s} {ok}/{len(t)} {harn[:30]} {p}', flush=True)
    elif refs:
        estados, det = [], []
        for k in range(PASADAS):
            a = captura(url); e = 'FAIL'; d = []
            for rel, ref in refs:
                (d0, d1), (n0, n1) = fuzzy(src, ref); mx, n = diff(a, captura(ref))
                igual = mx == 0 or (d0 <= mx <= d1 and n0 <= n <= n1)
                d.append(f'{rel} {os.path.basename(ref)}: max {mx}, {n} px')
                if igual == (rel == 'match'): e = 'PASS'; break
            estados.append(e); det.append(f'pasada {k + 1}: ' + '; '.join(d))
        estado = estados[0] if len(set(estados)) == 1 else 'INESTABLE'
        res[p] = {'tipo': 'reftest', 'estado': estado, 'detalle': det}
        print(f'{estado:9s} {det[0][:80] if estado != "INESTABLE" else " / ".join(estados)} {p}', flush=True)
    else:  # prueba de caída (crashtest): pasa si la página carga y el renderer sigue respondiendo
        call('Page.navigate', {'url': url}); fin = time.time() + 5
        while ev('location.href') != url and time.time() < fin: time.sleep(0.05)
        ev(LISTO, True); time.sleep(0.5)
        estado = 'PASS' if ev('1+1') == 2 else 'CAÍDA'
        res[p] = {'tipo': 'caída', 'estado': estado}; print(f'{estado:9s} (prueba de caída) {p}', flush=True)
        if estado != 'PASS': pestana_nueva()

for p in lista:
    try: una(p)
    except (socket.timeout, OSError, ValueError, KeyError, TypeError) as e:  # caída o cuelgue a mitad de una llamada
        res[p] = {'tipo': '?', 'estado': 'COLGADO', 'detalle': [str(e)[:80]]}
        print(f'{"COLGADO":9s} {p}', flush=True); pestana_nueva()

if len(sys.argv) > 4 and sys.argv[4] != '-': json.dump(res, open(sys.argv[4], 'w'), indent=1, ensure_ascii=False)
if len(sys.argv) > 5:
    esp = json.load(open(sys.argv[5])); igual = mejor = 0; peor = []
    for p, r in res.items():
        e = esp.get(p)
        if r['tipo'] == 'testharness' and r['estado'] == 'FAIL' and r['arnes'] == 'OK':
            fallos = sorted(n for n, st, _ in r['tests'] if st != 'PASS')
            chrome = sorted(e) if isinstance(e, list) else None if e is None else fallos
            if fallos == chrome: igual += 1
            else: peor.append(f'{p}: falla {fallos}; Chrome falla {chrome}')
        elif r['estado'] == 'PASS': igual += e is None; mejor += e is not None
        elif e is not None: igual += 1
        else: peor.append(f'{p}: {r["estado"]} {r.get("detalle", r.get("arnes", ""))}')
    print(f'\nIgual que Chrome: {igual}; pasa y Chrome falla: {mejor}; DIFERENCIAS con Chrome: {len(peor)}')
    for x in peor: print('  ' + x)
