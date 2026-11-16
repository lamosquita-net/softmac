// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base32"
	"encoding/base64"
	"encoding/binary"
	"strings"
	"sync"
	"time"
)

// Solicitudes de código por email (sync-cuenta.md §6.1 y §10): códigos de 8 caracteres de base32 (40 bits) que
// caducan a los 10 min, con un intento cada 10 s por solicitud y sin cierre por fallos.
//
// Viven en memoria. El identificador lleva caducidad y HMAC con una clave de arranque, así que una solicitud falsa
// (email sin cuenta, contraseña mala) tiene la misma forma que una verdadera y no se guarda nunca.
//
// El ritmo (O1 de SEGURIDAD-PORTES-23) va en una tabla de tamaño fijo, común a verdaderas y falsas: la hora del
// último intento en la casilla HMAC(id) mod M. Una colisión da una espera de más, igual para cualquier solicitud,
// así que el ritmo no dice si la solicitud era verdadera (si la contraseña era buena). No hay nada que llenar ni que
// descartar: ni «ocupado» general ni memoria que crezca con las falsas.
const (
	vidaCodigo     = 10 * time.Minute
	ritmoCodigo    = 10 * time.Second
	largoSolicitud = 16 + 8 + 16
)

type tipoSolicitud int

const (
	solAlta tipoSolicitud = iota + 1
	solEntrar
	solContrasena
	solEmail
	solBorrarEmail
	solEmpezarCero
)

type solicitud struct {
	id           string
	tipo         tipoSolicitud
	falsa        bool
	caduca       time.Time
	ultimo       time.Time // último intento con código
	codigo       []byte    // HMAC del código
	cuentaID     string
	emailHMAC    []byte // alta y email nuevo: la dirección que se va a guardar, ya con HMAC…
	hmacV        int
	emailCifrado []byte // …y cifrada; en claro solo va a la cola de correo
	aesV         int
	email        string // entrar: clave de la tabla de esperas, para ponerla a cero al terminar
	aplicada     []byte // resumen de lo aplicado, para contestar igual si el Mac repite la llamada (§4.6)
	aparato      string // aparato al que se dio token al aplicarla
}

type solicitudes struct {
	clave []byte
	ahora func() time.Time
	mu    sync.Mutex
	m     map[string]*solicitud // solo las verdaderas (acotadas por los cupos de correo)
	ritmo []int64               // hora (ns) del último intento por casilla
}

// nuevasSolicitudes: casillas es el tamaño de la tabla de ritmo (se redondea a potencia de 2; 8 bytes cada una).
func nuevasSolicitudes(casillas int, ahora func() time.Time) *solicitudes {
	m := 1
	for m < casillas {
		m <<= 1
	}
	return &solicitudes{clave: aleatorio(32), ahora: ahora, m: map[string]*solicitud{}, ritmo: make([]int64, m)}
}

func (s *solicitudes) mac(etiqueta string, b []byte) []byte {
	m := hmac.New(sha256.New, s.clave)
	m.Write([]byte(etiqueta))
	m.Write(b)
	return m.Sum(nil)
}

func (s *solicitudes) nuevoID() (string, time.Time) {
	caduca := s.ahora().Add(vidaCodigo)
	b := aleatorio(16)
	b = binary.BigEndian.AppendUint64(b, uint64(caduca.Unix()))
	b = append(b, s.mac("id", b)[:16]...)
	return base64.RawURLEncoding.EncodeToString(b), caduca
}

// idValido comprueba que el identificador lo dio este servidor y no ha caducado.
func (s *solicitudes) idValido(id string) (time.Time, bool) {
	b, err := base64.RawURLEncoding.DecodeString(id)
	if err != nil || len(b) != largoSolicitud || !hmac.Equal(s.mac("id", b[:24])[:16], b[24:]) {
		return time.Time{}, false
	}
	caduca := time.Unix(int64(binary.BigEndian.Uint64(b[16:24])), 0)
	return caduca, s.ahora().Before(caduca)
}

