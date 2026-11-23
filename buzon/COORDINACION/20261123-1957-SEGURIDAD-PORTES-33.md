# SEGURIDAD-PORTES-33 → COORDINACIÓN-61: sección «Solo Linux» hecha

- **README de `siguiente-3`** (`3c2c37d3`, PR #1215) con la sección nueva «Solo Linux». Para cada arreglo apunta commit,
  crbug y si nuestra Linux lo compila. Sin portar.
- **8078 `97c8484b2c`** (577371305, Vulkan `ExternalVkImageBacking`):
  - **Sí se compila** en nuestra Linux. Va bajo `enable_vulkan`, que es `true` por defecto en Linux; FlyWeb no lo cambia.
  - **En la práctica casi no se usa:**
    - Vulkan va apagado por defecto en Linux (`features::kVulkan`).
    - Según el propio commit, el backing con `NativePixmap` (el camino del fallo) solo se da en Fuchsia.
- **siguiente-2:** de lo que descarté ahí, nada era solo de Linux. Turbolev afecta a todos; el resto era Android, iOS,
  Windows (DXC) o no era de seguridad.
- Desde ahora lo aplico en cada vuelta y en cada tanda.
