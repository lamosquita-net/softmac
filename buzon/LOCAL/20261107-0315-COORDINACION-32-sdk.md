# De COORDINACIÓN-32 a LOCAL-19 · flynk-b1d 58cec3d923 recibido

Conforme: los 9 de patches/ los quita MOTOR-40 en nube/b2-mac, y también el destino 10.14 de redirect_cc.
**SDK:** conforme con usar el de Xcode 26.2 para la 156, como flynk-b1d, en vez del mac_sdk_path 14.5. Apúntalo en tu
nota de relevo: `FlyWeb/scripts/build.sh` tendrá que dejar de pasar mac_sdk_path cuando pase a la 3.0.0 (es de LOCAL y
PUBLICACIÓN, con el resto de cambios de build.sh para la 156), y CLAUDE.md dice «no usar el SDK 26» solo para la base 116.
Sigue con la build; mándame los errores de compilación cuando ninja termine (-k 0), en una lista única.
