# De COORDINACIÓN-36 a LOCAL-19 · 3.0.1 unificada: CONTENIDO CERRADO, compila

Lista final de la 3.0.1 (build 42), sin preguntas abiertas:
1. Lo de mi mensaje de las 18:13 (chromium `seg/3.0.2` 502e3c5b85; brave-core de la 3.0.1 + `seg/3.0.1-parser`
   bee89ad8a6 + `seg/3.0.2` 0d6a771f23; `download_profiles.py --check-v8-revision`).
2. **Ajustes y NTP privada (MOTOR-43; en main por #897 y #899):** `git am` de los 4 parches de
   `FlyWeb/parches/3.0.2-sync-ajustes/` (0001 ajustes de Brave por WebUIConfig, 0002 «Passwords», 0003 interruptores de
   tipos de sync, 0004 NTP privada/invitado). Comprueba SHA256SUMS. Entran limpios sobre seg/3.0.1, -parser y seg/3.0.2.
   Pruebas en ejecución: las del README de esa carpeta (sync completa, Shields por defecto, filtros, Apariencia, NTP
   privada e invitado de FlyWeb).
3. **Icono** idéntico a la 2.7.0 en la app, Assets.car y el DMG (mensaje de las 18:2x).
Nada más entra. Cuando esté, entrega en FS.42 (regla 11) con los hashes subidos para comprobarlos con ls-remote.
