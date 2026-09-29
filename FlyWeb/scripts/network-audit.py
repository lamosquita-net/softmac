#!/usr/bin/env python3
"""Auditoría de red de FlyWeb a partir de un NetLog de Chromium.

Cómo capturar (en el Mac, perfil de prueba nuevo para no mezclar datos):
  APP=~/proyectos/flyweb-build/brave-browser/src/out/Static/FlyWeb.app/Contents/MacOS/FlyWeb
  "$APP" --user-data-dir=/tmp/flyweb-audit --log-net-log=/tmp/flyweb-netlog.json --net-log-capture-mode=Default
  (usar 30 min y cerrar FlyWeb con Cmd-Q para que el NetLog quede completo)

Modos:
  reposo  FlyWeb abierto sin navegar: todo host fuera de allowlist.txt es un FALLO.
  uso     navegación normal: solo falla un host de denylist.txt que no esté en allowlist.txt.

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


def matches(host, patterns):
    return any(fnmatch.fnmatch(host, p) for p in patterns)


def main():
    parser = argparse.ArgumentParser(description='Auditoría de red de FlyWeb')
    parser.add_argument('netlog')
    parser.add_argument('--mode', choices=('reposo', 'uso'), default='reposo')
    args = parser.parse_args()

    allow = load_patterns('allowlist.txt')
    deny = load_patterns('denylist.txt')
    counts = hosts_in(load_netlog(args.netlog))

    failures = []
    for host, n in sorted(counts.items(), key=lambda kv: -kv[1]):
        allowed = matches(host, allow)
        if args.mode == 'reposo':
            bad = not allowed
        else:
            bad = matches(host, deny) and not allowed
        mark = 'FALLO' if bad else ('ok' if allowed else '-')
        print(f'{mark:6} {n:6}  {host}')
        if bad:
            failures.append(host)

    print(f'\nModo {args.mode}: {len(counts)} hosts, {len(failures)} fallos.')
    if failures:
        print('Hosts no permitidos: ' + ', '.join(failures))
        sys.exit(1)


if __name__ == '__main__':
    main()
