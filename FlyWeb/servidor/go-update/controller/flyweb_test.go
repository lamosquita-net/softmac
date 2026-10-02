package controller

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestFlywebCatalogFile(t *testing.T) {
	path := filepath.Join(t.TempDir(), "catalog.json")
	catalog := `[
	  {"ID":"iodkpdagapdfkphljnddpjlldadblomo","Version":"1.0.123","SHA256":"abc","Title":"Brave Ad Block Updater","Size":42},
	  {"ID":"incomplete","Version":"","SHA256":""}
	]`
	if err := os.WriteFile(path, []byte(catalog), 0o600); err != nil {
		t.Fatal(err)
	}
	t.Setenv("FLYWEB_CATALOG_FILE", path)
	initExtensionUpdatesFromFile()

	ext, ok := AllExtensionsMap.Load("iodkpdagapdfkphljnddpjlldadblomo")
	if !ok || ext.Version != "1.0.123" || ext.Size != 42 {
		t.Fatalf("catalog entry not loaded: %+v %v", ext, ok)
	}
	if _, ok := AllExtensionsMap.Load("incomplete"); ok {
		t.Fatal("incomplete entry must be skipped")
	}
}

func TestFlywebNoRedirect(t *testing.T) {
	body := `{"request":{"protocol":"3.1","prodversion":"116.1.57.64","requestid":"{e821bacd-8dbf-4cc8-9e8c-bcbe8c1cfd3d}","@os":"mac","arch":"x64","app":[{"appid":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","version":"1.0.0","updatecheck":{}}]}}`
	post := func() *httptest.ResponseRecorder {
		req := httptest.NewRequest(http.MethodPost, "/extensions", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		UpdateExtensions(rec, req)
		return rec
	}

	// Upstream behaviour: a single unknown component is redirected elsewhere.
	if rec := post(); rec.Code != http.StatusTemporaryRedirect {
		t.Fatalf("without FLYWEB_NO_REDIRECT want 307, got %d", rec.Code)
	}

	t.Setenv("FLYWEB_NO_REDIRECT", "1")
	rec := post()
	if rec.Code != http.StatusOK {
		t.Fatalf("with FLYWEB_NO_REDIRECT want 200, got %d: %s", rec.Code, rec.Body.String())
	}
	if !strings.Contains(rec.Body.String(), "error-unknownApplication") {
		t.Fatalf("want error-unknownApplication, got %s", rec.Body.String())
	}
	if loc := rec.Header().Get("Location"); loc != "" {
		t.Fatalf("unexpected redirect to %s", loc)
	}
}
