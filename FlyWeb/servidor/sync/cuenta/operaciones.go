// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/base64"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/rs/zerolog/log"
)

func (s *Servicio) nonce(*peticion) (int, any) {
	return http.StatusOK, map[string]string{"nonce": base64.RawURLEncoding.EncodeToString(s.nonces.nuevo())}
}

type respSolicitud struct {
	Solicitud string `json:"solicitud"`
}

type respAparato struct {
	Cuenta    string `json:"cuenta,omitempty"`
	Aparato   string `json:"aparato,omitempty"`
	Token     string `json:"token,omitempty"`
	Envoltura string `json:"envoltura,omitempty"`
	Secreto   string `json:"secreto,omitempty"` // del aparato nuevo: el Mac lo guarda como el token (C1)
}

// --- alta (§8) ---

// alta: email → código. Igual exista o no la cuenta (O1); a una dirección que ya tiene cuenta no se manda nada
// (provisional, pregunta 3 a COORDINACIÓN). Cupo (1).
func (s *Servicio) alta(p *peticion) (int, any) {
	var q struct{ Email string }
	if !p.leer(&q) {
		return malaPeticion()
	}
	email, ok := NormalizarEmail(q.Email)
	if !ok {
		return malaPeticion()
	}
	c, err := s.alm.porEmail(p.ctx, s.hmacs(email))
	if err != nil {
		return interno()
	}
	if c != nil || !s.cupos.Alta() {
		return http.StatusOK, respSolicitud{s.sol.falsa()}
	}
	h := s.cfg.HMAC.hmacEmail(s.cfg.HMAC.actual, email)
	x := &solicitud{tipo: solAlta, emailHMAC: h, hmacV: s.cfg.HMAC.actual}
	x.emailCifrado, x.aesV = s.cfg.AES.sellar(h, []byte(email))
	codigo := s.sol.crear(x)
	s.mandarCodigo(email, solAlta, codigo)
	return http.StatusOK, respSolicitud{x.id}
}

type pedirConClave struct {
	Solicitud string
	Codigo    string
	KL        string `json:"kl"`
	Envoltura string
	Modelo    string
	Nombre    string
	Aparato   string
	Secreto   string // del aparato (C1)
}

func (q *pedirConClave) claves() (kl, e []byte, ok bool) {
	kl, ok1 := b64(q.KL, largoKL)
	e, ok2 := b64(q.Envoltura, largoEnvoltura)
	return kl, e, ok1 && ok2
}

// resumen de lo que pide una llamada repetible: KL y envoltura (§4.6, «si la respuesta se pierde»).
func resumen(kl, e []byte) []byte { return sha(append(append([]byte{}, kl...), e...)) }

// turno toma turno en el semáforo; si no llega, «ocupado».
func (s *Servicio) turno(ctx context.Context) bool { return s.sem.Entrar(ctx) == nil }

