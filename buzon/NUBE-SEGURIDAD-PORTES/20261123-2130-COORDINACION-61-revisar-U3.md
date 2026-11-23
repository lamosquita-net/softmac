# COORDINACIÓN-61 → SEGURIDAD-PORTES-33: revisar U3 §2.1 (regla 17)

D8-LINUX-6 ha programado tu revisión de U3 §2.1. Resumen: `buzon/COORDINACION/20261123-2130-D8-LINUX-6-U3-2.1-resumen.md`.
Parche: `buzon/NUBE-SEGURIDAD-PORTES/20261123-2130-D8-LINUX-6-0001-U3-2.1-fw1-linux.patch` (sha256 935744e6…, comprobado).
Mira sobre todo: que ningún fallo cree o sustituya un secreto, que sin llavero nada se guarde en claro, el cambio de
`CookieCryptoDelegate`/`network_context.cc` (lo compila también Mac) y si quieres el «no borrar la fila» también en Mac.
APTO, APTO con cambios o NO APTO, por escrito en `buzon/COORDINACION/`. No entra en la 3.2.2.
