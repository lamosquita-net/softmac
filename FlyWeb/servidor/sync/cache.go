// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// Caché en memoria con la interfaz cache.RedisClient de go-sync: sustituye a Redis (un solo proceso, pocos
// usuarios). Si se reinicia, se pierde y no pasa nada: go-sync solo la usa para ahorrar consultas y para los
// contadores provisionales de cada commit.
package main

import (
	"context"
	"strconv"
	"sync"
	"time"

	"github.com/brave/go-sync/cache"
)

type entrada struct {
	valor  string
	caduca time.Time // cero = no caduca
}

type Memoria struct {
	mu sync.Mutex
	m  map[string]entrada
}

var _ cache.RedisClient = (*Memoria)(nil)

func NuevaMemoria() *Memoria {
	c := &Memoria{m: map[string]entrada{}}
	go func() {
		for range time.Tick(time.Minute) {
			c.purgar()
		}
	}()
	return c
}

func (c *Memoria) purgar() {
	c.mu.Lock()
	defer c.mu.Unlock()
	ahora := time.Now()
	for k, e := range c.m {
		if !e.caduca.IsZero() && ahora.After(e.caduca) {
			delete(c.m, k)
		}
	}
}

// leer, con el cerrojo tomado.
func (c *Memoria) leer(k string) (entrada, bool) {
	e, ok := c.m[k]
	if ok && !e.caduca.IsZero() && time.Now().After(e.caduca) {
		delete(c.m, k)
		return entrada{}, false
	}
	return e, ok
}

func (c *Memoria) Set(_ context.Context, k, v string, ttl time.Duration) error {
	c.mu.Lock()
	defer c.mu.Unlock()
	e := entrada{valor: v}
	if ttl > 0 {
		e.caduca = time.Now().Add(ttl)
	}
	c.m[k] = e
	return nil
}

// Incr como INCR/DECR de Redis: la clave ausente vale 0; conserva la caducidad.
func (c *Memoria) Incr(_ context.Context, k string, restar bool) (int, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	e, _ := c.leer(k)
	n := 0
	if e.valor != "" {
		var err error
		if n, err = strconv.Atoi(e.valor); err != nil {
			return 0, err
		}
	}
	if restar {
		n--
	} else {
		n++
	}
	e.valor = strconv.Itoa(n)
	c.m[k] = e
	return n, nil
}

func (c *Memoria) Get(_ context.Context, k string, borrar bool) (string, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	e, ok := c.leer(k)
	if ok && borrar {
		delete(c.m, k)
	}
	return e.valor, nil
}

func (c *Memoria) Del(_ context.Context, ks ...string) error {
	c.mu.Lock()
	defer c.mu.Unlock()
	for _, k := range ks {
		delete(c.m, k)
	}
	return nil
}

func (c *Memoria) FlushAll(context.Context) error {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.m = map[string]entrada{}
	return nil
}
