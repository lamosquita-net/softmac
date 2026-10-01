#!/usr/bin/env python3
"""Auditoría de red de FlyWeb a partir de un NetLog de Chromium.

Cómo capturar (en el Mac, perfil de prueba nuevo para no mezclar datos):
  APP=~/proyectos/flyweb-build/brave-browser/src/out/Static/FlyWeb.app/Contents/MacOS/FlyWeb
  "$APP" --user-data-dir=/tmp/flyweb-audit --log-net-log=/tmp/flyweb-netlog.json --net-log-capture-mode=Default
  (usar 30 min y cerrar FlyWeb con Cmd-Q para que el NetLog quede completo)

Modos:
  reposo  FlyWeb abierto sin navegar: todo host fuera de allowlist.txt es un FALLO.
  uso     navegación normal: falla un host de denylist.txt (y fuera de allowlist.txt) solo si lo pide
          el propio navegador. Cada petición (URL_REQUEST_START_JOB) se clasifica por su origen:
            pagina     la pide una web (initiator http(s), o network_isolation_key con un sitio web);
                       p. ej. Gmail llamando a accounts.google.com. No cuenta como fallo.
            extension  la pide una extensión (initiator chrome-extension://). No cuenta como fallo,
                       pero se muestra (para la auditoría con extensiones instaladas).
            navegador  sin origen web (initiator "not an origin" y clave de aislamiento vacía, o
                       página interna): servicios del propio navegador. Esta sí cuenta.
          Un host denegado que solo aparece en DNS o sockets, sin petición atribuible, se marca
          "revisar" (suele ser un preconnect de una web) pero no falla.
          Los patrones de denylist.txt que empiezan por "!" fallan siempre, venga de donde venga la
          petición: los servicios de Brave, porque algunos (traducción) se cargan desde la página.

Uso: network-audit.py <netlog.json> [--mode reposo|uso]
Sale con 1 si hay fallos; imprime el recuento por host.
"""
import argparse
import collections
import fnmatch
import json
import os
import sys
from urllib.parse import urlsplit

HERE = os.path.dirname(os.path.abspath(__file__))
AUDIT_DIR = os.path.join(os.path.dirname(HERE), 'audit')
IGNORED_SCHEMES = {'chrome', 'chrome-extension', 'brave', 'about', 'data',
                   'blob', 'file', 'devtools', 'chrome-untrusted'}


def load_patterns(name):
    with open(os.path.join(AUDIT_DIR, name), encoding='utf-8') as f:
        return [l.strip() for l in f if l.strip() and not l.startswith('#')]


def load_netlog(path):
    with open(path, encoding='utf-8') as f:
        text = f.read().rstrip()
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        # NetLog truncado (FlyWeb no se cerró limpiamente): cerrar la lista de eventos.
        return json.loads(text.rstrip(',') + ']}')


def hosts_in(netlog):
    counts = collections.Counter()
    for event in netlog.get('events', []):
        params = event.get('params') or {}
        url = params.get('url')
        if isinstance(url, str) and '://' in url:
            parts = urlsplit(url)
            if parts.scheme in IGNORED_SCHEMES or not parts.hostname:
                continue
            counts[parts.hostname.lower()] += 1
        host = params.get('host')
        if isinstance(host, str) and host and '/' not in host:
            counts[host.split(':')[0].lower()] += 1
    counts.pop('localhost', None)
    counts.pop('127.0.0.1', None)
    return counts


WEB_SCHEMES = ('http://', 'https://')


def classify(params):
    """Origen de una petición según los parámetros de URL_REQUEST_START_JOB (Chromium 116:
    net/url_request/url_request_netlog_params.cc)."""
    initiator = params.get('initiator') or ''
    if initiator.startswith('chrome-extension://'):
        return 'extension'
    if initiator.startswith(WEB_SCHEMES):
        return 'pagina'
    # Navegación escrita en la barra (initiator "not an origin") o petición de una página: el primer
    # campo de la clave de aislamiento es el sitio de la pestaña. Vacía ("null null") = navegador.
    nik = (params.get('network_isolation_key') or '').split(' ')[0]
    if nik.startswith(WEB_SCHEMES):
        return 'pagina'
    return 'navegador'


def requests_by_origin(netlog):
    """{host: Counter(origen)} con las peticiones URL_REQUEST_START_JOB del NetLog."""
    types = netlog.get('constants', {}).get('logEventTypes', {})
    start_job = types.get('URL_REQUEST_START_JOB')
    out = collections.defaultdict(collections.Counter)
    if start_job is None:
        return out
    for event in netlog.get('events', []):
        if event.get('type') != start_job:
            continue
        params = event.get('params') or {}
        url = params.get('url')
        if not isinstance(url, str) or '://' not in url:
            continue
        parts = urlsplit(url)
        if parts.scheme in IGNORED_SCHEMES or not parts.hostname:
            continue
        out[parts.hostname.lower()][classify(params)] += 1
    return out


def matches(host, patterns):
    return any(fnmatch.fnmatch(host, p) for p in patterns)


def main():
    parser = argparse.ArgumentParser(description='Auditoría de red de FlyWeb')
    parser.add_argument('netlog')
    parser.add_argument('--mode', choices=('reposo', 'uso'), default='reposo')
    args = parser.parse_args()

    allow = load_patterns('allowlist.txt')
    deny = load_patterns('denylist.txt')
    netlog = load_netlog(args.netlog)
    counts = hosts_in(netlog)
    origins = requests_by_origin(netlog)

    failures = []
    for host, n in sorted(counts.items(), key=lambda kv: -kv[1]):
        allowed = matches(host, allow)
        by_origin = origins.get(host, collections.Counter())
        detail = ''
        if args.mode == 'reposo':
            bad = not allowed
            mark = 'FALLO' if bad else 'ok'
        else:
            strict = [p[1:] for p in deny if p.startswith('!')]
            loose = [p for p in deny if not p.startswith('!')]
            denied = matches(host, strict + loose) and not allowed
            bad = denied and (matches(host, strict) or by_origin['navegador'] > 0)
            if bad:
                mark = 'FALLO'
            elif denied and not by_origin:
                mark = 'revisar'
            elif allowed:
                mark = 'ok'
            else:
                mark = '-'
            if by_origin:
                detail = '  (' + ', '.join(f'{k} {v}' for k, v in sorted(by_origin.items())) + ')'
        print(f'{mark:7} {n:6}  {host}{detail}')
        if bad:
            failures.append(host)

    print(f'\nModo {args.mode}: {len(counts)} hosts, {len(failures)} fallos.')
    if failures:
        print('Hosts no permitidos: ' + ', '.join(failures))
        sys.exit(1)


if __name__ == '__main__':
    main()
