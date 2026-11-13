// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
)

// Tablas de las cuentas en el mismo sync.db (sync-cuenta.md §7 y §10). Solo cifrado o seudónimos: el email y el
// nombre de cada Mac van cifrados con la clave AES de la credencial (con su versión); email_hmac sirve para buscar.
// Ni KL, ni KW, ni la envoltura interior E: solo sal, verificador y EE.
const esquema = `
CREATE TABLE IF NOT EXISTS cuentas (
  id TEXT PRIMARY KEY,
  email_hmac BLOB NOT NULL UNIQUE, hmac_v INTEGER NOT NULL,
  email_cifrado BLOB NOT NULL, aes_v INTEGER NOT NULL,
  cadena TEXT NOT NULL UNIQUE,
  sal BLOB NOT NULL, verificador BLOB NOT NULL, ee BLOB NOT NULL,
  creada INTEGER NOT NULL,
  aviso_inactiva INTEGER NOT NULL DEFAULT 0,
  fallos_n INTEGER NOT NULL DEFAULT 0, fallos_desde INTEGER NOT NULL DEFAULT 0,
  fallos_aviso INTEGER NOT NULL DEFAULT 0, fallos_mac BLOB, fallos_mac_v INTEGER NOT NULL DEFAULT 0,
  cancelado INTEGER NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS cuenta_aparatos (
  id TEXT PRIMARY KEY, cuenta TEXT NOT NULL, token_hash BLOB UNIQUE,
  modelo TEXT NOT NULL, nombre_cifrado BLOB NOT NULL, aes_v INTEGER NOT NULL,
  alta INTEGER NOT NULL, ultimo_uso INTEGER NOT NULL);
CREATE INDEX IF NOT EXISTS cuenta_aparatos_cuenta ON cuenta_aparatos (cuenta);
CREATE TABLE IF NOT EXISTS cuenta_eventos (
  cuenta TEXT NOT NULL, n INTEGER NOT NULL, tipo TEXT NOT NULL, fecha INTEGER NOT NULL,
  datos BLOB, aes_v INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (cuenta, n)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS cuenta_programados (
  cuenta TEXT PRIMARY KEY, tipo TEXT NOT NULL, pedido INTEGER NOT NULL, fecha INTEGER NOT NULL,
  cadena_nueva TEXT, sal BLOB, verificador BLOB, ee BLOB);
CREATE TABLE IF NOT EXISTS cuenta_sustituidas (cadena TEXT PRIMARY KEY, fecha INTEGER NOT NULL);
`

type almacen struct{ db *sql.DB }

func (a *almacen) crear(ctx context.Context) error {
	_, err := a.db.ExecContext(ctx, esquema)
	return err
}

func (a *almacen) enTx(ctx context.Context, f func(*sql.Tx) error) error {
	tx, err := a.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	if err := f(tx); err != nil {
		tx.Rollback()
		return err
	}
	return tx.Commit()
}

type registro struct {
	id           string
	emailHMAC    []byte
	hmacV        int
	emailCifrado []byte
	aesV         int
	cadena       string
	sal, verif   []byte
	ee           []byte
	creada       int64
	cancelado    int64
}

const columnas = `id, email_hmac, hmac_v, email_cifrado, aes_v, cadena, sal, verificador, ee, creada, cancelado`

type escaner interface{ Scan(...any) error }

func leerRegistro(r escaner) (*registro, error) {
	c := &registro{}
	err := r.Scan(&c.id, &c.emailHMAC, &c.hmacV, &c.emailCifrado, &c.aesV, &c.cadena, &c.sal, &c.verif, &c.ee,
		&c.creada, &c.cancelado)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	return c, err
}

type consultor interface {
	QueryRowContext(ctx context.Context, q string, args ...any) *sql.Row
}

func porCampo(ctx context.Context, q consultor, campo string, valor any) (*registro, error) {
	return leerRegistro(q.QueryRowContext(ctx, `SELECT `+columnas+` FROM cuentas WHERE `+campo+` = ?`, valor))
}

func (a *almacen) porID(ctx context.Context, id string) (*registro, error) {
	return porCampo(ctx, a.db, "id", id)
}

func (a *almacen) porCadena(ctx context.Context, cadena string) (*registro, error) {
	return porCampo(ctx, a.db, "cadena", cadena)
}

// porEmail busca con cada versión de la clave del HMAC (la actual primero).
func (a *almacen) porEmail(ctx context.Context, hmacs [][]byte) (*registro, error) {
	for _, h := range hmacs {
		c, err := porCampo(ctx, a.db, "email_hmac", h)
		if c != nil || err != nil {
			return c, err
		}
	}
	return nil, nil
}

