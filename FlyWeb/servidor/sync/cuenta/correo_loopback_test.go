// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"bufio"
	"context"
	"net"
	"strings"
	"testing"
)

func TestEsLoopback(t *testing.T) {
	for dir, quiero := range map[string]bool{
		"127.0.0.1:25": true, "127.0.0.2:2525": true, "[::1]:25": true, "localhost:25": true,
		"192.0.2.1:25": false, "smtp.example.org:25": false, "sin-puerto": false,
	} {
		if got := esLoopback(dir); got != quiero {
			t.Errorf("esLoopback(%q) = %v, quiero %v", dir, got, quiero)
		}
	}
}

// Un MTA en 127.0.0.1 que anuncia STARTTLS (como Postfix con su certificado propio) tiene que recibir el correo
// en claro: antes SMTPLocal intentaba STARTTLS y fallaba al verificar el certificado.
func TestSMTPLocalLoopbackSinSTARTTLS(t *testing.T) {
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer ln.Close()
	recibido := make(chan string, 1)
	go func() {
		c, err := ln.Accept()
		if err != nil {
			return
		}
		defer c.Close()
		r := bufio.NewReader(c)
		w := func(s string) { c.Write([]byte(s + "\r\n")) }
		w("220 prueba ESMTP")
		var datos strings.Builder
		enDatos := false
		for {
			l, err := r.ReadString('\n')
			if err != nil {
				return
			}
			if enDatos {
				if l == ".\r\n" {
					enDatos = false
					w("250 ok")
					continue
				}
				datos.WriteString(l)
				continue
			}
			switch cmd := strings.ToUpper(strings.TrimSpace(l)); {
			case strings.HasPrefix(cmd, "EHLO"):
				w("250-prueba")
				w("250 STARTTLS")
			case strings.HasPrefix(cmd, "STARTTLS"):
				w("454 no deberías pedirlo")
			case cmd == "DATA":
				enDatos = true
				w("354 adelante")
			case cmd == "QUIT":
				w("221 adiós")
				recibido <- datos.String()
				return
			default:
				w("250 ok")
			}
		}
	}()
	s := SMTPLocal{Direccion: ln.Addr().String(), Desde: "noreply@example.org"}
	if err := s.Enviar(context.Background(), "a@example.org", []byte("Subject: x\r\n\r\nhola\r\n")); err != nil {
		t.Fatalf("Enviar: %v", err)
	}
	if got := <-recibido; !strings.Contains(got, "hola") {
		t.Fatalf("no llegó el cuerpo: %q", got)
	}
}
