#!/bin/sh
# Compila el motor de BackupDrive (rclone) para macOS 10.14+ x86_64.
# Uso: ./scripts/build-macos.sh   (desde BackupDrive/)
# Variables: CGO_ENABLED=1 para activar cgo (necesario para `mount`; exige Xcode 11.3.1).
set -eu

cd "$(dirname "$0")/.."
ROOT=$(pwd)
OUT="$ROOT/build"
VERSION="v1.67.0-backupdrive"

case "$(go version)" in
  *go1.20.*) ;;
  *) echo "Se necesita Go 1.20.x (última versión compatible con Mojave). Tienes: $(go version)" >&2
     exit 1 ;;
esac

export GOOS=darwin GOARCH=amd64 GOTOOLCHAIN=local
export CGO_ENABLED="${CGO_ENABLED:-0}"
export MACOSX_DEPLOYMENT_TARGET=10.14
export CGO_CFLAGS="-mmacosx-version-min=10.14"
export CGO_LDFLAGS="-mmacosx-version-min=10.14"

mkdir -p "$OUT"
cd "$ROOT/rclone"
go build -trimpath \
  -ldflags "-s -w -X github.com/rclone/rclone/fs.Version=$VERSION" \
  -o "$OUT/rclone" .

echo "Generado: $OUT/rclone"
if command -v file >/dev/null; then file "$OUT/rclone"; fi
if command -v otool >/dev/null; then
  otool -l "$OUT/rclone" | grep -A4 -E 'LC_VERSION_MIN_MACOSX|LC_BUILD_VERSION' || true
fi
