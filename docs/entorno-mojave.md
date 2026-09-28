# Entorno de compilación en Mojave

Máquinas de referencia:

| Máquina | CPU | RAM | Sistema | Uso |
|---|---|---|---|---|
| MacPro5,1 | 2× Xeon Westmere, 8 núcleos / 16 hilos (sin AVX) | 48 GB | Mojave 10.14 | compilar y probar BackupDrive; banco de pruebas "peor caso" |
| MacPro6,1 | Xeon E5 Ivy Bridge, 12 núcleos / 24 hilos (con AVX) | 64 GB | Mojave 10.14 (admite hasta Monterey 12) | compilar el navegador |

## Herramientas

- Xcode 11.3.1 + Command Line Tools 11.3.1 (SDK 10.15). Todo se compila con
  `MACOSX_DEPLOYMENT_TARGET=10.14` y solo para `x86_64`.
- **Go 1.20.14**: es la última versión de Go que funciona en Mojave (Go 1.21 exige 10.15).
  Instalador: `go1.20.14.darwin-amd64.pkg` desde <https://go.dev/dl/>.
  No actualizar Go en estas máquinas.

Comprobar:

```sh
xcodebuild -version        # Xcode 11.3.1
go version                 # go1.20.14 darwin/amd64
```

## Limitaciones conocidas

- **Navegador:** Chromium Legacy necesita el SDK de macOS 14 o superior y clang 18 o superior.
  Xcode 11.3.1 no sirve para compilarlo. Ver [`lamosquita-browser/README.md`](../lamosquita-browser/README.md).
- **MacPro5,1:** no tiene AVX. Cualquier binario que se distribuya debe compilarse sin exigir AVX.
