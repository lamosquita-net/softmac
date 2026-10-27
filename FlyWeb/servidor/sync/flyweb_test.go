// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

// Pruebas propias de flyweb-sync (las de go-sync contra SQLite: pruebas/go-sync.sh).
package main

import (
	"bytes"
	"compress/gzip"
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"encoding/base64"
	"encoding/binary"
	"encoding/hex"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/brave/go-sync/cache"
	"github.com/brave/go-sync/datastore"
	"github.com/brave/go-sync/schema/protobuf/sync_pb"
	"google.golang.org/protobuf/proto"
)

func abrir(t *testing.T) *SQLite {
	t.Helper()
	db, err := AbrirSQLite(filepath.Join(t.TempDir(), "p.db"))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { db.Close() })
	return db
}

func entidad(id string, mtime, version int64) *datastore.SyncEntity {
	tipo := 32904
	dm := strconv.Itoa(tipo) + "#" + strconv.FormatInt(mtime, 10)
	f := false
	return &datastore.SyncEntity{ClientID: "c", ID: id, Mtime: &mtime, Ctime: &mtime, Version: &version,
		DataType: &tipo, DataTypeMtime: &dm, Folder: &f, Deleted: &f, Specifics: []byte{1}}
}

// Dos escrituras en el mismo milisegundo: la segunda pasa al siguiente, y la versión la sigue (commits) o no
// (entidades del servidor, versión 1). Así ningún token de GetUpdates se salta nada.
func TestRelojCreciente(t *testing.T) {
	db := abrir(t)
	ctx := context.Background()
	a, b, s := entidad("a", 1000, 1000), entidad("b", 1000, 1000), entidad("s", 1000, 1)
	for _, e := range []*datastore.SyncEntity{a, b, s} {
		if _, err := db.InsertSyncEntity(ctx, e); err != nil {
			t.Fatal(err)
		}
	}
	if *a.Mtime != 1000 || *b.Mtime != 1001 || *b.Version != 1001 || *s.Mtime != 1002 || *s.Version != 1 {
		t.Fatalf("mtime/versión: a=%d/%d b=%d/%d s=%d/%d", *a.Mtime, *a.Version, *b.Mtime, *b.Version, *s.Mtime, *s.Version)
	}
	if *b.DataTypeMtime != "32904#1001" {
		t.Fatalf("DataTypeMtime = %s", *b.DataTypeMtime)
	}
	// Actualizar «a» con un mtime antiguo: queda después de todo lo demás.
	u := entidad("a", 1000, 1000)
	if conflicto, _, err := db.UpdateSyncEntity(ctx, u, 1000); err != nil || conflicto {
		t.Fatalf("update: %v %v", conflicto, err)
	}
	if *u.Mtime != 1003 || *u.Version != 1003 {
		t.Fatalf("update mtime/versión = %d/%d", *u.Mtime, *u.Version)
	}
	// Lotes de 1: cada token avanza sin perder ni repetir.
	var vistos []string
	token := int64(0)
	for range 5 {
		mas, es, err := db.GetUpdatesForType(ctx, 32904, token, true, "c", 1)
		if err != nil {
			t.Fatal(err)
		}
		for _, e := range es {
			vistos = append(vistos, e.ID)
			token = *e.Mtime
		}
		if !mas {
			break
		}
	}
	if strings.Join(vistos, ",") != "b,s,a" {
		t.Fatalf("orden de GetUpdates = %v", vistos)
	}
}

func TestBorrarCaducados(t *testing.T) {
	db := abrir(t)
	ctx := context.Background()
	viejo, nuevo := entidad("h1", 1, 1), entidad("h2", 2, 2)
	pasado, futuro := time.Now().Unix()-10, time.Now().Unix()+1000
	viejo.ExpirationTime, nuevo.ExpirationTime = &pasado, &futuro
	for _, e := range []*datastore.SyncEntity{viejo, nuevo} {
		if _, err := db.InsertSyncEntity(ctx, e); err != nil {
			t.Fatal(err)
		}
	}
	if _, es, _ := db.GetUpdatesForType(ctx, 32904, 0, true, "c", 10); len(es) != 1 || es[0].ID != "h2" {
		t.Fatalf("GetUpdates debe ocultar lo caducado: %v", es)
	}
	if n, err := db.BorrarCaducados(ctx); err != nil || n != 1 {
		t.Fatalf("BorrarCaducados = %d, %v", n, err)
	}
}

