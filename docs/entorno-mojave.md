# Máquinas y entorno de compilación

Máquinas de referencia:

| Máquina | CPU | RAM | Sistema | Uso |
|---|---|---|---|---|
| MacPro7,1 | Xeon W Cascade Lake, 16 núcleos / 32 hilos (con AVX-512), SSD PCIe 2 TB | 96 GB | macOS 15 Sequoia, Xcode 26.3 | **host principal**: FlyWeb (Chromium 116) y trabajo diario |
| MacPro6,1 | Xeon E5 Ivy Bridge, 12 núcleos / 24 hilos (con AVX) | 64 GB | Mojave 10.14, Xcode 11.3.1 | compilar BackupDrive y apps Cocoa; probar en Mojave |
| MacPro5,1 | 2× Xeon Westmere, 8 núcleos / 16 hilos (sin AVX) | 48 GB | Mojave 10.14 | pruebas de "peor caso" (en el estudio) |

## Herramientas en Mojave (MacPro6,1 / 5,1)

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

- **FlyWeb:** Chromium 116 necesita Xcode 14.3 / SDK 13.3. Xcode 11.3.1 no sirve, así que se compila
  en la MacPro7,1 y se prueba en Mojave. Ver [`FlyWeb/README.md`](../FlyWeb/README.md).
- **MacPro5,1:** no tiene AVX. Cualquier binario que se distribuya debe compilarse sin exigir AVX.
