// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"encoding/json"
	"testing"
)

func TestModeloOpcional(t *testing.T) {
	for crudo, quiero := range map[string]string{
		`"Equipo X1"`: "Equipo X1", `"Mac14,2"`: "Mac14,2", ``: "", `null`: "", `""`: "", `7`: "", `{}`: "",
		`"<script>"`: "", `"a\\nb"`: "",
	} {
		if got := modeloOpcional(json.RawMessage(crudo)); got != quiero {
			t.Errorf("modeloOpcional(%s) = %q, quiero %q", crudo, got, quiero)
		}
	}
}

// El aviso de fallos lleva el modelo, también el pendiente, y una base sin la columna la recibe.
func TestFallosConModelo(t *testing.T) {
	b := nuevoBanco(t, nil)
	b.crearCuenta(nuevoMac("uno"), "ana@ejemplo.es", "contrasena larga y buena")
	b.entregar()
	c, err := b.s.alm.porEmail(t.Context(), b.s.hmacs("ana@ejemplo.es"))
	if err != nil || c == nil {
		t.Fatal("sin cuenta", err)
	}
	if _, err := b.s.cfg.DB.Exec(`ALTER TABLE cuentas DROP COLUMN fallos_modelo`); err != nil {
		t.Fatal(err)
	}
	for range 2 {
		if err := b.s.alm.crear(t.Context()); err != nil {
			t.Fatal(err)
		}
	}
	ultimo := func() (d datosEvento) {
		var datos []byte
		var v int
		if err := b.s.cfg.DB.QueryRow(`SELECT datos, aes_v FROM cuenta_eventos WHERE tipo = ? ORDER BY n DESC LIMIT 1`,
			evContrasenaFallos).Scan(&datos, &v); err != nil {
			t.Fatal(err)
		}
		claro, err := b.s.cfg.AES.abrir(v, asociadoEvento(c.id, evContrasenaFallos), datos)
		if err != nil || json.Unmarshal(claro, &d) != nil {
			t.Fatal("datos ilegibles", err)
		}
		return d
	}

	b.s.registrarFallo(t.Context(), c, "", "Equipo X1")
	if d := ultimo(); d.Modelo != "Equipo X1" || d.N != 1 {
		t.Fatalf("primer aviso: %+v", d)
	}
	b.s.registrarFallo(t.Context(), c, "", "Mac14,2")
	b.s.registrarFallo(t.Context(), c, "", "")
	b.reloj.avanzar(ritmoFallos)
	b.s.Tareas(t.Context())
	if d := ultimo(); d.Modelo != "Mac14,2" || d.N != 2 {
		t.Fatalf("aviso pendiente: %+v", d)
	}
	b.reloj.avanzar(ritmoFallos)
	b.s.registrarFallo(t.Context(), c, "", "")
	if d := ultimo(); d.Modelo != "" || d.N != 1 {
		t.Fatalf("sin modelo no hereda el anterior: %+v", d)
	}
}
