"""Filtro del vigía: lee la salida de vigia.sh y vigia-web.sh por stdin y
antepone una línea «ACCIÓN:» por cada cambio que pide algo a COORDINACIÓN.

Solo lee texto y lo reordena; no envía nada ni toca el estado.
Uso: { bash vigia.sh 70; bash vigia-web.sh; } | python3 -I acciones.py
"""
import re
import sys
import datetime
from zoneinfo import ZoneInfo

RULES = [
    (re.compile(r"\.dmg|SHA-256", re.I),
     "nota con datos de un DMG (nombre, bytes, SHA) para la web"),
    (re.compile(r"URGENT", re.I),
     "URGENTE"),
    (re.compile(r"LOCAL.*PUBLICACI|PUBLICACI.*LOCAL", re.I),
     "entrega de LOCAL a PUBLICACIÓN"),
    (re.compile(r"fusionar|pas[ae]? a listo|ready for review|listo para (fusi|revis)|pide (su )?fusi", re.I),
     "un PR pide fusionar o pasa a listo"),
]

LIMITE = 6000
ahora = datetime.datetime.now(ZoneInfo("Europe/Madrid")).strftime("%H:%M")

acciones = []
bloques = []
for linea in (l.rstrip("\n") for l in sys.stdin):
    if not linea.strip():
        continue
    if linea.startswith("ACCIÓN:"):
        acciones.append(linea)
    elif linea.startswith(" ") and bloques:
        bloques[-1].append(linea)
    else:
        bloques.append([linea])

for b in bloques:
    texto = "\n".join(b)
    for rx, motivo in RULES:
        if rx.search(texto):
            acciones.append("ACCIÓN: %s — %s" % (motivo, b[0][:100]))

if not acciones and not bloques:
    print("sin novedades " + ahora)
else:
    cuerpo = ["VIGÍA " + ahora] + [l for b in bloques for l in b]
    salida = "\n".join(acciones + cuerpo)
    if len(salida) > LIMITE:
        salida = salida[:LIMITE] + "\n[…salida cortada a 6000 caracteres…]"
    print(salida)
