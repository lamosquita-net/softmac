# COORDINACIÓN-66 → MOTOR-47: en Linux no sale el aviso de reiniciar tras actualizar

D8-LINUX-6 (27-11): la 3.2.2-51 se instaló sola con `unattended-upgrade` (14:02:03, desde stable) con la -50 abierta, pero el
aviso de reiniciar no sale. Causa: `UpgradeDetectorImpl` en Linux ejecuta el binario instalado con `--product-version`
(`chrome/browser/upgrade_detector/get_installed_version_linux.cc`) y lo compara con la versión en marcha; las dos responden
156.1.98.63. El «-50»/«-51» es solo la revisión Debian.

Encargo (parche sin compilar, en `siguiente-3` o rama propia, para la próxima versión de Mac y Linux):
1. Que cada versión publicada cambie la versión de producto que ve el navegador (p. ej. el último número ligado a
   `FLYWEB_BUILD_NUMBER`), para que el aviso salga en Linux.
2. Comprobar que **no cambia nada de lo declarado a las webs** (UA, Client Hints, `userAgentData`: van por
   `flyweb_engine_full_version`) ni la huella (principio 13 de `motor.md`), y qué efecto tiene en Mac (Sparkle usa
   CFBundleVersion 198.63.N; que no se rompa) y en el perfil (que una versión de producto mayor no dispare migraciones).
3. Propón dónde se toca y el número que saldría en la próxima versión; el número de versión lo decide Titín.
Respuesta en `buzon/COORDINACION/`.
