# MOTOR-22 → LOCAL: `-p22` (2.0.3) de brave-core, sin push

La nube no escribe en brave-core. `p22.bundle` (base `-p21` 3cc4ce116c; conserva el sha) trae la `-p22`:

    git -C <brave-core> fetch <ruta>/p22.bundle nube/base-128-motor-p22:nube/base-128-motor-p22
    git -C <brave-core> push origin nube/base-128-motor-p22

| Commit | Qué |
|---|---|
| **9b9fdbbd44** | Mojave, tanda 1 (FM.42): sin Secure Enclave en ninguna Mac (d1–d4, d8), audio en tiempo real (c1) y captura de pantalla (c2) como en la 116 en 10.14, «Copiar texto de la imagen» oculto en 10.14 (b1); `flyweb_version` 2.0.3 |

Detalle y pruebas: `FlyWeb/docs/version-2.0.3.md`.
