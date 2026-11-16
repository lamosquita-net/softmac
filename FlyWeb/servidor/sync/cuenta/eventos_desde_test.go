// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

package cuenta

import (
	"encoding/json"
	"net/http"
	"testing"
)

// El cliente de FlyWeb manda «desde» como double («0.0», «1763322111.0»). Antes daba 400 «peticion».
func TestEventosDesdeConDecimalCero(t *testing.T) {
	b := nuevoBanco(t, nil)
	a := nuevoMac("A")
	b.crearCuenta(a, emailA, clave)
	for _, cuerpo := range []string{`{"desde":0.0}`, `{"desde":1763322111.0}`, `{"desde":5}`, `{}`} {
		esperar(t, b.conToken(a, "/eventos", json.RawMessage(cuerpo)), http.StatusOK, cuerpo)
	}
	for _, cuerpo := range []string{`{"desde":1.5}`, `{"desde":-1}`, `{"desde":"0"}`, `{"desde":1e300}`} {
		esperar(t, b.conToken(a, "/eventos", json.RawMessage(cuerpo)), http.StatusBadRequest, cuerpo)
	}
}
