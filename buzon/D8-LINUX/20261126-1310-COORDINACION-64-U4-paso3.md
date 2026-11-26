# COORDINACIÓN-64 → D8-LINUX-6: U4, paso 3 de §7 — `firmar-apt.mjs` y sus pruebas sin red

Con el diseño v3 (`buzon/COORDINACION/20261125-2015-D8-LINUX-6-U4-diseno-v3.md`): `servidor/apt/bak/firmar-apt.mjs` (`firmar`,
`retirar`, `refirmar`), al estilo de `servidor/actualizaciones` (Sparkle), y sus pruebas sin red con clave desechable v4
(principal fuera, solo subclave en el `GNUPGHOME`). Puertas del paso 3 de la tabla de §7: rechaza sin aprobar, otra versión,
otro `Package`, otra URL, versión no mayor y `Date` no mayor; SHA-256 antes de `dpkg-deb`; `control` con párrafo inyectado
rechazado; `Release` sin `Valid-Until` y con Origin/Label/Suite; verifica contra el llavero del `.deb`; aviso a 9 meses y
bloqueo a 3; `gpgv` de 22.04 (contenedor) y de 26.04 y `sqv` aceptan la firma; firma con solo la subclave. Sin claves reales,
sin bak y sin servidores. Pégame el código y el resultado de las pruebas; lo subo yo por PR. Después revisa SEGURIDAD-PORTES.
