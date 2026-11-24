# -*- coding: utf-8 -*-
# LOCAL-23 · muestreador de la 6,1 (Python 2.7 de Mojave). Solo lee.
# Uso: muestreo61.py PERFIL SALIDA. Una línea JSON por segundo hasta que reciba SIGTERM:
#   t      hora de la 6,1 (la misma que Date.now() de la página)
#   gpu    {registryID: Device Utilization %}
#   vram   {registryID: [inUseVidMemoryBytes, vramFreeBytes]} (LOCAL-25, 24-11)
#   hilos  {pid: {tipo, h: [[%CPU, estado, PRI, sistema s, usuario s], ...]}}; el primer hilo es el principal
#   front  aplicación en primer plano; ajenas: otras FlyWeb o Chromium abiertas
import json, re, subprocess, sys, time

UD, SALIDA = sys.argv[1], sys.argv[2]
RE_GPU = re.compile(r'id (0x[0-9a-f]+)')
RE_USO = re.compile(r'"Device Utilization %"=(\d+)')
RE_VUSO = re.compile(r'"inUseVidMemoryBytes"=(\d+)')
RE_VLIB = re.compile(r'"vramFreeBytes"=(\d+)')
VRAM = {}
RE_HILO = re.compile(r'(\d+\.\d)\s+(\S+)\s+(\d+)[A-Z]?\s+(\d+):(\d\d\.\d\d)\s+(\d+):(\d\d\.\d\d)')


def orden(*args):
    try:
        return subprocess.check_output(args, stderr=subprocess.STDOUT).decode('utf-8', 'replace')
    except subprocess.CalledProcessError as e:
        return e.output.decode('utf-8', 'replace')


def gpus():
    uso, gid = {}, None
    for linea in orden('ioreg', '-r', '-d', '1', '-w', '0', '-c', 'IOAccelerator').splitlines():
        if linea.startswith('+-o'):
            m = RE_GPU.search(linea)
            gid = m.group(1) if m else None
        elif '"PerformanceStatistics" =' in linea and gid:
            m = RE_USO.search(linea)
            if m:
                uso[gid] = int(m.group(1))
            a, b = RE_VUSO.search(linea), RE_VLIB.search(linea)
            if a or b:
                VRAM[gid] = [int(a.group(1)) if a else None, int(b.group(1)) if b else None]
    return uso


def procesos():
    propios, ajenas = {}, []
    for linea in orden('ps', '-Aww', '-o', 'pid=,command=').splitlines():
        partes = linea.strip().split(None, 1)
        if len(partes) < 2:
            continue
        pid, cmd = partes
        if not cmd.startswith('/') or '.app/Contents/' not in cmd:
            continue
        if 'user-data-dir=' + UD in cmd:
            m = re.search(r'--type=([\w-]+)', cmd)
            propios[pid] = m.group(1) if m else 'navegador'
        elif re.search(r'/(FlyWeb|Chromium)\.app/Contents/MacOS/', cmd):
            ajenas.append(pid)
    return propios, ajenas


def hilos(pid):
    filas = []
    for linea in orden('ps', '-M', '-p', pid).splitlines()[1:]:
        m = RE_HILO.search(linea)
        if m:
            g = m.groups()
            filas.append([float(g[0]), g[1], int(g[2]), int(g[3]) * 60 + float(g[4]), int(g[5]) * 60 + float(g[6])])
    return filas


def delante():
    asn = orden('lsappinfo', 'front').strip()
    return orden('lsappinfo', 'info', '-only', 'name', asn).strip() if asn else ''


with open(SALIDA, 'a') as salida:
    while True:
        ini = time.time()
        propios, ajenas = procesos()
        reg = {'t': ini, 'gpu': gpus(), 'ajenas': ajenas, 'front': delante(), 'hilos': {}, 'vram': dict(VRAM)}
        for pid, tipo in propios.items():
            if tipo in ('gpu-process', 'renderer', 'navegador'):
                reg['hilos'][pid] = {'tipo': tipo, 't': time.time(), 'h': hilos(pid)}
        salida.write(json.dumps(reg) + '\n')
        salida.flush()
        time.sleep(max(0.05, 1.0 - (time.time() - ini)))
