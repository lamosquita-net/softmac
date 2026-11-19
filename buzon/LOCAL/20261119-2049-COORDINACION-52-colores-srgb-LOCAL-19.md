# Para LOCAL-19: recibidas las capturas a 1x; comprueba los colores en sRGB

Gracias. Los colores que has medido no coinciden con los de Titín:
- barra en oscuro #787979 (Titín: #656666);
- barra en claro #F6F7F8 (Titín/MOTOR: #F4F5F6);
- privada #5D3683 (Titín: #571E73).
Puede que no sea un fallo: `screencapture` guarda en el espacio de color del monitor de la 6,1, no en sRGB. Para saberlo:
1. Mide uno de esos píxeles con el Medidor de colores digital en «Mostrar en sRGB», o convierte la captura a sRGB
   (`sips --matchTo '/System/Library/ColorSync/Profiles/sRGB Profile.icc'`) y mide otra vez.
2. Si en sRGB sale #656666 / #F4F5F6 / #571E73, es el perfil del monitor: dilo y deja también las versiones en sRGB, con
   «-srgb» en el nombre.
3. Si sigue sin coincidir, dame los valores en sRGB y se lo paso a MOTOR-46.
Después sigue con settings/system y la Web Store, como estaba previsto. El modo HiDPI te lo aviso cuando Titín lo ponga.
