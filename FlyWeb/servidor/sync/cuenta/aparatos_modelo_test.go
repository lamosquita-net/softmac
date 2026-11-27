// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"net/http"
	"testing"
)

// aparatos/modelo cambia solo el aparato del token, valida el modelo y no deja evento ni correo.
func TestAparatosModelo(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("uno")
	b.crearCuenta(a, "ana@ejemplo.es", "contrasena larga y buena")
	b.entregar()
	modelo := func() (m string) {
		if err := b.s.cfg.DB.QueryRow(`SELECT modelo FROM cuenta_aparatos WHERE id = ?`, a.aparato).Scan(&m); err != nil {
			t.Fatal(err)
		}
		return m
	}
	cuantos := func() (n int) {
		if err := b.s.cfg.DB.QueryRow(`SELECT COUNT(*) FROM cuenta_eventos`).Scan(&n); err != nil {
			t.Fatal(err)
		}
		return n
	}
	antes, eventos := modelo(), cuantos()

	for _, malo := range []any{map[string]string{}, map[string]string{"modelo": ""},
		map[string]string{"modelo": "<x>"}, map[string]any{"modelo": 7}} {
		esperar(t, b.conToken(a, "/aparatos/modelo", malo), http.StatusBadRequest, "modelo no válido")
	}
	esperar(t, b.llamar("/aparatos/modelo", map[string]string{"modelo": "Equipo X1"}), http.StatusUnauthorized, "sin token")
	if modelo() != antes {
		t.Fatal("ha cambiado sin deber")
	}
	esperar(t, b.conToken(a, "/aparatos/modelo", map[string]string{"modelo": "Equipo X1", "aparato": "otro"}),
		http.StatusOK, "cambiar el modelo")
	if m := modelo(); m != "Equipo X1" {
		t.Fatalf("modelo: %q", m)
	}
	if cuantos() != eventos {
		t.Fatal("ha dejado un evento")
	}
}