// alta/confirmar: código + prueba de cadena (cuenta_id vacío) + KL + envoltura + modelo y nombre del Mac →
// cuenta, aparato y token. Liga la cadena a la cuenta (operación «alta»; vale para una cadena que ya existe y para
// una recién creada).
func (s *Servicio) altaConfirmar(p *peticion) (int, any) {
	var q pedirConClave
	if !p.leer(&q) || !validoModelo(q.Modelo) || !validoNombre(q.Nombre) {
		return malaPeticion()
	}
	kl, e, ok := q.claves()
	if !ok {
		return malaPeticion()
	}
	// El Mac aún no sabe el id de la cuenta, tampoco si repite la llamada: firma con cuenta_id vacío.
	pr, cod, v := s.pruebaSinCuenta(p, "X-FlyWeb-Cadena", "X-FlyWeb-Prueba", "alta")
	if cod != 0 {
		return cod, v
	}
	if !s.turno(p.ctx) {
		return ocupado()
	}
	defer s.sem.Salir()
	x, res, hasta := s.sol.intentar(q.Solicitud, solAlta, q.Codigo)
	switch {
	case res == codigoEspera:
		return espera(hasta)
	case res != codigoBien:
		return credenciales()
	case x.aplicada != nil:
		if c, err := s.alm.porCadena(p.ctx, pr.cadena); err != nil || c == nil || c.id != x.cuentaID {
			return credenciales()
		}
		return s.repetida(p.ctx, x, resumen(kl, e), true, "")
	}
	if des, err := s.cfg.Cadenas.Desactivada(p.ctx, pr.cadena); err != nil {
		return interno()
	} else if des {
		return http.StatusConflict, fallo("cadena-borrada")
	}
	ahora := s.ahora()
	cu := &registro{id: nuevoID(), emailHMAC: x.emailHMAC, hmacV: x.hmacV, emailCifrado: x.emailCifrado,
		aesV: x.aesV, cadena: pr.cadena, creada: ahora}
	cu.sal, cu.verif, cu.ee = s.nuevoSecreto(cu.id, kl, e)
	ap := s.nuevoAparato(cu.id, q.Modelo, q.Nombre)
	err := s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		if libre, err := cadenaLibre(p.ctx, tx, pr.cadena); err != nil || !libre {
			return errors.Join(err, errOcupada)
		}
		var x int
		if err := tx.QueryRowContext(p.ctx, `SELECT 1 FROM cuentas WHERE email_hmac = ?`, cu.emailHMAC).Scan(&x); err == nil {
			return errEmailOcupado
		}
		if err := insertarCuenta(p.ctx, tx, cu); err != nil {
			return err
		}
		if err := ap.insertar(p.ctx, tx); err != nil {
			return err
		}
		return s.evento(p.ctx, tx, cu.id, evCadenaLigada, datosEvento{Aparato: ap.id, Mac: q.Nombre, Modelo: q.Modelo})
	})
	if errors.Is(err, errEmailOcupado) {
		return http.StatusConflict, fallo("email-ocupado")
	}
	if errors.Is(err, errOcupada) {
		return http.StatusConflict, fallo("cadena-ligada")
	}
	if err != nil {
		log.Error().Err(err).Msg("cuenta: alta")
		return interno()
	}
	s.sol.cerrar(x, resumen(kl, e), cu.id, ap.id)
	s.avisar(cu, evCadenaLigada, "")
	return http.StatusOK, ap.respuesta(cu.id)
}

var (
	errOcupada      = errors.New("ocupada")
	errEmailOcupado = errors.New("email ocupado")
)

// aparatoNuevo es lo que se da al crear un aparato: su token y su secreto (C1), en claro para el Mac y con hash
// para la base.
type aparatoNuevo struct {
	*aparato
	token, secreto         string
	tokenHash, secretoHash []byte
}

func (s *Servicio) nuevoAparato(cuentaID, modelo, nombre string) *aparatoNuevo {
	ahora := s.ahora()
	ap := &aparato{id: nuevoID(), cuenta: cuentaID, modelo: modelo, alta: ahora, ultimo: ahora}
	ap.nombreCifrado, ap.aesV = s.cfg.AES.sellar(asociadoNombre(ap.id), []byte(nombre))
	n := &aparatoNuevo{aparato: ap}
	n.token, n.tokenHash = nuevoToken()
	n.secreto, n.secretoHash = nuevoToken()
	return n
}

func (n *aparatoNuevo) insertar(ctx context.Context, tx *sql.Tx) error {
	return insertarAparato(ctx, tx, n.aparato, n.tokenHash, n.secretoHash)
}

func (n *aparatoNuevo) respuesta(cuentaID string) respAparato {
	return respAparato{Cuenta: cuentaID, Aparato: n.id, Token: n.token, Secreto: n.secreto}
}

// aparatoVerificado devuelve el aparato si el secreto es el suyo (C1); si no, "". Solo con él se da token a un
// aparato que ya existe o se le atribuye una operación: los ids de los aparatos los ve cualquiera con la cadena.
func (s *Servicio) aparatoVerificado(ctx context.Context, cuentaID, aparatoID, secreto string) string {
	if aparatoID == "" {
		return ""
	}
	b, err := base64.RawURLEncoding.DecodeString(secreto)
	if err != nil || len(b) != 32 {
		return ""
	}
	h, err := s.alm.secretoHash(ctx, cuentaID, aparatoID)
	if err != nil || h == nil || !iguales(h, sha(b)) {
		return ""
	}
	return aparatoID
}

