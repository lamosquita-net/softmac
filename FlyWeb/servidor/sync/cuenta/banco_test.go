// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

// Banco de pruebas: servidor de cuentas por HTTP contra SQLite, con reloj, correo y cadenas de go-sync falsos, y
// «Macs» que hacen lo que hará el cliente (H3): claves de la contraseña, envoltura y prueba de cadena.

import (
	"bytes"
	"context"
	"crypto/aes"
	"crypto/cipher"
	"crypto/ed25519"
	"crypto/hkdf"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"io"
	"mime/quotedprintable"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
	"testing"
	"time"

	_ "modernc.org/sqlite"
)

type relojFalso struct {
	mu sync.Mutex
	t  time.Time
}

func (r *relojFalso) ahora() time.Time {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.t
}

func (r *relojFalso) avanzar(d time.Duration) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.t = r.t.Add(d)
}

type correoRecibido struct {
	para   string
	asunto string
	cuerpo string
}

type buzonFalso struct {
	mu       sync.Mutex
	recibido []correoRecibido
	caido    bool
}

func (b *buzonFalso) Enviar(_ context.Context, para string, m []byte) error {
	b.mu.Lock()
	defer b.mu.Unlock()
	if b.caido {
		return io.ErrUnexpectedEOF
	}
	cab, cuerpo, _ := bytes.Cut(m, []byte("\r\n\r\n"))
	claro, _ := io.ReadAll(quotedprintable.NewReader(bytes.NewReader(cuerpo)))
	asunto := ""
	for _, l := range strings.Split(string(cab), "\r\n") {
		if v, ok := strings.CutPrefix(l, "Subject: "); ok {
			asunto = v
		}
	}
	b.recibido = append(b.recibido, correoRecibido{para, asunto, string(claro)})
	return nil
}

func (b *buzonFalso) para(email string) []correoRecibido {
	b.mu.Lock()
	defer b.mu.Unlock()
	var r []correoRecibido
	for _, c := range b.recibido {
		if c.para == email {
			r = append(r, c)
		}
	}
	return r
}

var reCodigo = regexp.MustCompile(`[A-Z2-7]{4}-[A-Z2-7]{4}`)

type cadenasFalsas struct {
	mu           sync.Mutex
	desactivadas map[string]bool
	borradas     []string
	ultima       map[string]int64
}

func (c *cadenasFalsas) Desactivada(_ context.Context, cadena string) (bool, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.desactivadas[cadena], nil
}

func (c *cadenasFalsas) Borrar(_ context.Context, cadena string) error {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.desactivadas[cadena] = true
	c.borradas = append(c.borradas, cadena)
	return nil
}

func (c *cadenasFalsas) UltimaEscritura(_ context.Context, cadena string) (int64, bool, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	m, ok := c.ultima[cadena]
	return m, ok, nil
}

// estirarBarato sustituye al scrypt del servidor en las pruebas (el real tarda ~50 ms y reserva 16 MiB).
func estirarBarato(kl, sal []byte) []byte {
	h := sha256.Sum256(append(append([]byte("barato"), kl...), sal...))
	return h[:]
}

type banco struct {
	t         *testing.T
	s         *Servicio
	url       string
	reloj     *relojFalso
	buzon     *buzonFalso
	cad       *cadenasFalsas
	ruta      string // del fichero de SQLite
	estiradas sync.Map
}

func nuevoBanco(t *testing.T, ajustar func(*Config)) *banco {
	t.Helper()
	ruta := filepath.Join(t.TempDir(), "sync.db")
	db, err := sql.Open("sqlite", "file:"+ruta+"?_pragma=busy_timeout(10000)&_txlock=immediate")
	if err != nil {
		t.Fatal(err)
	}
	db.SetMaxOpenConns(1)
	t.Cleanup(func() { db.Close() })
	b := &banco{t: t, reloj: &relojFalso{t: time.Date(2026, 11, 13, 12, 0, 0, 0, time.UTC)}, buzon: &buzonFalso{},
		cad: &cadenasFalsas{desactivadas: map[string]bool{}, ultima: map[string]int64{}}, ruta: ruta}
	cfg := Config{DB: db, Cadenas: b.cad, HMAC: NuevaCredencial(aleatorio(32)), AES: NuevaCredencial(aleatorio(32)),
		Correo: b.buzon, Desde: "noreply@flyweb.example", Estirar: estirarBarato, Ahora: b.reloj.ahora,
		ScryptALaVez: 4}
	if ajustar != nil {
		ajustar(&cfg)
	}
	b.s, err = Nuevo(context.Background(), cfg)
	if err != nil {
		t.Fatal(err)
	}
	srv := httptest.NewServer(b.s.Router())
	t.Cleanup(srv.Close)
	b.url = srv.URL
	return b
}

