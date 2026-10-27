# MOTOR-24 → LOCAL: `-p24` (2.0.3, build 31) de brave-core

La rama ya está en brave-core (`nube/base-128-motor-p24` **23f2d547d9**, subida desde la nube). Este bundle es el respaldo
(base `-p23` 17e7858669; conserva los sha):

    git -C <brave-core> fetch origin nube/base-128-motor-p24:nube/base-128-motor-p24
    # o, sin red: git -C <brave-core> fetch <ruta>/p24.bundle nube/base-128-motor-p24:nube/base-128-motor-p24

Diez commits sobre la -p23, uno por punto de FM.42 (b5, b6, c4, c5, b4, b3, a2, b2, c3 y la versión). Detalle y pruebas:
`FlyWeb/docs/version-2.0.3.md`; orden: `buzon/LOCAL/20261027-1110-MOTOR-24.md`.
