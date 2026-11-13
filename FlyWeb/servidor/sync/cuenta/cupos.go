// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"sync"
	"time"

	"github.com/rs/zerolog/log"
)

// Cupos de correo (sync-cuenta.md §10, N2 y N3b), en ventana deslizante de una hora y en memoria:
//
//	(1) alta a direcciones sin cuenta: FLYWEB_SYNC_CORREOS_ALTA_HORA (20) en total;
//	(2) códigos de entrada a cuentas existentes, solo con KL correcta: FLYWEB_SYNC_CORREOS_HORA (60) en total y
//	    5 por cuenta;
//	(3) códigos pedidos con prueba de cadena: 5 por hora y cuenta, fuera de los topes globales;
//	(4) avisos: sin cupo (no pasan por aquí).
//
// Al alcanzar un tope se escribe un aviso en el registro (uno por tope y hora), sin identificar cuentas.
const porCuentaHora = 5

type ventana struct {
	tope   int
	marcas []time.Time
}

func (v *ventana) cabe(ahora time.Time) bool {
	i := 0
	for i < len(v.marcas) && !ahora.Before(v.marcas[i].Add(time.Hour)) {
		i++
	}
	v.marcas = v.marcas[i:]
	return len(v.marcas) < v.tope
}

type cupos struct {
	mu         sync.Mutex
	ahora      func() time.Time
	alta       ventana
	entrada    ventana
	porCuenta  map[string]*ventana // clave: tipo + cuenta
	avisado    map[string]time.Time
	rechazados map[string]int
}

func nuevosCupos(altaHora, entradaHora int, ahora func() time.Time) *cupos {
	return &cupos{ahora: ahora, alta: ventana{tope: altaHora}, entrada: ventana{tope: entradaHora},
		porCuenta: map[string]*ventana{}, avisado: map[string]time.Time{}, rechazados: map[string]int{}}
}

func (c *cupos) tope(nombre string, ahora time.Time) {
	c.rechazados[nombre]++
	if a, ok := c.avisado[nombre]; !ok || !ahora.Before(a.Add(time.Hour)) {
		c.avisado[nombre] = ahora
		log.Warn().Str("cupo", nombre).Msg("cuenta: tope de correos alcanzado; no se envía")
	}
}

func (c *cupos) cuenta(tipo, cuentaID string) *ventana {
	k := tipo + "/" + cuentaID
	v := c.porCuenta[k]
	if v == nil {
		v = &ventana{tope: porCuentaHora}
		c.porCuenta[k] = v
	}
	return v
}

// Alta: cupo (1).
func (c *cupos) Alta() bool {
	c.mu.Lock()
	defer c.mu.Unlock()
	ahora := c.ahora()
	if !c.alta.cabe(ahora) {
		c.tope("alta", ahora)
		return false
	}
	c.alta.marcas = append(c.alta.marcas, ahora)
	return true
}

// Entrada: cupo (2), el global y el de la cuenta; solo se gasta si caben los dos.
func (c *cupos) Entrada(cuentaID string) bool {
	c.mu.Lock()
	defer c.mu.Unlock()
	ahora := c.ahora()
	v := c.cuenta("entrada", cuentaID)
	if !c.entrada.cabe(ahora) {
		c.tope("entrada", ahora)
		return false
	}
	if !v.cabe(ahora) {
		c.tope("entrada-cuenta", ahora)
		return false
	}
	c.entrada.marcas = append(c.entrada.marcas, ahora)
	v.marcas = append(v.marcas, ahora)
	return true
}

// ConPrueba: cupo (3).
func (c *cupos) ConPrueba(cuentaID string) bool {
	c.mu.Lock()
	defer c.mu.Unlock()
	ahora := c.ahora()
	v := c.cuenta("prueba", cuentaID)
	if !v.cabe(ahora) {
		c.tope("prueba-cuenta", ahora)
		return false
	}
	v.marcas = append(v.marcas, ahora)
	return true
}

// Purgar quita las ventanas por cuenta vacías.
func (c *cupos) Purgar() {
	c.mu.Lock()
	defer c.mu.Unlock()
	ahora := c.ahora()
	for k, v := range c.porCuenta {
		if v.cabe(ahora) && len(v.marcas) == 0 {
			delete(c.porCuenta, k)
		}
	}
}
