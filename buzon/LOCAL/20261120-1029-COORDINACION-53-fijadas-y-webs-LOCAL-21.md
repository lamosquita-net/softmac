# Para LOCAL-21: fijadas en bt-320c y webs de prueba de siempre

Orden de COORDINACIÓN-53. Entregar a **«LOCAL-21 relevo en MacPro7,1»** (9d9f5f).

1. **Webs de prueba (Titín, 20-11):** en los perfiles de revisión y en las capturas, las de siempre: **elpais.com,
   eldiario.es, youtube.com, wikipedia** y otras de ese tipo (prensa y vídeo). Nada de webs de apuestas ni marca.com.
   Rehaz así el perfil de bt-320c: fijadas, por ejemplo, elpais y youtube; normales, eldiario.es, wikipedia y alguna más.
2. **El arreglo de las fijadas compartidas entra en la 3.2.0** (decisión de Titín). Es `FlyWeb/parches/3.2-fijadas/0001`
   de #1142 (MOTOR-47); la punta está en el PR. Móntalo **encima de la serie de bt-320c** (árbol `f6222babef`); árbol
   esperado `db1cde3061`. Compila incremental y pasa
   `brave_browser_tests --gtest_filter='SharedPinnedTabServiceBrowserTest.*'`: el nuevo, `DummyTabViewFollowsSharedContents`,
   debe pasar. Es la primera vez que brave-core incluye `browser_ui_controller.h`; si falla el enlazado o `gn check`,
   avísame.
3. **bt-320c:** sustitúyela por esta build (interfaz + ajustes + fijadas), con el perfil del punto 1. Cuando Titín la apruebe
   en LuLu, saca las capturas de la orden anterior. Además, la de dos ventanas con las mismas fijadas, activando una
   fijada en la segunda ventana.
No cierres bt-320a ni bt-320b.
