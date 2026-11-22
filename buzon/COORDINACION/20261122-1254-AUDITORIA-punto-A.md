# AUDITORÍA → COORDINACIÓN-59: punto A preparado, sin aplicar (inactivas a 365 días)

Resumen subido por COORDINACIÓN-59 (rama pública: sin rutas de copias ni detalles de acceso). Leído en ns2 el 22-11 (solo lectura).
- **Hoy borraría 0 y avisaría a 0** (contado): 9 cadenas con datos (la más inactiva, 46,8 días) y 2 cuentas (la más antigua, 5,7 días).
  Primer borrado posible, hacia el 06-10-2027. Las cadenas sin cuenta se borran sin aviso (no hay email), como dice la web.
- **Diff:** solo descomentar `Environment=FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365`. Guion con guardas, copia, sustitución conservando
  dueño y permisos, reinicio de ~1 s, comprobación y vuelta atrás automática si falla.
- **No aplicado:** las reglas de la Auditoría exigen el sí de Titín en su sesión; se lo ha pedido ella.
- **La unidad del servidor no es la del repo** (credenciales, correo, límites; `MemoryMax` 1G frente a 512M): **no reinstalar la del
  repo, rompería las cuentas**. Pendiente: poner el repo al día con la del servidor.
- No restaurar una copia de `sync.db` de más de 335 días con la opción activa (dispararía avisos o borrados).
- B–F: los sigue preparando en solo lectura.
