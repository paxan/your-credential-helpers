//go:build darwin && cgo

package main

import (
	"github.com/paxan/your-credential-helpers/credentials"
	"github.com/paxan/your-credential-helpers/macoskeychain"
)

func main() {
	credentials.Serve(macoskeychain.MacOSKeychain{})
}
