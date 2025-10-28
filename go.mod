module github.com/paxan/your-credential-helpers

go 1.21

retract (
	v0.9.1 // osxkeychain: a regression caused backward-incompatibility with earlier versions
	v0.9.0 // osxkeychain: a regression caused backward-incompatibility with earlier versions
)

require (
	github.com/danieljoos/wincred v1.2.3
	github.com/keybase/go-keychain v0.0.1
)

require golang.org/x/sys v0.20.0 // indirect
