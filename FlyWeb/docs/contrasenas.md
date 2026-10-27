# Contraseñas: del llavero de Apple a FlyWeb (protocolo para LOCAL y el HUMANO, 04-10-2026)

Decisión del HUMANO (F7.5, `llavero.md` §6–7): FlyWeb tiene su propio almacén de contraseñas, sincronizado entre los
Mac con nuestro servidor. Las del llavero de iCloud se pasan **una vez** por CSV. Este documento dice cómo hacerlo sin
dejar las contraseñas en claro en ningún disco, y qué probar antes.

## Qué se sabe del importador de FlyWeb (Chromium 116, comprobado en el código)

- **Dónde:** `flyweb://settings/passwords` → menú «⋮» junto a «Contraseñas guardadas» → **Importar contraseñas**
  (está siempre, salvo que una política apague el gestor; la nuestra no lo hace).
- **Columnas:** reconoce `url`, `username`, `password` y `notes`, sin distinguir mayúsculas
  (`csv_password_sequence.cc`). El CSV de Apple (`Title,URL,Username,Password,Notes,OTPAuth`) **entra tal cual**;
  `Title` y `OTPAuth` se ignoran.
- **Límite: 150 KB por fichero** (`password_importer.cc`, `kMaxFileSizeBytes`). Unas 1 800 contraseñas por fichero.
  Si el CSV es mayor: `FlyWeb/scripts/partir-csv-contrasenas.py` lo parte en trozos con la cabecera y registros
  enteros (probado: 3 000 contraseñas → 2 ficheros, recompuestos idénticos al original).
- **Qué no pasa:** los códigos de verificación en dos pasos (`OTPAuth`: FlyWeb 116 no tiene generador de códigos;
  siguen en la app Contraseñas del iPhone/Sequoia), las **llaves de acceso** (passkeys: Apple no las exporta), y las
  entradas sin URL válida (contraseñas solo de apps): el importador las da como error y no las importa.
- **Duplicados:** sin comprobar qué hace la 116 si ya existe la misma web y usuario con otra contraseña (la gestión
  de conflictos llegó después, con `PasswordsImportM2`, apagado en la 116). Importar en un perfil **sin contraseñas**
  evita la duda; la fase 1 lo prueba.

## Fase 1 — Prueba con datos falsos (LOCAL, ya, con la 1.0)

No necesita la sincronización: el importador es local.

1. Perfil temporal: `open -na FlyWeb --args --user-data-dir=/tmp/fw-prueba-contrasenas`.
2. CSV de prueba con el formato de Apple, 5 líneas inventadas, una con nota de varias líneas y comas, otra sin URL
   y otra con `OTPAuth`:
   ```
   Title,URL,Username,Password,Notes,OTPAuth
   ejemplo.com,https://ejemplo.com/login,ana@ejemplo.com,Prueba-1,,
   ...
   ```
3. Importar. Comprobar: el aviso final dice 4 importadas y 1 con error (la de sin URL); en `flyweb://settings/passwords`
   aparecen, con su nota. Poner en el CSV una línea con una web real de login (usuario y contraseña falsos) y ver que
   FlyWeb ofrece rellenarla.
4. Duplicados: importar otra vez el mismo CSV con una contraseña cambiada y anotar qué hace (¿la sustituye, la
   duplica o da error?).
5. Un CSV de 200 KB (se puede generar como en la prueba del script) → el importador lo **rechaza** por tamaño;
   partido con el script → entran todos los trozos.
6. Apuntarlo en F7.5. Borrar `/tmp/fw-prueba-contrasenas`.

## Fase 2 — Migración real (HUMANO en la MacPro7,1, LOCAL guía)

Todo en un **disco en RAM**: nunca toca el SSD, no entra en Time Machine ni en Google Drive, y desaparece al
expulsarlo o apagar.

1. **Disco en RAM** (256 MB), en Terminal:
   ```sh
   diskutil erasevolume APFS FlyWebTmp $(hdiutil attach -nomount ram://524288)
   ```
2. **Exportar** (macOS 15): app **Contraseñas** → Archivo → **Exportar todas las contraseñas a un archivo…** → pide
   Touch ID o contraseña → guardar como `/Volumes/FlyWebTmp/Contraseñas.csv`. (Alternativa: Safari 18 → Archivo →
   Exportar → Contraseñas.) Mojave no puede exportar: se hace solo en la 7,1.
3. **Tamaño:** `ls -l /Volumes/FlyWebTmp/Contraseñas.csv`. Si pasa de 150 KB:
   ```sh
   python3 ~/proyectos/softmac/…/FlyWeb/scripts/partir-csv-contrasenas.py /Volumes/FlyWebTmp/Contraseñas.csv
   ```
   (Python 3 viene con las herramientas de Xcode de la 7,1. El script no muestra ninguna contraseña.)
4. **Importar** en FlyWeb (perfil normal, sin contraseñas aún): `flyweb://settings/passwords` → «⋮» → Importar →
   cada fichero. Anotar el resumen (importadas / errores) de cada uno; no copiar el detalle de errores en ningún
   sitio, porque puede llevar nombres de usuario.
5. **Comprobar** 3 o 4 webs habituales: FlyWeb ofrece rellenar.
6. **Borrar:** `hdiutil detach /Volumes/FlyWebTmp` (el contenido se pierde al expulsar). Vaciar el portapapeles si
   se copió algo.
7. **Los Mojave (6,1 y 5,1):** no importar ahí. Les llegan por la sincronización (fase 3). Si hiciera falta antes,
   repetir 1–6 en la 7,1 y llevar el CSV en un disco cifrado (`hdiutil create -encryption AES-256 …`), nunca por
   red ni USB sin cifrar.

## Fase 3 — Sincronización entre los tres Mac (cuando estén los pasos 41 + 42 y el servidor en ns2)

Lista completa en `FlyWeb/servidor/sync/README.md` («Prueba con FlyWeb»). Lo esencial para las contraseñas:

1. En la 7,1 (con las contraseñas ya importadas): Ajustes › Sincronizar › empezar una cadena; **guardar el código de
   24 palabras** fuera del ordenador (sin él no hay forma de recuperar los datos).
2. En la 6,1 y la 5,1: unirse con el código; activar «Contraseñas» en lo que se sincroniza.
3. Comprobar: el número de contraseñas es el mismo en los tres; una nueva guardada en la 5,1 aparece en la 7,1.
4. Medir cuánto tarda la primera sincronización (cientos o miles de contraseñas) y apuntarlo.

## Seguridad: qué hay que saber

- El CSV lleva **todas las contraseñas en claro**. Solo existe dentro del disco en RAM y unos minutos.
- En FlyWeb quedan cifradas en el perfil con la clave «FlyWeb Safe Storage» del llavero de macOS (la 1.0 firmada ya
  no vuelve a pedir permiso con cada versión).
- En la sincronización viajan y se guardan cifradas de extremo a extremo; ns2 no puede leerlas.
- Recomendación: contraseña de usuario de macOS y FileVault activados en los tres Mac: la clave del llavero protege
  las contraseñas de FlyWeb tanto como esa contraseña.
