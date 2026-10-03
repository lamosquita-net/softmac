// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// Almacén SQLite para go-sync (FlyWeb): sustituye a DynamoDB con la misma
// semántica que datastore/sync_entity.go y datastore/item_count.go de go-sync.
// Un solo fichero, sin servicios aparte.
package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/brave/go-sync/datastore"
	_ "modernc.org/sqlite"
)

const esquema = `
PRAGMA journal_mode = WAL;
CREATE TABLE IF NOT EXISTS entities (
  client_id TEXT NOT NULL, id TEXT NOT NULL,
  parent_id TEXT, version INTEGER, mtime INTEGER, ctime INTEGER,
  name TEXT, non_unique_name TEXT, server_tag TEXT, deleted INTEGER,
  orig_cache_guid TEXT, orig_client_item_id TEXT, specifics BLOB,
  data_type INTEGER, folder INTEGER, client_tag TEXT, unique_position BLOB,
  expiration INTEGER, data_type_mtime TEXT,
  PRIMARY KEY (client_id, id)) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS entities_tipo_mtime ON entities (client_id, data_type, mtime);
CREATE INDEX IF NOT EXISTS entities_mtime ON entities (client_id, mtime);
-- Etiquetas únicas: id = "Client#<tag>" o "Server#<tag>", como en go-sync.
CREATE TABLE IF NOT EXISTS tags (
  client_id TEXT NOT NULL, id TEXT NOT NULL, mtime INTEGER, ctime INTEGER,
  PRIMARY KEY (client_id, id)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS disabled (
  client_id TEXT PRIMARY KEY, reason TEXT, mtime INTEGER, ctime INTEGER);
CREATE TABLE IF NOT EXISTS counts (
  client_id TEXT PRIMARY KEY, item_count INTEGER, h1 INTEGER, h2 INTEGER, h3 INTEGER, h4 INTEGER,
  last_period_change INTEGER, version INTEGER);
`

// relojCreciente: ver reloj(). Solo se desactiva en las pruebas de go-sync que fijan el mtime a mano.
var relojCreciente = true

// periodo de los contadores de historial (go-sync: periodDurationSecs).
const periodo = int64(datastore.HistoryExpirationIntervalSecs / 4)

type SQLite struct{ db *sql.DB }

var _ datastore.Datastore = (*SQLite)(nil)

func AbrirSQLite(ruta string) (*SQLite, error) {
	db, err := sql.Open("sqlite", "file:"+ruta+"?_pragma=busy_timeout(10000)&_pragma=foreign_keys(0)&_txlock=immediate")
	if err != nil {
		return nil, err
	}
	// SQLite admite un solo escritor: una conexión evita SQLITE_BUSY y serializa las transacciones.
	db.SetMaxOpenConns(1)
	if _, err := db.Exec(esquema); err != nil {
		db.Close()
		return nil, fmt.Errorf("creando el esquema: %w", err)
	}
	return &SQLite{db}, nil
}

func (s *SQLite) Close() error { return s.db.Close() }

// BorrarCaducados quita el historial caducado (en DynamoDB lo hace el TTL).
func (s *SQLite) BorrarCaducados(ctx context.Context) (int64, error) {
	r, err := s.db.ExecContext(ctx, `DELETE FROM entities WHERE expiration > 0 AND expiration < ?`, time.Now().Unix())
	if err != nil {
		return 0, err
	}
	return r.RowsAffected()
}

