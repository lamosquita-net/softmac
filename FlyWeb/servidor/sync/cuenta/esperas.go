// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"container/list"
	"sync"
	"time"
)

// Esperas es la tabla de la espera de la contraseña (sync-cuenta.md §10, N4 y N6). Una entrada por email_hmac,
// exista o no la cuenta; solo en memoria.
//
//   - Tras cada intento la espera se dobla: 10 s, 20 s, 40 s… hasta el tope (15 min).
//   - Vuelve a cero con Reiniciar, o a las 24 h sin intentos.
//   - Una entrada cuya espera no ha terminado no se descarta nunca.
//   - Si la tabla está llena de entradas en espera, un email nuevo recibe la espera máxima y no se comprueba nada.
//   - Para hacer sitio se descarta, entre las que han cumplido su espera, la de espera más corta y, entre iguales,
//     la más antigua.
//
// Para encontrar esa entrada sin recorrer la tabla, las entradas van en una lista por nivel de espera, ordenadas
// por el último intento: en cada nivel la primera es la que antes acaba su espera, así que basta mirar la primera
// de cada nivel, del más corto al más largo.
type Esperas struct {
	mu      sync.Mutex
	max     int
	base    time.Duration
	tope    time.Duration
	caduca  time.Duration
	ahora   func() time.Time
	m       map[string]*entradaEspera
	niveles []*list.List // niveles[i]: entradas con nivel i+1
}

type entradaEspera struct {
	clave  string
	nivel  int // intentos seguidos, sin pasar del último nivel
	ultimo time.Time
	elem   *list.Element
}

func NuevasEsperas(max int, base, tope time.Duration, ahora func() time.Time) *Esperas {
	n := 1
	for base<<(n-1) < tope {
		n++
	}
	t := &Esperas{max: max, base: base, tope: tope, caduca: 24 * time.Hour, ahora: ahora,
		m: map[string]*entradaEspera{}, niveles: make([]*list.List, n)}
	for i := range t.niveles {
		t.niveles[i] = list.New()
	}
	return t
}

func (t *Esperas) espera(nivel int) time.Duration {
	return min(t.base<<(nivel-1), t.tope)
}

func (t *Esperas) hasta(e *entradaEspera) time.Time { return e.ultimo.Add(t.espera(e.nivel)) }

func (t *Esperas) quitar(e *entradaEspera) {
	t.niveles[e.nivel-1].Remove(e.elem)
	delete(t.m, e.clave)
}

// viva devuelve la entrada si existe y no ha caducado (24 h sin intentos); si ha caducado la quita.
func (t *Esperas) viva(clave string, ahora time.Time) *entradaEspera {
	e := t.m[clave]
	if e != nil && !ahora.Before(e.ultimo.Add(t.caduca)) {
		t.quitar(e)
		return nil
	}
	return e
}

// Hasta dice hasta cuándo hay que esperar; cero si se puede intentar. No anota nada: es la consulta que se hace
// antes de pedir turno en el semáforo.
func (t *Esperas) Hasta(clave string) time.Time {
	t.mu.Lock()
	defer t.mu.Unlock()
	ahora := t.ahora()
	e := t.viva(clave, ahora)
	if e == nil {
		if len(t.m) >= t.max && !t.hayHueco(ahora) {
			return ahora.Add(t.tope)
		}
		return time.Time{}
	}
	if h := t.hasta(e); ahora.Before(h) {
		return h
	}
	return time.Time{}
}

// Anotar vuelve a mirar la espera y, si se puede, anota el intento (crea la entrada y crece la espera). Se llama
// al recibir turno en el semáforo de scrypt. Si no se puede, devuelve hasta cuándo.
func (t *Esperas) Anotar(clave string) (bool, time.Time) {
	t.mu.Lock()
	defer t.mu.Unlock()
	ahora := t.ahora()
	e := t.viva(clave, ahora)
	if e != nil {
		if h := t.hasta(e); ahora.Before(h) {
			return false, h
		}
		t.niveles[e.nivel-1].Remove(e.elem)
		e.nivel = min(e.nivel+1, len(t.niveles))
	} else {
		if len(t.m) >= t.max && !t.hacerHueco(ahora) {
			return false, ahora.Add(t.tope)
		}
		e = &entradaEspera{clave: clave, nivel: 1}
		t.m[clave] = e
	}
	e.ultimo = ahora
	e.elem = t.niveles[e.nivel-1].PushBack(e)
	return true, time.Time{}
}

// Reiniciar pone la espera a cero (contraseña buena con algo más: código, prueba de cadena o cambio).
func (t *Esperas) Reiniciar(clave string) {
	t.mu.Lock()
	defer t.mu.Unlock()
	if e := t.m[clave]; e != nil {
		t.quitar(e)
	}
}

// candidata devuelve la entrada que se descartaría para hacer sitio, o nil si todas están en espera. Antes quita
// las caducadas, que están al principio de cada nivel.
func (t *Esperas) candidata(ahora time.Time) *entradaEspera {
	for _, l := range t.niveles {
		for f := l.Front(); f != nil; f = l.Front() {
			e := f.Value.(*entradaEspera)
			if ahora.Before(e.ultimo.Add(t.caduca)) {
				break
			}
			t.quitar(e)
		}
	}
	if len(t.m) < t.max {
		return &entradaEspera{} // ya hay sitio
	}
	for _, l := range t.niveles {
		if f := l.Front(); f != nil {
			if e := f.Value.(*entradaEspera); !ahora.Before(t.hasta(e)) {
				return e
			}
		}
	}
	return nil
}

func (t *Esperas) hayHueco(ahora time.Time) bool { return t.candidata(ahora) != nil }

func (t *Esperas) hacerHueco(ahora time.Time) bool {
	e := t.candidata(ahora)
	if e == nil {
		return false
	}
	if e.elem != nil {
		t.quitar(e)
	}
	return true
}

// Purgar quita las entradas caducadas (la tarea periódica; también se hace al buscar sitio).
func (t *Esperas) Purgar() {
	t.mu.Lock()
	defer t.mu.Unlock()
	t.candidata(t.ahora())
}

// Len es el número de entradas (pruebas).
func (t *Esperas) Len() int {
	t.mu.Lock()
	defer t.mu.Unlock()
	return len(t.m)
}
