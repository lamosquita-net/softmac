#!/usr/bin/env python3
# U4, paso 1 de §7 (U4-diseno.md v3): el .deb de FlyWeb para Linux a partir de una salida ya compilada.
#
# En vez del instalador de upstream (chrome/installer/linux), que habría que parchear en cuatro sitios (nombre
# «-stable», cron y repositorio de Google, versión de Chromium, nombre de salida fijo en BUILD.gn), se usa de upstream
# solo lo que vale la pena: las dependencias que calcula sobre el sysroot (deb_common.deps, objetivo
# //chrome/installer/linux:merge_deb_dependencies) y sus plantillas de envoltorio, lanzador y AppArmor. El resto lo pone
# este guion con rutas y nombres de FlyWeb. Ni firma ni sube nada.
#
# Uso: empaquetar-deb.py --out <src/out/Release-…> --version 3.2.2 --build 50 --salida <dir>
#                        [--llavero flyweb.gpg | --prueba]
#   --llavero  clave pública del repositorio (la de servidor/apt/clave-publica.asc, en binario). Sin ella el paquete no
#              sirve para publicar: solo con --prueba, y entonces lleva el .sources pero no la clave (apt update fallará
#              en ese repositorio, a propósito).
import argparse
import hashlib
import os
import pathlib
import re
import shutil
import string
import subprocess
import sys

PAQUETE = "flyweb"
PROGNAME = "flyweb"
INSTALLDIR = "/opt/lamosquita/flyweb"
RDN = "net.lamosquita.flyweb"
MENUNAME = "FlyWeb"
MANTENEDOR = "FlyWeb <admin@lamosquita.net>"  # contacto público de registro-tratamientos.md:7 (decisión de Titín, 25-11)
WEB = "https://flyweb.lamosquita.net/"
# Textos provisionales [S]: los fija Titín (o web-auto) antes de publicar.
DESC_CORTA = "FlyWeb web browser"
DESC_LARGA = "FlyWeb, the web browser from lamosquita, based on Chromium and Brave."
REPO = "https://apt.flyweb.lamosquita.net"
PATRON_UU = "origin=FlyWeb,label=FlyWeb,suite=stable,site=apt.flyweb.lamosquita.net"
# Dependencias que no se ponen (decisión 5 de Titín, #1238/#1239): upstream las quiere para Breakpad.
FUERA = re.compile(r"^(wget|libcurl)")
PROHIBIDO = re.compile(rb"google|brave\.com|dl\.google", re.I)


class Plantilla(string.Template):
    delimiter = "@@"


def falla(msg):
    sys.exit(f"empaquetar-deb: {msg}")


def plantilla(origen, destino, vars_):
    texto = Plantilla(origen.read_text()).substitute(vars_)
    if "@@" in texto:
        falla(f"quedan variables sin poner en {destino}")
    destino.write_text(texto)


def copia(origen, destino, modo):
    if not origen.exists():
        falla(f"falta {origen}")
    destino.parent.mkdir(parents=True, exist_ok=True)
    if origen.is_dir():
        shutil.copytree(origen, destino)
        for r, ds, fs in os.walk(destino):
            os.chmod(r, 0o755)
            for f in fs:
                os.chmod(os.path.join(r, f), 0o644)
    else:
        shutil.copyfile(origen, destino)
        os.chmod(destino, modo)


