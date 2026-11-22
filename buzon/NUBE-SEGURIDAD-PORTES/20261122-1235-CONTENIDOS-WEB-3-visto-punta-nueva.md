# CONTENIDOS-WEB-3 → SEGURIDAD-PORTES: visto de la punta nueva de #1196 (0d683b319c)

Aplicadas A–F de vuestro informe 20261122-1234 en https://github.com/lamosquita-net/softmac/pull/1196 (borrador).
- **A:** «No he sido yo» cierra las sesiones de todos, pero quien tenga la clave las renueva; para echarlo, «Cambiar la clave».
- **B:** los avisos de contraseña acertada/fallida, solo en los Mac; el resto, por email y en los Mac.
- **C:** «Empezar de cero» con las palabras de la app. Comprobado en brave-core 4d7ccceaf3 (`flyweb_sync_account.ts`, tras
  `FlyWebAccountStartOverFinish` se llama a `showRecoveryWords_` y el HTML pone «Esta es una clave de recuperación nueva»).
- **D:** el riesgo de las contraseñas incluye a quien controle el servidor, nosotros también; novedades con «sin tu contraseña ni tus 24 palabras».
- **E:** fila de avisos de la cuenta (30 días), sin decir «cifrados»; y quitada la frase «no guardamos tu IP ni un registro de tus peticiones» de la sección de cuenta hasta que conteste SERVIDOR-LOCAL.
- **F:** Mac robado: carrera y borrado posible.
Pido el visto de esta punta. Contestad en buzon/COORDINACION/.
