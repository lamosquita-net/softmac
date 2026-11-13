// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// Package cuenta: la cuenta de la sincronización de FlyWeb 3.2 (FlyWeb/docs/sync-cuenta.md, hito H2).
//
// La cuenta lleva la semilla de la cadena a un Mac nuevo con email + contraseña + código por email. El servidor
// guarda la semilla envuelta dos veces (E, que hace el Mac con una clave que sale de la contraseña, y EE = E
// cifrada otra vez con KW) y un verificador de la clave de entrada KL; no ve la contraseña ni la semilla.
// Rutas POST /cuenta/v1/..., en el mismo binario y el mismo sync.db que go-sync. El protocolo de go-sync no cambia.
package cuenta

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"io"
	"mime"
	"net/http"
	"strings"
	"sync/atomic"
	"time"
	"unicode"
	"unicode/utf8"

	"github.com/go-chi/chi/v5"
	"github.com/rs/zerolog/log"
)

// Cadenas es lo que la cuenta necesita de go-sync (lo implementa el almacén SQLite de main).
type Cadenas interface {
	// Desactivada: la cadena se borró (DisableSyncChain).
	Desactivada(ctx context.Context, cadena string) (bool, error)
	// Borrar: DisableSyncChain + ClearServerData, como «Borrar datos de sincronización».
	Borrar(ctx context.Context, cadena string) error
	// UltimaEscritura: mtime (ms) de la última escritura de la cadena; hay = false si no tiene datos.
	UltimaEscritura(ctx context.Context, cadena string) (ms int64, hay bool, err error)
}

type Config struct {
	DB      *sql.DB
	Cadenas Cadenas
	HMAC    *Credencial // email_hmac
	AES     *Credencial // email y nombres de los Macs
	Correo  Enviador
	Desde   string // remitente: noreply@ del dominio de FlyWeb

	CorreosHora     int           // cupo (2) global; FLYWEB_SYNC_CORREOS_HORA = 60
	CorreosAltaHora int           // cupo (1); FLYWEB_SYNC_CORREOS_ALTA_HORA = 20
	EsperaBase      time.Duration // 10 s
	EsperaTope      time.Duration // FLYWEB_SYNC_ESPERA_TOPE_MIN = 15
	EsperasMax      int           // tamaño de la tabla de esperas
	ScryptALaVez    int           // FLYWEB_SYNC_SCRYPT_A_LA_VEZ (núcleos)
	ScryptCola      int           // longitud de la cola del semáforo
	ScryptEspera    time.Duration // FLYWEB_SYNC_SCRYPT_COLA_S = 25
	Demora          time.Duration // FLYWEB_SYNC_DEMORA_DIAS = 14
	InactivasDias   int           // FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS (0 = no)
	AvisoDias       int           // FLYWEB_SYNC_AVISO_DIAS = 30
	SolicitudesMax  int           // tope de intentos de código con solicitud falsa en 10 s

	Estirar func(kl, sal []byte) []byte // por defecto EstirarScrypt
	Ahora   func() time.Time
}

// Plazos fijos del diseño.
const (
	vidaToken       = 180 * 24 * time.Hour // sin uso (§10, O2)
	vidaEvento      = 30 * 24 * time.Hour  // provisional: §7 no lo fija (pregunta 2 a COORDINACIÓN)
	vidaSustituida  = 30 * 24 * time.Hour  // marca «cadena sustituida» (§6.3)
	trasCancelacion = 30 * 24 * time.Hour  // un borrado por email cada 30 días tras cancelarlo (§6.4, O10)
	ritmoFallos     = time.Hour            // aviso de fallos de contraseña: como mucho uno por hora (§6.2)
	maxCuerpo       = 64 << 10
)

type Servicio struct {
	cfg     Config
	alm     *almacen
	nonces  *nonces
	esperas *Esperas
	sem     *Semaforo
	sol     *solicitudes
	cupos   *cupos
	correo  *colaCorreo

	borradas, anadidos atomic.Int64 // contadores anónimos (§9)
}

