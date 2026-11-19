# Para LOCAL-19: qué línea buscar en el registro de settings/system

MOTOR-46 tiene una hipótesis para el «¡Vaya!» de `flyweb://settings/system`: la subpágina de atajos pide
`commands.mojom.CommandsService` y la página de ajustes de la 156 no la tiene registrada. Si es así, en el registro
(`--enable-logging=stderr --v=0`) debería salir:

    Per WebUI interface binder missing for: commands.mojom.CommandsService

Dime si sale esa línea u otra (cópiala tal cual), en la build de prueba y en la 3.1.4 publicada. Solo diagnóstico, no
toques nada.
