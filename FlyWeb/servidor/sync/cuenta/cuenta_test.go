// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

// Parte de servidor del guion de sync-cuenta.md §12 que se puede probar sin Macs. Cada prueba dice qué P cubre.

import (
	"bytes"
	"encoding/base64"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"
)

const (
	emailA = "ana@example.com"
	clave  = "contraseña de prueba 1"
)

// P1 y P2: alta desde un Mac con cadena; dos Macs nuevos entran con email + contraseña + código y reciben la
// semilla; el primero ve los eventos y recibe el correo «Se ha añadido el Mac».
func TestAltaYEntrar(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("Mac de Ana")
	b.crearCuenta(a, emailA, clave)
	if a.cuenta == "" || a.token == "" {
		t.Fatal("el alta no devuelve cuenta y token")
	}
	for _, nombre := range []string{"Portátil", "Mini"} {
		m := nuevoMac(nombre)
		b.entrar(m, emailA, clave)
		if !bytes.Equal(m.semilla, a.semilla) || m.cadena != a.cadena || m.cuenta != a.cuenta {
			t.Fatalf("%s no ha recibido la semilla de la cadena", nombre)
		}
	}
	ts := tipos(b.eventos(a))
	if cuenta(ts, evMacAnadido) != 2 || cuenta(ts, evContrasenaAcertada) != 2 || cuenta(ts, evCadenaLigada) != 1 {
		t.Fatalf("eventos: %v", ts)
	}
	b.entregar()
	anadidos := 0
	for _, c := range b.buzon.para(emailA) {
		if strings.Contains(c.cuerpo, "Se ha añadido el Mac «Portátil» (MacPro6,1)") {
			anadidos++
		}
	}
	if anadidos != 1 {
		t.Fatal("falta el aviso «Se ha añadido el Mac» por correo")
	}
	// La lista, con el token: tres aparatos con su nombre.
	r := b.conToken(a, "/aparatos/listar", map[string]any{})
	esperar(t, r, 200, "listar")
	if aps := r.cuerpo["aparatos"].([]any); len(aps) != 3 || aps[1].(map[string]any)["nombre"] != "Portátil" {
		t.Fatalf("aparatos: %v", aps)
	}
	// Una cadena, una cuenta.
	r = b.llamar("/alta", map[string]string{"email": "otra@example.com"})
	kl, ku := claves(clave, "otra@example.com")
	r = b.conPrueba(a, "alta", "", "/alta/confirmar", map[string]string{"solicitud": r.txt("solicitud"),
		"codigo": b.codigo("otra@example.com"), "kl": b64e(kl), "envoltura": b64e(envolver(ku, a.semilla, "otra@example.com")),
		"modelo": "MacPro7,1", "nombre": "x"})
	esperar(t, r, http.StatusConflict, "ligar una cadena que ya tiene cuenta")
}

// P22 (parte de servidor) y P20: en sync.db no están KL, la envoltura interior, la semilla ni el email en claro;
// tras borrar la cuenta, nada de la cuenta.
func TestLoQueHayEnSyncDB(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("Mac de Ana")
	b.crearCuenta(a, emailA, clave)
	kl, ku := claves(clave, emailA)
	leer := func() []byte {
		d, err := os.ReadFile(b.ruta)
		if err != nil {
			t.Fatal(err)
		}
		return d
	}
	d := leer()
	for que, x := range map[string][]byte{"KL": kl, "KU": ku, "semilla": a.semilla, "email": []byte(emailA),
		"nombre": []byte("Mac de Ana")} {
		if bytes.Contains(d, x) {
			t.Fatalf("%s está en sync.db", que)
		}
	}
	var n int
	b.s.cfg.DB.QueryRow(`SELECT COUNT(*) FROM cuentas`).Scan(&n)
	if n != 1 {
		t.Fatal("no hay cuenta")
	}
	r := b.deMac(a, "cuenta-borrar", "/cuenta/borrar", map[string]any{})
	esperar(t, r, 200, "borrar")
	for _, tabla := range []string{"cuentas", "cuenta_aparatos", "cuenta_eventos", "cuenta_programados"} {
		b.s.cfg.DB.QueryRow(`SELECT COUNT(*) FROM ` + tabla).Scan(&n)
		if n != 0 {
			t.Fatalf("quedan %d filas en %s", n, tabla)
		}
	}
	if !b.cad.desactivadas[a.cadena] {
		t.Fatal("la cadena no se ha borrado (ClearServerData + desactivada)")
	}
	b.entregar()
	if cs := b.buzon.para(emailA); !strings.Contains(cs[len(cs)-1].cuerpo, "Se ha borrado tu cuenta") {
		t.Fatal("falta el aviso de cuenta borrada")
	}
}

