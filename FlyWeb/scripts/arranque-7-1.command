#!/bin/bash
# Arranque de los agentes locales tras reiniciar la 7,1: una pestaña de Terminal por agente, con `claude remote-control`.
# Doble clic. Con --prueba solo enseña lo que haría. Orden de COORDINACIÓN-21 (buzon/LOCAL/20261030-1520).
#
# Sesión que retoma cada pestaña: la de SESION_<AGENTE> en ~/.config/flyweb/arranque.conf; sin ella, abre una nueva. No usa `-c`
# porque retoma la última de la carpeta, y los agentes comparten carpeta. Comprobado solo con --prueba.
# Lo que no se puede automatizar: el primer mensaje de una sesión nueva (la orden no admite texto inicial, por eso cada
# pestaña escribe qué nota leer), y el modelo y el esfuerzo, que se eligen en la sesión.
# Ajustes, fuera del repositorio, en ~/.config/flyweb/arranque.conf:
#   CARPETA_LOCAL=/ruta  CARPETA_PUBLICACION=/ruta  CARPETA_SERVIDOR=/ruta  CARPETA_CARTERO=/ruta
#   SESION_LOCAL=<id>    SESION_PUBLICACION=<id>    SESION_SERVIDOR=<id>    SESION_CARTERO=<id>
PRUEBA=; [ "$1" = --prueba ] && PRUEBA=1
BASE=/Volumes/googledrive/clientes/software
CARPETA_LOCAL=$BASE; CARPETA_PUBLICACION=$BASE; CARPETA_SERVIDOR=$BASE; CARPETA_CARTERO=$BASE
[ -r ~/.config/flyweb/arranque.conf ] && . ~/.config/flyweb/arranque.conf

if [ ! -d "$BASE" ]; then
  echo "No está montada $BASE (la comparte la 6,1). Mónta la carpeta y vuelve a abrir esto."
  [ -n "$PRUEBA" ] || read -n1 -r -p "Pulsa una tecla para cerrar."
  exit 1
fi

pestana() {  # <nombre> <carpeta> <nota que leer al empezar> <id de sesión, si hay>
  local orden nueva="claude remote-control --name '$1' --permission-mode auto"
  [ -n "$4" ] && nueva="claude remote-control --session-id '$4'"
  orden="cd '$2' && echo 'Agente $1. Si la sesión es nueva, primer mensaje: lee $3 y sigue.' && $nueva"
  if [ -n "$PRUEBA" ]; then echo "$orden"; return; fi
  osascript - "$orden" <<'AS'
on run argv
  tell application "Terminal"
    activate
    do script (item 1 of argv)
  end tell
end run
AS
  sleep 1
}

pestana LOCAL "$CARPETA_LOCAL" 'FlyWeb/docs/relevo-local.md y la rama buzon (buzon/LOCAL)' "$SESION_LOCAL"
pestana PUBLICACION "$CARPETA_PUBLICACION" 'docs/ARRANQUE.md, fila PUBLICACIÓN' "$SESION_PUBLICACION"
pestana SERVIDOR-LOCAL "$CARPETA_SERVIDOR" 'docs/SERVIDOR.md §8 y FlyWeb/servidor/ESTADO.md' "$SESION_SERVIDOR"
pestana CARTERO-LOCAL "$CARPETA_CARTERO" 'buzon/README.md y docs/ARRANQUE.md, CARTERO-LOCAL' "$SESION_CARTERO"