func TestMemoria(t *testing.T) {
	ctx := context.Background()
	m := &Memoria{m: map[string]entrada{}}
	if n, _ := m.Incr(ctx, "k", false); n != 1 {
		t.Fatal("Incr desde vacío")
	}
	if n, _ := m.Incr(ctx, "k", true); n != 0 {
		t.Fatal("Decr")
	}
	m.Incr(ctx, "k", false)
	if v, _ := m.Get(ctx, "k", true); v != "1" {
		t.Fatalf("GetDel = %q", v)
	}
	if v, _ := m.Get(ctx, "k", false); v != "" {
		t.Fatal("GetDel no borró")
	}
	m.Set(ctx, "t", "x", time.Millisecond)
	time.Sleep(5 * time.Millisecond)
	if v, _ := m.Get(ctx, "t", false); v != "" {
		t.Fatal("no caduca")
	}
}

// --- De punta a punta por HTTP, con el token que genera Brave 1.57 (brave_sync_auth_manager.cc) ---

type cadena struct {
	pub  ed25519.PublicKey
	priv ed25519.PrivateKey
}

func nuevaCadena() cadena {
	pub, priv, _ := ed25519.GenerateKey(rand.Reader)
	return cadena{pub, priv}
}

// base64(hex(timestamp)|hex(firma)|hex(clave pública)), hex en mayúsculas como base::HexEncode.
func (c cadena) token() string {
	ts := []byte(strconv.FormatInt(time.Now().UnixMilli(), 10))
	t := strings.ToUpper(hex.EncodeToString(ts) + "|" + hex.EncodeToString(ed25519.Sign(c.priv, ts)) + "|" +
		hex.EncodeToString(c.pub))
	return base64.StdEncoding.EncodeToString([]byte(t))
}

func iniciar(t *testing.T) string {
	t.Helper()
	db := abrir(t)
	ctx, h := servidor(db, cache.NewCache(NuevaMemoria()))
	srv := httptest.NewUnstartedServer(h)
	srv.Config.BaseContext = func(net.Listener) context.Context { return ctx }
	srv.Start()
	t.Cleanup(srv.Close)
	return srv.URL
}

func enviar(t *testing.T, url, token string, m *sync_pb.ClientToServerMessage, gz bool) (*sync_pb.ClientToServerResponse, int) {
	t.Helper()
	b, _ := proto.Marshal(m)
	if gz {
		var buf bytes.Buffer
		w := gzip.NewWriter(&buf)
		w.Write(b)
		w.Close()
		b = buf.Bytes()
	}
	req, _ := http.NewRequest("POST", url+"/v2/command/", bytes.NewReader(b))
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	if gz {
		req.Header.Set("Content-Encoding", "gzip")
	}
	r, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer r.Body.Close()
	cuerpo, _ := io.ReadAll(r.Body)
	rsp := &sync_pb.ClientToServerResponse{}
	if r.StatusCode == 200 {
		if err := proto.Unmarshal(cuerpo, rsp); err != nil {
			t.Fatal(err)
		}
	}
	return rsp, r.StatusCode
}

func s(v string) *string { return &v }

const tipoPassword = 45873

func commitPassword(guid, blob string) *sync_pb.ClientToServerMessage {
	c := sync_pb.ClientToServerMessage_COMMIT
	return &sync_pb.ClientToServerMessage{Share: s(""), MessageContents: &c, Commit: &sync_pb.CommitMessage{
		CacheGuid: s(guid),
		Entries: []*sync_pb.SyncEntity{{IdString: s("c1"), Name: s("c1"), Version: proto.Int64(0),
			Specifics: &sync_pb.EntitySpecifics{SpecificsVariant: &sync_pb.EntitySpecifics_Password{
				Password: &sync_pb.PasswordSpecifics{Encrypted: &sync_pb.EncryptedData{KeyName: s("k"), Blob: s(blob)}}}}}}}}
}

func getUpdates(tipo int32) *sync_pb.ClientToServerMessage {
	g := sync_pb.ClientToServerMessage_GET_UPDATES
	o := sync_pb.SyncEnums_GU_TRIGGER
	tok := make([]byte, binary.MaxVarintLen64)
	binary.PutVarint(tok, 0)
	return &sync_pb.ClientToServerMessage{Share: s(""), MessageContents: &g, GetUpdates: &sync_pb.GetUpdatesMessage{
		FetchFolders: proto.Bool(true), GetUpdatesOrigin: &o,
		FromProgressMarker: []*sync_pb.DataTypeProgressMarker{{DataTypeId: proto.Int32(tipo), Token: tok}}}}
}

func blobsDe(rsp *sync_pb.ClientToServerResponse) []string {
	var out []string
	for _, e := range rsp.GetGetUpdates().GetEntries() {
		if p := e.GetSpecifics().GetPassword(); p != nil && !e.GetDeleted() {
			out = append(out, p.GetEncrypted().GetBlob())
		}
	}
	return out
}

