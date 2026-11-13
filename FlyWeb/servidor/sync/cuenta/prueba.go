// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"crypto/ed25519"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/binary"
	"encoding/hex"
	"errors"
	"net/http"
	"strings"
	"sync"
	"time"
)

// Prueba de cadena (sync-cuenta.md §3.1):
//
//	firma = Ed25519(SK_cadena, "flyweb-cuenta-v1" ‖ op ‖ cuenta_id ‖ nonce ‖ SHA-256(cuerpo))
//
// op, cuenta_id y nonce van con un prefijo de 2 bytes (big endian) con su longitud; el resumen del cuerpo es fijo.
// El cuerpo es el de la petición HTTP tal cual llega. La prueba viaja en cabeceras:
//
//	X-FlyWeb-Cadena: clave pública Ed25519 en hex (la misma que el client_id de go-sync)
//	X-FlyWeb-Nonce:  el nonce que dio /nonce
//	X-FlyWeb-Prueba: la firma en base64 estándar
//
// «cadena/cambiar» lleva además X-FlyWeb-Cadena-Nueva y X-FlyWeb-Prueba-Nueva (mismo nonce, misma op).
// El prefijo no se puede leer como una hora en decimal: una prueba no vale como token de go-sync ni al revés.
const dominioPrueba = "flyweb-cuenta-v1"

const (
	vidaNonce   = 5 * time.Minute
	largoNonceA = 16 // aleatorio
	largoNonce  = largoNonceA + 8 + 16
)

func mensajePrueba(op, cuentaID string, nonce, cuerpo []byte) []byte {
	m := []byte(dominioPrueba)
	for _, campo := range [][]byte{[]byte(op), []byte(cuentaID), nonce} {
		m = binary.BigEndian.AppendUint16(m, uint16(len(campo)))
		m = append(m, campo...)
	}
	h := sha256.Sum256(cuerpo)
	return append(m, h[:]...)
}

// FirmarPrueba es lo que hará el Mac (components/brave_sync/crypto, H3); aquí sirve a las pruebas y de referencia.
func FirmarPrueba(sk ed25519.PrivateKey, op, cuentaID string, nonce, cuerpo []byte) []byte {
	return ed25519.Sign(sk, mensajePrueba(op, cuentaID, nonce, cuerpo))
}

// nonces sin estado para los pendientes (O8): 16 bytes aleatorios ‖ caducidad ‖ HMAC con una clave de arranque.
// Solo se apuntan los usados con una prueba válida, hasta que caducan.
type nonces struct {
	clave []byte
	ahora func() time.Time
	mu    sync.Mutex
	usado map[[largoNonceA]byte]time.Time
}

func nuevosNonces(ahora func() time.Time) *nonces {
	return &nonces{clave: aleatorio(32), ahora: ahora, usado: map[[largoNonceA]byte]time.Time{}}
}

func (n *nonces) mac(b []byte) []byte {
	m := hmac.New(sha256.New, n.clave)
	m.Write([]byte("nonce"))
	m.Write(b)
	return m.Sum(nil)[:16]
}

func (n *nonces) nuevo() []byte {
	b := aleatorio(largoNonceA)
	b = binary.BigEndian.AppendUint64(b, uint64(n.ahora().Add(vidaNonce).Unix()))
	return append(b, n.mac(b)...)
}

// valido comprueba forma, HMAC y caducidad, sin apuntar nada.
func (n *nonces) valido(b []byte) (time.Time, bool) {
	if len(b) != largoNonce || !hmac.Equal(n.mac(b[:largoNonceA+8]), b[largoNonceA+8:]) {
		return time.Time{}, false
	}
	caduca := time.Unix(int64(binary.BigEndian.Uint64(b[largoNonceA:])), 0)
	return caduca, n.ahora().Before(caduca)
}

// gastar apunta el nonce como usado; falla si ya lo estaba. Se llama después de verificar la firma, y comprobar y
// apuntar van bajo el mismo cerrojo (§3.1).
func (n *nonces) gastar(b []byte, caduca time.Time) bool {
	var k [largoNonceA]byte
	copy(k[:], b)
	n.mu.Lock()
	defer n.mu.Unlock()
	ahora := n.ahora()
	for u, c := range n.usado {
		if !ahora.Before(c) {
			delete(n.usado, u)
		}
	}
	if _, ya := n.usado[k]; ya {
		return false
	}
	n.usado[k] = caduca
	return true
}

var errPrueba = errors.New("prueba de cadena no válida")

// cadenaDe lee la clave pública de la cabecera. Se guarda en hex mayúsculas, como el client_id que manda Chromium.
func cadenaDe(r *http.Request, cabecera string) (ed25519.PublicKey, string, bool) {
	h := r.Header.Get(cabecera)
	pk, err := hex.DecodeString(h)
	if err != nil || len(pk) != ed25519.PublicKeySize {
		return nil, "", false
	}
	return pk, strings.ToUpper(h), true
}

func firmaDe(r *http.Request, cabecera string) ([]byte, bool) {
	f, err := base64.StdEncoding.DecodeString(r.Header.Get(cabecera))
	return f, err == nil && len(f) == ed25519.SignatureSize
}

// pruebaLeida es una prueba de forma correcta cuya firma aún no se ha comprobado (falta saber el cuenta_id).
type pruebaLeida struct {
	pk     ed25519.PublicKey
	cadena string
	nonce  []byte
	caduca time.Time
	firma  []byte
}

func leerPrueba(r *http.Request, nn *nonces, cabCadena, cabFirma string) (*pruebaLeida, error) {
	pk, cadena, ok := cadenaDe(r, cabCadena)
	if !ok {
		return nil, errPrueba
	}
	nonce, err := base64.RawURLEncoding.DecodeString(r.Header.Get("X-FlyWeb-Nonce"))
	if err != nil {
		return nil, errPrueba
	}
	caduca, ok := nn.valido(nonce)
	if !ok {
		return nil, errPrueba
	}
	firma, ok := firmaDe(r, cabFirma)
	if !ok {
		return nil, errPrueba
	}
	return &pruebaLeida{pk: pk, cadena: cadena, nonce: nonce, caduca: caduca, firma: firma}, nil
}

func (p *pruebaLeida) verificar(op, cuentaID string, cuerpo []byte) bool {
	return ed25519.Verify(p.pk, mensajePrueba(op, cuentaID, p.nonce, cuerpo), p.firma)
}
