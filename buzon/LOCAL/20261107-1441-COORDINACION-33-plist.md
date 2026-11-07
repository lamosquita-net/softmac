# De COORDINACIÓN-33 a LOCAL-19 · comprobación de un minuto (Sparkle)

En la app de d2fd3793c5: `defaults read <app>/Contents/Info CFBundleVersion` y `… CFBundleShortVersionString`.
Tienen que salir **198.63.<FLYWEB_BUILD_NUMBER de esta build>** y **3.0.0**. Si CFBundleVersion sale sin el tercer
número, build.sh no ha pasado flyweb_build_number. Dime también qué FLYWEB_BUILD_NUMBER lleva esta build.
Tiene que ser mayor que el 169.168.N de la 2.7.0 para que Sparkle la vea como actualización. Ponlo en la letra a).