// entregar reparte la cola de correo (en producción lo hace un repartidor en segundo plano).
func (b *banco) entregar() { b.s.correo.repartir(context.Background()) }

// codigo: el último código que ha llegado a esa dirección.
func (b *banco) codigo(email string) string {
	b.t.Helper()
	b.entregar()
	cs := b.buzon.para(email)
	for i := len(cs) - 1; i >= 0; i-- {
		if c := reCodigo.FindString(cs[i].cuerpo); c != "" {
			return c
		}
	}
	b.t.Fatalf("no ha llegado ningún código a %s", email)
	return ""
}

type respuesta struct {
	codigo int
	cuerpo map[string]any
	cab    http.Header
}

func (r respuesta) txt(k string) string { s, _ := r.cuerpo[k].(string); return s }
func (r respuesta) num(k string) int64  { f, _ := r.cuerpo[k].(float64); return int64(f) }

func (b *banco) pedir(ruta string, cuerpo []byte, cab map[string]string) respuesta {
	b.t.Helper()
	req, _ := http.NewRequest("POST", b.url+ruta, bytes.NewReader(cuerpo))
	req.Header.Set("Content-Type", "application/json")
	for k, v := range cab {
		req.Header.Set(k, v)
	}
	r, err := http.DefaultClient.Do(req)
	if err != nil {
		b.t.Fatal(err)
	}
	defer r.Body.Close()
	out := respuesta{codigo: r.StatusCode, cuerpo: map[string]any{}, cab: r.Header}
	json.NewDecoder(r.Body).Decode(&out.cuerpo)
	return out
}

func cuerpoJSON(v any) []byte {
	b, _ := json.Marshal(v)
	return b
}

// llamar sin autenticación.
func (b *banco) llamar(ruta string, v any) respuesta {
	b.t.Helper()
	return b.pedir(ruta, cuerpoJSON(v), nil)
}

func (b *banco) nonce() []byte {
	b.t.Helper()
	r := b.llamar("/nonce", map[string]any{})
	n, err := base64.RawURLEncoding.DecodeString(r.txt("nonce"))
	if err != nil || r.codigo != 200 {
		b.t.Fatalf("nonce: %d %v", r.codigo, r.cuerpo)
	}
	return n
}

// mac: un Mac con su semilla y su clave de cadena, y lo que sabe de la cuenta.
type mac struct {
	semilla []byte
	sk      ed25519.PrivateKey
	cadena  string
	cuenta  string
	aparato string
	token   string
	nombre  string
}

func nuevoMac(nombre string) *mac {
	m := &mac{semilla: aleatorio(32), nombre: nombre}
	m.ponerSemilla(m.semilla)
	return m
}

func (m *mac) ponerSemilla(s []byte) {
	m.semilla = s
	h := sha256.Sum256(append([]byte("cadena"), s...))
	m.sk = ed25519.NewKeyFromSeed(h[:])
	m.cadena = strings.ToUpper(hex.EncodeToString(m.sk.Public().(ed25519.PublicKey)))
}

// claves: lo que calcula el Mac de la contraseña (§4.2-4.3). El scrypt de 128 MiB del cliente se cambia aquí por
// un resumen: al servidor solo le llega KL.
func claves(contrasena, email string) (kl, ku []byte) {
	ke := sha256.Sum256([]byte("flyweb-cuenta-v1" + email + "\x00" + contrasena))
	kl, _ = hkdf.Key(sha256.New, ke[:], nil, "flyweb-cuenta-v1/entrar", 32)
	ku, _ = hkdf.Key(sha256.New, ke[:], nil, "flyweb-cuenta-v1/envolver", 32)
	return kl, ku
}

func asociadoEnvoltura(email string) []byte {
	h := sha256.Sum256([]byte(email))
	return append([]byte("flyweb-envoltura-v1"), h[:]...)
}

func envolver(ku, semilla []byte, email string) []byte {
	return sellar(ku, semilla, asociadoEnvoltura(email))
}

func desenvolver(ku, e []byte, email string) ([]byte, error) {
	blk, _ := aes.NewCipher(ku)
	g, _ := cipher.NewGCM(blk)
	return g.Open(nil, e[:12], e[12:], asociadoEnvoltura(email))
}

func b64e(b []byte) string { return base64.StdEncoding.EncodeToString(b) }

// firmante: una prueba de cadena en las cabeceras dadas.
type firmante struct {
	m         *mac
	cabCadena string
	cabFirma  string
}

