#!/usr/bin/env python3
"""Pone ?v=<10 primeros del SHA-256> en las direcciones de estilo.css, img/*.svg y js/*.js de todas las páginas, para que
ningún navegador mezcle una página nueva con un CSS o un JS viejos de su caché. Ejecutarlo SIEMPRE que cambie uno de
esos ficheros (y en el mismo PR). Sin argumentos: reescribe; con --comprobar: falla si alguna página está desfasada."""
import hashlib, pathlib, re, sys
RAIZ = pathlib.Path(__file__).resolve().parent
PAGINAS = ['index.html', 'privacidad.html', 'cifras.html', 'ayuda/index.html', 'ayuda/sincronizar/index.html']
RECURSO = re.compile(r'((?:\.\./)*)((?:estilo\.css)|(?:img/[\w.-]+\.svg)|(?:js/[\w.-]+\.js))(\?v=[0-9a-f]+)?(")')
def huella(rel):
    f = RAIZ / rel
    return hashlib.sha256(f.read_bytes()).hexdigest()[:10] if f.exists() else None
mal = []
for p in PAGINAS:
    f = RAIZ / p
    s = f.read_text()
    def poner(m):
        h = huella(m.group(2))  # lo que no está en el repo (p. ej. img/flyweb.svg) se deja como está
        return m.group(0) if h is None else f'{m.group(1)}{m.group(2)}?v={h}{m.group(4)}'
    n = RECURSO.sub(poner, s)
    if n != s:
        mal.append(p)
        if '--comprobar' not in sys.argv:
            f.write_text(n)
if '--comprobar' in sys.argv and mal:
    sys.exit('Desfasadas (ejecuta FlyWeb/web/versionar.py): ' + ', '.join(mal))
print('al día' if not mal else 'reescritas: ' + ', '.join(mal))
