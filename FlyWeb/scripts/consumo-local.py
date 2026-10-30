#!/usr/bin/env python3
"""Consumo de las sesiones locales de Claude Code (terminal), para docs/CONSUMO.md.

Lee los registros de ~/.claude/projects/*/*.jsonl (no los modifica) y saca, por sesión:
tokens de entrada, de caché (escritura y lectura) y de salida, número de turnos y el
contexto del último turno (lo que ocupaba la conversación). No calcula dólares: el precio
depende del plan; lo que cuenta para comparar agentes son los tokens.

Uso: consumo-local.py [--horas N] [--max-contexto 1000000]
  --horas N         solo sesiones con actividad en las últimas N horas (por defecto 24)
  --max-contexto    tamaño de la ventana para el porcentaje (por defecto 1 000 000)
COORDINACIÓN, 30-10-2026.
"""
import argparse
import glob
import json
import os
import time

ap = argparse.ArgumentParser()
ap.add_argument("--horas", type=float, default=24)
ap.add_argument("--max-contexto", type=int, default=1_000_000)
args = ap.parse_args()

limite = time.time() - args.horas * 3600
filas = []
for f in glob.glob(os.path.expanduser("~/.claude/projects/*/*.jsonl")):
    if os.path.getmtime(f) < limite:
        continue
    ent = cw = cr = sal = turnos = 0
    contexto = 0
    modelo = carpeta = ""
    vistos = set()
    with open(f, encoding="utf-8", errors="replace") as fh:
        for linea in fh:
            try:
                d = json.loads(linea)
            except ValueError:
                continue
            m = d.get("message") or {}
            u = m.get("usage") if isinstance(m, dict) else None
            if not u or d.get("isSidechain"):
                continue
            # Una respuesta puede repetirse en varias líneas (bloques): contar cada petición una vez.
            rid = d.get("requestId") or d.get("uuid")
            if rid in vistos:
                continue
            vistos.add(rid)
            turnos += 1
            ent += u.get("input_tokens", 0)
            cw += u.get("cache_creation_input_tokens", 0)
            cr += u.get("cache_read_input_tokens", 0)
            sal += u.get("output_tokens", 0)
            contexto = (u.get("input_tokens", 0) + u.get("cache_creation_input_tokens", 0)
                        + u.get("cache_read_input_tokens", 0))
            modelo = m.get("model", modelo)
            carpeta = os.path.basename(d.get("cwd") or "") or carpeta
    if turnos:
        filas.append((os.path.getmtime(f), os.path.basename(f)[:8], carpeta, modelo, turnos,
                      ent, cw, cr, sal, contexto))

filas.sort()
print("| última actividad | sesión | carpeta | modelo | turnos | entrada | caché escr. | caché leída | salida | contexto |")
print("|---|---|---|---|---|---|---|---|---|---|")
for t, s, c, mo, tu, e, w, r, o, ctx in filas:
    pct = 100 * ctx / args.max_contexto
    print(f"| {time.strftime('%d-%m %H:%M', time.localtime(t))} | {s} | {c} | {mo} | {tu} | {e:,} | {w:,} | {r:,} "
          f"| {o:,} | {ctx:,} ({pct:.0f} %) |")
