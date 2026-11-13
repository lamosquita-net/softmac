// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

// Revisión de SEGURIDAD-PORTES-23 sobre cbe0221 (#977, comentario 6865447630): C1 y C2.

import (
	"context"
	"net/http"
	"testing"
	"time"
)

// C1: con solo la cadena no se consigue token ni autoría para el aparato de otro Mac (secreto por aparato).
func TestSeg23SuplantarAutor(t *testing.T) {
	b := nuevoBanco(t, nil)
	a, robado := nuevoMac("A"), nuevoMac("Robado")
	b.crearCuenta(a, emailA, clave)
	b.entrar(robado, emailA, clave)
	b.reloj.avanzar(time.Minute)
	r := b.deMac(robado, "aparatos-renovar", "/aparatos/renovar", map[string]string{"aparato": a.aparato})
	if r.codigo == 200 {
		robado.token = r.txt("token")
		c := nuevoMac("C")
		b.reloj.avanzar(time.Hour)
		b.entrar(c, emailA, clave)
		b.deMac(robado, "aparatos-quitar", "/aparatos/quitar", map[string]string{"aparato": c.aparato})
		for _, e := range b.eventos(a) {
			if e["tipo"] == evAparatoQuitado {
				if d, _ := e["datos"].(map[string]any); d != nil && d["aparato"] == a.aparato {
					t.Fatal("C1: el Mac robado se hace pasar por A")
				}
			}
		}
		t.Fatal("C1: renovar el aparato de A sin su secreto da token")
	}
}

// C2: la numeración de eventos no vuelve a empezar al caducar los viejos.
func TestSeg23NumeracionEventos(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)
	b.reloj.avanzar(time.Minute)
	b.entrar(nuevoMac("B"), emailA, clave)
	desde := int64(0)
	for _, e := range b.eventos(a) {
		desde = max(desde, int64(e["n"].(float64)))
	}
	b.reloj.avanzar(31 * 24 * time.Hour)
	b.s.Tareas(context.Background())
	b.reloj.avanzar(time.Hour)
	b.entrar(nuevoMac("Intruso"), emailA, clave)
	r := b.deMac(a, "eventos", "/eventos", map[string]int64{"desde": desde})
	if len(r.cuerpo["eventos"].([]any)) == 0 {
		t.Fatal("C2: el evento nuevo no llega a un Mac con su «desde» antiguo")
	}
}

// C1 en los cambios: contrasena/cambiar con el aparato del dueño y sin su secreto no da token ni autor.
func TestSeg23SecretoEnCambios(t *testing.T) {
	b := nuevoBanco(t, nil)
	a, robado := nuevoMac("A"), nuevoMac("Robado")
	b.crearCuenta(a, emailA, clave)
	b.entrar(robado, emailA, clave)
	b.reloj.avanzar(time.Minute)
	// Quien tiene la cadena y el código del buzón cambia la contraseña poniendo el aparato de A sin su secreto.
	r := b.deMac(robado, "contrasena-codigo", "/contrasena/codigo", map[string]any{})
	kl, ku := claves("otra", emailA)
	r = b.deMac(robado, "contrasena-cambiar", "/contrasena/cambiar", map[string]string{"solicitud": r.txt("solicitud"),
		"codigo": b.codigo(emailA), "kl": b64e(kl), "envoltura": b64e(envolver(ku, a.semilla, emailA)),
		"aparato": a.aparato, "secreto": robado.secreto})
	esperar(t, r, 200, "el cambio se hace")
	if r.txt("token") != "" {
		t.Fatal("C1: token para el aparato de A sin su secreto")
	}
	if d := datosDe(t, b.eventos(a), evContrasenaCambiada); d["aparato"] != nil {
		t.Fatalf("C1: autoría de A sin su secreto: %v", d)
	}
	// Con su secreto, A renueva su token.
	r = b.deMac(a, "aparatos-renovar", "/aparatos/renovar", map[string]string{"aparato": a.aparato, "secreto": a.secreto})
	esperar(t, r, 200, "A renueva con su secreto")
	esperar(t, b.deMac(robado, "aparatos-renovar", "/aparatos/renovar", map[string]string{"aparato": a.aparato,
		"secreto": robado.secreto}), http.StatusForbidden, "con el secreto de otro aparato")
}

// C1 en el alta repetida: el Mac no tiene el secreto del aparato que se creó; la repetición le da uno nuevo y el
// viejo deja de valer.
func TestSeg23AltaRepetida(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("A")
	r := b.llamar("/alta", map[string]string{"email": emailA})
	kl, ku := claves(clave, emailA)
	pedir := map[string]string{"solicitud": r.txt("solicitud"), "codigo": b.codigo(emailA), "kl": b64e(kl),
		"envoltura": b64e(envolver(ku, a.semilla, emailA)), "modelo": "MacPro7,1", "nombre": "A"}
	r1 := b.conPrueba(a, "alta", "", "/alta/confirmar", pedir)
	esperar(t, r1, 200, "alta")
	b.reloj.avanzar(30 * time.Second)
	r2 := b.conPrueba(a, "alta", "", "/alta/confirmar", pedir)
	esperar(t, r2, 200, "alta repetida")
	if r2.txt("secreto") == "" || r2.txt("secreto") == r1.txt("secreto") || r2.txt("aparato") != r1.txt("aparato") {
		t.Fatalf("la repetición no da un secreto nuevo: %v", r2.cuerpo)
	}
	a.cuenta = r2.txt("cuenta")
	esperar(t, b.deMac(a, "aparatos-renovar", "/aparatos/renovar", map[string]string{"aparato": r1.txt("aparato"),
		"secreto": r1.txt("secreto")}), http.StatusForbidden, "el secreto viejo")
	esperar(t, b.deMac(a, "aparatos-renovar", "/aparatos/renovar", map[string]string{"aparato": r2.txt("aparato"),
		"secreto": r2.txt("secreto")}), 200, "el secreto nuevo")
}

// C4: los nonces gastados se purgan por delante al caducar; no se acumulan.
func TestSeg23NoncesPurga(t *testing.T) {
	r := &relojFalso{t: time.Unix(1_800_000_000, 0)}
	n := nuevosNonces(r.ahora)
	for range 1000 {
		x := n.nuevo()
		c, ok := n.valido(x)
		if !ok || !n.gastar(x, c) || n.gastar(x, c) {
			t.Fatal("gastar")
		}
	}
	r.avanzar(vidaNonce)
	x := n.nuevo()
	c, _ := n.valido(x)
	n.gastar(x, c)
	if n.Usados() != 1 {
		t.Fatalf("quedan %d nonces caducados", n.Usados())
	}
}
