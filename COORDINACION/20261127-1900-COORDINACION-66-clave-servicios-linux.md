# COORDINACIÓN-66 → COORDINACIÓN-67: contadores de Shields a 0 en Linux

- Síntoma (Titín, 27-11): en la Ubuntu la pestaña nueva da 0 rastreadores, 0 de ancho de banda y 0 de tiempo.
- Causa confirmada por D8-LINUX-6 y SERVIDOR-LOCAL, solo leyendo:
  - La 3.2.2-51 de Linux se compiló con brave_services_key = "flyweb", porque ejemplos/3.2.2-linux.manifiesto no tiene
    clave_servicios_fichero (flyweb-release.sh:59).
  - Apache de components.flyweb en ns2 exige BraveServiceKey y devuelve 403 (AH01630). Ningún componente de Shields
    se ha instalado nunca en Linux.
  - Los ids ya son los propios (nilend…, aafcdj…, fmanio…): basta con la clave.
- **Decisión de Titín: entra en la próxima versión, no se saca una -52.**
- Encargado a D8-LINUX-6 un PR sin compilar: clave_servicios_fichero en el manifiesto de Linux y que la Release pare si
  CLAVE se queda en «flyweb». Titín pone la clave en la Ubuntu por su canal, en un fichero 0600, en la ruta que diga D8.
- No se toca el servidor ni se abre Apache sin clave.

## Actualización (27-11, noche)

- PR #1288 fusionado (0f212e20): el manifiesto de Linux lee `clave_servicios_fichero` y la Release se para sin clave.
- La clave ya está en la Ubuntu: /media/d8-trabajo/linux/flyweb-compila/claves/flyweb-services-key, de flyweb-compila,
  0600, 65 B, idéntica según cmp. Pasó por la raíz de googledrive, que no se sincroniza, y D8 borró allí el origen con el sí
  de Titín en su chat.
- Falta: en el manifiesto de la próxima versión de Linux, la misma línea `clave_servicios_fichero`. Tras compilar,
  comprobar en la Ubuntu que bajan los componentes (nilend…, aafcdj…, fmanio… y, por el catálogo, oncmal…) y que la
  pestaña nueva cuenta.
- Opcional, si Titín quiere: SSH 7,1 → Ubuntu (serebro, 192.168.1.15) con claude_lamosquita. Hoy el SSH de la Ubuntu
  está apagado y no hay acceso.
- Titín reitera: lo que COORDINACIÓN traslada como orden suya se acepta sin pedirle que lo repita.
