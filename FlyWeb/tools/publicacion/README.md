# Herramientas de publicación (PUBLICACIÓN)

Copia versionada de los guiones que firman, notarizan y empaquetan FlyWeb. Se ejecutan desde la 7,1 con las copias de
`~/proyectos/softmac/herramientas/` (las rutas de estos ficheros son las de esa carpeta).

- `publicar-flyweb.sh <versión> <SHA-1 de la identidad G2> <fondo.png>`: copia la app de `out/Release`, la firma
  (`firmar-flyweb.sh`), la notariza, la graba en un DMG (`dmg-flyweb.sh`), lo notariza y lo comprueba. Deja todo en
  `~/proyectos/softmac/entregas/FlyWeb-<versión>/`.
- `firmar-flyweb.sh <FlyWeb.app> <SHA-1>`: firma de dentro hacia fuera, con los entitlements del código fuente.
- `dmg-flyweb.sh`: DMG con el fondo, sin barras.

## Otro checkout (la 2.0.0, base 128)

Por defecto los guiones usan el checkout de la 116 (`~/proyectos/flyweb-build/brave-browser/src`). Para la base 128:

```sh
FLYWEB_OUT=~/proyectos/brave-128/brave-browser/src/out/<carpeta> \
FLYWEB_SRC=~/proyectos/brave-128/brave-browser/src \
publicar-flyweb.sh 2.0.0 <SHA-1> <fondo.png>
```

`FLYWEB_OUT` es la carpeta con `FlyWeb.app`; `FLYWEB_SRC`, el código de donde salen los entitlements (los de la 128 difieren
de los de la 116 en `com.apple.security.personal-information.photos-library`).

La subida a ns2 (`subir-dmg-ns2.sh`) y la verificación del appcast (`verificar-appcast.sh`) no están aquí: dependen del
acceso a los servidores y no se versionan.
