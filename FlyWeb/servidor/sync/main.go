// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// flyweb-sync: servidor de sincronización de FlyWeb (contraseñas, marcadores…), en ns2.
// Es go-sync de Brave (MPL-2.0, versión fijada en go.mod) con su misma lógica de protocolo y autenticación, pero
// con SQLite en lugar de DynamoDB y caché en memoria en lugar de Redis: un solo binario y un fichero.
// Los datos llegan cifrados de extremo a extremo por el navegador; el servidor no puede leerlos.
// Sin registro de peticiones ni de IP. Solo escucha en local: Apache (sync.flyweb.lamosquita.net) va delante.
package main

import (
	"bytes"
	"compress/gzip"
	"context"
	"errors"
	"io"
	"net"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"runtime"
	"strconv"
	"syscall"
	"time"

	"flyweb-sync/cuenta"

	"github.com/brave/go-sync/auth"
	"github.com/brave/go-sync/cache"
	"github.com/brave/go-sync/controller"
	"github.com/brave/go-sync/middleware"
	syncContext "github.com/brave/go-sync/synccontext"
	"github.com/go-chi/chi/v5"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

const (
	maxCuerpo        = 8 << 20  // comprimido
	maxDescomprimido = 32 << 20 // contra bombas gzip: go-sync descomprime sin límite
)

func env(k, porDefecto string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return porDefecto
}

// limitarCuerpo comprueba el token antes de leer nada (así nadie sin cadena válida nos hace descomprimir) y
// descomprime aquí, con tope, lo que llegue en gzip; go-sync recibe el cuerpo ya plano.
func limitarCuerpo(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if _, err := auth.Authorize(r); err != nil {
			http.Error(w, http.StatusText(http.StatusUnauthorized), http.StatusUnauthorized)
			return
		}
		r.Body = http.MaxBytesReader(w, r.Body, maxCuerpo)
		if r.Header.Get("Content-Encoding") == "gzip" {
			gr, err := gzip.NewReader(r.Body)
			if err != nil {
				http.Error(w, "bad gzip", http.StatusBadRequest)
				return
			}
			plano, err := io.ReadAll(io.LimitReader(gr, maxDescomprimido+1))
			if err != nil || len(plano) > maxDescomprimido {
				http.Error(w, "request too large", http.StatusRequestEntityTooLarge)
				return
			}
			r.Body = io.NopCloser(bytes.NewReader(plano))
			r.Header.Del("Content-Encoding")
		}
		next.ServeHTTP(w, r)
	})
}

// servidor monta las rutas: POST /v2/command/ (go-sync) y, si está configurada, la cuenta en /cuenta/v1 (3.2,
// FlyWeb/docs/sync-cuenta.md); lo demás, 404. Sin /metrics ni pprof.
func servidor(db *SQLite, c *cache.Cache, cuentas http.Handler) (context.Context, http.Handler) {
	ctx := context.WithValue(context.Background(), syncContext.ContextKeyDatastore, db)
	ctx = context.WithValue(ctx, syncContext.ContextKeyCache, c)
	r := chi.NewRouter()
	r.Use(middleware.CommonResponseHeaders)
	r.With(limitarCuerpo).Mount("/v2", controller.SyncRouter(c, db))
	if cuentas != nil {
		r.Mount("/cuenta/v1", cuentas)
	}
	return ctx, http.TimeoutHandler(r, 60*time.Second, "timeout")
}

func entero(k string, porDefecto int) int {
	n, err := strconv.Atoi(env(k, strconv.Itoa(porDefecto)))
	if err != nil || n < 0 {
		log.Fatal().Str("variable", k).Msg("debe ser un número entero no negativo")
	}
	return n
}

