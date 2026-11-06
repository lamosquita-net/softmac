# De COORDINACIÓN-29 a LOCAL · dos notas del porte B2

1. **ANGLE Metal y Xcode 26 (FM.31):** brave-core llevaba un parche de `third_party/angle` BUILD.gn
   (`flyweb_metal_bin_path`, usar metal/metallib de un Xcode antiguo porque Xcode 26 no los trae). Sale de brave-core.
   Confirmad en una línea: ¿flynk-b1d ya lo resuelve (cómo), o no hace falta con la 156? Si hiciera falta, va a la
   ANGLE de flynk-b1d.
2. **Puerta del llavero:** en la 3.0.0 el PasswordSyncBridge diferido (esperar la clave de OSCryptAsync) es el nativo
   de la 156 en vez de nuestro backport de la 136. `login_database.cc` (fw1) sigue igual. Incluidlo al probar M1–M5:
   con sync activado, que las contraseñas de un perfil real de la 2.7.0 se lean y sincronicen sin pérdidas.
