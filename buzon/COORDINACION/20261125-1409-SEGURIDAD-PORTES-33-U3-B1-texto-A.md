# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: U3 B.1 con el texto A

Respuesta a `buzon/NUBE-SEGURIDAD-PORTES/20261125-1407-COORDINACION-63-U3-texto-A.md` (1bdf94e2). Es el parche
`…1649-D8-LINUX-6-U3-aviso-sin-llavero/0001` (`8ab2eb2c…afa64c`) con el texto que eligió Titín. **No cambia nada más del
código.** Solo Linux, sin compilar.

- **Parche:** carpeta de al lado, `0001-U3-aviso-sin-llavero-linux.patch`, 6181 B.
  **sha256 `ed169327be0e2f56ea11de7bb77dfd3ba0453e01cc4aa9ab585e81f4a5b10cb2`** (también en `SHA256SUMS`).
- **EN (`.grd`, 115 caracteres):** «Can’t reach your keyring: FlyWeb can’t use or save passwords and sign-ins. Nothing is lost.
  Unlock it and relaunch.» (apóstrofo tipográfico ’, como en el parche anterior).
- **ES (`es` y `es-419`, 123 caracteres):** «Sin acceso al llavero, FlyWeb no puede usar ni guardar contraseñas ni sesiones. No se pierde
  nada. Desbloquéalo y reinicia.»
- **Id de traducción: `6960035439647298739`.** Lo calculé con `tclib.GenerateMessageId` de grit de la 156, sobre el texto
  extraído del `.grd` ya parcheado. El método está comprobado: da `3910221419342394766` con el texto anterior y
  `6438922473717127121` con una cadena que ya existe («Account and sync»). Las dos `.xtb` llevan el id nuevo y el anterior
  desaparece. El `.grd` y las `.xtb` son XML válido.
- **Cambios menores, sin efecto en el id:** la `desc` del mensaje (dice que no se usan ni se guardan y que la barra es de una
  línea) y un comentario del `chromium_src`.
- **Aplica limpio** (`git apply --cached`) sobre `local/322-final` `060015a8` (árbol resultante `0338931b3e`) y sobre la
  tanda, brave-core `siguiente-3` `0001`–`0009` (`295a8c0ca2`).
- **Para D8-LINUX:** compilar, ver la barra en B.2 («llavero ausente») y comprobar que no se corta a 1280 px, en inglés y en
  español.

La burbuja y el volcado en SIGTERM no los he tocado, según la orden.

SEGURIDAD-PORTES-33
