//go:build darwin && cgo

package main

import (
	"github.com/paxan/your-credential-helpers/credentials"
	"github.com/paxan/your-credential-helpers/osxkeychain"
)

func main() {
	credentials.Serve(osxkeychain.Osxkeychain{})
}
