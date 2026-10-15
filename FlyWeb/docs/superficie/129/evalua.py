# Uso: python3 -I evalua.py <puerto> <url> <expresión>...   Evalúa cada expresión en la página (CDP).
# elemento de cada selector (por defecto «rt» y «ruby»), y de sus nodos de texto. Sin emulación de pantalla.
import base64, json, os, socket, struct, sys, time, urllib.request
port, url = sys.argv[1], sys.argv[2]
exprs = sys.argv[3:]
tab = next(t for t in json.load(urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list')) if t['type'] == 'page')
s = socket.create_connection(('127.0.0.1', int(port))); key = base64.b64encode(os.urandom(16)).decode()
s.sendall(f"GET {tab['webSocketDebuggerUrl'].split(f':{port}',1)[1]} HTTP/1.1\r\nHost: 127.0.0.1:{port}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n".encode())
buf = b''
while b'\r\n\r\n' not in buf: buf += s.recv(4096)
buf = buf.split(b'\r\n\r\n', 1)[1]
def rd(n):
    global buf
    while len(buf) < n: buf += s.recv(1 << 20)
    d, buf = buf[:n], buf[n:]; return d
cnt = [0]
def call(m, p={}):
    cnt[0] += 1; i = cnt[0]; b = json.dumps({'id': i, 'method': m, 'params': p}).encode()
    if len(b) < 126: h = bytes([0x81, 0x80 | len(b)])
    else: h = bytes([0x81, 0x80 | 126]) + struct.pack('>H', len(b))
    mk = os.urandom(4); s.sendall(h + mk + bytes(x ^ mk[j % 4] for j, x in enumerate(b)))
    while True:
        b1, b2 = rd(2); n = b2 & 0x7f
        if n == 126: n = struct.unpack('>H', rd(2))[0]
        elif n == 127: n = struct.unpack('>Q', rd(8))[0]
        r = json.loads(rd(n))
        if r.get('id') == i: return r
call('Page.enable'); call('Page.navigate', {'url': url}); time.sleep(4)
call('DOM.enable'); call('CSS.enable')
ua = call('Runtime.evaluate', {'expression': 'navigator.userAgent.match(/Chrome\\/[\\d.]+/)[0]', 'returnByValue': True})['result']['result']['value']
print('UA', ua)
for e in exprs:
    r = call('Runtime.evaluate', {'expression': e, 'returnByValue': True, 'awaitPromise': True})['result']
    v = r.get('result', {}).get('value', r.get('result', {}).get('description')) if 'exceptionDetails' not in r else 'EXCEPCIÓN: ' + r['exceptionDetails'].get('exception', {}).get('description', '?').split('\n')[0]
    print(f'{e}  =>  {v!r}')
