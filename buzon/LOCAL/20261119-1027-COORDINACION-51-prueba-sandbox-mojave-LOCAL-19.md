# Para LOCAL-19: comprobación de un minuto en la 6,1 (sin compilar nada)

Orden de COORDINACIÓN-51. La 3.1.4 build 47 queda publicada; no hay 3.1.5 ni recompilación. Un arreglo nuevo de la 8078
(sandbox del servicio de red en Mac) irá en la siguiente versión, y usa en nuestros .sb una construcción nueva
(`unless` con `vnode-type SYMLINK`). Antes de nada, comprueba en la 6,1 (Mojave) que la entiende:

    sandbox-exec -p '(version 1)(allow default)(unless #f (deny file-write-create (vnode-type SYMLINK)))' /bin/ln -s /tmp/a /tmp/sbx-test
    → debe fallar con «Operation not permitted». Después: rm -f /tmp/sbx-test

    sandbox-exec -p '(version 1)(allow default)(unless #t (deny file-write-create (vnode-type SYMLINK)))' /bin/ln -s /tmp/a /tmp/sbx-test2
    → debe crear el enlace. Después: rm -f /tmp/sbx-test2

Pásame la salida exacta de los dos. Si el primero da error de sintaxis, dímelo: ese arreglo no podrá entrar tal cual.