// repetida contesta a una llamada ya aplicada que el Mac repite porque no le llegó la respuesta (§4.6): si pide
// lo mismo, la misma respuesta con un token nuevo para su aparato; si pide otra cosa, el error de siempre.
// En el alta, el aparato lo creó esta misma llamada y el Mac no tiene su secreto: se le da uno nuevo. En las demás,
// el token solo va con el secreto del aparato (C1); sin él, la operación ya está hecha y se contesta sin token.
func (s *Servicio) repetida(ctx context.Context, x *solicitud, r []byte, alta bool, secreto string) (int, any) {
	if !bytes.Equal(x.aplicada, r) {
		return credenciales()
	}
	if x.aparato == "" || (!alta && s.aparatoVerificado(ctx, x.cuentaID, x.aparato, secreto) == "") {
		return http.StatusOK, respAparato{}
	}
	token, h := nuevoToken()
	var nuevoSecreto string
	var hs []byte
	if alta {
		nuevoSecreto, hs = nuevoToken()
	}
	ok := false
	err := s.alm.enTx(ctx, func(tx *sql.Tx) error {
		var err error
		if ok, err = ponerToken(ctx, tx, x.cuentaID, x.aparato, h, s.ahora()); err != nil || !ok || !alta {
			return err
		}
		return ponerSecreto(ctx, tx, x.cuentaID, x.aparato, hs)
	})
	if err != nil || !ok {
		return credenciales()
	}
	return http.StatusOK, respAparato{Cuenta: x.cuentaID, Aparato: x.aparato, Token: token, Secreto: nuevoSecreto}
}

// --- entrar (§5.1) ---

// entrar/empezar: email + KL → solicitud. Espera antes de mirar nada, igual exista o no la cuenta (N4); el intento
// se anota al recibir turno (N6). Con KL correcta, código al email (cupo 2) y evento en los Macs; si no, una
// solicitud falsa con la misma forma. Crece la espera en los dos casos.
func (s *Servicio) entrarEmpezar(p *peticion) (int, any) {
	var q struct {
		Email string
		KL    string `json:"kl"`
	}
	if !p.leer(&q) {
		return malaPeticion()
	}
	email, ok1 := NormalizarEmail(q.Email)
	kl, ok2 := b64(q.KL, largoKL)
	if !ok1 || !ok2 {
		return malaPeticion()
	}
	clave := s.claveEspera(email)
	if h := s.esperas.Hasta(clave); !h.IsZero() {
		return espera(h)
	}
	if !s.turno(p.ctx) {
		return ocupado()
	}
	defer s.sem.Salir()
	if ok, h := s.esperas.Anotar(clave); !ok {
		return espera(h)
	}
	c, err := s.alm.porEmail(p.ctx, s.hmacs(email))
	if err != nil {
		return interno()
	}
	if c == nil {
		s.cfg.Estirar(kl, aleatorio(largoSal)) // scrypt de relleno: mismo tiempo (§4.8)
		return http.StatusOK, respSolicitud{s.sol.falsa()}
	}
	if v, _ := s.secreto(kl, c.sal); !iguales(v, c.verif) {
		s.registrarFallo(p.ctx, c, "")
		return http.StatusOK, respSolicitud{s.sol.falsa()}
	}
	err = s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		return s.evento(p.ctx, tx, c.id, evContrasenaAcertada, datosEvento{})
	})
	if err != nil {
		return interno()
	}
	if !s.cupos.Entrada(c.id) {
		return http.StatusOK, respSolicitud{s.sol.falsa()}
	}
	x := &solicitud{tipo: solEntrar, cuentaID: c.id, email: clave}
	codigo := s.sol.crear(x)
	if e, err := s.emailDe(c); err == nil {
		s.mandarCodigo(e, solEntrar, codigo)
	}
	return http.StatusOK, respSolicitud{x.id}
}

