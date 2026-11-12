# Sync (#905): decisiones de producto de Titín (12-11) — rehacer §5 y ajustar §6–§7

De COORDINACIÓN-39. Respuestas de Titín a §13 (recogidas por mí; en `docs/DIRECTIVAS.md`, «Sync con cuenta de la 3.2»):
1. 24 palabras: siguen siendo la recuperación (las genera el primer Mac, como hoy).
2. **Añadir un Mac: modelo de Firefox Accounts (protocolo «onepw» de Mozilla).** Email + (contraseña puesta o código
   visible) + código por email; **sin aprobación desde otro Mac**. La clave de la cadena va envuelta con una clave que
   sale de la contraseña con estiramiento en el cliente; el servidor no ve ni la contraseña ni la semilla. Titín acepta
   el riesgo: un robo de la base de datos permite atacar contraseñas débiles fuera de línea («es problema del usuario»).
   Rehacer §5 con este modelo y decir qué queda de §6 (los dos códigos de 16 caracteres desaparecen).
   Explica claramente: qué pasa si se olvida la contraseña (¿se recupera con las 24 palabras?), cambio de contraseña
   (re-envolver), y KDF (Argon2id/scrypt en el cliente + estiramiento en el servidor), con fuentes (documentación de
   onepw de Mozilla).
3. Demora para borrar / empezar de cero: **más de 7 días** (Titín no ha dado cifra; propón 14 y lo confirmo con él).
4. Cuenta bloqueada: como está (cadena o 24 palabras, nunca solo email).
5. Textos de «Quitar de la lista» y «Cambiar la clave de sincronización»: sí; Titín los estudiará.
6. **Tope de códigos: sin máximo diario.** Con verificación por email no hay cierre; en su lugar, **aviso por email de
   cada operación** (puede indicar cuenta comprometida). Mantén ritmo (un intento cada X s) y códigos largos contra la
   fuerza bruta en línea (C4), sin cierre.
7. RGPD: plazos sí (correo 7 días, `sync.db` 30 días); **copia en bak: sí, cifrada, 30 días**.
8. Obligaciones legales: Titín quiere **primero una propuesta nuestra** (registro de actividades, contrato de encargado
   con OVH, procedimiento de brechas). Plantillas con marcadores: **ningún dato personal de Titín en el repo** (nombre,
   NIF, domicilio van solo en su copia local).
9. «Unirse con un código»: no como opción aparte; el alta es email + código visible o contraseña + código por email.
10. **Identificación del Mac: modelo + nombre que elija el usuario** (lo ve solo el usuario; anótalo como dato personal
    en el registro de actividades).
11. Nombre de la página: «Cuenta y sincronización». 12. Remitente: `noreply@` del dominio de FlyWeb.
13. (Contraseña o código para tres operaciones): sin respuesta; con el modelo nuevo, revisa si sigue haciendo falta.
Mismo PR #905. Después irá a SEGURIDAD-PORTES-21 (cuarta pasada) y a Titín. Avisa a COORDINACIÓN-39 al terminar.
