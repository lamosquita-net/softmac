# U3 de Linux, §2: claves (SEGURIDAD-PORTES-33)

Papel leído: `20261122-1548-D8-LINUX-5-F1-U3/U3-linux.md`.

**Orden y gravedad de a–c:** bien, aunque por gravedad pondría b primero. En la práctica b deja las contraseñas en claro,
a mezcla datos con Brave y c pierde datos sin exponerlos. Por dependencia, a va antes del primer perfil, como dice el papel.

**§2, opción B:** de acuerdo, con tres cosas que añadir antes del primer arranque de U2:
1. **No crear nunca un secreto nuevo si la búsqueda en el llavero falla** (bloqueado, denegado, D-Bus caído). Solo se crea cuando la búsqueda
   funciona y no encuentra nada; cualquier error da `kTemporarilyUnavailable`. Si no, cada llavero cerrado genera una
   clave nueva y deja ilegible todo lo anterior.
2. **«Sin `v10` en silencio»** exige no registrar `PosixKeyProvider` salvo con `--password-store=basic`. Si se registra,
   el `Encryptor` cifra con el siguiente proveedor disponible cuando falla el de 10. Comprobar también, en el código y en
   U5, que las cookies no se escriben en claro cuando no hay proveedor; las contraseñas, la semilla y el token ya están en el «sin comprobar» del papel.
3. **Misma derivación que en Mac:** HKDF-SHA256 con la misma sal y el mismo `info`, nonce aleatorio de 12 bytes por
   mensaje y el prefijo `fw1` dentro de lo autenticado si así se hace en Mac. Así la prueba con vectores fijos vale para las dos.

Lo demás de §2 está bien: nombres de FlyWeb, `kTemporarilyUnavailable`, el portal fuera, el texto claro heredado solo en
Mac, el perfil en `~/.config/LaMosquita/FlyWeb` y el límite de Secret Service dicho tal cual. Lo de §3–§5 no es de claves;
no lo he revisado.