// P4 y P5: con la contraseña mala no sale correo y la respuesta tiene la misma forma; con la buena y el código malo,
// un solo error. La espera crece igual acierte o no, y es la misma para un email sin cuenta. Aviso de fallos: el
// primero al momento, después como mucho uno por hora. Con la espera a tope, cambiar la contraseña la pone a cero.
func TestContrasenaEnLinea(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("Mac de Ana")
	b.crearCuenta(a, emailA, clave)
	b.entregar()
	antes := len(b.buzon.para(emailA))

	mala := b.empezarEntrada(emailA, "otra")
	esperar(t, mala, 200, "contraseña mala")
	b.entregar()
	if len(b.buzon.para(emailA)) != antes {
		t.Fatal("con la contraseña mala ha salido un correo")
	}
	b.reloj.avanzar(10 * time.Second)
	buena := b.empezarEntrada(emailA, clave)
	esperar(t, buena, 200, "contraseña buena")
	if len(mala.txt("solicitud")) != len(buena.txt("solicitud")) || len(mala.cuerpo) != len(buena.cuerpo) {
		t.Fatal("la respuesta distingue la contraseña buena de la mala")
	}
	kl, _ := claves(clave, emailA)
	r := b.llamar("/entrar/terminar", map[string]string{"solicitud": buena.txt("solicitud"), "codigo": "AAAA-AAAA",
		"kl": b64e(kl), "modelo": "MacPro6,1", "nombre": "x"})
	esperar(t, r, http.StatusForbidden, "código malo")
	klMal, _ := claves("otra", emailA)
	b.reloj.avanzar(10 * time.Second)
	r2 := b.llamar("/entrar/terminar", map[string]string{"solicitud": buena.txt("solicitud"), "codigo": b.codigo(emailA),
		"kl": b64e(klMal), "modelo": "MacPro6,1", "nombre": "x"})
	if r2.codigo != r.codigo || r2.txt("error") != r.txt("error") {
		t.Fatal("contraseña mala y código malo dan errores distintos")
	}

	// El ritmo medido: tras los dos intentos de arriba la espera es de 20 s, acertara o no el segundo.
	sinCuenta := "nadie@example.com"
	ritmo := func(email, contrasena string) []time.Duration {
		var esperas []time.Duration
		for range 9 {
			r := b.empezarEntrada(email, contrasena)
			for r.codigo == http.StatusTooManyRequests {
				hasta := time.Unix(r.num("hasta"), 0)
				esperas = append(esperas, hasta.Sub(b.reloj.ahora()))
				b.reloj.t = hasta
				r = b.empezarEntrada(email, contrasena)
			}
			esperar(t, r, 200, "intento")
		}
		return esperas
	}
	b.reloj.avanzar(time.Minute)
	b.s.esperas.Reiniciar(b.s.claveEspera(emailA))
	conCuenta := ritmo(emailA, "mala")
	b.s.esperas.Reiniciar(b.s.claveEspera(emailA))
	conCuentaBuena := ritmo(emailA, clave)
	sin := ritmo(sinCuenta, "mala")
	want := []time.Duration{10, 20, 40, 80, 160, 320, 640, 900}
	for i, w := range want {
		w *= time.Second
		if conCuenta[i] != w || sin[i] != w || conCuentaBuena[i] != w {
			t.Fatalf("espera %d: con cuenta %v, con la buena %v, sin cuenta %v; debe ser %v", i, conCuenta[i],
				conCuentaBuena[i], sin[i], w)
		}
	}

	// Aviso de fallos: hubo un fallo al principio (aviso al momento) y luego 9 más en menos de una hora…
	ts := tipos(b.eventos(a))
	if cuenta(ts, evContrasenaFallos) < 1 || cuenta(ts, evContrasenaAcertada) < 9 {
		t.Fatalf("eventos: %v", ts)
	}
	porHora := cuenta(ts, evContrasenaFallos)
	b.reloj.avanzar(time.Hour)
	b.s.Tareas(t.Context())
	ts = tipos(b.eventos(a))
	if cuenta(ts, evContrasenaFallos) != porHora+1 {
		t.Fatalf("los fallos pendientes no se avisan a la hora: %v", ts)
	}

	// A tope: A cambia la contraseña con un código y la espera vuelve a cero.
	b.s.esperas.Anotar(b.s.claveEspera(emailA))
	if b.s.esperas.Hasta(b.s.claveEspera(emailA)).IsZero() {
		t.Fatal("la espera debería estar a tope")
	}
	b.cambiarContrasena(a, emailA, "contraseña nueva 2")
	if !b.s.esperas.Hasta(b.s.claveEspera(emailA)).IsZero() {
		t.Fatal("cambiar la contraseña no pone la espera a cero")
	}
}

func (b *banco) cambiarContrasena(a *mac, email, nueva string) respuesta {
	b.t.Helper()
	r := b.deMac(a, "contrasena-codigo", "/contrasena/codigo", map[string]any{})
	esperar(b.t, r, 200, "contrasena/codigo")
	kl, ku := claves(nueva, email)
	r = b.deMac(a, "contrasena-cambiar", "/contrasena/cambiar", map[string]string{"solicitud": r.txt("solicitud"),
		"codigo": b.codigo(email), "kl": b64e(kl), "envoltura": b64e(envolver(ku, a.semilla, email)), "aparato": a.aparato})
	esperar(b.t, r, 200, "contrasena/cambiar")
	a.token = r.txt("token")
	return r
}

