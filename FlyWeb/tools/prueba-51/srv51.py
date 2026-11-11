# -*- coding: utf-8 -*-
# Servidor de la prueba de la 5,1 (Python 2.7 de Mojave o 3). MIT, como la raíz del repo.
# Uso: srv51.py PUERTO DIR_BENCH DIR_GUION SALIDA_PREFIJO
#  - sirve DIR_BENCH (speedometer3.1/, jetstream3/) en 127.0.0.1, con tipo MIME para .wasm/.mjs;
#  - sirve /fw51.html desde DIR_GUION (la página que lanza los benchmarks en un iframe del mismo origen);
#  - POST /resultado?caso=X&t=T guarda el JSON recibido en SALIDA_PREFIJO-X.json (la página lo manda tras cada pasada).
#  - Vigencia: cada apertura de FlyWeb lleva t = segundos de reloj. POST /hola?t=T apunta el t más nuevo; GET /vigente?t=T
#    responde 200 solo al más nuevo y 410 a los demás, y /resultado rechaza (410) los t viejos. Así una pestaña de un caso
#    anterior que FlyWeb restaure al abrirse ni mide a la vez ni pisa el resultado.
import sys, os, json
try:
    from http.server import SimpleHTTPRequestHandler as H, HTTPServer as S
    from socketserver import ThreadingMixIn as T
    from urllib.parse import urlparse, parse_qs
except ImportError:
    from SimpleHTTPServer import SimpleHTTPRequestHandler as H
    from BaseHTTPServer import HTTPServer as S
    from SocketServer import ThreadingMixIn as T
    from urlparse import urlparse, parse_qs
ULTIMO = [0]
PUERTO, BENCH, GUION, SALIDA = int(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
H.extensions_map.update({'.wasm': 'application/wasm', '.mjs': 'text/javascript', '.js': 'text/javascript',
                         '.json': 'application/json'})


class Manejador(H):
    def log_message(self, *a):
        pass

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store')
        H.end_headers(self)

    def t(self):
        try:
            return int((parse_qs(urlparse(self.path).query).get('t') or ['0'])[0])
        except ValueError:
            return 0

    def do_GET(self):
        if urlparse(self.path).path == '/vigente':
            self.send_response(200 if self.t() == ULTIMO[0] else 410)
            self.end_headers()
            return
        if urlparse(self.path).path == '/fw51.html':
            with open(os.path.join(GUION, 'fw51.html'), 'rb') as f:
                d = f.read()
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Content-Length', str(len(d)))
            self.end_headers()
            self.wfile.write(d)
            return
        H.do_GET(self)

    def do_POST(self):
        u = urlparse(self.path)
        caso = (parse_qs(u.query).get('caso') or ['x'])[0]
        caso = ''.join(c for c in caso if c.isalnum() or c in '-_') or 'x'
        n = int(self.headers.get('Content-Length') or 0)
        cuerpo = self.rfile.read(n)
        if u.path == '/hola':
            ULTIMO[0] = max(ULTIMO[0], self.t())
            self.send_response(204)
        elif u.path == '/resultado' and self.t() < ULTIMO[0]:
            self.send_response(410)
        elif u.path == '/resultado':
            try:
                json.loads(cuerpo.decode('utf-8'))
                with open('%s-%s.json' % (SALIDA, caso), 'wb') as f:
                    f.write(cuerpo)
                self.send_response(204)
            except Exception:
                self.send_response(400)
        else:
            self.send_response(404)
        self.end_headers()


class Servidor(T, S):
    daemon_threads = True


os.chdir(BENCH)
Servidor(('127.0.0.1', PUERTO), Manejador).serve_forever()
