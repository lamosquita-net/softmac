// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"bufio"
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/hkdf"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/hex"
	"errors"
	"fmt"
	"net/mail"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"unicode"

	"golang.org/x/crypto/scrypt"
	"golang.org/x/text/unicode/norm"
)

// Tamaños fijos del protocolo (sync-cuenta.md §4).
const (
	largoKL         = 32           // clave de entrada, HKDF de KE en el Mac
	largoEnvoltura  = 12 + 32 + 16 // E = nonce GCM ‖ semilla cifrada ‖ etiqueta
	largoSal        = 16
	largoVerificado = 32
)

// Estiramiento del servidor (§4.5): KS = scrypt(KL, sal_servidor, N = 2^14, r = 8, p = 1). 16 MiB por cálculo.
const (
	scryptN = 1 << 14
	scryptR = 8
	scryptP = 1
)

// EstirarScrypt es el estiramiento real; las pruebas lo cambian por otro más barato o que se pueda detener.
func EstirarScrypt(kl, sal []byte) []byte {
	ks, err := scrypt.Key(kl, sal, scryptN, scryptR, scryptP, 32)
	if err != nil {
		panic(err) // solo con parámetros inválidos, que son constantes
	}
	return ks
}

// derivar separa de KS el verificador V y la clave KW que envuelve otra vez la envoltura (§4.5). Las etiquetas
// son solo del servidor: el Mac no las usa.
func derivar(ks []byte) (v, kw []byte) {
	v, err := hkdf.Key(sha256.New, ks, nil, "flyweb-cuenta-v1/servidor/verificador", largoVerificado)
	if err != nil {
		panic(err)
	}
	kw, err = hkdf.Key(sha256.New, ks, nil, "flyweb-cuenta-v1/servidor/envoltura", 32)
	if err != nil {
		panic(err)
	}
	return v, kw
}

func aleatorio(n int) []byte {
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		panic(err)
	}
	return b
}

// sellar y abrir: AES-256-GCM con nonce aleatorio de 96 bits delante del cifrado.
func sellar(clave, claro, asociado []byte) []byte {
	b, err := aes.NewCipher(clave)
	if err != nil {
		panic(err)
	}
	g, err := cipher.NewGCM(b)
	if err != nil {
		panic(err)
	}
	nonce := aleatorio(g.NonceSize())
	return g.Seal(nonce, nonce, claro, asociado)
}

var errSello = errors.New("cifrado no válido")

func abrir(clave, sellado, asociado []byte) ([]byte, error) {
	b, err := aes.NewCipher(clave)
	if err != nil {
		return nil, err
	}
	g, err := cipher.NewGCM(b)
	if err != nil {
		return nil, err
	}
	if len(sellado) < g.NonceSize()+g.Overhead() {
		return nil, errSello
	}
	claro, err := g.Open(nil, sellado[:g.NonceSize()], sellado[g.NonceSize():], asociado)
	if err != nil {
		return nil, errSello
	}
	return claro, nil
}

// Credencial guarda las claves del servidor por versión. La más alta es la actual; las anteriores solo se usan para
// leer lo que se escribió con ellas (rotación tras una brecha, §7).
type Credencial struct {
	claves map[int][]byte
	actual int
}

// LeerCredencial lee un fichero de credencial de systemd (LoadCredential): una línea por versión, «versión
// clave_hex» (32 bytes). Las líneas vacías y las que empiezan por # no cuentan.
func LeerCredencial(ruta string) (*Credencial, error) {
	datos, err := os.ReadFile(ruta)
	if err != nil {
		return nil, err
	}
	c := &Credencial{claves: map[int][]byte{}}
	sc := bufio.NewScanner(bytes.NewReader(datos))
	for sc.Scan() {
		linea := strings.TrimSpace(sc.Text())
		if linea == "" || strings.HasPrefix(linea, "#") {
			continue
		}
		partes := strings.Fields(linea)
		if len(partes) != 2 {
			return nil, fmt.Errorf("%s: cada línea es «versión clave_hex»", filepath.Base(ruta))
		}
		v, err := strconv.Atoi(partes[0])
		if err != nil || v < 1 {
			return nil, fmt.Errorf("%s: versión no válida", filepath.Base(ruta))
		}
		k, err := hex.DecodeString(partes[1])
		if err != nil || len(k) != 32 {
			return nil, fmt.Errorf("%s: la clave son 32 bytes en hex", filepath.Base(ruta))
		}
		if _, dup := c.claves[v]; dup {
			return nil, fmt.Errorf("%s: versión repetida", filepath.Base(ruta))
		}
		c.claves[v] = k
		c.actual = max(c.actual, v)
	}
	if c.actual == 0 {
		return nil, fmt.Errorf("%s: sin claves", filepath.Base(ruta))
	}
	return c, nil
}

// NuevaCredencial crea una credencial de una sola versión (pruebas).
func NuevaCredencial(clave []byte) *Credencial {
	return &Credencial{claves: map[int][]byte{1: clave}, actual: 1}
}

func (c *Credencial) versiones() []int {
	vs := make([]int, 0, len(c.claves))
	for v := range c.claves {
		vs = append(vs, v)
	}
	sort.Sort(sort.Reverse(sort.IntSlice(vs)))
	return vs
}

// hmacEmail calcula email_hmac con una versión de la clave.
func (c *Credencial) hmacEmail(v int, email string) []byte {
	m := hmac.New(sha256.New, c.claves[v])
	m.Write([]byte(email))
	return m.Sum(nil)
}

func (c *Credencial) sellar(asociado, claro []byte) ([]byte, int) {
	return sellar(c.claves[c.actual], claro, asociado), c.actual
}

func (c *Credencial) abrir(v int, asociado, sellado []byte) ([]byte, error) {
	k, ok := c.claves[v]
	if !ok {
		return nil, errSello
	}
	return abrir(k, sellado, asociado)
}

// NormalizarEmail hace lo mismo que el Mac antes de estirar (§4.1): sin espacios a los lados, minúsculas y NFC.
// Además rechaza lo que no sea una dirección simple: va a una cabecera de correo y a RCPT TO.
func NormalizarEmail(s string) (string, bool) {
	s = norm.NFC.String(strings.ToLower(strings.TrimSpace(s)))
	if len(s) < 3 || len(s) > 254 {
		return "", false
	}
	for _, r := range s {
		if unicode.IsSpace(r) || unicode.IsControl(r) || r == '<' || r == '>' || r == '"' || r == ',' || r == ';' {
			return "", false
		}
	}
	a, err := mail.ParseAddress(s)
	if err != nil || a.Address != s || a.Name != "" || strings.Count(s, "@") != 1 {
		return "", false
	}
	if i := strings.LastIndexByte(s, '@'); i < 1 || i == len(s)-1 || !strings.Contains(s[i+1:], ".") {
		return "", false
	}
	return s, true
}

func iguales(a, b []byte) bool { return subtle.ConstantTimeCompare(a, b) == 1 }

func sha(b []byte) []byte {
	h := sha256.Sum256(b)
	return h[:]
}