// P6 y P11 (con un Mac): cambio de contraseña con un código y sin la anterior; los demás Macs pierden el token y
// sacan otro con la prueba de cadena; la vieja ya no entra y la nueva sí. «No he sido yo» invalida los tokens.
// La llamada repetida (respuesta perdida) contesta igual.
func TestCambioDeContrasena(t *testing.T) {
	b := nuevoBanco(t, nil)
	a, m := nuevoMac("A"), nuevoMac("B")
	b.crearCuenta(a, emailA, clave)
	b.entrar(m, emailA, clave)
	b.reloj.avanzar(time.Minute)

	r := b.deMac(a, "contrasena-codigo", "/contrasena/codigo", map[string]any{})
	sol := r.txt("solicitud")
	codigo := b.codigo(emailA)
	kl, ku := claves("nueva contraseña", emailA)
	pedir := map[string]string{"solicitud": sol, "codigo": codigo, "kl": b64e(kl),
		"envoltura": b64e(envolver(ku, a.semilla, emailA)), "aparato": a.aparato}
	r = b.deMac(a, "contrasena-cambiar", "/contrasena/cambiar", pedir)
	esperar(t, r, 200, "cambiar")
	a.token = r.txt("token")
	// Se repite la llamada (la respuesta no llegó): mismo resultado, token nuevo.
	b.reloj.avanzar(30 * time.Second)
	r = b.deMac(a, "contrasena-cambiar", "/contrasena/cambiar", pedir)
	esperar(t, r, 200, "repetida")
	a.token = r.txt("token")
	// Con otra envoltura, la misma solicitud ya no vale.
	b.reloj.avanzar(30 * time.Second)
	pedir["envoltura"] = b64e(envolver(ku, aleatorio(32), emailA))
	esperar(t, b.deMac(a, "contrasena-cambiar", "/contrasena/cambiar", pedir), http.StatusForbidden, "otra envoltura")

	esperar(t, b.conToken(m, "/eventos", map[string]int{}), http.StatusUnauthorized, "token de B tras el cambio")
	esperar(t, b.conToken(a, "/eventos", map[string]int{}), 200, "token de A tras el cambio")
	r = b.deMac(m, "aparatos-renovar", "/aparatos/renovar", map[string]string{"aparato": m.aparato})
	esperar(t, r, 200, "B renueva con la prueba de cadena")
	m.token = r.txt("token")
	if ts := tipos(b.eventos(m)); cuenta(ts, evContrasenaCambiada) != 1 {
		t.Fatalf("B no ve «contraseña cambiada»: %v", ts)
	}
	// La vieja no entra; la nueva sí.
	b.reloj.avanzar(time.Hour)
	viejo := b.empezarEntrada(emailA, clave)
	b.entregar()
	n := len(b.buzon.para(emailA))
	b.reloj.avanzar(time.Hour)
	_ = viejo
	b.entrar(nuevoMac("C"), emailA, "nueva contraseña")
	if len(b.buzon.para(emailA)) <= n {
		t.Fatal("con la contraseña nueva no llega el código")
	}
	// «No he sido yo» en B: nadie conserva el token.
	esperar(t, b.deMac(m, "no-he-sido-yo", "/no-he-sido-yo", map[string]any{}), 200, "no he sido yo")
	esperar(t, b.conToken(a, "/eventos", map[string]int{}), http.StatusUnauthorized, "token de A tras «No he sido yo»")
	esperar(t, b.conToken(m, "/eventos", map[string]int{}), http.StatusUnauthorized, "token de B tras «No he sido yo»")
}

// P14: un token de sync capturado no vale como prueba; una prueba usada no se repite; ni vale para otra operación,
// otra cuenta u otro cuerpo.
func TestReutilizacion(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)
	cuerpo := cuerpoJSON(map[string]int{"desde": 0})
	n := b.nonce()
	firma := FirmarPrueba(a.sk, "POST", prefijo+"/eventos", "eventos", a.cuenta, n, cuerpo)
	cab := map[string]string{"X-FlyWeb-Cadena": a.cadena, "X-FlyWeb-Nonce": base64.RawURLEncoding.EncodeToString(n),
		"X-FlyWeb-Prueba": b64e(firma)}
	esperar(t, b.pedir("/eventos", cuerpo, cab), 200, "prueba válida")
	esperar(t, b.pedir("/eventos", cuerpo, cab), http.StatusUnauthorized, "prueba repetida")

	// Token de go-sync: firma de la hora en decimal, sin el prefijo de dominio.
	ts := []byte("1794571200000")
	n = b.nonce()
	cab["X-FlyWeb-Nonce"] = base64.RawURLEncoding.EncodeToString(n)
	cab["X-FlyWeb-Prueba"] = b64e(ed25519Sign(a, ts))
	esperar(t, b.pedir("/eventos", cuerpo, cab), http.StatusUnauthorized, "token de sync como prueba")

	ruta := prefijo + "/eventos"
	for que, f := range map[string][]byte{
		"otra operación": FirmarPrueba(a.sk, "POST", ruta, "cuenta-borrar", a.cuenta, n, cuerpo),
		"otra cuenta":    FirmarPrueba(a.sk, "POST", ruta, "eventos", "otra", n, cuerpo),
		"otro cuerpo":    FirmarPrueba(a.sk, "POST", ruta, "eventos", a.cuenta, n, []byte(`{"desde":1}`)),
		"otra ruta":      FirmarPrueba(a.sk, "POST", prefijo+"/aparatos/listar", "eventos", a.cuenta, n, cuerpo),
		"otro método":    FirmarPrueba(a.sk, "PUT", ruta, "eventos", a.cuenta, n, cuerpo),
		"sin el prefijo": FirmarPrueba(a.sk, "POST", "/eventos", "eventos", a.cuenta, n, cuerpo),
	} {
		cab["X-FlyWeb-Prueba"] = b64e(f)
		esperar(t, b.pedir("/eventos", cuerpo, cab), http.StatusUnauthorized, que)
	}
	// Un nonce caducado (5 min) no vale.
	n = b.nonce()
	b.reloj.avanzar(5 * time.Minute)
	cab["X-FlyWeb-Nonce"] = base64.RawURLEncoding.EncodeToString(n)
	cab["X-FlyWeb-Prueba"] = b64e(FirmarPrueba(a.sk, "POST", ruta, "eventos", a.cuenta, n, cuerpo))
	esperar(t, b.pedir("/eventos", cuerpo, cab), http.StatusUnauthorized, "nonce caducado")
}

// P17: 100 códigos fallidos seguidos: un intento cada 10 s por solicitud y nunca se cierra; los fallos de otra
// solicitud no retrasan la del dueño.
func TestCodigosSinCierre(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)
	intruso := b.deMac(a, "contrasena-codigo", "/contrasena/codigo", map[string]any{}).txt("solicitud")
	dueno := b.deMac(a, "contrasena-codigo", "/contrasena/codigo", map[string]any{}).txt("solicitud")
	codigoDueno := b.codigo(emailA)
	kl, ku := claves("nueva", emailA)
	intento := func(sol, codigo string) respuesta {
		return b.deMac(a, "contrasena-cambiar", "/contrasena/cambiar", map[string]string{"solicitud": sol,
			"codigo": codigo, "kl": b64e(kl), "envoltura": b64e(envolver(ku, a.semilla, emailA))})
	}
	for i := range 100 {
		r := intento(intruso, "AAAA-AAAA")
		esperar(t, r, http.StatusForbidden, "código malo")
		r = intento(intruso, "AAAA-AAAA")
		esperar(t, r, http.StatusTooManyRequests, "antes de 10 s")
		if i%10 == 0 {
			b.reloj.avanzar(time.Second)
		}
		b.reloj.avanzar(ritmoCodigo)
		if b.reloj.ahora().Sub(time.Date(2026, 11, 13, 12, 0, 0, 0, time.UTC)) > 9*time.Minute {
			break // las solicitudes caducan a los 10 min
		}
	}
	esperar(t, intento(dueno, codigoDueno), 200, "el código del dueño, tras los fallos del intruso")
}

