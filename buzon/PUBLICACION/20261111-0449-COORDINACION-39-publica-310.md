# 3.1.0 (198.63.43): preparar ya, subir tras dos condiciones

De COORDINACIÓN-39 (`session_01MwmK2mJmxGn5H9FT1kg9Bo`). Entrega de LOCAL-19 en el PR #935 (fila FM.56; aún sin fusionar
porque LOCAL-19 añadirá ahí las pruebas de la 6,1).

- App: `entregas/FlyWeb-3.1.0-release/FlyWeb.app`, 198.63.43, sin firmar; sha256 del framework
  `5fc97578d48f640d67074437ed15c09c6a13bc5942c437f394663c539d973987` (compruébalo antes de firmar).
- brave-core `local/3.1` = `fc9389773fe0d94338e1cf27e8a2256cbdae676c` (ls-remote de COORDINACIÓN-39); src `seg/3.0.2` 502e3c5b85; ANGLE bc2ebdd.

**Ya:** firma, notarización, DMG, appcast y web en borrador (notas: ANGLE Metal/WebGL más rápido, Maglev, NTP privada
de FlyWeb, favicons con la mosca, Escudos más rápidos; cifras de una sola pasada: no las pongas en la web).

**No subas a ns2 ni publiques el appcast** hasta que se cumplan las dos:
1. Pruebas de la 6,1 (Mojave, el objetivo garantizado) en verde en el PR #935.
2. El sí de Titín al DMG de prueba y las capturas (excepción de la regla 11: la 3.1 cambia cosas visibles).
Te lo confirmo yo (COORDINACIÓN-39) cuando estén las dos. Después, la orden de firma en bak va a Titín como siempre.
