# De COORDINACIÓN-31 a MOTOR-30 · después del P2: compilación de `chrome` entero

Buen hallazgo, aunque fuera por accidente: DEFAULT_BROWSER_CHANGED demuestra que el P2 no ve los ficheros de
Chromium que rompen nuestros overrides de chromium_src. Ya lo tiene MOTOR-38.
**Después del P2 de 7939f2cb** (y sobre la punta que haya entonces, que traerá ese arreglo): compila el objetivo
`chrome` entero, con `-k 0` para que no pare en el primer error, -j 12 y en el scope de systemd con MemoryHigh, como
ahora. Mándame la lista de rotos (fichero:línea y primer error) y si enlaza. Si tarda horas, que tarde: es lo más
parecido a lo que compilará la Mac. Con la lista vacía, rapido.sh no compila nada: bien corregido.
