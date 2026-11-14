// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"crypto/ed25519"
	"fmt"
	"net/http"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

func ed25519Sign(m *mac, msg []byte) []byte { return ed25519.Sign(m.sk, msg) }

// N6, en la tabla sola: una entrada en espera no se descarta nunca; con la tabla llena de esperas, un email nuevo
// recibe la máxima; se descarta antes la de espera más corta y, entre iguales, la más antigua.
func TestTablaDeEsperas(t *testing.T) {
	r := &relojFalso{t: time.Unix(1_800_000_000, 0)}
	e := NuevasEsperas(4, 10*time.Second, 15*time.Minute, r.ahora)
	// «atacada» llega al tope: 8 intentos, esperando cada vez lo que toca.
	for i := range 8 {
		if ok, _ := e.Anotar("atacada"); !ok {
			t.Fatalf("intento %d", i)
		}
		r.t = e.Hasta("atacada")
	}
	if ok, h := e.Anotar("atacada"); !ok || h.IsZero() == false {
		t.Fatal("tras esperar, se puede volver a intentar")
	}
	if d := e.Hasta("atacada").Sub(r.ahora()); d != 15*time.Minute {
		t.Fatalf("espera a tope = %v", d)
	}
	// La tabla (4) se llena con emails inventados en espera: «atacada» sigue a tope.
	for i := range 3 {
		if ok, _ := e.Anotar(fmt.Sprint("inventado", i)); !ok {
			t.Fatal("hay sitio")
		}
	}
	ok, h := e.Anotar("nuevo")
	if ok || h.Sub(r.ahora()) != 15*time.Minute {
		t.Fatalf("con la tabla llena de esperas, un email nuevo: ok=%v espera=%v", ok, h.Sub(r.ahora()))
	}
	if d := e.Hasta("atacada").Sub(r.ahora()); d != 15*time.Minute {
		t.Fatalf("la entrada atacada ha perdido su espera: %v", d)
	}
	// Pasados 10 s, las inventadas han cumplido (nivel 1) y la atacada no: sale la inventada más antigua.
	r.avanzar(10 * time.Second)
	if ok, _ := e.Anotar("nuevo"); !ok {
		t.Fatal("debería haber hueco")
	}
	if e.Len() != 4 || !e.Hasta("inventado0").IsZero() || e.m["inventado0"] != nil {
		t.Fatal("no se ha descartado la inventada más antigua")
	}
	if d := e.Hasta("atacada").Sub(r.ahora()); d != 15*time.Minute-10*time.Second {
		t.Fatalf("la atacada: %v", d)
	}
	// Una vez cumplida su espera de 15 min, la atacada sale la última: antes, todas las de nivel menor.
	r.avanzar(15 * time.Minute)
	for i := range 3 {
		e.Anotar(fmt.Sprint("otro", i))
	}
	if e.m["atacada"] == nil {
		t.Fatal("la atacada ha salido antes que las de espera más corta")
	}
	// A las 24 h sin intentos, todo vuelve a cero.
	r.avanzar(24 * time.Hour)
	e.Purgar()
	if e.Len() != 0 {
		t.Fatalf("quedan %d entradas caducadas", e.Len())
	}
}

