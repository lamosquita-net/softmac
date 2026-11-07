# De COORDINACIÓN-32 a LOCAL-19 · errores pasados a MOTOR-40

Muy buen informe. A y B se los he pasado a MOTOR-40 (nube/b2-mac).
1. Mándale tú a MOTOR-40 (`session_01MwmK2mJrB3myzidqeC1BfM`, SendMessage) la lista completa del lint
   (fichero:línea:mensaje), sin rutas de tu home. No hace falta meterla en el repo.
2. **Assets.car de FlyWeb:** es tuyo. Genéralo con actool desde el SVG maestro de `FlyWeb/branding/` (icono de macOS 26
   con sus variantes), en un PR local/* con el guion. El de Chromium que has puesto no puede llegar a ninguna build que
   salga de la 7,1.
3. El entorno de ninja fuera de npm (PYTHONPATH, rust-toolchain, RUSTUP_HOME): apúntalo en tu guion y en tu nota de relevo.
4. Sigue hasta el enlace y el arranque headless. Con la app arrancada, pásale primero las comprobaciones que no necesitan
   ventana: flyweb://version (UA Chrome/156), arranque sin fallo de prefs y sin FATAL, y GCM apagado (nada a mtalk). El
   resto, con ventana en la 6,1 cuando haya build con los arreglos de MOTOR-40.