func Nuevo(ctx context.Context, cfg Config) (*Servicio, error) {
	if cfg.DB == nil || cfg.Cadenas == nil || cfg.HMAC == nil || cfg.AES == nil || cfg.Correo == nil {
		return nil, errors.New("cuenta: falta configuración")
	}
	if _, ok := NormalizarEmail(cfg.Desde); !ok {
		return nil, errors.New("cuenta: remitente de correo no válido")
	}
	if cfg.Ahora == nil {
		cfg.Ahora = time.Now
	}
	if cfg.Estirar == nil {
		cfg.Estirar = EstirarScrypt
	}
	por := func(v *int, d int) {
		if *v <= 0 {
			*v = d
		}
	}
	porD := func(v *time.Duration, d time.Duration) {
		if *v <= 0 {
			*v = d
		}
	}
	por(&cfg.CorreosHora, 60)
	por(&cfg.CorreosAltaHora, 20)
	por(&cfg.EsperasMax, 90000)
	por(&cfg.ScryptALaVez, 1)
	por(&cfg.ScryptCola, 4*cfg.ScryptALaVez)
	por(&cfg.AvisoDias, 30)
	por(&cfg.SolicitudesMax, 50000)
	porD(&cfg.EsperaBase, 10*time.Second)
	porD(&cfg.EsperaTope, 15*time.Minute)
	porD(&cfg.ScryptEspera, 25*time.Second)
	porD(&cfg.Demora, 14*24*time.Hour)
	s := &Servicio{
		cfg:     cfg,
		alm:     &almacen{cfg.DB},
		nonces:  nuevosNonces(cfg.Ahora),
		esperas: NuevasEsperas(cfg.EsperasMax, cfg.EsperaBase, cfg.EsperaTope, cfg.Ahora),
		sem:     NuevoSemaforo(cfg.ScryptALaVez, cfg.ScryptCola, cfg.ScryptEspera),
		sol:     nuevasSolicitudes(cfg.SolicitudesMax, cfg.Ahora),
		cupos:   nuevosCupos(cfg.CorreosAltaHora, cfg.CorreosHora, cfg.Ahora),
		correo:  nuevaColaCorreo(cfg.Correo, cfg.Desde, cfg.Ahora),
	}
	if err := s.alm.crear(ctx); err != nil {
		return nil, err
	}
	return s, nil
}

// Funcionar arranca el repartidor de correo y las tareas periódicas hasta que se cancele ctx.
func (s *Servicio) Funcionar(ctx context.Context) {
	go s.correo.funcionar(ctx)
	go func() {
		t := time.NewTicker(time.Minute)
		defer t.Stop()
		ultimaHora := s.cfg.Ahora()
		for {
			select {
			case <-ctx.Done():
				return
			case <-t.C:
			}
			s.Tareas(ctx)
			if s.cfg.Ahora().Sub(ultimaHora) >= time.Hour {
				ultimaHora = s.cfg.Ahora()
				s.Contadores()
			}
		}
	}()
}

// Router: las rutas de §10. Solo POST con Content-Type: application/json (lo demás, 415) y ninguna cabecera CORS
// (C5): una web no puede disparar «alta» desde el navegador de quien la visita.
func (s *Servicio) Router() http.Handler {
	r := chi.NewRouter()
	rutas := map[string]func(*peticion) (int, any){
		"/nonce":                             s.nonce,
		"/alta":                              s.alta,
		"/alta/confirmar":                    s.altaConfirmar,
		"/entrar/empezar":                    s.entrarEmpezar,
		"/entrar/terminar":                   s.entrarTerminar,
		"/contrasena/codigo":                 s.contrasenaCodigo,
		"/contrasena/cambiar":                s.contrasenaCambiar,
		"/email/cambiar/empezar":             s.emailEmpezar,
		"/email/cambiar/terminar":            s.emailTerminar,
		"/cadena/cambiar":                    s.cadenaCambiar,
		"/aparatos/listar":                   s.aparatosListar,
		"/aparatos/quitar":                   s.aparatosQuitar,
		"/aparatos/renovar":                  s.aparatosRenovar,
		"/aparatos/renombrar":                s.aparatosRenombrar,
		"/eventos":                           s.eventos,
		"/no-he-sido-yo":                     s.noHeSidoYo,
		"/cuenta/borrar":                     s.cuentaBorrar,
		"/cuenta/borrar/cancelar":            s.borradoCancelar,
		"/cuenta/borrar-por-email":           s.borrarPorEmail,
		"/cuenta/borrar-por-email/confirmar": s.borrarPorEmailConfirmar,
		"/cuenta/empezar-de-cero":            s.empezarDeCero,
		"/cuenta/empezar-de-cero/confirmar":  s.empezarDeCeroConfirmar,
		"/salir":                             s.salir,
	}
	for ruta, h := range rutas {
		r.Post(ruta, s.manejar(h))
	}
	r.NotFound(func(w http.ResponseWriter, _ *http.Request) { responder(w, http.StatusNotFound, fallo("ruta")) })
	r.MethodNotAllowed(func(w http.ResponseWriter, _ *http.Request) {
		responder(w, http.StatusMethodNotAllowed, fallo("metodo"))
	})
	return r
}