// BorrarInactivas borra las cadenas sin escrituras desde antesDe (ms) y las deja desactivadas, igual que «Borrar
// datos de sincronización»: un Mac que vuelva recibe DISABLED_BY_ADMIN y el navegador avisa de que la cadena ya no
// existe. Chromium renueva la ficha de cada dispositivo a diario, así que una cadena en uso siempre tiene escrituras
// recientes. Devuelve cuántas cadenas ha borrado.
func (s *SQLite) BorrarInactivas(ctx context.Context, antesDe int64) (int, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT client_id FROM entities GROUP BY client_id HAVING MAX(mtime) < ?`, antesDe)
	if err != nil {
		return 0, err
	}
	var cadenas []string
	for rows.Next() {
		var c string
		if err := rows.Scan(&c); err != nil {
			rows.Close()
			return 0, err
		}
		cadenas = append(cadenas, c)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return 0, err
	}
	for i, c := range cadenas {
		if err := s.DisableSyncChain(ctx, c); err != nil {
			return i, err
		}
		if _, err := s.ClearServerData(ctx, c); err != nil {
			return i, err
		}
	}
	return len(cadenas), nil
}

func b2i(b *bool) any {
	if b == nil {
		return nil
	}
	if *b {
		return 1
	}
	return 0
}

// reloj hace el mtime estrictamente creciente dentro de cada cadena (y la versión, que en go-sync es el mtime).
// go-sync pone mtime = ahora en milisegundos; dos escrituras en el mismo milisegundo empatarían, y el token de
// GetUpdates (mtime > token) podría saltarse la segunda o desordenar padres e hijos. En DynamoDB no pasa porque
// cada escritura tarda más de 1 ms. go-sync lee e.Mtime y e.Version después de escribir: el cambio llega al cliente.
func reloj(ctx context.Context, tx *sql.Tx, e *datastore.SyncEntity) error {
	if !relojCreciente {
		return nil
	}
	var ultimo sql.NullInt64
	if err := tx.QueryRowContext(ctx, `SELECT MAX(mtime) FROM entities WHERE client_id = ?`, e.ClientID).Scan(&ultimo); err != nil {
		return err
	}
	if ultimo.Valid && *e.Mtime <= ultimo.Int64 {
		m := ultimo.Int64 + 1
		// La versión sigue al mtime solo si era el mtime (commits); las entidades del servidor llevan versión 1.
		if e.Version != nil && *e.Version == *e.Mtime {
			*e.Version = m
		}
		*e.Mtime = m
		if e.DataType != nil {
			dm := fmt.Sprintf("%d#%d", *e.DataType, m)
			e.DataTypeMtime = &dm
		}
	}
	return nil
}

func insertarEntidad(ctx context.Context, tx *sql.Tx, e *datastore.SyncEntity) error {
	if err := reloj(ctx, tx, e); err != nil {
		return err
	}
	_, err := tx.ExecContext(ctx, `INSERT INTO entities (client_id, id, parent_id, version, mtime, ctime, name,
	  non_unique_name, server_tag, deleted, orig_cache_guid, orig_client_item_id, specifics, data_type, folder,
	  client_tag, unique_position, expiration, data_type_mtime) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
		e.ClientID, e.ID, e.ParentID, e.Version, e.Mtime, e.Ctime, e.Name, e.NonUniqueName, e.ServerDefinedUniqueTag,
		b2i(e.Deleted), e.OriginatorCacheGUID, e.OriginatorClientItemID, e.Specifics, e.DataType, b2i(e.Folder),
		e.ClientDefinedUniqueTag, e.UniquePosition, e.ExpirationTime, e.DataTypeMtime)
	return err
}

// insertarEtiqueta falla (conflicto) si la etiqueta ya existe para ese cliente.
func insertarEtiqueta(ctx context.Context, tx *sql.Tx, clientID, tag string, servidor bool) error {
	t := datastore.NewServerClientUniqueTagItem(clientID, tag, servidor)
	_, err := tx.ExecContext(ctx, `INSERT INTO tags (client_id, id, mtime, ctime) VALUES (?,?,?,?)`,
		t.ClientID, t.ID, t.Mtime, t.Ctime)
	return err
}

func esConflicto(err error) bool {
	// modernc.org/sqlite: "constraint failed: UNIQUE constraint failed: tags.client_id, tags.id (1555)".
	return err != nil && strings.Contains(err.Error(), "constraint failed")
}

func (s *SQLite) enTx(ctx context.Context, f func(*sql.Tx) error) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	if err := f(tx); err != nil {
		tx.Rollback()
		return err
	}
	return tx.Commit()
}

// InsertSyncEntity: devuelve conflict=true (con error) si la etiqueta de cliente ya existe.
func (s *SQLite) InsertSyncEntity(ctx context.Context, e *datastore.SyncEntity) (bool, error) {
	conTag := e.ClientDefinedUniqueTag != nil && *e.DataType != datastore.HistoryTypeID
	err := s.enTx(ctx, func(tx *sql.Tx) error {
		if conTag {
			if err := insertarEtiqueta(ctx, tx, e.ClientID, *e.ClientDefinedUniqueTag, false); err != nil {
				return err
			}
		}
		return insertarEntidad(ctx, tx, e)
	})
	if err != nil {
		return conTag && esConflicto(err), fmt.Errorf("error inserting sync item: %w", err)
	}
	return false, nil
}

