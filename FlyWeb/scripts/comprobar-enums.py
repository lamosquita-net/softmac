#!/usr/bin/env python3
"""Comprueba los enums numerados de Blink en el checkout, con los parches ya aplicados (MOTOR-41, 31-10-2026).

Uso: comprobar-enums.py <src>   (lo llama build.sh tras apply_patches; sale con 1 si hay errores)

En la 2.6.0, kSelectionDirection = 5040 y kSelectionGetComposedRanges = 5041 quedaron al final de web_feature.mojom,
tras 5374: el kNumberOfFeatures implícito bajó a 5042 y contar 5043+ abortaba en el bitset de UseCounter (Speedometer).
Regla: en los enums de Blink, añadir siempre al final con un valor mayor que el máximo, o insertar en su sitio numérico.

Mira los .mojom de third_party/blink/public/mojom. En cada enum con valores numéricos:
- ERROR si un miembro sin `=` (kNumberOfFeatures, un máximo implícito) vale menos o igual que un valor anterior;
- ERROR, en los enums vigilados con miembro implícito (WebFeature, WebDXFeature…), si un valor explícito queda por
  debajo del máximo anterior, y en los vigilados si dos miembros repiten un valor distinto de 0;
- AVISO en el resto (otros enums, o CSSSampleId, que no tiene miembro implícito: kReadingOrder = 839 tras 848 no
  rompe nada, pero se corrige en el próximo nivel). Los alias por nombre (kMaxValue = kFoo) no cuentan.
"""
import os
import re
import sys

VIGILADOS = {'WebFeature', 'WebDXFeature', 'PermissionsPolicyFeature', 'CSSSampleId'}


def enums(text):
    text = re.sub(r'//[^\n]*', '', text)
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    for m in re.finditer(r'\benum\s+(\w+)\s*\{([^}]*)\}', text):
        yield m.group(1), m.group(2)


def check(name, body):
    errs = []
    values = {}
    seen = {}
    cur = -1
    running_max = None
    vigilado = name in VIGILADOS or 'kNumberOfFeatures' in body
    # Sin miembro implícito, el orden no cambia nada (mojom calcula kMaxValue como el máximo): solo avisa.
    implicit = any(re.match(r'\s*(\[[^\]]*\]\s*)?\w+\s*$', x) for x in body.split(',') if x.strip())
    for raw in body.split(','):
        e = re.sub(r'\[[^\]]*\]', '', raw).strip()
        if not e:
            continue
        m = re.match(r'(\w+)\s*(?:=\s*(.+))?$', e, re.S)
        if not m:
            return []  # forma desconocida: no se mira
        member, val = m.group(1), m.group(2)
        alias = False
        if val is None:
            cur += 1
            if running_max is not None and cur <= running_max:
                errs.append((True, '%s.%s vale %d (implícito) y ya hay un valor %d antes: añadir en orden numérico'
                             % (name, member, cur, running_max)))
        else:
            val = val.strip()
            if re.fullmatch(r'-?\d+', val):
                cur = int(val)
            elif re.fullmatch(r'0[xX][0-9a-fA-F]+', val):
                cur = int(val, 16)
            elif val in values:
                cur = values[val]
                alias = True
            else:
                return []  # expresión: no se mira
            if not alias and running_max is not None and cur < running_max:
                msg = ('%s.%s = %d queda por debajo del máximo anterior %d: insertar en su sitio numérico'
                       % (name, member, cur, running_max))
                errs.append((vigilado and implicit, msg))
        values[member] = cur
        if not alias:
            if cur in seen and cur != 0:  # el 0 se repite a propósito (p. ej. propiedades internas de CSSSampleId)
                errs.append((vigilado, '%s.%s = %d repite el valor de %s' % (name, member, cur, seen[cur])))
            else:
                seen[cur] = member
            running_max = cur if running_max is None else max(running_max, cur)
    return errs


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    root = os.path.join(sys.argv[1], 'third_party', 'blink', 'public', 'mojom')
    if not os.path.isdir(root):
        print('comprobar-enums: no existe %s' % root, file=sys.stderr)
        return 2
    errors = []
    warnings = []
    nfiles = 0
    for d, _, files in os.walk(root):
        for f in files:
            if not f.endswith('.mojom'):
                continue
            path = os.path.join(d, f)
            nfiles += 1
            with open(path, encoding='utf-8', errors='replace') as fh:
                text = fh.read()
            for name, body in enums(text):
                for vigilado, e in check(name, body):
                    (errors if vigilado else warnings).append('%s: %s' % (os.path.relpath(path, sys.argv[1]), e))
    for e in warnings:
        print('AVISO enum: ' + e, file=sys.stderr)
    for e in errors:
        print('ERROR enum: ' + e, file=sys.stderr)
    print('comprobar-enums: %d .mojom, %d errores, %d avisos' % (nfiles, len(errors), len(warnings)))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
