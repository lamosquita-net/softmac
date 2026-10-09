# Acceso de SERVIDOR a ns1 y ns2 (SERVIDOR en la MacPro7,1)

Decisión del HUMANO (05-10-2026): SERVIDOR pasa a una sesión local en la 7,1 con SSH a ns1 y ns2 y **sudo limitado**.
bak queda fuera: allí solo actúa el HUMANO. Lo monta **el HUMANO, a mano, una vez**; nada de esto se aplica desde el
repo. Carta: `docs/SERVIDOR.md` §8.

| Fichero | Destino | Qué es |
|---|---|---|
| `sudoers-ns2` | ns2 `/etc/sudoers.d/flyweb-servidor` (0440) | Lista cerrada de órdenes como root |
| `sudoers-ns1` | ns1 `/etc/sudoers.d/flyweb-servidor` (0440) | Solo la zona `lamosquita.net` |
| `flyweb-desplegar` | ns2 `/usr/local/sbin/flyweb-desplegar` (root 0755) | Única vía para poner ficheros como root: binarios de las releases, DMG y páginas de la web, y (modo `imagen`) los PNG privados de `img/` que no pueden estar en el repo público (≤ 20 KB y 400×100 px, desde `~servidor/privado/`), siempre con SHA-256 y registro en `/var/log/flyweb-deploy/` |

## Límite real (para el auditor)

- **Sin shell ni `sudo` total.** Leer registros: grupos `adm` y `systemd-journal`. Las claves de `/etc/apache2/flyweb-*-keys.conf` (root 0600) no son legibles.
- **`certbot` solo para listar** (`certificates`). Ampliar el certificado lo sigue haciendo el HUMANO: `certbot` admite `--deploy-hook`, que da root total.
- **Ojo: editar `lamosquita.conf` o una unidad de systemd equivale en la práctica a root.** Un `CustomLog "|orden"` en Apache o un `ExecStart` sin `User=` se ejecutan como root. Lo que acota esos dos casos no es `sudoers`. Son la carta (cambio por PR, comprobaciones y vuelta atrás), el registro de `sudo` (`log_subcmds`) y la revisión que hace SERVIDOR-NUBE. Si se quiere un límite técnico estricto, hay que quitar `FW_EDITAR` y que esos cambios los haga el HUMANO.

## Pasos (HUMANO)

**1. En la 7,1** (clave propia del agente; la privada no sale de la 7,1):
```sh
ssh-keygen -t ed25519 -C "servidor@macpro71" -f ~/.ssh/servidor_ed25519      # con frase de paso si se quiere: ssh-agent
cat ~/.ssh/servidor_ed25519.pub                                               # la pública: va a ns1 y ns2
```
En `~/.ssh/config`: `Host ns2` / `HostName ns2.lamosquita.net` / `User servidor` / `IdentityFile ~/.ssh/servidor_ed25519`
(y lo mismo con `ns1`).
**Hecho el 05-10-2026** (SERVIDOR-LOCAL): sin frase de paso (el agente la usa sin el HUMANO delante), huella
`SHA256:XEaTXR7hNvPaycMS30/3U2hwkVB8Xu3FpvQWkB+8Jxg`; `Host ns1` y `Host ns2` ya en `~/.ssh/config`.

**2. En ns2:**
```sh
# Primero, descargar los ficheros de un commit fijo de main (C = el último commit que los cambió):
C=3bcd074292ba73230bcfd9df1730b3000ed66bca
R=https://raw.githubusercontent.com/lamosquita-net/softmac/$C/FlyWeb/servidor/acceso
mkdir -p ~/flyweb-acceso && cd ~/flyweb-acceso && curl -fsSLO "$R/flyweb-desplegar" && curl -fsSLO "$R/sudoers-ns2"
sudo adduser --disabled-password --gecos "Agente SERVIDOR (FlyWeb)" servidor
sudo usermod -aG adm,systemd-journal servidor
sudo install -d -m 0700 -o servidor -g servidor ~servidor/.ssh
# Una línea en ~servidor/.ssh/authorized_keys (0600, de servidor):
#   no-agent-forwarding,no-X11-forwarding,no-port-forwarding ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL5nHaEAsnoKTAbyAZhVOGtqIbfWbZJlvcmQK9iOVNI7 servidor@macpro71
sudo visudo -cf sudoers-ns2 && sudo install -m 0440 -o root -g root sudoers-ns2 /etc/sudoers.d/flyweb-servidor
echo "4583f87e9b12df4f5c1e42f7f298f446b814db0537ea5ad2ce88c8633067556b  flyweb-desplegar" | sha256sum -c \
  && sudo install -m 0755 -o root -g root flyweb-desplegar /usr/local/sbin/flyweb-desplegar
```
Si `AllowUsers` o `AllowGroups` están en `sshd_config`, añadir `servidor`. fail2ban y CrowdSec no cambian: la oficina ya
está en su lista blanca por nombre (`lamosquita5g.duckdns.org`, que fail2ban vuelve a resolver en cada comprobación;
verificado en la auditoría de los servidores).

**Sin `from=`:** la IP de la 7,1 es dinámica (5G) y cambia a menudo. `from=` solo admite nombres si sshd hace búsqueda
inversa (`UseDNS yes`, apagado en Ubuntu), y la inversa de una IP de 5G es el nombre del operador, no el de DuckDNS, así
que un `from=` con IP fija dejaría fuera al agente y uno con nombre no casaría nunca. Lo que acota la clave: la privada
solo existe en la 7,1 (0600), las opciones de arriba y la lista cerrada de `sudoers`.

**3. En ns1:** igual que en ns2 (descargando `sudoers-ns1` del mismo `C`) (usuario, `.ssh`, la misma línea en `authorized_keys`), sin grupos extra. Cambia `<ZONA>`
en `sudoers-ns1` por la ruta real del fichero de zona, comprueba con `visudo -cf` e instala.

**4. Comprobar** (desde la 7,1):
```sh
ssh ns2 'id; sudo -l'                     # grupos adm y systemd-journal; solo las órdenes de sudoers-ns2
ssh ns2 'sudo apachectl configtest'       # Syntax OK
ssh ns2 'sudo -n true'                    # debe FALLAR (no hay sudo general)
ssh ns1 'sudo -l'
```

## Quitar el acceso (en cualquier momento)

En ns1 y ns2: `sudo rm /etc/sudoers.d/flyweb-servidor`, y `sudo deluser --remove-home servidor` (o vaciar su
`authorized_keys`). En ns2, además, `sudo rm /usr/local/sbin/flyweb-desplegar` si ya no se usa.