def main():
    a = argparse.ArgumentParser()
    a.add_argument("--out", required=True, type=pathlib.Path)
    a.add_argument("--version", required=True)
    a.add_argument("--build", required=True, type=int)
    a.add_argument("--salida", required=True, type=pathlib.Path)
    a.add_argument("--iconos", type=pathlib.Path,
                   help="carpeta theme de brave-core (por omisión, la de src/brave/app/theme)")
    g = a.add_mutually_exclusive_group(required=True)
    g.add_argument("--llavero", type=pathlib.Path)
    g.add_argument("--prueba", action="store_true")
    args = a.parse_args()

    if not re.fullmatch(r"\d+\.\d+\.\d+", args.version):
        falla("--version tiene que ser X.Y.Z (flyweb_version)")
    version = f"{args.version}-{args.build}"
    out = args.out.resolve()
    src = out.parent.parent
    # Los iconos de Linux de brave-core (FlyWeb/parches/3.2-iconos-linux): los mismos tamaños que instala upstream.
    tema = args.iconos or src / "brave/app/theme"
    iconos = {n: tema / "brave/linux" / f"product_logo_{n}.png" for n in (24, 48, 64, 128, 256)}
    iconos |= {n: tema / "default_100_percent/brave/linux" / f"product_logo_{n}.png" for n in (16, 32)}
    comun = out / "installer/common"

    # Las dependencias de upstream (dpkg-shlibdeps sobre el sysroot más additional_deps), sin wget ni libcurl.
    deps_f = out / "deb_common.deps"
    if not deps_f.exists():
        falla(f"falta {deps_f}: compila antes //chrome/installer/linux:merge_deb_dependencies")
    deps = [d.strip() for d in deps_f.read_text().splitlines() if d.strip()]
    quitadas = [d for d in deps if FUERA.match(d)]
    deps = [d for d in deps if not FUERA.match(d)]

    stage = args.salida / f"deb-{PAQUETE}-{version}"
    if stage.exists():
        falla(f"{stage} ya existe; usa otra --salida (no se borra nada)")
    os.umask(0o022)
    inst = stage / INSTALLDIR.lstrip("/")
    inst.mkdir(parents=True)

    # Binarios (los .stripped que deja la compilación oficial) y recursos. use_static_angle es verdad en Linux: sin
    # libEGL ni libGLESv2, como upstream.
    binarios = {
        "brave.stripped": PROGNAME,
        "chrome_crashpad_handler.stripped": "chrome_crashpad_handler",
        "libvk_swiftshader.so.stripped": "libvk_swiftshader.so",
        "libvulkan.so.1.stripped": "libvulkan.so.1",
        "libqt5_shim.so.stripped": "libqt5_shim.so",
        "libqt6_shim.so.stripped": "libqt6_shim.so",
    }
    for o, d in binarios.items():
        copia(out / o, inst / d, 0o755)
    copia(out / "brave_sandbox.stripped", inst / "chrome-sandbox", 0o4755)
    recursos = ["resources.pak", "chrome_100_percent.pak", "chrome_200_percent.pak", "brave_resources.pak",
                "brave_100_percent.pak", "brave_200_percent.pak", "icudtl.dat", "v8_context_snapshot.bin",
                "vk_swiftshader_icd.json", "MEIPreload/manifest.json", "MEIPreload/preloaded_data.pb"]
    for r in recursos:
        copia(out / r, inst / r, 0o644)
    for pak in sorted((out / "locales").glob("*.pak")):
        copia(pak, inst / "locales" / pak.name, 0o644)
    copia(out / "resources/brave_extension/_locales", inst / "resources/brave_extension/_locales", 0o644)
    copia(comun / "LICENSE", inst / "LICENSE", 0o644)

    vars_ = {"PROGNAME": PROGNAME, "channel": "stable", "INSTALLDIR": INSTALLDIR, "usr_bin_symlink_name": PAQUETE,
             "MENUNAME": MENUNAME, "desktop_exec": f"/usr/bin/{PAQUETE}", "desktop_icon": PAQUETE,
             "startup_wm_class": PAQUETE, "uri_scheme": "", "extra_desktop_entries": ""}
    plantilla(comun / "wrapper", inst / f"{PROGNAME}-wrapper", vars_)
    envoltorio = inst / f"{PROGNAME}-wrapper"  # upstream marca una variable de GNOME con el nombre de Chrome
    envoltorio.write_text(envoltorio.read_text().replace("SET_BY_GOOGLE_CHROME", "SET_BY_FLYWEB"))
    os.chmod(inst / f"{PROGNAME}-wrapper", 0o755)

    usr = stage / "usr"
    (usr / "bin").mkdir(parents=True)
    os.symlink(f"{INSTALLDIR}/{PROGNAME}-wrapper", usr / "bin" / PAQUETE)
    (usr / "share/applications").mkdir(parents=True)
    plantilla(comun / "desktop.template", usr / f"share/applications/{PAQUETE}.desktop", vars_)
    for n, f in sorted(iconos.items()):
        copia(f, usr / f"share/icons/hicolor/{n}x{n}/apps/{PAQUETE}.png", 0o644)
    meta = usr / f"share/metainfo/{RDN}.metainfo.xml"
    meta.parent.mkdir(parents=True)
    meta.write_text(f"""<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>{RDN}</id>
  <launchable type="desktop-id">{PAQUETE}.desktop</launchable>
  <name>{MENUNAME}</name>
  <summary>{DESC_CORTA.capitalize()}</summary>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>MPL-2.0</project_license>
  <url type="homepage">{WEB}</url>
  <description><p>{DESC_LARGA}</p></description>
  <releases><release version="{version}"/></releases>
</component>
""")
    man = (comun / "manpage.1.in").read_text().replace("@@MENUNAME@@", MENUNAME).replace("@@PACKAGE@@", PAQUETE)
    (usr / "share/man/man1").mkdir(parents=True)
    subprocess.run(["gzip", "-9n"], input=man.encode(), stdout=open(usr / f"share/man/man1/{PAQUETE}.1.gz", "wb"),
                   check=True)
    doc = usr / f"share/doc/{PAQUETE}"
    doc.mkdir(parents=True)
    shutil.copyfile(comun / "LICENSE", doc / "copyright")
    subprocess.run(["gzip", "-9n"], input=f"{PAQUETE} ({version}) stable; urgency=medium\n\n  * FlyWeb {version}.\n\n"
                   f" -- {MANTENEDOR}  {subprocess.check_output(['date', '-R'], text=True).strip()}\n".encode(),
                   stdout=open(doc / "changelog.gz", "wb"), check=True)

    # /etc: AppArmor, el repositorio y el origen de unattended-upgrades (conffiles); la clave, fuera de /etc.
    etc = stage / "etc"
    (etc / "apparmor.d").mkdir(parents=True)
    plantilla(comun / "apparmor.template", etc / f"apparmor.d/{PAQUETE}", vars_)
    (etc / "apt/sources.list.d").mkdir(parents=True)
    (etc / f"apt/sources.list.d/{PAQUETE}.sources").write_text(
        f"Types: deb\nURIs: {REPO}\nSuites: stable\nComponents: main\nArchitectures: amd64\n"
        f"Signed-By: /usr/share/keyrings/{PAQUETE}.gpg\n")
    (etc / "apt/apt.conf.d").mkdir(parents=True)
    (etc / f"apt/apt.conf.d/52{PAQUETE}-unattended-upgrades").write_text(
        "// FlyWeb: instalar sus actualizaciones sin preguntar. Para no hacerlo, borra o comenta esta línea.\n"
        f'Unattended-Upgrade::Origins-Pattern:: "{PATRON_UU}";\n')
    if args.llavero:
        copia(args.llavero, usr / f"share/keyrings/{PAQUETE}.gpg", 0o644)

    deb = stage / "DEBIAN"
    deb.mkdir()
    conffiles = [f"/etc/apparmor.d/{PAQUETE}", f"/etc/apt/sources.list.d/{PAQUETE}.sources",
                 f"/etc/apt/apt.conf.d/52{PAQUETE}-unattended-upgrades"]
    (deb / "conffiles").write_text("".join(c + "\n" for c in conffiles))
    tam = sum(f.stat().st_size for f in stage.rglob("*") if f.is_file() and not f.is_symlink()) // 1024
    (deb / "control").write_text(
        f"Package: {PAQUETE}\nVersion: {version}\nArchitecture: amd64\nMaintainer: {MANTENEDOR}\n"
        f"Installed-Size: {tam}\nPre-Depends: dpkg (>= 1.14.0)\nDepends: {', '.join(deps)}\n"
        f"Provides: www-browser\nSection: web\nPriority: optional\nHomepage: {WEB}\n"
        f"Description: {DESC_CORTA}\n {DESC_LARGA}\n")
    guion = {
        "postinst": f"""#!/bin/sh
set -e
if [ "$1" = configure ]; then
  update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/{PAQUETE} 200
  update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/{PAQUETE} 200
  # Como upstream: el perfil solo se carga donde AppArmor entiende abi 4.0 (userns).
  if [ -e /etc/apparmor.d/abi/4.0 ] && command -v apparmor_parser > /dev/null && aa-enabled --quiet 2> /dev/null; then
    apparmor_parser -r -T -W /etc/apparmor.d/{PAQUETE} || true
  fi
  command -v update-desktop-database > /dev/null && update-desktop-database -q || true
fi
""",
        "prerm": f"""#!/bin/sh
set -e
if [ "$1" = remove ] || [ "$1" = deconfigure ]; then
  update-alternatives --remove x-www-browser /usr/bin/{PAQUETE}
  update-alternatives --remove gnome-www-browser /usr/bin/{PAQUETE}
fi
# El perfil de AppArmor se descarga aquí, con el fichero aún en su sitio: al llegar al postrm de purge, dpkg ya ha borrado
# /etc/apparmor.d/{PAQUETE} y apparmor_parser -R no tiene qué leer (el perfil se quedaba en el núcleo hasta reiniciar).
if [ "$1" = remove ] && [ -e /etc/apparmor.d/{PAQUETE} ] && command -v apparmor_parser > /dev/null; then
  apparmor_parser -R /etc/apparmor.d/{PAQUETE} 2> /dev/null || true
fi
""",
        "postrm": f"""#!/bin/sh
set -e
# Por si quedó cargado (p. ej. quitado con un prerm anterior): se descarga por nombre, sin el fichero.
if [ "$1" = purge ] && [ -w /sys/kernel/security/apparmor/.remove ]; then
  {{ printf %s {PAQUETE} > /sys/kernel/security/apparmor/.remove; }} 2> /dev/null || true
fi
""",
    }
    for n, t in guion.items():
        (deb / n).write_text(t)
        os.chmod(deb / n, 0o755)

    # Comprobaciones antes de empaquetar (las de «empaquetar» en el guion único, §2.1).
    for n in ["control", "postinst", "prerm", "postrm"]:
        if PROHIBIDO.search((deb / n).read_bytes()):
            falla(f"«google» o «brave.com» en DEBIAN/{n}")
    for f in list(etc.rglob("*")) + [usr / f"share/applications/{PAQUETE}.desktop", meta, inst / f"{PROGNAME}-wrapper"]:
        if f.is_file() and PROHIBIDO.search(f.read_bytes()):
            falla(f"«google» o «brave.com» en {f.relative_to(stage)}")
    if re.search(r"\b(wget|libcurl)", (deb / "control").read_text()):
        falla("wget o libcurl en Depends")
    if os.stat(inst / "chrome-sandbox").st_mode & 0o7777 != 0o4755:
        falla("chrome-sandbox sin 4755")

    nombre = args.salida / f"{PAQUETE}_{version}_amd64.deb"
    if nombre.exists():
        falla(f"{nombre} ya existe")
    subprocess.run(["dpkg-deb", "--root-owner-group", "-Zxz", "-z9", "--build", str(stage), str(nombre)], check=True)
    suma = hashlib.sha256(nombre.read_bytes()).hexdigest()
    with open(args.salida / "SHA256SUMS", "a") as f:
        f.write(f"{suma}  {nombre.name}\n")
    print(f"{nombre}\nsha256 {suma}\nquitadas de Depends: {', '.join(quitadas) or 'ninguna'}"
          f"\nllavero: {'sí' if args.llavero else 'NO (--prueba: no sirve para publicar)'}")


if __name__ == "__main__":
    main()
