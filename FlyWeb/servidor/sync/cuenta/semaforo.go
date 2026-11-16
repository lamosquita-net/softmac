// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"context"
	"errors"
	"sync/atomic"
	"time"
)

// Semaforo limita los scrypt a la vez (sync-cuenta.md §10, N5): como mucho tantos como núcleos; las peticiones de
// más esperan en una cola de longitud fija hasta 25 s y, si no les llega el turno, «servidor ocupado». Con la cola
// llena, «ocupado» al momento. Así la memoria tiene tope: 16 MiB por scrypt en curso, y la cola no reserva nada.
type Semaforo struct {
	turnos  chan struct{}
	cola    chan struct{}
	espera  time.Duration
	enCurso atomic.Int64
	maximo  atomic.Int64 // el máximo de scrypt a la vez que se ha visto (pruebas y registro)
}

var ErrOcupado = errors.New("servidor ocupado")

func NuevoSemaforo(aLaVez, cola int, espera time.Duration) *Semaforo {
	return &Semaforo{turnos: make(chan struct{}, aLaVez), cola: make(chan struct{}, cola), espera: espera}
}

// Entrar espera turno. Si lo consigue, hay que llamar a Salir.
func (s *Semaforo) Entrar(ctx context.Context) error {
	select {
	case s.turnos <- struct{}{}:
		s.dentro()
		return nil
	default:
	}
	select {
	case s.cola <- struct{}{}:
	default:
		return ErrOcupado
	}
	defer func() { <-s.cola }()
	t := time.NewTimer(s.espera)
	defer t.Stop()
	select {
	case s.turnos <- struct{}{}:
		s.dentro()
		return nil
	case <-t.C:
		return ErrOcupado
	case <-ctx.Done():
		return ErrOcupado
	}
}

func (s *Semaforo) dentro() {
	n := s.enCurso.Add(1)
	for {
		m := s.maximo.Load()
		if n <= m || s.maximo.CompareAndSwap(m, n) {
			return
		}
	}
}

func (s *Semaforo) Salir() {
	s.enCurso.Add(-1)
	<-s.turnos
}

// Maximo es el máximo de scrypt a la vez que ha habido.
func (s *Semaforo) Maximo() int64 { return s.maximo.Load() }
