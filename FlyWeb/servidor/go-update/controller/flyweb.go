// FlyWeb: local catalog and no redirects. See FlyWeb/servidor/README.md.
//
// FLYWEB_CATALOG_FILE=/path/catalog.json loads the extensions from a local JSON
// file (an array of extension.Extension, the same fields as the DynamoDB
// table) instead of DynamoDB, and reloads it on the usual ticker.
//
// FLYWEB_NO_REDIRECT=1 answers unknown components with
// "error-unknownApplication" instead of redirecting the browser to Brave's or
// Google's update servers.

package controller

import (
	"encoding/json/v2"
	"os"

	"github.com/brave/go-update/extension"
	"github.com/brave/go-update/logger"
)

func flywebCatalogFile() string {
	return os.Getenv("FLYWEB_CATALOG_FILE")
}

func flywebNoRedirect() bool {
	v := os.Getenv("FLYWEB_NO_REDIRECT")
	return v == "1" || v == "true"
}

func initExtensionUpdatesFromFile() {
	log := logger.New()
	path := flywebCatalogFile()
	data, err := os.ReadFile(path)
	if err != nil {
		log.Error("Failed to read catalog file", "path", path, "error", err)
		return
	}
	var extensions extension.Extensions
	if err := json.Unmarshal(data, &extensions); err != nil {
		log.Error("Failed to parse catalog file", "path", path, "error", err)
		return
	}
	for _, ext := range extensions {
		if ext.ID == "" || ext.Version == "" || ext.SHA256 == "" {
			log.Error("Skipping incomplete catalog entry", "id", ext.ID)
			continue
		}
		// Ensure Size is at least 1 as per Omaha v4 spec
		if ext.Size == 0 {
			ext.Size = 1
		}
		AllExtensionsMap.Store(ext.ID, ext)
	}
	log.Info("Extension refresh from file completed", "item_count", AllExtensionsMap.Len())

	cached, err := AllExtensionsMap.MarshalJSON()
	if err != nil {
		AllExtensionsCache.Invalidate()
		return
	}
	AllExtensionsCache.Set(cached)
}
