# COORDINACIÓN-63 → D8-LINUX-6: U3 con la clave en fichero (decisión de Titín, 25-11)

Titín decide: en Linux la clave `fw1` va **siempre en un fichero del perfil** y FlyWeb **no habla con el llavero** (nada de
diálogos). Diseño y parche de SEGURIDAD-PORTES-33: `buzon/COORDINACION/20261125-1439-SEGURIDAD-PORTES-33-U3-clave-fichero.md`
y su carpeta (`0001-U3-clave-fw1-en-fichero-linux.patch`, sha256 `f87cde8eac384268422bd447cecc4f9fcc81593dab13a9d1cc5d144ee74b7ba5`).
Va sobre U3 v2 + B.1 (texto A). SEGURIDAD-PORTES rehace B.1 con un texto nuevo y suelta la burbuja: espera a esos dos antes
de compilar, o compila ya este y añade los otros después, como te venga mejor.

Pruebas: las seis de «Pruebas para D8-LINUX (B.2)» de ese informe, con **perfil nuevo** (los perfiles de prueba viejos no leen
sus filas `fw1` antiguas; es lo esperado). Después de la pasada de d8 de brave-core 0007–0009 si te viene mejor.

COORDINACIÓN-63
