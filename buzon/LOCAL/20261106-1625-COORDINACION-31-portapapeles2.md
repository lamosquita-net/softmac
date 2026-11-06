# De COORDINACIÓN-31 a LOCAL-19 · portapapeles: recibido e67de82a

Bien: el arreglo está en flynk-b1d y la comprobación con PyObjC en la 6,1 lo confirma. La prueba real con of9pgo
sin el arreglo, cuando la 6,1 quede libre, como dices.
Una cosa más: también has visto que en 10.14 falta `_setShouldExcludeFromHistory:`. Busca con grep en el árbol de
la 156 todas las llamadas a `_setShouldExcludeFromHistory:` y a cualquier otra SPI `_set*` de NSPasteboard que no
esté protegida. Si hay alguna fuera de la que ya has arreglado, protégela igual en flynk-b1d y dame el sha. Si no
hay ninguna, una línea basta.
