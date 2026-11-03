# Tu propia clave de Google para BackupDrive

Decisión de Titín (03-11-2026): **cada usuario conecta BackupDrive con su propia clave de Google Cloud.** En el repositorio no
hay ni habrá ningún ID ni secreto de cliente; viven solo en `backupdrive.conf` de cada Mac (permisos 600).

## Por qué

- **Permiso de Drive completo = alcance restringido.** BackupDrive necesita leer y escribir cualquier fichero de las carpetas
  que sincroniza (`https://www.googleapis.com/auth/drive`). Google lo clasifica como *restricted scope*: una app que lo pida a
  usuarios ajenos con una clave común tiene que pasar la verificación de OAuth y una **evaluación de seguridad anual** de un
  auditor externo (CASA), con coste y plazos que no tienen sentido aquí. Fuentes:
  [alcances restringidos](https://support.google.com/cloud/answer/13464325),
  [política de datos de usuario de las APIs de Google](https://developers.google.com/terms/api-services-user-data-policy).
- **Sin verificar vale para uso personal:** una app en «producción» sin verificar funciona para **hasta 100 usuarios**, con un
  aviso de «Google no ha verificado esta app» que se acepta una vez por cuenta
  ([apps sin verificar](https://support.google.com/cloud/answer/7454865)). Titín, su familia y sus Mac caben de sobra.
- **En «producción», no en «pruebas»:** en «pruebas» el permiso caduca a los 7 días y habría que volver a conectar cada semana
  ([caducidad de los tokens](https://developers.google.com/identity/protocols/oauth2#expiration)).
- La guía de rclone (en el repo: `BackupDrive/rclone/docs/content/drive.md`, «Making your own client_id») confirma los
  pasos, la caducidad de 7 días en «pruebas» y el aviso al conectar con una app sin verificar. Los enlaces de Google de
  arriba no se han podido abrir desde la nube (dominio no permitido): son las páginas de referencia, por comprobar.
- **Cuota propia:** con la clave compartida de rclone, 40 ficheros tardaron 3 min 51 s (B.2): esa clave la usan miles de
  personas y Google la limita. La propia tiene su cuota entera
  ([rclone: hacer tu propio client_id](https://rclone.org/drive/#making-your-own-client-id)).

## Pasos en Google Cloud (una sola vez, en el navegador)

Con la cuenta de Google cuyo Drive vas a sincronizar. Los nombres de los menús son los de la consola en castellano
(noviembre de 2026); si alguno ha cambiado, el orden es el mismo.

1. Abre https://console.cloud.google.com/projectcreate, nombre del proyecto **BackupDrive**, «Crear».
2. Activa la API de Drive: https://console.cloud.google.com/apis/library/drive.googleapis.com → comprueba arriba que el
   proyecto es BackupDrive → «Habilitar».
3. Pantalla de consentimiento: https://console.cloud.google.com/auth/overview → «Empezar».
   - Información de la aplicación: nombre **BackupDrive**, correo de asistencia: el tuyo. Siguiente.
   - Público: **Externo**. Siguiente.
   - Información de contacto: tu correo. Siguiente, acepta la política y «Crear».
   - Acceso a datos: https://console.cloud.google.com/auth/scopes → «Añadir o quitar permisos» → en «Añadir manualmente»
     pega `https://www.googleapis.com/auth/drive` → «Añadir a la tabla» → «Actualizar» → «Guardar».
4. Publícala: https://console.cloud.google.com/auth/audience → «Publicar aplicación» → Confirmar. Debe quedar
   **«En producción»**. Si ofrece «Preparar para verificación», **no**: no hace falta para uso personal.
5. Crea la clave: https://console.cloud.google.com/auth/clients → «Crear cliente» → Tipo de aplicación **«App de escritorio»**,
   nombre **BackupDrive Mac** → «Crear». Copia el **ID de cliente** (termina en `.apps.googleusercontent.com`) y el **secreto**
   (o «Descargar JSON» y guárdalo en tu gestor de contraseñas). La misma clave sirve para tus otros Mac y para tu familia.

## En el Mac (terminal nuevo)

Hace falta BackupDrive instalado con la versión que trae `backupdrive-ctl.sh` (artefacto `BackupDrive-mojave` de `main`
desde el PR #704). Sustituye `PEGA-AQUI-TU-ID` por tu ID de cliente; el secreto lo pregunta sin que se vea al escribirlo:

```sh
backupdrive-ctl.sh connect --client-id 'PEGA-AQUI-TU-ID.apps.googleusercontent.com'
backupdrive-ctl.sh check
```

Se abre el navegador: elige la **misma cuenta de Google** que ya usabas (si no, las carpetas configuradas apuntarían a otro
Drive) → «Google no ha verificado esta app» → «Configuración avanzada» → «Ir a BackupDrive (no seguro)» → marca el acceso a
Google Drive → «Continuar». La terminal dice `"ok":true` y el espacio de tu Drive.

- Si ya había una cuenta `gdrive` (la de la prueba B.2, con la clave compartida), se **sustituye** y las carpetas configuradas
  siguen igual, sin volver a hacer la primera sincronización. Si cierras el navegador sin autorizar, no se cambia nada.
- **Si se filtra el secreto:** en https://console.cloud.google.com/auth/clients borra el cliente, crea otro y vuelve a conectar.
- Para quitar el acceso a BackupDrive: https://myaccount.google.com/connections.
