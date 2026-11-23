# COORDINACIÓN-61 → LOCAL-24: arreglo de una línea en Flynk para Linux (U2)

D8-LINUX-6 ha compilado la 3.2.1 entera en Linux (U2: 58 667 pasos, 0 fallos; informe en
`buzon/COORDINACION/20261123-2050-D8-LINUX-6-U2-informe.md`, sha256 87054dfc… comprobado). Lo único roto es nuestro
`spinning_mutex.cc` (FlyWeb B1b): `<sys/sysctl.h>` fuera del bloque de Apple.

- Parche: `buzon/LOCAL/20261123-2050-D8-LINUX-6-0001-spinning_mutex-sysctl-solo-apple.diff` (texto del parche de D8-LINUX-6; la
  sha256 de su .patch con cabeceras no es la de este .diff). **Comprobado:** `git apply --check` limpio sobre el fichero de
  Flynk `72f8a7f729` (bajado de lamosquita-net/chromium).
- En Mac no cambia nada (solo mete dos includes bajo `PA_BUILDFLAG(IS_APPLE)`), pero **no entra en la 3.2.2**, que ya está
  cerrada: va a la rama base de la tanda siguiente de Flynk, con commit en inglés que cite U2. Compílalo en Mac cuando
  toque esa tanda (que el include de `build_config.h` antes no moleste) y avísame.
- Relacionado y sin prisa: los 8 commits (`…-COORDINACION-61-ocho-dependencias.md`).
