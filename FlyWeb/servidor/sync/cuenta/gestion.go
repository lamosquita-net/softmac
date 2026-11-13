// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"time"

	"github.com/rs/zerolog/log"
)

// pruebaSinCuenta: prueba firmada con cuenta_id vacío (alta y «empezar de cero», cuando el Mac aún no conoce la
// cuenta). No mira si la cadena tiene cuenta.
func (s *Servicio) pruebaSinCuenta(p *peticion, cabCadena, cabFirma, op string) (*pruebaLeida, int, any) {
	pr, err := leerPrueba(p.r, s.nonces, cabCadena, cabFirma)
	if err != nil || !pr.verificar(op, "", p.cuerpo) || !s.nonces.gastar(pr.nonce, pr.caduca) {
		c, v := malaPrueba()
		return nil, c, v
	}
	return pr, 0, nil
}

// --- aparatos: con la cadena (§3.2); listar también con el token ---

type aparatoListado struct {
	ID     string `json:"id"`
	Modelo string `json:"modelo"`
	Nombre string `json:"nombre"`
	Alta   int64  `json:"alta"`
	Ultimo int64  `json:"ultimo_uso"`
	Este   bool   `json:"este,omitempty"`
}

// cuentaDe autentica con el token (si viene uno válido) o, si no, con la prueba de cadena de la operación.
func (s *Servicio) cuentaDe(p *peticion, op string) (*registro, *aparato, int, any) {
	if p.r.Header.Get("Authorization") != "" {
		ap, err := s.porToken(p)
		if err != nil {
			c, v := interno()
			return nil, nil, c, v
		}
		if ap == nil {
			c, v := malToken()
			return nil, nil, c, v
		}
		c, err := s.alm.porID(p.ctx, ap.cuenta)
		if err != nil || c == nil {
			cod, v := malToken()
			return nil, nil, cod, v
		}
		return c, ap, 0, nil
	}
	_, c, cod, v := s.conPruebaYCuenta(p, op)
	return c, nil, cod, v
}

func (s *Servicio) aparatosListar(p *peticion) (int, any) {
	c, este, cod, v := s.cuentaDe(p, "aparatos-listar")
	if cod != 0 {
		return cod, v
	}
	aps, err := s.alm.aparatos(p.ctx, c.id)
	if err != nil {
		return interno()
	}
	lista := []aparatoListado{}
	for i := range aps {
		ap := &aps[i]
		lista = append(lista, aparatoListado{ID: ap.id, Modelo: ap.modelo, Nombre: s.nombreDe(ap), Alta: ap.alta,
			Ultimo: ap.ultimo, Este: este != nil && este.id == ap.id})
	}
	return http.StatusOK, map[string]any{"aparatos": lista}
}

type pedirAparato struct {
	Aparato string
	Modelo  string
	Nombre  string
}

// quitarAparato: «Quitar de la lista» y «Salir en este Mac». El aparato deja de aparecer y pierde su token; no
// pierde la semilla (§6.3: para eso, cambiar la clave). Avisa por correo y evento.
func (s *Servicio) quitarAparato(p *peticion, op string) (int, any) {
	var q pedirAparato
	if !p.leer(&q) || q.Aparato == "" {
		return malaPeticion()
	}
	_, c, cod, v := s.conPruebaYCuenta(p, op)
	if cod != 0 {
		return cod, v
	}
	ap, err := s.alm.aparato(p.ctx, c.id, q.Aparato)
	if err != nil {
		return interno()
	}
	if ap == nil {
		return http.StatusNotFound, fallo("aparato")
	}
	nombre := s.nombreDe(ap)
	autor := s.autor(p, c.id)
	err = s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		if _, err := tx.ExecContext(p.ctx, `DELETE FROM cuenta_aparatos WHERE id = ?`, ap.id); err != nil {
			return err
		}
		return s.evento(p.ctx, tx, c.id, evAparatoQuitado, datosEvento{Aparato: autor, Mac: nombre, Modelo: ap.modelo})
	})
	if err != nil {
		return interno()
	}
	s.avisar(c, evAparatoQuitado, descMac(nombre, ap.modelo))
	return http.StatusOK, struct{}{}
}

func (s *Servicio) aparatosQuitar(p *peticion) (int, any) {
	return s.quitarAparato(p, "aparatos-quitar")
}

