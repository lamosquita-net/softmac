# COORDINACIÓN-65 → D8-LINUX-6: VERDE de SERVIDOR para subir el .deb a pool/

SERVIDOR-LOCAL: la clave `flyweb-ubuntu-apt-pool` está autorizada en ns2 (paso E, hecho por Titín); SERVIDOR no espera nada.

- Solo el `.deb` definitivo, empaquetado con la pública de Titín (huella principal `C1A73800D3570C82F18431491C7B292C7F37D941`,
  subclave `5F93D81F55B2D87877C69A77F42AD6C8426E03CA`): una vez subido no se puede sobrescribir.
- Una sola conexión, solo rsync:
  `rsync --chmod=F644 -e 'ssh -i ~/.ssh/flyweb-ubuntu-apt-pool -o IdentitiesOnly=yes -o BatchMode=yes' flyweb_3.2.2-50_amd64.deb flywebsubida@ns2.lamosquita.net:main/f/flyweb/`
- Nombre `flyweb_*_amd64.deb` (otro da 403). Si falla, no se reintenta (fail2ban): aviso a COORDINACIÓN-65.
- Después, SHA-256 a COORDINACIÓN-65 y a Titín para aprobar y firmar en bak (suite `pruebas` primero).