func TestDePuntaAPunta(t *testing.T) {
	url := iniciar(t)
	yo, otro := nuevaCadena(), nuevaCadena()
	blob := base64.StdEncoding.EncodeToString([]byte("cifrado-por-el-navegador"))

	if _, code := enviar(t, url, "", commitPassword("A", blob), false); code != 401 {
		t.Fatalf("sin token: %d", code)
	}
	falso := cadena{yo.pub, otro.priv} // firma con otra clave
	if _, code := enviar(t, url, falso.token(), commitPassword("A", blob), false); code != 401 {
		t.Fatalf("firma falsa: %d", code)
	}
	rsp, code := enviar(t, url, yo.token(), commitPassword("Mac-A", blob), false)
	if code != 200 || rsp.GetErrorCode() != sync_pb.SyncEnums_SUCCESS ||
		rsp.GetCommit().GetEntryresponse()[0].GetResponseType() != sync_pb.CommitResponse_SUCCESS {
		t.Fatalf("commit: %d %v", code, rsp)
	}
	// Otro Mac de la misma cadena (en gzip, como puede mandar Chromium) recibe exactamente lo mismo, cifrado.
	rsp, _ = enviar(t, url, yo.token(), getUpdates(tipoPassword), true)
	if b := blobsDe(rsp); len(b) != 1 || b[0] != blob {
		t.Fatalf("Mac B recibe %v", b)
	}
	if b := blobsDe(func() *sync_pb.ClientToServerResponse {
		r, _ := enviar(t, url, otro.token(), getUpdates(tipoPassword), false)
		return r
	}()); len(b) != 0 {
		t.Fatalf("otra cadena ve datos ajenos: %v", b)
	}
	// Borrar los datos del servidor (Ajustes › Sincronizar › borrar): todo fuera y la cadena desactivada.
	csd := sync_pb.ClientToServerMessage_CLEAR_SERVER_DATA
	rsp, _ = enviar(t, url, yo.token(), &sync_pb.ClientToServerMessage{Share: s(""), MessageContents: &csd,
		ClearServerData: &sync_pb.ClearServerDataMessage{}}, false)
	if rsp.GetErrorCode() != sync_pb.SyncEnums_SUCCESS {
		t.Fatalf("clear: %v", rsp)
	}
	rsp, _ = enviar(t, url, yo.token(), getUpdates(tipoPassword), false)
	if rsp.GetErrorCode() != sync_pb.SyncEnums_DISABLED_BY_ADMIN {
		t.Fatalf("tras borrar, la cadena debe quedar desactivada: %v", rsp.GetErrorCode())
	}
}

func TestRutasYLimites(t *testing.T) {
	url := iniciar(t)
	for _, p := range []string{"/", "/metrics", "/health-check", "/debug/pprof/"} {
		r, err := http.Get(url + p)
		if err != nil {
			t.Fatal(err)
		}
		r.Body.Close()
		if r.StatusCode != 404 {
			t.Fatalf("%s = %d, debe ser 404", p, r.StatusCode)
		}
	}
	// Bomba gzip: 40 MB de ceros caben en ~40 KB comprimidos.
	var buf bytes.Buffer
	w, _ := gzip.NewWriterLevel(&buf, gzip.BestCompression)
	w.Write(make([]byte, 40<<20))
	w.Close()
	req, _ := http.NewRequest("POST", url+"/v2/command/", &buf)
	req.Header.Set("Authorization", "Bearer "+nuevaCadena().token())
	req.Header.Set("Content-Encoding", "gzip")
	r, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	r.Body.Close()
	if r.StatusCode != http.StatusRequestEntityTooLarge {
		t.Fatalf("bomba gzip = %d", r.StatusCode)
	}
}

func TestBorrarInactivas(t *testing.T) {
	db := abrir(t)
	ctx := context.Background()
	vieja := entidad("v", 1000, 1000)
	vieja.ClientID = "vieja"
	nueva := entidad("n", time.Now().UnixMilli(), 1)
	nueva.ClientID = "nueva"
	for _, e := range []*datastore.SyncEntity{vieja, nueva} {
		if _, err := db.InsertSyncEntity(ctx, e); err != nil {
			t.Fatal(err)
		}
	}
	n, err := db.BorrarInactivas(ctx, time.Now().AddDate(-1, 0, 0).UnixMilli())
	if err != nil || n != 1 {
		t.Fatalf("BorrarInactivas = %d, %v", n, err)
	}
	if ok, _ := db.HasItem(ctx, "vieja", "v"); ok {
		t.Fatal("la cadena inactiva sigue ahí")
	}
	if off, _ := db.IsSyncChainDisabled(ctx, "vieja"); !off {
		t.Fatal("la cadena borrada debe quedar desactivada")
	}
	if ok, _ := db.HasItem(ctx, "nueva", "n"); !ok {
		t.Fatal("ha borrado una cadena en uso")
	}
	if off, _ := db.IsSyncChainDisabled(ctx, "nueva"); off {
		t.Fatal("ha desactivado una cadena en uso")
	}
}