// salir: «Salir de la sincronización en este Mac» (§9). Para el servidor es quitar su aparato; el Mac abandona la
// cadena y conserva el perfil. Avisa como «aparato quitado» (provisional, pregunta 9 a COORDINACIÓN).
func (s *Servicio) salir(p *peticion) (int, any) { return s.quitarAparato(p, "salir") }

// aparatos/renovar: token nuevo con la prueba de cadena (tras invalidarse o caducar). Sin aparato, con modelo y
// nombre, da de alta en la lista al Mac que se unió con las 24 palabras (provisional: el diseño no dice cómo entra
// en la lista; pregunta 11 a COORDINACIÓN). Eso avisa como «Mac añadido».
func (s *Servicio) aparatosRenovar(p *peticion) (int, any) {
	var q pedirAparato
	if !p.leer(&q) {
		return malaPeticion()
	}
	if q.Aparato == "" && (!validoModelo(q.Modelo) || !validoNombre(q.Nombre)) {
		return malaPeticion()
	}
	_, c, cod, v := s.conPruebaYCuenta(p, "aparatos-renovar")
	if cod != 0 {
		return cod, v
	}
	if q.Aparato == "" {
		ap, token, h := s.nuevoAparato(c.id, q.Modelo, q.Nombre)
		err := s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
			if err := insertarAparato(p.ctx, tx, ap, h); err != nil {
				return err
			}
			return s.evento(p.ctx, tx, c.id, evMacAnadido, datosEvento{Aparato: ap.id, Mac: q.Nombre, Modelo: q.Modelo})
		})
		if err != nil {
			return interno()
		}
		s.anadidos.Add(1)
		s.avisar(c, evMacAnadido, descMac(q.Nombre, q.Modelo))
		return http.StatusOK, respAparato{Cuenta: c.id, Aparato: ap.id, Token: token}
	}
	token, h := nuevoToken()
	ok := false
	err := s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		var err error
		ok, err = ponerToken(p.ctx, tx, c.id, q.Aparato, h, s.ahora())
		return err
	})
	if err != nil {
		return interno()
	}
	if !ok {
		return http.StatusNotFound, fallo("aparato")
	}
	return http.StatusOK, respAparato{Cuenta: c.id, Aparato: q.Aparato, Token: token}
}

func (s *Servicio) aparatosRenombrar(p *peticion) (int, any) {
	var q pedirAparato
	if !p.leer(&q) || q.Aparato == "" || !validoNombre(q.Nombre) {
		return malaPeticion()
	}
	_, c, cod, v := s.conPruebaYCuenta(p, "aparatos-renombrar")
	if cod != 0 {
		return cod, v
	}
	cif, av := s.cfg.AES.sellar(asociadoNombre(q.Aparato), []byte(q.Nombre))
	autor := s.autor(p, c.id)
	var n int64
	err := s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		r, err := tx.ExecContext(p.ctx, `UPDATE cuenta_aparatos SET nombre_cifrado = ?, aes_v = ? WHERE cuenta = ? AND id = ?`,
			cif, av, c.id, q.Aparato)
		if err != nil {
			return err
		}
		if n, err = r.RowsAffected(); err != nil || n == 0 {
			return err
		}
		return s.evento(p.ctx, tx, c.id, evAparatoRenombrado, datosEvento{Aparato: autor, Mac: q.Nombre})
	})
	if err != nil {
		return interno()
	}
	if n == 0 {
		return http.StatusNotFound, fallo("aparato")
	}
	return http.StatusOK, struct{}{}
}

// --- eventos (§6.2): con el token o con la prueba de cadena (aunque el token esté invalidado) ---

type eventoListado struct {
	N     int64        `json:"n"`
	Tipo  string       `json:"tipo"`
	Fecha int64        `json:"fecha"`
	Datos *datosEvento `json:"datos,omitempty"`
}

type respEventos struct {
	// activa · borrado-programado · cadena-sustituida (la clave se cambió desde otro Mac) · sin-cuenta
	Estado  string          `json:"estado"`
	Cuenta  string          `json:"cuenta,omitempty"`  // el id de la cuenta (S1: el Mac puede no saberlo)
	Email   string          `json:"email,omitempty"`   // solo con prueba de cadena (S2)
	Borrado int64           `json:"borrado,omitempty"` // con borrado-programado: cuándo
	Eventos []eventoListado `json:"eventos"`
}

