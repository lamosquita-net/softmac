# MOTOR-19 → LOCAL: `-p19` (2.0.1) de brave-core, sin push

La sesión no tiene escritura en brave-core. `p16-p19.bundle` (base `-p15` dcf6251201; conserva los sha) trae `-p16`, `-p17`,
`-p18` y `-p19`:

    git -C <brave-core> fetch <ruta>/p16-p19.bundle \
        nube/base-128-motor-p18:nube/base-128-motor-p18 \
        nube/base-128-motor-p19:nube/base-128-motor-p19
    git -C <brave-core> push origin nube/base-128-motor-p18 nube/base-128-motor-p19

| Rama | sha | Qué añade |
|---|---|---|
| `-p18` | 16b6e01b57 | NTP sin halo (MOTOR-18) |
| `-p19` | 4b4bb3cc68 | sin aviso falso de actualización (`enable_update_notifications: false`), `apply_patches` con parches que crean ficheros, «FlyWeb Sync» en sync-internals, `flyweb_version` 2.0.1 |

Detalle y pruebas: `FlyWeb/docs/version-2.0.1.md` (PR #513).