func insertarCuenta(ctx context.Context, tx *sql.Tx, c *registro) error {
	_, err := tx.ExecContext(ctx, `INSERT INTO cuentas (`+columnas+`) VALUES (?,?,?,?,?,?,?,?,?,?,?)`,
		c.id, c.emailHMAC, c.hmacV, c.emailCifrado, c.aesV, c.cadena, c.sal, c.verif, c.ee, c.creada, c.cancelado)
	return err
}

// cambiarSecreto sustituye sal, verificador y EE a la vez (§4.6: vale la contraseña vieja o la nueva, nunca
// ninguna de las dos).
func cambiarSecreto(ctx context.Context, tx *sql.Tx, id string, sal, verif, ee []byte) error {
	_, err := tx.ExecContext(ctx, `UPDATE cuentas SET sal = ?, verificador = ?, ee = ? WHERE id = ?`, sal, verif, ee, id)
	return err
}

type aparato struct {
	id, cuenta    string
	modelo        string
	nombreCifrado []byte
	aesV          int
	alta, ultimo  int64
}

func insertarAparato(ctx context.Context, tx *sql.Tx, ap *aparato, tokenHash []byte) error {
	_, err := tx.ExecContext(ctx, `INSERT INTO cuenta_aparatos (id, cuenta, token_hash, modelo, nombre_cifrado, aes_v,
	  alta, ultimo_uso) VALUES (?,?,?,?,?,?,?,?)`, ap.id, ap.cuenta, tokenHash, ap.modelo, ap.nombreCifrado, ap.aesV,
		ap.alta, ap.ultimo)
	return err
}

func (a *almacen) aparatos(ctx context.Context, cuenta string) ([]aparato, error) {
	rows, err := a.db.QueryContext(ctx, `SELECT id, cuenta, modelo, nombre_cifrado, aes_v, alta, ultimo_uso
	  FROM cuenta_aparatos WHERE cuenta = ? ORDER BY alta, rowid`, cuenta)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var aps []aparato
	for rows.Next() {
		var ap aparato
		if err := rows.Scan(&ap.id, &ap.cuenta, &ap.modelo, &ap.nombreCifrado, &ap.aesV, &ap.alta, &ap.ultimo); err != nil {
			return nil, err
		}
		aps = append(aps, ap)
	}
	return aps, rows.Err()
}

func (a *almacen) aparato(ctx context.Context, cuenta, id string) (*aparato, error) {
	ap := &aparato{}
	err := a.db.QueryRowContext(ctx, `SELECT id, cuenta, modelo, nombre_cifrado, aes_v, alta, ultimo_uso
	  FROM cuenta_aparatos WHERE cuenta = ? AND id = ?`, cuenta, id).Scan(&ap.id, &ap.cuenta, &ap.modelo,
		&ap.nombreCifrado, &ap.aesV, &ap.alta, &ap.ultimo)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	return ap, err
}

// porToken devuelve el aparato del token si no ha caducado (sin uso desde antesDe).
func (a *almacen) porToken(ctx context.Context, tokenHash []byte, antesDe int64) (*aparato, error) {
	ap := &aparato{}
	err := a.db.QueryRowContext(ctx, `SELECT id, cuenta, modelo, nombre_cifrado, aes_v, alta, ultimo_uso
	  FROM cuenta_aparatos WHERE token_hash = ? AND ultimo_uso >= ?`, tokenHash, antesDe).Scan(&ap.id, &ap.cuenta,
		&ap.modelo, &ap.nombreCifrado, &ap.aesV, &ap.alta, &ap.ultimo)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	return ap, err
}

func (a *almacen) usado(ctx context.Context, id string, ahora int64) error {
	_, err := a.db.ExecContext(ctx, `UPDATE cuenta_aparatos SET ultimo_uso = ? WHERE id = ?`, ahora, id)
	return err
}

func ponerToken(ctx context.Context, tx *sql.Tx, cuenta, id string, tokenHash []byte, ahora int64) (bool, error) {
	r, err := tx.ExecContext(ctx, `UPDATE cuenta_aparatos SET token_hash = ?, ultimo_uso = ? WHERE cuenta = ? AND id = ?`,
		tokenHash, ahora, cuenta, id)
	if err != nil {
		return false, err
	}
	n, err := r.RowsAffected()
	return n == 1, err
}

// invalidarTokens deja sin token a todos los aparatos de la cuenta menos, si se da, uno.
func invalidarTokens(ctx context.Context, tx *sql.Tx, cuenta, salvo string) (int64, error) {
	r, err := tx.ExecContext(ctx, `UPDATE cuenta_aparatos SET token_hash = NULL WHERE cuenta = ? AND id != ?
	  AND token_hash IS NOT NULL`, cuenta, salvo)
	if err != nil {
		return 0, err
	}
	return r.RowsAffected()
}