// P18: cupos de correo. 21 altas en una hora → la 21 no sale; el código de entrada a una cuenta real sí llega;
// agotados los 5 códigos con prueba de la hora, el aviso de un aparato quitado llega igual. 415 con otro
// Content-Type y ninguna cabecera CORS.
func TestCuposDeCorreo(t *testing.T) {
	b := nuevoBanco(t, nil)
	a, m := nuevoMac("A"), nuevoMac("B")
	b.crearCuenta(a, emailA, clave) // gasta 1 del cupo de altas
	b.entrar(m, emailA, clave)
	b.reloj.avanzar(time.Minute)
	for i := range 20 {
		esperar(t, b.llamar("/alta", map[string]string{"email": "alta" + string(rune('a'+i)) + "@example.com"}), 200, "alta")
	}
	b.entregar()
	salidos := 0
	for i := range 20 {
		salidos += len(b.buzon.para("alta" + string(rune('a'+i)) + "@example.com"))
	}
	if salidos != 19 {
		t.Fatalf("han salido %d correos de alta en la hora; debían ser 19 (más el de la cuenta de A)", salidos)
	}
	// El cupo de altas no toca a los códigos de entrada.
	b.s.esperas.Reiniciar(b.s.claveEspera(emailA))
	esperar(t, b.empezarEntrada(emailA, clave), 200, "entrar")
	b.codigo(emailA)
	// 5 códigos con prueba por hora y cuenta; el sexto, «cupo».
	for range 5 {
		esperar(t, b.deMac(a, "contrasena-codigo", "/contrasena/codigo", map[string]any{}), 200, "código")
	}
	r := b.deMac(a, "contrasena-codigo", "/contrasena/codigo", map[string]any{})
	if r.codigo != http.StatusTooManyRequests || r.txt("error") != "cupo" {
		t.Fatalf("sexto código: %d %v", r.codigo, r.cuerpo)
	}
	b.entregar()
	n := len(b.buzon.para(emailA))
	esperar(t, b.deMac(a, "aparatos-quitar", "/aparatos/quitar", map[string]string{"aparato": m.aparato}), 200, "quitar")
	b.entregar()
	cs := b.buzon.para(emailA)
	if len(cs) != n+1 || !strings.Contains(cs[n].cuerpo, "Se ha quitado el Mac «B»") {
		t.Fatal("el aviso del aparato quitado no llega con los códigos agotados")
	}
	// Los avisos se reintentan si el MTA no responde.
	b.buzon.caido = true
	esperar(t, b.deMac(a, "no-he-sido-yo", "/no-he-sido-yo", map[string]any{}), 200, "no he sido yo")
	b.entregar()
	b.buzon.caido = false
	b.reloj.avanzar(time.Minute)
	b.entregar()
	if cs := b.buzon.para(emailA); !strings.Contains(cs[len(cs)-1].cuerpo, "No he sido yo") {
		t.Fatal("el aviso no se reintenta")
	}
	// Forma de las peticiones (C5).
	for _, ct := range []string{"text/plain", "application/x-www-form-urlencoded", "multipart/form-data; boundary=x", ""} {
		req, _ := http.NewRequest("POST", b.url+"/alta", strings.NewReader(`{"email":"x@example.com"}`))
		if ct != "" {
			req.Header.Set("Content-Type", ct)
		}
		req.Header.Set("Origin", "https://web.example")
		res, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatal(err)
		}
		res.Body.Close()
		if res.StatusCode != http.StatusUnsupportedMediaType {
			t.Fatalf("Content-Type %q: %d", ct, res.StatusCode)
		}
	}
	req, _ := http.NewRequest("OPTIONS", b.url+"/alta", nil)
	req.Header.Set("Origin", "https://web.example")
	req.Header.Set("Access-Control-Request-Method", "POST")
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	res.Body.Close()
	r = b.llamar("/alta", map[string]string{"email": "z@example.com"})
	for _, h := range []http.Header{res.Header, r.cab} {
		for k := range h {
			if strings.HasPrefix(strings.ToLower(k), "access-control-") {
				t.Fatalf("cabecera CORS: %s", k)
			}
		}
	}
	if res.StatusCode == 200 || res.StatusCode == 204 {
		t.Fatalf("OPTIONS = %d", res.StatusCode)
	}
}

// Cupo (2): 5 códigos de entrada por hora y cuenta; el sexto no sale y la respuesta no lo dice.
func TestCupoDeEntradaPorCuenta(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)
	b.entregar()
	n := len(b.buzon.para(emailA))
	for range 6 {
		b.s.esperas.Reiniciar(b.s.claveEspera(emailA))
		esperar(t, b.empezarEntrada(emailA, clave), 200, "entrar")
	}
	b.entregar()
	if got := len(b.buzon.para(emailA)) - n; got != 5 {
		t.Fatalf("códigos de entrada en una hora: %d, debían ser 5", got)
	}
}

