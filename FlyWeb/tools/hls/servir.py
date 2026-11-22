#!/usr/bin/env python3
"""Servidor de pruebas HLS: dos orígenes en 127.0.0.1 (8471 = la página, 8472 = el «cruzado»).

/medios/...       sin cabeceras CORS
/cors/medios/...  con Access-Control-Allow-Origin: *
POST /resultado   guarda el JSON que manda prueba.html en resultados.jsonl (y lo imprime).
Uso: python3 servir.py [carpeta-de-medios]   (por defecto ./medios; la página se sirve desde esta carpeta)
"""
import http.server, json, os, sys, threading

AQUI = os.path.dirname(os.path.abspath(__file__))
MEDIOS = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else "medios")
TIPOS = {".m3u8": "application/vnd.apple.mpegurl", ".ts": "video/mp2t", ".m4s": "video/mp4",
         ".mp4": "video/mp4", ".html": "text/html; charset=utf-8"}
BLOQUEO = threading.Lock()


class Manejador(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        sys.stderr.write("[%d] %s %s\n" % (self.server.server_port, self.command, self.path))

    def _fichero(self):
        ruta = self.path.split("?", 1)[0]
        cors = ruta.startswith("/cors/")
        if cors:
            ruta = ruta[len("/cors"):]
        if ruta.startswith("/medios/"):
            base, rel = MEDIOS, ruta[len("/medios/"):]
        else:
            base, rel = AQUI, ruta.lstrip("/")
        real = os.path.realpath(os.path.join(base, rel))
        if not real.startswith(base + os.sep) or not os.path.isfile(real):
            return None, cors
        return real, cors

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Range")
        self.end_headers()

    def do_GET(self):
        real, cors = self._fichero()
        if not real:
            self.send_error(404)
            return
        ext = os.path.splitext(real)[1]
        tipo = TIPOS.get(ext, "application/vnd.apple.mpegurl" if "sin-extension" in real else "application/octet-stream")
        datos = open(real, "rb").read()
        inicio, fin, estado = 0, len(datos) - 1, 200
        rango = self.headers.get("Range", "")
        if rango.startswith("bytes="):
            a, _, b = rango[6:].split(",")[0].partition("-")
            if a:
                inicio, fin = int(a), (int(b) if b else len(datos) - 1)
            elif b:
                inicio = max(0, len(datos) - int(b))
            fin = min(fin, len(datos) - 1)
            estado = 206
        self.send_response(estado)
        self.send_header("Content-Type", tipo)
        self.send_header("Accept-Ranges", "bytes")
        self.send_header("Content-Length", str(fin - inicio + 1))
        if estado == 206:
            self.send_header("Content-Range", "bytes %d-%d/%d" % (inicio, fin, len(datos)))
        if cors:
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Expose-Headers", "Content-Range, Content-Length")
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(datos[inicio:fin + 1])

    def do_POST(self):
        if self.path != "/resultado":
            self.send_error(404)
            return
        cuerpo = self.rfile.read(int(self.headers.get("Content-Length", "0")))
        linea = json.dumps(json.loads(cuerpo), ensure_ascii=False)
        with BLOQUEO, open(os.path.join(os.getcwd(), "resultados.jsonl"), "a") as f:
            f.write(linea + "\n")
        print(linea, flush=True)
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()


if __name__ == "__main__":
    for puerto in (8472, 8471):
        s = http.server.ThreadingHTTPServer(("127.0.0.1", puerto), Manejador)
        threading.Thread(target=s.serve_forever, daemon=True).start()
    print("Sirviendo %s en 127.0.0.1:8471 y :8472" % MEDIOS, flush=True)
    threading.Event().wait()