// entrar/terminar: solicitud + KL + código + modelo y nombre → token y envoltura. No pasa por la espera (la frena el
// ritmo del código, §10) pero sí por el semáforo. Un solo error para contraseña y código (O9).
func (s *Servicio) entrarTerminar(p *peticion) (int, any) {
	var q pedirConClave
	if !p.leer(&q) || !validoModelo(q.Modelo) || !validoNombre(q.Nombre) {
		return malaPeticion()
	}
	kl, ok := b64(q.KL, largoKL)
	if !ok {
		return malaPeticion()
	}
	if !s.turno(p.ctx) {
		return ocupado()
	}
	defer s.sem.Salir()
	x, res, hasta := s.sol.intentar(q.Solicitud, solEntrar, q.Codigo)
	if res == codigoEspera {
		return espera(hasta)
	}
	var c *registro
	if res == codigoBien {
		var err error
		if c, err = s.alm.porID(p.ctx, x.cuentaID); err != nil {
			return interno()
		}
	}
	if c == nil {
		s.cfg.Estirar(kl, aleatorio(largoSal))
		return credenciales()
	}
	v, kw := s.secreto(kl, c.sal)
	if !iguales(v, c.verif) {
		return credenciales()
	}
	e, err := abrir(kw, c.ee, asociadoEE(c.id))
	if err != nil {
		log.Error().Msg("cuenta: EE no abre con un verificador correcto")
		return interno()
	}
	ap := s.nuevoAparato(c.id, q.Modelo, q.Nombre)
	err = s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		if err := ap.insertar(p.ctx, tx); err != nil {
			return err
		}
		return s.evento(p.ctx, tx, c.id, evMacAnadido, datosEvento{Aparato: ap.id, Mac: q.Nombre, Modelo: q.Modelo})
	})
	if err != nil {
		return interno()
	}
	s.sol.quitar(x)
	s.esperas.Reiniciar(x.email)
	s.anadidos.Add(1)
	s.avisar(c, evMacAnadido, descMac(q.Nombre, q.Modelo))
	r := ap.respuesta(c.id)
	r.Envoltura = base64.StdEncoding.EncodeToString(e)
	return http.StatusOK, r
}

// --- fallos de contraseña (§6.2): el primero al momento; después, como mucho un aviso por hora y cuenta ---

func (s *Servicio) registrarFallo(ctx context.Context, c *registro, mac string) {
	ahora := s.ahora()
	err := s.alm.enTx(ctx, func(tx *sql.Tx) error {
		var n, desde, aviso int64
		if err := tx.QueryRowContext(ctx, `SELECT fallos_n, fallos_desde, fallos_aviso FROM cuentas WHERE id = ?`,
			c.id).Scan(&n, &desde, &aviso); err != nil {
			return err
		}
		n++
		if desde == 0 {
			desde = ahora
		}
		var macC []byte
		var macV int
		if mac != "" {
			macC, macV = s.cfg.AES.sellar([]byte("fallos:"+c.id), []byte(mac))
		}
		if _, err := tx.ExecContext(ctx, `UPDATE cuentas SET fallos_n = ?, fallos_desde = ?,
		  fallos_mac = COALESCE(?, fallos_mac), fallos_mac_v = CASE WHEN ? IS NULL THEN fallos_mac_v ELSE ? END
		  WHERE id = ?`, n, desde, macC, macC, macV, c.id); err != nil {
			return err
		}
		if aviso == 0 || ahora-aviso >= int64(ritmoFallos/time.Second) {
			return s.eventoFallos(ctx, tx, c.id, ahora)
		}
		return nil
	})
	if err != nil {
		log.Error().Err(err).Msg("cuenta: registrando un fallo de contraseña")
	}
}

// eventoFallos convierte los fallos pendientes en un evento con el resumen y los pone a cero.
func (s *Servicio) eventoFallos(ctx context.Context, tx *sql.Tx, cuentaID string, ahora int64) error {
	var n, desde int64
	var macC []byte
	var macV int
	if err := tx.QueryRowContext(ctx, `SELECT fallos_n, fallos_desde, fallos_mac, fallos_mac_v FROM cuentas
	  WHERE id = ?`, cuentaID).Scan(&n, &desde, &macC, &macV); err != nil {
		return err
	}
	d := datosEvento{N: n, Desde: desde}
	if macC != nil {
		if m, err := s.cfg.AES.abrir(macV, []byte("fallos:"+cuentaID), macC); err == nil {
			d.Mac = string(m)
		}
	}
	if err := s.evento(ctx, tx, cuentaID, evContrasenaFallos, d); err != nil {
		return err
	}
	_, err := tx.ExecContext(ctx, `UPDATE cuentas SET fallos_n = 0, fallos_desde = 0, fallos_mac = NULL,
	  fallos_mac_v = 0, fallos_aviso = ? WHERE id = ?`, ahora, cuentaID)
	return err
}

