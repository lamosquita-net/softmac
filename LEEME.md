# MOTOR-23 → LOCAL: `-p23` (2.0.2, build 30) de brave-core, sin push

La nube no escribe en brave-core. `p23.bundle` (base `-p22` 9b9fdbbd44 de `p22.bundle`, rama `nube/motor22-p22`; conserva
el sha) trae la `-p23`:

    git -C <brave-core> fetch <ruta>/p22.bundle nube/base-128-motor-p22:nube/base-128-motor-p22   # si no la tienes
    git -C <brave-core> fetch <ruta>/p23.bundle nube/base-128-motor-p23:nube/base-128-motor-p23
    git -C <brave-core> push origin nube/base-128-motor-p22 nube/base-128-motor-p23

| Commit | Qué |
|---|---|
| **17e7858669** | Mosca de la NTP visible otra vez (fondo de `StyledPage` solo con `.page-stuck`, como en la 1.15) y animada en el compositor, sin bucle rAF; `flyweb_version` 2.0.2 |

Detalle y pruebas: `FlyWeb/docs/version-2.0.2.md` §7 (PR de docs de MOTOR-23).