func (s *Servicio) eventos(p *peticion) (int, any) {
	var q struct{ Desde int64 }
	if !p.leer(&q) {
		return malaPeticion()
	}
	var c *registro
	conPrueba := p.r.Header.Get("X-FlyWeb-Prueba") != ""
	if !conPrueba {
		var cod int
		var v any
		if c, _, cod, v = s.cuentaDe(p, "eventos"); cod != 0 {
			return cod, v
		}
	} else {
		pr, cu, cod, v := s.conPrueba(p, "eventos")
		if cod != 0 {
			return cod, v
		}
		if cu == nil {
			estado := "sin-cuenta"
			if sus, err := s.alm.sustituida(p.ctx, pr.cadena, s.ahora()-int64(vidaSustituida/time.Second)); err != nil {
				return interno()
			} else if sus {
				estado = "cadena-sustituida"
			}
			return http.StatusOK, respEventos{Estado: estado, Eventos: []eventoListado{}}
		}
		c = cu
	}
	r := respEventos{Estado: "activa", Cuenta: c.id, Eventos: []eventoListado{}}
	// S2: el email, solo con prueba de cadena (nunca con el token, que se puede ver en tráfico descifrado, §14). Lo
	// necesita para estirar la contraseña el Mac que se unió con las 24 palabras.
	if conPrueba {
		email, err := s.emailDe(c)
		if err != nil {
			return interno()
		}
		r.Email = email
	}
	if pg, err := s.alm.programado(p.ctx, c.id); err != nil {
		return interno()
	} else if pg != nil {
		r.Estado, r.Borrado = "borrado-programado", pg.fecha
	}
	es, err := s.alm.eventos(p.ctx, c.id, q.Desde, 100)
	if err != nil {
		return interno()
	}
	for _, e := range es {
		l := eventoListado{N: e.n, Tipo: e.tipo, Fecha: e.fecha}
		if e.datos != nil {
			if claro, err := s.cfg.AES.abrir(e.aesV, asociadoEvento(c.id, e.tipo), e.datos); err == nil {
				d := &datosEvento{}
				if json.Unmarshal(claro, d) == nil {
					l.Datos = d
				}
			}
		}
		r.Eventos = append(r.Eventos, l)
	}
	return http.StatusOK, r
}

// --- «No he sido yo» (§6.2): invalida todos los tokens y cancela los borrados pedidos por email ---

func (s *Servicio) noHeSidoYo(p *peticion) (int, any) {
	_, c, cod, v := s.conPruebaYCuenta(p, "no-he-sido-yo")
	if cod != 0 {
		return cod, v
	}
	cambio := false
	autor := s.autor(p, c.id)
	err := s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		n, err := invalidarTokens(p.ctx, tx, c.id, "")
		if err != nil {
			return err
		}
		cancelado, err := cancelarProgramado(p.ctx, tx, c.id, s.ahora())
		if err != nil {
			return err
		}
		cambio = n > 0 || cancelado
		if !cambio {
			return nil
		}
		return s.evento(p.ctx, tx, c.id, evNoHeSidoYo, datosEvento{Aparato: autor})
	})
	if err != nil {
		return interno()
	}
	if cambio { // no repite aviso si no cambia nada (§10)
		s.avisar(c, evNoHeSidoYo, "")
	}
	return http.StatusOK, struct{}{}
}

func cancelarProgramado(ctx context.Context, tx *sql.Tx, cuenta string, ahora int64) (bool, error) {
	r, err := tx.ExecContext(ctx, `DELETE FROM cuenta_programados WHERE cuenta = ?`, cuenta)
	if err != nil {
		return false, err
	}
	n, err := r.RowsAffected()
	if err != nil || n == 0 {
		return false, err
	}
	_, err = tx.ExecContext(ctx, `UPDATE cuentas SET cancelado = ? WHERE id = ?`, ahora, cuenta)
	return true, err
}

// --- borrar (§7) ---

// borrarCuenta: filas de la cuenta, y la cadena con ClearServerData y la marca de desactivada. Avisa a la
// dirección antes de olvidarla.
func (s *Servicio) borrarCuenta(ctx context.Context, c *registro, cadena bool) error {
	email, errEmail := s.emailDe(c)
	if err := s.alm.enTx(ctx, func(tx *sql.Tx) error { return borrarFilas(ctx, tx, c.id) }); err != nil {
		return err
	}
	s.sol.quitarDeCuenta(c.id)
	if cadena {
		if err := s.cfg.Cadenas.Borrar(ctx, c.cadena); err != nil {
			return err
		}
	}
	s.borradas.Add(1)
	if errEmail == nil {
		s.avisarA(email, "cuenta-borrada", "")
	}
	return nil
}

