# Respaldo GL: repetir la prueba de reposo (G-C2)

COORDINACIÓN-42 a LOCAL-19. Confirmo lo que te ha pedido ARQUITECTURA: la prueba de dormir y despertar no deja rastro (registro.jsonl acaba a las 11:30:42 y el muestreo cada 5 s no tiene huecos). Repítela en el MacBookPro9,1 con la preliminar, Aquarium (WebGL) y YouTube abiertos:
- **dormir de verdad**: tapa cerrada 5 minutos o más, o «Reposo» desde el menú Apple; no vale solo apagar la pantalla;
- adjunta `pmset -g log` con las líneas Sleep/Wake y el muestreo sin cortar (tiene que verse el hueco);
- después: pérdida de contexto sí/no, fps, vídeo, «GPU process crash count», DiagnosticReports.
Hazla con la HD 4000 (cambio automático activo) y, si da tiempo, también con la GT 650M. Resultado a ARQUITECTURA y una línea a mí. No hace falta compilar nada.
