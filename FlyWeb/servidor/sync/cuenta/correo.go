// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"bytes"
	"context"
	"encoding/hex"
	"fmt"
	"mime"
	"mime/quotedprintable"
	"net/smtp"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/rs/zerolog/log"
)

// Enviador manda un correo ya compuesto. El de verdad habla SMTP con el MTA local (sync-cuenta.md §10: nunca un
// servicio de terceros); las pruebas usan uno en memoria.
type Enviador interface {
	Enviar(ctx context.Context, para string, mensaje []byte) error
}

// SMTPLocal entrega por SMTP sin autenticación al MTA de la propia máquina (o al relé que diga SERVIDOR).
type SMTPLocal struct {
	Direccion string // host:puerto, p. ej. 127.0.0.1:25
	Desde     string
}

func (s SMTPLocal) Enviar(_ context.Context, para string, mensaje []byte) error {
	return smtp.SendMail(s.Direccion, nil, s.Desde, []string{para}, mensaje)
}

// componer arma el mensaje: texto plano UTF-8 en quoted-printable, asunto codificado. Las direcciones ya vienen
// normalizadas (sin CR ni LF: NormalizarEmail).
func componer(desde, para, asunto, cuerpo string, ahora time.Time) []byte {
	var b bytes.Buffer
	dominio := desde[strings.LastIndexByte(desde, '@')+1:]
	fmt.Fprintf(&b, "From: FlyWeb <%s>\r\n", desde)
	fmt.Fprintf(&b, "To: <%s>\r\n", para)
	fmt.Fprintf(&b, "Subject: %s\r\n", mime.QEncoding.Encode("utf-8", asunto))
	fmt.Fprintf(&b, "Date: %s\r\n", ahora.UTC().Format(time.RFC1123Z))
	fmt.Fprintf(&b, "Message-ID: <%s@%s>\r\n", hex.EncodeToString(aleatorio(16)), dominio)
	b.WriteString("MIME-Version: 1.0\r\nContent-Type: text/plain; charset=utf-8\r\n")
	b.WriteString("Content-Transfer-Encoding: quoted-printable\r\nAuto-Submitted: auto-generated\r\n\r\n")
	w := quotedprintable.NewWriter(&b)
	w.Write([]byte(strings.ReplaceAll(cuerpo, "\n", "\r\n")))
	w.Close()
	return b.Bytes()
}

type claseCorreo int

const (
	correoAlta claseCorreo = iota + 1
	correoCodigo
	correoAviso
)

type correoPendiente struct {
	clase     claseCorreo
	para      string
	mensaje   []byte
	caduca    time.Time // los códigos no sirven después; los avisos se reintentan hasta aquí
	siguiente time.Time
	intentos  int
}

// Cola de correo en memoria, con un solo repartidor. Los códigos se dan por perdidos cuando caducan; los avisos se
// reintentan con espera creciente durante 3 días si el MTA no responde, y nunca se descartan por cupo (N3b).
// Enviar fuera de la petición hace que contestar no tarde más cuando hay correo que cuando no lo hay (O1).
// Límite: un reinicio del servicio pierde lo que esté en la cola.
type colaCorreo struct {
	env                    Enviador
	desde                  string
	ahora                  func() time.Time
	mu                     sync.Mutex
	cola                   []*correoPendiente
	aviso                  chan struct{}
	altas, codigos, avisos atomic.Int64 // enviados (contador anónimo, §9)
}

const vidaAviso = 72 * time.Hour

func nuevaColaCorreo(env Enviador, desde string, ahora func() time.Time) *colaCorreo {
	return &colaCorreo{env: env, desde: desde, ahora: ahora, aviso: make(chan struct{}, 1)}
}

func (c *colaCorreo) poner(clase claseCorreo, para, asunto, cuerpo string, caduca time.Time) {
	ahora := c.ahora()
	m := &correoPendiente{clase: clase, para: para, mensaje: componer(c.desde, para, asunto, cuerpo, ahora),
		caduca: caduca, siguiente: ahora}
	c.mu.Lock()
	c.cola = append(c.cola, m)
	c.mu.Unlock()
	select {
	case c.aviso <- struct{}{}:
	default:
	}
}

// repartir envía lo que toca; devuelve cuándo volver a mirar.
func (c *colaCorreo) repartir(ctx context.Context) time.Duration {
	c.mu.Lock()
	ahora := c.ahora()
	var listos, resto []*correoPendiente
	for _, m := range c.cola {
		switch {
		case !ahora.Before(m.caduca):
			log.Warn().Int("clase", int(m.clase)).Msg("cuenta: correo descartado: ha caducado en la cola")
		case !ahora.Before(m.siguiente):
			listos = append(listos, m)
		default:
			resto = append(resto, m)
		}
	}
	c.cola = resto
	c.mu.Unlock()
	for _, m := range listos {
		if err := c.env.Enviar(ctx, m.para, m.mensaje); err != nil {
			m.intentos++
			m.siguiente = c.ahora().Add(min(time.Duration(1<<min(m.intentos, 10))*15*time.Second, time.Hour))
			log.Warn().Err(err).Msg("cuenta: el MTA no acepta el correo; se reintentará")
			c.mu.Lock()
			c.cola = append(c.cola, m)
			c.mu.Unlock()
			continue
		}
		switch m.clase {
		case correoAlta:
			c.altas.Add(1)
		case correoCodigo:
			c.codigos.Add(1)
		case correoAviso:
			c.avisos.Add(1)
		}
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	espera := time.Minute
	for _, m := range c.cola {
		espera = min(espera, max(m.siguiente.Sub(c.ahora()), time.Second))
	}
	return espera
}

func (c *colaCorreo) funcionar(ctx context.Context) {
	for {
		espera := c.repartir(ctx)
		t := time.NewTimer(espera)
		select {
		case <-ctx.Done():
			t.Stop()
			return
		case <-c.aviso:
			t.Stop()
		case <-t.C:
		}
	}
}

// Pendientes: cuántos correos esperan (pruebas).
func (c *colaCorreo) Pendientes() int {
	c.mu.Lock()
	defer c.mu.Unlock()
	return len(c.cola)
}