// P24: avalancha de entrar/empezar con emails inventados, más a la vez que el máximo de scrypt. Nunca hay más
// scrypt en curso que el máximo; las de más esperan en cola y, si no les llega el turno, «ocupado» (no cuenta como
// intento); mientras, quien ya sincroniza lee eventos sin esperar. Con una tabla de esperas reducida: tras llenarla
// con emails inventados, el email que estaba a tope sigue a tope, y con la tabla llena de esperas un email nuevo
// recibe la máxima sin que se calcule nada.
func TestAvalancha(t *testing.T) {
	const aLaVez = 2
	var enCurso, maximo, calculos atomic.Int64
	soltar := make(chan struct{})
	var bloquear atomic.Bool
	estirar := func(kl, sal []byte) []byte {
		n := enCurso.Add(1)
		defer enCurso.Add(-1)
		for m := maximo.Load(); n > m && !maximo.CompareAndSwap(m, n); m = maximo.Load() {
		}
		calculos.Add(1)
		if bloquear.Load() {
			<-soltar
		}
		return estirarBarato(kl, sal)
	}
	b := nuevoBanco(t, func(c *Config) {
		c.ScryptALaVez, c.ScryptCola, c.ScryptEspera = aLaVez, 3, 300*time.Millisecond
		c.EsperasMax = 8
		c.Estirar = estirar
	})
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)

	// Avalancha: 12 peticiones a la vez con el scrypt detenido.
	bloquear.Store(true)
	var wg sync.WaitGroup
	codigos := make(chan int, 12)
	for i := range 12 {
		wg.Go(func() {
			codigos <- b.empezarEntrada(fmt.Sprintf("inventado%d@example.com", i), "x").codigo
		})
	}
	// Mientras: los eventos no pasan por el semáforo.
	time.Sleep(100 * time.Millisecond)
	inicio := time.Now()
	esperar(t, b.conToken(a, "/eventos", map[string]int{}), 200, "eventos durante la avalancha")
	if d := time.Since(inicio); d > 200*time.Millisecond {
		t.Fatalf("los eventos tardan %v durante la avalancha", d)
	}
	time.Sleep(400 * time.Millisecond) // pasa la espera de la cola
	close(soltar)
	wg.Wait()
	close(codigos)
	cuenta := map[int]int{}
	for c := range codigos {
		cuenta[c]++
	}
	if maximo.Load() > aLaVez || b.s.sem.Maximo() > aLaVez {
		t.Fatalf("scrypt a la vez: %d (máximo %d)", maximo.Load(), aLaVez)
	}
	if cuenta[200] != aLaVez || cuenta[http.StatusServiceUnavailable] != 12-aLaVez {
		t.Fatalf("respuestas: %v", cuenta)
	}
	// «Ocupado» no cuenta como intento: solo 2 entradas en la tabla.
	if n := b.s.esperas.Len(); n != aLaVez {
		t.Fatalf("entradas en la tabla de esperas: %d; «ocupado» no debe contar", n)
	}
	bloquear.Store(false)

	// La cuenta de A, a tope.
	var d time.Duration
	for range 8 {
		r := b.empezarEntrada(emailA, "mala")
		esperar(t, r, 200, "intento")
		h := b.s.esperas.Hasta(b.s.claveEspera(emailA))
		d = h.Sub(b.reloj.ahora())
		b.reloj.t = h
	}
	if d != 15*time.Minute {
		t.Fatalf("A no está a tope: %v", d)
	}
	esperar(t, b.empezarEntrada(emailA, "mala"), 200, "intento a tope")
	// Se llena la tabla (8) con emails inventados, cada uno con su intento.
	for i := range 20 {
		b.empezarEntrada(fmt.Sprintf("relleno%d@example.com", i), "x")
		b.reloj.avanzar(time.Second)
	}
	if d := b.s.esperas.Hasta(b.s.claveEspera(emailA)).Sub(b.reloj.ahora()); d < 14*time.Minute {
		t.Fatalf("la espera de A ha bajado a %v al llenar la tabla", d)
	}
	// Con la tabla llena de esperas, un email nuevo recibe la máxima y no se calcula nada.
	for i := range 8 {
		b.empezarEntrada(fmt.Sprintf("lleno%d@example.com", i), "x")
	}
	antes := calculos.Load()
	r := b.empezarEntrada("otro@example.com", "x")
	if r.codigo != http.StatusTooManyRequests || time.Unix(r.num("hasta"), 0).Sub(b.reloj.ahora()) < 15*time.Minute {
		t.Fatalf("email nuevo con la tabla llena: %d %v", r.codigo, r.cuerpo)
	}
	if calculos.Load() != antes {
		t.Fatal("con la tabla llena se ha calculado un scrypt")
	}
}

// El scrypt real: parámetros de §4.5 y 16 MiB por cálculo (aquí solo se comprueba que da 32 bytes estables).
func TestEstirarScrypt(t *testing.T) {
	if testing.Short() {
		t.Skip("scrypt real")
	}
	a, b := EstirarScrypt([]byte("kl"), []byte("sal")), EstirarScrypt([]byte("kl"), []byte("sal"))
	if len(a) != 32 || string(a) != string(b) {
		t.Fatal("scrypt")
	}
}

// O1 de SEGURIDAD-PORTES-23: el ritmo de los códigos va en una tabla fija, común a verdaderas y falsas. Con una sola
// casilla todas chocan: una colisión da una espera de más, igual para una solicitud verdadera que para una falsa, y
// nunca «ocupado». Las falsas no ocupan memoria.
func TestRitmoEnTablaFija(t *testing.T) {
	b := nuevoBanco(t, func(c *Config) { c.RitmoCasillas = 1 })
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)
	b.reloj.avanzar(time.Minute)
	falsa := b.llamar("/cuenta/borrar-por-email", map[string]string{"email": "nadie@example.com"}).txt("solicitud")
	verdadera := b.llamar("/cuenta/borrar-por-email", map[string]string{"email": emailA}).txt("solicitud")
	codigo := b.codigo(emailA)
	confirmar := func(sol, cod string) respuesta {
		return b.llamar("/cuenta/borrar-por-email/confirmar", map[string]string{"solicitud": sol, "codigo": cod})
	}
	esperar(t, confirmar(falsa, "AAAA-AAAA"), http.StatusForbidden, "falsa")
	r := confirmar(verdadera, codigo)
	esperar(t, r, http.StatusTooManyRequests, "la verdadera choca con la falsa en la misma casilla")
	b.reloj.avanzar(ritmoCodigo)
	esperar(t, confirmar(verdadera, codigo), 200, "la verdadera, pasados 10 s")
	antes := len(b.s.sol.m) // las verdaderas aplicadas se guardan hasta caducar (llamada repetida, §4.6)
	for range 1000 {
		b.reloj.avanzar(ritmoCodigo)
		confirmar(b.s.sol.falsa(), "AAAA-AAAA")
	}
	if len(b.s.sol.m) != antes {
		t.Fatalf("las falsas ocupan memoria: %d → %d", antes, len(b.s.sol.m))
	}
}
