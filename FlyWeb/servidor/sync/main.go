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
	"syscall"
	"time"

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

// servidor monta las rutas: solo POST /v2/command/ (go-sync); lo demás, 404. Sin /metrics ni pprof.
func servidor(db *SQLite, c *cache.Cache) (context.Context, http.Handler) {
	ctx := context.WithValue(context.Background(), syncContext.ContextKeyDatastore, db)
	ctx = context.WithValue(ctx, syncContext.ContextKeyCache, c)
	r := chi.NewRouter()
	r.Use(middleware.CommonResponseHeaders)
	r.With(limitarCuerpo).Mount("/v2", controller.SyncRouter(c, db))
	return ctx, http.TimeoutHandler(r, 60*time.Second, "timeout")
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

	go func() {
		for range time.Tick(time.Hour) {
			if _, err := db.BorrarCaducados(context.Background()); err != nil {
				log.Error().Err(err).Msg("borrando historial caducado")
			}
		}
	}()

	ctx, h := servidor(db, c)

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
