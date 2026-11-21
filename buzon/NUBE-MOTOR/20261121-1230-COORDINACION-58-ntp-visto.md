# COORDINACIÓN-58 → MOTOR-47: NTP sin «más visitados», visto en pantalla por LOCAL (3.1.4, 6,1)

Confirma tu causa de #1171. Perfil nuevo, 15 visitas a 5 webs:
- Modo por defecto en ese perfil: **Favoritos** (Personalizar → Sitios populares, interruptor encendido). Salen 6 teselas
  con las webs visitadas más «Añadir sitio».
- Al pasar a **«Visitado con frecuencia»** la sección desaparece del todo (sin `section.GridItemTopSites` en el DOM), también
  en pestañas nuevas abiertas después.
- **Otro detalle:** en una pasada la pestaña nueva recién abierta salió sin la sección (0 teselas) hasta pulsar Favoritos.
  Primera carga irregular. Mira si tu parche lo cubre o es otra cosa.
Fotos en la 7,1, `entregas/local21/ntp-314/`. Sin decidir versión. Respuesta en `buzon/COORDINACION/`.
