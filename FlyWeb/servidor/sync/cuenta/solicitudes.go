// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"container/list"
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
// (email sin cuenta, contraseña mala) tiene la misma forma que una verdadera y no se guarda al darla. Si alguien
// prueba códigos con un identificador válido que no está en la tabla, se crea entonces una entrada falsa: el ritmo
// de 10 s es el mismo para las verdaderas y las falsas, y el ritmo no dice si la contraseña era buena.
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
	elem         *list.Element
}

type solicitudes struct {
	clave  []byte
	max    int
	ahora  func() time.Time
	mu     sync.Mutex
	m      map[string]*solicitud
	falsas *list.List // falsas por hora del último intento
}

func nuevasSolicitudes(max int, ahora func() time.Time) *solicitudes {
	return &solicitudes{clave: aleatorio(32), max: max, ahora: ahora, m: map[string]*solicitud{}, falsas: list.New()}
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
			s.borrar(id)
		}
	}
}

// borrar con el cerrojo tomado.
func (s *solicitudes) borrar(id string) {
	if x := s.m[id]; x != nil && x.elem != nil {
		s.falsas.Remove(x.elem)
	}
	delete(s.m, id)
}

// crear guarda una solicitud verdadera con su código y devuelve el código en claro (para el correo). Las
// verdaderas no cuentan para el tope: están acotadas por los cupos de correo.
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
	codigoOcupado
)

// intentar comprueba el código de una solicitud con el ritmo de un intento cada 10 s. Devuelve la solicitud solo
// si el código es correcto y la solicitud es verdadera y del tipo pedido. Con codigoEspera, hasta cuándo.
// No borra la solicitud: lo hace quien la aplica (cerrar), para poder contestar igual si se repite la llamada.
//
// Las entradas falsas solo guardan la hora del último intento, así que una cuyo intento tiene más de 10 s ya no
// cambia nada observable y se puede descartar: van en una lista por hora del último intento y se descartan por
// delante. Si aun así la tabla de falsas está llena (más de max intentos en 10 s), todas las comprobaciones de
// código contestan «ocupado», verdaderas o no: descartar una falsa en su ventana de 10 s, o contestar distinto a
// un identificador que no está en la tabla, diría si la solicitud era verdadera, es decir, si la contraseña era buena.
func (s *solicitudes) intentar(id string, tipo tipoSolicitud, codigo string) (*solicitud, resultadoCodigo, time.Time) {
	caduca, ok := s.idValido(id)
	if !ok {
		return nil, codigoMal, time.Time{}
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	ahora := s.ahora()
	for f := s.falsas.Front(); f != nil; f = s.falsas.Front() {
		y := f.Value.(*solicitud)
		if ahora.Before(y.ultimo.Add(ritmoCodigo)) {
			break
		}
		s.borrar(y.id)
	}
	if s.falsas.Len() >= s.max {
		return nil, codigoOcupado, time.Time{}
	}
	x := s.m[id]
	if x == nil {
		x = &solicitud{id: id, falsa: true, caduca: caduca}
		s.m[id] = x
	}
	if h := x.ultimo.Add(ritmoCodigo); !x.ultimo.IsZero() && ahora.Before(h) {
		return nil, codigoEspera, h
	}
	x.ultimo = ahora
	if x.falsa {
		if x.elem != nil {
			s.falsas.MoveToBack(x.elem)
		} else {
			x.elem = s.falsas.PushBack(x)
		}
	}
	c := normalizarCodigo(codigo)
	if x.falsa || x.tipo != tipo || c == "" || !hmac.Equal(x.codigo, s.mac("codigo", []byte(c))) {
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
	s.borrar(x.id)
}

// quitarDeCuenta borra las solicitudes de una cuenta (al borrarla).
func (s *solicitudes) quitarDeCuenta(cuentaID string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for id, x := range s.m {
		if x.cuentaID == cuentaID {
			s.borrar(id)
		}
	}
}

func (s *solicitudes) Purgar() {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.purgar(s.ahora())
}