type peticion struct {
	ctx    context.Context
	r      *http.Request
	cuerpo []byte
}

func (p *peticion) leer(v any) bool {
	return json.Unmarshal(p.cuerpo, v) == nil
}

type respuestaError struct {
	Error string `json:"error"`
	Hasta int64  `json:"hasta,omitempty"` // con «espera»: hora Unix a partir de la cual se puede volver a probar
}

func fallo(e string) respuestaError { return respuestaError{Error: e} }

// Errores, siempre los mismos textos (la página los traduce):
var (
	malaPeticion = func() (int, any) { return http.StatusBadRequest, fallo("peticion") }
	malaPrueba   = func() (int, any) { return http.StatusUnauthorized, fallo("prueba") }
	malToken     = func() (int, any) { return http.StatusUnauthorized, fallo("token") }
	// Un solo error para contraseña y código, sin decir cuál falla (O9).
	credenciales = func() (int, any) { return http.StatusForbidden, fallo("credenciales") }
	sinCuenta    = func() (int, any) { return http.StatusNotFound, fallo("sin-cuenta") }
	ocupado      = func() (int, any) { return http.StatusServiceUnavailable, fallo("ocupado") }
	interno      = func() (int, any) { return http.StatusInternalServerError, fallo("interno") }
)

func espera(hasta time.Time) (int, any) {
	// Hacia arriba al segundo: «a partir de» nunca antes de que acabe.
	return http.StatusTooManyRequests, respuestaError{Error: "espera", Hasta: hasta.Add(time.Second - 1).Unix()}
}

func responder(w http.ResponseWriter, codigo int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(codigo)
	json.NewEncoder(w).Encode(v)
}

func (s *Servicio) manejar(h func(*peticion) (int, any)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if mt, _, err := mime.ParseMediaType(r.Header.Get("Content-Type")); err != nil || mt != "application/json" {
			responder(w, http.StatusUnsupportedMediaType, fallo("content-type"))
			return
		}
		cuerpo, err := io.ReadAll(http.MaxBytesReader(w, r.Body, maxCuerpo))
		if err != nil {
			responder(w, http.StatusRequestEntityTooLarge, fallo("tamano"))
			return
		}
		codigo, v := h(&peticion{ctx: r.Context(), r: r, cuerpo: cuerpo})
		responder(w, codigo, v)
	}
}

// --- campos de las peticiones ---

func b64(s string, largo int) ([]byte, bool) {
	b, err := base64.StdEncoding.DecodeString(s)
	return b, err == nil && len(b) == largo
}

func validoModelo(m string) bool {
	if m == "" || len(m) > 64 {
		return false
	}
	for _, r := range m {
		if !(r >= 'a' && r <= 'z' || r >= 'A' && r <= 'Z' || r >= '0' && r <= '9' || strings.ContainsRune(",._- ", r)) {
			return false
		}
	}
	return true
}

func validoNombre(n string) bool {
	if n == "" || !utf8.ValidString(n) || utf8.RuneCountInString(n) > 64 {
		return false
	}
	for _, r := range n {
		if unicode.IsControl(r) {
			return false
		}
	}
	return true
}

func nuevoID() string { return hex.EncodeToString(aleatorio(16)) }

// nuevoToken: 32 bytes aleatorios; el servidor guarda su SHA-256.
func nuevoToken() (string, []byte) {
	t := make([]byte, 32)
	rand.Read(t)
	return base64.RawURLEncoding.EncodeToString(t), sha(t)
}

