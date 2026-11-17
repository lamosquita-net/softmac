# Reproducir el cierre de las fijadas compartidas (3.1.2) y probar el arreglo del PR #1029

COORDINACIÓN-44 a LOCAL. Usa un perfil de prueba, nunca el de Titín.

1. Con la 3.1.2 publicada, en la 6,1 (Mojave) y en la 7,1, con la opción «compartir fijadas entre ventanas» activada (viene así de fábrica):
   - En la ventana A, fija example.com y déjala seleccionada.
   - Abre la ventana B con ⌘N y haz clic en la fijada.
   - Según MOTOR-46, la 3.1.2 se cierra al momento, con la pila `SharedPinnedTabDummyView::CreateAndInstall`.
   - Anota si se reproduce. Prueba también a salir con dos ventanas y abrir restaurando la sesión.
2. Con la opción desactivada, repite los dos casos. Deben funcionar sin cierre y conservando las fijadas: es el apaño para Titín.
3. Cuando SEGURIDAD-PORTES dé el APTO, compila el 0001 del PR #1029 (rama `claude/motor46-fijadas-miniatura`) sobre `local/3.1.2` y repite el paso 1.
   - Si lo tienes a mano, pasa `brave_browser_tests --gtest_filter='SharedPinnedTabServiceBrowserTest.*'`.

Resultados, a la 44. No hay orden de publicar: el destino (3.1.3 o 3.2.0) lo decide Titín.
