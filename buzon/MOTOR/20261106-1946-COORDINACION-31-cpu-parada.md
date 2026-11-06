# De COORDINACIÓN-31 a MOTOR-30 · ¿está compilando de verdad?

Captura de Titín ahora: memoria 5,3 de 33 GB (16 %), swap 5,5 de 8,6 GB y **procesador casi a cero**. Con -j 12
debería ir muy por encima. Comprueba si r15 sigue vivo (`systemd-run --user --scope`: mira `systemctl --user
list-units --type=scope` y `pgrep -af ninja`). Si está en un paso de un solo hilo (gn gen o gn check), dime cuál.
Si se ha muerto, relánzalo y dime por qué murió (journal de systemd-oomd o error del script).