// configurarCuentas arranca la cuenta solo si systemd le da sus dos credenciales (LoadCredential=cuenta-hmac y
// cuenta-aes, en $CREDENTIALS_DIRECTORY). Sin ellas, flyweb-sync funciona como antes de la 3.2.
func configurarCuentas(ctx context.Context, db *SQLite, diasInactivas int) http.Handler {
	dir := os.Getenv("CREDENTIALS_DIRECTORY")
	if dir == "" {
		log.Warn().Msg("cuentas desactivadas: sin credenciales")
		return nil
	}
	claveHMAC, err1 := cuenta.LeerCredencial(filepath.Join(dir, "cuenta-hmac"))
	claveAES, err2 := cuenta.LeerCredencial(filepath.Join(dir, "cuenta-aes"))
	if errors.Is(err1, os.ErrNotExist) && errors.Is(err2, os.ErrNotExist) {
		log.Warn().Msg("cuentas desactivadas: sin credenciales")
		return nil
	}
	if err := errors.Join(err1, err2); err != nil {
		log.Fatal().Err(err).Msg("credenciales de las cuentas")
	}
	desde := os.Getenv("FLYWEB_SYNC_CORREO_DESDE")
	s, err := cuenta.Nuevo(ctx, cuenta.Config{
		DB: db.db, Cadenas: db, HMAC: claveHMAC, AES: claveAES,
		Correo: cuenta.SMTPLocal{Direccion: env("FLYWEB_SYNC_SMTP", "127.0.0.1:25"), Desde: desde},
		Desde:  desde,

		CorreosHora:     entero("FLYWEB_SYNC_CORREOS_HORA", 60),
		CorreosAltaHora: entero("FLYWEB_SYNC_CORREOS_ALTA_HORA", 20),
		EsperaTope:      time.Duration(entero("FLYWEB_SYNC_ESPERA_TOPE_MIN", 15)) * time.Minute,
		EsperasMax:      entero("FLYWEB_SYNC_ESPERAS_MAX", 90000),
		ScryptALaVez:    entero("FLYWEB_SYNC_SCRYPT_A_LA_VEZ", runtime.NumCPU()),
		ScryptCola:      entero("FLYWEB_SYNC_SCRYPT_COLA", 0),
		ScryptEspera:    time.Duration(entero("FLYWEB_SYNC_SCRYPT_COLA_S", 25)) * time.Second,
		Demora:          time.Duration(entero("FLYWEB_SYNC_DEMORA_DIAS", 14)) * 24 * time.Hour,
		InactivasDias:   diasInactivas,
		AvisoDias:       entero("FLYWEB_SYNC_AVISO_DIAS", 30),
	})
	if err != nil {
		log.Fatal().Err(err).Msg("cuentas")
	}
	s.Funcionar(ctx)
	log.Warn().Msg("cuentas activadas en /cuenta/v1")
	return s.Router()
}

func main() {
	// Solo avisos y errores: los mensajes informativos de go-sync incluyen el identificador de la cadena.
	zerolog.SetGlobalLevel(zerolog.WarnLevel)
	log.Logger = zerolog.New(os.Stderr).With().Timestamp().Logger()

	db, err := AbrirSQLite(env("FLYWEB_SYNC_DB", "/var/lib/flyweb-sync/sync.db"))
	if err != nil {
		log.Fatal().Err(err).Msg("no se puede abrir la base de datos")
	}
	defer db.Close()
	c := cache.NewCache(NuevaMemoria())

	// Cadenas sin uso: desactivado por defecto (0). Decisión del HUMANO (03/10): 365 días si algún día se abre a
	// otros usuarios (FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365 en la unidad de systemd).
	diasInactivas, err := strconv.Atoi(env("FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS", "0"))
	if err != nil || diasInactivas < 0 {
		log.Fatal().Msg("FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS debe ser un número de días (0 = no borrar)")
	}
	go func() {
		for range time.Tick(time.Hour) {
			if _, err := db.BorrarCaducados(context.Background()); err != nil {
				log.Error().Err(err).Msg("borrando historial caducado")
			}
			if diasInactivas > 0 {
				antes := time.Now().AddDate(0, 0, -diasInactivas).UnixMilli()
				if n, err := db.BorrarInactivas(context.Background(), antes); err != nil {
					log.Error().Err(err).Msg("borrando cadenas inactivas")
				} else if n > 0 {
					log.Warn().Int("cadenas", n).Msg("borradas cadenas inactivas")
				}
			}
		}
	}()

	fondo, parar := context.WithCancel(context.Background())
	defer parar()
	ctx, h := servidor(db, c, configurarCuentas(fondo, db, diasInactivas))

	srv := &http.Server{
		Addr:              env("FLYWEB_SYNC_LISTEN", "127.0.0.1:8295"),
		Handler:           h,
		BaseContext:       func(net.Listener) context.Context { return ctx },
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       60 * time.Second,
		IdleTimeout:       120 * time.Second,
	}
	go func() {
		sig := make(chan os.Signal, 1)
		signal.Notify(sig, syscall.SIGTERM, syscall.SIGINT)
		<-sig
		apagar, cancel := context.WithTimeout(context.Background(), 20*time.Second)
		defer cancel()
		srv.Shutdown(apagar)
	}()
	log.Warn().Str("escucha", srv.Addr).Msg("flyweb-sync arrancado")
	if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Fatal().Err(err).Msg("servidor")
	}
}
