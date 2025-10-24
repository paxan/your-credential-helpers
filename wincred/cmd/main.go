//go:build windows

package main

import (
	"github.com/paxan/your-credential-helpers/credentials"
	"github.com/paxan/your-credential-helpers/wincred"
)

func main() {
	credentials.Serve(wincred.Wincred{})
}