// cuenta/borrar: con la cadena, al momento.
func (s *Servicio) cuentaBorrar(p *peticion) (int, any) {
	_, c, cod, v := s.conPruebaYCuenta(p, "cuenta-borrar")
	if cod != 0 {
		return cod, v
	}
	if err := s.borrarCuenta(p.ctx, c, true); err != nil {
		log.Error().Err(err).Msg("cuenta: borrando")
		return interno()
	}
	return http.StatusOK, struct{}{}
}

// cuenta/borrar/cancelar: cualquier Mac con la cadena cancela un borrado o un «empezar de cero» pedido por email.
// Tras cancelar, no se puede volver a pedir en 30 días (O10).
func (s *Servicio) borradoCancelar(p *peticion) (int, any) {
	_, c, cod, v := s.conPruebaYCuenta(p, "borrado-cancelar")
	if cod != 0 {
		return cod, v
	}
	cancelado := false
	autor := s.autor(p, c.id)
	err := s.alm.enTx(p.ctx, func(tx *sql.Tx) error {
		var err error
		if cancelado, err = cancelarProgramado(p.ctx, tx, c.id, s.ahora()); err != nil || !cancelado {
			return err
		}
		return s.evento(p.ctx, tx, c.id, evBorradoCancelado, datosEvento{Aparato: autor})
	})
	if err != nil {
		return interno()
	}
	if cancelado {
		s.avisar(c, evBorradoCancelado, "")
	}
	return http.StatusOK, map[string]bool{"cancelado": cancelado}
}

// --- diferidos solo con el buzón (§6.4), provisional: pregunta 1 a COORDINACIÓN ---
//
// Dos pasos: pedir con el email (código al buzón, cupo 2, respuesta igual exista o no la cuenta) y confirmar con el
// código. Se programan a 14 días con correo y evento; cualquier Mac con la cadena los cancela.

func (s *Servicio) pedirDiferido(p *peticion, t tipoSolicitud) (int, any) {
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
	if c == nil {
		return http.StatusOK, respSolicitud{s.sol.falsa()}
	}
	pg, err := s.alm.programado(p.ctx, c.id)
	if err != nil {
		return interno()
	}
	ahora := s.ahora()
	enPlazo := c.cancelado != 0 && ahora-c.cancelado < int64(trasCancelacion/time.Second)
	if pg != nil || enPlazo || !s.cupos.Entrada(c.id) {
		return http.StatusOK, respSolicitud{s.sol.falsa()}
	}
	x := &solicitud{tipo: t, cuentaID: c.id}
	codigo := s.sol.crear(x)
	s.mandarCodigo(email, t, codigo)
	return http.StatusOK, respSolicitud{x.id}
}

func (s *Servicio) borrarPorEmail(p *peticion) (int, any) { return s.pedirDiferido(p, solBorrarEmail) }
func (s *Servicio) empezarDeCero(p *peticion) (int, any)  { return s.pedirDiferido(p, solEmpezarCero) }

// programar guarda el diferido y avisa.
func (s *Servicio) programar(ctx context.Context, x *solicitud, pg *programado) (int, any) {
	c, err := s.alm.porID(ctx, x.cuentaID)
	if err != nil || c == nil {
		return credenciales()
	}
	pg.cuenta, pg.pedido = c.id, s.ahora()
	pg.fecha = pg.pedido + int64(s.cfg.Demora/time.Second)
	err = s.alm.enTx(ctx, func(tx *sql.Tx) error {
		var y int
		if err := tx.QueryRowContext(ctx, `SELECT 1 FROM cuenta_programados WHERE cuenta = ?`, c.id).Scan(&y); err == nil {
			return errOcupada
		}
		if pg.cadenaNueva.Valid {
			if libre, err := cadenaLibre(ctx, tx, pg.cadenaNueva.String); err != nil || !libre {
				return errors.Join(err, errOcupada)
			}
		}
		if _, err := tx.ExecContext(ctx, `INSERT INTO cuenta_programados (cuenta, tipo, pedido, fecha, cadena_nueva, sal,
		  verificador, ee) VALUES (?,?,?,?,?,?,?,?)`, pg.cuenta, pg.tipo, pg.pedido, pg.fecha, pg.cadenaNueva, pg.sal,
			pg.verif, pg.ee); err != nil {
			return err
		}
		return s.evento(ctx, tx, c.id, evBorradoPedido, datosEvento{Fecha: pg.fecha})
	})
	if errors.Is(err, errOcupada) {
		return http.StatusConflict, fallo("programado")
	}
	if err != nil {
		return interno()
	}
	s.sol.cerrar(x, []byte{1}, c.id, "")
	s.avisar(c, evBorradoPedido, "")
	return http.StatusOK, map[string]int64{"fecha": pg.fecha}
}