func (s *Servicio) ahora() int64 { return s.cfg.Ahora().Unix() }

// --- email ---

func (s *Servicio) hmacs(email string) [][]byte {
	var hs [][]byte
	for _, v := range s.cfg.HMAC.versiones() {
		hs = append(hs, s.cfg.HMAC.hmacEmail(v, email))
	}
	return hs
}

// claveEspera: la clave de la tabla de esperas es el email_hmac con la versión actual de la clave.
func (s *Servicio) claveEspera(email string) string {
	return hex.EncodeToString(s.cfg.HMAC.hmacEmail(s.cfg.HMAC.actual, email))
}

func (s *Servicio) emailDe(c *registro) (string, error) {
	e, err := s.cfg.AES.abrir(c.aesV, c.emailHMAC, c.emailCifrado)
	return string(e), err
}

func asociadoNombre(aparatoID string) []byte { return []byte("aparato:" + aparatoID) }
func asociadoEE(cuentaID string) []byte      { return []byte("flyweb-ee-v1:" + cuentaID) }
func asociadoEvento(cuentaID, tipo string) []byte {
	return []byte("evento:" + cuentaID + ":" + tipo)
}

func (s *Servicio) nombreDe(ap *aparato) string {
	n, err := s.cfg.AES.abrir(ap.aesV, asociadoNombre(ap.id), ap.nombreCifrado)
	if err != nil {
		return ""
	}
	return string(n)
}

// --- estiramiento del servidor ---

// secreto calcula, de KL y una sal, el verificador y KW. Hay que tener turno en el semáforo.
func (s *Servicio) secreto(kl, sal []byte) (v, kw []byte) {
	return derivar(s.cfg.Estirar(kl, sal))
}

// nuevoSecreto: sal nueva, verificador y EE para una envoltura E.
func (s *Servicio) nuevoSecreto(cuentaID string, kl, e []byte) (sal, v, ee []byte) {
	sal = aleatorio(largoSal)
	v, kw := s.secreto(kl, sal)
	return sal, v, sellar(kw, e, asociadoEE(cuentaID))
}

// --- avisos ---

type datosEvento struct {
	Mac    string `json:"mac,omitempty"`
	Modelo string `json:"modelo,omitempty"`
	N      int64  `json:"n,omitempty"`
	Desde  int64  `json:"desde,omitempty"`
	Fecha  int64  `json:"fecha,omitempty"`
}

// evento deja un evento para los Macs de la cuenta (dentro de la transacción de la operación).
func (s *Servicio) evento(ctx context.Context, tx *sql.Tx, cuentaID, tipo string, d datosEvento) error {
	var datos []byte
	var v int
	if d != (datosEvento{}) {
		claro, _ := json.Marshal(d)
		datos, v = s.cfg.AES.sellar(asociadoEvento(cuentaID, tipo), claro)
	}
	_, err := anadirEvento(ctx, tx, cuentaID, tipo, s.ahora(), datos, v)
	return err
}

// avisar manda el correo de aviso (sin cupo, cola propia) a la dirección de la cuenta.
func (s *Servicio) avisar(c *registro, tipo, mac string) {
	email, err := s.emailDe(c)
	if err != nil {
		log.Error().Msg("cuenta: no se puede descifrar el email de una cuenta")
		return
	}
	s.avisarA(email, tipo, mac)
}

func (s *Servicio) avisarA(email, tipo, mac string) {
	asunto, cuerpo := textoAviso(tipo, mac)
	s.correo.poner(correoAviso, email, asunto, cuerpo, s.cfg.Ahora().Add(vidaAviso))
}

func (s *Servicio) mandarCodigo(email string, t tipoSolicitud, codigo string) {
	asunto, cuerpo := textoCodigo(t, codigo)
	clase := correoCodigo
	if t == solAlta {
		clase = correoAlta
	}
	s.correo.poner(clase, email, asunto, cuerpo, s.cfg.Ahora().Add(vidaCodigo))
}

// --- autenticación ---

