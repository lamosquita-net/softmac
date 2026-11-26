// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"bytes"
	"strings"
	"testing"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

// Cada entrar/empezar deja su resultado en el registro, sin email.
func TestRegistroDeEntrarEmpezar(t *testing.T) {
	b := nuevoBanco(t, nil)
	b.crearCuenta(nuevoMac("uno"), "ana@ejemplo.es", "contrasena larga y buena")
	b.entregar()

	var registro bytes.Buffer
	antes := log.Logger
	log.Logger = zerolog.New(&registro)
	defer func() { log.Logger = antes }()

	b.empezarEntrada("nadie@ejemplo.es", "contrasena larga y buena")
	b.empezarEntrada("ana@ejemplo.es", "otra contrasena distinta")
	b.reloj.avanzar(ritmoFallos)
	b.empezarEntrada("ana@ejemplo.es", "contrasena larga y buena")
	b.entregar()

	salida := registro.String()
	for _, quiero := range []string{`"resultado":"sin-cuenta"`, `"resultado":"kl-rechazada"`,
		`"resultado":"kl-aceptada-codigo-en-cola"`, "código entregado al MTA"} {
		if !strings.Contains(salida, quiero) {
			t.Errorf("falta %s en el registro:\n%s", quiero, salida)
		}
	}
	if strings.Contains(salida, "ejemplo.es") || strings.Contains(salida, "@") {
		t.Errorf("el registro lleva un email:\n%s", salida)
	}
}
