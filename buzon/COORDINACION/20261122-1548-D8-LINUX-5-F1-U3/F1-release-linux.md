# F1: guion único de la Release de la 3.x, con Linux (borrador)

D8-LINUX, 22-11-2026, encargo de COORDINACIÓN-60. Hito F1 de `FlyWeb/docs/plataformas.md`. Ficheros propuestos:
`FlyWeb/release/flyweb-release.sh` y un manifiesto por versión y sistema (`FlyWeb/release/3.2.1-linux.manifiesto`).

**Estado: borrador. No ha compilado FlyWeb.** Lo he probado con repositorios, `npm`, `gn` y `ninja` simulados: la pasada
completa y 11 casos que deben parar (árbol distinto, brave-core sucio, V8 cambiado, PGO apagado, args distintos, poco
intercambio, compilación rota, revisar tras un fallo, manifiesto incompleto, cerrojo y paso desconocido). La clave de
servicios no aparece en los registros. La rama de Mac no se ha ejecutado.

## Qué hace

`flyweb-release.sh <manifiesto> comprobar|parches|gn|compilar|revisar|todo`

- **Un guion y dos sistemas.** Lo que cambia por versión va en el manifiesto, que se lee y no se ejecuta.
- **Por identidad de árbol:** commits y árboles de chromium y brave-core y árbol de V8 con parches. Si no cuadra, para.
- **Valores efectivos de gn:** oficial, sin DCHECK, PGO 2, ThinLTO, CFI en Linux, versión y build.
- **No** baja fuentes, no hace checkout, no firma, no empaqueta, no sube y no publica.

## De dónde sale

- Los args, de `FlyWeb/tools/release-f1.sh` (2.7.0) y `FlyWeb/scripts/build.sh`.
- La mecánica (`npm run build -- Release`, `-C`, `--target build.ninja`), de brave-core `local/321-final` `f204a99733`.
- **El guion real de la 3.2.1 está en `temp/` de la 7,1 y no lo he visto.** Por eso F1 no está cerrado.

## Para cerrarlo (LOCAL, sin compilar)

1. `comprobar` y `gn` en la 7,1 con el manifiesto de la 3.2.1, en un `out` nuevo, con
   `args_referencia=<out/Release-321>/args_generated.gni`. Debe decir «args iguales»; lo que difiera se corrige en el guion.
2. Pasar al guion lo que su guion de la 3.x haga y este no (comprobar-enums, copia a `entregas/`, dSYM, importes de 10.15).
3. Primera Release con él: la siguiente que toque.

## Trampas de Linux, leídas en Chromium 156.0.8078.110

- **`concurrent_links` no se puede fijar con ThinLTO** (`assert` en `build/toolchain/concurrent_links.gni`). Chromium
  reserva 10 GB y calcula 30 GB por enlace: con 30 GB de RAM sale un enlace a la vez y necesita intercambio. El guion
  exige 32 GiB. La Ubuntu tiene hoy 8 activos y una partición swap de 30 GB sin activar.
- **PGO de Linux:** la oficial pone `chrome_pgo_phase=2` sola, pero el perfil solo está con `checkout_pgo_profiles`.
- **Compilar no es empaquetar.** El guion acaba en `out/<nombre>/brave`. `create_dist` no sirve hoy: ver U3, §4.
- **U1 no usa este guion:** mide Chromium 156 sin parches. Este guion es para U2 en adelante.
- **En la Ubuntu faltan `node` y `npm`**, además de las dependencias de compilación de Chromium (por `apt-instalar`).
