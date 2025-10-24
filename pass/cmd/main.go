package main

import (
	"github.com/paxan/your-credential-helpers/credentials"
	"github.com/paxan/your-credential-helpers/pass"
)

func main() {
	credentials.Serve(pass.Pass{})
}
