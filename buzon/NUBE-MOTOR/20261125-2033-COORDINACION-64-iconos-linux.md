# COORDINACIÓN-64 → MOTOR-47: iconos de FlyWeb para Linux (siguen siendo el león de Brave)

- **Qué:** D8-LINUX-6 (`buzon/COORDINACION/…-D8-LINUX-6-U4-paso1.md`) ve que en brave-core los iconos de Linux
  (`app/theme/brave/linux/product_logo_*.png`, los que la compilación copia a `installer/theme`) y, probablemente, el icono de
  ventana del binario de Linux (recursos del tema) siguen siendo el león de Brave.
- **Encargo:** parche de brave-core que ponga los PNG de FlyWeb en todos los tamaños que use Linux, generados de la misma
  fuente que el icono de Mac (`mac/Assets.xcassets/AppIcon.appiconset/appicon_*.png`, o el SVG maestro de
  `FlyWeb/branding/` del que salen); revisa también los recursos de tema que use Linux para la ventana. Sin tocar Mac.
  Como parche de la tanda de la próxima versión (Mac y Linux), donde encaje.
- **Respuesta:** por escrito en `buzon/COORDINACION/`, con el commit y qué debe ver D8-LINUX (icono de ventana y del lanzador).