// P21: Mac robado, con la cadena y sin el correo ni la contraseña. No cambia contraseña, email ni clave; sus fallos
// no cierran nada, avisan en los demás Macs con su nombre y suben la espera; el dueño cambia la clave con su
// contraseña cuando le llega el turno, y el robado deja de leer.
func TestMacRobado(t *testing.T) {
	b := nuevoBanco(t, nil)
	a, robado := nuevoMac("A"), nuevoMac("Robado")
	b.crearCuenta(a, emailA, clave)
	b.entrar(robado, emailA, clave)
	b.reloj.avanzar(time.Minute)

	// Contraseña: sin el código del buzón, nada.
	sol := b.deMac(robado, "contrasena-codigo", "/contrasena/codigo", map[string]any{}).txt("solicitud")
	kl, ku := claves("del ladrón", emailA)
	r := b.deMac(robado, "contrasena-cambiar", "/contrasena/cambiar", map[string]string{"solicitud": sol,
		"codigo": "AAAA-AAAA", "kl": b64e(kl), "envoltura": b64e(envolver(ku, robado.semilla, emailA))})
	esperar(t, r, http.StatusForbidden, "cambiar la contraseña sin código")
	// Email y clave: sin la contraseña, nada, y nada pendiente.
	esperar(t, b.deMac(robado, "email-empezar", "/email/cambiar/empezar", map[string]string{
		"email": "ladron@example.com", "kl": b64e(kl)}), http.StatusForbidden, "cambiar el email sin contraseña")
	b.entregar()
	if len(b.buzon.para("ladron@example.com")) != 0 {
		t.Fatal("ha salido un código a la dirección del ladrón")
	}
	nueva := nuevoMac("nueva")
	b.reloj.avanzar(10 * time.Second)
	r = b.conPrueba(robado, "cadena-cambiar", robado.cuenta, "/cadena/cambiar", map[string]string{"kl": b64e(kl),
		"envoltura": b64e(envolver(ku, nueva.semilla, emailA))}, firmante{nueva, "X-FlyWeb-Cadena-Nueva", "X-FlyWeb-Prueba-Nueva"})
	esperar(t, r, http.StatusForbidden, "cambiar la clave sin contraseña")
	var n int
	b.s.cfg.DB.QueryRow(`SELECT COUNT(*) FROM cuenta_programados`).Scan(&n)
	if n != 0 || len(b.cad.borradas) != 0 {
		t.Fatal("ha quedado algo pendiente o borrado")
	}
	// Aviso de fallos en A, con el nombre del Mac robado (venía con su token).
	es := b.eventos(a)
	vistoNombre := false
	for _, e := range es {
		if e["tipo"] == evContrasenaFallos {
			if d, _ := e["datos"].(map[string]any); d != nil && d["mac"] == "Robado" {
				vistoNombre = true
			}
		}
	}
	if !vistoNombre {
		t.Fatalf("el aviso de fallos no dice desde qué Mac: %v", es)
	}
	// La espera sube con los fallos con prueba de cadena: ahora 20 s.
	if h := b.s.esperas.Hasta(b.s.claveEspera(emailA)); h.Sub(b.reloj.ahora()) != 20*time.Second {
		t.Fatalf("espera tras dos fallos con prueba: %v", h.Sub(b.reloj.ahora()))
	}
	// A, con su contraseña y cuando le llega el turno, cambia la clave.
	b.reloj.avanzar(20 * time.Second)
	klA, kuA := claves(clave, emailA)
	r = b.conPrueba(a, "cadena-cambiar", a.cuenta, "/cadena/cambiar", map[string]string{"kl": b64e(klA),
		"envoltura": b64e(envolver(kuA, nueva.semilla, emailA)), "aparato": a.aparato},
		firmante{nueva, "X-FlyWeb-Cadena-Nueva", "X-FlyWeb-Prueba-Nueva"})
	esperar(t, r, 200, "A cambia la clave")
	if len(b.cad.borradas) != 1 || b.cad.borradas[0] != a.cadena {
		t.Fatal("la cadena vieja no se ha borrado")
	}
	viejaCadena := *robado
	viejaCadena.token = ""
	a.ponerSemilla(nueva.semilla)
	a.token = r.txt("token")
	// El robado: sus pruebas ya no tienen cuenta; ve «cadena sustituida».
	r = b.conPrueba(&viejaCadena, "eventos", "", "/eventos", map[string]int{"desde": 0})
	if r.codigo != 200 || r.txt("estado") != "cadena-sustituida" {
		t.Fatalf("eventos con la cadena vieja: %d %v", r.codigo, r.cuerpo)
	}
	esperar(t, b.conToken(robado, "/eventos", map[string]int{}), http.StatusUnauthorized, "token del robado")
	// A sigue, con la cadena nueva; un Mac nuevo entra y recibe la semilla nueva.
	if ts := tipos(b.eventos(a)); cuenta(ts, evCadenaCambiada) != 1 {
		t.Fatalf("eventos de A: %v", ts)
	}
	c := nuevoMac("C")
	b.reloj.avanzar(time.Hour)
	b.entrar(c, emailA, clave)
	if !bytes.Equal(c.semilla, nueva.semilla) {
		t.Fatal("tras el cambio de clave, el Mac nuevo no recibe la semilla nueva")
	}
}