func (s *Servicio) borrarPorEmailConfirmar(p *peticion) (int, any) {
	var q pedirConClave
	if !p.leer(&q) {
		return malaPeticion()
	}
	x, res, hasta := s.sol.intentar(q.Solicitud, solBorrarEmail, q.Codigo)
	switch {
	case res == codigoEspera:
		return espera(hasta)
	case res == codigoOcupado:
		return ocupado()
	case res != codigoBien || x.aplicada != nil:
		return credenciales()
	}
	return s.programar(p.ctx, x, &programado{tipo: "borrar"})
}

// empezar-de-cero/confirmar: código + prueba de la cadena NUEVA (cuenta_id vacío) + KL y envoltura nuevas. A los
// 14 días se borra la cadena vieja y la cuenta pasa a la nueva con la contraseña nueva.
func (s *Servicio) empezarDeCeroConfirmar(p *peticion) (int, any) {
	var q pedirConClave
	if !p.leer(&q) {
		return malaPeticion()
	}
	kl, e, ok := q.claves()
	if !ok {
		return malaPeticion()
	}
	pr, cod, v := s.pruebaSinCuenta(p, "X-FlyWeb-Cadena", "X-FlyWeb-Prueba", "empezar-de-cero")
	if cod != 0 {
		return cod, v
	}
	if !s.turno(p.ctx) {
		return ocupado()
	}
	defer s.sem.Salir()
	x, res, hasta := s.sol.intentar(q.Solicitud, solEmpezarCero, q.Codigo)
	switch {
	case res == codigoEspera:
		return espera(hasta)
	case res == codigoOcupado:
		return ocupado()
	case res != codigoBien || x.aplicada != nil:
		return credenciales()
	}
	if des, err := s.cfg.Cadenas.Desactivada(p.ctx, pr.cadena); err != nil {
		return interno()
	} else if des {
		return http.StatusConflict, fallo("cadena-borrada")
	}
	sal, verif, ee := s.nuevoSecreto(x.cuentaID, kl, e)
	return s.programar(p.ctx, x, &programado{tipo: "empezar", cadenaNueva: sql.NullString{String: pr.cadena, Valid: true},
		sal: sal, verif: verif, ee: ee})
}

// ejecutarVencidos: los diferidos cumplidos.
func (s *Servicio) ejecutarVencidos(ctx context.Context, ahora int64) error {
	ps, err := s.alm.vencidos(ctx, ahora)
	if err != nil {
		return err
	}
	for _, pg := range ps {
		c, err := s.alm.porID(ctx, pg.cuenta)
		if err != nil || c == nil {
			return err
		}
		switch pg.tipo {
		case "borrar":
			if err := s.borrarCuenta(ctx, c, true); err != nil {
				return err
			}
		case "empezar":
			err := s.alm.enTx(ctx, func(tx *sql.Tx) error {
				if _, err := tx.ExecContext(ctx, `UPDATE cuentas SET cadena = ?, sal = ?, verificador = ?, ee = ?
				  WHERE id = ?`, pg.cadenaNueva.String, pg.sal, pg.verif, pg.ee, c.id); err != nil {
					return err
				}
				if _, err := tx.ExecContext(ctx, `INSERT OR REPLACE INTO cuenta_sustituidas (cadena, fecha) VALUES (?, ?)`,
					c.cadena, ahora); err != nil {
					return err
				}
				// Los Macs de la cadena vieja dejan la lista: la cadena nueva se registra con aparatos/renovar.
				if _, err := tx.ExecContext(ctx, `DELETE FROM cuenta_aparatos WHERE cuenta = ?`, c.id); err != nil {
					return err
				}
				if _, err := tx.ExecContext(ctx, `DELETE FROM cuenta_programados WHERE cuenta = ?`, c.id); err != nil {
					return err
				}
				return s.evento(ctx, tx, c.id, evCadenaCambiada, datosEvento{})
			})
			if err != nil {
				return err
			}
			if err := s.cfg.Cadenas.Borrar(ctx, c.cadena); err != nil {
				return err
			}
			s.avisar(c, evCadenaCambiada, "")
		}
	}
	return nil
}

