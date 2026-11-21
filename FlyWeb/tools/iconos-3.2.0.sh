#!/bin/bash
# Copyright (c) 2026 lamosquita.net. MIT license (softmac root).
#
# Regenera los iconos de la interfaz de la 3.2.0 (diseño de Titín) dentro de un
# checkout de brave-core, con svg2icon.py y una escala común (proporciones de
# Illustrator, calibradas con la flecha de atrás al tamaño actual: 12 dip).
#
# Uso: FlyWeb/tools/iconos-3.2.0.sh <ruta de brave-core> [escala]
#
# Qué icono de Chromium 156 se ve en cada botón: los «old» (los redondeados,
# features::IsRoundedIconsEnabled(), están apagados). Las sustituciones van en
# brave/vector_icons/<misma ruta>; aggregate_vector_icons.py las usa en lugar
# del original. Los que son genéricos de Chromium (el «+», el «⌄») o que Brave
# pinta con PNG (la carpeta) van como iconos propios en brave/app/vector_icons y
# se usan con un gancho, solo en ese botón.
set -euo pipefail

BRAVE="${1:?ruta de brave-core}"
ESCALA="${2:-2.2642}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
SVG="$AQUI/../branding/interfaz-3.2.0/iconos"
CONV="$AQUI/svg2icon.py"

icono() {  # svg rejilla destino [opciones]
  local svg="$1" rejilla="$2" destino="$3"
  shift 3
  mkdir -p "$(dirname "$BRAVE/$destino")"
  python3 -I "$CONV" "$SVG/$svg" --rejilla "$rejilla" --escala "$ESCALA" \
    -o "$BRAVE/$destino" "$@"
  echo "$svg -> $destino"
}

V=vector_icons
# Barra de herramientas (rejilla de 20).
icono ico-atras.svg 20 $V/components/vector_icons/back_arrow_chrome_refresh_old.icon
icono ico-adelante.svg 20 $V/components/vector_icons/forward_arrow_chrome_refresh_old.icon
icono ico-recargar.svg 20 $V/components/vector_icons/reload_chrome_refresh_old.icon
icono ico-detener.svg 20 $V/chrome/app/vector_icons/navigate_stop_chrome_refresh_old.icon
icono ico-estrella-vacia.svg 20 $V/components/omnibox/browser/vector_icons/star_chrome_refresh_old.icon
icono ico-estrella-llena.svg 20 $V/components/omnibox/browser/vector_icons/star_active_chrome_refresh_old.icon
icono ico-extensiones.svg 20 $V/components/vector_icons/extension_chrome_refresh_old.icon
icono ico-descargas.svg 20 $V/chrome/app/vector_icons/download_toolbar_button_chrome_refresh_old.icon
icono ico-menu-tres-puntos.svg 20 $V/chrome/app/vector_icons/browser_tools_chrome_refresh_old.icon
# Pestañas y barra de marcadores (rejilla de 16).
icono ico-cerrar-pestana.svg 16 $V/chrome/app/vector_icons/close_tab_chrome_refresh_old.icon
icono ico-mas-adelante.svg 16 $V/chrome/app/vector_icons/bookmarkbar_overflow_refresh_old.icon
# Iconos propios de FlyWeb, usados con un gancho en un solo botón.
icono ico-pestana-nueva.svg 16 app/vector_icons/flyweb_new_tab.icon
icono ico-buscar-pestanas.svg 16 app/vector_icons/flyweb_tab_search.icon
icono ico-carpeta-marcadores.svg 16 app/vector_icons/flyweb_bookmark_folder.icon --flips-in-rtl
icono ico-escudo.svg 20 app/vector_icons/flyweb_shields.icon