func (s *Servicio) avisarFallosPendientes(ctx context.Context, ahora int64) error {
	rows, err := s.cfg.DB.QueryContext(ctx, `SELECT id FROM cuentas WHERE fallos_n > 0 AND fallos_aviso <= ?`,
		ahora-int64(ritmoFallos/time.Second))
	if err != nil {
		return err
	}
	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			rows.Close()
			return err
		}
		ids = append(ids, id)
	}
	rows.Close()
	for _, id := range ids {
		if err := s.alm.enTx(ctx, func(tx *sql.Tx) error { return s.eventoFallos(ctx, tx, id, ahora) }); err != nil {
			return err
		}
	}
	return rows.Err()
}

// conContrasena comprueba KL junto a una prueba de cadena (cambio de email o de clave) con la espera del email de la
// cuenta. Si falla, crece la espera y queda el fallo con el nombre del Mac si venía su token. Devuelve KW.
func (s *Servicio) conContrasena(p *peticion, c *registro, kl []byte) ([]byte, int, any) {
	email, err := s.emailDe(c)
	if err != nil {
		cod, v := interno()
		return nil, cod, v
	}
	clave := s.claveEspera(email)
	if h := s.esperas.Hasta(clave); !h.IsZero() {
		cod, v := espera(h)
		return nil, cod, v
	}
	if !s.turno(p.ctx) {
		cod, v := ocupado()
		return nil, cod, v
	}
	defer s.sem.Salir()
	if ok, h := s.esperas.Anotar(clave); !ok {
		cod, v := espera(h)
		return nil, cod, v
	}
	v, kw := s.secreto(kl, c.sal)
	if !iguales(v, c.verif) {
		mac := ""
		if ap, _ := s.porToken(p); ap != nil && ap.cuenta == c.id {
			mac = s.nombreDe(ap)
		}
		s.registrarFallo(p.ctx, c, mac)
		cod, v := credenciales()
		return nil, cod, v
	}
	s.esperas.Reiniciar(clave)
	return kw, 0, nil
}

// --- contraseña (§4.6, §6.1): cadena + código al email; no se pide la anterior ---

func (s *Servicio) contrasenaCodigo(p *peticion) (int, any) {
	_, c, cod, v := s.conPruebaYCuenta(p, "contrasena-codigo")
	if cod != 0 {
		return cod, v
	}
	// Cupo (3): 5 por hora y cuenta, con error explícito (quien pide tiene la cadena).
	if !s.cupos.ConPrueba(c.id) {
		return http.StatusTooManyRequests, fallo("cupo")
	}
	email, err := s.emailDe(c)
	if err != nil {
		return interno()
	}
	x := &solicitud{tipo: solContrasena, cuentaID: c.id}
	codigo := s.sol.crear(x)
	s.mandarCodigo(email, solContrasena, codigo)
	return http.StatusOK, respSolicitud{x.id}
}