// P26: cambio de email con la contraseña y un código a la dirección nueva; la vieja recibe el aviso; se entra con la
// nueva y no con la vieja. Con la contraseña mal no cambia nada ni sale código.
func TestCambioDeEmail(t *testing.T) {
	b := nuevoBanco(t, nil)
	a, m := nuevoMac("A"), nuevoMac("B")
	b.crearCuenta(a, emailA, clave)
	b.entrar(m, emailA, clave)
	const nuevo = "ana.nueva@example.com"
	klMal, _ := claves("mala", emailA)
	esperar(t, b.deMac(a, "email-empezar", "/email/cambiar/empezar", map[string]string{"email": nuevo,
		"kl": b64e(klMal)}), http.StatusForbidden, "contraseña mal")
	b.entregar()
	if len(b.buzon.para(nuevo)) != 0 {
		t.Fatal("con la contraseña mal ha salido un código")
	}
	b.reloj.avanzar(10 * time.Second)
	kl, _ := claves(clave, emailA)
	r := b.deMac(a, "email-empezar", "/email/cambiar/empezar", map[string]string{"email": nuevo, "kl": b64e(kl)})
	esperar(t, r, 200, "email/cambiar/empezar")
	kl2, ku2 := claves(clave, nuevo)
	r = b.llamar("/email/cambiar/terminar", map[string]string{"solicitud": r.txt("solicitud"), "codigo": b.codigo(nuevo),
		"kl": b64e(kl2), "envoltura": b64e(envolver(ku2, a.semilla, nuevo))})
	esperar(t, r, 200, "email/cambiar/terminar")
	b.entregar()
	if cs := b.buzon.para(emailA); !strings.Contains(cs[len(cs)-1].cuerpo, "ya no usa esta dirección") {
		t.Fatal("la dirección vieja no recibe el aviso")
	}
	if ts := tipos(b.eventos(m)); cuenta(ts, evEmailCambiado) != 1 {
		t.Fatalf("B no ve el evento: %v", ts)
	}
	b.reloj.avanzar(time.Hour)
	c := nuevoMac("C")
	b.entrar(c, nuevo, clave)
	if !bytes.Equal(c.semilla, a.semilla) {
		t.Fatal("no se entra con la dirección nueva")
	}
	b.reloj.avanzar(time.Hour)
	b.entregar()
	n := len(b.buzon.para(emailA))
	esperar(t, b.empezarEntrada(emailA, clave), 200, "entrar con la vieja")
	b.entregar()
	if len(b.buzon.para(emailA)) != n {
		t.Fatal("con la dirección vieja sale un código")
	}
}

// P7 y P8: «Salir en este Mac» quita el aparato sin borrar nada; «Borrar en todos» borra cuenta y cadena.
func TestSalirYBorrar(t *testing.T) {
	b := nuevoBanco(t, nil)
	a, c := nuevoMac("A"), nuevoMac("C")
	b.crearCuenta(a, emailA, clave)
	b.entrar(c, emailA, clave)
	esperar(t, b.deMac(c, "salir", "/salir", map[string]string{"aparato": c.aparato}), 200, "salir")
	r := b.conToken(a, "/aparatos/listar", map[string]any{})
	if aps := r.cuerpo["aparatos"].([]any); len(aps) != 1 {
		t.Fatalf("tras salir, A lista %d aparatos", len(aps))
	}
	if len(b.cad.borradas) != 0 {
		t.Fatal("salir ha borrado datos")
	}
	esperar(t, b.deMac(a, "cuenta-borrar", "/cuenta/borrar", map[string]any{}), 200, "borrar")
	if b.s.borradas.Load() != 1 {
		t.Fatal("el contador anónimo no sube")
	}
	c.token = ""
	r = b.conPrueba(c, "eventos", "", "/eventos", map[string]int{"desde": 0})
	if r.txt("estado") != "sin-cuenta" {
		t.Fatalf("tras borrar: %v", r.cuerpo)
	}
}

// P19: borrado y «empezar de cero» solo con el buzón: nada se borra en 14 días, un Mac lo cancela y no se puede
// volver a pedir en 30 días; si nadie lo cancela, se cumple.
func TestDiferidos(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)

	pedirBorrado := func() respuesta {
		r := b.llamar("/cuenta/borrar-por-email", map[string]string{"email": emailA})
		esperar(t, r, 200, "pedir borrado")
		return b.llamar("/cuenta/borrar-por-email/confirmar", map[string]string{"solicitud": r.txt("solicitud"),
			"codigo": b.codigo(emailA)})
	}
	esperar(t, pedirBorrado(), 200, "confirmar borrado")
	r := b.deMac(a, "eventos", "/eventos", map[string]int{"desde": 0})
	if r.txt("estado") != "borrado-programado" {
		t.Fatalf("estado: %v", r.cuerpo)
	}
	b.reloj.avanzar(13 * 24 * time.Hour)
	b.s.Tareas(t.Context())
	if len(b.cad.borradas) != 0 {
		t.Fatal("se ha borrado antes de 14 días")
	}
	r = b.deMac(a, "borrado-cancelar", "/cuenta/borrar/cancelar", map[string]any{})
	if r.codigo != 200 || r.cuerpo["cancelado"] != true {
		t.Fatalf("cancelar: %v", r.cuerpo)
	}
	b.reloj.avanzar(2 * 24 * time.Hour)
	b.s.Tareas(t.Context())
	if len(b.cad.borradas) != 0 {
		t.Fatal("se ha borrado tras cancelar")
	}
	// En 30 días no se puede volver a pedir: no llega código.
	b.entregar()
	n := len(b.buzon.para(emailA))
	esperar(t, b.llamar("/cuenta/borrar-por-email", map[string]string{"email": emailA}), 200, "pedir otra vez")
	b.entregar()
	if len(b.buzon.para(emailA)) != n {
		t.Fatal("se puede volver a pedir antes de 30 días")
	}
	// Pasados los 30 días, «empezar de cero» desde un Mac nuevo sin nada, y nadie lo cancela.
	b.reloj.avanzar(30 * 24 * time.Hour)
	b.s.Tareas(t.Context())
	cero := nuevoMac("Cero")
	r = b.llamar("/cuenta/empezar-de-cero", map[string]string{"email": emailA})
	kl, ku := claves("otra contraseña", emailA)
	r = b.conPrueba(cero, "empezar-de-cero", "", "/cuenta/empezar-de-cero/confirmar", map[string]string{
		"solicitud": r.txt("solicitud"), "codigo": b.codigo(emailA), "kl": b64e(kl),
		"envoltura": b64e(envolver(ku, cero.semilla, emailA))})
	esperar(t, r, 200, "empezar de cero")
	b.reloj.avanzar(14*24*time.Hour + time.Minute)
	b.s.Tareas(t.Context())
	if len(b.cad.borradas) != 1 || b.cad.borradas[0] != a.cadena {
		t.Fatal("a los 14 días no se ha borrado la cadena vieja")
	}
	// La cuenta es ahora de la cadena nueva con la contraseña nueva.
	b.entrar(nuevoMac("Otro"), emailA, "otra contraseña")
	a.token = ""
	if r := b.conPrueba(a, "eventos", "", "/eventos", map[string]int{}); r.txt("estado") != "cadena-sustituida" {
		t.Fatalf("la cadena vieja: %v", r.cuerpo)
	}
}

