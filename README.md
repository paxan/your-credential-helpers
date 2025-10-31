## Introduction

your-credential-helpers is a suite of programs to use native stores to keep
app-specific credentials safe.

## Installation

Go to the [Releases](https://github.com/paxan/your-credential-helpers/releases) page and download the binary that works better for you. Put that binary in your `$PATH`, so Docker can find it.

## Building

You can build the credential helpers using Docker:

```shell
$ export HELPER_PREFIX=myapp-credential
$ export HELPER_LABEL="MyApp Credentials"

# install emulators
$ docker run --privileged --rm tonistiigi/binfmt --install all

# create builder
$ docker buildx create --use

# build credential helpers from remote repository and output to ./bin/build
$ docker buildx bake "https://github.com/paxan/your-credential-helpers.git"

# or from local source
$ git clone https://github.com/paxan/your-credential-helpers.git
$ cd your-credential-helpers
$ docker buildx bake
```

Or if the toolchain is already installed on your machine:

1. Download the source.

```shell
$ git clone https://github.com/paxan/your-credential-helpers.git
$ cd your-credential-helpers
```

2.  Use `make` to build the program you want. That will leave an executable in the `bin` directory inside the repository.

```shell
$ make macoskeychain
```

3.  Put that binary in your `$PATH`, so Docker can find it.

```shell
$ cp bin/build/${HELPER_PREFIX}-macoskeychain /usr/local/bin/
```

## Usage

### With command line applications

The sub-package [client](https://godoc.org/github.com/paxan/your-credential-helpers/client) includes
functions to call external programs from your own command line applications.

There are three things you need to know if you need to interact with a helper:

1. The name of the program to execute, for instance `${HELPER_PREFIX}-macoskeychain`.
2. The server address to identify the credentials, for instance `https://example.com`.
3. The username and secret to store, when you want to store credentials.

You can see examples of each function in the [client](https://godoc.org/github.com/paxan/your-credential-helpers/client) documentation.

### Available programs

1. macoskeychain: Provides a helper to use the macOS keychain as credentials store.
2. secretservice: Provides a helper to use the D-Bus secret service as credentials store.
3. wincred: Provides a helper to use Windows credentials manager as store.
4. pass: Provides a helper to use `pass` as credentials store.

#### Note

`pass` needs to be configured for `${HELPER_PREFIX}-pass` to work properly.
It must be initialized with a `gpg2` key ID. Make sure your GPG key exists is in `gpg2` keyring as `pass` uses `gpg2` instead of the regular `gpg`.

## Development

A credential helper can be any program that can read values from the standard input. We use the first argument in the command line to differentiate the kind of command to execute. There are four valid values:

- `store`: Adds credentials to the keychain. The payload in the standard input is a JSON document with `ServerURL`, `Username` and `Secret`.
- `get`: Retrieves credentials from the keychain. The payload in the standard input is the raw value for the `ServerURL`.
- `erase`: Removes credentials from the keychain. The payload in the standard input is the raw value for the `ServerURL`.
- `list`: Lists stored credentials. There is no standard input payload.

This repository also includes libraries to implement new credentials programs in Go. Adding a new helper program is pretty easy. You can see how the macOS keychain helper works in the [macoskeychain](macoskeychain) directory.

1. Implement the interface `credentials.Helper` in `YOUR_PACKAGE/`
2. Create a main program in `YOUR_PACKAGE/cmd/`.
3. Add make tasks to build your program and run tests.

## License

MIT. See [LICENSE](LICENSE) for more information.
