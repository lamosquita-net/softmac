# Registro de actividades de tratamiento (art. 30 RGPD) — FlyWeb

Documento interno, para tenerlo a disposición de la AEPD si lo pide (art. 30.4); no hace falta publicarlo. Se lleva
aunque haya menos de 250 empleados porque los tratamientos de abajo no son ocasionales (art. 30.5). Cada cambio de
`FlyWeb/web/privacidad.html` que afecte a datos personales se refleja aquí en el mismo PR.

**Responsable:** Vicente Soriano Pérez-Almazán (nombre comercial lamosquita), profesional autónomo, Valencia.
Contacto: admin@lamosquita.net. NIF y domicilio: en el aviso legal de `flyweb.lamosquita.net` (no se guardan en este
repositorio, que es público). Sin delegado de protección de datos (no es obligatorio: art. 37).

**Encargado de tratamiento:** OVH (servidor dedicado *bare metal* ns2, en la UE), solo como alojamiento: la máquina la
administra el responsable y OVH no accede a los datos. Contrato del art. 28: el acuerdo de tratamiento de datos que OVH
incluye en sus condiciones generales, aceptadas con el contrato (confirmado por el HUMANO, 09-10-2026).

**Transferencias internacionales:** ninguna. A Google (navegación segura, diccionarios) solo le llega la IP del servidor y
prefijos de huellas que, sin la IP del usuario, no identifican a nadie.

**Medidas de seguridad (art. 32):** HTTPS en todos los servicios; registros sin IP en los servicios del navegador
(formato `sinip`); datos de Sincronizar cifrados de extremo a extremo con una clave que no sale del Mac del usuario;
servicios con usuario dinámico y endurecimiento de systemd; acceso al servidor solo por SSH con clave; fail2ban;
actualizaciones firmadas (EdDSA) en una máquina aparte (bak).

| Tratamiento | Fin y base legal | Interesados y datos | Plazo de supresión |
|---|---|---|---|
| Web `flyweb.lamosquita.net` | Seguridad de la web; interés legítimo (art. 6.1.f) | Visitantes: IP, fecha, página pedida, agente de usuario | 14 días (registro de Apache) |
| Servicios del navegador (`components.`, `updates.`, `proxy.`) | Mantener el navegador seguro y actualizado; interés legítimo (art. 6.1.f) | Usuarios de FlyWeb: IP solo en tránsito (no se guarda); versión del navegador y de los componentes, sistema y arquitectura | Registros sin IP: 7 días |
| Sincronizar (`sync.`) | Prestar el servicio que el usuario activa; ejecución del servicio (art. 6.1.b) | Usuarios que lo activan: datos del navegador **cifrados en su Mac** (seudonimizados para nosotros) y una clave pública que identifica la cadena; IP en tránsito | Hasta que el usuario los borre o un año sin uso (`FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365`); historial, 14 días |
| Cifras de descargas | Estadística pública de descargas; interés legítimo (art. 6.1.f) | Ninguno: solo fecha, versión y número, sin IP | Indefinido (no son datos personales) |
| Correo `admin@lamosquita.net` | Atender consultas, avisos de seguridad y ejercicio de derechos; interés legítimo y obligación legal (arts. 6.1.f y 6.1.c) | Quien escribe: dirección de correo y lo que cuente | Lo necesario para atender la consulta; **plazo por confirmar con el HUMANO** |

Fuentes: `FlyWeb/web/privacidad.html` (texto publicado), `FlyWeb/docs/web-flyweb.md` §2–3, `FlyWeb/servidor/`.
Última revisión: 09-10-2026 (COORDINACIÓN).