// Respuestas iguales exista o no la cuenta (O1) en las llamadas sin sesión.
func TestSinEnumeracion(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)
	for _, ruta := range []string{"/alta", "/cuenta/borrar-por-email", "/cuenta/empezar-de-cero"} {
		r1 := b.llamar(ruta, map[string]string{"email": emailA})
		r2 := b.llamar(ruta, map[string]string{"email": "nadie@example.com"})
		if r1.codigo != r2.codigo || len(r1.cuerpo) != len(r2.cuerpo) || len(r1.txt("solicitud")) != len(r2.txt("solicitud")) {
			t.Fatalf("%s distingue: %v / %v", ruta, r1.cuerpo, r2.cuerpo)
		}
	}
	// Una solicitud falsa se comporta como una verdadera con el ritmo de 10 s.
	falsa := b.llamar("/alta", map[string]string{"email": emailA}).txt("solicitud") // ya tiene cuenta: falsa
	pedir := map[string]string{"solicitud": falsa, "codigo": "AAAA-AAAA"}
	esperar(t, b.llamar("/cuenta/borrar-por-email/confirmar", pedir), http.StatusForbidden, "falsa, primer intento")
	esperar(t, b.llamar("/cuenta/borrar-por-email/confirmar", pedir), http.StatusTooManyRequests, "falsa, antes de 10 s")
}

// P12: inactividad con plazos cortos: aviso por correo a (días − aviso) y borrado de cuenta, cadena y email a los
// días. Una cuenta cuya cadena se borró por el protocolo de sync se borra también.
func TestInactivas(t *testing.T) {
	b := nuevoBanco(t, func(c *Config) { c.InactivasDias, c.AvisoDias = 2, 1 })
	a, z := nuevoMac("A"), nuevoMac("Z")
	b.crearCuenta(a, emailA, clave)
	b.crearCuenta(z, "zeta@example.com", clave)
	b.cad.ultima[a.cadena] = b.reloj.ahora().UnixMilli()
	b.cad.ultima[z.cadena] = b.reloj.ahora().UnixMilli()
	b.reloj.avanzar(36 * time.Hour)
	b.cad.ultima[z.cadena] = b.reloj.ahora().UnixMilli()
	b.s.Tareas(t.Context())
	b.entregar()
	if cs := b.buzon.para(emailA); !strings.Contains(cs[len(cs)-1].cuerpo, "casi un año sin uso") {
		t.Fatal("no llega el aviso de inactividad")
	}
	b.reloj.avanzar(13 * time.Hour)
	b.s.Tareas(t.Context())
	var n int
	b.s.cfg.DB.QueryRow(`SELECT COUNT(*) FROM cuentas`).Scan(&n)
	if n != 1 || !b.cad.desactivadas[a.cadena] || b.cad.desactivadas[z.cadena] {
		t.Fatalf("inactivas: %d cuentas; A borrada %v; Z borrada %v", n, b.cad.desactivadas[a.cadena], b.cad.desactivadas[z.cadena])
	}
	// La cadena de Z se borra desde un Mac sin cuenta (protocolo de sync): la cuenta se va con ella, con el borrado
	// normal de 14 días y su aviso (decisión 12); un Mac lo puede cancelar y no se reprograma en 30 días.
	b.cad.desactivadas[z.cadena] = true
	b.s.Tareas(t.Context())
	b.entregar()
	if cs := b.buzon.para("zeta@example.com"); !strings.Contains(cs[len(cs)-1].cuerpo, "dentro de 14 días") {
		t.Fatal("no llega el aviso del borrado programado")
	}
	z.token = ""
	r := b.deMac(z, "eventos", "/eventos", map[string]int{"desde": 0})
	if r.txt("estado") != "borrado-programado" {
		t.Fatalf("estado: %v", r.cuerpo)
	}
	b.reloj.avanzar(13 * 24 * time.Hour)
	b.s.Tareas(t.Context())
	b.s.cfg.DB.QueryRow(`SELECT COUNT(*) FROM cuentas`).Scan(&n)
	if n != 1 {
		t.Fatal("la cuenta se ha borrado antes de 14 días")
	}
	b.reloj.avanzar(24*time.Hour + time.Minute)
	b.s.Tareas(t.Context())
	b.s.cfg.DB.QueryRow(`SELECT COUNT(*) FROM cuentas`).Scan(&n)
	if n != 0 {
		t.Fatal("a los 14 días queda una cuenta con la cadena borrada")
	}
}

// Decisión 12, cancelada: un Mac cancela el borrado de la cuenta huérfana y no se reprograma en 30 días.
func TestHuerfanaCancelada(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)
	b.cad.desactivadas[a.cadena] = true
	b.s.Tareas(t.Context())
	r := b.deMac(a, "borrado-cancelar", "/cuenta/borrar/cancelar", map[string]any{})
	if r.cuerpo["cancelado"] != true {
		t.Fatalf("cancelar: %v", r.cuerpo)
	}
	b.reloj.avanzar(29 * 24 * time.Hour)
	b.s.Tareas(t.Context())
	a.token = ""
	if r := b.deMac(a, "eventos", "/eventos", map[string]int{}); r.txt("estado") != "activa" {
		t.Fatalf("se ha reprogramado antes de 30 días: %v", r.cuerpo)
	}
	b.reloj.avanzar(2 * 24 * time.Hour)
	b.s.Tareas(t.Context())
	if r := b.deMac(a, "eventos", "/eventos", map[string]int{}); r.txt("estado") != "borrado-programado" {
		t.Fatalf("pasados 30 días no se reprograma: %v", r.cuerpo)
	}
}

