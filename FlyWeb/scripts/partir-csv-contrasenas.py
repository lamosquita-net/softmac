#!/usr/bin/env python3
# Parte el CSV de contraseñas exportado por Apple (app Contraseñas o Safari) en trozos que acepte el importador de
# FlyWeb (Chromium 116 rechaza ficheros de más de 150 KB: password_importer.cc, kMaxFileSizeBytes).
# Cada trozo lleva la cabecera y registros enteros (respeta comillas y saltos de línea dentro de las notas).
# No muestra ni registra ninguna contraseña. Solo usa la biblioteca estándar (Python 3 de macOS).
#
# Uso: python3 partir-csv-contrasenas.py Contraseñas.csv     → Contraseñas-1.csv, Contraseñas-2.csv… al lado
#      (hacerlo dentro del disco en RAM del protocolo, nunca en Descargas ni en una carpeta con copia de seguridad)
import csv
import io
import os
import sys

LIMITE = 140 * 1024  # margen bajo los 150 KB


def partir(ruta, limite=LIMITE):
    with open(ruta, newline='', encoding='utf-8-sig') as f:
        filas = list(csv.reader(f))
    if not filas:
        sys.exit('El CSV está vacío')
    cabecera, registros = filas[0], filas[1:]
    nombres = [c.strip().lower() for c in cabecera]
    if 'password' not in nombres or not ({'url', 'website', 'origin', 'hostname', 'login_uri'} & set(nombres)):
        sys.exit(f'Cabecera inesperada ({len(cabecera)} columnas): no parece un CSV de contraseñas')

    def texto(rs):
        b = io.StringIO()
        w = csv.writer(b, lineterminator='\n')
        w.writerow(cabecera)
        w.writerows(rs)
        return b.getvalue()

    trozos, actual = [], []
    for r in registros:
        if actual and len(texto(actual + [r]).encode('utf-8')) > limite:
            trozos.append(actual)
            actual = []
        actual.append(r)
    if actual:
        trozos.append(actual)
    base, ext = os.path.splitext(ruta)
    salidas = []
    for i, t in enumerate(trozos, 1):
        destino = f'{base}-{i}{ext}'
        fd = os.open(destino, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, 'w', encoding='utf-8', newline='') as f:
            f.write(texto(t))
        salidas.append((destino, len(t)))
    return len(registros), salidas


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(__doc__ or 'Uso: partir-csv-contrasenas.py Contraseñas.csv')
    total, salidas = partir(sys.argv[1])
    for destino, n in salidas:
        print(f'{destino}: {n} contraseñas, {os.path.getsize(destino) // 1024} KB')
    print(f'Total: {total} en {len(salidas)} fichero(s). Impórtalos todos en FlyWeb y borra después el disco en RAM.')
