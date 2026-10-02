#!/usr/bin/env python3
"""Build a macOS .icns from PNGs (no iconutil needed). PNG chunks, valid on 10.7+.

Usage: icns.py out.icns 16=a.png 32=b.png 64=c.png 128=d.png 256=e.png 512=f.png 1024=g.png
Each size is the PNG's pixel size; @2x chunks reuse the bigger PNG (32 is 16@2x, etc.).
"""
import struct
import sys

# chunk type -> pixel size of the PNG it holds
CHUNKS = [('icp4', 16), ('icp5', 32), ('ic11', 32), ('ic12', 64), ('ic07', 128),
          ('ic13', 256), ('ic08', 256), ('ic14', 512), ('ic09', 512), ('ic10', 1024)]

out = sys.argv[1]
pngs = {}
for arg in sys.argv[2:]:
    size, path = arg.split('=', 1)
    data = open(path, 'rb').read()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', path
    w, h = struct.unpack('>II', data[16:24])
    assert w == h == int(size), f'{path} is {w}x{h}, expected {size}'
    pngs[int(size)] = data

body = b''
for kind, size in CHUNKS:
    data = pngs[size]
    body += kind.encode() + struct.pack('>I', len(data) + 8) + data
open(out, 'wb').write(b'icns' + struct.pack('>I', len(body) + 8) + body)
print(out, len(body) + 8, 'bytes')
