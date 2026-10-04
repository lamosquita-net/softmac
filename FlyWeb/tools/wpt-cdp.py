# Ejecuta tests testharness de WPT en una FlyWeb abierta con --remote-debugging-port y resume PASS/FAIL por test.
# Uso: python3 wpt-cdp.py <puerto> <url base> <lista de rutas> [salida.json]
# Engancha add_completion_callback con un script inyectado antes de que cargue cada página.
import json, os, socket, base64, struct, sys, time, urllib.request
port, base, lista = sys.argv[1], sys.argv[2].rstrip('/'), [l.strip() for l in open(sys.argv[3]) if l.strip().endswith('.html')]
tab = next(t for t in json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list')) if t['type'] == 'page')
s = socket.create_connection(('127.0.0.1', int(port)))
key = base64.b64encode(os.urandom(16)).decode()
s.sendall(f"GET {tab['webSocketDebuggerUrl'].split(f':{port}',1)[1]} HTTP/1.1\r\nHost: 127.0.0.1:{port}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n".encode())
buf = b''
while b'\r\n\r\n' not in buf: buf += s.recv(4096)
buf = buf.split(b'\r\n\r\n', 1)[1]
def rd(n):
    global buf
    while len(buf) < n: buf += s.recv(65536)
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
GANCHO = r'''(function(){var t=setInterval(function(){if(window.add_completion_callback){clearInterval(t);
add_completion_callback(function(tests,st){window.__wpt=JSON.stringify({st:st.status,msg:st.message,tests:tests.map(function(x){return [x.name,x.status,x.message]})});});}},5);})();'''
call('Page.enable', {}); call('Page.addScriptToEvaluateOnNewDocument', {'source': GANCHO})
NOM = {0: 'PASS', 1: 'FAIL', 2: 'TIMEOUT', 3: 'NOTRUN', 4: 'PRECONDITION_FAILED'}
res = {}
for p in lista:
    call('Page.navigate', {'url': f'{base}/{p}'}); fin = time.time() + 25; r = None
    while time.time() < fin:
        time.sleep(0.5)
        v = call('Runtime.evaluate', {'expression': 'window.__wpt||""'}).get('result', {}).get('result', {}).get('value')
        if v: r = json.loads(v); break
    if not r: res[p] = {'harness': 'SIN RESULTADO', 'tests': []}
    else: res[p] = {'harness': 'OK' if r['st'] == 0 else f"ERROR {r['msg']}", 'tests': [[n, NOM.get(st, st), m] for n, st, m in r['tests']]}
    t = res[p]['tests']; ok = sum(1 for x in t if x[1] == 'PASS')
    print(f"{ok:4d}/{len(t):<4d} {res[p]['harness'][:30]:30s} {p}", flush=True)
if len(sys.argv) > 4: json.dump(res, open(sys.argv[4], 'w'), indent=1, ensure_ascii=False)
