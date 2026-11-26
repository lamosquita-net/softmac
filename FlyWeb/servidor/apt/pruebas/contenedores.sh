#!/bin/bash
# Verificación cruzada del repositorio que deja «FLYWEB_APT_GUARDAR=<dir> node pruebas/firma-apt.mjs», con podman:
# gpgv de Ubuntu 22.04 (sin red), sqv de Ubuntu 26.04, y apt update + apt-cache policy en 22.04, 24.04, Debian 12 y 26.04
# (sin red; en 26.04 con sqv instalado, para que apt verifique con Sequoia).
# Uso: bash pruebas/contenedores.sh <dir>
set -u
G=$(realpath "$1"); R=0
cnt() { local img=$1; shift; podman run --rm -v "$G":/g:ro "$@" "$img" bash -c "$CMD"; }
echo "== gpgv de Ubuntu 22.04 (sin red)"
CMD='gpgv --version | head -1; gpgv --keyring /g/flyweb.gpg /g/dists/stable/InRelease && gpgv --keyring /g/flyweb.gpg /g/dists/stable/Release.gpg /g/dists/stable/Release && echo GPGV_2204_OK'
cnt docker.io/library/ubuntu:22.04 --network none 2>&1 | grep -E 'gpgv \(|OK|BAD|rror|Imposible|Good|Correcta'
APT='echo "deb [signed-by=/g/flyweb.gpg] file:/g stable main" > /tmp/fw.list
apt-get -o Dir::Etc::SourceList=/tmp/fw.list -o Dir::Etc::SourceParts=/nonexistent update 2>&1 | grep -E "^(Get|Des|Ign|Err|E|W):|flyweb|/g"
apt-cache policy flyweb | sed -n "1,4p"'
for img in ubuntu:22.04 ubuntu:24.04 debian:12; do
  echo "== apt en $img (sin red)"
  CMD="apt-get --version | head -1; $APT"
  cnt docker.io/library/$img --network none 2>&1
done
echo "== Ubuntu 26.04: sqv y apt con sqv (red solo para instalar sqv)"
CMD="apt-get update -qq > /dev/null && apt-get install -y -qq sqv > /dev/null 2>&1; sqv --version
sqv --keyring /g/flyweb.gpg /g/dists/stable/Release.gpg /g/dists/stable/Release && echo SQV_OK
apt-get --version | head -1; $APT"
cnt docker.io/library/ubuntu:26.04 2>&1
