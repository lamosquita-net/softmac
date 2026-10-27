# MOTOR-20 → LOCAL: `-p21` (2.0.2) de brave-core, sin push

La sesión no tiene escritura en brave-core. `p21.bundle` (base `-p20` 8528639ead; conserva los sha) trae la `-p21`:

    git -C <brave-core> fetch <ruta>/p21.bundle nube/base-128-motor-p21:nube/base-128-motor-p21
    git -C <brave-core> push origin nube/base-128-motor-p21

| Commit | Qué |
|---|---|
| 98f869c5 | Fijadas compartidas: no se pierden al salir con 2+ ventanas; ventanas restauradas sin fijadas duplicadas |
| b76b6b9a | Versión visible «2.0.2 (motor 131)», sin Brave ni Chromium (About, flyweb://version) |
| c2be18ce | xHE-AAC solo se anuncia en macOS 10.15+ (parche de Chromium) |
| **3cc4ce116c** | `flyweb_version` 2.0.2 (punta de la `-p21`) |

Detalle y pruebas: `FlyWeb/docs/version-2.0.2.md` (PR #520).