// contrasena/cambiar: prueba + solicitud + código + KL y envoltura nuevas (+ aparato que llama). Sal, verificador
// y EE nuevos en una transacción; los tokens de los demás aparatos dejan de valer (B2); la espera vuelve a cero.
func (s *Servicio) contrasenaCambiar(p *peticion) (int, any) {
	var q pedirConClave
	if !p.leer(&q) {
		return malaPeticion()
	}
	kl, e, ok := q.claves()
	if !ok {
		return malaPeticion()
	}
	_, c, cod, v := s.conPruebaYCuenta(p, "contrasena-cambiar")
	if cod != 0 {
		return cod, v
	}
	if !s.turno(p.ctx) {
		return ocupado()
	}
	defer s.sem.Salir()
	x, res, hasta := s.sol.intentar(q.Solicitud, solContrasena, q.Codigo)
	switch {
	case res == codigoEspera:
		return espera(hasta)
	case res != codigoBien || x.cuentaID != c.id:
		return credenciales()
	case x.aplicada != nil:
		return s.repetida(p.ctx, x, resumen(kl, e), false, q.Secreto)
	}
	sal, verif, ee := s.nuevoSecreto(c.id, kl, e)
	token, h := nuevoToken()
	conToken := false
	apID := s.aparatoVerificado(p.ctx, c.id, q.Aparato, q.Secreto) // C1: sin su secreto, ni token ni autor
	err := s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		if err := cambiarSecreto(p.ctx, tx, c.id, sal, verif, ee); err != nil {
			return err
		}
		if _, err := invalidarTokens(p.ctx, tx, c.id, apID); err != nil {
			return err
		}
		if apID != "" {
			var err error
			if conToken, err = ponerToken(p.ctx, tx, c.id, apID, h, s.ahora()); err != nil {
				return err
			}
		}
		d := datosEvento{}
		if conToken {
			d.Aparato = apID
		}
		return s.evento(p.ctx, tx, c.id, evContrasenaCambiada, d)
	})
	if err != nil {
		return interno()
	}
	if !conToken {
		apID = ""
	}
	s.sol.cerrar(x, resumen(kl, e), c.id, apID)
	if email, err := s.emailDe(c); err == nil {
		s.esperas.Reiniciar(s.claveEspera(email))
	}
	s.avisar(c, evContrasenaCambiada, "")
	if !conToken {
		return http.StatusOK, respAparato{}
	}
	return http.StatusOK, respAparato{Aparato: apID, Token: token}
}

// --- email (§6.5): cadena + contraseña + código a la dirección nueva ---

func (s *Servicio) emailEmpezar(p *peticion) (int, any) {
	var q struct {
		Email string
		KL    string `json:"kl"`
	}
	if !p.leer(&q) {
		return malaPeticion()
	}
	nuevo, ok1 := NormalizarEmail(q.Email)
	kl, ok2 := b64(q.KL, largoKL)
	if !ok1 || !ok2 {
		return malaPeticion()
	}
	_, c, cod, v := s.conPruebaYCuenta(p, "email-empezar")
	if cod != 0 {
		return cod, v
	}
	if _, cod, v := s.conContrasena(p, c, kl); cod != 0 {
		return cod, v
	}
	// Una dirección que ya usa otra cuenta: error explícito (quien pregunta tiene cadena y contraseña) y gasta cupo
	// (provisional, pregunta 5 a COORDINACIÓN).
	if !s.cupos.ConPrueba(c.id) {
		return http.StatusTooManyRequests, fallo("cupo")
	}
	otra, err := s.alm.porEmail(p.ctx, s.hmacs(nuevo))
	if err != nil {
		return interno()
	}
	if otra != nil {
		return http.StatusConflict, fallo("email-ocupado")
	}
	h := s.cfg.HMAC.hmacEmail(s.cfg.HMAC.actual, nuevo)
	cif, av := s.cfg.AES.sellar(h, []byte(nuevo))
	x := &solicitud{tipo: solEmail, cuentaID: c.id, emailHMAC: h, hmacV: s.cfg.HMAC.actual, emailCifrado: cif, aesV: av}
	codigo := s.sol.crear(x)
	s.mandarCodigo(nuevo, solEmail, codigo)
	return http.StatusOK, respSolicitud{x.id}
}

// email/cambiar/terminar: solicitud + código + KL y envoltura nuevas (la sal del Mac sale del email).
func (s *Servicio) emailTerminar(p *peticion) (int, any) {
	var q pedirConClave
	if !p.leer(&q) {
		return malaPeticion()
	}
	kl, e, ok := q.claves()
	if !ok {
		return malaPeticion()
	}
	if !s.turno(p.ctx) {
		return ocupado()
	}
	defer s.sem.Salir()
	x, res, hasta := s.sol.intentar(q.Solicitud, solEmail, q.Codigo)
	switch {
	case res == codigoEspera:
		return espera(hasta)
	case res != codigoBien:
		return credenciales()
	case x.aplicada != nil:
		return s.repetida(p.ctx, x, resumen(kl, e), false, q.Secreto)
	}
	c, err := s.alm.porID(p.ctx, x.cuentaID)
	if err != nil || c == nil {
		return credenciales()
	}
	viejo, err := s.emailDe(c)
	if err != nil {
		return interno()
	}
	sal, verif, ee := s.nuevoSecreto(c.id, kl, e)
	autor := s.autor(p, c.id)
	err = s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		if _, err := tx.ExecContext(p.ctx, `UPDATE cuentas SET email_hmac = ?, hmac_v = ?, email_cifrado = ?,
		  aes_v = ?, sal = ?, verificador = ?, ee = ? WHERE id = ?`, x.emailHMAC, x.hmacV, x.emailCifrado, x.aesV,
			sal, verif, ee, c.id); err != nil {
			if strings.Contains(err.Error(), "UNIQUE") {
				return errOcupada
			}
			return err
		}
		return s.evento(p.ctx, tx, c.id, evEmailCambiado, datosEvento{Aparato: autor})
	})
	if errors.Is(err, errOcupada) {
		return http.StatusConflict, fallo("email-ocupado")
	}
	if err != nil {
		return interno()
	}
	s.sol.cerrar(x, resumen(kl, e), c.id, "")
	s.avisarA(viejo, evEmailCambiado, "")
	return http.StatusOK, respAparato{}
}

