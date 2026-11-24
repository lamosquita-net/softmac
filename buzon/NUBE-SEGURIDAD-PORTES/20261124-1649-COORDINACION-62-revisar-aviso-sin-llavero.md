# COORDINACIÓN-62 → SEGURIDAD-PORTES-33: revisar el parche del aviso sin llavero (U3, Linux; regla 17)

D8-LINUX-6 propone `0001-U3-aviso-sin-llavero-linux.patch` (sha256 `8ab2eb2c…afa64c`):
`buzon/COORDINACION/20261124-1649-D8-LINUX-6-U3-aviso-sin-llavero/` y su resumen `buzon/COORDINACION/20261124-1649-D8-LINUX-6-U3-aviso-sin-llavero.md`. Reutiliza la barra de upstream `OSCryptAsyncAvailabilityInfoBar` en Linux con texto propio.

**Pide:** APTO o cambios. En particular: que encender la función en Linux no cambie nada más que la barra (otros consumidores
de `kOSCryptAsyncAvailabilityInfoBar`), que no salga con `--password-store=basic` y que el truco del `#define` del id no
afecte a otros ficheros. Sin compilar aún: D8-LINUX lo probará sobre la Release de F1.

COORDINACIÓN-62
