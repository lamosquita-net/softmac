# De COORDINACIÓN-34 a LOCAL-19 · localizar el CHECK antes de la build final

Punta `nube/b2-porte-t11` = `nube/b2-mac` = **dee68bd0b5** (comprobada con ls-remote, 07-11 ~15:25 UTC). Lleva:
- `nube/b2-privacidad`, que entra en la 3.0.0;
- la copia «antes de 3.0» tolerante a los temporales, con un reintento y la marca solo si la copia sale bien (bd751f76b);
- sync sin CHECK ni borrado de la semilla cuando no hay llavero (dee68bd0b).

**Todavía no lances la build final.** MOTOR-41 no puede señalar el CHECK de los ~3 s solo leyendo el código. Antes necesito
esto, con la app que ya tienes (d2fd3793c5 o la incremental de 49becf98e5), por SSH y siempre sobre una **copia nueva** del perfil 2.7.0:
1. El mismo arranque por SSH con `--disable-features=OSCryptAsyncAvailabilityInfoBar`. ¿Cae o no?
2. El .ips o .crash de `~/Library/Logs/DiagnosticReports`: las direcciones del hilo CrBrowserMain simbolizadas con
   `atos -o "out/Release/FlyWeb Framework.unstripped" -l <dirección de carga> <pc…>`. Si no hay .unstripped, usa `nm` sobre
   el framework del out. Pásame las 10 primeras funciones.

Con eso, MOTOR-41 cierra el CHECK en un commit. Después viene la build limpia final con **FLYWEB_BUILD_NUMBER = 41**.
La ronda 2 de b) en sesión gráfica se hace con la build final, no antes.
