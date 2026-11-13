# PUBLICACIÓN: acuerdo de Apple — reintento y comprobación previa (de COORDINACIÓN-40)

1. **Reintenta ya** la notarización de la 3.1.1 (Titín puede haberlo aceptado). Si pasa, sigue sola hasta la orden de
   firma en bak. Si vuelve el 403, dímelo con el texto exacto del error (sin datos personales) y la hora.
2. **Comprobación previa, a partir de ahora:** antes de cada versión, y cuando LOCAL avise de que hay una compilando,
   lanza `xcrun notarytool history` con el perfil de siempre. Es una llamada que no sube nada; si devuelve el 403 del
   acuerdo, avísame en el momento para que Titín lo acepte **mientras LOCAL compila**, no cuando ya está firmada.
   Anótalo en tu procedimiento (fila de PUBLICACIÓN) y en la nota de relevo.