func TestNormalizarEmail(t *testing.T) {
	for in, want := range map[string]string{" Ana@Example.COM ": "ana@example.com", "a.b+c@d.example": "a.b+c@d.example"} {
		if got, ok := NormalizarEmail(in); !ok || got != want {
			t.Errorf("%q → %q %v", in, got, ok)
		}
	}
	for _, mal := range []string{"", "ana", "ana@", "@x.com", "ana@x", "a b@x.com", "ana@x.com\r\nBcc: z@x.com",
		"Ana <ana@x.com>", "a@b@x.com", "a,b@x.com"} {
		if _, ok := NormalizarEmail(mal); ok {
			t.Errorf("%q no debería valer", mal)
		}
	}
}

// S2 [C]: «eventos» da el email solo con prueba de cadena, nunca con el token.
func TestEmailSoloConPrueba(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)
	r := b.conToken(a, "/eventos", map[string]int{})
	esperar(t, r, 200, "eventos con token")
	if _, hay := r.cuerpo["email"]; hay {
		t.Fatal("con el token se ve el email")
	}
	r = b.deMac(a, "eventos", "/eventos", map[string]int{})
	if r.txt("email") != emailA {
		t.Fatalf("con prueba de cadena no llega el email: %v", r.cuerpo)
	}
	palabras := nuevoMac("Con palabras")
	palabras.ponerSemilla(a.semilla)
	if r := b.conPrueba(palabras, "eventos", "", "/eventos", map[string]int{}); r.txt("email") != emailA {
		t.Fatalf("un Mac unido con las palabras no recibe el email: %v", r.cuerpo)
	}
}

// datosDe: el «datos» del último evento de ese tipo.
func datosDe(t *testing.T, es []map[string]any, tipo string) map[string]any {
	t.Helper()
	for i := len(es) - 1; i >= 0; i-- {
		if es[i]["tipo"] == tipo {
			d, _ := es[i]["datos"].(map[string]any)
			if d == nil {
				d = map[string]any{}
			}
			return d
		}
	}
	t.Fatalf("no hay evento %s", tipo)
	return nil
}

// S3 [C]: datos.aparato solo con autor verificado (token Bearer, token nuevo en contrasena/cambiar y
// cadena/cambiar, el nuevo de mac-anadido); el «aparato» del cuerpo no se refleja.
func TestAutorDeLosEventos(t *testing.T) {
	b := nuevoBanco(t, nil)
	a, m, ladron := nuevoMac("A"), nuevoMac("B"), nuevoMac("Robado")
	b.crearCuenta(a, emailA, clave)
	b.entrar(m, emailA, clave)
	b.reloj.avanzar(time.Hour)
	b.entrar(ladron, emailA, clave)
	es := b.eventos(a)
	if d := datosDe(t, es, evMacAnadido); d["aparato"] != ladron.aparato {
		t.Fatalf("mac-anadido sin el aparato nuevo: %v", d)
	}
	if d := datosDe(t, es, evCadenaLigada); d["aparato"] != a.aparato {
		t.Fatalf("cadena-ligada sin el aparato: %v", d)
	}
	// Con el token de A: el autor es A.
	esperar(t, b.deMac(a, "aparatos-renombrar", "/aparatos/renombrar", map[string]string{"aparato": m.aparato,
		"nombre": "B2"}), 200, "renombrar")
	if d := datosDe(t, b.eventos(a), evAparatoRenombrado); d["aparato"] != a.aparato {
		t.Fatalf("renombrar con token: %v", d)
	}
	// El ladrón, sin token, pone en el cuerpo el aparato de A: no se refleja.
	sinToken := *ladron
	sinToken.token = ""
	esperar(t, b.deMac(&sinToken, "salir", "/salir", map[string]string{"aparato": a.aparato}), 200, "salir con el aparato de A")
	if d := datosDe(t, b.eventos(m), evAparatoQuitado); d["aparato"] != nil {
		t.Fatalf("el «aparato» del cuerpo se refleja como autor: %v", d)
	}
	// Con su propio token, el autor es el ladrón, no el aparato del cuerpo.
	esperar(t, b.deMac(ladron, "aparatos-quitar", "/aparatos/quitar", map[string]string{"aparato": m.aparato}), 200, "quitar")
	if d := datosDe(t, b.eventos(ladron), evAparatoQuitado); d["aparato"] != ladron.aparato {
		t.Fatalf("quitar con token: %v", d)
	}
	// Un token de otra cuenta no cuenta como autor.
	otro := nuevoMac("Otra cuenta")
	b.crearCuenta(otro, "otra@example.com", clave)
	conTokenAjeno := sinToken
	conTokenAjeno.token = otro.token
	esperar(t, b.deMac(&conTokenAjeno, "no-he-sido-yo", "/no-he-sido-yo", map[string]any{}), 200, "no he sido yo")
	if d := datosDe(t, b.eventos(&sinToken), evNoHeSidoYo); d["aparato"] != nil {
		t.Fatalf("un token de otra cuenta se toma como autor: %v", d)
	}
	// Cambio de contraseña: el aparato que recibe el token nuevo (el ladrón ya quitó a A y a B de la lista).
	b.cambiarContrasena(ladron, emailA, "nueva 3")
	if d := datosDe(t, b.eventos(&sinToken), evContrasenaCambiada); d["aparato"] != ladron.aparato {
		t.Fatalf("contrasena-cambiada: %v", d)
	}
}
