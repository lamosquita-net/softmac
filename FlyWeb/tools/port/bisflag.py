#!/usr/bin/env python3
# bisflag.py <flag>... : primer commit (en la lista de /tmp/claude-0/port/j5-116-126.txt, de
# `git log --reverse --format=%H <tag A>..<tag B> -- runtime_enabled_features.json5`) en el que la flag ya no está.
# Bisección con caché de blobs (~0,7 s por blob en el clon sin blobs). MOTOR-9, nivel 130: las 41 flags `stable` de la
# 116 que no salían por el asunto del commit. Cambiar la lista y las etiquetas para otro tramo.
import subprocess, re, sys
CH='/tmp/claude-0/port/chromium/chromium'; P='third_party/blink/renderer/platform/runtime_enabled_features.json5'
commits=open('/tmp/claude-0/port/j5-116-126.txt').read().split()
cache={}
def has(i,n):
    c=commits[i]
    if c not in cache:
        cache[c]=subprocess.run(['git','-C',CH,'show',f'{c}:{P}'],capture_output=True,text=True).stdout
    return re.search(r'name:\s*"'+re.escape(n)+'"',cache[c]) is not None
for n in sys.argv[1:]:
    lo,hi=0,len(commits)-1   # has(lo) assumed True at start? check
    if not has(0,n): print(n,'ya no está en el primer commit'); continue
    if has(hi,n): print(n,'sigue en 126'); continue
    while hi-lo>1:
        mid=(lo+hi)//2
        if has(mid,n): lo=mid
        else: hi=mid
    c=commits[hi]
    s=subprocess.run(['git','-C',CH,'log','-1','--format=%h %ad %s','--date=short',c],capture_output=True,text=True).stdout.strip()
    print(f'{n}\t{s}',flush=True)
