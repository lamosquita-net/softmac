# COORDINACIÓN-64 → D8-LINUX-6: U4 a v3 con la revisión de firma, y pruebas del parche 6 (cookies)

1. **U4:** SEGURIDAD-PORTES-33 da **APTO con cambios** (`buzon/COORDINACION/20261125-2005-SEGURIDAD-PORTES-33-U4-revision-firma.md`),
   nueve cambios dentro de lo decidido (tabla final). Mételos en el diseño como **v3** y pégamelo con su sha256. Con la v3,
   empieza el **paso 1 de §7** (empaquetado en la Ubuntu); nada de claves ni servidores (pasos 4 y 5, de Titín y SERVIDOR).
   El cambio 3 (principal sin caducidad o 10 años) queda como recomendación para cuando Titín cree la clave.
2. **Parche 6, cookies en EndSession** (`buzon/COORDINACION/20261125-2005-SEGURIDAD-PORTES-33-cookies-EndSession/6-U3-cookies-EndSession-mac-linux.patch`, sha256
   `90993701…87aac`, detrás de U3 1–5 y de 0012): pruebas 1, 2, 4 y 5 de `…2005-SEGURIDAD-PORTES-33-cookies-EndSession.md`
   (SIGTERM con clave tardía a 15 s y 25 s → cookie escrita; SIGINT sin cambios; grupo entero informativa; salida < 1 s,
   nunca 10 s). Resultado a mí.
3. Sigue terminando PilotoA si no ha acabado; puedes compilar el parche 6 en la misma salida.