// conPrueba hace una llamada con prueba de cadena de m (y de los demás firmantes, con el mismo nonce).
func (b *banco) conPrueba(m *mac, op, cuentaID, ruta string, v any, otros ...firmante) respuesta {
	b.t.Helper()
	cuerpo := cuerpoJSON(v)
	n := b.nonce()
	cab := map[string]string{"X-FlyWeb-Nonce": base64.RawURLEncoding.EncodeToString(n)}
	for _, f := range append([]firmante{{m, "X-FlyWeb-Cadena", "X-FlyWeb-Prueba"}}, otros...) {
		cab[f.cabCadena] = f.m.cadena
		cab[f.cabFirma] = b64e(FirmarPrueba(f.m.sk, op, cuentaID, n, cuerpo))
	}
	if m.token != "" {
		cab["Authorization"] = "Bearer " + m.token
	}
	return b.pedir(ruta, cuerpo, cab)
}

// deMac: llamada con prueba de cadena firmada sobre la cuenta que el Mac conoce.
func (b *banco) deMac(m *mac, op, ruta string, v any) respuesta {
	b.t.Helper()
	return b.conPrueba(m, op, m.cuenta, ruta, v)
}

func (b *banco) conToken(m *mac, ruta string, v any) respuesta {
	b.t.Helper()
	return b.pedir(ruta, cuerpoJSON(v), map[string]string{"Authorization": "Bearer " + m.token})
}

func esperar(t *testing.T, r respuesta, codigo int, que string) {
	t.Helper()
	if r.codigo != codigo {
		t.Fatalf("%s: %d %v, se esperaba %d", que, r.codigo, r.cuerpo, codigo)
	}
}

// crearCuenta: el Mac m (con su cadena) crea la cuenta con email y contraseña (P1).
func (b *banco) crearCuenta(m *mac, email, contrasena string) {
	b.t.Helper()
	r := b.llamar("/alta", map[string]string{"email": email})
	esperar(b.t, r, 200, "alta")
	kl, ku := claves(contrasena, email)
	r = b.conPrueba(m, "alta", "", "/alta/confirmar", map[string]string{"solicitud": r.txt("solicitud"),
		"codigo": b.codigo(email), "kl": b64e(kl), "envoltura": b64e(envolver(ku, m.semilla, email)),
		"modelo": "MacPro7,1", "nombre": m.nombre})
	esperar(b.t, r, 200, "alta/confirmar")
	m.cuenta, m.aparato, m.token = r.txt("cuenta"), r.txt("aparato"), r.txt("token")
}

// empezarEntrada: entrar/empezar; devuelve la respuesta.
func (b *banco) empezarEntrada(email, contrasena string) respuesta {
	b.t.Helper()
	kl, _ := claves(contrasena, email)
	return b.llamar("/entrar/empezar", map[string]string{"email": email, "kl": b64e(kl)})
}

// entrar: un Mac nuevo entra con email + contraseña + código (P2) y se queda la semilla.
func (b *banco) entrar(m *mac, email, contrasena string) {
	b.t.Helper()
	r := b.empezarEntrada(email, contrasena)
	esperar(b.t, r, 200, "entrar/empezar")
	kl, ku := claves(contrasena, email)
	r = b.llamar("/entrar/terminar", map[string]string{"solicitud": r.txt("solicitud"), "codigo": b.codigo(email),
		"kl": b64e(kl), "modelo": "MacPro6,1", "nombre": m.nombre})
	esperar(b.t, r, 200, "entrar/terminar")
	e, _ := base64.StdEncoding.DecodeString(r.txt("envoltura"))
	semilla, err := desenvolver(ku, e, email)
	if err != nil {
		b.t.Fatalf("la envoltura no abre: %v", err)
	}
	m.ponerSemilla(semilla)
	m.cuenta, m.aparato, m.token = r.txt("cuenta"), r.txt("aparato"), r.txt("token")
}

// eventos de la cuenta, con prueba de cadena.
func (b *banco) eventos(m *mac) []map[string]any {
	b.t.Helper()
	r := b.deMac(m, "eventos", "/eventos", map[string]int{"desde": 0})
	esperar(b.t, r, 200, "eventos")
	var es []map[string]any
	for _, e := range r.cuerpo["eventos"].([]any) {
		es = append(es, e.(map[string]any))
	}
	return es
}

func tipos(es []map[string]any) []string {
	var ts []string
	for _, e := range es {
		ts = append(ts, e["tipo"].(string))
	}
	return ts
}

func cuenta(ts []string, tipo string) int {
	n := 0
	for _, t := range ts {
		if t == tipo {
			n++
		}
	}
	return n
}
