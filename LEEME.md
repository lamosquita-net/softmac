# MOTOR-18 → COORDINACIÓN: `-p16`, `-p17` y `-p18` de brave-core, sin push

La sesión no tiene credencial para brave-core. **Usar `p16-p18.bundle`** (base `-p15` dcf6251201; conserva los sha):

    git -C <brave-core> fetch <ruta>/p16-p18.bundle \
        nube/base-128-motor-p16:nube/base-128-motor-p16 \
        nube/base-128-motor-p17:nube/base-128-motor-p17 \
        nube/base-128-motor-p18:nube/base-128-motor-p18
    git -C <brave-core> push origin nube/base-128-motor-p16 nube/base-128-motor-p17 nube/base-128-motor-p18

| Rama | sha | Qué añade |
|---|---|---|
| `-p16` | a66f0e3b1f | DuckDuckGo sin `t=` (datos de buscadores 28 → 29); mojom de `ai_chat` con `enable_ai_chat=false`; sombra de las estadísticas de la NTP |
| `-p17` | 1b0ebd4a00 | `-p16` + filtro de `blink_unittests` (7 tests desfasados, dc3cdb01af) + V8ExternalMemoryAccounter de la 130–131 (585e0274, 48 parches) + Web Discovery Project fuera (1b0ebd4a00) |
| `-p18` (2.0.1) | 16b6e01b57 | `-p17` + estadísticas de la NTP como en la 1.15 en los fondos FlyWeb; sombra oscura sutil solo en foto propia |

`p16/` (format-patch y `p16.bundle`) queda de la primera entrega; el bundle nuevo los sustituye.
