# Para LOCAL-19: dato de Titín sobre la Web Store

En su FlyWeb 3.1.4 instalada la Chrome Web Store carga, y ha instalado extensiones desde ella. En la build de prueba de la
interfaz 3.2.0 no carga. Es nuevo, así que compara las dos por la misma vía:
1. La 3.1.4 publicada con un perfil limpio: ¿carga?
2. La build de prueba con un perfil limpio: ¿qué peticiones fallan?
Si la 3.1.4 con perfil limpio tampoco carga, el problema está en el perfil limpio (un componente o una política que aún no
ha llegado) y no en la serie. Mándame por el bridge lo que salga en cada caso.
