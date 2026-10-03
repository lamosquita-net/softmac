#!/bin/sh
# Genera las claves de firma de los componentes de Shields de FlyWeb (plan B).
#
# Uso: sh generar-claves.sh <directorio de claves> [listas.json]
#
# - Crea las que falten: publicador, defecto, primera-parte, recursos, catalogo y lista-<UUID> por cada lista regional de
#   listas.json. **Nunca sobrescribe** una clave existente: si cambia una clave, cambia el ID del componente, y los
#   FlyWeb ya instalados dejan de recibirlo.
# - Claves RSA-2048, permisos 0600, en un directorio 0700. No se muestra ninguna clave privada.
# - Muestra solo datos PÚBLICOS: el contenido de claves-publicas.json (claves públicas y hash del publicador).
#   Se puede pegar en un PR o en un chat sin riesgo; de ahí salen también los ID para brave-core.
# - Copia de seguridad: el directorio entero, por el canal habitual del HUMANO. Si se pierde, hay que publicar
#   un FlyWeb nuevo con claves nuevas.
set -eu
DIR=${1:?Uso: sh generar-claves.sh <directorio de claves> [listas.json]}
LISTAS=${2:-$(dirname "$0")/listas.json}
umask 077
mkdir -p "$DIR"
chmod 700 "$DIR"

NOMBRES="publicador defecto primera-parte recursos catalogo $(node -e '
  for (const u of JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).regionales) console.log("lista-" + u)
' "$LISTAS")"

for n in $NOMBRES; do
  f="$DIR/$n.pem"
  if [ -e "$f" ]; then
    echo "existe:  $n"
  else
    openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "$f" 2>/dev/null
    chmod 600 "$f"
    echo "creada:  $n"
  fi
done

echo
echo "== Datos PÚBLICOS: pegar en un PR o en el chat (ninguna clave privada) =="
node -e '
const crypto = require("crypto"), fs = require("fs"), path = require("path")
const [dir, ...nombres] = process.argv.slice(1)
const der = (n) => crypto.createPublicKey(fs.readFileSync(path.join(dir, n + ".pem"))).export({ type: "spki", format: "der" })
const claves = {}
for (const n of nombres) if (n !== "publicador") claves[n] = der(n).toString("base64")
const h = crypto.createHash("sha256").update(der("publicador")).digest()
console.log(JSON.stringify({ _comentario: "Claves PÚBLICAS de firma (SPKI DER en base64), generadas en bak con generar-claves.sh.",
  claves, publicador_sha256: h.toString("hex"),
  publicador_sha256_c: "{" + [...h].map((b) => "0x" + b.toString(16).padStart(2, "0")).join(", ") + "}" }, null, 2))
' "$DIR" $NOMBRES
