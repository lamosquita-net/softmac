#!/bin/bash
# Vigía: comprueba que el appcast de Sparkle y FlyWeb/web/VERSION (main de softmac) dan la misma versión.
# Solo lectura. Imprime «WEB DESFASADA…» / «WEB SINCRONIZADA…» cuando cambia el estado; si no, nada.
# Como el vigía muestrea una vez por hora, también detecta a posteriori un desfase que ocurrió entre dos pasadas:
# VERSION cambió (fecha del último commit en git) y el appcast es posterior (pubDate) y ya coincide.
# Estado en ${VIGIA_WEB_STATE:-/tmp/vigia-web.state} (JSON). Requiere curl, git y python3.
S=${VIGIA_WEB_STATE:-/tmp/vigia-web.state}
APPCAST=https://updates.flyweb.lamosquita.net/stable/appcast.xml
REPO=https://github.com/lamosquita-net/softmac

X=$(curl -sS --max-time 30 "$APPCAST") || { echo "ERR appcast" >&2; exit 1; }
D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
(cd "$D" && git init -q --bare && git fetch -q --depth=200 "$REPO" main) 2>/dev/null || { echo "ERR fetch softmac" >&2; exit 1; }
VER=$(cd "$D" && git show FETCH_HEAD:FlyWeb/web/VERSION 2>/dev/null) || { echo "ERR VERSION" >&2; exit 1; }
CT=$(cd "$D" && git log -1 --format=%ct FETCH_HEAD -- FlyWeb/web/VERSION 2>/dev/null); CT=${CT:-0}

X="$X" VER="$VER" CT="$CT" S="$S" python3 -I -c "
import os, sys, json, datetime, email.utils
import xml.etree.ElementTree as ET
SP='{http://www.andymatuschak.org/xml-namespaces/sparkle}'
root = ET.fromstring(os.environ['X'])
item = next(root.iter('item'))
enc = item.find('enclosure')
def sp(k):
    for el in (enc, item):
        if el is not None and el.get(SP + k): return el.get(SP + k)
    e = item.find(SP + k)
    return e.text if e is not None else ''
A = sp('shortVersionString'), sp('version')
pd = item.find('pubDate')
P = int(email.utils.parsedate_to_datetime(pd.text).timestamp()) if pd is not None and pd.text else 0
V = os.environ['VER'].split()
CT = int(os.environ['CT'])
S = os.environ['S']
st = {'estado': 'ok', 'C': 0}
try:
    st.update(json.load(open(S)))
except Exception:
    pass
hm = lambda t: datetime.datetime.fromtimestamp(t, datetime.timezone.utc).strftime('%H:%M UTC') if t else '?'
out = []
if A[0] != V[0]:
    st['n'] = st.get('n', 0) + 1
    if st['estado'] != 'desfasada':
        out.append('WEB DESFASADA: appcast %s / VERSION %s' % (A[0], V[0]))
    elif st['n'] == 2:
        out.append('ACCIÓN: WEB DESFASADA: sigue igual dos pasadas seguidas (appcast %s / VERSION %s)' % (A[0], V[0]))
    st['estado'] = 'desfasada'
elif st['estado'] == 'desfasada':
    out.append('WEB SINCRONIZADA: appcast %s / VERSION %s' % (A[0], V[0]))
    st['estado'] = 'ok'
elif st['C'] and CT > st['C'] and P > CT:
    out.append('WEB DESFASADA (a posteriori): VERSION %s desde %s, appcast %s; no se vio entre pasadas' % (V[0], hm(CT), hm(P)))
    out.append('WEB SINCRONIZADA: appcast %s / VERSION %s' % (A[0], V[0]))
if A[0] == V[0]:
    st['n'] = 0
st['C'] = CT
json.dump(st, open(S, 'w'))
for line in out:
    print(line)
print('appcast %s %s | VERSION %s %s' % (A[0], A[1], V[0], V[1]), file=sys.stderr)
"