// --- clave de sincronización (§6.3): prueba con la clave vieja y con la nueva + contraseña ---

func (s *Servicio) cadenaCambiar(p *peticion) (int, any) {
	var q pedirConClave
	if !p.leer(&q) {
		return malaPeticion()
	}
	kl, e, ok := q.claves()
	if !ok {
		return malaPeticion()
	}
	_, c, cod, v := s.conPruebaYCuenta(p, "cadena-cambiar")
	if cod != 0 {
		return cod, v
	}
	// La prueba nueva usa el mismo nonce, ya gastado por la vieja: se comprueba solo la firma.
	nueva, err := leerPruebaNueva(p, s.nonces)
	if err != nil || nueva.cadena == c.cadena || !nueva.verificar("cadena-cambiar", c.id, p.cuerpo) {
		return malaPrueba()
	}
	kw, cod, v := s.conContrasena(p, c, kl)
	if cod != 0 {
		return cod, v
	}
	if des, err := s.cfg.Cadenas.Desactivada(p.ctx, nueva.cadena); err != nil {
		return interno()
	} else if des {
		return http.StatusConflict, fallo("cadena-borrada")
	}
	ee := sellar(kw, e, asociadoEE(c.id))
	token, h := nuevoToken()
	conToken := false
	ahora := s.ahora()
	apID := s.aparatoVerificado(p.ctx, c.id, q.Aparato, q.Secreto) // C1
	err = s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		if libre, err := cadenaLibre(p.ctx, tx, nueva.cadena); err != nil || !libre {
			return errors.Join(err, errOcupada)
		}
		if _, err := tx.ExecContext(p.ctx, `UPDATE cuentas SET cadena = ?, ee = ? WHERE id = ?`, nueva.cadena, ee,
			c.id); err != nil {
			return err
		}
		if _, err := tx.ExecContext(p.ctx, `INSERT OR REPLACE INTO cuenta_sustituidas (cadena, fecha) VALUES (?, ?)`,
			c.cadena, ahora); err != nil {
			return err
		}
		if _, err := invalidarTokens(p.ctx, tx, c.id, apID); err != nil {
			return err
		}
		if apID != "" {
			var err error
			if conToken, err = ponerToken(p.ctx, tx, c.id, apID, h, ahora); err != nil {
				return err
			}
		}
		d := datosEvento{}
		if conToken {
			d.Aparato = apID
		}
		return s.evento(p.ctx, tx, c.id, evCadenaCambiada, d)
	})
	if errors.Is(err, errOcupada) {
		return http.StatusConflict, fallo("cadena-ligada")
	}
	if err != nil {
		return interno()
	}
	if err := s.cfg.Cadenas.Borrar(p.ctx, c.cadena); err != nil {
		log.Error().Err(err).Msg("cuenta: borrando la cadena sustituida")
	}
	s.avisar(c, evCadenaCambiada, "")
	if !conToken {
		return http.StatusOK, respAparato{}
	}
	return http.StatusOK, respAparato{Aparato: apID, Token: token}
}

func leerPruebaNueva(p *peticion, nn *nonces) (*pruebaLeida, error) {
	return leerPrueba(p.r, nn, "X-FlyWeb-Cadena-Nueva", "X-FlyWeb-Prueba-Nueva")
}