func anadirEvento(ctx context.Context, tx *sql.Tx, cuenta, tipo string, fecha int64, datos []byte, aesV int) (int64, error) {
	var n int64
	if err := tx.QueryRowContext(ctx, `SELECT COALESCE(MAX(n), 0) + 1 FROM cuenta_eventos WHERE cuenta = ?`,
		cuenta).Scan(&n); err != nil {
		return 0, err
	}
	_, err := tx.ExecContext(ctx, `INSERT INTO cuenta_eventos (cuenta, n, tipo, fecha, datos, aes_v) VALUES (?,?,?,?,?,?)`,
		cuenta, n, tipo, fecha, datos, aesV)
	return n, err
}

type evento struct {
	n     int64
	tipo  string
	fecha int64
	datos []byte
	aesV  int
}

func (a *almacen) eventos(ctx context.Context, cuenta string, desde int64, max int) ([]evento, error) {
	rows, err := a.db.QueryContext(ctx, `SELECT n, tipo, fecha, datos, aes_v FROM cuenta_eventos
	  WHERE cuenta = ? AND n > ? ORDER BY n LIMIT ?`, cuenta, desde, max)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var es []evento
	for rows.Next() {
		var e evento
		if err := rows.Scan(&e.n, &e.tipo, &e.fecha, &e.datos, &e.aesV); err != nil {
			return nil, err
		}
		es = append(es, e)
	}
	return es, rows.Err()
}

// borrarFilas quita todo lo de la cuenta de las tablas de cuentas (la cadena la borra go-sync aparte).
func borrarFilas(ctx context.Context, tx *sql.Tx, cuenta string) error {
	for _, t := range []string{"cuenta_aparatos WHERE cuenta", "cuenta_eventos WHERE cuenta",
		"cuenta_programados WHERE cuenta", "cuentas WHERE id"} {
		if _, err := tx.ExecContext(ctx, `DELETE FROM `+t+` = ?`, cuenta); err != nil {
			return fmt.Errorf("borrando %s: %w", strings.Fields(t)[0], err)
		}
	}
	return nil
}

type programado struct {
	cuenta, tipo   string
	pedido, fecha  int64
	cadenaNueva    sql.NullString
	sal, verif, ee []byte
}

func (a *almacen) programado(ctx context.Context, cuenta string) (*programado, error) {
	p := &programado{}
	err := a.db.QueryRowContext(ctx, `SELECT cuenta, tipo, pedido, fecha, cadena_nueva, sal, verificador, ee
	  FROM cuenta_programados WHERE cuenta = ?`, cuenta).Scan(&p.cuenta, &p.tipo, &p.pedido, &p.fecha, &p.cadenaNueva,
		&p.sal, &p.verif, &p.ee)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	return p, err
}

func (a *almacen) vencidos(ctx context.Context, ahora int64) ([]programado, error) {
	rows, err := a.db.QueryContext(ctx, `SELECT cuenta, tipo, pedido, fecha, cadena_nueva, sal, verificador, ee
	  FROM cuenta_programados WHERE fecha <= ?`, ahora)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var ps []programado
	for rows.Next() {
		var p programado
		if err := rows.Scan(&p.cuenta, &p.tipo, &p.pedido, &p.fecha, &p.cadenaNueva, &p.sal, &p.verif, &p.ee); err != nil {
			return nil, err
		}
		ps = append(ps, p)
	}
	return ps, rows.Err()
}

func (a *almacen) sustituida(ctx context.Context, cadena string, desde int64) (bool, error) {
	var x int
	err := a.db.QueryRowContext(ctx, `SELECT 1 FROM cuenta_sustituidas WHERE cadena = ? AND fecha >= ?`, cadena, desde).Scan(&x)
	if errors.Is(err, sql.ErrNoRows) {
		return false, nil
	}
	return err == nil, err
}

// cadenaLibre: ni ligada a una cuenta, ni programada como cadena nueva, ni sustituida («una cadena, una cuenta»,
// §8). Que no esté desactivada se mira aparte, con go-sync.
func cadenaLibre(ctx context.Context, tx *sql.Tx, cadena string) (bool, error) {
	var x int
	err := tx.QueryRowContext(ctx, `SELECT 1 FROM cuentas WHERE cadena = ?1
	  UNION ALL SELECT 1 FROM cuenta_programados WHERE cadena_nueva = ?1
	  UNION ALL SELECT 1 FROM cuenta_sustituidas WHERE cadena = ?1 LIMIT 1`, cadena).Scan(&x)
	if errors.Is(err, sql.ErrNoRows) {
		return true, nil
	}
	return false, err
}
