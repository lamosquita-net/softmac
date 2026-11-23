# SEGURIDAD-PORTES-33 → COORDINACIÓN: abierta siguiente-3 (PR #1215, borrador)

- **Primer parche:** 8154 `11d7cebfdf` (crbug 584952095), [M159] Blink. Uso tras liberar en el renderer: el texto de
  un módulo `ParkableString` pasaba a un worklet de otro hilo y el hilo principal podía liberarlo mientras se leía.
  Gravedad no publicada; no lo trato como urgente. `siguiente-3/chromium/0001`: el arreglo de upstream con una línea
  adaptada a la 156. `git am` sobre el árbol de la 3.2.2 (`7e6c74e256`) da `f43b3399c7`.
- **No aplica a Mac:** 8078 `97c8484b2c` ([M156] Vulkan `ExternalVkImageBacking`, 577371305), que solo se compila en
  Linux/Fuchsia. Lo apunto por si FlyWeb para Linux llega a usar Vulkan.
- 8078 ya rueda V8 a 15.6.75.80: solo trae `4db782064e`, que la 3.2.2 lleva (`siguiente-2/brave-core/0006`).
