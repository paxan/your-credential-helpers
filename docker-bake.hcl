variable "GO_VERSION" {
  default = null
}

# Defines the output folder
variable "DESTDIR" {
  default = ""
}

# Defines the credential helper prefix (required, no default)
variable "HELPER_PREFIX" {
  default = null
}

# Defines the credential helper label (required, no default)
variable "HELPER_LABEL" {
  default = null
}

function "bindir" {
  params = [defaultdir]
  result = DESTDIR != "" ? DESTDIR : "./bin/${defaultdir}"
}

target "_common" {
  args = {
    GO_VERSION = GO_VERSION
    HELPER_PREFIX = HELPER_PREFIX
    HELPER_LABEL = HELPER_LABEL
  }
}

group "default" {
  targets = ["binaries"]
}

group "validate" {
  targets = ["lint"]
}

target "lint" {
  inherits = ["_common"]
  target = "lint"
  output = ["type=cacheonly"]
}

target "test" {
  inherits = ["_common"]
  target = "test-coverage"
  output = [bindir("coverage")]
}

target "binaries" {
  inherits = ["_common"]
  target = "binaries"
  output = [bindir("build")]
  platforms = [
    "darwin/amd64",
    "darwin/arm64",
    "linux/amd64",
    "linux/arm64",
    "linux/arm/v7",
    "linux/arm/v6",
    "linux/ppc64le",
    "linux/s390x",
    "windows/amd64",
    "windows/arm64"
  ]
}

target "release" {
  inherits = ["binaries"]
  target = "release"
  output = [bindir("release")]
}