// --- inactivas (§7) ---
//
// Con FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS > 0: a (días − aviso) sin escrituras de la cadena, un correo; a los días,
// se borra cuenta, cadena y email. Una cadena en uso renueva su ficha a diario y nunca llega. Una cuenta cuya cadena
// ya está desactivada (se borró con el protocolo de sync desde un Mac sin cuenta, o la borró la regla de
// inactivas de hoy) se borra también, «una cadena, una cuenta», pero con el borrado normal de 14 días y su aviso
// [C: COORDINACIÓN-41, decisión 12]; un Mac lo puede cancelar (y, con la contraseña, cambiar a una cadena nueva).
// Tras cancelarlo no se vuelve a programar en 30 días, como el pedido por email.
func (s *Servicio) inactivas(ctx context.Context, ahora int64) error {
	rows, err := s.cfg.DB.QueryContext(ctx, `SELECT `+columnas+` FROM cuentas`)
	if err != nil {
		return err
	}
	var cs []*registro
	for rows.Next() {
		c, err := leerRegistro(rows)
		if err != nil {
			rows.Close()
			return err
		}
		cs = append(cs, c)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return err
	}
	dias := int64(s.cfg.InactivasDias)
	for _, c := range cs {
		des, err := s.cfg.Cadenas.Desactivada(ctx, c.cadena)
		if err != nil {
			return err
		}
		if des {
			if err := s.programarHuerfana(ctx, c, ahora); err != nil {
				return err
			}
			continue
		}
		if dias <= 0 {
			continue
		}
		ultima, hay, err := s.cfg.Cadenas.UltimaEscritura(ctx, c.cadena)
		if err != nil {
			return err
		}
		ultimaS := ultima / 1000
		if !hay {
			ultimaS = c.creada
		}
		sinUso := ahora - ultimaS
		switch {
		case sinUso >= dias*86400:
			if err := s.borrarCuenta(ctx, c, true); err != nil {
				return err
			}
		case sinUso >= (dias-int64(s.cfg.AvisoDias))*86400:
			var avisado int64
			if err := s.cfg.DB.QueryRowContext(ctx, `SELECT aviso_inactiva FROM cuentas WHERE id = ?`, c.id).Scan(&avisado); err != nil {
				return err
			}
			if avisado == 0 {
				if _, err := s.cfg.DB.ExecContext(ctx, `UPDATE cuentas SET aviso_inactiva = ? WHERE id = ?`, ahora, c.id); err != nil {
					return err
				}
				s.avisar(c, "inactiva", "")
			}
		default:
			if _, err := s.cfg.DB.ExecContext(ctx, `UPDATE cuentas SET aviso_inactiva = 0 WHERE id = ? AND aviso_inactiva != 0`, c.id); err != nil {
				return err
			}
		}
	}
	return nil
}

// programarHuerfana programa a 14 días el borrado de una cuenta cuya cadena ya está desactivada, con evento y aviso,
// si no hay ya uno programado ni se canceló hace menos de 30 días.
func (s *Servicio) programarHuerfana(ctx context.Context, c *registro, ahora int64) error {
	if c.cancelado != 0 && ahora-c.cancelado < int64(trasCancelacion/time.Second) {
		return nil
	}
	programado := false
	fecha := ahora + int64(s.cfg.Demora/time.Second)
	err := s.alm.enTx(ctx, func(tx *sql.Tx) error {
		r, err := tx.ExecContext(ctx, `INSERT OR IGNORE INTO cuenta_programados (cuenta, tipo, pedido, fecha)
		  VALUES (?, 'borrar', ?, ?)`, c.id, ahora, fecha)
		if err != nil {
			return err
		}
		n, err := r.RowsAffected()
		if err != nil || n == 0 {
			return err
		}
		programado = true
		return s.evento(ctx, tx, c.id, evBorradoPedido, datosEvento{Fecha: fecha})
	})
	if err == nil && programado {
		s.avisar(c, evBorradoPedido, "")
	}
	return err
}
