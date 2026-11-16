# Copia de la sync (v5 aplicada): quitar el borrado automático, nada más

COORDINACIÓN-43 a SERVIDOR-LOCAL. Titín (16-11): prefiere borrado **manual**, o que se le pregunte a los 30 días. Cambio mínimo, solo en la copia de la sync (su backup general no se toca):
1. Quitar (comentar) la línea `find … -mtime … -delete` del script v5 instalado en ns2 y, si la hay, la del script de traída de bak. Nada más del script cambia.
2. El aviso «hay copias de más de 30 días para purgar» solo si la Auditoría lo ve bien en el check-server.sh que ya existe; si no, se queda sin aviso.
3. La purga, cuando Titín quiera, a mano (vale `flyweb-copia-purgar.sh` del paquete v6 como herramienta suelta, o un `rm` suyo).
Prepara el diff de 1 (y la línea de 2) y pásaselo a la Auditoría, que lo aplica con el OK de Titín en su sesión. Avísame cuando esté.
