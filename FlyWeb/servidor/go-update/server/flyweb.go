// FlyWeb: listen addresses. See FlyWeb/servidor/README.md.
//
// Upstream listens on all interfaces (":8192" and the metrics on ":9090").
// FLYWEB_LISTEN (e.g. "127.0.0.1:8192") and FLYWEB_METRICS_LISTEN (e.g.
// "127.0.0.1:9090", or "off" to disable the metrics server) override them.

package server

import "os"

func flywebListen(upstream string) string {
	if v := os.Getenv("FLYWEB_LISTEN"); v != "" {
		return v
	}
	return upstream
}

// flywebMetricsListen returns "" when the metrics server must not start.
func flywebMetricsListen(upstream string) string {
	switch v := os.Getenv("FLYWEB_METRICS_LISTEN"); v {
	case "":
		return upstream
	case "off":
		return ""
	default:
		return v
	}
}
