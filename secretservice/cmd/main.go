//go:build linux && cgo

package main

import (
	"github.com/paxan/your-credential-helpers/credentials"
	"github.com/paxan/your-credential-helpers/secretservice"
)

func main() {
	credentials.Serve(secretservice.Secretservice{})
}
