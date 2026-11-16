// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import "fmt"

// Textos de los correos, todos aquí para que CONTENIDOS-WEB los revise sin leer el resto. Llevan solo el código o
// el aviso (sync-cuenta.md §7): ni IP ni nada que identifique más que el nombre del Mac que eligió el usuario.
// Pendiente: revisión de textos (CONTENIDOS-WEB) e idiomas además del español.

const pie = "\n\n—\nFlyWeb · Cuenta y sincronización. Este correo lo envía el servidor automáticamente; no respondas."

func textoCodigo(t tipoSolicitud, codigo string) (asunto, cuerpo string) {
	c := formatoCodigo(codigo)
	switch t {
	case solAlta:
		return "Tu código para crear la cuenta de FlyWeb", fmt.Sprintf(
			"Tu código para crear la cuenta de FlyWeb: %s\n\nCaduca en 10 minutos. Si no has sido tú, no hagas nada: sin el código no se crea ninguna cuenta.", c) + pie
	case solEntrar:
		return "Tu código para FlyWeb", fmt.Sprintf(
			"Tu código para FlyWeb: %s\n\nCaduca en 10 minutos. Si no has sido tú, alguien conoce tu contraseña: cámbiala.", c) + pie
	case solContrasena:
		return "Tu código para cambiar la contraseña de FlyWeb", fmt.Sprintf(
			"Tu código para cambiar la contraseña de FlyWeb: %s\n\nCaduca en 10 minutos. Si no lo has pedido tú, alguien está usando uno de tus Macs: cambia la clave de sincronización desde otro.", c) + pie
	case solEmail:
		return "Tu código para cambiar el email de FlyWeb", fmt.Sprintf(
			"Tu código para usar esta dirección en tu cuenta de FlyWeb: %s\n\nCaduca en 10 minutos. Si no has sido tú, no hagas nada.", c) + pie
	case solBorrarEmail:
		return "Tu código para borrar la cuenta de FlyWeb", fmt.Sprintf(
			"Tu código para borrar la cuenta de FlyWeb: %s\n\nCaduca en 10 minutos. El borrado se hará dentro de 14 días, y cualquiera de tus Macs puede cancelarlo. Si no has sido tú, no hagas nada.", c) + pie
	case solEmpezarCero:
		return "Tu código para empezar de cero en FlyWeb", fmt.Sprintf(
			"Tu código para empezar de cero en FlyWeb: %s\n\nCaduca en 10 minutos. Los datos sincronizados se borrarán dentro de 14 días, y cualquiera de tus Macs puede cancelarlo. Si no has sido tú, no hagas nada.", c) + pie
	}
	panic("tipo de solicitud sin texto")
}

// Avisos (sync-cuenta.md §6.2): cada operación avisa por correo y con un evento en los Macs.
const (
	evMacAnadido         = "mac-anadido"
	evContrasenaAcertada = "contrasena-acertada"
	evContrasenaFallos   = "contrasena-fallos"
	evContrasenaCambiada = "contrasena-cambiada"
	evEmailCambiado      = "email-cambiado"
	evCadenaCambiada     = "cadena-cambiada"
	evCadenaLigada       = "cadena-ligada"
	evAparatoQuitado     = "aparato-quitado"
	evAparatoRenombrado  = "aparato-renombrado"
	evNoHeSidoYo         = "no-he-sido-yo"
	evBorradoPedido      = "borrado-pedido"
	evBorradoCancelado   = "borrado-cancelado"
)

const siNoHasSidoTu = "\n\nSi no has sido tú, abre «Cuenta y sincronización» en uno de tus Macs y pulsa «No he sido yo»."

// descMac: «nombre» (modelo), como en los avisos de §5.1.
func descMac(nombre, modelo string) string { return "«" + nombre + "» (" + modelo + ")" }

func textoAviso(ev string, mac string) (asunto, cuerpo string) {
	switch ev {
	case evMacAnadido:
		return "Se ha añadido un Mac a tu cuenta de FlyWeb", "Se ha añadido el Mac " + mac + " a tu cuenta de FlyWeb." + siNoHasSidoTu + pie
	case evContrasenaCambiada:
		return "Se ha cambiado la contraseña de FlyWeb", "Se ha cambiado la contraseña de tu cuenta de FlyWeb." + siNoHasSidoTu + pie
	case evEmailCambiado:
		return "Se ha cambiado el email de tu cuenta de FlyWeb", "Tu cuenta de FlyWeb ya no usa esta dirección: se ha cambiado por otra." + siNoHasSidoTu + pie
	case evCadenaCambiada:
		return "Se ha cambiado la clave de sincronización de FlyWeb", "Se ha cambiado la clave de sincronización de tu cuenta de FlyWeb. Tus otros Macs tendrán que volver a entrar con el email, la contraseña y un código." + siNoHasSidoTu + pie
	case evCadenaLigada:
		return "Tu sincronización de FlyWeb tiene cuenta", "Se ha creado una cuenta de FlyWeb con esta dirección y se ha ligado a tu sincronización." + siNoHasSidoTu + pie
	case evAparatoQuitado:
		return "Se ha quitado un Mac de tu cuenta de FlyWeb", "Se ha quitado el Mac " + mac + " de la lista de tu cuenta de FlyWeb. Si lo has perdido o te lo han robado, cambia la clave de sincronización." + siNoHasSidoTu + pie
	case evNoHeSidoYo:
		return "Se ha pulsado «No he sido yo» en FlyWeb", "Desde uno de tus Macs se ha pulsado «No he sido yo»: se han cerrado las sesiones de todos y se han cancelado los borrados pedidos por email. Cambia la contraseña y la clave de sincronización." + pie
	case evBorradoPedido:
		return "Se ha pedido borrar tu cuenta de FlyWeb", "Se ha pedido por email borrar tu cuenta de FlyWeb (o empezar de cero). Se hará dentro de 14 días. Si no has sido tú, cancélalo desde cualquiera de tus Macs." + pie
	case evBorradoCancelado:
		return "Se ha cancelado el borrado de tu cuenta de FlyWeb", "Desde uno de tus Macs se ha cancelado el borrado pedido por email." + pie
	case "cuenta-borrada":
		return "Se ha borrado tu cuenta de FlyWeb", "Se ha borrado tu cuenta de FlyWeb y los datos sincronizados. Los datos que cada Mac tiene en su perfil no se han borrado." + pie
	case "inactiva":
		return "Tu cuenta de FlyWeb se borrará dentro de 30 días", "Tu cuenta de FlyWeb lleva casi un año sin uso. Si no se usa en los próximos 30 días, se borrarán la cuenta, los datos sincronizados y esta dirección. Para conservarla basta con sincronizar desde un Mac." + pie
	}
	panic("aviso sin texto: " + ev)
}