func (s *SQLite) InsertSyncEntitiesWithServerTags(ctx context.Context, es []*datastore.SyncEntity) error {
	err := s.enTx(ctx, func(tx *sql.Tx) error {
		for _, e := range es {
			if err := insertarEtiqueta(ctx, tx, e.ClientID, *e.ServerDefinedUniqueTag, true); err != nil {
				return err
			}
			if err := insertarEntidad(ctx, tx, e); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		return fmt.Errorf("error writing sync entities with server tags in a transaction: %w", err)
	}
	return nil
}

var errConflicto = errors.New("conflicto")

func (s *SQLite) UpdateSyncEntity(ctx context.Context, e *datastore.SyncEntity, oldVersion int64) (bool, bool, error) {
	borradoConTag := e.Deleted != nil && e.ClientDefinedUniqueTag != nil && *e.Deleted &&
		*e.DataType != datastore.HistoryTypeID
	var antes sql.NullInt64
	err := s.enTx(ctx, func(tx *sql.Tx) error {
		var version sql.NullInt64
		err := tx.QueryRowContext(ctx, `SELECT version, deleted FROM entities WHERE client_id = ? AND id = ?`,
			e.ClientID, e.ID).Scan(&version, &antes)
		if errors.Is(err, sql.ErrNoRows) {
			return errConflicto
		}
		if err != nil {
			return err
		}
		if *e.DataType != datastore.HistoryTypeID && (!version.Valid || version.Int64 != oldVersion) {
			return errConflicto
		}
		if err := reloj(ctx, tx, e); err != nil {
			return err
		}
		// Campos opcionales: solo si vienen (COALESCE con el valor actual).
		_, err = tx.ExecContext(ctx, `UPDATE entities SET version = ?, mtime = ?, specifics = ?, data_type_mtime = ?,
		  unique_position = COALESCE(?, unique_position), parent_id = COALESCE(?, parent_id),
		  name = COALESCE(?, name), non_unique_name = COALESCE(?, non_unique_name),
		  deleted = COALESCE(?, deleted), folder = COALESCE(?, folder)
		  WHERE client_id = ? AND id = ?`,
			e.Version, e.Mtime, e.Specifics, e.DataTypeMtime, e.UniquePosition, e.ParentID, e.Name, e.NonUniqueName,
			b2i(e.Deleted), b2i(e.Folder), e.ClientID, e.ID)
		if err != nil {
			return err
		}
		if borradoConTag {
			_, err = tx.ExecContext(ctx, `DELETE FROM tags WHERE client_id = ? AND id = ?`,
				e.ClientID, "Client#"+*e.ClientDefinedUniqueTag)
		}
		return err
	})
	if errors.Is(err, errConflicto) {
		return true, false, nil
	}
	if err != nil {
		return false, false, fmt.Errorf("error updating sync entity: %w", err)
	}
	if borradoConTag {
		return false, true, nil // igual que go-sync
	}
	switch {
	case e.Deleted == nil:
		return false, false, nil
	case !antes.Valid:
		return false, *e.Deleted, nil
	default:
		return false, antes.Int64 == 0 && *e.Deleted, nil
	}
}

func (s *SQLite) GetUpdatesForType(ctx context.Context, dataType int, clientToken int64, fetchFolders bool,
	clientID string, maxSize int) (bool, []datastore.SyncEntity, error) {
	q := `SELECT client_id, id, parent_id, version, mtime, ctime, name, non_unique_name, server_tag, deleted,
	  orig_cache_guid, orig_client_item_id, specifics, data_type, folder, client_tag, unique_position, expiration,
	  data_type_mtime FROM entities WHERE client_id = ? AND data_type = ? AND mtime > ?`
	if !fetchFolders {
		q += ` AND folder = 0`
	}
	q += ` ORDER BY mtime LIMIT ?`
	rows, err := s.db.QueryContext(ctx, q, clientID, dataType, clientToken, maxSize)
	if err != nil {
		return false, nil, fmt.Errorf("error doing query to get updates: %w", err)
	}
	defer rows.Close()
	var es []datastore.SyncEntity
	for rows.Next() {
		e, err := leerEntidad(rows)
		if err != nil {
			return false, nil, err
		}
		es = append(es, e)
	}
	if err := rows.Err(); err != nil {
		return false, nil, err
	}
	// Como DynamoDB (LastEvaluatedKey): «quedan más» si se llegó al límite, aunque no quede ninguna. Cuesta, como
	// mucho, una consulta más del navegador.
	hayMas := len(es) >= maxSize
	ahora := time.Now().Unix()
	out := make([]datastore.SyncEntity, 0, len(es))
	for _, e := range es {
		if e.ExpirationTime != nil && *e.ExpirationTime > 0 && *e.ExpirationTime < ahora {
			continue
		}
		out = append(out, e)
	}
	return hayMas, out, nil
}

type escaner interface{ Scan(...any) error }

func leerEntidad(r escaner) (datastore.SyncEntity, error) {
	var e datastore.SyncEntity
	var parent, name, nun, stag, ocg, ocii, ctag, dtm sql.NullString
	var version, mtime, ctime, deleted, dtype, folder, exp sql.NullInt64
	err := r.Scan(&e.ClientID, &e.ID, &parent, &version, &mtime, &ctime, &name, &nun, &stag, &deleted, &ocg, &ocii,
		&e.Specifics, &dtype, &folder, &ctag, &e.UniquePosition, &exp, &dtm)
	if err != nil {
		return e, err
	}
	str := func(n sql.NullString) *string {
		if !n.Valid {
			return nil
		}
		v := n.String
		return &v
	}
	i64 := func(n sql.NullInt64) *int64 {
		if !n.Valid {
			return nil
		}
		v := n.Int64
		return &v
	}
	bl := func(n sql.NullInt64) *bool {
		if !n.Valid {
			return nil
		}
		v := n.Int64 != 0
		return &v
	}
	e.ParentID, e.Name, e.NonUniqueName, e.ServerDefinedUniqueTag = str(parent), str(name), str(nun), str(stag)
	e.OriginatorCacheGUID, e.OriginatorClientItemID, e.ClientDefinedUniqueTag = str(ocg), str(ocii), str(ctag)
	e.Version, e.Mtime, e.Ctime, e.ExpirationTime = i64(version), i64(mtime), i64(ctime), i64(exp)
	e.Deleted, e.Folder = bl(deleted), bl(folder)
	e.DataTypeMtime = str(dtm)
	if dtype.Valid {
		v := int(dtype.Int64)
		e.DataType = &v
	}
	return e, nil
}

func (s *SQLite) existe(ctx context.Context, q string, args ...any) (bool, error) {
	var x int
	err := s.db.QueryRowContext(ctx, q, args...).Scan(&x)
	if errors.Is(err, sql.ErrNoRows) {
		return false, nil
	}
	return err == nil, err
}

func (s *SQLite) HasServerDefinedUniqueTag(ctx context.Context, clientID, tag string) (bool, error) {
	return s.existe(ctx, `SELECT 1 FROM tags WHERE client_id = ? AND id = ?`, clientID, "Server#"+tag)
}

func (s *SQLite) HasItem(ctx context.Context, clientID, id string) (bool, error) {
	return s.existe(ctx, `SELECT 1 FROM entities WHERE client_id = ? AND id = ?`, clientID, id)
}

func (s *SQLite) DisableSyncChain(ctx context.Context, clientID string) error {
	now := time.Now().UnixMilli()
	_, err := s.db.ExecContext(ctx, `INSERT OR REPLACE INTO disabled (client_id, reason, mtime, ctime) VALUES (?,?,?,?)`,
		clientID, "deleted", now, now)
	return err
}

func (s *SQLite) IsSyncChainDisabled(ctx context.Context, clientID string) (bool, error) {
	return s.existe(ctx, `SELECT 1 FROM disabled WHERE client_id = ?`, clientID)
}

// ClearServerData borra todo lo de la cadena (entidades, etiquetas y contador) salvo la marca de desactivada.
func (s *SQLite) ClearServerData(ctx context.Context, clientID string) ([]datastore.SyncEntity, error) {
	var es []datastore.SyncEntity
	err := s.enTx(ctx, func(tx *sql.Tx) error {
		rows, err := tx.QueryContext(ctx, `SELECT id, mtime, version, data_type FROM entities WHERE client_id = ?`, clientID)
		if err != nil {
			return err
		}
		for rows.Next() {
			e := datastore.SyncEntity{ClientID: clientID}
			var mtime, version, dtype sql.NullInt64
			if err := rows.Scan(&e.ID, &mtime, &version, &dtype); err != nil {
				rows.Close()
				return err
			}
			if mtime.Valid {
				e.Mtime = &mtime.Int64
			}
			if version.Valid {
				e.Version = &version.Int64
			}
			if dtype.Valid {
				v := int(dtype.Int64)
				e.DataType = &v
			}
			es = append(es, e)
		}
		rows.Close()
		// Como en DynamoDB (tabla única), también se devuelven los demás elementos de la cadena (etiquetas, contador y
		// marca de desactivada), sin DataType: go-sync solo usa los que lo tienen.
		otros, err := tx.QueryContext(ctx, `SELECT id FROM tags WHERE client_id = ?1
		  UNION ALL SELECT client_id FROM counts WHERE client_id = ?1
		  UNION ALL SELECT 'disabled_chain' FROM disabled WHERE client_id = ?1`, clientID)
		if err != nil {
			return err
		}
		for otros.Next() {
			e := datastore.SyncEntity{ClientID: clientID}
			if err := otros.Scan(&e.ID); err != nil {
				otros.Close()
				return err
			}
			es = append(es, e)
		}
		otros.Close()
		for _, t := range []string{"entities", "tags", "counts"} {
			if _, err := tx.ExecContext(ctx, `DELETE FROM `+t+` WHERE client_id = ?`, clientID); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("error deleting sync entities for client %s: %w", clientID, err)
	}
	return es, nil
}

func (s *SQLite) GetClientItemCount(ctx context.Context, clientID string) (*datastore.ClientItemCounts, error) {
	c := &datastore.ClientItemCounts{ClientID: clientID, ID: clientID}
	err := s.db.QueryRowContext(ctx, `SELECT item_count, h1, h2, h3, h4, last_period_change, version FROM counts
	  WHERE client_id = ?`, clientID).Scan(&c.ItemCount, &c.HistoryItemCountPeriod1, &c.HistoryItemCountPeriod2,
		&c.HistoryItemCountPeriod3, &c.HistoryItemCountPeriod4, &c.LastPeriodChangeTime, &c.Version)
	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		return nil, fmt.Errorf("error getting an item-count item: %w", err)
	}
	now := time.Now().Unix()
	if c.Version < datastore.CurrentCountVersion {
		// Cuenta nueva (en SQLite no hay contadores de la versión 1 que migrar).
		c.LastPeriodChangeTime = now
		c.Version = datastore.CurrentCountVersion
	} else if d := now - c.LastPeriodChangeTime; d >= periodo {
		n := int(d / periodo)
		for range n {
			c.HistoryItemCountPeriod1, c.HistoryItemCountPeriod2, c.HistoryItemCountPeriod3 =
				c.HistoryItemCountPeriod2, c.HistoryItemCountPeriod3, c.HistoryItemCountPeriod4
			c.HistoryItemCountPeriod4 = 0
		}
		c.LastPeriodChangeTime += periodo * int64(n)
	}
	return c, nil
}

func (s *SQLite) UpdateClientItemCount(ctx context.Context, c *datastore.ClientItemCounts, normal, historial int) error {
	c.HistoryItemCountPeriod4 += historial
	c.ItemCount += normal
	_, err := s.db.ExecContext(ctx, `INSERT OR REPLACE INTO counts (client_id, item_count, h1, h2, h3, h4,
	  last_period_change, version) VALUES (?,?,?,?,?,?,?,?)`, c.ClientID, c.ItemCount, c.HistoryItemCountPeriod1,
		c.HistoryItemCountPeriod2, c.HistoryItemCountPeriod3, c.HistoryItemCountPeriod4, c.LastPeriodChangeTime, c.Version)
	if err != nil {
		return fmt.Errorf("error updating item-count item: %w", err)
	}
	return nil
}