var codigoB32 = base32.StdEncoding.WithPadding(base32.NoPadding)

// NuevoCodigo: 5 bytes aleatorios = 8 caracteres de base32.
func nuevoCodigo() string { return codigoB32.EncodeToString(aleatorio(5)) }

// FormatoCodigo lo enseña como en el correo: K7QM-2XRA.
func formatoCodigo(c string) string { return c[:4] + "-" + c[4:] }

func normalizarCodigo(c string) string {
	c = strings.ToUpper(strings.NewReplacer("-", "", " ", "").Replace(c))
	if len(c) != 8 {
		return ""
	}
	if _, err := codigoB32.DecodeString(c); err != nil {
		return ""
	}
	return c
}

func (s *solicitudes) purgar(ahora time.Time) {
	for id, x := range s.m {
		if !ahora.Before(x.caduca) {
			delete(s.m, id)
		}
	}
}

// crear guarda una solicitud verdadera con su código y devuelve el código en claro (para el correo).
func (s *solicitudes) crear(x *solicitud) string {
	codigo := nuevoCodigo()
	x.id, x.caduca = s.nuevoID()
	x.codigo = s.mac("codigo", []byte(codigo))
	s.mu.Lock()
	defer s.mu.Unlock()
	s.m[x.id] = x
	return codigo
}

// falsa da un identificador con la misma forma, sin guardar nada.
func (s *solicitudes) falsa() string {
	id, _ := s.nuevoID()
	return id
}

type resultadoCodigo int

const (
	codigoMal resultadoCodigo = iota
	codigoBien
	codigoEspera
)

// intentar comprueba el código de una solicitud con el ritmo de un intento cada 10 s. Devuelve la solicitud solo
// si el código es correcto y la solicitud es verdadera y del tipo pedido. Con codigoEspera, hasta cuándo.
// No borra la solicitud: lo hace quien la aplica (cerrar), para poder contestar igual si se repite la llamada.
func (s *solicitudes) intentar(id string, tipo tipoSolicitud, codigo string) (*solicitud, resultadoCodigo, time.Time) {
	if _, ok := s.idValido(id); !ok {
		return nil, codigoMal, time.Time{}
	}
	casilla := binary.BigEndian.Uint64(s.mac("ritmo", []byte(id))) & uint64(len(s.ritmo)-1)
	s.mu.Lock()
	defer s.mu.Unlock()
	ahora := s.ahora()
	if u := s.ritmo[casilla]; u != 0 {
		if h := time.Unix(0, u).Add(ritmoCodigo); ahora.Before(h) {
			return nil, codigoEspera, h
		}
	}
	s.ritmo[casilla] = ahora.UnixNano()
	x := s.m[id]
	c := normalizarCodigo(codigo)
	if x == nil || x.tipo != tipo || c == "" || !hmac.Equal(x.codigo, s.mac("codigo", []byte(c))) {
		return nil, codigoMal, time.Time{}
	}
	return x, codigoBien, time.Time{}
}

// cerrar marca la solicitud como aplicada, con un resumen de lo aplicado, la cuenta y el aparato al que se dio token.
func (s *solicitudes) cerrar(x *solicitud, resumen []byte, cuentaID, aparato string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	x.aplicada, x.cuentaID, x.aparato = resumen, cuentaID, aparato
	x.emailCifrado = nil
}

// quitar borra una solicitud (p. ej. al terminar una entrada).
func (s *solicitudes) quitar(x *solicitud) {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.m, x.id)
}

// quitarDeCuenta borra las solicitudes de una cuenta (al borrarla).
func (s *solicitudes) quitarDeCuenta(cuentaID string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for id, x := range s.m {
		if x.cuentaID == cuentaID {
			delete(s.m, id)
		}
	}
}

func (s *solicitudes) Purgar() {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.purgar(s.ahora())
}