// conPrueba verifica la prueba de cadena de una operación. Devuelve la cuenta ligada a la cadena (nil si no hay)
// y el código de error si falla. El nonce se gasta solo con una firma válida.
func (s *Servicio) conPrueba(p *peticion, op string) (*pruebaLeida, *registro, int, any) {
	pr, err := leerPrueba(p.r, s.nonces, "X-FlyWeb-Cadena", "X-FlyWeb-Prueba")
	if err != nil {
		c, v := malaPrueba()
		return nil, nil, c, v
	}
	c, err := s.alm.porCadena(p.ctx, pr.cadena)
	if err != nil {
		cod, v := interno()
		return nil, nil, cod, v
	}
	id := ""
	if c != nil {
		id = c.id
	}
	if !pr.verificar(op, id, p.cuerpo) || !s.nonces.gastar(pr.nonce, pr.caduca) {
		cod, v := malaPrueba()
		return nil, nil, cod, v
	}
	return pr, c, 0, nil
}

// conPruebaYCuenta: como conPrueba, pero la cadena tiene que tener cuenta.
func (s *Servicio) conPruebaYCuenta(p *peticion, op string) (*pruebaLeida, *registro, int, any) {
	pr, c, cod, v := s.conPrueba(p, op)
	if cod != 0 {
		return nil, nil, cod, v
	}
	if c == nil {
		cod, v := sinCuenta()
		return nil, nil, cod, v
	}
	return pr, c, 0, nil
}

// porToken lee «Authorization: Bearer» y devuelve su aparato si el token vale.
func (s *Servicio) porToken(p *peticion) (*aparato, error) {
	t, ok := strings.CutPrefix(p.r.Header.Get("Authorization"), "Bearer ")
	if !ok {
		return nil, nil
	}
	b, err := base64.RawURLEncoding.DecodeString(t)
	if err != nil || len(b) != 32 {
		return nil, nil
	}
	ahora := s.ahora()
	ap, err := s.alm.porToken(p.ctx, sha(b), ahora-int64(vidaToken/time.Second))
	if err != nil || ap == nil {
		return nil, err
	}
	if ahora-ap.ultimo >= 3600 { // una escritura por hora como mucho
		if err := s.alm.usado(p.ctx, ap.id, ahora); err != nil {
			return nil, err
		}
	}
	return ap, nil
}

// --- tareas periódicas ---

// Tareas: lo que se hace cada minuto (exportada para las pruebas).
func (s *Servicio) Tareas(ctx context.Context) {
	s.esperas.Purgar()
	s.sol.Purgar()
	s.cupos.Purgar()
	ahora := s.ahora()
	for _, f := range []func(context.Context, int64) error{s.avisarFallosPendientes, s.ejecutarVencidos,
		s.caducar, s.inactivas} {
		if err := f(ctx, ahora); err != nil {
			log.Error().Err(err).Msg("cuenta: tarea periódica")
		}
	}
}

// Contadores: una línea por hora, a nivel warn, sin identificar cadenas ni cuentas (§9).
func (s *Servicio) Contadores() {
	log.Warn().Int64("cuentas_borradas", s.borradas.Swap(0)).Int64("macs_anadidos", s.anadidos.Swap(0)).
		Int64("correos_altas", s.correo.altas.Swap(0)).Int64("correos_codigos", s.correo.codigos.Swap(0)).
		Int64("correos_avisos", s.correo.avisos.Swap(0)).Int64("scrypt_max_a_la_vez", s.sem.Maximo()).
		Msg("cuenta: contadores de la última hora")
}

func (s *Servicio) caducar(ctx context.Context, ahora int64) error {
	for _, q := range []struct {
		sql    string
		limite int64
	}{
		{`UPDATE cuenta_aparatos SET token_hash = NULL WHERE token_hash IS NOT NULL AND ultimo_uso < ?`, ahora - int64(vidaToken/time.Second)},
		{`DELETE FROM cuenta_eventos WHERE fecha < ?`, ahora - int64(vidaEvento/time.Second)},
		{`DELETE FROM cuenta_sustituidas WHERE fecha < ?`, ahora - int64(vidaSustituida/time.Second)},
		{`UPDATE cuentas SET cancelado = 0 WHERE cancelado != 0 AND cancelado < ?`, ahora - int64(trasCancelacion/time.Second)},
	} {
		if _, err := s.cfg.DB.ExecContext(ctx, q.sql, q.limite); err != nil {
			return err
		}
	}
	return nil
}
