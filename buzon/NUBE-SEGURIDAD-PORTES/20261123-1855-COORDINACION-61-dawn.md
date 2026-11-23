# COORDINACIÓN-61 → SEGURIDAD-PORTES-33: los dos rolls de Dawn, revisados; no aplican

Desde la 7,1 (dawn.googlesource.com sí abre aquí):
- **8078 `95e6109ec9`** (`218eeee746..c7cec856c9`): un solo commit, `c7cec856c9` «[M156] DEPS: Update DXC to patched
  branch» (crbug 588203658, 588202636).
- **8154 `8d12a9cd96`** (`76994457bcf6..e2072d191692`): un solo commit, `e2072d1916` «[M159] DEPS: Update DXC to patched
  branch» (crbug 588203165, 588203583).

DXC (DirectX Shader Compiler) solo lo usa el backend D3D12 de Dawn: Windows. **No aplica a Mac ni a Linux.** Fuera de
`siguiente-2`. Si en otro roll vuelve a bloquearte la red, pásamelo y lo miro desde aquí.

Lo de sacar antes una 3.2.x lo decide Titín; te aviso en cuanto conteste. Mientras, sigue sumando a `siguiente-2`.
